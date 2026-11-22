# Dotfiles

Omarchy se configure principalement via les fameux dotfiles qui se trouvent dans `~/.config`. Ceux-ci sont considérés comme vos fichiers, pour vos modifications. Les fichiers qui se trouvent dans `/usr/share/omarchy` appartiennent à Omarchy lui-même, et vous ne devriez pas y toucher. Si vous devez modifier quoi que ce soit dans `/usr/share/omarchy`, vous devriez plutôt écraser la valeur dans `~/.config`.

Les configs principales peuvent être modifiées directement depuis le menu Omarchy (`Super + Space`), comme _Setup > Keyboard > Keybindings_, _Setup > Input_ et _Setup > Config > [file]_. Quand vous procédez ainsi, tout processus qui doit redémarrer après une modification de config le fera automatiquement dès que vous quitterez l'éditeur (Neovim par défaut — `:wq`, souvenez-vous ! — mais vous pouvez changer cela via _Setup > Defaults > Editor_).

Voici une liste des fichiers clés dans `~/.config` et ce qu'ils contrôlent :

| Fichier | Rôle |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | La config principale de Hyprland. Charge les réglages par défaut d'Omarchy plus vos fichiers de surcharge ci-dessous. [En savoir plus sur les configs Hyprland](https://wiki.hypr.land/Configuring/). |
| `~/.config/hypr/bindings.lua` | Vos propres raccourcis clavier et les surcharges des réglages par défaut. |
| `~/.config/hypr/monitors.lua` | Les réglages d'écran que le panneau des moniteurs ne couvre pas, comme la rotation, les modes supplémentaires ou le maintien d'un écran éteint. |
| `~/.config/hypr/input.lua` | Contrôle la disposition de votre clavier, la souris et les réglages du pavé tactile. |
| `~/.config/hypr/looknfeel.lua` | Contrôle les espacements, les bordures, les animations et le reste de l'apparence. |
| `~/.config/hypr/autostart.lua` | Contrôle les processus supplémentaires démarrés avec la session. |
| `~/.config/omarchy/shell.json` | Contrôle le shell Omarchy : la position de la barre, la disposition et les widgets, plus l'économiseur d'écran, le verrouillage et les délais d'inactivité. |
| `~/.config/foot/foot.ini` | Contrôle votre terminal (foot est celui par défaut). |
| `~/.XCompose` | Définit vos émojis à accès rapide et la saisie semi-automatique de votre nom/e-mail. Pensez à exécuter `omarchy-restart-xcompose` après avoir fait des modifications. |

Si vous finissez par faire beaucoup de modifications pour peaufiner votre propre installation, c'est une bonne idée de sauvegarder tous ces dotfiles. [Stow est un excellent moyen de le faire](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Démarrer vos propres applications avec la session

Si vous voulez que quelque chose s'exécute à chaque fois que vous vous connectez — un démon de synchronisation, une application de discussion, votre propre script — mettez-le dans `~/.config/hypr/autostart.lua` :

```lua
o.launch_on_start("my-service")
```

Cela démarre la commande dans le cadre de la session, donc elle est correctement nettoyée quand vous vous déconnectez à nouveau.

### Exécuter des scripts lors des événements système

Omarchy déclenche des hooks à quelques moments, et vous pouvez y raccrocher vos propres scripts. Ils se trouvent dans `~/.config/omarchy/hooks/<event>.d/`, un répertoire par événement, et chaque fichier qui s'y trouve et qui ne se termine pas par `.sample` s'exécute avec bash quand l'événement se produit :

| Événement | Quand il s'exécute |
| ----- | ------------ |
| `post-boot` | Juste après le démarrage du bureau |
| `post-update` | Vers la fin de `omarchy update`, après les paquets, les migrations et les redémarrages de services, avant la mise à jour des outils mise |
| `pre-refresh-pacman` | Après que `omarchy refresh pacman` a resynchronisé la config des paquets, avant qu'il ne mette à jour les paquets ; un changement de canal l'exécute pendant cette même étape d'actualisation |
| `theme-set` | Après un changement de thème (nom du thème dans `$1`) |
| `font-set` | Après un changement de police (nom de la police dans `$1`) |
| `battery-low` | Quand la batterie devient faible (pourcentage dans `$1`) |

Le hook `pre-refresh-pacman` est l'endroit où doivent aller les dépôts personnalisés ou les lignes `IgnorePkg`, puisqu'il s'exécute avant la transaction de paquets. Les deux s'exécutent en tant que votre utilisateur. `post-update` s'exécute pendant que l'autorisation sudo de `omarchy update` est encore fraîche, donc un hook qui utilise `sudo` ne vous redemandera pas votre mot de passe ; `pre-refresh-pacman` s'exécute juste après que `omarchy refresh pacman` a lui-même utilisé sudo.

Chacun de ces répertoires contient déjà un fichier `.sample` qui montre la forme d'un hook — retirez le `.sample` du nom pour le mettre en service. Pour installer un script que vous avez écrit ailleurs, utilisez `omarchy hook install post-boot ~/my-hook`, qui le copie à cet endroit et le rend exécutable.

### Ajouter vos propres entrées de menu

Le menu Omarchy (`Super + Space`) peut être étendu avec vos propres lignes en modifiant `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Les entrées sont indexées par un identifiant en notation pointée, et c'est cet identifiant qui les place dans l'arborescence, donc `personal` apparaît dans le menu racine et `personal.notes` apparaît à l'intérieur de celui-ci :

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Réutilisez un identifiant existant et vous écraserez cette ligne au lieu d'en ajouter une nouvelle. Le fichier est livré avec tous les champs disponibles documentés sous forme de commentaires.

### Ajouter vos propres exports, fonctions et alias du shell

Omarchy est livré avec un tas d'alias ergonomiques et de fonctions bien pratiques, mais il est très courant de vouloir ajouter les vôtres. Vous devriez ajouter à la fois les alias, les fonctions et les exports dans `~/.bashrc`. Ce fichier ne sera pas écrasé lors des mises à jour. Si vous voulez modifier l'un des réglages par défaut d'Omarchy, vous pouvez aussi les ajouter ici en toute sécurité.

### Définir les variables d'environnement pour le bureau

Les exports de la session de bureau ont leur place dans `~/.config/uwsm/env.d/`. Ces fichiers s'exécutent avant le démarrage de votre bureau, donc une erreur de shell peut vous renvoyer à l'écran de connexion. Gardez un terminal fonctionnel ouvert pendant que vous les modifiez. Pour désactiver une surcharge, déplacez-la hors de `env.d`. Voir [récupération de connexion](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) si un changement vous empêche de vous connecter.

### Modifier les fichiers internes d'Omarchy

Écoutez, c'est votre ordinateur. Vous pouvez en faire ce que vous voulez, mais je vous déconseille de modifier directement les fichiers dans `/usr/share/omarchy`. Ils appartiennent au paquet pacman d'Omarchy, donc vos modifications seront tout simplement écrasées lors de la prochaine mise à jour. Vous feriez mieux d'écraser simplement, dans le dossier `~/.config/*`, toutes les valeurs par défaut qui ne vous plaisent pas.

Vous pouvez changer à peu près tout de cette façon, comme les raccourcis clavier par défaut. Modifiez simplement `~/.config/hypr/bindings.lua` pour, par exemple, remplacer [Obsidian](https://obsidian.md/) par [Joplin](https://joplinapp.org/) (à installer avec `omarchy-pkg-add joplin-bin`) :

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` supprime le raccourci existant avant d'ajouter son remplaçant. Il prend les mêmes arguments que `o.bind`, y compris les aides au lancement et les options de raccourci. Utilisez `o.bind` pour ajouter un raccourci, ou `hl.unbind` pour en supprimer un sans le remplacer.

Si vous insistez pour bidouiller les fichiers internes d'Omarchy, passez au canal dev via _Update > Channel > Dev_. Cela relie Omarchy à un checkout git du code source dans `~/omarchy`, que vous êtes libre de modifier à votre guise. Personne ici ne va vous dire quoi faire !

### Réinitialiser vos modifications

Si vous finissez par mettre le bazar dans les configurations, vous pouvez toujours les ramener aux valeurs par défaut via _Update > Config_ dans le menu Omarchy. Ou en exécutant `omarchy reinstall configs` pour tout réinitialiser.
