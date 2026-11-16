# Gyorsbillentyűk

Minden fő billentyűkiosztást megnézhetsz a `Super + K` billentyűvel (a Tmux kiosztásokat a `Super + Alt + K`, a Herdr kiosztásokat a `Super + Ctrl + K` billentyűvel).

## Hogyan épülnek fel a gyorsbillentyűk

Mindegyik gyorsbillentyű egy síkon helyezkedik el, amelyet a módosítói határoznak meg, és minden síknak egy feladata van. Ettől nem mosódnak össze a gyorsbillentyűk, és általában ki is tudod találni, mi hol lakik.

| Sík | Mi lakik ott | Példák |
| --- | --- | --- |
| `Super + key` | A rendszer: ablakok, munkaterületek, elrendezések és alapmenük | `Super + Space` Omarchy menü, `Super + W` ablak bezárása, `Super + F` teljes képernyő |
| `Super + Shift + key` | Alkalmazások | `Super + Shift + B` böngésző, `Super + Shift + E` e-mail, `Super + Shift + N` szerkesztő |
| `Super + Ctrl + key` | Panelek és rendszermenük | `Super + Ctrl + A` hang, `Super + Ctrl + N` hálózat, `Super + Ctrl + C` rögzítés menü |
| `Super + Ctrl + Alt + key` | Gyorsműveletek és jelzések | `Super + Ctrl + Alt + T` idő megjelenítése, `Super + Ctrl + Alt + B` akkumulátor, `Super + Ctrl + Alt + C` képernyőkép |

Ha egy gyorsbillentyűhöz hozzáadod az `Alt` billentyűt, ugyanannak a dolognak egy változatát kapod, sosem valami teljesen mást:

- A `Super + Shift + B` megnyitja a böngészőt; a `Super + Shift + Alt + B` privát ablakot nyit
- A `Super + Shift + E` megnyitja az e-mailt; a `Super + Shift + Alt + E` újat kezd
- A `Super + F` teljes képernyőre vált; a `Super + Alt + F` teljes szélességre vált
- A `Super + Ctrl + C` megnyitja a rögzítés menüt; a `Super + Ctrl + Alt + C` kihagyja a menüt és képernyőképet készít

Gyorsbillentyű hozzáadásakor:

1. Válaszd ki a síkot abból, mit csinál, aztán válaszd ki a billentyűt.
2. Ne mozdíts el egy meglévő gyorsbillentyűt, hogy helyet csinálj neki. Keress szabad billentyűt a megfelelő síkon.
3. Az `Alt` billentyűt csak a nélküle használt gyorsbillentyű változatához használd.

Néhány gyorsbillentyű megszegi ezeket a szabályokat, mert úgy kényelmes. A `Shift` egy nyíllal vagy a `Tab` billentyűvel mozgat vagy visszafelé lép ahelyett, hogy alkalmazást nyitna, a `Print`, a médiabillentyűk, az `Alt + Tab` és a `Ctrl + Alt + Del` pedig úgy működnek, ahogy mindenhol máshol. Ezek kivételek, nem másolandó minták.

Ha egy alapértelmezés nem felel meg neked (mondjuk a `Super + Shift + S` billentyűt szeretnéd képernyőképekhez, mint Windowson), kösd újra a `~/.config/hypr/bindings.lua` fájlban.

## Navigálás

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menü (alkalmazások és minden más)    |
| `Super + Alt + Space` | Alkalmazásrács |
| `Super + Escape` | Rendszermenü (felfüggesztés, újraindítás stb.)  |
| `Super + Ctrl + L` | Számítógép zárolása |
| `Super + W` or `Super + Q` | Ablak bezárása             |
| `Ctrl + Alt + Del` | Minden ablak bezárása |
| `Super + T`               | Ablak váltása csempézés/lebegés között             |
| `Super + J` | Ablak pozíciójának váltása (vízszintes/függőleges) |
| `Super + O`               | Ablak sticky'n'floating módba ugrasztásának ki-/bekapcsolása |
| `Super + L`               | Végiglépkedés a dwindle, scrolling és floating elrendezéseken |
| `Super + Alt + L`         | Végiglépkedés az elrendezéseken visszafelé |
| `Super + P`               | Pseudo ablakstílus ki-/bekapcsolása (natural v stretch) |
| `Super + F`                 | Teljes képernyő              |
| `Super + Alt + F`                 | Teljes szélesség              |
| `Super + Ctrl + F`                 | Teljes képernyő az ablakon belül              |
| `Super + 1/2/3/4`         | Ugrás adott munkaterületre a fókuszban lévő monitoron |
| `Super + Tab` | Ugrás a következő munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + Tab` | Ugrás az előző munkaterületre a fókuszban lévő monitoron |
| `Super + Ctrl + Tab` | Ugrás a korábbi munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + 1/2/3/4` | Ablak áthelyezése munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + Alt + 1/2/3/4` | Ablak áthelyezése munkaterületre a fókuszban lévő monitoron, követés nélkül |
| `Super + S` | Teljes scratchpad ki-/bekapcsolása |
| `Super + Alt + S` | Ablak áthelyezése a teljes scratchpadra |
| `Super + Grave` | Quake konzol ki-/bekapcsolása |
| `Super + Shift + Grave` | Ablak áthelyezése a Quake konzolra |
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
| `Super + Scroll Wheel` | Görgetés a munkaterületek között a fókuszban lévő monitoron |
| `Super + G`               | Ablakcsoportosítás ki-/bekapcsolása      |
| `Super + Alt + G`               | Ablak kivétele a csoportosításból      |
| `Super + Alt + Tab`               | Lépegetés a csoport ablakai között      |
| `Super + Alt + Shift + Tab`               | Lépegetés visszafelé a csoport ablakai között      |
| `Super + Alt + Scroll Wheel` | Lépegetés a csoport ablakai között |
| `Super + Alt + 1/2/3/4/5`               | Ugrás adott ablakra a csoportban      |
| `Super + Alt + Arrow`  | Ablak bevitele a csoportosításba a nyíl irányában, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Ctrl + Left/Right`  | Mozgás a csempézési csoporton belüli ablakok között |
| `Super + Ctrl + Z` | Nagyítás a képernyőn (ismételd a nagyobb nagyításhoz) |
| `Super + Ctrl + Alt + Z` | Teljes kicsinyítés a képernyőről |
| `Super + /` | Előrelépés a monitor méretezési lehetőségei között |
| `Super + Alt + /` | Visszalépés a monitor méretezési lehetőségei között |
| `Alt + Tab` | Lépegetés előre az aktív munkaterület ablakai között |
| `Alt + Shift + Tab` | Lépegetés visszafelé az aktív munkaterület ablakai között |
| `Ctrl + Alt + Tab`| Fókusz léptetése előre a monitorok között |
| `Ctrl + Alt + Shift + Tab`| Fókusz léptetése visszafelé a monitorok között |

Az átméretezési gyorsbillentyűk a `code:20` és `code:21` fizikai billentyűket használják (XKB `<AE11>` és `<AE12>`), függetlenül a billentyűzetre nyomtatott karakterektől. US billentyűzeteken ezek a billentyűk a `-` és `=`; japán (JIS) billentyűzeteken a `-` és `^`; spanyol billentyűzeteken az `'` és `¡`. JIS-en a `Super + ^` a `Super + Equal`, míg a `Super + Shift + -` (amely `=` jelet ír) a `Super + Shift + Minus`.

## Rendszervezérlés

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Hangpanel    |
| `Super + Ctrl + B`           | Bluetooth panel    |
| `Super + Ctrl + N`           | Wifi/hálózat panel    |
| `Super + Ctrl + D`           | Kijelzőpanel    |
| `Super + Ctrl + P`           | Tápellátás panel    |
| `Super + Ctrl + X`           | Ügynökök panel    |
| `Super + Ctrl + Alt + D`           | Naptárpanel    |
| `Super + Ctrl + Alt + E`           | Világóra panel    |
| `Super + Ctrl + 1-9`           | Sávpanel ki-/bekapcsolása pozíció szerint    |
| `Super + Ctrl + S` | Megosztás menü (LocalSend segítségével) |
| `Super + Ctrl + C` | Rögzítésvezérlés (képernyőkép/-felvétel/választó) |
| `Super + Ctrl + O` | Menü ki-/bekapcsolása |
| `Super + Ctrl + H` | Hardvermenü |
| `Super + Ctrl + E` | Emojiválasztó |
| `Super + Ctrl + .` | Média átkódolása |
| `Super + Shift + Ctrl + A` | AI-ügynök kiválasztása |

## Állítások

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximális képernyőfényerő |
| `Shift + Brightness Down` | Minimális képernyőfényerő |
| `Alt + Brightness Up/Down` | Pontos, 1%-os fényerő-változtatások |
| `Alt + Volume Up/Down` | Pontos, 1%-os hangerő-változtatások |
| `Keyboard Brightness Up/Down` | Billentyűzet-háttérvilágítás erősebb/gyengébb |
| `Keyboard Backlight` | Billentyűzet-háttérvilágítás szintjeinek váltogatása |
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

Módosíts/adj hozzá kiosztásokat a `~/.config/hypr/bindings.lua` fájlban.

## Univerzális vágólap

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + A`           | Mind kijelölése azokban az alkalmazásokban, amelyek támogatják a `Ctrl + A` billentyűt    |
| `Super + C`           | Másolás    |
| `Super + X`           | Kivágás (terminálban nem)    |
| `Super + V`           | Beillesztés    |
| `Super + Ctrl + V`           | Vágólapkezelő    |

Linuxon általában `Ctrl + Shift + C/V` kell a másoláshoz és beillesztéshez a terminálban, és `Ctrl + C/V` mindenhol máshol. Ezek az Omarchy egységes vágólap-gyorsbillentyűi mindenhol működnek.

## Rögzítés

| Gyorsbillentyű              | Funkció                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Képernyőkép                      |
| `Super + Ctrl + Alt + C`            | Képernyőkép (ugyanaz a felvétel, Print Screen billentyű nélküli billentyűzetekhez) |
| `Super + Ctrl + C` | Rögzítés menü |
| `Alt + Print Screen`            | Képernyőfelvétel                     |
| `Super + Shift + Ctrl + Alt + C` | Képernyőfelvétel hang nélkül, a menüt kihagyva (nyomd meg újra a leállításhoz) |
| `Super + Print Screen` | Színválasztó |
| `Super + Ctrl + Print Screen` | Szöveg kinyerése a vágólapra |
| `Super + Alt + [` | Webkamera-fedvény kicsinyítése felvétel közben |
| `Super + Alt + ]` | Webkamera-fedvény nagyobbítása felvétel közben |
| `Alt + Shift + L` | Aktuális URL másolása webalkalmazásból vagy böngészőből |
| `Alt + Shift + D` | Az aktuális oldalon lévő videó letöltése a `~/Videos` mappába |
| `Alt + Space` | Diktálás indítása/leállítása (_Setup > Defaults > Dictation_ szükséges) |
| `Right Alt` | Tartsd lenyomva a diktáláshoz (_Setup > Defaults > Dictation_ szükséges) |

Képernyőfelvételeknél a gyorsbillentyű először megkérdezi, milyen hangot szeretnél, aztán elindítja a felvételt. Nyomd meg újra a leállításhoz. A részleteket lásd a [képernyőképek és felvétel](12-screenshots-recording.md) oldalon.

Az összes rögzítési lehetőség elérhető az Omarchy menü (`Super + Space`) _Trigger > Capture_ pontja alatt is.

## Értesítések

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + ,` | Művelet a legutóbbi értesítésen: megnyitja vagy megnyomja az egyetlen gombját, választ a lehetőségei közül, vagy elveti, ha nincs neki  |
| `Super + Shift + ,` | Minden értesítés elvetése |
| `Super + Ctrl + ,` | Értesítések vezérlése a billentyűzettel  |
| `Super + Alt + ,` | Legutóbbi értesítés elvetése  |
| `Super + Shift + Alt + ,` | Értesítési előzmények megnyitása  |
| `Super + Ctrl + Alt + ,` | Értesítések némításának ki-/bekapcsolása  |

## Stílus

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Új téma választása (akkor is `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Témaháttér választása (akkor is `Super + Ctrl + Space`) |
| `Super + Backspace` | Ablak átlátszóságának ki-/bekapcsolása |
| `Super + Ctrl + Backspace` | Egyablakos négyzetes képarány ki-/bekapcsolása |

Az extra háttérképek a `~/.config/omarchy/backgrounds/<theme name>` helyen találhatók. Elérhető az Omarchy menü _Install > Style > Background_ pontja alatt is.

Az összes stíluslehetőség elérhető az Omarchy menü (`Super + Space`) _Style_ pontja alatt is.

## Kapcsolók

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Zárolás üresjáratban ki-/bekapcsolása |
| `Super + Ctrl + Delete` | Laptopkijelző be-/kikapcsolása |
| `Super + Ctrl + Alt + Delete` | Laptopkijelző tükrözésének ki-/bekapcsolása |
| `Super + Shift + Space` | Felső sáv ki-/bekapcsolása  |
| `Shift + Mute` | Váltás a következő hangkimenetre |
| `Shift + Play` | Váltás a következő médiaforrásra |
| `Super + Shift + Backspace` | Ablakrések ki-/bekapcsolása |
| `Super + Ctrl + Alt + F` | Teljes képernyős asztal ki-/bekapcsolása (felső sáv + ablakrések) |

## Emlékeztetők

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Emlékeztető beállítása  |
| `Super + Ctrl + Alt + R` | Minden emlékeztető megtekintése  |
| `Super + Ctrl + Shift + R` | Minden emlékeztető törlése  |

## Jelzések

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Idő megjelenítése értesítésként  |
| `Super + Ctrl + Alt + B` | Akkumulátor megjelenítése értesítésként  |
| `Super + Ctrl + Alt + W` | Időjárás értesítésként ki-/bekapcsolása  |

## Tmux

Az előtagbillentyű a `Ctrl + Space` (a `Ctrl + B` is működik). Ezeket a kiosztásokat a `~/.config/tmux/tmux.conf` fájlban módosíthatod.

### Ablaktáblák

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + v` | Ablaktábla felosztása mellé (függőleges) |
| `Prefix + h` | Ablaktábla felosztása alá (vízszintes) |
| `Prefix + x` | Ablaktábla megszüntetése |
| `Prefix + z` | Ablaktábla nagyításának ki-/bekapcsolása (teljes képernyő) |
| `Alt + Enter` | Ablaktábla felosztása alá (előtag nélkül) |
| `Alt + Shift + Enter` | Ablaktábla felosztása mellé (előtag nélkül) |
| `Alt + Escape` | Ablaktábla megszüntetése (előtag nélkül) |
| `Ctrl + Alt + Arrows` | Mozgás az ablaktáblák között |
| `Ctrl + Alt + Shift + Arrows` | Ablaktáblák átméretezése |

### Ablakok

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + c` | Új ablak |
| `Prefix + k` | Ablak megszüntetése |
| `Prefix + r` | Ablak átnevezése |
| `Alt + 1-9` | Ugrás adott ablakra |
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
| `v` | Kijelölés kezdése (másolás módban) |
| `y` | Kijelölés másolása (másolás módban) |

### Általános

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguráció újratöltése |
| `Prefix + ?` | Tmux billentyűkiosztások megjelenítése |
| `Prefix + :` | Parancssor |

### Tmux elrendezési függvények

Ezeket a függvényeket Tmux munkameneten belül kell futtatni.

| Parancs | Funkció |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása szerkesztővel, AI-val és terminállal |
| `tdlm <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása alkönyvtáranként |
| `tsl <count> <command>` | Többpaneles swarm elrendezés létrehozása |

## Ghostty Terminal

A Ghostty terminal az Omarchy menü _Install > Terminal_ pontjával telepíthető.

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Új felosztás lent |
| `Ctrl + Shift + O` | Új felosztás mellette |
| `Ctrl + Alt + Arrows` | Mozgás a felosztások között |
| `Super + Ctrl + Shift + Arrows` | Felosztás átméretezése 10 sorral |
| `Super + Ctrl + Shift + Alt + Arrows` | Felosztás átméretezése 100 sorral |
| `Ctrl + Shift + T` | Új lap  |
| `Ctrl + Shift + Arrows` | Mozgás a lapok között |
| `Alt + Numbers` | Ugrás adott lapra |
| `Shift + Pg Up/Down` | Előzmények görgetése |
| `Ctrl + Left mouse` | Hivatkozás megnyitása böngészőben |

## File Manager

| Gyorsbillentyű              | Funkció                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ugrás elérési útra                     |
| `Space`               | Fájl előnézete (a nyilakkal navigálhatsz) |
| `Alt + Up`       | Fel a szülőmappába        |

## Neovim (w/ lazyvim)

### Navigáció

| Gyorsbillentyű                   | Funkció                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Parancslehetőségek megjelenítése            |
| `Space Space`              | Fájl megnyitása fuzzy kereséssel      |
| `Space E`                  | Oldalsáv ki-/bekapcsolása                  |
| `Space G G`                | Git vezérlők megjelenítése               |
| `Space S G`                | Fájltartalom keresése             |
| `Ctrl + W W`               | Ugrás az oldalsáv és a szerkesztő között |
| `Ctrl + Left/right arrow`  | Oldalsáv méretének módosítása          |
| `Shift + H`                      | Ugrás a bal oldali fájllapra             |
| `Shift + L`                      | Ugrás a jobb oldali fájllapra            |
| `Space B D`                | Fájllap bezárása                  |

### Amíg az oldalsávban vagy

| Gyorsbillentyű                   | Funkció                        |
| ------------------------ | ------------------------------- |
| `A`                        | Új fájl hozzáadása a szülőkönyvtárban      |
| `Shift + A`                | Új alkönyvtár hozzáadása a szülőkönyvtárban    |
| `D`                        | Kiemelt fájl/könyvtár törlése     |
| `M`                        | Kiemelt fájl/könyvtár áthelyezése       |
| `R`                        | Kiemelt fájl/könyvtár átnevezése     |
| `?`                        | Súgó megjelenítése minden parancshoz      |

[Lásd a LazyVim által beállított összes Neovim gyorsbillentyűt](https://www.lazyvim.org/keymaps).

## Quick Emojis

A `Super + Ctrl + E` billentyűvel teljes emojiválasztót jeleníthetsz meg, amely a kiválasztottat a vágólapra teszi, vagy használhatod ezeket a gyors elérési lehetőségeket.

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

## Quick Completions

| Gyorsbillentyű       | Completion       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | A neved (ahogy a beállításkor megadtad)  |
| `Shift + CapsLock Space E` | Az e-mailed (ahogy a beállításkor megadtad)  |

Továbbiakat is hozzáadhatsz a `~/.XCompose` szerkesztésével, aztán futtasd a terminálban az `omarchy-restart-xcompose` parancsot, hogy a változások érvénybe lépjenek.
