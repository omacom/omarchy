# Neovim

[Neovim](https://neovim.io/) je moderní implementace [editoru vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) vytvořeného Billem Joyem už v roce 1976. Je to modální editor, kde jsou režim vkládání a příkazový režim oddělené, a jakmile se naučíte byť jen část jeho neuvěřitelně hluboké sady klávesových příkazů, stane se z něj skutečná superschopnost. Počítejte ale s tím, že naučit se ho ovládat zabere čas!

Pokud jste v úpravách ve stylu vimu úplně noví, doporučuji podívat se na [sérii ThePrimeagen Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) na YouTube. Ta vás naučí základy. Jen vězte, že na rozdíl od běžnějších editorů vám bude trvat déle, než získáte základní zběhlost ve vimu. Ale jakmile ji získáte, odměna je také větší.

Neovim je v zásadě nekonečně konfigurovatelný. Pokud se opravdu chcete odvázat, můžete si vytvořit vlastní konfiguraci Neovimu od nuly. Existuje skvělý kurz od [Typecraft o nastavení Neovimu od nuly](https://www.youtube.com/watch?v=zHTeCSVAFNY). A [ThePrimeagen má také jeden](https://www.youtube.com/watch?v=w7i4amO_zaE).

Ale Omarchy se dodává s kompletním nastavením Neovimu — balíčkem `omarchy-nvim` — které bylo s láskou vyladěno tak, aby ukázalo to nejlepší z možného hned po vybalení. Aniž byste museli napsat jediný řádek konfigurace! Je postaveno na [LazyVim](https://www.lazyvim.org/), distribuci pluginů a konfigurací Neovimu. Je to úžasné.

## Základy LazyVimu

Jak jsem zmínil, nebudu vás v tomto krátkém úvodu učit vim, ale mohu vám ukázat pár základů LazyVimu a jak se v něm pohybovat.

Neovim především používá koncept klávesy leader. To je v zásadě brána ke všem příkazům. LazyVim ji nastavil na `Space`. Takže ji prostě stiskněte, chvíli počkejte a uvidíte spoustu možností vysvětlených přímo na místě takto:

Tady je pár základních příkazů, které používám pořád:

- `Space Space` - Fuzzy-vyhledání jakéhokoli souboru v aktuálním adresáři.
- `Space S G` - Prohledání všech souborů pomocí grepu s náhledem.
- `Space E` - Zobrazení/skrytí stromu souborů.
- `Ctrl + W W` - Přeskakování mezi stromem souborů a editorem.
- `Shift + H` - Pohyb doleva mezi otevřenými kartami (vim jim říká buffery).
- `Shift + L` - Pohyb doprava mezi otevřenými kartami.
- `Space B D` - Zavření karty.
- `Space B O` - Zavření všech ostatních karet kromě aktuální.
- `Space G G` - Spuštění LazyGit v plovoucím okně z aktuálního adresáře.
- `Space U W` - Přepnutí měkkého zalamování.

Zatímco jste ve stromu souborů (`Space E` pro zobrazení, `Ctrl + W W` pro přeskočení tam), můžete přidat nový soubor pomocí `a` nebo nový adresář pomocí `A`. Ve stromu stiskněte `?` a uvidíte všechny příkazy.

Pokud si chcete osvojit základní jazyk vimu, napsal jsem o [třídílné syntaxi](https://world.hey.com/dhh/wonderful-vi-a1d034d3) a o tom, jak provádět ty skvělé kombinované pohyby!

Všechny možné příkazy najdete na [stránce LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Spouštění Neovimu

Neovim můžete spustit pomocí `Super + Shift + N` (zkratka spouští váš výchozí editor, kterým je hned po vybalení Neovim), ale obvykle je jednodušší ovládat ho z terminálu tím, že přejdete do adresáře, ve kterém chcete pracovat, a napíšete `n`. `n` je alias pro `nvim`, který ve výchozím nastavení použije k otevření aktuální adresář. Jeden soubor můžete otevřít pomocí `n myfile.txt`.

## Používání Neovimu pro úpravy přes sudo

Pokud potřebujete upravit soubory, které můžete měnit pouze jako superuživatel, můžete použít neovim se všemi svými nastavenými pluginy spuštěním `sudoedit /etc/sudoers.d/00-sudo-only-file`.
