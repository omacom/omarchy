# Dotfiles

Omarchy se configure principalement via les fameux dotfiles qui se trouvent dans `~/.config`. Ce sont vos fichiers, à vous de les modifier. Les fichiers qui se trouvent dans `/usr/share/omarchy` appartiennent à Omarchy lui-même, et vous ne devriez pas y toucher. Si vous devez modifier quoi que ce soit dans `/usr/share/omarchy`, vous devriez plutôt écraser la valeur dans `~/.config`.

Les configurations principales peuvent être modifiées directement depuis le menu Omarchy (`Super + Space`), comme _Configuration > Clavier > Raccourcis clavier_, _Configuration > Saisie_ et _Configuration > Configuration > [fichier]_. Quand vous procédez ainsi, tout processus qui doit redémarrer après une modification de configuration le fera automatiquement dès que vous quitterez l'éditeur (Neovim par défaut — `:wq`, souvenez-vous ! — mais vous pouvez changer cela via _Configuration > Valeurs par défaut > Éditeur_).

Voici une liste des fichiers principaux dans `~/.config` et ce qu'ils contrôlent :

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | La configuration principale de Hyprland. Charge les valeurs par défaut d'Omarchy ainsi que vos fichiers de surcharge ci-dessous. [En savoir plus sur les configurations de Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vos propres raccourcis clavier et les surcharges de ceux par défaut. |
| `~/.config/hypr/monitors.lua` | Les paramètres d'écran que le panneau des écrans ne couvre pas, comme la rotation, les modes supplémentaires ou le maintien d'un écran éteint. |
| `~/.config/hypr/input.lua` | Contrôle la disposition de votre clavier, votre souris et les paramètres de votre trackpad. |
| `~/.config/hypr/looknfeel.lua` | Contrôle les espacements, les bordures, les animations et le reste de l'apparence. |
| `~/.config/hypr/autostart.lua` | Contrôle les processus supplémentaires lancés avec la session. |
| `~/.config/omarchy/shell.json` | Contrôle le shell Omarchy : position de la barre, disposition et widgets, ainsi que les délais de l'économiseur d'écran, du verrouillage et de l'inactivité. |
| `~/.config/foot/foot.ini` | Contrôle votre terminal (foot est celui par défaut). |
| `~/.XCompose` | Définit vos emoji à accès rapide et la saisie semi-automatique de votre nom/e-mail. Pensez bien à exécuter `omarchy-restart-xcompose` après avoir fait des modifications. |

Si vous finissez par apporter beaucoup de modifications pour peaufiner votre propre installation, c'est une bonne idée de sauvegarder tous ces dotfiles. [Stow est un excellent moyen de le faire](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Lancer vos propres applications avec la session

Si vous voulez que quelque chose s'exécute à chaque fois que vous vous connectez — un démon de synchronisation, une application de discussion, votre propre script — mettez-le dans `~/.config/hypr/autostart.lua` :

```lua
o.launch_on_start("my-service")
```

Cela lance la commande dans le cadre de la session, donc elle est correctement nettoyée quand vous vous déconnectez à nouveau.

### Exécuter des scripts lors d'événements système

Omarchy déclenche des hooks à quelques moments précis, et vous pouvez y accrocher vos propres scripts. Ils se trouvent dans `~/.config/omarchy/hooks/<event>.d/`, un répertoire par événement, et chaque fichier exécutable qui s'y trouve s'exécute quand l'événement se produit :

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Juste après le démarrage du bureau |
| `post-update` | Vers la fin de `omarchy update`, après les paquets, les migrations et les redémarrages de services, avant la mise à jour des outils mise |
| `pre-refresh-pacman` | Après que `omarchy refresh pacman` a resynchronisé la configuration des paquets, avant qu'il ne mette les paquets à jour ; un changement de canal l'exécute pendant cette même étape de resynchronisation |
| `theme-set` | Après un changement de thème (nom du thème dans `$1`) |
| `font-set` | Après un changement de police (nom de la police dans `$1`) |
| `battery-low` | Quand la batterie devient faible (pourcentage dans `$1`) |

C'est dans le hook `pre-refresh-pacman` que doivent aller les dépôts personnalisés ou les lignes `IgnorePkg`, puisqu'il s'exécute avant la transaction de paquets. Les deux hooks liés aux mises à jour s'exécutent en tant que votre utilisateur après qu'Omarchy a effacé son autorisation sudo mise en cache, donc un hook qui utilise `sudo` a besoin de sa propre autorisation et peut vous demander votre mot de passe.

Chacun de ces répertoires contient déjà un fichier `.sample` qui montre la forme d'un hook — retirez le `.sample` du nom pour le mettre en service. Pour installer un script que vous avez écrit ailleurs, utilisez `omarchy hook install post-boot ~/my-hook`, qui le copie à cet endroit et le rend exécutable.

### Ajouter vos propres entrées au menu

Le menu Omarchy (`Super + Space`) peut être enrichi avec vos propres lignes en modifiant `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Les entrées sont identifiées par un identifiant en notation pointée, et c'est cet identifiant qui les place dans l'arborescence, donc `personal` apparaît dans le menu racine et `personal.notes` apparaît à l'intérieur de celui-ci :

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Réutilisez un identifiant existant et vous écrasez cette ligne au lieu d'en ajouter une nouvelle. Le fichier est livré avec tous les champs disponibles documentés sous forme de commentaires.

### Ajouter vos propres exports, fonctions et alias du shell

Omarchy est livré avec tout un tas d'alias ergonomiques et de fonctions pratiques, mais il est très courant de vouloir ajouter les vôtres. Vous devriez ajouter alias, fonctions et exports dans `~/.bashrc`. Ce fichier ne sera pas écrasé lors des mises à jour. Si vous voulez modifier l'une des valeurs par défaut d'Omarchy, vous pouvez aussi les ajouter ici en toute sécurité.

### Définir des variables d'environnement pour le bureau

Les exports de la session de bureau appartiennent à `~/.config/uwsm/env.d/`. Ces fichiers s'exécutent avant le démarrage de votre bureau, donc une erreur de shell peut vous renvoyer à l'écran de connexion. Gardez un terminal fonctionnel ouvert pendant que vous les modifiez. Pour désactiver une surcharge, déplacez-la hors de `env.d`. Voir [récupération de la connexion](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) si une modification empêche la connexion.

### Modifier les fichiers internes d'Omarchy

Écoutez, c'est votre ordinateur. Vous pouvez en faire ce que vous voulez, mais je vous déconseille de modifier directement les fichiers dans `/usr/share/omarchy`. Ils appartiennent au paquet pacman d'Omarchy, donc vos modifications seront simplement écrasées lors de la prochaine mise à jour. Vous feriez mieux d'écraser simplement, dans le dossier `~/.config/*`, toutes les valeurs par défaut qui ne vous plaisent pas.

Vous pouvez changer presque tout de cette façon, comme les raccourcis clavier par défaut. Modifiez simplement `~/.config/hypr/bindings.lua` pour, disons, remplacer [Obsidian](https://obsidian.md/) par [Joplin](https://joplinapp.org/) (à installer avec `omarchy-pkg-add joplin-bin`) :

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` supprime le raccourci existant avant d'ajouter son remplaçant. Il prend les mêmes arguments que `o.bind`, y compris les aides au lancement et les options de raccourci. Utilisez `o.bind` pour ajouter un raccourci, ou `hl.unbind` pour en supprimer un sans le remplacer.

Si vous insistez pour bidouiller les fichiers internes d'Omarchy, passez au canal dev via _Mise à jour > Canal > Dev_. Cela relie Omarchy à un clone git du code source dans `~/omarchy`, que vous êtes libre de modifier à votre guise. Il n'y a personne ici pour vous dire quoi faire !

### Réinitialiser vos modifications

Si vous finissez par mettre le bazar dans les configurations, vous pouvez toujours revenir aux valeurs par défaut via _Mise à jour > Configuration_ dans le menu Omarchy. Ou en exécutant `omarchy reinstall configs` pour tout réinitialiser.
