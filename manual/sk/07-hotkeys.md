# Klávesové skratky

Všetky hlavné klávesové skratky si môžete pozrieť pomocou `Super + K` (skratky Tmux pomocou `Super + Alt + K` a skratky Herdr pomocou `Super + Ctrl + K`).

## Ako sú klávesové skratky usporiadané

Každá klávesová skratka sedí na jednej rovine, určenej jej modifikátormi, a každá rovina má jednu úlohu. Práve to bráni tomu, aby sa klávesové skratky miešali dokopy, a znamená to, že zvyčajne uhádnete, kde čo žije.

| Rovina | Čo tam žije | Príklady |
| --- | --- | --- |
| `Super + key` | Systém: okná, pracovné plochy, rozloženia a hlavné ponuky | `Super + Space` ponuka Omarchy, `Super + W` zatvoriť okno, `Super + F` celá obrazovka |
| `Super + Shift + key` | Aplikácie | `Super + Shift + B` prehliadač, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panely a systémové ponuky | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` sieť, `Super + Ctrl + C` ponuka snímania |
| `Super + Ctrl + Alt + key` | Rýchle akcie a oznámenia | `Super + Ctrl + Alt + T` zobraziť čas, `Super + Ctrl + Alt + B` batéria, `Super + Ctrl + Alt + C` snímka obrazovky |

Pridanie `Alt` ku klávesovej skratke vám dá variant toho istého, nikdy niečo nesúvisiace:

- `Super + Shift + B` otvorí prehliadač; `Super + Shift + Alt + B` otvorí súkromné okno
- `Super + Shift + E` otvorí e-mail; `Super + Shift + Alt + E` začne nový
- `Super + F` prejde na celú obrazovku; `Super + Alt + F` prejde na celú šírku
- `Super + Ctrl + C` otvorí ponuku snímania; `Super + Ctrl + Alt + C` ponuku preskočí a urobí snímku obrazovky

Pri pridávaní klávesovej skratky:

1. Podľa toho, čo robí, vyberte rovinu, potom vyberte kláves.
2. Nepresúvajte existujúcu klávesovú skratku, aby ste uvoľnili miesto. Nájdite voľný kláves na správnej rovine.
3. `Alt` používajte len pre variant klávesovej skratky bez neho.

Zopár klávesových skratiek tieto pravidlá porušuje, pretože je to pohodlné. `Shift` so šípkou alebo `Tab` presúva alebo obracia smer namiesto otvárania aplikácie a `Print`, mediálne klávesy, `Alt + Tab` a `Ctrl + Alt + Del` fungujú tak, ako všade inde. Sú to výnimky, nie vzory na kopírovanie.

Ak vám predvolená skratka nevyhovuje (povedzme chcete `Super + Shift + S` na snímky obrazovky ako vo Windows), premapujte si ju v `~/.config/hypr/bindings.lua`.

## Navigácia

| Hotkey                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Space`           | Ponuka Omarchy (aplikácie a všetko ostatné)    |
| `Super + Alt + Space` | Mriežka aplikácií |
| `Super + Escape` | Systémová ponuka (uspať, reštartovať atď.)  |
| `Super + Ctrl + L` | Uzamknúť počítač |
| `Super + W` or `Super + Q` | Zatvoriť okno             |
| `Ctrl + Alt + Del` | Zatvoriť všetky okná |
| `Super + K` | Zobraziť všetky klávesové skratky |
| `Super + Alt + K` | Zobraziť klávesové skratky tmux |
| `Super + Ctrl + K` | Zobraziť klávesové skratky herdr |
| `Super + M` | Minimalizovať okno do doku |
| `Super + T`               | Prepnúť okno medzi dlaždicovým/plávajúcim režimom             |
| `Super + J` | Prepnúť polohu okna (horizontálna/vertikálna) |
| `Super + O`               | Prepnúť okno do režimu sticky'n'floating |
| `Super + L`               | Cyklovať cez rozloženia dwindle, scrolling a floating |
| `Super + Alt + L`         | Cyklovať cez rozloženia v opačnom poradí |
| `Super + P`               | Prepnúť štýl pseudo okna (prirodzený vs. natiahnutý) |
| `Super + F`                 | Prejsť na celú obrazovku              |
| `Super + Alt + F`                 | Prejsť na celú šírku              |
| `Super + Ctrl + F`                 | Prejsť na celú obrazovku vnútri okna              |
| `Super + 1…9/0`         | Skočiť na konkrétnu pracovnú plochu (0 je 10) na zameranom monitore |
| `Super + Tab` | Skočiť na ďalšiu pracovnú plochu na zameranom monitore |
| `Super + Shift + Tab` | Skočiť na predchádzajúcu pracovnú plochu na zameranom monitore |
| `Super + Ctrl + Tab` | Skočiť na predošlú pracovnú plochu na zameranom monitore |
| `Super + Shift + 1…9/0` | Presunúť okno na pracovnú plochu na zameranom monitore |
| `Super + Shift + Alt + 1…9/0` | Presunúť okno na pracovnú plochu na zameranom monitore bez nasledovania |
| `Super + S` | Prepnúť celý scratchpad |
| `Super + Alt + S` | Presunúť okno do celého scratchpadu |
| `Super + the key above Tab` (grave na amerických rozloženiach) | Prepnúť konzolu Quake |
| `Super + Shift + the key above Tab` (grave na amerických rozloženiach) | Presunúť okno do konzoly Quake |
| `Super + Shift + Ctrl + Arrows` | Presunúť okno na monitor v danom smere |
| `Super + Shift + Alt + Arrows` | Presunúť pracovnú plochu na monitor v danom smere |
| `Super + Arrow`  | Presunúť zameranie na okno v smere šípky, na okraji obrazovky prejsť na monitor na danej strane |
| `Super + Shift + Arrow`  | Vymeniť okno s iným v smere šípky vrátane okna na monitore na danej strane |
| `Super + Minus` | Rozšíriť okno doľava |
| `Super + Equal` | Zmenšiť okno zľava |
| `Super + Shift + Minus` | Zmenšiť okno nahor |
| `Super + Shift + Equal` | Rozšíriť okno nadol |
| `Super + Alt + Minus/Equal` | Rovnaká zmena veľkosti v menších krokoch |
| `Super + Ctrl + Minus/Equal` | Rovnaká zmena veľkosti vo väčších krokoch |
| `Super + Alt + Home` | Uložiť šírku okna |
| `Super + Home` | Obnoviť uloženú šírku okna |
| `Super + Left Mouse` | Ťahať okno |
| `Super + Right Mouse` | Meniť veľkosť okna |
| `Super + Scroll Wheel` | Posúvať sa cez pracovné plochy na zameranom monitore |
| `Super + G`               | Prepnúť zoskupovanie okien      |
| `Super + Alt + G`               | Presunúť okno von zo zoskupenia      |
| `Super + Alt + Tab`               | Cyklovať medzi oknami v zoskupení      |
| `Super + Alt + Shift + Tab`               | Cyklovať dozadu medzi oknami v zoskupení      |
| `Super + Alt + Scroll Wheel` | Cyklovať medzi oknami v zoskupení |
| `Super + Alt + 1/2/3/4/5`               | Skočiť na konkrétne okno v zoskupení      |
| `Super + Alt + Arrow`  | Presunúť okno do zoskupenia v smere šípky vrátane okna na monitore na danej strane |
| `Super + Ctrl + Left/Right`  | Pohybovať sa medzi oknami vnútri dlaždicovej skupiny |
| `Super + Ctrl + Z` | Priblížiť obrazovku (opakovaním priblížite viac) |
| `Super + Ctrl + Alt + Z` | Úplne oddialiť obrazovku |
| `Super + /` | Krok vpred cez možnosti škálovania monitora |
| `Super + Alt + /` | Krok vzad cez možnosti škálovania monitora |
| `Alt + Tab` | Cyklovať vpred cez okná na aktívnej pracovnej ploche |
| `Alt + Shift + Tab` | Cyklovať vzad cez okná na aktívnej pracovnej ploche |
| `Ctrl + Alt + Tab`| Cyklovať zameranie vpred cez monitory |
| `Ctrl + Alt + Shift + Tab`| Cyklovať zameranie vzad cez monitory |
| `Super + I` | Prepnúť jazyk vstupu (pri viac ako jednom rozložení alebo metóde vstupu) |
| `Super + Shift + I` | Prepnúť jazyk vstupu späť |

Na touchpade prepínajú potiahnutia tromi a štyrmi prstami pracovné plochy, presúvajú okná a otvárajú ponuku a konzolu Quake; gestá nájdete v časti [klávesnica, myš a trackpad](34-keyboard-mouse-trackpad.md).

Zmena veľkosti používa dva klávesy napravo od 0, nech už na nich vaša klávesnica tlačí čokoľvek: `-` a `=` na amerických klávesniciach, `+` a `´` na dánskych a švédskych, `+` a `\` na nórskych, `ß` a `´` na nemeckých, `'` a `¡` na španielskych a `-` a `^` na japonských (JIS). `Super + K` ich uvádza tak, ako ich tlačí vaša klávesnica. Na JIS je `Super + ^` ako `Super + Equal`, zatiaľ čo `Super + Shift + -` (ktoré píše `=`) je `Super + Shift + Minus`. Škálovanie monitora a správca hesiel používajú `/`; na rozloženiach, ktoré píšu `/` len so Shiftom, ako väčšina európskych, používajú namiesto toho kláves naľavo od pravého Shiftu (`-` na dánskych a nemeckých).

## Systémové ovládanie

| Hotkey                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel zvuku    |
| `Super + Ctrl + B`           | Panel Bluetooth    |
| `Super + Ctrl + N`           | Panel Wi-Fi/siete    |
| `Super + Ctrl + D`           | Panel displeja    |
| `Super + Ctrl + P`           | Panel napájania    |
| `Super + Ctrl + X`           | Panel agentov    |
| `Super + Ctrl + Alt + D`           | Panel kalendára    |
| `Super + Ctrl + Alt + E`           | Panel svetových hodín    |
| `Super + Ctrl + 1-9`           | Prepnúť panel lišty podľa pozície    |
| `Super + Ctrl + S` | Ponuka zdieľania (cez LocalSend) |
| `Super + Ctrl + C` | Ovládanie snímania (snímka obrazovky/nahrávanie/výber) |
| `Super + Ctrl + O` | Prepnúť ponuku |
| `Super + Ctrl + H` | Ponuka hardvéru |
| `Super + Ctrl + E` | Výber emoji |
| `Super + Ctrl + .` | Prekódovať médiá |
| `Super + Shift + Ctrl + A` | Spustiť predvoleného agenta |
| `Power` key | Systémová ponuka |
| `Super + Shift + Copilot` key | Ponuka Omarchy |

## Úpravy

| Hotkey                  | Funkcia              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximálny jas obrazovky |
| `Shift + Brightness Down` | Minimálny jas obrazovky |
| `Alt + Brightness Up/Down` | Presné zmeny jasu po 1 % |
| `Alt + Volume Up/Down` | Presné zmeny hlasitosti po 1 % |
| `Keyboard Brightness Up/Down` | Podsvietenie klávesnice jasnejšie/tlmenejšie |
| `Keyboard Backlight` | Cyklovať úrovne podsvietenia klávesnice |
| `Ctrl + Brightness Up/Down` | Podsvietenie klávesnice jasnejšie/tlmenejšie, na klávesniciach bez vlastných klávesov |
| `Mic Mute` | Stlmiť mikrofón |
| `Shift + Mute` | Prepnúť výstup zvuku |
| `Touchpad Toggle` | Zapnúť alebo vypnúť touchpad |
| `Display` key | Cyklovať rozloženie pracovnej plochy |
| `Alt + Play` | Ďalšia skladba |
| `Alt + Shift + Play` | Predchádzajúca skladba |

## Spúšťanie aplikácií

| Hotkey                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminál    |
| `Super + Alt + Return` | Terminál Tmux |
| `Super + Ctrl + Return` | Herdr (správca agentov) |
| `Super + Shift + Return` or `Super + Shift + B`  | Prehliadač    |
| `Super + Shift + Alt + B`           | Prehliadač (súkromný/inkognito)    |
| `Super + Shift + F`           | Správca súborov    |
| `Super + Shift + Alt + F`           | Správca súborov v cwd terminálu    |
| `Super + Shift + M`           | Hudba (Spotify)    |
| `Super + Shift + Alt + M`           | Hudba (cliamp)    |
| `Super + Shift + /`           | Správca hesiel (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kalkulačka (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, po nainštalovaní)    |
| `Super + Shift + T`           | Aktivita (btop)    |
| `Super + Shift + N`           | Editor (Plain alebo vami zvolený predvolený)  |
| `Super + Shift + C`           | Kalendár ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nový e-mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Váš predvolený agent alebo ChatGPT, kým si nejakého nevyberiete |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Komunikátor (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Komunikátor (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Komunikátor (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Písanie (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (nový príspevok) |
| `Super + Shift + Y`           | YouTube |

Zmeňte/pridajte väzby v `~/.config/hypr/bindings.lua`.

## Univerzálna schránka

| Hotkey                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + A`           | Vybrať všetko v aplikáciách, ktoré podporujú `Ctrl + A`    |
| `Super + C`           | Kopírovať    |
| `Super + X`           | Vystrihnúť (nie v termináli)    |
| `Super + V`           | Prilepiť    |
| `Super + Ctrl + V`           | Správca schránky    |

Na Linuxe zvyčajne potrebujete `Ctrl + Shift + C/V` na kopírovanie a prilepovanie v termináli a `Ctrl + C/V` na to isté všade inde. Tieto zjednotené klávesové skratky schránky v Omarchy fungujú všade.

## Snímanie

| Hotkey              | Funkcia                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Snímka obrazovky                      |
| `Super + Ctrl + Alt + C`            | Snímka obrazovky (ten istý záber, pre klávesnice bez klávesu Print Screen) |
| `Super + Ctrl + C` | Ponuka snímania |
| `Alt + Print Screen`            | Nahrávanie obrazovky                     |
| `Super + Shift + Ctrl + Alt + C` | Nahrávanie obrazovky bez zvuku, s preskočením ponuky (opätovným stlačením zastavíte) |
| `Super + Print Screen` | Výber farby |
| `Super + Ctrl + Print Screen` | Extrakcia textu do schránky |
| `Super + Alt + [` | Zmenšiť prekrytie webkamery počas nahrávania |
| `Super + Alt + ]` | Zväčšiť prekrytie webkamery počas nahrávania |
| `Alt + Shift + L` | Kopírovať aktuálnu URL z webovej aplikácie alebo prehliadača |
| `Alt + Shift + D` | Stiahnuť video na aktuálnej stránke do `~/Videos` |
| `Alt + Space` | Spustiť/zastaviť diktovanie (vyžaduje _Nastavenie > Predvolené > Diktovanie_) |
| `Right Alt` | Podržaním diktovať (vyžaduje _Nastavenie > Predvolené > Diktovanie_) |

Pri nahrávaní obrazovky sa skratka najprv spýta, aký zvuk chcete, potom spustí nahrávanie. Opätovným stlačením ho zastavíte. Podrobnosti nájdete v časti [snímky obrazovky a nahrávanie](12-screenshots-recording.md).

Všetky možnosti snímania sú dostupné aj pod _Spúšťač > Snímanie_ v ponuke Omarchy (`Super + Space`).

## Oznámenia

| Hotkey                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + ,` | Vykonať akciu na najnovšom oznámení: otvoriť ho alebo stlačiť jeho jediné tlačidlo, vybrať z jeho možností alebo ho zrušiť, keď nemá žiadne  |
| `Super + Shift + ,` | Zrušiť všetky oznámenia |
| `Super + Ctrl + ,` | Ovládať oznámenia klávesnicou  |
| `Super + Alt + ,` | Zrušiť najnovšie oznámenie  |
| `Super + Shift + Alt + ,` | Otvoriť históriu oznámení  |
| `Super + Ctrl + Alt + ,` | Prepnúť stíšenie oznámení  |

## Štýl

| Hotkey                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vybrať novú tému (aj `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vybrať pozadie témy (aj `Super + Ctrl + Space`) |
| `Super + Backspace` | Prepnúť priehľadnosť okna |
| `Super + Ctrl + Backspace` | Prepnúť štvorcový pomer strán jedného okna |

Ďalšie obrázky pozadia žijú v `~/.config/omarchy/backgrounds/<theme name>`. Dostupné aj cez _Inštalácia > Štýl > Pozadie_ v ponuke Omarchy.

Všetky možnosti štýlu sú dostupné aj pod _Vzhľad_ v ponuke Omarchy (`Super + Space`).

## Prepínače

| Hotkey                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Prepnúť uzamykanie pri nečinnosti |
| `Super + Ctrl + Delete` | Prepnúť displej notebooku zap./vyp. |
| `Super + Ctrl + Alt + Delete` | Prepnúť zrkadlenie displeja notebooku |
| `Super + Shift + Space` | Prepnúť hornú lištu  |
| `Shift + Mute` | Prepnúť na ďalší výstup zvuku |
| `Shift + Play` | Prepnúť na ďalší zdroj médií |
| `Super + Shift + Backspace` | Prepnúť medzery medzi oknami |
| `Super + Ctrl + Alt + F` | Prepnúť pracovnú plochu na celú obrazovku (horná lišta + medzery medzi oknami) |

## Pripomienky

| Hotkey                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Nastaviť pripomienku  |
| `Super + Ctrl + Alt + R` | Zobraziť všetky pripomienky  |
| `Super + Ctrl + Shift + R` | Vymazať všetky pripomienky  |

## Upozornenia

| Hotkey                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Zobraziť čas ako oznámenie  |
| `Super + Ctrl + Alt + B` | Zobraziť batériu ako oznámenie  |
| `Super + Ctrl + Alt + W` | Prepnúť počasie ako oznámenie  |

## Tmux

Kláves prefixu je `Ctrl + Space` (`Ctrl + B` funguje tiež). Tieto väzby môžete zmeniť v `~/.config/tmux/tmux.conf`.

### Panely

| Hotkey                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + v` | Rozdeliť panel vedľa (vertikálne) |
| `Prefix + h` | Rozdeliť panel pod (horizontálne) |
| `Prefix + x` | Ukončiť panel |
| `Prefix + z` | Prepnúť zoom panela (celá obrazovka) |
| `Alt + Enter` | Rozdeliť panel pod (bez prefixu) |
| `Alt + Shift + Enter` | Rozdeliť panel vedľa (bez prefixu) |
| `Alt + Escape` | Ukončiť panel (bez prefixu) |
| `Ctrl + Alt + Arrows` | Pohybovať sa medzi panelmi |
| `Ctrl + Alt + Shift + Arrows` | Meniť veľkosť panelov |

### Okná

| Hotkey                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nové okno |
| `Prefix + k` | Ukončiť okno |
| `Prefix + r` | Premenovať okno |
| `Alt + 1-9` | Prejsť na konkrétne okno |
| `Alt + Arrow Left/Right` | Pohybovať sa medzi oknami |
| `Alt + Shift + Arrow Left/Right` | Presunúť okno doľava/doprava |

### Relácie

| Hotkey                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nová relácia |
| `Prefix + K` | Ukončiť reláciu |
| `Prefix + R` | Premenovať reláciu |
| `Prefix + N` | Ďalšia relácia |
| `Prefix + P` | Predchádzajúca relácia |
| `Alt + Arrow Up/Down` | Pohybovať sa medzi reláciami |
| `Prefix + s` | Zobraziť zoznam relácií |
| `Prefix + d` | Odpojiť sa od relácie |

### Režim kopírovania (v štýle vi)

| Hotkey                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + [` | Vstúpiť do režimu kopírovania |
| `v` | Začať výber (v režime kopírovania) |
| `y` | Kopírovať výber (v režime kopírovania) |

### Všeobecné

| Hotkey                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + q` | Znova načítať konfiguráciu |
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

Terminál Ghostty sa inštaluje pomocou _Inštalácia > Terminál_ cez ponuku Omarchy.

| Hotkey                  | Funkcia              |
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

| Hotkey              | Funkcia                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Prejsť na cestu                     |
| `Space`               | Náhľad súboru (navigácia šípkami) |
| `Alt + Up`       | Prejsť hore do nadradeného priečinka        |

## Neovim (s lazyvim)

### Navigácia

| Hotkey                   | Funkcia                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Zobraziť možnosti príkazov            |
| `Space Space`              | Otvoriť súbor cez fuzzy vyhľadávanie      |
| `Space E`                  | Prepnúť bočný panel                  |
| `Space G G`                | Zobraziť ovládanie gitu               |
| `Space S G`                | Vyhľadávať v obsahu súborov             |
| `Ctrl + W W`               | Skočiť medzi bočným panelom a editorom |
| `Ctrl + Left/right arrow`  | Zmeniť veľkosť bočného panela          |
| `Shift + H`                      | Prejsť na ľavú kartu súboru             |
| `Shift + L`                      | Prejsť na pravú kartu súboru            |
| `Space B D`                | Zatvoriť kartu súboru                  |

### V bočnom paneli

| Hotkey                   | Funkcia                        |
| ------------------------ | ------------------------------- |
| `A`                        | Pridať nový súbor v nadradenom adresári      |
| `Shift + A`                | Pridať nový podadresár v nadradenom adresári    |
| `D`                        | Odstrániť zvýraznený súbor/adresár     |
| `M`                        | Presunúť zvýraznený súbor/adresár       |
| `R`                        | Premenovať zvýraznený súbor/adresár     |
| `?`                        | Zobraziť pomoc pre všetky príkazy      |

[Pozrite si všetky klávesové skratky Neovimu nakonfigurované LazyVimom](https://www.lazyvim.org/keymaps).

## Rýchle emoji

Pomocou `Super + Ctrl + E` môžete zobraziť kompletný výber emoji, ktorý umiestni výber do schránky, alebo môžete použiť tieto možnosti rýchleho prístupu.

| Hotkey       | EM | Nápoveda       |
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
| `Shift + CapsLock M A` |💪 | sval |
| `Shift + CapsLock M B` |🤯 | vybuchujúca |

## Rýchle dopĺňanie

| Hotkey       | Dopĺňanie       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (dlhá pomlčka)   |
| `Shift + CapsLock Space N` | Vaše meno (ako bolo zadané pri nastavení)  |
| `Shift + CapsLock Space E` | Váš e-mail (ako bol zadaný pri nastavení)  |

Ďalšie vlastné môžete pridať úpravou `~/.XCompose` a následným spustením `omarchy restart xcompose` v termináli, aby sa zmeny načítali.
