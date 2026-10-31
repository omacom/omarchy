# Dotfiles

Omarchy sa primárne konfiguruje prostredníctvom takzvaných dotfiles, ktoré sa nachádzajú v `~/.config`. Tie sa považujú za vaše súbory určené na vaše zmeny. Súbory, ktoré sa nachádzajú v `/usr/share/omarchy`, patria samotnému Omarchy a nemali by ste sa v nich vŕtať. Ak potrebujete zmeniť čokoľvek v `/usr/share/omarchy`, namiesto toho by ste mali prepísať danú hodnotu v `~/.config`.

Kľúčové konfigurácie je možné upravovať priamo z ponuky Omarchy (`Super + Space`), napríklad _Nastavenie > Klávesové skratky_, _Nastavenie > Vstup_ a _Nastavenie > Konfigurácia > [file]_. Keď to urobíte týmto spôsobom, každý proces, ktorý je po úpravách konfigurácie potrebné reštartovať, sa po zatvorení editora reštartuje automaticky (predvolene Neovim — `:wq`, pamätajte! — ale môžete to zmeniť cez _Nastavenie > Predvolené > Editor_).

Tu je zoznam kľúčových súborov v `~/.config` a toho, čo ovládajú:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hlavná konfigurácia Hyprlandu. Načítava predvolené nastavenia Omarchy plus vaše súbory s prepísaniami uvedené nižšie. [Viac o konfiguráciách Hyprlandu](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vaše vlastné klávesové skratky a prepísania predvolených nastavení. |
| `~/.config/hypr/monitors.lua` | Nastavenia monitora, ktoré panel monitora nepokrýva, napríklad otočenie, ďalšie režimy alebo ponechanie monitora vypnutého. |
| `~/.config/hypr/input.lua` | Ovláda rozloženie klávesnice, nastavenia myši a trackpadu. |
| `~/.config/hypr/looknfeel.lua` | Ovláda medzery, okraje, animácie a zvyšok vzhľadu. |
| `~/.config/hypr/autostart.lua` | Ovláda ďalšie procesy spúšťané spolu s reláciou. |
| `~/.config/omarchy/shell.json` | Ovláda shell Omarchy: polohu panela, rozloženie a widgety, plus šetrič obrazovky, zamykanie a časovania nečinnosti. |
| `~/.config/foot/foot.ini` | Ovláda váš terminál (predvoleným je foot). |
| `~/.XCompose` | Definuje vaše rýchlo prístupné emoji a automatické dopĺňanie mena/e-mailu. Po vykonaní zmien nezabudnite spustiť `omarchy-restart-xcompose`. |

Ak nakoniec urobíte veľa zmien pri ladení vlastného nastavenia, je dobré si všetky tieto dotfiles zálohovať. [Stow je skvelý spôsob, ako to urobiť](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Spúšťanie vlastných aplikácií spolu s reláciou

Ak chcete, aby sa niečo spúšťalo pri každom prihlásení — synchronizačný démon, chatovacia aplikácia, váš vlastný skript — vložte to do `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tým sa príkaz spustí ako súčasť relácie, takže sa pri odhlásení správne vyčistí.

### Spúšťanie skriptov pri systémových udalostiach

Omarchy spúšťa hooky v niekoľkých okamihoch a môžete na ne zavesiť svoje vlastné skripty. Nachádzajú sa v `~/.config/omarchy/hooks/<event>.d/`, jeden adresár pre každú udalosť, a každý spustiteľný súbor v ňom sa spustí, keď daná udalosť nastane:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Hneď po spustení pracovnej plochy |
| `post-update` | Ku koncu `omarchy update`, po balíkoch, migráciách a reštartoch služieb, pred aktualizáciou nástrojov mise |
| `pre-refresh-pacman` | Po tom, ako `omarchy refresh pacman` znova zosynchronizuje konfiguráciu balíkov, pred aktualizáciou balíkov; prepnutie kanála ho spustí počas rovnakého kroku obnovenia |
| `theme-set` | Po zmene témy (názov témy v `$1`) |
| `font-set` | Po zmene písma (názov písma v `$1`) |
| `battery-low` | Keď je batéria takmer vybitá (percento v `$1`) |

Hook `pre-refresh-pacman` je miesto, kam patria vlastné repozitáre alebo riadky `IgnorePkg`, keďže sa spúšťa pred transakciou balíkov. Oba hooky súvisiace s aktualizáciou sa spúšťajú pod vaším používateľom po tom, ako Omarchy vymaže svoju uloženú autorizáciu sudo, takže hook, ktorý používa `sudo`, potrebuje vlastnú autorizáciu a môže si vyžiadať vaše heslo.

Každý z týchto adresárov už obsahuje súbor `.sample`, ktorý ukazuje tvar hooku — odstráňte z názvu `.sample`, aby ste ho uviedli do prevádzky. Ak chcete nainštalovať skript, ktorý ste napísali inde, použite `omarchy hook install post-boot ~/my-hook`, čím sa skopíruje dnu a nastaví sa ako spustiteľný.

### Pridávanie vlastných položiek ponuky

Ponuku Omarchy (`Super + Space`) je možné rozšíriť o vlastné riadky úpravou `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Položky sú kľúčované bodkovaným id a práve id ich umiestňuje do stromu, takže `personal` sa zobrazí v koreňovej ponuke a `personal.notes` sa zobrazí vnútri nej:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Opätovným použitím existujúceho id prepíšete daný riadok namiesto pridania nového. Súbor sa dodáva so všetkými dostupnými poľami zdokumentovanými ako komentáre.

### Pridávanie vlastných exportov, funkcií a aliasov shellu

Omarchy sa dodáva s množstvom ergonomických aliasov a užitočných funkcií, ale je veľmi bežné chcieť pridať vlastné. Aliasy, funkcie aj exporty by ste mali pridávať do `~/.bashrc`. Tento súbor sa pri aktualizáciách neprepíše. Ak chcete zmeniť niektoré z predvolených nastavení Omarchy, môžete ich tu tiež bezpečne pridať.

### Nastavenie premenných prostredia pre pracovnú plochu

Exporty relácie pracovnej plochy patria do `~/.config/uwsm/env.d/`. Tieto súbory sa spúšťajú pred spustením pracovnej plochy, takže chyba shellu vás môže vrátiť na prihlasovaciu obrazovku. Počas ich úprav majte otvorený funkčný terminál. Ak chcete prepísanie vypnúť, presuňte ho mimo `env.d`. Pozrite si [riešenie problémov s prihlásením](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), ak vám zmena zabráni v prihlásení.

### Zmena interných súborov Omarchy

Pozrite, toto je váš počítač. Môžete si s ním robiť, čo chcete, ale neodporúčal by som robiť zmeny priamo v súboroch v `/usr/share/omarchy`. Patria do balíka pacman Omarchy, takže vaše zmeny sa pri ďalšej aktualizácii jednoducho prepíšu. Radšej jednoducho prepíšte všetky predvolené hodnoty, ktoré sa vám nepáčia, v priečinku `~/.config/*`.

Takto môžete zmeniť takmer všetko, napríklad predvolené klávesové skratky. Stačí upraviť `~/.config/hypr/bindings.lua` a povedzme nahradiť [Obsidian](https://obsidian.md/) aplikáciou [Joplin](https://joplinapp.org/) (nainštalujete príkazom `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` odstráni existujúcu väzbu pred pridaním jej náhrady. Berie rovnaké argumenty ako `o.bind`, vrátane pomocníkov na spúšťanie a možností väzby. Pomocou `o.bind` väzbu pridáte alebo pomocou `hl.unbind` ju odstránite bez náhrady.

Ak trváte na hackovaní interných súborov Omarchy, prepnite na kanál dev cez _Aktualizácia > Kanál > Dev_. Tým sa Omarchy prepojí s git checkoutom zdrojového kódu v `~/omarchy`, ktorý môžete meniť, ako sa vám zachce. Nikto tu nie je na to, aby vám hovoril, čo máte robiť!

### Obnovenie akýchkoľvek zmien

Ak nakoniec v konfiguráciách narobíte neporiadok, vždy ich môžete vrátiť na predvolené hodnoty cez _Aktualizácia > Konfigurácia_ v ponuke Omarchy. Alebo spustením `omarchy reinstall configs` obnovíte všetko.
