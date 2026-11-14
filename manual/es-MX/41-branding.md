# Imagen de marca

Omarchy te permite establecer el logo de tu empresa o una imagen personal tanto para el desbloqueo al arrancar, como para el protector de pantalla y la pantalla Acerca de.

### Desbloqueo al arrancar

Puedes usar `omarchy plymouth preview` para ver cómo se verían tu logo y tus colores personalizados. Toma un color de fondo, un color de texto, un png del logo y una ruta para la imagen de vista previa:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Luego aplica la configuración con `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, que también le dará a la pantalla de inicio de sesión de SDDM los mismos colores y logo. Si quieres revertirlo, puedes usar `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Protector de pantalla

Puedes cambiar el logo usado para el protector de pantalla en _Apariencia > Imagen de marca > Protector de pantalla_. Es un logo en ASCII, así que puedes editar el texto directamente, pero también puedes darle una imagen png o svg, y nosotros la convertiremos a ASCII. Se ve bastante bien.

 ![branding-screensaver](images/branding-screensaver.webp)

Hay tres entradas en ese menú:

- **Editar texto** abre `~/.config/omarchy/branding/screensaver.txt` en tu editor. Escribe o pega lo que quieras — arte ASCII, tu nombre, una grosería. Guarda y sal, y el protector de pantalla se activa de inmediato para que puedas verlo.
- **Establecer desde una imagen** abre un selector de archivos para un png o svg, lo convierte a ASCII y te muestra el resultado. Los logos con una silueta clara funcionan mucho mejor que las fotos.
- **Restaurar predeterminado** vuelve a poner el logo de Omarchy.

### Pantalla Acerca de

Las mismas tres opciones están en _Apariencia > Imagen de marca > Acerca de_ para la pantalla _Acerca de_ que obtienes desde el menú de Omarchy, y funcionan de forma idéntica — el archivo es `~/.config/omarchy/branding/about.txt`, y la ventana Acerca de aparece después de cada cambio. El arte de Acerca de se convierte a un tamaño más pequeño que el del protector de pantalla, ya que tiene que caber en una ventana en lugar de llenar tu pantalla.

Mientras la ventana está abierta, un destello verde se desliza sobre el arte cada pocos segundos y luego lo vuelve a dejar quieto. Tu propio arte también lo recibe, siempre que cada carácter en él ocupe una sola columna — todo lo que produce _Establecer desde una imagen_ cumple con eso. El arte hecho con emoji o caracteres de doble ancho se queda quieto, en cambio, y también la pantalla si conservas una configuración de fastfetch propia: un logo quieto en esos casos es la animación haciéndose a un lado en lugar de fallar, ya que deslizar un destello sobre ellos dejaría el resto de la línea en el lugar equivocado.

 ![branding-about](images/branding-about.webp)

### Convertir imágenes por tu cuenta

Ambas opciones de _Establecer desde una imagen_ solo están llamando a `omarchy transcode ascii`, que puedes ejecutar directamente si quieres tener control sobre la conversión:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Toma `--width` y `--height` en columnas y filas de la terminal, un `--mode` de `braille` (el predeterminado, y mucho más fino) o `block`, un `--threshold` en porcentaje para decidir qué píxeles cuentan como parte del logo, y `--invert` para cuando tu logo es claro sobre un fondo oscuro. Si una conversión queda como una mancha, el umbral suele ser el parámetro que hay que ajustar.

### Palabras en lugar de un logo

`omarchy ascii` dibuja texto en Delta Corps Priest 1, la fuente FIGlet en la que está dibujado el propio wordmark de Omarchy, así que un protector de pantalla puede decir algo en lugar de mostrar una imagen:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Toma el texto como argumentos, o lo lee de una pipe cuando no se le da ninguno. La fuente solo incluye letras y espacios — fue dibujada sin dígitos ni signos de puntuación — así que cualquier otra cosa se descarta y se indica en stderr en lugar de tragársela en silencio.
