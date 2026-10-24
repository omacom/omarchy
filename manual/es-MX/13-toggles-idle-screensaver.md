# Alternancias, inactividad y el protector de pantalla

Mucho de lo que cambias día a día en realidad no es un ajuste. Es un modo que activas por una hora y desactivas otra vez: luz nocturna mientras trabajas hasta tarde, no molestar mientras presentas, mantenerse despierta mientras ves algo. Omarchy los llama alternancias (toggles), y todos funcionan igual — un atajo, una entrada de menú y un comando, todos accionando el mismo interruptor.

### El menú de alternancias

`Super + Ctrl + O` abre _Activar > Alternar_ directamente, o puedes caminar hasta ahí desde el menú de Omarchy (`Super + Space`). Todo en esa lista es un interruptor que puedes accionar sin pensar en dónde vive el estado. Los interruptores de cómo se ve el escritorio están junto a él, en _Activar > Apariencia_.

Desde la terminal, los mismos interruptores son `omarchy toggle <thing>`. Ejecuta `omarchy toggle` por sí solo para ver todo el grupo.

| Alternancia | Atajo | Comando |
| ------ | ------ | ------- |
| Luz nocturna | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Silenciar notificaciones | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Mantenerse despierta (sin bloqueo por inactividad) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura de fallos | — | `omarchy toggle crash-capture` |
| Protector de pantalla | — | `omarchy toggle screensaver` |
| Sincronizar tema de [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra de menú | `Super + Shift + Space` | `omarchy toggle bar` |
| Panel táctil | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Pantalla táctil | — | `omarchy toggle touchscreen` |
| Suspender | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy toggle hybrid gpu` |

Los interruptores de panel táctil, pantalla táctil y GPU híbrida viven en _Activar > Hardware_ (`Super + Ctrl + H`) en lugar de en Alternar, ya que solo aparecen cuando de verdad tienes ese hardware. Los de panel táctil y pantalla táctil sobreviven a una recarga de Hyprland — el nombre del dispositivo desactivado se guarda en un archivo de estado pequeño que Hyprland lee al iniciar para desactivarlo de nuevo.

_Activar > Apariencia_ contiene la barra de menú y las animaciones, además de algunas cosas que no son comandos `omarchy toggle` pero se comportan igual: el porcentaje de batería en la barra, la distribución predeterminada de espacios de trabajo, los espacios entre ventanas (`Super + Shift + Backspace`) y la proporción cuadrada de 1 ventana (`Super + Ctrl + Backspace`).

La mayoría de estos son simplemente un archivo de marca bajo `~/.local/state/omarchy/toggles/`. Si quieres ramificar según uno en un script, `omarchy-toggle-enabled` te da un código de salida en lugar de hacerte ir a buscar:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Las marcas se nombran según el estado desactivado — `screensaver-off`, `suspend-off`, `bar-off` — así que su presencia significa que la función está desactivada.

### Indicadores en la barra

Cuando un modo está activo, obtienes un glifo pequeño en el centro de la barra superior junto al reloj. Ese es el widget de indicadores, y lleva el dictado, la grabación de pantalla, los recordatorios pendientes, la luz nocturna, no molestar y mantenerse despierta.

Los indicadores inactivos están ocultos. Pasa el cursor por el área a su alrededor y aparecen atenuados, para que puedas hacer clic en uno para activarlo sin saber su atajo. Al hacer clic en uno activo se desactiva. Si prefieres verlos todos siempre, pon `alwaysShow` en `true` en la entrada `omarchy.indicators` de `~/.config/omarchy/shell.json` — consulta [la barra superior](05-the-top-bar.md) para saber cómo se configuran los widgets de la barra.

### Luz nocturna

`Super + Ctrl + N` calienta la pantalla a 4000K, y presionarlo otra vez la regresa a 6500K. Lo maneja hyprsunset, que la alternancia inicia por ti si no está corriendo ya.

Por defecto, hyprsunset no le hace nada a tu pantalla. `~/.config/hypr/hyprsunset.conf` viene con un perfil identidad precisamente para que la pantalla quede intacta hasta que pidas calidez. Si prefieres que cambie según el reloj, reemplaza eso con un perfil por hora:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Luego inicia hyprsunset al iniciar sesión agregando `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. El par 4000K/6500K que usa la alternancia es fijo, así que el archivo de configuración es a donde vas si quieres una temperatura distinta.

### No molestar

`Super + Ctrl + ,` silencia las notificaciones. No aparecen avisos emergentes mientras está activo, y el indicador de la campana tachada se queda en la barra para recordarte por qué el escritorio se quedó en silencio.

Pero no se pierde nada. Una notificación silenciada se escribe directo en tu historial de notificaciones, que es justo el registro que quieres cuando regresas y te preguntas qué te perdiste. Ábrelo con `Super + Shift + Alt + ,`. Consulta [avisos](10-notices.md) para el resto de la historia de las notificaciones.

Dos tipos de mensajes sí pasan: los avisos de confirmación propios de Omarchy para algo que acabas de hacer ("Theme changed", "Screenshot saved"), y las alertas críticas enviadas desde la línea de comandos. Las apps de chat que marcan todo como crítico para plantarse frente a ti no califican.

### Inactividad

El shell de Omarchy es dueño del comportamiento de inactividad, y los tiempos están en un bloque `idle` de nivel superior en `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ambos números son segundos contados desde el momento en que entraste en inactividad — no uno desde el otro. Así, con los valores predeterminados, el protector de pantalla aparece después de dos minutos y medio y la pantalla de bloqueo toma el control a los cinco minutos, haya corrido el protector o no. Guarda el archivo y el shell toma los tiempos nuevos de inmediato.

Si cierras el protector de pantalla antes del límite de bloqueo, eso cuenta como actividad y el bloqueo pendiente se cancela. No te quedas bloqueado por echarle un vistazo a tu máquina.

Para dejar de bloquear por inactividad por completo, `Super + Ctrl + I` — o `omarchy toggle idle` — activa mantenerse despierta, y aparece el indicador de la taza de café en la barra. Ese es el que presionas antes de una presentación larga o una compilación que quieres vigilar. Presiónalo otra vez para volver a la normalidad. `omarchy toggle idle status` imprime el estado actual como JSON si lo necesitas desde un script.

Esto trata del bloqueo y el protector de pantalla, no de la energía. Suspender e hibernar tienen su propia configuración en [suspensión del sistema](36-system-sleep.md).

### El protector de pantalla

El protector de pantalla de Omarchy es arte ASCII corriendo con efectos de texto aleatorios, una instancia por monitor. Cualquier tecla o movimiento del ratón sale de él.

Puedes iniciarlo a pedido desde _Sistema > Protector de pantalla_ (`Super + Esc`), lo cual lo fuerza aunque hayas desactivado el protector por inactividad. No hay un atajo asignado por defecto.

`omarchy toggle screensaver` es lo que desactiva el de inactividad, si prefieres ir directo de trabajar a bloqueado. Necesita una terminal que sepa configurar — Alacritty, Foot, Ghostty o Kitty — y te lo dirá si tu terminal predeterminada es otra cosa.

El logo que dibuja lo puedes cambiar, en _Estilo > Protector de pantalla_. Sube un png o svg y Omarchy lo convierte a ASCII. Consulta [branding](41-branding.md).

### La pantalla de bloqueo

`Super + Ctrl + L` bloquea la máquina. Eso ejecuta la pantalla de bloqueo del shell de Omarchy, apaga la pantalla, restablece tu distribución de teclado a la primera para que no escribas tu contraseña en el alfabeto equivocado y — si lo tienes corriendo — bloquea 1Password al salir.

La pantalla de bloqueo acepta una contraseña, y también aceptará una huella digital una vez que hayas configurado una. Eso, y las demás formas de autenticarse, se tratan en [autenticación por hardware](37-hardware-authentication.md).
