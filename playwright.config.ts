import { defineConfig } from '@playwright/test';
import { cucumberReporter, defineBddConfig } from 'playwright-bdd';

const testDir = defineBddConfig({
  features: 'features/**/*.feature',
  steps: 'steps/**/*.ts',
});

export default defineConfig({
  testDir,
  // Archivos técnicos de Playwright (trazas, errores) aparte; test-results/ queda para los reportes.
  outputDir: '.playwright/output',
  globalSetup: require.resolve('./src/global-setup'),
  // Un perfil de Chrome no puede abrirse dos veces a la vez: escenarios en secuencia.
  workers: 1,
  fullyParallel: false,
  timeout: 12 * 60_000,
  expect: { timeout: 10_000 },
  reporter: [
    ['list'],
    // Reportes de Cucumber con los pasos Gherkin y las capturas incluidas.
    // Se excluye la traza técnica (.zip), que pesa decenas de MB.
    cucumberReporter('message', {
      outputFile: 'test-results/cucumber-messages.ndjson',
      skipAttachments: ['application/zip', 'text/markdown'],
    }),
    cucumberReporter('json', {
      outputFile: 'test-results/cucumber-report.json',
      skipAttachments: ['application/zip', 'text/markdown'],
    }),
    // HTML con el formato de cucumber-js 10.8, generado a partir de los mensajes.
    [
      './src/cucumber-html-reporter.ts',
      { input: 'test-results/cucumber-messages.ndjson', outputFile: 'test-results/cucumber-report.html' },
    ],
  ],
  use: {
    trace: 'retain-on-failure',
  },
});
