# Extracción de texto y dictado

### Extracción de texto

Presiona `Super + Ctrl + PrtScr` para seleccionar una región en la pantalla para extraer texto. El modelo de OCR de código abierto tesseract convertirá rápidamente esa selección en texto y lo colocará en el portapapeles. Luego solo presiona `Super + V` para pegarlo.

Esto es muy útil para obtener direcciones de pies de página en imágenes o números de teléfono incrustados en encabezados de sitios web.

 ![text-extraction](images/text-extraction.webp)

### Dictado

En instalaciones nuevas, [Superwhisper](https://superwhisper.com/) es el backend de dictado predeterminado, con procesamiento en la nube sin descargas de modelos sin conexión. Elige Superwhisper, [Voxtype](https://voxtype.io/) o [Hex](https://anoma.ly/hex/) a través de _Setup > Defaults > Dictation_ en el menú de Omarchy. Al seleccionar un backend, se instala si es necesario y se convierte en el predeterminado para el dictado. Voxtype carga un modelo base en inglés que ocupa 150MB; cambia el modelo con `voxtype setup model` y otros ajustes a través de `~/.config/voxtype/config.toml`. Superwhisper abre su configuración para elegir entre procesamiento en la nube o local, y OPR mantiene actualizada la aplicación. Hex descarga su modelo de voz en el dispositivo durante la configuración y se ejecuta como el servicio de usuario `hex.service`; abre su ventana desde el ícono de la bandeja de la barra o ejecutando `hex` para cambiar el modelo y otros ajustes.

Dictas manteniendo presionado `Right Alt`, o activando y desactivando con `Alt + Space`, y el texto dictado aparecerá en el campo de entrada activo. Estos atajos usan el backend seleccionado. Right Alt también inicia el dictado cuando se usa en una combinación con modificadores; usa Left Alt para esas combinaciones. En distribuciones de teclado en las que Right Alt es AltGr, incluso cuando cambias a una distribución así, mantenlo presionado solo por un momento para dictar; AltGr presionado junto con otra tecla sigue escribiendo su carácter. Las instalaciones previas a que Alt + Space se volviera el predeterminado conservan `F9` para pulsar para hablar y `Super + Ctrl + X` para activar y desactivar, agregados a `~/.config/hypr/bindings.lua`, donde ese `Super + Ctrl + X` ocupa el lugar del panel de agentes; quítalos de ahí para devolverles esas teclas a las aplicaciones y al panel.

Los mismos atajos funcionan con todos los backends. Selecciona tu backend a través de Setup > Defaults > Dictation. El instalador del backend lo configura y guarda la selección. Ejecuta `omarchy default dictation` para ver cuál está seleccionado. La selección se guarda en `~/.config/omarchy/defaults/dictation`. Las instalaciones nuevas seleccionan Superwhisper automáticamente.

Omarchy carga automáticamente la integración de escritorio del backend seleccionado. No se necesita ninguna configuración de Superwhisper en `~/.config/hypr/`.

Las asignaciones de teclas personalizadas y los scripts pueden usar `omarchy dictation start`, `omarchy dictation stop` y `omarchy dictation toggle`. El backend seleccionado se encarga de la grabación y la transcripción. Al seleccionar Superwhisper se desactiva su atajo nativo de mantener presionado y su atajo nativo de activación se establece en `Ctrl + Alt + Space`, lo que lo mantiene separado de las teclas de grabación de Omarchy. Superwhisper requiere al menos un atajo nativo de grabación, y su atajo de cancelación sigue disponible.

Pueden integrarse backends adicionales sin modificar Omarchy. Proporciona un ejecutable con el nombre `omarchy-dictation-<backend>` en PATH que acepte `start`, `stop` y `toggle` y finalice de inmediato, con un código de salida distinto de cero si falla. Su instalador configura el proveedor y llama a `omarchy-dictation-use <backend>` tras una instalación exitosa. Esto detiene el backend anterior y guarda la selección de forma atómica; `stop` debe completarse sin error cuando el proveedor está inactivo o no está disponible. Los nombres de los backends usan letras minúsculas, dígitos y guiones. Proporciona `omarchy-install-dictation-<backend>` para la instalación; `omarchy default dictation <backend>` lo inicia. Agrega una entrada en el menú Defaults mediante una extensión del menú de Omarchy para llamar a ese selector. La integración opcional con el escritorio puede vivir en `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
