# Nástroje shellu

Kromě standardních nástrojů Linuxu je Omarchy dodávána také s řadou vylepšených nástrojů shellu. Tady jsou ty klíčové.

## fzf

[fzf](https://junegunn.github.io/fzf/) vám poskytuje fuzzy vyhledávání souborů prostřednictvím aliasu `ff`. Přejděte do libovolného adresáře, zadejte `ff` a budete moci fuzzy vyhledáváním dojít k libovolnému souboru v tomto stromu a zároveň na pravé straně uvidíte náhled souborů, mezi nimiž zužujete výběr.

Pomocí `Ctrl + R` můžete využít fzf k fuzzy vyhledávání v historii příkazů.

Tento nástroj používá také Neovim, když zadáte `Space Space`.

Úplnou příručku najdete prostřednictvím příkazu `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) je náhradou za cd. Pamatuje si adresáře, ve kterých jste byli, takže příště do nich můžete snáze přejít. Řekněme, že jednou provedete příkaz `cd ~/.config/omarchy`. Příště můžete jednoduše provést `cd omarchy` (nebo dokonce jen `cd oma`) a Zoxide vás tam přímo přesune.

Úplnou příručku najdete prostřednictvím příkazu `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) prohledává obsah souborů pomocí příkazu `rg <pattern> <path>`, například `rg Controller app/` vyhledá všechny výskyty slova `Controller` v adresáři app.

Tento nástroj používá také Neovim, když zadáte `Space S G`.

Úplnou příručku najdete prostřednictvím příkazu `man rg`.

## eza

[eza](https://eza.rocks/) je náhradou za ls. Poskytuje výpisy adresářů s více informacemi, barvami a ikonami. Ve výchozím nastavení je eza aliasováno jako ls. Můžete také použít příkaz `lt` k získání výpisu dvou úrovní vnoření. Příkaz `lsa` vám poskytne výpis včetně skrytých souborů. A `lta` vnořený výpis se skrytými soubory.

Úplnou příručku najdete prostřednictvím příkazu `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) je snadněji použitelná náhrada za příkaz `find`. Příkaz `fd person.rb` použijte k vyhledání souboru s názvem `person.rb` v aktuálním stromu. Příkaz `fd person.rb /` prohledá celý souborový systém. Příkaz `fd person.rb / -H` prohledá celý souborový systém včetně skrytých adresářů.

Úplnou příručku najdete prostřednictvím příkazu `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) je `cat` se zvýrazněním syntaxe, čísly řádků a stránkováním. Spusťte příkaz `bat somefile.rb` a uvidíte, proč je těžké se vrátit zpět. Nenápadně pro vás pracuje i jinde: barví vaše manuálové stránky a vykresluje náhledy v příkazu `ff`.

Úplnou příručku najdete prostřednictvím příkazu `man bat`.

## tldr

[tldr](https://tldr.sh/) je protilék na manuálové stránky, které začínají třemi obrazovkami historie, než vám ukážou jediný příklad. Příkaz `tldr tar` vám poskytne tu hrstku způsobů spuštění, které jste skutečně chtěli.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) stahuje videa z YouTube a stovek dalších webů. Příkaz `yt-dlp <url>` stáhne nejlepší dostupnou kvalitu do aktuálního adresáře.

Úplnou příručku najdete prostřednictvím příkazu `man yt-dlp`.

## try

[try](https://github.com/tobi/try) usnadňuje správu programovacích experimentů pomocí adresářů s datovým razítkem. Všechny experimenty žijí v adresáři `~/Work/tries` a můžete k nim přistupovat prostřednictvím příkazu `try`.

Omarchy nepřidává adresář `bin/` projektu do proměnné `PATH` automaticky. Důvěryhodné nástroje místní pro projekt spouštějte explicitní relativní cestou, například `bin/rails` nebo `./bin/dev`.
