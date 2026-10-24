# GUI

## Archivos

Files (Nautilus) es el gestor de archivos gráfico. `Super + Shift + F` lo abre, y `Super + Shift + Alt + F` lo abre en el directorio donde está tu terminal, lo cual ahorra mucho clic. `Ctrl + L` te permite escribir una ruta, y presionar `Space` sobre cualquier archivo te da una vista previa rápida sin abrir nada.

Conecta una memoria USB o una tarjeta SD y se monta automáticamente, así que simplemente aparece en la barra lateral. Para cualquier cosa más complicada —formatear una unidad, revisar la salud SMART, crear particiones— lanza _Discos_ desde el lanzador de aplicaciones (`Super + Space`).

El doble clic sigue valores predeterminados sensatos: las imágenes se abren en imv, el video en mpv, los PDF en Document Viewer y el texto plano en Neovim.

## Disktree

Cuando la unidad se llena y no tienes idea de qué la está devorando, lanza [Disktree](https://github.com/tobi/disktree) desde el lanzador de aplicaciones (`Super + Space`). Muestra un mapa de árbol gráfico de tu directorio personal. Los bloques más grandes ocupan más espacio; entra a los directorios con el teclado o el mouse, marca lo que debe irse y revisa tus selecciones antes de quitar nada. Ejecuta `disktree --disk` para escanear todo el disco.

## Obsidian

[Obsidian](https://obsidian.md/) es una aplicación gratuita y muy extensible para tomar notas que usa archivos Markdown simples para el almacenamiento.

Obsidian es gratuito para todos los fines, incluido el uso personal, comercial y sin fines de lucro.

Obsidian también ofrece un [complemento comercial para sincronizar](https://obsidian.md/sync) con aplicaciones móviles en iOS y Android. (https://obsidian.md/pricing).

Inicias Obsidian con `Super + Shift + O`. Para usar la sincronización de temas, debes seleccionar el tema `Omarchy` en los ajustes.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) es la aplicación de escritura Markdown súper simple de Omarchy. Sin bóvedas, sin plugins, solo tú y las palabras.

Inicias Omawrite con `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) es una herramienta básica de edición de imágenes que es genial para recortar, redimensionar y otras manipulaciones básicas. Solo no esperes una alternativa a Photoshop. ¡Pero aun así tiene Varita Mágica y capas!

Inicias Pinta desde el lanzador de aplicaciones (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) es una aplicación de temas que puede extraer colores de una imagen de fondo y convertirlos en un tema completo y cohesivo. Es la forma más fácil de [hacer tu propio tema](43-making-your-own-theme.md).

Inicias Aether desde el lanzador de aplicaciones (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) te permite enviar archivos a otros dispositivos en la misma red que ejecuten la aplicación, como AirDrop de Apple. Sin embargo, es multiplataforma, así que puedes enviar archivos hacia y desde Windows, macOS, Android, iOS y, por supuesto, Linux.

Puedes abrir el menú Compartir con `Super + Ctrl + S` o en _Activar > Compartir_ en el menú de Omarchy. Te da cuatro opciones:

- **Clipboard** envía lo que hayas copiado como un archivo de texto. Genial para pasar un enlace o un fragmento a tu teléfono sin enviarte un correo a ti mismo.
- **File** abre un selector de archivos donde puedes elegir varios a la vez.
- **Folder** envía un directorio entero.
- **Receive** abre LocalSend propiamente para que otro dispositivo pueda enviarte algo.

Lo mismo funciona desde la terminal con `omarchy share clipboard`, `omarchy share file [path]` y `omarchy share folder [path]`. Omite la ruta y obtendrás el selector.

También puedes enviar directamente desde el gestor de archivos: haz clic derecho en cualquier selección en Nautilus y elige _Send via LocalSend_.

El firewall de Omarchy está cerrado de forma predeterminada excepto por el puerto de LocalSend, así que esto funciona desde el principio en una instalación nueva. Consulta [seguridad](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) es un paquete de oficina completo con procesador de textos, hoja de cálculo, presentaciones, aplicación de dibujo y más. Es compatible con archivos de Microsoft Office, así que es una gran forma de poder abrir esos documentos de Word.

Inicias LibreOffice desde el lanzador de aplicaciones (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) es la aplicación de presentaciones súper simple de Omarchy. Tu presentación es un solo archivo Markdown con sus imágenes y videos al lado: escribe cada diapositiva debajo de una vista previa en vivo, arrastra las diapositivas para ordenarlas, y luego presenta en pantalla completa o exporta a PDF y PowerPoint. Incluso adopta tu tema de Omarchy.

Inicias Hype desde el lanzador de aplicaciones (`Super + Space`). Presiona `?` dentro de él para ver todos los atajos.

## Signed

[Signed](https://github.com/omacom/signed) es la forma súper simple de Omarchy para firmar PDF y llenarlos. Pon tu firma guardada, texto y la fecha de hoy en cualquier lugar de una página, y luego guarda una copia firmada junto al original. Consulta [Llenar PDF](27-filling-out-pdfs.md) para saber cómo.

Inicias Signed desde el lanzador de aplicaciones (`Super + Space`), o abres un PDF con él desde el gestor de archivos.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) es la calculadora súper simple de Omarchy, que se abre en una ventana flotante.

Inicias Omacalc con `Super + Ctrl + Q` (o la tecla de calculadora, si tu teclado tiene una).

## Signal

[Signal](https://signal.org/) es el pionero de la mensajería cifrada de extremo a extremo, y una gran opción de comunicación para cualquiera que prefiera no pasar por uno de los grandes conglomerados tecnológicos.

Inicias Signal con `Super + Shift + G`. No forma parte de la instalación base, así que la primera vez que presiones eso, Omarchy te ofrecerá instalarlo (también está en _Instalar > Servicio_ en el menú de Omarchy).

## mpv

[mpv](https://mpv.io/) es un reproductor multimedia simple y rápido que reproducirá casi cualquier cosa desde cualquier fuente. Genial para ver videos.

Inicias mpv desde el lanzador de aplicaciones (`Super + Space`) o simplemente haciendo doble clic en un video en el gestor de archivos.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) es el recortador de video súper simple de Omarchy. Cuando todo lo que necesitas es cortar el inicio y el final de un clip, supera con creces abrir un editor de video completo.

Inicias Omacut desde el lanzador de aplicaciones (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) es la grabadora de webcam súper simple de Omarchy. Elige tu cámara y micrófono una vez, luego presiona `Space` para grabar, y de nuevo para pausar y reanudar la misma toma. Siempre graba a la resolución más alta de tu cámara, con un medidor de micrófono en vivo para que puedas revisar tus niveles antes de empezar.

Detén la toma y se abre de inmediato en un editor integrado. Haz doble clic en un clip para dividirlo, arrastra los controles para recortar cada pedazo y quita las partes que no quieras. Luego guárdalo como MP4. Tu grabación original se conserva hasta que la descartes, así que siempre puedes volver y cortarla de otra forma.

Inicias Monologue desde el lanzador de aplicaciones (`Super + Space`).
