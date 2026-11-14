# Kapcsolók, tétlenség és a képernyővédő

Sok minden, amit nap mint nap megváltoztatsz, valójában nem is beállítás. Ez egy mód, amit egy órára bekapcsolsz, aztán megint kikapcsolsz: éjszakai fény, amikor későig dolgozol, ne zavarjanak, amikor prezentálsz, ébren maradás, amikor valamit nézel. Az Omarchy ezeket kapcsolóknak hívja, és mindegyik ugyanúgy működik — egy gyorsbillentyű, egy menübejegyzés és egy parancs, mind ugyanazt a kapcsolót működteti.

### A kapcsolómenü

A `Super + Ctrl + O` közvetlenül megnyitja a _Műveletindító > Kapcsoló_ menüt, vagy az Omarchy menüből (`Super + Space`) is odajuthatsz. A listában minden olyan kapcsoló, amit átkattinthatsz anélkül, hogy azon gondolkodnál, hol lakik az állapot. Az asztal megjelenésére vonatkozó kapcsolók mellette ülnek, a _Megjelenés_ alatt.

A terminálból ugyanezek a kapcsolók az `omarchy toggle <thing>` formában érhetők el. Futtasd az `omarchy toggle` parancsot önmagában, hogy lásd az egész csoportot.

| Kapcsoló | Gyorsbillentyű | Parancs |
| ------ | ------ | ------- |
| Éjszakai fény | — | `omarchy toggle nightlight` |
| Értesítések némítása | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Ébren maradás (nincs tétlenségi zárolás) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Összeomlás rögzítése | — | `omarchy toggle crash-capture` |
| Képernyővédő | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) témaszinkronizálása | — | `omarchy toggle theme sync` |
| Menüsor | `Super + Shift + Space` | `omarchy toggle bar` |
| Érintőpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Érintőképernyő | — | `omarchy toggle touchscreen` |
| Felfüggesztés | — | `omarchy toggle suspend` |
| Hibrid GPU | — | `omarchy toggle hybrid gpu` |

Az érintőpad, az érintőképernyő és a hibrid GPU kapcsolói a _Műveletindító > Hardver_ (`Super + Ctrl + H`) alatt találhatók, nem a Kapcsoló alatt, mivel csak akkor jelennek meg, ha ténylegesen rendelkezel ilyen hardverrel. Az érintőpad- és érintőképernyő-kapcsolók túlélik a Hyprland újratöltését — a letiltott eszköz neve egy kis állapotfájlba mentődik, amelyet a Hyprland indításkor beolvas, hogy ismét letiltsa.

A _Megjelenés_ alatt található a menüsor és az animációk, plusz néhány dolog, amelyek nem `omarchy toggle` parancsok, de ugyanúgy viselkednek: az akkumulátor töltöttségi százaléka a sávban, az alapértelmezett munkaterület-elrendezés, valamint az _Ablakok_ alatt az ablakok közötti hézagok (`Super + Shift + Backspace`) és az 1 ablakos négyzetes képarány (`Super + Ctrl + Backspace`).

Amikor a Hyprlandnek nincs GPU-ja, amivel rajzolhatna, és helyette a CPU-n renderel (llvmpipe), ahogy a még nem támogatott GPU-val rendelkező Maceken, a legtöbb virtuális gépben, vagy amikor egy grafikus illesztőprogram nem töltődik be, az Omarchy kikapcsolja az animációkat, az elmosást és az árnyékokat arra a munkamenetre, és ezt egyszer egy értesítéssel jelzi neked. A _Megjelenés > Animációk be_ visszahozza őket, és az Omarchy ezt a későbbi munkamenetekre is megjegyzi.

Ezek többsége mindössze egy jelzőfájl a `~/.local/state/omarchy/toggles/` alatt. Ha egy szkriptben szeretnél valamelyik alapján elágazni, az `omarchy-toggle-enabled` kilépési kódot ad, ahelyett, hogy neked kellene keresgélned:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

A jelzők a kikapcsolt állapotról kapták a nevüket — `screensaver-off`, `suspend-off`, `bar-off` —, így a jelenlétük azt jelenti, hogy a funkció le van tiltva.

### Jelzők a sávban

Amikor egy mód be van kapcsolva, egy kis jelképet kapsz a felső sáv közepén, az óra mellett. Ez a jelzők widget, és magában hordozza a diktálást, a képernyőfelvételt, a függőben lévő emlékeztetőket, az éjszakai fényt, a ne zavarjanak módot és az ébren maradást.

Az inaktív jelzők rejtve vannak. Vidd az egérmutatót bárhová a sáv fölé, és halványan megjelennek, így rákattinthatsz egyre a bekapcsolásához anélkül, hogy tudnád a gyorsbillentyűjét. Egy aktívra kattintva ismét kikapcsolod. Ha inkább mindig mindegyiket látni szeretnéd, állítsd az `alwaysShow` értékét `true`-ra az `omarchy.indicators` bejegyzésben a `~/.config/omarchy/shell.json` fájlban — lásd [a felső sávot](05-the-top-bar.md) a sáv widgetjeinek konfigurálásáról.

### Éjszakai fény

Az éjszakai fény 4000K-re melegíti a képernyőt, és ismételt átkapcsolása visszaállítja 6500K-re. Kapcsold át a kapcsolómenüből (`Super + Ctrl + O`) vagy az `omarchy toggle nightlight` paranccsal. A hyprsunset hajtja, amelyet a kapcsoló elindít neked, ha még nem fut.

Alapértelmezés szerint a hyprsunset egyáltalán nem nyúl a képernyődhöz. A `~/.config/hypr/hyprsunset.conf` identitásprofillal érkezik, pontosan azért, hogy a kijelző érintetlen maradjon, amíg melegséget nem kérsz. Ha inkább az óra szerint szeretnéd, hogy váltson, cseréld le ezt egy időprofilra:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ezután indítsd el a hyprsunsetet bejelentkezéskor úgy, hogy hozzáadod az `o.launch_on_start("hyprsunset")` sort a `~/.config/hypr/autostart.lua` fájlhoz. A kapcsoló által használt 4000K/6500K pár rögzített, így a konfigurációs fájl az a hely, ahová akkor mész, ha más hőmérsékletet szeretnél.

### Ne zavarjanak

A `Super + Ctrl + Alt + ,` elnémítja az értesítéseket. Amíg be van kapcsolva, nem jelennek meg felugró értesítések, és az áthúzott harang jelző ott ül a sávban, hogy emlékeztessen, miért lett csendes az asztal.

Semmi sem vész el azonban. Az elnémított értesítések visszatartódnak: tedd vissza az utolsó néhányat a képernyőre a `Super + Shift + Alt + ,` kombinációval. A többit lásd az [értesítések](10-notices.md) részben.

Kétféle üzenet továbbra is átjut: az Omarchy saját megerősítő felugró üzenetei valamiről, amit éppen tettél ("Theme changed", "Screenshot saved"), és a parancssorból küldött kritikus riasztások. Azok a csevegőalkalmazások, amelyek mindent kritikusnak jelölnek, hogy erővel eléd tolakodjanak, nem tartoznak ide.

### Tétlenség

Az Omarchy felület kezeli a tétlenségi viselkedést, és az időzítések egy legfelső szintű `idle` blokkban vannak a `~/.config/omarchy/shell.json` fájlban:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Mindkét szám másodperc, attól a pillanattól számolva, amikor tétlenné váltál — nem egymástól. Így az alapértelmezésekkel a képernyővédő két és fél perc után jelenik meg, a zárolási képernyő pedig öt percnél veszi át a helyét, függetlenül attól, hogy futott-e a képernyővédő. Mentsd el a fájlt, és a felület azonnal átveszi az új időzítéseket.

Ha a zárolási határidő előtt elveted a képernyővédőt, az tevékenységnek számít, és a függőben lévő zárolás törlődik. Nem záródsz ki azért, mert rápillantottál a gépedre.

A tétlenségi zárolás teljes leállításához a `Super + Ctrl + I` — vagy az `omarchy toggle idle` — bekapcsolja az ébren maradást, és a kávéscsésze jelző megjelenik a sávban. Ezt kell megnyomnod egy hosszú prezentáció vagy egy olyan build előtt, amelyet figyelni szeretnél. Nyomd meg ismét, hogy visszatérj a normál működéshez. Az `omarchy toggle idle status` JSON formában kiírja az aktuális állapotot, ha szkriptből van rá szükséged.

Ez a zárolásról és a képernyővédőről szól, nem az energiagazdálkodásról. A felfüggesztésnek és a hibernálásnak saját beállítása van a [rendszer alvó állapota](36-system-sleep.md) részben.

### A képernyővédő

Az Omarchy képernyővédője ASCII-művészet, amely véletlenszerű szöveghatásokon fut keresztül, monitoronként egy példányban. Bármely billentyű vagy egérmozdulat kilép belőle.

Igény szerint elindíthatod a _Rendszer > Képernyővédő_ menüből (`Super + Esc`), amely akkor is előkényszeríti, ha kikapcsoltad a tétlenségi képernyővédőt. Alapértelmezés szerint nincs hozzá rendelt gyorsbillentyű.

Az `omarchy toggle screensaver` kapcsolja ki a tétlenségit, ha inkább közvetlenül a munkából mennél a zárolt állapotba. Bármely billentyű, kattintás, görgetés vagy egérmozdulat bezárja.

Az általa rajzolt logó a tiéd, megváltoztathatod a _Megjelenés > Arculat > Képernyővédő_ alatt. Tölts fel egy png-t vagy svg-t, és az Omarchy ASCII-vé alakítja. Lásd a [márkajelzést](41-branding.md).

### A zárolási képernyő

A `Super + Ctrl + L` zárolja a gépet. Ez futtatja az Omarchy felület zárolási képernyőjét, elsötétíti a kijelzőt, visszaállítja a billentyűzetkiosztásodat az elsőre, hogy ne rossz ábécével gépeld a jelszavadat, és — ha fut nálad — kilépéskor zárolja az 1Password alkalmazást is.

A zárolási képernyő jelszót fogad, és ujjlenyomatot is elfogad, ha már beállítottál egyet. Ezt és a többi hitelesítési módot a [hardveres hitelesítés](37-hardware-authentication.md) tárgyalja.
