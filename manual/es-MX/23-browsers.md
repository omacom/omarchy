# Navegadores

Omarchy viene con [Google Chrome](https://www.google.com/chrome/) como navegador predeterminado. Tiene un tema a juego con el resto de tu sistema, y es lo que se abre con `Super + Shift + Return` (o `Super + Shift + B`), con `Super + Shift + Alt + B` para una ventana privada, y dentro de él se ejecuta cada [aplicación web](25-web-apps.md). Se abre directamente en una ventana del navegador: no hay pantalla de bienvenida ni aviso para iniciar sesión, las estadísticas de uso y los informes de fallos no se envían a Google, y los avisos de privacidad publicitaria están desactivados. Aun así, puedes iniciar sesión en tu cuenta de Google desde el botón de perfil cuando quieras sincronizar.

Si Chrome no es lo tuyo, no estás condenado a usarlo. En _Instalar > Navegador_ del menú de Omarchy encontrarás [Chromium](https://www.chromium.org/) (la compilación sencilla de código abierto a partir de la cual se crea Chrome), Edge, Brave, Brave Origin, Firefox y [Zen](https://zen-browser.app/) (Edge solo en equipos x86). Elige uno y Omarchy lo instala, configura su directorio de políticas y le aplica tu tema actual.

## Establecer uno como predeterminado

Instalar un navegador no lo convierte en el predeterminado. Para cambiarlo, ve a _Configuración > Predeterminados > Navegador_ y elige uno. El predeterminado actual está marcado con una palomita, y si eliges un navegador que aún no tienes, primero se instala.

Desde la terminal es:

```bash
omarchy default browser firefox
```

Ejecútalo sin argumentos y te dirá cuál es el predeterminado actual. Esto establece el controlador XDG, así que no solo los atajos de Omarchy se adaptan: cualquier cosa que abra un enlace, desde una app de chat hasta un comando de terminal, irá al navegador que elegiste.

## Copiar URL y Descargar video

Los navegadores de la familia Chromium (el propio Chromium, Chrome, Edge, Brave y Brave Origin) incluyen tres extensiones de Omarchy: dos que salen del navegador y llegan al resto de tu sistema, y una que pone orden en WhatsApp.

**Copiar URL** pone la dirección de la pestaña actual en tu portapapeles con `Alt + Shift + L`. Es más rápido que hacer clic en la barra de direcciones y copiar, y como pasa por el portapapeles del sistema en lugar del del navegador, recibes una notificación de Omarchy que lo confirma y la URL queda disponible de inmediato en el [historial del portapapeles](08-unified-clipboard-history.md) y en todas las demás apps. También hay un botón en la barra de herramientas, si prefieres hacer clic.

**Descargar video** toma el video que se está reproduciendo en la página que estás viendo con `Alt + Shift + D`. Le pasa la URL a [yt-dlp](https://github.com/yt-dlp/yt-dlp), así que funciona en mucho más que YouTube, y la descarga llega a `~/Videos`. El progreso aparece en la misma indicación en pantalla que usan el volumen y el brillo, actualizándose en el mismo sitio en lugar de acumular notificaciones. Define `OMARCHY_YTDLP_DIR` si prefieres que los archivos vayan a otro lugar: consulta las [preguntas frecuentes](46-faq.md) para saber dónde poner las variables de entorno.

Ambas extensiones se comunican con Omarchy a través de un pequeño host de mensajería nativa, que se instala junto con el navegador. Esa es la pieza que permite que el video de una página web termine en tu directorio principal y que una URL termine en tu gestor del portapapeles, algo que una extensión normal no puede hacer por sí sola.

**WhatsApp Slim** hace que WhatsApp Web siga el tema de tu sistema y contrae su lista de chats cuando la ventana es estrecha.

Son exclusivas de la familia Chromium. Firefox y Zen no las reciben.

## Firefox y Zen

Firefox y Zen son de otra familia, así que reciben un trato distinto: Omarchy instala un archivo de políticas con valores predeterminados sensatos y los cambia al modo nativo de Wayland, que es lo que quieres para el escalado fraccionario y un desplazamiento suave con el trackpad.

No reciben las extensiones de Chromium de arriba y Omarchy no les aplica temas, así que esas partes de la experiencia te toca configurarlas a ti.

## Quitar uno de nuevo

Cualquiera de estos navegadores, incluido Chrome, se puede volver a quitar desde _Quitar > Navegador_. Entonces, los enlaces irán a Chrome o Chromium si el otro sigue instalado.
