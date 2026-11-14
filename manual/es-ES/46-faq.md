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

Esto mostrará Domingo 10:55 AM.

### ¿Cómo cambio mi zona horaria?

Ejecuta _Actualizar > Zona horaria_ en el menú de Omarchy y elige de la lista. Si la zona horaria es correcta pero el reloj mismo se desfasó, _Actualizar > Hora_ reinicia la sincronización de la hora por ti.

### ¿Cómo cambio mi DNS, comparto mi Wi-Fi o reviso la velocidad de mi conexión?

Todo eso vive en [redes](35-networking.md).

### ¿Cómo reviso qué tan rápido es mi disco?

_Activar > Prueba de velocidad > Prueba de velocidad de disco_ mide la velocidad de lectura y escritura en vivo de tu unidad, o `omarchy disk speedtest` desde la terminal.

### ¿Por qué no puedo iniciar sesión en mi cuenta de Google en Chromium?

La versión de código abierto de Chromium no trae las credenciales OAuth que Google requiere para iniciar sesión en una cuenta. Ejecuta _Instalar > Servicio > Cuenta de Chromium_ en el menú de Omarchy para agregarlas, reinicia el navegador y el inicio de sesión pasará.

### ¿Cómo agrego una impresora?

La impresión ya está configurada y funcionando desde el inicio, y agregas cada impresora tú mismo desde _Print Settings_ en el lanzador de aplicaciones (`Super + Space`).

Elige _Add_ y dale un momento para buscar: una impresora conectada por USB, y la mayoría de las impresoras de red, se encuentran por ti. Si la tuya no está en la lista, elige _Network Printer > Internet Printing Protocol (ipp)_ e ingresa su dirección: la propia pantalla de la impresora o su página web te dirá cuál es, normalmente algo como `192.168.1.50` con una cola de `ipp/print`. _Forward_ luego ofrece un controlador, donde una impresora moderna funciona mejor con el perfil sin controlador _IPP Everywhere_ y una más viejita quiere el controlador propio del modelo.

Haz clic derecho en una impresora y elige _Set as Default_ para elegir cuál buscarán primero tus apps, y _Properties_ para establecer el tamaño de papel, el dúplex y la calidad.

El descubrimiento automático, donde las impresoras en la red aparecen sin ser agregadas, está desactivado temporalmente mientras se está rehaciendo, y por eso el primer paso de arriba es tuyo en lugar de automático. Imprimir a un archivo PDF funciona sin ninguna impresora.

### ¿Cómo cambio dónde se guardan las capturas de pantalla o las grabaciones de pantalla?

Las capturas de pantalla guardadas van a `~/Pictures/Screenshots` por defecto. Para usar otro directorio, agrega esto a un archivo en `~/.config/uwsm/env.d/` (como `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Puedes hacer lo mismo para las grabaciones de pantalla usando `OMARCHY_SCREENRECORD_DIR`.

Omasnap crea su directorio de capturas de pantalla automáticamente. Crea tú mismo el directorio de grabaciones de pantalla y luego reinicia Omarchy para que cualquiera de los dos cambios de entorno surta efecto.

### ¿Cómo hago funcionar las bocinas y la webcam de mi Apple Studio Display?

Pensarías que todo debería funcionar conectando el USB C, pero por desgracia no es así. La solución que he encontrado para que funcione de manera confiable es usar [el cable WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Entonces las bocinas y la webcam funcionan de maravilla.

Recuerda que tienes control de brillo integrado en Omarchy para las pantallas Apple (tanto la Studio como la XDR) usando los botones normales de brillo del teclado.

### ¿Cómo me deshago de todo el software extra?

Si no quieres programas como Obsidian o LibreOffice o cualquiera de las demás cosas preinstaladas, puedes quitarlos muy fácilmente.

Ejecuta _Quitar > Paquete_ para ver cada paquete que está instalado. Luego puedes seleccionar con Tab cualquier paquete que quieras quitar y empezar a eliminar todo lo que seleccionaste con Enter.

Y puedes usar _Quitar > App web_ desde el menú de Omarchy para quitar cualquiera de las apps web preinstaladas que no quieras.

O bien ejecuta _Quitar > Preinstalados_ para barrer con todos los extras preinstalados —apps web, TUIs y aplicaciones opcionales— de una vez. Los atajos de teclado que las abrían desaparecen con ellas, así que te queda una pizarra limpia de atajos para llenar con los tuyos en `~/.config/hypr/bindings.lua`.

---

Para errores y cosas rotas, consulta [la sección de Solución de problemas](45-troubleshooting.md).
