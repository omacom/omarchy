# Neovim

[Neovim](https://neovim.io/) est une implémentation moderne de [l'éditeur vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) créé par Bill Joy dès 1976. C'est un éditeur modal où le mode insertion et le mode commande sont séparés, et c'est un peu un super-pouvoir une fois que vous apprenez ne serait-ce qu'un sous-ensemble de son incroyablement profond ensemble de commandes clavier. Mais la courbe d'apprentissage est aussi réelle !

Si vous êtes totalement nouveau à l'édition de style vim, je vous recommande de regarder [la série Vim As Your Editor de ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) sur YouTube. Cela vous enseignera les bases. Sachez simplement que, contrairement aux éditeurs grand public plus similaires, il vous faudra plus de temps pour acquérir une maîtrise de base avec vim. Mais une fois que vous y serez, le bénéfice est aussi plus grand.

Neovim est pratiquement infiniment configurable. Si vous voulez vraiment y aller à fond, vous pouvez créer votre propre configuration Neovim à partir de zéro. Il existe un excellent cours de [Typecraft sur la configuration de Neovim à partir de zéro](https://www.youtube.com/watch?v=zHTeCSVAFNY). Et [ThePrimeagen en a un aussi](https://www.youtube.com/watch?v=w7i4amO_zaE).

Mais Omarchy est livré avec une configuration Neovim complète — le paquet `omarchy-nvim` — qui a été amoureusement réglée pour montrer le meilleur de ce qui est possible dès l'installation. Sans que vous ayez à écrire une seule ligne de configuration ! Elle est construite sur [LazyVim](https://www.lazyvim.org/), une distribution de plugins et de configurations Neovim. Elle est géniale.

## Bases de LazyVim

Comme mentionné, je ne vais pas vous apprendre vim dans cette courte introduction, mais je peux vous montrer quelques bases de LazyVim, et comment vous y repérer.

D'abord, Neovim a l'idée de la touche leader. C'est essentiellement la porte d'entrée vers toutes les commandes. LazyVim l'a définie sur `Space`. Appuyez simplement dessus, attendez une seconde, et vous verrez une série d'options expliquées en ligne comme ceci :

Voici quelques commandes de base que j'utilise tout le temps :

- `Space Space` - Recherche floue d'un fichier dans le répertoire courant.
- `Space S G` - Recherche dans tous les fichiers à l'aide de grep avec aperçu.
- `Space E` - Activer/désactiver l'arborescence de fichiers.
- `Ctrl + W W` - Passer de l'arborescence à l'éditeur et inversement.
- `Shift + H` - Passer à gauche entre les onglets ouverts (vim les appelle buffers).
- `Shift + L` - Passer à droite entre les onglets ouverts.
- `Space B D` - Fermer un onglet.
- `Space B O` - Fermer tous les autres onglets sauf l'actuel.
- `Space G G` - Lancer LazyGit dans un panneau flottant depuis le répertoire courant.
- `Space U W` - Activer/désactiver le retour à la ligne souple.

Pendant que vous êtes dans l'arborescence (`Space E` pour l'afficher, `Ctrl + W W` pour y passer), vous pouvez ajouter un nouveau fichier avec `a` ou un nouveau répertoire avec `A`. Appuyez sur `?` dans l'arborescence pour voir toutes les commandes.

Si vous voulez apprendre le langage vim de base, j'ai écrit sur [la syntaxe en trois parties](https://world.hey.com/dhh/wonderful-vi-a1d034d3) et comment réaliser ces super combos !

Vous pouvez voir toutes les commandes possibles sur [la page Keymaps de LazyVim](https://www.lazyvim.org/keymaps).

## Démarrer Neovim

Vous pouvez démarrer Neovim avec `Super + Shift + N` (le raccourci lance votre éditeur par défaut, qui est Neovim dès l'installation), mais il est généralement plus facile de le piloter depuis le terminal en naviguant vers le répertoire où vous souhaitez travailler et en tapant `n`. Le `n` est l'alias de `nvim`, qui utilisera par défaut le répertoire courant pour s'ouvrir. Vous pouvez ouvrir un seul fichier avec `n myfile.txt`.

## Utiliser Neovim pour les éditions sudo

Si vous devez éditer des fichiers que vous ne pouvez modifier qu'en tant que super-utilisateur, vous pouvez utiliser neovim avec toute votre configuration de plugins en exécutant `sudoedit /etc/sudoers.d/00-sudo-only-file`.
