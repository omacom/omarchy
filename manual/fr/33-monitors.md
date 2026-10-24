# Écrans

Omarchy suppose que vous utilisez par défaut un écran de classe retina capable de 2x. C'est ce qu'il vous faut pour obtenir ces belles polices de programmeur bien nettes. C'est ce pour quoi presque tous les nouveaux ordinateurs portables premium avec des écrans haute résolution sont optimisés. C'est ce que vous voudriez utiliser sur un 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ou un 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Mais si vous n'utilisez pas un écran avec un PPI de 218 ou plus, vous voudrez changer les réglages d'écran. Par exemple, si vous avez un 27" ou 32" 4K, vous pouvez utiliser la mise à l'échelle fractionnaire en ouvrant `~/.config/hypr/monitors.lua` (via _Configuration > Écrans_ dans le menu Omarchy) et en passant à la recommandation pour cette combinaison :

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Si vous utilisez un écran 1080p ou 1440p, vous voudrez probablement simplement utiliser une mise à l'échelle 1x, donc vous pouvez utiliser :

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Les changements apportés à `GDK_SCALE` s'appliquent aux applications démarrées après le changement (et GTK n'accepte que des nombres entiers, donc gardez-le à l'entier le plus proche de votre échelle d'écran). Assurez-vous donc de quitter les fenêtres surdimensionnées que vous avez après le changement (ou fermez toutes les fenêtres avec `Ctrl + Alt + Del` !).

Vous pouvez aussi parcourir rapidement les principaux ratios de mise à l'échelle d'écran (1x, 1.25x, 1.6x, 2x, 3x, 4x) en utilisant `Super + /` pour monter et `Super + Alt + /` pour descendre. Si vous avez la configuration par défaut, ces changements persisteront aussi après un redémarrage.

### Rendre le texte plus grand ou plus petit

La mise à l'échelle d'écran change la taille de tout. Si tout ce que vous voulez, c'est un _texte_ plus grand ou plus petit, il y a un seul réglage pour cela :

```
omarchy display text size 14
```

Cela prend une taille en pixels entre 9 et 20, et déplace le shell Omarchy, les applications GTK et votre terminal ensemble, pour que l'ensemble du bureau reste proportionné. Lancez-la sans argument pour voir où vous en êtes, et `omarchy display text size reset` pour revenir à la valeur par défaut. Foot est le seul retardataire : il n'a aucun moyen de recharger sa configuration, donc les terminaux en cours gardent leur ancienne taille jusqu'à ce que vous en ouvriez un nouveau.

### Étendre et recopier les écrans d'ordinateur portable

Quand vous connectez un écran externe à votre ordinateur portable, l'affichage est automatiquement étendu. Mais vous pouvez changer cela en recopie à la place en utilisant _Déclencher > Matériel_ dans le menu Omarchy ou `Super + Ctrl + Alt + Delete`. C'est particulièrement utile si cet écran externe est un projecteur, et que vous voulez montrer quelque chose tout en travaillant.

Quand vous êtes en extension, fermer le capot de l'ordinateur portable éteindra automatiquement l'écran interne. Ouvrir le capot le rallumera. Vous pouvez aussi contrôler cela manuellement en utilisant _Déclencher > Matériel_ dans le menu Omarchy ou `Super + Ctrl + Delete`.

### Organiser plusieurs écrans

Hyprland fonctionne très bien avec plusieurs écrans. Lisez-en plus sur la façon de les disposer dans [la documentation des écrans Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Vous pouvez aussi [lier des espaces de travail spécifiques à des écrans spécifiques](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). Dans Omarchy, ces règles vont dans `~/.config/hypr/monitors.lua` sous forme d'entrées `hl.monitor` — le fichier est livré avec des exemples commentés pour épingler un écran spécifique à une résolution, une position et une rotation.

Vous pouvez aussi consulter [Hyprmon](https://github.com/erans/hyprmon/), si vous souhaitez une TUI pour vous aider avec le positionnement de plusieurs écrans.

### Contrôler la luminosité

La luminosité de l'écran est contrôlée par les touches de fonction dédiées pour augmenter/diminuer la luminosité. Si vous maintenez Shift enfoncé en appuyant dessus, vous passerez à la luminosité maximale ou minimale. Les touches contrôlent l'écran sur lequel vous avez le focus, donc les écrans externes qui parlent DDC/CI sont ajustés de la même façon que l'écran de l'ordinateur portable.

### Écrans Apple

Si vous utilisez un écran Apple, les touches de luminosité classiques du clavier fonctionneront aussi automatiquement, si vous avez le focus sur l'écran Apple. Cela se fait via la commande `asdcontrol`.

Notez que si vous utilisez un écran Apple 6K XDR, vous pouvez voir un écran fantôme dans votre listing `hyprctl monitors`. Vous pouvez désactiver cela avec quelque chose comme `hl.monitor({ output = "DP-2", disabled = true })` via _Configuration > Écrans_.

Sur les machines Intel, vous devriez vous connecter aux écrans Apple avec un câble Thunderbolt classique. Sur d'autres machines sans Thunderbolt, vous devrez généralement utiliser un [câble DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) pour que cela fonctionne.
