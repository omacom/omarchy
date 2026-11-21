# Első lépések

Az Omarchy egy ISO segítségével telepíthető. Választhatsz a teljes lemezes telepítés között, amely átveszi az egész meghajtót, vagy a szabad helyre történő telepítés között, amely az Omarchyt a meghajtó lefoglalatlan területére helyezi — így dual bootolsz a Windows vagy egy másik OS mellett (lásd: [dual-boot telepítés](50-dual-boot-install.md) — vedd figyelembe, hogy előbb ki kell kapcsolnod a BitLockert a Windowsban). Akárhogy is, a telepítés alapértelmezetten teljes titkosítást használ, és a teljes lemezes opció törölni fogja a kiválasztott meghajtót, ezért mindenképpen készíts biztonsági mentést, mielőtt egy meglévőt használnál!

Először [töltsd le az Omarchy ISO-t](https://omarchy.org/), tedd egy USB-stickre (használj [Rufus](https://rufus.ie/)-t Windowson, [balenaEtcher](https://etcher.balena.io/)-t Macen vagy [caligula](https://github.com/ifd3f/caligula)-t Linuxon), és bootolj a stickről.

_Ki kell kapcsolnod a Secure Bootot és/vagy a TPM-et a BIOS-ban. Ki kell kapcsolnod ezeket ahhoz, hogy telepíteni tudd az Omarchyt. Ezek Microsoft biztonsági sémák, amelyek Windowshoz és Microsofthoz kapcsolódó Linux-disztribúciókhoz készültek._

Ezután válaszolj a konfigurációs kérdésekre, és erősítsd meg őket így:

 ![install-config](images/install-config.webp)

Ezután válassz ki egy meghajtót a telepítéshez, dőlj hátra, és nézd a telepítés show-ját. A leggyorsabb modern gépeken egy perc alatt kész lehet, de még egy régebbi számítógépen sem tarthat tovább 5 percnél.

 ![install-done](images/install-done.webp)

Most már készen állsz az Omarchyra!

### Használj vezetékes vagy 2.4ghz-es billentyűzetet!

A teljes lemezes titkosítás nem engedi, hogy Bluetooth-billentyűzetről add meg a jelszót indításkor. Ahogy egy PC-n Bluetooth-billentyűzettel a BIOS-ba sem tudsz belépni. Olyan billentyűzetre lesz szükséged, amely vagy 2.4ghz-es dongle-t használ, vagy kábelt (ami latency szempontjából amúgy is sokkal jobb!). Én személy szerint imádom a [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)-et!

### Telepítés másik tulajdonos számára

Ha valaki más számára állítasz be egy gépet — egy családtag, egy új alkalmazott, egy vevő számára —, nem neked kellene megválaszolnod a személyes kérdéseket helyettük. Nyomd meg a `Ctrl + C`-t a telepítő legelső képernyőjén (a billentyűzet kiválasztásánál), és az Omarchy felajánlja, hogy ehelyett másik tulajdonos számára készíti elő a gépet. A rendszer azonnal települ, de minden személyes beállítás — billentyűzetkiosztás, felhasználónév, jelszó — addig halasztódik, amíg a gép először el nem indul. A meghajtó továbbra is alapértelmezetten titkosított, és az új tulajdonos által az első induláskor választott jelszó lesz a titkosítási jelszó is. (Egy már használt gép újratelepítés nélkül is átadható — lásd: [a számítógép visszaállítása](48-security.md).)

### Felügyelet nélküli telepítések

Az ISO teljesen önállóan is tud telepíteni — billentyűzet nélkül, varázsló nélkül —, amikor egy második meghajtón megkapja a konfigurációját. Így érdemes az Omarchyt VM-ek és flottagépek alap image-eként kezelni. Lásd: [felügyelet nélküli telepítések](51-unattended-installs.md).

### Titkosítás nélküli telepítések

Az Omarchy alapértelmezetten titkosítással települ. Ez a biztonságos, felelősségteljes választás minden olyan számítógép esetében, amely esetleg elveszhet vagy ellophatják. Nem akarod, hogy bárki, aki hozzáfér a hardveredhez, hozzáférhessen az adataidhoz!

De különleges körülmények között, például védett számítógépeken történő távoli Omarchy-telepítések vagy érzékeny adatok nélküli, eldobható telepítések esetén érdemes lehet titkosítás nélkül telepíteni. A lemezformázás megerősítésénél megnyomhatod a `Ctrl + C`-t, hogy titkosítás nélküli telepítésre válts.

### Nyelv

Az Omarchy 50 nyelven beszél — ugyanazon a készleten, mint az omarchy.org —, és az angol az alapértelmezett. A váltáshoz nyisd meg az Omarchy menüt, és menj a _Setup > Region > Language_ menüpontra, vagy futtasd az `omarchy language <code>` parancsot egy terminálban (az `omarchy language list` mutatja a kódokat). A menü, az asztal és az Omarchy saját értesítései azonnal nyelvet váltanak, és minden utána megnyitott alkalmazás is követi őket. A már megnyitott appok akkor váltanak, amikor újraindítod őket.

Ha meg akarod tartani a nyelvet, de a dátumokat, időket, számokat, pénzt, mértékegységeket és papírméreteket úgy akarod írni, ahogy egy másik régió teszi (például angolul európai dátumokkal és 24-hour clockkal), válassz egy régiót a _Setup > Region > Formats_ alatt, ahol minden választás mintát mutat, vagy futtasd az `omarchy region formats <code>` parancsot (az `omarchy region formats list` mutatja a kódokat). A _Same as language_ visszaállít a nyelv saját formátumaira. A nyelvváltáshoz hasonlóan ez is az utána megnyitott appokat éri el.

### Segítség, ha elakadsz

Ha elakadsz, általában találsz valakit, aki hajlandó segíteni a _#omarchy-help_ csatornán [a közösségi Discordon](https://omarchy.org/discord).
