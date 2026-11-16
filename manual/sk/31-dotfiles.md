# Dotfiles

Omarchy sa konfiguruje predovšetkým prostredníctvom takzvaných dotfiles, ktoré sa nachádzajú v `~/.config`. Tie sa považujú za vaše súbory určené na vaše zmeny. Súbory, ktoré sa nachádzajú v `/usr/share/omarchy`, patria samotnému Omarchy a do tých by ste nemali zasahovať. Ak potrebujete niečo zmeniť v `/usr/share/omarchy`, mali by ste namiesto toho prepísať danú hodnotu v `~/.config`.

Kľúčové konfigurácie môžete upravovať priamo z menu Omarchy (`Super + Space`), napríklad _Setup > Keyboard > Keybindings_, _Setup > Input_ a _Setup > Config > [file]_. Keď to urobíte týmto spôsobom, každý proces, ktorý je po úpravách konfigurácie potrebné reštartovať, sa po zatvorení editora automaticky reštartuje (predvolene Neovim — `:wq`, pamätajte! — ale môžete to zmeniť cez _Setup > Defaults > Editor_).

Tu je zoznam kľúčových súborov v `~/.config` a toho, čo ovládajú:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hlavná konfigurácia Hyprland. Načítava predvoľby Omarchy plus vaše súbory s prepísaniami uvedené nižšie. [Viac o konfiguráciách Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vaše vlastné klávesové skratky a prepísania predvolieb. |
| `~/.config/hypr/monitors.lua` | Nastavenia monitora, ktoré panel monitora nepokrýva, ako napríklad otočenie, ďalšie režimy alebo ponechanie monitora vypnutého. |
| `~/.config/hypr/input.lua` | Ovláda rozloženie klávesnice, nastavenia myši a trackpadu. |
| `~/.config/hypr/looknfeel.lua` | Ovláda medzery, okraje, animácie a zvyšok vzhľadu. |
| `~/.config/hypr/autostart.lua` | Ovláda ďalšie procesy spúšťané spolu s reláciou. |
| `~/.config/omarchy/shell.json` | Ovláda shell Omarchy: polohu lišty, rozloženie a widgety, plus časovania šetriča obrazovky, zamykania a nečinnosti. |
| `~/.config/foot/foot.ini` | Ovláda váš terminál (foot je predvolený). |
| `~/.XCompose` | Definuje vaše emoji pre rýchly prístup a automatické dopĺňanie mena/e-mailu. Po vykonaní zmien nezabudnite spustiť `omarchy-restart-xcompose`. |

Ak nakoniec urobíte veľa zmien pri prispôsobovaní vlastného nastavenia, je dobré si všetky tieto dotfiles zálohovať. [Stow je skvelý spôsob, ako to urobiť](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Spúšťanie vlastných aplikácií spolu s reláciou

Ak chcete, aby sa niečo spúšťalo pri každom prihlásení — synchronizačný démon, chatovacia aplikácia, váš vlastný skript — vložte to do `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tým sa príkaz spustí ako súčasť relácie, takže sa pri odhlásení riadne vyčistí.

### Spúšťanie skriptov pri systémových udalostiach

Omarchy spúšťa hooky v niekoľkých okamihoch a môžete na ne zavesiť vlastné skripty. Nachádzajú sa v `~/.config/omarchy/hooks/<event>.d/`, jeden adresár pre každú udalosť, a každý spustiteľný súbor v ňom sa spustí, keď udalosť nastane:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Hneď po spustení desktopu |
| `post-update` | Ku koncu `omarchy update`, po balíkoch, migráciách a reštartoch služieb, pred aktualizáciou nástrojov mise |
| `pre-refresh-pacman` | Po tom, ako `omarchy refresh pacman` znovu zosynchronizuje konfiguráciu balíkov, pred aktualizáciou balíkov; prepnutie kanála ho spustí počas toho istého kroku obnovenia |
| `theme-set` | Po zmene témy (názov témy v `$1`) |
| `font-set` | Po zmene písma (názov písma v `$1`) |
| `battery-low` | Keď je batéria takmer vybitá (percento v `$1`) |

Hook `pre-refresh-pacman` je miesto, kam patria vlastné repozitáre alebo riadky `IgnorePkg`, pretože sa spúšťa pred transakciou balíkov. Oba hooky súvisiace s aktualizáciou bežia pod vaším používateľom po tom, ako Omarchy vymaže svoju uloženú autorizáciu sudo, takže hook, ktorý používa `sudo`, potrebuje vlastnú autorizáciu a môže si vyžiadať vaše heslo.

Každý z týchto adresárov už obsahuje súbor `.sample`, ktorý ukazuje tvar hooku — odstráňte z názvu `.sample` a môžete ho používať. Ak chcete nainštalovať skript, ktorý ste napísali inde, použite `omarchy hook install post-boot ~/my-hook`, čo ho skopíruje dnu a nastaví ako spustiteľný.

### Pridávanie vlastných položiek menu

Menu Omarchy (`Super + Space`) môžete rozšíriť o vlastné riadky úpravou `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Položky sú kľúčované bodkovým id a práve id ich umiestňuje do stromu, takže `personal` sa zobrazí v koreňovom menu a `personal.notes` sa zobrazí vnútri neho:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Opätovným použitím existujúceho id prepíšete daný riadok namiesto pridania nového. Súbor sa dodáva so všetkými dostupnými poľami zdokumentovanými vo forme komentárov.

### Pridávanie vlastných exportov shellu, funkcií a aliasov

Omarchy sa dodáva s kopou ergonomických aliasov a užitočných funkcií, ale je veľmi bežné chcieť si pridať vlastné. Aliasy, funkcie aj exporty by ste mali pridávať do `~/.bashrc`. Tento súbor sa pri aktualizáciách neprepíše. Ak chcete zmeniť niektoré z predvolieb Omarchy, môžete ich tu tiež bezpečne pridať.

### Nastavovanie premenných prostredia pre desktop

Exporty relácie desktopu patria do `~/.config/uwsm/env.d/`. Tieto súbory sa spúšťajú pred spustením vášho desktopu, takže chyba shellu vás môže vrátiť späť na prihlasovaciu obrazovku. Pri ich úprave majte otvorený funkčný terminál. Ak chcete prepísanie vypnúť, presuňte ho mimo `env.d`. Pozrite si [obnovu prihlásenia](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), ak zmena bráni prihláseniu.

### Zmena interných súborov Omarchy

Pozrite, toto je váš počítač. Môžete si s ním robiť, čo chcete, ale neodporúčal by som vám robiť zmeny priamo v súboroch v `/usr/share/omarchy`. Patria balíku Omarchy v pacman, takže vaše zmeny sa pri ďalšej aktualizácii jednoducho prepíšu. Radšej jednoducho prepíšte všetky predvolené hodnoty, ktoré sa vám nepáčia, v priečinku `~/.config/*`.

Takmer všetko môžete zmeniť týmto spôsobom, napríklad predvolené klávesové skratky. Stačí upraviť `~/.config/hypr/bindings.lua`, povedzme, aby ste nahradili [Obsidian](https://obsidian.md/) aplikáciou [Joplin](https://joplinapp.org/) (nainštalujete príkazom `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` odstráni existujúcu skratku pred pridaním jej náhrady. Berie rovnaké argumenty ako `o.bind`, vrátane pomocníkov na spúšťanie a možností skratiek. Použite `o.bind` na pridanie skratky alebo `hl.unbind` na odstránenie skratky bez jej nahradenia.

Ak trváte na tom, že budete zasahovať do interných súborov Omarchy, prepnite na dev kanál cez _Update > Channel > Dev_. Tým sa Omarchy prepojí s git checkoutom zdrojového kódu v `~/omarchy`, ktorý môžete meniť, ako sa vám zachce. Nikto vám tu nebude hovoriť, čo máte robiť!

### Resetovanie akýchkoľvek zmien

Ak nakoniec v konfiguráciách narobíte neporiadok, vždy ich môžete vrátiť na predvolené hodnoty cez _Update > Config_ v menu Omarchy. Alebo spustením `omarchy reinstall configs`, čím resetujete všetko.
