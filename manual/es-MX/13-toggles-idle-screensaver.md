# Interruptores, inactividad y el protector de pantalla

Mucho de lo que cambias en el día a día no es realmente un ajuste. Es un modo que activas por una hora y luego vuelves a desactivar: luz nocturna mientras trabajas hasta tarde, no molestar mientras haces una presentación, mantener despierto mientras ves algo. Omarchy los llama interruptores, y todos funcionan igual: un atajo de teclado, una entrada de menú y un comando, todos sobre el mismo interruptor.

### El menú de interruptores

`Super + Ctrl + O` abre directamente _Activación > Interruptores_, o puedes llegar ahí desde el menú de Omarchy (`Super + Space`). Todo lo que aparece en esa lista es un interruptor que puedes cambiar sin pensar en dónde vive el estado. Los interruptores de cómo se ve el escritorio están junto a ese menú, en _Apariencia_.

Desde la terminal, los mismos interruptores son `omarchy toggle <thing>`. Ejecuta `omarchy toggle` por sí solo para ver todo el grupo.

| Interruptor | Atajo | Comando |
| ------ | ------ | ------- |
| Luz nocturna | — | `omarchy toggle nightlight` |
| Silenciar notificaciones | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Mantener despierto (sin bloqueo por inactividad) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura de fallos | — | `omarchy toggle crash-capture` |
| Protector de pantalla | — | `omarchy toggle screensaver` |
| Sincronización de tema de [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra de menú | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Pantalla táctil | — | `omarchy toggle touchscreen` |
| Suspensión | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy toggle hybrid gpu` |

Los interruptores del touchpad, la pantalla táctil y la GPU híbrida viven en _Activación > Hardware_ (`Super + Ctrl + H`) y no en Interruptores, ya que solo aparecen cuando realmente tienes ese hardware. Los del touchpad y la pantalla táctil sobreviven a una recarga de Hyprland: el nombre del dispositivo desactivado se guarda en un pequeño archivo de estado que Hyprland lee al iniciar para volver a desactivarlo.

_Apariencia_ contiene la barra de menú y las animaciones, además de algunas cosas que no son comandos `omarchy toggle` pero se comportan igual: el porcentaje de batería en la barra, la disposición predeterminada del espacio de trabajo y, en _Ventanas_, los espacios entre ventanas (`Super + Shift + Backspace`) y la proporción cuadrada de 1 ventana (`Super + Ctrl + Backspace`).

La mayoría son solo un archivo de marca en `~/.local/state/omarchy/toggles/`. Si quieres condicionar un script según uno de ellos, `omarchy-toggle-enabled` te da un código de salida en lugar de obligarte a buscarlo:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Las marcas llevan el nombre del estado desactivado — `screensaver-off`, `suspend-off`, `bar-off` —, así que su presencia significa que la función está desactivada.

### Indicadores en la barra

Cuando un modo está activo, aparece un pequeño glifo en el centro de la barra superior, junto al reloj. Ese es el widget de indicadores, e incluye dictado, grabación de pantalla, recordatorios pendientes, luz nocturna, no molestar y mantener despierto.

Los indicadores inactivos están ocultos. Pasa el cursor sobre cualquier parte de la barra y aparecen atenuados, para que puedas hacer clic en uno y activarlo sin saber su atajo de teclado. Al hacer clic en uno activo, se vuelve a desactivar. Si prefieres verlos todos siempre, pon `alwaysShow` en `true` en la entrada `omarchy.indicators` de `~/.config/omarchy/shell.json` — consulta [la barra superior](05-the-top-bar.md) para ver cómo se configuran los widgets de la barra.

### Luz nocturna

La luz nocturna calienta la pantalla a 4000K, y al desactivarla vuelve a 6500K. Actívala desde el menú de interruptores (`Super + Ctrl + O`) o con `omarchy toggle nightlight`. La controla hyprsunset, que el interruptor inicia por ti si todavía no está en ejecución.

De forma predeterminada, hyprsunset no le hace nada a tu pantalla. `~/.config/hypr/hyprsunset.conf` viene con un perfil de identidad precisamente para que la pantalla quede intacta hasta que pidas calidez. Si prefieres que cambie según la hora, reemplázalo con un perfil por horario:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Después inicia hyprsunset al iniciar sesión agregando `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. El par 4000K/6500K que usa el interruptor es fijo, así que el archivo de configuración es a donde vas si quieres otra temperatura.

### No molestar

`Super + Ctrl + Alt + ,` silencia las notificaciones. Mientras está activo no aparecen notificaciones emergentes, y el indicador de la campana tachada se queda en la barra para recordarte por qué el escritorio se quedó callado.

Pero nada se pierde. Las notificaciones silenciadas se quedan retenidas: vuelve a poner las últimas en pantalla con `Super + Shift + Alt + ,`. Consulta [avisos](10-notices.md) para ver el resto.

Dos tipos de mensajes sí logran pasar: las notificaciones de confirmación propias de Omarchy para algo que acabas de hacer («Tema cambiado», «Captura de pantalla guardada») y las alertas críticas enviadas desde la línea de comandos. Las apps de chat que marcan todo como crítico para abrirse paso frente a ti no cuentan.

### Inactividad

El shell de Omarchy controla el comportamiento en inactividad, y los tiempos están en un bloque `idle` de nivel superior en `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ambos números son segundos contados desde el momento en que entraste en inactividad, no uno desde el otro. Así que, con los valores predeterminados, el protector de pantalla aparece después de dos minutos y medio y la pantalla de bloqueo toma el control a los cinco minutos, haya aparecido o no el protector de pantalla. Guarda el archivo y el shell adopta los nuevos tiempos de inmediato.

Si cierras el protector de pantalla antes del plazo de bloqueo, eso cuenta como actividad y el bloqueo pendiente se cancela. No te quedas fuera por echarle un vistazo a tu equipo.

Para dejar de bloquear por inactividad por completo, `Super + Ctrl + I` —o `omarchy toggle idle`— activa mantener despierto, y el indicador de la taza de café aparece en la barra. Es el que debes activar antes de una presentación larga o de una compilación que quieres vigilar. Actívalo otra vez para volver a la normalidad. `omarchy toggle idle status` imprime el estado actual como JSON si lo necesitas desde un script.

Esto trata del bloqueo y el protector de pantalla, no de la energía. La suspensión y la hibernación tienen su propia configuración en [suspensión del sistema](36-system-sleep.md).

### El protector de pantalla

El protector de pantalla de Omarchy es arte ASCII que pasa por efectos de texto aleatorios, una instancia por monitor. Cualquier tecla o movimiento del mouse lo cierra.

Puedes iniciarlo cuando quieras desde _Sistema > Protector de pantalla_ (`Super + Esc`), lo que lo obliga a aparecer incluso si desactivaste el protector de pantalla por inactividad. Por defecto no tiene ningún atajo de teclado asignado.

`omarchy toggle screensaver` es lo que desactiva el de inactividad, si prefieres pasar directo de trabajar a bloqueado. Cualquier tecla, clic, desplazamiento o movimiento del mouse lo cierra.

El logotipo que dibuja puedes cambiarlo tú, en _Apariencia > Marca > Protector de pantalla_. Sube un png o svg y Omarchy lo convierte a ASCII. Consulta [imagen de marca](41-branding.md).

### La pantalla de bloqueo

`Super + Ctrl + L` bloquea el equipo. Eso ejecuta la pantalla de bloqueo del shell de Omarchy, deja la pantalla en negro, restablece la distribución de teclado a la primera para que no escribas tu contraseña en el alfabeto equivocado y, si lo tienes en ejecución, bloquea 1Password al salir.

La pantalla de bloqueo acepta una contraseña, y también aceptará una huella digital una vez que hayas configurado una. Eso, y las demás formas de autenticarte, se explican en [autenticación por hardware](37-hardware-authentication.md).
