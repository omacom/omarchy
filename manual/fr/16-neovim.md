# Neovim

[Neovim](https://neovim.io/) est une implémentation moderne de [l'éditeur vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) créé par Bill Joy dès 1976. C'est un éditeur modal où le mode insertion et le mode commande sont séparés, et c'est un peu un super-pouvoir une fois que vous avez appris ne serait-ce qu'un sous-ensemble de cet ensemble de commandes clavier incroyablement riche. Mais la courbe d'apprentissage est aussi sacrément raide !

Si vous débutez complètement avec l'édition de style vim, je vous recommande de regarder [la série Vim As Your Editor de ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) sur YouTube. Elle vous apprendra les bases. Sachez simplement que, contrairement aux éditeurs grand public plus familiers, il vous faudra plus de temps pour acquérir une maîtrise de base avec vim. Mais une fois que ce sera fait, la récompense sera aussi plus grande.

Neovim est en fait configurable à l'infini. Si vous voulez vraiment devenir fou, vous pouvez créer votre propre configuration Neovim de zéro. Il y a un excellent cours de [Typecraft sur la configuration de Neovim de zéro](https://www.youtube.com/watch?v=zHTeCSVAFNY). Et [ThePrimeagen en propose un aussi](https://www.youtube.com/watch?v=w7i4amO_zaE).

Mais Omarchy est livré avec une configuration Neovim complète — le paquet `omarchy-nvim` — qui a été réglée avec amour pour montrer le meilleur de ce qui est possible dès l'installation. Sans que vous ayez à écrire une seule ligne de configuration ! Elle est construite sur [LazyVim](https://www.lazyvim.org/), une distribution de plugins et de configurations Neovim. C'est génial.

## Les bases de LazyVim

Comme je l'ai dit, je ne vais pas vous apprendre vim dans cette courte introduction, mais je peux vous montrer quelques bases de LazyVim, et comment vous y retrouver.

D'abord, Neovim a le concept de touche leader. C'est en fait la porte d'entrée vers toutes les commandes. LazyVim l'a définie sur `Space`. Appuyez simplement dessus, attendez une seconde, et vous verrez un tas d'options expliquées directement à l'écran, comme ceci :

Voici quelques commandes de base que j'utilise tout le temps :

- `Space Space` - Rechercher de façon floue n'importe quel fichier dans le répertoire courant.
- `Space S G` - Rechercher dans tous les fichiers avec grep et un aperçu.
- `Space E` - Afficher/masquer l'arborescence de fichiers.
- `Ctrl + W W` - Passer de l'arborescence de fichiers à l'éditeur et inversement.
- `Shift + H` - Aller à gauche entre les onglets ouverts (vim les appelle des buffers).
- `Shift + L` - Aller à droite entre les onglets ouverts.
- `Space B D` - Fermer un onglet.
- `Space B O` - Fermer tous les autres onglets sauf l'actuel.
- `Space G G` - Lancer LazyGit dans un panneau flottant depuis le répertoire courant.
- `Space U W` - Activer/désactiver le retour à la ligne souple.

Quand vous êtes dans l'arborescence de fichiers (`Space E` pour l'afficher, `Ctrl + W W` pour y aller), vous pouvez ajouter un nouveau fichier avec `a` ou un nouveau répertoire avec `A`. Appuyez sur `?` quand vous êtes dans l'arborescence pour voir toutes les commandes.

Si vous voulez apprendre le langage vim de base, j'ai écrit sur [la syntaxe en trois parties](https://world.hey.com/dhh/wonderful-vi-a1d034d3) et sur la façon de réaliser ces combos de folie !

Vous pouvez voir toutes les commandes possibles sur [la page Keymaps de LazyVim](https://www.lazyvim.org/keymaps).

## Démarrer Neovim

`Super + Shift + N` lance votre éditeur par défaut, qui est Plain sur les nouvelles installations ; choisissez Neovim sous _Setup > Defaults > Editor_ pour qu'il lance Neovim à la place. Mais il est généralement plus facile de le piloter depuis le terminal en naviguant jusqu'au répertoire dans lequel vous voulez travailler et en tapant `n`. Le `n` est l'alias de `nvim`, qui utilisera le répertoire actuel pour s'ouvrir par défaut. Vous pouvez ouvrir un seul fichier avec `n myfile.txt`.

## Utiliser Neovim pour les modifications sudo

Si vous devez modifier des fichiers que vous ne pouvez changer qu'en tant que super-utilisateur, exécutez `sudoedit /etc/sudoers.d/00-sudo-only-file`. Cela ouvre votre éditeur par défaut, alors définissez Neovim sous _Setup > Defaults > Editor_ si vous voulez l'y retrouver avec tous vos plugins.
