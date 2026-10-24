# Dotfiles

Omarchy sa primárne konfiguruje prostredníctvom takzvaných dotfiles, ktoré žijú v `~/.config`. Tie sa považujú za tvoje súbory pre tvoje zmeny. Súbory, ktoré žijú v `/usr/share/omarchy`, patria samotnému Omarchy a nemal by si sa do nich miešať. Ak potrebuješ niečo zmeniť v `/usr/share/omarchy`, mal by si namiesto toho prepísať hodnotu v `~/.config`.

Hlavné konfigurácie sa dajú upravovať priamo z menu Omarchy (`Super + Space`), napríklad _Nastavenie > Monitory_, _Nastavenie > Klávesové skratky_, _Nastavenie > Vstup_ a _Nastavenie > Konfigurácia > [file]_. Keď to urobíš týmto spôsobom, každý proces, ktorý sa po úprave konfigurácie potrebuje reštartovať, tak automaticky urobí po tom, čo ukončíš editor (predvolene Neovim — `:wq`, pamätaj! — ale môžeš ho zmeniť prostredníctvom _Nastavenie > Predvolené > Editor_).

Tu je zoznam hlavných súborov v `~/.config` a čo ovládajú:

| Súbor                  | Účel              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hlavná konfigurácia Hyprlandu. Načíta predvolené nastavenia Omarchy plus tvoje súbory na prepísanie uvedené nižšie. [Ďalšie informácie o konfiguráciách Hyprlandu](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Tvoje vlastné klávesové skratky a prepísania predvolených. |
| `~/.config/hypr/monitors.lua` | Ovláda tvoje monitory, rozlíšenie a polohu. |
| `~/.config/hypr/input.lua` | Ovláda rozloženie tvojej klávesnice, myši a trackpadu. |
| `~/.config/hypr/looknfeel.lua` | Ovláda medzery, orámovania, animácie a zvyšok vzhľadu. |
| `~/.config/hypr/autostart.lua` | Ovláda dodatočné procesy spúšťané so reláciou. |
| `~/.config/omarchy/shell.json` | Ovláda shell Omarchy: polohu lišty, rozloženie a widgety plus časy šetriča obrazovky, zámku a nečinnosti. |
| `~/.config/foot/foot.ini` | Ovláda tvoj terminál (foot je predvolený). |
| `~/.XCompose` | Definuje tvoje rýchlo prístupné emoji a automatické dopĺňanie mena/e-mailu. Po vykonaní zmien nezabudni spustiť `omarchy-restart-xcompose`. |

Ak nakoniec urobíš veľa zmien pri ladení vlastného nastavenia, je dobré všetky tieto dotfiles zálohovať. [Stow je na to skvelý spôsob](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Spúšťanie vlastných aplikácií so reláciou

Ak chceš, aby sa niečo spúšťalo pri každom prihlásení — synchronizačný démon, chatová aplikácia, tvoj vlastný skript — umiestni to do `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tým sa príkaz spustí ako súčasť relácie, takže sa správne vyčistí, keď sa znova odhlásiš.

### Spúšťanie skriptov pri systémových udalostiach

Omarchy spúšťa háky (hooks) v niekoľkých okamihoch a môžeš na ne zavesiť vlastné skripty. Žijú v `~/.config/omarchy/hooks/<event>.d/`, jeden adresár na udalosť, a každý spustiteľný súbor tam sa spustí, keď nastane daná udalosť:

| Udalosť | Kedy sa spúšťa |
| ----- | ------------ |
| `post-boot` | Hneď po spustení pracovnej plochy |
| `post-update` | Ku koncu `omarchy update`, po balíčkoch, migráciách a reštartoch služieb, pred aktualizáciou nástrojov mise |
| `pre-refresh-pacman` | Po tom, čo `omarchy refresh pacman` znova zosynchronizuje konfiguráciu balíčkov, pred aktualizáciou balíčkov; prepnutie kanála ho spustí počas toho istého kroku obnovenia |
| `theme-set` | Po zmene témy (názov témy v `$1`) |
| `font-set` | Po zmene písma (názov písma v `$1`) |
| `battery-low` | Keď je batéria slabá (percento v `$1`) |

Hák `pre-refresh-pacman` je miesto, kam patria vlastné repozitáre alebo riadky `IgnorePkg`, keďže sa spúšťa pred transakciou balíčkov. Oba háky súvisiace s aktualizáciou bežia pod tvojím používateľom po tom, čo Omarchy vymaže svoju uloženú autorizáciu sudo, takže hák, ktorý používa `sudo`, potrebuje vlastnú autorizáciu a môže si vyžiadať tvoje heslo.

Každý z týchto adresárov už obsahuje súbor `.sample` ukazujúci tvar háku — odstráň z názvu `.sample`, aby začal pracovať. Ak chceš nainštalovať skript, ktorý si napísal inde, použi `omarchy hook install post-boot ~/my-hook`, čím sa skopíruje dnu a urobí sa spustiteľným.

### Pridávanie vlastných položiek menu

Menu Omarchy (`Super + Space`) sa dá rozšíriť o vlastné riadky úpravou súboru `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Položky sú kľúčované bodkovým id a práve id ich umiestňuje do stromu, takže `personal` sa zobrazí v koreňovom menu a `personal.notes` sa zobrazí vnútri neho:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Ak znova použiješ existujúce id, prepíšeš tento riadok namiesto pridania nového. Súbor sa dodáva so všetkými dostupnými poliami zdokumentovanými ako komentáre.

### Pridávanie vlastných exportov, funkcií a aliasov shellu

Omarchy sa dodáva s množstvom ergonomických aliasov a užitočných funkcií, ale je veľmi bežné chcieť pridať vlastné. Aliasy, funkcie aj exporty by si mal pridávať do `~/.bashrc`. Tento súbor sa pri aktualizáciách neprepíše. Ak chceš zmeniť niektoré z predvolených nastavení Omarchy, môžeš ich tu tiež bezpečne pridať.

### Zmena interných súborov Omarchy

Pozri, toto je tvoj počítač. Môžeš si s ním robiť, čo chceš, ale neodporúčal by som robiť zmeny priamo v súboroch v `/usr/share/omarchy`. Patria balíčku pacman Omarchy, takže tvoje zmeny sa pri ďalšej aktualizácii jednoducho prepíšu. Radšej jednoducho prepíš všetky predvolené hodnoty, ktoré sa ti nepáčia, v priečinku `~/.config/*`.

Týmto spôsobom môžeš zmeniť takmer všetko, napríklad predvolené klávesové skratky. Stačí upraviť `~/.config/hypr/bindings.lua` a napríklad nahradiť [Obsidian](https://obsidian.md/) programom [Joplin](https://joplinapp.org/) (nainštaluješ pomocou `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` odstráni existujúcu skratku pred pridaním jej náhrady. Preberá rovnaké argumenty ako `o.bind` vrátane pomocníkov na spúšťanie a možností skratiek. Na pridanie skratky použi `o.bind` alebo na jej odstránenie bez náhrady `hl.unbind`.

Ak trváš na hackovaní interných súborov Omarchy, prepnúť sa na kanál dev prostredníctvom _Aktualizovať > Kanál > Dev_. Tým sa Omarchy prepojí s git checkoutom zdrojového kódu v `~/omarchy`, ktorý môžeš ľubovoľne meniť podľa svojej chuti. Nikto tu nie je, aby ti hovoril, čo máš robiť!

### Obnovenie vašich zmien

Ak nakoniec v konfiguráciách narobíš neporiadok, vždy ich môžeš vrátiť na predvolené nastavenia prostredníctvom _Aktualizovať > Konfigurácia_ v menu Omarchy. Alebo spustením `omarchy reinstall configs` a obnovením všetkého.
