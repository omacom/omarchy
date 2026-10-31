# Navegación

Todo en Omarchy sucede mediante el teclado — _¡TODO!_ Cuando el sistema arranca por primera vez, literalmente no puedes hacer nada solo con el ratón. Pero puedes pulsar `Super + Space` para mostrar el Omarchy Menu y desde ahí puedes hacer prácticamente todo.

Pero el menú de Omarchy ni siquiera está pensado para ser la forma principal de operar el sistema la mayor parte del tiempo. ¡Podemos hacerlo más rápido que eso! Todas las aplicaciones más importantes están vinculadas directamente a atajos individuales. Inicias la terminal con `Super + Return` y un navegador con `Super + Shift + Return`. Prueba a hacer una cosa después de la otra y verás la magia del mosaico de Hyprland en acción:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Luego puedes pulsar `Super + J` para apilarlas una encima de la otra en lugar de una al lado de la otra:

 ![navigation-stacked](images/navigation-stacked.webp)

Pulsa `Super + J` de nuevo para devolverlas a sus posiciones una al lado de la otra. Luego prueba `Super + Shift + Arrow Right` mientras estás en el navegador para intercambiar las ventanas.

Ahora prueba `Super + Shift + T` para iniciar el monitor de Activity. Eso aparecerá como una ventana flotante. Puedes ponerla en mosaico usando `Super + T` (y pulsar eso de nuevo para volver a hacerla flotante). Ahora pulsa `Super + Shift + F` para abrir el administrador de archivos. Tendrás una elegante configuración en cuatro partes:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navegas entre la ventana que quieres que esté activa con `Super + Arrow`. Esto cambiará el foco y moverá el cursor al centro de la nueva aplicación. En el borde de una pantalla, continúa hacia el monitor de ese lado.

Si pulsas `Super + Shift + 2`, moverás la aplicación enfocada actualmente al segundo espacio de trabajo. `Super + Shift + 1` la devuelve. (Y `Super + Shift + Alt + 2` moverá la aplicación enfocada actualmente al segundo espacio de trabajo sin cambiar a él).

Con más de un monitor, cada monitor tiene sus propios espacios de trabajo del 1 al 10. `Super + 2` va al segundo espacio de trabajo del monitor en el que estás, y la barra superior de cada monitor muestra sus propios espacios de trabajo y el que está mostrando. `Super + Tab` recorre los espacios de trabajo del monitor en el que estás. `Super + Shift + Ctrl + Arrows` mueve la ventana en la que estás al monitor en esa dirección, al espacio de trabajo que está mostrando, y `Super + Shift + Alt + Arrows` mueve el espacio de trabajo en el que estás al monitor en esa dirección, donde toma el mismo número si está libre. Un monitor conserva sus espacios de trabajo cuando lo desconectas: se unen a los de otra pantalla, numerados después de los que ya tiene, y vuelven a sus números anteriores cuando el monitor regresa.

Si mantienes pulsado `Super` y usas el ratón para hacer clic en una ventana, podrás reorganizar dónde se ubica. Si mantienes `Super` y usas el botón derecho del ratón, puedes redimensionar la ventana libremente.

Cierras una ventana con `Super + W` o `Super + Q` (y cierras todas las ventanas con `Ctrl + Alt + Delete`).

También puedes ir a pantalla completa con `Super + F` o incluso solo a ancho completo (manteniendo la barra superior) con `Super + Alt + F` o a pantalla completa dentro de una ventana con `Super + Ctrl + F` (¡ideal para YouTube!).

### Diseño dwindle frente a desplazamiento

El diseño predeterminado de Omarchy se llama dwindle. Mantiene todas las ventanas que abres en un solo espacio de trabajo visibles en todo momento, incluso si tiene que reducirlas.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Pero también puedes elegir convertir un espacio de trabajo en el diseño de desplazamiento, donde las ventanas se alinean una al lado de la otra, más allá del borde visible de la pantalla. Conviertes un solo espacio de trabajo a este diseño mediante `Super + L`.

Pulsar `Super + L` de nuevo convierte el espacio de trabajo en flotante, donde las ventanas se superponen libremente y tú las colocas, y una tercera pulsación lo devuelve a dwindle. `Super + Alt + L` los recorre en la otra dirección. Una ventana que flota de todos modos — una que sacaste con `Super + T`, o una app que siempre se abre flotante — sigue flotando cuando el espacio de trabajo vuelve al mosaico. La barra superior marca el espacio de trabajo en el que estás con su diseño: un cuadrado para dwindle, un círculo para desplazamiento y un triángulo para flotante. Hacer clic en esa marca también recorre el diseño.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

La elección es por espacio de trabajo, y se mantiene. Así que puedes mantener el espacio de trabajo 1 en dwindle para navegar y el espacio de trabajo 2 en desplazamiento para código, y volverán así después de un reinicio.

Si deseas usar el diseño de desplazamiento como predeterminado, puedes configurarlo en `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espacios de trabajo flotantes

Un espacio de trabajo flotante funciona como un escritorio tradicional: las ventanas se superponen, y tú las mueves y las dimensionas. Cada ventana obtiene una barra de título con los colores de tu tema, con botones para minimizar, maximizar y cerrar. `Super + M` también minimiza la ventana enfocada. Una ventana minimizada espera en el dock; haz clic en su app para traerla de vuelta. Haz clic en una ventana para traerla al frente. Redimensiónala desde cualquier borde o esquina. Haz doble clic en una barra de título para maximizar la ventana manteniendo la barra superior a la vista, y de nuevo para recuperar su tamaño anterior.

Un espacio de trabajo flotante también muestra un dock, con tus apps fijadas, todo lo que está en ejecución, y una cuadrícula de cada app detrás del botón de apps, que `Super + Alt + Space` y _Apps_ en el menú de Omarchy también abren. Haz clic derecho en una app en la cuadrícula, o pulsa `Delete`, para desinstalarla. Haz clic en una app para abrirla, o para traer su ventana al frente; haz clic de nuevo para recorrer sus ventanas. El clic central abre una ventana nueva. Arrastra un ícono a lo largo del dock para moverlo; arrastrar una app en ejecución entre las demás la mantiene ahí. Haz clic derecho para mantener una app en el dock, sacarla, o salir de ella. El dock se aparta del camino de una ventana en pantalla completa. Haz clic derecho en el botón de apps para mover el dock a otro borde o hacer que se oculte hasta que el puntero alcance su borde. La posición también está en _Appearance > Dock > Dock Position_, y `omarchy dock position left` y `omarchy dock autohide on` configuran ambas desde una terminal. Las apps que mantienes en el dock están atenuadas mientras no están en ejecución.

Los espacios de trabajo nuevos, y cualquiera a los que no les hayas dado un diseño propio con `Super + L`, usan el diseño predeterminado. Cambiar el predeterminado restablece a él cada espacio de trabajo sin ventanas, mientras que uno con ventanas conserva el diseño que tiene. Una ventana minimizada en el dock sigue contando como una ventana en el espacio de trabajo que dejó. Elígelo en _Appearance > Workspace Layout_: Tiling, Scrolling, o Floating. `omarchy-hyprland-workspace-layout-default scrolling` lo configura desde una terminal.

### Agrupar ventanas

Las ventanas se pueden agrupar usando `Super + G`. Una vez que estés en un grupo, cada ventana que inicies mientras eso esté activo pertenecerá al grupo. Puedes moverte entre estas ventanas agrupadas usando `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` para ir directamente a la ventana agrupada en orden.

Puedes sacar una ventana de la agrupación con `Super + Alt + G` o desarmar todo el grupo pulsando `Super + G` de nuevo. Por último, puedes mover ventanas fuera del grupo hacia dentro de él con `Super + Alt + Arrows`.

### Sacar ventanas

Puedes sacar una ventana de la asignación de su espacio de trabajo con `Super + O`. Eso la fijará como una ventana flotante que te sigue a cualquier espacio de trabajo al que vayas. Ideal para reproductores de video y similares.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espacio de trabajo scratchpad

Hay un espacio de trabajo scratchpad especial de tamaño completo que se superpone a cualquier espacio de trabajo en el que estés actualmente. Accedes a lo que hay en él usando `Super + S`, y colocas ventanas ahí usando `Super + Alt + S`.

Funciona bien para controles o una terminal con la que quieres interactuar rápidamente sin salir del espacio de trabajo actual.

### Consola Quake

Por último, hay una consola Quake de media altura que se despliega sobre cualquier espacio de trabajo en el que estés actualmente. Actívala con `Super + Grave`, y coloca una ventana ahí usando `Super + Shift + Grave`.

Se abre con tu agente predeterminado listo para usar. Mientras la consola contiene una sola ventana, se despliega como un panel centrado en lugar de abarcar la pantalla. Pon una segunda app en ella y vuelve al ancho completo, para que las dos tengan espacio para estar una al lado de la otra.

Para mover una ventana fuera del scratchpad o de la consola, envíala directamente a otro espacio de trabajo con algo como `Super + Shift + 1`.

### ¡Lleva algo de tiempo acostumbrarse!

Lleva un poco de tiempo acostumbrarse a navegar tu escritorio así, pero una vez que lo hagas, ¡será difícil volver a una experiencia de escritorio tradicional controlada con el ratón!
