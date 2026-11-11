# Gyorsbillentyűk

Az összes fő billentyűkiosztást a `Super + K` kombinációval nézheted meg (a Tmux-kiosztásokat a `Super + Alt + K`, a Herdr-kiosztásokat pedig a `Super + Ctrl + K` kombinációval).

## Hogyan épülnek fel a gyorsbillentyűk

Minden gyorsbillentyű egy síkon helyezkedik el, amelyet a módosítóbillentyűi határoznak meg, és minden síknak egy feladata van. Ettől nem mosódnak össze a gyorsbillentyűk, és általában ki is találhatod, hol keresd az adott funkciót.

| Sík | Mi található rajta | Példák |
| --- | --- | --- |
| `Super + key` | A rendszer: ablakok, munkaterületek, elrendezések és alapmenük | `Super + Space` Omarchy menü, `Super + W` ablak bezárása, `Super + F` teljes képernyő |
| `Super + Shift + key` | Alkalmazások | `Super + Shift + B` böngésző, `Super + Shift + E` e-mail, `Super + Shift + N` szerkesztő |
| `Super + Ctrl + key` | Panelek és rendszermenük | `Super + Ctrl + A` hang, `Super + Ctrl + N` hálózat, `Super + Ctrl + C` rögzítési menü |
| `Super + Ctrl + Alt + key` | Gyorsműveletek és értesítések | `Super + Ctrl + Alt + T` idő megjelenítése, `Super + Ctrl + Alt + B` akkumulátor, `Super + Ctrl + Alt + C` képernyőkép |

Ha egy gyorsbillentyűhöz hozzáadod az `Alt` billentyűt, ugyanannak a dolognak egy változatát kapod, sosem valami teljesen mást:

- A `Super + Shift + B` megnyitja a böngészőt; a `Super + Shift + Alt + B` privát ablakot nyit
- A `Super + Shift + E` megnyitja az e-mailt; a `Super + Shift + Alt + E` újat kezd
- A `Super + F` teljes képernyőre vált; a `Super + Alt + F` teljes szélességre vált
- A `Super + Ctrl + C` megnyitja a rögzítési menűt; a `Super + Ctrl + Alt + C` kihagyja a menüt, és képernyőképet készít

Gyorsbillentyű hozzáadásakor:

1. Először a feladata alapján válaszd ki a síkot, utána a billentyűt.
2. Ne mozdíts el egy meglévő gyorsbillentyűt, hogy helyet csinálj. Keress egy szabad billentyűt a megfelelő síkon.
3. Az `Alt` billentyűt csak a nélküle használt gyorsbillentyű változatához használd.

Néhány gyorsbillentyű megszegi ezeket a szabályokat, mert úgy kényelmes. A `Shift` egy nyílbillentyűvel vagy a `Tab` billentyűvel mozgat vagy visszafelé lép ahelyett, hogy alkalmazást nyitna meg, a `Print`, a médiabillentyűk, az `Alt + Tab` és a `Ctrl + Alt + Del` pedig úgy működnek, mint mindenhol máshol. Ezek kivételek, nem másolandó minták.

Ha egy alapértelmezés nem felel meg neked (mondjuk a Windowson megszokott módon a `Super + Shift + S` kombinációt szeretnéd a képernyőképekhez), kösd át a `~/.config/hypr/bindings.lua` fájlban.

## Navigáció

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menü (alkalmazások és minden más)    |
| `Super + Alt + Space` | Alkalmazásrács |
| `Super + Escape` | Rendszermenü (felfüggesztés, újraindítás stb.)  |
| `Super + Ctrl + L` | Számítógép zárolása |
| `Super + W` vagy `Super + Q` | Ablak bezárása             |
| `Ctrl + Alt + Del` | Összes ablak bezárása |
| `Super + T`               | Ablak váltása csempézett/lebegő mód között             |
| `Super + J` | Ablak pozíciójának váltása (vízszintes/függőleges) |
| `Super + O`               | Kiugró ablak rögzített-lebegő módjának ki-/bekapcsolása |
| `Super + L`               | Váltás a dwindle, a görgethető és a lebegő elrendezések között |
| `Super + Alt + L`         | Váltás az elrendezések között fordított sorrendben |
| `Super + P`               | Áláblakstílus váltása (természetes / nyújtott) |
| `Super + F`                 | Teljes képernyő              |
| `Super + Alt + F`                 | Teljes szélesség              |
| `Super + Ctrl + F`                 | Teljes képernyő az ablakon belül              |
| `Super + 1/2/3/4`         | Ugrás a fókuszált monitor adott munkaterületére |
| `Super + Tab` | Ugrás a fókuszált monitor következő munkaterületére |
| `Super + Shift + Tab` | Ugrás a fókuszált monitor előző munkaterületére |
| `Super + Ctrl + Tab` | Ugrás a fókuszált monitor korábbi munkaterületére |
| `Super + Shift + 1/2/3/4` | Ablak áthelyezése a fókuszált monitor munkaterületére |
| `Super + Shift + Alt + 1/2/3/4` | Ablak áthelyezése a fókuszált monitor munkaterületére, követés nélkül |
| `Super + S` | Teljes scratchpad ki-/bekapcsolása |
| `Super + Alt + S` | Ablak áthelyezése a teljes scratchpadre |
| `Super + Grave` | Quake-konzol ki-/bekapcsolása |
| `Super + Shift + Grave` | Ablak áthelyezése a Quake-konzolba |
| `Super + Shift + Ctrl + Arrows` | Ablak áthelyezése az adott irányban lévő monitorra |
| `Super + Shift + Alt + Arrows` | Munkaterület áthelyezése az adott irányban lévő monitorra |
| `Super + Arrow`  | Fókusz áthelyezése a nyíl irányában lévő ablakra, a képernyő szélén átlépve az azon az oldalon lévő monitorra |
| `Super + Shift + Arrow`  | Ablak felcserélése a nyíl irányában lévő másik ablakkal, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Minus` | Ablak bővítése balra |
| `Super + Equal` | Ablak szűkítése balra |
| `Super + Shift + Minus` | Ablak szűkítése felfelé |
| `Super + Shift + Equal` | Ablak bővítése lefelé |
| `Super + Alt + Minus/Equal` | Ugyanez az átméretezés kisebb lépésekben |
| `Super + Ctrl + Minus/Equal` | Ugyanez az átméretezés nagyobb lépésekben |
| `Super + Alt + Home` | Ablak szélességének mentése |
| `Super + Home` | Mentett ablakszélesség visszaállítása |
| `Super + Left Mouse` | Ablak húzása |
| `Super + Right Mouse` | Ablak átméretezése |
| `Super + Scroll Wheel` | Görgetés a fókuszált monitor munkaterületei között |
| `Super + G`               | Ablakcsoportosítás ki-/bekapcsolása      |
| `Super + Alt + G`               | Ablak kivétele a csoportból      |
| `Super + Alt + Tab`               | Váltás a csoport ablakai között      |
| `Super + Alt + Shift + Tab`               | Váltás visszafelé a csoport ablakai között      |
| `Super + Alt + Scroll Wheel` | Váltás a csoport ablakai között |
| `Super + Alt + 1/2/3/4/5`               | Ugrás a csoport adott ablakára      |
| `Super + Alt + Arrow`  | Ablak áthelyezése a csoportba a nyíl irányában, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Ctrl + Left/Right`  | Mozgás a csempézett csoport ablakai között |
| `Super + Ctrl + Z` | Nagyítás a képernyőn (ismételd a nagyobb nagyításhoz) |
| `Super + Ctrl + Alt + Z` | Teljes kicsinyítés a képernyőről |
| `Super + /` | Léptetés előre a monitor méretezési lehetőségei között |
| `Super + Alt + /` | Léptetés visszafelé a monitor méretezési lehetőségei között |
| `Alt + Tab` | Váltás előre az aktív munkaterület ablakai között |
| `Alt + Shift + Tab` | Váltás visszafelé az aktív munkaterület ablakai között |
| `Ctrl + Alt + Tab`| Fókusz léptetése előre a monitorok között |
| `Ctrl + Alt + Shift + Tab`| Fókusz léptetése visszafelé a monitorok között |

Az átméretező parancsok a fizikai `code:20` és `code:21` billentyűket használják (XKB `<AE11>` és `<AE12>`), függetlenül attól, milyen karakter van a billentyűre nyomtatva. Az amerikai billentyűzeteken ezek a `-` és `=` billentyűk; a japán (JIS) billentyűzeteken `-` és `^`; a spanyol billentyűzeteken pedig `'` és `¡`. JIS kiosztáson a `Super + ^` a `Super + Equal`, míg a `Super + Shift + -` (amely `=` jelet ír) a `Super + Shift + Minus`.

## Rendszervezérlés

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Hangpanel    |
| `Super + Ctrl + B`           | Bluetooth panel    |
| `Super + Ctrl + N`           | Wi-Fi/hálózati panel    |
| `Super + Ctrl + D`           | Kijelzőpanel    |
| `Super + Ctrl + P`           | Energiapanel    |
| `Super + Ctrl + X`           | Ágensek panelje    |
| `Super + Ctrl + Alt + D`           | Naptárpanel    |
| `Super + Ctrl + Alt + E`           | Világórapanel    |
| `Super + Ctrl + 1-9`           | Sávpanel ki-/bekapcsolása pozíció szerint    |
| `Super + Ctrl + S` | Megosztás menü (a LocalSend segítségével) |
| `Super + Ctrl + C` | Rögzítésvezérlés (képernyőkép/-felvétel/választó) |
| `Super + Ctrl + O` | Menü ki-/bekapcsolása |
| `Super + Ctrl + H` | Hardver menü |
| `Super + Ctrl + E` | Emoji-választó |
| `Super + Ctrl + .` | Média átkódolása |
| `Super + Shift + Ctrl + A` | AI-ágens kiválasztása |

## Beállítások

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximális képernyőfényerő |
| `Shift + Brightness Down` | Minimális képernyőfényerő |
| `Alt + Brightness Up/Down` | Pontos, 1%-os fényerő-változtatások |
| `Alt + Volume Up/Down` | Pontos, 1%-os hangerő-változtatások |
| `Keyboard Brightness Up/Down` | Billentyűzet-háttérvilágítás erősebb/gyengébb |
| `Keyboard Backlight` | Váltás a billentyűzet-háttérvilágítás szintjei között |
| `Alt + Play` | Következő szám |
| `Alt + Shift + Play` | Előző szám |

## Alkalmazások indítása

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminál    |
| `Super + Alt + Return` | Tmux-terminál |
| `Super + Ctrl + Return` | Herdr (ágenskezelő) |
| `Super + Shift + Return`           | Böngésző    |
| `Super + Shift + Alt + B`           | Böngésző (privát/inkognitó)    |
| `Super + Shift + F`           | Fájlkezelő    |
| `Super + Shift + Alt + F`           | Fájlkezelő a terminál aktuális könyvtárában    |
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
| `Super + Shift + Alt + X`           | X-bejegyzés létrehozása |
| `Super + Shift + Y`           | YouTube |

A kötéseket a `~/.config/hypr/bindings.lua` fájlban módosíthatod és adhatsz hozzá újakat.

## Univerzális vágólap

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + A`           | Összes kijelölése azokban az alkalmazásokban, amelyek támogatják a `Ctrl + A` kombinációt    |
| `Super + C`           | Másolás    |
| `Super + X`           | Kivágás (terminálban nem)    |
| `Super + V`           | Beillesztés    |
| `Super + Ctrl + V`           | Vágólapkezelő    |

Általában Linuxon a terminálban `Ctrl + Shift + C/V`, mindenhol máshol pedig `Ctrl + C/V` kell a másoláshoz és beillesztéshez. Ezek az Omarchy egységes vágólap-gyorsbillentyűi mindenhol működnek.

## Rögzítés

| Gyorsbillentyű              | Funkció                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Képernyőkép                      |
| `Super + Ctrl + Alt + C`            | Képernyőkép (ugyanaz a felvétel, Print Screen billentyű nélküli billentyűzetekhez) |
| `Super + Ctrl + C` | Rögzítési menü |
| `Alt + Print Screen`            | Képernyőfelvétel                     |
| `Super + Print Screen` | Színválasztó |
| `Super + Ctrl + Print Screen` | Szöveg kinyerése a vágólapra |
| `Super + Alt + [` | Webkamera-fedvény kicsinyítése felvétel közben |
| `Super + Alt + ]` | Webkamera-fedvény nagyítása felvétel közben |
| `Alt + Shift + L` | Aktuális URL másolása webalkalmazásból vagy a Chromiumból |
| `Alt + Shift + D` | Az aktuális oldalon lévő videó letöltése a `~/Videos` mappába |
| `Alt + Space` | Diktálás indítása/leállítása (szükséges hozzá: _Setup > Defaults > Dictation_) |
| `Right Alt` | Tartsd lenyomva a diktáláshoz (szükséges hozzá: _Setup > Defaults > Dictation_) |

Képernyőfelvételeknél a gyorsbillentyű először megkérdezi, milyen hangot szeretnél, ezután indítja el a felvételt. Nyomd meg újra a leállításhoz. A részleteket lásd: [képernyőképek és felvétel](12-screenshots-recording.md).

Az összes rögzítési lehetőség elérhető az Omarchy menü _Trigger > Capture_ pontja alatt is (`Super + Space`).

## Értesítések

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + ,` | Művelet a legutóbbi értesítésen: megnyitja, vagy megnyomja az egyetlen gombját, választ a lehetőségei közül, vagy elveti, ha egy sincs neki  |
| `Super + Shift + ,` | Összes értesítés elvetése |
| `Super + Ctrl + ,` | Értesítések vezérlése billentyűzettel  |
| `Super + Alt + ,` | Legutóbbi értesítés elvetése  |
| `Super + Shift + Alt + ,` | Értesítési előzmények megnyitása  |
| `Super + Ctrl + Alt + ,` | Értesítések némításának ki-/bekapcsolása  |

## Stílus

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Új téma választása (ezzel is: `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Témaháttér választása (ezzel is: `Super + Ctrl + Space`) |
| `Super + Backspace` | Ablak átlátszóságának ki-/bekapcsolása |
| `Super + Ctrl + Backspace` | Egyablakos négyzetes képarány ki-/bekapcsolása |

Az extra háttérképek a `~/.config/omarchy/backgrounds/<theme name>` mappában találhatók. Elérhetők az Omarchy menü _Install > Style > Background_ pontján keresztül is.

Az összes stílusbeállítás elérhető az Omarchy menü _Style_ pontja alatt is (`Super + Space`).

## Kapcsolók

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Tétlenség esetén történő zárolás ki-/bekapcsolása |
| `Super + Ctrl + Delete` | Laptopkijelző ki-/bekapcsolása |
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

Az előtagbillentyű a `Ctrl + Space` (a `Ctrl + B` is működik). Ezeket a kötéseket a `~/.config/tmux/tmux.conf` fájlban módosíthatod.

### Panelek

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + v` | Panel felosztása egymás mellé (függőleges) |
| `Prefix + h` | Panel felosztása egymás alá (vízszintes) |
| `Prefix + x` | Panel bezárása |
| `Prefix + z` | Panel nagyításának ki-/bekapcsolása (teljes képernyő) |
| `Alt + Enter` | Panel felosztása egymás alá (előtag nélkül) |
| `Alt + Shift + Enter` | Panel felosztása egymás mellé (előtag nélkül) |
| `Alt + Escape` | Panel bezárása (előtag nélkül) |
| `Ctrl + Alt + Arrows` | Mozgás a panelek között |
| `Ctrl + Alt + Shift + Arrows` | Panelek átméretezése |

### Ablakok

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + c` | Új ablak |
| `Prefix + k` | Ablak bezárása |
| `Prefix + r` | Ablak átnevezése |
| `Alt + 1-9` | Ugrás az adott ablakra |
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
| `v` | Kijelölés megkezdése (másolási módban) |
| `y` | Kijelölés másolása (másolási módban) |

### Általános

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguráció újratöltése |
| `Prefix + ?` | Tmux-billentyűkiosztások megjelenítése |
| `Prefix + :` | Parancssor |

### Tmux-elrendezési függvények

Ezeket a függvényeket Tmux-munkameneten belül kell futtatni.

| Parancs | Funkció |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása szerkesztővel, AI-val és terminállal |
| `tdlm <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása alkönyvtáranként |
| `tsl <count> <command>` | Többpaneles raj-elrendezés létrehozása |

## Ghostty terminál

A Ghostty terminál az Omarchy menü _Install > Terminal_ pontján keresztül telepíthető.

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Új felosztás alul |
| `Ctrl + Shift + O` | Új felosztás oldalt |
| `Ctrl + Alt + Arrows` | Mozgás a felosztások között |
| `Super + Ctrl + Shift + Arrows` | Felosztás átméretezése 10 sorral |
| `Super + Ctrl + Shift + Alt + Arrows` | Felosztás átméretezése 100 sorral |
| `Ctrl + Shift + T` | Új lap  |
| `Ctrl + Shift + Arrows` | Mozgás a lapok között |
| `Alt + Numbers` | Ugrás az adott lapra |
| `Shift + Pg Up/Down` | Előzmények görgetése |
| `Ctrl + Left mouse` | Hivatkozás megnyitása a böngészőben |

## Fájlkezelő

| Gyorsbillentyű              | Funkció                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ugrás az elérési útra                     |
| `Space`               | Fájl előnézete (navigáció a nyilakkal) |
| `Alt + Up`       | Fel a szülőmappába        |

## Neovim (LazyVimmel)

### Navigáció

| Gyorsbillentyű                   | Funkció                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Parancslehetőségek megjelenítése            |
| `Space Space`              | Fájl megnyitása fuzzy kereséssel      |
| `Space E`                  | Oldalsáv ki-/bekapcsolása                  |
| `Space G G`                | Git-vezérlők megjelenítése               |
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

[Nézd meg a LazyVim által beállított összes Neovim-gyorsbillentyűt](https://www.lazyvim.org/keymaps).

## Gyors emojik

A `Super + Ctrl + E` kombinációval megjeleníthetsz egy teljes emoji-választót, amely a kiválasztott elemet a vágólapra teszi, vagy használhatod ezeket a gyorselérési lehetőségeket.

| Gyorsbillentyű       | EM | Clue       |
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
| `Shift + CapsLock Space Space` | — (gondolatjel)   |
| `Shift + CapsLock Space N` | A neved (ahogy a beállításkor megadtad)  |
| `Shift + CapsLock Space E` | Az e-mail-címed (ahogy a beállításkor megadtad)  |

További sajátokat is hozzáadhatsz a `~/.XCompose` szerkesztésével, majd futtasd a terminálban az `omarchy-restart-xcompose` parancsot, hogy a változások érvénybe lépjenek.
