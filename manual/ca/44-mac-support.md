# Suport per a Mac

Omarchy inclou suport integrat per als **Mac amb Intel**. De moment hi ha un parell de limitacions conegudes, però mentre en siguis conscient i t'hi conformis, pots donar una nova vida als teus Mac antics instal·lant-hi Omarchy.

Tingues en compte que, de moment, la instal·lació en un Mac amb xip de la sèrie M no té suport directe. Pots saber-ne més sobre l'estat d'això a #omarchy-on-other, al nostre [Discord](https://discord.gg/tXFUdasqhY).

En una prova senzilla, vam aconseguir un 36% més de rendiment en un MacBook Pro del 2019 només instal·lant-hi Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instal·lar Omarchy en un Mac

Omarchy, de moment, només admet ser l'**únic** sistema operatiu instal·lat. Durant la instal·lació, el disc s'esborrarà i MacOS ja no es podrà arrencar.

Tot i així, si vols, el pots restaurar més endavant mitjançant Internet Recovery.

Per a aquesta part, suposarem que ja has revisat [Primers passos](02-getting-started.md) i que ja tens la unitat USB a punt. Si no és així, fes-ho ara.

#### Desactiva el Secure Boot

Cal desactivar el Secure Boot d'Apple per poder arrencar des de l'USB d'arrencada, així com el sistema operatiu. Per desactivar-lo, fes el següent:

1. Apaga el Mac
2. Encén-lo i, _immediatament_, mantén premut Command-R fins que vegis aparèixer la pantalla de càrrega
3. Selecciona el teu usuari i introdueix la contrasenya si se't demana
4. Un cop a la pantalla de recuperació, tria **Utilities > Startup Security Utility** a la barra de menús
5. Introdueix la contrasenya quan se't demani per autenticar-te
6. Tria "No Security" entre les opcions de Secure Boot
7. Tria "Allow booting from external or removable media" entre les opcions d'External Boot

#### Inicia la instal·lació

1. Insereix la unitat USB
2. Reinicia el Mac i, _immediatament_, mantén premuda la tecla Option fins que vegis una pantalla amb els dispositius d'arrencada
3. Selecciona el dispositiu EFI Boot de color taronja
4. Continua amb la [instal·lació com de costum](02-getting-started.md)

L'instal·lador detecta el maquinari del Mac i aplica automàticament les correccions necessàries: els controladors i el firmware de Wi-Fi de Broadcom, el controlador de teclat SPI en els models de MacBook que el necessiten i una correcció de la suspensió NVMe per a aquests mateixos models.

### Limitacions conegudes

Els membres de la comunitat treballen constantment en solucions per a aquests problemes, així que si et suposen un problema, uneix-te a #omarchy-on-other al nostre [Discord](https://discord.gg/tXFUdasqhY) i mira si hi ha mètodes actualitzats per resoldre'ls.

#### Dispositius amb xip T1

El xip Apple T1 es va presentar a finals del 2016 i es va utilitzar exclusivament en els models de MacBook Pro de primera generació amb Touch Bar.
- MacBook Pro de 13 polzades (2016, dos ports Thunderbolt 3) – Model: A1706
- MacBook Pro de 13 polzades (2016, quatre ports Thunderbolt 3) – Model: A1708
- MacBook Pro de 15 polzades (2016) – Model: A1707

#### Problemes coneguts

- La Touch Bar no funciona
- El so no funciona

#### Dispositius amb xip T2

El xip de seguretat Apple T2 es va presentar el 2017. El xip T2 es va deixar de fabricar amb la transició a Apple silicon (xips de la sèrie M) a partir del 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro de 13 polzades (2018, quatre ports Thunderbolt 3) – Model: A1989
- MacBook Pro de 15 polzades (2018) – Model: A1990
- MacBook Air (Retina, 13 polzades, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro de 13 polzades (2019, dos ports Thunderbolt 3) – Model: A2159
- MacBook Pro de 13 polzades (2019, quatre ports Thunderbolt 3) – Model: A2178
- MacBook Pro de 15 polzades (2019) – Model: A1990
- iMac (Retina 5K, 27 polzades, 2020) – Model: A2115 (iMac20,1 i iMac20,2)
- MacBook Pro de 13 polzades (2020, dos ports Thunderbolt 3) – Model: A2265
- MacBook Pro de 15 polzades (2020) – Model: A1990

En aquests models, l'instal·lador configura automàticament el nucli `linux-t2` amb pegats, la configuració d'àudio del T2, el firmware de Wi-Fi/Bluetooth Broadcom d'Apple i el control dels ventiladors mitjançant `t2fanrd`. La Touch Bar funciona amb el suport integrat del nucli a l'estil de Boot Camp.

#### iMac Retina 5K (2017)

L'iMac de 27 polzades del 2017 no té xip T2, així que l'instal·lador el configura com la resta de Mac amb Intel.

- iMac (Retina 5K, 27 polzades, 2017) – Model: A1419

#### Problemes coneguts

- La pantalla no funciona a la seva resolució nativa de 5120×2880: el panell està format per dues peces i el controlador de sèrie només n'encén una
- El so no funciona
- El control de la brillantor no té cap efecte
- En suspendre's, la màquina es bloqueja; només es recupera apagant-la i tornant-la a engegar

Un aplicador de pegats de la comunitat per a aquest model corregeix la pantalla, el so i la brillantor: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
