# Escenarios del bot Promart.
# Las frases salen de la hoja QA de "features/NLU - Promart.xlsx" (columna Intencion),
# agrupadas por su columna "Descripción". Los textos esperados vienen de los diseños de Figma.
# Para probar un solo grupo: npm run test:uno -- "@stock"
Feature: Flujos del bot Promart

  Background:
    Given se dirige al WhatsApp del bot "+55 11 3506-1670"
  # --- Cambio de datos ---

  @cambioDeDatos
  Scenario Outline: Responde el flujo de Cambio de datos a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | Lo siento, jean. Una vez realizado el pedido, el lugar de recojo o la dirección de entrega permanecen tal como se registraron. |
      | Pero como alternativa, puedo ayudarte a cancelar el pedido para que lo repitas con los datos correctos 👇                       |
      | *Mis pedidos online* 📦                                                                                                         |
      | Sigue tu pedido y reembolso, consulta la entrega estimada, *reprograma o cancela* tu pedido.                                   |
      | Elegir pedido                                                                                                                  |
      | ¿Puedo ayudarte en algo más? 😃                                                                                                 |
      | ✅ Sí                                                                                                                           |
      | ❌ No                                                                                                                           |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                                     |
      | He hecho un pedido pero con información incorrecta quisiera modificarlo con mis datos no los de mi abuela |
      | QUIERO CAMBIAR EL NUMERO DE CELULAR DE CONTACTO                                                           |
      | Quiero hacer un cambio de dirección                                                                       |
      | Si registre un correo y me equivoqué que se puede hacer?                                                  |
      | ME CONFUNDI AL COLOCAR MI CORREO ELECTRONICO                                                              |
      | El correo que aparece no es mi correo                                                                     |
      | He puesto mal mi correo                                                                                   |
      | Seguro la que me atendió copio mal mi correo                                                              |
      | el correo que ustedes tienen registrado es el incorrecto no me pidan confirman el token con correo        |
  # --- Cobertura y costo de envío ---

  @coberturaEnvio
  Scenario Outline: Responde el flujo de Cobertura y costo de envío a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 🚚 Realizamos entregas en las ciudades donde Promart tiene presencia.                                                                                           |
      | 🛒 Agrega tus productos al carrito, continúa tu compra e ingresa tu dirección para ver *el costo de envío calculado para tu pedido* en el resumen de tu compra. |
      | 👇 Aquí encontrarás el costo de envío:                                                                                                                          |
      | [imagen]                                                                                                                                                       |
      | 📍 Si no tenemos cobertura en tu dirección, puedes *comprar online y retirar tu pedido* en cualquier tienda Promart o en un punto de retiro externo.            |
      | Conócelos aquí                                                                                                                                               |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                                                             |
      | ¡Hola! Quisiera comprar unos productos en la página web pero quería saber si hacen envíos a provincia. Vivo en Rioja / San Martín |
      | El costo de envio se cobra x cada producto?                                                                                       |
      | en la devolucion se incluye el costo de envio?                                                                                    |
      | hacen envios a camaná - arequipa?                                                                                                 |
      | Hacen envíos a domicilio?                                                                                                         |
      | Puedo hacer mi compra y ustedes enviarlo por shalom para yo recogerlo de allí?                                                    |
      | Quiero saber si puedo hacerlo para q ustedes lo envíen x Shalom                                                                   |
      | quisiera saber si hacen envios a provincia Mala cañete                                                                            |
  # --- Cobertura y costo de envío: botones y enlaces ---

  @coberturaEnvio @botones
  Scenario: Botones y enlaces de Cobertura y costo de envío
    When usuario escribe en el chat "¡Hola! Quisiera comprar unos productos en la página web pero quería saber si hacen envíos a provincia. Vivo en Rioja / San Martín"
    When usuario escribe en el chat "Cerrar sesión"
    When usuario hace clic en el botón "Conócelos aquí"
    Then el botón lleva a "https://www.promart.pe/puntos-de-retiro-externos"
  # --- FAQ ---

  @faq
  Scenario Outline: Responde el flujo de FAQ - Preguntas frecuentes a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 💬 *¿Tienes alguna consulta?*                                             |
      | Selecciona una de las *opciones* y encuentra la respuesta que necesitas. |
      | Opciones                                                                 |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                      |
      | Necesito ayuda                             |
      | Quiero hacer otra consulta                 |
      | otra consulta                              |
      | Tengo otra duda                            |
      | No parece la opción que quiero en cónsulta |
      | tengo otra consulta                        |
      | OTRA CONSULTA                              |
      | quiero hacer otra consulta                 |
  # --- FAQ: botones y enlaces ---

  @faq @botones
  Scenario: Botones y enlaces de FAQ - Preguntas frecuentes
    When usuario escribe en el chat "Necesito ayuda"
    When usuario hace clic en el botón "Opciones"
    Then la lista muestra
      | 🔧 Adquirí un servicio                      |
      | ¿Cuándo realizarán mi servicio?            |
      | 📦 Modificar un pedido                      |
      | ¿Cómo cambio mi pedido?                    |
      | 🛡️ Garantía                                |
      | ¿Cómo funciona la garantía?                |
      | 👤 Persona autorizada                       |
      | ¿Quién puede recoger mi pedido?            |
      | 🚚 ¿Entregan a mi domicilio?                |
      | ¿Cuál es la cobertura y cuánto cuesta?     |
      | 💳 Tarjeta Sip                              |
      | ¿Cómo uso mi tarjeta débito o crédito SIP? |
      | 💰 Medios de pago                           |
      | ¿Qué medios de pago aceptan?               |
      | 💡 Otras dudas                              |
    When usuario escribe en el chat "Cerrar sesión"
  # --- Garantía ---

  @garantia
  Scenario Outline: Responde el flujo de FAQ - Garantía a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | *Garantía del fabricante*                                                                                                                                       |
      | Las condiciones, plazos, cobertura y exclusiones de la garantía son definidas por la marca o fabricante.                                                        |
      | Algunas marcas o fabricantes requieren que la instalación sea realizada por un servicio autorizado o por personal de la propia marca para mantener la garantía. |
      | *Garantía Promart*                                                                                                                                              |
      | ¿Tu producto presenta una falla? Conoce cómo funciona nuestra garantía y qué opciones tienes.                                                                   |
      | [4 imágenes]                                                                                                                                                    |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                                                                                                                                                                                                                             |
      | ¡Hola! Deseo más información sobre la garantia de mi pedido                                                                                                                                                                                                                                       |
      | ¿Cuántos meses de garantía tiene la Silla de Escritorio Viva Home con Reposapiés B SKU 1702696 / 1000708795? ¿Qué cubre la garantía y quién la atiende?                                                                                                                                           |
      | 2 preguntas sobre este teléfono 1 ¿tiene garantía de Apple? 2 mi marido trabaja para interbancario y puede obtener un descuento del 5 %. ¿Este producto es elegible para un descuento ya que es vendido por MarketcellExpress? Si él puede obtener un descuento ¿cómo podemos hacer esto? Gracias |
      | Años de Garantía de Einhell TV-VC1812                                                                                                                                                                                                                                                             |
      | Buenos días consulta sobre una garantía de un producto                                                                                                                                                                                                                                            |
      | Busco información de garantia de un producto                                                                                                                                                                                                                                                      |
      | Cómo saben si incumpli la garantía? Si ni siquiera se han acercado a hacer el servicio                                                                                                                                                                                                            |
      | De lo cuál tiene un año de garantía y como recién la emos abierto las orillas no arden                                                                                                                                                                                                            |
      | deseo comunicarme con el área de garantía                                                                                                                                                                                                                                                         |
      | Deseo informe sobre la garantia de un producto                                                                                                                                                                                                                                                    |
      | NECESITO AYUDA CON MI SOLICITUD DE ATENCION POR GARANTIA DE TIENDA                                                                                                                                                                                                                                |
      | necesito saber sobre un producto la garantia                                                                                                                                                                                                                                                      |
      | Que tiempo es su garantía                                                                                                                                                                                                                                                                         |
      | Quería saber cuántos años de garantía tiene el producto: Aspiradora Einhell TC-VC 1812                                                                                                                                                                                                            |
      | Quiero consultar garantía extendida                                                                                                                                                                                                                                                               |
      | Quiero reportar un problema con un equipo comprado con garantia                                                                                                                                                                                                                                   |
      | Una consulta el producto tuene garantia si compre por la web                                                                                                                                                                                                                                      |
  # --- Instalación de servición ---

  @instalacionServicio
  Scenario Outline: Responde el flujo de Instalación de servicio a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 💡 Ten en cuenta que...                                                                                                                                        |
      | Recibirás un correo electrónico cuando tu *servicio esté registrado* ✅. Luego podrás consultar la fecha programada y el rango horario en "*Elegir servicio*". |
      | 🗓️ De ser posible, el servicio se programará para el día siguiente de la entrega del producto.                                                                |
      | 🕐 El día de la atención, *permanece atento durante todo el rango horario*, ya que nuestro equipo puede comunicarse contigo 📞 o acudir a tu domicilio 🏠.       |
      | *Mis servicios* 🛠️                                                                                                                                            |
      | Consulta el estado de tu servicio, reprograma la fecha de atención o cancela tu servicio.                                                                     |
      | Elegir servicio                                                                                                                                               |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                                                                     |
      | Para cuando tengo la instalación de campana                                                                                               |
      | Buenas noches pague por un servicio de armado pero no me salió para programar la fecha                                                    |
      | Buenos dias quiero saber cuando realizaran la instalacion de mi espejo?                                                                   |
      | Buenos días quisiera que me indicaran cuando vendrán a realizar el armado de mi escritorio. Soy María Teresa Quiroz DNI 08798067          |
      | Cuándo es el servicio de armado                                                                                                           |
      | Cuando harán la instalación de mi Terma                                                                                                   |
      | Cuando lo instalan?                                                                                                                       |
      | cuando los armaran?                                                                                                                       |
      | Hola hice un pedido de un estante con el servicio de armado el día de hoy me lo entregaron pero me gustaria saber cuando vienen a armarlo |
      | Hola necesito saber cómo programar la fecha de armado de un mueble que he comprado en promart                                             |
      | Hoy me llega mi terma cuando me programan la instalación?                                                                                 |
      | Necesito coordinar la fecha de armado                                                                                                     |
      | Necesito saber cuando armar mi pedido                                                                                                     |
      | Pague para que tmbn lo armen estimado hoy me llego el producto cuando llegaran armarlo?                                                   |
      | para cuándo está programado mi servicio de armado?                                                                                        |
      | Para cuándo podría reprogramar mi armado                                                                                                  |
      | Para cuando recojo mi compra y cuando armarán mi armario                                                                                  |
      | Pero quiero saber cuando van a venir oara instalar mi terma                                                                               |
      | Quería saber cuando vendrán a armar el producto?                                                                                          |
      | Quiero saber cuando viene a mi casa el servicio de armado                                                                                 |
      | Quisiera saber cuando lo armarán?                                                                                                         |
      | Quisiera saber para cuando llega para el armado                                                                                           |
      | Señores cuando me instalan mi pedido me urge                                                                                              |
      | si he hecho un pedido online con servicio de armado incluido como y cuando sabré la fecha del armado?                                     |
      | Vi cuando compré la terma viene instalación incluida. Confirmarme                                                                         |
      | Y cuando hacen la instalación?                                                                                                            |
  # --- Medios de pago ---

  @mediosDePago
  Scenario Outline: Responde el flujo de Medios de pago a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 💳 Al finalizar tu compra podrás elegir el medio de pago que prefieras.                     |
      | Aceptamos:                                                                                 |
      | ✅ Tarjetas de *débito o crédito Sip*.                                                      |
      | ✅ *Otras tarjetas* de débito o crédito: (Visa, Mastercard, American Express y Diners Club) |
      | ✅ Billetera digital *App Sip*.                                                             |
      | 📱 *¿Quieres pagar con App Sip?*                                                            |
      | Selecciona "App Sip" como medio de pago y sigue estos pasos:                               |
      |                                              1. Ingresa tu número de documento y teléfono. |
      |                                        2. Confirma el pago desde la app en solo 3 pasos. 👇 |
      | [imagen]                                                                                   |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                         |
      | Aceptan yape?                                                 |
      | Como hago para pagar con tarjeta sip?                         |
      | como puedo pagar con mi tarjeta visa                          |
      | En promar si aceptan yape                                     |
      | Medios de pago                                                |
      | no puedo pagar con mi tarjeta como hago                       |
      | No puedo pagar con sip                                        |
      | No puedo pagar con tarjeta debito                             |
      | Puedo pagar con sip débito?                                   |
      | Que medios de pago tengo como empresa para realizar el pago-. |
      | quiero pagar con sip                                          |
      | Con que medio de pago puedo pagar                             |
  # --- Persona autorizada ---

  @personaAutorizada
  Scenario Outline: Responde el flujo de Persona autorizada a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 📍 Si retiras en una tienda Promart, puede ir cualquier persona con el QR y su DNI.                                                                           |
      | En puntos externos, solo puede retirar el titular de la compra con su DNI.                                                                                   |
      | 📲 Recibirás el QR por correo electrónico cuando tu pedido esté listo para recoger. Si ya recibiste la notificación, también puedes verlo en "Elegir pedido". |
      | *Mis pedidos online* 📦                                                                                                                                       |
      | Sigue tu pedido y reembolso, consulta la entrega estimada, *reprograma o cancela* tu pedido.                                                                 |
      | Elegir pedido                                                                                                                                                |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                                                                        |
      | No llegó el QR a mi correo                                                                                                                   |
      | Mi pedido sale para recoger pero no me han mandado el QR para recojo 1638810834912-02                                                        |
      | Yo no podré ir .. mi esposo irá con el qr                                                                                                    |
      | Puedo recojer sin Qr mi pedido por la web                                                                                                    |
      | No me llega el QR                                                                                                                            |
      | no tengo el codigo qr porque puse un correo equivocado                                                                                       |
      | NO ME LLEGA EL CODIGO QR                                                                                                                     |
      | No me llega el código QR a mi correo                                                                                                         |
      | No me llega mi qr de mi pedido                                                                                                               |
      | Tenía que recogerlo hoy y no me ha llegado el QR de retiro en tienda                                                                         |
      | No he recibido correo con el QR!!!                                                                                                           |
      | Por qué no me llega a mi correo el QR para poder recoger mi producto comprado                                                                |
      | Mi qr no me llega a mi correo                                                                                                                |
      | no me ha llegado dicho QR al correo                                                                                                          |
      | Si eh visto mi pedido en su página q ya está Pero me debe llegar un QR a mi correo y no me ah llegado ningún mensaje a mi correo hasta ahora |
      | Aun no me llega el correo de confirmación para recoger mi pedido                                                                             |
      | Quiero ver mi QR                                                                                                                             |
  # --- SIP ---

  @sip
  Scenario Outline: Responde el flujo de Tarjeta Sip a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 📲 Si tienes alguna duda sobre tu Tarjeta de Débito o Crédito Sip, AhorraMás o recompensas; puedes contactar al equipo |
      | Contactar a Sip                                                                                                       |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                                                                                                                                                                                                                                                  |
      | Hay un error en el cobro de mi tarjeta sip                                                                                                                                                                                                                                                                             |
      | Bien día hice una compra de 3 tanques de agua de 1100 litros para Puno pagué con la tarjeta SIP y no veo que me hayan hecho un descuento porque decía que tenía un cupón lo activé y nada también tenía entendido que si compro más de S/399 había un descuento eso indica la página de Promart y tampoco me engañaron |
      | Hola. Quería consultar sobre el cupón de sip50                                                                                                                                                                                                                                                                         |
      | Quería consultarte sobre el cupón SIP50                                                                                                                                                                                                                                                                                |
      | Buen as tardes como puedo optener mi tarjeta sip                                                                                                                                                                                                                                                                       |
      | Buenas Noches no aplica la promoción a pesar que quiero pagar con tarjeta SIP                                                                                                                                                                                                                                          |
      | Como hago para solicitar tarjeta sip?                                                                                                                                                                                                                                                                                  |
      | Por qué no me aplica el descuento SIP50 si tengo tarjeta SIP?                                                                                                                                                                                                                                                          |
      | sobre la tarjeta sip                                                                                                                                                                                                                                                                                                   |
  # --- SIP: botones y enlaces ---

  @sip @botones
  Scenario: Botones y enlaces de Tarjeta Sip
    When usuario escribe en el chat "Hay un error en el cobro de mi tarjeta sip"
    When usuario escribe en el chat "Cerrar sesión"
    When usuario hace clic en el botón "Contactar a Sip"
    Then el botón abre el chat de WhatsApp de "51989157775"
  # --- Stock ---

  @stock
  Scenario Outline: Responde el flujo de Productos y stock a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 🔍 *Productos y stock*                                                     |
      | Busca productos, consulta el stock disponible por tienda y compra online. |
      | Para empezar, selecciona el siguiente botón:                              |
      | Empezar                                                                   |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                    |
      | Dónde encuentro la opción de cotización? |
      | Tendrás horinarios de perro 🐕            |
  # --- Tiendas y horarios ---

  @tiendasYHorarios
  Scenario Outline: Responde el flujo de Tiendas y horarios a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | *Tiendas y horarios* 🏬                                                                                  |
      | Selecciona el tipo de búsqueda que quisieras realizar para ayudarte a encontrar la tienda más cercana 👇 |
      | 📍 Enviar ubicación                                                                                      |
      | 🏬 Elegir tienda                                                                                         |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                             |
      | a que hora abre el promart san juan de lurigancho |
  # --- Servicios ---

  @misServicios
  Scenario Outline: Responde el flujo de Mis servicios a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 👉 *Ten en cuenta que...*                                                                                            |
      | Los servicios de armado e instalación se contratan al momento de realizar la compra de tu producto.                 |
      | Si ya contrataste un servicio, selecciona "*Elegir servicio*" para consultar su estado, reprogramarlo o cancelarlo. |
      | Si aún no has contratado un servicio y deseas hacerlo, acércate a cualquiera de nuestras tiendas.                   |
      | *Mis servicios* 🛠️                                                                                                  |
      | Consulta el estado de tu servicio, reprograma la fecha de atención o cancela tu servicio.                           |
      | Elegir servicio                                                                                                     |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                  |
      | Quiero ver el detalle de mis servicios |
  # --- Comprobantes ---

  @comprobantes
  Scenario Outline: Responde el flujo de Comprobantes a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 📌 *Recuerda que...*                                                                                                     |
      | El tipo de comprobante lo eliges al momento de realizar tu compra. *Esta elección no podrá modificarse posteriormente.* |
      | Por ejemplo, si elegiste una boleta, luego no será posible solicitar una factura.                                       |
      | *Mis comprobantes* 🧾                                                                                                    |
      | Selecciona dónde realizaste tu compra para encontrar tu comprobante de pago.                                            |
      | 💻 Tienda online                                                                                                         |
      | 🏬 Tienda física                                                                                                         |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                 |
      | Descargar comprobante |
  # --- Pedidos ---

  @misPedidos
  Scenario Outline: Responde el flujo de Mis pedidos online a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | *Mis pedidos online* 📦                                                                       |
      | Sigue tu pedido y reembolso, consulta la entrega estimada, *reprograma o cancela* tu pedido. |
      | Elegir pedido                                                                                |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase           |
      | Ver mis pedidos |
  # --- Pasa a intencion no comprendida ---

  @intencionNoComprendida
  Scenario Outline: Responde el flujo de Intención no comprendida a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | Lo siento, creo que no entendí bien tu consulta 🤔 |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                          |
      | Kiero que me den soluciones                                                                    |
      | No me sale la opción                                                                           |
      | Cómo hago                                                                                      |
      | Pero ya page                                                                                   |
      | No en olva                                                                                     |
      | Cuales son los pasos                                                                           |
      | Hola me ganó el tiempo es el trabajo mañana trato de recogerlo a las 9am mil disculpas         |
      | Hola. Que diferencia hay entre un biodogestor y un tanque biodigestor ?                        |
      | Si quiero saber por qué no hay descuento para Arequipa                                         |
      | El descuento es solo para tarjeta de crédito SIP o tmb aplica para las tarjetas de débito sip? |
      | Deseo confirmar sus características                                                            |
      | Qué es útiles?                                                                                 |
      | Que opciones ahora no le entiendo                                                              |
      | Hay aplicación de promart                                                                      |
      | Estoy esperando                                                                                |
      | Sigo esperando                                                                                 |
      | Cuando me atienden                                                                             |
      | Urgente                                                                                        |
      | URGENTE                                                                                        |
      | Necesito solución                                                                              |
      | Rápido                                                                                         |
      | No puedo realizar el cambio                                                                    |
  # --- Reembolso ---
  # PENDIENTE: valores tomados de la respuesta actual del bot; falta confirmarlos con Figma.

  @reembolso
  Scenario Outline: Responde el flujo de Reembolso a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 👉 Los plazos de retorno de tu dinero pueden variar. Te recomendamos esperar el tiempo indicado para que se procese correctamente. |
      | Si ya solicitaste tu reembolso, puedes revisar el detalle en "Mis pedidos online".                                                 |
      | Aquí te dejamos más información:                                                                                                   |
      | [imagen]                                                                                                                           |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                    |
      | Tengo esta solicitud de Devolución N° HPSA-CD-43455174-1 |
      | solicitud de Devolución N° HPSA-CD-43455174-1            |
  # --- Saludo inicial (responde con imagen) ---

 
