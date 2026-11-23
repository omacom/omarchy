# Gyorsbillentyűk

Az összes fő billentyűkombinációt a `Super + K` billentyűkombinációval nézheted meg (a Tmux-kombinációkat a `Super + Alt + K`, a Herdr-kombinációkat pedig a `Super + Ctrl + K` billentyűkombinációval).

## Hogyan épülnek fel a gyorsbillentyűk

Minden gyorsbillentyű egy síkon helyezkedik el, amelyet a módosítóbillentyűi határoznak meg, és minden síknak egy feladata van. Ez akadályozza meg, hogy a gyorsbillentyűk összemosódjanak, és általában ki is tudod találni, hol található valami.

| Sík | Mi található ott | Példák |
| --- | --- | --- |
| `Super + key` | A rendszer: ablakok, munkaterületek, elrendezések és alapvető menük | `Super + Space` Omarchy menü, `Super + W` ablak bezárása, `Super + F` teljes képernyő |
| `Super + Shift + key` | Alkalmazások | `Super + Shift + B` böngésző, `Super + Shift + E` e-mail, `Super + Shift + N` szerkesztő |
| `Super + Ctrl + key` | Panelek és rendszermenük | `Super + Ctrl + A` hang, `Super + Ctrl + N` hálózat, `Super + Ctrl + C` rögzítési menü |
| `Super + Ctrl + Alt + key` | Gyors műveletek és értesítések | `Super + Ctrl + Alt + T` idő megjelenítése, `Super + Ctrl + Alt + B` akkumulátor, `Super + Ctrl + Alt + C` képernyőkép |

Ha egy gyorsbillentyűhöz hozzáadod az `Alt` billentyűt, ugyanannak a dolognak egy változatát kapod, soha nem valami teljesen mást:

- A `Super + Shift + B` megnyitja a böngészőt; a `Super + Shift + Alt + B` privát ablakot nyit meg
- A `Super + Shift + E` megnyitja az e-mailt; a `Super + Shift + Alt + E` újat kezd
- A `Super + F` teljes képernyőre vált; a `Super + Alt + F` teljes szélességre vált
- A `Super + Ctrl + C` megnyitja a rögzítési menüt; a `Super + Ctrl + Alt + C` kihagyja a menüt, és képernyőképet készít

Gyorsbillentyű hozzáadásakor:

1. Először a síkot válaszd ki aszerint, hogy mit csinál, utána a billentyűt.
2. Ne mozdíts el egy meglévő gyorsbillentyűt, hogy helyet csinálj. Keress szabad billentyűt a megfelelő síkon.
3. Az `Alt` billentyűt csak az nélküli gyorsbillentyű változatához használd.

Néhány gyorsbillentyű megszegi ezeket a szabályokat, mert úgy kényelmes. A `Shift` egy nyíllal vagy a `Tab` billentyűvel mozgat vagy visszafelé lép ahelyett, hogy alkalmazást nyitna meg, a `Print`, a médiabillentyűk, az `Alt + Tab` és a `Ctrl + Alt + Del` pedig mindenhol máshol megszokott módon működik. Ezek kivételek, nem másolandó minták.

Ha egy alapértelmezés nem felel meg neked (mondjuk szeretnéd a `Super + Shift + S` kombinációt a képernyőképekhez, mint a Windows rendszeren), kösd újra a `~/.config/hypr/bindings.lua` fájlban.

## Navigálás

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menü (alkalmazások és minden más)    |
| `Super + Alt + Space` | Alkalmazásrács |
| `Super + Escape` | Rendszermenü (felfüggesztés, újraindítás stb.)  |
| `Super + Ctrl + L` | Számítógép zárolása |
| `Super + W` vagy `Super + Q` | Ablak bezárása             |
| `Ctrl + Alt + Del` | Összes ablak bezárása |
| `Super + K` | Összes gyorsbillentyű megjelenítése |
| `Super + Alt + K` | Tmux-gyorsbillentyűk megjelenítése |
| `Super + Ctrl + K` | Herdr-gyorsbillentyűk megjelenítése |
| `Super + M` | Ablak lekicsinyítése a dokkra |
| `Super + T`               | Ablak váltása csempézés/lebegés között             |
| `Super + J` | Ablak helyzetének váltása (vízszintes/függőleges) |
| `Super + O`               | Ablak kiugratásának váltása ragadós és lebegő állapotba |
| `Super + L`               | Váltás a dwindle, görgető és lebegő elrendezések között |
| `Super + Alt + L`         | Váltás az elrendezések között visszafelé |
| `Super + P`               | Álblakstílus váltása (természetes vagy nyújtott) |
| `Super + F`                 | Teljes képernyőre váltás              |
| `Super + Alt + F`                 | Teljes szélességre váltás              |
| `Super + Ctrl + F`                 | Teljes képernyőre váltás az ablakon belül              |
| `Super + 1…9/0`         | Ugrás egy adott munkaterületre (a 0 a 10-es) a fókuszban lévő monitoron |
| `Super + Tab` | Ugrás a következő munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + Tab` | Ugrás az előző munkaterületre a fókuszban lévő monitoron |
| `Super + Ctrl + Tab` | Ugrás a korábbi munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + 1…9/0` | Ablak áthelyezése munkaterületre a fókuszban lévő monitoron |
| `Super + Shift + Alt + 1…9/0` | Ablak áthelyezése munkaterületre a fókuszban lévő monitoron anélkül, hogy követné |
| `Super + S` | Teljes scratchpad váltása |
| `Super + Alt + S` | Ablak áthelyezése teljes scratchpadra |
| `Super + Grave` | Quake konzol váltása |
| `Super + Shift + Grave` | Ablak áthelyezése Quake konzolra |
| `Super + Shift + Ctrl + Arrows` | Ablak áthelyezése az adott irányban lévő monitorra |
| `Super + Shift + Alt + Arrows` | Munkaterület áthelyezése az adott irányban lévő monitorra |
| `Super + Arrow`  | Fókusz áthelyezése a nyíl irányában lévő ablakra, a képernyő szélén átlépve az azon az oldalon lévő monitorra |
| `Super + Shift + Arrow`  | Ablak felcserélése egy másikkal a nyíl irányában, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Minus` | Ablak szélesítése balra |
| `Super + Equal` | Ablak keskenyítése balra |
| `Super + Shift + Minus` | Ablak keskenyítése felfelé |
| `Super + Shift + Equal` | Ablak szélesítése lefelé |
| `Super + Alt + Minus/Equal` | Ugyanez az átméretezés kisebb lépésekben |
| `Super + Ctrl + Minus/Equal` | Ugyanez az átméretezés nagyobb lépésekben |
| `Super + Alt + Home` | Ablak szélességének mentése |
| `Super + Home` | Mentett ablakszélesség visszaállítása |
| `Super + Left Mouse` | Ablak húzása |
| `Super + Right Mouse` | Ablak átméretezése |
| `Super + Scroll Wheel` | Görgetés a munkaterületek között a fókuszban lévő monitoron |
| `Super + G`               | Ablakcsoportosítás váltása      |
| `Super + Alt + G`               | Ablak kivétele a csoportosításból      |
| `Super + Alt + Tab`               | Váltás a csoportosításban lévő ablakok között      |
| `Super + Alt + Shift + Tab`               | Váltás visszafelé a csoportosításban lévő ablakok között      |
| `Super + Alt + Scroll Wheel` | Váltás a csoportosításban lévő ablakok között |
| `Super + Alt + 1/2/3/4/5`               | Ugrás egy adott ablakra a csoportosításban      |
| `Super + Alt + Arrow`  | Ablak áthelyezése a csoportosításba a nyíl irányában, beleértve az azon az oldalon lévő monitoron lévőt is |
| `Super + Ctrl + Left/Right`  | Mozgás a csempézési csoporton belüli ablakok között |
| `Super + Ctrl + Z` | Nagyítás a képernyőn (ismételd a nagyobb nagyításhoz) |
| `Super + Ctrl + Alt + Z` | Teljes kicsinyítés a képernyőről |
| `Super + /` | Lépés előre a monitor méretezési lehetőségei között |
| `Super + Alt + /` | Lépés visszafelé a monitor méretezési lehetőségei között |
| `Alt + Tab` | Váltás előre az aktív munkaterületen lévő ablakok között |
| `Alt + Shift + Tab` | Váltás visszafelé az aktív munkaterületen lévő ablakok között |
| `Ctrl + Alt + Tab`| Fókusz váltása előre a monitorok között |
| `Ctrl + Alt + Shift + Tab`| Fókusz váltása visszafelé a monitorok között |
| `Super + I` | Beviteli nyelv váltása (egynél több elrendezéssel vagy beviteli módszerrel) |
| `Super + Shift + I` | Beviteli nyelv visszafelé váltása |

Érintőpadon a három- és négyujjas simítások munkaterületeket váltanak, ablakokat mozgatnak, valamint megnyitják a menüt és a Quake konzolt; a mozdulatokat lásd a [billentyűzet, egér és érintőpad](34-keyboard-mouse-trackpad.md) részben.

Az átméretezési gyorsbillentyűk a `code:20` és `code:21` fizikai billentyűket használják (XKB `<AE11>` és `<AE12>`), függetlenül attól, milyen karakterek vannak a billentyűzetre nyomtatva. Az amerikai billentyűzeteken ezek a billentyűk a `-` és `=`; a japán (JIS) billentyűzeteken a `-` és `^`; a spanyol billentyűzeteken pedig a `'` és `¡`. A JIS billentyűzeten a `Super + ^` a `Super + Equal`, míg a `Super + Shift + -` (amely `=` jelet ír) a `Super + Shift + Minus`.

## Rendszervezérlők

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Hangpanel    |
| `Super + Ctrl + B`           | Bluetooth panel    |
| `Super + Ctrl + N`           | Wifi/hálózati panel    |
| `Super + Ctrl + D`           | Megjelenítési panel    |
| `Super + Ctrl + P`           | Energiapanel    |
| `Super + Ctrl + X`           | Agents panel    |
| `Super + Ctrl + Alt + X`           | Helyi modellek panel    |
| `Super + Ctrl + Alt + D`           | Naptár panel    |
| `Super + Ctrl + Alt + E`           | Világóra panel    |
| `Super + Ctrl + 1-9`           | Sávpanel váltása pozíció szerint    |
| `Super + Ctrl + S` | Megosztási menü (a LocalSend segítségével) |
| `Super + Ctrl + C` | Rögzítési vezérlők (képernyőkép/-felvétel/választó) |
| `Super + Ctrl + O` | Menü váltása |
| `Super + Ctrl + H` | Hardver menü |
| `Super + Ctrl + E` | Emoji választó |
| `Super + Ctrl + .` | Média átkódolása |
| `Super + Shift + Ctrl + A` | Alapértelmezett agented elindítása |
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
| `Keyboard Backlight` | Váltás a billentyűzet-háttérvilágítás szintjei között |
| `Ctrl + Brightness Up/Down` | Billentyűzet-háttérvilágítás erősebb/gyengébb olyan billentyűzeteken, amelyeken nincsenek saját billentyűk ehhez |
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
| `Super + Ctrl + Return` | Herdr (agentkezelő) |
| `Super + Shift + Return` vagy `Super + Shift + B`  | Böngésző    |
| `Super + Shift + Alt + B`           | Böngésző (privát/inkognitó)    |
| `Super + Shift + F`           | Fájlkezelő    |
| `Super + Shift + Alt + F`           | Fájlkezelő a terminál aktuális könyvtárában    |
| `Super + Shift + M`           | Zene (Spotify)    |
| `Super + Shift + Alt + M`           | Zene (cliamp)    |
| `Super + Shift + /`           | Jelszókezelő (1password)    |
| `Super + Shift + Q` vagy `Calculator` key  | Számológép (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, ha telepítve van)    |
| `Super + Shift + T`           | Tevékenység (btop)    |
| `Super + Shift + N`           | Szerkesztő (Plain, vagy a választott alapértelmezetted)  |
| `Super + Shift + C`           | Naptár ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Új e-mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Alapértelmezett agented, vagy a ChatGPT, amíg nem választasz egyet |
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

A hozzárendeléseket a `~/.config/hypr/bindings.lua` fájlban módosíthatod/adhatod hozzá.

## Univerzális vágólap

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + A`           | Összes kijelölése azokban az alkalmazásokban, amelyek támogatják a `Ctrl + A` kombinációt    |
| `Super + C`           | Másolás    |
| `Super + X`           | Kivágás (terminálban nem)    |
| `Super + V`           | Beillesztés    |
| `Super + Ctrl + V`           | Vágólapkezelő    |

Linuxon általában a `Ctrl + Shift + C/V` kombinációra van szükség a másoláshoz és beillesztéshez a terminálban, és a `Ctrl + C/V` kombinációra mindenhol máshol. Ezek az Omarchy egységes vágólap-gyorsbillentyűi mindenhol működnek.

## Rögzítés

| Gyorsbillentyű              | Funkció                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Képernyőkép                      |
| `Super + Ctrl + Alt + C`            | Képernyőkép (ugyanaz a felvétel, olyan billentyűzetekhez, amelyeken nincs Print Screen billentyű) |
| `Super + Ctrl + C` | Rögzítési menü |
| `Alt + Print Screen`            | Képernyőfelvétel                     |
| `Super + Shift + Ctrl + Alt + C` | Képernyőfelvétel hang nélkül, a menü kihagyásával (nyomd meg újra a leállításhoz) |
| `Super + Print Screen` | Színválasztó |
| `Super + Ctrl + Print Screen` | Szöveg kinyerése a vágólapra |
| `Super + Alt + [` | Webkamera-fedvény kisebbé tétele felvétel közben |
| `Super + Alt + ]` | Webkamera-fedvény nagyobbá tétele felvétel közben |
| `Alt + Shift + L` | Aktuális URL másolása webalkalmazásból vagy böngészőből |
| `Alt + Shift + D` | Az aktuális oldalon lévő videó letöltése a `~/Videos` mappába |
| `Alt + Space` | Diktálás indítása/leállítása (szükséges hozzá a _Setup > Defaults > Dictation_) |
| `Right Alt` | Tartsd lenyomva a diktáláshoz (szükséges hozzá a _Setup > Defaults > Dictation_) |

Képernyőfelvételeknél a gyorsbillentyű először megkérdezi, milyen hangot szeretnél, majd elindítja a felvételt. Nyomd meg újra a leállításhoz. A részleteket lásd a [képernyőképek és felvétel](12-screenshots-recording.md) részben.

Az összes rögzítési lehetőség elérhető az Omarchy menü (`Super + Space`) _Trigger > Capture_ pontja alatt is.

## Értesítések

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + ,` | Művelet a legutóbbi értesítésen: megnyitja vagy megnyomja az egyetlen gombját, választ a lehetőségei közül, vagy elveti, ha nincsenek ilyenek  |
| `Super + Shift + ,` | Összes értesítés elvetése |
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

További háttérképek a `~/.config/omarchy/backgrounds/<theme name>` mappában találhatók. Az Omarchy menü _Install > Style > Background_ pontján keresztül is elérhetők.

Az összes stíluslehetőség elérhető az Omarchy menü (`Super + Space`) _Appearance_ pontja alatt is.

## Váltások

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Zárolás váltása tétlenség esetén |
| `Super + Ctrl + Delete` | Laptopkijelző be-/kikapcsolásának váltása |
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
| `Super + Ctrl + Alt + R` | Összes emlékeztető megtekintése  |
| `Super + Ctrl + Shift + R` | Összes emlékeztető törlése  |

## Értesítő üzenetek

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Idő megjelenítése értesítésként  |
| `Super + Ctrl + Alt + B` | Akkumulátor megjelenítése értesítésként  |
| `Super + Ctrl + Alt + W` | Időjárás váltása értesítésként  |

## Tmux

Az előtagbillentyű a `Ctrl + Space` (a `Ctrl + B` is működik). Ezeket a hozzárendeléseket a `~/.config/tmux/tmux.conf` fájlban módosíthatod.

### Panelek

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + v` | Panel felosztása mellé (függőleges) |
| `Prefix + h` | Panel felosztása alá (vízszintes) |
| `Prefix + x` | Panel bezárása |
| `Prefix + z` | Panelnagyítás váltása (teljes képernyő) |
| `Alt + Enter` | Panel felosztása alá (előtag nélkül) |
| `Alt + Shift + Enter` | Panel felosztása mellé (előtag nélkül) |
| `Alt + Escape` | Panel bezárása (előtag nélkül) |
| `Ctrl + Alt + Arrows` | Mozgás a panelek között |
| `Ctrl + Alt + Shift + Arrows` | Panelek átméretezése |

### Ablakok

| Gyorsbillentyű                  | Funkció              |
| ----------------------- | --------------------- |
| `Prefix + c` | Új ablak |
| `Prefix + k` | Ablak bezárása |
| `Prefix + r` | Ablak átnevezése |
| `Alt + 1-9` | Ugrás egy adott ablakra |
| `Alt + Arrow Left/Right` | Mozgás az ablakok között |
| `Alt + Shift + Arrow Left/Right` | Ablak áthelyezése balra/jobbra |

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
| `Prefix + ?` | Tmux-billentyűkombinációk megjelenítése |
| `Prefix + :` | Parancssor |

### Tmux-elrendezési függvények

Ezeket a függvényeket egy Tmux-munkameneten belül kell futtatni.

| Parancs | Funkció |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása szerkesztővel, AI-val és terminállal |
| `tdlm <ai> [<second_ai>]` | Fejlesztői elrendezés létrehozása alkönyvtáranként |
| `tsl <count> <command>` | Többpaneles raj elrendezés létrehozása |

## Ghostty Terminal

A Ghostty terminal az Omarchy menü _Install > Terminal_ pontján keresztül telepíthető.

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
| `Shift + Pg Up/Down` | Előzmények görgetése |
| `Ctrl + Left mouse` | Hivatkozás megnyitása böngészőben |

## Fájlkezelő

| Gyorsbillentyű              | Funkció                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ugrás elérési útra                     |
| `Space`               | Fájl előnézete (a nyilak navigálnak) |
| `Alt + Up`       | Feljebb lépés a szülőmappába        |

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

[Lásd az összes Neovim-gyorsbillentyűt, amelyet a LazyVim konfigurál](https://www.lazyvim.org/keymaps).

## Gyors emojik

A `Super + Ctrl + E` billentyűkombinációval megjeleníthetsz egy teljes emoji választót, amely a kiválasztott elemet a vágólapra helyezi, vagy használhatod ezeket a gyors elérési lehetőségeket.

| Gyorsbillentyű       | EM | Nyom       |
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
| `Shift + CapsLock Space N` | A neved (a beállításkor megadott módon)  |
| `Shift + CapsLock Space E` | Az e-mail-címed (a beállításkor megadott módon)  |

Továbbiakat is hozzáadhatsz a `~/.XCompose` fájl szerkesztésével, majd futtasd az `omarchy restart xcompose` parancsot a terminálban, hogy a módosítások érvénybe lépjenek.
