# Suport per a Mac

Omarchy té suport integrat per als **Macs Intel**. De moment hi ha un parell de limitacions conegudes, però mentre les coneguis i t'hi avinguis, pots insuflar una mica de vida nova als teus Macs vells carregant-hi Omarchy.

Tingues en compte que la instal·lació en un Mac amb xip de la sèrie M no es suporta directament en aquest moment. Pots saber-ne més sobre l'estat d'això a #omarchy-on-other al nostre [Discord](https://discord.gg/tXFUdasqhY).

En una prova senzilla, vam aconseguir guanys de rendiment del 36% en un MacBook Pro del 2019 només instal·lant-hi Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instal·lar Omarchy en un Mac

Omarchy només suporta ser l'**únic** sistema operatiu instal·lat en aquest moment. Durant la instal·lació, la unitat s'esborrarà i macOS ja no es podrà arrencar.

Tanmateix, després el pots restaurar via Internet Recovery si ho vols.

Per als propòsits d'aquesta part, assumirem que ja has repassat [Primers passos](02-getting-started.md) i tens la unitat USB a punt. Si no, fes-ho ara.

#### Desactivar Secure Boot

Cal desactivar Secure Boot d'Apple per poder arrencar l'USB d'arrencada, i també el sistema operatiu. Per desactivar-ho, fes el següent:

1. Apaga el Mac
2. Encén-lo i premi i mantén premut _immediatament_ Command-R fins que aparegui la pantalla de càrrega
3. Selecciona el teu usuari i introdueix la contrasenya si se't demana
4. Un cop a la pantalla de recuperació, tria **Utilities > Startup Security Utility** de la barra de menús
5. Introdueix la contrasenya quan se't demani per autenticar-te
6. Tria «No Security» de les opcions de Secure Boot
7. Tria «Allow booting from external or removable media» de les opcions d'External Boot

#### Iniciar la instal·lació

1. Insereix la unitat USB
2. Reinicia el Mac i premi i mantén premut _immediatament_ Option fins que vegis una pantalla de dispositius d'arrencada
3. Selecciona el dispositiu taronja EFI Boot
4. Continua amb la [instal·lació com de costum](02-getting-started.md)

L'instal·lador detecta el maquinari Mac i aplica automàticament les correccions necessàries: els controladors i el microprogramari de la Wi-Fi Broadcom, el controlador de teclat SPI als models de MacBook que el necessiten i una correcció de suspensió d'NVMe per a aquests mateixos models.

### Limitacions conegudes

Els membres de la comunitat treballen constantment en solucions per a aquests reptes, de manera que, si això et suposa un problema, uneix-te a #omarchy-on-other al nostre [Discord](https://discord.gg/tXFUdasqhY) i mira si hi ha algun mètode actualitzat per resoldre-ho.

#### Dispositius amb xip T1

El xip Apple T1 es va introduir a finals del 2016 i es va fer servir exclusivament als models de MacBook Pro de primera generació amb Touch Bar.
- MacBook Pro de 13 polzades (2016, dos ports Thunderbolt 3) – Model: A1706
- MacBook Pro de 13 polzades (2016, quatre ports Thunderbolt 3) – Model: A1708
- MacBook Pro de 15 polzades (2016) – Model: A1707

#### Problemes coneguts

- La Touch Bar no funciona
- El so no funciona

#### Dispositius amb xip T2

El xip de seguretat Apple T2 es va introduir el 2017. El xip T2 es va deixar de fabricar amb la transició a l'Apple silicon (xips de la sèrie M) a partir del 2020.

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

En aquests models, l'instal·lador configura automàticament el nucli `linux-t2` pedaçat, la configuració d'àudio del T2, el microprogramari de la Wi-Fi/Bluetooth Broadcom d'Apple i el control del ventilador via `t2fanrd`. La Touch Bar funciona amb el suport integrat al nucli a l'estil Boot Camp.
