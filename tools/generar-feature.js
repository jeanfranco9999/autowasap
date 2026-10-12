/**
 * Crea un .feature a partir de la pestaña QA de un Excel ya convertido a .jsonl.
 * Uso: node tools/generar-feature.js tools/frases-mkr.jsonl features/makro.feature "Makro" "+51 999 999 999"
 *
 * Columnas esperadas: A = frase (intención), B = grupo (Descripción/NLU), C = enlace de Figma.
 * Los textos esperados quedan comentados: se completan con el diseño de Figma de cada grupo.
 */
const fs = require('node:fs');

const [, , jsonl, salida, marca, numeroBot] = process.argv;
if (!jsonl || !salida || !marca || !numeroBot) {
  console.error('Uso: node tools/generar-feature.js <frases.jsonl> <salida.feature> <marca> <número del bot>');
  process.exit(1);
}

const filas = fs.readFileSync(jsonl, 'utf8').trim().split('\n').map((l) => JSON.parse(l)).slice(1);

/** Para unir grupos que solo cambian por tildes, mayúsculas o una errata. */
const clave = (s) =>
  s
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9]/g, '');

const grupos = new Map();
let actual = '';
for (const fila of filas) {
  if (fila.B) actual = fila.B.trim();
  if (!fila.A) continue;
  const k = clave(actual) || 'singrupo';
  if (!grupos.has(k)) grupos.set(k, { nombre: actual || 'Sin grupo', frases: [], figma: '' });
  const grupo = grupos.get(k);
  if (!grupo.frases.includes(fila.A)) grupo.frases.push(fila.A);
  if (!grupo.figma && fila.C && /https?:\/\//.test(fila.C)) {
    grupo.figma = fila.C.match(/https?:\/\/\S+/)[0];
  }
}

/** Etiqueta en minúsculas, sin tildes ni espacios: @cambiarDatos */
const etiqueta = (nombre) => {
  const palabras = nombre
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-zA-Z0-9 ]/g, '')
    .split(/\s+/)
    .filter(Boolean);
  return palabras
    .map((p, i) => (i === 0 ? p.toLowerCase() : p[0].toUpperCase() + p.slice(1).toLowerCase()))
    .join('');
};

/** Alinea las columnas de una tabla Gherkin. */
const alinear = (valores) => {
  const ancho = Math.max(...valores.map((v) => [...v].length));
  return valores.map((v) => `| ${v}${' '.repeat(ancho - [...v].length)} |`);
};

const out = [];
out.push(`# Escenarios del bot de ${marca}.`);
out.push('# Las frases salen de la pestaña QA de su Excel (columna Intencion), agrupadas por su');
out.push('# columna Descripción. Los textos esperados se completan con el diseño de Figma de cada grupo.');
out.push(`# Para probar un solo grupo: npm run test:uno -- "@<etiqueta>"`);
out.push('');
out.push(`Feature: Flujos del bot ${marca}`);
out.push('');
out.push('  Background:');
out.push(`    Given se dirige al WhatsApp del bot "${numeroBot}"`);

for (const grupo of grupos.values()) {
  out.push('');
  out.push(`  # --- ${grupo.nombre} ---`);
  if (grupo.figma) out.push(`  # Figma: ${grupo.figma}`);
  out.push(`  @${etiqueta(grupo.nombre)} @pendiente`);
  out.push(`  Scenario Outline: Responde el flujo de ${grupo.nombre} a "<frase>"`);
  out.push('    When usuario escribe en el chat "<frase>"');
  out.push('    # PENDIENTE: copia del diseño los textos esperados y quita los # de estas líneas.');
  out.push('    # Then el bot responde');
  out.push('    #   | texto esperado tal como está en Figma |');
  out.push('    #   | *texto que va en negrita*             |');
  out.push('    #   | [imagen]                              |');
  out.push('    When usuario escribe en el chat "Cerrar sesión"');
  out.push('');
  out.push('    Examples:');
  for (const fila of alinear(['frase', ...grupo.frases])) out.push(`      ${fila}`);
}
out.push('');

fs.writeFileSync(salida, out.join('\n'), 'utf8');
const total = [...grupos.values()].reduce((n, g) => n + g.frases.length, 0);
console.log(`${salida}: ${grupos.size} grupos, ${total} escenarios`);
