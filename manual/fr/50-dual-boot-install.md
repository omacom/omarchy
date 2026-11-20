# Installation en dual boot

Vous pouvez installer Omarchy sur une seule partition aux côtés de Windows ou d'autres installations.

Cette méthode d'installation inclut toujours le chiffrement LUKS de la partition par défaut, donc elle n'est concrètement pas différente d'une installation sur l'ensemble du disque et requiert simplement de l'espace libre disponible sur le disque.

## Faire de la place sous Windows

Pour installer Omarchy aux côtés de Windows, tapez `disk management` dans le menu Démarrer et sélectionnez l'option **Créer et formater des partitions de disque dur**.

 ![dual-boot-1](images/dual-boot-1.webp)

Trouvez la partition appropriée, faites un clic droit dessus et choisissez **Réduire le volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Saisissez la taille dont vous souhaitez réduire le volume. Notez que ce sera la taille de votre future installation d'Omarchy, partition de démarrage incluse.

 ![dual-boot-3](images/dual-boot-3.webp)

Lorsque vous avez terminé, vous devriez voir quelque chose de ce genre, où la section de 50GB est celle dans laquelle nous installerons Omarchy dans cet exemple.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installation d'Omarchy

Le processus d'installation d'Omarchy est concrètement identique à la normale. Après avoir sélectionné votre disque, l'option **Installation sur l'espace libre** vous sera proposée. Sélectionnez cette option pour éviter d'effacer l'ensemble du disque.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirmez que tout vous semble correct et attendez la fin de l'installation comme d'habitude. C'est également ici que vous pouvez choisir d'installer le système sans chiffrement (non recommandé), comme pour une installation sur l'ensemble du disque.
 ![dual-boot-6](images/dual-boot-6.webp)

## Ajouter d'autres installations au chargeur de démarrage

Lorsque vous terminerez votre installation d'Omarchy, vous remarquerez que le chargeur de démarrage Limine est désormais celui par défaut. Avec lui, vous pouvez aussi ajouter à Limine des options pour vos autres installations, telles que Windows.

Pour ajouter d'autres systèmes d'exploitation, exécutez `limine-scan` et suivez les invites pour ajouter les entrées souhaitées à votre configuration Limine. Le menu de démarrage reste masqué par défaut et démarre Omarchy au bout d'une seconde. Pour choisir Windows ou une autre entrée, appuyez sur n'importe quelle touche dès que Limine démarre ; lorsque le menu apparaît, utilisez les touches fléchées pour sélectionner une entrée et appuyez sur Enter. Si Omarchy démarre avant que vous ayez appuyé sur une touche, redémarrez et réessayez.

## Bitlocker

Il est important de noter que cette méthode d'installation n'est pas compatible avec Bitlocker, car il chiffre l'ensemble du disque, et pas seulement la partition. Si vous rencontrez une erreur indiquant que Bitlocker est activé, démarrez sous Windows, allez dans **Paramètres -> Confidentialité et sécurité -> Chiffrement de l'appareil** et désactivez Bitlocker. Le déchiffrement du disque peut prendre un certain temps.

 ![dual-boot-7](images/dual-boot-7.webp)
