# Dépannage

### J'ai cassé mon système avec une mise à jour !

Essayez d'abord de [restaurer votre système](47-system-snapshots.md) à la version d'avant votre récente mise à jour. Si ça ne marche pas, utilisez `omarchy-debug` pour partager votre problème sur #omarchy-help dans le Discord. Et si tout ça échoue, vous pouvez réinstaller les configurations et paquets par défaut en utilisant `omarchy-reinstall`.

### Pourquoi certaines applications sont-elles si grandes sur mon écran ?

Omarchy part du principe que vous avez un écran haute résolution en 2x, donc il définit `GDK_SCALE` à 2 jusqu'à ce que vous choisissiez une échelle dans le panneau du moniteur. Si vous êtes sur un écran 1x et que les applications GTK ou X11 s'affichent en énorme, choisissez 1x pour celui-ci dans le panneau du moniteur, ou ajoutez `hl.env("GDK_SCALE", "1")` à `~/.config/hypr/monitors.lua` (puis redémarrez toute application surdimensionnée). Voir [le manuel sur les moniteurs](33-monitors.md).

Pour Spotify, vous pouvez utiliser `Ctrl + Minus` pour réduire l'interface (et `Ctrl + Plus` pour l'agrandir).

### Pourquoi toutes mes combinaisons de touches avec Super ont-elles cessé de fonctionner ?

Sur certains portables ASUS ROG et TUF, `Fn + Super` est une combinaison facile à manquer qui bascule un verrouillage firmware de la touche Windows (pensé pour le jeu, pour que vous ne quittiez pas une partie par accident). Rien à l'écran ne vous dit que c'est arrivé. Tant que le verrouillage est actif, Super n'émet absolument rien — donc toutes les combinaisons Omarchy qui utilisent Super s'arrêtent net, et on dirait que Hyprland est cassé.

Appuyez une fois sur `Fn + Super` avant de fouiller dans `~/.config/hypr/`, et si ça ne ramène pas Super, appuyez à nouveau dessus pour ne pas laisser le verrouillage actif. Ce n'est pas le Fn-lock, qui change seulement ce que fait la rangée de touches F.

### Mon Wi-Fi, mon Bluetooth, mon audio ou mon trackpad viennent d'arrêter de fonctionner

Avant de redémarrer, essayez de redémarrer le sous-système fautif tout seul. _Update > Hardware_ dans le menu Omarchy propose Wi-Fi, Bluetooth, Audio et Trackpad, et recharger l'un d'eux résout la majorité des situations « ça marchait il y a cinq minutes » — un casque Bluetooth qui ne veut pas se reconnecter, un trackpad mort après une mise en veille, du son disparu quand vous avez débranché un moniteur.

### Pourquoi mes haut-parleurs externes ne produisent-ils aucun son ?

Probablement parce qu'ils ne sont pas définis comme sortie principale. Cliquez sur l'icône de haut-parleur à droite de la barre, et ça ouvrira le popup de volume où vous pourrez choisir le périphérique de sortie (et mixer aussi les volumes par application).

### Les haut-parleurs de mon portable sonnent bizarrement

Sur certains portables, Omarchy applique automatiquement un réglage des haut-parleurs qui corrige la réponse en fréquence des haut-parleurs intégrés. `omarchy audio tuning status` vous dit si un réglage est actif sur votre machine, et `omarchy audio tuning off` le désactive si vous préférez entendre les haut-parleurs bruts.

### Pourquoi je ne peux pas me connecter ou utiliser sudo avec mon mot de passe ?

Vous l'avez probablement mal tapé trop de fois et vous vous êtes fait verrouiller dehors. Si ça arrive sur l'écran de verrouillage, vous pouvez appuyer sur `CTRL + ALT + F2` pour démarrer un nouveau TTY où vous pourrez vous connecter en root, puis lancer `faillock --reset --user [your-username]`. Ça réinitialisera le verrouillage, et vous serez reparti.

### Pourquoi les invites d'autorisation 1Password pour 1Password SSH Agent / CLI n'apparaissent-elles pas ?

Ça peut arriver pour 2 raisons :

Pour que l'invite d'approbation riche apparaisse, Settings > Advanced > Use Hardware Acceleration doit être activé. _Remarque : ça nécessite un redémarrage pour commencer à fonctionner._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ou si vous n'avez pas lancé 1Password depuis le démarrage, l'invite n'apparaîtra pas.
