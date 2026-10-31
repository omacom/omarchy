# Dotfiles

Omarchy sa primárne konfiguruje prostredníctvom takzvaných dotfiles, ktoré sa nachádzajú v `~/.config`. Tie sa považujú za vaše súbory na vaše zmeny. Súbory, ktoré sa nachádzajú v `/usr/share/omarchy`, patria samotnému Omarchy a do tých by ste nemali zasahovať. Ak potrebujete zmeniť čokoľvek v `/usr/share/omarchy`, mali by ste namiesto toho prepísať hodnotu v `~/.config`.

Kľúčové konfigurácie môžete upravovať priamo z ponuky Omarchy (`Super + Space`), napríklad _Setup > Keybindings_, _Setup > Input_ a _Setup > Config > [file]_. Keď to urobíte týmto spôsobom, všetky procesy, ktoré je potrebné po úpravách konfigurácie reštartovať, sa automaticky reštartujú po zatvorení editora (predvolene Neovim — `:wq`, nezabudnite! — ale môžete to zmeniť cez _Setup > Defaults > Editor_).

Tu je zoznam kľúčových súborov v `~/.config` a toho, čo ovládajú:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hlavná konfigurácia Hyprland. Načítava predvolené nastavenia Omarchy plus vaše súbory s prepismi nižšie. [Zistite viac o konfiguráciách Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vaše vlastné klávesové skratky a prepisy predvolených. |
| `~/.config/hypr/monitors.lua` | Nastavenia monitora, ktoré panel monitorov nepokrýva, ako napríklad rotácia, ďalšie režimy alebo ponechanie monitora vypnutého. |
| `~/.config/hypr/input.lua` | Ovláda rozloženie klávesnice, myš a nastavenia trackpadu. |
| `~/.config/hypr/looknfeel.lua` | Ovláda medzery, okraje, animácie a zvyšok vzhľadu. |
| `~/.config/hypr/autostart.lua` | Ovláda ďalšie procesy spúšťané so reláciou. |
| `~/.config/omarchy/shell.json` | Ovláda prostredie Omarchy shell: pozíciu panela, rozloženie a widgety, plus šetrič obrazovky, zámok a časovania nečinnosti. |
| `~/.config/foot/foot.ini` | Ovláda váš terminál (foot je predvolený). |
| `~/.XCompose` | Definuje váš rýchly prístup k emoji a automatické dopĺňanie mena/e-mailu. Po vykonaní zmien nezabudnite spustiť `omarchy-restart-xcompose`. |

Ak nakoniec urobíte veľa zmien, aby ste si prispôsobili vlastné nastavenie, je dobré zálohovať všetky tieto dotfiles. [Stow je skvelý spôsob, ako to urobiť](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Spúšťanie vlastných aplikácií so reláciou

Ak chcete, aby sa niečo spúšťalo pri každom prihlásení — synchronizačný démon, chatovacia aplikácia, váš vlastný skript — vložte to do `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tým sa príkaz spustí ako súčasť relácie, takže sa pri odhlásení správne vyčistí.

### Spúšťanie skriptov pri systémových udalostiach

Omarchy spúšťa hooky v niekoľkých momentoch a môžete na ne zavesiť svoje vlastné skripty. Nachádzajú sa v `~/.config/omarchy/hooks/<event>.d/`, jeden adresár pre každú udalosť, a každý spustiteľný súbor v ňom sa spustí, keď udalosť nastane:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Hneď po spustení pracovnej plochy |
| `post-update` | Ku koncu `omarchy update`, po balíkoch, migráciách a reštartoch služieb, pred aktualizáciou nástrojov mise |
| `pre-refresh-pacman` | Po tom, čo `omarchy refresh pacman` znova synchronizuje konfiguráciu balíkov, pred aktualizáciou balíkov; prepnutie kanála ho spustí počas toho istého kroku obnovenia |
| `theme-set` | Po zmene témy (názov témy v `$1`) |
| `font-set` | Po zmene písma (názov písma v `$1`) |
| `battery-low` | Keď je batéria slabá (percento v `$1`) |

Hook `pre-refresh-pacman` je miesto, kam patria vlastné repozitáre alebo riadky `IgnorePkg`, keďže sa spúšťa pred transakciou balíkov. Oba hooky súvisiace s aktualizáciou sa spúšťajú ako váš používateľ po tom, čo Omarchy vymaže svoju uloženú autorizáciu sudo, takže hook, ktorý používa `sudo`, potrebuje vlastnú autorizáciu a môže si vyžiadať vaše heslo.

Každý z týchto adresárov už obsahuje súbor `.sample`, ktorý ukazuje tvar hooku — odstráňte `.sample` z názvu, aby ste ho uviedli do prevádzky. Ak chcete nainštalovať skript, ktorý ste napísali inde, použite `omarchy hook install post-boot ~/my-hook`, ktorý ho skopíruje a nastaví ako spustiteľný.

### Pridávanie vlastných položiek ponuky

Ponuku Omarchy (`Super + Space`) môžete rozšíriť o vlastné riadky úpravou `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Položky sú kľúčované bodkovaným id a id je to, čo ich umiestňuje do stromu, takže `personal` sa zobrazí v koreňovej ponuke a `personal.notes` sa zobrazí vnútri nej:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Znova použite existujúce id a prepíšete tento riadok namiesto pridania nového. Súbor sa dodáva so všetkými dostupnými poľami zdokumentovanými ako komentáre.

### Pridávanie vlastných exportov prostredia shell, funkcií a aliasov

Omarchy sa dodáva s kopou ergonomických aliasov a užitočných funkcií, ale je veľmi bežné chcieť pridať svoje vlastné. Aliasy, funkcie aj exporty by ste mali pridávať do `~/.bashrc`. Tento súbor sa pri aktualizáciách neprepíše. Ak chcete zmeniť ktorékoľvek z predvolených nastavení Omarchy, môžete ich tiež bezpečne pridať sem.

### Zmena interných súborov Omarchy

Pozrite, toto je váš počítač. Môžete si s ním robiť, čo chcete, ale neodporúčal by som robiť zmeny priamo v súboroch v `/usr/share/omarchy`. Patria balíku Omarchy pacman, takže vaše zmeny sa pri ďalšej aktualizácii jednoducho prepíšu. Radšej prepíšte všetky predvolené hodnoty, ktoré sa vám nepáčia, v priečinku `~/.config/*`.

Takto môžete zmeniť takmer všetko, napríklad predvolené klávesové skratky. Stačí upraviť `~/.config/hypr/bindings.lua`, aby ste povedzme nahradili [Obsidian](https://obsidian.md/) za [Joplin](https://joplinapp.org/) (nainštalujte pomocou `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` odstráni existujúcu väzbu pred pridaním jej náhrady. Berie rovnaké argumenty ako `o.bind`, vrátane pomocníkov na spúšťanie a možností väzby. Pomocou `o.bind` pridáte väzbu alebo pomocou `hl.unbind` jednu odstránite bez nahradenia.

Ak trváte na úpravách interných súborov Omarchy, prepnite na vývojový kanál cez _Update > Channel > Dev_. Tým sa Omarchy prepojí s git checkoutom zdrojového kódu v `~/omarchy`, ktorý môžete meniť, koľko len chcete. Nikto vám tu nebude hovoriť, čo máte robiť!

### Obnovenie všetkých zmien

Ak nakoniec urobíte v konfiguráciách neporiadok, vždy ich môžete vrátiť na predvolené hodnoty cez _Update > Config_ v ponuke Omarchy. Alebo spustením `omarchy reinstall configs` na resetovanie všetkého.
