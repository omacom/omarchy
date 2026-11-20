# Kapcsolók, tétlenség és a képernyővédő

Sok minden, amit nap mint nap átállítasz, valójában nem is beállítás. Egy olyan mód, amit egy órára bekapcsolsz, aztán megint ki: éjszakai fény, amikor késő estig dolgozol, ne zavarjanak, amikor prezentálsz, ébren maradás, amikor épp nézel valamit. Az Omarchy ezeket kapcsolóknak hívja, és mindegyik ugyanúgy működik — egy gyorsbillentyű, egy menüpont és egy parancs, mind ugyanazt a kapcsolót billenti.

### A kapcsolómenü

A `Super + Ctrl + O` közvetlenül megnyitja a _Trigger > Toggle_ menüt, vagy az Omarchy menüből (`Super + Space`) is odajuthatsz. A listában minden olyan kapcsoló szerepel, amit átbillenthetsz anélkül, hogy azon kellene gondolkodnod, hol él az állapota. Mellette, az _Appearance_ alatt ülnek az asztal kinézetére vonatkozó kapcsolók.

Terminálból ugyanezek a kapcsolók az `omarchy toggle <thing>` formában érhetők el. Futtasd önmagában az `omarchy toggle` parancsot, hogy lásd az egész csoportot.

| Kapcsoló | Gyorsbillentyű | Parancs |
| ------ | ------ | ------- |
| Éjszakai fény | — | `omarchy toggle nightlight` |
| Értesítések némítása | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Ébren maradás (nincs tétlenségi zárolás) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Összeomlásrögzítés | — | `omarchy toggle crash-capture` |
| Képernyővédő | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) témaszinkron | — | `omarchy toggle theme sync` |
| Menüsáv | `Super + Shift + Space` | `omarchy toggle bar` |
| Teljes képernyős asztal (nincs sáv, nincs hézag) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animációk, elmosás és árnyékok | — | `omarchy toggle animations` |
| Érintőpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Érintőképernyő | — | `omarchy device touchscreen` |
| Felfüggesztés | — | `omarchy toggle suspend` |
| Hibrid GPU | — | `omarchy device gpu hybrid` |

Az érintőpad, az érintőképernyő és a hibrid GPU kapcsolói a _Trigger > Hardware_ (`Super + Ctrl + H`) alatt élnek, nem a Toggle alatt, mivel csak akkor jelennek meg, ha ténylegesen van ilyen hardvered. Az érintőpad és az érintőképernyő kapcsolói túlélnek egy Hyprland-újratöltést — a letiltott eszköz neve egy kis állapotfájlba mentődik, amelyet a Hyprland induláskor beolvas, hogy újra letiltsa.

Az _Appearance_ tartalmazza a menüsávot és az animációkat, plusz néhány olyan dolgot, amelyek nem `omarchy toggle` parancsok, de ugyanúgy viselkednek: az akkumulátor százalékos kijelzését a sávban, az alapértelmezett munkaterület-elrendezést, és a _Windows_ alatt az ablakok közötti hézagokat (`Super + Shift + Backspace`) és az 1 ablakos négyzetes képarányt (`Super + Ctrl + Backspace`).

Amikor a Hyprlandnak nincs GPU-ja, amellyel rajzolhatna, és helyette a CPU-n renderel (llvmpipe), ahogyan az olyan Maceken történik, amelyek GPU-ja még nem támogatott, a legtöbb virtuális gépben, vagy amikor egy grafikus illesztőprogram nem töltődik be, az Omarchy kikapcsolja az animációkat, az elmosást és az árnyékokat arra a munkamenetre, és erről egyszer értesítéssel szól neked. Az _Appearance > Animations On_ visszahozza őket, és az Omarchy ezt a későbbi munkamenetekre is megjegyzi.

Ezek többsége mindössze egy jelzőfájl a `~/.local/state/omarchy/toggles/` alatt. Ha egy szkriptben le akarsz ágazni valamelyik alapján, az `omarchy-toggle-enabled` kilépési kódot ad, ahelyett, hogy neked kellene keresgélned:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

A jelzők a kikapcsolt állapotról kapják a nevüket — `screensaver-off`, `suspend-off`, `bar-off` —, így a jelenlétük azt jelenti, hogy a funkció le van tiltva.

### Jelzők a sávban

Amikor egy mód be van kapcsolva, egy kis glifa jelenik meg a felső sáv közepén, az óra mellett. Ez a jelzők widget, és tartalmazza a képernyőfelvételt, a függőben lévő emlékeztetőket, az éjszakai fényt, a ne zavarjanak módot és az ébren maradást, plusz figyelmeztetéseket, amíg a jelszó nélküli sudo be van kapcsolva, vagy valaki csatlakozik egy távoli munkamenethez.

Az inaktív jelzők rejtve vannak. Vidd az egeret bárhová a sáv fölé, és halványan megjelennek, így rákattinthatsz egyre a bekapcsolásához anélkül, hogy ismernéd a gyorsbillentyűjét. Egy aktívra kattintva az kikapcsol. Ha inkább mindig látnád mindet, állítsd az `alwaysShow` értékét `true`-ra az `omarchy.indicators` bejegyzésben a `~/.config/omarchy/shell.json` fájlban — a sáv widgetjeinek konfigurálásáról lásd [a felső sávot](05-the-top-bar.md).

### Éjszakai fény

Az éjszakai fény 4000K-re melegíti a képernyőt, és az újbóli átbillentés visszaállítja 6500K-re. Billentsd át a kapcsolómenüből (`Super + Ctrl + O`) vagy az `omarchy toggle nightlight` paranccsal. A hyprsunset hajtja, amelyet a kapcsoló elindít helyetted, ha még nem fut.

Alapértelmezés szerint a hyprsunset egyáltalán nem nyúl a képernyődhöz. A `~/.config/hypr/hyprsunset.conf` identitásprofillal érkezik, pontosan azért, hogy a kijelző érintetlen maradjon, amíg melegséget nem kérsz. Ha inkább azt szeretnéd, hogy az óra szerint váltson, cseréld le ezt egy időprofilra:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ezután indítsd el a hyprsunsetet bejelentkezéskor azzal, hogy hozzáadod az `o.launch_on_start("hyprsunset")` sort a `~/.config/hypr/autostart.lua` fájlhoz. A kapcsoló által használt 4000K/6500K páros rögzített, így a konfigurációs fájl az a hely, ahová akkor mész, ha más hőmérsékletet szeretnél.

### Ne zavarjanak

A `Super + Ctrl + Alt + ,` elnémítja az értesítéseket. Amíg be van kapcsolva, nem ugranak fel pirítósértesítések, és az áthúzott csengő jelző a sávban ül, hogy emlékeztessen, miért lett csendes az asztal.

Semmi sem veszik el azonban. A némított értesítések visszatartódnak: tedd vissza az utolsó néhányat a képernyőre a `Super + Shift + Alt + ,` kombinációval. A többit lásd az [értesítések](10-notices.md) című fejezetben.

Háromféle üzenet továbbra is átjut: az Omarchy saját visszaigazoló pirítósértesítései valami olyasmiről, amit épp megtettél ("Theme changed", "Screenshot saved"), a parancssorból küldött kritikus riasztások és az ellenőrző kódok. Azok a csevegőalkalmazások, amelyek mindent kritikusnak jelölnek, hogy erőszakkal eléd tolakodjanak, nem felelnek meg a feltételeknek.

### Tétlenség

Az Omarchy shell birtokolja a tétlenségi viselkedést, és az időzítések egy legfelső szintű `idle` blokkban vannak a `~/.config/omarchy/shell.json` fájlban:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Mindkét szám másodperc, attól a pillanattól számolva, amikor tétlenné váltál — nem egymástól. Tehát az alapértelmezésekkel a képernyővédő két és fél perc után jelenik meg, a zárolási képernyő pedig öt percnél veszi át a helyét, függetlenül attól, hogy a képernyővédő futott-e. Mentsd el a fájlt, és a shell azonnal átveszi az új időzítéseket.

Ha a zárolási határidő előtt elveted a képernyővédőt, az tevékenységnek számít, és a függőben lévő zárolás törlődik. Nem záródsz ki azért, mert rápillantottál a gépedre.

Ha teljesen le akarod állítani a tétlenségi zárolást, a `Super + Ctrl + I` — vagy az `omarchy toggle idle` — bekapcsolja az ébren maradást, és a kávéscsésze jelző megjelenik a sávban. Ezt érdemes megnyomni egy hosszú prezentáció vagy egy build előtt, amelyet végig akarsz nézni. Nyomd meg újra, hogy visszatérj a normál működéshez. Az `omarchy toggle idle status` JSON-ként kiírja az aktuális állapotot, ha szkriptből van rá szükséged.

Ez a zárolásról és a képernyővédőről szól, nem az energiáról. A felfüggesztésnek és a hibernálásnak saját beállítása van a [rendszeralvás](36-system-sleep.md) című fejezetben.

### A képernyővédő

Az Omarchy képernyővédője véletlenszerű szövegeffekteken átfutó ASCII művészet, monitoronként egy példányban. Bármely billentyű vagy egérmozdulat kilép belőle.

Igény szerint elindíthatod a _System > Screensaver_ (`Super + Esc`) helyről, amely akkor is felkényszeríti, ha kikapcsoltad a tétlenségi képernyővédőt. Alapértelmezés szerint nincs hozzá rendelt gyorsbillentyű.

Az `omarchy toggle screensaver` az, ami kikapcsolja a tétlenségit, ha inkább egyenesen a munkából mennél a zárolt állapotba. Bármely billentyű, kattintás, görgetés vagy egérmozdulat bezárja.

Az általa rajzolt logó a tied, megváltoztathatod az _Appearance > Branding > Screensaver_ alatt. Tölts fel egy png vagy svg fájlt, és az Omarchy ASCII-vé alakítja. Lásd az [arculatot](41-branding.md).

### A zárolási képernyő

A `Super + Ctrl + L` zárolja a gépet. Ez futtatja a zárolási képernyőt az Omarchy shellből, elsötétíti a kijelzőt, visszaállítja a billentyűzetkiosztásodat az elsőre, hogy ne a rossz ábécében gépeld a jelszavadat, és — ha fut nálad — útközben zárolja a 1Passwordot.

A zárolási képernyő jelszót fogad, és ujjlenyomatot is elfogad, amint beállítottál egyet. Ezt és a hitelesítés többi módját a [hardveres hitelesítés](37-hardware-authentication.md) tárgyalja.
