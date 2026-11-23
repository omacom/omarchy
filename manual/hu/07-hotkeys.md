# Gyorsbillentyűk

Az összes fő billentyűkiosztást megtekintheted a `Super + K` billentyűkombinációval (a Tmux kiosztásait a `Super + Alt + K`, a Herdr kiosztásait pedig a `Super + Ctrl + K` kombinációval).

## Hogyan épülnek fel a gyorsbillentyűk

Minden gyorsbillentyű egy síkon helyezkedik el, amelyet a módosítóbillentyűi határoznak meg, és minden síknak egy feladata van. Ettől nem mosódnak össze a gyorsbillentyűk, és általában ki is tudod találni, hol keresd az adott funkciót.

| Sík | Mi tartozik ide | Példák |
| --- | --- | --- |
| `Super + key` | A rendszer: ablakok, munkaterületek, elrendezések és alapvető menük | `Super + Space` Omarchy menü, `Super + W` ablak bezárása, `Super + F` teljes képernyő |
| `Super + Shift + key` | Alkalmazások | `Super + Shift + B` böngésző, `Super + Shift + E` e-mail, `Super + Shift + N` szerkesztő |
| `Super + Ctrl + key` | Panelek és rendszermenük | `Super + Ctrl + A` hang, `Super + Ctrl + N` hálózat, `Super + Ctrl + C` rögzítési menü |
| `Super + Ctrl + Alt + key` | Gyorsműveletek és jelzések | `Super + Ctrl + Alt + T` idő megjelenítése, `Super + Ctrl + Alt + B` akkumulátor, `Super + Ctrl + Alt + C` képernyőkép |

Ha egy gyorsbillentyűhöz hozzáadod az `Alt` billentyűt, ugyanannak a dolognak egy változatát kapod, soha nem valami teljesen mást:

- A `Super + Shift + B` megnyitja a böngészőt; a `Super + Shift + Alt + B` privát ablakot nyit
- A `Super + Shift + E` megnyitja az e-mailt; a `Super + Shift + Alt + E` újat indít
- A `Super + F` teljes képernyőre vált; a `Super + Alt + F` teljes szélességre vált
- A `Super + Ctrl + C` megnyitja a rögzítési menüt; a `Super + Ctrl + Alt + C` kihagyja a menüt, és képernyőképet készít

Gyorsbillentyű hozzáadásakor:

1. Először a funkciója alapján válaszd ki a síkot, aztán válaszd ki a billentyűt.
2. Ne mozgass át meglévő gyorsbillentyűt, hogy helyet csinálj neki. Keress szabad billentyűt a megfelelő síkon.
3. Az `Alt` billentyűt csak az nélküle használt gyorsbillentyű változatához használd.

Néhány gyorsbillentyű megszegi ezeket a szabályokat, mert úgy kényelmes. A `Shift` nyílbillentyűvel vagy a `Tab` billentyűvel együtt mozgat vagy visszafelé lép ahelyett, hogy alkalmazást nyitna, a `Print`, a médiabillentyűk, az `Alt + Tab` és a `Ctrl + Alt + Del` pedig úgy működnek, ahogy mindenhol máshol is. Ezek kivételek, nem követendő minták.

Ha egy alapértelmezés nem felel meg neked (mondjuk a képernyőképekhez a Windowson megszokott `Super + Shift + S` kombinációt szeretnéd), kösd át a `~/.config/hypr/bindings.lua` fájlban.

## Navigálás

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy menü (alkalmazások és minden más) |
| `Super + Alt + Space` | Alkalmazásrács |
| `Super + Escape` | Rendszermenü (felfüggesztés, újraindítás stb.) |
| `Super + Ctrl + L` | Számítógép zárolása |
| `Super + W` or `Super + Q` | Ablak bezárása |
| `Ctrl + Alt + Del` | Összes ablak bezárása |
| `Super + K` | Összes gyorsbillentyű megjelenítése |
| `Super + Alt + K` | Tmux gyorsbillentyűk megjelenítése |
| `Super + Ctrl + K` | Herdr gyorsbillentyűk megjelenítése |
| `Super + M` | Ablak minimalizálása a dokkra |
| `Super + T` | Ablak váltása csempézett/lebegő mód között |
| `Super + J` | Ablak pozíciójának váltása (vízszintes/függőleges) |
| `Super + O` | Ablak átváltása rögzített és lebegő módba |
| `Super + L` | Váltás a dwindle, scrolling és floating elrendezések között |
| `Super + Alt + L` | Elrendezések közötti váltás fordított irányban |
| `Super + P` | Pseudo ablakstílus váltása (natural és stretch között) |
| `Super + F` | Teljes képernyő |
| `Super + Alt + F` | Teljes szélesség |
| `Super + Ctrl + F` | Teljes képernyő az ablakon belül |
| `Super + 1…9/0` | Ugrás adott munkaterületre (a 0 a 10-es) a fókuszban lévő monitoron |
| `Super + Tab` | Ugrás a következő munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + Tab` | Ugrás az előző munkaterületre a fókuszban lévő monitoron |
| `Super + Ctrl + Tab` | Ugrás a korábbi munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + 1…9/0` | Ablak áthelyezése munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + Alt + 1…9/0` | Ablak áthelyezése munkaterületre a fókuszban lévő monitoron, követés nélkül |
| `Super + S` | Teljes scratchpad be-/kikapcsolása |
| `Super + Alt + S` | Ablak áthelyezése a teljes scratchpadra |
| `Super + the key above Tab` (grave on US layouts) | Quake konzol be-/kikapcsolása |
| `Super + Shift + the key above Tab` (grave on US layouts) | Ablak áthelyezése a Quake konzolra |
| `Super + Shift + Ctrl + Arrows` | Ablak áthelyezése az adott irányban lévő monitorra |
| `Super + Shift + Alt + Arrows` | Munkaterület áthelyezése az adott irányban lévő monitorra |
| `Super + Arrow` | Fókusz áthelyezése a nyíl irányában lévő ablakra, a képernyő szélén átlépve az azon az oldalon lévő monitorra |
| `Super + Shift + Arrow` | Ablak cseréje a nyíl irányában lévő másik ablakkal, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Minus` | Ablak kiszélesítése balra |
| `Super + Equal` | Ablak keskenyítése balra |
| `Super + Shift + Minus` | Ablak kicsinyítése felfelé |
| `Super + Shift + Equal` | Ablak nagyítása lefelé |
| `Super + Alt + Minus/Equal` | Ugyanaz az átméretezés kisebb lépésekben |
| `Super + Ctrl + Minus/Equal` | Ugyanaz az átméretezés nagyobb lépésekben |
| `Super + Alt + Home` | Ablak szélességének mentése |
| `Super + Home` | Mentett ablakszélesség visszaállítása |
| `Super + Left Mouse` | Ablak húzása |
| `Super + Right Mouse` | Ablak átméretezése |
| `Super + Scroll Wheel` | Görgetés a fókuszban lévő monitor munkaterületei között |
| `Super + G` | Ablakcsoportosítás be-/kikapcsolása |
| `Super + Alt + G` | Ablak kiemelése a csoportból |
| `Super + Alt + Tab` | Váltás a csoportban lévő ablakok között |
| `Super + Alt + Shift + Tab` | Váltás visszafelé a csoportban lévő ablakok között |
| `Super + Alt + Scroll Wheel` | Váltás a csoportban lévő ablakok között |
| `Super + Alt + 1/2/3/4/5` | Ugrás adott ablakra a csoportban |
| `Super + Alt + Arrow` | Ablak áthelyezése csoportba a nyíl irányában, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Ctrl + Left/Right` | Mozgás az ablakok között egy csempézett csoporton belül |
| `Super + Ctrl + Z` | Nagyítás a képernyőn (ismétléssel tovább nagyít) |
| `Super + Ctrl + Alt + Z` | Teljes kicsinyítés a képernyőről |
| `Super + /` | Lépés előre a monitor méretezési beállításai között |
| `Super + Alt + /` | Lépés visszafelé a monitor méretezési beállításai között |
| `Alt + Tab` | Váltás előre az aktív munkaterület ablakai között |
| `Alt + Shift + Tab` | Váltás visszafelé az aktív munkaterület ablakai között |
| `Ctrl + Alt + Tab` | Fókusz váltása előre a monitorok között |
| `Ctrl + Alt + Shift + Tab` | Fókusz váltása visszafelé a monitorok között |
| `Super + I` | Beviteli nyelv váltása (több kiosztás vagy beviteli mód esetén) |
| `Super + Shift + I` | Beviteli nyelv visszaváltása |

Érintőpadon a három- és négyujjas húzások munkaterületeket váltanak, ablakokat mozgatnak, és megnyitják a menüt és a Quake konzolt; a mozdulatokért lásd a [billentyűzet, egér és érintőpad](34-keyboard-mouse-trackpad.md) fejezetet.

Az átméretező gyorsbillentyűk a `code:20` és `code:21` fizikai billentyűket használják (XKB `<AE11>` és `<AE12>`), függetlenül a billentyűkre nyomtatott karakterektől. US billentyűzeteken ezek a `-` és `=` billentyűk; japán (JIS) billentyűzeteken a `-` és `^`; spanyol billentyűzeteken a `'` és `¡`. JIS kiosztáson a `Super + ^` a `Super + Equal`, míg a `Super + Shift + -` (amely `=` jelet ír) a `Super + Shift + Minus`.

## Rendszervezérlés

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Hangpanel |
| `Super + Ctrl + B` | Bluetooth panel |
| `Super + Ctrl + N` | Wi-Fi/hálózati panel |
| `Super + Ctrl + D` | Kijelzőpanel |
| `Super + Ctrl + P` | Energiapanel |
| `Super + Ctrl + X` | Ügynökök panel |
| `Super + Ctrl + Alt + X` | Helyi modellek panel |
| `Super + Ctrl + Alt + D` | Naptárpanel |
| `Super + Ctrl + Alt + E` | Világórapanel |
| `Super + Ctrl + 1-9` | Sávpanel be-/kikapcsolása pozíció szerint |
| `Super + Ctrl + S` | Megosztás menü (LocalSend használatával) |
| `Super + Ctrl + C` | Rögzítésvezérlés (képernyőkép/-felvétel/választó) |
| `Super + Ctrl + O` | Menü be-/kikapcsolása |
| `Super + Ctrl + H` | Hardvermenü |
| `Super + Ctrl + E` | Emojiválasztó |
| `Super + Ctrl + .` | Média átkódolása |
| `Super + Shift + Ctrl + A` | Alapértelmezett ügynök indítása |
| `Power` key | Rendszermenü |
| `Super + Shift + Copilot` key | Omarchy menü |

## Beállítások

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximális képernyő-fényerő |
| `Shift + Brightness Down` | Minimális képernyő-fényerő |
| `Alt + Brightness Up/Down` | Pontos, 1%-os fényerő-változtatás |
| `Alt + Volume Up/Down` | Pontos, 1%-os hangerő-változtatás |
| `Keyboard Brightness Up/Down` | Billentyűzet-háttérvilágítás erősebb/gyengébb |
| `Keyboard Backlight` | Billentyűzet-háttérvilágítás szintjeinek váltása |
| `Ctrl + Brightness Up/Down` | Billentyűzet-háttérvilágítás erősebb/gyengébb, saját billentyűk nélküli billentyűzeteken |
| `Mic Mute` | Mikrofon némítása |
| `Shift + Mute` | Hangkimenet váltása |
| `Touchpad Toggle` | Érintőpad be- vagy kikapcsolása |
| `Display` key | Munkaterület-elrendezés váltása |
| `Alt + Play` | Következő szám |
| `Alt + Shift + Play` | Előző szám |

## Alkalmazások indítása

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + Return` | Terminál |
| `Super + Alt + Return` | Tmux terminál |
| `Super + Ctrl + Return` | Herdr (ügynökkezelő) |
| `Super + Shift + Return` or `Super + Shift + B` | Böngésző |
| `Super + Shift + Alt + B` | Böngésző (privát/inkognitó) |
| `Super + Shift + F` | Fájlkezelő |
| `Super + Shift + Alt + F` | Fájlkezelő a terminál cwd könyvtárában |
| `Super + Shift + M` | Zene (Spotify) |
| `Super + Shift + Alt + M` | Zene (cliamp) |
| `Super + Shift + /` | Jelszókezelő (1password) |
| `Super + Shift + Q` or `Calculator` key | Számológép (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, ha telepítve van) |
| `Super + Shift + T` | Aktivitás (btop) |
| `Super + Shift + N` | Szerkesztő (Plain, vagy a választott alapértelmezett) |
| `Super + Shift + C` | Naptár ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-mail ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Új e-mail ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Az alapértelmezett ügynököd, vagy a ChatGPT, amíg nem választasz egyet |
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

A kiosztásokat a `~/.config/hypr/bindings.lua` fájlban módosíthatod vagy egészítheted ki.

## Univerzális vágólap

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + A` | Összes kijelölése azokban az alkalmazásokban, amelyek támogatják a `Ctrl + A` kombinációt |
| `Super + C` | Másolás |
| `Super + X` | Kivágás (terminálban nem) |
| `Super + V` | Beillesztés |
| `Super + Ctrl + V` | Vágólapkezelő |

Linuxon általában a `Ctrl + Shift + C/V` kell a terminálban való másoláshoz és beillesztéshez, a `Ctrl + C/V` pedig mindenhol máshol. Ezek az Omarchy egységes vágólap-gyorsbillentyűi mindenhol működnek.

## Rögzítés

| Gyorsbillentyű | Funkció |
| ------------------- | ------------------------------ |
| `Print Screen` | Képernyőkép |
| `Super + Ctrl + Alt + C` | Képernyőkép (ugyanaz a felvétel, Print Screen billentyű nélküli billentyűzetekhez) |
| `Super + Ctrl + C` | Rögzítési menü |
| `Alt + Print Screen` | Képernyőfelvétel |
| `Super + Shift + Ctrl + Alt + C` | Képernyőfelvétel hang nélkül, a menü kihagyásával (a leállításhoz nyomd meg újra) |
| `Super + Print Screen` | Színválasztó |
| `Super + Ctrl + Print Screen` | Szöveg kinyerése a vágólapra |
| `Super + Alt + [` | Webkamera-fedvény kisebbé tétele felvétel közben |
| `Super + Alt + ]` | Webkamera-fedvény nagyobbá tétele felvétel közben |
| `Alt + Shift + L` | Aktuális URL másolása webalkalmazásból vagy böngészőből |
| `Alt + Shift + D` | Az aktuális oldalon lévő videó letöltése a `~/Videos` mappába |
| `Alt + Space` | Diktálás indítása/leállítása (szükséges hozzá: _Setup > Defaults > Dictation_) |
| `Right Alt` | Tartsd lenyomva a diktáláshoz (szükséges hozzá: _Setup > Defaults > Dictation_) |

Képernyőfelvételeknél a gyorsbillentyű először megkérdezi, milyen hangot szeretnél, majd elindítja a felvételt. A leállításhoz nyomd meg újra. A részletekért lásd a [képernyőképek és rögzítés](12-screenshots-recording.md) fejezetet.

Az összes rögzítési lehetőség az Omarchy menü (`Super + Space`) _Trigger > Capture_ pontjában is elérhető.

## Értesítések

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + ,` | Művelet a legutóbbi értesítésen: megnyitása vagy egyetlen gombjának megnyomása, választás a lehetőségei közül, vagy elvetése, ha egy sem van |
| `Super + Shift + ,` | Összes értesítés elvetése |
| `Super + Ctrl + ,` | Értesítések vezérlése billentyűzettel |
| `Super + Alt + ,` | Legutóbbi értesítés elvetése |
| `Super + Shift + Alt + ,` | Értesítési előzmények megnyitása |
| `Super + Ctrl + Alt + ,` | Értesítések némításának be-/kikapcsolása |

## Stílus

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Új téma választása (másként `Super + Ctrl + Shift + Space` is) |
| `Super + Ctrl + W` | Témaháttér választása (másként `Super + Ctrl + Space` is) |
| `Super + Backspace` | Ablak átlátszóságának be-/kikapcsolása |
| `Super + Ctrl + Backspace` | Egyablakos négyzetes képarány be-/kikapcsolása |

További háttérképek a `~/.config/omarchy/backgrounds/<theme name>` mappában találhatók. Az Omarchy menü _Install > Style > Background_ pontján keresztül is elérhetők.

Az összes stílusbeállítás az Omarchy menü (`Super + Space`) _Appearance_ pontjában is elérhető.

## Kapcsolók

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Üresjárati zárolás be-/kikapcsolása |
| `Super + Ctrl + Delete` | Laptopkijelző be-/kikapcsolása |
| `Super + Ctrl + Alt + Delete` | Laptopkijelző tükrözésének be-/kikapcsolása |
| `Super + Shift + Space` | Felső sáv be-/kikapcsolása |
| `Shift + Mute` | Váltás a következő hangkimenetre |
| `Shift + Play` | Váltás a következő médiaforrásra |
| `Super + Shift + Backspace` | Ablakhézagok be-/kikapcsolása |
| `Super + Ctrl + Alt + F` | Teljes képernyős asztal be-/kikapcsolása (felső sáv + ablakhézagok) |

## Emlékeztetők

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Emlékeztető beállítása |
| `Super + Ctrl + Alt + R` | Összes emlékeztető megtekintése |
| `Super + Ctrl + Shift + R` | Összes emlékeztető törlése |

## Jelzések

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Idő megjelenítése értesítésként |
| `Super + Ctrl + Alt + B` | Akkumulátor megjelenítése értesítésként |
| `Super + Ctrl + Alt + W` | Időjárás értesítésként való megjelenítésének be-/kikapcsolása |

## Tmux

Az előtagbillentyű a `Ctrl + Space` (a `Ctrl + B` is működik). Ezeket a kiosztásokat a `~/.config/tmux/tmux.conf` fájlban módosíthatod.

### Panelek

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Prefix + v` | Panel felosztása mellé (függőleges) |
| `Prefix + h` | Panel felosztása alá (vízszintes) |
| `Prefix + x` | Panel megszüntetése |
| `Prefix + z` | Panelnagyítás be-/kikapcsolása (teljes képernyő) |
| `Alt + Enter` | Panel felosztása alá (előtag nélkül) |
| `Alt + Shift + Enter` | Panel felosztása mellé (előtag nélkül) |
| `Alt + Escape` | Panel megszüntetése (előtag nélkül) |
| `Ctrl + Alt + Arrows` | Mozgás a panelek között |
| `Ctrl + Alt + Shift + Arrows` | Panelek átméretezése |

### Ablakok

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Prefix + c` | Új ablak |
| `Prefix + k` | Ablak megszüntetése |
| `Prefix + r` | Ablak átnevezése |
| `Alt + 1-9` | Ugrás adott ablakra |
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

### Másolási mód (vi-stílusú)

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Prefix + [` | Belépés másolási módba |
| `v` | Kijelölés megkezdése (másolási módban) |
| `y` | Kijelölés másolása (másolási módban) |

### Általános

| Gyorsbillentyű | Funkció |
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

A Ghostty terminál az Omarchy menü _Install > Terminal_ pontján keresztül telepíthető.

| Gyorsbillentyű | Funkció |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Új felosztás alul |
| `Ctrl + Shift + O` | Új felosztás mellette |
| `Ctrl + Alt + Arrows` | Mozgás a felosztások között |
| `Super + Ctrl + Shift + Arrows` | Felosztás átméretezése 10 sorral |
| `Super + Ctrl + Shift + Alt + Arrows` | Felosztás átméretezése 100 sorral |
| `Ctrl + Shift + T` | Új lap |
| `Ctrl + Shift + Arrows` | Mozgás a lapok között |
| `Alt + Numbers` | Ugrás adott lapra |
| `Shift + Pg Up/Down` | Előzmények görgetése |
| `Ctrl + Left mouse` | Hivatkozás megnyitása böngészőben |

## File Manager

| Gyorsbillentyű | Funkció |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Ugrás útvonalra |
| `Space` | Fájl előnézete (a nyilakkal lehet navigálni) |
| `Alt + Up` | Fel a szülőmappába |

## Neovim (w/ lazyvim)

### Navigálás

| Gyorsbillentyű | Funkció |
| ------------------------ | ------------------------------- |
| `Space` | Parancsbeállítások megjelenítése |
| `Space Space` | Fájl megnyitása fuzzy kereséssel |
| `Space E` | Oldalsáv be-/kikapcsolása |
| `Space G G` | Git vezérlők megjelenítése |
| `Space S G` | Fájltartalom keresése |
| `Ctrl + W W` | Ugrás az oldalsáv és a szerkesztő között |
| `Ctrl + Left/right arrow` | Oldalsáv méretének módosítása |
| `Shift + H` | Ugrás a bal oldali fájllapra |
| `Shift + L` | Ugrás a jobb oldali fájllapra |
| `Space B D` | Fájllap bezárása |

### Az oldalsávban

| Gyorsbillentyű | Funkció |
| ------------------------ | ------------------------------- |
| `A` | Új fájl hozzáadása a szülőkönyvtárban |
| `Shift + A` | Új alkönyvtár hozzáadása a szülőkönyvtárban |
| `D` | Kiemelt fájl/könyvtár törlése |
| `M` | Kiemelt fájl/könyvtár áthelyezése |
| `R` | Kiemelt fájl/könyvtár átnevezése |
| `?` | Súgó megjelenítése az összes parancshoz |

[Tekintsd meg a LazyVim által beállított összes Neovim gyorsbillentyűt](https://www.lazyvim.org/keymaps).

## Gyors emojik

A `Super + Ctrl + E` billentyűkombinációval megjeleníthetsz egy teljes emojiválasztót, amely a kiválasztott elemet a vágólapra helyezi, vagy használhatod ezeket a gyorselérési lehetőségeket.

| Gyorsbillentyű | EM | Tipp |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | mosoly |
| `Shift + CapsLock M C` | 😂 | sírás |
| `Shift + CapsLock M L` | 😍 | szerelem |
| `Shift + CapsLock M V` | ✌️ | győzelem |
| `Shift + CapsLock M H` | ❤️ | szív |
| `Shift + CapsLock M Y` | 👍 | igen |
| `Shift + CapsLock M N` | 👎 | nem |
| `Shift + CapsLock M F` | 🖕 | baszd meg |
| `Shift + CapsLock M W` | 🤞 | kívánság |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | csók |
| `Shift + CapsLock M E` | 🙄 | szemforgatás |
| `Shift + CapsLock M I` | 😉 | kacsintás |
| `Shift + CapsLock M P` | 🙏 | imádkozás |
| `Shift + CapsLock M D` | 🤤 | nyálcsorgatás |
| `Shift + CapsLock M M` | 💰 | pénz |
| `Shift + CapsLock M X` | 🎉 | ünneplés |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | koccintás |
| `Shift + CapsLock M O` |👌 | oké |
| `Shift + CapsLock M G` |👋 | üdvözlés |
| `Shift + CapsLock M A` |💪 | kar |
| `Shift + CapsLock M B` |🤯 | robbanó fej |

## Gyors kiegészítések

| Gyorsbillentyű | Kiegészítés |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (gondolatjel) |
| `Shift + CapsLock Space N` | A neved (ahogy a beállításkor megadtad) |
| `Shift + CapsLock Space E` | Az e-mail címed (ahogy a beállításkor megadtad) |

Továbbiakat is hozzáadhatsz a `~/.XCompose` szerkesztésével, majd futtasd a terminálban az `omarchy restart xcompose` parancsot, hogy a változások érvénybe lépjenek.
