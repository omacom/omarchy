# Macről vagy Windowsról érkezve

Ha éveket töltöttél macOS-en vagy Windowson, az ujjaid száz dolgot tudnak, amiről az agyad már el is felejtette, hogy valaha megtanulta. Ez a fejezet a fordítóréteg: hová kerülnek ezek az ösztönök az Omarchyban. Magukat a funkciókat máshol részletesen tárgyaljuk — ez csak a térkép.

### A Super mindennek a középpontja

A Cmd vagy a Windows-billentyű köré épült összes izommemóriád egyetlen billentyűre száll át: a Superre. Ez a Windows-billentyű egy PC-billentyűzeten, és ez szinte minden Omarchy-gyorsbillentyű horgonya.

A Spotlight-, Raycast- vagy Start menü-reflexedből `Super + Space` lesz. Ez nyitja meg az Omarchy menüt, amely alkalmazásokat indít, beállításokat módosít, szoftvert telepít, képernyőképet készít — nagyjából mindent. Kezdj el gépelni a szűréshez. A `Super + Alt + Space` minden alkalmazást egyetlen rácson mutat meg, ahogy a Launchpad teszi. Lásd [navigáció](04-navigation.md).

### Nincsenek asztali ikonok, és a dokk félreáll az útból

Nincsenek az asztalon rendezgetendő ikonok, és a dokk elrejtőzik, amint egy munkaterületen ablak van, amíg a mutatót a képernyő hozzá tartozó széléhez nem tolod — a jobb oldalhoz, hacsak át nem helyezed (lásd [navigáció](04-navigation.md)). Az alkalmazások gyorsbillentyűről indulnak (`Super + Return` a terminálhoz, `Super + Shift + Return` a böngészőhöz, és `Super + K` minden leképezett dolog listájához) vagy a menüből. Az egyetlen állandó felületelem a [felső sáv](05-the-top-bar.md), amely ellátja azt, amit korábban a menüsor, a rendszertálca és a Notification Center tett érted — és szinte minden widgetje csinál valamit bal, jobb és középső kattintásra.

### Az ablakok maguktól elhelyezkednek

A legnagyobb szemléletváltás: nem húzkodod az ablakokat ide-oda, és nem pattintod őket a képernyő feleire. Megnyitsz egy ablakot, és az elfoglalja az egész képernyőt. Megnyitsz egy másodikat, és megosztoznak rajta. Soha nem kell egy ablakot egy másik alól előhalásznod, mert az ablakok nem fedik egymást.

Amikor tényleg lebegő ablakra van szükséged, a `Super + T` ki- és visszakapcsolja az aktív ablakot a csempézésből. De előbb adj a csempézésnek egy igazi esélyt — ez az egész szíve. A [Navigáció](04-navigation.md) végigvezet rajta.

A munkaterületek ismerősek lesznek: olyanok, mint a macOS Spaces vagy a Windows virtuális asztalai, azzal a különbséggel, hogy ezeket tényleg használni is fogod, mert a `Super + 1/2/3/4` egyenesen az egyikre ugrik, a `Super + Shift + 1/2/3/4` pedig odaküldi az aktív ablakot. Nincs animációs késleltetés, csak azonnali ugrások. Ez azt jelenti, hogy talán több monitorra sem lesz szükséged, ha korábban ahhoz szoktál.

### A másolás és beillesztés egyszerűen működik

Macen mindenhol ott volt neked a Cmd + C. Windowson mindenhol ott volt a Ctrl + C — kivéve a terminált, ahol megöli a programodat. Az Omarchy a `Super + C`, `Super + X` és `Super + V` kombinációkat adja neked, és ezek mindenhol működnek, a terminálban is. Nem kell külön reflexet megtanulnod a shellhez.

Windowsról érkezők: a Win + V vágólap-előzményeitek a `Super + Ctrl + V` alatt élnek, és a szöveg mellett képeket is tárolnak. Lásd [egységes vágólap és előzmények](08-unified-clipboard-history.md).

### A fordítási táblázat

| Mihez nyúlsz | Az Omarchyban |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — az Omarchy menü |
| AirDrop | LocalSend, a `Super + Ctrl + S` segítségével — lásd [GUI-k](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` vagy `Print Screen` — lásd [képernyőképek és felvétel](12-screenshots-recording.md) |
| Notification Center | Értesítési előzmények a `Super + Shift + Alt + ,` alatt |
| Time Machine (a rendszerhez) | Automatikus [rendszer-pillanatképek](47-system-snapshots.md) minden frissítéskor |
| App Store / telepítő letöltése | _Install_ a menüben, vagy `omarchy pkg add` — lásd [egyéb csomagok](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ a menüben, amely egyszerű konfigurációs fájlokat szerkeszt — lásd [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, a `Super + Shift + F` alatt — lásd [GUI-k](22-guis.md) |
| Safari / Edge | Google Chrome a `Super + Shift + Return` alatt; válassz másikat a _Setup > Defaults > Browser_ alatt — lásd [böngészők](23-browsers.md) |
| Preview / Photos | Omaview képekhez, videóhoz és zenéhez, Document Viewer PDF-ekhez — lásd [GUI-k](22-guis.md) |
| TextEdit / Notepad | Plain, a `Super + Shift + N` alatt; válassz másikat a _Setup > Defaults > Editor_ alatt |

### Néhány dolog tényleg más

Sok beállítás szöveges fájlokban él, amelyeket te szerkesztesz, nem paneleken, amelyeken végigkattintgatsz. Ez primitívnek hangzik, amíg rá nem jössz, hogy ez azt jelenti, minden finomhangolás látható, átmásolható a következő gépedre, és verziókezelés alá tehető. A _Setup_ menü egyenesen a megfelelő fájlba dob, és újraindítja, amit újra kell indítani, ha végeztél.

A frissítések egyetlen parancson keresztül érkeznek — _Update > Omarchy_ —, amely frissíti magát az Omarchyt és a rendszer minden csomagját, előtte pillanatképet készítve. Nincsenek alkalmazásonkénti frissítők, amelyek véletlenszerűen zaklatnak. Lásd [frissítések](30-updates.md).

A szoftverek csomagkezelőből érkeznek, nem letöltött telepítőkből.

És amikor bezársz egy ablakot, az alkalmazás tényleg kilép. Nincs macOS-féle limbo, ahol a program ablakok nélkül tovább fut. A `Super + W` — vagy a `Super + Q`, ha ezzel az ujjemlékezettel érkeztél — azt jelenti: vége.

### Mac hardveren

Az Omarchy jól fut Intel Maceken, valamint M1, M2 és M3 Maceken az Omarchy for Apple Silicon segítségével. Lásd [Mac-támogatás](44-mac-support.md). És a billentyűzet kedves hozzád: az Omarchy semmit nem képez át, a Linux pedig a Command billentyűt Superként kezeli, így a Super pontosan ott ül, ahol a Cmd mindig is volt. A hüvelykujjad észre sem veszi a költözést.

### Adj neki két hetet

Az ösztönök gyorsabban átállnak, mint gondolnád. Fuss át egyszer a [gyorsbillentyűk](07-hotkeys.md) fejezeten, és valahányszor nem jut eszedbe egy billentyűkombináció, nyomd meg a `Super + K` kombinációt — megmutatja mindet. Ez az egyetlen gyorsbillentyű, amelyet tényleg meg kell jegyezned.
