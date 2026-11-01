# Dotfiles

Omarchy se konfiguruje především prostřednictvím takzvaných dotfiles, které sídlí v `~/.config`. Ty jsou považovány za vaše soubory pro vaše změny. Soubory, které sídlí v `/usr/share/omarchy`, patří samotnému Omarchy a do těch byste neměli zasahovat. Pokud potřebujete změnit cokoli v `/usr/share/omarchy`, měli byste místo toho přepsat hodnotu v `~/.config`.

Klíčové konfigurace můžete upravovat přímo z menu Omarchy (`Super + Space`), například _Setup > Keybindings_, _Setup > Input_ a _Setup > Config > [file]_. Když to uděláte tímto způsobem, každý proces, který je po úpravách konfigurace potřeba restartovat, se automaticky restartuje poté, co editor ukončíte (ve výchozím nastavení Neovim — `:wq`, pamatujte! — ale můžete to změnit přes _Setup > Defaults > Editor_).

Zde je seznam klíčových souborů v `~/.config` a toho, co ovládají:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hlavní konfigurace Hyprlandu. Načítá výchozí nastavení Omarchy plus vaše níže uvedené přepisující soubory. [Další informace o konfiguraci Hyprlandu](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vaše vlastní klávesové zkratky a přepisy výchozího nastavení. |
| `~/.config/hypr/monitors.lua` | Nastavení monitorů, která panel monitorů nepokrývá, jako je otočení, další režimy nebo ponechání monitoru vypnutého. |
| `~/.config/hypr/input.lua` | Ovládá rozložení klávesnice, nastavení myši a trackpadu. |
| `~/.config/hypr/looknfeel.lua` | Ovládá mezery, okraje, animace a zbytek vzhledu. |
| `~/.config/hypr/autostart.lua` | Ovládá další procesy spouštěné spolu s relací. |
| `~/.config/omarchy/shell.json` | Ovládá shell Omarchy: pozici panelu, rozložení a widgety, plus spořič obrazovky, zámek a časování nečinnosti. |
| `~/.config/foot/foot.ini` | Ovládá váš terminál (výchozí je foot). |
| `~/.XCompose` | Definuje vaše emoji pro rychlý přístup a automatické doplňování jména/e-mailu. Po provedení změn nezapomeňte spustit `omarchy-restart-xcompose`. |

Pokud nakonec provedete spoustu změn, abyste si vlastní nastavení vyladili, je dobré si všechny tyto dotfiles zálohovat. [Stow je skvělý způsob, jak to udělat](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Spouštění vlastních aplikací spolu s relací

Pokud chcete, aby se něco spouštělo při každém přihlášení — synchronizační daemon, chatovací aplikace, váš vlastní skript — vložte to do `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tím se příkaz spustí jako součást relace, takže se při vašem opětovném odhlášení řádně uklidí.

### Spouštění skriptů při systémových událostech

Omarchy spouští hooky v několika okamžicích a můžete na ně navěsit své vlastní skripty. Sídlí v `~/.config/omarchy/hooks/<event>.d/`, jeden adresář pro každou událost, a každý spustitelný soubor v něm se spustí, když událost nastane:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Hned po spuštění plochy |
| `post-update` | Ke konci `omarchy update`, po balíčcích, migracích a restartech služeb, před aktualizací nástrojů mise |
| `pre-refresh-pacman` | Poté, co `omarchy refresh pacman` znovu synchronizuje konfiguraci balíčků, před aktualizací balíčků; přepnutí kanálu jej spustí během téhož kroku refresh |
| `theme-set` | Po změně motivu (název motivu v `$1`) |
| `font-set` | Po změně písma (název písma v `$1`) |
| `battery-low` | Když je baterie téměř vybitá (procento v `$1`) |

Hook `pre-refresh-pacman` je místem, kam patří vlastní repozitáře nebo řádky `IgnorePkg`, protože se spouští před transakcí balíčků. Oba hooky související s aktualizací běží pod vaším uživatelem poté, co Omarchy vymaže svou uloženou autorizaci sudo, takže hook, který používá `sudo`, potřebuje vlastní autorizaci a může si vyžádat vaše heslo.

Každý z těchto adresářů už obsahuje soubor `.sample`, který ukazuje podobu hooku — odeberte z názvu `.sample` a hook začne fungovat. Chcete-li nainstalovat skript, který jste napsali jinde, použijte `omarchy hook install post-boot ~/my-hook`, který ho zkopíruje dovnitř a nastaví jako spustitelný.

### Přidávání vlastních položek menu

Menu Omarchy (`Super + Space`) můžete rozšířit o vlastní řádky úpravou `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Položky jsou klíčovány tečkovaným id a právě id je umisťuje do stromu, takže `personal` se objeví v kořenovém menu a `personal.notes` se objeví uvnitř něj:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Znovu použijete existující id a přepíšete daný řádek místo přidání nového. Soubor obsahuje všechny dostupné pole zdokumentované formou komentářů.

### Přidávání vlastních shellových exportů, funkcí a aliasů

Omarchy dodává hromadu ergonomických aliasů a užitečných funkcí, ale je velmi běžné chtít přidat vlastní. Aliasy, funkce i exporty byste měli přidávat do `~/.bashrc`. Tento soubor se při aktualizacích nepřepíše. Pokud chcete změnit kterékoli z výchozích nastavení Omarchy, můžete je sem také bezpečně přidat.

### Nastavení proměnných prostředí pro desktop

Exporty desktopové relace patří do `~/.config/uwsm/env.d/`. Tyto soubory se spouštějí před spuštěním vašeho desktopu, takže chyba shellu vás může poslat zpět na přihlašovací obrazovku. Při jejich úpravách si nechte otevřený funkční terminál. Chcete-li přepis zakázat, přesuňte ho pryč z `env.d`. Pokud změna brání přihlášení, viz [obnova přihlášení](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen).

### Změna interních souborů Omarchy

Podívejte, je to váš počítač. Můžete si s ním dělat, co chcete, ale doporučil bych vám nedělat změny přímo v souborech v `/usr/share/omarchy`. Patří do pacman balíčku Omarchy, takže vaše změny se při příští aktualizaci prostě přepíšou. Místo toho uděláte lépe, když jakékoli výchozí hodnoty, které se vám nelíbí, přepíšete ve složce `~/.config/*`.

Tímto způsobem můžete změnit téměř všechno, třeba výchozí klávesové zkratky. Stačí upravit `~/.config/hypr/bindings.lua` a třeba nahradit [Obsidian](https://obsidian.md/) aplikací [Joplin](https://joplinapp.org/) (nainstalujete pomocí `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` odstraní existující vazbu před přidáním její náhrady. Přijímá stejné argumenty jako `o.bind`, včetně pomocníků pro spouštění a možností vazby. Použijte `o.bind` pro přidání vazby, nebo `hl.unbind` pro odstranění vazby bez její náhrady.

Pokud trváte na tom, že se budete vrtat v interních souborech Omarchy, přepněte na dev kanál přes _Update > Channel > Dev_. Tím se Omarchy propojí s git checkoutem zdrojového kódu v `~/omarchy`, který můžete měnit podle libosti, jak se vám zlíbí. Tady vám nikdo nebude říkat, co máte dělat!

### Resetování jakýchkoli změn

Pokud konfigurace nakonec pořádně rozbijete, můžete je vždy vrátit do výchozího stavu přes _Update > Config_ v menu Omarchy. Nebo spuštěním `omarchy reinstall configs` resetujete všechno.
