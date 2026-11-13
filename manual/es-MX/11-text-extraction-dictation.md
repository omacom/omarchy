# Extracción de texto y dictado

### Extracción de texto

Presiona `Super + Ctrl + PrtScr` para seleccionar una región de la pantalla para la extracción de texto. El modelo OCR de código abierto tesseract convertirá rápidamente esa selección en texto y lo colocará en el portapapeles. Luego solo presiona `Super + V` para pegarlo.

Esto es muy útil para extraer direcciones de pies de imágenes o números de teléfono incrustados en titulares de sitios web.

 ![text-extraction](images/text-extraction.webp)

### Dictado

En instalaciones nuevas, [Superwhisper](https://superwhisper.com/) es el backend de dictado predeterminado, con procesamiento en la nube sin descargas de modelos sin conexión. Elige Superwhisper, [Voxtype](https://voxtype.io/) o [Hex](https://anoma.ly/hex/) desde _Configuración > Predeterminados > Dictado_ en el menú de Omarchy. Seleccionar un backend lo instala si es necesario y lo convierte en el predeterminado para el dictado. Voxtype carga un modelo base en inglés que ocupa 150MB; cambia el modelo con `voxtype setup model` y otros ajustes mediante `~/.config/voxtype/config.toml`. Superwhisper abre su configuración para elegir el procesamiento en la nube o local, y OPR mantiene la aplicación actualizada. Hex descarga su modelo de voz en el dispositivo durante la configuración y se ejecuta como el servicio de usuario `hex.service`; abre su ventana desde el ícono de la bandeja de la barra o ejecutando `hex` para cambiar el modelo y otros ajustes.

Dictas manteniendo presionada `Right Alt`, o activando y desactivando con `Alt + Space`, y el texto dictado aparecerá en el área de entrada enfocada. Estos atajos usan el backend seleccionado. Right Alt también inicia el dictado cuando se usa en una combinación con modificadores; usa Left Alt para esas combinaciones. En distribuciones de teclado donde Right Alt es AltGr, usa `Alt + Space` para mantener AltGr disponible para escribir. Las instalaciones anteriores a que Alt + Space se convirtiera en el predeterminado conservan `F9` para pulsar para hablar y `Super + Ctrl + X` para activar y desactivar, agregados a `~/.config/hypr/bindings.lua`, donde ese `Super + Ctrl + X` ocupa el lugar del panel de agentes; elimínalos ahí para devolver esas teclas a las aplicaciones y al panel.

Los mismos atajos funcionan con todos los backends. Selecciona tu backend desde Configuración > Predeterminados > Dictado. El instalador del backend lo configura y guarda la selección. Ejecuta `omarchy default dictation` para ver cuál está seleccionado. La selección se guarda en `~/.config/omarchy/defaults/dictation`. Las instalaciones nuevas seleccionan Superwhisper automáticamente.

Omarchy carga automáticamente la integración de escritorio del backend seleccionado. No se necesita ninguna configuración de Superwhisper en `~/.config/hypr/`.

Los enlaces personalizados y los scripts pueden usar `omarchy dictation start`, `omarchy dictation stop` y `omarchy dictation toggle`. El backend seleccionado se encarga de la grabación y la transcripción. Seleccionar Superwhisper desactiva su atajo nativo de mantener presionado y establece su activación nativa en `Ctrl + Alt + Space`, manteniéndola separada de las teclas de grabación de Omarchy. Superwhisper requiere al menos un atajo de grabación nativo, y su atajo de cancelación sigue disponible.

Se pueden integrar backends adicionales sin cambiar Omarchy. Proporciona un ejecutable llamado `omarchy-dictation-<backend>` en PATH que acepte `start`, `stop` y `toggle` y responda rápidamente, con un estado distinto de cero en caso de error. Su instalador configura el proveedor y llama a `omarchy-dictation-use <backend>` después de una configuración exitosa. Esto detiene el backend anterior y guarda la selección de forma atómica; `stop` debe tener éxito cuando el proveedor está inactivo o no está disponible. Los nombres de backend usan letras minúsculas, dígitos y guiones. Proporciona `omarchy-install-dictation-<backend>` para la configuración; `omarchy default dictation <backend>` lo inicia. Agrega una entrada al menú Predeterminados mediante una extensión del menú de Omarchy para llamar a ese selector. La integración de escritorio opcional puede estar en `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
