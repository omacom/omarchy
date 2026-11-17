# Frissítések

Az Omarchy és a csomagjaid az Omarchy menü _Frissítés > Omarchy_ menüpontjával tarthatók naprakészen (`Super + Space`).

Maga az Omarchy hagyományos pacman csomagokként települ az [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) tárolóból, így egy frissítés telepíti a [legújabb Omarchy kiadást](https://github.com/omacom/omarchy/releases), lefuttatja a függőben lévő migrációkat, hogy a rendszered szinkronba kerüljön a legújabb verzióval, és frissíti az összes rendszer-csomagot az [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) tükörről és az [AUR](https://aur.archlinux.org/) tárolóból (ha telepítettél bármilyen AUR csomagot).

Amikor új kiadások jelennek meg, egy kör alakú nyíl ikon jelenik meg az órád jobb oldalán. Kattints rá, és a frissítési folyamat elindul.

![update-available](images/update-available.webp)

### Négy csatorna

Az Omarchy négy csatornán frissül: stable, RC, edge és dev. Az új telepítések a stable csatornán indulnak, amely a [hivatalos kiadásokat](https://github.com/omacom/omarchy/releases/) követi, valamint a [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) tükröt, amely egy hónappal lemaradva követi a legújabbat, így még azelőtt elkaphatunk minden olyan új inkompatibilitást, amely konfigurációs változtatást igényel, mielőtt problémát okozna az embereknek.

De ha szeretnél segíteni ezeknek a lehetséges problémáknak a kiszúrásában, futhatsz az edge csatornán. Ez az Omarchy csomagjaidat a legújabb fejlesztői buildekhez igazítja, és lehetővé teszi, hogy amint elérhetővé válnak, frissíts a legújabb Arch csomagokra. Csak akkor tedd ezt, ha tapasztalt Linux-felhasználó vagy, és tudod, hogyan kell helyreállítani egy problémás rendszert.

Minden új nagyobb kiadás előtt az RC csatornán végezzük el a végső ellenőrzést. Ha érdekel a végső simításokban való segítség, gyere és lógj velünk a #omarchy-release-candidates csatornán Discordon.

Végül ott a dev csatorna, amely az Omarchyt közvetlenül a forráskód `~/omarchy` mappában lévő git checkoutjához kapcsolja, az edge csomagokkal kombinálva. Csak akkor használd ezt a csatornát, ha tapasztalt Linux-felhasználó vagy, közvetlenül az Omarchyn dolgozol, és hajlandó vagy eltűrni a töréseket.

A csatornák között az Omarchy menü _Frissítés > Csatorna_ pontjával válthatsz (vagy terminálban az `omarchy-channel-set` paranccsal).

### Kernelváltás

Az Omarchy a saját `linux-omarchy` kernelét indítja, de mellette másokat is telepítve tarthatsz, például az alap Arch `linux` kernelt vagy egy kísérleti buildet, amelyet éppen tesztelsz. Ha egynél több van, az Omarchy menü _Frissítés > Kernel_ pontja felsorolja őket, egy pipával az alapértelmezés szerint induló mellett. Válassz egy másikat, add meg egyszer a jelszavad, és a következő újraindítás után az fog indulni. A többi kernel megmarad a boot menüben, így kézzel is kiválaszthatod valamelyiket, ha az új alapértelmezett gondot okoz. Terminálban az `omarchy-kernel` mutatja a jelenlegi alapértelmezettet, az `omarchy-kernel list` a telepítetteket, az `omarchy-kernel set <kernel>` pedig a váltáshoz használható.

### Firmware-frissítések

Nem csak a csomagjaid avulhatnak el. Sok laptop és periféria a Linux Vendor Firmware Service-en keresztül szállítja a BIOS-, SSD- és dokkoló-firmware-t, az Omarchy menü _Frissítés > Firmware_ pontja pedig letölti és telepíti, ami csak vár a hardveredre. Első futtatáskor telepíti a `fwupd` csomagot. Rengeteg firmware csak újraindítás közben írható, úgyhogy ne lepődj meg, ha erre kér.

Amikor magában a BIOS-ban kell módosítanod egy beállítást, tartsd lenyomva az `Alt` billentyűt a rendszermenüben (`Super + Escape`), és az _Újraindítás_ _Újraindítás BIOS-ba_ opcióvá változik, amely közvetlenül a firmware-beállításba indít újra anélkül, hogy el kellene kapnod a megfelelő billentyűt bootoláskor. Terminálból ez az `omarchy system firmware`.

### Figyelmeztetés a közvetlen pacman/yay frissítésekről

Ha már ismered az Archot, kísértést érezhetsz, hogy egyszerűen magad futtasd a `pacman -Syu` vagy a `yay -Syu` parancsot, de ha ezt teszed, lemaradsz a pillanatképről, a migrációkról és a konfigurációs frissítésekről, amelyeket az Omarchy az új csomagokkal együtt futtat. Ezért az Omarchy valójában leállít egy közvetlen rendszerfrissítést, és helyette az `omarchy update` parancshoz irányít. (Ha tényleg tudod, mit csinálsz, a védelmi funkció elmondja, hogyan kerülheted meg egyetlen tranzakció erejéig.)

### Rossz frissítések visszaállítása

Ha egy frissítés után valaha problémád adódik, visszaállíthatod a rendszeredet a frissítés előtt készített pillanatképre. Csak indítsd újra, és válaszd ki a boot betöltő menüben azt a pillanatképet, amely a frissítés megkezdése előtti állapotot rögzíti.

![bootloader](images/bootloader.webp)

Ha a konfigurációs fájljaid valahogy megsérültek, Omarchy újratelepítést is végezhetsz a terminálban kiadott `omarchy reinstall` paranccsal. Ez újratelepíti az összes alapértelmezett Omarchy csomagot, a stable csatornára állít, visszaminősít minden túl új csomagot, és visszaállítja az összes konfigurációs fájlt. Vedd figyelembe, hogy ezzel az Omarchy alapértelmezéseihez fűzött összes felhasználói konfigurációs módosításod felülíródik!
