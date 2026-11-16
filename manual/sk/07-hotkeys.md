# Klávesové skratky

Všetky hlavné klávesové skratky si môžete pozrieť pomocou `Super + K` (skratky pre Tmux pomocou `Super + Alt + K` a skratky pre Herdr pomocou `Super + Ctrl + K`).

## Ako sú klávesové skratky usporiadané

Každá klávesová skratka sedí na jednej rovine, určenej jej modifikátormi, a každá rovina má jednu úlohu. Práve to bráni tomu, aby sa skratky navzájom plietli, a znamená to, že zvyčajne uhádnete, kde čo nájdete.

| Rovina | Čo tam patrí | Príklady |
| --- | --- | --- |
| `Super + key` | Systém: okná, pracovné plochy, rozloženia a základné ponuky | `Super + Space` ponuka Omarchy, `Super + W` zatvoriť okno, `Super + F` na celú obrazovku |
| `Super + Shift + key` | Aplikácie | `Super + Shift + B` prehliadač, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panely a systémové ponuky | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` sieť, `Super + Ctrl + C` ponuka zachytávania |
| `Super + Ctrl + Alt + key` | Rýchle akcie a oznámenia | `Super + Ctrl + Alt + T` zobraziť čas, `Super + Ctrl + Alt + B` batéria, `Super + Ctrl + Alt + C` snímka obrazovky |

Pridaním `Alt` ku klávesovej skratke získate variant tej istej veci, nikdy niečo nesúvisiace:

- `Super + Shift + B` otvorí prehliadač; `Super + Shift + Alt + B` otvorí súkromné okno
- `Super + Shift + E` otvorí e-mail; `Super + Shift + Alt + E` začne nový
- `Super + F` prejde na celú obrazovku; `Super + Alt + F` prejde na celú šírku
- `Super + Ctrl + C` otvorí ponuku zachytávania; `Super + Ctrl + Alt + C` ponuku preskočí a urobí snímku obrazovky

Pri pridávaní klávesovej skratky:

1. Vyberte rovinu podľa toho, čo robí, potom vyberte kláves.
2. Nepremiestňujte existujúcu klávesovú skratku, aby ste uvoľnili miesto. Nájdite voľný kláves na správnej rovine.
3. `Alt` používajte len pre variant skratky bez neho.

Niekoľko klávesových skratiek tieto pravidlá porušuje, pretože je to pohodlné. `Shift` so šípkou alebo `Tab` posúva alebo obracia smer namiesto otvárania aplikácie a `Print`, multimediálne klávesy, `Alt + Tab` a `Ctrl + Alt + Del` fungujú tak, ako všade inde. Sú to výnimky, nie vzory na kopírovanie.

Ak vám predvolená skratka nevyhovuje (povedzme, že chcete `Super + Shift + S` na snímky obrazovky ako vo Windowse), premapujte ju v `~/.config/hypr/bindings.lua`.

## Navigácia

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Space`           | Ponuka Omarchy (aplikácie a všetko ostatné)    |
| `Super + Alt + Space` | Mriežka aplikácií |
| `Super + Escape` | Systémová ponuka (uspať, reštartovať atď.)  |
| `Super + Ctrl + L` | Zamknúť počítač |
| `Super + W` or `Super + Q` | Zatvoriť okno             |
| `Ctrl + Alt + Del` | Zatvoriť všetky okná |
| `Super + T`               | Prepnúť okno medzi dlaždicovým/plávajúcim režimom             |
| `Super + J` | Prepnúť polohu okna (horizontálna/vertikálna) |
| `Super + O`               | Prepnúť okno na pripnuté a plávajúce |
| `Super + L`               | Prechádzať rozloženiami dwindle, scrolling a floating |
| `Super + Alt + L`         | Prechádzať rozloženiami v opačnom poradí |
| `Super + P`               | Prepnúť štýl pseudo okna (prirodzený vs. roztiahnutý) |
| `Super + F`                 | Prejsť na celú obrazovku              |
| `Super + Alt + F`                 | Prejsť na celú šírku              |
| `Super + Ctrl + F`                 | Prejsť na celú obrazovku vnútri okna              |
| `Super + 1/2/3/4`         | Prejsť na konkrétnu pracovnú plochu na zameranom monitore |
| `Super + Tab` | Prejsť na ďalšiu pracovnú plochu na zameranom monitore |
| `Super + Shift + Tab` | Prejsť na predchádzajúcu pracovnú plochu na zameranom monitore |
| `Super + Ctrl + Tab` | Prejsť na predošlú pracovnú plochu na zameranom monitore |
| `Super + Shift + 1/2/3/4` | Presunúť okno na pracovnú plochu na zameranom monitore |
| `Super + Shift + Alt + 1/2/3/4` | Presunúť okno na pracovnú plochu na zameranom monitore bez nasledovania |
| `Super + S` | Prepnúť celý scratchpad |
| `Super + Alt + S` | Presunúť okno do celého scratchpadu |
| `Super + Grave` | Prepnúť konzolu Quake |
| `Super + Shift + Grave` | Presunúť okno do konzoly Quake |
| `Super + Shift + Ctrl + Arrows` | Presunúť okno na monitor v danom smere |
| `Super + Shift + Alt + Arrows` | Presunúť pracovnú plochu na monitor v danom smere |
| `Super + Arrow`  | Presunúť zameranie na okno v smere šípky, na okraji obrazovky prejsť na monitor na tej strane |
| `Super + Shift + Arrow`  | Vymeniť okno s iným v smere šípky, vrátane okna na monitore na tej strane |
| `Super + Minus` | Rozšíriť okno doľava |
| `Super + Equal` | Zúžiť okno zľava |
| `Super + Shift + Minus` | Zmenšiť okno nahor |
| `Super + Shift + Equal` | Rozšíriť okno nadol |
| `Super + Alt + Minus/Equal` | Rovnaké zmeny veľkosti v menších krokoch |
| `Super + Ctrl + Minus/Equal` | Rovnaké zmeny veľkosti vo väčších krokoch |
| `Super + Alt + Home` | Uložiť šírku okna |
| `Super + Home` | Obnoviť uloženú šírku okna |
| `Super + Left Mouse` | Ťahať okno |
| `Super + Right Mouse` | Meniť veľkosť okna |
| `Super + Scroll Wheel` | Prechádzať pracovnými plochami na zameranom monitore |
| `Super + G`               | Prepnúť zoskupovanie okien      |
| `Super + Alt + G`               | Presunúť okno von zo skupiny      |
| `Super + Alt + Tab`               | Prechádzať medzi oknami v skupine      |
| `Super + Alt + Shift + Tab`               | Prechádzať dozadu medzi oknami v skupine      |
| `Super + Alt + Scroll Wheel` | Prechádzať medzi oknami v skupine |
| `Super + Alt + 1/2/3/4/5`               | Prejsť na konkrétne okno v skupine      |
| `Super + Alt + Arrow`  | Presunúť okno do skupiny v smere šípky, vrátane okna na monitore na tej strane |
| `Super + Ctrl + Left/Right`  | Pohyb medzi oknami vnútri dlaždicovej skupiny |
| `Super + Ctrl + Z` | Priblížiť obrazovku (opakovaním priblížite viac) |
| `Super + Ctrl + Alt + Z` | Úplne oddialiť obrazovku |
| `Super + /` | Krok vpred medzi možnosťami škálovania monitora |
| `Super + Alt + /` | Krok vzad medzi možnosťami škálovania monitora |
| `Alt + Tab` | Prechádzať dopredu medzi oknami na aktívnej pracovnej ploche |
| `Alt + Shift + Tab` | Prechádzať dozadu medzi oknami na aktívnej pracovnej ploche |
| `Ctrl + Alt + Tab`| Prechádzať zameraním dopredu medzi monitormi |
| `Ctrl + Alt + Shift + Tab`| Prechádzať zameraním dozadu medzi monitormi |

Skratky na zmenu veľkosti používajú fyzické klávesy `code:20` a `code:21` (XKB `<AE11>` a `<AE12>`), bez ohľadu na znaky vytlačené na klávesnici. Na amerických klávesniciach sú to klávesy `-` a `=`; na japonských (JIS) klávesniciach sú to `-` a `^`; na španielskych klávesniciach sú to `'` a `¡`. Na JIS je `Super + ^` `Super + Equal`, zatiaľ čo `Super + Shift + -` (ktoré napíše `=`) je `Super + Shift + Minus`.

## Systémové ovládanie

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel zvuku    |
| `Super + Ctrl + B`           | Panel Bluetooth    |
| `Super + Ctrl + N`           | Panel Wi-Fi/siete    |
| `Super + Ctrl + D`           | Panel displeja    |
| `Super + Ctrl + P`           | Panel napájania    |
| `Super + Ctrl + X`           | Panel agentov    |
| `Super + Ctrl + Alt + D`           | Panel kalendára    |
| `Super + Ctrl + Alt + E`           | Panel svetového času    |
| `Super + Ctrl + 1-9`           | Prepnúť panel lišty podľa pozície    |
| `Super + Ctrl + S` | Ponuka zdieľania (cez LocalSend) |
| `Super + Ctrl + C` | Ovládanie zachytávania (snímka obrazovky/nahrávanie/výber) |
| `Super + Ctrl + O` | Prepnúť ponuku |
| `Super + Ctrl + H` | Ponuka hardvéru |
| `Super + Ctrl + E` | Výber emoji |
| `Super + Ctrl + .` | Prekódovať médiá |
| `Super + Shift + Ctrl + A` | Vybrať AI agenta |

## Úpravy

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximálny jas obrazovky |
| `Shift + Brightness Down` | Minimálny jas obrazovky |
| `Alt + Brightness Up/Down` | Presné zmeny jasu po 1 % |
| `Alt + Volume Up/Down` | Presné zmeny hlasitosti po 1 % |
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
| `Super + Shift + G`           | Komunikátor (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Komunikátor (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Komunikátor (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Písanie (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Väzby zmeňte/pridajte v `~/.config/hypr/bindings.lua`.

## Univerzálna schránka

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + A`           | Vybrať všetko v aplikáciách, ktoré podporujú `Ctrl + A`    |
| `Super + C`           | Kopírovať    |
| `Super + X`           | Vystrihnúť (nie v termináli)    |
| `Super + V`           | Prilepiť    |
| `Super + Ctrl + V`           | Správca schránky    |

Na Linuxe zvyčajne potrebujete `Ctrl + Shift + C/V` na kopírovanie a prilepovanie v termináli a `Ctrl + C/V` na to všade inde. Tieto zjednotené klávesové skratky schránky v Omarchy fungujú všade.

## Zachytávanie

| Klávesová skratka              | Funkcia                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Snímka obrazovky                      |
| `Super + Ctrl + Alt + C`            | Snímka obrazovky (ten istý záber, pre klávesnice bez klávesu Print Screen) |
| `Super + Ctrl + C` | Ponuka zachytávania |
| `Alt + Print Screen`            | Nahrávanie obrazovky                     |
| `Super + Print Screen` | Výber farby |
| `Super + Ctrl + Print Screen` | Extrakcia textu do schránky |
| `Super + Alt + [` | Zmenšiť prekrytie webkamery počas nahrávania |
| `Super + Alt + ]` | Zväčšiť prekrytie webkamery počas nahrávania |
| `Alt + Shift + L` | Kopírovať aktuálnu URL z webovej aplikácie alebo prehliadača |
| `Alt + Shift + D` | Stiahnuť video na aktuálnej stránke do `~/Videos` |
| `Alt + Space` | Spustiť/zastaviť diktovanie (vyžaduje _Nastavenie > Predvolené > Diktovanie_) |
| `Right Alt` | Podržaním diktovať (vyžaduje _Nastavenie > Predvolené > Diktovanie_) |

Pri nahrávaní obrazovky sa skratka najprv opýta, ktorý zvuk chcete, a potom spustí nahrávanie. Stlačte ju znova na zastavenie. Podrobnosti nájdete v [snímky obrazovky a nahrávanie](12-screenshots-recording.md).

Všetky možnosti zachytávania sú dostupné aj v ponuke Omarchy (`Super + Space`) pod _Spúšťač > Zachytávanie_.

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
| `Super + Ctrl + T` | Vybrať novú tému (aj `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vybrať pozadie témy (aj `Super + Ctrl + Space`) |
| `Super + Backspace` | Prepnúť priehľadnosť okna |
| `Super + Ctrl + Backspace` | Prepnúť štvorcový pomer strán jedného okna |

Ďalšie obrázky pozadia sa nachádzajú v `~/.config/omarchy/backgrounds/<theme name>`. Dostupné aj cez _Inštalovať > Štýl > Pozadie_ v ponuke Omarchy.

Všetky možnosti štýlu sú dostupné aj v ponuke Omarchy (`Super + Space`) pod _Štýl_.

## Prepínače

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Prepnúť zamykanie pri nečinnosti |
| `Super + Ctrl + Delete` | Prepnúť displej notebooku zap./vyp. |
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

Kláves prefixu je `Ctrl + Space` (`Ctrl + B` funguje tiež). Tieto väzby môžete zmeniť v `~/.config/tmux/tmux.conf`.

### Panely

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + v` | Rozdeliť panel vedľa (vertikálne) |
| `Prefix + h` | Rozdeliť panel nižšie (horizontálne) |
| `Prefix + x` | Zabiť panel |
| `Prefix + z` | Prepnúť priblíženie panela (na celú obrazovku) |
| `Alt + Enter` | Rozdeliť panel nižšie (bez prefixu) |
| `Alt + Shift + Enter` | Rozdeliť panel vedľa (bez prefixu) |
| `Alt + Escape` | Zabiť panel (bez prefixu) |
| `Ctrl + Alt + Arrows` | Pohyb medzi panelmi |
| `Ctrl + Alt + Shift + Arrows` | Meniť veľkosť panelov |

### Okná

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nové okno |
| `Prefix + k` | Zabiť okno |
| `Prefix + r` | Premenovať okno |
| `Alt + 1-9` | Prejsť na konkrétne okno |
| `Alt + Arrow Left/Right` | Pohyb medzi oknami |
| `Alt + Shift + Arrow Left/Right` | Presunúť okno doľava/doprava |

### Relácie

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nová relácia |
| `Prefix + K` | Zabiť reláciu |
| `Prefix + R` | Premenovať reláciu |
| `Prefix + N` | Ďalšia relácia |
| `Prefix + P` | Predchádzajúca relácia |
| `Alt + Arrow Up/Down` | Pohyb medzi reláciami |
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
| `Prefix + ?` | Zobraziť klávesové skratky Tmuxu |
| `Prefix + :` | Príkazový riadok |

### Funkcie rozloženia Tmuxu

Tieto funkcie musíte spustiť vnútri relácie Tmuxu.

| Príkaz | Funkcia |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Vytvoriť vývojárske rozloženie s editorom, AI a terminálom |
| `tdlm <ai> [<second_ai>]` | Vytvoriť vývojárske rozloženie pre každý podadresár |
| `tsl <count> <command>` | Vytvoriť rozloženie roja s viacerými panelmi |

## Terminál Ghostty

Terminál Ghostty sa inštaluje pomocou _Inštalovať > Terminál_ cez ponuku Omarchy.

| Klávesová skratka                  | Funkcia              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nové rozdelenie nižšie |
| `Ctrl + Shift + O` | Nové rozdelenie vedľa |
| `Ctrl + Alt + Arrows` | Pohyb medzi rozdeleniami |
| `Super + Ctrl + Shift + Arrows` | Zmeniť veľkosť rozdelenia o 10 riadkov |
| `Super + Ctrl + Shift + Alt + Arrows` | Zmeniť veľkosť rozdelenia o 100 riadkov |
| `Ctrl + Shift + T` | Nová karta  |
| `Ctrl + Shift + Arrows` | Pohyb medzi kartami |
| `Alt + Numbers` | Prejsť na konkrétnu kartu |
| `Shift + Pg Up/Down` | Prechádzať históriou |
| `Ctrl + Left mouse` | Otvoriť odkaz v prehliadači |

## Správca súborov

| Klávesová skratka              | Funkcia                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Prejsť na cestu                     |
| `Space`               | Náhlad súboru (šípky navigujú) |
| `Alt + Up`       | Prejsť vyššie do nadradeného priečinka        |

## Neovim (s lazyvim)

### Navigácia

| Klávesová skratka                   | Funkcia                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Zobraziť možnosti príkazov            |
| `Space Space`              | Otvoriť súbor cez fuzzy vyhľadávanie      |
| `Space E`                  | Prepnúť bočný panel                  |
| `Space G G`                | Zobraziť ovládanie gitu               |
| `Space S G`                | Hľadať v obsahu súboru             |
| `Ctrl + W W`               | Skákať medzi bočným panelom a editorom |
| `Ctrl + Left/right arrow`  | Zmeniť veľkosť bočného panela          |
| `Shift + H`                      | Prejsť na kartu súboru vľavo             |
| `Shift + L`                      | Prejsť na kartu súboru vpravo            |
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

[Pozrite si všetky klávesové skratky Neovimu nakonfigurované LazyVimom](https://www.lazyvim.org/keymaps).

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
| `Shift + CapsLock M F` | 🖕 | do riti       |
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
| `Shift + CapsLock M A` |💪 | sval |
| `Shift + CapsLock M B` |🤯 | výbuch |

## Rýchle dopĺňanie

| Klávesová skratka       | Dopĺňanie       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (dlhá pomlčka)   |
| `Shift + CapsLock Space N` | Vaše meno (ako bolo zadané pri nastavení)  |
| `Shift + CapsLock Space E` | Váš e-mail (ako bol zadaný pri nastavení)  |

Svoje ďalšie môžete pridať úpravou `~/.XCompose` a potom spustením `omarchy-restart-xcompose` v termináli, aby sa zmeny načítali.
