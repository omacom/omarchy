# Outils du shell

En plus des outils Linux standard, Omarchy est aussi livré avec plein d'outils de shell améliorés. Voici les principaux.

## fzf

[fzf](https://junegunn.github.io/fzf/) vous offre une recherche floue de fichiers via l'alias `ff`. Allez dans n'importe quel répertoire, tapez `ff`, et vous pourrez trouver par recherche floue n'importe quel fichier de cette arborescence, tout en voyant un aperçu des fichiers que vous affinez sur la droite.

Vous pouvez utiliser `Ctrl + R` pour utiliser fzf afin de chercher par recherche floue dans l'historique de vos commandes.

Cet outil est aussi utilisé par Neovim quand vous tapez `Space Space`.

Le manuel complet est accessible via `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) remplace cd. Il se souvient des répertoires où vous êtes allé, pour que vous puissiez y retourner plus facilement la fois suivante. Disons que vous faites `cd ~/.config/omarchy` une fois. La fois suivante, vous pouvez simplement faire `cd omarchy` (ou même juste `cd oma`), et Zoxide vous y emmène directement.

Le manuel complet est accessible via `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) recherche dans le contenu des fichiers en utilisant `rg <pattern> <path>`, comme `rg Controller app/` pour trouver toutes les mentions de `Controller` dans le répertoire app.

Cet outil est aussi utilisé par Neovim quand vous tapez `Space S G`.

Le manuel complet est accessible via `man rg`.

## eza

[eza](https://eza.rocks/) remplace ls. Il vous donne des listings de répertoires avec plus d'informations, des couleurs et des icônes. Par défaut, eza a été aliasé en ls. Vous pouvez aussi utiliser `lt` pour obtenir un listing sur deux niveaux d'imbrication. `lsa` vous donne un listing incluant les fichiers cachés. Et `lta` un listing imbriqué avec les fichiers cachés.

Le manuel complet est accessible via `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) est un remplacement de `find` plus facile à utiliser. Utilisez `fd person.rb` pour trouver un fichier appelé `person.rb` dans l'arborescence courante. `fd person.rb /` recherchera dans tout le système de fichiers. `fd person.rb / -H` recherche dans tout le système de fichiers, y compris les répertoires cachés.

Le manuel complet est accessible via `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) est `cat` avec coloration syntaxique, numéros de ligne et pagination. Lancez `bat somefile.rb` et vous comprendrez pourquoi il est difficile de revenir en arrière. Il travaille aussi discrètement pour vous ailleurs : c'est lui qui colore vos pages man, et qui rend les aperçus dans `ff`.

Le manuel complet est accessible via `man bat`.

## tldr

[tldr](https://tldr.sh/) est l'antidote aux pages man qui s'ouvrent sur trois écrans d'historique avant de vous montrer le moindre exemple. `tldr tar` vous donne la poignée d'invocations que vous vouliez vraiment.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) télécharge des vidéos depuis YouTube et des centaines d'autres sites. `yt-dlp <url>` récupère la meilleure qualité disponible dans le répertoire courant.

Le manuel complet est accessible via `man yt-dlp`.

## try

[try](https://github.com/tobi/try) facilite la gestion d'expérimentations de programmation avec des répertoires horodatés. Toutes les expériences vivent dans `~/Work/tries` et vous pouvez y accéder via `try`.

Omarchy n'ajoute pas automatiquement le répertoire `bin/` d'un projet à `PATH`. Lancez les outils locaux au projet auxquels vous faites confiance avec un chemin relatif explicite, comme `bin/rails` ou `./bin/dev`.
