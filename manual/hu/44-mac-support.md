# Mac-támogatás

Az Omarchy beépített támogatással rendelkezik **Intel Macekre**. Jelenleg van néhány ismert korlátozás, de amennyiben tudatában vagy és rendben vagy velük; az Omarchy betöltésével új életet lehelhetsz a régi Maceidbe.

Kérjük, vedd figyelembe, hogy M-sorozatú Macre telepítés jelenleg nem közvetlenül támogatott. Ennek állapotáról többet a #omarchy-on-other csatornán tudhatsz meg a [Discordunkon](https://discord.gg/tXFUdasqhY).

Egy egyszerű tesztben egy 2019-es MacBook Prón egyedül az Omarchy telepítésével 36%-os teljesítménynövekedést értünk el.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Az Omarchy telepítése Macre

Az Omarchy jelenleg csak azt támogatja, hogy az **egyetlen** telepített operációs rendszer legyen. A telepítés során a meghajtó törlődik, és a MacOS nem lesz többé indítható.

Később visszaállíthatod Internet Recovery segítségével, ha szeretnéd.

Ennél a résznél feltételezzük, hogy már átnézted a [Kezdő lépéseket](02-getting-started.md), és készen állt az USB-meghajtód. Ha nem, tedd meg most.

#### A Secure Boot letiltása

Le kell tiltani az Apple Secure Bootját ahhoz, hogy be lehessen tölteni az indítható USB-t, valamint az operációs rendszert. A letiltásához végezd el a következőket:

1. Kapcsold ki a Maced
2. Kapcsold be, és _azonnal_ nyomd meg és tartsd lenyomva a Command-R billentyűket, amíg meg nem látod a betöltőképernyő megjelenését
3. Válaszd ki a felhasználód, és ha kéri, add meg a jelszavad
4. Miután a helyreállítási képernyőre kerültél, válaszd a menüsorból a **Utilities > Startup Security Utility** pontot
5. Add meg a jelszavad, amikor hitelesítésre kérnek
6. Válaszd a „No Security" lehetőséget a Secure Boot lehetőségek közül
7. Válaszd az „Allow booting from external or removable media" lehetőséget az External Boot lehetőségek közül

#### A telepítés elindítása

1. Helyezd be az USB-meghajtót
2. Indítsd újra a Maced, és _azonnal_ nyomd meg és tartsd lenyomva az Option billentyűt, amíg meg nem látod az indítóeszközök képernyőjét
3. Válaszd a narancssárga EFI Boot eszközt
4. Folytasd a [telepítést szokás szerint](02-getting-started.md)

A telepítő érzékeli a Mac-hardvert, és automatikusan alkalmazza a szükséges javításokat: a Broadcom Wi-Fi-illesztőprogramokat és firmware-t, az SPI-billentyűzetillesztőt azokon a MacBook-modelleken, amelyeknek szükségük van rá, és egy NVMe-felfüggesztési javítást ugyanezekre a modellekre.

### Ismert korlátozások

A közösség tagjai folyamatosan dolgoznak ezeknek a kihívásoknak a megoldásán, így ha ezek problémásak számodra, csatlakozz a #omarchy-on-other csatornához a [Discordunkon](https://discord.gg/tXFUdasqhY), és nézd meg, van-e valamilyen naprakész módszer ezek megoldására.

#### T1 chippel rendelkező eszközök

Az Apple T1 chipet 2016 végén vezették be, és kizárólag az első generációs, Touch Barral rendelkező MacBook Pro modellekben használták.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Ismert problémák

- A Touch Bar nem működik
- A hang nem működik

#### T2 chippel rendelkező eszközök

Az Apple T2 biztonsági chipet 2017-ben vezették be. A T2 chipet az Apple siliconra (M-sorozatú chipekre) való áttéréssel 2020-tól kezdve megszüntették.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Ezeken a modelleken a telepítő automatikusan beállítja a foltozott `linux-t2` kernelt, a T2-hangkonfigurációt, az Apple Broadcom Wi-Fi/Bluetooth firmware-jét és a ventilátorvezérlést a `t2fanrd` segítségével. A Touch Bar a kernel beépített Boot Camp-stílusú támogatásán fut.
