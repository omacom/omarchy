# Macről vagy Windowsról érkezve

Ha éveket töltöttél macOS-en vagy Windowson, az ujjaid száz dolgot tudnak, amelyekről az agyad elfelejtette, hogy valaha megtanulta. Ez a fejezet a fordítóréteg: hova kerülnek ezek az ösztönök az Omarchyban. A funkciók maguk bőven le vannak írva máshol — ez csak a térkép.

### A Super minden középpontja

Minden izommemória, amelyet a Cmd vagy a Windows-billentyű köré építettél, egyetlen billentyűre kerül át: a Superre. Ez egy PC-billentyűzeten a Windows-billentyű, és ez szinte minden Omarchy-billentyűparancs kiindulópontja.

A Spotlight- vagy Raycast- vagy Start-menü-reflexedből `Super + Space` lesz. Ez nyitja meg az Omarchy menüt, amely appokat indít, beállításokat módosít, szoftvereket telepít, rögzíti a képernyőt — szinte mindent. Kezdj gépelni a szűréshez. A `Super + Alt + Space` minden appot egyetlen rácson mutat, ahogy a Launchpad teszi. Lásd a [navigációt](04-navigation.md).

### Nincs dokk és nincsenek asztali ikonok

Nincs mi kattintani a dolgok indításához, nincsenek ikonok, amelyeket az asztalon rendezgethetnél. Az appok billentyűparancsról indulnak (`Super + Return` a terminálhoz, `Super + Shift + Return` a böngészőhöz, és `Super + K` minden hozzárendelt dolog listájához) vagy a menüből. Az egyetlen állandó felhasználói felületelem [a felső sáv](05-the-top-bar.md), amely lefedi azt, amit korábban a menüsor, a rendszertálca és az Értesítési központ nyújtott — és szinte minden widget rajta csinál valamit bal, jobb és középső kattintásra.

### Az ablakok maguktól rendeződnek

A legnagyobb szemléletváltás: nem húzogatod az ablakokat, és nem igazítod őket képernyőfelekhez. Megnyitsz egy ablakot, és az kitölti az egész képernyőt. Megnyitsz egy másodikat, és felosztják. Soha nem kell kiásnod egy ablakot egy másik alól, mert az ablakok nem fedik egymást.

Ha valóban szükséged van lebegő ablakra, a `Super + T` ki- (és vissza-) kapcsolja az aktív ablakot a csempézésből. De először adj a csempézésnek egy igazi esélyt — ez az egész dolog szíve. A [Navigáció](04-navigation.md) végigvezet rajta.

A munkaterületek ismerősnek fognak tűnni: ezek a macOS Spaces vagy a Windows virtuális asztalai, csak tényleg használni is fogod őket, mert a `Super + 1/2/3/4` egyenesen odaugrik, a `Super + Shift + 1/2/3/4` pedig az aktív ablakot küldi oda. Nincs animációs késleltetés, csak azonnali ugrások. Ez azt jelenti, hogy talán még több monitorra sincs szükséged, ha korábban ehhez voltál szokva.

### A másolás és beillesztés egyszerűen működik

Macen mindenütt Cmd + C volt. Windowson mindenütt Ctrl + C — kivéve a terminált, ahol megöli a programodat. Az Omarchy a `Super + C`, `Super + X` és `Super + V` kombinációkat adja, és ezek mindenütt működnek, beleértve a terminált is. Nem kell külön reflexet megtanulnod a shellhez.

Windowsosoknak: a Win + V vágólap-előzményetek a `Super + Ctrl + V` alatt él, és képeket is tárol, nemcsak szöveget. Lásd az [egységes vágólapot és előzményeket](08-unified-clipboard-history.md).

### A fordítótáblázat

| Amit keresnél | Az Omarchyban |
| ------------- | ---------- |
| Spotlight / Raycast / Start menü | `Super + Space` — az Omarchy menü |
| AirDrop | LocalSend, a `Super + Ctrl + S` kombinációval — lásd a [GUI-kat](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — lásd a [képernyőképeket és felvételt](12-screenshots-recording.md) |
| Értesítési központ | Értesítési előzmények a `Super + Shift + Alt + ,` kombinációval |
| Time Machine (a rendszerhez) | Automatikus [rendszer-pillanatképek](47-system-snapshots.md) minden frissítéskor |
| App Store / telepítő letöltése | _Telepítés_ a menüben, vagy `omarchy pkg add` — lásd az [egyéb csomagokat](29-other-packages.md) |
| Rendszerbeállítások / Vezérlőpult | _Beállítás_ a menüben, amely egyszerű konfigurációs fájlokat szerkeszt — lásd a [dotfile-okat](31-dotfiles.md) |

### Néhány dolog tényleg más

Sok beállítás szövegfájlokban él, amelyeket te szerkesztesz, nem pedig átkattintható panelekben. Ez primitíven hangzik, amíg rá nem jössz, hogy ez azt jelenti: minden finomhangolás látható, átmásolható a következő gépedre, és verziókezelésbe tehető. A _Beállítás_ menü egyenesen a megfelelő fájlba dob, és újraindítja, amit újra kell indítani, ha kész vagy.

A frissítések egyetlen parancson keresztül érkeznek — _Frissítés > Omarchy_ —, amely magát az Omarchyt és a rendszer minden csomagját frissíti, előbb pillanatképet készítve. Nincsenek véletlenszerűen zaklató appenkénti frissítők. Lásd a [frissítéseket](30-updates.md).

A szoftverek csomagkezelőből érkeznek, nem letöltött telepítőkből.

És amikor bezársz egy ablakot, az app tényleg kilép. Nincs macOS-es limbó, ahol a program tovább fut ablakok nélkül. A `Super + W` — vagy a `Super + Q`, ha ezzel az ujjemlékezettel érkeztél — azt jelenti: vége.

### Mac-hardveren

Az Omarchy jól fut Intel Maceken — lásd a [Mac-támogatást](44-mac-support.md). És a billentyűzet is kíméletes veled: az Omarchy nem rendel át semmit, és a Linux a Command billentyűt Superként kezeli, így a Super pontosan ott ül, ahol a Cmd mindig volt. A hüvelykujjad észre sem veszi a költözést.

### Adj neki két hetet

Az ösztönök gyorsabban átkerülnek, mint gondolnád. Nézd át egyszer a [billentyűparancsok](07-hotkeys.md) fejezetet, és valahányszor nem jut eszedbe egy hozzárendelés, nyomd meg a `Super + K` kombinációt — megmutatja az összeset. Ez az egyetlen billentyűparancs, amelyet tényleg meg kell jegyezned.
