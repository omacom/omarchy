# Dotfiles

Omarchy se primárně konfiguruje prostřednictvím takzvaných dotfiles, které se nacházejí v `~/.config`. Ty jsou považovány za vaše soubory pro vaše změny. Soubory, které se nacházejí v `/usr/share/omarchy`, patří samotnému Omarchy a do těch byste neměli zasahovat. Pokud potřebujete změnit cokoli v `/usr/share/omarchy`, měli byste místo toho přepsat danou hodnotu v `~/.config`.

Klíčové konfigurace můžete upravovat přímo z menu Omarchy (`Super + Space`), například _Setup > Keyboard > Keybindings_, _Setup > Input_ a _Setup > Config > [file]_. Když to uděláte tímto způsobem, každý proces, který je po úpravách konfigurace potřeba restartovat, bude automaticky restartován poté, co editor zavřete (ve výchozím nastavení Neovim — `:wq`, pamatujte! — ale můžete to změnit přes _Setup > Defaults > Editor_).

Zde je seznam klíčových souborů v `~/.config` a toho, co ovládají:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hlavní konfigurační soubor Hyprlandu. Načítá výchozí nastavení Omarchy a vaše níže uvedené soubory pro přepsání. [Další informace o konfiguraci Hyprlandu](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vaše vlastní klávesové zkratky a přepisy výchozích zkratek. |
| `~/.config/hypr/monitors.lua` | Nastavení monitorů, která panel monitorů nepokrývá, například rotace, další režimy nebo ponechání monitoru vypnutého. |
| `~/.config/hypr/input.lua` | Ovládá rozložení vaší klávesnice, nastavení myši a trackpadu. |
| `~/.config/hypr/looknfeel.lua` | Ovládá mezery, okraje, animace a zbytek vzhledu. |
| `~/.config/hypr/autostart.lua` | Ovládá další procesy spouštěné společně s relací. |
| `~/.config/omarchy/shell.json` | Ovládá shell Omarchy: pozici lišty, rozložení a widgety, plus spořič obrazovky, zamykání a časy nečinnosti. |
| `~/.config/foot/foot.ini` | Ovládá váš terminál (ve výchozím nastavení foot). |
| `~/.XCompose` | Definuje vaše rychlé emoji a automatické doplňování jména/e-mailu. Po provedení změn nezapomeňte spustit `omarchy-restart-xcompose`. |

Pokud nakonec provedete spoustu změn při ladění vlastního nastavení, je dobré si všechny tyto dotfiles zálohovat. [Stow je skvělý způsob, jak to udělat](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Spouštění vlastních aplikací společně s relací

Pokud chcete, aby se něco spouštělo při každém přihlášení — synchronizační démon, chatovací aplikace, váš vlastní skript — umístěte to do `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tím se příkaz spustí jako součást relace, takže bude při opětovném odhlášení řádně ukončen.

### Spouštění skriptů při systémových událostech

Omarchy v několika okamžicích spouští hooky a můžete na ně navěsit vlastní skripty. Nacházejí se v `~/.config/omarchy/hooks/<event>.d/`, jeden adresář pro každou událost, a každý soubor v něm, který nekončí na `.sample`, se při nastání události spustí pomocí bash:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Hned poté, co se desktop spustil |
| `post-update` | Ke konci `omarchy update`, po balíčcích, migracích a restartech služeb, před aktualizací nástrojů mise |
| `pre-refresh-pacman` | Poté, co `omarchy refresh pacman` znovu synchronizuje konfiguraci balíčků, před aktualizací balíčků; přepnutí kanálu ho spustí během téhož kroku obnovení |
| `theme-set` | Po změně tématu (název tématu v `$1`) |
| `font-set` | Po změně písma (název písma v `$1`) |
| `battery-low` | Když je baterie téměř vybitá (procento v `$1`) |

Hook `pre-refresh-pacman` je místo, kam patří vlastní repozitáře nebo řádky `IgnorePkg`, protože se spouští před transakcí balíčků. Oba běží pod vaším uživatelem. `post-update` běží, dokud je autorizace sudo pro `omarchy update` stále platná, takže hook, který používá `sudo`, po vás nebude znovu chtít heslo; `pre-refresh-pacman` běží hned poté, co `omarchy refresh pacman` sám použil sudo.

Každý z těchto adresářů už obsahuje soubor `.sample`, který ukazuje podobu hooku — odeberte z názvu `.sample`, abyste ho uvedli do provozu. Pro instalaci skriptu, který jste napsali jinde, použijte `omarchy hook install post-boot ~/my-hook`, což ho zkopíruje dovnitř a nastaví ho jako spustitelný.

### Přidávání vlastních položek menu

Menu Omarchy (`Super + Space`) můžete rozšířit o vlastní řádky úpravou `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Položky jsou klíčovány tečkovaným id a právě id je umisťuje do stromu, takže `personal` se zobrazí v kořenovém menu a `personal.notes` se zobrazí uvnitř něj:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Když znovu použijete existující id, přepíšete tento řádek, místo abyste přidali nový. Soubor je dodáván se všemi dostupnými poli zdokumentovanými formou komentářů.

### Přidávání vlastních exportů shellu, funkcí a aliasů

Omarchy je dodáváno se spoustou ergonomických aliasů a užitečných funkcí, ale je velmi běžné chtít přidat vlastní. Aliasy, funkce i exporty byste měli přidávat do `~/.bashrc`. Tento soubor nebude při aktualizacích přepsán. Pokud chcete změnit kterékoli z výchozích nastavení Omarchy, můžete je bezpečně přidat i sem.

### Nastavování proměnných prostředí pro desktop

Exporty relace desktopu patří do `~/.config/uwsm/env.d/`. Tyto soubory se spouštějí před spuštěním vašeho desktopu, takže chyba shellu vás může poslat zpět na přihlašovací obrazovku. Při jejich úpravách si nechte otevřený funkční terminál. Chcete-li přepsání zakázat, přesuňte ho pryč z `env.d`. Pokud změna zabrání přihlášení, viz [obnovení přihlášení](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen).

### Změna interních souborů Omarchy

Podívejte, je to váš počítač. Můžete si s ním dělat, co chcete, ale doporučil bych vám nedělat změny přímo v souborech v `/usr/share/omarchy`. Patří do balíčku pacman pro Omarchy, takže vaše změny budou při příští aktualizaci jednoduše přepsány. Místo toho uděláte lépe, když jakékoli výchozí hodnoty, které se vám nelíbí, přepíšete ve složce `~/.config/*`.

Tímto způsobem můžete změnit téměř všechno, například výchozí klávesové zkratky. Stačí upravit `~/.config/hypr/bindings.lua`, abyste třeba nahradili [Obsidian](https://obsidian.md/) aplikací [Joplin](https://joplinapp.org/) (instalace pomocí `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` před přidáním náhrady odstraní existující zkratku. Bere stejné argumenty jako `o.bind`, včetně pomocných funkcí pro spouštění a možností vazby. Pro přidání vazby použijte `o.bind`, nebo pro její odstranění bez nahrazení použijte `hl.unbind`.

Pokud trváte na tom, že budete zasahovat do interních souborů Omarchy, přepněte na dev kanál přes _Update > Channel > Dev_. Tím se Omarchy propojí s git checkoutem zdrojového kódu v `~/omarchy`, který můžete měnit, jak se vám zlíbí. Nikdo vám tu nebude říkat, co máte dělat!

### Resetování všech změn

Pokud nakonec v konfiguracích naděláte nepořádek, můžete je vždy vrátit do výchozího stavu přes _Update > Config_ v menu Omarchy. Nebo spuštěním `omarchy reinstall configs` pro resetování všeho.
