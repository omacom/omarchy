# Neovim

[Neovim](https://neovim.io/) je moderná implementácia [editora vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) vytvorená Billom Joyom ešte v roku 1976. Je to modálny editor, v ktorom sú režim vkladania a príkazový režim oddelené, a je to akási superschopnosť, keď sa naučíte čo i len podmnožinu neuveriteľne hlbokej sady klávesových príkazov. Ale je to aj poriadna krivka učenia!

Ak ste v editovaní vo vim štýle úplne noví, odporúčam vám pozrieť si sériu [Vim As Your Editor od ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) na YouTube. To vás naučí základy. Len vedzte, že na rozdiel od podobnejších mainstreamových editorov vám bude trvať dlhšie, kým vo vim dosiahnete základnú zručnosť. Ale keď ju dosiahnete, odmena je tiež väčšia.

Neovim je teraz v podstate nekonečne konfigurovateľný. Ak sa chcete skutočne odviazať, môžete si vytvoriť vlastnú konfiguráciu Neovim od nuly. Existuje skvelý kurz od [Typecraft o nastavení Neovim od nuly](https://www.youtube.com/watch?v=zHTeCSVAFNY). A [ThePrimeagen má tiež jeden](https://www.youtube.com/watch?v=w7i4amO_zaE).

Ale Omarchy sa dodáva s kompletným nastavením Neovimu — balíčkom `omarchy-nvim` — ktoré bolo starostlivo doladené, aby ukázalo to najlepšie z toho, čo je možné hneď po vybalení. Bez toho, aby ste museli napísať jediný riadok konfigurácie! Je postavené na [LazyVim](https://www.lazyvim.org/), distribúcii pluginov a konfigurácií Neovimu. Je to super.

## Základy LazyVim

Ako už bolo spomenuté, v tomto krátkom úvode vás nebudem učiť vim, ale môžem vám ukázať niekoľko základov LazyVim a ako sa v ňom pohybovať.

Najskôr má Neovim predstavu lídrového klávesu. To je v podstate brána ku všetkým príkazom. LazyVim ho nastavil na `Space`. Takže stačí stlačiť to, chvíľku počkať a uvidíte hromadu možností vysvetlených v riadku takto:

Tu je niekoľko základných príkazov, ktoré používam stále:

- `Space Space` - Fuzzy vyhľadávanie ľubovoľného súboru v aktuálnom adresári.
- `Space S G` - Vyhľadávanie vo všetkých súboroch pomocou grep s ukážkou.
- `Space E` - Prepnutie stromu súborov zap./vyp.
- `Ctrl + W W` - Skok zo stromu súborov do editora a späť.
- `Shift + H` - Posun doľava medzi otvorenými kartami (vim ich nazýva buffery).
- `Shift + L` - Posun doprava medzi otvorenými kartami.
- `Space B D` - Zatvoriť kartu.
- `Space B O` - Zatvoriť všetky ostatné karty okrem aktuálnej.
- `Space G G` - Spustiť LazyGit v plávajúcom paneli z aktuálneho adresára.
- `Space U W` - Prepnúť mäkké zalamovanie.

Kým ste v strome súborov (`Space E` na odhalenie, `Ctrl + W W` na skok tam), môžete pridať nový súbor pomocou `a` alebo nový adresár pomocou `A`. Stlačte `?` v strome, aby ste videli všetky príkazy.

Ak si chcete osvojiť základný jazyk vim, písal som o [trojdielnej syntaxi](https://world.hey.com/dhh/wonderful-vi-a1d034d3) a ako predviesť tie skvelé kombinované pohyby!

Všetky možné príkazy nájdete na [stránke LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Spustenie Neovimu

Neovim môžete spustiť pomocou `Super + Shift + N` (väzba spúšťa váš predvolený editor, ktorým je hneď po vybalení Neovim), ale zvyčajne je jednoduchšie riadiť ho z terminálu navigáciou do adresára, v ktorom chcete pracovať, a napísaním `n`. `n` je alias pre `nvim`, ktoré predvolene použije na otvorenie aktuálny adresár. Jednotlivý súbor môžete otvoriť pomocou `n myfile.txt`.

## Používanie Neovimu na úpravy so sudo

Ak potrebujete upraviť súbory, ktoré môžete zmeniť len ako superpoužívateľ, môžete použiť neovim so všetkými nastavenými pluginmi spustením `sudoedit /etc/sudoers.d/00-sudo-only-file`.
