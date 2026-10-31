# Dotfiles

Omarchy se configure principalement via les fameux dotfiles qui se trouvent dans `~/.config`. Ce sont tes fichiers, faits pour tes modifications. Les fichiers qui se trouvent dans `/usr/share/omarchy` appartiennent à Omarchy lui-même, et tu ne devrais pas y toucher. Si tu dois modifier quoi que ce soit dans `/usr/share/omarchy`, tu devrais plutôt écraser la valeur dans `~/.config`.

Les configurations clés peuvent être modifiées directement depuis le menu Omarchy (`Super + Space`), comme _Configuration > Raccourcis clavier_, _Configuration > Entrée_ et _Configuration > Configuration > [file]_. Quand tu procèdes ainsi, tout processus qui doit redémarrer après une modification de configuration le fera automatiquement dès que tu quitteras l'éditeur (Neovim par défaut — `:wq`, souviens-toi ! — mais tu peux changer cela via _Configuration > Valeurs par défaut > Éditeur_).

Voici une liste des fichiers clés dans `~/.config` et ce qu'ils contrôlent :

| Fichier                  | Rôle              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | La configuration principale de Hyprland. Charge les valeurs par défaut de Omarchy ainsi que tes fichiers de surcharge ci-dessous. [En savoir plus sur les configurations Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Tes propres raccourcis clavier et les surcharges de ceux par défaut. |
| `~/.config/hypr/monitors.lua` | Les réglages d'écran que le panneau des écrans ne couvre pas, comme la rotation, les modes supplémentaires ou le maintien d'un écran éteint. |
| `~/.config/hypr/input.lua` | Contrôle la disposition de ton clavier, ta souris et les réglages de ton pavé tactile. |
| `~/.config/hypr/looknfeel.lua` | Contrôle les espacements, les bordures, les animations et le reste de l'apparence. |
| `~/.config/hypr/autostart.lua` | Contrôle les processus supplémentaires démarrés avec la session. |
| `~/.config/omarchy/shell.json` | Contrôle le shell Omarchy : position de la barre, disposition et widgets, ainsi que les délais de l'économiseur d'écran, du verrouillage et de l'inactivité. |
| `~/.config/foot/foot.ini` | Contrôle ton terminal (foot est celui par défaut). |
| `~/.XCompose` | Définit tes emoji à accès rapide et la saisie semi-automatique de ton nom/e-mail. Pense à exécuter `omarchy-restart-xcompose` après avoir fait des modifications. |

Si tu finis par apporter beaucoup de modifications pour personnaliser ta propre configuration, c'est une bonne idée de sauvegarder tous ces dotfiles. [Stow est un excellent moyen de le faire](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Démarrer tes propres applications avec la session

Si tu veux que quelque chose s'exécute à chaque fois que tu te connectes — un démon de synchronisation, une application de discussion, ton propre script — mets-le dans `~/.config/hypr/autostart.lua` :

```lua
o.launch_on_start("my-service")
```

Cela démarre la commande dans le cadre de la session, donc elle est correctement nettoyée quand tu te déconnectes à nouveau.

### Exécuter des scripts lors d'événements système

Omarchy déclenche des hooks à quelques moments, et tu peux y accrocher tes propres scripts. Ils se trouvent dans `~/.config/omarchy/hooks/<event>.d/`, un répertoire par événement, et chaque fichier exécutable qui s'y trouve s'exécute quand l'événement se produit :

| Événement | Quand il s'exécute |
| ----- | ------------ |
| `post-boot` | Juste après le démarrage du bureau |
| `post-update` | Vers la fin de `omarchy update`, après les paquets, les migrations et les redémarrages de services, avant la mise à jour des outils mise |
| `pre-refresh-pacman` | Après que `omarchy refresh pacman` a resynchronisé la configuration des paquets, avant qu'il mette à jour les paquets ; un changement de canal l'exécute pendant cette même étape d'actualisation |
| `theme-set` | Après un changement de thème (nom du thème dans `$1`) |
| `font-set` | Après un changement de police (nom de la police dans `$1`) |
| `battery-low` | Quand la batterie devient faible (pourcentage dans `$1`) |

Le hook `pre-refresh-pacman` est l'endroit où doivent aller les dépôts personnalisés ou les lignes `IgnorePkg`, puisqu'il s'exécute avant la transaction de paquets. Les deux hooks liés aux mises à jour s'exécutent en tant que ton utilisateur après que Omarchy a effacé son autorisation sudo mise en cache, donc un hook qui utilise `sudo` a besoin de sa propre autorisation et peut te demander ton mot de passe.

Chacun de ces répertoires contient déjà un fichier `.sample` montrant la forme d'un hook — retire le `.sample` du nom pour le mettre au travail. Pour installer un script que tu as écrit ailleurs, utilise `omarchy hook install post-boot ~/my-hook`, qui le copie à cet endroit et le rend exécutable.

### Ajouter tes propres entrées de menu

Le menu Omarchy (`Super + Space`) peut être étendu avec tes propres lignes en modifiant `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Les entrées sont indexées par un id en notation pointée, et c'est cet id qui les place dans l'arborescence, donc `personal` apparaît dans le menu racine et `personal.notes` apparaît à l'intérieur :

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Réutilise un id existant et tu écrases cette ligne au lieu d'en ajouter une nouvelle. Le fichier est livré avec tous les champs disponibles documentés sous forme de commentaires.

### Ajouter tes propres exports, fonctions et alias shell

Omarchy est livré avec tout un tas d'alias ergonomiques et de fonctions utiles, mais il est très courant de vouloir ajouter les tiens. Tu devrais ajouter alias, fonctions et exports dans `~/.bashrc`. Ce fichier ne sera pas écrasé lors des mises à jour. Si tu veux modifier l'une des valeurs par défaut de Omarchy, tu peux aussi les ajouter ici en toute sécurité.

### Modifier les fichiers internes de Omarchy

Écoute, c'est ton ordinateur. Tu peux en faire ce que tu veux, mais je te déconseille de modifier directement les fichiers dans `/usr/share/omarchy`. Ils appartiennent au paquet pacman de Omarchy, donc tes modifications seront simplement écrasées lors de la prochaine mise à jour. Tu ferais mieux d'écraser simplement, dans le dossier `~/.config/*`, toutes les valeurs par défaut qui ne te plaisent pas.

Tu peux changer presque tout de cette façon, comme les raccourcis clavier par défaut. Modifie simplement `~/.config/hypr/bindings.lua` pour, disons, remplacer [Obsidian](https://obsidian.md/) par [Joplin](https://joplinapp.org/) (à installer avec `omarchy-pkg-add joplin-bin`) :

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` supprime le raccourci existant avant d'ajouter son remplaçant. Il prend les mêmes arguments que `o.bind`, y compris les aides au lancement et les options de raccourci. Utilise `o.bind` pour ajouter un raccourci, ou `hl.unbind` pour en supprimer un sans le remplacer.

Si tu insistes pour bidouiller les fichiers internes de Omarchy, passe au canal dev via _Mise à jour > Canal > Dev_. Cela relie Omarchy à un dépôt git du code source dans `~/omarchy`, que tu es libre de modifier à ta guise. Personne ici ne va te dire quoi faire !

### Réinitialiser tes modifications

Si tu finis par mettre le bazar dans les configurations, tu peux toujours les ramener à leurs valeurs par défaut via _Mise à jour > Configuration_ dans le menu Omarchy. Ou en exécutant `omarchy reinstall configs` pour tout réinitialiser.
