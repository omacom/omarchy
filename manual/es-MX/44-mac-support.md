# Soporte para Mac

## Omarchy para Apple Silicon

Omarchy para Apple Silicon es una solución oficial de Omacom, lanzada por primera vez con Omarchy 4.5. Se instala junto a macOS, y eliges entre los dos cuando tu Mac arranca.

¿Recibiste un aviso sobre Omarchy Mac? Ve a [Si vienes de Omarchy Mac](#coming-from-omarchy-mac).

Funciona en estas Mac:

| Mac | Chips |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Las Mac con M4 y posteriores aún no son compatibles. El soporte para M4 está en pruebas en el canal edge y viene después. El instalador revisa tu Mac antes de cambiar algo.

En cualquier Mac con Apple Silicon, incluidas las M4 y posteriores, puedes ejecutar Omarchy en una máquina virtual con [Try Omarchy](https://github.com/omacom/try-omarchy).

### Qué necesitas

- macOS 15 Sequoia o posterior, y una cuenta de administrador
- Espacio libre en disco para Omarchy. El instalador sugiere un tamaño y te permite cambiarlo.
- Una copia de seguridad de tu Mac, energía y una conexión a internet. La instalación descarga varios gigabytes.

### Instalación

La instalación se hace desde macOS. Instala el Instalador de Omarchy con [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

O descarga el Instalador de Omarchy más reciente desde su [página de lanzamientos](https://github.com/omacom/omarchy-mac-installer/releases) y ábrelo.

El instalador revisa tu Mac, te muestra el plan y hace espacio para Omarchy reduciendo la partición de macOS. macOS permanece en el disco y no se necesita ninguna unidad USB. Cuando termina la primera etapa, te guía para terminar la configuración en macOS Recovery: apaga, mantén presionado el botón de encendido hasta que aparezca "Loading startup options", elige Omarchy y sigue los pasos.

En el primer arranque, Omarchy te pide una contraseña que cifra su disco. No hay clave de recuperación: si olvidas la contraseña, tus archivos de Omarchy no se podrán recuperar.

Para cambiar entre Omarchy y macOS después, apaga, luego mantén presionado el botón de encendido hasta que aparezcan las opciones de arranque y elige uno.

### Si vienes de Omarchy Mac

Omarchy Mac ahora forma parte de Omarchy para Apple Silicon, y todas las Mac que lo ejecutaron son compatibles. Tu instalación actual sigue funcionando y sus paquetes del sistema se siguen actualizando, pero ya no recibe actualizaciones de Omarchy. No hay fecha límite ni actualización en el lugar: haces una copia de seguridad, quitas la instalación anterior, instalas desde cero y restauras. Los pasos 2 a 5 se hacen en macOS, así que abre esta página en tu teléfono antes de reiniciar.

1. **Haz una copia de seguridad desde Omarchy, fuera de la Mac.** Quitar la instalación anterior la borra, y macOS no puede leer el disco de Omarchy. Copia tu carpeta personal a una unidad externa u otra computadora, incluidas las claves SSH y GPG, los perfiles del navegador y el trabajo sin subir. Guarda tu lista de paquetes con `pacman -Qqe > ~/packages.txt`. Haz también una copia de seguridad de macOS, ya que tanto quitar como instalar redimensionan su disco.
2. **Arranca tu Mac en macOS.** Apaga, mantén presionado el botón de encendido hasta que aparezcan las opciones de arranque y elige macOS.
3. **Instala el Instalador de Omarchy** como se muestra en [Instalación](#installing).
4. **Quita la instalación anterior.** Abre el Instalador de Omarchy y elige Installation > Remove Omarchy. Te muestra qué eliminará y devuelve el espacio a macOS. Si no reconoce tu instalación, se detiene sin cambiar el disco. Pide ayuda en [Discord](https://discord.gg/tXFUdasqhY) en lugar de eliminar particiones a mano, lo que puede borrar macOS.
5. **Instala Omarchy para Apple Silicon** con el instalador.
6. **Restaura tus archivos.** Recupera tus ajustes poco a poco en lugar de copiar todo `~/.config` sobre los valores predeterminados nuevos, ya que los ajustes viejos pueden sobrescribirlos.

### Lo que debes saber

- En las MacBook con M1 y M2, despierta del reposo abriendo la tapa o presionando el botón de encendido.
- ¿Preguntas o problemas? Pregunta en nuestro [Discord](https://discord.gg/tXFUdasqhY).

El [README del instalador](https://github.com/omacom/omarchy-mac-installer#readme) cubre los canales de lanzamiento, la actualización del instalador y cómo quitar Omarchy.

## Mac con Intel

En una prueba sencilla, logramos un aumento de rendimiento del 36% en una MacBook Pro de 2019 solo con instalar Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalar Omarchy en Mac

Omarchy solo admite ser el **único** sistema operativo instalado por el momento. Durante la instalación, la unidad se borrará por completo y MacOS ya no se podrá arrancar.

Aun así, puedes restaurarlo después mediante Internet Recovery si quieres.

Para esta parte, supondremos que ya revisaste [Primeros pasos](02-getting-started.md) y que tienes lista tu unidad USB. Si no, hazlo ahora.

#### Desactivar Secure Boot

Es necesario desactivar Secure Boot de Apple para arrancar desde la USB de arranque, así como el sistema operativo. Para desactivarlo, haz lo siguiente:

1. Apaga tu Mac
2. Enciéndela e _inmediatamente_ mantén presionado Command-R hasta que veas aparecer la pantalla de carga
3. Selecciona tu usuario e ingresa tu contraseña si se te pide
4. Una vez en la pantalla de recuperación, elige **Utilities > Startup Security Utility** en la barra de menús
5. Ingresa tu contraseña cuando se te pida autenticarte
6. Elige "No Security" en las opciones de Secure Boot
7. Elige "Allow booting from external or removable media" en las opciones de External Boot

#### Iniciar la instalación

1. Inserta la unidad USB
2. Reinicia tu Mac e _inmediatamente_ mantén presionada Option hasta que veas una pantalla con los dispositivos de arranque
3. Selecciona el dispositivo EFI Boot naranja
4. Continúa con la [instalación normal](02-getting-started.md)

El instalador detecta el hardware de Mac y aplica automáticamente las correcciones necesarias: controladores y firmware de Broadcom Wi-Fi, el controlador de la cámara FaceTime HD en equipos con un Broadcom 1570 (su firmware se descarga de Apple una vez que la Mac está en línea, ya que el instalador funciona sin conexión), el controlador de teclado SPI en los modelos de MacBook que lo necesitan y una corrección de suspensión NVMe para esos mismos modelos.

### Limitaciones conocidas

Los miembros de la comunidad trabajan constantemente en soluciones para estos desafíos, así que si te resultan problemáticos, únete a #omarchy-on-other en nuestro [Discord](https://discord.gg/tXFUdasqhY) y revisa si hay métodos actualizados para resolverlos.

#### Cámara FaceTime HD

El controlador de la cámara cuelga el equipo si está cargado cuando la Mac hiberna, por lo que se descarga antes. No se puede descargar mientras una app tiene la cámara abierta, así que la hibernación se cancela con una notificación que nombra la app: ciérrala e hiberna de nuevo. Esto incluye la hibernación automática por batería crítica y suspender y luego hibernar, que se rechaza antes de suspenderse. La suspensión normal la rechaza el propio controlador mientras la cámara está abierta, sin notificación.

El firmware de la cámara se descarga de Apple, por lo que la cámara solo funciona una vez que la Mac ha estado en línea. La descarga comienza en el arranque y se reintenta cada 15 minutos mientras el problema sea la red; si el archivo de Apple cambió, se detiene y espera una actualización de Omarchy. Si la cámara no aparece, `journalctl -u facetimehd-firmware-fetcher` dice por qué, `sudo systemctl restart facetimehd-firmware-fetcher` lo intenta de nuevo, y un reinicio carga el controlador si la descarga terminó pero la cámara sigue sin aparecer.

#### Dispositivos con chip T1

El chip Apple T1 se presentó a finales de 2016 y se usó exclusivamente en los modelos MacBook Pro de primera generación con Touch Bar.
- MacBook Pro 13 pulgadas (2016, dos puertos Thunderbolt 3) – Modelo: A1706
- MacBook Pro 13 pulgadas (2016, cuatro puertos Thunderbolt 3) – Modelo: A1708
- MacBook Pro 15 pulgadas (2016) – Modelo: A1707

#### Problemas conocidos

- La Touch Bar no funciona
- El sonido no funciona

#### Dispositivos con chip T2

El Apple T2 Security Chip se presentó en 2017. El chip T2 se descontinuó con la transición a Apple silicon (chips de la serie M) a partir de 2020.

- iMac Pro (2017) – Modelo: A1862
- MacBook Pro 13 pulgadas (2018, cuatro puertos Thunderbolt 3) – Modelo: A1989
- MacBook Pro 15 pulgadas (2018) – Modelo: A1990
- MacBook Air (Retina, 13 pulgadas, 2018) – Modelo: A1932
- Mac mini (2018) – Modelo: A1998
- MacBook Pro 13 pulgadas (2019, dos puertos Thunderbolt 3) – Modelo: A2159
- MacBook Pro 13 pulgadas (2019, cuatro puertos Thunderbolt 3) – Modelo: A2178
- MacBook Pro 15 pulgadas (2019) – Modelo: A1990
- iMac (Retina 5K, 27 pulgadas, 2020) – Modelo: A2115 (iMac20,1 e iMac20,2)
- MacBook Pro 13 pulgadas (2020, dos puertos Thunderbolt 3) – Modelo: A2265
- MacBook Pro 15 pulgadas (2020) – Modelo: A1990

En estos modelos, el instalador configura automáticamente el kernel `linux-t2` parcheado, la configuración de audio del T2, el firmware Broadcom Wi-Fi/Bluetooth de Apple y el control de ventiladores mediante `t2fanrd`. La Touch Bar funciona con el soporte integrado estilo Boot Camp del kernel.

#### iMac Retina 5K (2017)

La iMac de 27 pulgadas de 2017 no tiene chip T2, por lo que el instalador la configura como las demás Mac con Intel.

- iMac (Retina 5K, 27 pulgadas, 2017) – Modelo: A1419

#### Problemas conocidos

- La pantalla no funciona a su resolución nativa de 5120×2880: el panel tiene dos mosaicos y el controlador de serie solo enciende uno
- El sonido no funciona
- El control de brillo no tiene ningún efecto
- La suspensión cuelga el equipo; solo apagar y encender lo recupera

Un parcheador de la comunidad para este modelo corrige la pantalla, el sonido y el brillo: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
