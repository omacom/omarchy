# Extracción de texto y dictado

### Extracción de texto

Presiona `Super + Ctrl + PrtScr` para seleccionar una región de la pantalla para extraer texto. El modelo OCR de código abierto tesseract convertirá rápidamente esa selección en texto y la colocará en el portapapeles. Luego solo presionas `Super + V` para pegar.

Esto es muy útil para sacar direcciones de pies de página en imágenes o números de teléfono incrustados en encabezados de sitios web.

 ![text-extraction](images/text-extraction.webp)

### Dictado

En instalaciones nuevas, [Superwhisper](https://superwhisper.com/) es el motor de dictado predeterminado, usando procesamiento en la nube sin descargas de modelos locales. Elige Superwhisper o [Voxtype](https://voxtype.io/) en _Configurar > Predeterminados > Dictado_ en el menú de Omarchy. Al seleccionar un motor, se instala si hace falta y queda como el predeterminado para el dictado. Voxtype carga un modelo base en inglés que ocupa 150 MB; cambia el modelo con `voxtype setup model` y otros ajustes en `~/.config/voxtype/config.toml`. Superwhisper abre sus ajustes para elegir procesamiento en la nube o local, y OPR mantiene la aplicación actualizada.

Dictas manteniendo presionado `Right Alt` o `F9`, o alternando con `Super + Ctrl + X`, y el texto dictado aparecerá en el área de entrada enfocada. Estos atajos usan el motor seleccionado. Right Alt también inicia el dictado cuando se usa en una combinación con modificadores; usa Left Alt para esas combinaciones. En distribuciones de teclado donde Right Alt es AltGr, usa `F9` para mantener AltGr disponible para escribir.

Los mismos atajos funcionan con cualquiera de los dos motores. Selecciona tu motor en Configurar > Predeterminados > Dictado. El instalador del motor lo configura y guarda la selección. Ejecuta `omarchy default dictation` para ver cuál está seleccionado. La selección se guarda en `~/.config/omarchy/defaults/dictation`. Las instalaciones nuevas seleccionan Superwhisper automáticamente.

Omarchy carga automáticamente la integración de escritorio del motor seleccionado. No se necesita ninguna configuración de Superwhisper en `~/.config/hypr/`.

Las asignaciones y scripts personalizados pueden usar `omarchy dictation start`, `omarchy dictation stop` y `omarchy dictation toggle`. El motor seleccionado se encarga de la grabación y la transcripción. Al seleccionar Superwhisper se desactiva su atajo nativo de mantener presionado y su alternancia nativa se fija en `Alt + Space`, manteniéndola separada de las teclas de grabación de Omarchy. Superwhisper requiere al menos un atajo nativo de grabación, y su atajo de cancelación sigue disponible.

Se pueden integrar motores adicionales sin cambiar Omarchy. Proporciona un ejecutable llamado `omarchy-dictation-<backend>` en el PATH que acepte `start`, `stop` y `toggle` y responda rápido, con un estado distinto de cero en caso de error. Su instalador configura el proveedor y llama a `omarchy-dictation-use <backend>` después de una configuración exitosa. Esto detiene el motor anterior y guarda la selección de forma atómica; `stop` debe tener éxito cuando el proveedor está inactivo o no disponible. Los nombres de motor usan letras minúsculas, dígitos y guiones. Proporciona `omarchy-install-dictation-<backend>` para la instalación; `omarchy default dictation <backend>` lo ejecuta. Agrega una entrada al menú Predeterminados mediante una extensión del menú de Omarchy para llamar a ese selector. La integración opcional con el escritorio puede vivir en `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
