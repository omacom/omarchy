# Neovim

[Neovim](https://neovim.io/) és una implementació moderna de [l'editor vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) creat per Bill Joy ja l'any 1976. És un editor modal on el mode d'inserció i el mode d'ordres estan separats, i és una mena de superpoder un cop n'aprens ni que sigui només un subconjunt del conjunt d'ordres de tecles increïblement profund. Però també té una bona corba d'aprenentatge!

Si ets totalment nou en l'edició a l'estil vim, et recomano que facis una ullada a la sèrie [Vim As Your Editor de ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) a YouTube. Això t'ensenyarà els fonaments. Només cal que sàpigues que, a diferència d'altres editors convencionals més semblants, trigaràs més a assolir una competència bàsica amb vim. Però un cop ho aconsegueixis, la recompensa també és més gran.

Ara bé, Neovim és bàsicament infinitament configurable. Si realment vols embogir, pots crear la teva pròpia configuració de Neovim des de zero. Hi ha un curs fantàstic de [Typecraft sobre com configurar Neovim des de zero](https://www.youtube.com/watch?v=zHTeCSVAFNY). I [ThePrimeagen en té un també](https://www.youtube.com/watch?v=w7i4amO_zaE).

Però Omarchy inclou una configuració completa de Neovim — el paquet `omarchy-nvim` — que s'ha ajustat amb estima per mostrar el millor del que és possible de fàbrica. Sense que hagis d'escriure ni una sola línia de configuració! Està construït sobre [LazyVim](https://www.lazyvim.org/), una distribució de connectors i configuracions de Neovim. És fantàstic.

## Fonaments de LazyVim

Com he dit, no t'ensenyaré vim en aquesta breu introducció, però et puc mostrar alguns fonaments de LazyVim i com moure-t'hi.

Primer, Neovim té el concepte de la tecla líder. És bàsicament la porta d'entrada a totes les ordres. LazyVim l'ha establerta a `Space`. Així que només has de prémer-la, esperar un segon, i veuràs un munt d'opcions explicades en línia així:

Aquí tens algunes ordres bàsiques que faig servir tot el temps:

- `Space Space` - Cerca difusa de qualsevol fitxer del directori actual.
- `Space S G` - Cerca a tots els fitxers amb grep i una vista prèvia.
- `Space E` - Mostra/amaga l'arbre de fitxers.
- `Ctrl + W W` - Salta de l'arbre de fitxers a l'editor i viceversa.
- `Shift + H` - Ves a l'esquerra entre les pestanyes obertes (vim les anomena buffers).
- `Shift + L` - Ves a la dreta entre les pestanyes obertes.
- `Space B D` - Tanca una pestanya.
- `Space B O` - Tanca totes les altres pestanyes excepte l'actual.
- `Space G G` - Obre LazyGit en un panell flotant des del directori actual.
- `Space U W` - Activa/desactiva l'ajust suau de línia.

Mentre ets a l'arbre de fitxers (`Space E` per mostrar-lo, `Ctrl + W W` per saltar-hi), pots afegir un fitxer nou amb `a` o un directori nou amb `A`. Prem `?` mentre ets a l'arbre per veure totes les ordres.

Si vols aprendre el llenguatge bàsic de vim, he escrit sobre [la sintaxi de tres parts](https://world.hey.com/dhh/wonderful-vi-a1d034d3) i sobre com fer aquests moviments combinats tan espectaculars!

Pots veure totes les ordres possibles a [la pàgina de dreceres de teclat de LazyVim](https://www.lazyvim.org/keymaps).

## Com iniciar Neovim

`Super + Shift + N` obre l'editor predeterminat, que és Plain a les instal·lacions noves; tria Neovim a _Setup > Defaults > Editor_ perquè obri Neovim en lloc seu. Però normalment és més fàcil fer-ho des del terminal, anant al directori on vols treballar i escrivint `n`. La `n` és l'àlies de `nvim`, que per defecte obrirà el directori actual. Pots obrir un sol fitxer amb `n myfile.txt`.

## Com utilitzar Neovim per a edicions amb sudo

Si has d'editar fitxers que només pots canviar com a superusuari, executa `sudoedit /etc/sudoers.d/00-sudo-only-file`. Obre l'editor predeterminat, així que estableix Neovim a _Setup > Defaults > Editor_ si el vols allà amb tots els teus connectors.
