# Kapcsolók, tétlenség és a képernyővédő

Sok minden, amit nap mint nap megváltoztatsz, valójában nem is beállítás. Ez egy mód, amelyet bekapcsolsz egy órára, majd újra kikapcsolsz: éjszakai fény, miközben későig dolgozol, ne zavarjanak, miközben prezentálsz, ébren maradás, miközben nézel valamit. Az Omarchy ezeket kapcsolóknak hívja, és mindegyik ugyanúgy működik — egy gyorsbillentyű, egy menübejegyzés és egy parancs, mind ugyanazt a kapcsolót működteti.

### A kapcsolómenü

A `Super + Ctrl + O` közvetlenül megnyitja a _Trigger > Toggle_ menüt, vagy az Omarchy menüből (`Super + Space`) is eljuthatsz oda. Minden, ami azon a listán szerepel, egy kapcsoló, amelyet átállíthatsz anélkül, hogy azon gondolkodnál, hol él az állapota. Az asztal megjelenését szabályozó kapcsolók mellette találhatók, az _Appearance_ alatt.

A terminálból ugyanazok a kapcsolók az `omarchy toggle <thing>` paranccsal érhetők el. Futtasd önmagában az `omarchy toggle` parancsot, hogy lásd az egész csoportot.

| Kapcsoló | Gyorsbillentyű | Parancs |
| ------ | ------ | ------- |
| Éjszakai fény | — | `omarchy toggle nightlight` |
| Értesítések némítása | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Ébren maradás (nincs tétlenségi zárolás) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Összeomlás rögzítése | — | `omarchy toggle crash-capture` |
| Képernyővédő | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) téma szinkronizálása | — | `omarchy toggle theme sync` |
| Menüsáv | `Super + Shift + Space` | `omarchy toggle bar` |
| Érintőpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Érintőképernyő | — | `omarchy device touchscreen` |
| Felfüggesztés | — | `omarchy toggle suspend` |
| Hibrid GPU | — | `omarchy toggle hybrid gpu` |

Az érintőpad, az érintőképernyő és a hibrid GPU kapcsolói a _Trigger > Hardware_ alatt találhatók (`Super + Ctrl + H`), nem a Toggle alatt, mivel csak akkor jelennek meg, ha ténylegesen rendelkezel ilyen hardverrel. Az érintőpad és az érintőképernyő kapcsolói túlélik a Hyprland újratöltését — a letiltott eszköz neve egy kis állapotfájlba kerül, amelyet a Hyprland indításkor beolvas, hogy újra letiltsa azt.

Az _Appearance_ tartalmazza a menüsávot és az animációkat, valamint néhány olyan dolgot is, amelyek nem `omarchy toggle` parancsok, de ugyanúgy viselkednek: az akkumulátor százalékos kijelzését a sávban, az alapértelmezett munkaterület-elrendezést, és a _Windows_ alatt az ablakok közötti réseket (`Super + Shift + Backspace`) és az 1 ablakos négyzetes képarányt (`Super + Ctrl + Backspace`).

Amikor a Hyprlandnak nincs GPU-ja, amellyel rajzolhatna, és helyette a CPU-n renderel (llvmpipe), mint azokon a Maceken, amelyek GPU-ja még nem támogatott, a legtöbb virtuális gépben, vagy amikor egy grafikus illesztőprogram nem töltődik be, az Omarchy kikapcsolja az animációkat, az elmosást és az árnyékokat arra a munkamenetre, és erről egyszer értesítéssel tájékoztat. Az _Appearance > Animations On_ visszahozza őket, és az Omarchy ezt a későbbi munkamenetekre is megjegyzi.

Ezek többsége mindössze egy jelzőfájl a `~/.local/state/omarchy/toggles/` alatt. Ha egy szkriptben szeretnél elágazni valamelyiken, az `omarchy-toggle-enabled` kilépési kódot ad, ahelyett hogy neked kellene keresgélned:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

A jelzők a kikapcsolt állapotról vannak elnevezve — `screensaver-off`, `suspend-off`, `bar-off` — tehát a jelenlétük azt jelenti, hogy a funkció le van tiltva.

### Jelzők a sávban

Amikor egy mód be van kapcsolva, egy kis jelképet kapsz a felső sáv közepén, az óra mellett. Ez a jelzők widget, és a diktálást, a képernyőfelvételt, a függőben lévő emlékeztetőket, az éjszakai fényt, a ne zavarjanak módot és az ébren maradást hordozza.

Az inaktív jelzők rejtve vannak. Vidd az egeret bárhová a sáv fölé, és halványan megjelennek, így rákattinthatsz egyre a bekapcsolásához anélkül, hogy ismernéd a gyorsbillentyűjét. Egy aktívra kattintva újra kikapcsolod azt. Ha inkább mindig látnád mindet, állítsd az `alwaysShow` értéket `true`-ra az `omarchy.indicators` bejegyzésen a `~/.config/omarchy/shell.json` fájlban — lásd [a felső sávot](05-the-top-bar.md) arról, hogyan konfigurálhatók a sáv widgetjei.

### Éjszakai fény

Az éjszakai fény 4000K-re melegíti a képernyőt, és újbóli átkapcsolása visszaállítja 6500K-re. Kapcsold át a kapcsolómenüből (`Super + Ctrl + O`) vagy az `omarchy toggle nightlight` paranccsal. A hyprsunset hajtja, amelyet a kapcsoló elindít neked, ha még nem fut.

Alapértelmezés szerint a hyprsunset egyáltalán nem nyúl a képernyődhöz. A `~/.config/hypr/hyprsunset.conf` identitásprofillal érkezik, pontosan azért, hogy a kijelző érintetlen maradjon, amíg meleget nem kérsz. Ha inkább azt szeretnéd, hogy az óra alapján kapcsoljon, cseréld le azt egy időprofilra:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ezután indítsd el a hyprsunsetet bejelentkezéskor azzal, hogy hozzáadod az `o.launch_on_start("hyprsunset")` sort a `~/.config/hypr/autostart.lua` fájlhoz. A kapcsoló által használt 4000K/6500K pár rögzített, tehát a konfigurációs fájl az a hely, ahová akkor mész, ha más hőmérsékletet szeretnél.

### Ne zavarjanak

A `Super + Ctrl + Alt + ,` elnémítja az értesítéseket. Amíg be van kapcsolva, nem ugranak fel pirítósértesítések, és az áthúzott harang jelző ott ül a sávban, hogy emlékeztessen, miért lett csendes az asztal.

Semmi sem vész el azonban. Az elnémított értesítések vissza vannak tartva: tedd vissza az utolsó néhányat a képernyőre a `Super + Shift + Alt + ,` kombinációval. A többit lásd az [értesítések](10-notices.md) oldalon.

Kétféle üzenet továbbra is átjut: az Omarchy saját megerősítő pirítósértesítései olyasmiről, amit éppen tettél ("Theme changed", "Screenshot saved"), és a parancssorból küldött kritikus riasztások. Azok a csevegőalkalmazások, amelyek mindent kritikusnak jelölnek, hogy erőszakkal eléd tolhassák magukat, nem számítanak ide.

### Tétlenség

A tétlenségi viselkedést az Omarchy shell birtokolja, és az időzítések egy legfelső szintű `idle` blokkban vannak a `~/.config/omarchy/shell.json` fájlban:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Mindkét szám másodperc, attól a pillanattól számolva, amikor tétlenné váltál — nem egymástól. Tehát az alapértelmezésekkel a képernyővédő két és fél perc után jelenik meg, és a zárolási képernyő öt percnél veszi át a helyét, függetlenül attól, hogy a képernyővédő futott-e. Mentsd el a fájlt, és a shell azonnal átveszi az új időzítéseket.

Ha a zárolási határidő előtt elveted a képernyővédőt, az aktivitásnak számít, és a függőben lévő zárolás törlődik. Nem záródsz ki azért, mert rápillantottál a gépedre.

A tétlenségre történő zárolás teljes leállításához a `Super + Ctrl + I` — vagy az `omarchy toggle idle` — bekapcsolja az ébren maradást, és a kávéscsésze jelző megjelenik a sávban. Ezt kell megnyomni egy hosszú prezentáció vagy egy olyan build előtt, amelyet figyelni szeretnél. Nyomd meg újra, hogy visszatérj a normál működéshez. Az `omarchy toggle idle status` JSON-ként kiírja az aktuális állapotot, ha szkriptből van rá szükséged.

Ez a zárolásról és a képernyővédőről szól, nem az energiáról. A felfüggesztésnek és a hibernálásnak saját beállítása van a [rendszeralvás](36-system-sleep.md) oldalon.

### A képernyővédő

Az Omarchy képernyővédője ASCII-művészet, amely véletlenszerű szövegeffektusokon fut keresztül, monitoronként egy példányban. Bármely billentyű vagy egérmozdulat kilép belőle.

Igény szerint elindíthatod a _System > Screensaver_ menüből (`Super + Esc`), amely akkor is erőszakkal felhozza, ha kikapcsoltad a tétlenségi képernyővédőt. Alapértelmezés szerint nincs hozzá gyorsbillentyű rendelve.

Az `omarchy toggle screensaver` kapcsolja ki a tétlenségit, ha inkább egyenesen a munkából mennél a zárolt állapotba. Bármely billentyű, kattintás, görgetés vagy egérmozdulat bezárja azt.

Az általa rajzolt logó a tiéd, megváltoztathatod az _Appearance > Branding > Screensaver_ alatt. Tölts fel egy png-t vagy svg-t, és az Omarchy ASCII-vé alakítja azt. Lásd az [arculat](41-branding.md) oldalt.

### A zárolási képernyő

A `Super + Ctrl + L` zárolja a gépet. Ez futtatja a zárolási képernyőt az Omarchy shellből, elsötétíti a kijelzőt, visszaállítja a billentyűzetkiosztást az elsőre, hogy ne a rossz ábécében gépeld a jelszavadat, és — ha fut nálad — útközben zárolja a 1Passwordot.

A zárolási képernyő jelszót fogad, és ujjlenyomatot is elfogad, amint beállítottál egyet. Ez, és a hitelesítés egyéb módjai, a [hardveres hitelesítés](37-hardware-authentication.md) oldalon vannak tárgyalva.
