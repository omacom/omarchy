# Compatibilidad con Mac

Omarchy tiene compatibilidad integrada para **Macs Intel**. Hay un par de limitaciones conocidas al momento, pero mientras estés consciente de ellas y te parezcan bien, podrás darle nueva vida a tus Macs viejas cargándoles Omarchy.

Ten en cuenta que por el momento no hay compatibilidad directa para instalar en una Mac de la serie M. Puedes enterarte más sobre el estado de esto en #omarchy-on-other en nuestro [Discord](https://discord.gg/tXFUdasqhY).

En una prueba sencilla, logramos un aumento de rendimiento del 36 % en una MacBook Pro de 2019 solo por instalar Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalar Omarchy en Mac

Por el momento, Omarchy solo es compatible siendo el **único** sistema operativo instalado. Durante la instalación, la unidad se borrará y MacOS ya no podrá arrancar.

Aun así, podrás restaurarlo después mediante Recuperación por Internet si así lo deseas.

Para efectos de esta parte, supondremos que ya revisaste [Primeros pasos](02-getting-started.md) y tienes tu memoria USB lista. Si no, adelante, hazlo ahora.

#### Desactivar el Arranque seguro

Es necesario desactivar el Arranque seguro de Apple para poder arrancar la USB de arranque, así como el sistema operativo. Para desactivarlo, haz lo siguiente:

1. Apaga tu Mac
2. Enciéndela e _inmediatamente_ mantén presionado Command-R hasta que veas aparecer la pantalla de carga
3. Selecciona tu usuario e ingresa tu contraseña si se te pide
4. Ya en la pantalla de recuperación, elige **Utilidades > Utilidad de Seguridad de Arranque** desde la barra de menús
5. Ingresa tu contraseña cuando se te pida para autenticarte
6. Elige «Sin seguridad» en las opciones de Arranque seguro
7. Elige «Permitir el arranque desde medios externos o extraíbles» en las opciones de Arranque externo

#### Iniciar la instalación

1. Inserta la memoria USB
2. Reinicia tu Mac e _inmediatamente_ mantén presionada la tecla Option hasta que veas una pantalla de dispositivos de arranque
3. Selecciona el dispositivo naranja EFI Boot
4. Continúa con la [instalación como de costumbre](02-getting-started.md)

El instalador detecta el hardware Mac y aplica las correcciones necesarias automáticamente: los controladores y el firmware de Wi-Fi Broadcom, el controlador de teclado SPI en los modelos MacBook que lo necesitan y una corrección de suspensión NVMe para esos mismos modelos.

### Limitaciones conocidas

Los miembros de la comunidad trabajan constantemente en soluciones para estos retos, así que si estos son problemáticos para ti, únete a #omarchy-on-other en nuestro [Discord](https://discord.gg/tXFUdasqhY) y ve si hay métodos actualizados para resolverlos.

#### Dispositivos con chip T1

El chip Apple T1 se presentó a finales de 2016 y se usó exclusivamente en los modelos MacBook Pro de primera generación con Touch Bar.
- MacBook Pro de 13 pulgadas (2016, dos puertos Thunderbolt 3) – Modelo: A1706
- MacBook Pro de 13 pulgadas (2016, cuatro puertos Thunderbolt 3) – Modelo: A1708
- MacBook Pro de 15 pulgadas (2016) – Modelo: A1707

#### Problemas conocidos

- La Touch Bar no funciona
- El sonido no funciona

#### Dispositivos con chip T2

El chip de seguridad Apple T2 se presentó en 2017. El chip T2 se dejó de usar con la transición a Apple silicon (chips de la serie M) a partir de 2020.

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

En estos modelos, el instalador configura automáticamente el kernel parcheado `linux-t2`, la configuración de audio T2, el firmware de Wi-Fi/Bluetooth Broadcom de Apple y el control de ventiladores mediante `t2fanrd`. La Touch Bar funciona con la compatibilidad integrada estilo Boot Camp del kernel.
