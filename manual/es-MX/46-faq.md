# Preguntas frecuentes

### ¿Cómo cambio entre distribuciones de teclado?

Edita tu archivo `~/.config/hypr/input.lua` y agrega esto para cambiar entre distribuciones con `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

La barra mostrará automáticamente tu distribución de teclado actual una vez que tengas configuradas varias distribuciones (y también puedes hacer clic en ella para cambiar).

### ¿Cómo cambio el formato del reloj a 12 horas?

Haz clic derecho en el reloj de la barra para recorrer los formatos comunes, incluidos los de 12 horas. También puedes establecer el formato directamente:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Esto mostrará domingo 10:55 AM.

### ¿Cómo cambio mi zona horaria?

Ejecuta _Update > Timezone_ en el menú de Omarchy y elige de la lista. Si la zona horaria es correcta pero el reloj en sí se desfasó, _Update > Time_ reinicia la sincronización de la hora por ti.

### ¿Cómo cambio mi DNS, comparto mi Wi-Fi o reviso la velocidad de mi conexión?

Todo eso está en [redes](35-networking.md).

### ¿Cómo reviso qué tan rápido es mi disco?

_Trigger > Speed Test > Disk Speed Test_ mide la velocidad de lectura y escritura en tiempo real de tu unidad, o `omarchy disk speedtest` desde la terminal.

### ¿Cómo agrego una impresora?

La impresión ya está configurada y funcionando desde el inicio, y tú agregas cada impresora desde _Print Settings_ en el lanzador de aplicaciones (`Super + Space`).

Elige _Add_, y dale un momento para buscar: detecta por ti una impresora conectada por USB y a la mayoría de las impresoras de red. Si la tuya no está en la lista, elige _Network Printer > Internet Printing Protocol (ipp)_ e ingresa su dirección — la propia pantalla de la impresora o su página web te dirá cuál es, normalmente algo como `192.168.1.50` con una cola de `ipp/print`. _Forward_ luego te ofrece un controlador, donde una impresora moderna funciona mejor con el perfil sin controladores _IPP Everywhere_ y una más antigua quiere el controlador propio del modelo.

Haz clic derecho en una impresora y elige _Set as Default_ para elegir cuál usarán primero tus aplicaciones, y _Properties_ para configurar el tamaño de papel, la impresión a doble cara y la calidad.

La detección automática, con la que las impresoras en la red aparecen sin tener que agregarlas, está desactivada temporalmente mientras se está rehaciendo, por eso el primer paso anterior te toca a ti y no es automático. Imprimir a un archivo PDF funciona sin ninguna impresora.

### ¿Cómo cambio dónde se guardan las capturas de pantalla o las grabaciones de pantalla?

Las capturas de pantalla guardadas van a `~/Pictures/Screenshots` de forma predeterminada. Para usar otro directorio, agrega esto a un archivo dentro de `~/.config/uwsm/env.d/` (como `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Puedes hacer lo mismo para las grabaciones de pantalla usando `OMARCHY_SCREENRECORD_DIR`.

Omasnap crea su directorio de capturas de pantalla automáticamente. Crea tú mismo el directorio de grabaciones de pantalla y luego reinicia Omarchy para que cualquiera de los dos cambios de entorno surta efecto.

### ¿Cómo hago que funcionen las bocinas + la cámara web en mi Apple Studio Display?

Uno pensaría que todo debería funcionar con solo conectar el USB C, pero desafortunadamente no es así. La solución que encontré para que funcione de forma confiable es usar [el cable WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Entonces las bocinas y la cámara web funcionan de maravilla.

Recuerda que tienes control de brillo integrado en Omarchy para las pantallas Apple (tanto Studio como XDR) usando los botones normales de brillo del teclado.

### ¿Cómo me deshago de todo el software extra?

Si no quieres programas como Obsidian o LibreOffice o cualquiera de las demás cosas preinstaladas, puedes eliminarlas muy fácilmente.

Ejecuta _Remove > Package_ para ver todos los paquetes instalados. Luego puedes seleccionar cualquier paquete que quieras eliminar con tab, y empezar a eliminar todo lo que seleccionaste con return.

Y puedes usar _Remove > Web App_ desde el menú de Omarchy para eliminar cualquiera de las aplicaciones web preinstaladas que no quieras.

O ejecuta _Remove > Preinstalls_ para barrer con todos los extras preinstalados — aplicaciones web, TUIs y aplicaciones opcionales — de una sola vez. Los atajos de teclado que las abrían desaparecen con ellos, así que te queda una hoja en blanco de asignaciones para llenarla con las tuyas en `~/.config/hypr/bindings.lua`.

---

Para errores y cosas rotas, consulta [la sección de solución de problemas](45-troubleshooting.md).
