# Gyorsbillentyűk

Minden fontos billentyűkombinációt megtekinthetsz a `Super + K` billentyűkombinációval (a Tmux kötéseket a `Super + Alt + K`, a Herdr kötéseket a `Super + Ctrl + K` billentyűkombinációval).

## Hogyan épülnek fel a gyorsbillentyűk

Minden gyorsbillentyű egy síkon helyezkedik el, amelyet a módosítói határoznak meg, és minden síknak egy feladata van. Ettől nem mosódnak össze a gyorsbillentyűk, és általában ki is tudod találni, hová tartozik valami.

| Sík | Mi tartozik ide | Példák |
| --- | --- | --- |
| `Super + key` | A rendszer: ablakok, munkaterületek, elrendezések és alapvető menük | `Super + Space` Omarchy menü, `Super + W` ablak bezárása, `Super + F` teljes képernyő |
| `Super + Shift + key` | Alkalmazások | `Super + Shift + B` böngésző, `Super + Shift + E` e-mail, `Super + Shift + N` szerkesztő |
| `Super + Ctrl + key` | Panelek és rendszermenük | `Super + Ctrl + A` hang, `Super + Ctrl + N` hálózat, `Super + Ctrl + C` rögzítés menü |
| `Super + Ctrl + Alt + key` | Gyorsműveletek és értesítések | `Super + Ctrl + Alt + T` idő megjelenítése, `Super + Ctrl + Alt + B` akkumulátor, `Super + Ctrl + Alt + C` képernyőkép |

Ha egy gyorsbillentyűhöz hozzáadod az `Alt` billentyűt, ugyanannak a dolognak egy változatát kapod, sosem valami teljesen mást:

- A `Super + Shift + B` megnyitja a böngészőt; a `Super + Shift + Alt + B` privát ablakot nyit
- A `Super + Shift + E` megnyitja az e-mailt; a `Super + Shift + Alt + E` újat kezd
- A `Super + F` teljes képernyőre vált; a `Super + Alt + F` teljes szélességre vált
- A `Super + Ctrl + C` megnyitja a rögzítés menüt; a `Super + Ctrl + Alt + C` kihagyja a menüt, és képernyőképet készít

Gyorsbillentyű hozzáadásakor:

1. Válaszd ki a síkot abból, amit csinál, majd válaszd ki a billentyűt.
2. Ne mozdíts el egy meglévő gyorsbillentyűt, hogy helyet csinálj. Keress egy szabad billentyűt a megfelelő síkon.
3. Az `Alt` billentyűt csak az nélküle használt gyorsbillentyű változatához használd.

Néhány gyorsbillentyű kényelmi okokból megszegi ezeket a szabályokat. A `Shift` nyíllal vagy `Tab` billentyűvel mozgat vagy visszafordít, ahelyett, hogy alkalmazást nyitna, a `Print`, a médiabillentyűk, az `Alt + Tab` és a `Ctrl + Alt + Del` pedig úgy működnek, mint mindenhol máshol. Ezek kivételek, nem másolandó minták.

Ha egy alapértelmezés nem felel meg neked (mondjuk a `Super + Shift + S` billentyűkombinációt szeretnéd képernyőképekhez, mint Windowson), kösd újra a `~/.config/hypr/bindings.lua` fájlban.

## Navigálás

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menü (alkalmazások és minden más)    |
| `Super + Alt + Space` | Alkalmazásrács |
| `Super + Escape` | Rendszermenü (felfüggesztés, újraindítás stb.)  |
| `Super + Ctrl + L` | Számítógép zárolása |
| `Super + W` vagy `Super + Q` | Ablak bezárása             |
| `Ctrl + Alt + Del` | Minden ablak bezárása |
| `Super + K` | Minden gyorsbillentyű megjelenítése |
| `Super + Alt + K` | tmux gyorsbillentyűk megjelenítése |
| `Super + Ctrl + K` | herdr gyorsbillentyűk megjelenítése |
| `Super + M` | Ablak minimalizálása a dokkra |
| `Super + T`               | Ablak váltása csempézett/lebegő mód között             |
| `Super + J` | Ablak pozíciójának váltása (vízszintes/függőleges) |
| `Super + O`               | Ablak sticky'n'floating módba ugrasztásának váltása |
| `Super + L`               | Léptetés a dwindle, scrolling és floating elrendezések között |
| `Super + Alt + L`         | Léptetés az elrendezések között visszafelé |
| `Super + P`               | Ál-ablakstílus váltása (természetes / nyújtott) |
| `Super + F`                 | Teljes képernyő              |
| `Super + Alt + F`                 | Teljes szélesség              |
| `Super + Ctrl + F`                 | Teljes képernyő az ablakon belül              |
| `Super + 1…9/0`         | Ugrás egy adott munkaterületre (a 0 a 10-es) a fókuszált monitoron |
| `Super + Tab` | Ugrás a következő munkaterületre a fókuszált monitoron |
| `Super + Shift + Tab` | Ugrás az előző munkaterületre a fókuszált monitoron |
| `Super + Ctrl + Tab` | Ugrás a korábbi munkaterületre a fókuszált monitoron |
| `Super + Shift + 1…9/0` | Ablak áthelyezése munkaterületre a fókuszált monitoron |
| `Super + Shift + Alt + 1…9/0` | Ablak áthelyezése munkaterületre a fókuszált monitoron követés nélkül |
| `Super + S` | Teljes scratchpad váltása |
| `Super + Alt + S` | Ablak áthelyezése a teljes scratchpadre |
| `Super + the key above Tab` (grave on US layouts) | Quake konzol váltása |
| `Super + Shift + the key above Tab` (grave on US layouts) | Ablak áthelyezése a Quake konzolra |
| `Super + Shift + Ctrl + Arrows` | Ablak áthelyezése az adott irányban lévő monitorra |
| `Super + Shift + Alt + Arrows` | Munkaterület áthelyezése az adott irányban lévő monitorra |
| `Super + Arrow`  | Fókusz mozgatása a nyíl irányában lévő ablakra, a képernyő szélén átlépve az azon az oldalon lévő monitorra |
| `Super + Shift + Arrow`  | Ablak cseréje a nyíl irányában lévő másik ablakkal, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Minus` | Ablak szélesítése balra |
| `Super + Equal` | Ablak keskenyítése balra |
| `Super + Shift + Minus` | Ablak zsugorítása felfelé |
| `Super + Shift + Equal` | Ablak bővítése lefelé |
| `Super + Alt + Minus/Equal` | Ugyanaz az átméretezés kisebb lépésekben |
| `Super + Ctrl + Minus/Equal` | Ugyanaz az átméretezés nagyobb lépésekben |
| `Super + Alt + Home` | Ablak szélességének mentése |
| `Super + Home` | Mentett ablakszélesség visszaállítása |
| `Super + Left Mouse` | Ablak húzása |
| `Super + Right Mouse` | Ablak átméretezése |
| `Super + Scroll Wheel` | Léptetés a munkaterületek között a fókuszált monitoron |
| `Super + G`               | Ablakcsoportosítás váltása      |
| `Super + Alt + G`               | Ablak kivétele a csoportból      |
| `Super + Alt + Tab`               | Léptetés a csoport ablakai között      |
| `Super + Alt + Shift + Tab`               | Léptetés visszafelé a csoport ablakai között      |
| `Super + Alt + Scroll Wheel` | Léptetés a csoport ablakai között |
| `Super + Alt + 1/2/3/4/5`               | Ugrás egy adott ablakra a csoportban      |
| `Super + Alt + Arrow`  | Ablak bevitele a csoportba a nyíl irányában, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Ctrl + Left/Right`  | Mozgás a csempézett csoport ablakai között |
| `Super + Ctrl + Z` | Nagyítás a képernyőn (ismételd a további nagyításhoz) |
| `Super + Ctrl + Alt + Z` | Teljes kicsinyítés a képernyőről |
| `Super + /` | Léptetés előre a monitor méretezési lehetőségei között |
| `Super + Alt + /` | Léptetés visszafelé a monitor méretezési lehetőségei között |
| `Alt + Tab` | Léptetés előre az aktív munkaterület ablakai között |
| `Alt + Shift + Tab` | Léptetés visszafelé az aktív munkaterület ablakai között |
| `Ctrl + Alt + Tab`| Fókusz léptetése előre a monitorok között |
| `Ctrl + Alt + Shift + Tab`| Fókusz léptetése visszafelé a monitorok között |
| `Super + I` | Beviteli nyelv váltása (egynél több elrendezés vagy beviteli mód esetén) |
| `Super + Shift + I` | Beviteli nyelv visszaváltása |

Érintőpadon a három- és négyujjas legyintések munkaterületeket váltanak, ablakokat mozgatnak, és megnyitják a menüt és a Quake konzolt; a gesztusokat lásd itt: [billentyűzet, egér és érintőpad](34-keyboard-mouse-trackpad.md).

Az átméretezés a 0-tól jobbra lévő két billentyűt használja, bármit is nyomtattak rájuk a billentyűzeteden: `-` és `=` az amerikai billentyűzeteken, `+` és `´` a dán és svéd billentyűzeteken, `+` és `\` a norvégon, `ß` és `´` a németen, `'` és `¡` a spanyolon, és `-` és `^` a japánon (JIS). A `Super + K` úgy sorolja fel őket, ahogyan a billentyűzeteden szerepelnek. JIS-en a `Super + ^` a `Super + Equal`, míg a `Super + Shift + -` (amely `=` jelet ír) a `Super + Shift + Minus`. A monitor méretezése és a jelszókezelő a `/` billentyűt használja; azokon az elrendezéseken, amelyek a `/` jelet csak Shift-tel írják, mint a legtöbb európai, ehelyett a jobb Shift-től balra lévő billentyűt használják (`-` dán és német elrendezésen).

## Rendszervezérlők

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Hangpanel    |
| `Super + Ctrl + B`           | Bluetooth panel    |
| `Super + Ctrl + N`           | Wi-Fi/hálózati panel    |
| `Super + Ctrl + D`           | Kijelzőpanel    |
| `Super + Ctrl + P`           | Energiapanel    |
| `Super + Ctrl + X`           | Ágensek panelja    |
| `Super + Ctrl + Alt + D`           | Naptárpanel    |
| `Super + Ctrl + Alt + E`           | Világóra panel    |
| `Super + Ctrl + 1-9`           | Sávpanel váltása pozíció szerint    |
| `Super + Ctrl + S` | Megosztás menü (LocalSend segítségével) |
| `Super + Ctrl + C` | Rögzítésvezérlők (képernyőkép/-felvétel/választó) |
| `Super + Ctrl + O` | Menü váltása |
| `Super + Ctrl + H` | Hardver menü |
| `Super + Ctrl + E` | Emoji-választó |
| `Super + Ctrl + .` | Média átkódolása |
| `Super + Shift + Ctrl + A` | Alapértelmezett ágensed indítása |
| `Power` key | Rendszermenü |
| `Super + Shift + Copilot` key | Omarchy menü |

## Beállítások

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximális képernyő-fényerő |
| `Shift + Brightness Down` | Minimális képernyő-fényerő |
| `Alt + Brightness Up/Down` | Pontos, 1%-os fényerő-változtatások |
| `Alt + Volume Up/Down` | Pontos, 1%-os hangerő-változtatások |
| `Keyboard Brightness Up/Down` | Billentyűzet-háttérvilágítás erősebb/gyengébb |
| `Keyboard Backlight` | Léptetés a billentyűzet-háttérvilágítás szintjei között |
| `Ctrl + Brightness Up/Down` | Billentyűzet-háttérvilágítás erősebb/gyengébb, saját billentyűk nélküli billentyűzeteken |
| `Mic Mute` | Mikrofon némítása |
| `Shift + Mute` | Hangkimenet váltása |
| `Touchpad Toggle` | Érintőpad be- vagy kikapcsolása |
| `Display` key | Munkaterület-elrendezés léptetése |
| `Alt + Play` | Következő szám |
| `Alt + Shift + Play` | Előző szám |

## Alkalmazások indítása

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminál    |
| `Super + Alt + Return` | Tmux terminál |
| `Super + Ctrl + Return` | Herdr (ágenskezelő) |
| `Super + Shift + Return` vagy `Super + Shift + B`  | Böngésző    |
| `Super + Shift + Alt + B`           | Böngésző (privát/inkognitó)    |
| `Super + Shift + F`           | Fájlkezelő    |
| `Super + Shift + Alt + F`           | Fájlkezelő a terminál cwd könyvtárában    |
| `Super + Shift + M`           | Zene (Spotify)    |
| `Super + Shift + Alt + M`           | Zene (cliamp)    |
| `Super + Shift + /`           | Jelszókezelő (1password)    |
| `Super + Shift + Q` vagy `Calculator` key  | Számológép (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, telepítés után)    |
| `Super + Shift + T`           | Aktivitás (btop)    |
| `Super + Shift + N`           | Szerkesztő (Plain, vagy a választott alapértelmezésed)  |
| `Super + Shift + C`           | Naptár ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Új e-mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Az alapértelmezett ágensed, vagy ChatGPT, amíg nem választasz egyet |
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

Módosítsd/adj hozzá kötéseket a `~/.config/hypr/bindings.lua` fájlban.

## Univerzális vágólap

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + A`           | Mind kijelölése azokban az alkalmazásokban, amelyek támogatják a `Ctrl + A` billentyűkombinációt    |
| `Super + C`           | Másolás    |
| `Super + X`           | Kivágás (terminálban nem)    |
| `Super + V`           | Beillesztés    |
| `Super + Ctrl + V`           | Vágólapkezelő    |

Linuxon általában `Ctrl + Shift + C/V` kell a másoláshoz/beillesztéshez a terminálban, és `Ctrl + C/V` mindenhol máshol. Ezek az Omarchy egységes vágólap-gyorsbillentyűi mindenhol működnek.

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
| `Super + Alt + [` | Webkamera-réteg kicsinyítése felvétel közben |
| `Super + Alt + ]` | Webkamera-réteg nagyítása felvétel közben |
| `Alt + Shift + L` | Aktuális URL másolása webalkalmazásból vagy böngészőből |
| `Alt + Shift + D` | Az aktuális oldalon lévő videó letöltése a `~/Videos` mappába |
| `Alt + Space` | Diktálás indítása/leállítása (szükséges: _Setup > Defaults > Dictation_) |
| `Right Alt` | Tartsd nyomva a diktáláshoz (szükséges: _Setup > Defaults > Dictation_) |

Képernyőfelvételeknél a gyorsbillentyű először megkérdezi, milyen hangot szeretnél, majd elindítja a felvételt. Nyomd meg újra a leállításhoz. A részleteket lásd itt: [képernyőképek és felvétel](12-screenshots-recording.md).

Minden rögzítési lehetőség elérhető az Omarchy menü (`Super + Space`) _Trigger > Capture_ pontja alatt is.

## Értesítések

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + ,` | Művelet a legutóbbi értesítésen: megnyitja, vagy megnyomja az egyetlen gombját, választ a lehetőségei közül, vagy elveti, ha egy sincs  |
| `Super + Shift + ,` | Minden értesítés elvetése |
| `Super + Ctrl + ,` | Értesítések vezérlése a billentyűzettel  |
| `Super + Alt + ,` | Legutóbbi értesítés elvetése  |
| `Super + Shift + Alt + ,` | Értesítési előzmények megnyitása  |
| `Super + Ctrl + Alt + ,` | Értesítések némításának váltása  |

## Stílus

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Új téma választása (szintén `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Témaháttér választása (szintén `Super + Ctrl + Space`) |
| `Super + Backspace` | Átlátszóság váltása egy ablakon |
| `Super + Ctrl + Backspace` | Egyablakos négyzetes képarány váltása |

A további háttérképek a `~/.config/omarchy/backgrounds/<theme name>` mappában találhatók. Elérhető az Omarchy menü _Install > Style > Background_ pontja alatt is.

Minden stíluslehetőség elérhető az Omarchy menü (`Super + Space`) _Appearance_ pontja alatt is.

## Kapcsolók

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Zárolás tétlenség esetén váltása |
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
| `Super + Ctrl + Alt + R` | Minden emlékeztető megtekintése  |
| `Super + Ctrl + Shift + R` | Minden emlékeztető törlése  |

## Közlemények

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Idő megjelenítése értesítésként  |
| `Super + Ctrl + Alt + B` | Akkumulátor megjelenítése értesítésként  |
| `Super + Ctrl + Alt + W` | Időjárás értesítésként megjelenítésének váltása  |

## Tmux

Az előtagbillentyű a `Ctrl + Space` (a `Ctrl + B` is működik). Ezeket a kötéseket a `~/.config/tmux/tmux.conf` fájlban módosíthatod.

### Panelek

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + v` | Panel felosztása mellé (függőleges) |
| `Prefix + h` | Panel felosztása alá (vízszintes) |
| `Prefix + x` | Panel lezárása |
| `Prefix + z` | Panel nagyításának váltása (teljes képernyő) |
| `Alt + Enter` | Panel felosztása alá (előtag nélkül) |
| `Alt + Shift + Enter` | Panel felosztása mellé (előtag nélkül) |
| `Alt + Escape` | Panel lezárása (előtag nélkül) |
| `Ctrl + Alt + Arrows` | Mozgás a panelek között |
| `Ctrl + Alt + Shift + Arrows` | Panelek átméretezése |

### Ablakok

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + c` | Új ablak |
| `Prefix + k` | Ablak lezárása |
| `Prefix + r` | Ablak átnevezése |
| `Alt + 1-9` | Ugrás egy adott ablakra |
| `Alt + Arrow Left/Right` | Mozgás az ablakok között |
| `Alt + Shift + Arrow Left/Right` | Ablak mozgatása balra/jobbra |

### Munkamenetek

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + C` | Új munkamenet |
| `Prefix + K` | Munkamenet lezárása |
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
| `Prefix + ?` | Tmux billentyűkötések megjelenítése |
| `Prefix + :` | Parancssor |

### Tmux elrendezési függvények

Ezeket a függvényeket Tmux munkameneten belül kell futtatni.

| Parancs | Funkció |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása szerkesztővel, AI-val és terminállal |
| `tdlm <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása alkönyvtáranként |
| `tsl <count> <command>` | Többpaneles raj elrendezés létrehozása |

## Ghostty terminál

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
| `Ctrl + Left mouse` | Hivatkozás megnyitása a böngészőben |

## Fájlkezelő

| Gyorsbillentyű              | Funkció                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ugrás egy útvonalra                     |
| `Space`               | Fájl előnézete (a nyilakkal navigálhatsz) |
| `Alt + Up`       | Fel a szülőmappába        |

## Neovim (w/ lazyvim)

### Navigálás

| Gyorsbillentyű                   | Funkció                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Parancslehetőségek megjelenítése            |
| `Space Space`              | Fájl megnyitása fuzzy kereséssel      |
| `Space E`                  | Oldalsáv váltása                  |
| `Space G G`                | git vezérlők megjelenítése               |
| `Space S G`                | Keresés a fájl tartalmában             |
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
| `?`                        | Súgó megjelenítése minden parancshoz      |

[Tekintsd meg a LazyVim által beállított összes Neovim gyorsbillentyűt](https://www.lazyvim.org/keymaps).

## Gyors emojik

A `Super + Ctrl + E` billentyűkombinációval megjeleníthetsz egy teljes emoji-választót, amely a kijelölést a vágólapra helyezi, vagy használhatod ezeket a gyorselérési lehetőségeket.

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
| `Shift + CapsLock M G` |👋 | üdvözlés |
| `Shift + CapsLock M A` |💪 | kar |
| `Shift + CapsLock M B` |🤯 | fejrobbanás |

## Gyors kiegészítések

| Gyorsbillentyű       | Kiegészítés       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (gondolatjel)   |
| `Shift + CapsLock Space N` | A neved (ahogy a beállításkor megadtad)  |
| `Shift + CapsLock Space E` | Az e-mail címed (ahogy a beállításkor megadtad)  |

További sajátokat adhatsz hozzá a `~/.XCompose` szerkesztésével, majd futtasd az `omarchy restart xcompose` parancsot a terminálban, hogy a változások érvénybe lépjenek.
