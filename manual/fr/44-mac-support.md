# Prise en charge des Mac

Omarchy prend en charge nativement les **Mac Intel**. Il existe pour le moment quelques limitations connues, mais tant que vous en êtes conscient et que cela vous convient ; vous pouvez redonner un nouveau souffle à vos vieux Mac en y installant Omarchy.

Veuillez noter que l'installation sur un Mac de série M n'est pas directement prise en charge pour le moment. Vous pouvez en savoir plus sur l'état des choses dans #omarchy-on-other sur notre [Discord](https://discord.gg/tXFUdasqhY).

Lors d'un simple test, nous avons obtenu des gains de performance de 36% simplement en installant Omarchy sur un MacBook Pro de 2019.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installer Omarchy sur Mac

Omarchy ne prend en charge pour le moment que le cas où il est le **seul** OS installé. Pendant l'installation, le disque sera effacé et MacOS ne pourra plus démarrer.

Vous pourrez toujours le restaurer plus tard via Internet Recovery si vous le souhaitez.

Pour cette partie, nous supposerons que vous avez déjà consulté [Bien démarrer](02-getting-started.md) et que votre clé USB est prête. Si ce n'est pas le cas, faites-le maintenant.

#### Désactiver Secure Boot

Il est nécessaire de désactiver Secure Boot d'Apple pour pouvoir démarrer la clé USB bootable, ainsi que l'OS. Pour le désactiver, procédez comme suit :

1. Éteignez votre Mac
2. Allumez-le et appuyez _immédiatement_ sur Command-R en maintenant les touches enfoncées jusqu'à ce que l'écran de chargement apparaisse
3. Sélectionnez votre utilisateur et saisissez votre mot de passe si on vous le demande
4. Une fois sur l'écran de récupération, choisissez **Utilities > Startup Security Utility** dans la barre de menus
5. Saisissez votre mot de passe lorsqu'on vous demande de vous authentifier
6. Choisissez "No Security" parmi les options de Secure Boot
7. Choisissez "Allow booting from external or removable media" parmi les options External Boot

#### Lancer l'installation

1. Insérez la clé USB
2. Redémarrez votre Mac et appuyez _immédiatement_ sur Option en maintenant la touche enfoncée jusqu'à ce que vous voyiez un écran listant les périphériques de démarrage
3. Sélectionnez le périphérique EFI Boot orange
4. Procédez à [l'installation comme d'habitude](02-getting-started.md)

L'installateur détecte le matériel Mac et applique automatiquement les correctifs nécessaires : les pilotes et le firmware Wi-Fi Broadcom, le pilote de clavier SPI sur les modèles de MacBook qui en ont besoin, et un correctif de suspension NVMe pour ces mêmes modèles.

### Limitations connues

Des membres de la communauté travaillent en permanence sur des solutions à ces défis, donc si cela pose problème pour vous, rejoignez #omarchy-on-other sur notre [Discord](https://discord.gg/tXFUdasqhY) et voyez s'il existe des méthodes à jour pour les résoudre.

#### Appareils avec puce T1

La puce Apple T1 a été introduite fin 2016 et utilisée exclusivement dans les modèles de MacBook Pro de première génération avec Touch Bar.
- MacBook Pro 13 pouces (2016, deux ports Thunderbolt 3) – Modèle : A1706
- MacBook Pro 13 pouces (2016, quatre ports Thunderbolt 3) – Modèle : A1708
- MacBook Pro 15 pouces (2016) – Modèle : A1707

#### Problèmes connus

- La Touch Bar ne fonctionne pas
- Le son ne fonctionne pas

#### Appareils avec puce T2

La puce de sécurité Apple T2 a été introduite en 2017. La puce T2 a été abandonnée avec la transition vers Apple silicon (puces de série M) à partir de 2020.

- iMac Pro (2017) – Modèle : A1862
- MacBook Pro 13 pouces (2018, quatre ports Thunderbolt 3) – Modèle : A1989
- MacBook Pro 15 pouces (2018) – Modèle : A1990
- MacBook Air (Retina, 13 pouces, 2018) – Modèle : A1932
- Mac mini (2018) – Modèle : A1998
- MacBook Pro 13 pouces (2019, deux ports Thunderbolt 3) – Modèle : A2159
- MacBook Pro 13 pouces (2019, quatre ports Thunderbolt 3) – Modèle : A2178
- MacBook Pro 15 pouces (2019) – Modèle : A1990
- iMac (Retina 5K, 27 pouces, 2020) – Modèle : A2115 (iMac20,1 et iMac20,2)
- MacBook Pro 13 pouces (2020, deux ports Thunderbolt 3) – Modèle : A2265
- MacBook Pro 15 pouces (2020) – Modèle : A1990

Sur ces modèles, l'installateur configure automatiquement le noyau `linux-t2` patché, la configuration audio T2, le firmware Wi-Fi/Bluetooth Broadcom d'Apple et le contrôle des ventilateurs via `t2fanrd`. La Touch Bar fonctionne grâce à la prise en charge intégrée au noyau, de type Boot Camp.

#### iMac Retina 5K (2017)

L'iMac 27 pouces de 2017 n'a pas de puce T2, l'installateur le configure donc comme les autres Mac Intel.

- iMac (Retina 5K, 27 pouces, 2017) – Modèle : A1419

#### Problèmes connus

- L'écran ne fonctionne pas dans sa résolution native de 5120×2880 : la dalle est composée de deux tuiles, et le pilote d'origine n'en allume qu'une
- Le son ne fonctionne pas
- Le réglage de la luminosité n'a aucun effet
- La mise en veille bloque la machine ; seul un cycle d'alimentation permet de s'en sortir

Un correctif communautaire pour ce modèle corrige l'écran, le son et la luminosité : [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
