# Soporte para Mac

Omarchy incluye soporte integrado para **Macs con Intel**. Por el momento hay un par de limitaciones conocidas, pero mientras las conozcas y te parezcan aceptables; puedes darle nueva vida a tus Macs viejas instalando Omarchy.

Ten en cuenta que por ahora no hay soporte directo para instalar en una Mac con chip de la serie M. Puedes enterarte de más sobre el estado de esto en #omarchy-on-other en nuestro [Discord](https://discord.gg/tXFUdasqhY).

En una prueba sencilla, logramos un aumento de rendimiento del 36% solo por instalar Omarchy en una MacBook Pro de 2019.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalar Omarchy en Mac

Por el momento, Omarchy solo admite ser el **único** sistema operativo instalado. Durante la instalación, se borrará el disco y MacOS ya no podrá arrancar.

Aun así, puedes restaurarlo después mediante Recuperación por Internet si quieres.

Para esta parte, asumiremos que ya revisaste [Primeros pasos](02-getting-started.md) y tienes lista tu unidad USB. Si no, hazlo ahora.

#### Desactivar Secure Boot

Es necesario desactivar Secure Boot de Apple para poder arrancar desde la USB de arranque, así como el sistema operativo. Para desactivarlo, haz lo siguiente:

1. Apaga tu Mac
2. Enciéndela e _inmediatamente_ mantén presionado Command-R hasta que veas aparecer la pantalla de carga
3. Selecciona tu usuario e ingresa tu contraseña si se te pide
4. Una vez en la pantalla de recuperación, elige **Utilidades > Utilidad de Seguridad de Arranque** desde la barra de menús
5. Ingresa tu contraseña cuando se te pida para autenticarte
6. Elige "Sin seguridad" de las opciones de Secure Boot
7. Elige "Permitir arrancar desde medios externos o extraíbles" de las opciones de Arranque Externo

#### Iniciar la instalación

1. Inserta la unidad USB
2. Reinicia tu Mac e _inmediatamente_ mantén presionada la tecla Option hasta que veas una pantalla con dispositivos de arranque
3. Selecciona el dispositivo EFI Boot naranja
4. Continúa con la [instalación como de costumbre](02-getting-started.md)

El instalador detecta el hardware de Mac y aplica automáticamente las correcciones necesarias: los controladores y el firmware de Wi-Fi Broadcom, el controlador de teclado SPI en los modelos de MacBook que lo necesitan y una corrección de suspensión NVMe para esos mismos modelos.

### Limitaciones conocidas

La comunidad trabaja constantemente en soluciones para estos problemas, así que si alguno te afecta, únete a #omarchy-on-other en nuestro [Discord](https://discord.gg/tXFUdasqhY) y revisa si hay algún método actualizado para resolverlo.

#### Dispositivos con chip T1

El chip Apple T1 se presentó a finales de 2016 y se usó exclusivamente en los modelos de MacBook Pro de primera generación con Touch Bar.
- MacBook Pro de 13 pulgadas (2016, dos puertos Thunderbolt 3) – Modelo: A1706
- MacBook Pro de 13 pulgadas (2016, cuatro puertos Thunderbolt 3) – Modelo: A1708
- MacBook Pro de 15 pulgadas (2016) – Modelo: A1707

#### Problemas conocidos

- La Touch Bar no funciona
- El sonido no funciona

#### Dispositivos con chip T2

El chip de seguridad Apple T2 se presentó en 2017. El chip T2 se descontinuó con la transición a Apple silicon (chips de la serie M) a partir de 2020.

- iMac Pro (2017) – Modelo: A1862
- MacBook Pro de 13 pulgadas (2018, cuatro puertos Thunderbolt 3) – Modelo: A1989
- MacBook Pro de 15 pulgadas (2018) – Modelo: A1990
- MacBook Air (Retina, 13 pulgadas, 2018) – Modelo: A1932
- Mac mini (2018) – Modelo: A1998
- MacBook Pro de 13 pulgadas (2019, dos puertos Thunderbolt 3) – Modelo: A2159
- MacBook Pro de 13 pulgadas (2019, cuatro puertos Thunderbolt 3) – Modelo: A2178
- MacBook Pro de 15 pulgadas (2019) – Modelo: A1990
- iMac (Retina 5K, 27 pulgadas, 2020) – Modelo: A2115 (iMac20,1 y iMac20,2)
- MacBook Pro de 13 pulgadas (2020, dos puertos Thunderbolt 3) – Modelo: A2265
- MacBook Pro de 15 pulgadas (2020) – Modelo: A1990

En estos modelos, el instalador configura automáticamente el kernel `linux-t2` parcheado, la configuración de audio del T2, el firmware de Wi-Fi/Bluetooth Broadcom de Apple y el control de ventiladores mediante `t2fanrd`. La Touch Bar funciona con el soporte estilo Boot Camp integrado en el kernel.

#### iMac Retina 5K (2017)

La iMac de 27 pulgadas de 2017 no tiene chip T2, así que el instalador la configura como las demás Macs con Intel.

- iMac (Retina 5K, 27 pulgadas, 2017) – Modelo: A1419

#### Problemas conocidos

- La pantalla no funciona a su resolución nativa de 5120×2880: el panel está formado por dos mosaicos y el controlador de serie solo enciende uno
- El sonido no funciona
- El control de brillo no tiene ningún efecto
- La suspensión bloquea la máquina; solo se recupera apagándola y volviéndola a encender

Un parche de la comunidad para este modelo corrige la pantalla, el sonido y el brillo: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
