# Kapcsolók, tétlenség és a képernyővédő

Sok minden, amit nap mint nap megváltoztatsz, valójában nem beállítás. Olyan mód, amelyet egy órára bekapcsolsz, majd újra kikapcsolsz: éjszakai fény, miközben későig dolgozol, ne zavarjanak, miközben előadsz, ébren maradás, miközben valamit nézel. Az Omarchy ezeket kapcsolóknak nevezi, és mindegyik ugyanúgy működik — egy gyorsbillentyű, egy menüpont és egy parancs, mind ugyanazt a kapcsolót működteti.

### A kapcsolómenü

A `Super + Ctrl + O` közvetlenül megnyitja a _Trigger > Toggle_ menüt, vagy az Omarchy menüből (`Super + Space`) is eljuthatsz oda. A listában minden olyan kapcsoló, amelyet átbillenthetsz anélkül, hogy azon kellene gondolkodnod, hol él az állapota. Az asztal megjelenésére vonatkozó kapcsolók mellette, a _Appearance_ alatt találhatók.

Terminálból ugyanezek a kapcsolók az `omarchy toggle <thing>` formában érhetők el. Futtasd önmagában az `omarchy toggle` parancsot az egész csoport megtekintéséhez.

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

Az érintőpad, az érintőképernyő és a hibrid GPU kapcsolói a _Trigger > Hardware_ (`Super + Ctrl + H`) alatt találhatók a Toggle helyett, mivel csak akkor jelennek meg, ha ténylegesen rendelkezel ilyen hardverrel. Az érintőpad és az érintőképernyő kapcsolói túlélnek egy Hyprland újratöltést — a letiltott eszköz neve egy kis állapotfájlba kerül, amelyet a Hyprland induláskor beolvas, hogy ismét letiltsa azt.

A _Appearance_ tartalmazza a menüsávot és az animációkat, valamint néhány olyan dolgot, amely nem `omarchy toggle` parancs, de ugyanúgy viselkedik: az akkumulátor százalékos töltöttségét a sávban, az alapértelmezett munkaterület-elrendezést, a _Windows_ alatt pedig az ablakok közötti térközt (`Super + Shift + Backspace`) és az egyablakos négyzetes képarányt (`Super + Ctrl + Backspace`).

Ezek többsége csupán egy jelzőfájl a `~/.local/state/omarchy/toggles/` alatt. Ha egy szkriptben szeretnél elágazni valamelyik alapján, az `omarchy-toggle-enabled` kilépési kódot ad, ahelyett hogy neked kellene keresgélned:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

A jelzők a kikapcsolt állapotról kapták a nevüket — `screensaver-off`, `suspend-off`, `bar-off` —, így a jelenlétük azt jelenti, hogy a funkció le van tiltva.

### Jelzők a sávban

Amikor egy mód be van kapcsolva, egy kis jel jelenik meg a felső sáv közepén az óra mellett. Ez az indicators widget, és a diktálást, a képernyőfelvételt, a függőben lévő emlékeztetőket, az éjszakai fényt, a ne zavarjanak módot és az ébren maradást hordozza.

Az inaktív jelzők rejtve vannak. Vigyd az egeret bárhová a sáv fölé, és halványan megjelennek, így rákattinthatsz egyre a bekapcsolásához anélkül, hogy tudnád a gyorsbillentyűjét. Egy aktívra kattintva újra kikapcsolhatod. Ha inkább mindig mindegyiket látni szeretnéd, állítsd az `alwaysShow` értékét `true`-ra az `omarchy.indicators` bejegyzésnél a `~/.config/omarchy/shell.json` fájlban — lásd [a felső sávot](05-the-top-bar.md) arról, hogyan konfigurálhatók a sáv widgetjei.

### Éjszakai fény

Az éjszakai fény 4000K-re melegíti a képernyőt, és újbóli átkapcsolása visszaállítja 6500K-re. Billentsd át a kapcsolómenüből (`Super + Ctrl + O`) vagy az `omarchy toggle nightlight` paranccsal. A hyprsunset hajtja, amelyet a kapcsoló elindít helyetted, ha még nem fut.

Alapértelmezés szerint a hyprsunset egyáltalán nem nyúl a képernyődhöz. A `~/.config/hypr/hyprsunset.conf` identitásprofillal érkezik, pontosan azért, hogy a kijelző érintetlen maradjon mindaddig, amíg melegséget nem kérsz. Ha inkább azt szeretnéd, hogy az óra szerint váltson, cseréld le azt egy időprofilra:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ezután indítsd el a hyprsunsetet bejelentkezéskor azáltal, hogy hozzáadod az `o.launch_on_start("hyprsunset")` sort a `~/.config/hypr/autostart.lua` fájlhoz. A kapcsoló által használt 4000K/6500K pár rögzített, így a konfigurációs fájlhoz kell fordulnod, ha más hőmérsékletet szeretnél.

### Ne zavarjanak

A `Super + Ctrl + Alt + ,` elnémítja az értesítéseket. Amíg be van kapcsolva, nem ugranak fel értesítési buborékok, és az áthúzott harang jelző ott ül a sávban, hogy emlékeztessen, miért lett csendes az asztal.

Semmi sem vész el azonban. Az elnémított értesítések visszatartásra kerülnek: a legutóbbi néhányat a `Super + Shift + Alt + ,` kombinációval teheted vissza a képernyőre. A többit lásd az [értesítések](10-notices.md) oldalon.

Kétféle üzenet továbbra is átjut: az Omarchy saját megerősítő buborékai valamiről, amit az imént tettél („Theme changed”, „Screenshot saved”), és a parancssorból küldött kritikus riasztások. Azok a csevegőalkalmazások, amelyek mindent kritikusnak jelölnek, hogy erővel eléd tolakodjanak, nem tartoznak ide.

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

Mindkét szám másodperc, attól a pillanattól számolva, amikor tétlenné váltál — nem egymástól. Így az alapértelmezésekkel a képernyővédő két és fél perc után jelenik meg, a zárolási képernyő pedig öt percnél veszi át a helyét, függetlenül attól, hogy a képernyővédő futott-e. Mentsd el a fájlt, és a shell azonnal átveszi az új időzítéseket.

Ha a zárolási határidő előtt elveted a képernyővédőt, az tevékenységnek számít, és a függőben lévő zárolás törlődik. Nem záródsz ki azért, mert ránéztél a gépedre.

Ha teljesen meg akarod szüntetni a tétlenség miatti zárolást, a `Super + Ctrl + I` — vagy az `omarchy toggle idle` — bekapcsolja az ébren maradást, és a kávéscsésze jelző megjelenik a sávban. Ezt érdemes megnyomni egy hosszú prezentáció vagy egy olyan build előtt, amelyet figyelni szeretnél. Nyomd meg újra a normál működéshez való visszatéréshez. Az `omarchy toggle idle status` JSON-ként írja ki az aktuális állapotot, ha szkriptből van rá szükséged.

Ez a zárolásról és a képernyővédőről szól, nem az energiagazdálkodásról. A felfüggesztésnek és a hibernálásnak saját beállítása van a [rendszeralvás](36-system-sleep.md) oldalon.

### A képernyővédő

Az Omarchy képernyővédője véletlenszerű szövegeffektusokon átfutó ASCII művészet, monitoronként egy példányban. Bármely billentyű vagy egérmozdulat kilép belőle.

Igény szerint elindíthatod a _System > Screensaver_ (`Super + Esc`) menüből, amely akkor is erővel előhozza, ha kikapcsoltad a tétlenségi képernyővédőt. Alapértelmezés szerint nincs hozzá gyorsbillentyű kötve.

Az `omarchy toggle screensaver` kapcsolja ki a tétlenségit, ha inkább egyenesen a munkából a zárolt állapotba szeretnél jutni. Olyan terminálra van szüksége, amelyet tud konfigurálni — Alacritty, Foot, Ghostty vagy Kitty —, és szólni fog, ha az alapértelmezett terminálod valami más.

Az általa rajzolt logó a tied, megváltoztathatod az _Appearance > Branding > Screensaver_ alatt. Tölts fel egy png vagy svg fájlt, és az Omarchy ASCII-vé alakítja. Lásd az [arculatot](41-branding.md).

### A zárolási képernyő

A `Super + Ctrl + L` zárolja a gépet. Ez futtatja az Omarchy shell zárolási képernyőjét, elsötétíti a kijelzőt, visszaállítja a billentyűzetkiosztást az elsőre, hogy ne rossz ábécében gépeld a jelszavadat, és — ha futtatod — kilépéskor zárolja a 1Password alkalmazást.

A zárolási képernyő jelszót fogad el, és ujjlenyomatot is elfogad, amint beállítottál egyet. Ez, és a hitelesítés egyéb módjai a [hardveres hitelesítés](37-hardware-authentication.md) oldalon szerepelnek.
