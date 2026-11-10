# Klávesové skratky

Všetky hlavné klávesové skratky si môžete pozrieť pomocou `Super + K` (skratky Tmux pomocou `Super + Alt + K` a skratky Herdr pomocou `Super + Ctrl + K`).

## Ako sú klávesové skratky rozložené

Každá klávesová skratka sedí na jednej rovine určenej jej modifikátormi a každá rovina má jednu úlohu. Práve to bráni tomu, aby sa skratky zlievali dokopy, a znamená to, že zvyčajne uhádnete, kam niečo patrí.

| Rovina | Čo tam patrí | Príklady |
| --- | --- | --- |
| `Super + key` | Systém: okná, pracovné plochy, rozloženia a hlavné menu | `Super + Space` menu Omarchy, `Super + W` zatvoriť okno, `Super + F` celá obrazovka |
| `Super + Shift + key` | Aplikácie | `Super + Shift + B` prehliadač, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panely a systémové menu | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` sieť, `Super + Ctrl + C` menu snímania |
| `Super + Ctrl + Alt + key` | Rýchle akcie a oznámenia | `Super + Ctrl + Alt + T` zobraziť čas, `Super + Ctrl + Alt + B` batéria, `Super + Ctrl + Alt + C` snímka obrazovky |

Pridanie `Alt` ku klávesovej skratke vám dá variant tej istej veci, nikdy niečo nesúvisiace:

- `Super + Shift + B` otvorí prehliadač; `Super + Shift + Alt + B` otvorí súkromné okno
- `Super + Shift + E` otvorí e-mail; `Super + Shift + Alt + E` začne nový
- `Super + F` prejde na celú obrazovku; `Super + Alt + F` prejde na celú šírku
- `Super + Ctrl + C` otvorí menu snímania; `Super + Ctrl + Alt + C` preskočí menu a urobí snímku obrazovky

Pri pridávaní klávesovej skratky:

1. Vyberte rovinu podľa toho, čo robí, potom vyberte kláves.
2. Nepresúvajte existujúcu skratku, aby ste uvoľnili miesto. Nájdite voľný kláves na správnej rovine.
3. `Alt` používajte len pre variant skratky bez neho.

Niekoľko skratiek tieto pravidlá porušuje, pretože je to pohodlné. `Shift` so šípkou alebo `Tab` presúva alebo obracia namiesto otvárania aplikácie a `Print`, mediálne klávesy, `Alt + Tab` a `Ctrl + Alt + Del` fungujú tak, ako všade inde. Sú to výnimky, nie vzory na kopírovanie.

Ak vám predvolená skratka nevyhovuje (povedzme, že chcete `Super + Shift + S` pre snímky obrazovky ako vo Windows), premapujte ju v `~/.config/hypr/bindings.lua`.

## Navigácia

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (aplikácie a všetko ostatné)    |
| `Super + Alt + Space` | Mriežka aplikácií |
| `Super + Escape` | Systémové menu (uspať, reštartovať atď.)  |
| `Super + Ctrl + L` | Zamknúť počítač |
| `Super + W` or `Super + Q` | Zatvoriť okno             |
| `Ctrl + Alt + Del` | Zatvoriť všetky okná |
| `Super + T`               | Prepnúť okno medzi dlaždicovým/plávajúcim režimom             |
| `Super + J` | Prepnúť polohu okna (horizontálna/vertikálna) |
| `Super + O`               | Prepnúť vyskakovacie okno do sticky'n'floating |
| `Super + L`               | Prechádzať rozloženiami dwindle, scrolling a floating |
| `Super + Alt + L`         | Prechádzať rozloženiami v opačnom poradí |
| `Super + P`               | Prepnúť štýl pseudo okna (prirodzený vs. natiahnutý) |
| `Super + F`                 | Prejsť na celú obrazovku              |
| `Super + Alt + F`                 | Prejsť na celú šírku              |
| `Super + Ctrl + F`                 | Prejsť na celú obrazovku vnútri okna              |
| `Super + 1/2/3/4`         | Prejsť na konkrétnu pracovnú plochu na zameranom monitore |
| `Super + Tab` | Prejsť na ďalšiu pracovnú plochu na zameranom monitore |
| `Super + Shift + Tab` | Prejsť na predchádzajúcu pracovnú plochu na zameranom monitore |
| `Super + Ctrl + Tab` | Prejsť na bývalú pracovnú plochu na zameranom monitore |
| `Super + Shift + 1/2/3/4` | Presunúť okno na pracovnú plochu na zameranom monitore |
| `Super + Shift + Alt + 1/2/3/4` | Presunúť okno na pracovnú plochu na zameranom monitore bez nasledovania |
| `Super + S` | Prepnúť celý scratchpad |
| `Super + Alt + S` | Presunúť okno do celého scratchpadu |
| `Super + Grave` | Prepnúť konzolu Quake |
| `Super + Shift + Grave` | Presunúť okno do konzoly Quake |
| `Super + Shift + Ctrl + Arrows` | Presunúť okno na monitor v danom smere |
| `Super + Shift + Alt + Arrows` | Presunúť pracovnú plochu na monitor v danom smere |
| `Super + Arrow`  | Presunúť zameranie na okno v smere šípky, na okraji obrazovky prejsť na monitor na tej strane |
| `Super + Shift + Arrow`  | Vymeniť okno s iným v smere šípky vrátane okna na monitore na tej strane |
| `Super + Minus` | Rozšíriť okno doľava |
| `Super + Equal` | Zmenšiť okno doľava |
| `Super + Shift + Minus` | Zmenšiť okno nahor |
| `Super + Shift + Equal` | Rozšíriť okno nadol |
| `Super + Alt + Minus/Equal` | Rovnaká zmena veľkosti v menších krokoch |
| `Super + Ctrl + Minus/Equal` | Rovnaká zmena veľkosti vo väčších krokoch |
| `Super + Alt + Home` | Uložiť šírku okna |
| `Super + Home` | Obnoviť uloženú šírku okna |
| `Super + Left Mouse` | Ťahať okno |
| `Super + Right Mouse` | Zmeniť veľkosť okna |
| `Super + Scroll Wheel` | Posúvať sa cez pracovné plochy na zameranom monitore |
| `Super + G`               | Prepnúť zoskupovanie okien      |
| `Super + Alt + G`               | Vybrať okno zo zoskupenia      |
| `Super + Alt + Tab`               | Prechádzať oknami v zoskupení      |
| `Super + Alt + Shift + Tab`               | Prechádzať oknami v zoskupení dozadu      |
| `Super + Alt + Scroll Wheel` | Prechádzať oknami v zoskupení |
| `Super + Alt + 1/2/3/4/5`               | Prejsť na konkrétne okno v zoskupení      |
| `Super + Alt + Arrow`  | Presunúť okno do zoskupenia v smere šípky vrátane okna na monitore na tej strane |
| `Super + Ctrl + Left/Right`  | Pohybovať sa medzi oknami vnútri dlaždicovej skupiny |
| `Super + Ctrl + Z` | Priblížiť obrazovku (opakovaním priblížite viac) |
| `Super + Ctrl + Alt + Z` | Úplne oddialiť obrazovku |
| `Super + /` | Krok vpred cez možnosti škálovania monitora |
| `Super + Alt + /` | Krok vzad cez možnosti škálovania monitora |
| `Alt + Tab` | Prechádzať vpred oknami na aktívnej pracovnej ploche |
| `Alt + Shift + Tab` | Prechádzať dozadu oknami na aktívnej pracovnej ploche |
| `Ctrl + Alt + Tab`| Prechádzať zameraním vpred cez monitory |
| `Ctrl + Alt + Shift + Tab`| Prechádzať zameraním dozadu cez monitory |

Skratky na zmenu veľkosti používajú fyzické klávesy `code:20` a `code:21` (XKB `<AE11>` a `<AE12>`) bez ohľadu na znaky vytlačené na klávesnici. Na amerických klávesniciach sú tieto klávesy `-` a `=`; na japonských (JIS) klávesniciach sú to `-` a `^`; na španielskych klávesniciach sú to `'` a `¡`. Na JIS je `Super + ^` to isté ako `Super + Equal`, zatiaľ čo `Super + Shift + -` (ktoré píše `=`) je `Super + Shift + Minus`.

## Systémové ovládanie

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel zvuku    |
| `Super + Ctrl + B`           | Panel Bluetooth    |
| `Super + Ctrl + N`           | Panel Wi-Fi/siete    |
| `Super + Ctrl + D`           | Panel displeja    |
| `Super + Ctrl + P`           | Panel napájania    |
| `Super + Ctrl + Alt + D`           | Panel kalendára    |
| `Super + Ctrl + Alt + E`           | Panel svetového času    |
| `Super + Ctrl + 1-9`           | Prepnúť panel lišty podľa pozície    |
| `Super + Ctrl + S` | Menu zdieľania (cez LocalSend) |
| `Super + Ctrl + C` | Ovládanie snímania (snímka obrazovky/-nahrávanie/výber) |
| `Super + Ctrl + O` | Prepnúť menu |
| `Super + Ctrl + H` | Menu hardvéru |
| `Super + Ctrl + E` | Výber emoji |
| `Super + Ctrl + .` | Prekódovať médiá |
| `Super + Shift + Ctrl + A` | Vybrať AI agenta |

## Úpravy

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximálny jas obrazovky |
| `Shift + Brightness Down` | Minimálny jas obrazovky |
| `Alt + Brightness Up/Down` | Presné zmeny jasu o 1 % |
| `Alt + Volume Up/Down` | Presné zmeny hlasitosti o 1 % |
| `Keyboard Brightness Up/Down` | Jasnejšie/slabšie podsvietenie klávesnice |
| `Keyboard Backlight` | Prechádzať úrovňami podsvietenia klávesnice |
| `Alt + Play` | Ďalšia skladba |
| `Alt + Shift + Play` | Predchádzajúca skladba |

## Spúšťanie aplikácií

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminál    |
| `Super + Alt + Return` | Terminál Tmux |
| `Super + Ctrl + Return` | Herdr (správca agentov) |
| `Super + Shift + Return`           | Prehliadač    |
| `Super + Shift + Alt + B`           | Prehliadač (súkromný/inkognito)    |
| `Super + Shift + F`           | Správca súborov    |
| `Super + Shift + Alt + F`           | Správca súborov v cwd terminálu    |
| `Super + Shift + M`           | Hudba (Spotify)    |
| `Super + Shift + Alt + M`           | Hudba (cliamp)    |
| `Super + Shift + /`           | Správca hesiel (1password)    |
| `Super + Shift + Q`           | Kalkulačka (Omacalc)    |
| `Super + Shift + T`           | Aktivita (btop)    |
| `Super + Shift + N`           | Editor (Neovim)  |
| `Super + Shift + C`           | Kalendár ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nový e-mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Messenger (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Messenger (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Messenger (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Písanie (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Zmeňte/pridajte väzby v `~/.config/hypr/bindings.lua`.

## Univerzálna schránka

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + A`           | Vybrať všetko v aplikáciách, ktoré podporujú `Ctrl + A`    |
| `Super + C`           | Kopírovať    |
| `Super + X`           | Vystrihnúť (nie v termináli)    |
| `Super + V`           | Prilepiť    |
| `Super + Ctrl + V`           | Správca schránky    |

Na Linuxe zvyčajne potrebujete `Ctrl + Shift + C/V` na copy'n'paste v termináli a `Ctrl + C/V` na to všade inde. Tieto zjednotené klávesové skratky schránky v Omarchy fungujú všade.

## Snímanie

| Klávesová skratka              | Funkcia                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Snímka obrazovky                      |
| `Super + Ctrl + Alt + C`            | Snímka obrazovky (ten istý záber, pre klávesnice bez klávesu Print Screen) |
| `Super + Ctrl + C` | Menu snímania |
| `Alt + Print Screen`            | Nahrávanie obrazovky                     |
| `Super + Print Screen` | Výber farby |
| `Super + Ctrl + Print Screen` | Extrakcia textu do schránky |
| `Super + Alt + [` | Zmenšiť prekrytie webkamery počas nahrávania |
| `Super + Alt + ]` | Zväčšiť prekrytie webkamery počas nahrávania |
| `Alt + Shift + L` | Kopírovať aktuálnu URL z webovej aplikácie alebo Chromium |
| `Alt + Shift + D` | Stiahnuť video na aktuálnej stránke do `~/Videos` |
| `Alt + Space` | Spustiť/zastaviť diktovanie (vyžaduje _Nastavenie > Predvolené > Diktovanie_) |
| `Right Alt` | Podržaním diktovať (vyžaduje _Nastavenie > Predvolené > Diktovanie_) |

Pri nahrávaní obrazovky sa skratka najprv opýta, aký zvuk chcete, a potom spustí nahrávanie. Stlačte ju znova na zastavenie. Podrobnosti nájdete v [snímky obrazovky a nahrávanie](12-screenshots-recording.md).

Všetky možnosti snímania sú dostupné aj v _Spúšťač > Snímanie_ v menu Omarchy (`Super + Space`).

## Oznámenia

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + ,` | Vykonať akciu s najnovším oznámením: otvoriť ho alebo stlačiť jeho jediné tlačidlo, vybrať z jeho možností, alebo ho zavrieť, keď žiadne nemá  |
| `Super + Shift + ,` | Zavrieť všetky oznámenia |
| `Super + Ctrl + ,` | Ovládať oznámenia klávesnicou  |
| `Super + Alt + ,` | Zavrieť najnovšie oznámenie  |
| `Super + Shift + Alt + ,` | Otvoriť históriu oznámení  |
| `Super + Ctrl + Alt + ,` | Prepnúť stíšenie oznámení  |

## Štýl

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vybrať novú tému (tiež `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vybrať pozadie témy (tiež `Super + Ctrl + Space`) |
| `Super + Backspace` | Prepnúť priehľadnosť okna |
| `Super + Ctrl + Backspace` | Prepnúť štvorcový pomer strán jedného okna |

Ďalšie obrázky pozadia sa nachádzajú v `~/.config/omarchy/backgrounds/<theme name>`. Dostupné aj cez _Inštalácia > Štýl > Pozadie_ v menu Omarchy.

Všetky možnosti štýlu sú dostupné aj v _Štýl_ v menu Omarchy (`Super + Space`).

## Prepínače

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Prepnúť zamykanie pri nečinnosti |
| `Super + Ctrl + Delete` | Zapnúť/vypnúť displej notebooku |
| `Super + Ctrl + Alt + Delete` | Prepnúť zrkadlenie displeja notebooku |
| `Super + Shift + Space` | Prepnúť hornú lištu  |
| `Shift + Mute` | Prepnúť na ďalší zvukový výstup |
| `Shift + Play` | Prepnúť na ďalší zdroj médií |
| `Super + Shift + Backspace` | Prepnúť medzery medzi oknami |
| `Super + Ctrl + Alt + F` | Prepnúť pracovnú plochu na celú obrazovku (horná lišta + medzery medzi oknami) |

## Pripomienky

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Nastaviť pripomienku  |
| `Super + Ctrl + Alt + R` | Zobraziť všetky pripomienky  |
| `Super + Ctrl + Shift + R` | Vymazať všetky pripomienky  |

## Upozornenia

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Zobraziť čas ako oznámenie  |
| `Super + Ctrl + Alt + B` | Zobraziť batériu ako oznámenie  |
| `Super + Ctrl + Alt + W` | Prepnúť počasie ako oznámenie  |

## Tmux

Prefixový kláves je `Ctrl + Space` (`Ctrl + B` tiež funguje). Tieto väzby môžete zmeniť v `~/.config/tmux/tmux.conf`.

### Panely

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + v` | Rozdeliť panel vedľa (vertikálne) |
| `Prefix + h` | Rozdeliť panel pod (horizontálne) |
| `Prefix + x` | Zabiť panel |
| `Prefix + z` | Prepnúť priblíženie panela (celá obrazovka) |
| `Alt + Enter` | Rozdeliť panel pod (bez prefixu) |
| `Alt + Shift + Enter` | Rozdeliť panel vedľa (bez prefixu) |
| `Alt + Escape` | Zabiť panel (bez prefixu) |
| `Ctrl + Alt + Arrows` | Pohybovať sa medzi panelmi |
| `Ctrl + Alt + Shift + Arrows` | Zmeniť veľkosť panelov |

### Okná

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nové okno |
| `Prefix + k` | Zabiť okno |
| `Prefix + r` | Premenovať okno |
| `Alt + 1-9` | Prejsť na konkrétne okno |
| `Alt + Arrow Left/Right` | Pohybovať sa medzi oknami |
| `Alt + Shift + Arrow Left/Right` | Presunúť okno doľava/doprava |

### Relácie

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nová relácia |
| `Prefix + K` | Zabiť reláciu |
| `Prefix + R` | Premenovať reláciu |
| `Prefix + N` | Ďalšia relácia |
| `Prefix + P` | Predchádzajúca relácia |
| `Alt + Arrow Up/Down` | Pohybovať sa medzi reláciami |
| `Prefix + s` | Zobraziť zoznam relácií |
| `Prefix + d` | Odpojiť sa od relácie |

### Režim kopírovania (v štýle vi)

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + [` | Vstúpiť do režimu kopírovania |
| `v` | Začať výber (v režime kopírovania) |
| `y` | Kopírovať výber (v režime kopírovania) |

### Všeobecné

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + q` | Znovu načítať konfiguráciu |
| `Prefix + ?` | Zobraziť klávesové skratky Tmux |
| `Prefix + :` | Príkazový riadok |

### Funkcie rozloženia Tmux

Tieto funkcie musíte spustiť vnútri relácie Tmux.

| Príkaz | Funkcia |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Vytvoriť vývojové rozloženie s editorom, AI a terminálom |
| `tdlm <ai> [<second_ai>]` | Vytvoriť vývojové rozloženie pre každý podadresár |
| `tsl <count> <command>` | Vytvoriť rojové rozloženie s viacerými panelmi |

## Terminál Ghostty

Terminál Ghostty sa inštaluje pomocou _Inštalácia > Terminál_ cez menu Omarchy.

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nové rozdelenie pod |
| `Ctrl + Shift + O` | Nové rozdelenie vedľa |
| `Ctrl + Alt + Arrows` | Pohybovať sa medzi rozdeleniami |
| `Super + Ctrl + Shift + Arrows` | Zmeniť veľkosť rozdelenia o 10 riadkov |
| `Super + Ctrl + Shift + Alt + Arrows` | Zmeniť veľkosť rozdelenia o 100 riadkov |
| `Ctrl + Shift + T` | Nová karta  |
| `Ctrl + Shift + Arrows` | Pohybovať sa medzi kartami |
| `Alt + Numbers` | Prejsť na konkrétnu kartu |
| `Shift + Pg Up/Down` | Posúvať históriu |
| `Ctrl + Left mouse` | Otvoriť odkaz v prehliadači |

## Správca súborov

| Klávesová skratka              | Funkcia                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Prejsť na cestu                     |
| `Space`               | Náhľad súboru (šípky navigujú) |
| `Alt + Up`       | Prejsť hore do nadradeného priečinka        |

## Neovim (w/ lazyvim)

### Navigácia

| Klávesová skratka                   | Funkcia                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Zobraziť možnosti príkazov            |
| `Space Space`              | Otvoriť súbor cez fuzzy vyhľadávanie      |
| `Space E`                  | Prepnúť bočný panel                  |
| `Space G G`                | Zobraziť ovládanie gitu               |
| `Space S G`                | Hľadať obsah súboru             |
| `Ctrl + W W`               | Preskakovať medzi bočným panelom a editorom |
| `Ctrl + Left/right arrow`  | Zmeniť veľkosť bočného panela          |
| `Shift + H`                      | Prejsť na ľavú kartu súboru             |
| `Shift + L`                      | Prejsť na pravú kartu súboru            |
| `Space B D`                | Zatvoriť kartu súboru                  |

### V bočnom paneli

| Klávesová skratka                   | Funkcia                        |
| ------------------------ | ------------------------------- |
| `A`                        | Pridať nový súbor v nadradenom adresári      |
| `Shift + A`                | Pridať nový podadresár v nadradenom adresári    |
| `D`                        | Odstrániť zvýraznený súbor/adresár     |
| `M`                        | Presunúť zvýraznený súbor/adresár       |
| `R`                        | Premenovať zvýraznený súbor/adresár     |
| `?`                        | Zobraziť pomoc pre všetky príkazy      |

[Pozrite si všetky klávesové skratky Neovimu nakonfigurované cez LazyVim](https://www.lazyvim.org/keymaps).

## Rýchle emoji

Pomocou `Super + Ctrl + E` môžete zobraziť kompletný výber emoji, ktorý vloží výber do schránky, alebo môžete použiť tieto možnosti rýchleho prístupu.

| Klávesová skratka       | EM | Nápoveda       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | úsmev      |
| `Shift + CapsLock M C` | 😂 | plač        |
| `Shift + CapsLock M L` | 😍 | láska       |
| `Shift + CapsLock M V` | ✌️ | víťazstvo    |
| `Shift + CapsLock M H` | ❤️ | srdce      |
| `Shift + CapsLock M Y` | 👍 | áno        |
| `Shift + CapsLock M N` | 👎 | nie         |
| `Shift + CapsLock M F` | 🖕 | prostredník       |
| `Shift + CapsLock M W` | 🤞 | prianie       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | bozk       |
| `Shift + CapsLock M E` | 🙄 | prevrátenie očí    |
| `Shift + CapsLock M I` | 😉 | žmurknutie       |
| `Shift + CapsLock M P` | 🙏 | modlitba |
| `Shift + CapsLock M D` | 🤤 | slintanie      |
| `Shift + CapsLock M M` | 💰 | peniaze      |
| `Shift + CapsLock M X` | 🎉 | oslava |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | prípitok      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pozdrav |
| `Shift + CapsLock M A` |💪 | ruka |
| `Shift + CapsLock M B` |🤯 | výbuch |

## Rýchle dopĺňanie

| Klávesová skratka       | Dopĺňanie       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (dlhá pomlčka)   |
| `Shift + CapsLock Space N` | Vaše meno (ako bolo zadané pri nastavení)  |
| `Shift + CapsLock Space E` | Váš e-mail (ako bol zadaný pri nastavení)  |

Ďalšie si môžete pridať úpravou `~/.XCompose`, potom spustite v termináli `omarchy-restart-xcompose`, aby sa zmeny načítali.
