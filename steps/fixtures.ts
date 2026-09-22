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
    await use(new WhatsAppPage(page, testInfo));
  },
});

export const { Given, When, Then } = createBdd(test);
