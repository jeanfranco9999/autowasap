const fs = require('fs');
const BOT = '+55 11 3506-1670';
const rows = fs.readFileSync(process.argv[2], 'utf8').trim().split('\n').map(JSON.parse).slice(1);
let g = '';
const phrases = new Map();
for (const r of rows) {
  if (r.D) g = r.D;
  if (!r.A) continue;
  if (!phrases.has(g)) phrases.set(g, []);
  phrases.get(g).push(r.A);
}

// El bot saluda por el nombre de la cuenta que escribe (en Figma es {{Nombre}}).
const NOMBRE = 'jean';

// Menú de apoyo con el que terminan varios flujos.
const MENU_DE_APOYO = ['¿Puedo ayudarte en algo más? 😃', '✅ Sí', '❌ No'];

// Valores esperados transcritos de las imágenes de Figma.
// Los emojis de inicio de línea se confirmaron con la respuesta real del bot (21/09/2026).
const G = {
  'Cambio de datos': {
    file: 'cambio-de-datos', tag: 'cambioDeDatos', title: 'Cambio de datos',
    expected: [
      `Lo siento, ${NOMBRE}. Una vez realizado el pedido, el lugar de recojo o la dirección de entrega permanecen tal como se registraron.`,
      'Pero como alternativa, puedo ayudarte a cancelar el pedido para que lo repitas con los datos correctos 👇',
      'Mis pedidos online 📦',
      'Sigue tu pedido y reembolso, consulta la entrega estimada, reprograma o cancela tu pedido.',
      'Elegir pedido',
      ...MENU_DE_APOYO,
    ],
    // Textos que el diseño muestra en negrita.
    bold: [
      'Mis pedidos online',
      'reprograma o cancela',
    ],
  },
  'Cobertura y costo de envío': {
    file: 'cobertura-y-costo-de-envio', tag: 'coberturaEnvio', title: 'Cobertura y costo de envío',
    expected: [
      '🚚 Realizamos entregas en las ciudades donde Promart tiene presencia.',
      '🛒 Agrega tus productos al carrito, continúa tu compra e ingresa tu dirección para ver el costo de envío calculado para tu pedido en el resumen de tu compra.',
      '👇 Aquí encontrarás el costo de envío:',
      '[imagen]',
      '📍 Si no tenemos cobertura en tu dirección, puedes comprar online y retirar tu pedido en cualquier tienda Promart o en un punto de retiro externo.',
      '📍 Conócelos aquí',
    ],
    // Textos que el diseño muestra en negrita.
    bold: [
      'el costo de envío calculado para tu pedido',
      'comprar online y retirar tu pedido',
    ],
    // Va después de "Cerrar sesión" porque el aviso del enlace tapa el chat.
    stepsAfterClose: [
      'When usuario hace clic en el botón "Conócelos aquí"',
      'Then el botón lleva a "https://www.promart.pe/puntos-de-retiro-externos"',
    ],
  },
  FAQ: {
    file: 'faq', tag: 'faq', title: 'FAQ - Preguntas frecuentes',
    expected: [
      '💬 ¿Tienes alguna consulta?',
      'Selecciona una de las opciones y encuentra la respuesta que necesitas.',
      'Opciones',
    ],
    // Textos que el diseño muestra en negrita.
    bold: [
      '¿Tienes alguna consulta?',
      'opciones',
    ],
    // Al hacer clic en "Opciones" se abre la lista de preguntas frecuentes.
    steps: [
      'When usuario hace clic en el botón "Opciones"',
      'Then la lista muestra',
      ...[
        '🔧 Adquirir un servicio',
        '¿Cuándo realizarán mi servicio?',
        '📦 Modificar un pedido',
        '¿Cómo cambio mi pedido?',
        '🛡️ Garantía',
        '¿Cómo funciona la garantía?',
        '👤 Persona autorizada',
        '¿Quién puede recoger mi pedido?',
        '🚚 ¿Entregan a mi domicilio?',
        '¿Cuál es la cobertura y cuánto cuesta?',
        '💳 Tarjeta Sip',
        '¿Cómo uso mi tarjeta débito o crédito SIP?',
        '💰 Medios de pago',
        '¿Qué medios de pago aceptan?',
        '💡 Otras dudas',
      ].map((option) => `  | ${option} |`),
    ],
  },
  'Garantía': {
    file: 'garantia', tag: 'garantia', title: 'FAQ - Garantía',
    expected: [
      'Garantía del fabricante',
      'Las condiciones, plazos, cobertura y exclusiones de la garantía son definidas por la marca o fabricante.',
      'Algunas marcas o fabricantes requieren que la instalación sea realizada por un servicio autorizado o por personal de la propia marca para mantener la garantía.',
      'Garantía Promart',
      '¿Tu producto presenta una falla? Conoce cómo funciona nuestra garantía y qué opciones tienes.',
      '[4 imágenes]',
    ],
    // Textos que el diseño muestra en negrita.
    bold: [
      'Garantía del fabricante',
      'Garantía Promart',
    ],
  },
  'Instalación de servición': {
    file: 'instalacion-de-servicio', tag: 'instalacionServicio', title: 'Instalación de servicio',
    expected: [
      '💡 Ten en cuenta que...',
      'Recibirás un correo electrónico cuando tu servicio esté registrado ✅. Luego podrás consultar la fecha programada y el rango horario en "Elegir servicio".',
      '🗓️ De ser posible, el servicio se programará para el día siguiente de la entrega del producto.',
      '🕐 El día de la atención, permanece atento durante todo el rango horario, ya que nuestro equipo puede comunicarse contigo 📞 o acudir a tu domicilio 🏠.',
      'Mis servicios 🛠️',
      'Consulta el estado de tu servicio, reprograma la fecha de atención o cancela tu servicio.',
      'Elegir servicio',
    ],
    // Textos que el diseño muestra en negrita.
    bold: [
      'servicio esté registrado',
      'Elegir servicio',
      'permanece atento durante todo el rango horario',
      'Mis servicios',
    ],
  },
  'Medios de pago': {
    file: 'medios-de-pago', tag: 'mediosDePago', title: 'Medios de pago',
    expected: [
      '💳 Al finalizar tu compra podrás elegir el medio de pago que prefieras.',
      'Aceptamos:',
      '✅ Tarjetas de débito o crédito Sip.',
      '✅ Otras tarjetas de débito o crédito: (Visa, Mastercard, American Express y Diners Club)',
      '✅ Billetera digital App Sip.',
      '📱 ¿Quieres pagar con App Sip?',
      'Selecciona "App Sip" como medio de pago y sigue estos pasos:',
      '1. Ingresa tu número de documento y teléfono.',
      '2. Confirma el pago desde la app en solo 3 pasos. 👇',
      '[imagen]',
    ],
    // Textos que el diseño muestra en negrita.
    bold: [
      'débito o crédito Sip',
      'Otras tarjetas',
      'App Sip',
      '¿Quieres pagar con App Sip?',
    ],
  },
  'Persona autorizada': {
    file: 'persona-autorizada', tag: 'personaAutorizada', title: 'Persona autorizada',
    expected: [
      '📍 Si retiras en una tienda Promart, puede ir cualquier persona con el QR y su DNI.',
      'En puntos externos, solo puede retirar el titular de la compra con su DNI.',
      '📲 Recibirás el QR por correo electrónico cuando tu pedido esté listo para recoger. Si ya recibiste la notificación, también puedes verlo en "Elegir pedido".',
      'Mis pedidos online 📦',
      'Sigue tu pedido y reembolso, consulta la entrega estimada, reprograma o cancela tu pedido.',
      'Elegir pedido',
    ],
    // Textos que el diseño muestra en negrita.
    bold: [
      'Mis pedidos online',
      'reprograma o cancela',
    ],
  },
  SIP: {
    file: 'sip', tag: 'sip', title: 'Tarjeta Sip',
    expected: [
      '📲 Si tienes alguna duda sobre tu Tarjeta de Débito o Crédito Sip, AhorraMás o recompensas; puedes contactar al equipo',
      'Contactar a Sip',
    ],
    // El botón usa un enlace acortado que lleva al chat de WhatsApp de Sip.
    // Va después de "Cerrar sesión" porque abre otro chat.
    stepsAfterClose: [
      'When usuario hace clic en el botón "Contactar a Sip"',
      // Se valida por número: WhatsApp solo muestra "Sip" si el contacto está guardado.
      'Then el botón abre el chat de WhatsApp de "51989157775"',
    ],
  },
  Stock: {
    file: 'stock', tag: 'stock', title: 'Productos y stock',
    expected: [
      '🔍 Productos y stock',
      'Busca productos, consulta el stock disponible por tienda y compra online.',
      'Para empezar, selecciona el siguiente botón:',
      'Empezar',
    ],
    // Textos que el diseño muestra en negrita.
    bold: [
      'Productos y stock',
    ],
  },
  'Tiendas y horarios': {
    file: 'tiendas-y-horarios', tag: 'tiendasYHorarios', title: 'Tiendas y horarios',
    expected: [
      'Tiendas y horarios 🏬',
      'Selecciona el tipo de búsqueda que quisieras realizar para ayudarte a encontrar la tienda más cercana 👇',
      '📍 Enviar ubicación',
      '🏬 Elegir tienda',
    ],
    // Textos que el diseño muestra en negrita.
    bold: [
      'Tiendas y horarios',
    ],
  },
  Servicios: {
    file: 'mis-servicios', tag: 'misServicios', title: 'Mis servicios',
    expected: [
      '👉 Ten en cuenta que...',
      'Los servicios de armado e instalación se contratan al momento de realizar la compra de tu producto.',
      'Si ya contrataste un servicio, selecciona "Elegir servicio" para consultar su estado, reprogramarlo o cancelarlo.',
      'Si aún no has contratado un servicio y deseas hacerlo, acércate a cualquiera de nuestras tiendas.',
      'Mis servicios 🛠️',
      'Consulta el estado de tu servicio, reprograma la fecha de atención o cancela tu servicio.',
      'Elegir servicio',
    ],
    // Textos que el diseño muestra en negrita.
    bold: [
      'Ten en cuenta que...',
      'Elegir servicio',
      'Mis servicios',
    ],
  },
  Comprobantes: {
    file: 'comprobantes', tag: 'comprobantes', title: 'Comprobantes',
    expected: [
      '📌 Recuerda que...',
      'El tipo de comprobante lo eliges al momento de realizar tu compra. Esta elección no podrá modificarse posteriormente.',
      'Por ejemplo, si elegiste una boleta, luego no será posible solicitar una factura.',
      'Mis comprobantes 🧾',
      'Selecciona dónde realizaste tu compra para encontrar tu comprobante de pago.',
      '💻 Tienda online',
      '🏬 Tienda física',
    ],
    // Textos que el diseño muestra en negrita.
    bold: [
      'Recuerda que...',
      'Esta elección no podrá modificarse posteriormente.',
      'Mis comprobantes',
    ],
  },
  Pedidos: {
    file: 'mis-pedidos', tag: 'misPedidos', title: 'Mis pedidos online',
    expected: [
      'Mis pedidos online 📦',
      'Sigue tu pedido y reembolso, consulta la entrega estimada, reprograma o cancela tu pedido.',
      'Elegir pedido',
    ],
    // Textos que el diseño muestra en negrita.
    bold: [
      'Mis pedidos online',
      'reprograma o cancela',
    ],
  },
  'Pasa a intencion no comprendida': {
    file: 'intencion-no-comprendida', tag: 'intencionNoComprendida', title: 'Intención no comprendida',
    expected: ['Lo siento, creo que no entendí bien tu consulta 🤔'],
  },
  Reembolso: {
    file: 'reembolso', tag: 'reembolso', title: 'Reembolso',
    expected: [
      '[imagen]',
      '💡 El plazo máximo para hacer un cambio o devolución depende del producto, aquí te dejo más información:',
      '🙋‍♂️ Si tienes otras consultas o quisieras que te ayude a iniciar tu cambio o devolución, estoy aquí para ti',
      'Haz clic en uno de los siguientes botones 👇',
      '🔁 Cambio/devolución',
      '❓ Otras consultas',
    ],
    pending: 'valores tomados de la respuesta actual del bot; falta confirmarlos con Figma.',
  },
};

// Alinea las columnas de una tabla Gherkin.
const pad = (values) => {
  const width = Math.max(...values.map((v) => [...v].length));
  return values.map((v) => `| ${v}${' '.repeat(width - [...v].length)} |`);
};

const out = [];
out.push('# Escenarios del bot Promart.');
out.push('# Las frases salen de la hoja QA de "features/NLU - Promart.xlsx" (columna Intencion),');
out.push('# agrupadas por su columna "Descripción". Los textos esperados vienen de los diseños de Figma.');
out.push('# Para probar un solo grupo: npm run test:uno -- "@stock"');
out.push('');
out.push('Feature: Flujos del bot Promart');
out.push('');
out.push('  Background:');
out.push(`    Given se dirige al WhatsApp del bot "${BOT}"`);

let total = 0;
for (const [group, cfg] of Object.entries(G)) {
  // El Excel repite algunas frases dentro del mismo grupo.
  const list = [...new Set(phrases.get(group) || [])];
  total += list.length;
  out.push('');
  out.push(`  # --- ${group} ---`);
  if (cfg.pending) out.push(`  # PENDIENTE: ${cfg.pending}`);
  out.push(`  @${cfg.tag}${cfg.pending ? ' @pendiente' : ''}`);
  out.push(`  Scenario Outline: Responde el flujo de ${cfg.title} a "<frase>"`);
  out.push('    When usuario escribe en el chat "<frase>"');
  // Las negritas se marcan con *asteriscos* dentro de la frase donde aparecen,
  // igual que se escribe la negrita en WhatsApp.
  const expected = cfg.expected.slice();
  for (const fragment of cfg.bold || []) {
    const i = expected.findIndex((row) => row.includes(fragment) && !row.includes(`*${fragment}*`));
    if (i >= 0) expected[i] = expected[i].replace(fragment, `*${fragment}*`);
    else expected.push(`*${fragment}*`); // no está en ninguna fila: se valida por separado
  }
  if (expected.length) {
    out.push('    Then el bot responde');
    for (const row of pad(expected)) out.push(`      ${row}`);
  } else {
    out.push('    # Completa los textos esperados y quita los # de estas dos líneas:');
    out.push('    # Then el bot responde');
    out.push('    #   | texto esperado |');
  }
  out.push('    When usuario escribe en el chat "Cerrar sesión"');
  out.push('');
  out.push('    Examples:');
  for (const row of pad(['frase', ...list])) out.push(`      ${row}`);

  // Los botones, listas y enlaces van en un escenario aparte: si el texto falla,
  // el escenario se detiene y estas revisiones nunca llegarían a ejecutarse.
  if (cfg.steps || cfg.stepsAfterClose || cfg.todo) {
    out.push('');
    out.push(`  # --- ${group}: botones y enlaces ---`);
    out.push(`  @${cfg.tag} @botones`);
    out.push(`  Scenario: Botones y enlaces de ${cfg.title}`);
    out.push(`    When usuario escribe en el chat "${list[0]}"`);
    for (const line of cfg.steps || []) out.push(`    ${line}`);
    for (const line of cfg.todo || []) out.push(`    # ${line}`);
    out.push('    When usuario escribe en el chat "Cerrar sesión"');
    for (const line of cfg.stepsAfterClose || []) out.push(`    ${line}`);
  }
  console.log(`${group}`.padEnd(34), `${String(list.length).padStart(3)} frases`, `${String(cfg.expected.length).padStart(2)} filas esperadas`);
}

// Ejemplo suelto: el saludo inicial responde con imagen.
out.push('');
out.push('  # --- Saludo inicial (responde con imagen) ---');
out.push('  @saludo');
out.push('  Scenario: El bot saluda con una imagen');
out.push('    When usuario escribe en el chat "Hola"');
out.push('    Then el bot responde');
for (const row of pad(['[imagen]', '¡Hola, jean! ¡Qué bueno tenerte por aquí de nuevo! 😊'])) out.push(`      ${row}`);
out.push('    When usuario escribe en el chat "Cerrar sesión"');
out.push('');

fs.writeFileSync('features/promart.feature', out.join('\n'), 'utf8');
console.log('\nfeatures/promart.feature:', total + 1, 'escenarios');
