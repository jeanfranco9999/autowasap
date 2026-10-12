# Escenarios del bot de Oechsle.
# Las frases salen de la pestaña QA de su Excel (columna Intencion), agrupadas por su
# columna Descripción. Los textos esperados se completan con el diseño de Figma de cada grupo.
# Para probar un solo grupo: npm run test:uno -- "@<etiqueta>"

Feature: Flujos del bot Oechsle

  Background:
    Given se dirige al WhatsApp del bot "+1 (555) 707-2834"

  # --- Cambio de datos ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%7C-Dise%C3%B1o-de-Flujos-IR?node-id=8261-5645&t=SKkZXU59BrMAsK2k-0
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
      | frase                                                                                      |
      | Me puedes ayudar a corregir mi DNI que coloque mal                                         |
      | Todo está bien.. lo que quiero es que rectifiquen mi número celular que lo pusieron errado |
      | Me equivoque en poner mi dni correcto en mi compra q puedo hacer                           |
      | Puse mal el dni                                                                            |
      | Quiero agregar mi número de celular para que me puedan llamar al enviar mi pedido          |
      | Me confundí mi dni                                                                         |
      | No coloque bien mi dni                                                                     |
      | Para actualizar mis datos                                                                  |

  # --- Como cambiar o devolver ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=3572-11863&t=vab2oAofOtFJkXH0-0
  @comoCambiarODevolver
  Scenario Outline: Responde el flujo de Como cambiar o devolver a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | [imagen]                                                                           |
      | 🙋‍♂️ Te ayudo a iniciar el proceso, ¿Cómo quieres realizar tu cambio o devolución? |
      | Haz clic en uno de los siguientes botones para comenzar 👇                          |
      | 📝 Iniciar gestión aquí                                                             |
      | 🛍️ Gestión en tienda                                                               |
      | 🧾 Ver mis comprobantes                                                             |
      | ¿Puedo ayudarte en algo más? 😃                                                     |
      | ✅ Sí                                                                               |
      | ❌ No                                                                               |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                              |
      | Recibí mi pedido pero el celular se calienta mucho |

  # --- Costo y envio ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16645&t=vab2oAofOtFJkXH0-0.
  # Las frases del grupo se reparten entre los dos botones: cada intención se usa
  # una sola vez y pulsa un botón distinto.

  @costoYEnvio @verTarifas
  Scenario Outline: Costo y envio, botón Ver tarifas, con "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 🚚 Realizamos entregas en las ciudades donde Oechsle tiene presencia.                                                                                           |
      | 🛒 Agrega tus productos al carrito, continúa tu compra e ingresa tu dirección para ver *el costo de envío calculado para tu pedido* en el resumen de tu compra. |
      | 👇 Aquí encontrarás el costo de envío:                                                                                                                          |
      | [imagen]                                                                                                                                                       |
      | 🚚 *Conoce el costo de tu entrega*                                                                                                                             |
      | Consulta nuestro tarifario aproximado según el tamaño de tu pedido y la zona de cobertura.                                                                     |
      | 🚚 Ver tarifas                                                                                                                                                 |
      | 📍 *¿No tenemos cobertura en tu dirección?*                                                                                                                    |
      | Puedes comprar online y retirar tu pedido en cualquier tienda Oechsle o punto de retiro externo.                                                                |
      | Ver puntos de retiro                                                                                                                                           |
    When usuario hace clic en el botón "🚚 Ver tarifas"
    Then el botón lleva a "https://storage.googleapis.com/p-tpsaec-oec-stg-us-bf02/oechsle/web/pdf/tarifas/Tarifario-de-acuerdo-a-zonas-de-cobertura.pdf"
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                            |
      | Nesecito saber si hacen envío                    |
      | Deseo envío a domicilio                          |
      | Me.podrisn enviar a mi domicilio                 |
      | pueden indicar si llegan a Amazonas Bagua Imaza? |

  @costoYEnvio @verPuntosDeRetiro
  Scenario Outline: Costo y envio, botón Ver puntos de retiro, con "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 🚚 Realizamos entregas en las ciudades donde Oechsle tiene presencia.                                                                                           |
      | 🛒 Agrega tus productos al carrito, continúa tu compra e ingresa tu dirección para ver *el costo de envío calculado para tu pedido* en el resumen de tu compra. |
      | 👇 Aquí encontrarás el costo de envío:                                                                                                                          |
      | [imagen]                                                                                                                                                       |
      | 🚚 *Conoce el costo de tu entrega*                                                                                                                             |
      | Consulta nuestro tarifario aproximado según el tamaño de tu pedido y la zona de cobertura.                                                                     |
      | 🚚 Ver tarifas                                                                                                                                                 |
      | 📍 *¿No tenemos cobertura en tu dirección?*                                                                                                                    |
      | Puedes comprar online y retirar tu pedido en cualquier tienda Oechsle o punto de retiro externo.                                                                |
      | Ver puntos de retiro                                                                                                                                           |
    When usuario hace clic en el botón "Ver puntos de retiro"
    Then el botón lleva a "https://www.oechsle.pe/retira-en-tienda"
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                         |
      | Condiciones y términos para envío a domicilio |
      | Llega hasta acá el pedido                     |
      | envian a provincia                            |
      | Como puedo saber si llegará a casa le entrega |

  # --- FAQ ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16786&t=vab2oAofOtFJkXH0-0
  @faq
  Scenario Outline: Responde el flujo de FAQ a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 💬 *¿Tienes alguna consulta?*                                             |
      | Selecciona una de las *opciones* y encuentra la respuesta que necesitas. |
      | Opciones                                                                 |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                  |
      | Una consulta           |
      | Quiero saber si        |
      | Si nesecito ayuda      |
      | pero no me queda claro |
      | Otra consulta          |
      | Quiero consultar       |
      | Quiero información     |

  # --- Garantia ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16454&t=vab2oAofOtFJkXH0-0.
  # Las frases del grupo se reparten entre las tres opciones: cada intención se usa
  # una sola vez y pulsa un botón distinto.

  @garantia @superGarantia
  Scenario Outline: Garantia, opción Super Garantía, con "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | ¿Sobre qué tipo de producto necesitas consultar la garantía? |
      | Selecciona una opción:                                      |
      | Electro y Máquinas                                          |
      | Muebles y Decohogar                                         |
      | Super Garantía                                              |
    When usuario hace clic en el botón "Super Garantía"
    Then el bot responde
      | Si tu producto no funciona correctamente y adquiriste la opción de "Súper Garantía" en tu compra, puedes comunicarte al *0-800-00678* o al *615-5720* para recibir asistencia. |
      | ¿Puedo ayudarte en algo más? 😃                                                                                                                                                 |
      | ✅ Sí                                                                                                                                                                           |
      | ❌ No                                                                                                                                                                           |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                         |
      | Necesito consultar la garantía de un producto |
      | Garantía                                      |
      | Garantia                                      |

  @garantia @electroYMaquinas
  Scenario Outline: Garantia, opción Electro y Máquinas, con "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | ¿Sobre qué tipo de producto necesitas consultar la garantía? |
      | Selecciona una opción:                                      |
      | Electro y Máquinas                                          |
      | Muebles y Decohogar                                         |
      | Super Garantía                                              |
    When usuario hace clic en el botón "Electro y Máquinas"
    Then el bot responde
      | 🔌 *Garantía de fábrica*                                                                                                                                       |
      | Estos productos cuentan con *garantía de fábrica*. Revisa el certificado de garantía incluido con tu producto para conocer el período de vigencia y los detalles. |
      | Conoce lo más importante 👇                                                                                                                                      |
      | [2 imágenes]                                                                                                                                                     |
      | Encuentra el contacto de la Central de Servicio Técnico para productos de mayor tamaño aquí 👇📱                                                                 |
      | Central de Servicio técnico                                                                                                                                      |
      | ¿Puedo ayudarte en algo más? 😃                                                                                                                                  |
      | ✅ Sí                                                                                                                                                            |
      | ❌ No                                                                                                                                                            |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                 |
      | Ya gestioné con LG visita pero cómo activo la garantía?               |
      | Quiero saber si mi equipo telefónico tiene garantía y esta registrado |

  @garantia @mueblesYDecohogar
  Scenario Outline: Garantia, opción Muebles y Decohogar, con "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | ¿Sobre qué tipo de producto necesitas consultar la garantía? |
      | Selecciona una opción:                                      |
      | Electro y Máquinas                                          |
      | Muebles y Decohogar                                         |
      | Super Garantía                                              |
    When usuario hace clic en el botón "Muebles y Decohogar"
    Then el bot responde
      | Tu mueble cuenta con 3 meses de *garantía de Oechsle*, desde la fecha de entrega por defectos de fabricación que impidan su uso.    |
      | También cubre los daños ocasionados durante el transporte o armado, *siempre que estos servicios hayan sido realizados por Oechsle*. |
      | [imagen]                                                                                                                            |
      | 📦 ¿Tu producto fue entregado o retirado hace más de 7 días?                                                                        |
      | ✅ Sí                                                                                                                               |
      | ❌ No                                                                                                                               |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                    |
      | Quiero saber sobre la garantía de un producto que compre |
      | Garantía de productos                                    |

  # --- Medios de pago ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16728&t=vab2oAofOtFJkXH0-0
  @mediosDePago
  Scenario Outline: Responde el flujo de Medios de pago a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 💳 Al finalizar tu compra podrás elegir el medio de pago que prefieras.                     |
      | Aceptamos:                                                                                 |
      | ✅ Tarjetas de *débito o crédito Sip*.                                                      |
      | ✅ *Otras tarjetas* de débito o crédito: (Visa, Mastercard, American Express y Diners Club) |
      | ✅ Billetera digital *App Sip*.                                                             |
      | ✅ *Pago efectivo* o transferencia bancaria                                                 |
      | 📱 *¿Quieres pagar con App Sip?*                                                            |
      | Selecciona "App Sip" como medio de pago y sigue estos pasos:                               |
      | 1. Ingresa tu número de documento y teléfono.                                              |
      | 2. Confirma el pago desde la app en solo 3 pasos. 👇                                        |
      | [imagen]                                                                                   |
      | ¿Puedo ayudarte en algo más? 😃                                                             |
      | ✅ Sí                                                                                       |
      | ❌ No                                                                                       |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                           |
      | Como puedo pagar mi pedido      |
      | Quiero mas información del pago |
      | Tengo dudas sobre el pago       |
      | Cómo puedo pagar con yape       |
      | Quiero saber como pagar         |
      | Quiero pagar con sip            |
      | Como pagar                      |
      | Como pago                       |

  # --- Mis pedidos ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16778&t=vab2oAofOtFJkXH0-0
  @misPedidos
  Scenario Outline: Responde el flujo de Mis pedidos a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | *Mis pedidos online* 📦                                                                       |
      | Sigue tu pedido y reembolso, consulta la entrega estimada, *reprograma o cancela* tu pedido. |
      | Elegir pedido                                                                                |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                     |
      | No llega el correo de aprobación                                          |
      | Necesito que se me ayude con mi pedido no encuentro respuesta             |
      | Quiero saber porque no me llega ningún mensaje a mi correo de Compras     |
      | neceisto ayuda para saber de pedidos                                      |
      | ¡Hola! Hice un pedido en la web y no me llegó la confirmación a mi correo |
      | Necesito apoyo con mi pedido                                              |
      | No me llega el mensaje de ese pedido                                      |
      | Si necesito ayuda con mis pedidos                                         |

  # --- Pago efectivo ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16772&t=vab2oAofOtFJkXH0-0
  # Incluye también las frases del grupo "Pago en efectivo" del Excel, que es la misma cartilla.
  @pagoEfectivo
  Scenario Outline: Responde el flujo de Pago efectivo a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 💬 *¿Quieres pagar en efectivo?*                                                           |
      | Selecciona "Pago en efectivo / transferencia bancaria" como método de pago.                |
      | 📩 Al finalizar tu compra, recibirás por correo tu código de pago (CIP) y las instrucciones. |
      | ⏰ *¿Cuándo recibirás tu CIP?*                                                              |
      | 7:00 a. m. a 11:59 p. m.: hasta *30 minutos* después de tu compra.                         |
      | 12:00 a. m. a 5:59 a. m.: a partir de las *6:00 a. m.*                                     |
      | Puedes pagarlo de dos formas:                                                              |
      | 🌐 *Online:* desde tu banca por internet o tu app bancaria favorita                         |
      | 👛 *En efectivo:* acercándote a un agente o agencia bancaria autorizada                    |
      | ¿Puedo ayudarte en algo más? 😃                                                             |
      | ✅ Sí                                                                                       |
      | ❌ No                                                                                       |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                     |
      | Me refiero al cip para el pago por transferencia                                          |
      | No recibo el codigo de pago safetypay a mi correo electrónico                             |
      | quiero el número CIP de pago                                                              |
      | No me llega el código de pago de safetypay                                                |
      | no me llego el codigo de pago                                                             |
      | No recibo el codigo de pago de safetypay                                                  |
      | No me llega el CIP                                                                        |
      | Como pago mi compra? No me aparece codigo ni nada                                         |
      | Quiero saber cómo puedo pagarlo si seleccione la opción de pagar por transacción bancaria |

  # --- Pasa a intencion no comprendida ---
  # Figma: https://www.figma.com/design/YxUS1k4nk7E1y6bbTp8l47/Promart-%257C-WhatsApp?node-id=14125-18233&t=9NFlATTJcLzR50Se-0
  @pasaAIntencionNoComprendida
  Scenario Outline: Responde el flujo de Pasa a intencion no comprendida a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | Lo siento, creo que no entendí bien tu consulta 🤔 |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                                           |
      | quieoro inscribirme en oeshle                                                                                   |
      | Y me a llegado a mi correo ahora                                                                                |
      | Como llenó el formulario                                                                                        |
      | Yo no solicité reembolso                                                                                        |
      | Buenas noches quisiera cambiar más cuotas de mi compra                                                          |
      | Una consulta                                                                                                    |
      | Pedí un celular pero a cuotas sin interés es automático o tengo que llamar para verificar que sea sin intereses |
      | En poner mi DNI                                                                                                 |

  # --- Persona autorizada ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16436&t=vab2oAofOtFJkXH0-0
  @personaAutorizada
  Scenario Outline: Responde el flujo de Persona autorizada a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 📍 Si retiras en una tienda Oechsle, puede ir cualquier persona con el QR y su DNI.                                                                           |
      | En puntos externos, solo puede retirar el titular de la compra con su DNI.                                                                                   |
      | 📲 Recibirás el QR por correo electrónico cuando tu pedido esté listo para recoger. Si ya recibiste la notificación, también puedes verlo en "Elegir pedido". |
      | *Mis pedidos online* 📦                                                                                                                                       |
      | Consulta la dirección, horario y la fecha máxima para ir a retirar tu pedido. También puedes visualizar tu código QR de retiro.                               |
      | Elegir pedido                                                                                                                                                |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                        |
      | Todas las intenciones englobadas en esta intencion                           |
      | Pero no me llegó ningún QR a mi correo solo me aparece que está para recoger |

  # --- Plazos ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=1200-20936&t=vab2oAofOtFJkXH0-0
  @plazos
  Scenario Outline: Responde el flujo de Plazos a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 💡 El plazo máximo para hacer un cambio o devolución depende del producto, aquí te dejo más información: |
      | [2 imágenes]                                                                                             |
      | 🙋‍♂️ Si tienes otras consultas o quisieras que te ayude a iniciar tu cambio o devolución, estoy aquí para ti |
      | Haz clic en uno de los siguientes botones 👇                                                              |
      | 🔄 Cómo cambiar o devolver                                                                                |
      | ❓ Otras consultas                                                                                        |
      | ¿Puedo ayudarte en algo más? 😃                                                                           |
      | ✅ Sí                                                                                                     |
      | ❌ No                                                                                                     |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                          |
      | Condiciones para devolver un producto online debido a la talla |

  # --- Productos y stock ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=8261-7489&t=vab2oAofOtFJkXH0-0
  @productosYStock
  Scenario Outline: Responde el flujo de Productos y stock a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 🔍 *Productos y stock*                                                     |
      | Busca productos, consulta el stock disponible por tienda y compra online. |
      | Para empezar, selecciona el siguiente botón:                              |
      | Empezar                                                                   |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                       |
      | Buenas quisiera ayuda con una compra        |
      | ayuda para realizar un pedido               |
      | Necesito ayuda con los datos de un producto |
      | Deseo pedir pero no se hacerlo ayudeme      |
      | Necesito ayuda para comprar online          |

  # --- QR - Persona autorizada ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16436&t=vab2oAofOtFJkXH0-0
  @qrPersonaAutorizada
  Scenario Outline: Responde el flujo de QR - Persona autorizada a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 📍 Si retiras en una tienda Oechsle, puede ir cualquier persona con el QR y su DNI.                                                                           |
      | En puntos externos, solo puede retirar el titular de la compra con su DNI.                                                                                   |
      | 📲 Recibirás el QR por correo electrónico cuando tu pedido esté listo para recoger. Si ya recibiste la notificación, también puedes verlo en "Elegir pedido". |
      | *Mis pedidos online* 📦                                                                                                                                       |
      | Consulta la dirección, horario y la fecha máxima para ir a retirar tu pedido. También puedes visualizar tu código QR de retiro.                               |
      | Elegir pedido                                                                                                                                                |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                                                     |
      | Al ver la web dice que mi pedido y compra ya esta para recoger pero no me llego a mi correo-e el código QR para recogerlo |
      | El QR de mi pedido sin no me llega a mi correo                                                                            |
      | Ya dice: LISTO PARA RECOGER solo que no me llega el correo-e con el código QR eso necesito si ya esta                     |
      | No tengo el codigo QR                                                                                                     |
      | Tenia que recoger un producto el día de ayer pero aún no le llega el correo con el QR                                     |
      | No me llega a mi correo el Qr                                                                                             |
      | no me llega el QR para recoger pedido                                                                                     |
      | Me pide código QR no me llego al correo-e                                                                                 |

  # --- Reembolso ---
  # Figma: https://www.figma.com/design/l3LCbVyPNMG53Nz4gwY7ZA/Oechsle-%257C-WhatsApp?node-id=12967-15182&t=BtYOjOdf56bnjnpU-0
  @reembolso
  Scenario Outline: Responde el flujo de Reembolso a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 👉 Los plazos de retorno de tu dinero pueden variar. Te recomendamos esperar el tiempo indicado para que se procese correctamente. |
      | Si ya solicitaste tu reembolso, puedes revisar el detalle en "Mis pedidos online".                                                 |
      | Aquí te dejamos más información:                                                                                                   |
      | [imagen]                                                                                                                           |
      | *Mis pedidos online* 📦                                                                                                            |
      | Sigue tu pedido y reembolso, consulta la entrega estimada, *reprograma o cancela* tu pedido.                                       |
      | Elegir pedido                                                                                                                      |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                                       |
      | Mi pedido realizado hoy fue cancelado y no veo mi reembolso. ¿Podrían enviarme el comprobante de reembolso? |
      | ¿Puedo ver el recibo del reembolso?                                                                         |

  # --- SIP ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16669&t=vab2oAofOtFJkXH0-0
  @sip
  Scenario Outline: Responde el flujo de SIP a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 📣 *¡Ten en cuenta!*                                                                                                    |
      | Algunas promociones de Oechsle aplican solo con tarjeta de crédito Sip.                                                 |
      | 👀 Antes de pagar, revisa el logo de la promoción y verifica que corresponda al tipo de tarjeta que tienes.             |
      | Te mostramos cómo identificarlas 👇                                                                                     |
      | [imagen]                                                                                                               |
      | 📲 Si tienes alguna duda sobre tu Tarjeta de Débito o Crédito Sip, AhorraMás o recompensas; puedes contactar al equipo |
      | Contactar a Sip                                                                                                       |
    When usuario hace clic en el botón "Contactar a Sip"
    Then el botón lleva a "https://wa.me/51989157775"
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                  |
      | Dedo saber cómo puedo sacar una tarjeta SIP                            |
      | Tarjeta SIP                                                            |
      | Como obtengo una tarjeta                                               |
      | Tengo una tarjeta de crédito esta bloqueada o esta activa ?            |
      | Está vigente la opción 12 meses sin intereses con sip?                 |
      | pagando con al app de sip                                              |
      | Deseo saber si cálifico para una tarjeta de crédito                    |
      | Es sobre referente a mis estados de cuenta                             |
      | Como me aseguro de que lo que dice pago 12meses sin interes es cierto? |
      | Quiero informacion sobre tarjeta sip                                   |

  # --- Comprobantes ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16780&t=qzDAdqTJhyUrhorT-0
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
      | frase                |
      | Quiero ver mi boleta |

  # --- Servicios ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16783&t=qzDAdqTJhyUrhorT-0
  @servicios
  Scenario Outline: Responde el flujo de Servicios a "<frase>"
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
      | frase                     |
      | Quiero anular mi servicio |
