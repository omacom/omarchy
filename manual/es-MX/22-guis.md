# Interfaces gráficas

## Archivos

Archivos (Nautilus) es el administrador de archivos gráfico. `Super + Shift + F` lo abre, y `Super + Shift + Alt + F` lo abre en el directorio en el que está tu terminal, lo que te ahorra un montón de clics. `Ctrl + L` te permite escribir una ruta, y presionar `Space` sobre cualquier archivo te ofrece una vista previa rápida sin abrir nada.

Conecta una memoria USB o una tarjeta SD y se monta automáticamente, así que simplemente aparece en la barra lateral. Para cualquier cosa más elaborada —formatear una unidad, revisar el estado SMART, crear particiones— abre _Disks_ desde el lanzador de aplicaciones (`Super + Space`).

Al hacer doble clic se siguen valores predeterminados sensatos: las imágenes se abren en imv, el video en mpv, los PDF en Document Viewer y el texto plano en Neovim.

## Disktree

Cuando la unidad se llena y no tienes idea de qué la está devorando, abre [Disktree](https://github.com/tobi/disktree) desde el lanzador de aplicaciones (`Super + Space`). Muestra un mapa de árbol gráfico de tu directorio personal. Los bloques más grandes ocupan más espacio; entra a los directorios con el teclado o el mouse, marca lo que debe desaparecer y revisa tus selecciones antes de eliminar cualquier cosa. Ejecuta `disktree --disk` para escanear todo el disco.

## Obsidian

[Obsidian](https://obsidian.md/) es una aplicación para tomar notas gratuita y sumamente extensible que usa archivos Markdown sencillos para el almacenamiento.

Obsidian es gratuito para todos los fines, incluido el uso personal, comercial y sin fines de lucro.

Obsidian también ofrece un [complemento comercial para sincronizar](https://obsidian.md/sync) con aplicaciones móviles en iOS y Android. (https://obsidian.md/pricing).

Inicias Obsidian con `Super + Shift + O`. Para usar la sincronización de temas, debes seleccionar el tema `Omarchy` en los ajustes.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) es la aplicación de escritura en Markdown sumamente sencilla de Omarchy. Sin bóvedas, sin complementos, solo tú y las palabras.

Inicias Omawrite con `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) es una herramienta básica de edición de imágenes que es excelente para recortar, redimensionar y otras manipulaciones básicas. Eso sí, no esperes una alternativa a Photoshop. ¡Pero aun así tiene Varita mágica y capas!

Inicias Pinta desde el lanzador de aplicaciones (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) es una aplicación de temas que puede extraer colores de una imagen de fondo y convertirlos en un tema completo y cohesivo. Es la manera más fácil de [crear tu propio tema](43-making-your-own-theme.md).

Inicias Aether desde el lanzador de aplicaciones (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) te permite enviar archivos a otros dispositivos en la misma red que ejecuten la aplicación, como AirDrop de Apple. Sin embargo, es multiplataforma, así que puedes enviar archivos hacia y desde Windows, macOS, Android, iOS y, por supuesto, Linux.

Puedes abrir el menú Compartir con `Super + Ctrl + S` o en _Trigger > Share_ en el menú de Omarchy. Te ofrece cuatro opciones:

- **Clipboard** envía lo que hayas copiado como un archivo de texto. Excelente para llevar un enlace o un fragmento a tu teléfono sin enviártelo por correo.
- **File** abre un selector de archivos donde puedes elegir varios a la vez.
- **Folder** envía un directorio completo.
- **Receive** abre LocalSend propiamente para que otro dispositivo pueda enviarte algo.

Lo mismo funciona desde la terminal con `omarchy share clipboard`, `omarchy share file [path]` y `omarchy share folder [path]`. Omite la ruta y obtendrás el selector.

También puedes enviar directamente desde el administrador de archivos: haz clic derecho en cualquier selección en Nautilus y elige _Send via LocalSend_.

El firewall de Omarchy está cerrado de forma predeterminada, excepto por el puerto de LocalSend, así que esto funciona desde el primer momento en una instalación nueva. Consulta [seguridad](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) es un paquete ofimático completo con procesador de textos, hoja de cálculo, presentaciones, aplicación de dibujo y más. Es compatible con archivos de Microsoft Office, así que es una excelente manera de poder abrir esos documentos de Word.

Inicias LibreOffice desde el lanzador de aplicaciones (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) es la aplicación de presentaciones sumamente sencilla de Omarchy. Tu presentación es un único archivo Markdown con sus imágenes y videos junto a él: escribe cada diapositiva debajo de una vista previa en vivo, arrastra las diapositivas para ordenarlas y luego presenta en pantalla completa o exporta a PDF y PowerPoint. Incluso adopta tu tema de Omarchy.

Inicias Hype desde el lanzador de aplicaciones (`Super + Space`). Presiona `?` dentro de la aplicación para ver todos los atajos.

## Signed

[Signed](https://github.com/omacom/signed) es la manera sumamente sencilla de Omarchy para firmar PDF y rellenarlos. Coloca tu firma guardada, texto y la fecha de hoy en cualquier lugar de una página, y luego guarda una copia firmada junto al original. Consulta [Rellenar PDF](27-filling-out-pdfs.md) para saber cómo hacerlo.

Inicias Signed desde el lanzador de aplicaciones (`Super + Space`), o abre un PDF con él desde el administrador de archivos.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) es la calculadora sumamente sencilla de Omarchy, que se abre en una ventana flotante.

Inicias Omacalc con `Super + Shift + Q` (o la tecla de calculadora, si tu teclado tiene una).

## Signal

[Signal](https://signal.org/) es el pionero de la mensajería con cifrado E2E, y una excelente opción de comunicación para cualquiera que prefiera no pasar por uno de los grandes conglomerados tecnológicos.

Inicias Signal con `Super + Shift + G`. No forma parte de la instalación base, así que la primera vez que presiones esa combinación, Omarchy te ofrecerá instalarlo (también está en _Install > Service_ en el menú de Omarchy).

## mpv

[mpv](https://mpv.io/) es un reproductor multimedia sencillo y rápido que reproducirá casi cualquier cosa desde cualquier fuente. Excelente para ver videos.

Inicias mpv desde el lanzador de aplicaciones (`Super + Space`) o simplemente haciendo doble clic en un video en el administrador de archivos.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) es el recortador de video sumamente sencillo de Omarchy. Cuando todo lo que necesitas es cortar el principio y el final de un clip, supera con creces abrir un editor de video completo.

Inicias Omacut desde el lanzador de aplicaciones (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) es el grabador de cámara web sumamente sencillo de Omarchy. Elige tu cámara y micrófono una vez, luego presiona `Space` para grabar, y de nuevo para pausar y reanudar la misma toma. Siempre graba a la resolución más alta de tu cámara, con un medidor de micrófono en vivo para que puedas revisar tus niveles antes de empezar.

Detén la toma y se abre de inmediato en un editor integrado. Haz doble clic en un clip para dividirlo, arrastra los controles para recortar cada fragmento y elimina las partes que no quieras. Luego guárdalo como un MP4. Tu grabación original se conserva hasta que la descartes, así que siempre puedes volver y cortarla de otra manera.

Inicias Monologue desde el lanzador de aplicaciones (`Super + Space`).
