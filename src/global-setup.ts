import fs from 'node:fs';
import { config } from './config';

/**
 * Se ejecuta una vez antes de todas las pruebas: verifica que exista la sesión
 * y borra las capturas de la ejecución anterior.
 */
export default function globalSetup() {
  if (!fs.existsSync(config.sessionDir)) {
    throw new Error(
      `No hay sesión guardada para ${config.myPhone}. Ejecuta primero: npm run login`,
    );
  }
  fs.rmSync(config.screenshotsDir, { recursive: true, force: true });
}
