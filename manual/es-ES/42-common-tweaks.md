# Ajustes comunes

Esta es una colección de adaptaciones comunes a la configuración de Omarchy. Ten en cuenta que ocasionalmente las actualizaciones del sistema pueden restaurar ciertas configuraciones a su estado original. Si esto sucede, tus cambios no se perderán, sino que quedarán en un archivo `.bak` en el mismo directorio.

Si arruinas algo, puedes restaurar cada configuración a su estado original desde _Actualizar > Configuración_ en el menú de Omarchy. Si arruinas _todo_ de verdad, puedes restablecer todas las configuraciones con `omarchy-reinstall`.

### Mostrar siempre todos los iconos de la bandeja

Por defecto, los iconos de la bandeja, como Dropbox, 1Password o Steam, están ocultos detrás de la flecha que despliega la bandeja, que los muestra cuando pasas el cursor sobre ella. Si quieres tenerlos siempre a la vista, haz clic derecho en la flecha expansora para abrir el administrador de iconos de la bandeja y luego fija los iconos que quieres mantener visibles (también puedes ocultar los que nunca quieres ver).

### Esquinas redondeadas en las ventanas

El diseño predeterminado de Omarchy es de esquinas rectas, pero si quieres suavizarlo un poco, puedes editar `~/.config/hypr/looknfeel.lua` para descomentar el redondeo:

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
