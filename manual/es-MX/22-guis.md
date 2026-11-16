# Interfaces gráficas

## Files

Files (Nautilus) es el administrador de archivos gráfico. `Super + Shift + F` lo abre, y `Super + Shift + Alt + F` lo abre en el directorio en el que está tu terminal, lo que ahorra muchos clics. `Ctrl + L` te permite escribir una ruta, y presionar `Space` en cualquier archivo te da una vista previa rápida sin abrir nada.

Conecta una memoria USB o una tarjeta SD y se monta automáticamente, así que simplemente aparece en la barra lateral. Para cualquier cosa más elaborada — formatear una unidad, revisar el estado SMART, crear particiones — abre _Disks_ desde el lanzador de aplicaciones (`Super + Space`).

Hacer doble clic sigue valores predeterminados sensatos: las imágenes, los videos y la música se abren en Omaview, los PDF en Document Viewer, Markdown en Omawrite y el texto plano en el editor elegido en _Setup > Default > Editor_.

## Disktree

Cuando la unidad se llena y no tienes idea de qué la está consumiendo, abre [Disktree](https://github.com/tobi/disktree) desde el lanzador de aplicaciones (`Super + Space`). Muestra un mapa de árbol gráfico de tu directorio de inicio. Los bloques más grandes ocupan más espacio; entra a los directorios con el teclado o el mouse, marca lo que debe desaparecer y revisa tus selecciones antes de eliminar nada. Ejecuta `disktree --disk` para escanear todo el disco.

## Obsidian

[Obsidian](https://obsidian.md/) es una aplicación para tomar notas gratuita y muy extensible que usa archivos Markdown simples para el almacenamiento.

Obsidian es gratuito para todos los fines, incluido el uso personal, comercial y sin fines de lucro.

Obsidian también ofrece un [complemento comercial de sincronización](https://obsidian.md/sync) con aplicaciones móviles en iOS y Android. (https://obsidian.md/pricing).

Inicias Obsidian con `Super + Shift + O`. Para usar la sincronización de temas, debes seleccionar el tema `Omarchy` en los ajustes.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) es la aplicación de escritura en Markdown simplísima y propia de Omarchy. Sin bóvedas, sin complementos, solo tú y las palabras.

Inicias Omawrite con `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) es una herramienta básica de edición de imágenes que es excelente para recortar, cambiar el tamaño y otras manipulaciones básicas. Nada más no esperes una alternativa a Photoshop. ¡Pero aun así tiene Magic Wand y capas!

Inicias Pinta desde el lanzador de aplicaciones (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) es una aplicación de temas que puede extraer colores de una imagen de fondo y convertirlos en un tema completo y cohesivo. Es la forma más fácil de [crear tu propio tema](43-making-your-own-theme.md).

Inicias Aether desde el lanzador de aplicaciones (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) te permite enviar archivos a otros dispositivos en la misma red que ejecuten la aplicación, como AirDrop de Apple. Sin embargo, es multiplataforma, así que puedes enviar archivos hacia y desde Windows, macOS, Android, iOS y, por supuesto, Linux.

Puedes abrir el menú Share con `Super + Ctrl + S` o en _Trigger > Share_ en el menú de Omarchy. Te ofrece cuatro opciones:

- **Clipboard** envía lo que hayas copiado como un archivo de texto. Perfecto para pasar un enlace o un fragmento a tu teléfono sin enviártelo por correo.
- **File** abre un selector de archivos donde puedes seleccionar varios a la vez.
- **Folder** envía un directorio completo.
- **Receive** abre LocalSend propiamente para que otro dispositivo pueda enviarte algo.

Lo mismo funciona desde la terminal con `omarchy share clipboard`, `omarchy share file [path]` y `omarchy share folder [path]`. Omite la ruta y aparecerá el selector.

También puedes enviar directamente desde el administrador de archivos: haz clic derecho en cualquier selección en Nautilus y elige _Send via LocalSend_.

El firewall de Omarchy está cerrado por defecto, excepto por el puerto de LocalSend, así que esto funciona desde el primer momento en una instalación nueva. Consulta [seguridad](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) es un paquete de oficina completo con procesador de textos, hoja de cálculo, presentaciones, aplicación de dibujo y más. Es compatible con archivos de Microsoft Office, así que es una excelente forma de poder abrir esos documentos de Word.

Inicias LibreOffice desde el lanzador de aplicaciones (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) es la aplicación de presentaciones simplísima y propia de Omarchy. Tu presentación es un solo archivo Markdown con sus imágenes y videos junto a él: escribe cada diapositiva debajo de una vista previa en vivo, arrastra las diapositivas para ordenarlas y luego presenta en pantalla completa o exporta a PDF y PowerPoint. Incluso adopta tu tema de Omarchy.

Inicias Hype desde el lanzador de aplicaciones (`Super + Space`). Presiona `?` dentro de la aplicación para ver todos los atajos.

## Signed

[Signed](https://github.com/omacom/signed) es la forma simplísima y propia de Omarchy de firmar PDF y rellenarlos. Coloca tu firma guardada, texto y la fecha de hoy en cualquier lugar de una página y luego guarda una copia firmada junto al original. Consulta [Llenar documentos PDF](27-filling-out-pdfs.md) para saber cómo hacerlo.

Inicias Signed desde el lanzador de aplicaciones (`Super + Space`), o abre un PDF con él desde el administrador de archivos.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) es la calculadora simplísima y propia de Omarchy, que se abre en una ventana flotante.

Inicias Omacalc con `Super + Shift + Q` (o la tecla de calculadora, si tu teclado tiene una).

## Signal

[Signal](https://signal.org/) es el pionero de la mensajería con cifrado E2E, y una excelente opción de comunicación para cualquiera que prefiera no pasar por uno de los grandes conglomerados tecnológicos.

Inicias Signal con `Super + Shift + G`. No forma parte de la instalación base, así que la primera vez que presiones eso, Omarchy te ofrecerá instalártelo (también está en _Install > Service_ en el menú de Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) es el visor de imágenes y reproductor multimedia simplísimo y propio de Omarchy: una ventana para tus fotos, videos y música. Abre una foto y las teclas de flecha avanzan por el resto de su carpeta, `N` y `P` lo hacen para cualquier cosa, y `Ctrl + M` muestra toda la carpeta como una cuadrícula. También muestra fotos HEIC, AVIF y JPEG XL, y retoma donde te quedaste en cualquier contenido largo.

Presiona `F` para pantalla completa, `E` para editar una imagen en Omasnap o recortar un video en Omacut, `Ctrl + P` para imprimir una imagen y `Delete` para mover un archivo a la Papelera (`Ctrl + Z` lo trae de vuelta). Presiona `?` dentro de la aplicación para ver todos los atajos.

Inicias Omaview como _Media Viewer_ desde el lanzador de aplicaciones (`Super + Space`), o simplemente haz doble clic en una imagen, un video o una canción en el administrador de archivos.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) es el recortador de video simplísimo y propio de Omarchy. Cuando solo necesitas recortar el inicio y el final de un clip, supera con creces abrir un editor de video completo.

Inicias Omacut desde el lanzador de aplicaciones (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) es el grabador de webcam simplísimo y propio de Omarchy. Elige tu cámara y tu micrófono una vez y luego presiona `Space` para grabar, y otra vez para pausar y reanudar la misma toma. Siempre graba a la resolución más alta de tu cámara, con un medidor de micrófono en vivo para que puedas revisar tus niveles antes de empezar.

Detén la toma y se abre de inmediato en un editor integrado. Haz doble clic en un clip para dividirlo, arrastra los controles para recortar cada pieza y elimina las partes que no quieras. Luego guárdalo como MP4. Tu grabación original se conserva hasta que la descartes, así que siempre puedes volver y cortarla de otra manera.

Inicias Monologue desde el lanzador de aplicaciones (`Super + Space`).
