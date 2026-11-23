# Klávesové zkratky

Všechny hlavní klávesové zkratky si zobrazíte pomocí `Super + K` (zkratky pro Tmux pomocí `Super + Alt + K` a zkratky pro Herdr pomocí `Super + Ctrl + K`).

## Jak jsou klávesové zkratky uspořádané

Každá klávesová zkratka sedí v jedné rovině dané jejími modifikátory a každá rovina má jeden úkol. Díky tomu se klávesové zkratky neslévají dohromady a většinou uhodnete, kde co žije.

| Rovina | Co tam žije | Příklady |
| --- | --- | --- |
| `Super + key` | Systém: okna, pracovní plochy, rozvržení a hlavní nabídky | `Super + Space` nabídka Omarchy, `Super + W` zavřít okno, `Super + F` celá obrazovka |
| `Super + Shift + key` | Aplikace | `Super + Shift + B` prohlížeč, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panely a systémové nabídky | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` síť, `Super + Ctrl + C` nabídka zachycení |
| `Super + Ctrl + Alt + key` | Rychlé akce a upozornění | `Super + Ctrl + Alt + T` zobrazit čas, `Super + Ctrl + Alt + B` baterie, `Super + Ctrl + Alt + C` snímek obrazovky |

Přidání `Alt` ke klávesové zkratce vám dá variantu téže věci, nikdy něco nesouvisejícího:

- `Super + Shift + B` otevře prohlížeč; `Super + Shift + Alt + B` otevře soukromé okno
- `Super + Shift + E` otevře e-mail; `Super + Shift + Alt + E` začne nový
- `Super + F` přejde na celou obrazovku; `Super + Alt + F` přejde na celou šířku
- `Super + Ctrl + C` otevře nabídku zachycení; `Super + Ctrl + Alt + C` nabídku přeskočí a pořídí snímek obrazovky

Při přidávání klávesové zkratky:

1. Vyberte rovinu podle toho, co dělá, a pak vyberte klávesu.
2. Nepřesouvejte existující klávesovou zkratku, abyste udělali místo. Najděte volnou klávesu na správné rovině.
3. `Alt` používejte pouze pro variantu klávesové zkratky bez něj.

Pár klávesových zkratek tato pravidla porušuje, protože je to pohodlné. `Shift` se šipkou nebo `Tab` přesouvá nebo obrací místo otevírání aplikace a `Print`, multimediální klávesy, `Alt + Tab` a `Ctrl + Alt + Del` fungují tak, jak fungují všude jinde. Jsou to výjimky, ne vzory ke kopírování.

Pokud vám výchozí nastavení nevyhovuje (řekněme, že chcete `Super + Shift + S` pro snímky obrazovky jako ve Windows), převažte si ji v `~/.config/hypr/bindings.lua`.

## Navigace

| Klávesová zkratka                  | Funkce              |
| ----------------------- | --------------------- |
| `Super + Space`           | Nabídka Omarchy (aplikace a všechno ostatní)    |
| `Super + Alt + Space` | Mřížka aplikací |
| `Super + Escape` | Systémová nabídka (uspání, restart atd.)  |
| `Super + Ctrl + L` | Zamknout počítač |
| `Super + W` nebo `Super + Q` | Zavřít okno             |
| `Ctrl + Alt + Del` | Zavřít všechna okna |
| `Super + K` | Zobrazit všechny klávesové zkratky |
| `Super + Alt + K` | Zobrazit klávesové zkratky tmux |
| `Super + Ctrl + K` | Zobrazit klávesové zkratky herdr |
| `Super + M` | Minimalizovat okno do doku |
| `Super + T`               | Přepnout okno mezi dlaždicovým/plovoucím režimem             |
| `Super + J` | Přepnout pozici okna (horizontální/vertikální) |
| `Super + O`               | Přepnout vyskakování okna do sticky'n'floating |
| `Super + L`               | Procházet rozvržení dwindle, scrolling a floating |
| `Super + Alt + L`         | Procházet rozvržení v opačném pořadí |
| `Super + P`               | Přepnout styl pseudo okna (přirozené vs. roztažené) |
| `Super + F`                 | Přejít na celou obrazovku              |
| `Super + Alt + F`                 | Přejít na celou šířku              |
| `Super + Ctrl + F`                 | Přejít na celou obrazovku uvnitř okna              |
| `Super + 1…9/0`         | Přejít na konkrétní pracovní plochu (0 je 10) na zaměřeném monitoru |
| `Super + Tab` | Přejít na další pracovní plochu na zaměřeném monitoru |
| `Super + Shift + Tab` | Přejít na předchozí pracovní plochu na zaměřeném monitoru |
| `Super + Ctrl + Tab` | Přejít na dřívější pracovní plochu na zaměřeném monitoru |
| `Super + Shift + 1…9/0` | Přesunout okno na pracovní plochu na zaměřeném monitoru |
| `Super + Shift + Alt + 1…9/0` | Přesunout okno na pracovní plochu na zaměřeném monitoru bez následování |
| `Super + S` | Přepnout celý scratchpad |
| `Super + Alt + S` | Přesunout okno do celého scratchpadu |
| `Super + the key above Tab` (grave na amerických rozvrženích) | Přepnout konzoli Quake |
| `Super + Shift + the key above Tab` (grave na amerických rozvrženích) | Přesunout okno do konzole Quake |
| `Super + Shift + Ctrl + Arrows` | Přesunout okno na monitor v daném směru |
| `Super + Shift + Alt + Arrows` | Přesunout pracovní plochu na monitor v daném směru |
| `Super + Arrow`  | Přesunout zaměření na okno ve směru šipky, na okraji obrazovky přejít na monitor na dané straně |
| `Super + Shift + Arrow`  | Prohodit okno s jiným ve směru šipky, včetně okna na monitoru na dané straně |
| `Super + Minus` | Rozšířit okno doleva |
| `Super + Equal` | Zúžit okno zleva |
| `Super + Shift + Minus` | Zúžit okno nahoru |
| `Super + Shift + Equal` | Rozšířit okno dolů |
| `Super + Alt + Minus/Equal` | Stejné měnění velikosti v menších krocích |
| `Super + Ctrl + Minus/Equal` | Stejné měnění velikosti ve větších krocích |
| `Super + Alt + Home` | Uložit šířku okna |
| `Super + Home` | Obnovit uloženou šířku okna |
| `Super + Left Mouse` | Táhnout okno |
| `Super + Right Mouse` | Měnit velikost okna |
| `Super + Scroll Wheel` | Procházet pracovní plochy na zaměřeném monitoru |
| `Super + G`               | Přepnout seskupování oken      |
| `Super + Alt + G`               | Přesunout okno ze seskupení      |
| `Super + Alt + Tab`               | Procházet okna ve skupině      |
| `Super + Alt + Shift + Tab`               | Procházet okna ve skupině pozpátku      |
| `Super + Alt + Scroll Wheel` | Procházet okna ve skupině |
| `Super + Alt + 1/2/3/4/5`               | Přejít na konkrétní okno ve skupině      |
| `Super + Alt + Arrow`  | Přesunout okno do skupiny ve směru šipky, včetně okna na monitoru na dané straně |
| `Super + Ctrl + Left/Right`  | Přecházet mezi okny uvnitř dlaždicové skupiny |
| `Super + Ctrl + Z` | Přiblížit obrazovku (opakováním přiblížíte víc) |
| `Super + Ctrl + Alt + Z` | Plně oddálit obrazovku |
| `Super + /` | Krok dopředu možnostmi měřítka monitoru |
| `Super + Alt + /` | Krok dozadu možnostmi měřítka monitoru |
| `Alt + Tab` | Procházet okna na aktivní pracovní ploše dopředu |
| `Alt + Shift + Tab` | Procházet okna na aktivní pracovní ploše dozadu |
| `Ctrl + Alt + Tab`| Procházet zaměření mezi monitory dopředu |
| `Ctrl + Alt + Shift + Tab`| Procházet zaměření mezi monitory dozadu |
| `Super + I` | Přepnout jazyk vstupu (při více než jednom rozvržení nebo metodě vstupu) |
| `Super + Shift + I` | Přepnout jazyk vstupu zpět |

Na touchpadu gesta přejetí třemi a čtyřmi prsty přepínají pracovní plochy, přesouvají okna a otevírají nabídku a konzoli Quake; gesta najdete v [klávesnice, myš a trackpad](34-keyboard-mouse-trackpad.md).

Zkratky pro změnu velikosti používají fyzické klávesy `code:20` a `code:21` (XKB `<AE11>` a `<AE12>`) bez ohledu na znaky vytištěné na klávesnici. Na amerických klávesnicích jsou těmito klávesami `-` a `=`; na japonských klávesnicích (JIS) jsou to `-` a `^`; na španělských klávesnicích jsou to `'` a `¡`. Na JIS je `Super + ^` totéž co `Super + Equal`, zatímco `Super + Shift + -` (které píše `=`) je `Super + Shift + Minus`.

## Systémové ovládání

| Klávesová zkratka                  | Funkce              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel zvuku    |
| `Super + Ctrl + B`           | Panel Bluetooth    |
| `Super + Ctrl + N`           | Panel Wi-Fi/sítě    |
| `Super + Ctrl + D`           | Panel displeje    |
| `Super + Ctrl + P`           | Panel napájení    |
| `Super + Ctrl + X`           | Panel agentů    |
| `Super + Ctrl + Alt + X`           | Panel místních modelů    |
| `Super + Ctrl + Alt + D`           | Panel kalendáře    |
| `Super + Ctrl + Alt + E`           | Panel světového času    |
| `Super + Ctrl + 1-9`           | Přepnout panel lišty podle pozice    |
| `Super + Ctrl + S` | Nabídka sdílení (přes LocalSend) |
| `Super + Ctrl + C` | Ovládání zachycení (snímek obrazovky/-záznam/výběr) |
| `Super + Ctrl + O` | Přepnout nabídku |
| `Super + Ctrl + H` | Nabídka hardwaru |
| `Super + Ctrl + E` | Výběr emoji |
| `Super + Ctrl + .` | Překódovat média |
| `Super + Shift + Ctrl + A` | Spustit výchozího agenta |
| `Power` key | Systémová nabídka |
| `Super + Shift + Copilot` key | Nabídka Omarchy |

## Úpravy

| Klávesová zkratka                  | Funkce              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximální jas obrazovky |
| `Shift + Brightness Down` | Minimální jas obrazovky |
| `Alt + Brightness Up/Down` | Přesné změny jasu po 1 % |
| `Alt + Volume Up/Down` | Přesné změny hlasitosti po 1 % |
| `Keyboard Brightness Up/Down` | Podsvícení klávesnice jasnější/tmavší |
| `Keyboard Backlight` | Procházet úrovně podsvícení klávesnice |
| `Ctrl + Brightness Up/Down` | Podsvícení klávesnice jasnější/tmavší, na klávesnicích bez vlastních kláves |
| `Mic Mute` | Ztlumit mikrofon |
| `Shift + Mute` | Přepnout výstup zvuku |
| `Touchpad Toggle` | Zapnout nebo vypnout touchpad |
| `Display` key | Procházet rozvržení pracovní plochy |
| `Alt + Play` | Další skladba |
| `Alt + Shift + Play` | Předchozí skladba |

## Spouštění aplikací

| Klávesová zkratka                  | Funkce              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminál    |
| `Super + Alt + Return` | Terminál Tmux |
| `Super + Ctrl + Return` | Herdr (správce agentů) |
| `Super + Shift + Return` nebo `Super + Shift + B`  | Prohlížeč    |
| `Super + Shift + Alt + B`           | Prohlížeč (soukromý/inkognito)    |
| `Super + Shift + F`           | Správce souborů    |
| `Super + Shift + Alt + F`           | Správce souborů v cwd terminálu    |
| `Super + Shift + M`           | Hudba (Spotify)    |
| `Super + Shift + Alt + M`           | Hudba (cliamp)    |
| `Super + Shift + /`           | Správce hesel (1password)    |
| `Super + Shift + Q` nebo `Calculator` key  | Kalkulačka (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, po instalaci)    |
| `Super + Shift + T`           | Aktivita (btop)    |
| `Super + Shift + N`           | Editor (Plain, nebo váš zvolený výchozí)  |
| `Super + Shift + C`           | Kalendář ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nový e-mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Váš výchozí agent, nebo ChatGPT, dokud si nějakého nezvolíte |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Zprávy (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Zprávy (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Zprávy (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Psaní (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (nový příspěvek) |
| `Super + Shift + Y`           | YouTube |

Změňte/přidejte vazby v `~/.config/hypr/bindings.lua`.

## Univerzální schránka

| Klávesová zkratka                  | Funkce              |
| ----------------------- | --------------------- |
| `Super + A`           | Vybrat vše v aplikacích, které podporují `Ctrl + A`    |
| `Super + C`           | Kopírovat    |
| `Super + X`           | Vyjmout (ne v terminálu)    |
| `Super + V`           | Vložit    |
| `Super + Ctrl + V`           | Správce schránky    |

Obvykle v Linuxu potřebujete `Ctrl + Shift + C/V` ke kopírování a vkládání v terminálu a `Ctrl + C/V` všude jinde. Tyto sjednocené klávesové zkratky schránky v Omarchy fungují všude.

## Zachycení

| Klávesová zkratka              | Funkce                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Snímek obrazovky                      |
| `Super + Ctrl + Alt + C`            | Snímek obrazovky (stejný snímek, pro klávesnice bez klávesy Print Screen) |
| `Super + Ctrl + C` | Nabídka zachycení |
| `Alt + Print Screen`            | Záznam obrazovky                     |
| `Super + Shift + Ctrl + Alt + C` | Záznam obrazovky bez zvuku, bez nabídky (opětovným stisknutím zastavíte) |
| `Super + Print Screen` | Výběr barvy |
| `Super + Ctrl + Print Screen` | Extrakce textu do schránky |
| `Super + Alt + [` | Zmenšit překryv webkamery během nahrávání |
| `Super + Alt + ]` | Zvětšit překryv webkamery během nahrávání |
| `Alt + Shift + L` | Zkopírovat aktuální URL z webové aplikace nebo prohlížeče |
| `Alt + Shift + D` | Stáhnout video na aktuální stránce do `~/Videos` |
| `Alt + Space` | Spustit/zastavit diktování (vyžaduje _Nastavení > Výchozí nastavení > Diktování_) |
| `Right Alt` | Podržením diktovat (vyžaduje _Nastavení > Výchozí nastavení > Diktování_) |

U záznamů obrazovky se klávesová zkratka nejprve zeptá, jaký zvuk chcete, a pak začne nahrávat. Opětovným stisknutím nahrávání zastavíte. Podrobnosti najdete v [snímky obrazovky a nahrávání](12-screenshots-recording.md).

Všechny možnosti zachycení jsou dostupné také v _Spouštěč > Zachycení_ v nabídce Omarchy (`Super + Space`).

## Oznámení

| Klávesová zkratka                  | Funkce              |
| ----------------------- | --------------------- |
| `Super + ,` | Provést akci u nejnovějšího oznámení: otevřít je nebo stisknout jeho jediné tlačítko, vybrat z jeho možností, nebo je zavřít, když žádné nemá  |
| `Super + Shift + ,` | Zavřít všechna oznámení |
| `Super + Ctrl + ,` | Ovládat oznámení klávesnicí  |
| `Super + Alt + ,` | Zavřít nejnovější oznámení  |
| `Super + Shift + Alt + ,` | Otevřít historii oznámení  |
| `Super + Ctrl + Alt + ,` | Přepnout ztlumení oznámení  |

## Styl

| Klávesová zkratka                  | Funkce              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vybrat nový motiv (také `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vybrat pozadí motivu (také `Super + Ctrl + Space`) |
| `Super + Backspace` | Přepnout průhlednost okna |
| `Super + Ctrl + Backspace` | Přepnout čtvercový poměr stran jednoho okna |

Další obrázky pozadí jsou v `~/.config/omarchy/backgrounds/<theme name>`. Dostupné také přes _Instalovat > Styl > Pozadí_ v nabídce Omarchy.

Všechny možnosti stylu jsou dostupné také v _Vzhled_ v nabídce Omarchy (`Super + Space`).

## Přepínače

| Klávesová zkratka                  | Funkce              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Přepnout zamykání při nečinnosti |
| `Super + Ctrl + Delete` | Zapnout/vypnout displej notebooku |
| `Super + Ctrl + Alt + Delete` | Přepnout zrcadlení displeje notebooku |
| `Super + Shift + Space` | Přepnout horní lištu  |
| `Shift + Mute` | Přepnout na další výstup zvuku |
| `Shift + Play` | Přepnout na další zdroj médií |
| `Super + Shift + Backspace` | Přepnout mezery mezi okny |
| `Super + Ctrl + Alt + F` | Přepnout celoobrazovkovou plochu (horní lišta + mezery mezi okny) |

## Připomínky

| Klávesová zkratka                  | Funkce              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Nastavit připomínku  |
| `Super + Ctrl + Alt + R` | Zobrazit všechny připomínky  |
| `Super + Ctrl + Shift + R` | Vymazat všechny připomínky  |

## Upozornění

| Klávesová zkratka                  | Funkce              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Zobrazit čas jako oznámení  |
| `Super + Ctrl + Alt + B` | Zobrazit baterii jako oznámení  |
| `Super + Ctrl + Alt + W` | Přepnout počasí jako oznámení  |

## Tmux

Klávesa prefix je `Ctrl + Space` (`Ctrl + B` také funguje). Tyto vazby můžete změnit v `~/.config/tmux/tmux.conf`.

### Panely

| Klávesová zkratka                  | Funkce              |
| ----------------------- | --------------------- |
| `Prefix + v` | Rozdělit panel vedle (vertikálně) |
| `Prefix + h` | Rozdělit panel pod (horizontálně) |
| `Prefix + x` | Ukončit panel |
| `Prefix + z` | Přepnout přiblížení panelu (celá obrazovka) |
| `Alt + Enter` | Rozdělit panel pod (bez prefixu) |
| `Alt + Shift + Enter` | Rozdělit panel vedle (bez prefixu) |
| `Alt + Escape` | Ukončit panel (bez prefixu) |
| `Ctrl + Alt + Arrows` | Přecházet mezi panely |
| `Ctrl + Alt + Shift + Arrows` | Měnit velikost panelů |

### Okna

| Klávesová zkratka                  | Funkce              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nové okno |
| `Prefix + k` | Ukončit okno |
| `Prefix + r` | Přejmenovat okno |
| `Alt + 1-9` | Přejít na konkrétní okno |
| `Alt + Arrow Left/Right` | Přecházet mezi okny |
| `Alt + Shift + Arrow Left/Right` | Přesunout okno doleva/doprava |

### Relace

| Klávesová zkratka                  | Funkce              |
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

| Klávesová zkratka                  | Funkce              |
| ----------------------- | --------------------- |
| `Prefix + [` | Vstoupit do režimu kopírování |
| `v` | Začít výběr (v režimu kopírování) |
| `y` | Zkopírovat výběr (v režimu kopírování) |

### Obecné

| Klávesová zkratka                  | Funkce              |
| ----------------------- | --------------------- |
| `Prefix + q` | Znovu načíst konfiguraci |
| `Prefix + ?` | Zobrazit klávesové zkratky Tmux |
| `Prefix + :` | Příkazový řádek |

### Funkce rozvržení Tmux

Tyto funkce musíte spouštět uvnitř relace Tmux.

| Příkaz | Funkce |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Vytvořit vývojové rozvržení s editorem, AI a terminálem |
| `tdlm <ai> [<second_ai>]` | Vytvořit vývojové rozvržení pro každý podadresář |
| `tsl <count> <command>` | Vytvořit rozvržení roje s více panely |

## Terminál Ghostty

Terminál Ghostty se instaluje pomocí _Instalovat > Terminál_ přes nabídku Omarchy.

| Klávesová zkratka                  | Funkce              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nové rozdělení pod |
| `Ctrl + Shift + O` | Nové rozdělení vedle |
| `Ctrl + Alt + Arrows` | Přecházet mezi rozděleními |
| `Super + Ctrl + Shift + Arrows` | Změnit velikost rozdělení o 10 řádků |
| `Super + Ctrl + Shift + Alt + Arrows` | Změnit velikost rozdělení o 100 řádků |
| `Ctrl + Shift + T` | Nová karta  |
| `Ctrl + Shift + Arrows` | Přecházet mezi kartami |
| `Alt + Numbers` | Přejít na konkrétní kartu |
| `Shift + Pg Up/Down` | Posouvat historii |
| `Ctrl + Left mouse` | Otevřít odkaz v prohlížeči |

## Správce souborů

| Klávesová zkratka              | Funkce                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Přejít na cestu                     |
| `Space`               | Náhled souboru (šipky navigují) |
| `Alt + Up`       | Přejít do nadřazené složky        |

## Neovim (s lazyvim)

### Navigace

| Klávesová zkratka                   | Funkce                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Zobrazit možnosti příkazů            |
| `Space Space`              | Otevřít soubor přes fuzzy vyhledávání      |
| `Space E`                  | Přepnout postranní panel                  |
| `Space G G`                | Zobrazit ovládání gitu               |
| `Space S G`                | Prohledat obsah souboru             |
| `Ctrl + W W`               | Přeskakovat mezi postranním panelem a editorem |
| `Ctrl + Left/right arrow`  | Změnit velikost postranního panelu          |
| `Shift + H`                      | Přejít na kartu souboru vlevo             |
| `Shift + L`                      | Přejít na kartu souboru vpravo            |
| `Space B D`                | Zavřít kartu souboru                  |

### V postranním panelu

| Klávesová zkratka                   | Funkce                        |
| ------------------------ | ------------------------------- |
| `A`                        | Přidat nový soubor v nadřazeném adresáři      |
| `Shift + A`                | Přidat nový podadresář v nadřazeném adresáři    |
| `D`                        | Smazat zvýrazněný soubor/adresář     |
| `M`                        | Přesunout zvýrazněný soubor/adresář       |
| `R`                        | Přejmenovat zvýrazněný soubor/adresář     |
| `?`                        | Zobrazit nápovědu ke všem příkazům      |

[Podívejte se na všechny klávesové zkratky Neovimu nakonfigurované v LazyVim](https://www.lazyvim.org/keymaps).

## Rychlé emoji

Můžete použít `Super + Ctrl + E` k zobrazení kompletního výběru emoji, který výběr vloží do schránky, nebo můžete použít tyto možnosti rychlého přístupu.

| Klávesová zkratka       | EM | Nápověda       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | úsměv      |
| `Shift + CapsLock M C` | 😂 | pláč        |
| `Shift + CapsLock M L` | 😍 | láska       |
| `Shift + CapsLock M V` | ✌️ | vítězství    |
| `Shift + CapsLock M H` | ❤️ | srdce      |
| `Shift + CapsLock M Y` | 👍 | ano        |
| `Shift + CapsLock M N` | 👎 | ne         |
| `Shift + CapsLock M F` | 🖕 | fakáč       |
| `Shift + CapsLock M W` | 🤞 | přání       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | polibek       |
| `Shift + CapsLock M E` | 🙄 | protočení očí    |
| `Shift + CapsLock M I` | 😉 | mrknutí       |
| `Shift + CapsLock M P` | 🙏 | modlitba |
| `Shift + CapsLock M D` | 🤤 | slintání      |
| `Shift + CapsLock M M` | 💰 | peníze      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | přípitek      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pozdrav |
| `Shift + CapsLock M A` |💪 | paže |
| `Shift + CapsLock M B` |🤯 | výbuch |

## Rychlá doplňování

| Klávesová zkratka       | Doplnění       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (dlouhá pomlčka)   |
| `Shift + CapsLock Space N` | Vaše jméno (jak bylo zadáno při nastavení)  |
| `Shift + CapsLock Space E` | Váš e-mail (jak byl zadán při nastavení)  |

Další vlastní můžete přidat úpravou `~/.XCompose` a poté spuštěním `omarchy restart xcompose` v terminálu, aby se změny načetly.
