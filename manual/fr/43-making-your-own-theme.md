# Créer votre propre thème

Vous pouvez ajouter vos propres thèmes dans `~/.config/omarchy/themes`. Copiez simplement l'un des thèmes existants comme base (regardez dans `/usr/share/omarchy/themes`), puis ajustez à votre goût. Tant que votre thème se trouve dans ce dossier, il sera inclus dans le menu de sélection de thème.

Le fichier principal à modifier est `colors.toml`. Il définit le jeu de couleurs ensuite utilisé pour générer les configurations du terminal (Foot/Alacritty/Ghostty/Kitty), de btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, et de tout le shell Omarchy (barre du haut, menu, notifications, OSD et écran de verrouillage).

Vous pouvez aussi utiliser l'application Aether incluse pour créer un nouveau thème à l'aide d'une jolie interface graphique pour jouer avec les couleurs et chercher des arrière-plans. Lancez-la simplement depuis la grille d'applications sur `Super + Alt + Space`.

### Ce qu'un thème installé peut contenir

Un thème que vous écrivez vous-même dans `~/.config/omarchy/themes` peut contenir ce que vous voulez — c'est votre machine et votre fichier, et Omarchy applique tout.

Un thème que vous installez depuis le dépôt de quelqu'un d'autre avec `omarchy theme install` garde tout ce qui est couleur, et perd la poignée de fichiers qui exécuteraient du code sur votre machine : tout fichier `.lua`, les configurations de terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), et `vscode.json`. Le `hyprland.lua` d'un thème est du Lua que votre compositeur exécute à la connexion, une configuration de terminal nomme le programme que votre terminal démarre, et `vscode.json` nomme une extension VSCode à installer. Installer le thème de quelqu'un d'autre doit changer l'apparence de votre bureau, jamais ce qu'il exécute.

Tout le reste fonctionne exactement comme l'auteur du thème l'a écrit — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, les arrière-plans et les aperçus sont tous conservés. Seul ce qui a été écarté est régénéré à partir de `colors.toml` sur votre machine.

Omarchy distingue les deux selon que le thème possède ou non son propre dépôt git à l'intérieur, ce que laisse `omarchy theme install` quand il clone. Ainsi, un thème que vous avez écrit reste le vôtre, et un thème récupéré sur Internet reste des couleurs.

### Mode clair

Si vous créez un thème en mode clair, définissez `mode = "light"` en haut de votre `colors.toml`. Il sera alors automatiquement associé au mode clair pour toutes les applications. (L'ancienne méthode consistant à déposer un fichier vide nommé `light.mode` à la racine de votre thème fonctionne aussi toujours.)

### Couleurs des icônes

Si vous voulez assortir les icônes du gestionnaire de fichiers à votre thème, ajoutez un fichier nommé `icons.theme` avec le nom du jeu d'icônes que vous voulez utiliser. Par défaut, les options sont : `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Image de déverrouillage

Les thèmes fournis avec les images `unlock.png` et `preview-unlock.png` seront listés sous _Style > Déverrouiller_. Votre `unlock.png` doit de préférence être un png transparent. Et vous pouvez créer l'image d'aperçu avec `omarchy plymouth preview`.

### Thématiser des applications qu'Omarchy ne couvre pas

Si vous utilisez une application qui n'est pas dans cette liste, vous pouvez apprendre à Omarchy à la thématiser vous-même avec un modèle. Déposez un fichier dans `~/.config/omarchy/themed/` nommé d'après la configuration qu'il génère plus une extension `.tpl`, et écrivez la configuration avec `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` jusqu'à `{{ color15 }}`, et le reste de la palette comme espaces réservés. Chaque fois que vous changez de thème, le fichier est régénéré avec les couleurs de ce thème.

Il y a dans ce dossier un `alacritty.toml.tpl.sample` entièrement commenté à copier — il liste chaque variable utilisable, plus les modificateurs `_strip` et `_rgb` pour les applications qui veulent leurs couleurs sans le `#` ou en RVB décimal. Vos modèles prennent le pas sur ceux d'Omarchy, si bien que vous pouvez aussi utiliser cela pour remplacer la façon dont une application intégrée est thématisée.

### Distribuer votre thème

Si vous voulez distribuer votre thème pour que d'autres puissent l'utiliser, vous devez le placer sur un serveur git public, comme GitHub. Les gens pourront alors l'installer via _Installer > Style > Thème_ dans le menu Omarchy avec cette URL. Il est recommandé de suivre la convention de nommage `omarchy-[themename]-theme`, car le thème s'affichera correctement comme simplement `[themename]` dans le menu de sélection de thème après l'installation.

Ce `[themename]` restant devient le nom de répertoire du thème, il doit donc être un nom qu'Omarchy peut faire circuler en toute sécurité : il doit commencer par une lettre, un chiffre ou un underscore, et le reste peut contenir des lettres, des chiffres, `.`, `_`, `+` et `-`. Les majuscules sont mises en minuscules pour vous, mais tout le reste — un espace, un guillemet, un caractère non anglais — est refusé au moment de l'installation plutôt que transformé en nom de répertoire. Ainsi, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` et `omarchy-c++-theme` s'installent tous très bien.

Rappelez-vous qu'une fois installé depuis un dépôt, tout `.lua`, configuration de terminal ou `vscode.json` qu'il contient est écarté, alors ne construisez pas le thème autour d'eux.

Vous pouvez faire ajouter votre thème à [la page des thèmes supplémentaires](https://omarchy.org/themes/) en envoyant une pull request au [dépôt omarchy-site](https://github.com/omacom-io/omarchy-site).
