# Outils de développement

## Éditeurs alternatifs

Omarchy est livré avec [Neovim](https://neovim.io/) par défaut, mais si vous souhaitez quelque chose d'un peu plus grand public et familier, vous pouvez ouvrir le menu Omarchy (`Super + Space`) et voir les options sous _Installer > Éditeur_. Nous y proposons VSCode, Cursor, Zed, Sublime Text, Helix, Vim et Emacs. Si vous ne trouvez pas ce que vous cherchez, consultez _Installer > Paquet_ pour vérifier s'il n'existe pas en paquet Arch (et sinon, essayez _Installer > AUR_ pour vérifier l'AUR).

L'éditeur `vi` d'origine est aussi disponible dès l'installation. Lancez `vi filename` pour modifier un fichier dans le terminal.

La correspondance de thème est proposée pour `VSCode`, `Cursor`, `VSCodium` et `Helix`.

Vous pouvez définir l'éditeur par défaut à l'échelle du système sous `Configuration > Par défaut > Éditeur`.

## Environnement

Omarchy permet de mettre en place toute une panoplie d'environnements de développement via la section _Installer > Développement_ du menu Omarchy (`Super + Space`). Vous y trouverez bien sûr _Ruby on Rails_, mais aussi les trois principaux runtimes JavaScript (Node.js, Bun, Deno), ainsi que des frameworks PHP populaires comme Laravel et Symfony. Oh, et il y a aussi Go, Rust, Python, Java, Elixir (avec Phoenix), .NET, OCaml, Zig, Clojure et Scala. Le choix est très large !

La majorité de ces environnements sont gérés par [Mise](https://mise.jdx.dev/). C'est un outil qui vous permet d'installer et d'exécuter plusieurs versions d'un langage de programmation sur la même machine. C'est comme rbenv ou rvm pour Ruby ou virtualenv pour Python, mais il fonctionne pour plein d'environnements différents.

Pour installer, disons, Ruby, vous lancez `mise use -g ruby`, ce qui installe Ruby et le définit comme valeur par défaut globale. Ou, si votre projet a un fichier .ruby-version, vous pouvez simplement lancer `mise i` à la racine de ce projet.

## Docker

[Docker](https://www.docker.com/) n'a guère besoin de présentation. Il vous permet d'exécuter des conteneurs isolés, et Omarchy installe tout ce qu'il faut pour bien le faire fonctionner, y compris Docker lui-même et [Docker Compose](https://docs.docker.com/compose/).

Par défaut, votre utilisateur n'appartient *pas* au groupe `docker`. Ce groupe équivaut en pratique à un root sans mot de passe — tout ce qui en fait partie peut lancer `docker run -v /:/host` et prendre le contrôle de la machine — donc un seul script ou une seule dépendance malveillante s'exécutant sous votre compte serait autrement à une commande de devenir root. En ligne de commande, vous utilisez donc Docker avec `sudo` (`sudo docker ps`, `sudo docker compose up`), et les outils graphiques qui parlent au démon — la machine virtuelle Windows — demandent une autorisation quand ils en ont besoin. Si vous souhaitez retrouver la commodité d'une configuration sans groupe et que vous comprenez le compromis, activez-la depuis **Configuration > Sécurité > Docker sans sudo** (ou lancez `omarchy-setup-security-sudoless-docker`), ce qui vous ajoute au groupe `docker` après un avertissement ; ensuite, `docker` simple et l'alias `d` fonctionnent à nouveau sans `sudo`.

Vous pouvez configurer les bases de données courantes pour le développement local dans Docker via _Installer > Développement > Docker DB_ dans le menu Omarchy.

## GitHub CLI

[Le GitHub CLI](https://cli.github.com/) vous permet de vous authentifier avec votre compte GitHub et de cloner des dépôts privés avec lui. Il est branché comme l'un des stubs mise à chargement paresseux, donc la première fois que vous lancez `gh`, il s'installe tout seul. Pour vous authentifier, lancez `gh auth login`. Vous pouvez ensuite récupérer des dépôts privés avec `gh repo clone org/repo`.

Vous pouvez aussi effectuer plein d'autres opérations GitHub avec cette commande. Lancez simplement `gh` pour voir tout ce qui est possible.

Il existe aussi un stub à installation paresseuse pour `ghui` pour gérer vos pull requests dans une TUI. Et [lazygit](https://github.com/jesseduffield/lazygit) est préinstallé, si vous voulez aussi piloter git lui-même depuis une TUI.
