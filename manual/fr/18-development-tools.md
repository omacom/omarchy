# Outils de développement

## Éditeurs alternatifs

Omarchy est livré avec Plain comme éditeur par défaut sur les nouvelles installations et [Neovim](https://neovim.io/) préinstallé, mais si vous voulez quelque chose d'un peu plus grand public et familier, vous pouvez ouvrir le Omarchy Menu (`Super + Space`) et voir les options sous _Install > Editor_. Nous y proposons VSCode, Cursor, Zed, Sublime Text, Helix, Vim et Emacs. Si vous ne trouvez pas ce que vous cherchez, allez voir _Install > Package_ et vérifiez si ce n'est pas dans un paquet Arch (et sinon, essayez _Install > AUR_ pour vérifier dans l'AUR).

L'éditeur `vi` d'origine est également disponible dès le départ. Exécutez `vi filename` pour modifier un fichier dans le terminal.

La correspondance des thèmes est proposée pour `VSCode`, `Cursor`, `VSCodium` et `Helix`.

Vous pouvez définir l'éditeur par défaut à l'échelle du système sous `Setup > Defaults > Editor`.

## Environnement

Omarchy prend en charge la configuration de toute une série d'environnements de développement via la section _Install > Development_ du Omarchy Menu (`Super + Space`). Vous y trouverez bien sûr _Ruby on Rails_, mais aussi les trois principaux environnements d'exécution pour JavaScript (Node.js, Bun, Deno), ainsi que des frameworks PHP populaires comme Laravel et Symfony. Oh, et il y a aussi Go, Rust, Python, Java, Elixir (avec Phoenix), .NET, OCaml, Zig, Clojure et Scala. C'est une sélection très large !

La majorité de ces environnements sont gérés par [Mise](https://mise.jdx.dev/). C'est un outil qui vous permet d'installer et d'exécuter plusieurs versions d'un langage de programmation sur la même machine. C'est comme rbenv ou rvm pour Ruby ou virtualenv pour Python, mais il fonctionne pour tout un tas d'environnements différents.

Pour installer, disons, Ruby, vous exécuteriez `mise use -g ruby`, ce qui installera Ruby et le définira comme valeur par défaut globale. Ou, si votre projet a un fichier .ruby-version, vous pouvez simplement exécuter `mise i` à la racine de ce projet.

## Outils CLI préinstallés

Omarchy met à disposition des outils tels que `gh`, `uv` et la plupart des [agents de codage](17-ai.md) via [l'installation paresseuse de mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). La première fois que vous en exécutez un, mise l'installe. Les agents de codage vérifient ensuite s'il existe une mise à jour avant de s'exécuter, au maximum une fois toutes les quatre heures ; les autres outils, comme `gh` et `uv`, réutilisent la version installée jusqu'à ce que vous les mettiez à jour.

Vous pouvez également inspecter les valeurs par défaut ou les installer à l'avance :

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Exécutez `omarchy update` pour mettre à jour les outils installés en même temps que le reste d'Omarchy. L'alias `mup` met à jour uniquement les outils gérés par mise. Pour ajouter un autre outil à votre propre configuration, utilisez `mise use -g <tool>`.

La configuration de Python installe également `uv` via mise. La suppression de l'environnement de développement Python laisse `uv` disponible en tant qu'outil indépendant.

### Utiliser votre propre installation

Les commandes de mise passent avant `~/.local/bin` dans le `PATH`, donc un outil que vous avez installé vous-même, par exemple avec l'installateur propre à Claude Code ou à Cursor, exécute quand même la copie de mise. Les applications lancées depuis le bureau trouvent également les commandes de mise avant les paquets système, donc une application qui exécute `gh` obtient la copie de mise même si vous avez installé `github-cli` avec pacman, et mise installe cette copie la première fois. Pour utiliser la vôtre à la place, désactivez la copie de mise dans `~/.config/mise/config.toml`. Par exemple, si vous avez installé Cursor CLI vous-même :

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Si vous avez déjà une table `[settings]`, ajoutez-y l'entrée ; étendez une liste `disable_tools` existante plutôt que de la remplacer. Assurez-vous que votre installation est dans le `PATH`. Utilisez le nom d'outil mise, qui peut différer de sa commande : `oh-my-pi` fournit `omp`, par exemple. Le lanceur de l'agent par défaut préfère également un Cursor ou un Muse installé par l'utilisateur dans `~/.local/bin`.

### Suppression et restauration des valeurs par défaut

_Remove > Preinstalls_ supprime les applications web, les TUI et les applications préinstallées d'Omarchy, et fait en sorte que mise ignore les déclarations d'outils d'Omarchy pour votre utilisateur, en les ajoutant à `ignored_config_paths` dans `~/.config/mise/miserc.toml`. _Install > Preinstalls_ les ramène et supprime à nouveau cette ligne. Les outils que vous déclarez vous-même, dans votre propre configuration ou dans le `mise.toml` d'un projet, continuent de fonctionner dans les deux cas. Si vous choisissez un agent par défaut ou configurez Python après avoir supprimé les préinstallations, cet outil est ajouté à votre propre configuration. Le paramètre mise s'applique uniquement à votre utilisateur, et les autres utilisateurs conservent leur propre choix ; les applications sont toutefois des paquets, donc les supprimer ou les restaurer les modifie pour tout le monde sur la machine.

## Docker

[Docker](https://www.docker.com/) n'a guère besoin d'être présenté. Il vous permet d'exécuter des conteneurs isolés, et Omarchy installe tout ce qu'il faut pour le faire tourner correctement, y compris Docker lui-même et [Docker Compose](https://docs.docker.com/compose/).

Par défaut, votre utilisateur n'est *pas* dans le groupe `docker`. Ce groupe équivaut en pratique à un accès root sans mot de passe — tout ce qui s'y trouve peut exécuter `docker run -v /:/host` et prendre le contrôle de la machine — donc un seul script ou une seule dépendance malveillant exécuté sous votre identité serait sinon à une commande de l'accès root. Sur la ligne de commande, vous exécutez donc Docker avec `sudo` (`sudo docker ps`, `sudo docker compose up`), et les outils graphiques qui communiquent avec le démon — la VM Windows — demandent une autorisation quand ils en ont besoin. Si vous voulez retrouver la commodité d'une configuration sans groupe et que vous comprenez le compromis, activez-la depuis **Setup > Security > Sudoless Docker** (ou exécutez `omarchy-setup-security-sudoless-docker`), ce qui vous ajoute au groupe `docker` après un avertissement ; ensuite, `docker` tout court et l'alias `d` fonctionneront à nouveau sans `sudo`.

Vous pouvez configurer les bases de données courantes pour le développement local dans Docker via _Install > Development > Docker DB_ dans le menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) est disponible sous le nom `gh` pour travailler avec les dépôts, les issues et les pull requests depuis le terminal. Exécutez `gh auth login` pour l'installer lors de la première utilisation et vous authentifier, puis `gh repo clone org/repo` pour cloner un dépôt. Exécutez `gh --help` pour explorer ses commandes.

Pour une interface terminal dédiée aux pull requests, exécutez `ghui` ; mise l'installe également lors de la première utilisation. [Lazygit](https://github.com/jesseduffield/lazygit) est préinstallé pour travailler avec Git lui-même.
