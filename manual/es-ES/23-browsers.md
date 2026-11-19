# Navegadores

Omarchy viene con [Google Chrome](https://www.google.com/chrome/) como navegador predeterminado. Está tematizado a juego con el resto de tu sistema, y es lo que abre `Super + Shift + Return` y donde se ejecuta cada [aplicación web](25-web-apps.md). Se abre directamente en una ventana del navegador: no hay pantalla de bienvenida ni inicio de sesión que hacer, las estadísticas de uso y los informes de fallos no se envían a Google, y los avisos de privacidad de los anuncios están desactivados. Puedes iniciar sesión en tu cuenta de Google desde el botón de perfil cuando quieras tener la sincronización.

Si Chrome no te convence, no estás atado a él. En _Instalar > Navegador_ en el menú de Omarchy encontrarás [Chromium](https://www.chromium.org/) (la versión simple de código abierto a partir de la que se hace Chrome), Edge, Brave, Brave Origin, Firefox y [Zen](https://zen-browser.app/). Elige uno y Omarchy lo instala, configura su directorio de políticas y le aplica tu tema actual.

## Hacer que uno sea el predeterminado

Instalar un navegador no lo convierte en el predeterminado. Con el navegador ya instalado, ve a _Configurar > Predeterminados > Navegador_ y elígelo: el menú solo lista los navegadores que realmente tienes instalados, y marca el predeterminado actual con una marca de verificación.

Desde la terminal es:

```bash
omarchy default browser firefox
```

Ejecútalo sin argumento y te dice el predeterminado actual. Esto establece el gestor de XDG, así que no son solo los atajos de Omarchy los que siguen el cambio: cualquier cosa que abra un enlace, desde una aplicación de chat hasta un comando de terminal, va al navegador que elegiste.

## Copiar URL y Descargar vídeo

Los navegadores de la familia Chromium (el propio Chromium, Chrome, Edge y Brave) vienen con dos extensiones de Omarchy que salen del navegador y llegan al resto de tu sistema.

**Copy URL** pone la dirección de la pestaña actual en tu portapapeles con `Alt + Shift + L`. Eso es más rápido que hacer clic en la barra de direcciones y copiar, y como pasa por el portapapeles del sistema y no por el del navegador, recibes una notificación de Omarchy que lo confirma y la URL queda disponible de inmediato en el [historial del portapapeles](08-unified-clipboard-history.md) y en todas las demás aplicaciones. También hay un botón en la barra de herramientas, por si prefieres hacer clic.

**Download Video** obtiene el vídeo que se está reproduciendo en la página que estás viendo con `Alt + Shift + D`. Le pasa la URL a [yt-dlp](https://github.com/yt-dlp/yt-dlp), así que funciona en mucho más que YouTube, y la descarga llega a `~/Videos`. El progreso aparece en el mismo indicador en pantalla que usan el volumen y el brillo, y se actualiza sobre la marcha en vez de acumular notificaciones. Establece `OMARCHY_YTDLP_DIR` si prefieres que los archivos vayan a otro lugar; consulta las [FAQ](46-faq.md) para saber dónde poner las variables de entorno.

Ambas extensiones hablan con Omarchy mediante un pequeño host de mensajería nativa, que se instala junto con el navegador. Esa es la pieza que permite que el vídeo de una página web termine en tu directorio personal y que una URL termine en tu gestor del portapapeles, algo que una extensión normal no puede hacer por sí sola.

Estas son solo para la familia Chromium. Firefox y Zen no las reciben.

## Firefox y Zen

Firefox y Zen son una familia distinta, así que reciben un trato distinto: Omarchy instala un archivo de políticas para valores predeterminados sensatos y los cambia a modo Wayland nativo, que es lo que quieres para el escalado fraccional y un desplazamiento suave con el panel táctil.

No reciben las extensiones de Chromium de arriba, y Omarchy no les aplica tema, así que esas partes de la experiencia te toca configurarlas a ti.

## Quitar uno de nuevo

Todo lo que hayas instalado aquí, Chrome incluido, se puede quitar en _Quitar > Navegador_; los enlaces pasan entonces a Chrome o Chromium, si el otro sigue instalado.
