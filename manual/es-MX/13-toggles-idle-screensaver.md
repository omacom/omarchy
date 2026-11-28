# Interruptores, inactividad y el protector de pantalla

Mucho de lo que cambias a diario no es realmente una configuración. Es un modo que activas durante una hora y luego desactivas: luz nocturna mientras trabajas hasta tarde, no molestar mientras presentas, mantener despierto mientras ves algo. Omarchy los llama interruptores, y todos funcionan igual: una tecla de acceso rápido, una entrada de menú y un comando, todos accionando el mismo interruptor.

### El menú de interruptores

`Super + Ctrl + O` abre _Trigger > Toggle_ directamente, o puedes llegar ahí desde el menú de Omarchy (`Super + Space`). Todo lo que aparece en esa lista es un interruptor que puedes accionar sin pensar en dónde vive el estado. Los interruptores sobre cómo se ve el escritorio están junto a él, bajo _Appearance_.

Desde la terminal, los mismos interruptores son `omarchy toggle <thing>`. Ejecuta `omarchy toggle` por sí solo para ver todo el grupo.

| Interruptor | Tecla de acceso rápido | Comando |
| ------ | ------ | ------- |
| Luz nocturna | — | `omarchy toggle nightlight` |
| Silenciar notificaciones | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Mantener despierto (sin bloqueo por inactividad) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura de fallos | — | `omarchy toggle crash-capture` |
| Protector de pantalla | — | `omarchy toggle screensaver` |
| Sincronización de tema de [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra de menú | `Super + Shift + Space` | `omarchy toggle bar` |
| Escritorio a pantalla completa (sin barra, sin espacios) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animaciones, desenfoque y sombras | — | `omarchy toggle animations` |
| Panel táctil | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Pantalla táctil | — | `omarchy device touchscreen` |
| Suspender | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy device gpu hybrid` |

Los interruptores del panel táctil, la pantalla táctil y la GPU híbrida viven bajo _Trigger > Hardware_ (`Super + Ctrl + H`) y no bajo Toggle, ya que solo aparecen cuando realmente tienes ese hardware. Los del panel táctil y la pantalla táctil sobreviven a una recarga de Hyprland: el nombre del dispositivo desactivado se guarda en un pequeño archivo de estado que Hyprland lee al inicio para desactivarlo de nuevo.

_Appearance_ contiene la barra de menú y las animaciones, además de algunas cosas que no son comandos de `omarchy toggle` pero se comportan igual: el porcentaje de batería en la barra, la disposición predeterminada de los espacios de trabajo y, bajo _Windows_, los espacios entre ventanas (`Super + Shift + Backspace`) y la proporción cuadrada de 1 ventana (`Super + Ctrl + Backspace`).

Cuando Hyprland no tiene ninguna GPU con la que dibujar y renderiza con la CPU en su lugar (llvmpipe), como en las Mac cuya GPU aún no es compatible, en la mayoría de las máquinas virtuales o cuando un controlador de gráficos no se carga, Omarchy desactiva las animaciones, el desenfoque y las sombras durante esa sesión y te lo avisa una vez con una notificación. _Appearance > Animations On_ los vuelve a activar, y Omarchy también lo recuerda para sesiones posteriores.

La mayoría de estos son solo un archivo de marca bajo `~/.local/state/omarchy/toggles/`. Si quieres ramificar según uno en un script, `omarchy-toggle-enabled` te da un código de salida en lugar de obligarte a ir a buscarlo:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Las marcas se nombran por el estado desactivado — `screensaver-off`, `suspend-off`, `bar-off` —, así que su presencia significa que la función está desactivada.

### Indicadores en la barra

Cuando un modo está activo, obtienes un pequeño glifo en el centro de la barra superior, junto al reloj. Ese es el widget de indicadores, y reúne grabación de pantalla, recordatorios pendientes, luz nocturna, no molestar y mantener despierto, además de advertencias mientras sudo sin contraseña está activo o alguien está conectado a una sesión remota.

Los indicadores inactivos están ocultos. Pasa el cursor sobre cualquier parte de la barra y aparecerán atenuados, para que puedas hacer clic en uno y activarlo sin conocer su tecla de acceso rápido. Hacer clic en uno activo lo vuelve a desactivar. Si prefieres verlos todos todo el tiempo, establece `alwaysShow` en `true` en la entrada `omarchy.indicators` de `~/.config/omarchy/shell.json`: consulta [la barra superior](05-the-top-bar.md) para ver cómo se configuran los widgets de la barra.

### Luz nocturna

La luz nocturna calienta la pantalla a 4000K, y al desactivarla vuelve a 6500K. Actívala desde el menú de interruptores (`Super + Ctrl + O`) o con `omarchy toggle nightlight`. La controla hyprsunset, que el interruptor inicia por ti si aún no está en ejecución.

Por defecto, hyprsunset no le hace absolutamente nada a tu pantalla. `~/.config/hypr/hyprsunset.conf` viene con un perfil de identidad precisamente para que la pantalla permanezca intacta hasta que pidas calidez. Si prefieres que cambie según el reloj, reemplázalo con un perfil por hora:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Luego inicia hyprsunset al iniciar sesión agregando `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. El par 4000K/6500K que usa el interruptor es fijo, así que el archivo de configuración es a donde vas si quieres una temperatura diferente.

### No molestar

`Super + Ctrl + Alt + ,` silencia las notificaciones. No aparece ninguna notificación emergente mientras está activo, y el indicador de la campana tachada permanece en la barra para recordarte por qué el escritorio se quedó en silencio.

Pero no se pierde nada. Las notificaciones silenciadas se retienen: vuelve a poner las últimas en pantalla con `Super + Shift + Alt + ,`. Consulta [avisos](10-notices.md) para el resto.

Tres tipos de mensajes sí logran pasar: las notificaciones emergentes de confirmación propias de Omarchy por algo que acabas de hacer ("Theme changed", "Screenshot saved"), las alertas críticas enviadas desde la línea de comandos y los códigos de verificación. Las aplicaciones de chat que marcan todo como crítico para obligarte a verlas no califican.

### Inactividad

El shell de Omarchy es dueño del comportamiento por inactividad, y los tiempos son un bloque `idle` de nivel superior en `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ambos números son segundos contados desde el momento en que entraste en inactividad, no uno desde el otro. Así que, con los valores predeterminados, el protector de pantalla aparece después de dos minutos y medio y la pantalla de bloqueo toma el control a los cinco minutos, haya funcionado o no el protector de pantalla. Guarda el archivo y el shell adopta los nuevos tiempos de inmediato.

Si descartas el protector de pantalla antes del plazo de bloqueo, eso cuenta como actividad y el bloqueo pendiente se cancela. No te quedas bloqueado por echar un vistazo a tu máquina.

Para dejar de bloquear por inactividad por completo, `Super + Ctrl + I` —o `omarchy toggle idle`— activa mantener despierto, y el indicador de la taza de café aparece en la barra. Ese es el que debes accionar antes de una presentación larga o una compilación que quieres vigilar. Acciónalo de nuevo para volver a la normalidad. `omarchy toggle idle status` imprime el estado actual como JSON si lo necesitas desde un script.

Esto trata del bloqueo y el protector de pantalla, no de la energía. La suspensión y la hibernación tienen su propia configuración en [suspensión del sistema](36-system-sleep.md).

### El protector de pantalla

El protector de pantalla de Omarchy es arte ASCII que pasa por efectos de texto aleatorios, una instancia por monitor. Cualquier tecla o movimiento del mouse lo cierra.

Puedes iniciarlo bajo demanda desde _System > Screensaver_ (`Super + Esc`), lo que lo fuerza a aparecer incluso si desactivaste el protector de pantalla por inactividad. Por defecto no tiene ninguna tecla de acceso rápido asignada.

`omarchy toggle screensaver` es lo que desactiva el de inactividad, si prefieres ir directo de trabajar a bloqueado. Cualquier tecla, clic, desplazamiento o movimiento del mouse lo cierra.

El logo que dibuja es tuyo para cambiarlo, bajo _Appearance > Branding > Screensaver_. Sube un png o svg y Omarchy lo convierte a ASCII. Consulta [marca](41-branding.md).

### La pantalla de bloqueo

`Super + Ctrl + L` bloquea la máquina. Eso ejecuta la pantalla de bloqueo del shell de Omarchy, apaga la pantalla, restablece la disposición de tu teclado a la primera para que no escribas tu contraseña en el alfabeto equivocado y, si lo tienes en ejecución, bloquea 1Password al salir.

La pantalla de bloqueo acepta una contraseña, y también aceptará una huella digital una vez que hayas configurado una. Eso, y las demás formas de autenticarte, se cubren en [autenticación por hardware](37-hardware-authentication.md).
