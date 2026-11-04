# Klávesové zkratky

Všechny hlavní klávesové zkratky si můžete zobrazit pomocí `Super + K` (zkratky Tmux pomocí `Super + Alt + K` a zkratky Herdr pomocí `Super + Ctrl + K`).

## Jak jsou klávesové zkratky uspořádány

Každá klávesová zkratka leží v jedné rovině, určené jejími modifikátory, a každá rovina má jeden úkol. Díky tomu se klávesové zkratky nepletou dohromady a většinou snadno odhadnete, kde co najdete.

| Rovina | Co tam patří | Příklady |
| --- | --- | --- |
| `Super + key` | Systém: okna, pracovní plochy, rozvržení a základní menu | `Super + Space` menu Omarchy, `Super + W` zavřít okno, `Super + F` celá obrazovka |
| `Super + Shift + key` | Aplikace | `Super + Shift + B` prohlížeč, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panely a systémová menu | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` síť, `Super + Ctrl + C` menu zachytávání |
| `Super + Ctrl + Alt + key` | Rychlé akce a oznámení | `Super + Ctrl + Alt + T` zobrazit čas, `Super + Ctrl + Alt + B` baterie, `Super + Ctrl + Alt + C` snímek obrazovky |

Přidání `Alt` ke klávesové zkratce vám dá variantu téže věci, nikdy něco nesouvisejícího:

- `Super + Shift + B` otevře prohlížeč; `Super + Shift + Alt + B` otevře soukromé okno
- `Super + Shift + E` otevře e-mail; `Super + Shift + Alt + E` začne nový
- `Super + F` přejde na celou obrazovku; `Super + Alt + F` přejde na celou šířku
- `Super + Ctrl + C` otevře menu zachytávání; `Super + Ctrl + Alt + C` menu přeskočí a pořídí snímek obrazovky

Při přidávání klávesové zkratky:

1. Nejprve podle toho, co dělá, vyberte rovinu, pak vyberte klávesu.
2. Nepřesouvejte existující klávesovou zkratku, abyste uvolnili místo. Najděte volnou klávesu ve správné rovině.
3. `Alt` používejte jen pro variantu klávesové zkratky bez něj.

Několik klávesových zkratek tato pravidla porušuje, protože je to pohodlné. `Shift` se šipkou nebo `Tab` přesouvá nebo obrací směr místo otevírání aplikace a `Print`, mediální klávesy, `Alt + Tab` a `Ctrl + Alt + Del` fungují tak, jak fungují všude jinde. Jsou to výjimky, ne vzory ke kopírování.

Pokud vám výchozí nastavení nevyhovuje (třeba chcete `Super + Shift + S` pro snímky obrazovky jako ve Windows), převažte si ji v `~/.config/hypr/bindings.lua`.

## Navigace

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Super + Space` | Menu Omarchy (aplikace a všechno ostatní) |
| `Super + Alt + Space` | Mřížka aplikací |
| `Super + Escape` | Systémové menu (uspání, restart atd.) |
| `Super + Ctrl + L` | Zamknout počítač |
| `Super + W` nebo `Super + Q` | Zavřít okno |
| `Ctrl + Alt + Del` | Zavřít všechna okna |
| `Super + T` | Přepnout okno mezi dlaždicovým/plovoucím režimem |
| `Super + J` | Přepnout pozici okna (vodorovná/svislá) |
| `Super + O` | Přepnout vyskakování okna do sticky'n'floating |
| `Super + L` | Procházet rozvržení dwindle, scrolling a floating |
| `Super + Alt + L` | Procházet rozvržení v opačném pořadí |
| `Super + P` | Přepnout styl pseudo okna (přirozený vs. roztažený) |
| `Super + F` | Přejít na celou obrazovku |
| `Super + Alt + F` | Přejít na celou šířku |
| `Super + Ctrl + F` | Přejít na celou obrazovku uvnitř okna |
| `Super + 1/2/3/4` | Přeskočit na konkrétní pracovní plochu na zaměřeném monitoru |
| `Super + Tab` | Přeskočit na další pracovní plochu na zaměřeném monitoru |
| `Super + Shift + Tab` | Přeskočit na předchozí pracovní plochu na zaměřeném monitoru |
| `Super + Ctrl + Tab` | Přeskočit na dřívější pracovní plochu na zaměřeném monitoru |
| `Super + Shift + 1/2/3/4` | Přesunout okno na pracovní plochu na zaměřeném monitoru |
| `Super + Shift + Alt + 1/2/3/4` | Přesunout okno na pracovní plochu na zaměřeném monitoru bez následování |
| `Super + S` | Přepnout plný scratchpad |
| `Super + Alt + S` | Přesunout okno do plného scratchpadu |
| `Super + Grave` | Přepnout konzoli Quake |
| `Super + Shift + Grave` | Přesunout okno do konzole Quake |
| `Super + Shift + Ctrl + Arrows` | Přesunout okno na monitor v daném směru |
| `Super + Shift + Alt + Arrows` | Přesunout pracovní plochu na monitor v daném směru |
| `Super + Arrow` | Přesunout zaměření na okno ve směru šipky, na okraji obrazovky přejít na monitor na té straně |
| `Super + Shift + Arrow` | Prohodit okno s jiným ve směru šipky, včetně okna na monitoru na té straně |
| `Super + Minus` | Rozšířit okno doleva |
| `Super + Equal` | Zmenšit okno doleva |
| `Super + Shift + Minus` | Zmenšit okno nahoru |
| `Super + Shift + Equal` | Rozšířit okno dolů |
| `Super + Alt + Minus/Equal` | Totéž měnění velikosti v menších krocích |
| `Super + Ctrl + Minus/Equal` | Totéž měnění velikosti ve větších krocích |
| `Super + Alt + Home` | Uložit šířku okna |
| `Super + Home` | Obnovit uloženou šířku okna |
| `Super + Left Mouse` | Táhnout okno |
| `Super + Right Mouse` | Měnit velikost okna |
| `Super + Scroll Wheel` | Procházet pracovní plochy na zaměřeném monitoru |
| `Super + G` | Přepnout seskupování oken |
| `Super + Alt + G` | Přesunout okno ze seskupení |
| `Super + Alt + Tab` | Procházet okna ve seskupení |
| `Super + Alt + Shift + Tab` | Procházet okna ve seskupení pozpátku |
| `Super + Alt + Scroll Wheel` | Procházet okna ve seskupení |
| `Super + Alt + 1/2/3/4/5` | Přeskočit na konkrétní okno ve seskupení |
| `Super + Alt + Arrow` | Přesunout okno do seskupení ve směru šipky, včetně okna na monitoru na té straně |
| `Super + Ctrl + Left/Right` | Přecházet mezi okny uvnitř dlaždicové skupiny |
| `Super + Ctrl + Z` | Přiblížit obrazovku (opakováním přiblížíte víc) |
| `Super + Ctrl + Alt + Z` | Úplně oddálit obrazovku |
| `Super + /` | Krok vpřed mezi možnostmi škálování monitoru |
| `Super + Alt + /` | Krok zpět mezi možnostmi škálování monitoru |
| `Alt + Tab` | Procházet okna na aktivní pracovní ploše vpřed |
| `Alt + Shift + Tab` | Procházet okna na aktivní pracovní ploše pozpátku |
| `Ctrl + Alt + Tab` | Procházet zaměření mezi monitory vpřed |
| `Ctrl + Alt + Shift + Tab` | Procházet zaměření mezi monitory pozpátku |

Klávesové zkratky pro změnu velikosti používají fyzické klávesy `code:20` a `code:21` (XKB `<AE11>` a `<AE12>`) bez ohledu na znaky vytištěné na klávesnici. Na amerických klávesnicích jsou to klávesy `-` a `=`; na japonských klávesnicích (JIS) `-` a `^`; na španělských klávesnicích `'` a `¡`. Na JIS je `Super + ^` totéž co `Super + Equal`, zatímco `Super + Shift + -` (které píše `=`) je `Super + Shift + Minus`.

## Ovládání systému

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Panel zvuku |
| `Super + Ctrl + B` | Panel Bluetooth |
| `Super + Ctrl + N` | Panel Wi-Fi/sítě |
| `Super + Ctrl + D` | Panel displeje |
| `Super + Ctrl + P` | Panel napájení |
| `Super + Ctrl + Alt + D` | Panel kalendáře |
| `Super + Ctrl + Alt + E` | Panel světového času |
| `Super + Ctrl + 1-9` | Přepnout panel lišty podle pozice |
| `Super + Ctrl + S` | Menu sdílení (přes LocalSend) |
| `Super + Ctrl + C` | Ovládání zachytávání (snímek obrazovky/-nahrávání/výběr) |
| `Super + Ctrl + O` | Přepnout menu |
| `Super + Ctrl + H` | Menu hardwaru |
| `Super + Ctrl + E` | Výběr emoji |
| `Super + Ctrl + .` | Překódovat média |
| `Super + Shift + Ctrl + A` | Vybrat AI agenta |

## Úpravy

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximální jas obrazovky |
| `Shift + Brightness Down` | Minimální jas obrazovky |
| `Alt + Brightness Up/Down` | Přesné změny jasu po 1 % |
| `Alt + Volume Up/Down` | Přesné změny hlasitosti po 1 % |
| `Keyboard Brightness Up/Down` | Podsvícení klávesnice jasnější/tmavší |
| `Keyboard Backlight` | Procházet úrovně podsvícení klávesnice |
| `Alt + Play` | Další skladba |
| `Alt + Shift + Play` | Předchozí skladba |

## Spouštění aplikací

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Super + Return` | Terminál |
| `Super + Alt + Return` | Terminál Tmux |
| `Super + Ctrl + Return` | Herdr (správce agentů) |
| `Super + Shift + Return` | Prohlížeč |
| `Super + Shift + Alt + B` | Prohlížeč (soukromý/anonymní) |
| `Super + Shift + F` | Správce souborů |
| `Super + Shift + Alt + F` | Správce souborů v cwd terminálu |
| `Super + Shift + M` | Hudba (Spotify) |
| `Super + Shift + Alt + M` | Hudba (cliamp) |
| `Super + Shift + /` | Správce hesel (1password) |
| `Super + Shift + Q` | Kalkulačka (Omacalc) |
| `Super + Shift + T` | Aktivita (btop) |
| `Super + Shift + N` | Editor (Neovim) |
| `Super + Shift + C` | Kalendář ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-mail ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Nový e-mail ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Komunikátor (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Komunikátor (WhatsApp) |
| `Super + Shift + Ctrl + G` | Komunikátor (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Psaní (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

Změňte/přidejte vazby v `~/.config/hypr/bindings.lua`.

## Univerzální schránka

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Super + A` | Vybrat vše v aplikacích, které podporují `Ctrl + A` |
| `Super + C` | Kopírovat |
| `Super + X` | Vyjmout (ne v terminálu) |
| `Super + V` | Vložit |
| `Super + Ctrl + V` | Správce schránky |

V Linuxu obvykle potřebujete `Ctrl + Shift + C/V` ke kopírování a vkládání v terminálu a `Ctrl + C/V` k témuž všude jinde. Tyto sjednocené klávesové zkratky schránky v Omarchy fungují všude.

## Zachytávání

| Klávesová zkratka | Funkce |
| ------------------- | ------------------------------ |
| `Print Screen` | Snímek obrazovky |
| `Super + Ctrl + Alt + C` | Snímek obrazovky (tentýž záběr, pro klávesnice bez klávesy Print Screen) |
| `Super + Ctrl + C` | Menu zachytávání |
| `Alt + Print Screen` | Nahrávání obrazovky |
| `Super + Print Screen` | Výběr barvy |
| `Super + Ctrl + Print Screen` | Extrakce textu do schránky |
| `Super + Alt + [` | Zmenšit překryv webkamery během nahrávání |
| `Super + Alt + ]` | Zvětšit překryv webkamery během nahrávání |
| `Alt + Shift + L` | Kopírovat aktuální URL z webové aplikace nebo Chromium |
| `Alt + Shift + D` | Stáhnout video na aktuální stránce do `~/Videos` |
| `Alt + Space` | Spustit/zastavit diktování (vyžaduje _Nastavení > Výchozí > Diktování_) |
| `Right Alt` | Podržte pro diktování (vyžaduje _Nastavení > Výchozí > Diktování_) |

U nahrávání obrazovky se zkratka nejprve zeptá, který zvuk chcete, a pak spustí nahrávání. Dalším stisknutím ho zastavíte. Podrobnosti najdete v [snímky obrazovky a nahrávání](12-screenshots-recording.md).

Všechny možnosti zachytávání jsou dostupné také pod _Trigger > Capture_ v menu Omarchy (`Super + Space`).

## Oznámení

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Super + ,` | Provést akci u nejnovějšího oznámení: otevřít ho nebo stisknout jeho jediné tlačítko, vybrat z jeho možností, nebo ho zavřít, když žádné nemá |
| `Super + Shift + ,` | Zavřít všechna oznámení |
| `Super + Ctrl + ,` | Ovládat oznámení klávesnicí |
| `Super + Alt + ,` | Zavřít nejnovější oznámení |
| `Super + Shift + Alt + ,` | Otevřít historii oznámení |
| `Super + Ctrl + Alt + ,` | Přepnout ztišení oznámení |

## Styl

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vybrat nový motiv (také `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vybrat pozadí motivu (také `Super + Ctrl + Space`) |
| `Super + Backspace` | Přepnout průhlednost okna |
| `Super + Ctrl + Backspace` | Přepnout čtvercový poměr stran jednoho okna |

Další obrázky pozadí jsou v `~/.config/omarchy/backgrounds/<theme name>`. Dostupné také přes _Install > Style > Background_ v menu Omarchy.

Všechny možnosti stylu jsou dostupné také pod _Style_ v menu Omarchy (`Super + Space`).

## Přepínače

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Přepnout zamykání při nečinnosti |
| `Super + Ctrl + Delete` | Přepnout displej notebooku zap./vyp. |
| `Super + Ctrl + Alt + Delete` | Přepnout zrcadlení displeje notebooku |
| `Super + Shift + Space` | Přepnout horní lištu |
| `Shift + Mute` | Přepnout na další zvukový výstup |
| `Shift + Play` | Přepnout na další zdroj médií |
| `Super + Shift + Backspace` | Přepnout mezery mezi okny |
| `Super + Ctrl + Alt + F` | Přepnout plochu na celou obrazovku (horní lišta + mezery mezi okny) |

## Připomínky

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Nastavit připomínku |
| `Super + Ctrl + Alt + R` | Zobrazit všechny připomínky |
| `Super + Ctrl + Shift + R` | Vymazat všechny připomínky |

## Upozornění

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Zobrazit čas jako oznámení |
| `Super + Ctrl + Alt + B` | Zobrazit baterii jako oznámení |
| `Super + Ctrl + Alt + W` | Přepnout počasí jako oznámení |

## Tmux

Předponová klávesa je `Ctrl + Space` (`Ctrl + B` také funguje). Tyto vazby můžete změnit v `~/.config/tmux/tmux.conf`.

### Panely

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Prefix + v` | Rozdělit panel vedle (svisle) |
| `Prefix + h` | Rozdělit panel níže (vodorovně) |
| `Prefix + x` | Ukončit panel |
| `Prefix + z` | Přepnout přiblížení panelu (celá obrazovka) |
| `Alt + Enter` | Rozdělit panel níže (bez předpony) |
| `Alt + Shift + Enter` | Rozdělit panel vedle (bez předpony) |
| `Alt + Escape` | Ukončit panel (bez předpony) |
| `Ctrl + Alt + Arrows` | Přecházet mezi panely |
| `Ctrl + Alt + Shift + Arrows` | Měnit velikost panelů |

### Okna

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Prefix + c` | Nové okno |
| `Prefix + k` | Ukončit okno |
| `Prefix + r` | Přejmenovat okno |
| `Alt + 1-9` | Přejít na konkrétní okno |
| `Alt + Arrow Left/Right` | Přecházet mezi okny |
| `Alt + Shift + Arrow Left/Right` | Přesunout okno doleva/doprava |

### Relace

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Prefix + C` | Nová relace |
| `Prefix + K` | Ukončit relaci |
| `Prefix + R` | Přejmenovat relaci |
| `Prefix + N` | Další relace |
| `Prefix + P` | Předchozí relace |
| `Alt + Arrow Up/Down` | Přecházet mezi relacemi |
| `Prefix + s` | Seznam relací |
| `Prefix + d` | Odpojit se od relace |

### Režim kopírování (ve stylu vi)

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Prefix + [` | Vstoupit do režimu kopírování |
| `v` | Začít výběr (v režimu kopírování) |
| `y` | Kopírovat výběr (v režimu kopírování) |

### Obecné

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Prefix + q` | Znovu načíst konfiguraci |
| `Prefix + ?` | Zobrazit klávesové zkratky Tmux |
| `Prefix + :` | Příkazový řádek |

### Funkce rozvržení Tmux

Tyto funkce musíte spouštět uvnitř relace Tmux.

| Příkaz | Funkce |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Vytvořit vývojářské rozvržení s editorem, AI a terminálem |
| `tdlm <ai> [<second_ai>]` | Vytvořit vývojářské rozvržení pro každý podadresář |
| `tsl <count> <command>` | Vytvořit vícepanelové rozvržení swarm |

## Terminál Ghostty

Terminál Ghostty se instaluje pomocí _Install > Terminal_ přes menu Omarchy.

| Klávesová zkratka | Funkce |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nové rozdělení níže |
| `Ctrl + Shift + O` | Nové rozdělení vedle |
| `Ctrl + Alt + Arrows` | Přecházet mezi rozděleními |
| `Super + Ctrl + Shift + Arrows` | Změnit velikost rozdělení o 10 řádků |
| `Super + Ctrl + Shift + Alt + Arrows` | Změnit velikost rozdělení o 100 řádků |
| `Ctrl + Shift + T` | Nová karta |
| `Ctrl + Shift + Arrows` | Přecházet mezi kartami |
| `Alt + Numbers` | Přejít na konkrétní kartu |
| `Shift + Pg Up/Down` | Procházet historii |
| `Ctrl + Left mouse` | Otevřít odkaz v prohlížeči |

## Správce souborů

| Klávesová zkratka | Funkce |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Přejít na cestu |
| `Space` | Náhled souboru (šipky navigují) |
| `Alt + Up` | Přejít nahoru do nadřazené složky |

## Neovim (s lazyvim)

### Navigace

| Klávesová zkratka | Funkce |
| ------------------------ | ------------------------------- |
| `Space` | Zobrazit možnosti příkazů |
| `Space Space` | Otevřít soubor přes fuzzy vyhledávání |
| `Space E` | Přepnout postranní panel |
| `Space G G` | Zobrazit ovládání git |
| `Space S G` | Hledat obsah souborů |
| `Ctrl + W W` | Přeskakovat mezi postranním panelem a editorem |
| `Ctrl + Left/right arrow` | Změnit velikost postranního panelu |
| `Shift + H` | Přejít na kartu souboru vlevo |
| `Shift + L` | Přejít na kartu souboru vpravo |
| `Space B D` | Zavřít kartu souboru |

### V postranním panelu

| Klávesová zkratka | Funkce |
| ------------------------ | ------------------------------- |
| `A` | Přidat nový soubor v nadřazeném adresáři |
| `Shift + A` | Přidat nový podadresář v nadřazeném adresáři |
| `D` | Smazat zvýrazněný soubor/adresář |
| `M` | Přesunout zvýrazněný soubor/adresář |
| `R` | Přejmenovat zvýrazněný soubor/adresář |
| `?` | Zobrazit nápovědu ke všem příkazům |

[Zobrazit všechny klávesové zkratky Neovim nakonfigurované LazyVim](https://www.lazyvim.org/keymaps).

## Rychlé emoji

Pomocí `Super + Ctrl + E` můžete zobrazit kompletní výběr emoji, který vloží výběr do schránky, nebo můžete použít tyto možnosti rychlého přístupu.

| Klávesová zkratka | EM | Nápověda |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | úsměv |
| `Shift + CapsLock M C` | 😂 | pláč |
| `Shift + CapsLock M L` | 😍 | láska |
| `Shift + CapsLock M V` | ✌️ | vítězství |
| `Shift + CapsLock M H` | ❤️ | srdce |
| `Shift + CapsLock M Y` | 👍 | ano |
| `Shift + CapsLock M N` | 👎 | ne |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | přání |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | polibek |
| `Shift + CapsLock M E` | 🙄 | protočení očí |
| `Shift + CapsLock M I` | 😉 | mrknutí |
| `Shift + CapsLock M P` | 🙏 | modlitba |
| `Shift + CapsLock M D` | 🤤 | slintání |
| `Shift + CapsLock M M` | 💰 | peníze |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | přípitek |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pozdrav |
| `Shift + CapsLock M A` |💪 | paže |
| `Shift + CapsLock M B` |🤯 | výbuch |

## Rychlá doplňování

| Klávesová zkratka | Doplnění |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (dlouhá pomlčka) |
| `Shift + CapsLock Space N` | Vaše jméno (jak bylo zadáno při nastavení) |
| `Shift + CapsLock Space E` | Váš e-mail (jak byl zadán při nastavení) |

Své další můžete přidat úpravou `~/.XCompose`, pak spuštěním `omarchy-restart-xcompose` v terminálu, aby se změny projevily.
