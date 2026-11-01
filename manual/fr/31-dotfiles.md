# Dotfiles

Omarchy se configure principalement via les fameux dotfiles qui vivent dans `~/.config`. Ce sont vos fichiers, à vous de les modifier. Les fichiers qui vivent dans `/usr/share/omarchy` appartiennent à Omarchy lui-même, et vous ne devriez pas y toucher. Si vous devez changer quoi que ce soit dans `/usr/share/omarchy`, vous devriez plutôt écraser la valeur dans `~/.config`.

Les configs clés peuvent être éditées directement depuis le menu Omarchy (`Super + Space`), comme _Setup > Keybindings_, _Setup > Input_, et _Setup > Config > [file]_. Quand vous procédez ainsi, tout processus qui doit redémarrer après des modifications de config le fera automatiquement après que vous aurez quitté l'éditeur (Neovim par défaut — `:wq`, souvenez-vous ! — mais vous pouvez changer cela via _Setup > Defaults > Editor_).

Voici une liste des fichiers clés dans `~/.config` et ce qu'ils contrôlent :

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | La config principale de Hyprland. Charge les valeurs par défaut d'Omarchy plus vos fichiers de surcharge ci-dessous. [En savoir plus sur les configs Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vos propres raccourcis clavier et vos surcharges des valeurs par défaut. |
| `~/.config/hypr/monitors.lua` | Les réglages d'écran que le panneau des écrans ne couvre pas, comme la rotation, les modes supplémentaires, ou le fait de garder un écran éteint. |
| `~/.config/hypr/input.lua` | Contrôle la disposition de votre clavier, votre souris et les réglages du pavé tactile. |
| `~/.config/hypr/looknfeel.lua` | Contrôle les espacements, les bordures, les animations et le reste de l'apparence. |
| `~/.config/hypr/autostart.lua` | Contrôle les processus supplémentaires démarrés avec la session. |
| `~/.config/omarchy/shell.json` | Contrôle le shell Omarchy : position de la barre, disposition et widgets, plus l'économiseur d'écran, le verrouillage et les délais d'inactivité. |
| `~/.config/foot/foot.ini` | Contrôle votre terminal (foot par défaut). |
| `~/.XCompose` | Définit vos emoji à accès rapide et la saisie semi-automatique nom/e-mail. Pensez bien à exécuter `omarchy-restart-xcompose` après avoir fait des modifications. |

Si vous finissez par faire beaucoup de modifications pour ajuster votre propre installation, c'est une bonne idée de sauvegarder tous ces dotfiles. [Stow est un excellent moyen de le faire](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Démarrer vos propres applications avec la session

Si vous voulez que quelque chose se lance à chaque fois que vous vous connectez — un démon de synchronisation, une application de discussion, votre propre script — mettez-le dans `~/.config/hypr/autostart.lua` :

```lua
o.launch_on_start("my-service")
```

Cela démarre la commande dans le cadre de la session, donc elle est correctement nettoyée quand vous vous déconnectez à nouveau.

### Exécuter des scripts lors d'événements système

Omarchy déclenche des hooks à quelques moments, et vous pouvez y accrocher vos propres scripts. Ils vivent dans `~/.config/omarchy/hooks/<event>.d/`, un répertoire par événement, et chaque fichier exécutable qui s'y trouve s'exécute quand l'événement se produit :

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Juste après le démarrage du bureau |
| `post-update` | Vers la fin de `omarchy update`, après les paquets, les migrations et les redémarrages de services, avant la mise à jour des outils mise |
| `pre-refresh-pacman` | Après que `omarchy refresh pacman` a resynchronisé la config des paquets, avant qu'il mette à jour les paquets ; un changement de canal l'exécute pendant cette même étape de rafraîchissement |
| `theme-set` | Après un changement de thème (nom du thème dans `$1`) |
| `font-set` | Après un changement de police (nom de la police dans `$1`) |
| `battery-low` | Quand la batterie devient faible (pourcentage dans `$1`) |

C'est dans le hook `pre-refresh-pacman` que vont les dépôts personnalisés ou les lignes `IgnorePkg`, puisqu'il s'exécute avant la transaction de paquets. Les deux hooks liés aux mises à jour s'exécutent en tant que votre utilisateur après qu'Omarchy a effacé son autorisation sudo mise en cache, donc un hook qui utilise `sudo` a besoin de sa propre autorisation et peut vous demander votre mot de passe.

Chacun de ces répertoires contient déjà un fichier `.sample` qui montre la forme d'un hook — retirez le `.sample` du nom pour le mettre au travail. Pour installer un script que vous avez écrit ailleurs, utilisez `omarchy hook install post-boot ~/my-hook`, qui le copie à cet endroit et le rend exécutable.

### Ajouter vos propres entrées de menu

Le menu Omarchy (`Super + Space`) peut être étendu avec vos propres lignes en éditant `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Les entrées sont identifiées par un id à points, et c'est cet id qui les place dans l'arborescence, donc `personal` apparaît dans le menu racine et `personal.notes` apparaît à l'intérieur :

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Réutilisez un id existant et vous écrasez cette ligne au lieu d'en ajouter une nouvelle. Le fichier est livré avec tous les champs disponibles documentés sous forme de commentaires.

### Ajouter vos propres exports, fonctions et alias shell

Omarchy est livré avec tout un tas d'alias ergonomiques et de fonctions utiles, mais il est très courant de vouloir ajouter les vôtres. Vous devriez ajouter à la fois les alias, les fonctions et les exports dans `~/.bashrc`. Ce fichier ne sera pas écrasé lors des mises à jour. Si vous voulez changer l'une des valeurs par défaut d'Omarchy, vous pouvez aussi les ajouter ici en toute sécurité.

### Définir des variables d'environnement pour le bureau

Les exports de la session de bureau vont dans `~/.config/uwsm/env.d/`. Ces fichiers s'exécutent avant le démarrage de votre bureau, donc une erreur shell peut vous renvoyer à l'écran de connexion. Gardez un terminal fonctionnel ouvert pendant que vous les éditez. Pour désactiver une surcharge, déplacez-la hors de `env.d`. Voir [récupération de connexion](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) si un changement empêche la connexion.

### Modifier les fichiers internes d'Omarchy

Écoutez, c'est votre ordinateur. Vous pouvez en faire ce que vous voulez, mais je vous déconseille de modifier directement les fichiers dans `/usr/share/omarchy`. Ils appartiennent au paquet pacman d'Omarchy, donc vos modifications seront simplement écrasées lors de la prochaine mise à jour. Vous feriez mieux d'écraser simplement les valeurs par défaut qui ne vous plaisent pas dans le dossier `~/.config/*` à la place.

Vous pouvez changer à peu près tout de cette façon, comme les raccourcis clavier par défaut. Éditez simplement `~/.config/hypr/bindings.lua` pour, disons, remplacer [Obsidian](https://obsidian.md/) par [Joplin](https://joplinapp.org/) (à installer avec `omarchy-pkg-add joplin-bin`) :

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` supprime le raccourci existant avant d'ajouter son remplaçant. Il prend les mêmes arguments que `o.bind`, y compris les aides au lancement et les options de raccourci. Utilisez `o.bind` pour ajouter un raccourci, ou `hl.unbind` pour en supprimer un sans le remplacer.

Si vous insistez pour bidouiller les fichiers internes d'Omarchy, passez au canal dev via _Update > Channel > Dev_. Cela relie Omarchy à un checkout git du code source dans `~/omarchy`, que vous êtes libre de modifier à votre guise. Il n'y a personne ici pour vous dire quoi faire !

### Réinitialiser vos modifications

Si vous finissez par mettre le bazar dans les configurations, vous pouvez toujours les ramener aux valeurs par défaut via _Update > Config_ dans le menu Omarchy. Ou en exécutant `omarchy reinstall configs` pour tout réinitialiser.
