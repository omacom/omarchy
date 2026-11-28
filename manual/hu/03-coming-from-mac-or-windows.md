# Ha Macről vagy Windowsról érkezel

Ha éveket töltöttél macOS-en vagy Windowson, az ujjaid száz olyan dolgot tudnak, amiről az agyad már elfelejtette, hogy valaha megtanulta. Ez a fejezet a fordítóréteg: hová kerülnek ezek az ösztönök az Omarchyban. Magukat a funkciókat máshol részletesen tárgyaljuk — ez csak a térkép.

### A Super mindennek a középpontja

A Cmd vagy a Windows billentyű köré épült összes izommemóriád egyetlen billentyűre száll át: a Superre. Ez PC-billentyűzeten a Windows billentyű, és ez szinte minden Omarchy-gyorsbillentyű horgonya.

A Spotlight-, Raycast- vagy Start menüs reflexedből `Super + Space` lesz. Ez nyitja meg az Omarchy menüt, amely appokat indít, beállításokat módosít, szoftvert telepít, képernyőképet készít — nagyjából mindent. Kezdj el gépelni a szűréshez. A `Super + Alt + Space` minden appot egyetlen rácson mutat meg, ahogy a Launchpad teszi. Lásd: [navigáció](04-navigation.md).

### Nincsenek asztali ikonok, és a dokk csak akkor jelenik meg, ha lebegtetsz

Nincsenek az asztalon rendezgetendő ikonok, és csempéző munkaterületen dokk sincs — a dokk csak lebegő munkaterületen jelenik meg (lásd: [navigáció](04-navigation.md)). Az appok gyorsbillentyűvel indulnak (`Super + Return` a terminálhoz, `Super + Shift + Return` a böngészőhöz, `Super + K` pedig minden hozzárendelt dolog listájához) vagy a menüből. Az egyetlen állandó felületelem [a felső sáv](05-the-top-bar.md), amely lefedi azt, amit korábban a menüsáv, a rendszertálca és a Notification Center tett érted — és szinte minden widget rajta csinál valamit bal, jobb és középső kattintásra.

### Az ablakok maguktól elhelyezkednek

A legnagyobb szemléletváltás: nem húzkodod az ablakokat, és nem illeszted őket a képernyő feleire. Megnyitsz egy ablakot, és az elfoglalja az egész képernyőt. Megnyitsz egy másodikat, és megosztoznak rajta. Soha nem kell egy ablakot egy másik alól kihalásznod, mert az ablakok nem fedik egymást.

Amikor tényleg lebegő ablakra van szükséged, a `Super + T` kapcsolja ki az aktív ablakot a csempézésből (és vissza). De előbb adj a csempézésnek igazi esélyt — ez az egész szíve. A [Navigáció](04-navigation.md) végigvezet rajta.

A munkaterületek ismerősek lesznek: olyanok, mint a macOS Spaces vagy a Windows virtuális asztalai, azzal a különbséggel, hogy ezeket tényleg használni is fogod, mert a `Super + 1/2/3/4` egyenesen az egyikre ugrik, a `Super + Shift + 1/2/3/4` pedig odaküldi az aktív ablakot. Nincs animációs késleltetés, csak azonnali ugrások. Ez azt jelenti, hogy talán több monitorra sem lesz szükséged, ha korábban ahhoz szoktál.

### A másolás és beillesztés egyszerűen működik

Macen mindenhol ott volt a Cmd + C. Windowson mindenhol ott volt a Ctrl + C — kivéve a terminált, ahol megöli a programodat. Az Omarchy a `Super + C`, a `Super + X` és a `Super + V` kombinációkat adja neked, és ezek mindenhol működnek, a terminálban is. Nem kell külön reflexet megtanulnod a shellhez.

Windowsosok: a Win + V-s vágólapelőzményetek a `Super + Ctrl + V` alatt él, és képeket is tárol, nemcsak szöveget. Lásd: [egységes vágólap és előzmények](08-unified-clipboard-history.md).

### A fordítótáblázat

| Amiért nyúlsz | Az Omarchyban |
| ------------- | ---------- |
| Spotlight / Raycast / Start menü | `Super + Space` — az Omarchy menü |
| AirDrop | LocalSend, a `Super + Ctrl + S` kombinációval — lásd: [GUI-k](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` vagy `Print Screen` — lásd: [képernyőképek és felvétel](12-screenshots-recording.md) |
| Notification Center | Értesítési előzmények a `Super + Shift + Alt + ,` kombinációval |
| Time Machine (a rendszerhez) | Automatikus [rendszer-pillanatképek](47-system-snapshots.md) minden frissítéskor |
| App Store / telepítő letöltése | _Install_ a menüben, vagy `omarchy pkg add` — lásd: [egyéb csomagok](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ a menüben, amely egyszerű konfigurációs fájlokat szerkeszt — lásd: [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, a `Super + Shift + F` kombinációval — lásd: [GUI-k](22-guis.md) |
| Safari / Edge | Google Chrome a `Super + Shift + Return` kombinációval; válassz másikat a _Setup > Defaults > Browser_ alatt — lásd: [böngészők](23-browsers.md) |
| Preview / Photos | Omaview képekhez, videókhoz és zenéhez, Document Viewer PDF-ekhez — lásd: [GUI-k](22-guis.md) |
| TextEdit / Notepad | Plain, a `Super + Shift + N` kombinációval; válassz másikat a _Setup > Defaults > Editor_ alatt |

### Néhány dolog tényleg más

Sok beállítás szöveges fájlokban él, amelyeket te szerkesztesz, nem paneleken, amelyeken végigkattintgatsz. Ez primitívnek hangzik, amíg rá nem jössz, hogy így minden finomhangolás látható, átmásolható a következő gépedre, és verziókövetés alá tehető. A _Setup_ menü egyenesen a megfelelő fájlba dob, és amikor végeztél, újraindít mindent, amit újra kell indítani.

A frissítések egyetlen parancson keresztül érkeznek — _Update > Omarchy_ —, amely frissíti magát az Omarchyt és a rendszer minden csomagját, előtte pedig pillanatképet készít. Nincsenek külön appfrissítők, amelyek véletlenszerűen nyaggatnának. Lásd: [frissítések](30-updates.md).

A szoftver csomagkezelőből érkezik, nem letöltött telepítőkből.

És amikor bezársz egy ablakot, az app tényleg kilép. Nincs macOS-es köztes állapot, ahol a program ablakok nélkül tovább fut. A `Super + W` — vagy a `Super + Q`, ha ezzel az ujjmemóriával érkeztél — azt jelenti: vége.

### Mac hardveren

Az Omarchy jól fut Intel Maceken, valamint M1, M2 és M3 Maceken az Omarchy for Apple Silicon segítségével. Lásd: [Mac-támogatás](44-mac-support.md). A billentyűzet pedig kedves hozzád: az Omarchy semmit nem rendel át, a Linux pedig a Command billentyűt Superként kezeli, így a Super pontosan ott ül, ahol a Cmd mindig is volt. A hüvelykujjad észre sem veszi a váltást.

### Adj neki két hetet

Az ösztönök gyorsabban átállnak, mint gondolnád. Futd át egyszer a [gyorsbillentyűk](07-hotkeys.md) fejezetet, és amikor üresen jár az agyad egy hozzárendelésnél, nyomd meg a `Super + K` kombinációt — megmutatja az összeset. Ez az egyetlen gyorsbillentyű, amelyet tényleg meg kell jegyezned.
