# Dotfiles

Omarchy se primárně konfiguruje prostřednictvím takzvaných dotfiles, které se nacházejí v `~/.config`. Ty jsou považovány za tvoje soubory pro tvoje změny. Soubory, které se nacházejí v `/usr/share/omarchy`, patří samotnému Omarchy a neměl by ses v nich hrabat. Pokud potřebuješ něco změnit v `/usr/share/omarchy`, měl bys místo toho přepsat hodnotu v `~/.config`.

Klíčové konfigurace můžeš upravovat přímo z nabídky Omarchy (`Super + Space`), například _Setup > Keybindings_, _Setup > Input_ a _Setup > Config > [file]_. Když to uděláš tímto způsobem, každý proces, který je po úpravách konfigurace potřeba restartovat, se automaticky restartuje poté, co ukončíš editor (ve výchozím nastavení Neovim — `:wq`, pamatuj! — ale můžeš to změnit přes _Setup > Defaults > Editor_).

Tady je seznam klíčových souborů v `~/.config` a toho, co ovládají:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hlavní konfigurace Hyprlandu. Načítá výchozí nastavení Omarchy plus tvoje níže uvedené soubory pro přepsání. [Další informace o konfiguracích Hyprlandu](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Tvoje vlastní klávesové zkratky a přepsání výchozích. |
| `~/.config/hypr/monitors.lua` | Nastavení monitorů, která panel monitorů nepokrývá, například otáčení, další režimy nebo ponechání monitoru vypnutého. |
| `~/.config/hypr/input.lua` | Ovládá rozložení klávesnice a nastavení myši a trackpadu. |
| `~/.config/hypr/looknfeel.lua` | Ovládá mezery, okraje, animace a zbytek vzhledu. |
| `~/.config/hypr/autostart.lua` | Ovládá další procesy spouštěné s relací. |
| `~/.config/omarchy/shell.json` | Ovládá shell Omarchy: pozici lišty, rozložení a widgety, plus spořič obrazovky, zámek a doby nečinnosti. |
| `~/.config/foot/foot.ini` | Ovládá tvůj terminál (ve výchozím nastavení je to foot). |
| `~/.XCompose` | Definuje tvoje rychle přístupné emoji a automatické doplňování jména/e-mailu. Po provedení změn nezapomeň spustit `omarchy-restart-xcompose`. |

Pokud nakonec provedeš spoustu změn, abys vyladil vlastní nastavení, je dobré si všechny tyto dotfiles zálohovat. [Stow je skvělý způsob, jak to udělat](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Spouštění vlastních aplikací se relací

Pokud chceš, aby se něco spouštělo při každém přihlášení — synchronizační démon, chatovací aplikace, tvůj vlastní skript — vlož to do `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tím se příkaz spustí jako součást relace, takže se při odhlášení řádně uklidí.

### Spouštění skriptů při systémových událostech

Omarchy spouští hooky v několika okamžicích a můžeš na ně navěsit vlastní skripty. Nacházejí se v `~/.config/omarchy/hooks/<event>.d/`, jeden adresář pro každou událost, a každý spustitelný soubor v něm se spustí, když k události dojde:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Hned poté, co se plocha spustila |
| `post-update` | Ke konci `omarchy update`, po balíčcích, migracích a restartování služeb, před aktualizací nástrojů mise |
| `pre-refresh-pacman` | Poté, co `omarchy refresh pacman` znovu synchronizuje konfiguraci balíčků, předtím, než balíčky aktualizuje; přepnutí kanálu ho spouští během stejného kroku obnovení |
| `theme-set` | Po změně motivu (název motivu v `$1`) |
| `font-set` | Po změně písma (název písma v `$1`) |
| `battery-low` | Když je baterie téměř vybitá (procento v `$1`) |

Hook `pre-refresh-pacman` je místem, kam patří vlastní repozitáře nebo řádky `IgnorePkg`, protože se spouští před transakcí balíčků. Oba hooky související s aktualizací běží pod tvým uživatelem poté, co Omarchy vymaže svou uloženou autorizaci sudo, takže hook, který používá `sudo`, potřebuje vlastní autorizaci a může tě požádat o heslo.

Každý z těchto adresářů už obsahuje soubor `.sample`, který ukazuje podobu hooku — odeber z názvu `.sample` a uveď ho do provozu. Chceš-li nainstalovat skript, který jsi napsal jinde, použij `omarchy hook install post-boot ~/my-hook`, který ho tam zkopíruje a nastaví jako spustitelný.

### Přidávání vlastních položek nabídky

Nabídku Omarchy (`Super + Space`) můžeš rozšířit o vlastní řádky úpravou `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Položky jsou klíčovány tečkovým id a právě id je umisťuje do stromu, takže `personal` se objeví v kořenové nabídce a `personal.notes` se objeví uvnitř ní:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Když znovu použiješ existující id, přepíšeš daný řádek místo přidání nového. Soubor se dodává se všemi dostupnými poli zdokumentovanými jako komentáře.

### Přidávání vlastních exportů shellu, funkcí a aliasů

Omarchy se dodává se spoustou ergonomických aliasů a užitečných funkcí, ale je velmi běžné, že si chceš přidat vlastní. Vlastní aliasy, funkce i exporty bys měl přidávat do `~/.bashrc`. Tento soubor nebude při aktualizacích přepisován. Pokud chceš změnit některé z výchozích nastavení Omarchy, můžeš je bezpečně přidat i sem.

### Změna interních souborů Omarchy

Podívej, je to tvůj počítač. Můžeš si s ním dělat, co chceš, ale nedoporučoval bych ti měnit soubory v `/usr/share/omarchy` přímo. Patří do balíčku pacman Omarchy, takže tvoje změny budou při příští aktualizaci prostě přepsány. Uděláš lépe, když místo toho přepíšeš všechny výchozí hodnoty, které se ti nelíbí, ve složce `~/.config/*`.

Tímto způsobem můžeš změnit skoro vše, třeba výchozí klávesové zkratky. Stačí upravit `~/.config/hypr/bindings.lua` a třeba nahradit [Obsidian](https://obsidian.md/) aplikací [Joplin](https://joplinapp.org/) (nainstaluješ ji příkazem `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` existující vazbu před přidáním její náhrady odstraní. Přijímá stejné argumenty jako `o.bind`, včetně pomocných funkcí pro spouštění a možností vazby. Použij `o.bind` k přidání vazby, nebo `hl.unbind` k odstranění vazby bez její náhrady.

Pokud trváš na tom, že budeš hackovat interní soubory Omarchy, přepni na kanál dev přes _Update > Channel > Dev_. Tím se Omarchy propojí s gitovým checkoutem zdrojového kódu v `~/omarchy`, který můžeš měnit, jak se ti zlíbí. Nikdo ti tady nebude říkat, co máš dělat!

### Resetování všech změn

Pokud nakonec uděláš v konfiguracích nepořádek, můžeš je kdykoliv vrátit na výchozí hodnoty přes _Update > Config_ v nabídce Omarchy. Nebo spuštěním `omarchy reinstall configs` pro resetování všeho.
