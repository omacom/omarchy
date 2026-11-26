# Neovim

[Neovim](https://neovim.io/) je moderní implementace [editoru vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>), který vytvořil Bill Joy už v roce 1976. Je to modální editor, kde jsou oddělené režim vkládání a příkazový režim, a jakmile se naučíte byť jen část neuvěřitelně rozsáhlé sady klávesových příkazů, je to tak trochu superschopnost. Ale taky to má pořádnou křivku učení!

Pokud jste ve stylu úprav vim úplnými nováčky, doporučuji vám podívat se na sérii [ThePrimeagen's Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) na YouTube. Ta vás naučí základy. Jen vězte, že na rozdíl od podobnějších mainstreamových editorů vám bude trvat déle, než s vimem získáte základní zběhlost. Ale jakmile se to stane, odměna je taky větší.

Neovim je teď v podstatě nekonečně konfigurovatelný. Pokud se do toho chcete opravdu pustit naplno, můžete si vytvořit vlastní konfiguraci Neovimu úplně od nuly. Existuje skvělý kurz od [Typecraft o nastavení Neovimu od nuly](https://www.youtube.com/watch?v=zHTeCSVAFNY). A [ThePrimeagen má jeden taky](https://www.youtube.com/watch?v=w7i4amO_zaE).

Omarchy ale dodává kompletní nastavení Neovimu — balíček `omarchy-nvim` — které bylo s láskou vyladěno tak, aby hned po instalaci ukázalo to nejlepší z toho, co je možné. Aniž byste museli napsat jediný řádek konfigurace! Je postavené na [LazyVim](https://www.lazyvim.org/), distribuci pluginů a konfigurací pro Neovim. Je to skvělé.

## Základy LazyVim

Jak už jsem zmínil, v tomto krátkém úvodu vás nebudu učit vim, ale můžu vám ukázat pár základů LazyVim a jak se v něm pohybovat.

Neovim má nejprve myšlenku leader klávesy. To je v podstatě brána ke všem příkazům. LazyVim ji nastavil na `Space`. Takže ji prostě stiskněte, chvíli počkejte a uvidíte spoustu možností vysvětlených přímo v řádku takhle:

Tady je pár základních příkazů, které používám pořád:

- `Space Space` - Fuzzy-vyhledání libovolného souboru v aktuálním adresáři.
- `Space S G` - Prohledání všech souborů pomocí grep s náhledem.
- `Space E` - Přepnutí stromu souborů zap/vyp.
- `Ctrl + W W` - Přeskakování mezi stromem souborů a editorem tam a zpět.
- `Shift + H` - Přesun doleva mezi otevřenými kartami (vim jim říká buffery).
- `Shift + L` - Přesun doprava mezi otevřenými kartami.
- `Space B D` - Zavření karty.
- `Space B O` - Zavření všech ostatních karet kromě aktuální.
- `Space G G` - Spuštění LazyGit v plovoucím panelu z aktuálního adresáře.
- `Space U W` - Přepnutí měkkého zalamování.

Když jste ve stromu souborů (`Space E` pro zobrazení, `Ctrl + W W` pro přechod tam), můžete přidat nový soubor pomocí `a` nebo nový adresář pomocí `A`. Stisknutím `?` ve stromu zobrazíte všechny příkazy.

Pokud si chcete osvojit základní jazyk vimu, psal jsem o [třídílné syntaxi](https://world.hey.com/dhh/wonderful-vi-a1d034d3) a o tom, jak provádět ty husté kombinační tahy!

Všechny možné příkazy můžete vidět na [stránce LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Spuštění Neovimu

`Super + Shift + N` spustí váš výchozí editor, kterým je na nových instalacích Plain; zvolte Neovim v _Setup > Defaults > Editor_, aby místo toho spouštěl Neovim. Obvykle je ale snazší ovládat ho z terminálu tak, že přejdete do adresáře, ve kterém chcete pracovat, a napíšete `n`. `n` je alias pro `nvim`, který ve výchozím nastavení použije k otevření aktuální adresář. Jeden soubor můžete otevřít pomocí `n myfile.txt`.

## Použití Neovimu pro úpravy přes sudo

Pokud potřebujete upravit soubory, které můžete měnit pouze jako superuživatel, spusťte `sudoedit /etc/sudoers.d/00-sudo-only-file`. Otevře váš výchozí editor, takže si v _Setup > Defaults > Editor_ nastavte Neovim, pokud ho tam chcete mít se všemi svými pluginy.
