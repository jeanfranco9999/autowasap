# Escenarios del bot de Plaza Vea.
# Las frases salen de la pestaña QA de su Excel (columna Intencion), agrupadas por su
# columna Descripción. Los textos esperados se completan con el diseño de Figma de cada grupo.
# Para probar un solo grupo: npm run test:uno -- "@<etiqueta>"

Feature: Flujos del bot Plaza Vea

  Background:
    Given se dirige al WhatsApp del bot "+55 11 3506-1635"

  # --- Cambiar datos ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%7C-Dise%C3%B1o-de-Flujos-IR?node-id=8261-5645&t=SKkZXU59BrMAsK2k-0
  @cambiarDatos
  Scenario Outline: Responde el flujo de Cambiar datos a "<frase>"
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
      | frase                                                                                                                      |
      | Quiero que cambien mi numero de contacto                                                                                   |
      | Quiero cambiar el numero de telefono de contacto                                                                           |
      | Quiero cambiar el Gmail                                                                                                    |
      | quiero cambiar el correo porque está equivocado. En correcto es chiclayovegahenrry@gmail.com. Lo puedes cambiar por favor? |
      | No tengo acceso al correo                                                                                                  |
      | Quiero cambiar el nombre a mi pedido                                                                                       |
      | Puse mal mi correo y no me llega el correo de confirmación de la compra                                                    |
      | el correo que puse esta con error                                                                                          |
      | Hola aclarar que la entrega es a Club Internacional Arequipa                                                               |
      | Puse mal mi correo en mi pedido                                                                                            |
      | Hola buenas noches ah habido un error en mi pedido                                                                         |

  # --- Cambiar o devolver ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=3572-11863&t=qzDAdqTJhyUrhorT-0
  @cambiarODevolver
  Scenario Outline: Responde el flujo de Cambiar o devolver a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | [imagen]                                                                        |
      | 🙋‍♂️ Te ayudo a iniciar el proceso, ¿Cómo quieres realizar tu cambio o devolución? |
      | Haz clic en uno de los siguientes botones para comenzar 👇                       |
      | 📝 Iniciar gestión aquí                                                          |
      | 🛍️ Gestión en tienda                                                             |
      | 🧾 Ver mis comprobantes                                                          |
      | ¿Puedo ayudarte en algo más? 😃                                               |
      | ✅ Sí                                                                         |
      | ❌ No                                                                         |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                       |
      | No coincide con lo que pedí |

  # --- Cobertura y costo de envio ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16902&t=qzDAdqTJhyUrhorT-0
  # Las frases del grupo se reparten entre los dos botones: cada intención se usa
  # una sola vez y pulsa un botón distinto.

  @coberturaYCostoDeEnvio @zonaDeCobertura
  Scenario Outline: Cobertura y costo de envio, botón Zona de cobertura, con "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 🛒 Agrega tus productos al carrito, continúa tu compra e ingresa tu dirección para ver *el costo de envío calculado para tu pedido* en el resumen de tu compra. |
      | 👇 Aquí encontrarás el costo de envío:                                                                                                                         |
      | [imagen]                                                                                                                                                      |
      | 🚚 Conoce nuestras zonas de cobertura para despacho a domicilio                                                                                                |
      | 🚚 Zona de cobertura                                                                                                                                           |
      | 📍 Si no tenemos cobertura en tu dirección, puedes *comprar online y retirar tu pedido* en cualquier tienda Plaza Vea o en un punto de retiro externo.          |
      | 📍 Puntos de retiro                                                                                                                                            |
    When usuario hace clic en el botón "🚚 Zona de cobertura"
    Then el botón lleva a "https://www.plazavea.com.pe/terminos-y-condiciones"
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                     |
      | pero no esta disponible para mi direccion                                 |
      | quisiera saber cuanto es el costo en llevar un artefacto a casa           |
      | Quiero saber por q no se pueden hacer entregas en mi dirección?           |
      | quisiera hacer pedido de un producto pero no lo tienen disponible en lima |

  @coberturaYCostoDeEnvio @puntosDeRetiro
  Scenario Outline: Cobertura y costo de envio, botón Puntos de retiro, con "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 🛒 Agrega tus productos al carrito, continúa tu compra e ingresa tu dirección para ver *el costo de envío calculado para tu pedido* en el resumen de tu compra. |
      | 👇 Aquí encontrarás el costo de envío:                                                                                                                         |
      | [imagen]                                                                                                                                                      |
      | 🚚 Conoce nuestras zonas de cobertura para despacho a domicilio                                                                                                |
      | 🚚 Zona de cobertura                                                                                                                                           |
      | 📍 Si no tenemos cobertura en tu dirección, puedes *comprar online y retirar tu pedido* en cualquier tienda Plaza Vea o en un punto de retiro externo.          |
      | 📍 Puntos de retiro                                                                                                                                            |
    When usuario hace clic en el botón "📍 Puntos de retiro"
    Then el botón lleva a "https://www.plazavea.com.pe/recojo-en-tienda"
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                    |
      | Envian a domicilio?                                                      |
      | quiero hacer un pedido online pero está habilitado el delivery para zona  |
      | Quisiera saber si pueden traérmelo o tengo que recogerlo ?               |
      | desea saber si hay entrega a domicilio en provincia                      |

  # --- Comprobantes ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-17031&t=qzDAdqTJhyUrhorT-0
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
      | frase                                                                 |
      | Un favor en la compra de mi pedido he escrito un numero mal en mi dni |
      | Hola en la factura me sale otro nombre                                |
      | La boleta electrónica deseo que parezca el nombre de otra persona     |
      | Quiero que modifiquen la factura                                      |

  # --- Garantia ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16880&t=qzDAdqTJhyUrhorT-0.
  # Las frases del grupo se reparten entre las dos opciones: cada intención se usa
  # una sola vez y pulsa un botón distinto.

  @garantia @superGarantia
  Scenario Outline: Garantia, opción Adquirí Super Garantía, con "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | ¿Sobre qué tipo de producto necesitas consultar la garantía? |
      | Selecciona una opción:                                      |
      | 🔌 Productos Electro                                        |
      | 🛡️ Adquirí Super Garantía                                   |
    When usuario hace clic en el botón "🛡️ Adquirí Super Garantía"
    Then el bot responde
      | Si tu producto no funciona correctamente y adquiriste la opción de "Súper Garantía", puedes comunicarte al *01-625-8000* para recibir asistencia. |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                     |
      | Usó de garantía                                           |
      | Garantía de un producto                                   |
      | Garantía de productos                                     |
      | Deseo saber sobre garantía de la refrigeradora qué compre |

  @garantia @productosElectro
  Scenario Outline: Garantia, opción Productos Electro, con "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | ¿Sobre qué tipo de producto necesitas consultar la garantía? |
      | Selecciona una opción:                                      |
      | 🔌 Productos Electro                                        |
      | 🛡️ Adquirí Super Garantía                                   |
    When usuario hace clic en el botón "🔌 Productos Electro"
    Then el bot responde
      | Estos productos cuentan con garantía de fábrica. Para conocer el período de vigencia y los detalles, *revisa el certificado de garantía incluido con tu producto*. |
      | 🤝 Nuestro equipo se encargará de coordinar con el proveedor para evaluar tu solicitud.                                                                             |
      | Conoce lo más importante 👇                                                                                                                                        |
      | [imagen]                                                                                                                                                           |
      | 📦 ¿Han pasado más de 7 días desde que recibiste o retiraste tu producto?                                                                                           |
      | ✅ Sí                                                                                                                                                               |
      | ❌ No                                                                                                                                                               |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                                                  |
      | Quiero saber garantía de un producto                                                                                   |
      | Garantía                                                                                                               |
      | no hice aun la compra quiero preguntar si un tv tiene garantía porque en tu pagina web dice que no cuenta con garantía |
      | Quiero ver si mi producto tiene garantía                                                                               |

  # --- Medios de pago ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16963&t=qzDAdqTJhyUrhorT-0
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
      | frase                                                      |
      | Hola quiero saber si se puede pagar con tarjeta de crédito |

  # --- Mis pedidos ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-17029&t=qzDAdqTJhyUrhorT-0
  @misPedidos
  Scenario Outline: Responde el flujo de Mis pedidos a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | *Mis pedidos online* 📦                                                                       |
      | Sigue tu pedido y reembolso, consulta la entrega estimada, *reprograma o cancela* tu pedido. |
      | Elegir pedido                                                                                |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                                               |
      | aun no me llega el correo de confirmación                                                                           |
      | Hasta que hora es el horario de recojo de un pedido web?                                                            |
      | ¡Hola! Hice un pedido en la web me salió el cargo en la tarjeta pero no me llegó la confirmación por correo ni nada |
      | Horario de atención para recojo de compra online                                                                    |
      | No llego a mi correo la compra                                                                                      |
      | No recibo confirmación en mi e-mail                                                                                 |
      | Buenos días he realizado una compra y aún no me llega a mi correo los detalles                                      |
      | NO HE recibido el correo electronico con el pedido                                                                  |

  # --- Pedido incompleto ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16861&t=qzDAdqTJhyUrhorT-0
  @pedidoIncompleto
  Scenario Outline: Responde el flujo de Pedido incompleto a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | Si tu pedido no ha llegado completo, puede deberse a lo siguiente:                                                                    |
      | 🚚 Tu pedido tiene más de un despacho. Es posible que uno de ellos y haya sido entregado y el otro aún se encuentre En Camino.         |
      | 📦 Algún producto se agotó o se ajustó la cantidad solicitada.                                                                        |
      | 👉 Para revisar el detalle de tu pedido, ingresa a la sección "Mis pedidos" e inicia sesión.                                           |
      | Haz clic en el siguiente botón 👇                                                                                                     |
      | Ir a Mis pedidos                                                                                                                      |
    # El botón debe derivar a la cartilla de Mis pedidos
    When usuario hace clic en el botón "Ir a Mis pedidos"
    Then el bot responde
      | *Mis pedidos online* 📦                                                                      |
      | Sigue tu pedido y reembolso, consulta la entrega estimada, *reprograma o cancela* tu pedido. |
      | Elegir pedido                                                                                |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                                                      |
      | le faltó un producto a mi pedido                                                                                           |
      | Está incompleto                                                                                                            |
      | No me ha llegado completo                                                                                                  |
      | yo he comprado por la web una lista de productos pero no me llegó el polvo para hornear que pedí.                          |
      | pedido incompleto                                                                                                          |
      | Mi pedido llego incompleto                                                                                                 |
      | me falta la barra de sonido en el pedido                                                                                   |
      | Faltan algunos artículos en mi pedido. Papa Prefrita Congelada AVIKO Bolsa 1kg y Chicharrón de Pollo AVINKA Bolsa 350g x 2 |

  # --- Persona autorizada ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16865&t=qzDAdqTJhyUrhorT-0
  @personaAutorizada
  Scenario Outline: Responde el flujo de Persona autorizada a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 📍 Si retiras en una tienda Plaza Vea, puede ir cualquier persona con el QR y su DNI.                                                                           |
      | En puntos externos, solo puede retirar el titular de la compra con su DNI.                                                                                   |
      | 📲 Recibirás el QR por correo electrónico cuando tu pedido esté listo para recoger. Si ya recibiste la notificación, también puedes verlo en "Elegir pedido". |
      | *Mis pedidos online* 📦                                                                                                                                       |
      | Consulta la *dirección, horario y la fecha máxima* para ir a retirar tu pedido. También puedes visualizar tu *código QR* de retiro.                         |
      | Elegir pedido                                                                                                                                                |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                       |
      | El correo con el qr                                         |
      | Pero aún no me enviar el código Qr para recoger             |
      | Quiero el QR para recoger mi pedido                         |
      | No me llega el código QR para recoger mi pedido             |
      | QR enviar de nievo                                          |
      | QR no me llegó para recoger el pedido                       |
      | Le indicaron a mi esposo que no se puede entregar sin el QR |
      | QR de mi pedido no me llega                                 |

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
      | frase                                |
      | Tengo una consulta sobre un producto |
      | Tengo duda de un producto            |

  # --- Sip ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-16944&t=qzDAdqTJhyUrhorT-0
  @sip
  Scenario Outline: Responde el flujo de Sip a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 📣 *¡Ten en cuenta!*                                                                                                    |
      | Algunas promociones de Plaza Vea aplican solo con tarjeta de crédito Sip.                                               |
      | 👀 Antes de pagar, revisa el logo de la promoción y verifica que corresponda al tipo de tarjeta que tienes.             |
      | Te mostramos cómo identificarlas 👇                                                                                     |
      | [imagen]                                                                                                               |
      | 📲 Si tienes alguna duda sobre tu Tarjeta de Débito o Crédito Sip, AhorraMás o recompensas; puedes contactar al equipo |
      | Contactar a Sip                                                                                                       |
    When usuario hace clic en el botón "Contactar a Sip"
    Then el botón lleva a "https://wa.me/51989157775"
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                                    |
      | Como puedo obtener mi tarjeta oh                                                                         |
      | Quería saber si el pago con la sip es exclusiva con la tarjeta de crédito o TMB puede ser con la virtual |
      | ahi se indicaba que el precio con tarjeta SIP era menor al que me han cobrado porque ?                   |
      | Si cuento con la tarjeta Oh! es la misma a la tarjeta SIP?                                               |
      | Pague con mi tarjeta oh! pay y no me hizo el descuento                                                   |
      | Quiero pagar con tarjeta oh pero no me sale el descuento                                                 |
      | Hola el pago con SIP salía 337 y me han cobrado 338 porque?                                              |

  # --- Tienda sy horario ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=8261-7494&t=qzDAdqTJhyUrhorT-0
  @tiendaSyHorario
  Scenario Outline: Responde el flujo de Tienda sy horario a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | Excelente pregunta, tengo la información precisa para ayudarte con ello                                  |
      | *Tiendas y horarios* 🛍️                                                                                  |
      | Selecciona el tipo de búsqueda que quisieras realizar para ayudarte a encontrar la tienda más cercana 👇 |
      | 📍 Enviar ubicación                                                                                      |
      | 🏬 Elegir tienda                                                                                         |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                          |
      | Días y horarios de recojo en plaza Vea Huancayo sede principal |
      | Buenos dias hoy atienden en Cusco                              |
      | Hoy atienden en el local de tullumayo cusco                    |
      | Horario de plaza vea chacarera                                 |
      | Días de recojo en plaza Vea sede principal                     |
      | Horario de retiro en tienda Plaza vea Risso                    |
      | Quiero saber el horario de atención de Plaza Vea Pisco         |

  # --- FAQ ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-17037&t=qzDAdqTJhyUrhorT-0
  @faq
  Scenario Outline: Responde el flujo de FAQ a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 💬 *¿Tienes alguna consulta?*                                             |
      | Selecciona una de las *opciones* y encuentra la respuesta que necesitas. |
      | Opciones                                                                 |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase              |
      | Ayuda              |
      | mÁS INFORMACIÓN    |
      | Tengo una consulta |

  # --- hora de entrega ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=8271-10992&t=qzDAdqTJhyUrhorT-0
  @horaDeEntrega
  Scenario Outline: Responde el flujo de hora de entrega a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 👉 Recibirás un correo cuando tu pedido salga a reparto. Desde ese momento estará "en camino" y podrás consultar por aquí un rango de hora de entrega más preciso. |
      | *Mis pedidos online* 📦                                                                                                                                             |
      | Sigue tu pedido y reembolso, consulta la entrega estimada, *reprograma o cancela* tu pedido.                                                                       |
      | Elegir pedido                                                                                                                                                      |
      | ¿Puedo ayudarte en algo más? 😃                                                                                                                                     |
      | ✅ Sí                                                                                                                                                               |
      | ❌ No                                                                                                                                                               |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                    |
      | Cambiar de horario para entrega                          |
      | Qué día está llegando                                    |
      | Quiero cambiar el horario                                |
      | Quisiera saber que día me enviaran el producto y la hora |
