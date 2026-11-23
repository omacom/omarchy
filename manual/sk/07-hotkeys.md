# Klávesové skratky

Všetky hlavné klávesové skratky si môžete pozrieť pomocou `Super + K` (skratky Tmux pomocou `Super + Alt + K` a skratky Herdr pomocou `Super + Ctrl + K`).

## Ako sú klávesové skratky usporiadané

Každá klávesová skratka sedí na rovine určenej jej modifikátormi a každá rovina má jednu úlohu. Práve to bráni tomu, aby sa skratky navzájom plietli, a znamená to, že zvyčajne dokážete uhádnuť, kam niečo patrí.

| Rovina | Čo tam patrí | Príklady |
| --- | --- | --- |
| `Super + key` | Systém: okná, pracovné priestory, rozloženia a základné ponuky | `Super + Space` ponuka Omarchy, `Super + W` zatvoriť okno, `Super + F` celá obrazovka |
| `Super + Shift + key` | Aplikácie | `Super + Shift + B` prehliadač, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panely a systémové ponuky | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` sieť, `Super + Ctrl + C` ponuka snímania |
| `Super + Ctrl + Alt + key` | Rýchle akcie a oznámenia | `Super + Ctrl + Alt + T` zobraziť čas, `Super + Ctrl + Alt + B` batéria, `Super + Ctrl + Alt + C` snímka obrazovky |

Pridanie `Alt` ku klávesovej skratke vám dá variant toho istého, nikdy niečo nesúvisiace:

- `Super + Shift + B` otvorí prehliadač; `Super + Shift + Alt + B` otvorí súkromné okno
- `Super + Shift + E` otvorí e-mail; `Super + Shift + Alt + E` začne nový
- `Super + F` prejde na celú obrazovku; `Super + Alt + F` prejde na celú šírku
- `Super + Ctrl + C` otvorí ponuku snímania; `Super + Ctrl + Alt + C` preskočí ponuku a urobí snímku obrazovky

Pri pridávaní klávesovej skratky:

1. Najprv vyberte rovinu podľa toho, čo robí, potom vyberte kláves.
2. Nepremiestňujte existujúcu skratku, aby ste uvoľnili miesto. Nájdite voľný kláves na správnej rovine.
3. `Alt` používajte len pre variant skratky bez neho.

Niekoľko skratiek tieto pravidlá porušuje, pretože je to pohodlné. `Shift` so šípkou alebo `Tab` presúva alebo obracia smer namiesto otvárania aplikácie a `Print`, mediálne klávesy, `Alt + Tab` a `Ctrl + Alt + Del` fungujú tak, ako všade inde. Sú to výnimky, nie vzory na kopírovanie.

Ak vám predvolené nastavenie nevyhovuje (povedzme, že chcete `Super + Shift + S` na snímky obrazovky ako vo Windows), zmeňte jej väzbu v `~/.config/hypr/bindings.lua`.

## Navigácia

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Space`           | Ponuka Omarchy (aplikácie a všetko ostatné)    |
| `Super + Alt + Space` | Mriežka aplikácií |
| `Super + Escape` | Systémová ponuka (uspanie, reštart atď.)  |
| `Super + Ctrl + L` | Zamknúť počítač |
| `Super + W` or `Super + Q` | Zatvoriť okno             |
| `Ctrl + Alt + Del` | Zatvoriť všetky okná |
| `Super + K` | Zobraziť všetky klávesové skratky |
| `Super + Alt + K` | Zobraziť klávesové skratky tmux |
| `Super + Ctrl + K` | Zobraziť klávesové skratky herdr |
| `Super + M` | Minimalizovať okno do doku |
| `Super + T`               | Prepnúť okno medzi dlaždicovým/plávajúcim režimom             |
| `Super + J` | Prepnúť polohu okna (horizontálna/vertikálna) |
| `Super + O`               | Prepnúť okno do režimu sticky'n'floating |
| `Super + L`               | Cyklicky prepínať medzi rozloženiami dwindle, scrolling a floating |
| `Super + Alt + L`         | Cyklicky prepínať medzi rozloženiami v opačnom poradí |
| `Super + P`               | Prepnúť štýl pseudo okna (natural v stretch) |
| `Super + F`                 | Prejsť na celú obrazovku              |
| `Super + Alt + F`                 | Prejsť na celú šírku              |
| `Super + Ctrl + F`                 | Prejsť na celú obrazovku vnútri okna              |
| `Super + 1…9/0`         | Prejsť na konkrétny pracovný priestor (0 je 10) na zameranom monitore |
| `Super + Tab` | Prejsť na ďalší pracovný priestor na zameranom monitore |
| `Super + Shift + Tab` | Prejsť na predchádzajúci pracovný priestor na zameranom monitore |
| `Super + Ctrl + Tab` | Prejsť na predošlý pracovný priestor na zameranom monitore |
| `Super + Shift + 1…9/0` | Presunúť okno na pracovný priestor na zameranom monitore |
| `Super + Shift + Alt + 1…9/0` | Presunúť okno na pracovný priestor na zameranom monitore bez nasledovania |
| `Super + S` | Prepnúť úplný scratchpad |
| `Super + Alt + S` | Presunúť okno do úplného scratchpadu |
| `Super + the key above Tab` (grave on US layouts) | Prepnúť konzolu Quake |
| `Super + Shift + the key above Tab` (grave on US layouts) | Presunúť okno do konzoly Quake |
| `Super + Shift + Ctrl + Arrows` | Presunúť okno na monitor v danom smere |
| `Super + Shift + Alt + Arrows` | Presunúť pracovný priestor na monitor v danom smere |
| `Super + Arrow`  | Presunúť zameranie na okno v smere šípky, na okraji obrazovky prejsť na monitor na danej strane |
| `Super + Shift + Arrow`  | Vymeniť okno s iným v smere šípky vrátane okna na monitore na danej strane |
| `Super + Minus` | Rozšíriť okno doľava |
| `Super + Equal` | Zúžiť okno zľava |
| `Super + Shift + Minus` | Zmenšiť okno nahor |
| `Super + Shift + Equal` | Rozšíriť okno nadol |
| `Super + Alt + Minus/Equal` | Rovnaká zmena veľkosti v menších krokoch |
| `Super + Ctrl + Minus/Equal` | Rovnaká zmena veľkosti vo väčších krokoch |
| `Super + Alt + Home` | Uložiť šírku okna |
| `Super + Home` | Obnoviť uloženú šírku okna |
| `Super + Left Mouse` | Ťahať okno |
| `Super + Right Mouse` | Meniť veľkosť okna |
| `Super + Scroll Wheel` | Posúvať sa medzi pracovnými priestormi na zameranom monitore |
| `Super + G`               | Prepnúť zoskupovanie okien      |
| `Super + Alt + G`               | Vyňať okno zo zoskupenia      |
| `Super + Alt + Tab`               | Cyklicky prepínať medzi oknami v zoskupení      |
| `Super + Alt + Shift + Tab`               | Cyklicky prepínať medzi oknami v zoskupení v opačnom smere      |
| `Super + Alt + Scroll Wheel` | Cyklicky prepínať medzi oknami v zoskupení |
| `Super + Alt + 1/2/3/4/5`               | Prejsť na konkrétne okno v zoskupení      |
| `Super + Alt + Arrow`  | Presunúť okno do zoskupenia v smere šípky vrátane okna na monitore na danej strane |
| `Super + Ctrl + Left/Right`  | Presúvať sa medzi oknami vnútri dlaždicovej skupiny |
| `Super + Ctrl + Z` | Priblížiť obrazovku (opakovaním priblížite viac) |
| `Super + Ctrl + Alt + Z` | Úplne oddialiť obrazovku |
| `Super + /` | Krok vpred medzi možnosťami škálovania monitora |
| `Super + Alt + /` | Krok vzad medzi možnosťami škálovania monitora |
| `Alt + Tab` | Cyklicky prepínať vpred medzi oknami na aktívnom pracovnom priestore |
| `Alt + Shift + Tab` | Cyklicky prepínať vzad medzi oknami na aktívnom pracovnom priestore |
| `Ctrl + Alt + Tab`| Cyklicky presúvať zameranie vpred medzi monitormi |
| `Ctrl + Alt + Shift + Tab`| Cyklicky presúvať zameranie vzad medzi monitormi |
| `Super + I` | Prepnúť jazyk vstupu (pri viac než jednom rozložení alebo metóde vstupu) |
| `Super + Shift + I` | Prepnúť jazyk vstupu späť |

Na touchpade prepínajú potiahnutia tromi a štyrmi prstami pracovné priestory, presúvajú okná a otvárajú ponuku a konzolu Quake; gestá nájdete v časti [klávesnica, myš a trackpad](34-keyboard-mouse-trackpad.md).

Zmena veľkosti používa dva klávesy napravo od 0, nech už na nich vaša klávesnica vytlačí čokoľvek: `-` a `=` na amerických klávesniciach, `+` a `´` na dánskych a švédskych, `+` a `\` na nórskych, `ß` a `´` na nemeckých, `'` a `¡` na španielskych a `-` a `^` na japonských (JIS). `Super + K` ich uvádza tak, ako ich vytlačí vaša klávesnica. Na JIS je `Super + ^` vlastne `Super + Equal`, zatiaľ čo `Super + Shift + -` (ktoré píše `=`) je `Super + Shift + Minus`. Škálovanie monitora a správca hesiel používajú `/`; na rozloženiach, ktoré píšu `/` len so Shift, ako väčšina európskych, používajú namiesto toho kláves naľavo od pravého Shift (`-` na dánskom a nemeckom).

## Systémové ovládanie

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel zvuku    |
| `Super + Ctrl + B`           | Panel Bluetooth    |
| `Super + Ctrl + N`           | Panel Wi-Fi/siete    |
| `Super + Ctrl + D`           | Panel displeja    |
| `Super + Ctrl + P`           | Panel napájania    |
| `Super + Ctrl + X`           | Panel agentov    |
| `Super + Ctrl + Alt + X`           | Panel lokálnych modelov    |
| `Super + Ctrl + Alt + D`           | Panel kalendára    |
| `Super + Ctrl + Alt + E`           | Panel svetových hodín    |
| `Super + Ctrl + 1-9`           | Prepnúť panel lišty podľa pozície    |
| `Super + Ctrl + S` | Ponuka zdieľania (cez LocalSend) |
| `Super + Ctrl + C` | Ovládanie snímania (snímka obrazovky/-nahrávanie/výber) |
| `Super + Ctrl + O` | Prepnúť ponuku |
| `Super + Ctrl + H` | Ponuka hardvéru |
| `Super + Ctrl + E` | Výber emoji |
| `Super + Ctrl + .` | Prekódovať médiá |
| `Super + Shift + Ctrl + A` | Spustiť predvoleného agenta |
| `Power` key | Systémová ponuka |
| `Super + Shift + Copilot` key | Ponuka Omarchy |

## Úpravy

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximálny jas obrazovky |
| `Shift + Brightness Down` | Minimálny jas obrazovky |
| `Alt + Brightness Up/Down` | Presné zmeny jasu o 1 % |
| `Alt + Volume Up/Down` | Presné zmeny hlasitosti o 1 % |
| `Keyboard Brightness Up/Down` | Jasnejšie/slabšie podsvietenie klávesnice |
| `Keyboard Backlight` | Cyklicky prepínať úrovne podsvietenia klávesnice |
| `Ctrl + Brightness Up/Down` | Jasnejšie/slabšie podsvietenie klávesnice na klávesniciach bez vlastných klávesov |
| `Mic Mute` | Stlmiť mikrofón |
| `Shift + Mute` | Prepnúť výstup zvuku |
| `Touchpad Toggle` | Zapnúť alebo vypnúť touchpad |
| `Display` key | Cyklicky prepínať rozloženie pracovného priestoru |
| `Alt + Play` | Ďalšia skladba |
| `Alt + Shift + Play` | Predchádzajúca skladba |

## Spúšťanie aplikácií

| Klávesová skratka                  | Funkcia              |
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
| `Super + Shift + N`           | Editor (Plain alebo váš zvolený predvolený)  |
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

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + A`           | Vybrať všetko v aplikáciách, ktoré podporujú `Ctrl + A`    |
| `Super + C`           | Kopírovať    |
| `Super + X`           | Vystrihnúť (nie v termináli)    |
| `Super + V`           | Prilepiť    |
| `Super + Ctrl + V`           | Správca schránky    |

Na Linuxe zvyčajne potrebujete `Ctrl + Shift + C/V` na kopírovanie a prilepovanie v termináli a `Ctrl + C/V` na to všade inde. Tieto zjednotené klávesové skratky schránky v Omarchy fungujú všade.

## Snímanie

| Klávesová skratka              | Funkcia                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Snímka obrazovky                      |
| `Super + Ctrl + Alt + C`            | Snímka obrazovky (rovnaký záber, pre klávesnice bez klávesu Print Screen) |
| `Super + Ctrl + C` | Ponuka snímania |
| `Alt + Print Screen`            | Nahrávanie obrazovky                     |
| `Super + Shift + Ctrl + Alt + C` | Nahrávanie obrazovky bez zvuku, s preskočením ponuky (opätovným stlačením zastavíte) |
| `Super + Print Screen` | Výber farby |
| `Super + Ctrl + Print Screen` | Extrakcia textu do schránky |
| `Super + Alt + [` | Zmenšiť prekrytie webkamery počas nahrávania |
| `Super + Alt + ]` | Zväčšiť prekrytie webkamery počas nahrávania |
| `Alt + Shift + L` | Kopírovať aktuálnu URL z webovej aplikácie alebo prehliadača |
| `Alt + Shift + D` | Stiahnuť video na aktuálnej stránke do `~/Videos` |
| `Alt + Space` | Spustiť/zastaviť diktovanie (vyžaduje _Setup > Defaults > Dictation_) |
| `Right Alt` | Podržaním diktovať (vyžaduje _Setup > Defaults > Dictation_) |

Pri nahrávaní obrazovky sa skratka najprv spýta, aký zvuk chcete, potom začne nahrávať. Opätovným stlačením nahrávanie zastavíte. Podrobnosti nájdete v časti [snímky obrazovky a nahrávanie](12-screenshots-recording.md).

Všetky možnosti snímania sú dostupné aj pod _Trigger > Capture_ v ponuke Omarchy (`Super + Space`).

## Oznámenia

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + ,` | Vykonať akciu pri najnovšom oznámení: otvoriť ho alebo stlačiť jeho jediné tlačidlo, vybrať z jeho možností alebo ho zrušiť, keď žiadne nemá  |
| `Super + Shift + ,` | Zrušiť všetky oznámenia |
| `Super + Ctrl + ,` | Ovládať oznámenia klávesnicou  |
| `Super + Alt + ,` | Zrušiť najnovšie oznámenie  |
| `Super + Shift + Alt + ,` | Otvoriť históriu oznámení  |
| `Super + Ctrl + Alt + ,` | Prepnúť stíšenie oznámení  |

## Štýl

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vybrať novú tému (tiež `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vybrať pozadie témy (tiež `Super + Ctrl + Space`) |
| `Super + Backspace` | Prepnúť priehľadnosť okna |
| `Super + Ctrl + Backspace` | Prepnúť štvorcový pomer strán jedného okna |

Ďalšie obrázky pozadia sa nachádzajú v `~/.config/omarchy/backgrounds/<theme name>`. Dostupné aj cez _Install > Style > Background_ v ponuke Omarchy.

Všetky možnosti štýlu sú dostupné aj pod _Appearance_ v ponuke Omarchy (`Super + Space`).

## Prepínače

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Prepnúť zamykanie pri nečinnosti |
| `Super + Ctrl + Delete` | Zapnúť/vypnúť displej notebooku |
| `Super + Ctrl + Alt + Delete` | Prepnúť zrkadlenie displeja notebooku |
| `Super + Shift + Space` | Prepnúť hornú lištu  |
| `Shift + Mute` | Prepnúť na ďalší výstup zvuku |
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

Klávesom prefixu je `Ctrl + Space` (`Ctrl + B` funguje tiež). Tieto väzby môžete zmeniť v `~/.config/tmux/tmux.conf`.

### Panely

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + v` | Rozdeliť panel vedľa (vertikálne) |
| `Prefix + h` | Rozdeliť panel nižšie (horizontálne) |
| `Prefix + x` | Zabiť panel |
| `Prefix + z` | Prepnúť priblíženie panela (celá obrazovka) |
| `Alt + Enter` | Rozdeliť panel nižšie (bez prefixu) |
| `Alt + Shift + Enter` | Rozdeliť panel vedľa (bez prefixu) |
| `Alt + Escape` | Zabiť panel (bez prefixu) |
| `Ctrl + Alt + Arrows` | Presúvať sa medzi panelmi |
| `Ctrl + Alt + Shift + Arrows` | Meniť veľkosť panelov |

### Okná

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nové okno |
| `Prefix + k` | Zabiť okno |
| `Prefix + r` | Premenovať okno |
| `Alt + 1-9` | Prejsť na konkrétne okno |
| `Alt + Arrow Left/Right` | Presúvať sa medzi oknami |
| `Alt + Shift + Arrow Left/Right` | Presunúť okno doľava/doprava |

### Relácie

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nová relácia |
| `Prefix + K` | Zabiť reláciu |
| `Prefix + R` | Premenovať reláciu |
| `Prefix + N` | Ďalšia relácia |
| `Prefix + P` | Predchádzajúca relácia |
| `Alt + Arrow Up/Down` | Presúvať sa medzi reláciami |
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
| `Prefix + q` | Znova načítať konfiguráciu |
| `Prefix + ?` | Zobraziť klávesové skratky Tmux |
| `Prefix + :` | Príkazový riadok |

### Funkcie rozloženia Tmux

Tieto funkcie sa musia spúšťať vnútri relácie Tmux.

| Príkaz | Funkcia |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Vytvoriť vývojové rozloženie s editorom, AI a terminálom |
| `tdlm <ai> [<second_ai>]` | Vytvoriť vývojové rozloženie pre každý podadresár |
| `tsl <count> <command>` | Vytvoriť rozloženie roja s viacerými panelmi |

## Terminál Ghostty

Terminál Ghostty sa inštaluje pomocou _Install > Terminal_ cez ponuku Omarchy.

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nové rozdelenie nižšie |
| `Ctrl + Shift + O` | Nové rozdelenie vedľa |
| `Ctrl + Alt + Arrows` | Presúvať sa medzi rozdeleniami |
| `Super + Ctrl + Shift + Arrows` | Zmeniť veľkosť rozdelenia o 10 riadkov |
| `Super + Ctrl + Shift + Alt + Arrows` | Zmeniť veľkosť rozdelenia o 100 riadkov |
| `Ctrl + Shift + T` | Nová karta  |
| `Ctrl + Shift + Arrows` | Presúvať sa medzi kartami |
| `Alt + Numbers` | Prejsť na konkrétnu kartu |
| `Shift + Pg Up/Down` | Posúvať históriu |
| `Ctrl + Left mouse` | Otvoriť odkaz v prehliadači |

## Správca súborov

| Klávesová skratka              | Funkcia                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Prejsť na cestu                     |
| `Space`               | Náhľad súboru (navigácia šípkami) |
| `Alt + Up`       | Prejsť nahor do nadradeného priečinka        |

## Neovim (s lazyvim)

### Navigácia

| Klávesová skratka                   | Funkcia                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Zobraziť možnosti príkazov            |
| `Space Space`              | Otvoriť súbor cez fuzzy vyhľadávanie      |
| `Space E`                  | Prepnúť bočný panel                  |
| `Space G G`                | Zobraziť ovládanie git               |
| `Space S G`                | Hľadať v obsahu súboru             |
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

[Pozrite si všetky klávesové skratky Neovim nakonfigurované LazyVim](https://www.lazyvim.org/keymaps).

## Rýchle emoji

Pomocou `Super + Ctrl + E` môžete zobraziť úplný výber emoji, ktorý umiestni výber do schránky, alebo môžete použiť tieto možnosti rýchleho prístupu.

| Klávesová skratka       | EM | Nápoveda       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | úsmev      |
| `Shift + CapsLock M C` | 😂 | plač        |
| `Shift + CapsLock M L` | 😍 | láska       |
| `Shift + CapsLock M V` | ✌️ | víťazstvo    |
| `Shift + CapsLock M H` | ❤️ | srdce      |
| `Shift + CapsLock M Y` | 👍 | áno        |
| `Shift + CapsLock M N` | 👎 | nie         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | želanie       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | bozk       |
| `Shift + CapsLock M E` | 🙄 | prevrátenie očí    |
| `Shift + CapsLock M I` | 😉 | žmurknutie       |
| `Shift + CapsLock M P` | 🙏 | modlitba |
| `Shift + CapsLock M D` | 🤤 | slintanie      |
| `Shift + CapsLock M M` | 💰 | peniaze      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | prípitok      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pozdrav |
| `Shift + CapsLock M A` |💪 | ruka |
| `Shift + CapsLock M B` |🤯 | fúkanie |

## Rýchle dopĺňanie

| Klávesová skratka       | Dokončenie       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (dlhá pomlčka)   |
| `Shift + CapsLock Space N` | Vaše meno (ako bolo zadané pri nastavení)  |
| `Shift + CapsLock Space E` | Váš e-mail (ako bol zadaný pri nastavení)  |

Ďalšie vlastné môžete pridať úpravou `~/.XCompose` a následným spustením `omarchy restart xcompose` v termináli, aby sa zmeny načítali.
