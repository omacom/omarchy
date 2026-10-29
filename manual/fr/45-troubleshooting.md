# Dépannage

### J'ai cassé mon système avec une mise à jour !

Essayez d'abord de [restaurer votre système](47-system-snapshots.md) à la version précédant votre récente mise à jour. Si ça ne fonctionne pas, utilisez `omarchy-debug` pour partager votre problème sur #omarchy-help dans le Discord. Et si tout ça échoue, vous pouvez réinstaller les configurations et les paquets par défaut avec `omarchy-reinstall`.

### Pourquoi certaines applications sont-elles si grandes sur mon écran ?

Omarchy suppose un écran haute résolution en 2x, ce qui nécessite de définir `GDK_SCALE` à 2 dans `~/.config/hypr/monitors.lua`. Mais si vous êtes sur un écran en 1x, vous pouvez changer `local omarchy_gdk_scale = 2` en 1 (puis redémarrer toute application surdimensionnée). Voir [le manuel sur les moniteurs](33-monitors.md).

Pour Spotify, vous pouvez utiliser `Ctrl + Minus` pour réduire l'interface (et `Ctrl + Plus` pour l'agrandir).

### Pourquoi tous mes raccourcis avec la touche Super ont-ils cessé de fonctionner ?

Sur certains portables ASUS ROG et TUF, `Fn + Super` est un raccourci facile à déclencher sans s'en rendre compte qui bascule un verrouillage de la touche Windows au niveau du firmware (pensé pour le jeu, pour ne pas quitter une partie par accident). Rien à l'écran ne vous indique que c'est arrivé. Tant que le verrouillage est actif, Super n'émet absolument rien — donc tous les raccourcis Omarchy qui utilisent Super s'arrêtent tout simplement, et on dirait que Hyprland est cassé.

Appuyez une fois sur `Fn + Super` avant de fouiller dans `~/.config/hypr/`, et si ça ne ramène pas Super, appuyez à nouveau dessus pour ne pas laisser le verrouillage actif. Ce n'est pas le verrouillage Fn, qui modifie uniquement le comportement de la rangée de touches F.

### Mon Wi-Fi, mon Bluetooth, mon audio ou mon trackpad vient de cesser de fonctionner

Avant de redémarrer, essayez de redémarrer uniquement le sous-système fautif. _Update > Hardware_ dans le menu Omarchy propose Wi-Fi, Bluetooth, Audio et Trackpad, et recharger l'un d'eux résout la majorité des situations du type « ça marchait il y a cinq minutes » — un casque Bluetooth qui refuse de se reconnecter, un trackpad devenu inerte après une mise en veille, un son disparu quand vous avez débranché un moniteur.

### Pourquoi mes enceintes externes ne produisent-elles aucun son ?

Probablement parce qu'elles ne sont pas définies comme sortie principale. Cliquez sur l'icône de haut-parleur à droite de la barre, et cela ouvrira la fenêtre contextuelle de volume où vous pourrez choisir le périphérique de sortie (et aussi régler les volumes par application).

### Les haut-parleurs de mon portable ont un son bizarre

Sur certains portables, Omarchy applique automatiquement un réglage des haut-parleurs qui corrige la réponse en fréquence des haut-parleurs intégrés. `omarchy audio tuning status` vous indique si un réglage est actif sur votre machine, et `omarchy audio tuning off` le désactive si vous préférez entendre les haut-parleurs bruts.

### Pourquoi ne puis-je pas me connecter ou utiliser sudo avec mon mot de passe ?

Vous l'avez probablement mal saisi trop de fois et vous avez été bloqué. Si cela se produit sur l'écran de verrouillage, vous pouvez appuyer sur `CTRL + ALT + F2` pour démarrer un nouveau TTY où vous pourrez vous connecter en tant que root, puis exécuter `faillock --reset --user [your-username]`. Cela réinitialisera le blocage, et vous pourrez repartir.

### Pourquoi les invites d'autorisation de 1Password pour 1Password SSH Agent / CLI n'apparaissent-elles pas ?

Cela peut se produire pour 2 raisons :

Pour que l'invite d'approbation enrichie apparaisse, Settings > Advanced > Use Hardware Acceleration doit être activé. _Note : un redémarrage est nécessaire pour que cela commence à fonctionner._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ou si vous n'avez pas lancé 1Password depuis le démarrage, l'invite n'apparaîtra pas.
