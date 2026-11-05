# Gyorsbillentyűk

Minden fő billentyűkombinációt megnézhetsz a `Super + K` segítségével (a Tmux kötéseket a `Super + Alt + K`, a Herdr kötéseket pedig a `Super + Ctrl + K` segítségével).

## Hogyan épülnek fel a gyorsbillentyűk

Minden gyorsbillentyű egy síkon helyezkedik el, amelyet a módosítói határoznak meg, és minden síknak egy feladata van. Ez tartja távol attól, hogy a gyorsbillentyűk összemosódjanak, és azt jelenti, hogy általában ki tudod találni, hol található valami.

| Sík | Mi tartozik ide | Példák |
| --- | --- | --- |
| `Super + key` | A rendszer: ablakok, munkaterületek, elrendezések és alapmenük | `Super + Space` Omarchy menü, `Super + W` ablak bezárása, `Super + F` teljes képernyő |
| `Super + Shift + key` | Alkalmazások | `Super + Shift + B` böngésző, `Super + Shift + E` e-mail, `Super + Shift + N` szerkesztő |
| `Super + Ctrl + key` | Panelek és rendszermenük | `Super + Ctrl + A` hang, `Super + Ctrl + N` hálózat, `Super + Ctrl + C` rögzítés menü |
| `Super + Ctrl + Alt + key` | Gyors műveletek és értesítések | `Super + Ctrl + Alt + T` idő megjelenítése, `Super + Ctrl + Alt + B` akkumulátor, `Super + Ctrl + Alt + C` képernyőkép |

Ha egy gyorsbillentyűhöz hozzáadod az `Alt` billentyűt, ugyanannak a dolognak egy változatát kapod, sosem valami teljesen mást:

- A `Super + Shift + B` megnyitja a böngészőt; a `Super + Shift + Alt + B` privát ablakot nyit
- A `Super + Shift + E` megnyitja az e-mailt; a `Super + Shift + Alt + E` újat indít
- A `Super + F` teljes képernyőre vált; a `Super + Alt + F` teljes szélességre vált
- A `Super + Ctrl + C` megnyitja a rögzítés menüt; a `Super + Ctrl + Alt + C` kihagyja a menüt és képernyőképet készít

Gyorsbillentyű hozzáadásakor:

1. Válaszd ki a síkot abból, amit csinál, majd válaszd ki a billentyűt.
2. Ne mozgass át egy meglévő gyorsbillentyűt, hogy helyet csinálj. Keress szabad billentyűt a megfelelő síkon.
3. Az `Alt` billentyűt csak az nélküle használt gyorsbillentyű változatához használd.

Néhány gyorsbillentyű kényelmi okból megszegi ezeket a szabályokat. A `Shift` egy nyíllal vagy `Tab` billentyűvel mozgat vagy visszafordít ahelyett, hogy alkalmazást nyitna, a `Print`, a médiabillentyűk, az `Alt + Tab` és a `Ctrl + Alt + Del` pedig ugyanúgy működnek, mint mindenhol máshol. Ezek kivételek, nem másolandó minták.

Ha egy alapértelmezett nem felel meg neked (mondjuk a `Super + Shift + S` billentyűt szeretnéd képernyőképekhez, mint Windowson), kösd újra a `~/.config/hypr/bindings.lua` fájlban.

## Navigáció

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menü (alkalmazások és minden más)    |
| `Super + Alt + Space` | Alkalmazásrács |
| `Super + Escape` | Rendszermenü (felfüggesztés, újraindítás stb.)  |
| `Super + Ctrl + L` | Számítógép zárolása |
| `Super + W` vagy `Super + Q` | Ablak bezárása             |
| `Ctrl + Alt + Del` | Minden ablak bezárása |
| `Super + T`               | Ablak váltása csempézett/lebegő között             |
| `Super + J` | Ablakpozíció váltása (vízszintes/függőleges) |
| `Super + O`               | Ablak váltása rögzített és lebegő állapotba |
| `Super + L`               | Váltás a dwindle, scrolling és floating elrendezések között |
| `Super + Alt + L`         | Elrendezések váltása fordított sorrendben |
| `Super + P`               | Pszeudo ablakstílus váltása (természetes / nyújtott) |
| `Super + F`                 | Teljes képernyő              |
| `Super + Alt + F`                 | Teljes szélesség              |
| `Super + Ctrl + F`                 | Teljes képernyő az ablakon belül              |
| `Super + 1/2/3/4`         | Ugrás adott munkaterületre a fókuszált monitoron |
| `Super + Tab` | Ugrás a következő munkaterületre a fókuszált monitoron |
| `Super + Shift + Tab` | Ugrás az előző munkaterületre a fókuszált monitoron |
| `Super + Ctrl + Tab` | Ugrás a korábbi munkaterületre a fókuszált monitoron |
| `Super + Shift + 1/2/3/4` | Ablak áthelyezése munkaterületre a fókuszált monitoron |
| `Super + Shift + Alt + 1/2/3/4` | Ablak áthelyezése munkaterületre a fókuszált monitoron követés nélkül |
| `Super + S` | Teljes scratchpad ki-/bekapcsolása |
| `Super + Alt + S` | Ablak áthelyezése a teljes scratchpadra |
| `Super + Grave` | Quake konzol ki-/bekapcsolása |
| `Super + Shift + Grave` | Ablak áthelyezése a Quake konzolba |
| `Super + Shift + Ctrl + Arrows` | Ablak áthelyezése az adott irányban lévő monitorra |
| `Super + Shift + Alt + Arrows` | Munkaterület áthelyezése az adott irányban lévő monitorra |
| `Super + Arrow`  | Fókusz áthelyezése a nyíl irányában lévő ablakra, a képernyő szélén átlépve az azon az oldalon lévő monitorra |
| `Super + Shift + Arrow`  | Ablak felcserélése a nyíl irányában lévő másik ablakkal, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Minus` | Ablak szélesítése balra |
| `Super + Equal` | Ablak keskenyítése balra |
| `Super + Shift + Minus` | Ablak kicsinyítése felfelé |
| `Super + Shift + Equal` | Ablak nagyítása lefelé |
| `Super + Alt + Minus/Equal` | Ugyanaz az átméretezés kisebb lépésekben |
| `Super + Ctrl + Minus/Equal` | Ugyanaz az átméretezés nagyobb lépésekben |
| `Super + Alt + Home` | Ablakszélesség mentése |
| `Super + Home` | Mentett ablakszélesség visszaállítása |
| `Super + Left Mouse` | Ablak húzása |
| `Super + Right Mouse` | Ablak átméretezése |
| `Super + Scroll Wheel` | Munkaterületek görgetése a fókuszált monitoron |
| `Super + G`               | Ablakcsoportosítás ki-/bekapcsolása      |
| `Super + Alt + G`               | Ablak kivétele a csoportból      |
| `Super + Alt + Tab`               | Váltás a csoportban lévő ablakok között      |
| `Super + Alt + Shift + Tab`               | Váltás visszafelé a csoportban lévő ablakok között      |
| `Super + Alt + Scroll Wheel` | Váltás a csoportban lévő ablakok között |
| `Super + Alt + 1/2/3/4/5`               | Ugrás adott ablakra a csoportban      |
| `Super + Alt + Arrow`  | Ablak bevitele a csoportba a nyíl irányában, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Ctrl + Left/Right`  | Mozgás a csempézett csoporton belüli ablakok között |
| `Super + Ctrl + Z` | Nagyítás a képernyőn (ismételve még nagyobb) |
| `Super + Ctrl + Alt + Z` | Teljes kicsinyítés a képernyőről |
| `Super + /` | Léptetés előre a monitor méretezési lehetőségei között |
| `Super + Alt + /` | Léptetés hátra a monitor méretezési lehetőségei között |
| `Alt + Tab` | Váltás előre az aktív munkaterület ablakai között |
| `Alt + Shift + Tab` | Váltás hátra az aktív munkaterület ablakai között |
| `Ctrl + Alt + Tab`| Fókusz léptetése előre a monitorok között |
| `Ctrl + Alt + Shift + Tab`| Fókusz léptetése hátra a monitorok között |

Az átméretező gyorsbillentyűk a fizikai `code:20` és `code:21` billentyűket használják (XKB `<AE11>` és `<AE12>`), függetlenül a billentyűkre nyomtatott karakterektől. US billentyűzeteken ezek a billentyűk a `-` és `=`; japán (JIS) billentyűzeteken a `-` és `^`; spanyol billentyűzeteken a `'` és `¡`. JIS esetén a `Super + ^` a `Super + Equal`, míg a `Super + Shift + -` (ami `=`-t ír) a `Super + Shift + Minus`.

## Rendszervezérlők

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Hangpanel    |
| `Super + Ctrl + B`           | Bluetooth panel    |
| `Super + Ctrl + N`           | Wi-Fi/hálózati panel    |
| `Super + Ctrl + D`           | Kijelzőpanel    |
| `Super + Ctrl + P`           | Energiapanel    |
| `Super + Ctrl + Alt + D`           | Naptárpanel    |
| `Super + Ctrl + Alt + E`           | Világóra panel    |
| `Super + Ctrl + 1-9`           | Sávpanel ki-/bekapcsolása pozíció szerint    |
| `Super + Ctrl + S` | Megosztás menü (LocalSend segítségével) |
| `Super + Ctrl + C` | Rögzítésvezérlők (képernyőkép/-felvétel/választó) |
| `Super + Ctrl + O` | Kapcsolómenü |
| `Super + Ctrl + H` | Hardvermenü |
| `Super + Ctrl + E` | Emoji-választó |
| `Super + Ctrl + .` | Média átkódolása |
| `Super + Shift + Ctrl + A` | AI agent kiválasztása |

## Finombeállítások

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximális képernyőfényerő |
| `Shift + Brightness Down` | Minimális képernyőfényerő |
| `Alt + Brightness Up/Down` | Pontos, 1%-os fényerő változtatások |
| `Alt + Volume Up/Down` | Pontos, 1%-os hangerő változtatások |
| `Keyboard Brightness Up/Down` | Billentyűzet háttérvilágítása erősebb/gyengébb |
| `Keyboard Backlight` | Billentyűzet háttérvilágítási szintjeinek váltása |
| `Alt + Play` | Következő szám |
| `Alt + Shift + Play` | Előző szám |

## Alkalmazások indítása

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminál    |
| `Super + Alt + Return` | Tmux terminál |
| `Super + Ctrl + Return` | Herdr (agentkezelő) |
| `Super + Shift + Return`           | Böngésző    |
| `Super + Shift + Alt + B`           | Böngésző (privát/inkognitó)    |
| `Super + Shift + F`           | Fájlkezelő    |
| `Super + Shift + Alt + F`           | Fájlkezelő a terminál cwd könyvtárában    |
| `Super + Shift + M`           | Zene (Spotify)    |
| `Super + Shift + Alt + M`           | Zene (cliamp)    |
| `Super + Shift + /`           | Jelszókezelő (1password)    |
| `Super + Shift + Q`           | Számológép (Omacalc)    |
| `Super + Shift + T`           | Aktivitás (btop)    |
| `Super + Shift + N`           | Szerkesztő (Neovim)  |
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
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Módosíts / adj hozzá kötéseket a `~/.config/hypr/bindings.lua` fájlban.

## Univerzális vágólap

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + A`           | Mind kijelölése azokban az alkalmazásokban, amelyek támogatják a `Ctrl + A` kombinációt    |
| `Super + C`           | Másolás    |
| `Super + X`           | Kivágás (terminálban nem)    |
| `Super + V`           | Beillesztés    |
| `Super + Ctrl + V`           | Vágólapkezelő    |

Linuxon általában `Ctrl + Shift + C/V` kell a másoláshoz és beillesztéshez a terminálban, és `Ctrl + C/V` mindenhol máshol. Ezek az egységes Omarchy vágólapos gyorsbillentyűk mindenhol működnek.

## Rögzítés

| Gyorsbillentyű              | Funkció                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Képernyőkép                      |
| `Super + Ctrl + Alt + C`            | Képernyőkép (ugyanaz a felvétel, Print Screen billentyű nélküli billentyűzetekhez) |
| `Super + Ctrl + C` | Rögzítés menü |
| `Alt + Print Screen`            | Képernyőfelvétel                     |
| `Super + Print Screen` | Színválasztó |
| `Super + Ctrl + Print Screen` | Szöveg kinyerése a vágólapra |
| `Super + Alt + [` | Webkamera átfedés kisebbé tétele felvétel közben |
| `Super + Alt + ]` | Webkamera átfedés nagyobbá tétele felvétel közben |
| `Alt + Shift + L` | Aktuális URL másolása webappból vagy Chromiumból |
| `Alt + Shift + D` | Az aktuális oldalon lévő videó letöltése a `~/Videos` mappába |
| `Alt + Space` | Diktálás indítása/leállítása (szükséges hozzá a _Setup > Defaults > Dictation_) |
| `Right Alt` | Tartsd nyomva a diktáláshoz (szükséges hozzá a _Setup > Defaults > Dictation_) |

Képernyőfelvételeknél a gyorsbillentyű először megkérdezi, melyik hangot szeretnéd, majd elindítja a felvételt. Nyomd meg újra a leállításhoz. A részletekért lásd: [képernyőképek és felvétel](12-screenshots-recording.md).

Minden rögzítési lehetőség elérhető az Omarchy menü (`Super + Space`) _Trigger > Capture_ pontja alatt is.

## Értesítések

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + ,` | Művelet a legutóbbi értesítésen: megnyitja, vagy megnyomja az egyetlen gombját, választ a lehetőségei közül, vagy elveti, ha egy sincs  |
| `Super + Shift + ,` | Minden értesítés elvetése |
| `Super + Ctrl + ,` | Értesítések vezérlése billentyűzettel  |
| `Super + Alt + ,` | Legutóbbi értesítés elvetése  |
| `Super + Shift + Alt + ,` | Értesítési előzmények megnyitása  |
| `Super + Ctrl + Alt + ,` | Értesítések némításának ki-/bekapcsolása  |

## Stílus

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Új téma kiválasztása (szintén `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Téma hátterének kiválasztása (szintén `Super + Ctrl + Space`) |
| `Super + Backspace` | Átlátszóság ki-/bekapcsolása egy ablakon |
| `Super + Ctrl + Backspace` | Egyablakos négyzetes képarány ki-/bekapcsolása |

További háttérképek a `~/.config/omarchy/backgrounds/<theme name>` mappában találhatók. Az Omarchy menü _Install > Style > Background_ pontján keresztül is elérhetők.

Minden stílusbeállítás elérhető az Omarchy menü (`Super + Space`) _Style_ pontja alatt is.

## Kapcsolók

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Zárolás üresjáratban ki-/bekapcsolása |
| `Super + Ctrl + Delete` | Laptopkijelző ki-/bekapcsolása |
| `Super + Ctrl + Alt + Delete` | Laptopkijelző tükrözésének ki-/bekapcsolása |
| `Super + Shift + Space` | Felső sáv ki-/bekapcsolása  |
| `Shift + Mute` | Váltás a következő hangkimenetre |
| `Shift + Play` | Váltás a következő médiaforrásra |
| `Super + Shift + Backspace` | Ablakok közötti rés ki-/bekapcsolása |
| `Super + Ctrl + Alt + F` | Teljes képernyős asztal ki-/bekapcsolása (felső sáv + ablakok közötti rés) |

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
| `Super + Ctrl + Alt + W` | Időjárás-értesítés ki-/bekapcsolása  |

## Tmux

A prefix billentyű a `Ctrl + Space` (a `Ctrl + B` is működik). Ezeket a kötéseket a `~/.config/tmux/tmux.conf` fájlban módosíthatod.

### Panelek

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + v` | Panel kettéosztása egymás mellé (függőleges) |
| `Prefix + h` | Panel kettéosztása egymás alá (vízszintes) |
| `Prefix + x` | Panel bezárása |
| `Prefix + z` | Panelnagyítás ki-/bekapcsolása (teljes képernyő) |
| `Alt + Enter` | Panel kettéosztása egymás alá (prefix nélkül) |
| `Alt + Shift + Enter` | Panel kettéosztása egymás mellé (prefix nélkül) |
| `Alt + Escape` | Panel bezárása (prefix nélkül) |
| `Ctrl + Alt + Arrows` | Mozgás a panelek között |
| `Ctrl + Alt + Shift + Arrows` | Panelek átméretezése |

### Ablakok

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + c` | Új ablak |
| `Prefix + k` | Ablak bezárása |
| `Prefix + r` | Ablak átnevezése |
| `Alt + 1-9` | Ugrás adott ablakra |
| `Alt + Arrow Left/Right` | Mozgás az ablakok között |
| `Alt + Shift + Arrow Left/Right` | Ablak mozgatása balra/jobbra |

### Munkamenetek

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + C` | Új munkamenet |
| `Prefix + K` | Munkamenet bezárása |
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
| `v` | Kijelölés kezdése (másolási módban) |
| `y` | Kijelölés másolása (másolási módban) |

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
| `tsl <count> <command>` | Többpaneles swarm elrendezés létrehozása |

## Ghostty terminál

A Ghostty terminál az Omarchy menü _Install > Terminal_ pontjával telepíthető.

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Új felosztás alul |
| `Ctrl + Shift + O` | Új felosztás mellette |
| `Ctrl + Alt + Arrows` | Mozgás a felosztások között |
| `Super + Ctrl + Shift + Arrows` | Felosztás átméretezése 10 sorral |
| `Super + Ctrl + Shift + Alt + Arrows` | Felosztás átméretezése 100 sorral |
| `Ctrl + Shift + T` | Új lap  |
| `Ctrl + Shift + Arrows` | Mozgás a lapok között |
| `Alt + Numbers` | Ugrás adott lapra |
| `Shift + Pg Up/Down` | Előzmények görgetése |
| `Ctrl + Left mouse` | Link megnyitása böngészőben |

## Fájlkezelő

| Gyorsbillentyű              | Funkció                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ugrás elérési útra                     |
| `Space`               | Fájl előnézete (a nyilakkal lehet navigálni) |
| `Alt + Up`       | Fel a szülőmappába        |

## Neovim (lazyvimmel)

### Navigáció

| Gyorsbillentyű                   | Funkció                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Parancslehetőségek megjelenítése            |
| `Space Space`              | Fájl megnyitása fuzzy kereséssel      |
| `Space E`                  | Oldalsáv ki-/bekapcsolása                  |
| `Space G G`                | git vezérlők megjelenítése               |
| `Space S G`                | Keresés a fájl tartalmában             |
| `Ctrl + W W`               | Váltás oldalsáv és szerkesztő között |
| `Ctrl + Left/right arrow`  | Oldalsáv méretének módosítása          |
| `Shift + H`                      | Ugrás a bal oldali fájllapra             |
| `Shift + L`                      | Ugrás a jobb oldali fájllapra            |
| `Space B D`                | Fájllap bezárása                  |

### Az oldalsávban

| Gyorsbillentyű                   | Funkció                        |
| ------------------------ | ------------------------------- |
| `A`                        | Új fájl létrehozása a szülőkönyvtárban      |
| `Shift + A`                | Új alkönyvtár létrehozása a szülőkönyvtárban    |
| `D`                        | Kijelölt fájl/könyvtár törlése     |
| `M`                        | Kijelölt fájl/könyvtár áthelyezése       |
| `R`                        | Kijelölt fájl/könyvtár átnevezése     |
| `?`                        | Súgó megjelenítése minden parancshoz      |

[Lásd a LazyVim által beállított összes Neovim gyorsbillentyűt](https://www.lazyvim.org/keymaps).

## Gyors emojik

A `Super + Ctrl + E` segítségével megjeleníthetsz egy teljes emoji-választót, amely a kiválasztott elemet a vágólapra teszi, vagy használhatod ezeket a gyors elérési lehetőségeket.

| Gyorsbillentyű       | EM | Tipp       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | mosoly      |
| `Shift + CapsLock M C` | 😂 | sírás        |
| `Shift + CapsLock M L` | 😍 | szerelem       |
| `Shift + CapsLock M V` | ✌️ | győzelem    |
| `Shift + CapsLock M H` | ❤️ | szív      |
| `Shift + CapsLock M Y` | 👍 | igen        |
| `Shift + CapsLock M N` | 👎 | nem         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | kívánság       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | csók       |
| `Shift + CapsLock M E` | 🙄 | szemforgatás    |
| `Shift + CapsLock M I` | 😉 | kacsintás       |
| `Shift + CapsLock M P` | 🙏 | imádkozás |
| `Shift + CapsLock M D` | 🤤 | nyáladzás      |
| `Shift + CapsLock M M` | 💰 | pénz      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | koccintás      |
| `Shift + CapsLock M O` |👌 | rendben |
| `Shift + CapsLock M G` |👋 | üdvözlés |
| `Shift + CapsLock M A` |💪 | kar |
| `Shift + CapsLock M B` |🤯 | fejrobbanás |

## Gyors kiegészítések

| Gyorsbillentyű       | Kiegészítés       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (hosszú gondolatjel)   |
| `Shift + CapsLock Space N` | A neved (ahogy a beállításkor megadtad)  |
| `Shift + CapsLock Space E` | Az e-mail címed (ahogy a beállításkor megadtad)  |

Továbbiakat is hozzáadhatsz a `~/.XCompose` szerkesztésével, majd a terminálban az `omarchy-restart-xcompose` futtatásával érvényesítheted a változtatásokat.
