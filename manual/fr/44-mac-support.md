# Prise en charge Mac

Omarchy prend en charge nativement les **Mac Intel**. Il y a pour le moment quelques limitations connues, mais tant que vous en êtes conscient et que cela vous convient, vous pouvez insuffler une nouvelle vie à vos vieux Mac en chargeant Omarchy.

Notez que l'installation sur un Mac à puce M n'est pas directement prise en charge pour le moment. Vous pouvez en savoir plus sur l'état de la chose dans #omarchy-on-other sur notre [Discord](https://discord.gg/tXFUdasqhY).

Lors d'un test simple, nous avons réussi à obtenir des gains de performance de 36 % sur un MacBook Pro 2019 rien qu'en installant Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installer Omarchy sur Mac

Omarchy ne prend en charge pour le moment que le fait d'être le **seul** système d'exploitation installé. Pendant l'installation, le disque sera effacé et MacOS ne sera plus amorçable.

Vous pourrez toujours le restaurer plus tard via la Récupération par Internet si vous le souhaitez.

Pour cette partie, nous supposerons que vous avez déjà lu [Pour commencer](02-getting-started.md) et que votre clé USB est prête. Si ce n'est pas le cas, faites-le maintenant.

#### Désactiver le Secure Boot

Il est nécessaire de désactiver le Secure Boot d'Apple pour démarrer la clé USB amorçable, ainsi que le système d'exploitation. Pour le désactiver, procédez comme suit :

1. Éteignez votre Mac
2. Allumez-le et appuyez _immédiatement_ sur Commande-R en maintenant jusqu'à ce que l'écran de chargement apparaisse
3. Sélectionnez votre utilisateur et saisissez votre mot de passe si on vous le demande
4. Une fois sur l'écran de récupération, choisissez **Utilitaires > Utilitaire de sécurité du démarrage** dans la barre de menus
5. Saisissez votre mot de passe quand on vous demande de vous authentifier
6. Choisissez « Aucune sécurité » parmi les options Secure Boot
7. Choisissez « Autoriser le démarrage à partir d'un support externe ou amovible » parmi les options Démarrage externe

#### Lancer l'installation

1. Insérez la clé USB
2. Redémarrez votre Mac et appuyez _immédiatement_ sur Option en maintenant jusqu'à ce qu'un écran de périphériques de démarrage apparaisse
3. Sélectionnez le périphérique EFI Boot orange
4. Poursuivez l'[installation comme d'habitude](02-getting-started.md)

L'installateur détecte le matériel Mac et applique automatiquement les correctifs nécessaires : pilotes et firmwares Wi-Fi Broadcom, le pilote de clavier SPI sur les modèles MacBook qui en ont besoin, et un correctif de suspension NVMe pour ces mêmes modèles.

### Limitations connues

Les membres de la communauté travaillent constamment à des solutions pour ces défis, alors si c'est problématique pour vous, rejoignez #omarchy-on-other sur notre [Discord](https://discord.gg/tXFUdasqhY) et voyez s'il existe des méthodes à jour pour les résoudre.

#### Appareils avec puce T1

La puce Apple T1 a été introduite fin 2016 et utilisée exclusivement dans les modèles MacBook Pro de première génération avec Touch Bar.
- MacBook Pro 13 pouces (2016, deux ports Thunderbolt 3) – Modèle : A1706
- MacBook Pro 13 pouces (2016, quatre ports Thunderbolt 3) – Modèle : A1708
- MacBook Pro 15 pouces (2016) – Modèle : A1707

#### Problèmes connus

- La Touch Bar ne fonctionne pas
- Le son ne fonctionne pas

#### Appareils avec puce T2

La puce de sécurité Apple T2 a été introduite en 2017. La puce T2 a été abandonnée avec la transition vers Apple silicon (puces série M) à partir de 2020.

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

Sur ces modèles, l'installateur configure automatiquement le noyau patché `linux-t2`, la configuration audio T2, le firmware Wi-Fi/Bluetooth Broadcom d'Apple et le contrôle des ventilateurs via `t2fanrd`. La Touch Bar fonctionne sur la prise en charge intégrée au noyau de style Boot Camp.
