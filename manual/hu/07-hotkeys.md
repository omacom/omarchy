# Gyorsbillentyűk

Az összes fő billentyűkiosztást a `Super + K` kombinációval nézheted meg (a Tmux-kiosztásokat a `Super + Alt + K`, a Herdr-kiosztásokat pedig a `Super + Ctrl + K` kombinációval).

## Hogyan szerveződnek a gyorsbillentyűk

Minden gyorsbillentyű egy síkon helyezkedik el, amelyet a módosító billentyűi határoznak meg, és minden síknak egy feladata van. Ettől nem mosódnak össze a gyorsbillentyűk, és általában ki is találhatod, hová tartozik valami.

| Sík | Mi tartozik ide | Példák |
| --- | --- | --- |
| `Super + key` | A rendszer: ablakok, munkaterületek, elrendezések és alapmenük | `Super + Space` Omarchy menü, `Super + W` ablak bezárása, `Super + F` teljes képernyő |
| `Super + Shift + key` | Alkalmazások | `Super + Shift + B` böngésző, `Super + Shift + E` e-mail, `Super + Shift + N` szerkesztő |
| `Super + Ctrl + key` | Panelek és rendszermenük | `Super + Ctrl + A` hang, `Super + Ctrl + N` hálózat, `Super + Ctrl + C` rögzítés menü |
| `Super + Ctrl + Alt + key` | Gyorsműveletek és jelzések | `Super + Ctrl + Alt + T` idő megjelenítése, `Super + Ctrl + Alt + B` akkumulátor, `Super + Ctrl + Alt + C` képernyőkép |

Ha egy gyorsbillentyűhöz hozzáadod az `Alt` billentyűt, ugyanannak a dolognak egy változatát kapod, soha nem valami teljesen mást:

- A `Super + Shift + B` megnyitja a böngészőt; a `Super + Shift + Alt + B` privát ablakot nyit
- A `Super + Shift + E` megnyitja az e-mailt; a `Super + Shift + Alt + E` újat kezd
- A `Super + F` teljes képernyőre vált; a `Super + Alt + F` teljes szélességre vált
- A `Super + Ctrl + C` megnyitja a rögzítés menüt; a `Super + Ctrl + Alt + C` kihagyja a menüt, és képernyőképet készít

Gyorsbillentyű hozzáadásakor:

1. Válaszd ki a síkot abból, amit csinál, majd válaszd ki a billentyűt.
2. Ne mozdíts el egy meglévő gyorsbillentyűt, hogy helyet csinálj. Keress egy szabad billentyűt a megfelelő síkon.
3. Az `Alt` billentyűt csak a nélküle működő gyorsbillentyű változatához használd.

Néhány gyorsbillentyű azért szegi meg ezeket a szabályokat, mert úgy kényelmes. A `Shift` egy nyíllal vagy a `Tab` billentyűvel mozgat vagy visszafelé lép ahelyett, hogy alkalmazást nyitna, a `Print`, a médiabillentyűk, az `Alt + Tab` és a `Ctrl + Alt + Del` pedig úgy működnek, ahogy mindenhol máshol. Ezek kivételek, nem másolandó minták.

Ha egy alapértelmezés nem felel meg neked (mondjuk a képernyőképekhez a Windowson megszokott `Super + Shift + S` kombinációt szeretnéd), kösd újra a `~/.config/hypr/bindings.lua` fájlban.

## Navigálás

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy menü (alkalmazások és minden más) |
| `Super + Alt + Space` | Alkalmazásrács |
| `Super + Escape` | Rendszermenü (felfüggesztés, újraindítás stb.) |
| `Super + Ctrl + L` | Számítógép zárolása |
| `Super + W` or `Super + Q` | Ablak bezárása |
| `Ctrl + Alt + Del` | Az összes ablak bezárása |
| `Super + K` | Az összes gyorsbillentyű megjelenítése |
| `Super + Alt + K` | A tmux-gyorsbillentyűk megjelenítése |
| `Super + Ctrl + K` | A herdr-gyorsbillentyűk megjelenítése |
| `Super + M` | Ablak kicsinyítése a dokkra |
| `Super + T` | Ablak váltása csempézett/lebegő mód között |
| `Super + J` | Ablak helyzetének váltása (vízszintes/függőleges) |
| `Super + O` | Ablak átváltása sticky'n'floating módba |
| `Super + L` | Váltogatás a dwindle, a görgető és a lebegő elrendezés között |
| `Super + Alt + L` | Váltogatás az elrendezések között fordított irányban |
| `Super + P` | Álabakstílus ki-/bekapcsolása (természetes kontra nyújtott) |
| `Super + F` | Váltás teljes képernyőre |
| `Super + Alt + F` | Váltás teljes szélességre |
| `Super + Ctrl + F` | Teljes képernyő az ablakon belül |
| `Super + 1…9/0` | Ugrás a megadott munkaterületre (a 0 a 10-es) a fókuszban lévő monitoron |
| `Super + Tab` | Ugrás a következő munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + Tab` | Ugrás az előző munkaterületre a fókuszban lévő monitoron |
| `Super + Ctrl + Tab` | Ugrás a korábbi munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + 1…9/0` | Ablak áthelyezése munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + Alt + 1…9/0` | Ablak áthelyezése munkaterületre a fókuszban lévő monitoron anélkül, hogy követnéd |
| `Super + S` | A teljes scratchpad ki-/bekapcsolása |
| `Super + Alt + S` | Ablak áthelyezése a teljes scratchpadbe |
| `Super + Grave` | A Quake-konzol ki-/bekapcsolása |
| `Super + Shift + Grave` | Ablak áthelyezése a Quake-konzolba |
| `Super + Shift + Ctrl + Arrows` | Ablak áthelyezése az adott irányban lévő monitorra |
| `Super + Shift + Alt + Arrows` | Munkaterület áthelyezése az adott irányban lévő monitorra |
| `Super + Arrow` | Fókusz áthelyezése a nyíl irányában lévő ablakra, a képernyő szélén átlépve az azon az oldalon lévő monitorra |
| `Super + Shift + Arrow` | Ablak felcserélése a nyíl irányában lévő másikkal, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Minus` | Ablak kiszélesítése balra |
| `Super + Equal` | Ablak keskenyítése balra |
| `Super + Shift + Minus` | Ablak zsugorítása felfelé |
| `Super + Shift + Equal` | Ablak bővítése lefelé |
| `Super + Alt + Minus/Equal` | Ugyanaz az átméretezés kisebb lépésekben |
| `Super + Ctrl + Minus/Equal` | Ugyanaz az átméretezés nagyobb lépésekben |
| `Super + Alt + Home` | Ablak szélességének mentése |
| `Super + Home` | A mentett ablakszélesség visszaállítása |
| `Super + Left Mouse` | Ablak húzása |
| `Super + Right Mouse` | Ablak átméretezése |
| `Super + Scroll Wheel` | Görgetés a munkaterületek között a fókuszban lévő monitoron |
| `Super + G` | Ablakcsoportosítás ki-/bekapcsolása |
| `Super + Alt + G` | Ablak kivétele a csoportból |
| `Super + Alt + Tab` | Váltogatás a csoportban lévő ablakok között |
| `Super + Alt + Shift + Tab` | Váltogatás visszafelé a csoportban lévő ablakok között |
| `Super + Alt + Scroll Wheel` | Váltogatás a csoportban lévő ablakok között |
| `Super + Alt + 1/2/3/4/5` | Ugrás a megadott ablakra a csoportban |
| `Super + Alt + Arrow` | Ablak áthelyezése csoportba a nyíl irányában, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Ctrl + Left/Right` | Mozgás a csempéző csoporton belüli ablakok között |
| `Super + Ctrl + Z` | Nagyítás a képernyőn (ismételd a nagyobb nagyításhoz) |
| `Super + Ctrl + Alt + Z` | Teljes kicsinyítés a képernyőről |
| `Super + /` | Lépegetés előre a monitor méretezési lehetőségei között |
| `Super + Alt + /` | Lépegetés hátra a monitor méretezési lehetőségei között |
| `Alt + Tab` | Váltogatás előre az aktív munkaterületen lévő ablakok között |
| `Alt + Shift + Tab` | Váltogatás visszafelé az aktív munkaterületen lévő ablakok között |
| `Ctrl + Alt + Tab` | Fókusz léptetése előre a monitorok között |
| `Ctrl + Alt + Shift + Tab` | Fókusz léptetése visszafelé a monitorok között |
| `Super + I` | Beviteli nyelv váltása (egynél több kiosztás vagy beviteli mód esetén) |
| `Super + Shift + I` | Beviteli nyelv visszafelé váltása |

Érintőpadon a három- és négyujjas simítások munkaterületeket váltanak, ablakokat mozgatnak, és megnyitják a menüt és a Quake-konzolt; a mozdulatokat lásd itt: [billentyűzet, egér és érintőpad](34-keyboard-mouse-trackpad.md).

Az átméretező gyorsbillentyűk a `code:20` és `code:21` fizikai billentyűket használják (XKB `<AE11>` és `<AE12>`), függetlenül a billentyűzetre nyomtatott karakterektől. Amerikai billentyűzeteken ezek a `-` és `=` billentyűk; japán (JIS) billentyűzeteken a `-` és `^`; spanyol billentyűzeteken a `'` és `¡`. JIS esetén a `Super + ^` a `Super + Equal`, míg a `Super + Shift + -` (amely `=` jelet ír) a `Super + Shift + Minus`.

## Rendszervezérlés

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Hangpanel |
| `Super + Ctrl + B` | Bluetooth-panel |
| `Super + Ctrl + N` | Wi-Fi-/hálózati panel |
| `Super + Ctrl + D` | Kijelzőpanel |
| `Super + Ctrl + P` | Energiapanel |
| `Super + Ctrl + X` | Ágenspanel |
| `Super + Ctrl + Alt + D` | Naptárpanel |
| `Super + Ctrl + Alt + E` | Világóra-panel |
| `Super + Ctrl + 1-9` | Sávpanel ki-/bekapcsolása pozíció szerint |
| `Super + Ctrl + S` | Megosztás menü (a LocalSend segítségével) |
| `Super + Ctrl + C` | Rögzítésvezérlők (képernyőkép/-felvétel/választó) |
| `Super + Ctrl + O` | Menü ki-/bekapcsolása |
| `Super + Ctrl + H` | Hardvermenü |
| `Super + Ctrl + E` | Emodzsiválasztó |
| `Super + Ctrl + .` | Média átkódolása |
| `Super + Shift + Ctrl + A` | AI-ágens kiválasztása |
| `Power` key | Rendszermenü |
| `Super + Shift + Copilot` key | Omarchy menü |

## Beállítások

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximális képernyő-fényerő |
| `Shift + Brightness Down` | Minimális képernyő-fényerő |
| `Alt + Brightness Up/Down` | Pontos, 1%-os fényerő-változtatások |
| `Alt + Volume Up/Down` | Pontos, 1%-os hangerő-változtatások |
| `Keyboard Brightness Up/Down` | Billentyűzet-háttérvilágítás erősebb/gyengébb |
| `Keyboard Backlight` | Váltogatás a billentyűzet-háttérvilágítás szintjei között |
| `Ctrl + Brightness Up/Down` | Billentyűzet-háttérvilágítás erősebb/gyengébb, olyan billentyűzeteken, amelyeken nincsenek erre saját billentyűk |
| `Mic Mute` | A mikrofon némítása |
| `Shift + Mute` | Hangkimenet váltása |
| `Touchpad Toggle` | Az érintőpad ki-/bekapcsolása |
| `Display` key | A munkaterület-elrendezés váltogatása |
| `Alt + Play` | Következő szám |
| `Alt + Shift + Play` | Előző szám |

## Alkalmazások indítása

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + Return` | Terminál |
| `Super + Alt + Return` | Tmux-terminál |
| `Super + Ctrl + Return` | Herdr (ágenskezelő) |
| `Super + Shift + Return` or `Super + Shift + B` | Böngésző |
| `Super + Shift + Alt + B` | Böngésző (privát/inkognitó) |
| `Super + Shift + F` | Fájlkezelő |
| `Super + Shift + Alt + F` | Fájlkezelő a terminál cwd-jében |
| `Super + Shift + M` | Zene (Spotify) |
| `Super + Shift + Alt + M` | Zene (cliamp) |
| `Super + Shift + /` | Jelszókezelő (1password) |
| `Super + Shift + Q` or `Calculator` key | Számológép (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, ha telepítve van) |
| `Super + Shift + T` | Aktivitás (btop) |
| `Super + Shift + N` | Szerkesztő (Plain, vagy a választott alapértelmezetted) |
| `Super + Shift + C` | Naptár ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-mail ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Új e-mail ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Üzenetküldő (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Üzenetküldő (WhatsApp) |
| `Super + Shift + Ctrl + G` | Üzenetküldő (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Írás (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (új bejegyzés) |
| `Super + Shift + Y` | YouTube |

A kiosztásokat a `~/.config/hypr/bindings.lua` fájlban módosíthatod/vehetsz fel újakat.

## Univerzális vágólap

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + A` | Az összes kijelölése azokban az alkalmazásokban, amelyek támogatják a `Ctrl + A` kombinációt |
| `Super + C` | Másolás |
| `Super + X` | Kivágás (terminálban nem) |
| `Super + V` | Beillesztés |
| `Super + Ctrl + V` | Vágólapkezelő |

Linuxon általában `Ctrl + Shift + C/V` kell a terminálban való másoláshoz és beillesztéshez, és `Ctrl + C/V` mindenhol máshol. Ezek az Omarchy egységes vágólap-gyorsbillentyűi mindenhol működnek.

## Rögzítés

| Gyorsbillentyű | Funkció |
| ------------------- | ------------------------------ |
| `Print Screen` | Képernyőkép |
| `Super + Ctrl + Alt + C` | Képernyőkép (ugyanaz a felvétel, olyan billentyűzetekhez, amelyeken nincs Print Screen billentyű) |
| `Super + Ctrl + C` | Rögzítés menü |
| `Alt + Print Screen` | Képernyőfelvétel |
| `Super + Shift + Ctrl + Alt + C` | Képernyőfelvétel hang nélkül, a menü kihagyásával (a leállításhoz nyomd meg újra) |
| `Super + Print Screen` | Színválasztó |
| `Super + Ctrl + Print Screen` | Szöveg kinyerése a vágólapra |
| `Super + Alt + [` | A webkamera-réteg kisebbé tétele felvétel közben |
| `Super + Alt + ]` | A webkamera-réteg nagyobbá tétele felvétel közben |
| `Alt + Shift + L` | Az aktuális URL másolása a webalkalmazásból vagy a böngészőből |
| `Alt + Shift + D` | Az aktuális oldalon lévő videó letöltése ide: `~/Videos` |
| `Alt + Space` | Diktálás indítása/leállítása (ehhez szükséges: _Beállítás > Alapértelmezések > Diktálás_) |
| `Right Alt` | Tartsd nyomva a diktáláshoz (ehhez szükséges: _Beállítás > Alapértelmezések > Diktálás_) |

Képernyőfelvételeknél a gyorsbillentyű először megkérdezi, milyen hangot szeretnél, majd elindítja a felvételt. A leállításhoz nyomd meg újra. A részleteket lásd itt: [képernyőképek és felvétel](12-screenshots-recording.md).

Az összes rögzítési lehetőség elérhető az Omarchy menüben (`Super + Space`) az _Indító > Rögzítés_ alatt is.

## Értesítések

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + ,` | A legutóbbi értesítés kezelése: megnyitása vagy egyetlen gombjának megnyomása, választás a lehetőségei közül, vagy elvetése, ha egy sincs neki |
| `Super + Shift + ,` | Az összes értesítés elvetése |
| `Super + Ctrl + ,` | Értesítések vezérlése a billentyűzettel |
| `Super + Alt + ,` | A legutóbbi értesítés elvetése |
| `Super + Shift + Alt + ,` | Az értesítési előzmények megnyitása |
| `Super + Ctrl + Alt + ,` | Az értesítések némításának ki-/bekapcsolása |

## Stílus

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Új téma kiválasztása (ezzel is: `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Témaháttér kiválasztása (ezzel is: `Super + Ctrl + Space`) |
| `Super + Backspace` | Ablak átlátszóságának ki-/bekapcsolása |
| `Super + Ctrl + Backspace` | Egyablakos négyzetes képarány ki-/bekapcsolása |

A további háttérképek itt találhatók: `~/.config/omarchy/backgrounds/<theme name>`. Az Omarchy menüben a _Telepítés > Stílus > Háttér_ alatt is elérhető.

Az összes stíluslehetőség elérhető az Omarchy menüben (`Super + Space`) a _Megjelenés_ alatt is.

## Kapcsolók

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | A tétlenségnél zárolás ki-/bekapcsolása |
| `Super + Ctrl + Delete` | A laptopkijelző ki-/bekapcsolása |
| `Super + Ctrl + Alt + Delete` | A laptopkijelző tükrözésének ki-/bekapcsolása |
| `Super + Shift + Space` | A felső sáv ki-/bekapcsolása |
| `Shift + Mute` | Váltás a következő hangkimenetre |
| `Shift + Play` | Váltás a következő médiaforrásra |
| `Super + Shift + Backspace` | Az ablakközök ki-/bekapcsolása |
| `Super + Ctrl + Alt + F` | A teljes képernyős asztal ki-/bekapcsolása (felső sáv + ablakközök) |

## Emlékeztetők

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Emlékeztető beállítása |
| `Super + Ctrl + Alt + R` | Az összes emlékeztető megtekintése |
| `Super + Ctrl + Shift + R` | Az összes emlékeztető törlése |

## Jelzések

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Az idő megjelenítése értesítésként |
| `Super + Ctrl + Alt + B` | Az akkumulátor megjelenítése értesítésként |
| `Super + Ctrl + Alt + W` | Az időjárás értesítésként megjelenítésének ki-/bekapcsolása |

## Tmux

Az előtagbillentyű a `Ctrl + Space` (a `Ctrl + B` is működik). Ezeket a kiosztásokat a `~/.config/tmux/tmux.conf` fájlban módosíthatod.

### Ablaktáblák

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Prefix + v` | Ablaktábla felosztása mellé (függőleges) |
| `Prefix + h` | Ablaktábla felosztása alá (vízszintes) |
| `Prefix + x` | Ablaktábla megszüntetése |
| `Prefix + z` | Ablaktábla-nagyítás ki-/bekapcsolása (teljes képernyő) |
| `Alt + Enter` | Ablaktábla felosztása alá (előtag nélkül) |
| `Alt + Shift + Enter` | Ablaktábla felosztása mellé (előtag nélkül) |
| `Alt + Escape` | Ablaktábla megszüntetése (előtag nélkül) |
| `Ctrl + Alt + Arrows` | Mozgás az ablaktáblák között |
| `Ctrl + Alt + Shift + Arrows` | Ablaktáblák átméretezése |

### Ablakok

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Prefix + c` | Új ablak |
| `Prefix + k` | Ablak megszüntetése |
| `Prefix + r` | Ablak átnevezése |
| `Alt + 1-9` | Ugrás a megadott ablakra |
| `Alt + Arrow Left/Right` | Mozgás az ablakok között |
| `Alt + Shift + Arrow Left/Right` | Ablak mozgatása balra/jobbra |

### Munkamenetek

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Prefix + C` | Új munkamenet |
| `Prefix + K` | Munkamenet megszüntetése |
| `Prefix + R` | Munkamenet átnevezése |
| `Prefix + N` | Következő munkamenet |
| `Prefix + P` | Előző munkamenet |
| `Alt + Arrow Up/Down` | Mozgás a munkamenetek között |
| `Prefix + s` | Munkamenetek listázása |
| `Prefix + d` | Leválás a munkamenetről |

### Másoló mód (vi-stílusú)

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Prefix + [` | Belépés másoló módba |
| `v` | Kijelölés megkezdése (másoló módban) |
| `y` | Kijelölés másolása (másoló módban) |

### Általános

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Prefix + q` | A konfiguráció újratöltése |
| `Prefix + ?` | A Tmux-billentyűkiosztások megjelenítése |
| `Prefix + :` | Parancsbekérő |

### Tmux elrendezési függvények

Ezeket a függvényeket Tmux-munkameneten belül kell futtatni.

| Parancs | Funkció |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása szerkesztővel, AI-val és terminállal |
| `tdlm <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása alkönyvtáronként |
| `tsl <count> <command>` | Többablaktáblás swarm-elrendezés létrehozása |

## Ghostty Terminal

A Ghostty terminál az Omarchy menüben a _Telepítés > Terminál_ lehetőséggel telepíthető.

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Új felosztás alá |
| `Ctrl + Shift + O` | Új felosztás mellé |
| `Ctrl + Alt + Arrows` | Mozgás a felosztások között |
| `Super + Ctrl + Shift + Arrows` | Felosztás átméretezése 10 sorral |
| `Super + Ctrl + Shift + Alt + Arrows` | Felosztás átméretezése 100 sorral |
| `Ctrl + Shift + T` | Új lap |
| `Ctrl + Shift + Arrows` | Mozgás a lapok között |
| `Alt + Numbers` | Ugrás a megadott lapra |
| `Shift + Pg Up/Down` | Az előzmények görgetése |
| `Ctrl + Left mouse` | Hivatkozás megnyitása a böngészőben |

## Fájlkezelő

| Gyorsbillentyű | Funkció |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Ugrás az elérési útra |
| `Space` | Fájl előnézete (a nyilakkal navigálhatsz) |
| `Alt + Up` | Fel a szülőmappába |

## Neovim (w/ lazyvim)

### Navigáció

| Gyorsbillentyű | Funkció |
| ------------------------ | ------------------------------- |
| `Space` | A parancslehetőségek megjelenítése |
| `Space Space` | Fájl megnyitása fuzzy kereséssel |
| `Space E` | Az oldalsáv ki-/bekapcsolása |
| `Space G G` | A git-vezérlők megjelenítése |
| `Space S G` | Keresés a fájl tartalmában |
| `Ctrl + W W` | Ugrás az oldalsáv és a szerkesztő között |
| `Ctrl + Left/right arrow` | Az oldalsáv méretének módosítása |
| `Shift + H` | Ugrás a bal oldali fájllapra |
| `Shift + L` | Ugrás a jobb oldali fájllapra |
| `Space B D` | Fájllap bezárása |

### Az oldalsávban

| Gyorsbillentyű | Funkció |
| ------------------------ | ------------------------------- |
| `A` | Új fájl hozzáadása a szülőkönyvtárban |
| `Shift + A` | Új alkönyvtár hozzáadása a szülőkönyvtárban |
| `D` | A kijelölt fájl/könyvtár törlése |
| `M` | A kijelölt fájl/könyvtár áthelyezése |
| `R` | A kijelölt fájl/könyvtár átnevezése |
| `?` | Súgó megjelenítése az összes parancshoz |

[Nézd meg a LazyVim által beállított összes Neovim-gyorsbillentyűt](https://www.lazyvim.org/keymaps).

## Gyors emodzsik

A `Super + Ctrl + E` kombinációval megjeleníthetsz egy teljes emodzsiválasztót, amely a kiválasztottat a vágólapra teszi, vagy használhatod ezeket a gyorselérési lehetőségeket.

| Gyorsbillentyű | EM | Jelentés |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | mosoly |
| `Shift + CapsLock M C` | 😂 | sírás |
| `Shift + CapsLock M L` | 😍 | szerelem |
| `Shift + CapsLock M V` | ✌️ | győzelem |
| `Shift + CapsLock M H` | ❤️ | szív |
| `Shift + CapsLock M Y` | 👍 | igen |
| `Shift + CapsLock M N` | 👎 | nem |
| `Shift + CapsLock M F` | 🖕 | baszdmeg |
| `Shift + CapsLock M W` | 🤞 | kívánság |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | csók |
| `Shift + CapsLock M E` | 🙄 | szemforgatás |
| `Shift + CapsLock M I` | 😉 | kacsintás |
| `Shift + CapsLock M P` | 🙏 | imádkozik |
| `Shift + CapsLock M D` | 🤤 | nyáladzás |
| `Shift + CapsLock M M` | 💰 | pénz |
| `Shift + CapsLock M X` | 🎉 | ünneplés |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | koccintás |
| `Shift + CapsLock M O` |👌 | oké |
| `Shift + CapsLock M G` |👋 | üdvözlés |
| `Shift + CapsLock M A` |💪 | kar |
| `Shift + CapsLock M B` |🤯 | robbanás |

## Gyors kiegészítések

| Gyorsbillentyű | Kiegészítés |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (gondolatjel) |
| `Shift + CapsLock Space N` | A neved (ahogy a beállításkor megadtad) |
| `Shift + CapsLock Space E` | Az e-mail-címed (ahogy a beállításkor megadtad) |

További sajátokat a `~/.XCompose` szerkesztésével adhatsz hozzá, majd futtasd a terminálban az `omarchy restart xcompose` parancsot, hogy a változtatások életbe lépjenek.
