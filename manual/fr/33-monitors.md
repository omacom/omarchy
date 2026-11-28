# Moniteurs

Omarchy part du principe que vous utilisez par défaut un écran de classe retina capable de 2x. C'est ce qu'il vous faut pour obtenir ces polices de programmeur belles et nettes. C'est ce pour quoi presque tous les nouveaux ordinateurs portables haut de gamme avec des écrans haute résolution sont optimisés. C'est ce que vous voudrez utiliser sur un 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ou 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Mais si vous n'utilisez pas un écran avec une densité de 218 PPI ou plus, vous voudrez modifier les paramètres du moniteur. Par exemple, si vous avez un 27" ou 32" 4K, vous pouvez choisir une échelle fractionnaire pour celui-ci depuis le panneau du moniteur dans la barre supérieure, ou définir la valeur par défaut pour chaque moniteur en ouvrant `~/.config/hypr/monitors.lua` et en passant à la recommandation pour cette combinaison :

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Si vous utilisez un écran 1080p ou 1440p, vous voudrez probablement simplement utiliser une échelle 1x, et la même chose pour les applications GTK et X11, donc vous pouvez utiliser :

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Les modifications de `GDK_SCALE` s'appliquent aux applications lancées après le changement (et GTK n'accepte que les nombres entiers, donc gardez-le à l'entier le plus proche de l'échelle de votre moniteur). Assurez-vous donc de quitter les fenêtres que vous avez qui sont surdimensionnées après le changement (ou fermez toutes les fenêtres avec `Ctrl + Alt + Del` !).

Vous pouvez aussi parcourir rapidement les principaux ratios d'échelle du moniteur (1x, 1.25x, 1.6x, 2x, 3x, 4x) en utilisant `Super + /` pour augmenter et `Super + Alt + /` pour diminuer, ou en choisir un depuis le panneau du moniteur dans la barre supérieure. Ceux-ci ne modifient que le moniteur sur lequel vous êtes concentré, donc un écran d'ordinateur portable et un écran externe peuvent chacun avoir leur propre échelle. Le panneau définit aussi la résolution, le taux de rafraîchissement et la rotation de chaque moniteur. Vos choix sont enregistrés pour ce moniteur physique dans `~/.local/state/omarchy/monitors/settings`, donc ils persistent après un redémarrage et suivent le moniteur quel que soit le port ou la station d'accueil sur lequel il est branché ensuite. Ils ont la priorité sur toute règle pour le même moniteur dans `~/.config/hypr/monitors.lua`, qu'Omarchy ne modifie jamais. Si vous préférez définir vos moniteurs entièrement dans ce fichier, ajoutez `omarchy_monitor_panel_settings = false` à celui-ci, et les modifications du panneau ne dureront que jusqu'au rechargement de Hyprland. Comme `GDK_SCALE` est une seule valeur pour tous les écrans, une échelle choisie le définit à partir du moniteur avec l'échelle la plus faible, donc les applications X11 ressortent un peu petites sur l'écran le plus dense plutôt que surdimensionnées sur l'autre.

### Agrandir ou réduire le texte

La mise à l'échelle du moniteur modifie la taille de tout. Si tout ce que vous voulez, c'est un _texte_ plus grand ou plus petit, il y a un seul réglage pour cela :

```
omarchy display text size 14
```

Celui-ci prend une taille en pixels entre 9 et 20, et fait évoluer ensemble le shell Omarchy, les applications GTK et votre terminal, donc tout le bureau reste proportionné. Lancez-le sans argument pour voir où vous en êtes, et `omarchy display text size reset` pour revenir à la valeur par défaut. Foot est le seul retardataire : il n'a aucun moyen de recharger sa configuration, donc les terminaux en cours conservent leur ancienne taille jusqu'à ce que vous en ouvriez un nouveau.

### Étendre et dupliquer les écrans d'ordinateur portable

Quand vous branchez un écran externe à votre ordinateur portable, l'affichage est automatiquement étendu. Mais vous pouvez passer à la duplication à la place avec _Extend_ | _Mirror_ dans le panneau du moniteur dans la barre supérieure, _Trigger > Hardware_ dans le menu Omarchy, ou `Super + Ctrl + Alt + Delete`. C'est particulièrement utile si cet écran externe est un projecteur, et que vous voulez montrer quelque chose tout en travaillant.

Quand vous êtes en mode étendu, fermer le capot de l'ordinateur portable désactivera automatiquement l'écran interne. Ouvrir le capot le réactivera. Vous pouvez aussi contrôler cela manuellement en utilisant _Trigger > Hardware_ dans le menu Omarchy ou `Super + Ctrl + Delete`.

Tant que l'ordinateur portable est branché, fermer le capot ne le met jamais en veille, donc un ordinateur portable sur station d'accueil reste éveillé même si l'écran externe se déconnecte brièvement. Sans aucun écran externe raccordé, fermer le capot sur alimentation le verrouille simplement. Sur batterie, fermer le capot le met en suspension comme d'habitude.

### Disposer plusieurs écrans

Hyprland fonctionne très bien avec plusieurs écrans. Le panneau du moniteur dans la barre supérieure les dessine là où ils se trouvent : faites-en glisser un contre le côté d'un autre pour le déplacer à cet endroit, et la disposition est enregistrée avec les autres paramètres de chaque moniteur. Pour tout ce que le panneau ne couvre pas, lisez-en plus sur la façon de les disposer dans [la documentation Hyprland sur les moniteurs](https://wiki.hypr.land/Configuring/Basics/Monitors/). Dans Omarchy, ceux-ci vont dans `~/.config/hypr/monitors.lua` sous forme d'entrées `hl.monitor` — le fichier est livré avec des exemples commentés pour garder un moniteur éteint, les modes que le panneau ne propose pas, la couleur 10-bit et le taux de rafraîchissement variable.

Chaque moniteur a ses propres espaces de travail 1 à 10, donc `Super + 1` désigne toujours le premier espace de travail du moniteur sur lequel vous êtes. En coulisses, Hyprland numérote toujours les espaces de travail sur tous les moniteurs : votre écran d'ordinateur portable (ou premier moniteur) obtient 1–10, le moniteur suivant 11–20, et ainsi de suite, et chaque moniteur conserve son bloc chaque fois que vous le branchez. Utilisez ces numéros si vous écrivez des [règles d'espaces de travail](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ou des règles de fenêtres pour un moniteur précis, donc l'espace de travail 12 est le deuxième espace de travail de votre deuxième moniteur. `~/.local/state/omarchy/monitors/workspaces` liste quel bloc chaque moniteur possède.

Les touches fléchées fonctionnent entre les moniteurs qui partagent un bord dans votre disposition. Les écrans qui ne se touchent qu'à un coin, ou qui ont un écart entre eux, ne sont pas voisins, donc utilisez `Ctrl + Alt + Tab` pour passer de l'un à l'autre.

| Raccourci clavier | Entre les moniteurs |
| --- | --- |
| `Super + Arrow` | Déplace le focus vers le moniteur de ce côté une fois qu'il n'y a plus de fenêtre dans cette direction |
| `Super + Shift + Arrow` | Échange avec une fenêtre sur le moniteur de ce côté |
| `Super + Alt + Arrow` | Déplace la fenêtre dans un groupe sur le moniteur de ce côté |
| `Super + Shift + Ctrl + Arrow` | Déplace la fenêtre vers le moniteur de ce côté, sur l'espace de travail qu'il affiche |
| `Super + Shift + Alt + Arrow` | Déplace l'espace de travail vers le moniteur de ce côté, en conservant son numéro s'il est libre |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Déplace le focus vers le moniteur suivant ou précédent, quelle que soit la disposition |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Restent sur le moniteur sur lequel vous êtes |

Vous pouvez aussi découvrir [Hyprmon](https://github.com/erans/hyprmon/), si vous voulez un TUI pour vous aider à positionner plusieurs écrans.

### Contrôler la luminosité

La luminosité du moniteur est contrôlée par les touches de fonction dédiées pour augmenter/diminuer la luminosité. Si vous maintenez Shift enfoncée tout en appuyant sur celles-ci, vous irez à la luminosité maximale ou minimale. Les touches contrôlent l'écran sur lequel vous êtes concentré, donc les moniteurs externes qui parlent DDC/CI se règlent de la même manière que l'écran de l'ordinateur portable.

### Écrans Apple

Si vous utilisez un écran Apple, les touches habituelles de luminosité du clavier fonctionneront aussi automatiquement, si vous êtes concentré sur l'écran Apple. Cela se fait via la commande `asdcontrol`.

Notez que si vous utilisez un écran Apple 6K XDR, vous pouvez voir un écran fantôme dans votre liste `hyprctl monitors`. Vous pouvez désactiver cela avec quelque chose comme `hl.monitor({ output = "DP-2", disabled = true })` dans `~/.config/hypr/monitors.lua`.

Sur les machines Intel, vous devriez brancher les écrans Apple en utilisant un câble Thunderbolt ordinaire. Sur les autres machines sans Thunderbolt, vous devrez généralement utiliser un [câble DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) pour que cela fonctionne.
