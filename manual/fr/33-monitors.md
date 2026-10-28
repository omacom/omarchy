# Écrans

Omarchy part du principe que vous utilisez par défaut un écran de classe Retina compatible 2x. C'est ce qu'il vous faut pour obtenir ces jolies polices de programmeur bien nettes. C'est ce pour quoi presque tous les nouveaux ordinateurs portables haut de gamme avec des écrans haute résolution sont optimisés. C'est ce que vous voudriez utiliser sur un 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ou 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Mais si vous n'utilisez pas un écran avec un PPI de 218 ou plus, vous voudrez modifier les paramètres de l'écran. Par exemple, si vous avez un 27" ou 32" 4K, vous pouvez utiliser une mise à l'échelle fractionnaire en ouvrant `~/.config/hypr/monitors.lua` (via _Setup > Monitors_ dans le menu Omarchy) et en passant à la recommandation pour cette combinaison :

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Si vous utilisez un écran 1080p ou 1440p, vous voudrez probablement simplement utiliser une mise à l'échelle 1x, vous pouvez donc utiliser :

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Les modifications de `GDK_SCALE` s'appliquent aux applications démarrées après la modification (et GTK n'accepte que les nombres entiers, alors gardez-le à l'entier le plus proche de l'échelle de votre écran). Assurez-vous donc de quitter les fenêtres surdimensionnées que vous avez après la modification (ou fermez toutes les fenêtres avec `Ctrl + Alt + Del` !).

Vous pouvez aussi parcourir rapidement les principaux ratios de mise à l'échelle des écrans (1x, 1.25x, 1.6x, 2x, 3x, 4x) en utilisant `Super + /` pour augmenter et `Super + Alt + /` pour diminuer, ou en choisir un depuis le panneau des écrans dans la barre supérieure. Ces réglages ne modifient que l'écran sur lequel vous êtes concentré, donc un écran d'ordinateur portable et un écran externe peuvent chacun avoir leur propre échelle. Le choix est enregistré dans `~/.config/hypr/monitors.lua` sous forme de règle `hl.monitor` pour cet écran, donc il persiste après un redémarrage et prend le pas sur `omarchy_monitor_scale`, qui reste l'échelle pour tout écran sans règle propre.

### Agrandir ou réduire le texte

La mise à l'échelle de l'écran modifie la taille de tout. Si tout ce que vous voulez, c'est un _texte_ plus grand ou plus petit, il y a un seul réglage pour ça :

```
omarchy display text size 14
```

Cela prend une taille en pixels entre 9 et 20, et fait évoluer ensemble le shell Omarchy, les applications GTK et votre terminal, pour que tout le bureau reste proportionné. Exécutez-le sans argument pour voir où vous en êtes, et `omarchy display text size reset` pour revenir à la valeur par défaut. Foot est le seul retardataire : il n'a aucun moyen de recharger sa configuration, donc les terminaux en cours d'exécution conservent leur ancienne taille jusqu'à ce que vous en ouvriez un nouveau.

### Étendre et dupliquer en miroir les écrans d'ordinateur portable

Lorsque vous connectez un écran externe à votre ordinateur portable, l'affichage est automatiquement étendu. Mais vous pouvez changer cela pour passer en duplication en miroir à la place en utilisant _Trigger > Hardware_ dans le menu Omarchy ou `Super + Ctrl + Alt + Delete`. C'est particulièrement utile si cet écran externe est un projecteur, et que vous voulez montrer quelque chose tout en travaillant.

Lorsque vous êtes en mode étendu, fermer le capot de l'ordinateur portable éteindra automatiquement l'écran interne. Ouvrir le capot le rallumera. Vous pouvez aussi contrôler cela manuellement en utilisant _Trigger > Hardware_ dans le menu Omarchy ou `Super + Ctrl + Delete`.

### Disposer plusieurs écrans

Hyprland fonctionne très bien avec plusieurs écrans. Lisez-en plus sur la façon de les disposer dans [la documentation Hyprland sur les écrans](https://wiki.hypr.land/Configuring/Basics/Monitors/). Dans Omarchy, ceux-ci vont dans `~/.config/hypr/monitors.lua` sous forme d'entrées `hl.monitor` — le fichier est fourni avec des exemples commentés pour fixer un écran spécifique à une résolution, une position et une rotation.

Chaque écran a ses propres espaces de travail 1 à 10, donc `Super + 1` signifie toujours le premier espace de travail de l'écran sur lequel vous êtes. En coulisses, Hyprland numérote quand même les espaces de travail sur l'ensemble des écrans : l'écran de votre ordinateur portable (ou le premier écran) obtient 1–10, l'écran suivant 11–20, et ainsi de suite, et chaque écran conserve son bloc chaque fois que vous le branchez. Utilisez ces numéros si vous écrivez des [règles d'espace de travail](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ou des règles de fenêtre pour un écran spécifique, donc l'espace de travail 12 est le deuxième espace de travail de votre deuxième écran. `~/.local/state/omarchy/monitor-workspaces` liste quel bloc chaque écran possède.

Les touches fléchées fonctionnent entre les écrans qui partagent un bord dans votre disposition. Les écrans qui ne se touchent qu'à un coin, ou qui ont un espace entre eux, ne sont pas voisins, alors utilisez `Ctrl + Alt + Tab` pour passer de l'un à l'autre.

| Hotkey | Across monitors |
| --- | --- |
| `Super + Arrow` | Déplace le focus vers l'écran de ce côté une fois qu'il n'y a plus de fenêtre dans cette direction |
| `Super + Shift + Arrow` | Échange avec une fenêtre sur l'écran de ce côté |
| `Super + Alt + Arrow` | Déplace la fenêtre dans un groupe sur l'écran de ce côté |
| `Super + Shift + Ctrl + Arrow` | Déplace la fenêtre vers l'écran de ce côté, sur l'espace de travail qu'il affiche |
| `Super + Shift + Alt + Arrow` | Déplace l'espace de travail vers l'écran de ce côté, en gardant son numéro s'il est libre |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Déplace le focus vers l'écran suivant ou précédent, quelle que soit la disposition |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Restent sur l'écran sur lequel vous êtes |

Vous pouvez aussi jeter un œil à [Hyprmon](https://github.com/erans/hyprmon/), si vous aimeriez une TUI pour vous aider avec le positionnement de plusieurs écrans.

### Contrôler la luminosité

La luminosité de l'écran est contrôlée par les touches de fonction dédiées pour augmenter/diminuer la luminosité. Si vous maintenez shift enfoncé tout en appuyant sur ces touches, vous irez à la luminosité maximale ou minimale. Les touches contrôlent l'écran sur lequel vous êtes concentré, donc les écrans externes qui parlent DDC/CI sont réglés de la même façon que l'écran de l'ordinateur portable.

### Écrans Apple

Si vous utilisez un écran Apple, les touches de luminosité habituelles du clavier fonctionneront aussi automatiquement, si vous êtes concentré sur l'écran Apple. Cela se fait via la commande `asdcontrol`.

Notez que si vous utilisez un écran Apple 6K XDR, vous pouvez voir un écran fantôme dans votre liste `hyprctl monitors`. Vous pouvez désactiver cela avec quelque chose comme `hl.monitor({ output = "DP-2", disabled = true })` via _Setup > Monitors_.

Sur les machines Intel, vous devriez connecter les écrans Apple en utilisant un câble Thunderbolt ordinaire. Sur les autres machines sans Thunderbolt, vous devrez généralement utiliser un [câble DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) pour que ça fonctionne.
