import path from 'node:path';
import dotenv from 'dotenv';

dotenv.config({ path: path.resolve(__dirname, '..', '.env') });

export const ROOT_DIR = path.resolve(__dirname, '..');

/** Normaliza un número de teléfono: deja solo dígitos. */
export function normalizePhone(raw: string): string {
  const digits = raw.replace(/\D/g, '');
  if (digits.length < 8 || digits.length > 15) {
    throw new Error(
      `Número inválido "${raw}". Usa formato internacional solo con dígitos, ej. 51999999999.`,
    );
  }
  return digits;
}

function readMyPhone(): string {
  const argIndex = process.argv.indexOf('--my-phone');
  const raw = argIndex >= 0 ? process.argv[argIndex + 1] : process.env.MY_PHONE;
  if (!raw) {
    throw new Error('Falta MY_PHONE. Crea el archivo .env a partir de .env.example.');
  }
  return normalizePhone(raw);
}

export const config = {
  get myPhone() {
    return readMyPhone();
  },
  get sessionDir() {
    return path.join(ROOT_DIR, '.sessions', readMyPhone());
  },
  replyMinWaitMs: Number(process.env.REPLY_MIN_WAIT_SECONDS ?? 5) * 1000,
  /**
   * Frases con las que el bot cierra un flujo. Al recibirlas ya no se espera más,
   * lo que evita esperar de más en la mayoría de los casos.
   */
  endMarkers: (process.env.REPLY_END_MARKERS ?? '¿Puedo ayudarte en algo más?,Entonces por aquí me quedo')
    .split(',')
    .map((m) => m.trim())
    .filter(Boolean),
  replyTimeoutMs: Number(process.env.REPLY_TIMEOUT_SECONDS ?? 30) * 1000,
  replySettleMs: Number(process.env.REPLY_SETTLE_SECONDS ?? 3) * 1000,
  headless: process.env.HEADLESS === 'true',
  // Se limpia al iniciar cada ejecución (global-setup): queda solo la última.
  screenshotsDir: path.join(ROOT_DIR, 'test-results', 'screenshots'),
};
