# Monitores

Omarchy asume que estás usando una pantalla clase retina con capacidad 2x de forma predeterminada. Esto es lo que necesitas para obtener esas fuentes de programador bonitas y nítidas. Es para lo que están optimizadas casi todas las laptops premium nuevas con pantallas de alta resolución. Es lo que querrías usar en un [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) de 27" 5K o un [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) de 32" 6K.

Pero si no estás usando una pantalla con un PPI de 218 o más, vas a querer cambiar los ajustes del monitor. Por ejemplo, si tienes un 4K de 27" o 32", puedes usar escalado fraccional abriendo `~/.config/hypr/monitors.lua` (mediante _Configurar > Monitores_ en el menú de Omarchy) y cambiándolo a la recomendación para esa combinación:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Si estás usando una pantalla de 1080p o 1440p, probablemente solo quieras usar escalado 1x, así que puedes usar:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Los cambios en `GDK_SCALE` se aplican a las aplicaciones iniciadas después del cambio (y GTK solo acepta números enteros, así que mantenlo en el entero más cercano de tu escala de monitor). Así que asegúrate de cerrar las ventanas que tengas que queden sobredimensionadas después del cambio (¡o cierra todas las ventanas con `Ctrl + Alt + Del`!).

También puedes recorrer rápidamente las principales proporciones de escalado de monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) usando `Super + /` para subir y `Super + Alt + /` para bajar. Si tienes la configuración predeterminada, estos cambios también persistirán tras reiniciar.

### Hacer el texto más grande o más pequeño

El escalado de monitor cambia el tamaño de todo. Si todo lo que quieres es _texto_ más grande o más pequeño, hay un solo control para eso:

```
omarchy display text size 14
```

Eso toma un tamaño en píxeles entre 9 y 20, y mueve juntos el shell de Omarchy, las aplicaciones GTK y tu terminal, así que todo el escritorio se mantiene en proporción. Ejecútalo sin argumento para ver dónde estás, y `omarchy display text size reset` para volver al valor predeterminado. Foot es el único rezagado: no tiene forma de recargar su configuración, así que las terminales en ejecución conservan su tamaño anterior hasta que abras una nueva.

### Extender y duplicar pantallas de laptop

Cuando conectas una pantalla externa a tu laptop, la pantalla se extiende automáticamente. Pero puedes cambiar eso a duplicación usando _Activar > Hardware_ en el menú de Omarchy o `Super + Ctrl + Alt + Delete`. Esto es especialmente útil si esa pantalla externa es un proyector, y quieres mostrar algo mientras trabajas.

Cuando estás extendiendo, cerrar la tapa de la laptop apagará automáticamente la pantalla interna. Abrir la tapa la volverá a encender. También puedes controlar esto manualmente usando _Activar > Hardware_ en el menú de Omarchy o `Super + Ctrl + Delete`.

### Organizar varias pantallas

Hyprland funciona genial con varias pantallas. Lee más sobre cómo distribuirlas en [la documentación de monitores de Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). También puedes [vincular espacios de trabajo específicos a monitores específicos](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). En Omarchy, estas reglas van en `~/.config/hypr/monitors.lua` como entradas `hl.monitor`: el archivo viene con ejemplos comentados para fijar un monitor específico a una resolución, posición y rotación.

También puedes revisar [Hyprmon](https://github.com/erans/hyprmon/), si quieres una TUI que te ayude con la posición de varias pantallas.

### Controlar el brillo

El brillo del monitor lo controlan las teclas de función dedicadas para subir/bajar el brillo. Si mantienes presionado shift mientras las presionas, irás al brillo máximo o mínimo. Las teclas controlan la pantalla en la que estás enfocado, así que los monitores externos que hablan DDC/CI se ajustan de la misma forma que la pantalla de la laptop.

### Pantallas de Apple

Si estás usando una pantalla de Apple, las teclas normales de brillo del teclado también funcionarán automáticamente, si estás enfocado en la pantalla de Apple. Esto se hace mediante el comando `asdcontrol`.

Ten en cuenta que si estás usando una pantalla Apple 6K XDR, puedes ver una pantalla fantasma en tu listado de `hyprctl monitors`. Puedes apagarla con algo como `hl.monitor({ output = "DP-2", disabled = true })` mediante _Configurar > Monitores_.

En computadoras Intel, deberías conectarte a las pantallas de Apple usando un cable Thunderbolt normal. En otras computadoras sin Thunderbolt, por lo general tendrás que usar un [cable DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) para que funcione.
