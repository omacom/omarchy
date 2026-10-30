# Dotfiles

Omarchy se configure principalement via les fameux dotfiles qui vivent dans `~/.config`. Ceux-ci sont considérés comme vos fichiers pour vos changements. Les fichiers qui vivent dans `/usr/share/omarchy` appartiennent à Omarchy lui-même, et vous ne devriez pas y toucher. Si vous devez changer quoi que ce soit dans `/usr/share/omarchy`, vous devriez plutôt écraser la valeur dans `~/.config`.

Les configurations clés peuvent être modifiées directement depuis le menu Omarchy (`Super + Space`), comme _Configuration > Écrans_, _Configuration > Raccourcis clavier_, _Configuration > Entrées_ et _Configuration > Configuration > [file]_. Quand vous faites cela de cette façon, tout processus qui doit redémarrer après des modifications de configuration le fera automatiquement après que vous aurez quitté l'éditeur (Neovim par défaut — `:wq`, souvenez-vous ! — mais vous pouvez changer cela via _Configuration > Par défaut > Éditeur_).

Voici une liste des fichiers clés dans `~/.config` et ce qu'ils contrôlent :

| Fichier                  | Rôle              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | La configuration principale de Hyprland. Charge les valeurs par défaut d'Omarchy ainsi que vos fichiers de surcharge ci-dessous. [En savoir plus sur les configurations Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Vos propres raccourcis clavier et les surcharges des valeurs par défaut. |
| `~/.config/hypr/monitors.lua` | Contrôle vos écrans, leur résolution et leur position. |
| `~/.config/hypr/input.lua` | Contrôle la disposition de votre clavier, votre souris et les réglages du pavé tactile. |
| `~/.config/hypr/looknfeel.lua` | Contrôle les espacements, les bordures, les animations et le reste de l'apparence. |
| `~/.config/hypr/autostart.lua` | Contrôle les processus supplémentaires démarrés avec la session. |
| `~/.config/omarchy/shell.json` | Contrôle le shell Omarchy : position de la barre, disposition et widgets, plus les délais d'écran de veille, de verrouillage et d'inactivité. |
| `~/.config/foot/foot.ini` | Contrôle votre terminal (foot est celui par défaut). |
| `~/.XCompose` | Définit vos émojis à accès rapide et l'autocomplétion du nom/e-mail. Pensez à lancer `omarchy-restart-xcompose` après avoir fait des changements. |

Si vous finissez par faire beaucoup de changements pour ajuster votre propre installation, c'est une bonne idée de sauvegarder tous ces dotfiles. [Stow est un excellent moyen de faire cela](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Démarrer vos propres applis avec la session

Si vous voulez que quelque chose s'exécute à chaque fois que vous vous connectez — un démon de synchronisation, une appli de discussion, votre propre script — mettez-le dans `~/.config/hypr/autostart.lua` :

```lua
o.launch_on_start("my-service")
```

Cela démarre la commande dans le cadre de la session, donc elle est correctement nettoyée quand vous vous déconnectez à nouveau.

### Exécuter des scripts sur des événements système

Omarchy déclenche des hooks à quelques moments, et vous pouvez y accrocher vos propres scripts. Ils vivent dans `~/.config/omarchy/hooks/<event>.d/`, un répertoire par événement, et chaque fichier exécutable qui s'y trouve s'exécute quand l'événement se produit :

| Événement | Quand il s'exécute |
| ----- | ------------ |
| `post-boot` | Juste après le démarrage du bureau |
| `post-update` | Vers la fin de `omarchy update`, après les paquets, les migrations et les redémarrages de services, avant la mise à jour des outils mise |
| `pre-refresh-pacman` | Après que `omarchy refresh pacman` resynchronise la configuration des paquets, avant qu'il ne mette à jour les paquets ; un changement de canal l'exécute pendant cette même étape d'actualisation |
| `theme-set` | Après un changement de thème (nom du thème dans `$1`) |
| `font-set` | Après un changement de police (nom de la police dans `$1`) |
| `battery-low` | Quand la batterie devient faible (pourcentage dans `$1`) |

Le hook `pre-refresh-pacman` est l'endroit où les dépôts personnalisés ou les lignes `IgnorePkg` ont leur place, puisqu'il s'exécute avant la transaction de paquets. Les deux hooks liés aux mises à jour s'exécutent sous votre utilisateur après qu'Omarchy a effacé son autorisation sudo en cache, donc un hook qui utilise `sudo` a besoin de sa propre autorisation et peut vous demander votre mot de passe.

Chacun de ces répertoires contient déjà un fichier `.sample` montrant la forme d'un hook — retirez le `.sample` du nom pour le mettre au travail. Pour installer un script que vous avez écrit ailleurs, utilisez `omarchy hook install post-boot ~/my-hook`, ce qui le copie et le rend exécutable.

### Ajouter vos propres entrées de menu

Le menu Omarchy (`Super + Space`) peut être étendu avec vos propres lignes en modifiant `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Les entrées sont indexées par un id à points, et c'est l'id qui les place dans l'arbre, donc `personal` apparaît dans le menu racine et `personal.notes` apparaît à l'intérieur :

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Réutilisez un id existant et vous écrasez cette ligne au lieu d'en ajouter une nouvelle. Le fichier est livré avec tous les champs disponibles documentés sous forme de commentaires.

### Ajouter vos propres exports, fonctions et alias de shell

Omarchy est livré avec plein d'alias ergonomiques et de fonctions utiles, mais il est très courant de vouloir ajouter les vôtres. Vous devriez ajouter à la fois les alias, les fonctions et les exports dans `~/.bashrc`. Ce fichier ne sera pas écrasé lors des mises à jour. Si vous voulez changer l'une des valeurs par défaut d'Omarchy, vous pouvez aussi les ajouter ici en toute sécurité.

### Changer les fichiers internes d'Omarchy

Écoutez, c'est votre ordinateur. Vous pouvez en faire ce que vous voulez, mais je vous déconseillerais de modifier directement les fichiers dans `/usr/share/omarchy`. Ils appartiennent au paquet pacman Omarchy, donc vos changements seront simplement écrasés lors de la prochaine mise à jour. Vous feriez mieux d'écraser simplement toutes les valeurs par défaut que vous n'aimez pas dans le dossier `~/.config/*` à la place.

Vous pouvez changer à peu près tout de cette façon, comme les raccourcis clavier par défaut. Modifiez simplement `~/.config/hypr/bindings.lua` pour, disons, remplacer [Obsidian](https://obsidian.md/) par [Joplin](https://joplinapp.org/) (à installer avec `omarchy-pkg-add joplin-bin`) :

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` supprime le raccourci existant avant d'ajouter son remplaçant. Il prend les mêmes arguments que `o.bind`, y compris les helpers de lancement et les options de raccourci. Utilisez `o.bind` pour ajouter un raccourci, ou `hl.unbind` pour en supprimer un sans le remplacer.

Si vous insistez pour bidouiller les fichiers internes d'Omarchy, passez sur le canal dev via _Mettre à jour > Canal > Dev_. Cela lie Omarchy à un clone git du code source dans `~/omarchy`, que vous êtes libre de modifier à votre guise. Il n'y a personne ici pour vous dire quoi faire !

### Réinitialiser tous les changements

Si vous finissez par mettre le bazar dans les configurations, vous pouvez toujours les restaurer aux valeurs par défaut via _Mettre à jour > Configuration_ dans le menu Omarchy. Ou en lançant `omarchy reinstall configs` pour tout réinitialiser.
