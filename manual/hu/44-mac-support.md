# Mac támogatás

## Omarchy Apple Siliconra

Az Omarchy for Apple Silicon az Omacom hivatalos megoldása, amely először az Omarchy 4.5-tel jelent meg. A macOS mellé települ, és a Mac indításakor választhatsz a kettő között.

Értesítést kaptál az Omarchy Macről? Ugrás ide: [Omarchy Macről érkezőknek](#coming-from-omarchy-mac).

Ezeken a Maceken fut:

| Mac | Chipek |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Az M4-es és újabb Macek még nem támogatottak. Az M4 támogatása az edge csatornán tesztelés alatt áll, és következik. A telepítő ellenőrzi a Macedet, mielőtt bármit megváltoztatna.

Bármely Apple Silicon Macen, beleértve az M4-es és újabb modelleket is, futtathatod az Omarchyt virtuális gépben a [Try Omarchy](https://github.com/omacom/try-omarchy) segítségével.

### Amire szükséged van

- macOS 15 Sequoia vagy újabb, és egy rendszergazdai fiók
- Szabad lemezterület az Omarchy számára. A telepítő javasol egy méretet, és hagyja, hogy módosítsd.
- Biztonsági mentés a Macedről, áramellátás és internetkapcsolat. A telepítés több gigabájtot tölt le.

### Telepítés

macOS-ből telepítesz. Telepítsd az Omarchy Installert a [Homebrew](https://brew.sh) segítségével:

```sh
brew install omacom/mac/omarchy
```

Vagy töltsd le a legújabb Omarchy Installert a [kiadások oldaláról](https://github.com/omacom/omarchy-mac-installer/releases), és nyisd meg.

A telepítő ellenőrzi a Macedet, megmutatja a tervet, és helyet csinál az Omarchynak a macOS partíció zsugorításával. A macOS a lemezen marad, és nincs szükség USB-meghajtóra. Amikor az első szakasz kész, végigvezet a beállítás macOS Recoveryben történő befejezésén: kapcsold ki, tartsd lenyomva a bekapcsológombot, amíg meg nem jelenik a „Loading startup options”, válaszd az Omarchyt, és kövesd a lépéseket.

Első indításkor az Omarchy egy jelszót kér, amely titkosítja a lemezét. Nincs helyreállítási kulcs: ha elfelejted a jelszót, az Omarchy-fájljaid nem állíthatók helyre.

Ha később váltani akarsz az Omarchy és a macOS között, kapcsold ki, majd tartsd lenyomva a bekapcsológombot, amíg meg nem jelennek az indítási lehetőségek, és válassz egyet.

### Omarchy Macről érkezőknek

Az Omarchy Mac most már az Omarchy for Apple Silicon része, és minden Mac támogatott, amelyen futott. A jelenlegi telepítésed tovább fut, és a rendszercsomagjai továbbra is frissülnek, de több Omarchy-frissítést nem kap. Nincs határidő és nincs helyben történő frissítés: biztonsági mentést készítesz, eltávolítod a régi telepítést, frissen telepítesz, és visszaállítasz. A 2–5. lépés macOS-ben történik, ezért újraindítás előtt nyisd meg ezt az oldalt a telefonodon.

1. **Készíts biztonsági mentést az Omarchy-ból, a Macen kívülre.** A régi telepítés eltávolítása törli azt, a macOS pedig nem tudja olvasni az Omarchy lemezét. Másold a saját mappádat egy külső meghajtóra vagy egy másik számítógépre, beleértve az SSH- és GPG-kulcsokat, a böngészőprofilokat és a nem pusholt munkát. Mentsd el a csomaglistádat ezzel: `pacman -Qqe > ~/packages.txt`. Készíts biztonsági mentést a macOS-ről is, mivel az eltávolítás és a telepítés is átméretezi a lemezét.
2. **Indítsd a Macedet macOS-ben.** Kapcsold ki, tartsd lenyomva a bekapcsológombot, amíg meg nem jelennek az indítási lehetőségek, és válaszd a macOS-t.
3. **Telepítsd az Omarchy Installert** a [Telepítés](#installing) részben leírtak szerint.
4. **Távolítsd el a régi telepítést.** Nyisd meg az Omarchy Installert, és válaszd az Installation > Remove Omarchy lehetőséget. Megmutatja, mit fog törölni, és visszaadja a területet a macOS-nek. Ha nem ismeri fel a telepítésedet, leáll anélkül, hogy megváltoztatná a lemezt. Kérj segítséget a [Discord](https://discord.gg/tXFUdasqhY) felületén, ahelyett hogy kézzel törölnéd a partíciókat, ami törölheti a macOS-t.
5. **Telepítsd az Omarchy for Apple Silicont** a telepítővel.
6. **Állítsd vissza a fájljaidat.** A beállításaidat darabonként hozd vissza, ahelyett hogy az összes `~/.config` tartalmat az új alapértelmezések fölé másolnád, mivel a régi beállítások felülírhatják azokat.

### Jó tudni

- M1-es és M2-es MacBookokon a fedél felnyitásával vagy a bekapcsológomb megnyomásával ébreszd fel a gépet alvó állapotból.
- Kérdésed vagy problémád van: kérdezz a [Discord](https://discord.gg/tXFUdasqhY) felületünkön.

[A telepítő README-je](https://github.com/omacom/omarchy-mac-installer#readme) kitér a kiadási csatornákra, a telepítő frissítésére és az Omarchy eltávolítására.

## Intel Macek

Egy egyszerű tesztben 36%-os teljesítménynövekedést tudtunk elérni egy 2019-es MacBook Prón pusztán az Omarchy telepítésével.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Az Omarchy telepítése Macre

Az Omarchy jelenleg csak akkor támogatott, ha az az **egyetlen** telepített OS. A telepítés során a meghajtó törlődik, és a macOS többé nem lesz indítható.

Később még visszaállíthatod az Internet Recovery segítségével, ha szeretnéd.

Ehhez a részhez feltételezzük, hogy már átnézted az [Első lépéseket](02-getting-started.md), és készen áll az USB-meghajtód. Ha nem, menj és tedd meg most.

#### A Secure Boot letiltása

Le kell tiltani az Apple Secure Boot funkcióját ahhoz, hogy indítani lehessen a bootolható USB-t, valamint az OS-t. A letiltásához tedd a következőket:

1. Kapcsold ki a Macedet
2. Kapcsold be, és _azonnal_ nyomd le és tartsd lenyomva a Command-R billentyűkombinációt, amíg meg nem jelenik a betöltési képernyő
3. Válaszd ki a felhasználódat, és add meg a jelszavadat, ha kéri
4. Miután a helyreállítási képernyőn vagy, válaszd a **Utilities > Startup Security Utility** lehetőséget a menüsávból
5. Add meg a jelszavadat, amikor hitelesítéshez kéri
6. Válaszd a „No Security” lehetőséget a Secure Boot beállításai közül
7. Válaszd az „Allow booting from external or removable media” lehetőséget az External Boot beállításai közül

#### A telepítés indítása

1. Helyezd be az USB-meghajtót
2. Indítsd újra a Macedet, és _azonnal_ nyomd le és tartsd lenyomva az Option billentyűt, amíg meg nem jelenik az indítóeszközök képernyője
3. Válaszd a narancssárga EFI Boot eszközt
4. Folytasd a [telepítéssel a szokásos módon](02-getting-started.md)

A telepítő felismeri a Mac hardverét, és automatikusan alkalmazza a szükséges javításokat: a Broadcom Wi-Fi illesztőprogramokat és firmware-t, a FaceTime HD kamera illesztőprogramját a Broadcom 1570-es gépeken (ennek firmware-e az Apple-től töltődik le, amint a Mac online lesz, mivel a telepítő offline működik), az SPI billentyűzet illesztőprogramját azokon a MacBook modelleken, amelyeknek szükségük van rá, valamint egy NVMe felfüggesztési javítást ugyanezekhez a modellekhez.

### Ismert korlátozások

A közösség tagjai folyamatosan dolgoznak ezeknek a kihívásoknak a megoldásán, ezért ha ezek problémát jelentenek számodra, csatlakozz a #omarchy-on-other csatornához a [Discord](https://discord.gg/tXFUdasqhY) felületünkön, és nézd meg, vannak-e naprakész módszerek a megoldásukra.

#### FaceTime HD kamera

A kamera illesztőprogramja lefagyasztja a gépet, ha be van töltve, amikor a Mac hibernálódik, ezért a rendszer először eltávolítja. Nem távolítható el, amíg egy alkalmazás nyitva tartja a kamerát, ezért a hibernálás egy, az alkalmazást megnevező értesítéssel megszakad: zárd be, és hibernálj újra. Ez vonatkozik a kritikus töltöttség esetén történő automatikus hibernálásra is, valamint a suspend-then-hibernate módra, amelyet a rendszer még a felfüggesztés előtt elutasít. A szokásos felfüggesztést maga az illesztőprogram utasítja el, amíg a kamera nyitva van, értesítés nélkül.

A kamera firmware-e az Apple-től töltődik le, ezért a kamera csak akkor működik, ha a Mac már volt online. A letöltés indításkor elkezdődik, és 15 percenként újrapróbálkozik, amíg a hálózat a probléma; ha az Apple fájlja megváltozott, leáll, és Omarchy-frissítésre vár. Ha a kamera nem jelenik meg, a `journalctl -u facetimehd-firmware-fetcher` megmondja, miért, a `sudo systemctl restart facetimehd-firmware-fetcher` újrapróbálja, egy újraindítás pedig betölti az illesztőprogramot, ha a letöltés befejeződött, de a kamera még mindig nincs ott.

#### T1 chippel rendelkező eszközök

Az Apple T1 chip 2016 végén jelent meg, és kizárólag a Touch Barral rendelkező első generációs MacBook Pro modellekben használták.
- MacBook Pro 13 hüvelykes (2016, két Thunderbolt 3 port) – Modell: A1706
- MacBook Pro 13 hüvelykes (2016, négy Thunderbolt 3 port) – Modell: A1708
- MacBook Pro 15 hüvelykes (2016) – Modell: A1707

#### Ismert problémák

- A Touch Bar nem működik
- A hang nem működik

#### T2 chippel rendelkező eszközök

Az Apple T2 Security Chip 2017-ben jelent meg. A T2 chipet az Apple siliconra (M-sorozatú chipekre) való átállással, 2020-tól kezdődően vezették ki.

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

Ezeken a modelleken a telepítő automatikusan beállítja a patchelt `linux-t2` kernelt, a T2 hangkonfigurációt, az Apple Broadcom Wi-Fi/Bluetooth firmware-ét, és a ventilátorvezérlést a `t2fanrd` segítségével. A Touch Bar a kernel beépített, Boot Camp-stílusú támogatásával működik.

#### iMac Retina 5K (2017)

A 2017-es 27 hüvelykes iMacben nincs T2 chip, ezért a telepítő a többi Intel Machez hasonlóan állítja be.

- iMac (Retina 5K, 27 hüvelykes, 2017) – Modell: A1419

#### Ismert problémák

- A kijelző nem a natív 5120×2880 felbontásán fut: a panel két csempéből áll, és az alap illesztőprogram csak az egyiket működteti
- A hang nem működik
- A fényerő-szabályozásnak nincs hatása
- Az alvó állapot lefagyasztja a gépet; csak a ki- és bekapcsolás állítja helyre

Ehhez a modellhez egy közösségi patcher javítja a kijelzőt, a hangot és a fényerőt: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
