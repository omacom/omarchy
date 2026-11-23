# La barra superior

La franja a lo largo de la parte superior de tu pantalla es la barra de Omarchy. No es una barra de estado añadida a posteriori, sino parte del shell de Omarchy, el único proceso de Quickshell de larga duración que también dibuja el menú, las notificaciones, las ventanas emergentes OSD y la pantalla de bloqueo. Por eso combina a la perfección con todo lo demás y por eso un panel se abre al instante en lugar de lanzar una aplicación nueva.

También es la única pieza del escritorio que siempre está en pantalla, así que vale la pena saber qué hacen todos esos pequeños glifos.

## Qué trae por defecto

La barra tiene tres secciones. A la izquierda está el logotipo de Omarchy (el lanzador del menú) y los indicadores de espacios de trabajo. En el centro aparecen los indicadores de estado, el reloj, Elsewhen (un reloj mundial), el tiempo y una insignia de actualización de Omarchy. A la derecha: la bandeja del sistema, la distribución del teclado (cuando hay más de una distribución o método de entrada configurado), agentes, bluetooth, red, audio, pantalla y energía.

Algunos de esos solo aparecen cuando tienen algo que decir. La distribución del teclado aparece solo si has configurado más de una distribución o método de entrada. La insignia de actualización aparece solo cuando hay una actualización de Omarchy en espera.

## Hacer clic por todas partes

Casi todos los componentes hacen algo con el clic izquierdo, derecho y central, y varios responden al desplazamiento. Esta es la parte que la gente se pierde: en los botones derecho y central es donde se esconde mucho de lo bueno.

| Componente | Izquierdo | Derecho | Central / desplazamiento |
| --- | --- | --- | --- |
| Menú | Menú de Omarchy | Terminal nueva | — |
| Espacios de trabajo | Enfocar ese espacio de trabajo en este monitor | — | Desplazamiento: espacio de trabajo siguiente/anterior |
| Reloj | Ventana emergente del calendario | Alternar el formato de la etiqueta | Central: selector de zona horaria |
| Reloj mundial | Panel del reloj mundial | Actualizar | Central: actualizar |
| Tiempo | Ventana emergente del pronóstico | Tiempo completo como notificación | Central: actualizar |
| Audio | Panel de audio | Silenciar | Central: panel · desplazamiento: volumen |
| Micrófono | Silenciar el micrófono | — | Central: panel de audio · desplazamiento: volumen de entrada |
| Red | Panel de red | — | — |
| Bluetooth | Panel de Bluetooth | Activar/desactivar la radio | — |
| Pantalla | Panel de pantalla | — | Desplazamiento: brillo |
| Energía | Panel de energía | Activar/desactivar el porcentaje de batería | — |
| Multimedia | Reproducir/pausar | Ventana emergente de la portada | Central: siguiente · desplazamiento: anterior/siguiente |
| Agentes | Panel de agentes | Iniciar tu agente | Central: actualizar el uso |
| Bandeja | Pasa el ratón para mostrar el cajón | Clic derecho en los chevrones para administrar | — |
| Actualización de Omarchy | Ejecutar la actualización | — | — |

No todo lo de esa tabla está en tu barra desde el inicio. El componente multimedia (MPRIS con lo que se está reproduciendo, con la pista y el artista desplazándose) y el componente de micrófono están integrados, pero desactivados por defecto: añádelos si los quieres, como se describe más abajo.

## Los paneles

Al hacer clic en un icono de la barra se abre un panel, que es una ventana emergente de verdad, con controles deslizantes, listas y navegación con teclado, y no un simple globo de ayuda. Cada uno también tiene un atajo de teclado, así que nunca tienes que apuntar a un glifo de 16 píxeles:

| Atajo de teclado | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Red |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Pantalla |
| `Super + Ctrl + P` | Energía |
| `Super + Ctrl + Alt + D` | Calendario |
| `Super + Ctrl + Alt + E` | Reloj mundial |
| `Super + Ctrl + X` | Agentes |
| `Super + Ctrl + 1-9` | Activar/desactivar el enésimo panel en la sección derecha |

Los paneles no son meros indicadores. Son donde de verdad se actúa:

- **Audio** tiene un control deslizante de volumen principal, un selector de dispositivo de salida y un mezclador por aplicación, así que puedes bajar el volumen de esa única pestaña del navegador sin tocar todo lo demás.
- **Red** busca redes Wi-Fi, muestra la intensidad de la señal, se conecta y te deja elegir un proveedor de DNS.
- **Bluetooth** enumera tus dispositivos con conectar/desconectar y niveles de batería.
- **Energía** muestra estadísticas de la batería, cambia los perfiles de energía (recuerda una elección separada para batería y corriente alterna) y muestra algo de información del sistema.
- **Pantalla** trae un control deslizante de brillo, tamaño del texto, ajustes preestablecidos de escala del monitor y, cuando tienes más de una pantalla, controles por monitor. Consulta [monitores](33-monitors.md) para saber más.
- **Reloj** abre una rejilla mensual con números de semana ISO y desplazamiento por meses.
- **Reloj mundial** mantiene una fila por ciudad, con el tiempo que hace y cómo va su día. La búsqueda encuentra pueblos además de zonas horarias, así que Fort Lauderdale es Fort Lauderdale y no New York. Si la línea de arriba nombra la ciudad equivocada, haz clic en ella y di dónde estás; elige un lugar en otra zona horaria y el reloj del sistema también se mueve ahí, lo cual es útil cuando viajas. Pasa el ratón por encima de una ciudad y haz clic en el botón de la persona para decir quién vive ahí: nombres simples, o identificadores de GitHub con `@` para traer también sus caras.

Todos los paneles aceptan el teclado además del ratón: las flechas se mueven, Return activa, Tab pasa al panel vecino y Escape cierra.

`Super + Ctrl + 1-9` cuenta los paneles de izquierda a derecha en la sección derecha, saltándose la bandeja porque no tiene panel propio. Así que el número coincide con el icono al que apuntarías.

### Tailscale y Dropbox

Dos componentes más aparecen en la barra solo una vez que instalas el servicio correspondiente desde **Instalar → Servicio**, y vale la pena conocer ambos porque hacen más que reportar el estado.

El panel de **Tailscale** conecta y desconecta la tailnet, cambia entre cuentas y elige un nodo de salida (tus propias máquinas y las regiones de Mullvad aparecen en esa lista). También explora tus máquinas, y con una seleccionada, `s` le envía archivos por Taildrop, que es la forma más rápida de mover un archivo a tu teléfono u otro portátil. `c` copia la IP de la máquina, `n` su nombre y `d` su nombre DNS completo. También hay un botón de enviar en cada fila de máquina, por si prefieres hacer clic. Lo mismo desde la terminal es `omarchy tailscale send <machine> [file...]`.

El panel de **Dropbox** gestiona el inicio de sesión, muestra cuánto almacenamiento has usado y enumera los archivos sincronizados recientemente.

Si quitas cualquiera de los dos servicios, su componente desaparece de la barra.

## Indicadores

El pequeño grupo en el centro es el componente de indicadores. Estos son glifos de estado para los modos que has activado: no molestar, luz nocturna, un [recordatorio](09-reminders.md) en cola, una grabación de pantalla activa y mantenerse despierto, además de advertencias mientras sudo sin contraseña está activado o alguien está conectado a una sesión remota. Se iluminan cuando el modo está activo y en caso contrario no estorban: pasa el cursor justo al lado de ellos, donde estarían los inactivos, para echarles un vistazo. Al hacer clic en un indicador se activa o desactiva ese modo. Uno más es solo de estado: una sesión remota se ilumina en rojo mientras alguien está conectado a esta máquina a través de gliff.

Si prefieres que siempre estén visibles, establece `alwaysShow` en `true` en el componente. Y si solo te importan algunos de ellos, enumera los que quieres en `items`: `["Dnd", "Reminder", "NightLight"]`. Puedes tener más de un componente de indicadores, así que secciones diferentes pueden mostrar subconjuntos diferentes.

## Reordenar la barra

La barra se configura sola. No tienes que abrir un archivo de configuración para mover las cosas.

Coge un trozo vacío de la barra alrededor del centro y arrástralo hacia otro borde de la pantalla, y la barra se mueve ahí: izquierda, derecha, arriba o abajo funcionan, y cada componente se adapta (las barras verticales vuelven a formas compactas de solo iconos). Mantener pulsado también inicia el arrastre. Haz doble clic izquierdo en ese mismo espacio vacío para ir alternando el fondo de la barra entre transparente, cristalino y opaco. Y arrastra cualquier componente para reordenarlo o lanzarlo a otra sección; los demás componentes se separan para hacer sitio donde va a caer.

El centro de la barra es una caja: lo que sea que esté en ella permanece centrado como un solo grupo, y los componentes a cada lado cuelgan de sus bordes. Mientras arrastras un componente, la caja se muestra como un contorno, o una línea a través de la barra cuando está vacía, y puedes soltar dentro de ella o junto a ella. Cuando el componente vaya a soltarse dentro de la caja, esta crece para acogerlo.

Un componente que quieres cerca pero no siempre a la vista puede ir en el cajón de la bandeja: arrástralo a la bandeja y el cajón se abre para recibirlo. Se coloca ahí después de los iconos de las aplicaciones, y aparece siempre que se abre el cajón y mantiene su cajón abierto mientras su panel está abierto. Arrástralo de vuelta a la barra para devolverlo.

Si prefieres elegir desde un menú, en **Apariencia → Barra de menú** está la posición, y **Fondo de la barra** elige cómo se dibuja la barra: **Barra opaca**, **Barra cristalina** (transparente, con lo que está detrás borroso) o **Barra transparente**.

Todo esto también se puede hacer con comandos, que es lo que quieres para una configuración de [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Para añadir o quitar un componente por completo, usa los comandos de complementos. `omarchy plugin list` muestra cada componente que conoce el shell con su id, y luego:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Ocultar la barra

`Super + Shift + Space` oculta la barra y la vuelve a mostrar sin matar el shell: los paneles y los atajos de teclado siguen funcionando, solo recuperas los píxeles. También está en el menú en **Apariencia → Barra de menús → Ocultar barra**.

## El archivo de configuración

Todo se guarda en `~/.config/omarchy/shell.json`, bajo la clave `bar`. Esta es una versión recortada:

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

Cada componente es una entrada en una de las cinco listas de disposición, y su configuración va en línea en esa entrada: no hay un archivo de configuración separado ni un subobjeto `config`. El `format`, el `formatAlt` (a lo que cambia el clic derecho) y el `verticalFormat` del reloj viven todos justo ahí en `{ "id": "omarchy.clock" }`.

`center` es la caja en el centro de la barra: todo lo que está en ella se centra en la pantalla como un solo grupo. `centerBegin` y `centerEnd` cuelgan de cada lado de la caja, que es como el reloj se queda justo en el centro aun cuando el tiempo y la insignia de actualización van y vienen. Pon más de un componente en `center` y se centran juntos; déjalo vacío y `centerBegin` y `centerEnd` se encuentran en el centro de la barra.

Una regla que vale la pena interiorizar: **en cuanto tengas tu propio `shell.json`, es la fuente de verdad**. Hasta que personalices algo, el shell lee el archivo por defecto de Omarchy. En el momento en que arrastras un componente, ejecutas `omarchy bar` o editas el archivo tú mismo, es tuyo: no hay una fusión profunda, así que los componentes por defecto nuevos en versiones futuras de Omarchy no aparecerán en tu barra automáticamente. `omarchy bar defaults` vuelve a poner la disposición incluida cuando quieras empezar de cero.

Ese archivo guarda además tus tiempos de inactividad en el nivel superior, fuera de la clave `bar`: `idle.screensaver` e `idle.lock`, ambos en segundos de inactividad. Así que el protector de pantalla por defecto entra a los 150 segundos y el bloqueo a los 300.
