# Macről vagy Windowsról érkezve

Ha éveket töltöttél macOS-en vagy Windowson, az ujjaid száz dolgot tudnak, amiről az agyad már elfelejtette, hogy valaha megtanulta. Ez a fejezet a fordítóréteg: hova kerülnek ezek az ösztönök az Omarchyban. Magukat a funkciókat máshol részletesen tárgyaljuk — ez csak a térkép.

### A Super mindennek a középpontja

Minden izommemória, amit a Cmd vagy a Windows billentyű köré építettél, egyetlen billentyűre száll át: a Superre. Ez PC-billentyűzeten a Windows billentyű, és szinte minden Omarchy-gyorsbillentyű horgonya.

A Spotlight-, Raycast- vagy Start menüs reflexedből `Super + Space` lesz. Ez nyitja meg az Omarchy menüt, amely alkalmazásokat indít, beállításokat módosít, szoftvert telepít, képernyőképet készít — szinte mindent. Kezdj el gépelni a szűréshez. A `Super + Alt + Space` minden alkalmazást egyetlen rácsban mutat meg, ahogy a Launchpad teszi. Lásd: [navigáció](04-navigation.md).

### Nincsenek asztali ikonok, és a dokk félreáll az útból

Nincsenek az asztalon rendezgethető ikonok, és a dokk elrejtőzik, amint egy munkaterületen ablak van, amíg a mutatót a képernyő széléhez nem tolod — az alsóhoz, hacsak át nem helyezed (lásd: [navigáció](04-navigation.md)). Az alkalmazások gyorsbillentyűvel indulnak (`Super + Return` a terminálhoz, `Super + Shift + Return` a böngészőhöz, és `Super + K` minden leképezett dolog listájához) vagy a menüből. Az egyetlen állandó felületelem [a felső sáv](05-the-top-bar.md), amely lefedi azt, amit korábban a menüsor, a rendszertálca és a Notification Center tett érted — és szinte minden widget rajta csinál valamit bal, jobb és középső kattintásra.

### Az ablakok maguktól elhelyezkednek

A legnagyobb szemléletváltás: nem húzkodod az ablakokat, és nem illeszted őket a képernyő feleire. Megnyitsz egy ablakot, és elfoglalja az egész képernyőt. Megnyitsz egy másodikat, és megosztoznak rajta. Soha nem kell egy ablakot egy másik alól kihalásznod, mert az ablakok nem fedik egymást.

Amikor tényleg lebegő ablakra van szükséged, a `Super + T` kapcsolja ki az aktív ablakot a csempézésből (és vissza). De előbb adj a csempézésnek igazi esélyt — ez az egész szíve. A [Navigáció](04-navigation.md) végigvezet rajta.

A munkaterületek ismerősek lesznek: ezek a macOS Spaces vagy a Windows virtuális asztalai, azzal a különbséggel, hogy tényleg használni is fogod őket, mert a `Super + 1/2/3/4` egyenesen az egyikre ugrik, a `Super + Shift + 1/2/3/4` pedig az aktív ablakot küldi oda. Nincs animációs késleltetés, csak azonnali ugrás. Ez azt jelenti, hogy talán több monitorra sincs szükséged, ha korábban ahhoz szoktál.

### A másolás és beillesztés egyszerűen működik

Macen mindenhol Cmd + C volt. Windowson mindenhol Ctrl + C volt — kivéve a terminált, ahol megöli a programodat. Az Omarchy a `Super + C`, `Super + X` és `Super + V` kombinációkat adja, és ezek mindenhol működnek, a terminálban is. Nem kell külön reflexet tanulnod a shellhez.

Windowsosok: a Win + V vágólaptörténeted a `Super + Ctrl + V` alatt él, és képeket is tárol, nem csak szöveget. Lásd: [egységes vágólap és előzmények](08-unified-clipboard-history.md).

### A fordítótáblázat

| Amiért nyúlsz | Az Omarchyban |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — az Omarchy menü |
| AirDrop | LocalSend, a `Super + Ctrl + S` révén — lásd: [GUI-k](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` vagy `Print Screen` — lásd: [képernyőképek és felvétel](12-screenshots-recording.md) |
| Notification Center | Értesítési előzmények a `Super + Shift + Alt + ,` alatt |
| Time Machine (a rendszerhez) | Automatikus [rendszerpillanatképek](47-system-snapshots.md) minden frissítéskor |
| App Store / telepítő letöltése | _Install_ a menüben, vagy `omarchy pkg add` — lásd: [egyéb csomagok](29-other-packages.md) |
| Rendszerbeállítások / Vezérlőpult | _Setup_ a menüben, amely sima konfigurációs fájlokat szerkeszt — lásd: [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, a `Super + Shift + F` alatt — lásd: [GUI-k](22-guis.md) |
| Safari / Edge | Google Chrome a `Super + Shift + Return` alatt; válassz másikat a _Setup > Defaults > Browser_ alatt — lásd: [böngészők](23-browsers.md) |
| Preview / Photos | Omaview képekhez, videóhoz és zenéhez, Document Viewer PDF-ekhez — lásd: [GUI-k](22-guis.md) |
| TextEdit / Notepad | Plain, a `Super + Shift + N` alatt; válassz másikat a _Setup > Defaults > Editor_ alatt |

### Néhány dolog tényleg más

Sok beállítás szöveges fájlokban él, amelyeket szerkesztesz, nem paneleken, amelyeken végigkattintgatsz. Ez primitívnek hangzik, amíg rá nem jössz, hogy így minden finomhangolás látható, átmásolható a következő gépedre, és verziókövetés alá tehető. A _Setup_ menü egyenesen a megfelelő fájlba dob, és amikor végeztél, újraindítja, amit újra kell indítani.

A frissítések egyetlen parancson keresztül érkeznek — _Update > Omarchy_ —, amely frissíti magát az Omarchyt és a rendszer minden csomagját, előtte pillanatképet készítve. Nincsenek alkalmazásonkénti frissítők, amelyek véletlenszerűen zaklatnak. Lásd: [frissítések](30-updates.md).

A szoftver csomagkezelőből jön, nem letöltött telepítőkből.

És amikor bezársz egy ablakot, az alkalmazás tényleg kilép. Nincs macOS-féle bizonytalanság, ahol a program ablakok nélkül tovább fut. A `Super + W` — vagy a `Super + Q`, ha ezzel az ujjmemóriával érkeztél — azt jelenti: vége.

### Mac hardveren

Az Omarchy jól fut Intel Maceken, valamint M1, M2 és M3 Maceken az Omarchy for Apple Silicon segítségével. Lásd: [Mac támogatás](44-mac-support.md). A billentyűzet pedig kedves hozzád: az Omarchy nem képez át semmit, és a Linux a Command billentyűt Superként kezeli, így a Super pontosan ott ül, ahol a Cmd mindig is volt. A hüvelykujjad észre sem veszi a költözést.

### Adj neki két hetet

Az ösztönök gyorsabban átállnak, mint gondolnád. Fuss át egyszer a [gyorsbillentyűk](07-hotkeys.md) fejezeten, és amikor nem jut eszedbe egy leképezés, üsd le a `Super + K` kombinációt — megmutatja mindet. Ez az egyetlen gyorsbillentyű, amelyet tényleg meg kell jegyezned.
