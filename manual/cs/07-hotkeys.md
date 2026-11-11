# Klávesové zkratky

Všechny hlavní klávesové zkratky si zobrazíte pomocí `Super + K` (zkratky Tmux pomocí `Super + Alt + K` a zkratky Herdr pomocí `Super + Ctrl + K`).

## Jak jsou klávesové zkratky uspořádané

Každá klávesová zkratka sedí na jedné rovině, dané jejími modifikátory, a každá rovina má jeden úkol. Díky tomu se zkratky navzájem nepletou a většinou uhodnete, kde co žije.

| Rovina | Co na ní žije | Příklady |
| --- | --- | --- |
| `Super + key` | Systém: okna, pracovní plochy, rozložení a základní nabídky | `Super + Space` nabídka Omarchy, `Super + W` zavřít okno, `Super + F` celá obrazovka |
| `Super + Shift + key` | Aplikace | `Super + Shift + B` prohlížeč, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panely a systémové nabídky | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` síť, `Super + Ctrl + C` nabídka snímání |
| `Super + Ctrl + Alt + key` | Rychlé akce a upozornění | `Super + Ctrl + Alt + T` zobrazit čas, `Super + Ctrl + Alt + B` baterie, `Super + Ctrl + Alt + C` snímek obrazovky |

Přidání `Alt` ke klávesové zkratce vám dá variantu téže věci, nikdy něco nesouvisejícího:

- `Super + Shift + B` otevře prohlížeč; `Super + Shift + Alt + B` otevře soukromé okno
- `Super + Shift + E` otevře e-mail; `Super + Shift + Alt + E` založí nový
- `Super + F` přejde na celou obrazovku; `Super + Alt + F` přejde na celou šířku
- `Super + Ctrl + C` otevře nabídku snímání; `Super + Ctrl + Alt + C` nabídku přeskočí a pořídí snímek obrazovky

Při přidávání klávesové zkratky:

1. Vyberte rovinu podle toho, co dělá, pak vyberte klávesu.
2. Nepřesouvejte existující zkratku, abyste uvolnili místo. Najděte volnou klávesu na správné rovině.
3. `Alt` používejte pouze pro variantu zkratky bez něj.

Pár zkratek tato pravidla porušuje, protože je to pohodlné. `Shift` se šipkou nebo `Tab` přesouvá nebo obrací směr místo otevírání aplikace a `Print`, multimediální klávesy, `Alt + Tab` a `Ctrl + Alt + Del` fungují tak, jak fungují všude jinde. Jsou to výjimky, ne vzory ke kopírování.

Pokud vám výchozí nastavení nevyhovuje (řekněme chcete `Super + Shift + S` pro snímky obrazovky jako ve Windows), převažte si ji v `~/.config/hypr/bindings.lua`.

## Navigace

| Klávesová zkratka | Funkce |
| --- | --- |
| `Super + Space` | Nabídka Omarchy (aplikace a všechno ostatní) |
| `Super + Alt + Space` | Mřížka aplikací |
| `Super + Escape` | Systémová nabídka (uspání, restart atd.) |
| `Super + Ctrl + L` | Zamknout počítač |
| `Super + W` nebo `Super + Q` | Zavřít okno |
| `Ctrl + Alt + Del` | Zavřít všechna okna |
| `Super + T` | Přepnout okno mezi dlaždicovým/plovoucím režimem |
| `Super + J` | Přepnout polohu okna (vodorovně/svisle) |
| `Super + O` | Přepnout okno do režimu sticky'n'floating |
| `Super + L` | Procházet rozložení dwindle, scrolling a floating |
| `Super + Alt + L` | Procházet rozložení v opačném pořadí |
| `Super + P` | Přepnout styl pseudo okna (natural v stretch) |
| `Super + F` | Přejít na celou obrazovku |
| `Super + Alt + F` | Přejít na celou šířku |
| `Super + Ctrl + F` | Přejít na celou obrazovku uvnitř okna |
| `Super + 1/2/3/4` | Přeskočit na konkrétní pracovní plochu na zaměřeném monitoru |
| `Super + Tab` | Přeskočit na další pracovní plochu na zaměřeném monitoru |
| `Super + Shift + Tab` | Přeskočit na předchozí pracovní plochu na zaměřeném monitoru |
| `Super + Ctrl + Tab` | Přeskočit na dřívější pracovní plochu na zaměřeném monitoru |
| `Super + Shift + 1/2/3/4` | Přesunout okno na pracovní plochu na zaměřeném monitoru |
| `Super + Shift + Alt + 1/2/3/4` | Přesunout okno na pracovní plochu na zaměřeném monitoru bez následování |
| `Super + S` | Přepnout celý scratchpad |
| `Super + Alt + S` | Přesunout okno do celého scratchpadu |
| `Super + Grave` | Přepnout konzoli Quake |
| `Super + Shift + Grave` | Přesunout okno do konzole Quake |
| `Super + Shift + Ctrl + Arrows` | Přesunout okno na monitor v daném směru |
| `Super + Shift + Alt + Arrows` | Přesunout pracovní plochu na monitor v daném směru |
| `Super + Arrow` | Přesunout zaměření na okno ve směru šipky, na okraji obrazovky přejít na monitor na dané straně |
| `Super + Shift + Arrow` | Prohodit okno s jiným ve směru šipky, včetně okna na monitoru na dané straně |
| `Super + Minus` | Rozšířit okno doleva |
| `Super + Equal` | Zmenšit okno doleva |
| `Super + Shift + Minus` | Zmenšit okno nahoru |
| `Super + Shift + Equal` | Rozšířit okno dolů |
| `Super + Alt + Minus/Equal` | Totéž měnění velikosti v menších krocích |
| `Super + Ctrl + Minus/Equal` | Totéž měnění velikosti ve větších krocích |
| `Super + Alt + Home` | Uložit šířku okna |
| `Super + Home` | Obnovit uloženou šířku okna |
| `Super + Left Mouse` | Táhnout okno |
| `Super + Right Mouse` | Změnit velikost okna |
| `Super + Scroll Wheel` | Procházet pracovní plochy na zaměřeném monitoru |
| `Super + G` | Přepnout seskupování oken |
| `Super + Alt + G` | Přesunout okno ze seskupení ven |
| `Super + Alt + Tab` | Procházet okna ve seskupení |
| `Super + Alt + Shift + Tab` | Procházet okna ve seskupení pozpátku |
| `Super + Alt + Scroll Wheel` | Procházet okna ve seskupení |
| `Super + Alt + 1/2/3/4/5` | Přeskočit na konkrétní okno ve seskupení |
| `Super + Alt + Arrow` | Přesunout okno do seskupení ve směru šipky, včetně okna na monitoru na dané straně |
| `Super + Ctrl + Left/Right` | Pohybovat se mezi okny uvnitř dlaždicové skupiny |
| `Super + Ctrl + Z` | Přiblížit obrazovku (opakováním přiblížíte víc) |
| `Super + Ctrl + Alt + Z` | Úplně oddálit obrazovku |
| `Super + /` | Krok vpřed mezi možnostmi škálování monitoru |
| `Super + Alt + /` | Krok vzad mezi možnostmi škálování monitoru |
| `Alt + Tab` | Procházet okna na aktivní pracovní ploše vpřed |
| `Alt + Shift + Tab` | Procházet okna na aktivní pracovní ploše pozpátku |
| `Ctrl + Alt + Tab` | Procházet zaměření mezi monitory vpřed |
| `Ctrl + Alt + Shift + Tab` | Procházet zaměření mezi monitory pozpátku |

Zkratky pro změnu velikosti používají fyzické klávesy `code:20` a `code:21` (XKB `<AE11>` a `<AE12>`) bez ohledu na znaky vytištěné na klávesnici. Na amerických klávesnicích jsou tyto klávesy `-` a `=`; na japonských (JIS) klávesnicích jsou to `-` a `^`; na španělských klávesnicích jsou to `'` a `¡`. Na JIS je `Super + ^` totéž co `Super + Equal`, zatímco `Super + Shift + -` (které píše `=`) je `Super + Shift + Minus`.

## Systémové ovládání

| Klávesová zkratka | Funkce |
| --- | --- |
| `Super + Ctrl + A` | Panel zvuku |
| `Super + Ctrl + B` | Panel Bluetooth |
| `Super + Ctrl + N` | Panel Wi-Fi/sítě |
| `Super + Ctrl + D` | Panel displeje |
| `Super + Ctrl + P` | Panel napájení |
| `Super + Ctrl + X` | Panel agentů |
| `Super + Ctrl + Alt + D` | Panel kalendáře |
| `Super + Ctrl + Alt + E` | Panel světového času |
| `Super + Ctrl + 1-9` | Přepnout panel lišty podle pozice |
| `Super + Ctrl + S` | Nabídka sdílení (přes LocalSend) |
| `Super + Ctrl + C` | Ovládání snímání (snímek obrazovky/-nahrávání/výběr) |
| `Super + Ctrl + O` | Přepnout nabídku |
| `Super + Ctrl + H` | Nabídka hardwaru |
| `Super + Ctrl + E` | Výběr emoji |
| `Super + Ctrl + .` | Překódovat média |
| `Super + Shift + Ctrl + A` | Vybrat AI agenta |

## Úpravy

| Klávesová zkratka | Funkce |
| --- | --- |
| `Shift + Brightness Up` | Maximální jas obrazovky |
| `Shift + Brightness Down` | Minimální jas obrazovky |
| `Alt + Brightness Up/Down` | Přesné změny jasu o 1% |
| `Alt + Volume Up/Down` | Přesné změny hlasitosti o 1% |
| `Keyboard Brightness Up/Down` | Podsvícení klávesnice jasnější/tmavší |
| `Keyboard Backlight` | Procházet úrovně podsvícení klávesnice |
| `Alt + Play` | Další skladba |
| `Alt + Shift + Play` | Předchozí skladba |

## Spouštění aplikací

| Klávesová zkratka | Funkce |
| --- | --- |
| `Super + Return` | Terminál |
| `Super + Alt + Return` | Terminál Tmux |
| `Super + Ctrl + Return` | Herdr (správce agentů) |
| `Super + Shift + Return` | Prohlížeč |
| `Super + Shift + Alt + B` | Prohlížeč (soukromý/inkognito) |
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
| --- | --- |
| `Super + A` | Vybrat vše v aplikacích, které podporují `Ctrl + A` |
| `Super + C` | Kopírovat |
| `Super + X` | Vyjmout (ne v terminálu) |
| `Super + V` | Vložit |
| `Super + Ctrl + V` | Správce schránky |

Na Linuxu obvykle potřebujete `Ctrl + Shift + C/V` ke kopírování'n'vkládání v terminálu a `Ctrl + C/V` všude jinde. Tyto sjednocené klávesové zkratky schránky Omarchy fungují všude.

## Snímání

| Klávesová zkratka | Funkce |
| --- | --- |
| `Print Screen` | Snímek obrazovky |
| `Super + Ctrl + Alt + C` | Snímek obrazovky (tentýž snímek, pro klávesnice bez klávesy Print Screen) |
| `Super + Ctrl + C` | Nabídka snímání |
| `Alt + Print Screen` | Nahrávání obrazovky |
| `Super + Print Screen` | Výběr barvy |
| `Super + Ctrl + Print Screen` | Extrakce textu do schránky |
| `Super + Alt + [` | Zmenšit překryv webkamery během nahrávání |
| `Super + Alt + ]` | Zvětšit překryv webkamery během nahrávání |
| `Alt + Shift + L` | Zkopírovat aktuální URL z webové aplikace nebo Chromium |
| `Alt + Shift + D` | Stáhnout video na aktuální stránce do `~/Videos` |
| `Alt + Space` | Spustit/zastavit diktování (vyžaduje _Setup > Defaults > Dictation_) |
| `Right Alt` | Držet pro diktování (vyžaduje _Setup > Defaults > Dictation_) |

U nahrávání obrazovky se zkratka nejprve zeptá, který zvuk chcete, pak začne nahrávat. Stiskněte ji znovu pro zastavení. Podrobnosti viz [snímky obrazovky a nahrávání](12-screenshots-recording.md).

Všechny možnosti snímání jsou přístupné také pod _Trigger > Capture_ v nabídce Omarchy (`Super + Space`).

## Oznámení

| Klávesová zkratka | Funkce |
| --- | --- |
| `Super + ,` | Reagovat na nejnovější oznámení: otevřít ho nebo stisknout jeho jediné tlačítko, vybrat z jeho možností, nebo ho zavřít, když žádné nemá |
| `Super + Shift + ,` | Zavřít všechna oznámení |
| `Super + Ctrl + ,` | Ovládat oznámení klávesnicí |
| `Super + Alt + ,` | Zavřít nejnovější oznámení |
| `Super + Shift + Alt + ,` | Otevřít historii oznámení |
| `Super + Ctrl + Alt + ,` | Přepnout ztišení oznámení |

## Styl

| Klávesová zkratka | Funkce |
| --- | --- |
| `Super + Ctrl + T` | Vybrat nové téma (také `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vybrat pozadí tématu (také `Super + Ctrl + Space`) |
| `Super + Backspace` | Přepnout průhlednost okna |
| `Super + Ctrl + Backspace` | Přepnout čtvercový poměr stran jednoho okna |

Další obrázky pozadí žijí v `~/.config/omarchy/backgrounds/<theme name>`. Dostupné také přes _Install > Style > Background_ v nabídce Omarchy.

Všechny možnosti stylu jsou přístupné také pod _Style_ v nabídce Omarchy (`Super + Space`).

## Přepínače

| Klávesová zkratka | Funkce |
| --- | --- |
| `Super + Ctrl + I` | Přepnout zamykání při nečinnosti |
| `Super + Ctrl + Delete` | Přepnout displej notebooku zap./vyp. |
| `Super + Ctrl + Alt + Delete` | Přepnout zrcadlení displeje notebooku |
| `Super + Shift + Space` | Přepnout horní lištu |
| `Shift + Mute` | Přepnout na další zvukový výstup |
| `Shift + Play` | Přepnout na další zdroj médií |
| `Super + Shift + Backspace` | Přepnout mezery mezi okny |
| `Super + Ctrl + Alt + F` | Přepnout desktop na celou obrazovku (horní lišta + mezery mezi okny) |

## Připomínky

| Klávesová zkratka | Funkce |
| --- | --- |
| `Super + Ctrl + R` | Nastavit připomínku |
| `Super + Ctrl + Alt + R` | Zobrazit všechny připomínky |
| `Super + Ctrl + Shift + R` | Vymazat všechny připomínky |

## Upozornění

| Klávesová zkratka | Funkce |
| --- | --- |
| `Super + Ctrl + Alt + T` | Zobrazit čas jako oznámení |
| `Super + Ctrl + Alt + B` | Zobrazit baterii jako oznámení |
| `Super + Ctrl + Alt + W` | Přepnout počasí jako oznámení |

## Tmux

Klávesa prefixu je `Ctrl + Space` (`Ctrl + B` také funguje). Tyto vazby můžete změnit v `~/.config/tmux/tmux.conf`.

### Panely

| Klávesová zkratka | Funkce |
| --- | --- |
| `Prefix + v` | Rozdělit panel vedle (svisle) |
| `Prefix + h` | Rozdělit panel níže (vodorovně) |
| `Prefix + x` | Zavřít panel |
| `Prefix + z` | Přepnout přiblížení panelu (celá obrazovka) |
| `Alt + Enter` | Rozdělit panel níže (bez prefixu) |
| `Alt + Shift + Enter` | Rozdělit panel vedle (bez prefixu) |
| `Alt + Escape` | Zavřít panel (bez prefixu) |
| `Ctrl + Alt + Arrows` | Pohybovat se mezi panely |
| `Ctrl + Alt + Shift + Arrows` | Měnit velikost panelů |

### Okna

| Klávesová zkratka | Funkce |
| --- | --- |
| `Prefix + c` | Nové okno |
| `Prefix + k` | Zavřít okno |
| `Prefix + r` | Přejmenovat okno |
| `Alt + 1-9` | Přejít na konkrétní okno |
| `Alt + Arrow Left/Right` | Pohybovat se mezi okny |
| `Alt + Shift + Arrow Left/Right` | Přesunout okno doleva/doprava |

### Relace

| Klávesová zkratka | Funkce |
| --- | --- |
| `Prefix + C` | Nová relace |
| `Prefix + K` | Zavřít relaci |
| `Prefix + R` | Přejmenovat relaci |
| `Prefix + N` | Další relace |
| `Prefix + P` | Předchozí relace |
| `Alt + Arrow Up/Down` | Pohybovat se mezi relacemi |
| `Prefix + s` | Vypsat relace |
| `Prefix + d` | Odpojit se od relace |

### Režim kopírování (ve stylu vi)

| Klávesová zkratka | Funkce |
| --- | --- |
| `Prefix + [` | Vstoupit do režimu kopírování |
| `v` | Začít výběr (v režimu kopírování) |
| `y` | Zkopírovat výběr (v režimu kopírování) |

### Obecné

| Klávesová zkratka | Funkce |
| --- | --- |
| `Prefix + q` | Znovu načíst konfiguraci |
| `Prefix + ?` | Zobrazit klávesové zkratky Tmux |
| `Prefix + :` | Příkazový řádek |

### Funkce rozložení Tmux

Tyto funkce musí být spuštěny uvnitř relace Tmux.

| Příkaz | Funkce |
| --- | --- |
| `tdl <ai> [<second_ai>]` | Vytvořit vývojové rozložení s editorem, AI a terminálem |
| `tdlm <ai> [<second_ai>]` | Vytvořit vývojové rozložení pro každý podadresář |
| `tsl <count> <command>` | Vytvořit rozložení roje s více panely |

## Terminál Ghostty

Terminál Ghostty se instaluje pomocí _Install > Terminal_ přes nabídku Omarchy.

| Klávesová zkratka | Funkce |
| --- | --- |
| `Ctrl + Shift + E` | Nové rozdělení níže |
| `Ctrl + Shift + O` | Nové rozdělení vedle |
| `Ctrl + Alt + Arrows` | Pohybovat se mezi rozděleními |
| `Super + Ctrl + Shift + Arrows` | Změnit velikost rozdělení o 10 řádků |
| `Super + Ctrl + Shift + Alt + Arrows` | Změnit velikost rozdělení o 100 řádků |
| `Ctrl + Shift + T` | Nová karta |
| `Ctrl + Shift + Arrows` | Pohybovat se mezi kartami |
| `Alt + Numbers` | Přejít na konkrétní kartu |
| `Shift + Pg Up/Down` | Posouvat historii |
| `Ctrl + Left mouse` | Otevřít odkaz v prohlížeči |

## Správce souborů

| Klávesová zkratka | Funkce |
| --- | --- |
| `Ctrl + L` | Přejít na cestu |
| `Space` | Náhled souboru (šipky navigují) |
| `Alt + Up` | Přejít nahoru do nadřazené složky |

## Neovim (s lazyvim)

### Navigace

| Klávesová zkratka | Funkce |
| --- | --- |
| `Space` | Zobrazit možnosti příkazů |
| `Space Space` | Otevřít soubor přes fuzzy vyhledávání |
| `Space E` | Přepnout postranní panel |
| `Space G G` | Zobrazit ovládací prvky git |
| `Space S G` | Hledat obsah souboru |
| `Ctrl + W W` | Skákat mezi postranním panelem a editorem |
| `Ctrl + Left/right arrow` | Změnit velikost postranního panelu |
| `Shift + H` | Přejít na levou kartu souboru |
| `Shift + L` | Přejít na pravou kartu souboru |
| `Space B D` | Zavřít kartu souboru |

### V postranním panelu

| Klávesová zkratka | Funkce |
| --- | --- |
| `A` | Přidat nový soubor v nadřazeném adresáři |
| `Shift + A` | Přidat nový podadresář v nadřazeném adresáři |
| `D` | Smazat zvýrazněný soubor/adresář |
| `M` | Přesunout zvýrazněný soubor/adresář |
| `R` | Přejmenovat zvýrazněný soubor/adresář |
| `?` | Zobrazit nápovědu pro všechny příkazy |

[Zobrazit všechny klávesové zkratky Neovim nakonfigurované LazyVim](https://www.lazyvim.org/keymaps).

## Rychlé emoji

Pomocí `Super + Ctrl + E` zobrazíte kompletní výběr emoji, který umístí výběr do schránky, nebo můžete použít tyto možnosti rychlého přístupu.

| Klávesová zkratka | EM | Nápověda |
| --- | --- | --- |
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
| `Shift + CapsLock M O` | 👌 | ok |
| `Shift + CapsLock M G` | 👋 | pozdrav |
| `Shift + CapsLock M A` | 💪 | paže |
| `Shift + CapsLock M B` | 🤯 | výbuch |

## Rychlá dokončení

| Klávesová zkratka | Dokončení |
| --- | --- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Vaše jméno (jak bylo zadáno při nastavení) |
| `Shift + CapsLock Space E` | Váš e-mail (jak byl zadán při nastavení) |

Další vlastní můžete přidat úpravou `~/.XCompose` a poté spuštěním `omarchy-restart-xcompose` v terminálu, aby se změny projevily.
