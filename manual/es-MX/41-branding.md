# Imagen de marca

Omarchy te permite establecer el logotipo de tu empresa o una imagen personal tanto para el protector de pantalla como para la pantalla Acerca de.

### Protector de pantalla

Puedes cambiar el logotipo usado para el protector de pantalla en _Apariencia > Imagen de marca > Protector de pantalla_. Es un logotipo ASCII, así que puedes editar el texto directamente, pero también puedes darle una imagen png o svg, y la convertiremos a ASCII. Se ve muy padre.

 ![branding-screensaver](images/branding-screensaver.webp)

Hay tres opciones en ese menú:

- **Editar texto** abre `~/.config/omarchy/branding/screensaver.txt` en tu editor. Escribe o pega lo que quieras: arte ASCII, tu nombre, una grosería. Guarda y sal, y el protector de pantalla se activa de inmediato para que puedas verlo.
- **Establecer desde una imagen** abre un selector de archivos para un png o svg, lo convierte a ASCII y te muestra el resultado. Los logotipos con una silueta clara funcionan mucho mejor que las fotos.
- **Restaurar el predeterminado** vuelve a poner el logotipo de Omarchy.

### Pantalla Acerca de

Las mismas tres opciones están en _Apariencia > Imagen de marca > Acerca de_ para la pantalla _Acerca de_ que obtienes desde el menú de Omarchy, y funcionan de forma idéntica: el archivo es `~/.config/omarchy/branding/about.txt`, y la ventana Acerca de aparece después de cada cambio. El arte de Acerca de se convierte a un tamaño menor que el del protector de pantalla, ya que tiene que caber en una ventana en lugar de llenar tu pantalla.

Mientras la ventana está abierta, una banda de luz blanca brillante cruza el arte cada pocos segundos y luego lo deja quieto otra vez. Tu propio arte también la recibe, siempre que cada carácter que lo compone ocupe una columna de ancho; todo lo que produce _Establecer desde una imagen_ cumple eso. En cambio, el arte creado con emoji o caracteres de doble ancho permanece quieto, y lo mismo ocurre con la pantalla si conservas tu propia configuración de fastfetch: en esos casos, que el logotipo permanezca quieto significa que la animación se aparta en lugar de fallar, ya que deslizar un destello sobre ellos haría que el resto de la línea quedara en el lugar equivocado.

 ![branding-about](images/branding-about.webp)

### Convertir imágenes por tu cuenta

Ambas opciones de _Establecer desde una imagen_ solo ejecutan `omarchy transcode ascii`, que puedes ejecutar directamente si quieres controlar la conversión:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Acepta `--width` y `--height` en columnas y filas de la terminal, un `--mode` que puede ser `braille` (el predeterminado y mucho más fino) o `block`, un porcentaje `--threshold` para decidir qué píxeles cuentan como parte del logotipo, y `--invert` para cuando tu logotipo es claro sobre un fondo oscuro. Si una conversión sale como una mancha, el umbral suele ser el ajuste que hay que mover.

### Palabras en lugar de un logotipo

`omarchy ascii` dibuja texto en Delta Corps Priest 1, la fuente FIGlet con la que está dibujado el propio logotipo tipográfico de Omarchy, para que un protector de pantalla pueda decir algo en lugar de mostrar una imagen:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Recibe el texto como argumentos, o lo lee desde una tubería cuando no se le da ninguno. La fuente incluye solo letras y espacios (fue dibujada sin dígitos ni signos de puntuación), así que cualquier otra cosa se descarta y se indica en stderr en lugar de tragársela en silencio.
