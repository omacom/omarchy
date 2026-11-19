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

La barra mostrará automáticamente tu distribución de teclado actual una vez que tengas varias distribuciones configuradas (y también puedes hacer clic en ella para cambiar).

### ¿Cómo cambio el formato del reloj a 12 horas?

Haz clic derecho en el reloj de la barra para recorrer los formatos comunes, incluidos los de 12 horas. También puedes establecer el formato directamente:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Esto mostrará domingo 10:55 AM.

### ¿Cómo cambio mi zona horaria?

Abre _Configuración > Región > Zona horaria_ en el menú de Omarchy y elige una opción de la lista. Si la zona horaria es correcta pero el reloj se desfasó, _Actualizar > Hora_ reinicia la sincronización de la hora por ti.

### ¿Cómo cambio mi DNS, comparto mi Wi-Fi o reviso la velocidad de mi conexión?

Todo eso está en [redes](35-networking.md).

### ¿Cómo reviso qué tan rápido es mi disco?

_Activador > Prueba de velocidad > Prueba de velocidad del disco_ mide la velocidad de lectura y escritura en vivo de tu unidad, o `omarchy disk speedtest` desde la terminal.

### ¿Cómo agrego una impresora?

La impresión ya está configurada y funcionando desde el inicio, y tú agregas cada impresora desde _Configuración de impresión_ en el lanzador de aplicaciones (`Super + Space`).

Elige _Agregar_ y dale un momento para buscar: una impresora conectada por USB y la mayoría de las impresoras de red se encuentran por ti. Si la tuya no está en la lista, elige _Impresora de red > Internet Printing Protocol (ipp)_ e ingresa su dirección — la pantalla de la propia impresora o su página web te dirá cuál es, normalmente algo como `192.168.1.50` con una cola de `ipp/print`. Luego, _Adelante_ te ofrece un controlador, donde una impresora moderna funciona mejor con el perfil sin controlador _IPP Everywhere_ y una más antigua necesita el controlador propio del modelo.

Haz clic derecho en una impresora y elige _Establecer como predeterminada_ para elegir cuál usarán primero tus aplicaciones, y _Propiedades_ para configurar el tamaño de papel, el dúplex y la calidad.

El descubrimiento automático, donde las impresoras de la red aparecen sin agregarlas, está desactivado temporalmente mientras se está reelaborando, por lo que el primer paso anterior te toca a ti y no es automático. Imprimir a un archivo PDF funciona sin ninguna impresora.

### ¿Cómo cambio dónde se guardan las capturas de pantalla o las grabaciones de pantalla?

Las capturas de pantalla guardadas van a `~/Pictures/Screenshots` por defecto. Para usar otro directorio, agrega esto a un archivo en `~/.config/uwsm/env.d/` (como `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Puedes hacer lo mismo para las grabaciones de pantalla usando `OMARCHY_SCREENRECORD_DIR`.

Omasnap crea su directorio de capturas de pantalla automáticamente. Crea tú mismo el directorio de grabaciones de pantalla y luego reinicia Omarchy para que cualquiera de los cambios de entorno surta efecto.

### ¿Cómo hago que funcionen las bocinas + la cámara web en mi Apple Studio Display?

Pensarías que todo debería funcionar solo con conectar el USB C, pero por desgracia no es así. La solución que encontré para que funcione de manera confiable es usar [el cable WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Luego las bocinas y la cámara web funcionan de maravilla.

Recuerda que tienes control de brillo integrado en Omarchy para las pantallas Apple (tanto Studio como XDR) usando los botones normales de brillo del teclado.

### ¿Cómo me deshago de todo el software extra?

Si no quieres programas como Obsidian o LibreOffice ni ninguna de las demás cosas preinstaladas, puedes quitarlas muy fácilmente.

Abre _Quitar > Paquete_ para ver todos los paquetes instalados. Luego puedes seleccionar con tab cualquier paquete que quieras quitar, y empezar a quitar todo lo que seleccionaste con return.

Y puedes usar _Quitar > Aplicación web_ desde el menú de Omarchy para quitar cualquiera de las aplicaciones web preinstaladas que no quieras.

O ejecuta _Quitar > Preinstalados_ para sacar de una vez todos los extras preinstalados — aplicaciones web, TUI y aplicaciones opcionales —. Los atajos de teclado que las abrían desaparecen con ellas, así que te queda una lista limpia de atajos para llenarla con los tuyos en `~/.config/hypr/bindings.lua`.

---

Para errores y partes que no funcionan, consulta [la sección de solución de problemas](45-troubleshooting.md).
