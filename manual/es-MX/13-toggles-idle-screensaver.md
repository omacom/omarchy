# Conmutadores, inactividad y el protector de pantalla

Mucho de lo que cambias día a día no es en realidad un ajuste. Es un modo que activas por una hora y luego vuelves a apagar: luz nocturna mientras trabajas hasta tarde, no molestar mientras estás presentando, mantener despierto mientras ves algo. Omarchy los llama conmutadores, y todos funcionan de la misma manera: un atajo de teclado, una entrada del menú y un comando, todos apuntando al mismo interruptor.

### El menú de conmutadores

`Super + Ctrl + O` abre directamente _Activar > Conmutador_, o puedes llegar ahí desde el menú de Omarchy (`Super + Space`). Todo lo que aparece en esa lista es un interruptor que puedes cambiar sin pensar en dónde vive el estado. Los interruptores sobre cómo se ve el escritorio están justo al lado, en _Apariencia_.

Desde la terminal, los mismos interruptores son `omarchy toggle <thing>`. Ejecuta `omarchy toggle` por sí solo para ver todo el grupo.

| Conmutador | Atajo de teclado | Comando |
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

Los interruptores del panel táctil, la pantalla táctil y la GPU híbrida viven en _Activar > Hardware_ (`Super + Ctrl + H`) y no en Conmutador, ya que solo aparecen cuando realmente tienes ese hardware. Los del panel táctil y la pantalla táctil sobreviven a una recarga de Hyprland: el nombre del dispositivo desactivado se guarda en un pequeño archivo de estado que Hyprland lee al iniciar para volver a desactivarlo.

_Apariencia_ contiene la barra de menú y las animaciones, además de algunas cosas que no son comandos `omarchy toggle` pero se comportan igual: el porcentaje de batería en la barra, la disposición predeterminada de los espacios de trabajo y, en _Ventanas_, los espacios entre ventanas (`Super + Shift + Backspace`) y la proporción cuadrada de 1 ventana (`Super + Ctrl + Backspace`).

Cuando Hyprland no tiene una GPU con la que dibujar y renderiza con la CPU en su lugar (llvmpipe), como en las Mac cuya GPU aún no es compatible, en la mayoría de las máquinas virtuales o cuando un controlador gráfico no logra cargarse, Omarchy desactiva las animaciones, el desenfoque y las sombras para esa sesión y te lo avisa una vez con una notificación. _Apariencia > Activar animaciones_ las vuelve a activar, y Omarchy también lo recuerda para sesiones posteriores.

La mayoría de estos son simplemente un archivo de bandera en `~/.local/state/omarchy/toggles/`. Si quieres ramificar según uno en un script, `omarchy-toggle-enabled` te da un código de salida en lugar de obligarte a ir a buscarlo:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Las banderas se nombran según el estado desactivado — `screensaver-off`, `suspend-off`, `bar-off` —, así que su presencia significa que la función está desactivada.

### Indicadores en la barra

Cuando un modo está activo, obtienes un pequeño glifo en el centro de la barra superior, junto al reloj. Ese es el widget de indicadores, y muestra dictado, grabación de pantalla, recordatorios pendientes, luz nocturna, no molestar y mantener despierto.

Los indicadores inactivos están ocultos. Pasa el cursor sobre cualquier parte de la barra y aparecerán atenuados, para que puedas hacer clic en uno y activarlo sin saber su atajo de teclado. Al hacer clic en uno activo, se vuelve a desactivar. Si prefieres verlos todos todo el tiempo, establece `alwaysShow` en `true` en la entrada `omarchy.indicators` de `~/.config/omarchy/shell.json`: consulta [la barra superior](05-the-top-bar.md) para saber cómo se configuran los widgets de la barra.

### Luz nocturna

La luz nocturna calienta la pantalla a 4000K, y al volver a cambiarla regresa a 6500K. Cámbiala desde el menú de conmutadores (`Super + Ctrl + O`) o con `omarchy toggle nightlight`. La impulsa hyprsunset, que el conmutador inicia por ti si aún no está en ejecución.

Por defecto, hyprsunset no le hace absolutamente nada a tu pantalla. `~/.config/hypr/hyprsunset.conf` viene con un perfil de identidad precisamente para que la pantalla permanezca intacta hasta que pidas calidez. Si prefieres que cambie según la hora, reemplázalo con un perfil por horario:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Luego haz que hyprsunset inicie al iniciar sesión agregando `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. El par 4000K/6500K que usa el conmutador es fijo, así que el archivo de configuración es a donde debes ir si quieres una temperatura diferente.

### No molestar

`Super + Ctrl + Alt + ,` silencia las notificaciones. Mientras está activo no aparece ninguna notificación emergente, y el indicador de la campana tachada se queda en la barra para recordarte por qué el escritorio se quedó en silencio.

Sin embargo, no se pierde nada. Las notificaciones silenciadas se quedan retenidas: vuelve a poner las últimas en pantalla con `Super + Shift + Alt + ,`. Consulta [avisos](10-notices.md) para ver el resto.

Dos tipos de mensajes sí logran pasar: las notificaciones emergentes de confirmación propias de Omarchy por algo que acabas de hacer ("Tema cambiado", "Captura de pantalla guardada"), y las alertas críticas enviadas desde la línea de comandos. Las aplicaciones de chat que marcan todo como crítico para imponerse frente a ti no califican.

### Inactividad

El shell de Omarchy se encarga del comportamiento por inactividad, y los tiempos están en un bloque `idle` de nivel superior en `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ambos números son segundos contados desde el momento en que quedaste inactivo, no uno desde el otro. Así que, con los valores predeterminados, el protector de pantalla aparece después de dos minutos y medio y la pantalla de bloqueo toma el control a los cinco minutos, se haya ejecutado el protector de pantalla o no. Guarda el archivo y el shell adopta los nuevos tiempos de inmediato.

Si cierras el protector de pantalla antes de que se cumpla el plazo de bloqueo, eso cuenta como actividad y el bloqueo pendiente se cancela. No te vas a quedar bloqueado por echarle un vistazo a tu máquina.

Para dejar de bloquear por inactividad por completo, `Super + Ctrl + I` —o `omarchy toggle idle`— activa mantener despierto, y el indicador de la taza de café aparece en la barra. Ese es el que debes presionar antes de una presentación larga o de una compilación que quieres vigilar. Presiónalo de nuevo para volver a la normalidad. `omarchy toggle idle status` imprime el estado actual como JSON si lo necesitas desde un script.

Esto es sobre el bloqueo y el protector de pantalla, no sobre la energía. La suspensión y la hibernación tienen su propia configuración en [suspensión del sistema](36-system-sleep.md).

### El protector de pantalla

El protector de pantalla de Omarchy es arte ASCII que pasa por efectos de texto aleatorios, una instancia por monitor. Cualquier tecla o movimiento del mouse lo cierra.

Puedes iniciarlo cuando quieras desde _Sistema > Protector de pantalla_ (`Super + Esc`), lo que lo fuerza a aparecer incluso si desactivaste el protector de pantalla por inactividad. Por defecto no tiene ningún atajo de teclado asignado.

`omarchy toggle screensaver` es lo que desactiva el de inactividad, si prefieres pasar directamente de trabajar a bloqueado. Cualquier tecla, clic, desplazamiento o movimiento del mouse lo cierra.

El logotipo que dibuja lo puedes cambiar tú, en _Apariencia > Marca > Protector de pantalla_. Sube un png o svg y Omarchy lo convierte a ASCII. Consulta [marca](41-branding.md).

### La pantalla de bloqueo

`Super + Ctrl + L` bloquea la máquina. Eso ejecuta la pantalla de bloqueo del shell de Omarchy, apaga la pantalla, restablece la distribución de tu teclado a la primera para que no escribas tu contraseña en el alfabeto equivocado y, si lo tienes en ejecución, bloquea 1Password al salir.

La pantalla de bloqueo acepta una contraseña, y también aceptará una huella digital una vez que hayas configurado una. Eso, y las demás formas de autenticarte, se explican en [autenticación por hardware](37-hardware-authentication.md).
