# Navegadores

Omarchy incluye [Google Chrome](https://www.google.com/chrome/) como navegador predeterminado. Tiene un tema que combina con el resto de tu sistema, es lo que se abre con `Super + Shift + Return` y lo que ejecuta por dentro cada [aplicación web](25-web-apps.md). Se abre directo en una ventana del navegador: no hay pantalla de bienvenida ni aviso para iniciar sesión, no se envían estadísticas de uso ni informes de fallos a Google, y los avisos de privacidad publicitaria están desactivados. Aun así, puedes iniciar sesión en tu cuenta de Google desde el botón de perfil cuando quieras sincronizar.

Si Chrome no es lo tuyo, no estás obligado a quedarte con él. En _Instalar > Navegador_ del menú de Omarchy encontrarás [Chromium](https://www.chromium.org/) (la versión sencilla de código abierto a partir de la cual se crea Chrome), Edge, Brave, Brave Origin, Firefox y [Zen](https://zen-browser.app/). Elige uno y Omarchy lo instala, configura su directorio de políticas y le aplica tu tema actual.

## Cómo establecer uno como predeterminado

Instalar un navegador no lo convierte en predeterminado. Una vez que esté en el equipo, ve a _Configuración > Predeterminados > Navegador_ y elígelo: el menú solo muestra los navegadores que sí tienes instalados y marca el predeterminado actual con una palomita.

Desde la terminal es así:

```bash
omarchy default browser firefox
```

Ejecútalo sin argumentos y te dirá cuál es el predeterminado actual. Esto establece el controlador XDG, así que no solo los atajos de Omarchy lo respetan: cualquier cosa que abra un enlace, desde una app de chat hasta un comando en la terminal, irá al navegador que elegiste.

## Copiar URL y Descargar video

Los navegadores de la familia Chromium (el propio Chromium, Chrome, Edge y Brave) incluyen dos extensiones de Omarchy que salen del navegador y llegan al resto de tu sistema.

**Copiar URL** pone la dirección de la pestaña actual en tu portapapeles con `Alt + Shift + L`. Es más rápido que hacer clic en la barra de direcciones y copiar, y como pasa por el portapapeles del sistema y no por el del navegador, recibes una notificación de Omarchy que lo confirma y la URL queda disponible de inmediato en el [historial del portapapeles unificado](08-unified-clipboard-history.md) y en todas las demás apps. También hay un botón en la barra de herramientas, por si prefieres hacer clic.

**Descargar video** captura el video que se está reproduciendo en la página que estás viendo con `Alt + Shift + D`. Le pasa la URL a [yt-dlp](https://github.com/yt-dlp/yt-dlp), así que funciona en muchos más sitios que solo YouTube, y la descarga llega a `~/Videos`. El progreso aparece en la misma visualización en pantalla que usan el volumen y el brillo, y se actualiza en el mismo lugar en lugar de acumular notificaciones. Define `OMARCHY_YTDLP_DIR` si prefieres que los archivos vayan a otro lugar: consulta las [preguntas frecuentes](46-faq.md) para saber dónde poner las variables de entorno.

Ambas extensiones se comunican con Omarchy a través de un pequeño host de mensajería nativa, que se instala automáticamente junto con el navegador. Esa es la pieza que permite que el video de una página web termine en tu directorio de inicio y que una URL termine en tu gestor del portapapeles, algo que una extensión normal no puede hacer por sí sola.

Estas son exclusivas de la familia Chromium. Firefox y Zen no las reciben.

## Firefox y Zen

Firefox y Zen son de otra familia, así que reciben un trato distinto: Omarchy instala un archivo de políticas con valores predeterminados sensatos y los cambia al modo nativo de Wayland, que es lo que quieres para el escalado fraccionario y un desplazamiento suave con el trackpad.

No reciben las extensiones de Chromium mencionadas arriba y Omarchy no les aplica temas, así que esas partes de la experiencia te toca configurarlas a ti.

## Cómo quitar uno de nuevo

Cualquiera de estos navegadores, incluido Chrome, se puede quitar de nuevo en _Quitar > Navegador_. Entonces los enlaces irán a Chrome o a Chromium si el otro sigue instalado.
