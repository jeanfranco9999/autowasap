# Pruebas del bot de pedidos en WhatsApp

Escribes conversaciones en archivos `.feature` (Gherkin). La automatización las ejecuta en WhatsApp Web y **toma una captura de cada respuesta del bot**. Tú solo revisas el reporte.

## Primera vez (solo una vez)

1. Instalar: `npm install`
2. Copiar `.env.example` como `.env` y poner tu número en `MY_PHONE` (solo dígitos, con código de país, ej. `51999999999`).
3. Vincular WhatsApp: `npm run login` → se abre Chrome → escanea el QR desde tu celular (**WhatsApp > Dispositivos vinculados > Vincular dispositivo**).

La sesión queda guardada en `.sessions/<tu número>`. Solo se vuelve a pedir el QR si WhatsApp desvincula el dispositivo. Si pasa, las pruebas te avisan: "Ejecuta: npm run login".

## Los escenarios ya creados

En `features/` hay un archivo por grupo de la columna "Descripción" de la hoja **QA** de `NLU - Promart.xlsx` (`faq.feature`, `garantia.feature`, `stock.feature`…). Cada uno tiene un `Scenario Outline`: la prueba se repite con cada frase del Excel, listadas en `Examples`. Arriba de cada `Feature` hay una etiqueta (`@garantia`, `@stock`…) para ejecutar solo ese grupo.

Para agregar una frase a un grupo, basta con sumar una fila a su tabla `Examples`.

## Escribir un escenario nuevo

Crea un archivo en la carpeta `features/`, por ejemplo `features/seguimiento.feature`:

```gherkin
Feature: Seguimiento de pedido

  Scenario: Ver el estado de un pedido
    Given se dirige al WhatsApp del bot "51988888888"
    When usuario escribe en el chat "Mis pedidos"
    Then el bot responde
      | Tus pedidos          |
      | Selecciona un pedido |
    When usuario escribe en el chat "Ver detalle"
    Then el bot responde
      | Estado del pedido |
    When usuario escribe en el chat "Cerrar sesión"
```

| Paso | Qué hace |
|---|---|
| `Given se dirige al WhatsApp del bot "<número>"` | Abre WhatsApp Web en el chat del bot. El número puede ir con `+`, espacios o guiones |
| `When usuario escribe en el chat "<texto>"` | Envía el texto, espera la respuesta del bot (mínimo 5 segundos) y toma la captura |
| `Then el bot responde` + tabla | Revisa que **cada fila** de la tabla aparezca en la respuesta |
| `When usuario hace clic en el botón "<texto>"` | Pulsa un botón de la respuesta del bot (por ejemplo "Opciones") y toma la captura |
| `Then la lista muestra` + tabla | Revisa que cada fila aparezca en el desplegable de opciones que abrió ese botón, y lo cierra |

**Tabla del `Then`:**
- **Primera columna**: el texto que debe aparecer en la respuesta, tal como está en Figma e **incluyendo los emojis** (ej. `➡️ ¿Tienes alguna duda…`). Basta con que la respuesta lo *contenga*; no importan mayúsculas ni espacios de más.
- **Negritas**: se marcan con asteriscos dentro de la misma frase, igual que se escribe la negrita en WhatsApp (`| ✅ Billetera digital *App Sip*. |`). Se valida el texto completo y, además, que esa parte venga en negrita.
- **Listas numeradas**: el número forma parte del texto esperado (`| 1. Ingresa tu número de documento y teléfono. |`).
- **Fila `[imagen]`**: valida que el bot respondió con una foto o un video, sin mirar su contenido. También sirven `[foto]` y `[video]`. Si el diseño muestra varias, indica la cantidad: `[4 imágenes]` exige exactamente cuatro. El pie de foto se valida como cualquier otro texto:
  ```gherkin
  Then el bot responde
    | [imagen]                                             |
    | ¡Hola, jean! ¡Qué bueno tenerte por aquí de nuevo! 😊 |
  ```
- **Columnas siguientes** (opcionales): notas, por ejemplo la pantalla o el componente de Figma. No se validan; solo se muestran en el reporte.
- Se revisan todas las filas aunque alguna falle, y el reporte marca cada una con ✔ o ✘.
- `Then el bot responde` siempre lleva tabla. Si solo quieres la captura para revisarla a ojo, no pongas `Then`: el `When` ya toma la captura y falla si el bot no responde.

Termina cada escenario con `When usuario escribe en el chat "Cerrar sesión"` para que el siguiente empiece como una conversación nueva.

## Ejecutar y revisar

- Todas las pruebas: `npm test` (son ~137 escenarios y tardan más de una hora).
- Solo un grupo, por etiqueta: `npm run test:uno -- "@stock"` (la etiqueta está arriba de cada `Feature`).
- Solo un escenario, por texto: `npm run test:uno -- "No me llega el QR"`
- Ver el reporte: `npm run report` → abre el reporte de **Cucumber** en el navegador. Cada escenario muestra sus pasos Gherkin con la captura, el texto recibido y la validación fila por fila (✔/✘). En rojo aparece lo que no coincidió.
- Todo queda en la carpeta `test-results/`:
  - `cucumber-report.html`: el reporte, un solo archivo con las capturas incluidas. Puedes enviarlo por correo o chat.
  - `cucumber-report.json` y `cucumber-messages.ndjson`: los mismos resultados en formatos de Cucumber, para otras herramientas.
  - `screenshots/<feature>/<escenario>/`: las capturas sueltas.
- Cada `npm test` reemplaza los resultados anteriores.

No uses WhatsApp Web en otra ventana de Chrome mientras corren las pruebas.

## Cómo leer el reporte

Los escenarios en verde están bien. En los rojos, el paso marcado explica qué pasó:

| Mensaje | Qué significa |
|---|---|
| **FALTA ESTE TEXTO** | El bot no envió ese texto por ningún lado |
| **EL TEXTO ES DISTINTO** | El bot envió algo parecido; debajo se ve qué debía decir y qué dice |
| **FALTA LA NEGRITA** | El texto llegó, pero el bot no lo envió en negrita |
| **FALTA LA IMAGEN** | El bot no envió ninguna foto ni video |
| **FALTA ESTA OPCIÓN EN LA LISTA** | La opción no aparece en el desplegable |
| **ESTA OPCIÓN DICE OTRA COSA** | La opción está, pero con otro texto |
| **EL BOTÓN LLEVA A OTRA PÁGINA** | El botón abre una web distinta a la esperada |
| **EL BOTÓN ABRE OTRO CHAT** | El botón deriva a un número distinto al esperado |
| **El bot no respondió a "..."** | Pasó el tiempo de espera sin respuesta |

Debajo de cada paso hay dos anexos que se abren con un clic:
- **Captura N**: la foto del chat, con tu mensaje y la respuesta del bot.
- **Revisión de la respuesta**: la lista completa de lo revisado, con ✔ y ✘, y al final el texto exacto que respondió el bot.

## Si algo deja de funcionar

WhatsApp cambia su página seguido. Si las pruebas no encuentran la caja de texto, los mensajes o los botones, hay que ajustar los selectores en `src/selectors.ts`.

Los tiempos de espera se configuran en `.env`:
- `REPLY_MIN_WAIT_SECONDS` (5): siempre se espera al menos esto después de cada mensaje.
- `REPLY_SETTLE_SECONDS` (3): segundos sin mensajes nuevos para dar por terminada la respuesta (el bot puede enviar varias burbujas).
- `REPLY_TIMEOUT_SECONDS` (30): si en este tiempo el bot no responde, el paso falla.
