# Macről vagy Windowsról érkezve

Ha éveket töltöttél macOS-en vagy Windowson, az ujjaid száz olyan dolgot tudnak, amiről az agyad már elfelejtette, hogy valaha megtanulta. Ez a fejezet a fordítóréteg: hova kerülnek ezek az ösztönök Omarchyban. Magukat a funkciókat máshol részletesen tárgyaljuk — ez csak a térkép.

### A Super mindennek a középpontja

Minden izommemória, amelyet a Cmd vagy a Windows billentyű köré építettél, egyetlen billentyűre vihető át: a Superre. Ez a Windows billentyű egy PC-billentyűzeten, és ez szinte minden Omarchy-gyorsbillentyű horgonya.

A Spotlight-, Raycast- vagy Start menü-reflexedből `Super + Space` lesz. Ez nyitja meg az Omarchy menüt, amely alkalmazásokat indít, beállításokat módosít, szoftvert telepít, képernyőképet készít — nagyjából mindent. Kezdj el gépelni a szűréshez. A `Super + Alt + Space` minden alkalmazást egyetlen rácson mutat meg, ahogyan a Launchpad teszi. Lásd: [navigáció](04-navigation.md).

### Nincsenek asztali ikonok, és a dokk csak lebegő munkaterületen jelenik meg

Nincsenek az asztalon elrendezendő ikonok, és csempéző munkaterületen sincs dokk — a dokk csak lebegő munkaterületen jelenik meg (lásd: [navigáció](04-navigation.md)). Az alkalmazások gyorsbillentyűvel indulnak (`Super + Return` a terminálhoz, `Super + Shift + Return` a böngészőhöz és `Super + K` minden leképezett művelet listájához) vagy a menüből. Az egyetlen állandó felületelem [a felső sáv](05-the-top-bar.md), amely lefedi azt, amit korábban a menüsáv, a rendszertálca és a Notification Center végzett helyetted — és szinte minden widgete csinál valamit bal, jobb és középső kattintásra.

### Az ablakok maguktól helyezkednek el

A legnagyobb szemléletváltás: nem húzod ide-oda az ablakokat, és nem illeszted őket a képernyő feleire. Megnyitsz egy ablakot, és az elfoglalja az egész képernyőt. Megnyitsz egy másodikat, és megosztoznak rajta. Soha nem kell egy ablakot egy másik alól kihalásznod, mert az ablakok nem fedik egymást.

Amikor valóban lebegő ablakra van szükséged, a `Super + T` ki- és visszaváltja az aktív ablakot a csempézésből. De előbb adj a csempézésnek igazi esélyt — ez az egész szíve. A [Navigáció](04-navigation.md) végigvezet rajta.

A munkaterületek ismerősek lesznek: ezek a macOS Spaces vagy a Windows virtuális asztalai, azzal a különbséggel, hogy tényleg használni is fogod őket, mert a `Super + 1/2/3/4` egyenesen az egyikre ugrik, a `Super + Shift + 1/2/3/4` pedig odaviszi az aktív ablakot. Nincs animációs késleltetés, csak azonnali ugrások. Ez azt jelenti, hogy talán több monitorra sem lesz szükséged, ha korábban ahhoz szoktál.

### A másolás és beillesztés egyszerűen működik

Macen mindenhol Cmd + C volt. Windowson mindenhol Ctrl + C volt — kivéve a terminált, ahol megöli a programodat. Az Omarchy a `Super + C`, a `Super + X` és a `Super + V` billentyűket adja, és ezek mindenhol működnek, a terminálban is. Nem kell külön reflexet megtanulnod a shellhez.

Windowsról érkezők: a Win + V vágólap-előzményeid a `Super + Ctrl + V` alatt élnek, és a szöveg mellett képeket is tárolnak. Lásd: [egységes vágólap és előzmények](08-unified-clipboard-history.md).

### A fordítótáblázat

| Amit keresel | Omarchyban |
| ------------- | ---------- |
| Spotlight / Raycast / Start menü | `Super + Space` — az Omarchy menü |
| AirDrop | LocalSend, a `Super + Ctrl + S` billentyűkombinációval — lásd: [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` vagy `Print Screen` — lásd: [képernyőképek és felvétel](12-screenshots-recording.md) |
| Notification Center | Értesítési előzmények a `Super + Shift + Alt + ,` billentyűkombináción |
| Time Machine (a rendszerhez) | Automatikus [rendszer-pillanatfelvételek](47-system-snapshots.md) minden frissítéskor |
| App Store / telepítő letöltése | _Install_ a menüben, vagy `omarchy pkg add` — lásd: [egyéb csomagok](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ a menüben, amely egyszerű konfigurációs fájlokat szerkeszt — lásd: [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, a `Super + Shift + F` billentyűkombinációval — lásd: [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome a `Super + Shift + Return` billentyűkombinációval; válassz másikat a _Setup > Defaults > Browser_ alatt — lásd: [böngészők](23-browsers.md) |
| Preview / Photos | Omaview képekhez, videóhoz és zenéhez, Document Viewer PDF-ekhez — lásd: [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, a `Super + Shift + N` billentyűkombinációval; válassz másikat a _Setup > Defaults > Editor_ alatt |

### Néhány dolog tényleg más

Sok beállítás szöveges fájlokban él, amelyeket te szerkesztesz, nem paneleken, amelyeken végigkattintgatsz. Ez primitívnek hangzik, amíg rá nem jössz, hogy így minden módosítás látható, átmásolható a következő gépedre, és verziókövetés alá tehető. A _Setup_ menü egyenesen a megfelelő fájlba visz, és amikor végeztél, újraindítja azt, amit újra kell indítani.

A frissítések egyetlen paranccsal érkeznek — _Update > Omarchy_ —, amely frissíti magát az Omarchyt és a rendszer minden csomagját, előtte pedig pillanatfelvételt készít. Nincsenek véletlenszerűen zaklató alkalmazásonkénti frissítők. Lásd: [frissítések](30-updates.md).

A szoftverek csomagkezelőből érkeznek, nem letöltött telepítőkből.

És amikor bezársz egy ablakot, az alkalmazás ténylegesen kilép. Nincs macOS-es köztes állapot, ahol a program ablakok nélkül tovább fut. A `Super + W` — vagy a `Super + Q`, ha ezzel az ujjmemóriával érkeztél — azt jelenti: vége.

### Mac hardveren

Az Omarchy jól fut Intel Mac gépeken — lásd: [Mac támogatás](44-mac-support.md). A billentyűzet pedig kedves hozzád: az Omarchy semmit sem képez át, a Linux pedig a Command billentyűt Superként kezeli, így a Super pontosan ott ül, ahol a Cmd mindig is volt. A hüvelykujjad észre sem veszi a váltást.

### Adj neki két hetet

Az ösztönök gyorsabban átjönnek, mint gondolnád. Futd át egyszer a [gyorsbillentyűk](07-hotkeys.md) fejezetet, és amikor nem jut eszedbe egy billentyűkombináció, nyomd meg a `Super + K` billentyűkombinációt — megmutatja mindet. Ez az egyetlen gyorsbillentyű, amelyet tényleg meg kell jegyezned.
