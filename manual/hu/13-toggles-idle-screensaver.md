# Kapcsolók, üresjárat és a képernyővédő

Sok dolog, amit nap mint nap módosítasz, nem igazán beállítás. Hanem egy mód, amelyet egy órára bekapcsolsz, majd kikapcsolsz: éjszakai fény, miközben későig dolgozol, ne zavarjanak, miközben prezentálsz, ébren maradás, miközben valamit nézel. Az Omarchy kapcsolóknak hívja őket, és mind ugyanúgy működik — egy billentyűparancs, egy menüpont és egy parancs, mind ugyanarra a kapcsolóra hatva.

### A kapcsolómenü

A `Super + Ctrl + O` közvetlenül a _Trigger > Toggle_ pontot nyitja meg, vagy az Omarchy menüből (`Super + Space`) odasétálhatsz. Ezen a listán minden olyan kapcsoló, amelyet anélkül is átköthetsz, hogy azon gondolkodnál, hol él az állapota. Mellette, a _Trigger > Appearance_ alatt vannak azok a kapcsolók, amelyek az asztal kinézetére vonatkoznak.

Terminálból ugyanazok a kapcsolók az `omarchy toggle <thing>` parancsok. Futtasd önmagában az `omarchy toggle` parancsot, hogy az egész csoportot lásd.

| Kapcsoló | Billentyűparancs | Parancs |
| ------ | ------ | ------- |
| Éjszakai fény | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Értesítések némítása | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Ébren maradás (nincs üresjárati zárolás) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Összeomlás rögzítése | — | `omarchy toggle crash-capture` |
| Képernyővédő | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) témaszinkron | — | `omarchy toggle theme sync` |
| Menüsor | `Super + Shift + Space` | `omarchy toggle bar` |
| Érintőpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Érintőképernyő | — | `omarchy toggle touchscreen` |
| Felfüggesztés | — | `omarchy toggle suspend` |
| Hibrid GPU | — | `omarchy toggle hybrid gpu` |

Az érintőpad, érintőképernyő és hibrid GPU kapcsolói a _Trigger > Hardware_ pont (`Super + Ctrl + H`) alatt élnek, nem a Toggle alatt, mivel csak akkor jelennek meg, ha tényleg van olyan hardvered. Az érintőpad és az érintőképernyő kapcsolói túlélnek egy Hyprland-újratöltést — a letiltott eszköz neve egy kis állapotfájlba kerül, amelyet a Hyprland induláskor elolvas, hogy ismét letiltsa azt.

A _Trigger > Appearance_ tartja a menüsort és az animációkat, plusz néhány dolgot, amelyek nem `omarchy toggle` parancsok, de ugyanúgy viselkednek: akku százaléka a sávon, az alapértelmezett munkaterület-kiosztás, ablakközök (`Super + Shift + Backspace`) és az egyetlen ablak négyszögletű képaránya (`Super + Ctrl + Backspace`).

Ezek többsége egyszerűen egy jelzőfájl a `~/.local/state/omarchy/toggles/` helyen. Ha szkriptben szeretnél elágazni egyet illetően, az `omarchy-toggle-enabled` kilépési kódot ad a keresés kényszere helyett:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

A jelzők a kikapcsolt államról vannak elnevezve — `screensaver-off`, `suspend-off`, `bar-off` —, így a jelenlétük azt jelenti, hogy a funkció le van tiltva.

### Jelzők a sávon

Ha egy mód aktív, kis jelet kapsz a felső sáv közepén, az óra mellett. Ez az indicators widget, és hordozza a diktálást, a képernyőfelvételt, a függőben lévő emlékeztetőket, az éjszakai fényt, a ne zavarjanak módot és az ébren maradást.

Az inaktív jelzők rejtve vannak. Vidd az egeret a körülöttük lévő területre, és elhalványodva előjönnek, így rákattinthatsz egyre, hogy bekapcsold anélkül, hogy tudnád a billentyűparancsát. Aktív jelzőre kattintva kikapcsolod azt. Ha inkább mindet mindig látni szeretnéd, állítsd az `alwaysShow` értékét `true`-ra a `~/.config/omarchy/shell.json` fájlban lévő `omarchy.indicators` bejegyzésen — hogy hogyan konfigurálódnak a sávwidgetek, abban [a felső sáv](05-the-top-bar.md) fejezet segít.

### Éjszakai fény

A `Super + Ctrl + N` 4000K-re melegíti a képernyőt, és ismételt megnyomása visszaállítja 6500K-re. A hyprsunset hajtja, amelyet a kapcsoló elindít neked, ha még nem fut.

Alapértelmezetten a hyprsunset egyáltalán nem csinál semmit a képernyőddel. A `~/.config/hypr/hyprsunset.conf` identitásprofillal érkezik, pontosan azért, hogy a kijelző érintetlen maradjon, amíg melegséget nem kérsz. Ha inkább azt szeretnéd, hogy az óra szerint váltson, cseréld le egy időprofilra:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ezután indítsd el a hyprsunsetet bejelentkezéskor az `o.launch_on_start("hyprsunset")` sor `~/.config/hypr/autostart.lua` fájlhoz való hozzáadásával. A kapcsoló által használt 4000K/6500K páros rögzített, így a konfigurációs fájl az, ahova más hőmérsékletekért mész.

### Ne zavarjanak

A `Super + Ctrl + ,` némítja az értesítéseket. Amíg be van kapcsolva, nem ugranak fel pirítósszerű értesítések, és az áthúzott csengőjel a sávon emlékeztet arra, miért lett csendes az asztal.

Semmi sem vész el azonban. Egy némított értesítés egyenesen bekerül az értesítési előzményeidbe, amely pontosan az a nyilvántartás, amelyet érdemes megnézni, amikor visszatérsz, és kíváncsi vagy, miről maradtál le. Nyisd meg a `Super + Shift + Alt + ,` kombinációval. Az értesítési történet többi részéért lásd a [értesítéseket](10-notices.md).

Kétféle üzenet még mindig át jut: az Omarchy saját megerősítő értesítései olyasvalamiről, amit épp megtettél („Theme changed”, „Screenshot saved”), és a parancssorból küldött kritikus riasztások. Azok a csevegőappok, amelyek mindent kritikusnak jelölnek, hogy erőszakosan az orrod elé kerüljenek, nem jogosultak erre.

### Üresjárat

Az üresjárati viselkedést az Omarchy shell birtokolja, és az időzítések legfelső szintű `idle` blokkban vannak a `~/.config/omarchy/shell.json` fájlban:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Mindkét szám másodpercekben mérendő attól a pillanattól, amikor üresjáratba mentél — nem egymástól. Így az alapértelmezésekkel a képernyővédő két és fél perc után jelenik meg, és a zárolási képernyő átveszi az irányítást öt percnél, függetlenül attól, hogy a képernyővédő futott-e. Mentsd el a fájlt, és a shell azonnal átveszi az új időzítéseket.

Ha a zárolási határidő előtt elveted a képernyővédőt, az tevékenységnek számít, és a függőben lévő zárolás megszűnik. Nem zárnak ki azért, mert egy pillantást vetettél a gépedre.

Az üresjárati zárolás teljes megszüntetéséhez a `Super + Ctrl + I` — vagy az `omarchy toggle idle` — bekapcsolja az ébren maradást, és a kávéscsésze-jelző megjelenik a sávon. Ezt kell megnyomnod egy hosszú prezentáció vagy egy figyelni kívánt build előtt. Nyomd meg ismét a normálishoz való visszatéréshez. Az `omarchy toggle idle status` kiírja az aktuális állapotot JSON formában, ha szkriptből kell neked.

Ez a zárolásról és a képernyővédőről szól, nem az energiáról. A felfüggesztésnek és a hibernálásnak saját beállítása van a [rendszeralvásban](36-system-sleep.md).

### A képernyővédő

Az Omarchy képernyővédője véletlen szöveghatásokon keresztül futó ASCII-rajz, monitoronként egy példány. Bármely billentyű vagy egérmozgás kilép belőle.

Igény szerint elindíthatod a _System > Screensaver_ pontból (`Super + Esc`), amely felkényszeríti még akkor is, ha az üresjárati képernyővédőt kikapcsoltad. Alapértelmezetten nincs hozzá rendelt billentyűparancs.

Az `omarchy toggle screensaver` kapcsolja ki az üresjáratit, ha inkább egyenesen a munkától a zároláshoz mennél. Szüksége van olyan terminálra, amelyet be tud állítani — Alacritty, Foot, Ghostty vagy Kitty — és meg is fogja mondani neked, ha az alapértelmezett terminálod valami más.

Az általa rajzolt logót megváltoztathatod a _Style > Screensaver_ alatt. Tölts fel egy png-t vagy svg-t, és az Omarchy ASCII-vá alakítja azt. Lásd a [brandinget](41-branding.md).

### A zárolási képernyő

A `Super + Ctrl + L` zárolja a gépet. Ez futtatja a zárolási képernyőt az Omarchy shellből, üresíti a kijelzőt, visszaállítja a billentyűzetkiosztásodat az elsőre, hogy ne rossz ábécével írd be a jelszavadat, és — ha futtatod — kilépéskor zárolja az 1Passwordot is.

A zárolási képernyő jelszót fogad, és ujjlenyomatot is fogad, miután beállítottál egyet. Ezt, és a hitelesítés többi módját a [hardveres hitelesítés](37-hardware-authentication.md) tárgyalja.
