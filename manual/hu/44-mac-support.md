# Mac-támogatás

Az Omarchy beépített támogatást kínál az **Intel Macekhez**. Jelenleg van néhány ismert korlátozás, de amíg tisztában vagy ezekkel, és rendben vannak számodra, új életet lehelhetsz régi Macjeidbe az Omarchy telepítésével.

Felhívjuk a figyelmet, hogy az M-sorozatú Macekre történő telepítés jelenleg nem támogatott közvetlenül. Erről bővebben a #omarchy-on-other csatornán tájékozódhatsz a [Discord](https://discord.gg/tXFUdasqhY) szerverünkön.

Egy egyszerű tesztben 36%-os teljesítménynövekedést értünk el egy 2019-es MacBook Prón pusztán az Omarchy telepítésével.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Az Omarchy telepítése Macre

Az Omarchy jelenleg csak egyedüli operációs rendszerként telepítve támogatott. A telepítés során a meghajtó törlődik, és a MacOS a továbbiakban nem lesz indítható.

Később az Internet Recovery segítségével mégis visszaállíthatod, ha szeretnéd.

Ehhez a részhez feltételezzük, hogy már átnézted a [Kezdő lépések](02-getting-started.md) útmutatót, és készen áll az USB-meghajtód. Ha még nem, tedd meg most.

#### A Secure Boot letiltása

Az Apple Secure Boot letiltása szükséges ahhoz, hogy elindíthasd az indítható USB-meghajtót, valamint az operációs rendszert is. A letiltáshoz hajtsd végre az alábbiakat:

1. Kapcsold ki a Macedet
2. Kapcsold be, és _azonnal_ nyomd le és tartsd lenyomva a Command-R billentyűkombinációt, amíg meg nem jelenik a betöltőképernyő
3. Válaszd ki a felhasználódat, és add meg a jelszavadat, ha a rendszer kéri
4. Miután a helyreállítási képernyőre kerültél, válaszd a menüsávból a **Utilities > Startup Security Utility** menüpontot
5. Add meg a jelszavadat, amikor a rendszer hitelesítésre kér
6. Válaszd a "No Security" lehetőséget a Secure Boot beállításai közül
7. Válaszd az "Allow booting from external or removable media" lehetőséget az External Boot beállításai közül

#### A telepítés indítása

1. Helyezd be az USB-meghajtót
2. Indítsd újra a Macedet, és _azonnal_ nyomd le és tartsd lenyomva az Option billentyűt, amíg meg nem jelenik az indítóeszközök képernyője
3. Válaszd ki a narancssárga EFI Boot eszközt
4. Folytasd a [szokásos telepítéssel](02-getting-started.md)

A telepítő felismeri a Mac hardverét, és automatikusan alkalmazza a szükséges javításokat: a Broadcom Wi-Fi illesztőprogramokat és firmware-t, az SPI billentyűzet-illesztőprogramot azokon a MacBook modelleken, amelyeknek szükségük van rá, valamint egy NVMe felfüggesztési javítást ugyanezekhez a modellekhez.

### Ismert korlátozások

A közösség tagjai folyamatosan dolgoznak e kihívások megoldásain, ezért ha ezek problémát jelentenek számodra, csatlakozz a #omarchy-on-other csatornához a [Discord](https://discord.gg/tXFUdasqhY) szerverünkön, és nézd meg, vannak-e naprakész módszerek a megoldásukra.

#### T1 chippel rendelkező eszközök

Az Apple T1 chipet 2016 végén mutatták be, és kizárólag a Touch Barral felszerelt első generációs MacBook Pro modellekben használták.
- MacBook Pro 13 hüvelykes (2016, két Thunderbolt 3 port) – Modell: A1706
- MacBook Pro 13 hüvelykes (2016, négy Thunderbolt 3 port) – Modell: A1708
- MacBook Pro 15 hüvelykes (2016) – Modell: A1707

#### Ismert problémák

- A Touch Bar nem működik
- A hang nem működik

#### T2 chippel rendelkező eszközök

Az Apple T2 Security Chipet 2017-ben mutatták be. A T2 chipet az Apple siliconra (M-sorozatú chipekre) való átállással, 2020-tól kezdve vezették ki.

- iMac Pro (2017) – Modell: A1862
- MacBook Pro 13 hüvelykes (2018, négy Thunderbolt 3 port) – Modell: A1989
- MacBook Pro 15 hüvelykes (2018) – Modell: A1990
- MacBook Air (Retina, 13 hüvelykes, 2018) – Modell: A1932
- Mac mini (2018) – Modell: A1998
- MacBook Pro 13 hüvelykes (2019, két Thunderbolt 3 port) – Modell: A2159
- MacBook Pro 13 hüvelykes (2019, négy Thunderbolt 3 port) – Modell: A2178
- MacBook Pro 15 hüvelykes (2019) – Modell: A1990
- iMac (Retina 5K, 27 hüvelykes, 2020) – Modell: A2115 (iMac20,1 és iMac20,2)
- MacBook Pro 13 hüvelykes (2020, két Thunderbolt 3 port) – Modell: A2265
- MacBook Pro 15 hüvelykes (2020) – Modell: A1990

Ezeken a modelleken a telepítő automatikusan beállítja a javított `linux-t2` kernelt, a T2 hangkonfigurációt, az Apple Broadcom Wi-Fi/Bluetooth firmware-t, valamint a ventilátorvezérlést a `t2fanrd` segítségével. A Touch Bar a kernel beépített, Boot Camp-stílusú támogatásával működik.

#### iMac Retina 5K (2017)

A 2017-es 27 hüvelykes iMacben nincs T2 chip, ezért a telepítő a többi Intel Machez hasonlóan állítja be.

- iMac (Retina 5K, 27 hüvelykes, 2017) – Modell: A1419

#### Ismert problémák

- A kijelző nem a natív 5120×2880-as felbontásán működik: a panel két csempéből áll, és az alapértelmezett illesztőprogram csak az egyiket világítja meg
- A hang nem működik
- A fényerőszabályozásnak nincs hatása
- Az alvó állapot lefagyasztja a gépet; csak a ki- és bekapcsolás hozza helyre

Egy közösségi javítóprogram ehhez a modellhez kijavítja a kijelzőt, a hangot és a fényerőt: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
