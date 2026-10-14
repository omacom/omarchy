# La barra superior

La franja a lo largo de la parte superior de tu pantalla es la barra de Omarchy. No es una barra de estado pegada con tornillos, sino parte del shell de Omarchy, el proceso único y de larga duración de Quickshell que también dibuja el menú, las notificaciones, los emergentes OSD y la pantalla de bloqueo. Por eso combina a la perfección con todo lo demás y por eso un panel se abre al instante en lugar de lanzar una aplicación nueva.

También es la única pieza del escritorio que siempre está en pantalla, así que vale la pena saber qué hacen todos esos glifos pequeños.

## Qué trae por defecto

La barra tiene tres secciones. A la izquierda está el logo de Omarchy (el lanzador del menú) y los indicadores de espacios de trabajo. En el centro están los indicadores de estado, el reloj, Elsewhen (un reloj mundial), el clima y una insignia de actualización de Omarchy. A la derecha: la distribución de teclado (cuando hay más de una configurada), la bandeja del sistema, agentes, bluetooth, red, audio, pantalla y energía.

Algunos de esos solo aparecen cuando tienen algo que decir. La distribución de teclado aparece solo si has configurado más de una distribución. La insignia de actualización aparece solo cuando hay una actualización de Omarchy en espera. Y el icono de agentes aparece la primera vez que Omarchy encuentra uso de agentes de IA para código en la máquina (consulta [IA](17-ai.md)).

## Hacer clic por ahí

Casi todos los widgets hacen algo con clic izquierdo, derecho y central, y varios responden al desplazamiento. Esta es la parte que la gente se pierde — los botones derecho y central son donde se esconde mucha de la parte buena.

| Widget | Izquierdo | Derecho | Central / desplazamiento |
| --- | --- | --- | --- |
| Menú | Menú de Omarchy | Terminal nueva | — |
| Espacios de trabajo | Enfocar ese espacio de trabajo | — | Desplazamiento: espacio siguiente/anterior |
| Reloj | Calendario emergente | Cambiar el formato de la etiqueta | Central: selector de zona horaria |
| Clima | Pronóstico emergente | Clima completo como notificación | Central: actualizar |
| Audio | Panel de audio | Silenciar | Central: panel · desplazamiento: volumen |
| Micrófono | Silenciar el micrófono | — | Central: panel de audio · desplazamiento: volumen de entrada |
| Red | Panel de red | — | — |
| Bluetooth | Panel de Bluetooth | Activar/desactivar la radio | — |
| Pantalla | Panel de pantalla | — | Desplazamiento: brillo |
| Energía | Panel de energía | Mostrar/ocultar el porcentaje de batería | — |
| Multimedia | Reproducir/pausar | Portada emergente | Central: siguiente · desplazamiento: anterior/siguiente |
| Agentes | Panel de agentes | Abrir tu agente | Central: siguiente suscripción |
| Bandeja | Pasar el cursor para mostrar el cajón | Clic derecho en el chevrón para administrar | — |
| Actualización de Omarchy | Ejecutar la actualización | — | — |

No todo lo de esa tabla está en tu barra desde el principio. El widget de multimedia (lo que suena según MPRIS, con pista y artista en desplazamiento) y el widget de micrófono vienen integrados pero desactivados por defecto — agrégalos si los quieres, como se describe abajo.

## Los paneles

Al hacer clic en un icono de la barra se abre un panel, que es un emergente en forma con deslizadores, listas y navegación con teclado, no un tooltip. Cada uno también tiene un atajo, así que nunca tienes que apuntarle a un glifo de 16 píxeles:

| Atajo | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + W` | Red |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Pantalla |
| `Super + Ctrl + P` | Energía |
| `Super + Ctrl + Alt + D` | Calendario |
| `Super + Ctrl + Alt + E` | Reloj mundial |
| `Super + Ctrl + 1-9` | Mostrar/ocultar el enésimo panel de la sección derecha |

Los paneles no son lecturas de estado. Ahí es donde de verdad haces la cosa:

- **Audio** tiene un deslizador de volumen maestro, un selector de dispositivo de salida y un mezclador por aplicación, para que puedas bajarle a esa pestaña del navegador sin tocar todo lo demás.
- **Red** busca redes Wi-Fi, muestra la intensidad de la señal, se conecta y te deja elegir un proveedor de DNS.
- **Bluetooth** enumera tus dispositivos con conectar/desconectar y niveles de batería.
- **Energía** muestra estadísticas de la batería, cambia perfiles de energía (recuerda una elección distinta para batería y para corriente) e imprime información del sistema.
- **Pantalla** incluye un deslizador de brillo, tamaño del texto, ajustes de escala de monitor y — cuando tienes más de una pantalla — controles por monitor. Consulta [monitores](33-monitors.md) para la historia completa.
- **Reloj** abre una cuadrícula mensual con números de semana ISO y cambio de mes.

Cada panel acepta tanto el teclado como el ratón: las flechas mueven, Return activa, Tab pasa al panel vecino y Escape cierra.

`Super + Ctrl + 1-9` cuenta los paneles de izquierda a derecha en la sección derecha, saltándose la bandeja porque no tiene panel propio. Así, el número coincide con el icono al que apuntarías.

### Tailscale y Dropbox

Dos widgets más aparecen en la barra solo cuando instalas el servicio correspondiente desde **Instalar → Servicio**, y vale la pena conocer ambos porque hacen más que reportar estado.

El panel de **Tailscale** conecta y desconecta la tailnet, cambia entre cuentas y elige un nodo de salida (tus propias máquinas y las regiones de Mullvad aparecen en esa lista). También explora tus máquinas — y con una seleccionada, `s` le envía archivos por Taildrop, que es la manera más rápida de pasar un archivo a tu teléfono o a otra laptop. `c` copia la IP de la máquina, `n` su nombre y `d` su nombre DNS completo. También hay un botón de enviar en la fila de cada máquina, si prefieres hacer clic. Lo mismo desde la terminal es `omarchy tailscale send <machine> [file...]`.

El panel de **Dropbox** maneja el inicio de sesión, muestra cuánto almacenamiento has usado y enumera los archivos sincronizados recientemente.

Quitar cualquiera de los dos servicios retira su widget de la barra.

## Indicadores

El grupito en el centro es el widget de indicadores. Son glifos de estado para los modos que has activado: no molestar, luz nocturna, un [recordatorio](09-reminders.md) en cola, una grabación de pantalla activa, mantenerse despierto y [dictado](11-text-extraction-dictation.md). Se encienden cuando el modo está activo y, si no, no estorban — pasa el cursor a la izquierda del reloj (encima de él en una barra vertical) para echar un vistazo a los inactivos. Al hacer clic en un indicador se activa o desactiva ese modo. Uno más es solo de estado: una sesión remota se enciende en rojo mientras alguien está conectado a esta máquina a través de gliff.

Si prefieres que siempre estén visibles, pon `alwaysShow` en `true` en el widget. Y si solo te importan algunos, enumera los que quieres en `items`: `["Dnd", "Reminder", "NightLight"]`. Puedes tener más de un widget de indicadores, para que distintas secciones muestren distintos subconjuntos.

## Reacomodar la barra

La barra se configura sola. No tienes que abrir un archivo de configuración para mover las cosas.

Agarra un pedazo vacío de la barra alrededor del centro y arrástralo hacia otro borde de la pantalla, y la barra se mueve ahí — izquierda, derecha, arriba o abajo funcionan, y cada widget se adapta (las barras verticales recurren a formas compactas de solo icono). Hacer clic y mantener inicia el mismo arrastre. Haz doble clic izquierdo en ese mismo espacio vacío para cambiar el fondo de la barra de transparente a cristalino a opaco. Y arrastra cualquier widget para reordenarlo o aventarlo a otra sección.

Un widget que quieres tener a la mano pero no siempre a la vista puede ir en el cajón de la bandeja: arrástralo sobre la bandeja y el cajón se abre para recibirlo. Ahí queda, después de los iconos de las aplicaciones, aparece cada vez que aparece el cajón y lo mantiene abierto mientras su panel está visible. Arrástralo de vuelta a la barra para regresarlo a su lugar.

Si prefieres elegir desde un menú, **Activar → Apariencia → Barra de menú** tiene la posición, y **Fondo de barra** elige cómo se dibuja la barra: **Barra opaca**, **Barra cristalina** (translúcida, con lo que hay detrás difuminado) o **Barra transparente**.

Esas mismas cosas tienen comandos, que es lo que quieres para una configuración con [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Para agregar o quitar un widget por completo, usa los comandos de plugin. `omarchy plugin list` imprime cada widget que el shell conoce con su id, y luego:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Ocultar la barra

`Super + Shift + Space` apaga la barra y la vuelve a encender sin matar el shell — los paneles y los atajos siguen funcionando, solo recuperas los píxeles. También está en el menú en **Activar → Apariencia → Barra de menú → Ocultar barra**.

## El archivo de configuración

Todo se guarda en `~/.config/omarchy/shell.json`, bajo la clave `bar`. Aquí tienes una versión recortada:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Cada widget es una entrada en uno de los tres arreglos de distribución, y sus ajustes viven en línea en esa entrada — no hay un archivo de ajustes aparte ni un subobjeto `config`. El `format`, el `formatAlt` (al que cambia el clic derecho) y el `verticalFormat` del reloj viven todos justo ahí en `{ "id": "omarchy.clock" }`.

`centerAnchor` nombra el único widget central que se fija al centro exacto de la pantalla, con los demás flanqueándolo. Así es como el reloj se queda justo al centro aunque el clima y la insignia de actualización vayan y vengan. Ponlo como cadena vacía y la lista central simplemente se centra como grupo.

Una regla que vale la pena interiorizar: **una vez que tienes tu propio `shell.json`, es canónico**. Hasta que personalices algo, el shell lee el archivo predeterminado de Omarchy. En el momento en que arrastras un widget, ejecutas `omarchy bar` o editas el archivo tú mismo, es tuyo — no hay fusión profunda, así que los widgets predeterminados nuevos en versiones futuras de Omarchy no aparecerán automáticamente en tu barra. `omarchy bar defaults` regresa la distribución original cuando quieras empezar de cero.

El mismo archivo también guarda tus tiempos de inactividad en el nivel superior, fuera de la clave `bar`: `idle.screensaver` e `idle.lock`, ambos en segundos desde que entraste en inactividad. Así, el protector de pantalla predeterminado entra a los 150 segundos y el bloqueo a los 300.
