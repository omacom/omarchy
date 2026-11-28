# La barra superior

La franja a lo largo de la parte superior de tu pantalla es la barra de Omarchy. No es una barra de estado añadida a la fuerza, sino parte del shell de Omarchy, el único proceso de larga duración de Quickshell que también dibuja el menú, las notificaciones, las ventanas emergentes OSD y la pantalla de bloqueo. Por eso combina a la perfección con todo lo demás y por eso un panel se abre al instante en lugar de iniciar una app nueva.

También es la única pieza del escritorio que siempre está en pantalla, así que vale la pena saber qué hacen todos esos glifos pequeños.

## Qué trae por defecto

La barra tiene tres secciones. A la izquierda está el logotipo de Omarchy (el lanzador del menú) y los indicadores de espacios de trabajo. En el centro obtienes los indicadores de estado, el reloj, Elsewhen (un reloj mundial), el clima y una insignia de actualización de Omarchy. A la derecha: la bandeja del sistema, la distribución del teclado (cuando hay más de una distribución o método de entrada configurado), agentes, bluetooth, red, audio, pantalla y energía.

Algunos de esos solo aparecen cuando tienen algo que decir. La distribución del teclado aparece solo si has configurado más de una distribución o método de entrada. La insignia de actualización aparece solo cuando hay una actualización de Omarchy en espera.

## Hacer clic por ahí

Casi todos los widgets hacen algo con el clic izquierdo, derecho y central, y varios responden al desplazamiento. Esta es la parte que la gente se pierde: en los botones derecho y central es donde se esconde mucho de lo bueno.

| Widget | Izquierdo | Derecho | Central / desplazamiento |
| --- | --- | --- | --- |
| Menú | Menú de Omarchy | Nueva terminal | — |
| Espacios de trabajo | Enfocar ese espacio de trabajo en este monitor | — | Desplazamiento: espacio de trabajo siguiente/anterior |
| Reloj | Ventana emergente del calendario | Recorrer los formatos de la etiqueta | Central: selector de zona horaria |
| Reloj mundial | Panel del reloj mundial | Actualizar | Central: actualizar |
| Clima | Ventana emergente del pronóstico | Clima completo como una notificación | Central: actualizar |
| Audio | Panel de audio | Silenciar | Central: panel · desplazamiento: volumen |
| Micrófono | Silenciar el micrófono | — | Central: panel de audio · desplazamiento: volumen de entrada |
| Red | Panel de red | — | — |
| Bluetooth | Panel de Bluetooth | Activar/desactivar la radio | — |
| Pantalla | Panel de pantalla | — | Desplazamiento: brillo |
| Energía | Panel de energía | Mostrar/ocultar el porcentaje de la batería | — |
| Medios | Reproducir/pausar | Ventana emergente de la portada | Central: siguiente · desplazamiento: anterior/siguiente |
| Agentes | Panel de agentes | Iniciar tu agente | Central: actualizar el uso |
| Bandeja | Pasar el cursor para mostrar el cajón | Clic derecho en el chevron para administrar | — |
| Actualización de Omarchy | Ejecutar la actualización | — | — |

No todo lo que está en esa tabla está en tu barra desde el inicio. El widget de medios (lo que se está reproduciendo en MPRIS, con la pista y el artista desplazándose) y el widget de micrófono ya vienen incluidos pero están desactivados por defecto: agrégalos si los quieres, como se describe a continuación.

## Los paneles

Al hacer clic en un ícono de la barra se abre un panel, que es una ventana emergente en forma con controles deslizantes, listas y navegación con el teclado, en lugar de una sugerencia. Cada uno también tiene una tecla de acceso rápido, así que nunca tienes que atinarle a un glifo de 16 píxeles:

| Tecla de acceso rápido | Panel |
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

Los paneles no son lecturas de solo lectura. Son donde realmente haces la cosa:

- **Audio** tiene un control deslizante de volumen principal, un selector de dispositivo de salida y una mezcladora por app, para que puedas bajarle a esa única pestaña del navegador sin tocar todo lo demás.
- **Red** busca redes Wi-Fi, muestra la intensidad de la señal, se conecta y te permite elegir un proveedor de DNS.
- **Bluetooth** enumera tus dispositivos con conectar/desconectar y niveles de batería.
- **Energía** muestra estadísticas de la batería, cambia los perfiles de energía (recuerda una elección por separado para batería y AC) e imprime algo de información del sistema.
- **Pantalla** incluye un control deslizante de brillo, tamaño del texto, valores preestablecidos de escala del monitor y, cuando tienes más de una pantalla, controles por monitor. Consulta [monitores](33-monitors.md) para conocer la historia más a fondo.
- **Reloj** abre una cuadrícula mensual con números de semana ISO y navegación por meses.
- **Reloj mundial** mantiene una fila por ciudad, con su clima y cómo va su día. La búsqueda encuentra pueblos además de zonas horarias, así que Fort Lauderdale es Fort Lauderdale y no New York. Si la línea de arriba nombra la ciudad equivocada, haz clic en ella y di dónde estás; elige un lugar en otra zona horaria y el reloj del sistema también se mueve ahí, lo cual es útil cuando viajas. Pasa el cursor sobre una ciudad y haz clic en el botón de la persona para decir quién vive ahí: nombres simples, o cuentas de GitHub con `@` para traer también sus caras.

Todos los paneles aceptan el teclado además del mouse: las flechas se mueven, Return activa, Tab pasa al panel vecino y Escape cierra.

`Super + Ctrl + 1-9` cuenta los paneles de izquierda a derecha en la sección derecha, saltándose la bandeja porque no tiene un panel propio. Así que el número coincide con el ícono al que apuntarías.

### Tailscale y Dropbox

Aparecen dos widgets más en la barra solo una vez que instalas el servicio correspondiente desde **Instalar → Servicio**, y vale la pena conocerlos porque hacen más que reportar el estado.

El panel de **Tailscale** conecta y desconecta la tailnet, cambia entre cuentas y elige un nodo de salida (tanto tus propias máquinas como las regiones de Mullvad aparecen en esa lista). También explora tus máquinas, y con una seleccionada, `s` le envía archivos a través de Taildrop, que es la forma más rápida de mover un archivo a tu teléfono u otra laptop. `c` copia la IP de la máquina, `n` su nombre y `d` su nombre DNS completo. También hay un botón de enviar en cada fila de máquina, por si prefieres hacer clic. Lo mismo desde la terminal es `omarchy tailscale send <machine> [file...]`.

El panel de **Dropbox** se encarga del inicio de sesión, muestra cuánto almacenamiento has usado y enumera los archivos sincronizados recientemente.

Al eliminar cualquiera de los dos servicios, su widget también se quita de la barra.

## Indicadores

El pequeño grupo en el centro es el widget de indicadores. Estos son glifos de estado para los modos que has activado: no molestar, luz nocturna, un [recordatorio](09-reminders.md) en cola, una grabación de pantalla activa y mantenerse despierto, además de advertencias mientras sudo sin contraseña está activado o alguien está conectado a una sesión remota. Se iluminan cuando el modo está activo y en caso contrario no estorban: pasa el cursor justo al lado de ellos, donde estarían los inactivos, para echarles un vistazo. Al hacer clic en un indicador se activa o desactiva ese modo. Uno más es solo de estado: una sesión remota se ilumina en rojo mientras alguien está conectado a esta máquina a través de gliff.

Si prefieres que siempre estén visibles, establece `alwaysShow` en `true` en el widget. Y si solo te importan algunos de ellos, enumera los que quieres en `items`: `["Dnd", "Reminder", "NightLight"]`. Puedes tener más de un widget de indicadores, para que diferentes secciones puedan mostrar diferentes subconjuntos.

## Reorganizar la barra

La barra se configura sola. No tienes que abrir un archivo de configuración para mover las cosas.

Agarra un pedazo vacío de la barra alrededor del centro y arrástralo hacia otro borde de la pantalla, y la barra se mueve ahí: izquierda, derecha, arriba o abajo funcionan, y todos los widgets se adaptan (las barras verticales recurren a formas compactas de solo ícono). Un clic sostenido inicia el mismo arrastre. Haz doble clic izquierdo en ese mismo espacio vacío para recorrer el fondo de la barra de transparente a translúcido a opaco. Y arrastra cualquier widget para reordenarlo o lanzarlo a otra sección; los demás widgets se abren para hacerle espacio donde va a caer.

El centro de la barra es una caja: lo que sea que esté en ella se mantiene centrado como un solo grupo, y los widgets a cada lado cuelgan de sus bordes. Mientras arrastras un widget, la caja se muestra como un contorno, o como una línea a lo largo de la barra cuando está vacía, y puedes soltar dentro de ella o al lado de ella. Cuando una caída caería en la caja, la caja crece para acoger al widget.

Un widget que quieres cerca pero no siempre a la vista puede ir en el cajón de la bandeja: arrástralo sobre la bandeja, y el cajón se abre para recibirlo. Se queda ahí después de los íconos de las apps, aparece cada vez que aparece el cajón y mantiene su cajón abierto mientras su panel está abierto. Arrástralo de nuevo a la barra para volver a ponerlo.

Si prefieres elegir desde un menú, **Apariencia → Barra de menú** tiene la posición, y **Fondo de la barra** elige cómo se dibuja la barra: **Barra opaca**, **Barra translúcida** (transparente, con lo que hay detrás borroso) o **Barra transparente**.

Las mismas cosas tienen comandos, que es lo que quieres para una configuración de [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Para agregar o quitar un widget por completo, usa los comandos de plugins. `omarchy plugin list` imprime todos los widgets que el shell conoce con su id, y luego:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Ocultar la barra

`Super + Shift + Space` oculta la barra y la vuelve a mostrar sin matar el shell: los paneles y las teclas de acceso rápido siguen funcionando, solo recuperas los píxeles. También está en el menú en **Apariencia → Barra de menú → Ocultar barra**.

## El archivo de configuración

Todo se almacena en `~/.config/omarchy/shell.json`, bajo la clave `bar`. Aquí hay una versión recortada:

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

Cada widget es una entrada en uno de los cinco arreglos de disposición, y su configuración está en línea en esa entrada: no hay un archivo de configuración aparte ni un subobjeto `config`. El `format`, el `formatAlt` del reloj (a lo que el clic derecho recorre) y `verticalFormat` viven todos ahí mismo en `{ "id": "omarchy.clock" }`.

`center` es la caja en el centro de la barra: todo lo que hay en ella está centrado en la pantalla como un solo grupo. `centerBegin` y `centerEnd` cuelgan a cada lado de la caja, que es como el reloj se mantiene justo en el centro incluso cuando el clima y la insignia de actualización van y vienen. Pon más de un widget en `center` y se centran juntos; déjalo vacío y `centerBegin` y `centerEnd` se encuentran en el centro de la barra.

Una regla que vale la pena interiorizar: **una vez que tienes tu propio `shell.json`, es el canónico**. Hasta que personalizas algo, el shell lee el archivo predeterminado de Omarchy. En el momento en que arrastras un widget, ejecutas `omarchy bar` o editas el archivo tú mismo, es tuyo: no hay una fusión profunda, así que los nuevos widgets predeterminados en futuras versiones de Omarchy no aparecerán en tu barra automáticamente. `omarchy bar defaults` vuelve a poner la disposición que viene de fábrica cuando quieras empezar de cero.

El mismo archivo también guarda tus tiempos de inactividad en el nivel superior, fuera de la clave `bar`: `idle.screensaver` e `idle.lock`, ambos en segundos desde que te quedaste inactivo. Así que el protector de pantalla predeterminado entra a los 150 segundos y el bloqueo a los 300.
