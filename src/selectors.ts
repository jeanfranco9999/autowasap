/**
 * Selectores de WhatsApp Web, verificados contra el HTML real (septiembre 2026).
 * WhatsApp cambia su HTML con frecuencia: si algo deja de funcionar, normalmente
 * basta con ajustar este archivo.
 */
export const sel = {
  /** Lista de chats: indica que la sesión está iniciada. */
  chatList: '#pane-side',
  /** Código QR: indica que la sesión NO está iniciada. */
  qrCode: 'canvas[aria-label*="QR" i], div[data-ref] canvas',
  /** Panel de la conversación abierta. */
  conversation: '#main',
  /** Cabecera del chat abierto (nombre y estado "en línea" / "escribiendo..."). */
  chatHeader: '#main header',
  /** Caja de texto para escribir mensajes. */
  composer: '#main footer div[contenteditable="true"]',

  /** Cada mensaje del chat (enviado o recibido). Su atributo data-id es único. */
  message: '#main [data-id][data-testid^="conv-msg-"]',
  /**
   * Contenido del mensaje. WhatsApp deja vacíos (data-virtualized="true") los mensajes
   * fuera de pantalla; solo los dibujados tienen este contenedor.
   */
  messageLoaded: '[data-testid="msg-container"]',
  /**
   * Texto del mensaje. Los emojis van dentro como <img data-plain-text="👇">.
   * Se usa ~= porque el pie de foto es data-testid="image-caption selectable-text".
   */
  messageText: 'span[data-testid~="selectable-text"]',
  /** Texto en negrita dentro del mensaje (WhatsApp lo escribe como *texto*). */
  messageBold: 'strong[data-app-text-template]',
  /** Foto o video del mensaje (los emojis también son <img>, pero no cuentan). */
  messageImage: '[data-testid="image-thumb"], video',
  /** Hora y estado del mensaje (tiene role="button", pero no es un botón del bot). */
  messageMeta: '[data-testid="msg-meta"]',
  /** Estado Enviado / Entregado / Leído: solo lo tienen los mensajes que TÚ envías. */
  messageStatus: '[data-testid="msg-meta"] [aria-label]',
  /** Botones del bot dentro de la burbuja ("Opciones", "Sí", "No"...). */
  messageButtons: '[role="button"]',

  /** Botón del aviso "WhatsApp está abierto en otra ventana". */
  useHereButton: 'button:has-text("Usar aquí"), button:has-text("Use here")',
  /** URL que muestra WhatsApp al pulsar un botón que abre un enlace. */
  popupUrl: '[data-testid="popup-url-text"]',
  /** Ventana emergente (ej. número inválido). */
  dialog: 'div[role="dialog"], [data-animate-modal-popup="true"]',
};
