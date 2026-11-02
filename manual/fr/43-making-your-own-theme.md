# Créer ton propre thème

Tu peux ajouter tes propres thèmes à `~/.config/omarchy/themes`. Copie simplement l'un des thèmes existants comme base (regarde dans `/usr/share/omarchy/themes`), puis ajuste-le à ton goût. Tant que ton thème se trouve dans ce dossier, il sera inclus dans le menu de sélection des thèmes.

Le fichier principal à modifier est `colors.toml`. Il définit le jeu de couleurs qui est ensuite utilisé pour générer les configurations du terminal (Foot/Alacritty/Ghostty/Kitty), de btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, et de l'ensemble du shell Omarchy (barre supérieure, menu, notifications, OSD et écran de verrouillage).

Tu peux aussi utiliser l'application Aether incluse pour créer un nouveau thème à l'aide d'une belle interface GUI pour jouer avec les couleurs et chercher des arrière-plans. Lance-la simplement depuis la grille d'applications avec `Super + Alt + Space`.

### Ce qu'un thème installé peut contenir

Un thème que tu écris toi-même dans `~/.config/omarchy/themes` peut contenir ce que tu veux — c'est ta machine et ton fichier, et Omarchy applique tout.

Un thème que tu installes depuis le dépôt de quelqu'un d'autre avec `omarchy theme install` conserve tout ce qui relève de la couleur, et perd la poignée de fichiers qui exécuteraient du code sur ta machine : tout fichier `.lua`, les configurations de terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), et `vscode.json`. Le `hyprland.lua` d'un thème est du Lua que ton compositeur exécute à la connexion, une configuration de terminal nomme le programme que ton terminal démarre, et `vscode.json` nomme une extension VSCode à installer. Installer le thème de quelqu'un doit changer l'apparence de ton bureau, jamais ce qu'il exécute.

Tout le reste fonctionne toujours exactement comme l'auteur du thème l'a écrit — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, les arrière-plans et les aperçus sont tous conservés. Seul ce qui a été supprimé est régénéré à partir de `colors.toml` sur ta machine.

Omarchy distingue les deux selon que le thème contient ou non son propre dépôt git, ce que `omarchy theme install` laisse derrière lui lorsqu'il clone. Donc un thème que tu as écrit reste le tien, et un thème récupéré sur internet reste des couleurs.

### Mode clair

Si tu crées un thème en mode clair, définis `mode = "light"` en haut de ton `colors.toml`. Il sera alors automatiquement associé au mode clair pour toutes les applications. (L'ancienne méthode consistant à déposer un fichier vide nommé `light.mode` à la racine de ton thème fonctionne toujours aussi.)

### Couleurs des icônes

Si tu veux assortir les icônes du gestionnaire de fichiers aux couleurs de ton thème, ajoute un fichier nommé `icons.theme` contenant le nom du jeu d'icônes que tu veux utiliser. Par défaut, les options sont : `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Image de déverrouillage

Les thèmes fournis avec les images `unlock.png` et `preview-unlock.png` seront listés sous _Appearance > Unlock_. Ton `unlock.png` doit de préférence être un png transparent. Et tu peux créer l'image d'aperçu à l'aide de `omarchy plymouth preview`.

### Thématiser les applications qu'Omarchy ne couvre pas

Si tu utilises une application qui ne figure pas dans cette liste, tu peux apprendre toi-même à Omarchy à la thématiser à l'aide d'un modèle. Dépose un fichier dans `~/.config/omarchy/themed/` nommé d'après la configuration qu'il génère plus une extension `.tpl`, et écris la configuration avec `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` jusqu'à `{{ color15 }}`, et le reste de la palette comme espaces réservés. Chaque fois que tu changes de thème, le fichier est régénéré avec les couleurs de ce thème.

Il y a un `alacritty.toml.tpl.sample` entièrement commenté dans ce dossier à partir duquel copier — il liste toutes les variables que tu peux utiliser, plus les modificateurs `_strip` et `_rgb` pour les applications qui veulent leurs couleurs sans le `#` ou en RGB décimal. Tes modèles ont la priorité sur ceux d'Omarchy, donc tu peux aussi utiliser cela pour remplacer la façon dont une application intégrée est thématisée.

### Distribuer ton thème

Si tu veux distribuer ton thème pour que d'autres puissent l'utiliser, tu dois le mettre sur un serveur git public, comme GitHub. Les gens pourront ensuite l'installer via _Install > Style > Theme_ dans le menu Omarchy à l'aide de cette URL. Il est recommandé de suivre la convention de nommage `omarchy-[themename]-theme`, car le thème s'affichera correctement sous la forme simplement `[themename]` dans le menu de sélection des thèmes après l'installation.

Ce `[themename]` restant devient le nom du répertoire du thème, donc il doit être un nom qu'Omarchy peut manipuler en toute sécurité : il doit commencer par une lettre, un chiffre ou un tiret bas, et le reste peut contenir des lettres, des chiffres, `.`, `_`, `+` et `-`. Les majuscules sont converties en minuscules pour toi, mais tout le reste — un espace, un guillemet, un caractère non anglais — est refusé au moment de l'installation plutôt que transformé en nom de répertoire. Donc `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` et `omarchy-c++-theme` s'installent tous sans problème.

N'oublie pas qu'une fois installé depuis un dépôt, tout `.lua`, toute configuration de terminal ou tout `vscode.json` qu'il contient est supprimé, donc ne construis pas le thème autour de ceux-ci.

Tu peux faire ajouter ton thème à [la page des thèmes supplémentaires](https://omarchy.org/themes/) en envoyant une pull request au [dépôt omarchy-site](https://github.com/omacom-io/omarchy-site).
