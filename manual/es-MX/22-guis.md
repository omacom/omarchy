# Interfaces gráficas

## Files

Files (Nautilus) es el administrador de archivos gráfico. `Super + Shift + F` lo abre, y `Super + Shift + Alt + F` lo abre en el directorio en el que está tu terminal, lo que te ahorra un montón de clics. `Ctrl + L` te permite escribir una ruta, y presionar `Space` sobre cualquier archivo te da una vista previa rápida sin abrir nada.

Conecta una memoria USB o una tarjeta SD y se monta automáticamente, así que simplemente aparece en la barra lateral. Para cualquier cosa más elaborada — formatear una unidad, revisar el estado SMART, crear particiones — abre _Disks_ desde el lanzador de aplicaciones (`Super + Space`).

El doble clic sigue valores predeterminados sensatos: las imágenes, los videos y la música se abren en Omaview, los PDF en Document Viewer, Markdown en Omawrite, y el texto sin formato en el editor elegido en _Setup > Default > Editor_.

## Disktree

Cuando la unidad se llena y no tienes idea de qué se la está comiendo, abre [Disktree](https://github.com/tobi/disktree) desde el lanzador de aplicaciones (`Super + Space`). Muestra un mapa de árbol gráfico de tu directorio personal. Los bloques más grandes ocupan más espacio; recorre los directorios con el teclado o el mouse, marca lo que debe irse y revisa tus selecciones antes de eliminar cualquier cosa. Ejecuta `disktree --disk` para escanear todo el disco.

## Obsidian

[Obsidian](https://obsidian.md/) es una aplicación para tomar notas gratuita y muy extensible que usa archivos Markdown simples para el almacenamiento.

Obsidian es gratuito para todos los fines, incluido el uso personal, comercial y sin fines de lucro.

Obsidian también ofrece un [complemento comercial para sincronizar](https://obsidian.md/sync) con aplicaciones móviles en iOS y Android. (https://obsidian.md/pricing).

Abres Obsidian con `Super + Shift + O`. Para usar la sincronización del tema, debes seleccionar el tema `Omarchy` en los ajustes.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) es la aplicación propia de Omarchy, sencillísima, para escribir en Markdown. Sin bóvedas, sin plugins, solo tú y las palabras.

Abres Omawrite con `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) es una herramienta básica de edición de imágenes, ideal para recortar, redimensionar y hacer otras manipulaciones básicas. Solo no esperes una alternativa a Photoshop. ¡Pero aun así tiene Varita mágica y capas!

Abres Pinta desde el lanzador de aplicaciones (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) es una aplicación de temas que puede extraer colores de una imagen de fondo y convertirlos en un tema completo y cohesivo. Es la forma más fácil de [crear tu propio tema](43-making-your-own-theme.md).

Abres Aether desde el lanzador de aplicaciones (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) te permite enviar archivos a otros dispositivos en la misma red que ejecuten la aplicación, como AirDrop de Apple. Sin embargo, es multiplataforma, así que puedes enviar archivos hacia y desde Windows, macOS, Android, iOS y, por supuesto, Linux.

Puedes abrir el menú Share con `Super + Ctrl + S` o en _Trigger > Share_ en el menú de Omarchy. Te da cuatro opciones:

- **Clipboard** envía lo que hayas copiado como un archivo de texto. Ideal para pasar un enlace o un fragmento a tu teléfono sin enviártelo por correo.
- **File** abre un selector de archivos donde puedes elegir varios a la vez.
- **Folder** envía un directorio completo.
- **Receive** abre LocalSend propiamente para que otro dispositivo pueda enviarte algo.

Lo mismo funciona desde la terminal con `omarchy share clipboard`, `omarchy share file [path]` y `omarchy share folder [path]`. Omite la ruta y obtendrás el selector.

También puedes enviar directamente desde el administrador de archivos: haz clic derecho en cualquier selección en Nautilus y elige _Send via LocalSend_.

El firewall de Omarchy está cerrado de forma predeterminada, excepto por el puerto de LocalSend, así que esto funciona desde el primer momento en una instalación nueva. Consulta [seguridad](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) es un paquete de oficina completo con procesador de textos, hoja de cálculo, presentaciones, aplicación de dibujo y más. Es compatible con archivos de Microsoft Office, así que es una excelente manera de poder abrir esos documentos de Word.

Abres LibreOffice desde el lanzador de aplicaciones (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) es la aplicación de presentaciones propia de Omarchy, sencillísima. Tu presentación es un solo archivo Markdown con sus imágenes y videos junto a él: escribe cada diapositiva debajo de una vista previa en vivo, arrastra las diapositivas para ordenarlas y luego presenta en pantalla completa o exporta a PDF y PowerPoint. Incluso adopta tu tema de Omarchy.

Abres Hype desde el lanzador de aplicaciones (`Super + Space`). Presiona `?` dentro para ver todos los atajos.

## Signed

[Signed](https://github.com/omacom/signed) es la forma propia de Omarchy, sencillísima, de firmar PDF y llenarlos. Coloca tu firma guardada, texto y la fecha de hoy en cualquier lugar de una página, luego guarda una copia firmada junto al original. Consulta [Llenar PDF](27-filling-out-pdfs.md) para saber cómo.

Abres Signed desde el lanzador de aplicaciones (`Super + Space`), o abre un PDF con esta aplicación desde el administrador de archivos.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) es el juego de ajedrez 3D propio de Omarchy. Juega contra un amigo en la misma computadora o contra el oponente integrado en tres niveles, en cuatro sets esculpidos, cada uno con su propia forma de moverse: naves orbitales, madera tallada y marfil, criaturas del bosque y dulces. Las partidas no tienen reloj y se guardan después de cada movimiento.

Abres Checkmate desde el lanzador de aplicaciones (`Super + Space`), donde aparece como Chess. Presiona `?` dentro para ver todos los atajos.

## Cards

[Cards](https://github.com/omacom/cards) es el solitario Klondike propio de Omarchy. Roba de tres en tres, sin límite de pasadas, en cuatro series de cartas: una dibujada con los colores de tu tema y tres con un aspecto propio. Haz clic en una carta y luego en dónde va, arrástrala, o haz doble clic para enviarla al mejor lugar. Las partidas se guardan después de cada movimiento.

Abres Cards desde el lanzador de aplicaciones (`Super + Space`). Haz clic en su nombre, o presiona `?`, para ver todos los atajos.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) es la calculadora propia de Omarchy, sencillísima, que se abre en una ventana flotante.

Abres Omacalc con `Super + Shift + Q` (o la tecla de calculadora, si tu teclado tiene una).

## Signal

[Signal](https://signal.org/) es el pionero de la mensajería con cifrado E2E, y una excelente opción de comunicación para cualquiera que prefiera no pasar por uno de los grandes conglomerados tecnológicos.

Abres Signal con `Super + Shift + G`. No forma parte de la instalación base, así que la primera vez que presiones esa combinación, Omarchy te ofrecerá instalártelo (también está en _Install > Service_ en el menú de Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) es el visor de imágenes y reproductor multimedia propio de Omarchy, sencillísimo: una ventana para tus fotos, videos y música. Abre una foto y las teclas de flecha recorren el resto de su carpeta, `N` y `P` hacen lo mismo para cualquier cosa, y `Ctrl + M` muestra toda la carpeta como una cuadrícula. También muestra fotos HEIC, AVIF y JPEG XL, y retoma los archivos largos justo donde los dejaste.

Presiona `F` para pantalla completa, `E` para editar una imagen en Omasnap o recortar un video en Omacut, `Ctrl + P` para imprimir una imagen, y `Delete` para mover un archivo a la Papelera (`Ctrl + Z` lo trae de vuelta). Presiona `?` dentro para ver todos los atajos.

Abres Omaview como _Media Viewer_ desde el lanzador de aplicaciones (`Super + Space`), o simplemente haz doble clic en una imagen, un video o una canción en el administrador de archivos.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) es el recortador de video propio de Omarchy, sencillísimo. Cuando todo lo que necesitas es cortar el inicio y el final de un clip, supera con creces abrir un editor de video completo.

Abres Omacut desde el lanzador de aplicaciones (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) es la grabadora de cámara web propia de Omarchy, sencillísima. Elige tu cámara y tu micrófono una vez, luego presiona `Space` para grabar, y otra vez para pausar y reanudar la misma toma. Siempre graba a la resolución más alta de tu cámara, con un medidor de micrófono en vivo para que puedas revisar tus niveles antes de empezar.

Detén la toma y se abre de inmediato en un editor integrado. Haz doble clic en un clip para dividirlo, arrastra los controles para recortar cada parte y elimina las partes que no quieras. Luego guárdalo como MP4. Tu grabación original se conserva hasta que la descartes, así que siempre puedes volver y cortarla de otra manera.

Abres Monologue desde el lanzador de aplicaciones (`Super + Space`).
