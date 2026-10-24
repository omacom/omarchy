# Navegación

Todo en Omarchy sucede con el teclado — _¡TODO!_ Cuando el sistema arranca por primera vez, literalmente no puedes hacer nada solo con el mouse. Pero puedes presionar `Super + Space` para mostrar el menú de Omarchy y desde ahí hacer prácticamente todo.

Pero el menú de Omarchy ni siquiera está pensado para ser la forma principal de operar el sistema la mayor parte del tiempo. ¡Podemos hacerlo más rápido que eso! Todas las aplicaciones más importantes están vinculadas directamente a atajos de teclado individuales. Abres la terminal con `Super + Return` y un navegador con `Super + Shift + Return`. Prueba hacer una tras otra y verás la magia del mosaico de Hyprland en acción:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Luego puedes presionar `Super + J` para apilarlas una sobre otra en lugar de ponerlas lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Presiona `Super + J` otra vez para regresarlas a sus posiciones lado a lado. Luego prueba `Super + Shift + Arrow Right` estando en el navegador para intercambiar las ventanas.

Ahora prueba `Super + Ctrl + T` para abrir el monitor de actividad. Aparecerá como una ventana flotante. Puedes ponerla en mosaico con `Super + T` (y presionar eso otra vez para hacerla flotante de nuevo). Ahora presiona `Super + Shift + F` para abrir el administrador de archivos. Tendrás una ordenada configuración de cuatro ventanas:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navegas entre las ventanas hasta la que quieres que esté activa con `Super + Arrow`. Esto cambiará el foco y moverá el cursor al centro de la nueva aplicación.

Si presionas `Super + Shift + 2`, moverás la aplicación enfocada actualmente al segundo espacio de trabajo. `Super + Shift + 1` la regresa. (Y `Super + Shift + Alt + 2` moverá la aplicación enfocada actualmente al segundo espacio de trabajo sin cambiarte a él).

Si mantienes presionado `Super` y usas el mouse para hacer clic en una ventana, podrás reacomodar dónde queda. Si mantienes presionado `Super` y usas el botón derecho del mouse, puedes cambiar el tamaño de la ventana libremente.

Cierras una ventana con `Super + W` o `Super + Q` (y cierras todas las ventanas con `Ctrl + Alt + Delete`).

También puedes pasar a pantalla completa con `Super + F` o incluso solo a todo el ancho (manteniendo la barra superior) con `Super + Alt + F` o a pantalla completa dentro de una ventana con `Super + Ctrl + F` (¡ideal para YouTube!).

### Diseño dwindle vs. diseño con desplazamiento

El diseño predeterminado de Omarchy se llama dwindle. Mantiene visibles en todo momento todas las ventanas que abres en un mismo espacio de trabajo, aunque tenga que encogerlas.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Pero también puedes elegir convertir un espacio de trabajo al diseño con desplazamiento, donde las ventanas se alinean lado a lado, más allá del borde visible de la pantalla. Conviertes un espacio de trabajo individual a este diseño con `Super + L`.

Presionar `Super + L` otra vez vuelve flotante el espacio de trabajo, donde las ventanas se superponen libremente y tú las colocas, y una tercera vez lo regresa a dwindle. `Super + Alt + L` los recorre en el otro sentido. Una ventana que de por sí es flotante — una que desprendiste con `Super + T`, o una app que siempre se abre flotante — se mantiene flotante cuando el espacio de trabajo vuelve al mosaico. La barra superior marca el espacio de trabajo en el que estás con su diseño: un cuadrado para dwindle, un círculo para el diseño con desplazamiento y un triángulo para el flotante. Hacer clic en esa marca también alterna el diseño.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

La elección es por espacio de trabajo y se conserva. Así puedes mantener el espacio de trabajo 1 en dwindle para navegar y el espacio de trabajo 2 con desplazamiento para programar, y volverán así después de un reinicio.

Si quieres usar el diseño con desplazamiento como predeterminado, puedes configurar eso en `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espacios de trabajo flotantes

Un espacio de trabajo flotante funciona como un escritorio tradicional: las ventanas se superponen y tú las mueves y les cambias el tamaño. Cada ventana recibe una barra de título con los colores de tu tema, con botones para minimizar, maximizar y cerrar. `Super + M` también minimiza la ventana enfocada. Una ventana minimizada espera en el dock; haz clic en su app para traerla de regreso. Haz clic en una ventana para traerla al frente. Cámbiale el tamaño desde cualquier borde o esquina. Haz doble clic en una barra de título para maximizar la ventana manteniendo visible la barra superior, y otra vez para recupere su tamaño anterior.

Un espacio de trabajo flotante también muestra un dock, con tus apps fijadas, todo lo que está en ejecución y una cuadrícula de todas las apps detrás del botón de aplicaciones, que `Super + Alt + Space` y _Aplicaciones_ en el menú de Omarchy también abren. Haz clic derecho en una app de la cuadrícula, o presiona `Delete`, para desinstalarla. Haz clic en una app para abrirla, o para traer su ventana al frente; haz clic otra vez para alternar entre sus ventanas. Un clic con el botón central abre una ventana nueva. Arrastra un ícono por el dock para moverlo; arrastrar una app en ejecución entre las demás la deja ahí. Haz clic derecho para mantener una app en el dock, sacarla o cerrarla. El dock se quita del camino de una ventana en pantalla completa. Haz clic derecho en el botón de aplicaciones para mover el dock a otro borde o hacer que se oculte hasta que el puntero llegue a su borde. La posición también está en _Trigger > Apariencia > Dock > Posición del dock_, y `omarchy dock position left` y `omarchy dock autohide on` configuran ambas cosas desde una terminal. Las apps que mantienes en el dock se ven atenuadas mientras no están en ejecución.

Los espacios de trabajo nuevos, y cualquiera al que no le hayas dado un diseño propio con `Super + L`, usan el diseño predeterminado. Cambiar el predeterminado restablece a ese diseño todo espacio de trabajo sin ventanas, mientras que uno con ventanas conserva el diseño que tiene. Una ventana minimizada al dock sigue contando como una ventana en el espacio de trabajo que dejó. Elígelo en _Trigger > Apariencia > Diseño del espacio de trabajo_: En mosaico, Con desplazamiento o Flotante. `omarchy-hyprland-workspace-layout-default scrolling` lo configura desde una terminal.

### Agrupar ventanas

Las ventanas se pueden agrupar con `Super + G`. Una vez que estás en un grupo, cada ventana que abras mientras eso está activo pertenecerá al grupo. Puedes moverte entre estas ventanas agrupadas con `Super + Ctrl + Arrow Left/Right` o con `Super + Alt + 1/2/3/4` para ir directamente a una ventana agrupada en orden.

Puedes sacar una ventana del grupo con `Super + Alt + G` o desarmar todo el grupo presionando `Super + G` otra vez. Por último, puedes mover ventanas fuera del grupo hacia dentro de él con `Super + Alt + Arrows`.

### Desprender ventanas

Puedes desprender una ventana de su asignación en el espacio de trabajo con `Super + O`. Eso la fijará como una ventana flotante que te sigue a cualquier espacio de trabajo al que vayas. Ideal para reproductores de video y cosas por el estilo.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espacio de trabajo scratchpad

Por último, hay un espacio de trabajo especial tipo scratchpad que se despliega sobre cualquier espacio de trabajo en el que estés actualmente, muy parecido a una consola de Quake. Actívalo y desactívalo con `Super + Grave` o `Super + S`, y coloca una ventana ahí con `Super + Shift + Grave` o `Super + Alt + S`.

Funciona especialmente bien para una terminal que ejecuta un agente, o para controles con los que quieres interactuar rápido sin dejar el espacio de trabajo actual. Para sacar una ventana del scratchpad, envíala directamente a otro espacio de trabajo con algo como `Super + Shift + 1`.

Mientras el scratchpad contiene una sola ventana, se despliega como un panel centrado en lugar de abarcar toda la pantalla. Pon una segunda app en él y volverá a todo el ancho, para que las dos tengan espacio para estar lado a lado.

### ¡Cuesta un poco acostumbrarse!

Cuesta un poco acostumbrarse a navegar tu escritorio así, pero una vez que lo haces, ¡será difícil volver a una experiencia de escritorio tradicional basada en el mouse!
