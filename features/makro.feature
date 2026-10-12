# Escenarios del bot de Makro.
# Las frases salen de la pestaña QA de su Excel (columna Intencion), agrupadas por su
# columna Descripción. Los textos esperados se completan con el diseño de Figma de cada grupo.
# Para probar un solo grupo: npm run test:uno -- "@<etiqueta>"

Feature: Flujos del bot Makro

  Background:
    Given se dirige al WhatsApp del bot "+51 999 999 999"

  # --- Intención no comprendida ---
  # Figma: https://www.figma.com/design/YxUS1k4nk7E1y6bbTp8l47/Promart-%257C-WhatsApp?node-id=14125-18233&t=9NFlATTJcLzR50Se-0
  @intencionNoComprendida
  Scenario Outline: Responde el flujo de Intención no comprendida a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | Lo siento, creo que no entendí bien tu consulta 🤔 |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                              |
      | Quién puede ir a recoger mi pedido |
      | Quiero ver mi QA                   |
      | Cambiar el lugar para ir a retirar |

  # --- Cambiar datos ---
  # Figma: https://www.figma.com/design/6QcaZKt9IK4qtLNTSQq9gC/Makro-%257C-WhatsApp?node-id=19511-17198&t=cYcIr49uvP3oRojX-0
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
      | frase                                                                   |
      | QUIERO ADICIONAR A MI PEDIDO *Concentrado de Maíz Morado MONA *         |
      | REALICE MI PEDIDO HOY Y ME EQUIVOQUE NE LA CANTIDAD DE ESTE PRODUCTO    |
      | Puedo agregar más cosas a mi pedido                                     |
      | Agregar más productos a un pedido                                       |
      | es sal de mesa en lugar de sal de cocina                                |
      | si quiero cambiar un item antes de que lo entreguen                     |
      | me equivoqué al leer el detalle es sal de cocina en luga de sal de mesa |
      | QUIERO CAMBIAR UN ITEM DE M IPEDIDO                                     |
      | necesito incluir mas productos                                          |
      | Pero por error compre las botellas pequeñas                             |
      | Agregar un producto más a mi compra                                     |
      | Agregar un producto más a mi pedido                                     |
      | Quiero aumentar mi pedido                                               |
      | Hice mi pedido pero me gustaria aumentar productos a ese pedido         |
      | Aumentar cosas a mi pedido                                              |
      | solo me olvide inclouir un producto en mi lista como puedo hacer        |
      | Puedo agregar algo al pedido que acabo de hacer?                        |

  # --- Cobertura y costos de envios ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11680-15206&t=uHm5ho7XnRbzYrY4-0
  @coberturaYCostosDeEnvios
  Scenario Outline: Responde el flujo de Cobertura y costos de envios a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 🚚 Realizamos entregas en las ciudades donde Makro tiene presencia.                                                                                           |
      | 🛒 Agrega tus productos al carrito, continúa tu compra e ingresa tu dirección para ver *el costo de envío calculado para tu pedido* en el resumen de tu compra. |
      | 👇 Aquí encontrarás el costo de envío:                                                                                                                          |
      | [imagen]                                                                                                                                                       |
      | 📍 Si no tenemos cobertura en tu dirección, puedes *comprar online y retirar tu pedido* en cualquier tienda Makro o en un punto de retiro externo.            |
      | Conócelos aquí                                                                                                                                               |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                                           |
      | No hacen delivery                                                                                               |
      | Quiero saber si hay cobertura de delivery para mi domicilio                                                     |
      | Quiero saber si en makro cuaco hacen delivery                                                                   |
      | Delivery                                                                                                        |
      | Pueden llevarlo                                                                                                 |
      | Aden delivery                                                                                                   |
      | Hola hacen delivery express?                                                                                    |
      | Pedido virtual a dirección de villa elSalvador sector 3 grupo 27A manzana O lote 21 llega el pedido a domicilio |
      | Hacen envíos ?                                                                                                  |
      | Quier que al llegar ami dirección toquen el intercomunicador 401                                                |
      | Pedidos delivery                                                                                                |
      | Monto mínimo de delivery                                                                                        |
      | Costo del delivery                                                                                              |

  # --- Tiendas y horarios ---
  # Figma: https://www.figma.com/design/6QcaZKt9IK4qtLNTSQq9gC/Makro-%257C-WhatsApp?node-id=19461-15807&t=cYcIr49uvP3oRojX-0
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
      | frase                                                  |
      | Horario de atención en Huancayo                        |
      | Horario de atención de makro surco                     |
      | Makro huacho está abierto hasta las 9pm                |
      | Hasta qué hora atienden hoy día en Makro de Chorrillos |

  # --- Catálogo ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-17125&t=uHm5ho7XnRbzYrY4-0
  @catalogo @pendiente
  Scenario Outline: Responde el flujo de Catálogo a "<frase>"
    When usuario escribe en el chat "<frase>"
    # PENDIENTE: copia del diseño los textos esperados y quita los # de estas líneas.
    # Then el bot responde
    #   | texto esperado tal como está en Figma |
    #   | *texto que va en negrita*             |
    #   | [imagen]                              |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                     |
      | Catálogo                                                  |
      | Quiero catálogo                                           |
      | QUSIERA QUE ME ENVIES LAS REVISTAS DE ENERO 2026          |
      | Qué tal un favor no me puedes mandar un catálogo completo |
      | Me podra enviar el catalago                               |
      | Promoción de todo macroo                                  |
      | necesito el catalogo vigente                              |
      | Catálogo de Makro Arequipa Avelino                        |
      | Quiero último catalogo                                    |

  # --- Cliente MKR ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11680-15152&t=uHm5ho7XnRbzYrY4-0
  @clienteMkr @pendiente
  Scenario Outline: Responde el flujo de Cliente MKR a "<frase>"
    When usuario escribe en el chat "<frase>"
    # PENDIENTE: copia del diseño los textos esperados y quita los # de estas líneas.
    # Then el bot responde
    #   | texto esperado tal como está en Figma |
    #   | *texto que va en negrita*             |
    #   | [imagen]                              |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                      |
      | Cliente makro                                                                              |
      | Quiero ser cliente MAKRO                                                                   |
      | Quiero que me aflien a mi cuenta de macro y tener descuento. Soy cliente de macro directa. |

  # --- Cupón ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11680-15098&t=uHm5ho7XnRbzYrY4-0
  @cupon @pendiente
  Scenario Outline: Responde el flujo de Cupón a "<frase>"
    When usuario escribe en el chat "<frase>"
    # PENDIENTE: copia del diseño los textos esperados y quita los # de estas líneas.
    # Then el bot responde
    #   | texto esperado tal como está en Figma |
    #   | *texto que va en negrita*             |
    #   | [imagen]                              |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                                                                                                                                                                          |
      | Se aplica el cupon                                                                                                                                                                                             |
      | Me sale que hay un cupon                                                                                                                                                                                       |
      | Como obtengo el descuento de 40 soles por primera compra                                                                                                                                                       |
      | ¡Hola! Quiero obtener el cupon del delivery gratis pasando los 400 soles de compra cómo hago                                                                                                                   |
      | hola quiero hacer uso del cupon de                                                                                                                                                                             |
      | alguien mas puede darme soluciion a un cupon de descuento que no se activa??                                                                                                                                   |
      | NO ME HAN APLICADO EL DESCUENTO DEL CUPON FREE2026                                                                                                                                                             |
      | NO FUNCIONA LOS CUPONES                                                                                                                                                                                        |
      | No funciona el descuento SOYMAKRO40                                                                                                                                                                            |
      | Acabo de hacer una compra ingresando el cupon que me enviaron pero no descontaron nada                                                                                                                         |
      | No tengo un reclamo tengo un cupon de dsto por cumpleaño y no se a aplicado en algunos productos ademas no dice nada ni en letritas de restricciones y ademas debo de tener un cupon de dsto x complas en mayo |

  # --- Pedido incompleto ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-17112&t=uHm5ho7XnRbzYrY4-0
  @pedidoIncompleto @pendiente
  Scenario Outline: Responde el flujo de Pedido incompleto a "<frase>"
    When usuario escribe en el chat "<frase>"
    # PENDIENTE: copia del diseño los textos esperados y quita los # de estas líneas.
    # Then el bot responde
    #   | texto esperado tal como está en Figma |
    #   | *texto que va en negrita*             |
    #   | [imagen]                              |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                       |
      | Mi pedido llegó incompleto  |
      | Un producto faltante        |
      | No llegó mi pedido completo |
      | No llego mi pedido completo |

  # --- Pedido inompleto ---
  @pedidoInompleto @pendiente
  Scenario Outline: Responde el flujo de Pedido inompleto a "<frase>"
    When usuario escribe en el chat "<frase>"
    # PENDIENTE: copia del diseño los textos esperados y quita los # de estas líneas.
    # Then el bot responde
    #   | texto esperado tal como está en Figma |
    #   | *texto que va en negrita*             |
    #   | [imagen]                              |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                |
      | No me llegan los productos completos |
      | no me llego el pedido completo       |
      | Pedido incompleto                    |

  # --- FAQ ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-17166&t=uHm5ho7XnRbzYrY4-0
  @faq
  Scenario Outline: Responde el flujo de FAQ a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | 💬 *¿Tienes alguna consulta?*                                             |
      | Selecciona una de las *opciones* y encuentra la respuesta que necesitas. |
      | Opciones                                                                 |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase            |
      | Osea le escribo? |

  # --- Cotizaciones ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11703-19122&t=uHm5ho7XnRbzYrY4-0
  @cotizaciones @pendiente
  Scenario Outline: Responde el flujo de Cotizaciones a "<frase>"
    When usuario escribe en el chat "<frase>"
    # PENDIENTE: copia del diseño los textos esperados y quita los # de estas líneas.
    # Then el bot responde
    #   | texto esperado tal como está en Figma |
    #   | *texto que va en negrita*             |
    #   | [imagen]                              |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                                                              |
      | Quiero la cotización de 120 unidades de cerveza pilsen             |
      | Pedido unpedi una cotización de pilsen callao de 630 ml            |
      | Cotización                                                         |
      | Cotización de productos                                            |
      | cotizacion                                                         |
      | necesito una cotizacion de unos productos                          |
      | quiero una cotización formal                                       |
      | para una empresa que pide por mayor ¿se pueden hacer cotizaciones? |

  # --- Pedidos ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-17157&t=bRwsqj1ITjRK0EMM-0
  @pedidos
  Scenario Outline: Responde el flujo de Pedidos a "<frase>"
    When usuario escribe en el chat "<frase>"
    Then el bot responde
      | *Mis pedidos online* 📦                                                                       |
      | Sigue tu pedido y reembolso, consulta la entrega estimada, *reprograma o cancela* tu pedido. |
      | Elegir pedido                                                                                |
    When usuario escribe en el chat "Cerrar sesión"

    Examples:
      | frase                   |
      | Quiero anular mi pedido |

  # --- Comprobantes ---
  # Figma: https://www.figma.com/design/OkM3OAUzhebVohroJBvduR/Whatsapp-%257C-Dise%25C3%25B1o-de-Flujos-IR?node-id=11399-17159&t=bRwsqj1ITjRK0EMM-0
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
      | frase                          |
      | Quiero ver mi boleta de compra |
