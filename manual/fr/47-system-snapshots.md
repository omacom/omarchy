# Instantanés système

Nous créons des instantanés automatiquement à chaque mise à jour Omarchy, mais si vous voulez créer les vôtres, vous pouvez utiliser `omarchy-snapshot create`.

Pour démarrer et restaurer un instantané, vous le sélectionnez depuis le chargeur de démarrage Limine. (Si vous démarrez actuellement directement sur l'écran de déchiffrement Omarchy, vous devrez d'abord sélectionner Limine comme option de démarrage via le BIOS.)

Depuis cet écran, choisissez l'instantané sur lequel vous voulez démarrer selon la date et la version. La version d'Omarchy au moment de l'instantané se voit dans le coin inférieur gauche.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quand vous arrivez dedans, une notification apparaîtra pour vous signaler que vous êtes dans un instantané amorçable et, si vous cliquez dessus, elle lancera le processus de restauration. Vous pouvez aussi utiliser `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Cela restaurera votre système de fichiers racine, mais pas votre `/home`. Cela fonctionne donc pour revenir sur une mise à jour système cassée, mais pas pour récupérer des fichiers personnels perdus.

Cela signifie aussi que votre répertoire `~/.config` est conservé tel quel. Si vous revenez donc à une version antérieure d'une bibliothèque ou d'une application qui stocke des fichiers de configuration dans un nouveau format, vous devrez régler cela manuellement.

_Remarque : cette fonctionnalité n'est disponible que sur les installations utilisant le chargeur de démarrage Limine, qui est la valeur par défaut depuis Omarchy 2.0. Elle n'est pas disponible si vous êtes sur GRUB ou systemd-boot._

### Éviter le menu de démarrage

Si vous ne touchez jamais au menu de démarrage et voulez simplement que la machine aille directement à l'écran de déchiffrement, lancez _Configuration > Démarrage direct_ dans le menu Omarchy. Cela ajoute une entrée EFI pointant directement sur Omarchy, si bien que le firmware le démarre sans s'arrêter à Limine.

Le compromis est celui mentionné en haut : avec le démarrage direct activé, atteindre un instantané signifie d'abord choisir Limine depuis le menu de démarrage de votre BIOS. Lancez _Configuration > Démarrage direct_ à nouveau pour retirer l'entrée et revenir à un démarrage via Limine. Certains firmwares n'apprécient pas les entrées EFI personnalisées, la configuration refuse donc de s'exécuter sur les firmwares American Megatrends et Apple.
