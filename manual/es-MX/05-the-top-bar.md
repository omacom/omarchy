# La barra superior

La franja a lo largo de la parte superior de tu pantalla es la barra de Omarchy. No es una barra de estado añadida a la fuerza, sino parte de la shell de Omarchy, el único proceso de Quickshell de larga ejecución que también dibuja el menú, las notificaciones, las ventanas emergentes OSD y la pantalla de bloqueo. Por eso combina a la perfección con todo lo demás en el tema y por eso un panel se abre al instante en lugar de lanzar una aplicación nueva.

También es la única pieza del escritorio que siempre está en pantalla, así que vale la pena saber qué hacen todos esos pequeños glifos.

## Qué trae por default

La barra tiene tres secciones. A la izquierda está el logo de Omarchy (el lanzador del menú) y los indicadores de espacios de trabajo. En el centro tienes los indicadores de estado, el reloj, Elsewhen (un reloj mundial), el clima y una insignia de actualización de Omarchy. A la derecha: la bandeja del sistema, la distribución de teclado (cuando hay más de una configurada), agentes, bluetooth, red, audio, pantalla y energía.

Algunos de esos solo aparecen cuando tienen algo que decir. La distribución de teclado aparece solo si configuraste más de una distribución. La insignia de actualización aparece solo cuando hay una actualización de Omarchy esperando. Y el ícono de agentes aparece la primera vez que Omarchy encuentra un uso de codificación con IA en la máquina (consulta [IA](17-ai.md)).

## Hacer clic por aquí y por allá

Casi todos los widgets hacen algo con el clic izquierdo, derecho y central, y varios responden a la rueda del mouse. Esta es la parte que la gente se pierde: en los botones derecho y central es donde se esconde mucho de lo bueno.

| Widget | Izquierdo | Derecho | Central / rueda |
| --- | --- | --- | --- |
| Menú | Menú de Omarchy | Nueva terminal | — |
| Espacios de trabajo | Enfocar ese espacio de trabajo en este monitor | — | Rueda: espacio de trabajo siguiente/anterior |
| Reloj | Ventana emergente del calendario | Recorrer el formato de la etiqueta | Central: selector de zona horaria |
| Clima | Ventana emergente del pronóstico | Clima completo como notificación | Central: actualizar |
| Audio | Panel de audio | Silenciar | Central: panel · rueda: volumen |
| Micrófono | Silenciar el micrófono | — | Central: panel de audio · rueda: volumen de entrada |
| Red | Panel de red | — | — |
| Bluetooth | Panel de Bluetooth | Activar/desactivar la radio | — |
| Pantalla | Panel de pantalla | — | Rueda: brillo |
| Energía | Panel de energía | Mostrar/ocultar el porcentaje de batería | — |
| Multimedia | Reproducir/pausar | Ventana emergente con la portada | Central: siguiente · rueda: anterior/siguiente |
| Agentes | Panel de agentes | Lanzar tu agente | Central: siguiente suscripción |
| Bandeja | Pasar el cursor para revelar el cajón | Derecho en el chevrones para administrar | — |
| Actualización de Omarchy | Ejecutar la actualización | — | — |

No todo lo que aparece en esa tabla está en tu barra desde el inicio. El widget multimedia (reproducción actual de MPRIS, con pista y artista desplazándose) y el widget de micrófono están integrados, pero desactivados por default: agrégalos si los quieres, como se describe a continuación.

## Los paneles

Hacer clic en un ícono de la barra abre un panel, que es una ventana emergente en forma, con controles deslizantes, listas y navegación por teclado, en lugar de una descripción emergente. Cada uno también tiene un atajo, así que nunca tienes que apuntarle a un glifo de 16 píxeles:

| Atajo | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Red |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Pantalla |
| `Super + Ctrl + P` | Energía |
| `Super + Ctrl + Alt + D` | Calendario |
| `Super + Ctrl + Alt + E` | Reloj mundial |
| `Super + Ctrl + 1-9` | Activar/desactivar el enésimo panel en la sección derecha |

Los paneles no son solo lecturas. Son el lugar donde de verdad haces la cosa:

- **Audio** tiene un control deslizante de volumen maestro, un selector de dispositivo de salida y una mezcladora por aplicación, para que puedas bajarle a esa única pestaña del navegador sin tocar todo lo demás.
- **Red** busca redes Wi-Fi, muestra la intensidad de la señal, se conecta y te permite elegir un proveedor de DNS.
- **Bluetooth** lista tus dispositivos con conectar/desconectar y niveles de batería.
- **Energía** muestra estadísticas de la batería, cambia los perfiles de energía (recuerda una elección distinta para batería y para corriente alterna) e imprime algo de información del sistema.
- **Pantalla** incluye un control deslizante de brillo, tamaño del texto, preajustes de escala del monitor y, cuando tienes más de una pantalla, controles por monitor. Consulta [monitores](33-monitors.md) para conocer la historia a fondo.
- **Reloj** abre una cuadrícula mensual con números de semana ISO y desplazamiento por meses.
- **Reloj mundial** mantiene una fila por ciudad, con su clima y cómo va su día. La búsqueda encuentra pueblos además de zonas horarias, así que Fort Lauderdale es Fort Lauderdale y no Nueva York. Si la línea de arriba nombra la ciudad equivocada, haz clic en ella y di dónde estás; elige un lugar en otra zona horaria y el reloj del sistema también se mueve ahí, lo cual es muy práctico cuando viajas. Pasa el cursor sobre una ciudad y haz clic en el botón de la persona para decir quién vive ahí: nombres normales, o identificadores de GitHub con `@` para traer también sus caras.

Todos los paneles aceptan el teclado además del mouse: las flechas se mueven, Return activa, Tab pasa al panel vecino y Escape cierra.

`Super + Ctrl + 1-9` cuenta los paneles de izquierda a derecha en la sección derecha, saltándose la bandeja porque no tiene un panel propio. Así el número coincide con el ícono al que le apuntarías.

### Tailscale y Dropbox

Dos widgets más aparecen en la barra solo cuando instalas el servicio correspondiente desde **Instalar → Servicio**, y vale la pena conocer ambos porque hacen más que informar el estado.

El panel de **Tailscale** conecta y desconecta la tailnet, cambia entre cuentas y elige un nodo de salida (tanto tus propias máquinas como las regiones de Mullvad aparecen en esa lista). También explora tus máquinas y, con una seleccionada, `s` le envía archivos por Taildrop, que es la forma más rápida de pasar un archivo a tu teléfono o a otra laptop. `c` copia la IP de la máquina, `n` su nombre y `d` su nombre DNS completo. También hay un botón de enviar en cada fila de máquina, si prefieres hacer clic. Lo mismo desde la terminal es `omarchy tailscale send <machine> [file...]`.

El panel de **Dropbox** se encarga del inicio de sesión, muestra cuánto almacenamiento has usado y lista los archivos sincronizados recientemente.

Quitar cualquiera de los dos servicios también retira su widget de la barra.

## Indicadores

El pequeño grupo en el centro es el widget de indicadores. Son glifos de estado para los modos que activaste: no molestar, luz nocturna, un [recordatorio](09-reminders.md) en cola, una grabación de pantalla activa, mantenerse despierto y el [dictado](11-text-extraction-dictation.md). Se encienden cuando el modo está activo y, si no, se quedan fuera del camino: pasa el cursor justo al lado de ellos, donde irían los inactivos, para echarles un vistazo a esos. Hacer clic en un indicador activa o desactiva ese modo. Hay uno más que es solo de estado: una sesión remota se enciende en rojo mientras alguien está conectado a esta máquina a través de gliff.

Si prefieres que siempre estén visibles, establece `alwaysShow` en `true` en el widget. Y si solo te importan algunos de ellos, lista los que quieres en `items`: `["Dnd", "Reminder", "NightLight"]`. Puedes tener más de un widget de indicadores, para que secciones distintas muestren subconjuntos distintos.

## Reordenar la barra

La barra se configura sola. No tienes que abrir un archivo de configuración para mover las cosas.

Agarra un pedazo vacío de la barra alrededor del centro y arrástralo hacia otro borde de la pantalla: la barra se mueve ahí (izquierda, derecha, arriba o abajo funcionan, y todos los widgets se adaptan; las barras verticales recurren a formas compactas de solo íconos). Mantener presionado el clic inicia el mismo arrastre. Haz doble clic izquierdo en ese mismo espacio vacío para recorrer el fondo de la barra de transparente a cristalino a opaco. Y arrastra cualquier widget para reordenarlo o lanzarlo a otra sección; los demás widgets se abren para hacer espacio donde va a caer.

El centro de la barra es una caja: lo que sea que esté dentro se queda centrado como un solo grupo, y los widgets a cada lado cuelgan de sus bordes. Mientras arrastras un widget, la caja se muestra como un contorno, o como una línea a lo ancho de la barra cuando está vacía, y puedes soltar dentro de ella o a su lado. Cuando un elemento soltado caería en la caja, la caja crece para recibir al widget.

Un widget que quieres cerca, pero no siempre a la vista, puede ir en el cajón de la bandeja: arrástralo hasta la bandeja y el cajón se abre para recibirlo. Se queda ahí después de los íconos de las aplicaciones, aparece cada vez que lo hace el cajón y mantiene abierto su cajón mientras su panel está arriba. Arrástralo de vuelta a la barra para regresarlo a su lugar.

Si prefieres elegir desde un menú, **Apariencia → Barra de menú** tiene la posición y **Fondo de la barra** elige cómo se dibuja la barra: **Barra opaca**, **Barra cristalina** (transparente, con lo que está detrás difuminado) o **Barra transparente**.

Esas mismas cosas tienen comandos, que es lo que quieres para una configuración con [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Para agregar o quitar un widget por completo, usa los comandos de plugins. `omarchy plugin list` imprime todos los widgets que la shell conoce con su id, y luego:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Ocultar la barra

`Super + Shift + Space` oculta y vuelve a mostrar la barra sin matar la shell: los paneles y los atajos siguen funcionando, solo recuperas los píxeles. También está en el menú en **Apariencia → Barra de menú → Ocultar barra**.

## El archivo de configuración

Todo se guarda en `~/.config/omarchy/shell.json`, bajo la clave `bar`. Aquí está una versión recortada:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Cada widget es una entrada en uno de los cinco arreglos del diseño, y su configuración va en línea en esa entrada: no hay un archivo de configuración aparte ni un subobjeto `config`. El `format` del reloj, `formatAlt` (a lo que cambia el clic derecho) y `verticalFormat` viven todos justo ahí en `{ "id": "omarchy.clock" }`.

`center` es la caja en el centro de la barra: todo lo que contiene se centra en la pantalla como un solo grupo. `centerBegin` y `centerEnd` cuelgan a cada lado de la caja, que es como el reloj se queda justo en el centro aunque el clima y la insignia de actualización vayan y vengan. Pon más de un widget en `center` y se centran juntos; déjalo vacío y `centerBegin` y `centerEnd` se encuentran en el centro de la barra.

Una regla que vale la pena interiorizar: **en cuanto tienes tu propio `shell.json`, es el canónico**. Hasta que personalizas algo, la shell lee el archivo default de Omarchy. En el momento en que arrastras un widget, ejecutas `omarchy bar` o editas el archivo tú mismo, es tuyo: no hay una fusión profunda, así que los widgets default nuevos en versiones futuras de Omarchy no aparecerán en tu barra automáticamente. `omarchy bar defaults` restablece el diseño incluido cada vez que quieres empezar de cero.

Ese mismo archivo también guarda tus tiempos de inactividad en el nivel superior, fuera de la clave `bar`: `idle.screensaver` e `idle.lock`, ambos en segundos desde que quedaste inactivo. Así, el protector de pantalla default entra a los 150 segundos y el bloqueo a los 300.
