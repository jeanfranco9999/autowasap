import fs from 'node:fs';
import path from 'node:path';
import type { Page, TestInfo } from '@playwright/test';
import { config, normalizePhone } from './config';
import { sel } from './selectors';
import { WHATSAPP_URL } from './session';

export interface BotMessage {
  text: string;
  buttons: string[];
  /** Fragmentos que el bot envió en negrita. */
  bold: string[];
  /** Cuántas fotos o videos trae el mensaje. */
  images: number;
}

export interface BotReply {
  /** Lo que se envió para provocar esta respuesta. */
  trigger: string;
  messages: BotMessage[];
  /** Texto de todas las burbujas juntas (con emojis). */
  text: string;
  /** Botones de todas las burbujas juntas. */
  buttons: string[];
  /** Fragmentos en negrita de todas las burbujas juntas. */
  bold: string[];
  /** Cuántas fotos o videos trae la respuesta completa. */
  images: number;
}

/** Un mensaje del chat tal como se lee de la página. */
interface ChatMessage extends BotMessage {
  id: string;
  outgoing: boolean;
  /** false si WhatsApp aún no lo dibuja (mensaje fuera de pantalla). */
  loaded: boolean;
}

/** Compara textos sin importar mayúsculas, espacios ni el selector de emoji U+FE0F. */
export const normalizeText = (s: string) =>
  s.replace(/️/g, '').replace(/\s+/g, ' ').trim().toLowerCase();

/** Selectores que usan las funciones que corren dentro de la página. */
const pageSel = {
  message: sel.message,
  loaded: sel.messageLoaded,
  text: sel.messageText,
  meta: sel.messageMeta,
  status: sel.messageStatus,
  buttons: sel.messageButtons,
  image: sel.messageImage,
  bold: sel.messageBold,
};

export class WhatsAppPage {
  private chatReady = false;
  private captureCount = 0;
  /** data-id de los mensajes que ya existían antes del último envío. */
  private seen = new Set<string>();
  /** data-id del último mensaje enviado: la respuesta es lo que llega debajo de él. */
  private anchorId?: string;
  lastReply?: BotReply;

  constructor(
    private readonly page: Page,
    private readonly testInfo: TestInfo,
  ) {}

  /** Abre directamente el chat con el número indicado. */
  async openChat(phone: string): Promise<void> {
    const botPhone = normalizePhone(phone);
    const chatUrl = `${WHATSAPP_URL}/send?phone=${botPhone}`;
    await this.page.goto(chatUrl);

    const composer = this.page.locator(sel.composer);
    const qr = this.page.locator(sel.qrCode);
    const invalidNumber = this.page
      .locator(sel.dialog)
      .filter({ hasText: /no es válido|not valid|invalid/i });

    const useHere = this.page.locator(sel.useHereButton);
    const ready = composer.or(qr).or(invalidNumber);

    await ready.or(useHere).first().waitFor({ timeout: 90_000 });
    // "WhatsApp está abierto en otra ventana": tomar el control en esta pestaña.
    if (await useHere.first().isVisible()) {
      await useHere.first().click();
      await this.page.goto(chatUrl);
      await ready.first().waitFor({ timeout: 90_000 });
    }

    if (await qr.first().isVisible()) {
      throw new Error('La sesión de WhatsApp expiró o se desvinculó. Ejecuta: npm run login');
    }
    if (await invalidNumber.first().isVisible()) {
      await this.capture(`numero invalido ${botPhone}`);
      throw new Error(`El número ${botPhone} no tiene WhatsApp o no es válido.`);
    }
    this.chatReady = true;
  }

  /** Escribe un mensaje, espera la respuesta del bot y la captura. */
  async sendMessage(text: string): Promise<BotReply> {
    this.ensureChat();
    await this.waitUntilQuiet();
    this.seen = new Set((await this.readMessages()).map((m) => m.id));
    this.anchorId = undefined;

    const composer = this.page.locator(sel.composer);
    await composer.click();
    await composer.pressSequentially(text, { delay: 15 });
    await this.page.keyboard.press('Enter');

    this.anchorId = await this.waitForSentMessage(text);
    return this.waitForReply(text);
  }

  /**
   * Hace clic en un botón de la última respuesta del bot. Si abre una lista de
   * opciones, la deja abierta para validarla; si en cambio envía un mensaje,
   * espera la respuesta del bot.
   */
  async clickButton(label: string): Promise<void> {
    this.ensureChat();
    // Se marca el botón dentro de la página: su texto visible no coincide con el
    // texto del HTML, que incluye el nombre interno del ícono (ic-...).
    const marked = await this.page.evaluate(
      ({ s, label }) => {
        document.querySelectorAll(`[${'data-qa-click'}]`).forEach((el) => el.removeAttribute('data-qa-click'));
        const wanted = label.replace(/️/g, '').replace(/\s+/g, ' ').trim().toLowerCase();
        const buttons = Array.from(document.querySelectorAll(`${s.message} ${s.buttons}`)).filter(
          (b) => !b.closest(s.meta) && !b.querySelector(s.image) && !b.querySelector(s.text),
        );
        for (const b of buttons.reverse()) {
          let out = '';
          const walker = document.createTreeWalker(b, NodeFilter.SHOW_TEXT | NodeFilter.SHOW_ELEMENT);
          let node = walker.nextNode();
          while (node) {
            if (node.nodeType === Node.TEXT_NODE) {
              if (!node.parentElement?.closest('svg')) out += node.textContent ?? '';
            } else if ((node as Element).tagName === 'IMG') {
              out += (node as Element).getAttribute('data-plain-text') ?? (node as Element).getAttribute('alt') ?? '';
            }
            node = walker.nextNode();
          }
          if (out.replace(/️/g, '').replace(/\s+/g, ' ').trim().toLowerCase() === wanted) {
            b.setAttribute('data-qa-click', '1');
            return true;
          }
        }
        return false;
      },
      { s: pageSel, label },
    );

    if (!marked) {
      await this.capture(`sin boton ${label}`);
      throw new Error(`No se encontró el botón "${label}" en la respuesta del bot.`);
    }
    await this.page.locator('[data-qa-click="1"]').click();
    await this.page.waitForTimeout(1_500);
    await this.capture(`clic en ${label}`);
  }

  /** Texto de la lista de opciones que está abierta (la que abre un botón del bot). */
  async readOpenList(): Promise<string> {
    const list = this.page.locator(sel.dialog).last();
    if (!(await list.isVisible())) {
      throw new Error('No hay ninguna lista de opciones abierta.');
    }
    const text = await list.innerText();
    await this.testInfo.attach('Opciones que mostró la lista', { body: text, contentType: 'text/plain' });
    return text;
  }

  /**
   * Lee el aviso "¿Deseas abrir este enlace?" que WhatsApp muestra al pulsar un botón
   * de enlace. Devuelve la URL mostrada y, si es un enlace acortado, a dónde lleva.
   * No abre el enlace: solo lo consulta.
   */
  async readLinkPopup(): Promise<{ shown: string; final: string }> {
    const popup = this.page.locator(sel.popupUrl).last();
    if (!(await popup.isVisible().catch(() => false))) {
      await this.capture('sin aviso de enlace');
      throw new Error('El botón no abrió ningún enlace.');
    }
    const shown = (await popup.innerText()).trim();
    let final = shown;
    try {
      const response = await this.page.request.get(shown, { maxRedirects: 10, timeout: 20_000 });
      final = response.url();
    } catch {
      // Si no se puede resolver (sin red, enlace caído), queda la URL mostrada.
    }
    await this.testInfo.attach('Enlace al que lleva el botón', {
      body: shown === final ? shown : `${shown}\n→ ${final}`,
      contentType: 'text/plain',
    });
    return { shown, final };
  }

  /**
   * Sigue el enlace del botón recién pulsado hasta el chat de WhatsApp al que deriva,
   * lo abre y devuelve el nombre que muestra ese chat.
   */
  async openChatFromLink(): Promise<{ name: string; phone: string }> {
    const { final } = await this.readLinkPopup();
    const phone = new URL(final).searchParams.get('phone');
    if (!phone) {
      throw new Error(`El botón no lleva a un chat de WhatsApp, lleva a "${final}".`);
    }
    await this.closeOpenList();
    await this.openChat(phone);
    const header = await this.page.locator(sel.chatHeader).first().innerText();
    const name = header.split('\n')[0].trim();
    await this.capture(`chat de destino ${name}`);
    return { name, phone };
  }

  /** Cierra la lista de opciones abierta, si la hay. */
  async closeOpenList(): Promise<void> {
    if (await this.page.locator(sel.dialog).last().isVisible().catch(() => false)) {
      await this.page.keyboard.press('Escape');
      await this.page.waitForTimeout(500);
    }
  }

  private ensureChat() {
    if (!this.chatReady) {
      throw new Error('Primero abre el chat con: Given se dirige al WhatsApp del bot "<número>"');
    }
  }

  /**
   * Lee los mensajes del chat en orden. El texto incluye los emojis, que WhatsApp
   * dibuja como <img data-plain-text="👇">.
   */
  private async readMessages(): Promise<ChatMessage[]> {
    return this.page.evaluate((s) => {
      return Array.from(document.querySelectorAll(s.message)).map((el) => {
        const bodies = Array.from(el.querySelectorAll(s.text)).filter((b) => !b.parentElement?.closest(s.text));
        // Se descartan la hora del mensaje y la imagen (que también es clicable).
        const buttonEls = Array.from(el.querySelectorAll(s.buttons)).filter(
          (b) => !b.closest(s.meta) && !b.querySelector(s.image) && !b.querySelector(s.text),
        );
        const boldEls = Array.from(el.querySelectorAll(s.bold));
        // Recorre texto e imágenes-emoji de cada elemento, en orden.
        const texts = [...bodies, ...buttonEls, ...boldEls].map((root) => {
          let out = '';
          const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT | NodeFilter.SHOW_ELEMENT);
          let node = walker.nextNode();
          while (node) {
            // Se ignoran los nombres internos de íconos SVG (<title>ic-...</title>).
            if (node.nodeType === Node.TEXT_NODE) {
              if (!node.parentElement?.closest('svg')) out += node.textContent ?? '';
            }
            else if ((node as Element).tagName === 'IMG') {
              // Solo los emojis aportan texto; la foto repite el pie en su atributo alt.
              out += (node as Element).getAttribute('data-plain-text') ?? '';
            } else if ((node as Element).tagName === 'BR') out += '\n';
            else {
              // Número o viñeta de una lista ("1. "): WhatsApp lo dibuja, no es texto.
              // El mismo atributo lleva la hora del mensaje, por eso se exige un marcador.
              const marker = (node as Element).getAttribute('data-pre-plain-text');
              if (marker && /^\s*(\d+[.)]|[-•*])\s*$/.test(marker)) out += `${marker.trim()} `;
            }
            node = walker.nextNode();
          }
          return out.replace(/[ \t]+\n/g, '\n').trim();
        });
        const buttons = texts.slice(bodies.length, bodies.length + buttonEls.length).filter((t) => t.length > 0);
        const bold = texts.slice(bodies.length + buttonEls.length).filter((t) => t.length > 0);
        return {
          bold: [...new Set(bold)],
          id: el.getAttribute('data-id') ?? '',
          outgoing: !!el.querySelector(s.status),
          loaded: !!el.querySelector(s.loaded),
          images: el.querySelectorAll(s.image).length,
          text: texts.slice(0, bodies.length).join('\n'),
          buttons: [...new Set(buttons)],
        };
      });
    }, pageSel);
  }

  /** Espera a que el mensaje enviado aparezca en el chat y devuelve su data-id. */
  private async waitForSentMessage(text: string): Promise<string> {
    const deadline = Date.now() + 15_000;
    while (Date.now() < deadline) {
      const sent = (await this.readMessages())
        .filter((m) => m.outgoing && !this.seen.has(m.id) && normalizeText(m.text) === normalizeText(text))
        .pop();
      if (sent) return sent.id;
      await this.page.waitForTimeout(300);
    }
    await this.capture(`no enviado ${text}`);
    throw new Error(`El mensaje "${text}" no apareció en el chat. ¿Se envió?`);
  }

  /** Mensajes del bot que llegaron debajo del último mensaje enviado. */
  private async readReply(): Promise<ChatMessage[]> {
    const all = await this.readMessages();
    const start = all.findIndex((m) => m.id === this.anchorId);
    return all.slice(start + 1).filter((m) => !m.outgoing && m.loaded);
  }

  /**
   * Espera a que el chat quede tranquilo antes de escribir: si el bot todavía está
   * enviando la respuesta del paso anterior, esos mensajes no deben contarse como
   * respuesta del siguiente.
   */
  private async waitUntilQuiet(): Promise<void> {
    const deadline = Date.now() + config.replyTimeoutMs;
    let lastSignature = '';
    let lastChange = Date.now();
    while (Date.now() < deadline) {
      const signature = (await this.readMessages()).map((m) => m.id).join(',');
      if (signature !== lastSignature) {
        lastSignature = signature;
        lastChange = Date.now();
      } else if (Date.now() - lastChange >= config.replyMinWaitMs && !(await this.isBotTyping())) {
        return;
      }
      await this.page.waitForTimeout(500);
    }
  }

  /** true si el bot ya envió su mensaje de cierre del flujo (no llegará nada más). */
  private endsFlow(messages: BotMessage[]): boolean {
    const text = messages.map((m) => m.text).join('\n').toLowerCase();
    return config.endMarkers.some((marker) => text.includes(marker.toLowerCase()));
  }

  /** true mientras el chat muestra "escribiendo..." / "typing...". */
  private async isBotTyping(): Promise<boolean> {
    const status = (await this.page.locator(sel.chatHeader).first().innerText().catch(() => '')) ?? '';
    return /escribiendo|typing|grabando|recording/i.test(status);
  }

  /**
   * Espera siempre al menos REPLY_MIN_WAIT_SECONDS, y además a que llegue al menos un
   * mensaje del bot y deje de escribir (sin mensajes nuevos durante
   * REPLY_SETTLE_SECONDS). Luego toma el screenshot.
   */
  private async waitForReply(trigger: string): Promise<BotReply> {
    const start = Date.now();
    const deadline = start + config.replyTimeoutMs;
    // WhatsApp vacía las burbujas que quedan fuera de pantalla, así que se guarda
    // lo leído de cada mensaje (por data-id) y no solo la última lectura.
    const collected = new Map<string, BotMessage>();
    let messages: BotMessage[] = [];
    let lastSignature = '';
    let lastChange = start;

    while (Date.now() < deadline) {
      for (const m of await this.readReply()) {
        const previous = collected.get(m.id);
        collected.set(m.id, {
          text: m.text || previous?.text || '',
          buttons: m.buttons.length ? m.buttons : previous?.buttons ?? [],
          bold: m.bold.length ? m.bold : previous?.bold ?? [],
          images: Math.max(m.images, previous?.images ?? 0),
        });
      }
      messages = [...collected.values()].filter((m) => m.text || m.buttons.length || m.images);

      const signature = JSON.stringify(messages);
      const now = Date.now();
      if (signature !== lastSignature) {
        lastSignature = signature;
        lastChange = now;
      } else if (
        messages.length > 0 &&
        !(await this.isBotTyping()) &&
        now - start >= config.replyMinWaitMs &&
        (now - lastChange >= config.replySettleMs || this.endsFlow(messages))
      ) {
        break;
      }
      await this.page.waitForTimeout(500);
    }

    await this.capture(trigger);

    if (messages.length === 0) {
      throw new Error(
        `El bot no respondió a "${trigger}" en ${config.replyTimeoutMs / 1000} segundos.`,
      );
    }

    this.lastReply = {
      trigger,
      messages,
      text: messages.map((m) => m.text).join('\n'),
      buttons: messages.flatMap((m) => m.buttons),
      bold: messages.flatMap((m) => m.bold),
      images: messages.reduce((total, m) => total + m.images, 0),
    };
    await this.testInfo.attach(`Lo que respondió el bot a "${trigger}"`, {
      body:
        (this.lastReply.images ? `[${this.lastReply.images} imagen(es)]\n` : '') +
        this.lastReply.text +
        (this.lastReply.buttons.length ? `\n\n[Botones] ${this.lastReply.buttons.join(' | ')}` : '') +
        (this.lastReply.bold.length ? `\n[Negritas] ${this.lastReply.bold.join(' | ')}` : ''),
      contentType: 'text/plain',
    });
    return this.lastReply;
  }

  /**
   * Screenshot de la interacción: desde el mensaje enviado hasta el último mensaje del bot.
   * Si no cabe en pantalla, agranda temporalmente la ventana. Se adjunta al reporte
   * y se guarda en test-results/screenshots/.
   */
  async capture(label: string): Promise<void> {
    this.captureCount += 1;

    // Espera a que carguen las imágenes del chat (máx. 5 s).
    await this.page
      .waitForFunction(
        (message) =>
          Array.from(document.querySelectorAll<HTMLImageElement>(`${message} img`)).every((i) => i.complete),
        sel.message,
        { timeout: 5_000 },
      )
      .catch(() => {});

    const dialogo = this.page.locator(sel.dialog).last();
    const body = (await dialogo.isVisible().catch(() => false))
      ? await this.captureDialog()
      : this.anchorId
        ? await this.captureInteraction(this.anchorId)
        : await this.page.locator(sel.conversation).screenshot().catch(() => this.page.screenshot());

    const name = `${String(this.captureCount).padStart(2, '0')}-${safeName(label)}`;
    // Nombre corto para el reporte; el archivo conserva el nombre completo.
    const corto = safeName(label).slice(0, 40);
    await this.testInfo.attach(`Captura ${this.captureCount}: ${corto}${corto.length === 40 ? '…' : ''}`, {
      body,
      contentType: 'image/png',
    });

    const [feature, scenario] = this.testInfo.titlePath.slice(-2).map(safeName);
    const dir = path.join(config.screenshotsDir, feature, scenario);
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(path.join(dir, `${name}.png`), body);
  }

  /** Recorta la pantalla desde el mensaje `anchorId` hasta el último mensaje del chat. */
  /**
   * Captura la ventana que está abierta (la lista de opciones o el aviso de un enlace).
   * Si su contenido tiene scroll, agranda la ventana para que salga completo.
   */
  private async captureDialog(): Promise<Buffer> {
    const dialogo = this.page.locator(sel.dialog).last();
    const original = await this.page.evaluate(() => ({ width: window.innerWidth, height: window.innerHeight }));

    const necesario = await dialogo.evaluate((el) => {
      // Dentro del diálogo, el elemento que se desplaza es el que tiene contenido oculto.
      const conScroll = Array.from(el.querySelectorAll('*')).find((n) => n.scrollHeight > n.clientHeight + 20);
      if (conScroll) conScroll.scrollTop = 0; // empezar desde la primera opción
      const oculto = conScroll ? conScroll.scrollHeight - conScroll.clientHeight : 0;
      return Math.ceil(el.getBoundingClientRect().height + oculto) + 200;
    });

    const agrandar = necesario > original.height;
    if (agrandar) {
      await this.page.setViewportSize({ width: original.width, height: Math.min(necesario, 4000) });
      await this.page.waitForTimeout(600);
    }
    const shot = await dialogo.screenshot();
    if (agrandar) await this.page.setViewportSize(original);
    return shot;
  }

  private async captureInteraction(anchorId: string): Promise<Buffer> {
    const MARGIN = 12;
    const measure = () =>
      this.page.evaluate(
        ({ message, anchorId }) => {
          const all = Array.from(document.querySelectorAll(message));
          const anchor = all.find((m) => m.getAttribute('data-id') === anchorId);
          const last = all[all.length - 1];
          if (!anchor || !last) return null;
          // Contenedor con scroll de la conversación.
          let panel: HTMLElement | null = anchor.parentElement;
          while (panel && !/(auto|scroll)/.test(getComputedStyle(panel).overflowY)) panel = panel.parentElement;
          panel = panel ?? document.querySelector<HTMLElement>('#main');
          if (!panel) return null;
          last.scrollIntoView({ block: 'end' });
          const p = panel.getBoundingClientRect();
          const a = anchor.getBoundingClientRect();
          const l = last.getBoundingClientRect();
          return { panelTop: p.top, panelBottom: p.bottom, left: p.left, width: p.width, top: a.top, bottom: l.bottom };
        },
        { message: sel.message, anchorId },
      );

    let m = await measure();
    if (!m) return this.page.locator(sel.conversation).screenshot();

    // Si la interacción es más alta que el panel, agranda la ventana lo necesario.
    const original = await this.page.evaluate(() => ({ width: window.innerWidth, height: window.innerHeight }));
    const missing = m.bottom - m.top + 2 * MARGIN - (m.panelBottom - m.panelTop);
    if (missing > 0) {
      await this.page.setViewportSize({ width: original.width, height: Math.ceil(original.height + missing) });
      await this.page.waitForTimeout(800);
      m = (await measure()) ?? m;
    }
    await this.page.waitForTimeout(300);
    m = (await measure()) ?? m;

    const top = Math.max(0, m.panelTop, m.top - MARGIN);
    const bottom = Math.min(m.panelBottom, m.bottom + MARGIN);
    const shot = await this.page.screenshot({
      clip: { x: m.left, y: top, width: m.width, height: Math.max(1, bottom - top) },
    });

    if (missing > 0) await this.page.setViewportSize(original);
    return shot;
  }
}

function safeName(s: string): string {
  return s.replace(/[<>:"/\\|?*\x00-\x1f]/g, '').replace(/\s+/g, ' ').trim().slice(0, 80) || 'sin-nombre';
}

function escapeRegExp(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
