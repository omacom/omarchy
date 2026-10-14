# Installation en double amorçage

Vous pouvez installer Omarchy sur une seule partition aux côtés de Windows ou d'autres installations.

Cette méthode d'installation inclut toujours le chiffrement LUKS pour la partition par défaut, ce n'est donc effectivement pas différent d'un disque entier et cela requiert simplement de l'espace libre disponible sur le disque.

## Libérer de l'espace sous Windows

Pour installer aux côtés de Windows, tapez `disk management` dans le menu Démarrer et sélectionnez l'option **Créer et formater des partitions de disque dur**.

 ![dual-boot-1](images/dual-boot-1.webp)

Trouvez la partition appropriée, cliquez droit, et choisissez **Réduire le volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Saisissez la quantité de laquelle vous voulez réduire le volume. Notez que ce sera la taille de votre future installation Omarchy, partition de démarrage incluse.

 ![dual-boot-3](images/dual-boot-3.webp)

Quand vous aurez terminé, vous devriez voir quelque chose comme ceci, où la section de 50 Go est l'endroit où nous installerons Omarchy dans cet exemple.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installer Omarchy

Le processus d'installation d'Omarchy est effectivement le même que d'habitude. Après avoir sélectionné votre disque, on vous proposera l'option **Installation dans l'espace libre**. Sélectionnez cette option pour éviter d'effacer tout le disque.

 ![dual-boot-5](images/dual-boot-5.webp)

Vérifiez que tout a l'air bon et attendez que l'installation se termine comme d'habitude. C'est aussi là que vous pourriez choisir d'installer sans chiffrement (déconseillé), tout comme sur une installation sur disque entier.
 ![dual-boot-6](images/dual-boot-6.webp)

## Ajouter les autres installations au chargeur de démarrage

Quand vous terminerez votre installation Omarchy, vous remarquerez que le chargeur de démarrage Limine est désormais celui par défaut. Avec lui, vous pouvez aussi ajouter à Limine des options pour vos autres installations, comme Windows.

Pour ce faire, lancez `limine-scan` et suivez les invites pour ajouter les éléments voulus à votre configuration limine. Quand vous démarrerez, vous verrez alors vos options habituelles pour Omarchy, ainsi que Windows Boot Manager ou d'autres.

## Bitlocker

Il est important de noter que cette méthode d'installation n'est pas compatible avec Bitlocker, car il chiffre tout le disque, pas seulement la partition. Si vous rencontrez une erreur indiquant que Bitlocker est activé, démarrez sous Windows, allez dans **Paramètres -> Confidentialité et sécurité -> Chiffrement de l'appareil** et désactivez Bitlocker. Le déchiffrement du disque peut prendre un certain temps.

 ![dual-boot-7](images/dual-boot-7.webp)
