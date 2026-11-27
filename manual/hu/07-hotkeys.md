# Gyorsbillentyűk

Az összes fő billentyűkombinációt a `Super + K` billentyűkombinációval nézheted meg (a Tmux kötéseit a `Super + Alt + K`, a Herdr kötéseit a `Super + Ctrl + K` billentyűkombinációval).

## Hogyan épülnek fel a gyorsbillentyűk

Minden gyorsbillentyű egy síkon ül, amelyet a módosítói határoznak meg, és minden síknak egy feladata van. Ettől nem mosódnak össze a gyorsbillentyűk, és általában ki is találhatod, mi hol lakik.

| Sík | Mi tartozik ide | Példák |
| --- | --- | --- |
| `Super + key` | A rendszer: ablakok, munkaterületek, elrendezések és alapvető menük | `Super + Space` Omarchy menü, `Super + W` ablak bezárása, `Super + F` teljes képernyő |
| `Super + Shift + key` | Alkalmazások | `Super + Shift + B` böngésző, `Super + Shift + E` e-mail, `Super + Shift + N` szerkesztő |
| `Super + Ctrl + key` | Panelek és rendszermenük | `Super + Ctrl + A` hang, `Super + Ctrl + N` hálózat, `Super + Ctrl + C` rögzítés menü |
| `Super + Ctrl + Alt + key` | Gyorsműveletek és jelzések | `Super + Ctrl + Alt + T` idő megjelenítése, `Super + Ctrl + Alt + B` akkumulátor, `Super + Ctrl + Alt + C` képernyőkép |

Ha egy gyorsbillentyűhöz hozzáadod az `Alt` billentyűt, ugyanannak a dolognak egy változatát kapod, sosem valami teljesen mást:

- A `Super + Shift + B` megnyitja a böngészőt; a `Super + Shift + Alt + B` privát ablakot nyit
- A `Super + Shift + E` megnyitja az e-mailt; a `Super + Shift + Alt + E` újat kezd
- A `Super + F` teljes képernyőre vált; a `Super + Alt + F` teljes szélességre vált
- A `Super + Ctrl + C` megnyitja a rögzítés menüt; a `Super + Ctrl + Alt + C` kihagyja a menüt, és képernyőképet készít

Gyorsbillentyű hozzáadásakor:

1. Abból válaszd ki a síkot, amit csinál, aztán válaszd ki a billentyűt.
2. Ne mozdíts el egy meglévő gyorsbillentyűt, hogy helyet csinálj neki. Keress egy szabad billentyűt a megfelelő síkon.
3. Az `Alt` billentyűt csak az nélküle működő gyorsbillentyű változatához használd.

Néhány gyorsbillentyű megszegi ezeket a szabályokat, mert úgy kényelmes. A `Shift` nyíllal vagy `Tab` billentyűvel mozgat vagy visszafelé lép, ahelyett, hogy alkalmazást nyitna, a `Print`, a médiabillentyűk, az `Alt + Tab` és a `Ctrl + Alt + Del` pedig úgy működnek, mint mindenhol máshol. Ezek kivételek, nem másolandó minták.

Ha egy alapértelmezés nem felel meg neked (mondjuk a Windowson megszokott módon `Super + Shift + S` billentyűkombinációt szeretnél a képernyőképekhez), kösd újra a `~/.config/hypr/bindings.lua` fájlban.

## Navigáció

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
| `Super + M` | Ablak lekicsinyítése a dokkra |
| `Super + T`               | Ablak váltása csempézett/lebegő mód között             |
| `Super + J` | Ablak pozíciójának váltása (vízszintes/függőleges) |
| `Super + O`               | Ablak átváltása ragadós és lebegő módba |
| `Super + L`               | Váltás a dwindle, a scrolling és a floating elrendezések között |
| `Super + Alt + L`         | Váltás az elrendezések között fordított irányban |
| `Super + P`               | Ál-ablakstílus váltása (természetes vagy nyújtott) |
| `Super + F`                 | Teljes képernyő              |
| `Super + Alt + F`                 | Teljes szélesség              |
| `Super + Ctrl + F`                 | Teljes képernyő az ablakon belül              |
| `Super + 1…9/0`         | Ugrás egy adott munkaterületre (a 0 a 10-es) a fókuszban lévő monitoron |
| `Super + Tab` | Ugrás a következő munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + Tab` | Ugrás az előző munkaterületre a fókuszban lévő monitoron |
| `Super + Ctrl + Tab` | Ugrás a korábbi munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + 1…9/0` | Ablak áthelyezése munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + Alt + 1…9/0` | Ablak áthelyezése munkaterületre a fókuszban lévő monitoron, követés nélkül |
| `Super + S` | Teljes scratchpad ki-/bekapcsolása |
| `Super + Alt + S` | Ablak áthelyezése a teljes scratchpadre |
| `Super + the key above Tab` (grave on US layouts) | Quake konzol ki-/bekapcsolása |
| `Super + Shift + the key above Tab` (grave on US layouts) | Ablak áthelyezése a Quake konzolba |
| `Super + Shift + Ctrl + Arrows` | Ablak áthelyezése az adott irányban lévő monitorra |
| `Super + Shift + Alt + Arrows` | Munkaterület áthelyezése az adott irányban lévő monitorra |
| `Super + Arrow`  | Fókusz áthelyezése a nyíl irányában lévő ablakra, a képernyő szélén átlépve az azon az oldalon lévő monitorra |
| `Super + Shift + Arrow`  | Ablak felcserélése a nyíl irányában lévő másik ablakkal, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Minus` | Ablak szélesítése balra |
| `Super + Equal` | Ablak szűkítése balra |
| `Super + Shift + Minus` | Ablak szűkítése felfelé |
| `Super + Shift + Equal` | Ablak szélesítése lefelé |
| `Super + Alt + Minus/Equal` | Ugyanez az átméretezés kisebb lépésekben |
| `Super + Ctrl + Minus/Equal` | Ugyanez az átméretezés nagyobb lépésekben |
| `Super + Alt + Home` | Ablak szélességének mentése |
| `Super + Home` | Mentett ablakszélesség visszaállítása |
| `Super + Left Mouse` | Ablak húzása |
| `Super + Right Mouse` | Ablak átméretezése |
| `Super + Scroll Wheel` | Görgetés a munkaterületek között a fókuszban lévő monitoron |
| `Super + G`               | Ablakcsoportosítás ki-/bekapcsolása      |
| `Super + Alt + G`               | Ablak kivétele a csoportból      |
| `Super + Alt + Tab`               | Váltás a csoportban lévő ablakok között      |
| `Super + Alt + Shift + Tab`               | Váltás visszafelé a csoportban lévő ablakok között      |
| `Super + Alt + Scroll Wheel` | Váltás a csoportban lévő ablakok között |
| `Super + Alt + 1/2/3/4/5`               | Ugrás egy adott ablakra a csoportban      |
| `Super + Alt + Arrow`  | Ablak áthelyezése csoportba a nyíl irányában, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Ctrl + Left/Right`  | Mozgás a csempézett csoporton belüli ablakok között |
| `Super + Ctrl + Z` | Nagyítás a képernyőn (ismételd a nagyobb nagyításhoz) |
| `Super + Ctrl + Alt + Z` | Teljes kicsinyítés a képernyőről |
| `Super + /` | Lépés előre a monitor méretezési lehetőségei között |
| `Super + Alt + /` | Lépés hátra a monitor méretezési lehetőségei között |
| `Alt + Tab` | Váltás előre az aktív munkaterület ablakai között |
| `Alt + Shift + Tab` | Váltás visszafelé az aktív munkaterület ablakai között |
| `Ctrl + Alt + Tab`| Fókusz váltása előre a monitorok között |
| `Ctrl + Alt + Shift + Tab`| Fókusz váltása visszafelé a monitorok között |
| `Super + I` | Beviteli nyelv váltása (több kiosztás vagy beviteli mód esetén) |
| `Super + Shift + I` | Beviteli nyelv visszaváltása |

Érintőpadon a három- és négyujjas simítások munkaterületeket váltanak, ablakokat mozgatnak, és megnyitják a menüt és a Quake konzolt; a mozdulatokat lásd itt: [billentyűzet, egér és érintőpad](34-keyboard-mouse-trackpad.md).

Az átméretezés a 0-tól jobbra lévő két billentyűt használja, bármit is nyomtattak rájuk a billentyűzeteden: `-` és `=` az amerikai billentyűzeteken, `+` és `´` a dán és svéd, `+` és `\` a norvég, `ß` és `´` a német, `'` és `¡` a spanyol, `-` és `^` pedig a japán (JIS) billentyűzeteken. A `Super + K` úgy sorolja fel őket, ahogyan a billentyűzetedre nyomtatták őket. JIS esetén a `Super + ^` a `Super + Equal`, míg a `Super + Shift + -` (amely `=` jelet ír) a `Super + Shift + Minus`. A monitor méretezése és a jelszókezelő a `/` billentyűt használja; azokon a kiosztásokon, amelyek a `/` jelet csak Shifttel írják, mint a legtöbb európai, ehelyett a jobb Shift billentyűtől balra lévő billentyűt használják (dán és német esetén `-`).

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
| `Super + Ctrl + Alt + E`           | Világóra panel    |
| `Super + Ctrl + 1-9`           | Sávpanel ki-/bekapcsolása pozíció szerint    |
| `Super + Ctrl + S` | Megosztás menü (a LocalSend segítségével) |
| `Super + Ctrl + C` | Rögzítésvezérlők (képernyőkép/-felvétel/választó) |
| `Super + Ctrl + O` | Menü ki-/bekapcsolása |
| `Super + Ctrl + H` | Hardvermenü |
| `Super + Ctrl + E` | Emojiválasztó |
| `Super + Ctrl + .` | Média átkódolása |
| `Super + Shift + Ctrl + A` | Alapértelmezett ágensed indítása |
| `Power` key | Rendszermenü |
| `Super + Shift + Copilot` key | Omarchy menü |

## Állítások

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximális képernyő-fényerő |
| `Shift + Brightness Down` | Minimális képernyő-fényerő |
| `Alt + Brightness Up/Down` | Pontos, 1%-os fényerő-változtatások |
| `Alt + Volume Up/Down` | Pontos, 1%-os hangerő-változtatások |
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

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminál    |
| `Super + Alt + Return` | Tmux terminál |
| `Super + Ctrl + Return` | Herdr (ágenskezelő) |
| `Super + Shift + Return` or `Super + Shift + B`  | Böngésző    |
| `Super + Shift + Alt + B`           | Böngésző (privát/inkognitó)    |
| `Super + Shift + F`           | Fájlkezelő    |
| `Super + Shift + Alt + F`           | Fájlkezelő a terminál cwd-jében    |
| `Super + Shift + M`           | Zene (Spotify)    |
| `Super + Shift + Alt + M`           | Zene (cliamp)    |
| `Super + Shift + /`           | Jelszókezelő (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Számológép (Omacalc)    |
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

A kötéseket a `~/.config/hypr/bindings.lua` fájlban módosíthatod / adhatsz hozzá újakat.

## Univerzális vágólap

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + A`           | Összes kijelölése azokban az alkalmazásokban, amelyek támogatják a `Ctrl + A` billentyűkombinációt    |
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
| `Super + Shift + Ctrl + Alt + C` | Képernyőfelvétel hang nélkül, a menü kihagyásával (nyomd meg újra a leállításhoz) |
| `Super + Print Screen` | Színválasztó |
| `Super + Ctrl + Print Screen` | Szöveg kinyerése a vágólapra |
| `Super + Alt + [` | Webkamera-réteg kicsinyítése felvétel közben |
| `Super + Alt + ]` | Webkamera-réteg nagyítása felvétel közben |
| `Alt + Shift + L` | Aktuális URL másolása webalkalmazásból vagy böngészőből |
| `Alt + Shift + D` | Az aktuális oldalon lévő videó letöltése ide: `~/Videos` |
| `Alt + Space` | Diktálás indítása/leállítása (a _Setup > Defaults > Dictation_ beállítást igényli) |
| `Right Alt` | Tartsd nyomva a diktáláshoz (a _Setup > Defaults > Dictation_ beállítást igényli) |

Képernyőfelvételeknél a gyorsbillentyű először megkérdezi, milyen hangot szeretnél, aztán elindítja a felvételt. Nyomd meg újra a leállításhoz. A részleteket lásd itt: [képernyőképek és felvétel](12-screenshots-recording.md).

Az összes rögzítési lehetőség elérhető az Omarchy menü (`Super + Space`) _Trigger > Capture_ pontja alatt is.

## Értesítések

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + ,` | Művelet a legutóbbi értesítésen: megnyitása vagy egyetlen gombjának megnyomása, választás a lehetőségei közül, vagy elvetése, ha egy sincs neki  |
| `Super + Shift + ,` | Összes értesítés elvetése |
| `Super + Ctrl + ,` | Értesítések vezérlése a billentyűzettel  |
| `Super + Alt + ,` | Legutóbbi értesítés elvetése  |
| `Super + Shift + Alt + ,` | Értesítési előzmények megnyitása  |
| `Super + Ctrl + Alt + ,` | Értesítések némításának ki-/bekapcsolása  |

## Stílus

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Új téma választása (másképp: `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Téma hátterének választása (másképp: `Super + Ctrl + Space`) |
| `Super + Backspace` | Átlátszóság ki-/bekapcsolása egy ablakon |
| `Super + Ctrl + Backspace` | Egyablakos négyzetes képarány ki-/bekapcsolása |

A további háttérképek itt találhatók: `~/.config/omarchy/backgrounds/<theme name>`. Az Omarchy menü _Install > Style > Background_ pontján keresztül is elérhető.

Az összes stílusbeállítás elérhető az Omarchy menü (`Super + Space`) _Appearance_ pontja alatt is.

## Kapcsolók

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Zárolás üresjáratban ki-/bekapcsolása |
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

## Felugró jelzések

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Idő megjelenítése értesítésként  |
| `Super + Ctrl + Alt + B` | Akkumulátor megjelenítése értesítésként  |
| `Super + Ctrl + Alt + W` | Időjárás ki-/bekapcsolása értesítésként  |

## Tmux

Az előtagbillentyű a `Ctrl + Space` (a `Ctrl + B` is működik). Ezeket a kötéseket a `~/.config/tmux/tmux.conf` fájlban módosíthatod.

### Ablaktáblák

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + v` | Ablaktábla felosztása mellé (függőleges) |
| `Prefix + h` | Ablaktábla felosztása alá (vízszintes) |
| `Prefix + x` | Ablaktábla bezárása |
| `Prefix + z` | Ablaktábla nagyításának ki-/bekapcsolása (teljes képernyő) |
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
| `Prefix + ?` | Tmux billentyűkötések megjelenítése |
| `Prefix + :` | Parancssor |

### Tmux elrendezési függvények

Ezeket a függvényeket egy Tmux munkameneten belül kell futtatni.

| Parancs | Funkció |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása szerkesztővel, AI-val és terminállal |
| `tdlm <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása alkönyvtáranként |
| `tsl <count> <command>` | Több ablaktáblás swarm elrendezés létrehozása |

## Ghostty Terminal

A Ghostty terminál az Omarchy menü _Install > Terminal_ pontjával telepíthető.

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Új felosztás lent |
| `Ctrl + Shift + O` | Új felosztás mellette |
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

[Nézd meg a LazyVim által beállított összes Neovim gyorsbillentyűt](https://www.lazyvim.org/keymaps).

## Gyors emojik

Használhatod a `Super + Ctrl + E` billentyűkombinációt egy teljes emojiválasztó megjelenítéséhez, amely a választást a vágólapra helyezi, vagy használhatod ezeket a gyors elérési lehetőségeket.

| Gyorsbillentyű       | EM | Jelölés       |
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
| `Shift + CapsLock M K` | 😘 | puszi       |
| `Shift + CapsLock M E` | 🙄 | szemforgatás    |
| `Shift + CapsLock M I` | 😉 | kacsintás       |
| `Shift + CapsLock M P` | 🙏 | ima |
| `Shift + CapsLock M D` | 🤤 | nyálcsorgatás      |
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

Továbbiakat is hozzáadhatsz a `~/.XCompose` szerkesztésével, aztán futtasd az `omarchy restart xcompose` parancsot a terminálban, hogy a változások érvénybe lépjenek.
