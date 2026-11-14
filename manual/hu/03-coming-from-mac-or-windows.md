# Ha Macről vagy Windowsról jössz

Ha évekig macOS-t vagy Windowst használtál, az ujjaid száz dolgot tudnak, amiről az agyad már el is felejtette, hogy valaha megtanulta. Ez a fejezet a fordítóréteg: hova kerülnek ezek az ösztönök Omarchyban. Magukat a funkciókat máshol részletesen tárgyaljuk — ez csak a térkép.

### A Super mindennek a középpontja

Minden izommemória, amit a Cmd vagy a Windows billentyű köré építettél, egyetlen billentyűre száll át: a Superre. Ez PC-billentyűzeten a Windows billentyű, és szinte minden Omarchy-gyorsbillentyű horgonya.

A Spotlight-, Raycast- vagy Start-menü-reflexedből `Super + Space` lesz. Ez nyitja meg az Omarchy menüt, amely appokat indít, beállításokat módosít, szoftvert telepít, rögzíti a képernyőt — szinte mindent. Kezdj el gépelni a szűréshez. A `Super + Alt + Space` minden appot egyetlen rácson mutat meg, ahogy a Launchpad teszi. Lásd: [navigáció](04-navigation.md).

### Nincs dock és nincsenek asztali ikonok

Semmi, amire kattintva indíthatnál dolgokat, nincsenek ikonok, amiket az asztalon rendezgethetnél. Az appok gyorsbillentyűvel indulnak (`Super + Return` a terminálhoz, `Super + Shift + Return` a böngészőhöz, és `Super + K` minden leképezett dolog listájához) vagy a menüből. Az egyetlen állandó UI-elem [a felső sáv](05-the-top-bar.md), amely lefedi azt, amit korábban a menüsor, a rendszertálca és a Notification Center csinált neked — és szinte minden widget rajta csinál valamit bal, jobb és középső kattintásra.

### Az ablakok maguktól elhelyezkednek

A legnagyobb szemléletváltás: nem húzkodod az ablakokat, és nem illeszted őket a képernyő feleire. Megnyitsz egy ablakot, és elfoglalja az egész képernyőt. Megnyitsz egy másodikat, és elfelezik. Sosem kell ablakot kihalásznod egy másik alól, mert az ablakok nem fedik át egymást.

Amikor tényleg lebegő ablakra van szükséged, a `Super + T` kiveszi az aktívat a csempézésből (és vissza is teszi). De előbb adj a csempézésnek igazi esélyt — ez az egész szíve. A [Navigáció](04-navigation.md) végigvezet rajta.

A munkaterületek ismerősek lesznek: ezek a macOS Spaces vagy a Windows virtuális asztalai, csak éppen tényleg használni is fogod őket, mert a `Super + 1/2/3/4` egyenesen az egyikre ugrik, a `Super + Shift + 1/2/3/4` pedig oda küldi az aktív ablakot. Nincs animációs késleltetés, csak azonnali ugrások. Ez azt jelenti, hogy talán több monitorra sem lesz szükséged, ha korábban ahhoz szoktál.

### A másolás és beillesztés egyszerűen működik

Macen mindenhol Cmd + C-t használtál. Windowson mindenhol Ctrl + C-t — kivéve a terminált, ahol megöli a programodat. Omarchy a `Super + C`, `Super + X` és `Super + V` kombinációkat adja, és ezek mindenhol működnek, a terminálban is. Nem kell külön reflexet megtanulnod a shellhez.

Windowsról érkezők: a Win + V vágólap-előzményetek a `Super + Ctrl + V` alatt él, és képeket is tárol, nemcsak szöveget. Lásd: [egységes vágólap és előzmények](08-unified-clipboard-history.md).

### A fordítótáblázat

| Amit megszokásból keresel | Omarchyban |
| ------------- | ---------- |
| Spotlight / Raycast / Start menü | `Super + Space` — az Omarchy menü |
| AirDrop | LocalSend, a `Super + Ctrl + S` segítségével — lásd: [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` vagy `Print Screen` — lásd: [képernyőképek és felvétel](12-screenshots-recording.md) |
| Notification Center | Értesítési előzmények a `Super + Shift + Alt + ,` alatt |
| Time Machine (a rendszerhez) | Automatikus [rendszer-pillanatképek](47-system-snapshots.md) minden frissítéskor |
| App Store / telepítő letöltése | _Telepítés_ a menüben, vagy `omarchy pkg add` — lásd: [egyéb csomagok](29-other-packages.md) |
| System Settings / Control Panel | _Beállítás_ a menüben, amely sima konfigurációs fájlokat szerkeszt — lásd: [dotfiles](31-dotfiles.md) |

### Néhány dolog tényleg más

Sok beállítás szövegfájlokban él, amelyeket te szerkesztesz, nem paneleken, amelyeken végigkattintgatsz. Ez primitívnek hangzik, amíg rá nem jössz, hogy így minden módosítás látható, átmásolható a következő gépedre, és verziókövetés alá tehető. A _Beállítás_ menü egyenesen a megfelelő fájlba dob, és újraindítja, amit újra kell indítani, amikor végeztél.

A frissítések egyetlen parancson át érkeznek — _Frissítés > Omarchy_ —, amely frissíti magát az Omarchyt és a rendszer minden csomagját, előtte pedig pillanatképet készít. Nincsenek véletlenszerűen nyaggató, apponkénti frissítők. Lásd: [frissítések](30-updates.md).

A szoftver csomagkezelőből érkezik, nem letöltött telepítőkből.

És amikor bezársz egy ablakot, az app tényleg kilép. Nincs macOS-féle bizonytalan állapot, ahol a program ablakok nélkül tovább fut. A `Super + W` — vagy a `Super + Q`, ha ezzel az ujjemlékkel érkeztél — azt jelenti: vége.

### Mac hardveren

Az Omarchy jól fut Intel Maceken — lásd: [Mac-támogatás](44-mac-support.md). És a billentyűzet kedves hozzád: az Omarchy nem képez át semmit, a Linux pedig a Command billentyűt Superként kezeli, így a Super pontosan ott ül, ahol a Cmd mindig is volt. A hüvelykujjad észre sem veszi a költözést.

### Adj neki két hetet

Az ösztönök gyorsabban átállnak, mint gondolnád. Futd át egyszer a [gyorsbillentyűk](07-hotkeys.md) fejezetet, és amikor nem jut eszedbe egy billentyűkombináció, nyomd meg a `Super + K` kombinációt — megmutatja mindet. Ez az egyetlen gyorsbillentyű, amit tényleg meg kell jegyezned.
