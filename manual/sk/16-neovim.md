# Neovim

[Neovim](https://neovim.io/) je moderná implementácia [editora vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>), ktorý vytvoril Bill Joy ešte v roku 1976. Je to modálny editor, v ktorom sú režim vkladania a príkazový režim oddelené, a keď sa naučíš čo i len časť jeho neuveriteľne bohatej sady klávesových príkazov, je to tak trochu superschopnosť. Ale treba sa aj poriadne učiť!

Ak si vo vim-štýle úprav úplný nováčik, odporúčam ti pozrieť si na YouTube sériu [ThePrimeagen's Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R). Tá ťa naučí základy. Len počítaj s tým, že na rozdiel od podobnejších mainstreamových editorov ti bude dlhšie trvať, kým získaš základnú zručnosť vo vime. Keď sa ti to však podarí, odmena je tiež väčšia.

Neovim sa dá konfigurovať prakticky donekonečna. Ak sa chceš naozaj odviazať, môžeš si vytvoriť vlastnú konfiguráciu Neovimu úplne od nuly. Skvelý kurz o nastavení Neovimu od nuly má [Typecraft](https://www.youtube.com/watch?v=zHTeCSVAFNY). A [ThePrimeagen má tiež jeden](https://www.youtube.com/watch?v=w7i4amO_zaE).

Omarchy však prichádza s kompletným nastavením Neovimu — balíkom `omarchy-nvim` — ktoré bolo s láskou vyladené tak, aby hneď po vybalení ukázalo to najlepšie, čo je možné. Bez toho, aby si musel napísať jediný riadok konfigurácie! Je postavené na [LazyVim](https://www.lazyvim.org/), distribúcii pluginov a konfigurácií pre Neovim. Je to skvelé.

## Základy LazyVim

Ako som už spomenul, v tomto krátkom úvode ťa nebudem učiť vim, ale môžem ti ukázať pár základov LazyVim a ako sa v ňom pohybovať.

Neovim má najprv koncept klávesy leader. Tá je v podstate vstupnou bránou ku všetkým príkazom. LazyVim ju má nastavenú na `Space`. Takže ju len stlač, chvíľu počkaj a uvidíš kopu možností vysvetlených priamo na mieste takto:

Tu je niekoľko základných príkazov, ktoré používam stále:

- `Space Space` - Fuzzy vyhľadávanie ľubovoľného súboru v aktuálnom adresári.
- `Space S G` - Vyhľadávanie vo všetkých súboroch pomocou grep aj s náhľadom.
- `Space E` - Zapnutie/vypnutie stromu súborov.
- `Ctrl + W W` - Prechod zo stromu súborov do editora a späť.
- `Shift + H` - Posun doľava medzi otvorenými kartami (vim ich nazýva buffery).
- `Shift + L` - Posun doprava medzi otvorenými kartami.
- `Space B D` - Zatvorenie karty.
- `Space B O` - Zatvorenie všetkých ostatných kariet okrem aktuálnej.
- `Space G G` - Spustenie LazyGit v plávajúcom paneli z aktuálneho adresára.
- `Space U W` - Prepnutie mäkkého zalamovania riadkov.

Keď si v strome súborov (`Space E` na jeho zobrazenie, `Ctrl + W W` na prechod tam), môžeš pridať nový súbor pomocou `a` alebo nový adresár pomocou `A`. Stlačením `?` v strome zobrazíš všetky príkazy.

Ak si chceš osvojiť základný jazyk vimu, písal som o [trojdielnej syntaxi](https://world.hey.com/dhh/wonderful-vi-a1d034d3) a o tom, ako predvádzať tie choré kombá!

Všetky možné príkazy si môžeš pozrieť na [stránke LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Spustenie Neovimu

`Super + Shift + N` spustí tvoj predvolený editor, ktorým je pri nových inštaláciách Plain; ak chceš, aby sa namiesto neho spúšťal Neovim, vyber Neovim v časti _Setup > Defaults > Editor_. Zvyčajne je však jednoduchšie ovládať ho z terminálu tak, že prejdeš do adresára, v ktorom chceš pracovať, a napíšeš `n`. `n` je alias pre `nvim`, ktorý predvolene otvorí aktuálny adresár. Jednotlivý súbor otvoríš pomocou `n myfile.txt`.

## Používanie Neovimu na úpravy so sudo

Ak potrebuješ upraviť súbory, ktoré môžeš meniť len ako superpoužívateľ, spusti `sudoedit /etc/sudoers.d/00-sudo-only-file`. Otvorí tvoj predvolený editor, takže ak ho tam chceš mať so všetkými svojimi pluginmi, nastav Neovim v časti _Setup > Defaults > Editor_.
