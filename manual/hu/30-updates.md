# Frissítések

Az Omarchy és a csomagjaid az Omarchy menüben (`Super + Space`) található _Update > Omarchy_ ponttal tarthatók naprakészen.

Az Omarchy maga hagyományos pacman csomagokként települ az [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) tárolóból, így egy frissítés telepíti [a legújabb Omarchy kiadást](https://github.com/omacom/omarchy/releases), lefuttat minden függőben lévő migrációt, hogy a rendszered összhangba kerüljön a legújabbal, és frissíti az összes rendszer-csomagot az [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) tükörről és az [AUR](https://aur.archlinux.org/) tárolóból (ha telepítettél bármilyen AUR csomagot).

Amikor új kiadások jelennek meg, egy kör alakú nyíl ikon jelenik meg az órádtól jobbra. Kattints rá, és a frissítési folyamat elindul.

![update-available](images/update-available.webp)

### Négy csatorna

Az Omarchy négy csatornán keresztül frissül: stable, RC, edge és dev. Az új telepítések a stable csatornán indulnak, amely a [hivatalos kiadásokat](https://github.com/omacom/omarchy/releases/) követi, valamint a [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) tükröt, amely egy hónappal lemarad a legújabbtól, így még azelőtt elkaphatunk minden új inkompatibilitást, amely konfigurációs változtatásokat igényel, mielőtt problémát okozna az embereknek.

De ha szeretnél segíteni ezeknek a lehetséges problémáknak a kiszúrásában, futhatsz az edge csatornán. Ez az Omarchy csomagjaidat a legújabb fejlesztői buildek követésén tartja, és lehetővé teszi, hogy a legújabb Arch csomagokra frissíts, amint elérhetővé válnak. Csak akkor tedd ezt, ha tapasztalt Linux-felhasználó vagy, és tudod, hogyan kell helyreállítani egy problémás rendszert.

Minden új nagyobb kiadás előtt az RC csatornán végezzük el a végső ellenőrzést. Ha érdekel, hogy segíts az utolsó simításokban, gyere, és lógj velünk a Discord #omarchy-release-candidates csatornáján.

Végül ott van a dev csatorna, amely közvetlenül egy `~/omarchy` mappában lévő, a forráskódból készült git checkouthoz köti az Omarchyt, az edge csomagokkal kombinálva. Csak akkor használd ezt a csatornát, ha tapasztalt Linux-felhasználó vagy, közvetlenül az Omarchyn dolgozol, és hajlandó vagy elviselni a törést.

Csatornák között az Omarchy menü _Update > Channel_ pontjával válthatsz (vagy terminálban az `omarchy channel set <stable|rc|edge|dev>` paranccsal, az `omarchy channel current` paranccsal pedig megnézheted, hol vagy éppen).

### Kernelek közötti váltás

Az Omarchy a saját `linux-omarchy` kerneljével indul, de mellette másokat is telepítve tarthatsz, például az alap Arch `linux` kernelt vagy egy kísérleti buildet, amelyet éppen tesztelsz. Ha egynél több van, az Omarchy menü _Update > Kernel_ pontja felsorolja őket, és egy pipa jelöli azt, amelyik alapértelmezetten indul. Válassz egy másikat, add meg egyszer a jelszavadat, és a következő újraindítás után azzal fog indulni. A többi kernel a boot menüben marad, így kézzel is választhatsz közülük, ha az új alapértelmezett gondot okoz. Terminálban az `omarchy kernel` mutatja meg az aktuális alapértelmezettet, az `omarchy kernel list` a telepítetteket, az `omarchy kernel set <kernel>` pedig a váltásra szolgál.

### Firmware-frissítések

Nem csak a csomagjaid avulhatnak el. Sok laptop és periféria a Linux Vendor Firmware Service-en keresztül kínálja a BIOS-, SSD- és dokkoló-firmware-t, és az Omarchy menü _Update > Firmware_ pontja letölti és telepíti mindazt, ami a hardveredre vár. Az első futtatáskor telepíti az `fwupd` csomagot. Sok firmware csak újraindítás közben írható fel, ezért ne lepődj meg, ha erre kér.

Amikor magában a BIOS-ban kell módosítanod egy beállítást, tartsd lenyomva az `Alt` billentyűt a rendszermenüben (`Super + Escape`), és a _Reboot_ _Reboot to BIOS_ ponttá változik, amely közvetlenül a firmware-beállításba indít újra, anélkül hogy induláskor el kellene kapnod a megfelelő billentyűt. Terminálból ez az `omarchy system firmware`.

### Figyelmeztetés a közvetlen pacman/yay frissítésekről

Ha már ismered az Archot, csábító lehet egyszerűen magad futtatni a `pacman -Syu` vagy `yay -Syu` parancsot, de ha így teszel, lemaradsz a pillanatképről, a migrációkról és a konfigurációs frissítésekről, amelyeket az Omarchy az új csomagokkal együtt futtat. Ezért az Omarchy valójában leállít egy közvetlen rendszerfrissítést, és helyette az `omarchy update` parancshoz irányít. (Ha tényleg tudod, mit csinálsz, a védelmi mechanizmus elárulja, hogyan kerülheted meg egyetlen tranzakció erejéig.)

### Rossz frissítések visszaállítása

Ha frissítés után valaha is problémád adódik, visszaállíthatod a rendszeredet a frissítés előtt készített pillanatképre. Csak indítsd újra, és válaszd ki a boot betöltőmenüben azt a pillanatképet, amely a frissítés elindítása előtti állapotot rögzíti.

![bootloader](images/bootloader.webp)

Ha a konfigurációs fájljaid valahogyan megsérültek, terminálban az `omarchy reinstall` paranccsal Omarchy-újratelepítést is végezhetsz. Ez újratelepíti az összes alapértelmezett Omarchy csomagot, a stable csatornára tesz (Apple Silicon esetén edge csatornára), visszaminősít minden túl új csomagot, és visszaállítja az összes konfigurációs fájlt. Vedd figyelembe, hogy ezzel az Omarchy alapértelmezéseihez fűzött összes saját konfigurációs módosításod felülíródik!
