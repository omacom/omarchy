# Moniteurs

Omarchy suppose par défaut que vous utilisez un écran de classe retina capable de 2x. C'est ce qu'il vous faut pour obtenir ces belles polices de programmeur nettes et précises. C'est ce pour quoi presque tous les nouveaux ordinateurs portables haut de gamme avec des écrans haute résolution sont optimisés. C'est ce que vous voudriez utiliser sur un 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ou un 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Mais si vous n'utilisez pas un écran avec un PPI de 218 ou plus, vous voudrez modifier les paramètres du moniteur. Par exemple, si vous avez un 4K de 27" ou 32", vous pouvez utiliser la mise à l'échelle fractionnaire en ouvrant `~/.config/hypr/monitors.lua` (via _Setup > Monitors_ dans le menu Omarchy) et en passant à la recommandation pour cette combinaison :

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Si vous utilisez un écran 1080p ou 1440p, vous voudrez probablement simplement utiliser une mise à l'échelle 1x, vous pouvez donc utiliser :

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Les modifications de `GDK_SCALE` s'appliquent aux applications lancées après le changement (et GTK n'accepte que les nombres entiers, gardez-le donc à l'entier le plus proche de l'échelle de votre moniteur). Assurez-vous donc de quitter les fenêtres surdimensionnées que vous avez après le changement (ou fermez toutes les fenêtres avec `Ctrl + Alt + Del` !).

Vous pouvez aussi parcourir rapidement les principaux ratios de mise à l'échelle du moniteur (1x, 1.25x, 1.6x, 2x, 3x, 4x) en utilisant `Super + /` pour augmenter et `Super + Alt + /` pour diminuer. Si vous avez la configuration par défaut, ces changements persisteront aussi après un redémarrage.

### Agrandir ou réduire le texte

La mise à l'échelle du moniteur modifie la taille de tout. Si tout ce que vous voulez, c'est un _texte_ plus grand ou plus petit, il y a un seul réglage pour cela :

```
omarchy display text size 14
```

Cela prend une taille en pixels entre 9 et 20, et déplace ensemble le shell Omarchy, les applications GTK et votre terminal, pour que tout le bureau reste proportionné. Lancez-la sans argument pour voir où vous en êtes, et `omarchy display text size reset` pour revenir à la valeur par défaut. Foot est le seul retardataire : il n'a aucun moyen de recharger sa configuration, les terminaux en cours d'exécution gardent donc leur ancienne taille jusqu'à ce que vous en ouvriez un nouveau.

### Étendre et dupliquer les écrans d'ordinateur portable

Quand vous connectez un écran externe à votre ordinateur portable, l'affichage est automatiquement étendu. Mais vous pouvez changer cela pour passer en duplication à la place en utilisant _Trigger > Hardware_ dans le menu Omarchy ou `Super + Ctrl + Alt + Delete`. C'est particulièrement utile si cet écran externe est un projecteur, et que vous voulez montrer quelque chose tout en travaillant.

Quand vous êtes en mode étendu, fermer le capot de l'ordinateur portable éteindra automatiquement l'écran interne. Ouvrir le capot le rallumera. Vous pouvez aussi contrôler cela manuellement en utilisant _Trigger > Hardware_ dans le menu Omarchy ou `Super + Ctrl + Delete`.

### Organiser plusieurs écrans

Hyprland fonctionne très bien avec plusieurs écrans. Lisez-en plus sur la façon de les disposer dans [la documentation Hyprland sur les moniteurs](https://wiki.hypr.land/Configuring/Basics/Monitors/). Dans Omarchy, ils vont dans `~/.config/hypr/monitors.lua` sous forme d'entrées `hl.monitor` — le fichier est livré avec des exemples commentés pour épingler un moniteur spécifique à une résolution, une position et une rotation.

Chaque moniteur a ses propres espaces de travail 1 à 10, donc `Super + 1` signifie toujours le premier espace de travail du moniteur sur lequel vous vous trouvez. En coulisses, Hyprland numérote toujours les espaces de travail sur tous les moniteurs : votre écran d'ordinateur portable (ou premier moniteur) obtient 1–10, le moniteur suivant 11–20, et ainsi de suite, et chaque moniteur conserve son bloc chaque fois que vous le branchez. Utilisez ces numéros si vous écrivez des [règles d'espace de travail](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ou des règles de fenêtre pour un moniteur spécifique, de sorte que l'espace de travail 12 est le deuxième espace de travail de votre deuxième moniteur. `~/.local/state/omarchy/monitor-workspaces` liste le bloc que possède chaque moniteur.

Les touches fléchées fonctionnent entre les moniteurs qui partagent un bord dans votre disposition. Les écrans qui ne se touchent qu'à un coin, ou qui ont un espace entre eux, ne sont pas voisins, utilisez donc `Ctrl + Alt + Tab` pour passer de l'un à l'autre.

| Hotkey | Across monitors |
| --- | --- |
| `Super + Arrow` | Déplace le focus vers le moniteur de ce côté une fois qu'il n'y a plus de fenêtre dans cette direction |
| `Super + Shift + Arrow` | Échange avec une fenêtre sur le moniteur de ce côté |
| `Super + Alt + Arrow` | Déplace la fenêtre dans un groupe sur le moniteur de ce côté |
| `Super + Shift + Ctrl + Arrow` | Déplace la fenêtre vers le moniteur de ce côté, sur l'espace de travail qu'il affiche |
| `Super + Shift + Alt + Arrow` | Déplace l'espace de travail vers le moniteur de ce côté, en conservant son numéro s'il est libre |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Déplace le focus vers le moniteur suivant ou précédent, quelle que soit la disposition |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Restent sur le moniteur sur lequel vous vous trouvez |

Vous pouvez aussi jeter un œil à [Hyprmon](https://github.com/erans/hyprmon/), si vous aimeriez un TUI pour vous aider à positionner plusieurs écrans.

### Contrôler la luminosité

La luminosité du moniteur est contrôlée par les touches de fonction dédiées pour augmenter/diminuer la luminosité. Si vous maintenez shift enfoncée tout en appuyant sur ces touches, vous irez à la luminosité maximale ou minimale. Les touches contrôlent l'écran sur lequel vous avez le focus, les moniteurs externes qui parlent DDC/CI sont donc ajustés de la même façon que l'écran de l'ordinateur portable.

### Écrans Apple

Si vous utilisez un écran Apple, les touches habituelles de luminosité du clavier fonctionneront aussi automatiquement, si vous avez le focus sur l'écran Apple. Cela se fait via la commande `asdcontrol`.

Notez que si vous utilisez un écran Apple 6K XDR, vous pouvez voir un écran fantôme dans votre liste `hyprctl monitors`. Vous pouvez désactiver cela avec quelque chose comme `hl.monitor({ output = "DP-2", disabled = true })` via _Setup > Monitors_.

Sur les machines Intel, vous devriez connecter les écrans Apple en utilisant un câble Thunderbolt ordinaire. Sur les autres machines sans Thunderbolt, vous devrez généralement utiliser un [câble DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) pour que cela fonctionne.
