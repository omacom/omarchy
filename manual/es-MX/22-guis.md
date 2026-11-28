# Interfaces gráficas

## Files

Files (Folio) es el administrador de archivos gráfico. `Super + Shift + F` lo abre, y `Super + Shift + Alt + F` lo abre en el directorio en el que está tu terminal, lo que te ahorra muchos clics. `Ctrl + L` te permite escribir una ruta, y presionar `Space` en cualquier archivo lo muestra en vista previa a tamaño completo sin abrirlo.

Conecta una memoria USB o una tarjeta SD y se monta automáticamente, así que simplemente aparece en la barra lateral. Para algo más complejo —formatear una unidad, revisar el estado SMART, crear particiones— abre _Disks_ desde el lanzador de aplicaciones (`Super + Space`).

Una unidad cifrada pide su contraseña cuando se conecta. Para que una se desbloquee por sí sola, agrégale un archivo de clave con `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` y coloca ese archivo de clave en `~/.config/omarchy/drive-keys/<UUID>`, con el nombre del UUID que `lsblk -dno UUID /dev/sdX1` imprime para la partición cifrada, y legible solo por ti (`chmod 600`). Si ese archivo de clave no está o es rechazado, se te pedirá la contraseña como de costumbre.

El doble clic sigue valores predeterminados sensatos: las imágenes, los videos y la música se abren en Omaview, los PDF en Document Viewer, Markdown en Omawrite, y el texto plano en tu editor, Plain a menos que elijas otro en _Setup > Defaults > Editor_.

## Disktree

Cuando la unidad se llena y no tienes idea de qué la está consumiendo, abre [Disktree](https://github.com/tobi/disktree) desde el lanzador de aplicaciones (`Super + Space`). Muestra un mapa de árbol gráfico de tu directorio de inicio. Los bloques más grandes ocupan más espacio; entra a los directorios con el teclado o el mouse, marca lo que debe irse y revisa tus selecciones antes de eliminar cualquier cosa. Ejecuta `disktree --disk` para escanear todo el disco.

## Obsidian

[Obsidian](https://obsidian.md/) es una aplicación para tomar notas, gratuita y altamente extensible, que usa archivos Markdown simples para el almacenamiento.

Obsidian es gratuita para todos los fines, incluido el uso personal, comercial y sin fines de lucro.

Obsidian también ofrece un [complemento comercial de sincronización](https://obsidian.md/sync) con aplicaciones móviles en iOS y Android. (https://obsidian.md/pricing).

Inicias Obsidian con `Super + Shift + O`. Para usar la sincronización de temas, debes seleccionar el tema `Omarchy` en los ajustes.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) es la aplicación de escritura Markdown sencillísima, propia de Omarchy. Sin bóvedas, sin complementos, solo tú y las palabras.

Inicias Omawrite con `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) es una herramienta básica de edición de imágenes que es excelente para recortar, cambiar el tamaño y otras manipulaciones básicas. Solo no esperes una alternativa a Photoshop. ¡Pero aun así tiene Magic Wand y capas!

Inicias Pinta mediante el lanzador de aplicaciones (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) es una aplicación de temas que puede extraer colores de una imagen de fondo y convertirlos en un tema completo y cohesivo. Es la forma más fácil de [crear tu propio tema](43-making-your-own-theme.md).

Inicias Aether mediante el lanzador de aplicaciones (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) te permite enviar archivos a otros dispositivos en la misma red que ejecuten la aplicación, como AirDrop de Apple. Sin embargo, es multiplataforma, así que puedes enviar archivos hacia y desde Windows, macOS, Android, iOS y, por supuesto, Linux.

Puedes abrir el menú Share con `Super + Ctrl + S` o en _Trigger > Share_ en el menú de Omarchy. Te da cuatro opciones:

- **Clipboard** envía lo que hayas copiado como un archivo de texto. Excelente para llevar un enlace o un fragmento a tu teléfono sin enviártelo por correo electrónico.
- **File** abre un selector de archivos donde puedes elegir varios a la vez.
- **Folder** envía un directorio completo.
- **Receive** abre LocalSend propiamente para que otro dispositivo pueda enviarte algo.

Lo mismo funciona desde la terminal con `omarchy share clipboard`, `omarchy share file [path]` y `omarchy share folder [path]`. Deja la ruta fuera y obtendrás el selector.

También puedes enviar directamente desde el administrador de archivos: haz clic derecho en cualquier selección en Files y compártela con LocalSend.

El firewall de Omarchy está cerrado por defecto, excepto por el puerto de LocalSend, así que esto funciona de inmediato en una instalación nueva. Consulta [seguridad](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) es un paquete de oficina completo con procesador de texto, hoja de cálculo, presentaciones, aplicación de dibujo y más. Es compatible con archivos de Microsoft Office, así que es una excelente manera de poder abrir esos documentos de Word.

Inicias LibreOffice mediante el lanzador de aplicaciones (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) es la aplicación de presentaciones sencillísima, propia de Omarchy. Tu presentación es un solo archivo Markdown con sus imágenes y videos al lado: escribe cada diapositiva debajo de una vista previa en vivo, arrastra las diapositivas para ponerlas en orden, luego preséntala en pantalla completa o expórtala a PDF y PowerPoint. Incluso adopta tu tema de Omarchy.

Inicias Hype mediante el lanzador de aplicaciones (`Super + Space`). Presiona `?` dentro de la aplicación para ver todos los atajos de teclado.

## Signed

[Signed](https://github.com/omacom/signed) es la forma sencillísima, propia de Omarchy, de firmar PDF y rellenarlos. Coloca tu firma guardada, texto y la fecha de hoy en cualquier lugar de una página, luego guarda una copia firmada junto al original. Consulta [Rellenar PDF](27-filling-out-pdfs.md) para saber cómo hacerlo.

Inicias Signed mediante el lanzador de aplicaciones (`Super + Space`), o abre un PDF con Signed desde el administrador de archivos.

## Game Vibes

Game Vibes, en el lanzador de aplicaciones (`Super + Space`), es donde viven los jueguitos de Omarchy: Checkmate, un juego de ajedrez en 3D contra un amigo o contra el oponente integrado; Cards, solitario Klondike; Death Wish, un juego de plataformas de precisión al píxel con diez cuartos llenos de púas y sierras; y Neon Swarm, un shooter arcade. Cada uno es una sola página web que sigue tu tema. Elige uno con las flechas y `Enter`, y regresa a la lista con `Esc` desde la pantalla de título de un juego o con `Q` mientras está en pausa. Se abre en pantalla completa: `Super + F` lo convierte en una ventana, y `Super + W` lo cierra.

Los juegos que creas con un agente también aparecen aquí: elige _Make something cool → Game_ en el panel de agentes y describe uno, o nombra un juego que ya esté en Game Vibes para seguir trabajando en él. El agente lo copia en `~/Games/vibes`, donde es tuyo para modificarlo, y lo abre cuando termina. Puedes hacer esa copia tú mismo con `omarchy games vibes copy <game>`. Un juego que comparte otra persona se instala como un tema: elige _Install > Gaming > Game Vibes_ y pega su dirección git, o ejecuta `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ vuelve a quitar uno, y _Update > Game Vibes Games_ obtiene las nuevas versiones. Los juegos cargan three.js desde la web, así que necesitan una conexión para iniciar.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) es la calculadora sencillísima, propia de Omarchy, que se abre en una ventana flotante.

Inicias Omacalc con `Super + Shift + Q` (o con la tecla de calculadora, si tu teclado tiene una).

## Signal

[Signal](https://signal.org/) es el pionero de la mensajería con cifrado E2E, y una excelente opción de comunicación para cualquiera que prefiera no pasar por uno de los grandes conglomerados tecnológicos.

Inicias Signal con `Super + Shift + G`. No forma parte de la instalación base, así que la primera vez que presiones esa combinación, Omarchy te ofrecerá instalártelo (también está en _Install > Service_ en el menú de Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) es el visor de imágenes y reproductor multimedia sencillísimo, propio de Omarchy: una ventana para tus fotos, videos y música. Abre una foto y las teclas de flecha recorren el resto de su carpeta, `N` y `P` hacen lo mismo para cualquier cosa, y `Ctrl + M` muestra toda la carpeta como una cuadrícula. También muestra fotos HEIC, AVIF y JPEG XL, y retoma cualquier contenido largo justo donde lo dejaste.

Presiona `F` para pantalla completa, `E` para editar una imagen en Omasnap o recortar un video en Omacut, `Ctrl + P` para imprimir una imagen y `Delete` para mover un archivo a la papelera (`Ctrl + Z` lo trae de vuelta). Presiona `?` dentro de la aplicación para ver todos los atajos de teclado.

Inicias Omaview como _Media Viewer_ mediante el lanzador de aplicaciones (`Super + Space`), o simplemente haz doble clic en una imagen, un video o una canción en el administrador de archivos.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) es el recortador de video sencillísimo, propio de Omarchy. Cuando todo lo que necesitas es cortar el principio y el final de un clip, es mucho mejor que abrir un editor de video completo.

Inicias Omacut mediante el lanzador de aplicaciones (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) es la grabadora de cámara web sencillísima, propia de Omarchy. Elige tu cámara y tu micrófono una vez, luego presiona `Space` para grabar, y otra vez para pausar y reanudar la misma toma. Siempre graba a la resolución más alta de tu cámara, con un medidor de micrófono en vivo para que puedas revisar tus niveles antes de empezar.

Detén la toma y se abrirá de inmediato en un editor integrado. Haz doble clic en un clip para dividirlo, arrastra los controles para recortar cada pieza y elimina las partes que no quieras. Luego guárdalo como un MP4. Tu grabación original se conserva hasta que la descartes, así que siempre puedes volver y cortarla de otra manera.

Inicias Monologue mediante el lanzador de aplicaciones (`Super + Space`).
