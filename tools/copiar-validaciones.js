/**
 * Copia los textos esperados de features/promart.feature a los grupos equivalentes
 * de otra bandera, cambiando el nombre de la marca donde aparece.
 *
 * Uso: node tools/copiar-validaciones.js features/makro.feature Makro
 *
 * Los grupos que no existen en Promart se quedan como están (pendientes).
 */
const fs = require('node:fs');

const [, , destino, marca] = process.argv;
if (!destino || !marca) {
  console.error('Uso: node tools/copiar-validaciones.js <archivo.feature> <marca>');
  process.exit(1);
}

/** Nombre comparable: sin tildes, mayúsculas ni signos. */
const clave = (s) =>
  s
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9]/g, '');

/** Cómo se llama en cada bandera un grupo que en Promart tiene otro nombre. */
const EQUIVALENCIAS = {
  cambiardatos: 'Cambio de datos',
  costoyenvio: 'Cobertura y costo de envío',
  coberturaycostosdeenvios: 'Cobertura y costo de envío',
  coberturaycostodeenvio: 'Cobertura y costo de envío',
  faq: 'FAQ',
  garantia: 'Garantía',
  mediosdepago: 'Medios de pago',
  mispedidos: 'Pedidos',
  pedidos: 'Pedidos',
  personaautorizada: 'Persona autorizada',
  qrpersonaautorizada: 'Persona autorizada',
  productosystock: 'Stock',
  sip: 'SIP',
  tiendasyhorarios: 'Tiendas y horarios',
  tiendasyhorario: 'Tiendas y horarios',
  comprobantes: 'Comprobantes',
  servicios: 'Servicios',
  reembolso: 'Reembolso',
  intencionnocomprendida: 'Pasa a intencion no comprendida',
  pasaaintencionnocomprendida: 'Pasa a intencion no comprendida',
};

/** Lee de promart.feature el bloque "Then el bot responde" de cada grupo. */
function validacionesDePromart() {
  const lineas = fs.readFileSync('features/promart.feature', 'utf8').split('\n');
  const porGrupo = new Map();
  let grupo = '';
  let bloque = null;
  for (const linea of lineas) {
    const encabezado = linea.match(/^\s*# --- (.+?)(?:: botones y enlaces)? ---\s*$/);
    if (encabezado) {
      grupo = encabezado[1];
      bloque = null;
      continue;
    }
    if (/^\s*Then el bot responde\s*$/.test(linea) && grupo && !porGrupo.has(clave(grupo))) {
      bloque = [];
      porGrupo.set(clave(grupo), bloque);
      continue;
    }
    if (bloque) {
      if (/^\s*\|/.test(linea)) bloque.push(linea.trim());
      else bloque = null;
    }
  }
  return porGrupo;
}

const validaciones = validacionesDePromart();
const lineas = fs.readFileSync(destino, 'utf8').split('\n');
const salida = [];
let grupoActual = '';
let copiados = 0;
const pendientes = [];

for (let i = 0; i < lineas.length; i++) {
  const linea = lineas[i];

  const encabezado = linea.match(/^\s*# --- (.+?) ---\s*$/);
  if (encabezado) grupoActual = encabezado[1];

  // Nombre del grupo en Promart: el mismo, o el de la tabla de equivalencias.
  const nombrePromart = EQUIVALENCIAS[clave(grupoActual)] || grupoActual;
  const filas = validaciones.get(clave(nombrePromart));

  // La etiqueta deja de ser pendiente cuando hay validación que copiar.
  if (/^\s*@/.test(linea)) {
    if (!filas && !pendientes.includes(grupoActual)) pendientes.push(grupoActual);
    salida.push(filas ? linea.replace(' @pendiente', '') : linea);
    continue;
  }

  // Reemplaza el bloque comentado por la validación real.
  if (filas && /# PENDIENTE: copia del diseño/.test(linea)) {
    salida.push('    Then el bot responde');
    for (const fila of filas) salida.push(`      ${fila.replace(/Promart/g, marca)}`);
    while (i + 1 < lineas.length && /^\s*#\s/.test(lineas[i + 1])) i++; // saltar el resto del bloque
    copiados++;
    continue;
  }

  salida.push(linea);
}

fs.writeFileSync(destino, salida.join('\n'), 'utf8');
console.log(`${destino}: ${copiados} grupos con validación copiada de Promart`);
if (pendientes.length) console.log(`   siguen pendientes: ${pendientes.join(', ')}`);
