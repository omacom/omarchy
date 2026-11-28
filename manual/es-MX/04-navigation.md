# Navegación

Todo en Omarchy pasa por el teclado: _¡TODO!_ Cuando el sistema arranca por primera vez, literalmente no puedes hacer nada solo con el mouse. Pero puedes presionar `Super + Space` para mostrar el menú de Omarchy y desde ahí puedes hacer prácticamente todo.

Pero el menú de Omarchy ni siquiera está pensado para ser la forma principal de operar el sistema la mayor parte del tiempo. ¡Podemos ir más rápido que eso! Todas las aplicaciones más importantes están asignadas directamente a atajos individuales. Inicias la terminal con `Super + Return` y un navegador con `Super + Shift + Return`. Prueba hacer una cosa tras otra y verás la magia del mosaico de Hyprland en acción:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Luego puedes presionar `Super + J` para apilarlas una sobre otra en lugar de ponerlas lado a lado:

 ![navigation-stacked](images/navigation-stacked.webp)

Presiona `Super + J` otra vez para regresarlas a sus posiciones lado a lado. Luego prueba `Super + Shift + Arrow Right` mientras estás en el navegador para intercambiar las ventanas.

Ahora prueba `Super + Shift + T` para iniciar el monitor de Actividad. Aparecerá como una ventana flotante, con una barra de título para arrastrarla y botones para minimizarla, maximizarla y cerrarla. Cada ventana flotante tiene una, esté donde esté. Puedes ponerla en mosaico con `Super + T` (y presionar eso otra vez para volver a hacerla flotante). Ahora presiona `Super + Shift + F` para abrir el administrador de archivos. Tendrás una ordenada disposición en cuatro:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navegas entre la ventana que quieres activar con `Super + Arrow`. Esto cambiará el foco y moverá el cursor al centro de la nueva aplicación. En el borde de una pantalla, continúa hacia el monitor de ese lado.

Si presionas `Super + Shift + 2`, moverás la aplicación enfocada actual al segundo espacio de trabajo. `Super + Shift + 1` la regresa. (Y `Super + Shift + Alt + 2` moverá la aplicación enfocada actual al segundo espacio de trabajo sin cambiar a él).

Con más de un monitor, cada monitor tiene sus propios espacios de trabajo del 1 al 10. `Super + 2` va al segundo espacio de trabajo del monitor en el que estás, y la barra superior de cada monitor muestra sus propios espacios de trabajo y el que está mostrando. `Super + Tab` recorre los espacios de trabajo del monitor en el que estás. `Super + Shift + Ctrl + Arrows` mueve la ventana en la que estás al monitor en esa dirección, al espacio de trabajo que está mostrando, y `Super + Shift + Alt + Arrows` mueve el espacio de trabajo en el que estás al monitor en esa dirección, donde toma el mismo número si está libre. Un monitor conserva sus espacios de trabajo cuando lo desconectas: se unen a los de otra pantalla, numerados después de los que ya tiene, y regresan a sus números anteriores cuando el monitor vuelve.

Si mantienes presionado `Super` y usas el mouse para hacer clic en una ventana, podrás reorganizar dónde está colocada. Si mantienes presionado `Super` y usas el botón derecho del mouse, puedes cambiar el tamaño de la ventana libremente.

Cierras una ventana con `Super + W` o `Super + Q` (y cierras todas las ventanas con `Ctrl + Alt + Delete`).

También puedes ir a pantalla completa con `Super + F` o incluso solo a ancho completo (manteniendo la barra superior) con `Super + Alt + F` o a pantalla completa dentro de una ventana con `Super + Ctrl + F` (¡ideal para YouTube!).

### Dwindle vs. diseño con desplazamiento

El diseño predeterminado de Omarchy se llama dwindle. Mantiene visibles en todo momento todas las ventanas que abres en un solo espacio de trabajo, incluso si tiene que reducirlas.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Pero también puedes elegir convertir un espacio de trabajo al diseño con desplazamiento, donde las ventanas se alinean lado a lado, más allá del borde visible de la pantalla. Conviertes un solo espacio de trabajo a este diseño con `Super + L`.

Presionar `Super + L` otra vez vuelve flotante el espacio de trabajo, donde las ventanas se superponen libremente y tú las colocas, y una tercera presión lo regresa a dwindle. `Super + Alt + L` los recorre en el otro sentido. Una ventana que de todos modos es flotante —una que sacaste con `Super + T`, o una aplicación que siempre se abre flotante— sigue flotante cuando el espacio de trabajo regresa al mosaico. La barra superior marca el espacio de trabajo en el que estás con su diseño: un cuadrado para dwindle, un círculo para desplazamiento y un triángulo para flotante. Hacer clic en esa marca también recorre el diseño, y lo mismo hace la tecla de pantalla en las laptops que tienen una.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

La elección es por espacio de trabajo, y se queda. Así puedes mantener el espacio de trabajo 1 en dwindle para navegar y el espacio de trabajo 2 con desplazamiento para código, y volverán así después de un reinicio.

Si quieres usar el diseño con desplazamiento como predeterminado, puedes definirlo en `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espacios de trabajo flotantes

Un espacio de trabajo flotante funciona como un escritorio tradicional: las ventanas se superponen, y tú las mueves y les cambias el tamaño. Cada ventana tiene una barra de título con los colores de tu tema, con botones para minimizar, maximizar y cerrar. `Super + M` también minimiza la ventana enfocada. Una ventana minimizada espera en el dock; haz clic en su aplicación para traerla de vuelta. Haz clic en una ventana para traerla al frente. Cambia su tamaño desde cualquier borde o esquina. Haz doble clic en una barra de título para maximizar la ventana manteniendo visible la barra superior, y otra vez para recuperar su tamaño anterior. Chrome y otros navegadores basados en Chromium, Disks y Document Viewer omiten la barra de título y usan su propio encabezado en su lugar; `Super + Alt + F` los maximiza, y `Super + M` los minimiza.

Cada espacio de trabajo tiene un dock, con tus aplicaciones fijadas, todo lo que está en ejecución, y una cuadrícula de cada aplicación detrás del botón de aplicaciones, que `Super + Alt + Space` y _Apps_ en el menú de Omarchy también abren. Haz clic derecho en una aplicación de la cuadrícula, o presiona `Delete`, para desinstalarla. Haz clic en una aplicación para abrirla, o para traer su ventana al frente; haz clic otra vez para recorrer sus ventanas. Files solo trae de vuelta una ventana del espacio de trabajo en el que estás y en caso contrario abre una nueva, y Terminal y Agent siempre inician otra, aunque una ventana minimizada regresa primero. Haz clic central para abrir una ventana nueva. Arrastra un ícono por el dock para moverlo; arrastrar una aplicación en ejecución entre las demás hace que se quede ahí. Haz clic derecho para mantener una aplicación en el dock, sacarla o salir de ella. El dock permanece visible mientras un espacio de trabajo está vacío, y una vez que el espacio de trabajo tiene una ventana, se oculta hasta que el puntero llega a su borde. Una ventana en pantalla completa lo oculta por completo. Arrastra el botón de aplicaciones hacia otro borde de la pantalla para mover el dock ahí. Haz clic derecho en él para _Position_, para elegir un borde, _Layout_, para definir el diseño predeterminado como lo hace _Appearance > Workspace Layout_, y _Visibility_, para mantener el dock siempre visible, hacer que la primera aplicación lo oculte o mantenerlo siempre oculto. `omarchy dock visibility always` define eso desde una terminal. La posición también está en _Appearance > Dock > Dock Position_, y `omarchy dock position left` la define desde una terminal. Las aplicaciones que mantienes en el dock se ven atenuadas mientras no están en ejecución. Para limitar el dock a los espacios de trabajo flotantes, usa _Appearance > Dock > Dock Only on Floating_ o `omarchy dock tiling off`.

Los espacios de trabajo nuevos, y cualquiera al que no le hayas dado un diseño propio con `Super + L`, usan el diseño predeterminado. Cambiar el predeterminado restablece a él cada espacio de trabajo sin ventanas, mientras que uno con ventanas conserva el diseño que tiene. Una ventana minimizada en el dock sigue contando como una ventana en el espacio de trabajo que dejó. Elígelo en _Appearance > Workspace Layout_: Tiling, Scrolling o Floating. `omarchy hyprland workspace layout default scrolling` lo define desde una terminal.

### Agrupar ventanas

Las ventanas se pueden agrupar con `Super + G`. Una vez que estás en un grupo, cada ventana que inicies mientras eso esté activo pertenecerá al grupo. Puedes moverte entre estas ventanas agrupadas con `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` para ir directamente a las ventanas agrupadas en orden.

Puedes sacar una ventana de la agrupación con `Super + Alt + G` o desarmar todo el grupo presionando `Super + G` otra vez. Por último, puedes mover ventanas fuera del grupo hacia dentro de él con `Super + Alt + Arrows`.

### Extraer ventanas

Puedes sacar una ventana de su asignación de espacio de trabajo con `Super + O`. Eso la fijará como una ventana flotante que te sigue a cualquier espacio de trabajo al que vayas. Ideal para reproductores de video y cosas por el estilo.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espacio de trabajo scratchpad

Hay un espacio de trabajo scratchpad especial de tamaño completo que se superpone a cualquier espacio de trabajo en el que estés actualmente. Accedes a lo que hay en él con `Super + S`, y colocas ventanas ahí con `Super + Alt + S`.

Funciona bien para controles o una terminal con la que quieres interactuar rápido sin salir del espacio de trabajo actual.

### Consola Quake

Por último, hay una consola Quake de media altura que se despliega sobre cualquier espacio de trabajo en el que estés actualmente. Actívala o desactívala con `Super + the key above Tab` (grave en diseños de EE. UU.), y coloca una ventana ahí con `Super + Shift + the key above Tab`.

La primera vez que se abre, inicia tu agente predeterminado, o te pide que elijas uno si aún no has elegido ninguno. Mientras la consola tiene una sola ventana, se despliega como un panel centrado en lugar de abarcar toda la pantalla. Pon una segunda aplicación en ella y vuelve al ancho completo, para que las dos tengan espacio para estar lado a lado.

Para sacar una ventana del scratchpad o de la consola, envíala directamente a otro espacio de trabajo con algo como `Super + Shift + 1`.

### ¡Cuesta un poco acostumbrarse!

Toma un poco de tiempo acostumbrarse a navegar tu escritorio así, pero una vez que lo hagas, ¡será difícil volver a una experiencia de escritorio tradicional controlada con el mouse!
