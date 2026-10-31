# Extracción de texto y dictado

### Extracción de texto

Presiona `Super + Ctrl + PrtScr` para seleccionar una región de la pantalla y extraer su texto. El modelo de OCR de código abierto tesseract convertirá rápidamente esa selección en texto y lo colocará en el portapapeles. Después, solo presiona `Super + V` para pegarlo.

Esto es muy útil para obtener direcciones de pies de imagen o números de teléfono incrustados en titulares de sitios web.

 ![text-extraction](images/text-extraction.webp)

### Dictado

En instalaciones nuevas, [Superwhisper](https://superwhisper.com/) es el backend de dictado predeterminado, que usa procesamiento en la nube sin descargar modelos para usarlos sin conexión. Elige Superwhisper o [Voxtype](https://voxtype.io/) en _Setup > Defaults > Dictation_ dentro del menú de Omarchy. Al seleccionar un backend, este se instala si es necesario y se establece como predeterminado para el dictado. Voxtype carga un modelo base en inglés que ocupa 150MB; cambia el modelo con `voxtype setup model` y otros ajustes en `~/.config/voxtype/config.toml`. Superwhisper abre su configuración para elegir entre procesamiento en la nube o local, y OPR mantiene la aplicación actualizada.

Dictas manteniendo presionado `Right Alt`, o activándolo y desactivándolo con `Alt + Space`, y el texto dictado aparecerá en el área de entrada que tenga el foco. Estos atajos usan el backend seleccionado. Right Alt también inicia el dictado cuando se usa dentro de una combinación con modificadores; usa Left Alt para esas combinaciones. En distribuciones de teclado donde Right Alt es AltGr, usa `Alt + Space` para que AltGr siga disponible al escribir. Las instalaciones anteriores a que Alt + Space se volviera el predeterminado conservan `F9` para pulsar para hablar y `Super + Ctrl + X` para activar y desactivar, agregados a `~/.config/hypr/bindings.lua`; elimínalos ahí para devolver esas teclas a las aplicaciones.

Los mismos atajos funcionan con cualquiera de los dos backends. Selecciona tu backend en Setup > Defaults > Dictation. El instalador del backend lo configura y guarda la selección. Ejecuta `omarchy default dictation` para ver cuál está seleccionado. La selección se guarda en `~/.config/omarchy/defaults/dictation`. Las instalaciones nuevas seleccionan Superwhisper automáticamente.

Omarchy carga automáticamente la integración de escritorio del backend seleccionado. No se necesita ninguna configuración de Superwhisper en `~/.config/hypr/`.

Los atajos personalizados y los scripts pueden usar `omarchy dictation start`, `omarchy dictation stop` y `omarchy dictation toggle`. El backend seleccionado se encarga de la grabación y la transcripción. Seleccionar Superwhisper desactiva su atajo nativo para mantener presionado y establece su alternancia nativa en `Ctrl + Alt + Space`, manteniéndola separada de las teclas de grabación de Omarchy. Superwhisper requiere al menos un atajo nativo de grabación, y su atajo de cancelación sigue disponible.

Se pueden integrar backends adicionales sin cambiar Omarchy. Proporciona un ejecutable llamado `omarchy-dictation-<backend>` en PATH que acepte `start`, `stop` y `toggle`, devuelva el control rápidamente y retorne un estado distinto de cero en caso de error. Su instalador configura el proveedor y llama a `omarchy-dictation-use <backend>` después de una configuración exitosa. Esto detiene el backend anterior y guarda la selección de forma atómica; `stop` debe ejecutarse correctamente cuando el proveedor está inactivo o no está disponible. Los nombres de los backends usan letras minúsculas, dígitos y guiones. Proporciona `omarchy-install-dictation-<backend>` para la instalación; `omarchy default dictation <backend>` lo inicia. Agrega una entrada al menú Defaults mediante una extensión del menú de Omarchy para llamar a ese selector. La integración de escritorio opcional puede estar en `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
