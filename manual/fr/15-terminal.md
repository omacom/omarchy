# Terminal

[Foot](https://codeberg.org/dnkl/foot) est le terminal par défaut d'Omarchy. Il est rapide, léger et compatible même avec les vieux ordinateurs. Il ne prend cependant pas en charge les onglets ou les divisions natifs.

Si vous utilisez Tmux, cela ne vous dérangera peut-être pas, mais sinon, nous prenons aussi pleinement en charge _Alacritty_, _Ghostty_ et _Kitty_ comme options. Choisissez votre préférence sous _Installer > Terminal_ dans le menu Omarchy.

Vous démarrez un nouveau terminal avec `Super + Return`. (Ce raccourci pointera automatiquement vers le terminal que vous avez installé via _Installer > Terminal_, et vous pouvez basculer entre les terminaux installés sous _Configuration > Par défaut > Terminal_.)

## Tmux

Tmux fournit une interface cohérente et programmable pour les panneaux, les fenêtres (alias onglets) et les sessions reprenables, quel que soit votre terminal. Il fonctionne même sur des hôtes distants, de sorte que lorsque vous vous connectez en SSH à un serveur, vous pouvez utiliser la même approche.

Vous démarrez une nouvelle session Tmux dans un nouveau terminal avec `Super + Alt + Return`, et comme Tmux est un processus persistant, vous pouvez reprendre votre session même si vous fermez ce terminal. Faites simplement `Ctrl + Space` (appelée touche préfixe) puis `s` pour voir toutes vos sessions actives.

Omarchy est livré avec une configuration Tmux optimisée pour l'ergonomie, qui comporte beaucoup de raccourcis à apprendre, alors gardez [l'antisèche à portée de main](07-hotkeys.md#tmux).

## Fonctions de disposition Tmux

Comme Tmux est programmable, nous pouvons utiliser des fonctions pour créer des dispositions. Omarchy est livré avec quatre fonctions différentes pour les dispositions de développement courantes.

`tdl [agent]` démarre une interface en trois parties de type IDE avec `$EDITOR` à gauche, l'agent IA de votre choix à droite (comme `c` pour opencode ou `cx` pour Claude ou `codex` pour OpenAI), puis un terminal en bas.

Ainsi, `tdl c` démarrerait ceci (ou simplement `ic`) :

 ![tmux-tdl](images/tmux-tdl.webp)

Vous pouvez aussi démarrer un deuxième agent avec `tdl c cx` (opencode + claude) (ou simplement `icx`) :

 ![tmux-tdl2](images/tmux-tdl2.webp)

Il y a aussi `tds`, qui démarre un carré en quatre parties avec l'éditeur en haut à gauche, un surveillant de diff en direct en haut à droite, un terminal en bas à gauche, et opencode en bas à droite.

Vous pouvez aussi démarrer cette configuration de disposition pour chaque sous-répertoire du répertoire courant avec `tdlm [agent]`, puis naviguer avec `alt + 1/2/3/4/5/...` :

 ![tmux-tdlm](images/tmux-tdlm.webp)

Enfin, vous pouvez démarrer un essaim d'agents avec `tsl [panes] [command]`. Ainsi, `tsl 4 c` vous donnera une grille en quatre parties d'agents opencode :

 ![tmux-tsl](images/tmux-tsl.webp)
