# Marca personal

Omarchy te permite establecer el logo de tu empresa o tu imagen personal para el desbloqueo al arrancar, el protector de pantalla y la pantalla Acerca de.

### Desbloqueo al arrancar

Puedes usar `omarchy plymouth preview` para ver cómo se verían tu logo y tus colores personalizados. Recibe un color de fondo, un color de texto, un logo en png y una ruta para la imagen de vista previa:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Luego aplica la configuración con `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, que también le dará a la pantalla de inicio de sesión de SDDM los mismos colores y el mismo logo. Si quieres revertirlo, puedes usar `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Protector de pantalla

Puedes cambiar el logo que se usa para el protector de pantalla en _Estilo > Protector de pantalla_. Es un logo en ASCII, así que puedes editar el texto directamente, pero también puedes darle una imagen png o svg y nosotros la convertiremos a ASCII. Se ve bastante genial.

 ![branding-screensaver](images/branding-screensaver.webp)

Hay tres entradas en ese menú:

- **Editar texto** abre `~/.config/omarchy/branding/screensaver.txt` en tu editor. Escribe o pega lo que quieras: arte ASCII, tu nombre, una grosería. Guarda y sal, y el protector de pantalla se activa de inmediato para que puedas verlo.
- **Desde imagen** abre un selector de archivos para un png o svg, lo convierte a ASCII y te muestra el resultado. Los logos con una silueta clara funcionan mucho mejor que las fotos.
- **Restablecer predeterminado** regresa el logo de Omarchy.

### Pantalla Acerca de

Las mismas tres opciones están en _Estilo > Acerca de_ para la pantalla _Acerca de_ que obtienes desde el menú de Omarchy, y funcionan igual: el archivo es `~/.config/omarchy/branding/about.txt`, y la ventana Acerca de aparece después de cada cambio. El arte de Acerca de se convierte a un tamaño más pequeño que el del protector de pantalla, ya que tiene que caber en una ventana en lugar de llenar tu pantalla.

Mientras la ventana está abierta, un destello verde recorre el arte cada pocos segundos y luego lo deja quieto de nuevo. Tu propio arte también lo recibe, siempre que cada carácter en él tenga una columna de ancho, como lo es todo lo que produce _Desde imagen_. El arte construido con emoji o caracteres de doble ancho se queda quieto, y lo mismo pasa con la pantalla si mantienes tu propia configuración de fastfetch: un logo quieto en esos casos es la animación quitándose del camino en lugar de fallar, ya que deslizar un destello sobre ellos dejaría el resto de la línea en el lugar equivocado.

 ![branding-about](images/branding-about.webp)

### Convertir imágenes tú mismo

Las dos opciones de _Desde imagen_ simplemente llaman a `omarchy transcode ascii`, que puedes ejecutar directamente si quieres control sobre la conversión:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Recibe `--width` y `--height` en columnas y filas de la terminal, un `--mode` de `braille` (el predeterminado, y mucho más fino) o `block`, un porcentaje `--threshold` para decidir qué píxeles cuentan como parte del logo, y `--invert` para cuando tu logo es claro sobre un fondo oscuro. Si una conversión sale como una mancha, el umbral suele ser la perilla que hay que girar.

### Palabras en lugar de un logo

`omarchy ascii` dibuja texto en Delta Corps Priest 1, la fuente FIGlet con la que está dibujado el propio nombre de Omarchy, así que un protector de pantalla puede decir algo en lugar de mostrar una imagen:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Recibe el texto como argumentos, o lo lee de una tubería cuando no se le da ninguno. La fuente lleva solo letras y espacios — se dibujó sin dígitos ni signos de puntuación — así que cualquier otra cosa se descarta y se nombra en stderr en lugar de tragársela en silencio.
