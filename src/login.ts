import { config } from './config';
import { openSession, WHATSAPP_URL } from './session';
import { sel } from './selectors';

const LOGIN_TIMEOUT_MS = 3 * 60_000;

async function main() {
  console.log(`Abriendo WhatsApp Web para ${config.myPhone}...`);
  const context = await openSession();
  const page = context.pages()[0] ?? (await context.newPage());
  await page.goto(WHATSAPP_URL);

  await page.locator(`${sel.chatList}, ${sel.qrCode}`).first().waitFor({ timeout: 60_000 });

  if (!(await page.locator(sel.chatList).isVisible())) {
    console.log('Escanea el QR desde tu celular: WhatsApp > Dispositivos vinculados > Vincular dispositivo.');
    await page.waitForSelector(sel.chatList, { timeout: LOGIN_TIMEOUT_MS });
    // Da tiempo a WhatsApp de terminar de guardar la sesión en el perfil.
    await page.waitForTimeout(10_000);
    console.log('Sesión guardada. Ya puedes ejecutar: npm test');
  } else {
    console.log('La sesión ya estaba iniciada. Ya puedes ejecutar: npm test');
  }

  await context.close();
}

main().catch((err) => {
  console.error(err instanceof Error ? err.message : err);
  process.exit(1);
});
