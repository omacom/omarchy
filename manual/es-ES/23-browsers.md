# Navegadores

Omarchy viene con [Google Chrome](https://www.google.com/chrome/) como navegador predeterminado. Tiene un tema a juego con el resto de tu sistema, y es lo que se abre con `Super + Shift + Return` (o `Super + Shift + B`), con `Super + Shift + Alt + B` para una ventana privada, y dentro de él se ejecuta cada [aplicación web](25-web-apps.md). Se abre directamente en una ventana del navegador: no hay pantalla de bienvenida ni aviso para iniciar sesión, las estadísticas de uso y los informes de fallos no se envían a Google, y los avisos de privacidad publicitaria están desactivados. Aun así, puedes iniciar sesión en tu cuenta de Google desde el botón de perfil cuando quieras sincronizar.

Si Chrome no es lo tuyo, no estás condenado a usarlo. En _Instalar > Navegador_ del menú de Omarchy encontrarás [Chromium](https://www.chromium.org/) (la compilación sencilla de código abierto a partir de la cual se crea Chrome), Edge, Brave, Brave Origin, Firefox y [Zen](https://zen-browser.app/) (Edge solo en equipos x86). Elige uno y Omarchy lo instala, configura su directorio de políticas y le aplica tu tema actual.

## Hacer que uno sea el predeterminado

Instalar un navegador no lo convierte en el predeterminado. Para cambiarlo, ve a _Configurar > Predeterminados > Navegador_ y elige uno. El predeterminado actual aparece marcado, y si eliges un navegador que aún no tienes, primero se instala.

Desde la terminal es:

```bash
omarchy default browser firefox
```

Ejecútalo sin argumento y te dice el predeterminado actual. Esto establece el gestor de XDG, así que no son solo los atajos de Omarchy los que siguen el cambio: cualquier cosa que abra un enlace, desde una aplicación de chat hasta un comando de terminal, va al navegador que elegiste.

## Copiar URL y Descargar vídeo

Los navegadores de la familia Chromium (el propio Chromium, Chrome, Edge, Brave y Brave Origin) incluyen tres extensiones de Omarchy: dos que salen del navegador y llegan al resto de tu sistema, y una que pone orden en WhatsApp.

**Copy URL** pone la dirección de la pestaña actual en tu portapapeles con `Alt + Shift + L`. Eso es más rápido que hacer clic en la barra de direcciones y copiar, y como pasa por el portapapeles del sistema y no por el del navegador, recibes una notificación de Omarchy que lo confirma y la URL queda disponible de inmediato en el [historial del portapapeles](08-unified-clipboard-history.md) y en todas las demás aplicaciones. También hay un botón en la barra de herramientas, por si prefieres hacer clic.

**Download Video** obtiene el vídeo que se está reproduciendo en la página que estás viendo con `Alt + Shift + D`. Le pasa la URL a [yt-dlp](https://github.com/yt-dlp/yt-dlp), así que funciona en mucho más que YouTube, y la descarga llega a `~/Videos`. El progreso aparece en el mismo indicador en pantalla que usan el volumen y el brillo, y se actualiza sobre la marcha en vez de acumular notificaciones. Establece `OMARCHY_YTDLP_DIR` si prefieres que los archivos vayan a otro lugar; consulta las [FAQ](46-faq.md) para saber dónde poner las variables de entorno.

Ambas extensiones hablan con Omarchy mediante un pequeño host de mensajería nativa, que se instala junto con el navegador. Esa es la pieza que permite que el vídeo de una página web termine en tu directorio personal y que una URL termine en tu gestor del portapapeles, algo que una extensión normal no puede hacer por sí sola.

**WhatsApp Slim** hace que WhatsApp Web siga el tema de tu sistema y contrae su lista de chats cuando la ventana es estrecha.

Estas son solo para la familia Chromium. Firefox y Zen no las reciben.

## Firefox y Zen

Firefox y Zen son una familia distinta, así que reciben un trato distinto: Omarchy instala un archivo de políticas para valores predeterminados sensatos y los cambia a modo Wayland nativo, que es lo que quieres para el escalado fraccional y un desplazamiento suave con el panel táctil.

No reciben las extensiones de Chromium de arriba, y Omarchy no les aplica tema, así que esas partes de la experiencia te toca configurarlas a ti.

## Quitar uno de nuevo

Todo lo que hayas instalado aquí, Chrome incluido, se puede quitar en _Quitar > Navegador_; los enlaces pasan entonces a Chrome o Chromium, si el otro sigue instalado.
