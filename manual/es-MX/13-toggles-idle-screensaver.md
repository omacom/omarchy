# Interruptores, inactividad y el protector de pantalla

Mucho de lo que cambias día a día no es realmente un ajuste. Es un modo que activas por una hora y luego desactivas: luz nocturna mientras trabajas hasta tarde, no molestar mientras haces una presentación, mantener despierto el equipo mientras ves algo. Omarchy los llama interruptores, y todos funcionan igual: una tecla de acceso rápido, una entrada de menú y un comando, todos apuntando al mismo interruptor.

### El menú de interruptores

`Super + Ctrl + O` abre _Activador > Interruptores_ directamente, o puedes llegar ahí desde el menú de Omarchy (`Super + Space`). Todo lo que hay en esa lista es un interruptor que puedes activar sin pensar dónde vive el estado. Los interruptores de cómo se ve el escritorio están junto a eso, en _Apariencia_.

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
| Panel táctil | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Pantalla táctil | — | `omarchy toggle touchscreen` |
| Suspender | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy toggle hybrid gpu` |

Los interruptores del panel táctil, la pantalla táctil y la GPU híbrida están en _Activador > Hardware_ (`Super + Ctrl + H`) en lugar de en Interruptores, ya que solo aparecen cuando realmente tienes ese hardware. Los del panel táctil y la pantalla táctil sobreviven a una recarga de Hyprland: el nombre del dispositivo desactivado se guarda en un pequeño archivo de estado que Hyprland lee al inicio para desactivarlo de nuevo.

_Apariencia_ contiene la barra de menú y las animaciones, además de algunas cosas que no son comandos `omarchy toggle` pero se comportan igual: el porcentaje de batería en la barra, la distribución predeterminada del espacio de trabajo y, en _Ventanas_, los espacios entre ventanas (`Super + Shift + Backspace`) y el aspecto cuadrado de 1 ventana (`Super + Ctrl + Backspace`).

La mayoría de estos son solo un archivo de bandera en `~/.local/state/omarchy/toggles/`. Si quieres condicionar un script según uno de ellos, `omarchy-toggle-enabled` te da un código de salida en lugar de obligarte a ir a buscarlo:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Las banderas se llaman según el estado desactivado —`screensaver-off`, `suspend-off`, `bar-off`—, así que su presencia significa que la función está desactivada.

### Indicadores en la barra

Cuando un modo está activo, aparece un pequeño glifo en el centro de la barra superior junto al reloj. Ese es el widget de indicadores, y contiene dictado, grabación de pantalla, recordatorios pendientes, luz nocturna, no molestar y mantener despierto.

Los indicadores inactivos están ocultos. Pasa el cursor sobre cualquier parte de la barra y aparecen atenuados, para que puedas hacer clic en uno para activarlo sin conocer su tecla de acceso rápido. Hacer clic en uno activo lo desactiva. Si prefieres verlos todos todo el tiempo, establece `alwaysShow` en `true` en la entrada `omarchy.indicators` de `~/.config/omarchy/shell.json`: consulta [la barra superior](05-the-top-bar.md) para ver cómo se configuran los widgets de la barra.

### Luz nocturna

La luz nocturna calienta la pantalla a 4000K, y al activarla de nuevo vuelve a 6500K. Actívala desde el menú de interruptores (`Super + Ctrl + O`) o con `omarchy toggle nightlight`. Lo controla hyprsunset, que el interruptor inicia por ti si aún no está en ejecución.

De forma predeterminada, hyprsunset no le hace nada a tu pantalla. `~/.config/hypr/hyprsunset.conf` viene con un perfil de identidad precisamente para que la pantalla permanezca intacta hasta que pidas calidez. Si prefieres que cambie según la hora, reemplázalo con un perfil por hora:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Luego inicia hyprsunset al iniciar sesión agregando `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. El par 4000K/6500K que usa el interruptor es fijo, así que el archivo de configuración es donde debes ir si quieres una temperatura distinta.

### No molestar

`Super + Ctrl + Alt + ,` silencia las notificaciones. No aparecen notificaciones emergentes mientras está activo, y el indicador de la campana tachada se queda en la barra para recordarte por qué el escritorio se quedó en silencio.

Pero no se pierde nada. Las notificaciones silenciadas se retienen: vuelve a poner las últimas en pantalla con `Super + Shift + Alt + ,`. Consulta [avisos](10-notices.md) para el resto.

Dos tipos de mensajes sí logran pasar: las notificaciones de confirmación propias de Omarchy para algo que acabas de hacer ("Tema cambiado", "Captura de pantalla guardada") y las alertas críticas enviadas desde la línea de comandos. Las apps de chat que marcan todo como crítico para obligarte a ponerles atención no cuentan.

### Inactividad

El shell de Omarchy se encarga del comportamiento por inactividad, y los tiempos son un bloque `idle` de nivel superior en `~/.config/omarchy/shell.json`:

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

Si descartas el protector de pantalla antes del plazo de bloqueo, eso cuenta como actividad y el bloqueo pendiente se cancela. No te quedas bloqueado por echarle un vistazo a tu equipo.

Para dejar de bloquear por inactividad por completo, `Super + Ctrl + I` —o `omarchy toggle idle`— activa mantener despierto, y el indicador de la taza de café aparece en la barra. Ese es el que debes activar antes de una presentación larga o de una compilación que quieres observar. Actívalo de nuevo para volver a la normalidad. `omarchy toggle idle status` imprime el estado actual como JSON si lo necesitas desde un script.

Esto tiene que ver con el bloqueo y el protector de pantalla, no con la energía. La suspensión y la hibernación tienen su propia configuración en [reposo del sistema](36-system-sleep.md).

### El protector de pantalla

El protector de pantalla de Omarchy es arte ASCII que pasa por efectos de texto aleatorios, una instancia por monitor. Cualquier tecla o movimiento del mouse lo cierra.

Puedes iniciarlo bajo demanda desde _Sistema > Protector de pantalla_ (`Super + Esc`), que lo fuerza a aparecer incluso si desactivaste el protector de pantalla por inactividad. No tiene una tecla de acceso rápido asignada de forma predeterminada.

`omarchy toggle screensaver` es lo que desactiva el de inactividad, si prefieres ir directo del trabajo al bloqueo. Necesita una terminal que sepa cómo configurar —Alacritty, Foot, Ghostty o Kitty— y te lo dirá si tu terminal predeterminada es otra.

El logotipo que dibuja puedes cambiarlo tú, en _Apariencia > Imagen de marca > Protector de pantalla_. Sube un png o svg y Omarchy lo convierte a ASCII. Consulta [imagen de marca](41-branding.md).

### La pantalla de bloqueo

`Super + Ctrl + L` bloquea el equipo. Eso ejecuta la pantalla de bloqueo del shell de Omarchy, apaga la pantalla, restablece la distribución de tu teclado a la primera para que no escribas tu contraseña en el alfabeto equivocado y, si lo tienes en ejecución, bloquea 1Password al salir.

La pantalla de bloqueo acepta una contraseña, y también aceptará una huella digital una vez que hayas configurado una. Eso, y las demás formas de autenticarte, se explican en [autenticación por hardware](37-hardware-authentication.md).
