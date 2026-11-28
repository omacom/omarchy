# Extracción de texto y dictado

### Extracción de texto

Pulsa `Super + Ctrl + PrtScr` para seleccionar una región de la pantalla de la que extraer texto. El modelo OCR de código abierto tesseract convertirá rápidamente esa selección en texto y lo colocará en el portapapeles. Después solo pulsa `Super + V` para pegar.

Esto resulta muy útil para sacar direcciones de los pies de las imágenes o números de teléfono incrustados en los titulares de una web.

 ![text-extraction](images/text-extraction.webp)

### Dictado

En las instalaciones nuevas, [Superwhisper](https://superwhisper.com/) es el backend de dictado predeterminado y usa procesamiento en la nube, sin descargas de modelos para uso sin conexión. Elige Superwhisper, [Voxtype](https://voxtype.io/) o [Hex](https://anoma.ly/hex/) mediante _Configurar > Predeterminados > Dictado_ en el menú de Omarchy. Al seleccionar un backend, este se instala si es necesario y se convierte en el predeterminado para el dictado. Voxtype carga un modelo básico en inglés que ocupa 150MB; cambia el modelo con `voxtype setup model` y otros ajustes mediante `~/.config/voxtype/config.toml`. Superwhisper abre sus ajustes para elegir entre procesamiento en la nube o local, y OPR mantiene la aplicación actualizada. Hex descarga su modelo de voz para el dispositivo durante la configuración y se ejecuta como el servicio de usuario `hex.service`; abre su ventana desde el icono de la bandeja de la barra superior o ejecutando `hex` para cambiar el modelo y otros ajustes.

Dictas manteniendo pulsado `Right Alt`, o activando y desactivando con `Alt + Space`, y el texto dictado aparecerá en el campo de entrada activo. Estos atajos usan el backend seleccionado. Right Alt también inicia el dictado cuando se usa en una combinación con modificadores; usa Left Alt para esas combinaciones. En distribuciones de teclado en las que Right Alt es AltGr, incluso cuando cambias a una distribución así, mantenlo pulsado solo por un momento para dictar; AltGr pulsado junto con otra tecla sigue escribiendo su carácter. Las instalaciones previas a que Alt + Space se volviera el predeterminado conservan `F9` para pulsar para hablar y `Super + Ctrl + X` para activar y desactivar, añadidos a `~/.config/hypr/bindings.lua`, donde ese `Super + Ctrl + X` ocupa el lugar del panel de agentes; quítalos de ahí para devolverles esas teclas a las aplicaciones y al panel.

Los mismos atajos funcionan con todos los backends. Selecciona tu backend mediante Configurar > Predeterminados > Dictado. El instalador del backend lo configura y guarda la selección. Ejecuta `omarchy default dictation` para ver cuál está seleccionado. La selección se guarda en `~/.config/omarchy/defaults/dictation`. Las instalaciones nuevas seleccionan Superwhisper automáticamente.

Omarchy carga automáticamente la integración de escritorio del backend seleccionado. No se necesita ninguna configuración de Superwhisper en `~/.config/hypr/`.

Las asignaciones de teclas y los scripts personalizados pueden usar `omarchy dictation start`, `omarchy dictation stop` y `omarchy dictation toggle`. El backend seleccionado se encarga de la grabación y la transcripción. Al seleccionar Superwhisper, se desactiva su atajo nativo para mantener pulsado y su activación nativa se fija en `Ctrl + Alt + Space`, separada de las teclas de grabación de Omarchy. Superwhisper requiere al menos un atajo nativo de grabación, y su atajo de cancelación sigue disponible.

Los backends adicionales pueden integrarse sin cambiar Omarchy. Proporciona un ejecutable llamado `omarchy-dictation-<backend>` en PATH que acepte `start`, `stop` y `toggle` y responda rápidamente, con un estado distinto de cero en caso de error. Su instalador configura el proveedor y llama a `omarchy-dictation-use <backend>` cuando la configuración ha ido bien. Esto detiene el backend anterior y guarda la selección de forma atómica; `stop` debe completarse correctamente cuando el proveedor está inactivo o no está disponible. Los nombres de backend usan letras minúsculas, dígitos y guiones. Proporciona `omarchy-install-dictation-<backend>` para la configuración; `omarchy default dictation <backend>` lo inicia. Añade una entrada al menú de valores predeterminados mediante una extensión del menú de Omarchy para llamar a ese selector. La integración opcional de escritorio puede residir en `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
