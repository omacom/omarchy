# Interruptores, inactividad y el salvapantallas

Gran parte de lo que cambias en el día a día no es realmente una configuración. Es un modo que activas por una hora y luego desactivas: luz nocturna mientras trabajas hasta tarde, no molestar mientras haces una presentación, mantener despierto mientras ves algo. Omarchy los llama interruptores, y todos funcionan igual: una tecla de acceso rápido, una entrada de menú y un comando, todos apuntando al mismo interruptor.

### El menú de interruptores

`Super + Ctrl + O` abre directamente _Activador > Interruptores_, o puedes llegar ahí desde el menú de Omarchy (`Super + Space`). Todo lo que hay en esa lista es un interruptor que puedes cambiar sin pensar dónde vive el estado. Los interruptores de cómo se ve el escritorio están junto a él, en _Apariencia_.

Desde la terminal, los mismos interruptores son `omarchy toggle <thing>`. Ejecuta `omarchy toggle` solo para ver todo el grupo.

| Interruptor | Atajo de teclado | Comando |
| ------ | ------ | ------- |
| Luz nocturna | — | `omarchy toggle nightlight` |
| Silenciar notificaciones | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Mantener despierto (sin bloqueo por inactividad) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura de fallos | — | `omarchy toggle crash-capture` |
| Salvapantallas | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) sincronización de tema | — | `omarchy toggle theme sync` |
| Barra de menú | `Super + Shift + Space` | `omarchy toggle bar` |
| Panel táctil | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Pantalla táctil | — | `omarchy device touchscreen` |
| Suspender | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy toggle hybrid gpu` |

Los interruptores del panel táctil, la pantalla táctil y la GPU híbrida viven en _Activador > Hardware_ (`Super + Ctrl + H`) y no en Interruptores, porque solo aparecen cuando de verdad tienes ese hardware. El del panel táctil y el de la pantalla táctil sobreviven a una recarga de Hyprland: el nombre del dispositivo desactivado se guarda en un pequeño archivo de estado que Hyprland lee al iniciar para desactivarlo de nuevo.

_Apariencia_ guarda la barra de menú y las animaciones, además de algunas cosas que no son comandos `omarchy toggle` pero se comportan igual: el porcentaje de batería en la barra, el diseño predeterminado del espacio de trabajo y, en _Ventanas_, los espacios entre ventanas (`Super + Shift + Backspace`) y el aspecto cuadrado de 1 ventana (`Super + Ctrl + Backspace`).

Cuando Hyprland no tiene una GPU con la que dibujar y renderiza con la CPU (llvmpipe), como en Macs cuya GPU aún no es compatible, en la mayoría de las máquinas virtuales o cuando un controlador gráfico no carga, Omarchy desactiva las animaciones, el desenfoque y las sombras durante esa sesión y te lo avisa una vez con una notificación. _Apariencia > Animaciones activadas_ los trae de vuelta, y Omarchy también lo recuerda para sesiones posteriores.

La mayoría de estos son solo un archivo de bandera en `~/.local/state/omarchy/toggles/`. Si quieres ramificar según uno en un script, `omarchy-toggle-enabled` te da un código de salida en lugar de obligarte a buscarlo:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Las banderas se nombran por el estado desactivado — `screensaver-off`, `suspend-off`, `bar-off` — así que su presencia significa que la función está desactivada.

### Indicadores en la barra

Cuando un modo está activo, obtienes un pequeño glifo en el centro de la barra superior junto al reloj. Ese es el widget de indicadores, y lleva dictado, grabación de pantalla, recordatorios pendientes, luz nocturna, no molestar y mantener despierto.

Los indicadores inactivos están ocultos. Pasa el cursor sobre cualquier parte de la barra y aparecen atenuados, para que puedas hacer clic en uno y activarlo sin conocer su tecla de acceso rápido. Hacer clic en uno activo lo desactiva. Si prefieres verlos todos todo el tiempo, establece `alwaysShow` en `true` en la entrada `omarchy.indicators` de `~/.config/omarchy/shell.json`: consulta [la barra superior](05-the-top-bar.md) para ver cómo se configuran los widgets de la barra.

### Luz nocturna

La luz nocturna calienta la pantalla a 4000K, y al activarla de nuevo vuelve a 6500K. Cámbiala desde el menú de interruptores (`Super + Ctrl + O`) o con `omarchy toggle nightlight`. La maneja hyprsunset, que el interruptor inicia por ti si aún no está en ejecución.

Por defecto, hyprsunset no le hace nada a tu pantalla. `~/.config/hypr/hyprsunset.conf` viene con un perfil de identidad precisamente para que la pantalla se mantenga intacta hasta que pidas calidez. Si prefieres que cambie según el reloj, reemplázalo con un perfil por horario:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Luego inicia hyprsunset al iniciar sesión agregando `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. El par 4000K/6500K que usa el interruptor es fijo, así que el archivo de configuración es a donde vas si quieres otra temperatura.

### No molestar

`Super + Ctrl + Alt + ,` silencia las notificaciones. No aparecen notificaciones emergentes mientras está activo, y el indicador de la campana tachada se queda en la barra para recordarte por qué el escritorio se quedó callado.

Nada se pierde, sin embargo. Las notificaciones silenciadas se retienen: vuelve a poner las últimas en pantalla con `Super + Shift + Alt + ,`. Consulta [avisos](10-notices.md) para el resto.

Dos tipos de mensajes aún pasan: los avisos de confirmación propios de Omarchy para algo que acabas de hacer ("Theme changed", "Screenshot saved"), y las alertas críticas enviadas desde la línea de comandos. Las apps de chat que marcan todo como crítico para abrirse paso frente a ti no califican.

### Inactividad

El shell de Omarchy controla el comportamiento por inactividad, y los tiempos son un bloque `idle` de nivel superior en `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ambos números son segundos contados desde el momento en que entraste en inactividad, no desde el otro. Así que con los valores predeterminados, el salvapantallas aparece después de dos minutos y medio y la pantalla de bloqueo toma el control a los cinco minutos, haya o no corrido el salvapantallas. Guarda el archivo y el shell toma los nuevos tiempos de inmediato.

Si descartas el salvapantallas antes del límite de bloqueo, eso cuenta como actividad y el bloqueo pendiente se cancela. No te quedas bloqueado por echar un vistazo a tu máquina.

Para dejar de bloquear por inactividad por completo, `Super + Ctrl + I` — o `omarchy toggle idle` — activa mantener despierto, y el indicador de la taza de café aparece en la barra. Ese es el que debes presionar antes de una presentación larga o una compilación que quieres ver. Presiónalo de nuevo para volver a la normalidad. `omarchy toggle idle status` imprime el estado actual como JSON si lo necesitas desde un script.

Esto trata del bloqueo y el salvapantallas, no de la energía. La suspensión y la hibernación tienen su propia configuración en [suspensión del sistema](36-system-sleep.md).

### El salvapantallas

El salvapantallas de Omarchy es arte ASCII que pasa por efectos de texto aleatorios, una instancia por monitor. Cualquier tecla o movimiento del mouse lo cierra.

Puedes iniciarlo a petición desde _Sistema > Salvapantallas_ (`Super + Esc`), lo que lo fuerza aunque hayas desactivado el salvapantallas por inactividad. No hay una tecla de acceso rápido asignada por defecto.

`omarchy toggle screensaver` es lo que desactiva el de inactividad, si prefieres ir directo de trabajar a bloqueado. Cualquier tecla, clic, desplazamiento o movimiento del mouse lo cierra.

El logo que dibuja es tuyo para cambiarlo, en _Apariencia > Marca > Salvapantallas_. Sube un png o svg y Omarchy lo convierte a ASCII. Consulta [marca](41-branding.md).

### La pantalla de bloqueo

`Super + Ctrl + L` bloquea la máquina. Eso ejecuta la pantalla de bloqueo desde el shell de Omarchy, apaga la pantalla, restablece la distribución de teclado a la primera para que no escribas tu contraseña en el alfabeto equivocado y —si lo tienes en ejecución— bloquea 1Password al salir.

La pantalla de bloqueo acepta una contraseña, y también aceptará una huella dactilar una vez que hayas configurado una. Eso, y las demás formas de autenticarte, se cubren en [autenticación de hardware](37-hardware-authentication.md).
