# Kapcsolók, tétlenség és a képernyővédő

Sok minden, amit nap mint nap átállítasz, valójában nem beállítás. Egy mód, amit egy órára bekapcsolsz, aztán ki: éjszakai fény, amikor későig dolgozol, ne zavarjanak, amikor prezentálsz, ébren maradás, amikor nézel valamit. Az Omarchy ezeket kapcsolóknak hívja, és mindegyik ugyanúgy működik — egy gyorsbillentyű, egy menübejegyzés és egy parancs, mind ugyanazt a kapcsolót nyomja meg.

### A kapcsolómenü

A `Super + Ctrl + O` közvetlenül megnyitja a _Trigger > Toggle_ menüt, vagy eljuthatsz oda az Omarchy menüből (`Super + Space`) is. Abban a listában minden egy kapcsoló, amit átkattinthatsz anélkül, hogy azon gondolkodnál, hol lakik az állapota. Az asztal megjelenését szabályozó kapcsolók mellette ülnek, a _Appearance_ alatt.

Terminálból ugyanezek a kapcsolók az `omarchy toggle <thing>` formában érhetők el. Futtasd az `omarchy toggle` parancsot önmagában az egész csoport megtekintéséhez.

| Kapcsoló | Gyorsbillentyű | Parancs |
| ------ | ------ | ------- |
| Éjszakai fény | — | `omarchy toggle nightlight` |
| Értesítések némítása | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Ébren maradás (nincs tétlenségi zárolás) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Összeomlás rögzítése | — | `omarchy toggle crash-capture` |
| Képernyővédő | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) témaszinkronizálás | — | `omarchy toggle theme sync` |
| Menüsáv | `Super + Shift + Space` | `omarchy toggle bar` |
| Érintőpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Érintőképernyő | — | `omarchy toggle touchscreen` |
| Felfüggesztés | — | `omarchy toggle suspend` |
| Hibrid GPU | — | `omarchy toggle hybrid gpu` |

Az érintőpad, az érintőképernyő és a hibrid GPU kapcsolói a _Trigger > Hardware_ (`Super + Ctrl + H`) alatt találhatók, nem a Toggle alatt, mivel csak akkor jelennek meg, ha tényleg van ilyen hardvered. Az érintőpad és az érintőképernyő kapcsolója túléli a Hyprland újratöltését — a letiltott eszköz neve egy kis állapotfájlba mentődik, amelyet a Hyprland induláskor beolvas, hogy újra letiltsa.

A _Appearance_ tartalmazza a menüsávot és az animációkat, plusz néhány dolgot, amelyek nem `omarchy toggle` parancsok, de ugyanúgy viselkednek: az akkumulátor százalékos kijelzését a sávban, az alapértelmezett munkaterület-elrendezést, és a _Windows_ alatt az ablakok közötti távolságot (`Super + Shift + Backspace`) és az 1 ablakos négyzetes képarányt (`Super + Ctrl + Backspace`).

Ezek többsége csak egy jelzőfájl a `~/.local/state/omarchy/toggles/` alatt. Ha szkriptben akarsz elágazni valamelyiken, az `omarchy-toggle-enabled` kilépési kódot ad, ahelyett hogy neked kellene keresgélned:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

A jelzők a kikapcsolt állapotról vannak elnevezve — `screensaver-off`, `suspend-off`, `bar-off` — tehát a jelenlétük azt jelenti, hogy a funkció le van tiltva.

### Jelzők a sávban

Amikor egy mód be van kapcsolva, egy kis jel jelenik meg a felső sáv közepén, az óra mellett. Ez a jelzők widget, és tartalmazza a diktálást, a képernyőfelvételt, a függőben lévő emlékeztetőket, az éjszakai fényt, a ne zavarjanak módot és az ébren maradást.

Az inaktív jelzők rejtve vannak. Vidd az egeret bárhová a sáv fölé, és halványan megjelennek, így rákattinthatsz egyre a bekapcsolásához anélkül, hogy tudnád a gyorsbillentyűjét. Egy aktívra kattintva újra kikapcsolhatod. Ha inkább mindig mindegyiket látni akarod, állítsd az `alwaysShow` értékét `true`-ra a `~/.config/omarchy/shell.json` fájl `omarchy.indicators` bejegyzésénél — lásd [a felső sáv](05-the-top-bar.md) leírását a sáv widgetjeinek beállításáról.

### Éjszakai fény

Az éjszakai fény 4000K-re melegíti a képernyőt, újbóli átkapcsolása pedig visszaállítja 6500K-re. Kapcsold át a kapcsolómenüből (`Super + Ctrl + O`) vagy az `omarchy toggle nightlight` paranccsal. A hyprsunset hajtja, amelyet a kapcsoló elindít helyetted, ha még nem fut.

Alapértelmezés szerint a hyprsunset egyáltalán nem nyúl a képernyődhöz. A `~/.config/hypr/hyprsunset.conf` identitásprofillal érkezik, pontosan azért, hogy a kijelző érintetlen maradjon, amíg meleget nem kérsz. Ha inkább az óra alapján akarod kapcsolni, cseréld le egy időprofilra:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ezután indítsd el a hyprsunsetet bejelentkezéskor úgy, hogy hozzáadod az `o.launch_on_start("hyprsunset")` sort a `~/.config/hypr/autostart.lua` fájlhoz. A kapcsoló által használt 4000K/6500K pár rögzített, tehát a konfigurációs fájlhoz kell nyúlnod, ha más hőmérsékletet akarsz.

### Ne zavarjanak

A `Super + Ctrl + Alt + ,` elnémítja az értesítéseket. Amíg be van kapcsolva, nem ugranak fel értesítési buborékok, és az áthúzott harang jelző ott ül a sávban, hogy emlékeztessen, miért lett csendes az asztal.

Semmi sem vész el azonban. Az elnémított értesítések visszatartódnak: tedd vissza az utóbbi néhányat a képernyőre a `Super + Shift + Alt + ,` kombinációval. A többit lásd az [értesítések](10-notices.md) részben.

Kétféle üzenet azért átjut: az Omarchy saját megerősítő buborékjai arról, amit épp csináltál ("Theme changed", "Screenshot saved"), és a parancssorból küldött kritikus riasztások. Azok a csevegőalkalmazások, amelyek mindent kritikusnak jelölnek, hogy eléd tolakodjanak, nem számítanak annak.

### Tétlenség

Az Omarchy shell kezeli a tétlenségi viselkedést, és az időzítések egy legfelső szintű `idle` blokkban vannak a `~/.config/omarchy/shell.json` fájlban:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Mindkét szám másodperc, attól a pillanattól számolva, amikor tétlen lettél — nem egymástól. Tehát az alapértelmezésekkel a képernyővédő két és fél perc után jelenik meg, a zárolási képernyő pedig öt percnél veszi át a helyét, függetlenül attól, hogy a képernyővédő futott-e. Mentsd el a fájlt, és a shell azonnal átveszi az új időzítéseket.

Ha a zárolási határidő előtt kilépsz a képernyővédőből, az aktivitásnak számít, és a függőben lévő zárolás törlődik. Nem záródsz ki azért, mert csak rápillantottál a gépedre.

Ha teljesen le akarod állítani a tétlenségi zárolást, a `Super + Ctrl + I` — vagy az `omarchy toggle idle` — bekapcsolja az ébren maradást, és a kávéscsésze jelző megjelenik a sávban. Ezt kell megnyomnod egy hosszú prezentáció vagy egy build előtt, amelyet végig akarsz nézni. Nyomd meg újra a normál működéshez való visszatéréshez. Az `omarchy toggle idle status` JSON formátumban kiírja az aktuális állapotot, ha szkriptből van rá szükséged.

Ez a zárolásról és a képernyővédőről szól, nem az energiaellátásról. A felfüggesztésnek és a hibernálásnak saját beállítása van a [rendszer alvása](36-system-sleep.md) részben.

### A képernyővédő

Az Omarchy képernyővédője ASCII-művészet véletlenszerű szövegeffekteken keresztül, monitoronként egy példányban. Bármelyik billentyű vagy egérmozdulat kilép belőle.

Igény szerint elindíthatod a _System > Screensaver_ (`Super + Esc`) helyről, amely akkor is előkényszeríti, ha kikapcsoltad a tétlenségi képernyővédőt. Alapértelmezés szerint nincs hozzá gyorsbillentyű rendelve.

Az `omarchy toggle screensaver` kapcsolja ki a tétlenségit, ha inkább közvetlenül a munkából mennél a zárolásba. Bármelyik billentyű, kattintás, görgetés vagy egérmozdulat bezárja.

Az általa rajzolt logót megváltoztathatod a _Appearance > Branding > Screensaver_ alatt. Tölts fel egy png-t vagy svg-t, és az Omarchy ASCII-vé alakítja. Lásd a [márkajelzés](41-branding.md) részt.

### A zárolási képernyő

A `Super + Ctrl + L` zárolja a gépet. Ez elindítja az Omarchy shell zárolási képernyőjét, elsötétíti a kijelzőt, visszaállítja a billentyűzetkiosztást az elsőre, hogy ne rossz ábécével gépeld a jelszavadat, és — ha fut — kilépéskor zárolja az 1Passwordot.

A zárolási képernyő jelszót kér, és ujjlenyomatot is elfogad, ha már beállítottál egyet. Ezt és a többi hitelesítési módot a [hardveres hitelesítés](37-hardware-authentication.md) tárgyalja.
