# Első lépések

Az Omarchy telepítése ISO segítségével történik. Választhatsz a teljes lemezes telepítés, amely átveszi az egész meghajtót, vagy a szabad helyre történő telepítés között, amely az Omarchy-t a meghajtó le nem foglalt területére helyezi — így tudsz dual bootot használni a Windows vagy egy másik OS mellett (lásd: [dual-boot telepítés](50-dual-boot-install.md) — vedd figyelembe, hogy előbb ki kell kapcsolnod a BitLockert a Windowsban). Akárhogy is, a telepítés alapértelmezés szerint teljes titkosítást használ, és a teljes lemezes lehetőség törli a kiválasztott meghajtót, ezért mindenképpen készíts biztonsági mentést, mielőtt egy már meglévőt használnál!

Előbb [töltsd le az Omarchy ISO-t](https://omarchy.org/), tedd egy USB-stickre (használj [Rufus](https://rufus.ie/) programot Windowson, [balenaEtcher](https://etcher.balena.io/) programot Macen, vagy [caligula](https://github.com/ifd3f/caligula) programot Linuxon), és bootolj arról.

_Ki kell kapcsolnod a Secure Bootot és/vagy a TPM-et a BIOS-ban. Ki kell kapcsolnod ezeket ahhoz, hogy telepíteni tudd az Omarchy-t. Ezek Microsoft biztonsági megoldások, amelyeket a Windowshoz és a Microsofthoz kötődő Linux-disztribúciókhoz szántak._

Ezután válaszold meg a konfigurációs kérdéseket, és erősítsd meg őket így:

 ![install-config](images/install-config.webp)

Ezután válassz ki egy meghajtót a telepítéshez, majd dőlj hátra, és nézd végig a telepítési műsort. A leggyorsabb modern gépeken egy perc alatt megvan, de még egy régebbi számítógépen sem tarthat tovább 5 percnél.

 ![install-done](images/install-done.webp)

Most már készen állsz az Omarchyra!

### Használj vezetékes vagy 2.4ghz-es billentyűzetet!

A teljes lemezes titkosítás miatt induláskor nem tudod Bluetooth-billentyűzetről megadni a jelszót. Ahogy PC-n Bluetooth-billentyűzettel a BIOS-ba sem tudsz belépni. Olyan billentyűzetre lesz szükséged, amely vagy 2.4ghz-es dongle-t, vagy kábelt használ (ami a késleltetés szempontjából egyébként is sokkal jobb!). Nekem személy szerint nagyon bejön a [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Telepítés másik tulajdonos számára

Ha valaki másnak — egy családtagnak, egy új munkatársnak, egy vevőnek — állítasz be egy gépet, nem neked kellene helyettük megválaszolnod a személyes kérdéseket. Nyomd meg a `Ctrl + C` billentyűkombinációt a telepítő legelső képernyőjén (a billentyűzet kiválasztásánál), és az Omarchy ehelyett felajánlja, hogy a gépet egy másik tulajdonos számára készíti elő. A rendszer azonnal települ, de minden személyes beállítás — billentyűzetkiosztás, felhasználónév, jelszó — arra az időpontra marad, amikor a gép először elindul. A meghajtó alapértelmezés szerint továbbra is titkosított, és az a jelszó, amelyet az új tulajdonos ezen az első indításkor választ, egyben a titkosítási jelszó is lesz. (Egy már használt gép újratelepítés nélkül is átadható — lásd: [a számítógép alaphelyzetbe állítása](48-security.md).)

### Felügyelet nélküli telepítések

Az ISO teljesen magától is tud telepíteni — billentyűzet és varázsló nélkül —, ha egy második meghajtón megkapja a konfigurációját. Így érdemes az Omarchy-t alapképként kezelni VM-ekhez és gépcsoportokhoz. Lásd: [felügyelet nélküli telepítések](51-unattended-installs.md).

### Titkosítás nélküli telepítések

Az Omarchy alapértelmezés szerint titkosítással települ. Ez a biztonságos, felelős választás minden olyan számítógépnél, amely esetleg elveszhet vagy ellophatják. Nem akarod, hogy bárki, aki hozzáfér a hardveredhez, hozzáférhessen az adataidhoz is!

De különleges körülmények között, például védett számítógépeken végzett távoli Omarchy-telepítéseknél, vagy érzékeny adatok nélküli, eldobható telepítéseknél előfordulhat, hogy titkosítás nélkül akarsz telepíteni. A lemezformázás megerősítésénél a `Ctrl + C` megnyomásával válthatsz titkosítás nélküli telepítésre.

### Nyelv

Az Omarchy 50 nyelven beszél — ugyanazt a készletet, mint az omarchy.org —, és az alapértelmezett az angol. A váltáshoz nyisd meg az Omarchy menüt, és menj a _Beállítás > Régió > Nyelv_ pontra, vagy futtasd egy terminálban az `omarchy language <code>` parancsot (az `omarchy language list` megmutatja a kódokat). A menü, az asztal és az Omarchy saját értesítései azonnal nyelvet váltanak, és minden alkalmazás, amelyet ezután nyitsz meg, szintén követi ezt. A már megnyitott alkalmazások akkor váltanak, amikor újraindítod őket.

Ha meg akarod tartani a nyelvet, de a dátumokat, időpontokat, számokat, pénzt, mértékegységeket és papírméreteket egy másik régió szokásai szerint akarod írni (például angol nyelv európai dátumokkal és 24 órás órával), válassz ki egy régiót a _Beállítás > Régió > Formátumok_ alatt, ahol minden lehetőséghez tartozik egy minta, vagy futtasd az `omarchy region <code>` parancsot (az `omarchy region list` megmutatja a kódokat). Az _Ugyanaz, mint a nyelv_ visszaállít a nyelv saját formátumaira. A nyelvváltáshoz hasonlóan ez is az ezután megnyitott alkalmazásokra érvényes.

### Segítség, ha elakadtál

Ha elakadsz, általában találsz valakit, aki szívesen segít a _#omarchy-help_ csatornán a [közösségi Discordon](https://omarchy.org/discord).
