# Plugins du shell

Le bureau Omarchy tourne sous forme d'un seul processus Quickshell de longue durée appelé `omarchy-shell`, et presque tout ce que vous voyez à l'écran est un plugin à l'intérieur. La barre est un plugin. Il en va de même pour les panneaux qui descendent depuis celle-ci, les superpositions plein écran comme le sélecteur d'émojis et le gestionnaire de presse-papiers, le menu Omarchy lui-même, l'écran de verrouillage, la boîte de dialogue polkit, et les services sans interface qui surveillent votre batterie et réchauffent votre écran la nuit.

Ce n'est pas juste un détail d'implémentation. Cela signifie que vous pouvez désactiver des morceaux du bureau, les remplacer, ou écrire les vôtres sans toucher une ligne du code source d'Omarchy.

Les plugins maison sont livrés avec Omarchy et vivent dans `$OMARCHY_PATH/shell/plugins/`. Tout ce que vous ajoutez vous-même — vos propres expériences, ou quelque chose que vous avez trouvé sur GitHub — vit dans `~/.config/omarchy/plugins/`. Les deux sont découverts de la même façon au démarrage, mais les plugins intégrés reçoivent des interfaces de shell de confiance tandis que les plugins tiers reçoivent une interface limitée, circonscrite à leur propre service et à leur cycle de vie. Les clones des plugins intégrés ne conservent que la configuration propre à la source et les appels d'interface nécessaires au comportement d'origine.

## Voir ce que vous avez

```
omarchy plugin list
```

Cela affiche chaque plugin découvert avec son id, s'il est activé, s'il est maison ou tiers, ses types, et son nom d'affichage. Ajoutez `--json` si vous le transmettez à autre chose.

Les ids de plugins sont namespacés. Les plugins intégrés commencent tous par `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — et ce namespace est réservé, donc un plugin tiers ne peut jamais le revendiquer.

## Les activer et les désactiver

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Ou utilisez le menu : _Configuration > Plugins_ propose Activer plugin, Désactiver plugin, Ajouter plugin, Cloner plugin et Supprimer plugin, chacun avec un sélecteur qui ne propose que les plugins qui ont du sens pour cette action.

L'état activé est stocké dans `~/.config/omarchy/shell.json`, et la règle diffère légèrement selon les deux types de plugins. Un plugin tiers est activé exactement quand son id apparaît quelque part dans ce fichier — comme entrée de disposition de la barre, comme entrée dans `plugins[]`, ou comme `bar.id`. Les plugins maison qui ne sont pas des widgets de barre fonctionnent dans l'autre sens : ils sont activés par défaut et ne se désactivent qu'en étant listés dans `disabledPlugins[]`.

Un plugin de barre complète n'a pas d'état désactivé du tout. Il y a toujours exactement une barre, donc vous la remplacez en en activant une autre. Le placement des widgets de barre est couvert dans [la barre de menu](05-the-top-bar.md).

## Ajouter un plugin depuis git

Un plugin tiers est simplement un dépôt git avec un `manifest.json` à sa racine.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Avant de faire quoi que ce soit, il vous dit clairement que les plugins tournent comme du code arbitraire, non cloisonné, à l'intérieur de votre processus shell de longue durée, vous montre l'URL, et vous demande de confirmer. Prenez cela au sérieux. L'interface des plugins tiers n'expose pas directement les services d'authentification, et une barre de remplacement ne reçoit que des capacités limitées pour l'interface configurée hors authentification. Les plugins visuels partagent toujours la scène QML du shell et peuvent remonter les objets parents ordinaires, tandis que tout le code de plugin tourne avec tout ce que votre compte utilisateur peut atteindre. L'état d'authentification est protégé séparément en gardant ces services en dehors du graphe d'objets hôtes atteignable. N'ajoutez que des dépôts que vous êtes prêt à exécuter, et lisez-les avant de les activer.

Une barre de remplacement peut afficher les widgets installés, mais les widgets tiers adossés à un service peuvent avoir des fonctionnalités réduites là, parce que la barre n'est pas autorisée à demander l'objet de service vivant d'un autre plugin. Revenez au `omarchy.bar` intégré si un tel widget a besoin de son service compagnon.

Ensuite, il clone le dépôt dans un répertoire temporaire, valide le manifest, refuse l'installation si un autre plugin revendique déjà cet id, et le déplace dans `~/.config/omarchy/plugins/<id>/`. Sans `--enable`, il demande si vous voulez l'activer maintenant, et vous pouvez dire non et aller lire le code d'abord. Il n'exécute jamais rien du plugin, n'exécute jamais un hook d'installation, et ne demande jamais sudo — il clone des fichiers, vérifie le manifest, et bascule un bit via IPC.

La mise à jour est un pull en avance rapide de ce même clone :

```
omarchy plugin update acme.weather
omarchy plugin update
```

Sans id, il met à jour chaque plugin géré par git que vous avez. Il vous montre le diff avant de l'appliquer, refuse de mettre à jour si vous avez des changements locaux qu'il ne peut pas dépasser en avance rapide, et revient en arrière si la nouvelle révision échoue à la validation.

```
omarchy plugin remove acme.weather
```

La suppression désactive d'abord le plugin, puis le supprime si c'est un clone git (le dépôt est toujours en amont) ou le délie si c'est un lien symbolique. Un dossier de plugin fait main sans dépôt git est déplacé vers une sauvegarde horodatée à l'intérieur du répertoire des plugins au lieu d'être supprimé purement et simplement.

## Cloner un plugin intégré pour le modifier

C'est ma partie préférée. Si vous voulez changer la façon dont un widget intégré se comporte, ne modifiez pas les fichiers sous `$OMARCHY_PATH` — ceux-ci appartiennent au paquet et la prochaine mise à jour les écrasera. Clonez-le plutôt :

```
omarchy plugin clone omarchy.clock
```

Cela copie l'ensemble du plugin dans `~/.config/omarchy/plugins/dhh.clock` (votre nom d'utilisateur, pas le mien), le renomme en « My Clock », l'active, et bascule le shell du plugin intégré vers votre copie — en gardant la position et les réglages d'un widget de barre existant. Ajoutez `--edit` pour ouvrir le nouveau répertoire dans votre `$EDITOR` tout de suite, ce que fait pour vous _Configuration > Plugins > Cloner plugin_ du menu.

Le préfixe de nom d'utilisateur fait que l'id de votre clone reste le vôtre, donc le partager n'entre en collision avec celui de personne d'autre. Les appels faits à l'id intégré d'origine sont routés vers votre clone, donc rien de ce qui référençait `omarchy.clock` n'a besoin d'être mis à jour. Et si vous mettez le bazar dedans, `omarchy plugin remove dhh.clock` remet le plugin intégré en place.

Enregistrer un fichier n'importe où sous `~/.config/omarchy/plugins/` recharge automatiquement le code du plugin, donc vous pouvez laisser l'éditeur ouvert et regarder vos changements atterrir.

## Écrire les vôtres

Un plugin est un répertoire avec un `manifest.json` et du QML. Le manifest déclare `schemaVersion: 1`, un `id`, `name`, `version`, un ou plusieurs `kinds`, et un objet `entryPoints` pointant vers le fichier QML de chaque type :

| Type | Ce que c'est |
|------|------------|
| `bar-widget` | Un composant que la barre active peut déposer dans une section |
| `panel` | Une fenêtre flottante persistante ou invoquée |
| `overlay` | Une superposition plein écran |
| `menu` | Une surface de menu invoquée |
| `service` | Un singleton sans interface et sans UI |
| `bar` | Une barre complète qui remplace celle intégrée |

Un plugin peut déclarer plusieurs types à la fois — le plugin média est à la fois un `service` et un `bar-widget`. Les widgets de barre obtiennent un bloc `barWidget` supplémentaire avec un nom d'affichage, une catégorie, un `defaultSection` optionnel, et `allowMultiple`, qui dit s'il est sensé d'en avoir plus d'un sur la barre. La plupart des widgets le mettent à `false` ; les espaceurs et les indicateurs le mettent à `true`.

Avant de publier quoi que ce soit, vérifiez-le :

```
omarchy plugin validate ./my-plugin
```

Cela exécute les mêmes vérifications que le shell fait au chargement : la version du schéma, les champs requis, un id qui n'est pas réservé, des points d'entrée qui sont des chemins relatifs sûrs et qui existent réellement, un point d'entrée pour chaque type que vous avez revendiqué, et aucun lien symbolique nulle part dans le dossier.

Pour le développement de plugins, voir la [référence du shell](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) et le [catalogue des plugins maison](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Partager les vôtres avec le monde

Une fois que vous avez fait quelque chose qui vous plaît, mettez-le dans un dépôt git public. C'est tout le mécanisme de distribution — n'importe qui peut alors lancer `omarchy plugin add` contre votre URL et le faire tourner en quelques secondes.

Pour aider les gens à le trouver réellement, listez-le sur [plugins.omarchy.org](https://plugins.omarchy.org). C'est la place de marché des plugins du shell Omarchy, et c'est le premier endroit où regarder quand vous vous demandez si quelqu'un a déjà construit le widget que vous êtes sur le point d'écrire. Parcourez-le avant de commencer !
