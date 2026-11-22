# Mac támogatás

## Omarchy Apple Siliconra

Az Omarchy for Apple Silicon az Omacom hivatalos megoldása, amely először az Omarchy 4.5 verzióval jelent meg. A macOS mellé települ, és a Mac indításakor választhatsz a kettő közül.

Értesítést kaptál az Omarchy Macről? Ugrás ide: [Ha Omarchy Macről váltasz](#coming-from-omarchy-mac).

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

Az M4-es és újabb Macek még nem támogatottak. Az M4 támogatása tesztelés alatt áll az edge csatornán, és ez következik. A telepítő ellenőrzi a Macedet, mielőtt bármit módosítana.

Bármely Apple Silicon Macen, beleértve az M4-es és újabb modelleket is, futtathatod az Omarchyt virtuális gépben a [Try Omarchy](https://github.com/omacom/try-omarchy) segítségével.

### Amire szükséged van

- macOS 15 Sequoia vagy újabb, valamint egy rendszergazdai fiók
- Szabad lemezterület az Omarchy számára. A telepítő javasol egy méretet, és hagyja, hogy módosítsd.
- Biztonsági mentés a Macedről, áramellátás és internetkapcsolat. A telepítés több gigabájtot tölt le.

### Telepítés

A telepítés macOS-ből történik. Telepítsd az Omarchy Installert a [Homebrew](https://brew.sh) segítségével:

```sh
brew install omacom/mac/omarchy
```

Vagy töltsd le a legújabb Omarchy Installert a [kiadások oldaláról](https://github.com/omacom/omarchy-mac-installer/releases), és nyisd meg.

A telepítő ellenőrzi a Macedet, megmutatja a tervet, és helyet csinál az Omarchynak a macOS-partíció zsugorításával. A macOS a lemezen marad, és nincs szükség USB-meghajtóra. Amikor az első szakasz kész, végigvezet a beállítás befejezésén a macOS Recoveryben: állítsd le a gépet, tartsd nyomva a bekapcsológombot, amíg meg nem jelenik a „Loading startup options” felirat, válaszd az Omarchyt, és kövesd a lépéseket.

Első indításkor az Omarchy jelszót kér, amely titkosítja a lemezét. Nincs helyreállítási kulcs: ha elfelejted a jelszót, az Omarchy-fájljaid nem állíthatók vissza.

Ha később váltanál az Omarchy és a macOS között, állítsd le a gépet, majd tartsd nyomva a bekapcsológombot, amíg meg nem jelennek az indítási lehetőségek, és válassz egyet.

### Ha Omarchy Macről váltasz

Az Omarchy Mac mostantól az Omarchy for Apple Silicon része, és minden Mac támogatott, amelyen futott. A jelenlegi telepítésed tovább fut, és a rendszercsomagjai továbbra is frissülnek, de Omarchy-frissítéseket már nem kap. Nincs határidő és nincs helyben történő frissítés: biztonsági mentést készítesz, eltávolítod a régi telepítést, frissen telepítesz, és visszaállítasz. A 2–5. lépések macOS-ben történnek, ezért az újraindítás előtt nyisd meg ezt az oldalt a telefonodon.

1. **Készíts biztonsági mentést az Omarchyból, a Macen kívülre.** A régi telepítés eltávolítása törli azt, a macOS pedig nem tudja olvasni az Omarchy-lemezt. Másold a home mappádat egy külső meghajtóra vagy egy másik számítógépre, beleértve az SSH- és GPG-kulcsokat, a böngészőprofilokat és a nem pusholt munkát. Mentsd el a csomaglistádat ezzel: `pacman -Qqe > ~/packages.txt`. Készíts biztonsági mentést a macOS-ről is, mivel mind az eltávolítás, mind a telepítés átméretezi a lemezét.
2. **Indítsd el a Macedet macOS-ben.** Állítsd le, tartsd nyomva a bekapcsológombot, amíg meg nem jelennek az indítási lehetőségek, és válaszd a macOS-t.
3. **Telepítsd az Omarchy Installert** a [Telepítés](#installing) részben leírtak szerint.
4. **Távolítsd el a régi telepítést.** Nyisd meg az Omarchy Installert, és válaszd az Installation > Remove Omarchy lehetőséget. Megmutatja, mit fog törölni, és visszaadja a helyet a macOS-nek. Ha nem ismeri fel a telepítésedet, a lemez módosítása nélkül leáll. Kérj segítséget a [Discord](https://discord.gg/tXFUdasqhY) felületén ahelyett, hogy kézzel törölnél partíciókat, ami törölheti a macOS-t.
5. **Telepítsd az Omarchy for Apple Silicont** a telepítővel.
6. **Állítsd vissza a fájljaidat.** A beállításaidat darabonként hozd vissza ahelyett, hogy az összes `~/.config` tartalmat az új alapértelmezésekre másolnád, mivel a régi beállítások felülírhatják azokat.

### Jó tudni

- M1-es és M2-es MacBookokon a fedél felnyitásával vagy a bekapcsológomb megnyomásával ébreszd fel a gépet alvó állapotból.
- Kérdések vagy problémák: kérdezz a [Discord](https://discord.gg/tXFUdasqhY) felületünkön.

A [telepítő README-je](https://github.com/omacom/omarchy-mac-installer#readme) foglalkozik a kiadási csatornákkal, a telepítő frissítésével és az Omarchy eltávolításával.

## Intel Macek

Egy egyszerű tesztben 36%-os teljesítménynövekedést tudtunk elérni egy 2019-es MacBook Prón pusztán az Omarchy telepítésével.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Az Omarchy telepítése Macre

Az Omarchy jelenleg csak egyedüli telepített OS-ként támogatott. A telepítés során a meghajtó törlődik, és a macOS már nem lesz indítható.

Később még visszaállíthatod az Internet Recovery segítségével, ha szeretnéd.

Ennél a résznél feltételezzük, hogy már átnézted az [Első lépések](02-getting-started.md) részt, és az USB-meghajtód készen áll. Ha nem, tedd meg most.

#### A Secure Boot letiltása

Le kell tiltani az Apple Secure Boot funkcióját ahhoz, hogy indítható legyen az indítható USB, valamint az OS is. A letiltásához tedd a következőket:

1. Kapcsold ki a Macedet
2. Kapcsold be, és _azonnal_ tartsd lenyomva a Command-R billentyűket, amíg meg nem jelenik a betöltőképernyő
3. Válaszd ki a felhasználódat, és add meg a jelszavadat, ha a rendszer kéri
4. Miután a helyreállítási képernyőre jutottál, válaszd a menüsorból a **Utilities > Startup Security Utility** lehetőséget
5. Add meg a jelszavadat, amikor hitelesítésre kér
6. Válaszd a „No Security” lehetőséget a Secure Boot beállításai közül
7. Válaszd a „Allow booting from external or removable media” lehetőséget az External Boot beállításai közül

#### A telepítés indítása

1. Helyezd be az USB-meghajtót
2. Indítsd újra a Macedet, és _azonnal_ tartsd lenyomva az Option billentyűt, amíg meg nem jelenik az indítóeszközök képernyője
3. Válaszd ki a narancssárga EFI Boot eszközt
4. Folytasd a [telepítést a szokásos módon](02-getting-started.md)

A telepítő észleli a Mac hardverét, és automatikusan alkalmazza a szükséges javításokat: a Broadcom Wi-Fi-illesztőprogramokat és firmware-t, az SPI billentyűzet-illesztőprogramot azokon a MacBook modelleken, amelyeknek szükségük van rá, és egy NVMe felfüggesztési javítást ugyanezekre a modellekre.

### Ismert korlátozások

A közösség tagjai folyamatosan dolgoznak ezeknek a kihívásoknak a megoldásán, ezért ha ezek problémát jelentenek neked, csatlakozz a #omarchy-on-other csatornához a [Discord](https://discord.gg/tXFUdasqhY) felületünkön, és nézd meg, vannak-e naprakész módszerek a megoldásukra.

#### T1 chipes eszközök

Az Apple T1 chipet 2016 végén mutatták be, és kizárólag az első generációs, Touch Barral rendelkező MacBook Pro modellekben használták.
- MacBook Pro 13 hüvelykes (2016, két Thunderbolt 3 port) – Modell: A1706
- MacBook Pro 13 hüvelykes (2016, négy Thunderbolt 3 port) – Modell: A1708
- MacBook Pro 15 hüvelykes (2016) – Modell: A1707

#### Ismert problémák

- A Touch Bar nem működik
- A hang nem működik

#### T2 chipes eszközök

Az Apple T2 Security Chipet 2017-ben mutatták be. A T2 chipet az Apple siliconra (M-szériás chipekre) való átállással szüntették meg, amely 2020-ban kezdődött.

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

Ezeken a modelleken a telepítő automatikusan beállítja a javított `linux-t2` kernelt, a T2 hangkonfigurációt, az Apple Broadcom Wi-Fi/Bluetooth firmware-jét és a ventilátorvezérlést a `t2fanrd` segítségével. A Touch Bar a kernel beépített, Boot Camp-stílusú támogatásával fut.

#### iMac Retina 5K (2017)

A 2017-es 27 hüvelykes iMacben nincs T2 chip, ezért a telepítő a többi Intel Machez hasonlóan állítja be.

- iMac (Retina 5K, 27 hüvelykes, 2017) – Modell: A1419

#### Ismert problémák

- A kijelző nem a natív 5120×2880 felbontásán fut: a panel két csempéből áll, és az alap illesztőprogram csak az egyiket működteti
- A hang nem működik
- A fényerőszabályozásnak nincs hatása
- Az alvó állapot lefagyasztja a gépet; csak a ki- és bekapcsolás hozza vissza

Ehhez a modellhez egy közösségi javítóprogram kijavítja a kijelzőt, a hangot és a fényerőt: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
