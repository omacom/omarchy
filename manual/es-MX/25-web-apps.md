# Aplicaciones web

Puedes agregar tus propias aplicaciones web usando _Instalar > Aplicación web_ en el menú de Omarchy (`Super + Space`). Te pedirá el nombre de la aplicación, la URL de la aplicación y la URL del ícono, si no puede obtenerla mediante el favicon. Puedes conseguir excelentes íconos PNG para muchas aplicaciones web populares en [Dashboard Icons](https://dashboardicons.com).

Después serán accesibles desde el lanzador de aplicaciones (`Super + Space`), y usarán la hermosa ventana de aplicación web sin marco.

Si quieres quitar una aplicación web, solo ve a _Quitar > Aplicación web_ en el menú de Omarchy.

Es mejor que inicies sesión en todas tus cuentas usando un navegador normal antes de usar los atajos de aplicaciones web. El delgado marco contenedor no funciona bien con 1password, así que es más fácil haber iniciado sesión directamente primero.

Todos los atajos de teclado para estas aplicaciones web se pueden cambiar en `~/.config/hypr/bindings.lua`.

Cuando estés en una aplicación web, puedes copiar la URL actual al portapapeles usando `Shift + Alt + L`.

De forma predeterminada, Omarchy ya viene con un surtido de aplicaciones predeterminadas:

## HEY

[HEY](https://www.hey.com/) es un servicio de correo electrónico y calendario que sirve como una gran alternativa para la gente cansada de Gmail, Outlook o Apple Mail. Lo hace [37signals](https://37signals.com/), donde se originó Omarchy.

Puedes iniciar HEY Email usando `Super + Shift + E`, saltar directo a redactar un correo nuevo usando `Super + Shift + Alt + E`, e iniciar HEY Calendar usando `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) es un servicio de gestión de proyectos que ayuda a los equipos pequeños a moverse más rápido y avanzar más. En lugar de unir una mezcolanza de Trello, Slack, Asana, Notion o lo que sea, puedes tenerlo todo en un solo lugar con Basecamp. Lo hace [37signals](https://37signals.com/), donde se originó Omarchy.

Puedes iniciar Basecamp usando el lanzador de aplicaciones (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) es el chatbot de IA más popular del mundo.

Puedes iniciar ChatGPT usando `Super + Shift + A`.

## Grok

[Grok](https://grok.com) es el chatbot de xAI.

Puedes iniciar Grok usando `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) es uno de los servicios de mensajería más populares del mundo, y la versión web es una gran opción para Linux.

Puedes iniciar WhatsApp usando `Super + Shift + Alt + G`.

## Aplicaciones de Google

Google Messages, Google Photos, Google Maps y Google Contacts también están incluidos como aplicaciones web.

Puedes iniciar Google Messages usando `Super + Shift + Ctrl + G`, Google Photos usando `Super + Shift + P`, y Google Maps usando `Super + Shift + S`. Google Contacts está disponible desde el lanzador de aplicaciones (`Super + Space`).

## X

X es donde estallan las noticias.

Puedes iniciar X usando `Super + Shift + X` e ir directo a escribir una publicación nueva con `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) es la plataforma de video más popular del mundo.

Puedes iniciar YouTube usando `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) es el sistema de videochat más popular usado en EE. UU. Grandes conexiones en todo el mundo. Y se pueden hacer reuniones de 40 minutos sin una cuenta de pago. Omarchy envuelve el cliente web de Zoom, y los enlaces de reuniones de Zoom se abrirán directo en él.

Inicias Zoom usando el lanzador de aplicaciones (`Super + Space`).

## Discord

[Discord](https://discord.com/) es donde se reúne la mayoría de las comunidades de videojuegos y código abierto, incluida [la propia de Omarchy](https://discord.gg/tXFUdasqhY).

Inicias Discord usando el lanzador de aplicaciones (`Super + Space`).

## Aplicaciones de Microsoft

Selecciona _Instalar > Servicio > Microsoft_ para agregar Outlook, Word, Excel, PowerPoint, Teams y OneDrive como aplicaciones web. Cada aplicación tiene su propio lanzador y se abre directamente, usando las URL comerciales de Microsoft 365 y tu perfil de navegador existente. Se abren en las mismas ventanas de aplicación de navegador que las demás aplicaciones web de Omarchy; no instalan el cliente separado de Teams para Linux.

Quita el paquete con _Quitar > Servicio > Microsoft_, o quita aplicaciones individuales con _Quitar > Aplicación web_. También puedes instalar solo las aplicaciones que quieras mediante _Instalar > Aplicación web_.

Para una nube gubernamental o soberana, edita la URL en la línea `Exec=` del lanzador correspondiente en `~/.local/share/applications/`, como `Microsoft Teams.desktop`, usando la URL que te dé tu organización. Escribe cualquier `%` literal en esa línea como `%%`. Los cambios se aplican en el próximo lanzamiento. Ejecutar de nuevo el instalador del paquete reemplaza sus lanzadores con las URL predeterminadas.

Para mantener separados los inicios de sesión del trabajo, agrega un directorio de datos del navegador a la línea `Exec=` de cada lanzador:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Reemplaza el directorio de ejemplo con una ruta absoluta de tu elección y usa la misma ruta para los seis lanzadores para compartir los inicios de sesión del trabajo entre ellos. Las aplicaciones web usan el navegador compatible seleccionado de Omarchy, recurriendo a Chromium cuando el navegador predeterminado no es compatible.
