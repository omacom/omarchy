# Installation en double démarrage

Vous pouvez installer Omarchy sur une seule partition, à côté de Windows ou d'autres installations.

Cette méthode d'installation inclut toujours le chiffrement LUKS de la partition par défaut, elle ne diffère donc concrètement pas d'une installation sur le disque entier et nécessite simplement de l'espace libre sur le disque.

## Libérer de l'espace sous Windows

Pour installer Omarchy à côté de Windows, saisissez `disk management` dans le menu Démarrer et sélectionnez l'option **Créer et formater des partitions de disque dur**.

 ![dual-boot-1](images/dual-boot-1.webp)

Trouvez la partition appropriée, faites un clic droit dessus et choisissez **Réduire le volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Saisissez la quantité dont vous souhaitez réduire le volume. Notez que cela correspondra à la taille de votre future installation d'Omarchy, partition de démarrage incluse.

 ![dual-boot-3](images/dual-boot-3.webp)

Une fois terminé, vous devriez voir quelque chose comme ceci, où la section de 50 Go est celle où nous installerons Omarchy dans cet exemple.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installation d'Omarchy

Le processus d'installation d'Omarchy est concrètement le même que d'habitude. Après avoir sélectionné votre disque, l'option **Installation sur l'espace libre** vous sera proposée. Sélectionnez cette option pour éviter d'effacer l'intégralité du disque.

 ![dual-boot-5](images/dual-boot-5.webp)

Vérifiez que tout semble correct et attendez la fin de l'installation, comme d'habitude. C'est également à cette étape que vous pouvez choisir d'installer le système sans chiffrement (non recommandé), exactement comme pour une installation sur le disque entier.
 ![dual-boot-6](images/dual-boot-6.webp)

## Ajouter d'autres installations au chargeur de démarrage

Une fois l'installation d'Omarchy terminée, vous remarquerez que le chargeur de démarrage Limine est désormais celui par défaut. Avec celui-ci, vous pouvez également ajouter à Limine des options pour vos autres installations, comme Windows.

Pour ajouter d'autres systèmes d'exploitation, exécutez `limine-scan` et suivez les instructions pour ajouter les entrées souhaitées à votre configuration Limine. Le menu de démarrage reste masqué par défaut et démarre Omarchy après une seconde. Pour choisir Windows ou une autre entrée, appuyez sur n'importe quelle touche dès que Limine démarre ; lorsque le menu apparaît, utilisez les touches fléchées pour sélectionner une entrée et appuyez sur Enter. Si Omarchy démarre avant que vous ayez pu appuyer sur une touche, redémarrez et réessayez. Si vous avez activé _Setup > Direct Boot_, le firmware ignore complètement Limine, alors sélectionnez Limine depuis le menu de démarrage de votre BIOS ou exécutez à nouveau _Setup > Direct Boot_ pour supprimer l'entrée.

## Bitlocker

Il est important de noter que cette méthode d'installation n'est pas compatible avec Bitlocker, car celui-ci chiffre l'intégralité du disque, et pas seulement la partition. Si vous rencontrez une erreur indiquant que Bitlocker est activé, démarrez sous Windows, allez dans **Paramètres -> Confidentialité et sécurité -> Chiffrement de l'appareil** et désactivez Bitlocker. Le déchiffrement du disque peut prendre un certain temps.

 ![dual-boot-7](images/dual-boot-7.webp)
