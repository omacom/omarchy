# Instantanés du système

Nous créons des instantanés automatiquement à chaque mise à jour d'Omarchy, mais si vous voulez créer le vôtre, vous pouvez utiliser `omarchy-snapshot create`.

Pour démarrer et restaurer un instantané, vous le sélectionnez depuis le chargeur de démarrage Limine. (Si vous démarrez actuellement directement sur l'écran de déchiffrement d'Omarchy, vous devrez d'abord sélectionner Limine comme option de démarrage via le BIOS).

Depuis cet écran, choisissez l'instantané sur lequel vous voulez démarrer en fonction de la date et de la version. La version d'Omarchy au moment de l'instantané est visible dans le coin inférieur gauche.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quand vous arrivez dedans, une notification apparaîtra pour vous prévenir que vous êtes dans un instantané démarrable et, si vous cliquez dessus, elle lancera le processus de restauration. Sinon, vous pouvez utiliser `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Cela restaurera votre système de fichiers racine, mais pas votre `/home`. Donc ça marche pour annuler une mise à jour système cassée, mais pas pour récupérer des fichiers personnels perdus.

Cela signifie aussi que votre répertoire `~/.config` est conservé tel quel. Donc si vous revenez à une version antérieure d'une bibliothèque ou d'une application qui stocke des fichiers de configuration dans un nouveau format, vous devrez régler ça manuellement.

Il en va de même pour l'enregistrement par Omarchy des migrations déjà exécutées : il vit dans votre répertoire personnel, donc il survit à la restauration. Les migrations exécutées après la prise de l'instantané restent marquées comme terminées, même si les changements qu'elles ont apportés au système de fichiers racine ont été annulés, et la prochaine `omarchy update` ne les exécutera pas à nouveau. Donc si vous mettez à jour à nouveau après une restauration et que quelque chose qu'une mise à jour précédente avait mis en place manque toujours, c'est probablement la raison.

_Note : Cette fonctionnalité n'est disponible que sur les installations utilisant le chargeur de démarrage Limine, qui est le défaut depuis Omarchy 2.0. Elle n'est pas disponible si vous êtes sur GRUB ou systemd-boot._

### Ignorer le menu de démarrage

Si vous ne touchez jamais au menu de démarrage et que vous voulez simplement que la machine aille directement à l'écran de déchiffrement, lancez _Setup > Direct Boot_ dans le menu Omarchy. Cela ajoute une entrée EFI pointant directement vers Omarchy, pour que le firmware le démarre sans s'arrêter sur Limine.

Le compromis est celui mentionné en haut : avec le démarrage direct activé, accéder à un instantané signifie d'abord choisir Limine depuis le menu de démarrage de votre BIOS. Lancez à nouveau _Setup > Direct Boot_ pour supprimer l'entrée et revenir à un démarrage via Limine. Certains firmwares n'apprécient pas les entrées EFI personnalisées, donc l'installation refuse de s'exécuter sur les firmwares American Megatrends et Apple.
