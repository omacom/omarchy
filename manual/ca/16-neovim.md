# Neovim

[Neovim](https://neovim.io/) és una implementació moderna de [l'editor vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) creat per Bill Joy l'any 1976. És un editor modal on el mode d'inserció i el mode d'ordres estan separats, i és una mena de superpoder un cop n'apreneu només un subconjunt del conjunt d'ordres de teclat increïblement profund. Però també té una corba d'aprenentatge considerable!

Si sou completament nous en l'edició estil vim, us recomano que feu un cop d'ull a [ThePrimeagen's Vim As Your Editor series](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) a YouTube. Això us ensenyarà els fonaments. Sabeu simplement que, a diferència d'editors convencionals més semblants, trigareu més a assolir una competència bàsica amb vim. Però un cop ho feu, la recompensa també és més gran.

Ara bé, Neovim és bàsicament infinitament configurable. Si realment voleu tornar-vos bojos, podeu crear la vostra pròpia configuració de Neovim des de zero. Hi ha un curs fantàstic de [Typecraft on setting up Neovim from scratch](https://www.youtube.com/watch?v=zHTeCSVAFNY). I [ThePrimeagen també en té un](https://www.youtube.com/watch?v=w7i4amO_zaE).

Però Omarchy ve amb una configuració completa de Neovim — el paquet `omarchy-nvim` — que s'ha ajustat amb estima per mostrar el millor del que és possible de sèrie. Sense que hàgiu d'escriure ni una sola línia de configuració! Està construït sobre [LazyVim](https://www.lazyvim.org/), una distribució de complements i configuracions de Neovim. És impressionant.

## Fonaments de LazyVim

Com he esmentat, no us ensenyaré vim en aquesta breu introducció, però us puc mostrar alguns fonaments de LazyVim i com moure-us-hi.

Primer, Neovim té la idea de la tecla líder. Això és bàsicament la porta d'entrada a totes les ordres. LazyVim l'ha definida a `Space`. Així que només heu de prémer-la, esperar un segon i veureu un munt d'opcions explicades en línia així:

Aquí teniu algunes ordres bàsiques que faig servir sempre:

- `Space Space` - Cerca difusa de qualsevol fitxer del directori actual.
- `Space S G` - Cerca a tots els fitxers amb grep i amb previsualització.
- `Space E` - Commuta l'arbre de fitxers activat/desactivat.
- `Ctrl + W W` - Salta de l'arbre de fitxers a l'editor i torna.
- `Shift + H` - Mou-te a l'esquerra entre les pestanyes obertes (vim les anomena buffers).
- `Shift + L` - Mou-te a la dreta entre les pestanyes obertes.
- `Space B D` - Tanca una pestanya.
- `Space B O` - Tanca totes les altres pestanyes excepte l'actual.
- `Space G G` - Llança LazyGit en un panell flotant des del directori actual.
- `Space U W` - Commuta l'ajust suau de línia.

Mentre sou a l'arbre de fitxers (`Space E` per revelar-lo, `Ctrl + W W` per saltar-hi), podeu afegir un fitxer nou amb `a` o un directori nou amb `A`. Premeu `?` mentre sou a l'arbre per veure totes les ordres.

Si voleu aprendre el llenguatge bàsic de vim, he escrit sobre [la sintaxi de tres parts](https://world.hey.com/dhh/wonderful-vi-a1d034d3) i com fer aquests moviments combinats impressionants!

Podeu veure totes les ordres possibles a [la pàgina de dreceres de LazyVim](https://www.lazyvim.org/keymaps).

## Iniciar Neovim

Podeu iniciar Neovim amb `Super + Shift + N` (l'assignació llança l'editor per defecte, que és Neovim de sèrie), però normalment és més fàcil conduir-lo des del terminal navegant fins al directori en què voleu treballar i escrivint `n`. La `n` és l'àlies de `nvim`, que farà servir el directori actual per obrir per defecte. Podeu obrir un únic fitxer amb `n myfile.txt`.

## Fer servir Neovim per a edicions amb sudo

Si necessiteu editar fitxers que només podeu canviar com a superusuari, podeu fer servir neovim amb tots els vostres complements configurats executant `sudoedit /etc/sudoers.d/00-sudo-only-file`.
