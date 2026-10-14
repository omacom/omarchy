# Dotfiles

Omarchy se konfiguruje především prostřednictvím takzvaných dotfiles, které žijí v adresáři `~/.config`. Ty jsou považovány za vaše soubory pro vaše změny. Soubory, které žijí v adresáři `/usr/share/omarchy`, patří samotné Omarchy a neměli byste se v nich šťourat. Pokud potřebujete cokoli v adresáři `/usr/share/omarchy` změnit, měli byste místo toho přepsat hodnotu v adresáři `~/.config`.

Klíčové konfigurace lze upravovat přímo z nabídky Omarchy (`Super + Space`), například _Nastavení > Monitory_, _Nastavení > Klávesové zkratky_, _Nastavení > Vstup_ a _Nastavení > Config > [file]_. Když to uděláte tímto způsobem, každý proces, který po úpravách konfigurace potřebuje restartovat automaticky, se restartuje poté, co zavřete editor (ve výchozím nastavení Neovim — `:wq`, pamatujte! — ale to můžete změnit v části _Nastavení > Výchozí > Editor_).

Tady je seznam klíčových souborů v adresáři `~/.config` a toho, co ovládají:

| File                  | Účel              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hlavní konfigurace Hyprlandu. Načítá výchozí nastavení Omarchy plus vaše soubory pro přepsání níže. [Další informace o konfiguracích Hyprlandu](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vaše vlastní klávesové zkratky a přepsání výchozích nastavení. |
| `~/.config/hypr/monitors.lua` | Ovládá vaše monitory, rozlišení a polohu. |
| `~/.config/hypr/input.lua` | Ovládá rozložení vaší klávesnice, nastavení myši a trackpadu. |
| `~/.config/hypr/looknfeel.lua` | Ovládá mezery, rámečky, animace a zbytek vzhledu. |
| `~/.config/hypr/autostart.lua` | Ovládá další procesy spuštěné se relací. |
| `~/.config/omarchy/shell.json` | Ovládá shell Omarchy: polohu panelu, rozložení a widgety, plus časy spořiče obrazovky, zamykání a nečinnosti. |
| `~/.config/foot/foot.ini` | Ovládá váš terminál (foot je výchozí). |
| `~/.XCompose` | Definuje vaše emoji s rychlým přístupem a automatické doplňování jména/e-mailu. Po provedení změn nezapomeňte spustit příkaz `omarchy-restart-xcompose`. |

Pokud nakonec uděláte spoustu změn při ladění vlastního nastavení, je dobré si všechny tyto dotfiles zazálohovat. [Stow je skvělý způsob, jak to udělat](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Spouštění vlastních aplikací se relací

Pokud chcete, aby se při každém přihlášení něco spustilo — démon pro synchronizaci, chatovací aplikace, vlastní skript — vložte to do souboru `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tím se příkaz spustí jako součást relace, takže při odhlášení se zase řádně uklidí.

### Spouštění skriptů při systémových událostech

Omarchy spouští háčky v několika okamžicích a můžete na ně zavěsit vlastní skripty. Žijí v adresáři `~/.config/omarchy/hooks/<event>.d/`, jeden adresář pro každou událost, a každý spustitelný soubor v něm se spustí, když událost nastane:

| Event | Kdy běží |
| ----- | ------------ |
| `post-boot` | Hned po spuštění pracovního prostředí |
| `post-update` | Ke konci příkazu `omarchy update`, po balíčcích, migracích a restartech služeb, před aktualizací nástrojů mise |
| `pre-refresh-pacman` | Poté, co příkaz `omarchy refresh pacman` znovu synchronizuje konfiguraci balíčků, předtím, než balíčky aktualizuje; přepnutí kanálu ho spustí během stejného kroku obnovení |
| `theme-set` | Po změně motivu (název motivu v proměnné `$1`) |
| `font-set` | Po změně písma (název písma v proměnné `$1`) |
| `battery-low` | Když je baterie vybitá (procenta v proměnné `$1`) |

Háček `pre-refresh-pacman` je místo, kam patří vlastní repozitáře nebo řádky `IgnorePkg`, protože běží před transakcí balíčků. Oba háčky související s aktualizací běží pod vaším uživatelem poté, co Omarchy vymaže oprávnění sudo z mezipaměti, takže háček používající `sudo` potřebuje vlastní oprávnění a může si vyžádat vaše heslo.

Každý z těchto adresářů již obsahuje soubor `.sample` ukazující tvar háčku — odeberte příponu `.sample` z názvu, abyste ho uvedli do provozu. Chcete-li nainstalovat skript, který jste napsali jinde, použijte příkaz `omarchy hook install post-boot ~/my-hook`, který ho zkopíruje a udělá z něho spustitelný soubor.

### Přidávání vlastních položek nabídky

Nabídku Omarchy (`Super + Space`) lze rozšířit vlastními řádky úpravou souboru `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Položky jsou klíčovány tečkovaným id a toto id je umisťuje do stromu, takže `personal` se objeví v kořenové nabídce a `personal.notes` se objeví uvnitř ní:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Znovu použijte existující id a tento řádek přepíšete, místo abyste přidali nový. Soubor je dodáván se všemi dostupnými poli zdokumentovanými jako komentáře.

### Přidávání vlastních exportů, funkcí a aliasů shellu

Omarchy je dodávána s řadou ergonomických aliasů a užitečných funkcí, ale je velmi běžné, že chcete přidat své vlastní. Aliasy, funkce i exporty byste měli přidat do souboru `~/.bashrc`. Tento soubor nebude při aktualizacích přepsán. Pokud chcete změnit některá z výchozích nastavení Omarchy, můžete je zde také bezpečně přidat.

### Změna vnitřních souborů Omarchy

Podívejte, toto je váš počítač. Můžete si s ním dělat, co chcete, ale doporučoval bych neprovádět změny přímo v souborech v adresáři `/usr/share/omarchy`. Patří do balíčku pacman pro Omarchy, takže vaše změny budou při příští aktualizaci jednoduše přepsány. Místo toho je lepší jednoduše přepsat všechny výchozí hodnoty, které se vám nelíbí, ve složce `~/.config/*`.

Tímto způsobem můžete změnit téměř vše, například výchozí klávesové zkratky. Stačí upravit soubor `~/.config/hypr/bindings.lua` tak, že například nahradíte [Obsidian](https://obsidian.md/) programem [Joplin](https://joplinapp.org/) (nainstalujte pomocí příkazu `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

Příkaz `o.rebind` odstraní existující vazbu před přidáním její náhrady. Přijímá stejné argumenty jako `o.bind`, včetně pomocných funkcí pro spouštění a možností vazeb. K přidání vazby použijte příkaz `o.bind`, nebo k jejímu odebrání bez nahrazení příkaz `hl.unbind`.

Pokud trváte na hackování vnitřních souborů Omarchy, přepněte na kanál dev v části _Aktualizovat > Kanál > Dev_. Tím se Omarchy propojí s gitovým checkoutem zdrojového kódu v adresáři `~/omarchy`, který můžete libovolně měnit dle libosti. Nikdo vám tu nebude říkat, co máte dělat!

### Resetování jakýchkoli změn

Pokud nakonec uděláte v konfiguracích nepořádek, můžete je vždy vrátit do výchozích nastavení v části _Aktualizovat > Config_ v nabídce Omarchy. Nebo spuštěním příkazu `omarchy reinstall configs`, který vše resetuje.
