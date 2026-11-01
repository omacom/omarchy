# Funciones de shell

Omarchy viene con un conjunto de funciones de shell para simplificar tareas comunes y encapsular llamadas con parámetros enredados.

## Compresión

- `compress [file/dir]`: Crea un archivo tar.gz a partir del archivo/directorio.
- `decompress [file.tar.gz]`: Expande un archivo tar.gz.

## Unidades

- `iso2sd [image.iso]`: Crea una unidad booteable en una tarjeta SD usando el archivo iso referenciado y eligiendo la unidad de forma interactiva.
- `format-drive [device] [name]`: Formatea un disco entero con una sola partición exFAT (que también funciona en Windows y macOS). Ejecútalo sin argumentos para ver las unidades disponibles. ¡Ten cuidado!

## Layouts de desarrollo

Layouts de desarrollo multipanel instantáneos para tmux:

- `tdl [ai]`: Crea un Tmux Dev Layout con tu editor, un agente de IA y una terminal. Usa los alias de agente, como `tdl c` para opencode o `tdl cx` para Claude Code, o pasa un segundo agente para ejecutar ambos, como `tdl c cx`.
- `tds`: Crea un Tmux Dev Square con editor, monitoreo de diff (con `hunk diff --watch`), terminal y opencode.
- `tdlm [ai]`: Crea una ventana `tdl` para cada subdirectorio en el directorio actual.
- `tsl [count] [command]`: Crea un enjambre de paneles en mosaico en una cuadrícula, todos ejecutando el mismo comando (ideal para agentes de IA).

Los mismos layouts están disponibles para Herdr como `hdl`, `hds`, `hdlm` y `hsl`.

## Worktrees de Git

- `ga [branch]`: Crea un nuevo worktree y una rama junto al repositorio actual y salta a él.
- `gd`: Quita el worktree actual y su rama (pide confirmación primero).

## Observadores de rsync

- `rsw [source] [destination]`: Inicia un observador en segundo plano que sincroniza con rsync el origen al destino cada vez que algo cambia. El destino puede ser un host remoto, como `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Lista todos los observadores activos.
- `dsw`: Detiene todos los observadores activos.

## Reenvío de puertos SSH

Ideal para hacer desarrollo web con privilegios de contexto seguro de localhost contra una computadora remota.

- `fip`: Reenvía uno o más puertos desde un host remoto a localhost vía SSH.
- `dip`: Desconecta uno o más puertos reenviados.
- `lip`: Lista todos los reenvíos de puertos SSH activos.

Digamos que inicias un servidor de desarrollo en el puerto `3000` en una computadora accesible como `nyc-dev`, entonces puedes ejecutar `fip nyc-dev 3000` para reenviar ese puerto, de modo que `localhost:3000` en realidad llegue a `nyc-dev:3000`, pero sin necesidad de certificados SSL para establecer el contexto seguro necesario para probar web sockets o cosas por el estilo.

## Reconexión SSH

`ssh` mismo está envuelto en una función que limpia la terminal si una conexión muere mientras un tmux, Herdr o editor remoto la ha tomado, y luego se reconecta automáticamente cuando una sesión interactiva se cae (Ctrl-C detiene el ciclo de reintentos).
