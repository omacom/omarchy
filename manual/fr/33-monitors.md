# Écrans

Omarchy part du principe que vous utilisez par défaut un écran de classe retina compatible 2x. C'est ce qu'il vous faut pour obtenir ces belles polices de programmation bien nettes. C'est ce pour quoi presque tous les nouveaux ordinateurs portables haut de gamme dotés d'écrans haute résolution sont optimisés. C'est ce que vous voudriez utiliser sur un écran 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ou 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Mais si vous n'utilisez pas un écran avec un PPI de 218 ou plus, vous voudrez modifier les paramètres de l'écran. Par exemple, si vous avez un écran 4K de 27" ou 32", vous pouvez utiliser la mise à l'échelle fractionnaire en ouvrant `~/.config/hypr/monitors.lua` (via _Configuration > Écrans_ dans le menu Omarchy) et en adoptant la recommandation pour cette combinaison :

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Si vous utilisez un écran 1080p ou 1440p, vous voudrez probablement simplement utiliser une mise à l'échelle 1x, vous pouvez donc utiliser :

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Les modifications apportées à `GDK_SCALE` s'appliquent aux applications lancées après la modification (et GTK ne prend en charge que les nombres entiers, alors gardez-le à l'entier le plus proche de l'échelle de votre écran). Assurez-vous donc de quitter les fenêtres que vous avez et qui sont surdimensionnées après la modification (ou fermez toutes les fenêtres avec `Ctrl + Alt + Del` !).

Vous pouvez aussi parcourir rapidement les principaux ratios de mise à l'échelle de l'écran (1x, 1.25x, 1.6x, 2x, 3x, 4x) en utilisant `Super + /` pour augmenter et `Super + Alt + /` pour diminuer, ou en choisir un depuis le panneau de l'écran dans la barre supérieure. Ces réglages ne modifient que l'écran actif, de sorte qu'un écran d'ordinateur portable et un écran externe peuvent chacun avoir leur propre échelle. Le choix est enregistré dans `~/.config/hypr/monitors.lua` sous forme de règle `hl.monitor` pour cet écran, de sorte qu'il persiste après un redémarrage et prime sur `omarchy_monitor_scale`, qui reste l'échelle de tout écran sans règle propre. Comme `GDK_SCALE` est une valeur unique pour tous les écrans, ces modifications la définissent à partir de l'écran ayant l'échelle la plus faible, de sorte que les applications X11 apparaissent un peu petites sur l'écran le plus dense plutôt que surdimensionnées sur l'autre.

### Agrandir ou réduire le texte

La mise à l'échelle de l'écran modifie la taille de tout. Si tout ce que vous voulez, c'est un _texte_ plus grand ou plus petit, il y a un seul réglage pour cela :

```
omarchy display text size 14
```

Il prend une taille en pixels entre 9 et 20, et fait évoluer ensemble l'interface d'Omarchy, les applications GTK et votre terminal, de sorte que l'ensemble du bureau reste proportionné. Lancez-le sans argument pour voir où vous en êtes, et `omarchy display text size reset` pour revenir à la valeur par défaut. Foot est le seul retardataire : il n'a aucun moyen de recharger sa configuration, les terminaux en cours d'exécution conservent donc leur ancienne taille jusqu'à ce que vous en ouvriez un nouveau.

### Étendre et dupliquer les écrans d'ordinateur portable

Lorsque vous connectez un écran externe à votre ordinateur portable, l'affichage est automatiquement étendu. Mais vous pouvez passer en mode duplication à la place en utilisant _Déclencheur > Matériel_ dans le menu Omarchy ou `Super + Ctrl + Alt + Delete`. C'est particulièrement utile si cet écran externe est un projecteur, et que vous voulez montrer quelque chose tout en travaillant.

En mode extension, fermer le capot de l'ordinateur portable éteindra automatiquement l'écran interne. Ouvrir le capot le rallumera. Vous pouvez aussi contrôler cela manuellement en utilisant _Déclencheur > Matériel_ dans le menu Omarchy ou `Super + Ctrl + Delete`.

### Disposer plusieurs écrans

Hyprland fonctionne très bien avec plusieurs écrans. Pour en savoir plus sur leur disposition, lisez [la documentation Hyprland sur les écrans](https://wiki.hypr.land/Configuring/Basics/Monitors/). Dans Omarchy, ceux-ci vont dans `~/.config/hypr/monitors.lua` sous forme d'entrées `hl.monitor` — le fichier est livré avec des exemples commentés pour verrouiller un écran spécifique à une résolution, une position et une rotation.

Chaque écran dispose de ses propres espaces de travail 1 à 10, de sorte que `Super + 1` désigne toujours le premier espace de travail de l'écran où vous vous trouvez. En coulisses, Hyprland numérote tout de même les espaces de travail sur l'ensemble des écrans : l'écran de votre ordinateur portable (ou votre premier écran) reçoit 1–10, l'écran suivant 11–20, et ainsi de suite, et chaque écran conserve son bloc chaque fois que vous le branchez. Utilisez ces numéros si vous écrivez des [règles d'espaces de travail](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ou des règles de fenêtres pour un écran spécifique, de sorte que l'espace de travail 12 est le deuxième espace de travail de votre deuxième écran. `~/.local/state/omarchy/monitor-workspaces` indique quel bloc possède chaque écran.

Les touches fléchées fonctionnent entre les écrans qui partagent un bord dans votre disposition. Les écrans qui ne se touchent qu'à un coin, ou entre lesquels il y a un espace, ne sont pas voisins, alors utilisez `Ctrl + Alt + Tab` pour passer de l'un à l'autre.

| Raccourci clavier | Entre écrans |
| --- | --- |
| `Super + Arrow` | Déplace le focus vers l'écran situé de ce côté lorsqu'il ne reste plus aucune fenêtre dans cette direction |
| `Super + Shift + Arrow` | Échange avec une fenêtre sur l'écran situé de ce côté |
| `Super + Alt + Arrow` | Déplace la fenêtre dans un groupe sur l'écran situé de ce côté |
| `Super + Shift + Ctrl + Arrow` | Déplace la fenêtre vers l'écran situé de ce côté, sur l'espace de travail qu'il affiche |
| `Super + Shift + Alt + Arrow` | Déplace l'espace de travail vers l'écran situé de ce côté, en conservant son numéro s'il est libre |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Déplace le focus vers l'écran suivant ou précédent, quelle que soit la disposition |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Restent sur l'écran où vous vous trouvez |

Vous pouvez aussi découvrir [Hyprmon](https://github.com/erans/hyprmon/), si vous souhaitez un TUI pour vous aider à positionner plusieurs écrans.

### Régler la luminosité

La luminosité de l'écran est contrôlée par les touches de fonction dédiées pour augmenter/diminuer la luminosité. Si vous maintenez shift enfoncée tout en appuyant sur ces touches, vous passerez à la luminosité maximale ou minimale. Les touches contrôlent l'écran actif, de sorte que les écrans externes qui parlent DDC/CI sont réglés de la même manière que l'écran de l'ordinateur portable.

### Écrans Apple

Si vous utilisez un écran Apple, les touches de luminosité habituelles du clavier fonctionneront aussi automatiquement, si l'écran Apple est actif. Cela se fait via la commande `asdcontrol`.

Notez que si vous utilisez un écran Apple 6K XDR, vous pouvez voir un écran fantôme dans la liste de `hyprctl monitors`. Vous pouvez le désactiver avec quelque chose comme `hl.monitor({ output = "DP-2", disabled = true })` via _Configuration > Écrans_.

Sur les machines Intel, vous devriez connecter les écrans Apple à l'aide d'un câble Thunderbolt ordinaire. Sur les autres machines sans Thunderbolt, vous devrez généralement utiliser un [câble DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) pour que cela fonctionne.
