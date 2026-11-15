# Gyorsbillentyűk

Az összes fő billentyűkiosztást a `Super + K` kombinációval nézheted meg (a Tmux kiosztását a `Super + Alt + K`, a Herdr kiosztását a `Super + Ctrl + K` kombinációval).

## Hogyan épülnek fel a gyorsbillentyűk

Minden gyorsbillentyű egy síkon ül, amit a módosítói határoznak meg, és minden síknak egy feladata van. Ettől nem mosódnak össze a gyorsbillentyűk, és ettől tudod általában kitalálni, hol lakik valami.

| Sík | Mi lakik ott | Példák |
| --- | --- | --- |
| `Super + key` | A rendszer: ablakok, munkaterületek, elrendezések és alapmenük | `Super + Space` Omarchy menü, `Super + W` ablak bezárása, `Super + F` teljes képernyő |
| `Super + Shift + key` | Alkalmazások | `Super + Shift + B` böngésző, `Super + Shift + E` e-mail, `Super + Shift + N` szerkesztő |
| `Super + Ctrl + key` | Panelek és rendszermenük | `Super + Ctrl + A` hang, `Super + Ctrl + N` hálózat, `Super + Ctrl + C` rögzítés menü |
| `Super + Ctrl + Alt + key` | Gyorsműveletek és jelzések | `Super + Ctrl + Alt + T` idő megjelenítése, `Super + Ctrl + Alt + B` akkumulátor, `Super + Ctrl + Alt + C` képernyőkép |

Ha egy gyorsbillentyűhöz hozzáadod az `Alt` billentyűt, ugyanannak a dolognak egy változatát kapod, soha nem valami teljesen mást:

- `Super + Shift + B` megnyitja a böngészőt; a `Super + Shift + Alt + B` privát ablakot nyit
- `Super + Shift + E` megnyitja az e-mailt; a `Super + Shift + Alt + E` újat kezd
- `Super + F` teljes képernyőre vált; a `Super + Alt + F` teljes szélességre vált
- `Super + Ctrl + C` megnyitja a rögzítés menüt; a `Super + Ctrl + Alt + C` kihagyja a menüt és képernyőképet készít

Amikor gyorsbillentyűt adsz hozzá:

1. Válaszd ki a síkot abból, mit csinál, aztán válaszd ki a billentyűt.
2. Ne mozdíts el egy meglévő gyorsbillentyűt, hogy helyet csinálj. Keress szabad billentyűt a megfelelő síkon.
3. Az `Alt` billentyűt csak az nélküle működő gyorsbillentyű változatához használd.

Néhány gyorsbillentyű megszegi ezeket a szabályokat, mert úgy kényelmes. A `Shift` egy nyíllal vagy a `Tab` billentyűvel mozgat vagy visszafordít ahelyett, hogy alkalmazást nyitna, a `Print`, a médiabillentyűk, az `Alt + Tab` és a `Ctrl + Alt + Del` pedig úgy működnek, ahogy mindenhol máshol is. Ezek kivételek, nem másolandó minták.

Ha egy alapértelmezés nem felel meg neked (mondjuk `Super + Shift + S` kombinációt akarsz képernyőképekhez, ahogy Windowson), kösd újra a `~/.config/hypr/bindings.lua` fájlban.

## Navigálás

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menü (alkalmazások és minden más)    |
| `Super + Alt + Space` | Alkalmazásrács |
| `Super + Escape` | Rendszermenü (felfüggesztés, újraindítás stb.)  |
| `Super + Ctrl + L` | Számítógép zárolása |
| `Super + W` vagy `Super + Q` | Ablak bezárása             |
| `Ctrl + Alt + Del` | Összes ablak bezárása |
| `Super + T`               | Ablak váltása csempézés/lebegés között             |
| `Super + J` | Ablak pozíciójának váltása (vízszintes/függőleges) |
| `Super + O`               | Ablak sticky'n'floating módba ugratásának ki-/bekapcsolása |
| `Super + L`               | Végigléptetés a dwindle, scrolling és floating elrendezéseken |
| `Super + Alt + L`         | Végigléptetés az elrendezéseken visszafelé |
| `Super + P`               | Ál-ablakstílus váltása (természetes vs. nyújtott) |
| `Super + F`                 | Teljes képernyőre váltás              |
| `Super + Alt + F`                 | Teljes szélességre váltás              |
| `Super + Ctrl + F`                 | Teljes képernyőre váltás az ablakon belül              |
| `Super + 1/2/3/4`         | Ugrás adott munkaterületre a fókuszált monitoron |
| `Super + Tab` | Ugrás a következő munkaterületre a fókuszált monitoron |
| `Super + Shift + Tab` | Ugrás az előző munkaterületre a fókuszált monitoron |
| `Super + Ctrl + Tab` | Ugrás a korábbi munkaterületre a fókuszált monitoron |
| `Super + Shift + 1/2/3/4` | Ablak áthelyezése munkaterületre a fókuszált monitoron |
| `Super + Shift + Alt + 1/2/3/4` | Ablak áthelyezése munkaterületre a fókuszált monitoron követés nélkül |
| `Super + S` | Teljes scratchpad ki-/bekapcsolása |
| `Super + Alt + S` | Ablak áthelyezése a teljes scratchpadre |
| `Super + Grave` | Quake konzol ki-/bekapcsolása |
| `Super + Shift + Grave` | Ablak áthelyezése a Quake konzolba |
| `Super + Shift + Ctrl + Arrows` | Ablak áthelyezése az adott irányban lévő monitorra |
| `Super + Shift + Alt + Arrows` | Munkaterület áthelyezése az adott irányban lévő monitorra |
| `Super + Arrow`  | Fókusz áthelyezése a nyíl irányában lévő ablakra, a képernyő szélén átlépve az azon az oldalon lévő monitorra |
| `Super + Shift + Arrow`  | Ablak felcserélése a nyíl irányában lévő másikkal, beleértve az azon az oldalon lévő monitoron lévőt is |
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
| `Super + Scroll Wheel` | Görgetés a munkaterületeken a fókuszált monitoron |
| `Super + G`               | Ablakcsoportosítás ki-/bekapcsolása      |
| `Super + Alt + G`               | Ablak kivétele a csoportosításból      |
| `Super + Alt + Tab`               | Léptetés a csoportosításban lévő ablakok között      |
| `Super + Alt + Shift + Tab`               | Léptetés visszafelé a csoportosításban lévő ablakok között      |
| `Super + Alt + Scroll Wheel` | Léptetés a csoportosításban lévő ablakok között |
| `Super + Alt + 1/2/3/4/5`               | Ugrás adott ablakra a csoportosításban      |
| `Super + Alt + Arrow`  | Ablak áthelyezése csoportosításba a nyíl irányában, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Ctrl + Left/Right`  | Mozgás az ablakok között egy csempézési csoporton belül |
| `Super + Ctrl + Z` | Nagyítás a képernyőn (ismételd a még nagyobb nagyításhoz) |
| `Super + Ctrl + Alt + Z` | Teljes kicsinyítés a képernyőről |
| `Super + /` | Előrelépés a monitor méretezési lehetőségein |
| `Super + Alt + /` | Visszalépés a monitor méretezési lehetőségein |
| `Alt + Tab` | Léptetés előre az aktív munkaterület ablakain |
| `Alt + Shift + Tab` | Léptetés visszafelé az aktív munkaterület ablakain |
| `Ctrl + Alt + Tab`| Fókusz léptetése előre a monitorokon |
| `Ctrl + Alt + Shift + Tab`| Fókusz léptetése visszafelé a monitorokon |

Az átméretezési parancsok a fizikai `code:20` és `code:21` billentyűket (XKB `<AE11>` és `<AE12>`) használják, függetlenül attól, milyen karakterek vannak a billentyűzetre nyomtatva. Az amerikai billentyűzeteken ezek a billentyűk a `-` és a `=`; a japán (JIS) billentyűzeteken a `-` és a `^`; a spanyol billentyűzeteken az `'` és a `¡`. JIS-en a `Super + ^` a `Super + Equal`, míg a `Super + Shift + -` (ami `=` karaktert ír) a `Super + Shift + Minus`.

## Rendszervezérlés

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Hangpanel    |
| `Super + Ctrl + B`           | Bluetooth panel    |
| `Super + Ctrl + N`           | Wifi/hálózati panel    |
| `Super + Ctrl + D`           | Kijelzőpanel    |
| `Super + Ctrl + P`           | Energiapanel    |
| `Super + Ctrl + X`           | Ügynökpanel    |
| `Super + Ctrl + Alt + D`           | Naptárpanel    |
| `Super + Ctrl + Alt + E`           | Világóra panel    |
| `Super + Ctrl + 1-9`           | Sávpanel ki-/bekapcsolása pozíció szerint    |
| `Super + Ctrl + S` | Megosztás menü (LocalSend segítségével) |
| `Super + Ctrl + C` | Rögzítésvezérlők (képernyőkép/-felvétel/választó) |
| `Super + Ctrl + O` | Menü ki-/bekapcsolása |
| `Super + Ctrl + H` | Hardvermenü |
| `Super + Ctrl + E` | Emoji-választó |
| `Super + Ctrl + .` | Média átkódolása |
| `Super + Shift + Ctrl + A` | AI-ügynök kiválasztása |

## Beállítások

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximális képernyőfényerő |
| `Shift + Brightness Down` | Minimális képernyőfényerő |
| `Alt + Brightness Up/Down` | Pontos, 1%-os fényerő-változtatások |
| `Alt + Volume Up/Down` | Pontos, 1%-os hangerő-változtatások |
| `Keyboard Brightness Up/Down` | Billentyűzet háttérvilágítása erősebb/gyengébb |
| `Keyboard Backlight` | Billentyűzet háttérvilágítási szintjeinek végigléptetése |
| `Alt + Play` | Következő szám |
| `Alt + Shift + Play` | Előző szám |

## Alkalmazások indítása

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminál    |
| `Super + Alt + Return` | Tmux terminál |
| `Super + Ctrl + Return` | Herdr (ügynökkezelő) |
| `Super + Shift + Return`           | Böngésző    |
| `Super + Shift + Alt + B`           | Böngésző (privát/inkognitó)    |
| `Super + Shift + F`           | Fájlkezelő    |
| `Super + Shift + Alt + F`           | Fájlkezelő a terminál cwd könyvtárában    |
| `Super + Shift + M`           | Zene (Spotify)    |
| `Super + Shift + Alt + M`           | Zene (cliamp)    |
| `Super + Shift + /`           | Jelszókezelő (1password)    |
| `Super + Shift + Q`           | Számológép (Omacalc)    |
| `Super + Shift + T`           | Tevékenység (btop)    |
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

A kötéseket a `~/.config/hypr/bindings.lua` fájlban módosíthatod/adhatod hozzá.

## Univerzális vágólap

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + A`           | Összes kijelölése azokban az alkalmazásokban, amelyek támogatják a `Ctrl + A` kombinációt    |
| `Super + C`           | Másolás    |
| `Super + X`           | Kivágás (terminálban nem)    |
| `Super + V`           | Beillesztés    |
| `Super + Ctrl + V`           | Vágólapkezelő    |

Linuxon általában `Ctrl + Shift + C/V` kell a terminálban történő másoláshoz és beillesztéshez, és `Ctrl + C/V` mindenhol máshol. Ezek az egységes Omarchy vágólap-gyorsbillentyűk mindenhol működnek.

## Rögzítés

| Gyorsbillentyű              | Funkció                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Képernyőkép                      |
| `Super + Ctrl + Alt + C`            | Képernyőkép (ugyanaz a felvétel, Print Screen billentyű nélküli billentyűzetekhez) |
| `Super + Ctrl + C` | Rögzítés menü |
| `Alt + Print Screen`            | Képernyőfelvétel                     |
| `Super + Print Screen` | Színválasztó |
| `Super + Ctrl + Print Screen` | Szöveg kinyerése a vágólapra |
| `Super + Alt + [` | Webkamera-fedvény kisebbé tétele felvétel közben |
| `Super + Alt + ]` | Webkamera-fedvény nagyobbá tétele felvétel közben |
| `Alt + Shift + L` | Aktuális URL másolása webalkalmazásból vagy böngészőből |
| `Alt + Shift + D` | Az aktuális oldalon lévő videó letöltése a `~/Videos` mappába |
| `Alt + Space` | Diktálás indítása/leállítása (szükséges hozzá: _Setup > Defaults > Dictation_) |
| `Right Alt` | Tartsd nyomva a diktáláshoz (szükséges hozzá: _Setup > Defaults > Dictation_) |

Képernyőfelvételeknél a gyorsbillentyű először megkérdezi, milyen hangot akarsz, aztán elindítja a felvételt. Nyomd meg újra a leállításhoz. A részletekért lásd: [képernyőképek és felvétel](12-screenshots-recording.md).

Minden rögzítési lehetőség elérhető az Omarchy menü (`Super + Space`) _Trigger > Capture_ pontja alatt is.

## Értesítések

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + ,` | Művelet a legutóbbi értesítésen: nyisd meg, vagy nyomd meg az egyetlen gombját, válassz a lehetőségei közül, vagy zárd be, ha nincs neki egy sem  |
| `Super + Shift + ,` | Összes értesítés elvetése |
| `Super + Ctrl + ,` | Értesítések vezérlése billentyűzettel  |
| `Super + Alt + ,` | Legutóbbi értesítés elvetése  |
| `Super + Shift + Alt + ,` | Értesítési előzmények megnyitása  |
| `Super + Ctrl + Alt + ,` | Értesítések némításának ki-/bekapcsolása  |

## Stílus

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Új téma kiválasztása (vagy `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Téma hátterének kiválasztása (vagy `Super + Ctrl + Space`) |
| `Super + Backspace` | Átlátszóság ki-/bekapcsolása egy ablakon |
| `Super + Ctrl + Backspace` | Egyablakos négyzetes képarány ki-/bekapcsolása |

Az extra háttérképek a `~/.config/omarchy/backgrounds/<theme name>` mappában vannak. Az Omarchy menü _Install > Style > Background_ pontján keresztül is elérhetők.

Minden stílusbeállítás elérhető az Omarchy menü (`Super + Space`) _Style_ pontja alatt is.

## Kapcsolók

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Tétlenség esetén történő zárolás ki-/bekapcsolása |
| `Super + Ctrl + Delete` | Laptopkijelző be-/kikapcsolása |
| `Super + Ctrl + Alt + Delete` | Laptopkijelző tükrözésének ki-/bekapcsolása |
| `Super + Shift + Space` | Felső sáv ki-/bekapcsolása  |
| `Shift + Mute` | Váltás a következő hangkimenetre |
| `Shift + Play` | Váltás a következő médiaforrásra |
| `Super + Shift + Backspace` | Ablakközök ki-/bekapcsolása |
| `Super + Ctrl + Alt + F` | Teljes képernyős asztal ki-/bekapcsolása (felső sáv + ablakközök) |

## Emlékeztetők

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Emlékeztető beállítása  |
| `Super + Ctrl + Alt + R` | Összes emlékeztető megtekintése  |
| `Super + Ctrl + Shift + R` | Összes emlékeztető törlése  |

## Jelzések

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Idő megjelenítése értesítésként  |
| `Super + Ctrl + Alt + B` | Akkumulátor megjelenítése értesítésként  |
| `Super + Ctrl + Alt + W` | Időjárás értesítésként való megjelenítésének ki-/bekapcsolása  |

## Tmux

A prefix billentyű a `Ctrl + Space` (a `Ctrl + B` is működik). Ezeket a kötéseket a `~/.config/tmux/tmux.conf` fájlban módosíthatod.

### Ablaktáblák

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + v` | Ablaktábla felosztása mellé (függőleges) |
| `Prefix + h` | Ablaktábla felosztása alá (vízszintes) |
| `Prefix + x` | Ablaktábla kilövése |
| `Prefix + z` | Ablaktábla nagyításának ki-/bekapcsolása (teljes képernyő) |
| `Alt + Enter` | Ablaktábla felosztása alá (prefix nélkül) |
| `Alt + Shift + Enter` | Ablaktábla felosztása mellé (prefix nélkül) |
| `Alt + Escape` | Ablaktábla kilövése (prefix nélkül) |
| `Ctrl + Alt + Arrows` | Mozgás az ablaktáblák között |
| `Ctrl + Alt + Shift + Arrows` | Ablaktáblák átméretezése |

### Ablakok

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + c` | Új ablak |
| `Prefix + k` | Ablak kilövése |
| `Prefix + r` | Ablak átnevezése |
| `Alt + 1-9` | Ugrás adott ablakra |
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
| `Prefix + :` | Parancsbeviteli sor |

### Tmux elrendezési függvények

Ezeket a függvényeket Tmux munkameneten belül kell futtatni.

| Parancs | Funkció |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása szerkesztővel, AI-val és terminállal |
| `tdlm <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása alkönyvtáranként |
| `tsl <count> <command>` | Többablaktáblás swarm elrendezés létrehozása |

## Ghostty Terminal

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
| `Ctrl + Left mouse` | Hivatkozás megnyitása böngészőben |

## Fájlkezelő

| Gyorsbillentyű              | Funkció                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ugrás útvonalra                     |
| `Space`               | Fájl előnézete (a nyilak navigálnak) |
| `Alt + Up`       | Fel a szülőmappába        |

## Neovim (w/ lazyvim)

### Navigáció

| Gyorsbillentyű                   | Funkció                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Parancslehetőségek megjelenítése            |
| `Space Space`              | Fájl megnyitása fuzzy kereséssel      |
| `Space E`                  | Oldalsáv ki-/bekapcsolása                  |
| `Space G G`                | Git vezérlők megjelenítése               |
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
| `?`                        | Súgó megjelenítése az összes parancshoz      |

[Lásd a LazyVim által beállított összes Neovim gyorsbillentyűt](https://www.lazyvim.org/keymaps).

## Gyors emojik

A `Super + Ctrl + E` kombinációval megjeleníthetsz egy teljes emoji-választót, amely a kiválasztottat a vágólapra teszi, vagy használhatod ezeket a gyors elérési lehetőségeket.

| Gyorsbillentyű       | EM | Jelentés       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | mosoly      |
| `Shift + CapsLock M C` | 😂 | sírás        |
| `Shift + CapsLock M L` | 😍 | imádat       |
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
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | pohárköszöntő      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | üdvözlés |
| `Shift + CapsLock M A` |💪 | kar |
| `Shift + CapsLock M B` |🤯 | agyrobbantó |

## Gyors kiegészítések

| Gyorsbillentyű       | Kiegészítés       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (gondolatjel)   |
| `Shift + CapsLock Space N` | A neved (ahogy a beállításkor megadtad)  |
| `Shift + CapsLock Space E` | Az e-mail címed (ahogy a beállításkor megadtad)  |

Továbbiakat is hozzáadhatsz a `~/.XCompose` szerkesztésével, majd a `omarchy-restart-xcompose` terminálban való futtatásával, hogy a változások életbe lépjenek.
