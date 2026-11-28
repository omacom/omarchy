# Navegadores

Omarchy viene con [Google Chrome](https://www.google.com/chrome/) como navegador predeterminado. Tiene un tema que combina con el resto de tu sistema, y es lo que abre `Super + Shift + Return` (o `Super + Shift + B`), con `Super + Shift + Alt + B` para una ventana privada, y dentro de lo que se ejecuta cada [aplicación web](25-web-apps.md). Se abre directo en una ventana del navegador: no hay pantalla de bienvenida ni aviso para iniciar sesión, no se envían a Google las estadísticas de uso ni los informes de fallos, y los avisos de privacidad publicitaria están desactivados. Aun así, puedes iniciar sesión en tu cuenta de Google desde el botón de perfil cuando quieras sincronizar.

Si Chrome no es de tu agrado, no estás obligado a quedarte con él. En _Instalar > Navegador_ en el menú de Omarchy encontrarás [Chromium](https://www.chromium.org/) (la versión sencilla de código abierto a partir de la cual está hecho Chrome), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) y [Ladybird](https://ladybird.org/) (Edge solo en equipos x86). Elige uno y Omarchy lo instala, configura su directorio de políticas y le aplica tu tema actual.

## Establecer uno como predeterminado

Instalar un navegador no lo convierte en el predeterminado. Para cambiarlo, ve a _Configuración > Predeterminados > Navegador_ y elige uno. El predeterminado actual está marcado con una palomita, y elegir un navegador que aún no tienes lo instala primero.

Desde la terminal es:

```bash
omarchy default browser firefox
```

Ejecútalo sin argumentos y te dirá cuál es el predeterminado actual. Esto establece el controlador XDG, así que no solo los atajos de teclado de Omarchy se ajustan: todo lo que abra un enlace, desde una app de chat hasta un comando de terminal, irá al navegador que elegiste.

## Copy URL y Download Video

Los navegadores de la familia Chromium (el propio Chromium, Chrome, Edge, Brave y Brave Origin) vienen con tres extensiones de Omarchy: dos que salen del navegador y llegan al resto de tu sistema, y una que pone orden en WhatsApp.

**Copy URL** pone la dirección de la pestaña actual en tu portapapeles con `Alt + Shift + L`. Es más rápido que hacer clic en la barra de direcciones y copiar, y como pasa por el portapapeles del sistema en lugar del del navegador, recibes una notificación de Omarchy que lo confirma y la URL queda disponible de inmediato en el [historial del portapapeles](08-unified-clipboard-history.md) y en todas las demás apps. También hay un botón en la barra de herramientas, por si prefieres hacer clic.

**Download Video** toma el video que se está reproduciendo en la página que estás viendo con `Alt + Shift + D`. Le pasa la URL a [yt-dlp](https://github.com/yt-dlp/yt-dlp), así que funciona en mucho más que YouTube, y la descarga llega a `~/Videos`. El progreso aparece en la misma visualización en pantalla que usan el volumen y el brillo, actualizándose en el mismo lugar en lugar de acumular notificaciones. Define `OMARCHY_YTDLP_DIR` si prefieres que los archivos vayan a otro lugar: consulta las [FAQ](46-faq.md) para saber dónde poner las variables de entorno.

Ambas extensiones se comunican con Omarchy a través de un pequeño host de mensajería nativa, que se instala junto con el navegador. Esa es la pieza que permite que el video de una página web termine en tu directorio principal y que una URL termine en tu gestor del portapapeles, algo que una extensión normal no puede hacer por sí sola.

**WhatsApp Slim** hace que WhatsApp Web siga el tema de tu sistema y contrae su lista de chats cuando la ventana es angosta.

Estas son exclusivas de la familia Chromium. Firefox y Zen no las reciben.

## Firefox y Zen

Firefox y Zen son de otra familia, así que reciben un trato distinto: Omarchy instala un archivo de políticas con valores predeterminados sensatos y los cambia al modo nativo de Wayland, que es lo que quieres para el escalado fraccionario y un desplazamiento suave con el trackpad.

No reciben las extensiones de Chromium mencionadas arriba y Omarchy no les aplica temas, así que esas partes de la experiencia te toca configurarlas a ti.

## Ladybird

Ladybird es un navegador escrito desde cero, con su propio motor en lugar del de Chromium o el de Firefox. Todavía está en alfa, así que espera sitios que aún no funcionan, y Omarchy lo instala tal como viene: sin extensiones, sin tema, sin políticas. Tampoco tiene ventana privada, así que `Super + Shift + Alt + B` lo abre con un perfil temporal que se elimina cuando lo cierras. Las [aplicaciones web](25-web-apps.md) siguen ejecutándose en Chrome o Chromium.

## Quitar uno de nuevo

Cualquiera de estos navegadores, incluido Chrome, se puede volver a quitar en _Quitar > Navegador_. Entonces los enlaces irán a Chrome o Chromium si el otro sigue instalado.
