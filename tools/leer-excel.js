/**
 * Lee la pestaña "QA" de un Excel .xlsx y escribe un .jsonl con sus filas.
 * Uso: node tools/leer-excel.js "features/NLU - MKR.xlsx" tools/frases-mkr.jsonl [NombreHoja]
 *
 * No usa librerías: un .xlsx es un .zip con XML adentro, así que lo descomprime
 * con la herramienta del sistema y lee el XML.
 */
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { execFileSync } = require('node:child_process');

const [, , excel, salida, hojaPedida = 'QA'] = process.argv;
if (!excel || !salida) {
  console.error('Uso: node tools/leer-excel.js <archivo.xlsx> <salida.jsonl> [hoja]');
  process.exit(1);
}

const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'xlsx-'));
// Expand-Archive solo acepta la extensión .zip, así que se copia con ese nombre.
const copiaZip = path.join(temp, 'libro.zip');
fs.copyFileSync(path.resolve(excel), copiaZip);
execFileSync('powershell', [
  '-NoProfile',
  '-Command',
  `Expand-Archive -LiteralPath "${copiaZip}" -DestinationPath "${temp}" -Force`,
]);

const leer = (relativo) => fs.readFileSync(path.join(temp, relativo), 'utf8');

// Textos compartidos: las celdas de texto apuntan a esta lista por número.
const textos = leer('xl/sharedStrings.xml')
  .split('<si>')
  .slice(1)
  .map((si) =>
    (si.match(/<t[^>]*>([\s\S]*?)<\/t>/g) || [])
      .map((t) => t.replace(/<[^>]+>/g, ''))
      .join('')
      .replace(/&amp;/g, '&')
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')
      .replace(/&quot;/g, '"')
      .replace(/&#39;|&apos;/g, "'"),
  );

// Ubica la hoja pedida por su nombre: workbook.xml la liga a un archivo por su rId.
const libro = leer('xl/workbook.xml');
const hoja = [...libro.matchAll(/<sheet name="([^"]+)"[^>]*r:id="(rId\d+)"/g)].find(
  ([, nombre]) => nombre.trim().toLowerCase() === hojaPedida.toLowerCase(),
);
if (!hoja) {
  const nombres = [...libro.matchAll(/<sheet name="([^"]+)"/g)].map(([, n]) => n);
  console.error(`No existe la hoja "${hojaPedida}". Hojas disponibles: ${nombres.join(', ')}`);
  process.exit(1);
}
const relaciones = leer('xl/_rels/workbook.xml.rels');
const [, destino] = relaciones.match(new RegExp(`Id="${hoja[2]}"[^>]*Target="([^"]+)"`)) || [];

const filas = leer(path.join('xl', destino.replace(/^\//, '')))
  .split('<row ')
  .slice(1)
  .map((fila) => {
    const celdas = {};
    for (const celda of fila.split('<c ').slice(1)) {
      const columna = (celda.match(/r="([A-Z]+)\d+"/) || [])[1];
      const esTexto = /t="s"/.test(celda);
      const enLinea = (celda.match(/<is>[\s\S]*?<t[^>]*>([\s\S]*?)<\/t>/) || [])[1];
      let valor = enLinea !== undefined ? enLinea : (celda.match(/<v>([\s\S]*?)<\/v>/) || [])[1];
      if (valor !== undefined && esTexto) valor = textos[Number(valor)];
      if (valor !== undefined && columna) celdas[columna] = String(valor).replace(/\s+/g, ' ').trim();
    }
    return celdas;
  });

fs.writeFileSync(salida, filas.map((f) => JSON.stringify(f)).join('\n'), 'utf8');
fs.rmSync(temp, { recursive: true, force: true });
console.log(`${excel} → ${salida}: ${filas.length} filas de la hoja "${hoja[1]}"`);
