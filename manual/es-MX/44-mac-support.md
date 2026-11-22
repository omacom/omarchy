# Soporte para Mac

## Omarchy for Apple Silicon

Omarchy for Apple Silicon es una solución oficial de Omacom, lanzada por primera vez con Omarchy 4.5. Se instala junto a macOS, y eliges entre los dos cuando arranca tu Mac.

¿Te llegó un aviso sobre Omarchy Mac? Ve a [Si vienes de Omarchy Mac](#coming-from-omarchy-mac).

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

Las Mac con M4 y posteriores aún no son compatibles. La compatibilidad con M4 está en pruebas en el canal edge y viene a continuación. El instalador revisa tu Mac antes de cambiar cualquier cosa.

En cualquier Mac con Apple Silicon, incluidas las M4 y posteriores, puedes ejecutar Omarchy en una máquina virtual con [Try Omarchy](https://github.com/omacom/try-omarchy).

### Qué necesitas

- macOS 15 Sequoia o posterior, y una cuenta de administrador
- Espacio libre en disco para Omarchy. El instalador sugiere un tamaño y te permite cambiarlo.
- Una copia de seguridad de tu Mac, energía y una conexión a internet. La instalación descarga varios gigabytes.

### Instalación

La instalación se hace desde macOS. Instala Omarchy Installer con [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

O descarga la versión más reciente de Omarchy Installer desde su [página de versiones](https://github.com/omacom/omarchy-mac-installer/releases) y ábrela.

El instalador revisa tu Mac, te muestra el plan y hace espacio para Omarchy reduciendo la partición de macOS. macOS permanece en el disco y no se necesita ninguna unidad USB. Cuando termina la primera etapa, te guía para terminar la configuración en macOS Recovery: apaga, mantén presionado el botón de encendido hasta que aparezca "Loading startup options", elige Omarchy y sigue los pasos.

En el primer arranque, Omarchy te pide una contraseña que cifra su disco. No hay clave de recuperación: si olvidas la contraseña, tus archivos de Omarchy no podrán recuperarse.

Para cambiar entre Omarchy y macOS después, apaga, luego mantén presionado el botón de encendido hasta que aparezcan las opciones de arranque y elige una.

### Si vienes de Omarchy Mac

Omarchy Mac ahora es parte de Omarchy for Apple Silicon, y todas las Mac que lo ejecutaban son compatibles. Tu instalación actual sigue funcionando, y sus paquetes del sistema todavía se actualizan, pero ya no recibe actualizaciones de Omarchy. No hay fecha límite ni actualización en el lugar: haces una copia de seguridad, eliminas la instalación anterior, instalas desde cero y restauras. Los pasos 2 a 5 se hacen en macOS, así que abre esta página en tu teléfono antes de reiniciar.

1. **Haz una copia de seguridad desde Omarchy, fuera de la Mac.** Eliminar la instalación anterior la borra, y macOS no puede leer el disco de Omarchy. Copia tu carpeta personal a una unidad externa u otra computadora, incluidas tus claves SSH y GPG, perfiles del navegador y trabajo que no hayas subido. Guarda tu lista de paquetes con `pacman -Qqe > ~/packages.txt`. Haz también una copia de seguridad de macOS, ya que tanto la eliminación como la instalación redimensionan su disco.
2. **Arranca tu Mac en macOS.** Apaga, mantén presionado el botón de encendido hasta que aparezcan las opciones de arranque y elige macOS.
3. **Instala Omarchy Installer** como se muestra en [Instalación](#installing).
4. **Elimina la instalación anterior.** Abre Omarchy Installer y elige Installation > Remove Omarchy. Te muestra lo que eliminará y devuelve el espacio a macOS. Si no reconoce tu instalación, se detiene sin cambiar el disco. Pide ayuda en [Discord](https://discord.gg/tXFUdasqhY) en lugar de eliminar particiones manualmente, lo que puede borrar macOS.
5. **Instala Omarchy for Apple Silicon** con el instalador.
6. **Restaura tus archivos.** Recupera tu configuración poco a poco en lugar de copiar todo `~/.config` sobre los nuevos valores predeterminados, ya que la configuración anterior puede sobrescribirlos.

### Lo que debes saber

- En las MacBook con M1 y M2, despierta del reposo abriendo la tapa o presionando el botón de encendido.
- ¿Preguntas o problemas?: pregunta en nuestro [Discord](https://discord.gg/tXFUdasqhY).

El [README del instalador](https://github.com/omacom/omarchy-mac-installer#readme) cubre los canales de lanzamiento, la actualización del instalador y la eliminación de Omarchy.

## Mac con Intel

En una prueba sencilla, logramos un aumento de rendimiento del 36% en una MacBook Pro de 2019 solo por instalar Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalar Omarchy en una Mac

Por el momento, Omarchy solo admite ser el **único** sistema operativo instalado. Durante la instalación, la unidad se borrará por completo y macOS ya no podrá arrancar.

Aún puedes restaurarlo después mediante Internet Recovery si quieres.

Para esta parte, supondremos que ya revisaste [Primeros pasos](02-getting-started.md) y que ya tienes lista tu unidad USB. Si no, adelante, hazlo ahora.

#### Desactivar Secure Boot

Es necesario desactivar el Secure Boot de Apple para poder arrancar desde la USB de arranque, así como el sistema operativo. Para desactivarlo, haz lo siguiente:

1. Apaga tu Mac
2. Enciéndela e _inmediatamente_ mantén presionadas Command-R hasta que veas aparecer la pantalla de carga
3. Selecciona tu usuario e ingresa tu contraseña si te la pide
4. Una vez en la pantalla de recuperación, elige **Utilities > Startup Security Utility** desde la barra de menús
5. Ingresa tu contraseña cuando te la pida para autenticarte
6. Elige "No Security" en las opciones de Secure Boot
7. Elige "Allow booting from external or removable media" en las opciones de External Boot

#### Iniciar la instalación

1. Inserta la unidad USB
2. Reinicia tu Mac e _inmediatamente_ mantén presionada Option hasta que veas una pantalla con los dispositivos de arranque
3. Selecciona el dispositivo EFI Boot de color naranja
4. Continúa con la [instalación como de costumbre](02-getting-started.md)

El instalador detecta el hardware de la Mac y aplica automáticamente las correcciones necesarias: los controladores y el firmware de Broadcom Wi-Fi, el controlador de teclado SPI en los modelos de MacBook que lo necesitan y una corrección de suspensión NVMe para esos mismos modelos.

### Limitaciones conocidas

Los miembros de la comunidad trabajan constantemente en soluciones para estos problemas, así que si alguno te afecta, únete a #omarchy-on-other en nuestro [Discord](https://discord.gg/tXFUdasqhY) y revisa si hay métodos actualizados para resolverlos.

#### Dispositivos con chip T1

El chip Apple T1 se presentó a finales de 2016 y se usó exclusivamente en los modelos de MacBook Pro de primera generación con Touch Bar.
- MacBook Pro de 13 pulgadas (2016, dos puertos Thunderbolt 3) – Modelo: A1706
- MacBook Pro de 13 pulgadas (2016, cuatro puertos Thunderbolt 3) – Modelo: A1708
- MacBook Pro de 15 pulgadas (2016) – Modelo: A1707

#### Problemas conocidos

- La Touch Bar no funciona
- El sonido no funciona

#### Dispositivos con chip T2

El Apple T2 Security Chip se presentó en 2017. El chip T2 se descontinuó con la transición a Apple silicon (chips de la serie M) a partir de 2020.

- iMac Pro (2017) – Modelo: A1862
- MacBook Pro de 13 pulgadas (2018, cuatro puertos Thunderbolt 3) – Modelo: A1989
- MacBook Pro de 15 pulgadas (2018) – Modelo: A1990
- MacBook Air (Retina, 13 pulgadas, 2018) – Modelo: A1932
- Mac mini (2018) – Modelo: A1998
- MacBook Pro de 13 pulgadas (2019, dos puertos Thunderbolt 3) – Modelo: A2159
- MacBook Pro de 13 pulgadas (2019, cuatro puertos Thunderbolt 3) – Modelo: A2178
- MacBook Pro de 15 pulgadas (2019) – Modelo: A1990
- iMac (Retina 5K, 27 pulgadas, 2020) – Modelo: A2115 (iMac20,1 e iMac20,2)
- MacBook Pro de 13 pulgadas (2020, dos puertos Thunderbolt 3) – Modelo: A2265
- MacBook Pro de 15 pulgadas (2020) – Modelo: A1990

En estos modelos, el instalador configura automáticamente el kernel `linux-t2` parcheado, la configuración de audio T2, el firmware Broadcom Wi-Fi/Bluetooth de Apple y el control de ventiladores mediante `t2fanrd`. La Touch Bar funciona con el soporte estilo Boot Camp integrado en el kernel.

#### iMac Retina 5K (2017)

La iMac de 27 pulgadas de 2017 no tiene chip T2, así que el instalador la configura como las demás Mac con Intel.

- iMac (Retina 5K, 27 pulgadas, 2017) – Modelo: A1419

#### Problemas conocidos

- La pantalla no funciona a su resolución nativa de 5120×2880: el panel está formado por dos mosaicos y el controlador de serie solo enciende uno
- El sonido no funciona
- El control de brillo no tiene ningún efecto
- El reposo congela la máquina; solo se recupera apagándola y volviéndola a encender

Una herramienta de parcheo de la comunidad para este modelo corrige la pantalla, el sonido y el brillo: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
