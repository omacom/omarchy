# Dépannage

### J'ai cassé mon système avec une mise à jour !

Essayez d'abord de [restaurer votre système](47-system-snapshots.md) à la version qui précédait votre récente mise à jour. Si ça ne fonctionne pas, utilisez `omarchy-debug` pour partager votre problème sur #omarchy-help dans le Discord. Et si tout ça échoue, vous pouvez réinstaller les configurations et les paquets par défaut à l'aide de `omarchy-reinstall`.

### Pourquoi certaines applications sont-elles si grandes sur mon écran ?

Omarchy part du principe que vous avez un écran haute résolution en 2x, donc il définit `GDK_SCALE` à 2 jusqu'à ce que vous choisissiez une échelle dans le panneau des écrans. Si vous êtes sur un écran en 1x et que les applications GTK ou X11 s'affichent en surdimensionné, choisissez 1x pour celui-ci dans le panneau des écrans, ou ajoutez `hl.env("GDK_SCALE", "1")` à `~/.config/hypr/monitors.lua` (puis redémarrez toute application surdimensionnée). Voir [le manuel sur les écrans](33-monitors.md).

Pour Spotify, vous pouvez utiliser `Ctrl + Minus` pour réduire l'interface (et `Ctrl + Plus` pour l'agrandir).

### Pourquoi tous mes raccourcis avec la touche Super ont-ils cessé de fonctionner ?

Sur certains ordinateurs portables ASUS ROG et TUF, `Fn + Super` est une combinaison facile à manquer qui active ou désactive un verrouillage firmware de la touche Windows (pensé pour le jeu, pour ne pas quitter une partie par accident). Rien à l'écran ne vous indique que c'est arrivé. Tant que le verrouillage est actif, Super n'émet absolument rien — donc tous les raccourcis Omarchy qui utilisent Super cessent simplement de fonctionner, et on dirait que Hyprland est cassé.

Appuyez une fois sur `Fn + Super` avant de fouiller dans `~/.config/hypr/`, et si ça ne ramène pas Super, appuyez à nouveau dessus pour ne pas laisser le verrouillage actif. Ce n'est pas le Fn-lock, qui change seulement le comportement de la rangée de touches F.

### Mon Wi-Fi, mon Bluetooth, mon audio ou mon pavé tactile viennent de cesser de fonctionner

Avant de redémarrer, essayez de redémarrer le sous-système fautif tout seul. _Mise à jour > Matériel_ dans le menu Omarchy propose Wi-Fi, Bluetooth, Audio et Pavé tactile, et recharger l'un de ceux-ci règle la majorité des situations du type « ça marchait il y a cinq minutes » — un casque Bluetooth qui ne veut pas se reconnecter, un pavé tactile devenu inerte après une mise en veille, un son qui a disparu quand vous avez débranché un écran.

### Pourquoi mes enceintes externes ne produisent-elles aucun son ?

Probablement parce qu'elles ne sont pas définies comme sortie principale. Cliquez sur l'icône de haut-parleur à droite de la barre, et ça ouvrira la fenêtre contextuelle de volume où vous pouvez choisir le périphérique de sortie (et aussi régler le volume par application).

### Le son des haut-parleurs de mon ordinateur portable est bizarre

Sur certains ordinateurs portables, Omarchy applique automatiquement un réglage des haut-parleurs qui corrige la réponse en fréquence des haut-parleurs intégrés. `omarchy audio tuning status` vous indique si un réglage est actif sur votre machine, et `omarchy audio tuning off` le désactive si vous préférez entendre les haut-parleurs sans correction.

### Pourquoi je ne peux pas me connecter ni utiliser sudo avec mon mot de passe ?

Vous l'avez probablement mal tapé trop de fois et vous vous êtes fait verrouiller dehors. Si ça vous arrive sur l'écran de verrouillage, vous pouvez appuyer sur `CTRL + ALT + F2` pour démarrer un nouveau TTY où vous pouvez vous connecter en tant que root, puis exécuter `faillock --reset --user [your-username]`. Ça réinitialisera le verrouillage, et vous serez reparti.

### Mon mot de passe est accepté, mais je reviens à l'écran de connexion

Un fichier d'environnement de session cassé peut empêcher le bureau de démarrer même quand votre mot de passe est correct. C'est particulièrement à vérifier après avoir modifié `~/.config/uwsm/env.d/`.

Appuyez sur `Ctrl + Alt + F2`, connectez-vous avec votre nom d'utilisateur et votre mot de passe habituels, et inspectez le journal utilisateur du démarrage en cours :

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Cherchez une erreur nommant l'un de vos fichiers d'environnement, comme `bad substitution`, juste avant un message indiquant que la marque de sortie de l'environnement est introuvable. Déplacez ce fichier hors de `env.d` avant d'essayer de vous reconnecter. Par exemple, si l'erreur nomme `99-custom` :

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM ignore un fichier contenant une erreur de syntaxe, mais une erreur fatale qui n'apparaît que pendant l'exécution du fichier, comme `bad substitution`, peut quand même empêcher le bureau de démarrer. Une restauration d'instantané système ne répare pas ces fichiers, parce que `/home` n'est pas restauré.

Une fois que vous pouvez vous connecter, corrigez la copie sauvegardée avant de la remettre en place. `sh -n` détecte les erreurs de syntaxe sans exécuter le fichier, mais ne peut pas détecter toutes les erreurs qui se produisent quand il est sourcé. Gardez un terminal fonctionnel ouvert pendant que vous testez les modifications.

### Pourquoi mes invites d'autorisation 1Password pour 1Password SSH Agent / CLI n'apparaissent-elles pas ?

Cela peut arriver pour 2 raisons :

Pour que l'invite d'approbation enrichie apparaisse, Paramètres > Avancé > Utiliser l'accélération matérielle doit être activé. _Remarque : Cela nécessite un redémarrage pour commencer à fonctionner._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ou si vous n'avez pas lancé 1Password depuis le démarrage, l'invite n'apparaîtra pas.
