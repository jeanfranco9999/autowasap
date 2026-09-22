import type { DataTable } from 'playwright-bdd';
import { Given, Then, When } from './fixtures';
import { normalizeText as normalize } from '../src/whatsapp';

/**
 * Fila que valida las imágenes de la respuesta: `[imagen]` pide al menos una,
 * y `[4 imágenes]` pide esa cantidad exacta. También valen foto y video.
 */
const IMAGE_ROW = /^\[\s*(\d+)?\s*(imagen|im[aá]genes|image|images|foto|fotos|video|videos)\s*\]$/i;

/** Lo que va entre asteriscos debe venir en negrita, como se escribe la negrita en WhatsApp. */
const BOLD_PART = /\*([^*]+)\*/g;

/**
 * Falla el paso con un mensaje claro. Se borra el rastro técnico (stack) para que
 * el reporte muestre solo la explicación y no fragmentos de código.
 */
function fallar(mensaje: string): never {
  const error = new Error(mensaje);
  error.stack = '';
  throw error;
}

/** Resultado de revisar una fila esperada. `problema` explica en palabras qué salió mal. */
interface Revision {
  esperado: string;
  nota: string;
  ok: boolean;
  problema?: string;
}

/** Qué tan parecidas son dos frases (0 a 1), contando las palabras que comparten. */
function parecido(a: string, b: string): number {
  const palabras = (s: string) => new Set(normalize(s).split(' ').filter((p) => p.length > 3));
  const [x, y] = [palabras(a), palabras(b)];
  if (!x.size || !y.size) return 0;
  const comunes = [...x].filter((p) => y.has(p)).length;
  return comunes / Math.max(x.size, y.size);
}

/** De todo lo que respondió el bot, la frase más parecida a la esperada. */
function masParecido(esperado: string, recibidas: string[]): string | undefined {
  let mejor: { texto: string; puntaje: number } | undefined;
  for (const texto of recibidas) {
    const puntaje = parecido(esperado, texto);
    if (puntaje > 0.35 && (!mejor || puntaje > mejor.puntaje)) mejor = { texto, puntaje };
  }
  return mejor?.texto;
}

// ---------- Given: ir al chat del bot ----------

Given(/^se dirige al (?:whatsapp|whastapp) del bot "([^"]+)"$/i, async ({ whatsapp }, phone: string) => {
  await whatsapp.openChat(phone);
});

// ---------- When: lo que se escribe en el chat ----------

When(
  /^(?:el )?(?:usuario|bot) escribe en el chat "([^"]*)"$/i,
  async ({ whatsapp }, text: string) => {
    await whatsapp.sendMessage(text);
  },
);

When(/^usuario hace clic en el botón "([^"]+)"$/i, async ({ whatsapp }, label: string) => {
  await whatsapp.clickButton(label);
});

// ---------- Then: lo que responde el bot ----------

/**
 * Valida a dónde lleva el botón de enlace que se acaba de pulsar. Si la URL del botón
 * es un enlace acortado, se sigue hasta su destino. El enlace no se abre.
 */
Then(/^el botón lleva a "([^"]+)"$/i, async ({ whatsapp }, esperado: string) => {
  const { shown, final } = await whatsapp.readLinkPopup();
  await whatsapp.closeOpenList();
  // Se compara sin los parámetros de seguimiento, que cambian en cada visita (?utm=, ?srsltid=).
  const sinParametros = (url: string) => url.split('?')[0];
  const ok =
    shown.includes(esperado) ||
    final.includes(esperado) ||
    sinParametros(final) === sinParametros(esperado) ||
    sinParametros(shown) === sinParametros(esperado);

  if (!ok) {
    fallar(`EL BOTÓN LLEVA A OTRA PÁGINA.\n   Debía llevar a: ${esperado}\n   Y lleva a:      ${final}`);
  }
});

/**
 * Sigue el enlace del botón hasta el chat de WhatsApp al que deriva, lo abre y
 * valida de quién es. Se usa al final del escenario, porque cambia de chat.
 */
Then(/^el botón abre el chat de WhatsApp de "([^"]+)"$/i, async ({ whatsapp, $testInfo }, esperado: string) => {
  const { name, phone } = await whatsapp.openChatFromLink();
  await $testInfo.attach('Chat al que deriva el botón', {
    body: `${name} (${phone})`,
    contentType: 'text/plain',
  });
  // El número identifica el chat; el nombre solo aparece si el contacto está guardado.
  const soloNumeros = (s: string) => s.replace(/\D/g, '');
  const ok = soloNumeros(esperado)
    ? soloNumeros(phone).endsWith(soloNumeros(esperado))
    : normalize(name).includes(normalize(esperado));

  if (!ok) {
    fallar(
      `EL BOTÓN ABRE OTRO CHAT.\n   Debía abrir el chat de: ${esperado}\n   Y abrió el de: ${name} (${phone})`,
    );
  }
});

/**
 * Valida el contenido de la lista de opciones que abre un botón del bot.
 * Cada fila de la tabla debe aparecer en la lista; al terminar, la lista se cierra.
 */
Then('la lista muestra', async ({ whatsapp, $testInfo }, table: DataTable) => {
  const textoLista = await whatsapp.readOpenList();
  const recibido = normalize(textoLista);
  const lineas = textoLista.split('\n').filter((l) => l.trim());

  const revisiones: Revision[] = table
    .raw()
    .filter((fila) => fila[0]?.trim())
    .map(([esperado]) => {
      if (recibido.includes(normalize(esperado))) return { esperado, nota: '', ok: true };
      const similar = masParecido(esperado, lineas);
      return {
        esperado,
        nota: '',
        ok: false,
        problema: similar
          ? `ESTA OPCIÓN DICE OTRA COSA.\n   Debía decir: ${esperado}\n   Y dice:      ${similar}`
          : `FALTA ESTA OPCIÓN EN LA LISTA: ${esperado}`,
      };
    });

  await $testInfo.attach('Revisión de la lista de opciones', {
    body: resumen(revisiones, textoLista, 'La lista mostró:'),
    contentType: 'text/plain',
  });
  await whatsapp.closeOpenList();
  reportar(revisiones, 'la lista de opciones');
});

/**
 * Cada fila de la tabla es un texto que debe aparecer en la respuesta (primera columna).
 * Las demás columnas son notas (ej. pantalla de Figma) y solo se muestran en el reporte.
 */
Then('el bot responde', async ({ whatsapp, $testInfo }, table: DataTable) => {
  const respuesta = whatsapp.lastReply;
  if (!respuesta) {
    throw new Error('Todavía no hay respuesta del bot. Usa antes: When usuario escribe en el chat "..."');
  }

  const recibido = normalize([respuesta.text, ...respuesta.buttons].join(' '));
  const negritasRecibidas = respuesta.bold.map(normalize);
  const lineas = [...respuesta.text.split('\n'), ...respuesta.buttons].filter((l) => l.trim());

  const revisiones: Revision[] = table
    .raw()
    .filter((fila) => fila[0]?.trim())
    .map(([esperado, ...notas]) => {
      const nota = notas.filter(Boolean).join(' | ');

      // Fila [imagen] o [4 imágenes]: el bot debe haber enviado esas fotos o videos.
      const filaImagen = IMAGE_ROW.exec(esperado.trim());
      if (filaImagen) {
        const pedidas = filaImagen[1] ? Number(filaImagen[1]) : 1;
        const llegaron = respuesta.images;
        if (filaImagen[1] ? llegaron === pedidas : llegaron >= 1) {
          return { esperado, nota, ok: true };
        }
        return {
          esperado,
          nota,
          ok: false,
          problema: llegaron
            ? `LLEGARON ${llegaron} IMÁGENES Y SE ESPERABAN ${pedidas}.`
            : 'FALTA LA IMAGEN: el bot no envió ninguna foto ni video.',
        };
      }

      const negritas = [...esperado.matchAll(BOLD_PART)].map((m) => m[1]);
      const textoPlano = esperado.replace(BOLD_PART, '$1');

      // 1) ¿Está el texto?
      if (!recibido.includes(normalize(textoPlano))) {
        const similar = masParecido(textoPlano, lineas);
        return {
          esperado,
          nota,
          ok: false,
          problema: similar
            ? `EL TEXTO ES DISTINTO.\n   Debía decir: ${textoPlano}\n   Y dice:      ${similar}`
            : `FALTA ESTE TEXTO: ${textoPlano}`,
        };
      }

      // 2) El texto está: ¿vienen en negrita las partes marcadas con *asteriscos*?
      const sinNegrita = negritas.filter((parte) => !negritasRecibidas.some((b) => b.includes(normalize(parte))));
      if (sinNegrita.length) {
        return {
          esperado,
          nota,
          ok: false,
          problema:
            `FALTA LA NEGRITA en: ${sinNegrita.join(' | ')}\n` +
            `   El texto sí llegó, pero el bot no lo envió en negrita.`,
        };
      }

      return { esperado, nota, ok: true };
    });

  revisiones.push(...textoDeMas(revisiones, lineas));

  await $testInfo.attach(`Revisión de la respuesta a "${respuesta.trigger}"`, {
    body: resumen(revisiones, textoDeLaRespuesta(respuesta), 'El bot respondió:'),
    contentType: 'text/plain',
  });

  // Se revisan todas las filas y se informan juntas todas las que no coinciden.
  reportar(revisiones, `la respuesta a "${respuesta.trigger}"`);
});

/**
 * Busca lo que el bot envió y no está en ninguna fila del escenario. Una línea se da
 * por cubierta si alguna fila la contiene o está contenida en ella (las filas suelen
 * ser un fragmento de la burbuja).
 */
function textoDeMas(revisiones: Revision[], lineas: string[]): Revision[] {
  const esperados = revisiones
    .map((r) => normalize(r.esperado.replace(BOLD_PART, '$1')))
    .filter((e) => e && !IMAGE_ROW.test(e));

  return lineas
    .map((linea) => normalize(linea))
    .filter((linea) => linea.length > 2)
    .filter((linea, i, todas) => todas.indexOf(linea) === i)
    .filter((linea) => !esperados.some((e) => e.includes(linea) || linea.includes(e)))
    // Si la línea se parece a una fila esperada, ya se informó como "EL TEXTO ES DISTINTO".
    .filter((linea) => !masParecido(linea, esperados))
    .map((linea) => ({
      esperado: linea,
      nota: '',
      ok: false,
      problema: `SOBRA ESTE TEXTO: ${linea}\n   El bot lo envió, pero no está en el escenario.`,
    }));
}

/** Si alguna fila no coincide, falla el paso enumerando todos los problemas. */
function reportar(revisiones: Revision[], que: string): void {
  const errores = revisiones.filter((r) => !r.ok);
  if (!errores.length) return;
  const detalle = errores.map((r, i) => `${i + 1}) ${r.problema}`).join('\n\n');
  fallar(`${errores.length} de ${revisiones.length} revisiones fallaron en ${que}:\n\n${detalle}`);
}

/** Texto completo de la respuesta, tal como se muestra en el reporte. */
function textoDeLaRespuesta(respuesta: { text: string; buttons: string[]; images: number }): string {
  return [
    respuesta.images ? `[${respuesta.images} imagen(es)]` : '',
    respuesta.text,
    respuesta.buttons.length ? `Botones: ${respuesta.buttons.join('  |  ')}` : '',
  ]
    .filter(Boolean)
    .join('\n');
}

/** Arma el texto que se adjunta al reporte: primero el resultado, luego el detalle. */
function resumen(revisiones: Revision[], recibido: string, titulo: string): string {
  const errores = revisiones.filter((r) => !r.ok);
  const encabezado = errores.length
    ? `RESULTADO: ${errores.length} de ${revisiones.length} no coinciden\n`
    : `RESULTADO: todo correcto (${revisiones.length} de ${revisiones.length})\n`;

  const detalle = revisiones
    .map((r) =>
      r.ok
        ? `✔ ${r.esperado}${r.nota ? `   (${r.nota})` : ''}`
        : `✘ ${r.problema}${r.nota ? `\n   Nota: ${r.nota}` : ''}`,
    )
    .join('\n');

  return `${encabezado}\n${detalle}\n\n------------------------------\n${titulo}\n${recibido}\n`;
}
