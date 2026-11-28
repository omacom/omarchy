# FAQ

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

Esto mostrará Domingo 10:55 AM.

### ¿Cómo cambio mi zona horaria?

Ejecuta _Configuración > Región > Zona horaria_ en el menú de Omarchy y elige de la lista. Si la zona horaria es correcta pero el reloj en sí se desvió, _Actualizar > Hora_ reinicia la sincronización de la hora por ti.

### ¿Cómo cambio mi DNS, comparto mi Wi-Fi o reviso la velocidad de mi conexión?

Todo eso está en [redes](35-networking.md).

### ¿Cómo reviso qué tan rápido es mi disco?

_Activar > Prueba de velocidad > Prueba de velocidad de disco_ mide la velocidad de lectura y escritura en vivo en tu unidad, o `omarchy disk speedtest` desde la terminal.

### ¿Cómo agrego una impresora?

La impresión ya está configurada y funcionando desde el inicio, y agregas cada impresora tú mismo desde _Configuración de impresión_ en el lanzador de aplicaciones (`Super + Alt + Space`).

Elige _Agregar_ y dale un momento para buscar: una impresora conectada por USB, y la mayoría de las impresoras de red, se encuentran por ti. Si la tuya no está en la lista, elige _Impresora de red > Internet Printing Protocol (ipp)_ e ingresa su dirección — la propia pantalla de la impresora o su página web te dirá cuál es, normalmente algo como `192.168.1.50` con una cola de `ipp/print`. _Adelante_ luego te ofrece un controlador, donde una impresora moderna funciona mejor con el perfil sin controlador _IPP Everywhere_ y una más antigua quiere el controlador propio del modelo.

Haz clic derecho en una impresora y elige _Establecer como predeterminada_ para elegir a cuál recurren primero tus aplicaciones, y _Propiedades_ para establecer el tamaño de papel, la impresión a doble cara y la calidad.

El descubrimiento automático, donde las impresoras de la red aparecen sin agregarlas, está desactivado temporalmente mientras se está rehaciendo, por eso el primer paso anterior es tuyo y no automático. Imprimir a un archivo PDF funciona sin ninguna impresora.

### ¿Cómo cambio dónde se guardan las capturas de pantalla o las grabaciones de pantalla?

Las capturas de pantalla guardadas van a `~/Pictures/Screenshots` de forma predeterminada. Para usar otro directorio, agrega esto a un archivo bajo `~/.config/uwsm/env.d/` (como `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Puedes hacer lo mismo para las grabaciones de pantalla usando `OMARCHY_SCREENRECORD_DIR`.

Omasnap crea su directorio de capturas de pantalla automáticamente. Crea tú mismo el directorio de grabaciones de pantalla y luego reinicia Omarchy para que cualquiera de los dos cambios de entorno surta efecto.

### ¿Cómo hago que funcionen las bocinas + la cámara web en mi Apple Studio Display?

Pensarías que todo debería funcionar solo con conectar el USB C, pero desafortunadamente no es así. La solución que encontré para que funcione de forma confiable es usar [el cable WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Luego las bocinas y la cámara web funcionan de maravilla.

Recuerda que tienes control de brillo integrado en Omarchy para las pantallas Apple (tanto Studio como XDR) usando los botones normales de brillo del teclado.

### ¿Cómo me deshago de todo el software extra?

Si no quieres programas como Obsidian o LibreOffice o cualquiera de las demás cosas preinstaladas, puedes quitarlo muy fácilmente.

Ejecuta _Eliminar > Paquete_ para ver todos los paquetes que están instalados. Luego puedes seleccionar cualquier paquete que quieras eliminar con tab, y empezar a eliminar todo lo que hayas seleccionado con return.

Y puedes usar _Eliminar > Aplicación web_ desde el menú de Omarchy para eliminar cualquiera de las aplicaciones web preinstaladas que no quieras.

O ejecuta _Eliminar > Preinstalados_ para barrer con todos los extras preinstalados — aplicaciones web, TUIs y aplicaciones opcionales — de una sola vez. Los atajos de teclado que los lanzaban desaparecen con ellos, así que te queda una hoja en blanco de atajos para llenarla con los tuyos en `~/.config/hypr/bindings.lua`.

---

Para errores y cosas rotas, consulta [la sección de solución de problemas](45-troubleshooting.md).
