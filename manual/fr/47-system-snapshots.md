# Instantanés système

Nous créons des instantanés automatiquement à chaque mise à jour d'Omarchy, mais si vous voulez créer le vôtre, vous pouvez utiliser `omarchy-snapshot create`.

La façon dont vous démarrez et restaurez un instantané dépend du chargeur de démarrage avec lequel votre machine démarre. Les nouvelles installations UEFI utilisent systemd-boot ; les installations plus anciennes et les machines BIOS utilisent Limine. `omarchy-boot-backend` vous indique lequel vous avez.

## Avec systemd-boot

Choisissez _System > Snapshots_ dans le menu Omarchy et sélectionnez l'instantané dans lequel vous voulez démarrer. La machine y redémarre une fois. Ou maintenez Space pendant que la machine démarre pour voir le menu de démarrage, où chaque instantané est listé du plus récent au plus ancien avec sa version d'Omarchy et sa date.

Un instantané démarre avec une couche temporaire par-dessus, donc vous pouvez l'utiliser normalement, mais tout ce que vous modifiez disparaît au prochain redémarrage. Pour le conserver, faites-en votre système : cliquez sur la notification qui apparaît lorsque vous vous connectez, choisissez _System > Snapshots > Restore This Snapshot_, ou exécutez `omarchy-snapshot restore`. La restauration a lieu pendant que la machine redémarre. Le système tel qu'il était avant reste dans le menu de démarrage sous le nom _Before restore_, et `omarchy-snapshot restore backup` le remet en place.

Depuis le terminal :

- `omarchy-snapshot list` liste les instantanés dans lesquels vous pouvez démarrer ;
- `omarchy-snapshot boot 12` redémarre une fois dans l'instantané 12 ;
- `omarchy-snapshot restore 12` fait de l'instantané 12 le système au prochain redémarrage, et `omarchy-snapshot restore --cancel` vous permet de changer d'avis avant ce redémarrage.

## Avec Limine

Pour démarrer et restaurer un instantané, vous le sélectionnez depuis le chargeur de démarrage Limine. Le menu de démarrage reste masqué par défaut, donc appuyez sur n'importe quelle touche dès que Limine démarre pour l'afficher.

Depuis cet écran, choisissez l'instantané dans lequel vous voulez démarrer en fonction de la date et de la version. La version d'Omarchy au moment de l'instantané est visible dans le coin inférieur gauche.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Une fois arrivé dedans, une notification apparaîtra pour vous signaler que vous êtes dans un instantané démarrable et, si vous cliquez dessus, elle lancera le processus de restauration. Sinon, vous pouvez utiliser `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Ce que couvre une restauration

Une restauration ramène votre système de fichiers racine, mais pas votre `/home`. Elle fonctionne donc pour annuler une mise à jour système cassée, mais pas pour récupérer des fichiers personnels perdus.

Cela signifie aussi que votre répertoire `~/.config` est conservé tel quel. Donc si vous revenez à une version antérieure d'une bibliothèque ou d'une application qui stocke des fichiers de configuration dans un nouveau format, vous devrez régler ça manuellement.

Il en va de même pour l'enregistrement propre à Omarchy des migrations déjà exécutées : il vit dans votre répertoire personnel, donc il survit à la restauration. Les migrations exécutées après la prise de l'instantané restent marquées comme terminées, même si les modifications qu'elles ont apportées au système de fichiers racine ont été annulées, et la prochaine `omarchy update` ne les exécutera pas à nouveau. Donc si vous mettez à jour à nouveau après une restauration et que quelque chose qu'une mise à jour précédente avait mis en place manque toujours, c'est probablement la raison.
