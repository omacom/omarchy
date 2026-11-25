# Outils de développement

## Éditeurs alternatifs

Omarchy est livré avec Plain comme éditeur par défaut sur les nouvelles installations et [Neovim](https://neovim.io/) préinstallé, mais si vous voulez quelque chose d'un peu plus grand public et familier, vous pouvez lancer le Omarchy Menu (`Super + Space`) et voir les options sous _Install > Editor_. Nous y proposons VSCode, Cursor, Zed, Sublime Text, Helix, Vim et Emacs. Si vous ne trouvez pas ce que vous cherchez, allez voir _Install > Package_, et vérifiez si ce n'est pas dans un paquet Arch (et sinon, essayez _Install > AUR_ pour vérifier dans l'AUR).

L'éditeur `vi` d'origine est également disponible dès l'installation. Exécutez `vi filename` pour modifier un fichier dans le terminal.

L'adaptation au thème est proposée pour `VSCode`, `Cursor`, `VSCodium` et `Helix`.

Vous pouvez définir l'éditeur par défaut pour tout le système sous `Setup > Defaults > Editor`.

## Environnement

Omarchy permet de configurer toute une série d'environnements de développement via la section _Install > Development_ du Omarchy Menu (`Super + Space`). Vous y trouverez bien sûr _Ruby on Rails_, mais aussi les trois principaux environnements d'exécution pour JavaScript (Node.js, Bun, Deno), ainsi que des frameworks PHP populaires comme Laravel et Symfony. Oh, et il y a aussi Go, Rust, Python, Java, Elixir (avec Phoenix), .NET, OCaml, Zig, Clojure et Scala. C'est une sélection très vaste !

La plupart de ces environnements sont gérés par [Mise](https://mise.jdx.dev/). C'est un outil qui vous permet d'installer et d'exécuter plusieurs versions d'un langage de programmation sur la même machine. C'est comme rbenv ou rvm pour Ruby ou virtualenv pour Python, mais il fonctionne pour plein d'environnements différents.

Pour installer, disons, Ruby, vous exécuteriez `mise use -g ruby`, ce qui installera Ruby et le définira comme valeur par défaut globale. Ou, si votre projet contient un fichier .ruby-version, vous pouvez simplement exécuter `mise i` à la racine de ce projet.

## Outils CLI préinstallés

`uv`, Node.js et `playwright-cli` (pour que les agents pilotent un navigateur, en utilisant le Chrome installé) sont installés sous forme de paquets, et `omarchy update` les maintient à jour avec le reste du système. [Hunk](https://github.com/modem-dev/hunk) et les CLI GitHub, Basecamp, Cloudflare et HEY sont à un choix de distance sous _Install > CLI_, et les [agents de codage](17-ai.md) sous _Install > AI > CLI_.

mise ne gère que les environnements d'exécution que vous configurez depuis _Install > Development_ ; Omarchy n'installe rien par son intermédiaire de son propre chef. Exécutez `omarchy update` pour les mettre à jour avec le reste d'Omarchy ; l'alias `mup` ne met à jour que les outils gérés par mise. Pour ajouter un autre outil à votre propre configuration, utilisez `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) n'a guère besoin d'être présenté. Il vous permet d'exécuter des conteneurs isolés, et Omarchy installe tout ce qu'il faut pour bien le faire fonctionner, y compris Docker lui-même et [Docker Compose](https://docs.docker.com/compose/).

Par défaut, votre utilisateur n'est *pas* dans le groupe `docker`. Ce groupe équivaut en pratique à un accès root sans mot de passe — tout ce qui en fait partie peut exécuter `docker run -v /:/host` et prendre le contrôle de la machine — donc un seul script ou une seule dépendance malveillante s'exécutant sous votre compte serait sinon à une commande de l'accès root. Donc, en ligne de commande, vous exécutez Docker avec `sudo` (`sudo docker ps`, `sudo docker compose up`), et les outils graphiques qui dialoguent avec le démon — la VM Windows — demandent une autorisation quand ils en ont besoin. Si vous voulez retrouver le confort d'une configuration sans groupe et que vous comprenez le compromis, activez-la depuis **Setup > Security > Sudoless Docker** (ou exécutez `omarchy-setup-security-sudoless-docker`), ce qui vous ajoute au groupe `docker` après un avertissement ; ensuite, `docker` tout court et l'alias `d` fonctionnent de nouveau sans `sudo`.

Vous pouvez configurer les bases de données courantes pour le développement local dans Docker à l'aide de _Install > Development > Docker DB_ dans le menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) est `gh`, pour travailler avec les dépôts, les issues et les pull requests depuis le terminal. _Setup > Git_ l'installe lorsque vous choisissez de vous connecter à GitHub à cet endroit, ou installez-le séparément depuis _Install > CLI > GitHub_. Ensuite, `gh repo clone org/repo` clone un dépôt ; exécutez `gh --help` pour explorer ses commandes.

[Lazygit](https://github.com/jesseduffield/lazygit) est préinstallé pour travailler avec Git lui-même.
