# Instantanés système

Nous créons des instantanés automatiquement à chaque mise à jour d’Omarchy, mais si vous voulez créer le vôtre, vous pouvez utiliser `omarchy-snapshot create`.

Pour démarrer sur un instantané et le restaurer, sélectionnez-le dans le chargeur de démarrage Limine. Le menu de démarrage reste masqué par défaut, alors appuyez sur n’importe quelle touche dès que Limine démarre pour l’afficher.

Depuis cet écran, choisissez l’instantané sur lequel vous voulez démarrer en fonction de la date et de la version. La version d’Omarchy au moment de l’instantané est visible dans le coin inférieur gauche.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Une fois dedans, une notification apparaîtra pour vous signaler que vous êtes dans un instantané démarrable et, si vous cliquez dessus, elle lancera le processus de restauration. Sinon, vous pouvez utiliser `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Cela restaurera votre système de fichiers racine, mais pas votre `/home`. Cela fonctionne donc pour annuler une mise à jour système cassée, mais pas pour récupérer des fichiers personnels perdus.

Cela signifie aussi que votre répertoire `~/.config` est conservé tel quel. Donc si vous revenez à une version antérieure d’une bibliothèque ou d’une application qui stocke des fichiers de configuration dans un nouveau format, vous devrez régler ça manuellement.

Il en va de même pour l’historique propre à Omarchy des migrations déjà exécutées : il vit dans votre répertoire personnel, donc il survit à la restauration. Les migrations exécutées après la prise de l’instantané restent marquées comme terminées, même si les changements qu’elles ont apportés au système de fichiers racine ont été annulés, et la prochaine `omarchy update` ne les exécutera pas à nouveau. Donc si vous refaites une mise à jour après une restauration et que quelque chose qu’une mise à jour précédente avait mis en place manque toujours, c’est probablement la raison.

_Remarque : Cette fonctionnalité n’est disponible que sur les installations utilisant le chargeur de démarrage Limine, qui est le choix par défaut depuis Omarchy 2.0. Elle n’est pas disponible si vous êtes sur GRUB ou systemd-boot._
