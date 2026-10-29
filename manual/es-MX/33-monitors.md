# Monitores

Omarchy asume por defecto que estás usando una pantalla clase retina con capacidad 2x. Esto es lo que necesitas para obtener esas fuentes de programación nítidas y agradables. Es para lo que están optimizadas casi todas las laptops premium nuevas con pantallas de alta resolución. Es lo que querrías usar en una de 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) o de 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Pero si no estás usando una pantalla con un PPI de 218 o superior, querrás cambiar la configuración del monitor. Por ejemplo, si tienes una 4K de 27" o 32", puedes usar el escalado fraccionario abriendo `~/.config/hypr/monitors.lua` (mediante _Configuración > Monitores_ en el menú de Omarchy) y cambiando a la recomendación para esa combinación:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Si estás usando una pantalla de 1080p o 1440p, probablemente solo querrás usar escalado 1x, así que puedes usar:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Los cambios en `GDK_SCALE` se aplican a las aplicaciones iniciadas después del cambio (y GTK solo acepta números enteros, así que mantenlo en el entero más cercano a la escala de tu monitor). Así que asegúrate de cerrar las ventanas que tengas sobredimensionadas después del cambio (¡o cierra todas las ventanas con `Ctrl + Alt + Del`!).

También puedes recorrer rápidamente las principales proporciones de escalado del monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) usando `Super + /` para subir y `Super + Alt + /` para bajar, o elegir una desde el panel del monitor en la barra superior. Estos cambios solo afectan al monitor en el que estás enfocado, así que la pantalla de una laptop y una pantalla externa pueden tener cada una su propia escala. La elección se guarda en `~/.config/hypr/monitors.lua` como una regla `hl.monitor` para ese monitor, así que persiste después de reiniciar y tiene prioridad sobre `omarchy_monitor_scale`, que sigue siendo la escala para todos los monitores que no tengan una regla propia. Como `GDK_SCALE` es un solo valor para todas las pantallas, estos cambios lo establecen a partir del monitor con la escala más baja, para que las aplicaciones X11 salgan un poco pequeñas en la pantalla más densa en lugar de sobredimensionadas en la otra.

### Hacer el texto más grande o más pequeño

El escalado del monitor cambia el tamaño de todo. Si lo único que quieres es texto más grande o más pequeño, hay un solo control para eso:

```
omarchy display text size 14
```

Eso acepta un tamaño en píxeles entre 9 y 20, y mueve juntos el shell de Omarchy, las aplicaciones GTK y tu terminal, para que todo el escritorio se mantenga en proporción. Ejecútalo sin ningún argumento para ver en qué punto estás, y `omarchy display text size reset` para volver al valor predeterminado. Foot es el único rezagado: no tiene forma de recargar su configuración, así que las terminales en ejecución mantienen su tamaño anterior hasta que abras una nueva.

### Extender y duplicar pantallas de laptop

Cuando conectas una pantalla externa a tu laptop, la pantalla se extiende automáticamente. Pero puedes cambiar eso a duplicación en su lugar usando _Disparador > Hardware_ en el menú de Omarchy o `Super + Ctrl + Alt + Delete`. Esto es especialmente útil si esa pantalla externa es un proyector y quieres mostrar algo mientras trabajas.

Cuando estás extendiendo, cerrar la tapa de la laptop apagará automáticamente la pantalla interna. Abrir la tapa la volverá a encender. También puedes controlar esto manualmente usando _Disparador > Hardware_ en el menú de Omarchy o `Super + Ctrl + Delete`.

### Organizar varias pantallas

Hyprland funciona muy bien con varias pantallas. Lee más sobre cómo organizarlas en [la documentación de monitores de Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). En Omarchy, estas van en `~/.config/hypr/monitors.lua` como entradas `hl.monitor`: el archivo incluye ejemplos comentados para fijar un monitor específico a una resolución, posición y rotación.

Cada monitor tiene sus propios espacios de trabajo del 1 al 10, así que `Super + 1` siempre significa el primer espacio de trabajo del monitor en el que estás. Detrás de escena, Hyprland sigue numerando los espacios de trabajo a través de todos los monitores: la pantalla de tu laptop (o primer monitor) obtiene 1–10, el siguiente monitor 11–20, y así sucesivamente, y cada monitor mantiene su bloque cada vez que lo conectas. Usa esos números si escribes [reglas de espacios de trabajo](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) o reglas de ventanas para un monitor específico, de modo que el espacio de trabajo 12 sea el segundo espacio de trabajo de tu segundo monitor. `~/.local/state/omarchy/monitor-workspaces` enumera qué bloque tiene cada monitor.

Las teclas de flecha funcionan a través de monitores que comparten un borde en tu diseño. Las pantallas que solo se tocan en una esquina, o que tienen un espacio entre ellas, no son vecinas, así que usa `Ctrl + Alt + Tab` para moverte entre ellas.

| Atajo de teclado | Entre monitores |
| --- | --- |
| `Super + Arrow` | Mueve el foco al monitor de ese lado una vez que ya no queda ninguna ventana en esa dirección |
| `Super + Shift + Arrow` | Intercambia con una ventana en el monitor de ese lado |
| `Super + Alt + Arrow` | Mueve la ventana a un grupo en el monitor de ese lado |
| `Super + Shift + Ctrl + Arrow` | Mueve la ventana al monitor de ese lado, al espacio de trabajo que está mostrando |
| `Super + Shift + Alt + Arrow` | Mueve el espacio de trabajo al monitor de ese lado, manteniendo su número si está libre |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Mueve el foco al monitor siguiente o anterior, sea cual sea el diseño |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Se quedan en el monitor en el que estás |

También puedes echar un vistazo a [Hyprmon](https://github.com/erans/hyprmon/), si quieres una TUI que te ayude con la colocación de varias pantallas.

### Controlar el brillo

El brillo del monitor se controla con las teclas de función dedicadas para subir/bajar el brillo. Si mantienes presionada shift mientras presionas estas, irás al brillo máximo o mínimo. Las teclas controlan la pantalla en la que estás enfocado, así que los monitores externos que hablan DDC/CI se ajustan de la misma manera que la pantalla de la laptop.

### Pantallas Apple

Si estás usando una pantalla Apple, las teclas regulares de brillo del teclado también funcionarán automáticamente, si estás enfocado en la pantalla Apple. Esto se hace mediante el comando `asdcontrol`.

Ten en cuenta que si estás usando una pantalla Apple 6K XDR, es posible que veas una pantalla fantasma en tu listado de `hyprctl monitors`. Puedes desactivar esto con algo como `hl.monitor({ output = "DP-2", disabled = true })` mediante _Configuración > Monitores_.

En máquinas Intel, deberías conectar las pantallas Apple usando un cable Thunderbolt regular. En otras máquinas sin Thunderbolt, normalmente tendrás que usar un [cable DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) para que funcione.
