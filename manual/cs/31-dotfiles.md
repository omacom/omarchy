# Dotfiles

Omarchy se konfiguruje především prostřednictvím takzvaných dotfiles, které se nacházejí v `~/.config`. Ty jsou považovány za vaše soubory pro vaše změny. Soubory, které se nacházejí v `/usr/share/omarchy`, patří samotnému Omarchy a do těch byste neměli zasahovat. Pokud potřebujete cokoli změnit v `/usr/share/omarchy`, měli byste místo toho přepsat danou hodnotu v `~/.config`.

Klíčové konfigurace lze upravovat přímo z nabídky Omarchy (`Super + Space`), například _Setup > Keyboard > Keybindings_, _Setup > Input_ a _Setup > Config > [file]_. Když to uděláte tímto způsobem, každý proces, který je po úpravách konfigurace potřeba restartovat, se automaticky restartuje, jakmile editor zavřete (ve výchozím nastavení Neovim — `:wq`, pamatujte! — ten si ale můžete změnit přes _Setup > Defaults > Editor_).

Zde je seznam klíčových souborů v `~/.config` a toho, co ovládají:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hlavní konfigurace Hyprlandu. Načítá výchozí nastavení Omarchy plus vaše níže uvedené soubory s přepsáními. [Další informace o konfiguracích Hyprlandu](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vaše vlastní klávesové zkratky a přepsání výchozích. |
| `~/.config/hypr/monitors.lua` | Nastavení monitorů, která panel monitorů nepokrývá, například otočení, další režimy nebo ponechání monitoru vypnutého. |
| `~/.config/hypr/input.lua` | Ovládá rozložení klávesnice a nastavení myši a trackpadu. |
| `~/.config/hypr/looknfeel.lua` | Ovládá mezery, okraje, animace a zbytek vzhledu. |
| `~/.config/hypr/autostart.lua` | Ovládá další procesy spouštěné spolu s relací. |
| `~/.config/omarchy/shell.json` | Ovládá shell Omarchy: polohu lišty, rozložení a widgety plus časování spořiče obrazovky, zámku a nečinnosti. |
| `~/.config/foot/foot.ini` | Ovládá váš terminál (ve výchozím nastavení je to foot). |
| `~/.XCompose` | Definuje vaše emoji pro rychlý přístup a automatické doplňování jména/e-mailu. Po provedení změn nezapomeňte spustit `omarchy-restart-xcompose`. |

Pokud nakonec provedete spoustu změn, abyste si vlastní nastavení vyladili, je dobré si všechny tyto dotfiles zálohovat. [Stow je skvělý způsob, jak to udělat](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Spouštění vlastních aplikací spolu s relací

Pokud chcete, aby se něco spouštělo při každém přihlášení — synchronizační démon, chatovací aplikace, váš vlastní skript — vložte to do `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Tím se příkaz spustí jako součást relace, takže se při opětovném odhlášení řádně ukončí.

### Spouštění skriptů při systémových událostech

Omarchy v několika okamžicích spouští hooky a můžete na ně navěsit své vlastní skripty. Nacházejí se v `~/.config/omarchy/hooks/<event>.d/`, pro každou událost jeden adresář, a každý spustitelný soubor v něm se spustí, když k dané události dojde:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Hned po spuštění desktopu |
| `post-update` | Ke konci `omarchy update`, po balíčcích, migracích a restartech služeb, předtím, než se aktualizují nástroje mise |
| `pre-refresh-pacman` | Poté, co `omarchy refresh pacman` znovu synchronizuje konfiguraci balíčků, předtím, než balíčky aktualizuje; přepnutí kanálu ho spustí během téhož kroku obnovení |
| `theme-set` | Po změně motivu (název motivu v `$1`) |
| `font-set` | Po změně písma (název písma v `$1`) |
| `battery-low` | Když je baterie téměř vybitá (procento v `$1`) |

Právě do hooku `pre-refresh-pacman` patří vlastní repozitáře nebo řádky `IgnorePkg`, protože se spouští před transakcí balíčků. Oba hooky související s aktualizací běží pod vaším uživatelem poté, co Omarchy vymaže svou uloženou autorizaci sudo, takže hook, který používá `sudo`, potřebuje vlastní autorizaci a může vás požádat o heslo.

Každý z těchto adresářů už obsahuje soubor `.sample`, který ukazuje podobu hooku — abyste ho uvedli do provozu, odstraňte z názvu `.sample`. K instalaci skriptu, který jste napsali jinde, použijte `omarchy hook install post-boot ~/my-hook`, což ho zkopíruje dovnitř a nastaví ho jako spustitelný.

### Přidávání vlastních položek nabídky

Nabídku Omarchy (`Super + Space`) lze rozšířit o vlastní řádky úpravou `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Položky jsou klíčovány tečkovým id a právě toto id je umisťuje do stromu, takže `personal` se zobrazí v kořenové nabídce a `personal.notes` se zobrazí uvnitř ní:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Když znovu použijete existující id, přepíšete daný řádek, místo abyste přidali nový. Soubor se dodává se všemi dostupnými poli zdokumentovanými jako komentáře.

### Přidávání vlastních exportů shellu, funkcí a aliasů

Omarchy se dodává se spoustou ergonomických aliasů a užitečných funkcí, ale je velmi běžné, že si chcete přidat vlastní. Aliasy, funkce i exporty byste měli přidávat do `~/.bashrc`. Tento soubor nebude při aktualizacích přepsán. Pokud chcete změnit kterékoli z výchozích nastavení Omarchy, můžete je sem také bezpečně přidat.

### Nastavování proměnných prostředí pro desktop

Exporty relace desktopu patří do `~/.config/uwsm/env.d/`. Tyto soubory se spouštějí před spuštěním vašeho desktopu, takže chyba shellu vás může poslat zpět na přihlašovací obrazovku. Při jejich úpravách mějte otevřený funkční terminál. Chcete-li přepsání zakázat, přesuňte ho mimo `env.d`. Pokud změna zabrání přihlášení, podívejte se na [obnovení přihlášení](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen).

### Změna interních souborů Omarchy

Podívejte, je to váš počítač. Můžete si s ním dělat, co chcete, ale doporučoval bych vám nedělat změny přímo v souborech v `/usr/share/omarchy`. Patří do balíčku Omarchy pro pacman, takže vaše změny se při příští aktualizaci jednoduše přepíší. Mnohem lépe uděláte, když jakékoli výchozí hodnoty, které se vám nelíbí, přepíšete místo toho ve složce `~/.config/*`.

Tímto způsobem můžete změnit téměř cokoli, třeba výchozí klávesové zkratky. Stačí upravit `~/.config/hypr/bindings.lua` a třeba nahradit [Obsidian](https://obsidian.md/) aplikací [Joplin](https://joplinapp.org/) (nainstalujete pomocí `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` odstraní existující vazbu před přidáním její náhrady. Přijímá stejné argumenty jako `o.bind`, včetně pomocníků pro spouštění a možností vazby. Pomocí `o.bind` vazbu přidáte, pomocí `hl.unbind` ji odstraníte bez náhrady.

Pokud trváte na hackování interních souborů Omarchy, přepněte se na dev kanál přes _Update > Channel > Dev_. Tím se Omarchy propojí s git checkoutem zdrojového kódu v `~/omarchy`, který můžete měnit dle libosti. Nikdo tu není od toho, aby vám říkal, co máte dělat!

### Resetování všech změn

Pokud nakonec konfigurace pořádně zpackáte, můžete je vždy vrátit do výchozího stavu přes _Update > Config_ v nabídce Omarchy. Nebo spuštěním `omarchy reinstall configs`, čímž resetujete všechno.
