# Créer votre propre thème

Vous pouvez ajouter vos propres thèmes dans `~/.config/omarchy/themes`. Copiez simplement l'un des thèmes existants comme base (regardez dans `/usr/share/omarchy/themes`), puis ajustez-le à votre guise. Tant que votre thème se trouve dans ce dossier, il figurera dans le menu de sélection des thèmes.

Le fichier principal à retoucher est `colors.toml`. Il définit la palette de couleurs qui sert ensuite à générer les configurations pour le terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, les applications Qt, le rétroéclairage du clavier, la méthode de saisie, le sélecteur de partage d'écran, les icônes d'applications, plusieurs outils d'IA (Claude, Pi, Hermes, T3 Code, Herdr), et l'ensemble du shell Omarchy (barre supérieure, menu, notifications, OSD et écran de verrouillage).

Vous pouvez aussi utiliser l'application Aether incluse pour créer un nouveau thème à l'aide d'une charmante interface graphique permettant de jouer avec les couleurs et de chercher des arrière-plans. Lancez-la simplement depuis la grille d'applications avec `Super + Alt + Space`.

### Ce qu'un thème installé peut contenir

Un thème que vous écrivez vous-même dans `~/.config/omarchy/themes` peut contenir tout ce que vous voulez — c'est votre machine et votre fichier, et Omarchy applique tout.

Un thème que vous installez depuis le dépôt de quelqu'un d'autre avec `omarchy theme install` conserve tout ce qui relève de la couleur, et perd la poignée de fichiers qui exécuteraient du code sur votre machine : tout fichier `.lua`, les configurations de terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), et `vscode.json`. Le `hyprland.lua` d'un thème est du Lua que votre compositeur exécute à la connexion, une configuration de terminal nomme le programme que votre terminal démarre, et `vscode.json` nomme une extension VSCode à installer. Installer le thème de quelqu'un devrait changer l'apparence de votre bureau, jamais ce qu'il exécute.

Tout le reste fonctionne toujours exactement comme l'auteur du thème l'a écrit — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, les arrière-plans et les aperçus sont tous conservés. Seul ce qui a été écarté est régénéré à partir de `colors.toml` sur votre machine.

Omarchy distingue les deux selon que le thème contient son propre dépôt git, ce que `omarchy theme install` laisse derrière lui lorsqu'il clone. Ainsi, un thème que vous avez écrit reste le vôtre, et un thème récupéré sur internet reste cantonné aux couleurs.

### Mode clair

Si vous créez un thème en mode clair, définissez `mode = "light"` en haut de votre `colors.toml`. Il sera alors automatiquement associé au mode clair pour toutes les applications. (L'ancienne méthode, qui consiste à déposer un fichier vide nommé `light.mode` à la racine de votre thème, fonctionne toujours aussi.)

### Image de déverrouillage

Les thèmes fournis avec les images `unlock.png` et `preview-unlock.png` seront répertoriés sous _Apparence > Déverrouillage_. Votre `unlock.png` devrait de préférence être un png transparent. Et vous pouvez créer l'image d'aperçu à l'aide de `omarchy plymouth preview`.

### Thématiser les applications qu'Omarchy ne couvre pas

Si vous utilisez une application qui ne figure pas dans cette liste, vous pouvez apprendre vous-même à Omarchy à la thématiser à l'aide d'un modèle. Déposez un fichier dans `~/.config/omarchy/themed/` nommé d'après la configuration qu'il génère, plus une extension `.tpl`, et écrivez la configuration avec `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` à `{{ color15 }}`, ainsi que le reste de la palette comme espaces réservés. Chaque fois que vous changez de thème, le fichier est régénéré avec les couleurs de ce thème.

Un fichier `alacritty.toml.tpl.sample` entièrement commenté se trouve dans ce dossier pour vous servir de base — il répertorie toutes les variables que vous pouvez utiliser, ainsi que les modificateurs `_strip` et `_rgb` pour les applications qui veulent leurs couleurs sans le `#` ou sous forme RGB décimale. Vos modèles ont priorité sur ceux d'Omarchy, vous pouvez donc aussi vous en servir pour remplacer la façon dont une application intégrée est thématisée.

### Distribuer votre thème

Si vous voulez distribuer votre thème pour que d'autres puissent l'utiliser, vous devez le placer sur un serveur git public, comme GitHub. Les gens pourront alors l'installer via _Installation > Style > Thème_ dans le menu Omarchy à l'aide de cette URL. Il est recommandé de suivre la convention de nommage `omarchy-[themename]-theme`, car le thème s'affichera alors correctement sous la seule forme `[themename]` dans le menu de sélection des thèmes après l'installation.

Ce `[themename]` restant devient le nom de répertoire du thème, il doit donc être un nom qu'Omarchy peut manipuler en toute sécurité : il doit commencer par une lettre, un chiffre ou un trait de soulignement, et le reste peut contenir des lettres, des chiffres, `.`, `_`, `+` et `-`. Les majuscules sont converties en minuscules pour vous, mais tout le reste — un espace, un guillemet, un caractère non anglais — est refusé au moment de l'installation plutôt que transformé en nom de répertoire. Ainsi, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` et `omarchy-c++-theme` s'installent tous sans problème.

N'oubliez pas qu'une fois installé depuis un dépôt, tout fichier `.lua`, toute configuration de terminal ou tout `vscode.json` qu'il contient est écarté, alors ne construisez pas le thème autour de ces éléments.

Vous pouvez faire ajouter votre thème à [la page des thèmes supplémentaires](https://omarchy.org/themes/) en envoyant une pull request au [dépôt omarchy-site](https://github.com/omacom-io/omarchy-site).
