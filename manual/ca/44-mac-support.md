# Suport per a Mac

## Omarchy per a Apple Silicon

Omarchy per a Apple Silicon és una solució oficial d'Omacom, llançada per primera vegada amb Omarchy 4.5. S'instal·la al costat de macOS, i tries entre els dos quan el Mac s'inicia.

Has rebut un avís sobre Omarchy Mac? Vés a [Si véns d'Omarchy Mac](#coming-from-omarchy-mac).

Funciona en aquests Mac:

| Mac | Xips |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Els Mac amb M4 i posteriors encara no són compatibles. El suport per a M4 està en proves al canal edge i arribarà a continuació. L'instal·lador comprova el teu Mac abans de canviar res.

En qualsevol Mac amb Apple Silicon, inclosos els M4 i posteriors, pots executar Omarchy en una màquina virtual amb [Try Omarchy](https://github.com/omacom/try-omarchy).

### Què et cal

- macOS 15 Sequoia o posterior, i un compte d'administrador
- Espai lliure al disc per a Omarchy. L'instal·lador suggereix una mida i et deixa canviar-la.
- Una còpia de seguretat del teu Mac, alimentació i una connexió a internet. La instal·lació descarrega diversos gigabytes.

### Instal·lació

S'instal·la des de macOS. Instal·la l'Omarchy Installer amb [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

O descarrega l'Omarchy Installer més recent des de la seva [pàgina de versions](https://github.com/omacom/omarchy-mac-installer/releases) i obre'l.

L'instal·lador comprova el teu Mac, et mostra el pla i fa lloc per a Omarchy reduint la partició de macOS. macOS es queda al disc i no cal cap unitat USB. Quan la primera fase ha acabat, et guia per acabar la configuració a macOS Recovery: apaga, mantén premut el botó d'encesa fins que aparegui "Loading startup options", tria Omarchy i segueix els passos.

En la primera arrencada, Omarchy et demana una contrasenya que xifra el seu disc. No hi ha cap clau de recuperació: si oblides la contrasenya, els teus fitxers d'Omarchy no es podran recuperar.

Per canviar entre Omarchy i macOS més tard, apaga, després mantén premut el botó d'encesa fins que apareguin les opcions d'arrencada i tria'n un.

### Si véns d'Omarchy Mac

Omarchy Mac ara forma part d'Omarchy per a Apple Silicon, i tots els Mac que l'executaven són compatibles. La teva instal·lació actual continua funcionant, i els seus paquets del sistema encara s'actualitzen, però ja no rep cap més actualització d'Omarchy. No hi ha cap termini ni cap actualització in situ: fas una còpia de seguretat, elimines la instal·lació antiga, instal·les de nou i restaures. Els passos 2 a 5 passen a macOS, així que obre aquesta pàgina al telèfon abans de reiniciar.

1. **Fes una còpia de seguretat des d'Omarchy, fora del Mac.** Eliminar la instal·lació antiga l'esborra, i macOS no pot llegir el disc d'Omarchy. Copia la teva carpeta personal a una unitat externa o a un altre ordinador, incloent-hi claus SSH i GPG, perfils del navegador i feina sense pujar. Desa la teva llista de paquets amb `pacman -Qqe > ~/packages.txt`. Fes també una còpia de seguretat de macOS, ja que tant eliminar com instal·lar li redimensionen el disc.
2. **Inicia el teu Mac a macOS.** Apaga, mantén premut el botó d'encesa fins que apareguin les opcions d'arrencada i tria macOS.
3. **Instal·la l'Omarchy Installer** com es mostra a [Instal·lació](#installing).
4. **Elimina la instal·lació antiga.** Obre l'Omarchy Installer i tria Installation > Remove Omarchy. Et mostra què esborrarà i retorna l'espai a macOS. Si no reconeix la teva instal·lació, s'atura sense canviar el disc. Demana ajuda a [Discord](https://discord.gg/tXFUdasqhY) en lloc d'esborrar particions a mà, cosa que pot esborrar macOS.
5. **Instal·la Omarchy per a Apple Silicon** amb l'instal·lador.
6. **Restaura els teus fitxers.** Torna a posar la teva configuració a poc a poc en lloc de copiar tot `~/.config` per sobre dels valors per defecte nous, perquè la configuració antiga els pot sobreescriure.

### És bo saber-ho

- Als MacBook amb M1 i M2, desperta'l de la suspensió obrint la tapa o prement el botó d'encesa.
- Preguntes o problemes: pregunta al nostre [Discord](https://discord.gg/tXFUdasqhY).

El [README de l'instal·lador](https://github.com/omacom/omarchy-mac-installer#readme) cobreix els canals de llançament, l'actualització de l'instal·lador i l'eliminació d'Omarchy.

## Mac amb Intel

En una prova senzilla, vam aconseguir guanys de rendiment del 36% en un MacBook Pro de 2019 només instal·lant Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instal·lar Omarchy al Mac

De moment, Omarchy només admet ser l'**únic** SO instal·lat. Durant la instal·lació, la unitat s'esborrarà i MacOS ja no es podrà arrencar.

Encara el pots restaurar més tard mitjançant Internet Recovery si vols.

Per a aquesta part, donarem per fet que ja has revisat [Primers passos](02-getting-started.md) i tens la unitat USB a punt. Si no, vés i fes-ho ara.

#### Desactiva Secure Boot

Cal desactivar el Secure Boot d'Apple per poder arrencar l'USB d'arrencada, així com el SO. Per desactivar-lo, fes el següent:

1. Apaga el Mac
2. Encén-lo i _immediatament_ mantén premut Command-R fins que vegis aparèixer la pantalla de càrrega
3. Selecciona el teu usuari i introdueix la teva contrasenya si se't demana
4. Un cop a la pantalla de recuperació, tria **Utilities > Startup Security Utility** a la barra de menús
5. Introdueix la teva contrasenya quan se't demani per autenticar-te
6. Tria "No Security" entre les opcions de Secure Boot
7. Tria "Allow booting from external or removable media" entre les opcions d'External Boot

#### Inicia la instal·lació

1. Insereix la unitat USB
2. Reinicia el Mac i _immediatament_ mantén premuda Option fins que vegis una pantalla de dispositius d'arrencada
3. Selecciona el dispositiu EFI Boot taronja
4. Continua amb la [instal·lació normal](02-getting-started.md)

L'instal·lador detecta el maquinari del Mac i aplica automàticament les correccions necessàries: controladors i firmware de Broadcom Wi-Fi, el controlador de teclat SPI als models de MacBook que el necessiten, i una correcció de suspensió NVMe per a aquests mateixos models.

### Limitacions conegudes

Els membres de la comunitat treballen constantment en solucions per a aquests reptes, així que si això et suposa un problema, uneix-te a #omarchy-on-other al nostre [Discord](https://discord.gg/tXFUdasqhY) i mira si hi ha cap mètode actualitzat per resoldre'ls.

#### Dispositius amb xip T1

El xip Apple T1 es va presentar a finals de 2016 i es va utilitzar exclusivament als models de MacBook Pro de primera generació amb Touch Bar.
- MacBook Pro de 13 polzades (2016, dos ports Thunderbolt 3) – Model: A1706
- MacBook Pro de 13 polzades (2016, quatre ports Thunderbolt 3) – Model: A1708
- MacBook Pro de 15 polzades (2016) – Model: A1707

#### Problemes coneguts

- La Touch Bar no funciona
- El so no funciona

#### Dispositius amb xip T2

El xip de seguretat Apple T2 es va presentar el 2017. El xip T2 es va deixar de fabricar amb la transició a Apple silicon (xips de la sèrie M) a partir de 2020.

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

En aquests models, l'instal·lador configura automàticament el nucli `linux-t2` amb pegats, la configuració d'àudio del T2, el firmware de Broadcom Wi-Fi/Bluetooth d'Apple i el control de ventiladors mitjançant `t2fanrd`. La Touch Bar funciona amb el suport tipus Boot Camp integrat al nucli.

#### iMac Retina 5K (2017)

L'iMac de 27 polzades de 2017 no té xip T2, així que l'instal·lador el configura com els altres Mac amb Intel.

- iMac (Retina 5K, 27 polzades, 2017) – Model: A1419

#### Problemes coneguts

- La pantalla no funciona a la seva resolució nativa de 5120×2880: el panell són dues rajoles, i el controlador de sèrie només n'encén una
- El so no funciona
- El control de brillantor no té cap efecte
- La suspensió penja la màquina; només un cicle d'apagada i encesa la recupera

Un aplicador de pegats de la comunitat per a aquest model corregeix la pantalla, el so i la brillantor: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
