# Gyorsbillentyűk

Az összes fő billentyűkiosztást a `Super + K` kombinációval nézheted meg (a Tmux kiosztásokat a `Super + Alt + K`, a Herdr kiosztásokat pedig a `Super + Ctrl + K` kombinációval).

## Hogyan épülnek fel a gyorsbillentyűk

Minden gyorsbillentyű egy síkon helyezkedik el, amelyet a módosítói határoznak meg, és minden síknak egy feladata van. Ettől nem mosódnak össze a gyorsbillentyűk, és általában ki is tudod találni, mi hol lakik.

| Sík | Mi lakik ott | Példák |
| --- | --- | --- |
| `Super + key` | A rendszer: ablakok, munkaterületek, elrendezések és alapmenük | `Super + Space` Omarchy menü, `Super + W` ablak bezárása, `Super + F` teljes képernyő |
| `Super + Shift + key` | Alkalmazások | `Super + Shift + B` böngésző, `Super + Shift + E` e-mail, `Super + Shift + N` szerkesztő |
| `Super + Ctrl + key` | Panelek és rendszermenük | `Super + Ctrl + A` hang, `Super + Ctrl + N` hálózat, `Super + Ctrl + C` rögzítési menü |
| `Super + Ctrl + Alt + key` | Gyors műveletek és jelzések | `Super + Ctrl + Alt + T` idő megjelenítése, `Super + Ctrl + Alt + B` akkumulátor, `Super + Ctrl + Alt + C` képernyőkép |

Ha egy gyorsbillentyűhöz hozzáadod az `Alt` billentyűt, ugyanannak a dolognak egy változatát kapod, sosem valami teljesen mást:

- `Super + Shift + B` megnyitja a böngészőt; `Super + Shift + Alt + B` privát ablakot nyit
- `Super + Shift + E` megnyitja az e-mailt; `Super + Shift + Alt + E` újat kezd
- `Super + F` teljes képernyőre vált; `Super + Alt + F` teljes szélességre vált
- `Super + Ctrl + C` megnyitja a rögzítési menüt; `Super + Ctrl + Alt + C` kihagyja a menüt és képernyőképet készít

Gyorsbillentyű hozzáadásakor:

1. Válaszd ki a síkot abból, mit csinál, aztán válaszd ki a billentyűt.
2. Ne mozdíts el egy meglévő gyorsbillentyűt, hogy helyet csinálj. Keress egy szabad billentyűt a megfelelő síkon.
3. Az `Alt` billentyűt csak a nélküle működő gyorsbillentyű változatához használd.

Néhány gyorsbillentyű megszegi ezeket a szabályokat, mert úgy kényelmes. A `Shift` egy nyíllal vagy a `Tab` billentyűvel mozgat vagy visszafelé lép ahelyett, hogy alkalmazást nyitna, a `Print`, a médiabillentyűk, az `Alt + Tab` és a `Ctrl + Alt + Del` pedig úgy működnek, ahogy mindenhol máshol. Ezek kivételek, nem másolandó minták.

Ha egy alapértelmezés nem felel meg neked (mondjuk a `Super + Shift + S` kombinációt szeretnéd képernyőképekhez, mint Windowson), kösd újra a `~/.config/hypr/bindings.lua` fájlban.

## Navigálás

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menü (alkalmazások és minden más)    |
| `Super + Alt + Space` | Alkalmazásrács |
| `Super + Escape` | Rendszermenü (felfüggesztés, újraindítás stb.)  |
| `Super + Ctrl + L` | Számítógép zárolása |
| `Super + W` or `Super + Q` | Ablak bezárása             |
| `Ctrl + Alt + Del` | Az összes ablak bezárása |
| `Super + K` | Az összes gyorsbillentyű megjelenítése |
| `Super + Alt + K` | A tmux gyorsbillentyűk megjelenítése |
| `Super + Ctrl + K` | A herdr gyorsbillentyűk megjelenítése |
| `Super + M` | Ablak kicsinyítése a dokkra |
| `Super + T`               | Ablak váltása csempézett/lebegő között             |
| `Super + J` | Ablakpozíció váltása (vízszintes/függőleges) |
| `Super + O`               | Ablak átváltása sticky'n'floating módba |
| `Super + L`               | Végiglépkedés a dwindle, scrolling és floating elrendezéseken |
| `Super + Alt + L`         | Végiglépkedés az elrendezéseken fordított sorrendben |
| `Super + P`               | Ál-ablakstílus váltása (natural v stretch) |
| `Super + F`                 | Teljes képernyő              |
| `Super + Alt + F`                 | Teljes szélesség              |
| `Super + Ctrl + F`                 | Teljes képernyő az ablakon belül              |
| `Super + 1…9/0`         | Ugrás egy adott munkaterületre (a 0 a 10-es) a fókuszban lévő monitoron |
| `Super + Tab` | Ugrás a következő munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + Tab` | Ugrás az előző munkaterületre a fókuszban lévő monitoron |
| `Super + Ctrl + Tab` | Ugrás a korábbi munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + 1…9/0` | Ablak áthelyezése munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + Alt + 1…9/0` | Ablak áthelyezése munkaterületre a fókuszban lévő monitoron, követés nélkül |
| `Super + S` | Teljes scratchpad váltása |
| `Super + Alt + S` | Ablak áthelyezése a teljes scratchpadra |
| `Super + Grave` | Quake konzol váltása |
| `Super + Shift + Grave` | Ablak áthelyezése a Quake konzolba |
| `Super + Shift + Ctrl + Arrows` | Ablak áthelyezése az abban az irányban lévő monitorra |
| `Super + Shift + Alt + Arrows` | Munkaterület áthelyezése az abban az irányban lévő monitorra |
| `Super + Arrow`  | Fókusz áthelyezése a nyíl irányában lévő ablakra, a képernyő szélén átlépve az azon az oldalon lévő monitorra |
| `Super + Shift + Arrow`  | Ablak felcserélése a nyíl irányában lévő másikkal, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Minus` | Ablak kibővítése balra |
| `Super + Equal` | Ablak szűkítése balra |
| `Super + Shift + Minus` | Ablak szűkítése felfelé |
| `Super + Shift + Equal` | Ablak kibővítése lefelé |
| `Super + Alt + Minus/Equal` | Ugyanaz az átméretezés kisebb lépésekben |
| `Super + Ctrl + Minus/Equal` | Ugyanaz az átméretezés nagyobb lépésekben |
| `Super + Alt + Home` | Ablak szélességének mentése |
| `Super + Home` | Mentett ablaks szélesség visszaállítása |
| `Super + Left Mouse` | Ablak húzása |
| `Super + Right Mouse` | Ablak átméretezése |
| `Super + Scroll Wheel` | Görgetés a munkaterületeken a fókuszban lévő monitoron |
| `Super + G`               | Ablakcsoportosítás váltása      |
| `Super + Alt + G`               | Ablak kiemelése a csoportból      |
| `Super + Alt + Tab`               | Váltás a csoportban lévő ablakok között      |
| `Super + Alt + Shift + Tab`               | Váltás visszafelé a csoportban lévő ablakok között      |
| `Super + Alt + Scroll Wheel` | Váltás a csoportban lévő ablakok között |
| `Super + Alt + 1/2/3/4/5`               | Ugrás egy adott ablakra a csoportban      |
| `Super + Alt + Arrow`  | Ablak áthelyezése csoportba a nyíl irányában, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Ctrl + Left/Right`  | Mozgás az ablakok között egy csempézett csoporton belül |
| `Super + Ctrl + Z` | Nagyítás a képernyőn (ismételd a nagyobb nagyításhoz) |
| `Super + Ctrl + Alt + Z` | Teljes kicsinyítés a képernyőről |
| `Super + /` | Előrelépés a monitor méretezési lehetőségein |
| `Super + Alt + /` | Visszalépés a monitor méretezési lehetőségein |
| `Alt + Tab` | Váltás előre az aktív munkaterület ablakai között |
| `Alt + Shift + Tab` | Váltás visszafelé az aktív munkaterület ablakai között |
| `Ctrl + Alt + Tab`| Fókusz váltása előre a monitorok között |
| `Ctrl + Alt + Shift + Tab`| Fókusz váltása visszafelé a monitorok között |
| `Super + I` | Beviteli nyelv váltása (több kiosztás vagy beviteli mód esetén) |
| `Super + Shift + I` | Beviteli nyelv visszaváltása |

Érintőpadon a három- és négyujjas simítások munkaterületeket váltanak, ablakokat mozgatnak, és megnyitják a menüt és a Quake konzolt; a mozdulatokat lásd a [billentyűzet, egér és érintőpad](34-keyboard-mouse-trackpad.md) oldalon.

Az átméretező parancsok a `code:20` és `code:21` fizikai billentyűket használják (XKB `<AE11>` és `<AE12>`), függetlenül attól, milyen karakterek vannak a billentyűzetre nyomtatva. US billentyűzeteken ezek a billentyűk a `-` és `=`; japán (JIS) billentyűzeteken a `-` és `^`; spanyol billentyűzeteken az `'` és `¡`. JIS esetén a `Super + ^` a `Super + Equal`, míg a `Super + Shift + -` (amely `=` jelet ír) a `Super + Shift + Minus`.

## Rendszervezérlők

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Hangpanel    |
| `Super + Ctrl + B`           | Bluetooth panel    |
| `Super + Ctrl + N`           | Wi-Fi/hálózati panel    |
| `Super + Ctrl + D`           | Kijelzőpanel    |
| `Super + Ctrl + P`           | Energiapanel    |
| `Super + Ctrl + X`           | Ágensek panel    |
| `Super + Ctrl + Alt + X`           | Helyi modellek panel    |
| `Super + Ctrl + Alt + D`           | Naptárpanel    |
| `Super + Ctrl + Alt + E`           | Világóra panel    |
| `Super + Ctrl + 1-9`           | Sávpanel váltása pozíció szerint    |
| `Super + Ctrl + S` | Megosztás menü (LocalSend segítségével) |
| `Super + Ctrl + C` | Rögzítésvezérlők (képernyőkép/-felvétel/választó) |
| `Super + Ctrl + O` | Menü váltása |
| `Super + Ctrl + H` | Hardver menü |
| `Super + Ctrl + E` | Emoji-választó |
| `Super + Ctrl + .` | Média átkódolása |
| `Super + Shift + Ctrl + A` | AI-ágens kiválasztása |
| `Power` billentyű | Rendszermenü |
| `Super + Shift + Copilot` billentyű | Omarchy menü |

## Beállítások

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximális képernyőfényerő |
| `Shift + Brightness Down` | Minimális képernyőfényerő |
| `Alt + Brightness Up/Down` | Pontos, 1%-os fényerőváltoztatások |
| `Alt + Volume Up/Down` | Pontos, 1%-os hangerőváltoztatások |
| `Keyboard Brightness Up/Down` | Billentyűzet-háttérvilágítás erősebb/gyengébb |
| `Keyboard Backlight` | A billentyűzet-háttérvilágítás szintjeinek végigléptetése |
| `Ctrl + Brightness Up/Down` | Billentyűzet-háttérvilágítás erősebb/gyengébb, saját billentyűk nélküli billentyűzeteken |
| `Mic Mute` | Mikrofon némítása |
| `Shift + Mute` | Hangkimenet váltása |
| `Touchpad Toggle` | Érintőpad be- vagy kikapcsolása |
| `Display` billentyű | Munkaterület-elrendezés végigléptetése |
| `Alt + Play` | Következő szám |
| `Alt + Shift + Play` | Előző szám |

## Alkalmazások indítása

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminál    |
| `Super + Alt + Return` | Tmux terminál |
| `Super + Ctrl + Return` | Herdr (ágenskezelő) |
| `Super + Shift + Return` or `Super + Shift + B`  | Böngésző    |
| `Super + Shift + Alt + B`           | Böngésző (privát/inkognitó)    |
| `Super + Shift + F`           | Fájlkezelő    |
| `Super + Shift + Alt + F`           | Fájlkezelő a terminál cwd könyvtárában    |
| `Super + Shift + M`           | Zene (Spotify)    |
| `Super + Shift + Alt + M`           | Zene (cliamp)    |
| `Super + Shift + /`           | Jelszókezelő (1password)    |
| `Super + Shift + Q` or `Calculator` billentyű  | Számológép (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, telepítés után)    |
| `Super + Shift + T`           | Tevékenység (btop)    |
| `Super + Shift + N`           | Szerkesztő (Plain, vagy a választott alapértelmezetted)  |
| `Super + Shift + C`           | Naptár ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Új e-mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Üzenetküldő (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Üzenetküldő (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Üzenetküldő (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Írás (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (új bejegyzés) |
| `Super + Shift + Y`           | YouTube |

A kiosztások módosítása/hozzáadása a `~/.config/hypr/bindings.lua` fájlban.

## Univerzális vágólap

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + A`           | Az összes kijelölése azokban az alkalmazásokban, amelyek támogatják a `Ctrl + A` kombinációt    |
| `Super + C`           | Másolás    |
| `Super + X`           | Kivágás (terminálban nem)    |
| `Super + V`           | Beillesztés    |
| `Super + Ctrl + V`           | Vágólapkezelő    |

Linuxon általában `Ctrl + Shift + C/V` kell a másoláshoz és beillesztéshez a terminálban, és `Ctrl + C/V` mindenhol máshol. Ezek az egységes Omarchy vágólap-gyorsbillentyűk mindenhol működnek.

## Rögzítés

| Gyorsbillentyű              | Funkció                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Képernyőkép                      |
| `Super + Ctrl + Alt + C`            | Képernyőkép (ugyanaz a felvétel, Print Screen billentyű nélküli billentyűzetekhez) |
| `Super + Ctrl + C` | Rögzítés menü |
| `Alt + Print Screen`            | Képernyőfelvétel                     |
| `Super + Shift + Ctrl + Alt + C` | Képernyőfelvétel hang nélkül, a menü kihagyásával (nyomd meg újra a leállításhoz) |
| `Super + Print Screen` | Színválasztó |
| `Super + Ctrl + Print Screen` | Szöveg kinyerése a vágólapra |
| `Super + Alt + [` | Webkamera-réteg kisebbé tétele felvétel közben |
| `Super + Alt + ]` | Webkamera-réteg nagyobbá tétele felvétel közben |
| `Alt + Shift + L` | Aktuális URL másolása webalkalmazásból vagy böngészőből |
| `Alt + Shift + D` | Az aktuális oldalon lévő videó letöltése a `~/Videos` mappába |
| `Alt + Space` | Diktálás indítása/leállítása (szükséges hozzá: _Setup > Defaults > Dictation_) |
| `Right Alt` | Tartsd lenyomva a diktáláshoz (szükséges hozzá: _Setup > Defaults > Dictation_) |

Képernyőfelvételeknél a gyorsbillentyű először megkérdezi, milyen hangot szeretnél, aztán elindítja a felvételt. Nyomd meg újra a leállításhoz. A részleteket lásd a [képernyőképek és felvétel](12-screenshots-recording.md) oldalon.

Az összes rögzítési lehetőség elérhető az Omarchy menü (`Super + Space`) _Trigger > Capture_ pontja alatt is.

## Értesítések

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + ,` | Művelet a legutóbbi értesítésen: megnyitása vagy egyetlen gombjának megnyomása, választás a lehetőségei közül, vagy elvetése, ha egyik sincs  |
| `Super + Shift + ,` | Az összes értesítés elvetése |
| `Super + Ctrl + ,` | Értesítések vezérlése a billentyűzettel  |
| `Super + Alt + ,` | Legutóbbi értesítés elvetése  |
| `Super + Shift + Alt + ,` | Értesítési előzmények megnyitása  |
| `Super + Ctrl + Alt + ,` | Értesítések némításának váltása  |

## Stílus

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Új téma kiválasztása (akár `Super + Ctrl + Shift + Space` is) |
| `Super + Ctrl + W` | Témaháttér kiválasztása (akár `Super + Ctrl + Space` is) |
| `Super + Backspace` | Átlátszóság váltása egy ablakon |
| `Super + Ctrl + Backspace` | Egyablakos négyzetes képarány váltása |

A további háttérképek a `~/.config/omarchy/backgrounds/<theme name>` mappában vannak. Elérhető az Omarchy menü _Install > Style > Background_ pontján keresztül is.

Az összes stílusbeállítás elérhető az Omarchy menü (`Super + Space`) _Appearance_ pontja alatt is.

## Kapcsolók

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Zárolás üresjáratban váltása |
| `Super + Ctrl + Delete` | Laptopkijelző be-/kikapcsolása |
| `Super + Ctrl + Alt + Delete` | Laptopkijelző tükrözésének váltása |
| `Super + Shift + Space` | Felső sáv váltása  |
| `Shift + Mute` | Váltás a következő hangkimenetre |
| `Shift + Play` | Váltás a következő médiaforrásra |
| `Super + Shift + Backspace` | Ablakközök váltása |
| `Super + Ctrl + Alt + F` | Teljes képernyős asztal váltása (felső sáv + ablakközök) |

## Emlékeztetők

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Emlékeztető beállítása  |
| `Super + Ctrl + Alt + R` | Az összes emlékeztető megtekintése  |
| `Super + Ctrl + Shift + R` | Az összes emlékeztető törlése  |

## Közlemények

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Idő megjelenítése értesítésként  |
| `Super + Ctrl + Alt + B` | Akkumulátor megjelenítése értesítésként  |
| `Super + Ctrl + Alt + W` | Időjárás értesítésként váltása  |

## Tmux

Az előtagbillentyű a `Ctrl + Space` (a `Ctrl + B` is működik). Ezeket a kiosztásokat a `~/.config/tmux/tmux.conf` fájlban módosíthatod.

### Panelek

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + v` | Panel kettéosztása mellé (függőleges) |
| `Prefix + h` | Panel kettéosztása alá (vízszintes) |
| `Prefix + x` | Panel kilövése |
| `Prefix + z` | Panelnagyítás váltása (teljes képernyő) |
| `Alt + Enter` | Panel kettéosztása alá (előtag nélkül) |
| `Alt + Shift + Enter` | Panel kettéosztása mellé (előtag nélkül) |
| `Alt + Escape` | Panel kilövése (előtag nélkül) |
| `Ctrl + Alt + Arrows` | Mozgás a panelek között |
| `Ctrl + Alt + Shift + Arrows` | Panelek átméretezése |

### Ablakok

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + c` | Új ablak |
| `Prefix + k` | Ablak kilövése |
| `Prefix + r` | Ablak átnevezése |
| `Alt + 1-9` | Ugrás egy adott ablakra |
| `Alt + Arrow Left/Right` | Mozgás az ablakok között |
| `Alt + Shift + Arrow Left/Right` | Ablak mozgatása balra/jobbra |

### Munkamenetek

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + C` | Új munkamenet |
| `Prefix + K` | Munkamenet kilövése |
| `Prefix + R` | Munkamenet átnevezése |
| `Prefix + N` | Következő munkamenet |
| `Prefix + P` | Előző munkamenet |
| `Alt + Arrow Up/Down` | Mozgás a munkamenetek között |
| `Prefix + s` | Munkamenetek listázása |
| `Prefix + d` | Leválás a munkamenetről |

### Másolási mód (vi-stílusú)

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + [` | Belépés másolási módba |
| `v` | Kijelölés megkezdése (másolási módban) |
| `y` | Kijelölés másolása (másolási módban) |

### Általános

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguráció újratöltése |
| `Prefix + ?` | Tmux billentyűkiosztások megjelenítése |
| `Prefix + :` | Parancssor |

### Tmux elrendezési funkciók

Ezeket a funkciókat egy Tmux munkameneten belül kell futtatni.

| Parancs | Funkció |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása szerkesztővel, AI-val és terminállal |
| `tdlm <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása alkönyvtáranként |
| `tsl <count> <command>` | Többpaneles swarm elrendezés létrehozása |

## Ghostty Terminal

A Ghostty terminál az Omarchy menü _Install > Terminal_ pontjával telepíthető.

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Új felosztás alá |
| `Ctrl + Shift + O` | Új felosztás mellé |
| `Ctrl + Alt + Arrows` | Mozgás a felosztások között |
| `Super + Ctrl + Shift + Arrows` | Felosztás átméretezése 10 sorral |
| `Super + Ctrl + Shift + Alt + Arrows` | Felosztás átméretezése 100 sorral |
| `Ctrl + Shift + T` | Új lap  |
| `Ctrl + Shift + Arrows` | Mozgás a lapok között |
| `Alt + Numbers` | Ugrás egy adott lapra |
| `Shift + Pg Up/Down` | Előzmények görgetése |
| `Ctrl + Left mouse` | Hivatkozás megnyitása böngészőben |

## Fájlkezelő

| Gyorsbillentyű              | Funkció                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ugrás egy elérési útra                     |
| `Space`               | Fájl előnézete (a nyilakkal navigálhatsz) |
| `Alt + Up`       | Fel a szülőmappába        |

## Neovim (w/ lazyvim)

### Navigálás

| Gyorsbillentyű                   | Funkció                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Parancslehetőségek megjelenítése            |
| `Space Space`              | Fájl megnyitása fuzzy kereséssel      |
| `Space E`                  | Oldalsáv váltása                  |
| `Space G G`                | Git-vezérlők megjelenítése               |
| `Space S G`                | Fájltartalom keresése             |
| `Ctrl + W W`               | Ugrás az oldalsáv és a szerkesztő között |
| `Ctrl + Left/right arrow`  | Oldalsáv méretének módosítása          |
| `Shift + H`                      | Ugrás a bal oldali fájllapra             |
| `Shift + L`                      | Ugrás a jobb oldali fájllapra            |
| `Space B D`                | Fájllap bezárása                  |

### Az oldalsávban

| Gyorsbillentyű                   | Funkció                        |
| ------------------------ | ------------------------------- |
| `A`                        | Új fájl hozzáadása a szülőkönyvtárban      |
| `Shift + A`                | Új alkönyvtár hozzáadása a szülőkönyvtárban    |
| `D`                        | Kiemelt fájl/könyvtár törlése     |
| `M`                        | Kiemelt fájl/könyvtár áthelyezése       |
| `R`                        | Kiemelt fájl/könyvtár átnevezése     |
| `?`                        | Súgó megjelenítése az összes parancshoz      |

[Tekintsd meg a LazyVim által beállított összes Neovim gyorsbillentyűt](https://www.lazyvim.org/keymaps).

## Gyors emojik

A `Super + Ctrl + E` kombinációval megjeleníthetsz egy teljes emoji-választót, amely a kiválasztottat a vágólapra teszi, vagy használhatod ezeket a gyors elérési lehetőségeket.

| Gyorsbillentyű       | EM | Jel       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | mosoly      |
| `Shift + CapsLock M C` | 😂 | sírás        |
| `Shift + CapsLock M L` | 😍 | szerelem       |
| `Shift + CapsLock M V` | ✌️ | győzelem    |
| `Shift + CapsLock M H` | ❤️ | szív      |
| `Shift + CapsLock M Y` | 👍 | igen        |
| `Shift + CapsLock M N` | 👎 | nem         |
| `Shift + CapsLock M F` | 🖕 | bassza meg       |
| `Shift + CapsLock M W` | 🤞 | kívánság       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | csók       |
| `Shift + CapsLock M E` | 🙄 | szemforgatás    |
| `Shift + CapsLock M I` | 😉 | kacsintás       |
| `Shift + CapsLock M P` | 🙏 | ima |
| `Shift + CapsLock M D` | 🤤 | nyáladzás      |
| `Shift + CapsLock M M` | 💰 | pénz      |
| `Shift + CapsLock M X` | 🎉 | ünneplés |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | koccintás      |
| `Shift + CapsLock M O` |👌 | oké |
| `Shift + CapsLock M G` |👋 | üdvözlet |
| `Shift + CapsLock M A` |💪 | kar |
| `Shift + CapsLock M B` |🤯 | fejrobbanás |

## Gyors kiegészítések

| Gyorsbillentyű       | Kiegészítés       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (gondolatjel)   |
| `Shift + CapsLock Space N` | A neved (ahogy a beállításkor megadtad)  |
| `Shift + CapsLock Space E` | Az e-mail-címed (ahogy a beállításkor megadtad)  |

Továbbiakat is hozzáadhatsz a `~/.XCompose` szerkesztésével, majd futtasd az `omarchy restart xcompose` parancsot a terminálban, hogy a változások érvénybe lépjenek.
