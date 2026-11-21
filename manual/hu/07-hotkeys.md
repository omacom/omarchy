# Gyorsbillentyűk

Az összes fő billentyűkiosztást a `Super + K` billentyűvel tekintheted meg (a Tmux kiosztásait a `Super + Alt + K`, a Herdr kiosztásait pedig a `Super + Ctrl + K` billentyűvel).

## Hogyan épülnek fel a gyorsbillentyűk

Minden gyorsbillentyű egy síkon helyezkedik el, amelyet a módosító billentyűi határoznak meg, és minden síknak egy feladata van. Ez tartja távol a gyorsbillentyűket attól, hogy összemosódjanak, és azt jelenti, hogy általában ki tudod találni, mi hol található.

| Sík | Mi tartozik ide | Példák |
| --- | --- | --- |
| `Super + key` | A rendszer: ablakok, munkaterületek, elrendezések és alapvető menük | `Super + Space` Omarchy menü, `Super + W` ablak bezárása, `Super + F` teljes képernyő |
| `Super + Shift + key` | Alkalmazások | `Super + Shift + B` böngésző, `Super + Shift + E` e-mail, `Super + Shift + N` szerkesztő |
| `Super + Ctrl + key` | Panelek és rendszermenük | `Super + Ctrl + A` hang, `Super + Ctrl + N` hálózat, `Super + Ctrl + C` rögzítés menü |
| `Super + Ctrl + Alt + key` | Gyorsműveletek és tájékoztatók | `Super + Ctrl + Alt + T` idő megjelenítése, `Super + Ctrl + Alt + B` akkumulátor, `Super + Ctrl + Alt + C` képernyőkép |

Ha egy gyorsbillentyűhöz hozzáadod az `Alt` billentyűt, ugyanannak a dolognak egy változatát kapod, soha nem valami teljesen mást:

- A `Super + Shift + B` megnyitja a böngészőt; a `Super + Shift + Alt + B` privát ablakot nyit meg
- A `Super + Shift + E` megnyitja az e-mailt; a `Super + Shift + Alt + E` újat kezd
- A `Super + F` teljes képernyőre vált; a `Super + Alt + F` teljes szélességre vált
- A `Super + Ctrl + C` megnyitja a rögzítés menüt; a `Super + Ctrl + Alt + C` kihagyja a menüt, és képernyőképet készít

Gyorsbillentyű hozzáadásakor:

1. Válaszd ki a síkot aszerint, hogy mit csinál, aztán válaszd ki a billentyűt.
2. Ne mozgass át egy meglévő gyorsbillentyűt, hogy helyet csinálj neki. Keress egy szabad billentyűt a megfelelő síkon.
3. Az `Alt` billentyűt csak a nélküle használt gyorsbillentyű változatához használd.

Néhány gyorsbillentyű megszegi ezeket a szabályokat, mert úgy kényelmes. A `Shift` egy nyíllal vagy a `Tab` billentyűvel mozgat vagy visszafelé halad ahelyett, hogy alkalmazást nyitna meg, a `Print`, a médiabillentyűk, az `Alt + Tab` és a `Ctrl + Alt + Del` pedig úgy működnek, ahogy mindenhol máshol. Ezek kivételek, nem követendő minták.

Ha egy alapértelmezett beállítás nem felel meg neked (mondjuk a képernyőképekhez a `Super + Shift + S` billentyűt szeretnéd, mint Windowson), kösd át a `~/.config/hypr/bindings.lua` fájlban.

## Navigálás

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menü (alkalmazások és minden más)    |
| `Super + Alt + Space` | Alkalmazásrács |
| `Super + Escape` | Rendszermenü (felfüggesztés, újraindítás stb.)  |
| `Super + Ctrl + L` | Számítógép zárolása |
| `Super + W` or `Super + Q` | Ablak bezárása             |
| `Ctrl + Alt + Del` | Összes ablak bezárása |
| `Super + K` | Összes gyorsbillentyű megjelenítése |
| `Super + Alt + K` | Tmux gyorsbillentyűk megjelenítése |
| `Super + Ctrl + K` | Herdr gyorsbillentyűk megjelenítése |
| `Super + M` | Ablak minimalizálása a dokkra |
| `Super + T`               | Ablak váltása csempézett/lebegő között             |
| `Super + J` | Ablakpozíció váltása (vízszintes/függőleges) |
| `Super + O`               | Ablak átváltása sticky'n'floating állapotba |
| `Super + L`               | Váltás sorban a dwindle, scrolling és floating elrendezések között |
| `Super + Alt + L`         | Az elrendezések váltása fordított sorrendben |
| `Super + P`               | Pszeudoablak-stílus váltása (natural v stretch) |
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
| `Super + Alt + S` | Ablak áthelyezése a teljes scratchpadre |
| `Super + Grave` | Quake konzol váltása |
| `Super + Shift + Grave` | Ablak áthelyezése a Quake konzolra |
| `Super + Shift + Ctrl + Arrows` | Ablak áthelyezése az abban az irányban lévő monitorra |
| `Super + Shift + Alt + Arrows` | Munkaterület áthelyezése az abban az irányban lévő monitorra |
| `Super + Arrow`  | Fókusz áthelyezése a nyíl irányában lévő ablakra, a képernyő szélén átlépve az azon az oldalon lévő monitorra |
| `Super + Shift + Arrow`  | Ablak cseréje egy másikkal a nyíl irányában, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Minus` | Ablak kiszélesítése balra |
| `Super + Equal` | Ablak keskenyítése balra |
| `Super + Shift + Minus` | Ablak keskenyítése felfelé |
| `Super + Shift + Equal` | Ablak kiszélesítése lefelé |
| `Super + Alt + Minus/Equal` | Ugyanaz az átméretezés kisebb lépésekben |
| `Super + Ctrl + Minus/Equal` | Ugyanaz az átméretezés nagyobb lépésekben |
| `Super + Alt + Home` | Ablak szélességének mentése |
| `Super + Home` | Mentett ablakszélesség visszaállítása |
| `Super + Left Mouse` | Ablak húzása |
| `Super + Right Mouse` | Ablak átméretezése |
| `Super + Scroll Wheel` | Görgetés a munkaterületek között a fókuszban lévő monitoron |
| `Super + G`               | Ablakcsoportosítás váltása      |
| `Super + Alt + G`               | Ablak kivétele a csoportosításból      |
| `Super + Alt + Tab`               | Váltás sorban a csoportban lévő ablakok között      |
| `Super + Alt + Shift + Tab`               | Váltás visszafelé sorban a csoportban lévő ablakok között      |
| `Super + Alt + Scroll Wheel` | Váltás sorban a csoportban lévő ablakok között |
| `Super + Alt + 1/2/3/4/5`               | Ugrás egy adott ablakra a csoportban      |
| `Super + Alt + Arrow`  | Ablak bevitele a csoportba a nyíl irányában, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Ctrl + Left/Right`  | Mozgás az ablakok között egy csempézett csoporton belül |
| `Super + Ctrl + Z` | Nagyítás a képernyőn (további nagyításhoz ismételd) |
| `Super + Ctrl + Alt + Z` | Teljes kicsinyítés a képernyőről |
| `Super + /` | Lépés előre a monitor méretezési lehetőségei között |
| `Super + Alt + /` | Lépés visszafelé a monitor méretezési lehetőségei között |
| `Alt + Tab` | Váltás előre sorban az aktív munkaterület ablakai között |
| `Alt + Shift + Tab` | Váltás visszafelé sorban az aktív munkaterület ablakai között |
| `Ctrl + Alt + Tab`| Fókusz váltása előre sorban a monitorok között |
| `Ctrl + Alt + Shift + Tab`| Fókusz váltása visszafelé sorban a monitorok között |
| `Super + I` | Beviteli nyelv váltása (egynél több kiosztás vagy beviteli mód esetén) |
| `Super + Shift + I` | Beviteli nyelv visszaváltása |

Érintőpadon a három- és négyujjas pöccintések munkaterületeket váltanak, ablakokat mozgatnak, valamint megnyitják a menüt és a Quake konzolt; a gesztusokért lásd a [billentyűzet, egér és érintőpad](34-keyboard-mouse-trackpad.md) oldalt.

Az átméretezési gyorsbillentyűk a fizikai `code:20` és `code:21` billentyűket használják (XKB `<AE11>` és `<AE12>`), függetlenül attól, milyen karakterek vannak a billentyűzetre nyomtatva. US billentyűzeteken ezek a billentyűk a `-` és az `=`; japán (JIS) billentyűzeteken a `-` és a `^`; spanyol billentyűzeteken pedig a `'` és az `¡`. JIS kiosztáson a `Super + ^` a `Super + Equal`, míg a `Super + Shift + -` (amely az `=` karaktert írja) a `Super + Shift + Minus`.

## Rendszervezérlők

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Hangpanel    |
| `Super + Ctrl + B`           | Bluetooth panel    |
| `Super + Ctrl + N`           | Wi-Fi/hálózati panel    |
| `Super + Ctrl + D`           | Kijelzőpanel    |
| `Super + Ctrl + P`           | Energiapanel    |
| `Super + Ctrl + X`           | Ágensek panelje    |
| `Super + Ctrl + Shift + X`           | Helyi modellek panelje    |
| `Super + Ctrl + Alt + D`           | Naptárpanel    |
| `Super + Ctrl + Alt + E`           | Világóra panel    |
| `Super + Ctrl + 1-9`           | Sávpanel váltása pozíció szerint    |
| `Super + Ctrl + S` | Megosztás menü (a LocalSend segítségével) |
| `Super + Ctrl + C` | Rögzítési vezérlők (képernyőkép/-felvétel/választó) |
| `Super + Ctrl + O` | Menü váltása |
| `Super + Ctrl + H` | Hardver menü |
| `Super + Ctrl + E` | Emoji-választó |
| `Super + Ctrl + .` | Média átkódolása |
| `Super + Shift + Ctrl + A` | AI-ágens kiválasztása |
| `Power` billentyű | Rendszermenü |
| `Super + Shift + Copilot` billentyű | Omarchy menü |

## Állítások

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximális képernyő-fényerő |
| `Shift + Brightness Down` | Minimális képernyő-fényerő |
| `Alt + Brightness Up/Down` | Pontos, 1%-os fényerő-változtatások |
| `Alt + Volume Up/Down` | Pontos, 1%-os hangerő-változtatások |
| `Keyboard Brightness Up/Down` | Billentyűzet-háttérvilágítás fényesebb/halványabb |
| `Keyboard Backlight` | A billentyűzet-háttérvilágítás szintjeinek váltása sorban |
| `Ctrl + Brightness Up/Down` | Billentyűzet-háttérvilágítás fényesebb/halványabb, olyan billentyűzeteken, amelyeken nincsenek ehhez saját billentyűk |
| `Mic Mute` | A mikrofon némítása |
| `Shift + Mute` | Hangkimenet váltása |
| `Touchpad Toggle` | Az érintőpad be- vagy kikapcsolása |
| `Display` billentyű | A munkaterület-elrendezés váltása sorban |
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
| `Super + Shift + T`           | Aktivitás (btop)    |
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

A kiosztásokat a `~/.config/hypr/bindings.lua` fájlban módosíthatod/vehetsz fel újakat.

## Univerzális vágólap

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + A`           | Összes kijelölése azokban az alkalmazásokban, amelyek támogatják a `Ctrl + A` billentyűkombinációt    |
| `Super + C`           | Másolás    |
| `Super + X`           | Kivágás (terminálban nem)    |
| `Super + V`           | Beillesztés    |
| `Super + Ctrl + V`           | Vágólapkezelő    |

Linuxon általában a `Ctrl + Shift + C/V` kell a terminálban való másoláshoz és beillesztéshez, a `Ctrl + C/V` pedig mindenhol máshol ugyanehhez. Ezek az Omarchy egységes vágólap-gyorsbillentyűi mindenhol működnek.

## Rögzítés

| Gyorsbillentyű              | Funkció                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Képernyőkép                      |
| `Super + Ctrl + Alt + C`            | Képernyőkép (ugyanaz a felvétel, Print Screen billentyű nélküli billentyűzetekhez) |
| `Super + Ctrl + C` | Rögzítés menü |
| `Alt + Print Screen`            | Képernyőfelvétel                     |
| `Super + Shift + Ctrl + Alt + C` | Képernyőfelvétel hang nélkül, a menü kihagyásával (a leállításhoz nyomd meg újra) |
| `Super + Print Screen` | Színválasztó |
| `Super + Ctrl + Print Screen` | Szöveg kinyerése a vágólapra |
| `Super + Alt + [` | A webkamera-réteg kisebbé tétele felvétel közben |
| `Super + Alt + ]` | A webkamera-réteg nagyobbá tétele felvétel közben |
| `Alt + Shift + L` | Az aktuális URL másolása webalkalmazásból vagy böngészőből |
| `Alt + Shift + D` | Az aktuális oldalon lévő videó letöltése ide: `~/Videos` |
| `Alt + Space` | Diktálás indítása/leállítása (szükséges hozzá: _Setup > Defaults > Dictation_) |
| `Right Alt` | Tartsd lenyomva a diktáláshoz (szükséges hozzá: _Setup > Defaults > Dictation_) |

Képernyőfelvételeknél a gyorsbillentyű először megkérdezi, milyen hangot szeretnél, aztán elindítja a felvételt. A leállításhoz nyomd meg újra. A részletekért lásd a [képernyőképek és felvétel](12-screenshots-recording.md) oldalt.

Minden rögzítési lehetőség az Omarchy menü (`Super + Space`) _Trigger > Capture_ pontja alatt is elérhető.

## Értesítések

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + ,` | Művelet a legutóbbi értesítésen: megnyitja, vagy megnyomja az egyetlen gombját, választ a lehetőségei közül, vagy elveti, ha egy sincs neki  |
| `Super + Shift + ,` | Összes értesítés elvetése |
| `Super + Ctrl + ,` | Értesítések vezérlése a billentyűzettel  |
| `Super + Alt + ,` | A legutóbbi értesítés elvetése  |
| `Super + Shift + Alt + ,` | Értesítési előzmények megnyitása  |
| `Super + Ctrl + Alt + ,` | Értesítések némításának váltása  |

## Stílus

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Új téma kiválasztása (ezzel is: `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Témaháttér kiválasztása (ezzel is: `Super + Ctrl + Space`) |
| `Super + Backspace` | Átlátszóság váltása egy ablakon |
| `Super + Ctrl + Backspace` | Egyablakos négyzetes képarány váltása |

Az extra háttérképek itt találhatók: `~/.config/omarchy/backgrounds/<theme name>`. Az Omarchy menüben a _Install > Style > Background_ útvonalon is elérhető.

Minden stílusbeállítás az Omarchy menü (`Super + Space`) _Appearance_ pontja alatt is elérhető.

## Kapcsolók

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Zárolás váltása tétlenség esetén |
| `Super + Ctrl + Delete` | Laptopkijelző be-/kikapcsolásának váltása |
| `Super + Ctrl + Alt + Delete` | Laptopkijelző tükrözésének váltása |
| `Super + Shift + Space` | A felső sáv váltása  |
| `Shift + Mute` | Váltás a következő hangkimenetre |
| `Shift + Play` | Váltás a következő médiaforrásra |
| `Super + Shift + Backspace` | Ablakrések váltása |
| `Super + Ctrl + Alt + F` | Teljes képernyős asztal váltása (felső sáv + ablakrések) |

## Emlékeztetők

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Emlékeztető beállítása  |
| `Super + Ctrl + Alt + R` | Összes emlékeztető megtekintése  |
| `Super + Ctrl + Shift + R` | Összes emlékeztető törlése  |

## Tájékoztatók

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Idő megjelenítése értesítésként  |
| `Super + Ctrl + Alt + B` | Akkumulátor megjelenítése értesítésként  |
| `Super + Ctrl + Alt + W` | Időjárás értesítésként való megjelenítésének váltása  |

## Tmux

Az előtagbillentyű a `Ctrl + Space` (a `Ctrl + B` is működik). Ezeket a kiosztásokat a `~/.config/tmux/tmux.conf` fájlban módosíthatod.

### Ablaktáblák

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + v` | Ablaktábla felosztása mellé (függőleges) |
| `Prefix + h` | Ablaktábla felosztása alá (vízszintes) |
| `Prefix + x` | Ablaktábla bezárása |
| `Prefix + z` | Ablaktábla nagyításának váltása (teljes képernyő) |
| `Alt + Enter` | Ablaktábla felosztása alá (előtag nélkül) |
| `Alt + Shift + Enter` | Ablaktábla felosztása mellé (előtag nélkül) |
| `Alt + Escape` | Ablaktábla bezárása (előtag nélkül) |
| `Ctrl + Alt + Arrows` | Mozgás az ablaktáblák között |
| `Ctrl + Alt + Shift + Arrows` | Ablaktáblák átméretezése |

### Ablakok

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + c` | Új ablak |
| `Prefix + k` | Ablak bezárása |
| `Prefix + r` | Ablak átnevezése |
| `Alt + 1-9` | Ugrás egy adott ablakra |
| `Alt + Arrow Left/Right` | Mozgás az ablakok között |
| `Alt + Shift + Arrow Left/Right` | Ablak mozgatása balra/jobbra |

### Munkamenetek

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + C` | Új munkamenet |
| `Prefix + K` | Munkamenet megszüntetése |
| `Prefix + R` | Munkamenet átnevezése |
| `Prefix + N` | Következő munkamenet |
| `Prefix + P` | Előző munkamenet |
| `Alt + Arrow Up/Down` | Mozgás a munkamenetek között |
| `Prefix + s` | Munkamenetek listázása |
| `Prefix + d` | Leválás a munkamenetről |

### Másolás mód (vi-stílusú)

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + [` | Belépés másolás módba |
| `v` | Kijelölés megkezdése (másolás módban) |
| `y` | Kijelölés másolása (másolás módban) |

### Általános

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguráció újratöltése |
| `Prefix + ?` | Tmux billentyűkiosztások megjelenítése |
| `Prefix + :` | Parancssor |

### Tmux elrendezési függvények

Ezeket a függvényeket egy Tmux munkameneten belül kell futtatni.

| Parancs | Funkció |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása szerkesztővel, AI-val és terminállal |
| `tdlm <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása alkönyvtáranként |
| `tsl <count> <command>` | Több ablaktáblás swarm elrendezés létrehozása |

## Ghostty terminál

A Ghostty terminál az Omarchy menü _Install > Terminal_ pontján keresztül telepíthető.

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Új felosztás alul |
| `Ctrl + Shift + O` | Új felosztás mellette |
| `Ctrl + Alt + Arrows` | Mozgás a felosztások között |
| `Super + Ctrl + Shift + Arrows` | Felosztás átméretezése 10 sorral |
| `Super + Ctrl + Shift + Alt + Arrows` | Felosztás átméretezése 100 sorral |
| `Ctrl + Shift + T` | Új lap  |
| `Ctrl + Shift + Arrows` | Mozgás a lapok között |
| `Alt + Numbers` | Ugrás egy adott lapra |
| `Shift + Pg Up/Down` | Az előzmények görgetése |
| `Ctrl + Left mouse` | Hivatkozás megnyitása a böngészőben |

## Fájlkezelő

| Gyorsbillentyű              | Funkció                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ugrás egy útvonalra                     |
| `Space`               | Fájl előnézete (a nyilakkal navigálhatsz) |
| `Alt + Up`       | Fel a szülőmappába        |

## Neovim (LazyVimmel)

### Navigálás

| Gyorsbillentyű                   | Funkció                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Parancslehetőségek megjelenítése            |
| `Space Space`              | Fájl megnyitása fuzzy kereséssel      |
| `Space E`                  | Oldalsáv váltása                  |
| `Space G G`                | Git vezérlők megjelenítése               |
| `Space S G`                | Keresés a fájl tartalmában             |
| `Ctrl + W W`               | Ugrás az oldalsáv és a szerkesztő között |
| `Ctrl + Left/right arrow`  | Az oldalsáv méretének módosítása          |
| `Shift + H`                      | Ugrás a bal oldali fájllapra             |
| `Shift + L`                      | Ugrás a jobb oldali fájllapra            |
| `Space B D`                | Fájllap bezárása                  |

### Az oldalsávban

| Gyorsbillentyű                   | Funkció                        |
| ------------------------ | ------------------------------- |
| `A`                        | Új fájl hozzáadása a szülőkönyvtárban      |
| `Shift + A`                | Új alkönyvtár hozzáadása a szülőkönyvtárban    |
| `D`                        | A kiemelt fájl/könyvtár törlése     |
| `M`                        | A kiemelt fájl/könyvtár áthelyezése       |
| `R`                        | A kiemelt fájl/könyvtár átnevezése     |
| `?`                        | Súgó megjelenítése az összes parancshoz      |

[Nézd meg a LazyVim által beállított összes Neovim gyorsbillentyűt](https://www.lazyvim.org/keymaps).

## Gyors emojik

A `Super + Ctrl + E` billentyűvel megjeleníthetsz egy teljes emoji-választót, amely a kiválasztott elemet a vágólapra teszi, vagy használhatod ezeket a gyors elérési lehetőségeket.

| Gyorsbillentyű       | EM | Tipp       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smile      |
| `Shift + CapsLock M C` | 😂 | cry        |
| `Shift + CapsLock M L` | 😍 | love       |
| `Shift + CapsLock M V` | ✌️ | victory    |
| `Shift + CapsLock M H` | ❤️ | heart      |
| `Shift + CapsLock M Y` | 👍 | yes        |
| `Shift + CapsLock M N` | 👎 | no         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | wish       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | kiss       |
| `Shift + CapsLock M E` | 🙄 | eyeroll    |
| `Shift + CapsLock M I` | 😉 | wink       |
| `Shift + CapsLock M P` | 🙏 | pray |
| `Shift + CapsLock M D` | 🤤 | drool      |
| `Shift + CapsLock M M` | 💰 | money      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | greeting |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blowing |

## Gyors kiegészítések

| Gyorsbillentyű       | Kiegészítés       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | A neved (ahogy a beállításkor megadtad)  |
| `Shift + CapsLock Space E` | Az e-mail-címed (ahogy a beállításkor megadtad)  |

További sajátokat is hozzáadhatsz a `~/.XCompose` szerkesztésével, majd futtasd a terminálban az `omarchy restart xcompose` parancsot, hogy a változások érvénybe lépjenek.
