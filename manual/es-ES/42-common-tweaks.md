# Ajustes comunes

Esta es una colección de ajustes comunes para la configuración de Omarchy. Ten en cuenta que ocasionalmente puede ser necesario que las actualizaciones del sistema restauren ciertas configuraciones a su estado original. Si esto sucede, tus cambios no se perderán, sino que se guardarán en un archivo `.bak.<timestamp>` junto al original.

Si echas algo a perder, puedes restaurar configuraciones individuales a su configuración original mediante _Actualizar > Configuración_ en el menú de Omarchy. Si _de verdad_ echas todo a perder, puedes restablecer todas las configuraciones con `omarchy reinstall configs`, o reinstalar cada paquete y configuración predeterminados con `omarchy reinstall`.

### Mostrar siempre todos los iconos de la bandeja

Por defecto, los iconos de la bandeja, como Dropbox, 1Password o Steam, están ocultos detrás de la flecha que despliega la bandeja, que los muestra cuando pasas el cursor sobre ella. Si quieres tenerlos siempre a la vista, haz clic derecho en la flecha expansora para abrir el administrador de iconos de la bandeja y luego fija los iconos que quieres mantener visibles (también puedes ocultar los que nunca quieres ver).

### Esquinas redondeadas en las ventanas

El diseño predeterminado de Omarchy es de esquinas cuadradas, pero si quieres suavizarlo un poco, elige _Apariencia > Ventanas > Esquinas de ventana > Esquinas redondas_ en el menú de Omarchy, o ejecuta `omarchy hyprland corners rounded`. _Esquinas del tema_ vuelve a lo que usa el tema. Para elegir tu propio radio, mantente en _Esquinas del tema_ (`omarchy hyprland corners theme`), ya que las esquinas redondas y rectas se cargan después de tu configuración y la sobrescriben, y descomenta rounding en `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Eliminar los espacios entre ventanas

En las pantallas de portátil, algunas personas prefieren no desperdiciar ningún píxel en espacios entre ventanas (o incluso en una barra superior, que puedes desactivar con `Super + Shift + Space`). Puedes desactivar todos los espacios y bordes con `Super + Shift + Backspace`, o eliminarlos permanentemente descomentando esta sección de `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
