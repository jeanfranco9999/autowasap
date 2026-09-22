import fs from 'node:fs';
import path from 'node:path';
import { Readable } from 'node:stream';
import { pipeline } from 'node:stream/promises';
import type { Reporter } from '@playwright/test/reporter';
import CucumberHtmlStream from 'cucumber-html-formatter-21';

/**
 * El reporte muestra el encabezado del error y, debajo, su detalle. Como ambos
 * traen el mismo texto, el error salía repetido: aquí el encabezado se deja en
 * una sola línea y el detalle completo queda abajo.
 */
function acortarEncabezadoDelError(envelope: any): any {
  const exception = envelope?.testStepFinished?.testStepResult?.exception;
  if (exception?.stackTrace?.includes('\n')) {
    const [primera, ...resto] = exception.stackTrace.split('\n');
    exception.message = primera;
    exception.stackTrace = resto.join('\n').trim();
  }
  return envelope;
}

interface Options {
  /** Archivo NDJSON con los mensajes de Cucumber (lo genera cucumberReporter('message')). */
  input: string;
  /** Archivo HTML de salida. */
  outputFile: string;
}

/**
 * Genera el reporte HTML de Cucumber con @cucumber/html-formatter 21.3.1, la versión
 * que usa cucumber-js 10.8 (barra de estado, porcentaje, duración y entorno).
 * Corre en onExit, cuando los reporters de playwright-bdd ya escribieron el NDJSON.
 */
export default class CucumberHtmlReporter implements Reporter {
  constructor(private readonly options: Options) {}

  printsToStdio() {
    return false;
  }

  async onExit() {
    const { input, outputFile } = this.options;
    if (!fs.existsSync(input)) return;

    // Al listar escenarios (playwright test --list) no se ejecuta ninguna prueba:
    // sin esto, el reporte de la última corrida se reemplazaría por uno vacío.
    if (!fs.readFileSync(input, 'utf8').includes('"testCaseStarted"')) {
      console.log('Sin escenarios ejecutados: se conserva el reporte anterior.');
      return;
    }

    const envelopes = fs
      .readFileSync(input, 'utf8')
      .split('\n')
      .filter((line) => line.trim())
      .map((line) => JSON.parse(line))
      .map(acortarEncabezadoDelError);

    const distDir = path.resolve(path.dirname(require.resolve('cucumber-html-formatter-21')), '..');
    fs.mkdirSync(path.dirname(outputFile), { recursive: true });
    await pipeline(
      Readable.from(envelopes),
      new CucumberHtmlStream(path.join(distDir, 'main.css'), path.join(distDir, 'main.js')),
      fs.createWriteStream(outputFile),
    );

    this.archivar(outputFile);
  }

  /**
   * Guarda una copia del reporte con la fecha y hora, porque cada ejecución
   * reemplaza el reporte anterior.
   */
  private archivar(outputFile: string): void {
    const ahora = new Date();
    const dos = (n: number) => String(n).padStart(2, '0');
    const sello =
      `${ahora.getFullYear()}-${dos(ahora.getMonth() + 1)}-${dos(ahora.getDate())}` +
      `_${dos(ahora.getHours())}-${dos(ahora.getMinutes())}`;
    const carpeta = 'reportes';
    fs.mkdirSync(carpeta, { recursive: true });
    fs.copyFileSync(outputFile, path.join(carpeta, `reporte_${sello}.html`));
  }
}
