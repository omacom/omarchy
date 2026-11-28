# Dépannage

### J'ai cassé mon système avec une mise à jour !

Essayez d'abord de [restaurer votre système](47-system-snapshots.md) à la version précédant votre récente mise à jour. Si cela ne fonctionne pas, utilisez `omarchy-debug` pour partager votre problème sur #omarchy-help dans le Discord. Et si tout cela échoue, vous pouvez réinstaller les configurations et paquets par défaut à l'aide de `omarchy-reinstall`.

### Pourquoi certaines applications sont-elles si grandes sur mon écran ?

Omarchy suppose que vous avez un écran haute résolution en 2x, donc il définit `GDK_SCALE` à 2 jusqu'à ce que vous choisissiez une échelle dans le panneau des moniteurs. Si vous êtes sur un écran en 1x et que les applications GTK ou X11 s'affichent en surdimensionné, choisissez 1x pour celui-ci dans le panneau des moniteurs, ou ajoutez `hl.env("GDK_SCALE", "1")` à `~/.config/hypr/monitors.lua` (puis redémarrez toute application qui est surdimensionnée). Voir [le manuel sur les moniteurs](33-monitors.md).

Pour Spotify, vous pouvez utiliser `Ctrl + Minus` pour réduire l'interface (et `Ctrl + Plus` pour l'agrandir).

### Pourquoi tous mes raccourcis avec la touche Super ont-ils cessé de fonctionner ?

Sur certains portables ASUS ROG et TUF, `Fn + Super` est un raccourci facile à manquer qui active/désactive un verrouillage firmware de la touche Windows (pensé pour le gaming afin de ne pas quitter un jeu par accident). Rien à l'écran ne vous indique que c'est arrivé. Tant que le verrouillage est actif, Super n'émet absolument rien — donc tous les raccourcis Omarchy qui utilisent Super s'arrêtent simplement, et on dirait que Hyprland est cassé.

Appuyez une fois sur `Fn + Super` avant de fouiller dans `~/.config/hypr/`, et si cela ne ramène pas Super, appuyez à nouveau dessus pour ne pas laisser le verrouillage actif. Ce n'est pas le Fn-lock, qui ne change que le comportement de la rangée de touches F.

### Mon Wi-Fi, Bluetooth, audio ou pavé tactile vient de cesser de fonctionner

Avant de redémarrer, essayez de redémarrer le sous-système fautif tout seul. _Mise à jour > Matériel_ dans le menu Omarchy propose Wi-Fi, Bluetooth, Audio et Pavé tactile, et recharger l'un d'eux résout la majorité des situations du type « ça marchait il y a cinq minutes » — un casque Bluetooth qui refuse de se reconnecter, un pavé tactile devenu inerte après une mise en veille, un son disparu quand vous avez débranché un moniteur.

### Pourquoi mes enceintes externes ne produisent-elles aucun son ?

Probablement parce qu'elles ne sont pas définies comme sortie principale. Cliquez sur l'icône de haut-parleur sur le côté droit de la barre, et cela ouvrira la fenêtre contextuelle de volume où vous pourrez choisir le périphérique de sortie (et mixer aussi les volumes par application).

### Le son des haut-parleurs de mon portable semble bizarre

Sur certains portables, Omarchy applique automatiquement un réglage de haut-parleurs qui corrige la réponse en fréquence des haut-parleurs intégrés. `omarchy audio tuning status` vous indique si un tel réglage est actif sur votre machine, et `omarchy audio tuning off` le désactive si vous préférez entendre les haut-parleurs bruts.

### Pourquoi ne puis-je pas me connecter ou utiliser sudo avec mon mot de passe ?

Vous l'avez probablement mal saisi dix fois et vous vous êtes retrouvé verrouillé. Le verrouillage se lève tout seul au bout de deux minutes. Si vous ne pouvez pas attendre, et que cela se produit sur l'écran de verrouillage, vous pouvez appuyer sur `CTRL + ALT + F2` pour ouvrir un nouveau TTY où vous pourrez vous connecter en tant que root, puis exécuter `faillock --reset --user [your-username]`. Cela réinitialisera le verrouillage, et vous serez prêt à repartir.

### Mon mot de passe est accepté, mais je reviens à l'écran de connexion

Un fichier d'environnement de session cassé peut empêcher le bureau de démarrer même lorsque votre mot de passe est correct. Cela vaut particulièrement la peine d'être vérifié après avoir modifié `~/.config/uwsm/env.d/`.

Appuyez sur `Ctrl + Alt + F2`, connectez-vous avec votre nom d'utilisateur et votre mot de passe habituels, et inspectez le journal utilisateur du démarrage actuel :

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Cherchez une erreur nommant l'un de vos fichiers d'environnement, comme `bad substitution`, juste avant un message indiquant que la marque de sortie env n'a pas été trouvée. Déplacez ce fichier hors de `env.d` avant d'essayer de vous reconnecter. Par exemple, si l'erreur nomme `99-custom` :

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM ignore un fichier comportant une erreur de syntaxe, mais une erreur fatale qui n'apparaît que pendant l'exécution du fichier, comme `bad substitution`, peut quand même empêcher le bureau de démarrer. Une restauration d'instantané système ne répare pas ces fichiers, car `/home` n'est pas restauré.

Une fois que vous pouvez vous connecter, corrigez la copie sauvegardée avant de la remettre en place. `sh -n` détecte les erreurs de syntaxe sans exécuter le fichier, mais ne peut pas détecter toutes les erreurs qui se produisent lorsqu'il est sourcé. Gardez un terminal fonctionnel ouvert pendant que vous testez les modifications.

### Pourquoi mes invites d'autorisation 1Password pour 1Password SSH Agent / CLI n'apparaissent-elles pas ?

Cela peut se produire pour 2 raisons :

Pour que l'invite d'approbation enrichie apparaisse, Paramètres > Avancé > Use Hardware Acceleration doit être activé. _Remarque : Cela nécessite un redémarrage pour commencer à fonctionner._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ou si vous n'avez pas lancé 1Password depuis le démarrage, l'invite n'apparaîtra pas.
