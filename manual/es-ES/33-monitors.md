# Monitores

Omarchy asume por defecto que estás usando una pantalla tipo Retina con capacidad 2x. Esto es lo que necesitas para obtener esas fuentes de programación bonitas y nítidas. Es para lo que están optimizados casi todos los portátiles premium nuevos con pantallas de alta resolución. Es lo que querrías usar en un monitor de 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) o de 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Pero si tu pantalla no tiene un PPI de 218 o más, tendrás que cambiar la configuración del monitor. Por ejemplo, si tienes un monitor 4K de 27" o 32", puedes elegir un escalado fraccional para él desde el panel de monitores en la barra superior, o fijar el valor predeterminado para cada monitor: abre `~/.config/hypr/monitors.lua` y pon la recomendación para esa combinación:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Si estás usando una pantalla de 1080p o 1440p, probablemente solo quieras usar escalado 1x, y lo mismo para las aplicaciones GTK y X11, así que puedes usar:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Los cambios en `GDK_SCALE` se aplican a las aplicaciones iniciadas después del cambio (y GTK solo acepta números enteros, así que mantenlo en el entero más cercano a la escala de tu monitor). Por eso conviene cerrar las ventanas que queden sobredimensionadas tras el cambio (¡o cierra todas las ventanas con `Ctrl + Alt + Del`!).

También puedes recorrer rápidamente las principales proporciones de escalado de monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) con `Super + /` para subir y `Super + Alt + /` para bajar, o elegir una desde el panel de monitores en la barra superior. Estos cambios solo afectan al monitor que tiene el foco, así que la pantalla de un portátil y una pantalla externa pueden tener cada una su propia escala. El panel también establece la resolución, la frecuencia de actualización y la rotación de cada monitor. Tus elecciones se guardan para ese monitor físico en `~/.local/state/omarchy/monitors/settings`, así que se mantienen tras reiniciar y acompañan al monitor a cualquier puerto o dock donde lo conectes luego. Tienen precedencia sobre cualquier regla para el mismo monitor en `~/.config/hypr/monitors.lua`, que Omarchy nunca edita. Si prefieres configurar tus monitores por completo en ese archivo, agrégale `omarchy_monitor_panel_settings = false`, y los cambios del panel durarán solo hasta que Hyprland se recargue. Como `GDK_SCALE` es un solo valor para todas las pantallas, una escala elegida lo establece a partir del monitor con la escala más baja, así que las aplicaciones X11 salen un poco pequeñas en la pantalla más densa en lugar de sobredimensionadas en la otra.

### Hacer el texto más grande o más pequeño

El escalado del monitor cambia el tamaño de todo. Si todo lo que quieres es _texto_ más grande o más pequeño, hay un solo control para eso:

```
omarchy display text size 14
```

Acepta un tamaño en píxeles entre 9 y 20, y mueve juntos el shell de Omarchy, las aplicaciones GTK y tu terminal, así que todo el escritorio se mantiene en proporción. Ejecútalo sin un argumento para ver dónde estás, y `omarchy display text size reset` para volver al valor predeterminado. Foot es la única excepción: no tiene forma de recargar su configuración, así que las terminales en ejecución mantienen su tamaño anterior hasta que abras una nueva.

### Extender y duplicar la pantalla del portátil

Cuando conectas una pantalla externa a tu portátil, la pantalla se extiende automáticamente. Pero puedes cambiar eso a duplicación con _Extender_ | _Duplicar_ en el panel del monitor en la barra superior, _Activar > Hardware_ en el menú de Omarchy, o `Super + Ctrl + Alt + Delete`. Esto es especialmente útil si esa pantalla externa es un proyector y quieres mostrar algo mientras trabajas.

Cuando estás extendiendo, cerrar la tapa del portátil apagará automáticamente la pantalla interna. Abrir la tapa la volverá a encender. También puedes controlar esto manualmente usando _Activar > Hardware_ en el menú de Omarchy o `Super + Ctrl + Delete`.

### Organizar varias pantallas

Hyprland funciona muy bien con varias pantallas. El panel de monitores en la barra superior las dibuja donde están ubicadas: arrastra una contra el lado de otra para moverla ahí, y la disposición se guarda junto con los demás ajustes de cada monitor. Para cualquier cosa que el panel no cubra, lee más sobre cómo organizarlas en [la documentación de monitores de Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). En Omarchy, estas van en `~/.config/hypr/monitors.lua` como entradas `hl.monitor`: el archivo incluye ejemplos comentados para mantener un monitor apagado, modos que el panel no ofrece, color de 10 bits y frecuencia de actualización variable.

Cada monitor tiene sus propios espacios de trabajo del 1 al 10, así que `Super + 1` siempre significa el primer espacio de trabajo del monitor en el que estás. Entre bambalinas, Hyprland sigue numerando los espacios de trabajo en todos los monitores: tu pantalla de portátil (o primer monitor) obtiene 1–10, el siguiente monitor 11–20, y así sucesivamente, y cada monitor mantiene su bloque cada vez que lo conectas. Usa esos números si escribes [reglas de espacios de trabajo](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) o reglas de ventanas para un monitor específico, así que el espacio de trabajo 12 es el segundo espacio de trabajo de tu segundo monitor. `~/.local/state/omarchy/monitors/workspaces` enumera qué bloque tiene cada monitor.

Las teclas de flecha funcionan entre monitores que comparten un borde en tu disposición. Las pantallas que solo se tocan en una esquina, o que tienen un espacio entre ellas, no son vecinas, así que usa `Ctrl + Alt + Tab` para pasar entre ellas.

| Atajo de teclado | Entre monitores |
| --- | --- |
| `Super + Arrow` | Mueve el foco al monitor de ese lado cuando ya no quede ninguna ventana en esa dirección |
| `Super + Shift + Arrow` | Intercambia con una ventana en el monitor de ese lado |
| `Super + Alt + Arrow` | Mueve la ventana a un grupo en el monitor de ese lado |
| `Super + Shift + Ctrl + Arrow` | Mueve la ventana al monitor de ese lado, al espacio de trabajo que está mostrando |
| `Super + Shift + Alt + Arrow` | Mueve el espacio de trabajo al monitor de ese lado, conservando su número si está libre |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Mueve el foco al monitor siguiente o anterior, sea cual sea la disposición |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Se quedan en el monitor en el que estás |

También puedes echarle un vistazo a [Hyprmon](https://github.com/erans/hyprmon/), si te apetece una TUI que te ayude con la posición de varias pantallas.

### Controlar el brillo

El brillo se controla con las teclas de función dedicadas a subirlo y bajarlo. Si mantienes pulsado Shift mientras pulsas estas teclas, irás al brillo máximo o mínimo. Las teclas controlan la pantalla en la que estás enfocado, así que los monitores externos que hablan DDC/CI se ajustan de la misma manera que la pantalla del portátil.

### Pantallas Apple

Si estás usando una pantalla Apple, las teclas normales de brillo del teclado también funcionarán automáticamente, si el foco está en la pantalla Apple. Esto se hace a través del comando `asdcontrol`.

Ten en cuenta que si estás usando una pantalla Apple 6K XDR, es posible que veas una pantalla fantasma en tu listado de `hyprctl monitors`. Puedes desactivar esto con algo como `hl.monitor({ output = "DP-2", disabled = true })` en `~/.config/hypr/monitors.lua`.

En máquinas Intel, conecta las pantallas Apple con un cable Thunderbolt normal. En otras máquinas sin Thunderbolt, normalmente tendrás que usar un [cable DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) para que funcione.
