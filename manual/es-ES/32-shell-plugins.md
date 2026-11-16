# Plugins del shell

El escritorio de Omarchy se ejecuta como un solo proceso Quickshell de larga vida llamado `omarchy-shell`, y casi todo lo que ves en pantalla es un plugin dentro de él. La barra es un plugin. También lo son los paneles que se despliegan desde ella, las superposiciones de pantalla completa como el selector de emojis y el gestor del portapapeles, el propio menú de Omarchy, la pantalla de bloqueo, el diálogo de polkit y los servicios sin interfaz que vigilan tu batería y dan un tono cálido a tu pantalla por la noche.

Eso no es solo un detalle de implementación: puedes apagar partes del escritorio, intercambiarlas o escribir las tuyas sin tocar una línea del código fuente de Omarchy.

Los plugins oficiales vienen con Omarchy y viven en `$OMARCHY_PATH/shell/plugins/`. Todo lo que añadas tú —tus propios experimentos, o algo que encontraste en GitHub— vive en `~/.config/omarchy/plugins/`. Ambos se descubren de la misma forma al iniciar, pero los integrados reciben interfaces de shell de confianza mientras que los plugins de terceros reciben una interfaz limitada y acotada a su propio servicio y ciclo de vida. Los clones de los integrados conservan solo la configuración y las llamadas de interfaz propias del original que hacen falta para reproducir su comportamiento y las llamadas de interfaz necesarias para el comportamiento original.

## Ver lo que tienes

```
omarchy plugin list
```

Eso imprime cada plugin descubierto con su id, si está habilitado, si es oficial o de terceros, sus tipos y su nombre para mostrar. Añade `--json` si lo vas a pasar a otra cosa.

Los ids de plugin tienen espacio de nombres. Todos los integrados empiezan con `omarchy.` —`omarchy.clock`, `omarchy.network`, `omarchy.notifications`— y ese espacio de nombres está reservado, así que un plugin de terceros nunca puede reclamarlo.

## Activarlos y desactivarlos

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

O usa el menú: _Configurar > Plugins_ tiene Activar, Desactivar, Añadir, Clonar y Quitar, cada uno con un selector que solo ofrece los plugins que tienen sentido para esa acción.

El estado habilitado se guarda en `~/.config/omarchy/shell.json`, y la regla difiere ligeramente para los dos tipos de plugin. Un plugin de terceros está habilitado exactamente cuando su id aparece en algún lugar de ese archivo: como una entrada de distribución de la barra, como una entrada en `plugins[]`, o como `bar.id`. Con los plugins oficiales que no son componentes de la barra pasa lo contrario: están activados por defecto y solo se apagan si se listan en `disabledPlugins[]`.

Un plugin de barra completa no tiene estado apagado en absoluto. Siempre hay exactamente una barra, así que la reemplazas habilitando otra. La colocación de componentes de la barra se cubre en [la barra superior](05-the-top-bar.md).

## Añadir un plugin desde git

Un plugin de terceros es simplemente un repositorio git con un `manifest.json` en su raíz.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Antes de hacer nada, te dice claramente que los plugins se ejecutan como código arbitrario y sin sandbox dentro de tu proceso de shell de larga vida, te muestra la URL y te pide que confirmes. Tómalo en serio. La interfaz de plugins de terceros no expone directamente los servicios de autenticación, y una barra de reemplazo recibe solo capacidades limitadas para la interfaz configurada que no es de autenticación. Los plugins visuales aun así comparten la escena QML del shell y pueden recorrer los objetos padre ordinarios, mientras que todo el código de plugins se ejecuta con todo lo que tu cuenta de usuario puede alcanzar. El estado de autenticación se protege por separado manteniendo esos servicios fuera del grafo de objetos host alcanzable. Solo añade repositorios que estés dispuesto a ejecutar, y léelos antes de habilitarlos.

Una barra de reemplazo puede renderizar los componentes instalados, pero los componentes de terceros respaldados por un servicio pueden tener funcionalidad reducida ahí porque la barra no puede solicitar el objeto de servicio activo de otro plugin. Vuelve a la `omarchy.bar` integrada si ese componente necesita su servicio asociado.

Después clona el repositorio en un directorio temporal, valida el manifiesto, rechaza la instalación si otro plugin ya reclama ese id, y lo mueve a `~/.config/omarchy/plugins/<id>/`. Sin `--enable` te pregunta si quieres que esté activado ahora, y puedes decir que no e ir a leer el código primero. Nunca ejecuta nada del plugin, nunca ejecuta un hook de instalación y nunca pide sudo: clona archivos, revisa el manifiesto y cambia un bit por IPC.

Actualizar es un pull de avance rápido de esa misma copia:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Sin id, actualiza cada plugin gestionado por git que tengas. Te muestra el diff antes de aplicarlo, se niega a actualizar si tienes cambios locales que no puede superar con avance rápido, y revierte si la nueva revisión no pasa la validación.

```
omarchy plugin remove acme.weather
```

La eliminación primero deshabilita el plugin, y luego lo borra si es una copia git (el repositorio sigue en el origen) o lo desenlaza si es un enlace simbólico. Una carpeta de plugin hecha a mano sin repositorio git se mueve a una copia de seguridad con marca de tiempo dentro del directorio de plugins en lugar de borrarse sin más.

## Clonar un integrado para modificarlo

Esta es mi parte favorita. Si quieres cambiar cómo se comporta un componente integrado, no edites los archivos bajo `$OMARCHY_PATH`: esos pertenecen al paquete y la próxima actualización los sobrescribirá. Clónalo en su lugar:

```
omarchy plugin clone omarchy.clock
```

Eso copia todo el plugin a `~/.config/omarchy/plugins/dhh.clock` (tu nombre de usuario, no el mío), lo renombra a "My Clock", lo habilita y pasa el shell del integrado a tu copia, conservando la posición y los ajustes de un componente de barra existente. Añade `--edit` para abrir el directorio nuevo en tu `$EDITOR` de inmediato, que es lo que hace por ti el _Configurar > Plugins > Clonar plugin_ del menú.

El prefijo de nombre de usuario hace que el id de tu clon sea tuyo, así que compartirlo no choca con el de nadie más. Las llamadas hechas al id integrado original se enrutan a tu clon, así que nada que se refiera a `omarchy.clock` necesita actualizarse. Y si haces un desastre, `omarchy plugin remove dhh.clock` vuelve a poner el integrado.

Guardar un archivo en cualquier lugar bajo `~/.config/omarchy/plugins/` recarga el código del plugin automáticamente, así que puedes dejar el editor abierto y ver cómo llegan tus cambios.

## Escribir los tuyos

Un plugin es un directorio con un `manifest.json` y algo de QML. El manifiesto declara `schemaVersion: 1`, un `id`, `name`, `version`, uno o más `kinds`, y un objeto `entryPoints` que apunta al archivo QML de cada tipo:

| Tipo | Qué es |
|------|------------|
| `bar-widget` | Un componente que la barra activa puede poner en una sección |
| `panel` | Una ventana flotante persistente o invocada |
| `overlay` | Una superposición de pantalla completa |
| `menu` | Una superficie de menú invocada |
| `service` | Un singleton sin interfaz |
| `bar` | Una barra completa que reemplaza a la integrada |

Un plugin puede declarar varios tipos a la vez: el plugin de medios es a la vez un `service` y un `bar-widget`. Los componentes de barra reciben un bloque `barWidget` extra con un nombre para mostrar, una categoría, un `defaultSection` opcional y `allowMultiple`, que dice si tiene sentido tener más de uno en la barra. La mayoría de los componentes lo pone en `false`; los espaciadores e indicadores lo ponen en `true`.

Antes de publicar nada, revísalo:

```
omarchy plugin validate ./my-plugin
```

Eso ejecuta las mismas comprobaciones que hace el shell al cargar: la versión del esquema, los campos obligatorios, un id que no esté reservado, puntos de entrada que sean rutas relativas seguras y que realmente existan, un punto de entrada para cada tipo que hayas declarado, y ningún enlace simbólico en ningún lugar dentro de la carpeta.

Para el desarrollo de plugins, consulta la [referencia del shell](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) y el [catálogo de plugins oficiales](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Compartir los tuyos con el mundo

Cuando tengas algo que te guste, ponlo en un repositorio git público. Ese es todo el mecanismo de distribución: cualquiera puede entonces ejecutar `omarchy plugin add` contra tu URL y tenerlo funcionando en segundos.

Para ayudar a que la gente realmente lo encuentre, lístalo en [plugins.omarchy.org](https://plugins.omarchy.org). Ese es el mercado de plugins del shell de Omarchy, y es el primer lugar donde buscar cuando te preguntas si alguien ya construyó el componente que estás a punto de escribir. ¡Explóralo antes de empezar!
