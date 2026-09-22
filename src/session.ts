import { chromium, type BrowserContext } from '@playwright/test';
import { config } from './config';

export const WHATSAPP_URL = 'https://web.whatsapp.com';

/**
 * Abre Chrome con un perfil persistente por número (.sessions/<MY_PHONE>).
 * WhatsApp guarda ahí la sesión, por lo que el QR solo se escanea una vez.
 */
export async function openSession(): Promise<BrowserContext> {
  const context = await chromium.launchPersistentContext(config.sessionDir, {
    channel: 'chrome',
    headless: config.headless,
    // Sin tamaño fijo: la página se ajusta a la ventana maximizada (evita el "zoom" y los recortes).
    viewport: null,
    args: ['--start-maximized', '--hide-crash-restore-bubble'],
    // Quita la barra amarilla "--no-sandbox" que ocupa espacio en pantalla.
    ignoreDefaultArgs: ['--no-sandbox'],
    locale: 'es-PE',
  }).catch((err: Error) => {
    throw new Error(
      'No se pudo abrir Chrome con la sesión guardada. Si quedó abierta una ventana de ' +
        `Chrome de una prueba anterior, ciérrala y vuelve a intentar.\n${err.message}`,
    );
  });

  // Chrome puede restaurar pestañas de la ejecución anterior; dos pestañas con WhatsApp
  // chocan ("WhatsApp está abierto en otra ventana"). Se deja una sola pestaña vacía.
  const [first, ...rest] = context.pages();
  await Promise.all(rest.map((p) => p.close()));
  await (first ?? (await context.newPage())).goto('about:blank');
  return context;
}
