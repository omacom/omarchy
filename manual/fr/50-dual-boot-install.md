# Installation en double démarrage

Vous pouvez installer Omarchy sur une seule partition aux côtés de Windows ou d'autres installations.

Cette méthode d'installation inclut toujours le chiffrement LUKS pour la partition par défaut, elle n'est donc en pratique pas différente d'une installation sur tout le disque et nécessite simplement de l'espace libre disponible sur le disque.

## Libérer de l'espace sous Windows

Pour installer Omarchy aux côtés de Windows, tapez `disk management` dans le menu Démarrer et sélectionnez l'option **Créer et formater des partitions de disque dur**.

 ![dual-boot-1](images/dual-boot-1.webp)

Trouvez la partition appropriée, faites un clic droit et choisissez **Réduire le volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Saisissez la quantité dont vous souhaitez réduire le volume. Notez que ce sera la taille de votre future installation d'Omarchy, partition de démarrage incluse.

 ![dual-boot-3](images/dual-boot-3.webp)

Quand vous avez terminé, vous devriez voir quelque chose comme ceci, où la section de 50GB est l'endroit où nous installerons Omarchy dans cet exemple.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installation d'Omarchy

Le processus d'installation d'Omarchy est en pratique le même que d'habitude. Après avoir sélectionné votre disque, vous aurez l'option **Installation dans l'espace libre**. Sélectionnez cette option pour éviter d'effacer tout le disque.

 ![dual-boot-5](images/dual-boot-5.webp)

Vérifiez que tout semble correct et attendez que l'installation se termine comme d'habitude. C'est aussi là que vous pouvez choisir d'installer sans chiffrement (non recommandé), comme pour une installation sur tout le disque.
 ![dual-boot-6](images/dual-boot-6.webp)

## Ajout d'autres installations au chargeur de démarrage

Une fois l'installation d'Omarchy terminée, vous remarquerez que le chargeur de démarrage Limine est désormais celui par défaut. Avec lui, vous pouvez aussi ajouter à Limine des options pour vos autres installations, comme Windows.

Pour ajouter d'autres systèmes d'exploitation, exécutez `limine-scan` et suivez les invites pour ajouter les entrées souhaitées à votre configuration Limine. Le menu de démarrage reste masqué par défaut et lance Omarchy au bout d'une seconde. Pour choisir Windows ou une autre entrée, appuyez sur n'importe quelle touche dès que Limine démarre ; lorsque le menu apparaît, utilisez les touches fléchées pour sélectionner une entrée et appuyez sur Enter. Si Omarchy démarre avant que vous ayez appuyé sur une touche, redémarrez et réessayez.

## Bitlocker

Il est important de noter que cette méthode d'installation n'est pas compatible avec Bitlocker, car il chiffre l'intégralité du disque, et pas seulement la partition. Si vous rencontrez une erreur indiquant que Bitlocker est activé, démarrez sous Windows, allez dans **Paramètres -> Confidentialité et sécurité -> Chiffrement de l'appareil** et désactivez Bitlocker. Le déchiffrement du disque peut prendre un certain temps.

 ![dual-boot-7](images/dual-boot-7.webp)

## Réinstallation de Windows

Si cet ordinateur a été livré avec Windows, sa clé de produit est stockée dans le firmware. Exécutez `omarchy windows key` pour l'afficher, afin de pouvoir réactiver Windows si vous le réinstallez un jour sur cette machine.
