import type { BrowserContext } from '@playwright/test';
import { createBdd, test as base } from 'playwright-bdd';
import { openSession } from '../src/session';
import { WhatsAppPage } from '../src/whatsapp';

type TestFixtures = { whatsapp: WhatsAppPage };
type WorkerFixtures = { waContext: BrowserContext };

export const test = base.extend<TestFixtures, WorkerFixtures>({
  // Un solo Chrome (con la sesión guardada) para todos los escenarios.
  waContext: [
    async ({}, use) => {
      const context = await openSession();
      await use(context);
      await context.close();
    },
    { scope: 'worker' },
  ],

  whatsapp: async ({ waContext }, use, testInfo) => {
    const page = waContext.pages()[0] ?? (await waContext.newPage());
    const whatsapp = new WhatsAppPage(page, testInfo);
    await use(whatsapp);

    // Al terminar el escenario se informan juntos todos los problemas anotados.
    if (whatsapp.problemas.length) {
      const detalle = whatsapp.problemas
        .map(({ paso, detalle }, i) => `${i + 1}) En "${paso}":\n${detalle}`)
        .join('\n\n');
      const error = new Error(
        `${whatsapp.problemas.length} revisión(es) no coinciden en este escenario:\n\n${detalle}`,
      );
      error.stack = '';
      throw error;
    }
  },
});

export const { Given, When, Then } = createBdd(test);
