# Prise en charge des Mac

## Omarchy pour Apple Silicon

Omarchy pour Apple Silicon est une solution officielle d'Omacom, publiée pour la première fois avec Omarchy 4.5. Elle s'installe à côté de macOS, et vous choisissez entre les deux au démarrage de votre Mac.

Vous avez reçu un avis concernant Omarchy Mac ? Allez à [Vous venez d'Omarchy Mac](#coming-from-omarchy-mac).

Elle fonctionne sur ces Mac :

| Mac | Puces |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Les Mac M4 et plus récents ne sont pas encore pris en charge. La prise en charge du M4 est en test sur le canal edge et arrive ensuite. L'installateur vérifie votre Mac avant de modifier quoi que ce soit.

Sur n'importe quel Mac Apple Silicon, y compris les M4 et plus récents, vous pouvez exécuter Omarchy dans une machine virtuelle avec [Try Omarchy](https://github.com/omacom/try-omarchy).

### Ce qu'il vous faut

- macOS 15 Sequoia ou ultérieur, et un compte administrateur
- De l'espace disque libre pour Omarchy. L'installateur suggère une taille et vous permet de la modifier.
- Une sauvegarde de votre Mac, une alimentation et une connexion internet. L'installation télécharge plusieurs gigaoctets.

### Installation

Vous l'installez depuis macOS. Installez l'Omarchy Installer avec [Homebrew](https://brew.sh) :

```sh
brew install omacom/mac/omarchy
```

Ou téléchargez le plus récent Omarchy Installer depuis sa [page des versions](https://github.com/omacom/omarchy-mac-installer/releases) et ouvrez-le.

L'installateur vérifie votre Mac, vous présente le plan et libère de la place pour Omarchy en réduisant la partition macOS. macOS reste sur le disque et aucune clé USB n'est nécessaire. Une fois la première étape terminée, il vous guide pour terminer la configuration dans macOS Recovery : éteignez, maintenez le bouton d'alimentation enfoncé jusqu'à ce que "Loading startup options" apparaisse, choisissez Omarchy et suivez les étapes.

Au premier démarrage, Omarchy demande un mot de passe qui chiffre son disque. Il n'y a aucune clé de récupération : si vous oubliez le mot de passe, vos fichiers Omarchy ne pourront pas être récupérés.

Pour passer d'Omarchy à macOS par la suite, éteignez, puis maintenez le bouton d'alimentation enfoncé jusqu'à ce que les options de démarrage apparaissent et choisissez-en un.

### Vous venez d'Omarchy Mac

Omarchy Mac fait désormais partie d'Omarchy pour Apple Silicon, et tous les Mac qui l'exécutaient sont pris en charge. Votre installation actuelle continue de fonctionner, et ses paquets système continuent de se mettre à jour, mais elle ne reçoit plus de mises à jour Omarchy. Il n'y a aucune date limite et aucune mise à niveau sur place : vous sauvegardez, vous supprimez l'ancienne installation, vous installez à neuf et vous restaurez. Les étapes 2 à 5 se déroulent dans macOS, alors ouvrez cette page sur votre téléphone avant de redémarrer.

1. **Sauvegardez depuis Omarchy, hors du Mac.** La suppression de l'ancienne installation l'efface, et macOS ne peut pas lire le disque Omarchy. Copiez votre dossier personnel sur un disque externe ou un autre ordinateur, y compris les clés SSH et GPG, les profils de navigateur et le travail non poussé. Enregistrez votre liste de paquets avec `pacman -Qqe > ~/packages.txt`. Sauvegardez aussi macOS, car la suppression et l'installation redimensionnent toutes deux son disque.
2. **Démarrez votre Mac sous macOS.** Éteignez, maintenez le bouton d'alimentation enfoncé jusqu'à ce que les options de démarrage apparaissent, et choisissez macOS.
3. **Installez l'Omarchy Installer** comme indiqué dans [Installation](#installing).
4. **Supprimez l'ancienne installation.** Ouvrez l'Omarchy Installer et choisissez Installation > Remove Omarchy. Il vous montre ce qu'il va supprimer et restitue l'espace à macOS. S'il ne reconnaît pas votre installation, il s'arrête sans modifier le disque. Demandez de l'aide sur [Discord](https://discord.gg/tXFUdasqhY) plutôt que de supprimer des partitions à la main, ce qui peut effacer macOS.
5. **Installez Omarchy pour Apple Silicon** avec l'installateur.
6. **Restaurez vos fichiers.** Récupérez vos réglages petit à petit plutôt que de copier tout `~/.config` par-dessus les nouveaux réglages par défaut, car les anciens réglages peuvent les écraser.

### Bon à savoir

- Sur les MacBook M1 et M2, sortez de veille en ouvrant le capot ou en appuyant sur le bouton d'alimentation.
- Questions ou problèmes : demandez sur notre [Discord](https://discord.gg/tXFUdasqhY).

Le [README de l'installateur](https://github.com/omacom/omarchy-mac-installer#readme) couvre les canaux de publication, la mise à jour de l'installateur et la suppression d'Omarchy.

## Mac Intel

Lors d'un test simple, nous avons obtenu 36 % de gains de performance sur un MacBook Pro 2019 simplement en installant Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installer Omarchy sur Mac

Omarchy ne prend en charge pour le moment que le fait d'être le **seul** OS installé. Pendant l'installation, le disque sera effacé et MacOS ne pourra plus démarrer.

Vous pourrez toujours le restaurer plus tard via Internet Recovery si vous le souhaitez.

Pour cette partie, nous supposerons que vous avez déjà consulté [Bien démarrer](02-getting-started.md) et que votre clé USB est prête. Si ce n'est pas le cas, faites-le maintenant.

#### Désactiver Secure Boot

Il est nécessaire de désactiver Secure Boot d'Apple pour pouvoir démarrer la clé USB bootable, ainsi que l'OS. Pour le désactiver, procédez comme suit :

1. Éteignez votre Mac
2. Allumez-le et appuyez _immédiatement_ sur Command-R et maintenez les touches enfoncées jusqu'à ce que l'écran de chargement apparaisse
3. Sélectionnez votre utilisateur et saisissez votre mot de passe si vous y êtes invité
4. Une fois sur l'écran de récupération, choisissez **Utilities > Startup Security Utility** dans la barre de menus
5. Saisissez votre mot de passe lorsqu'on vous demande de vous authentifier
6. Choisissez "No Security" parmi les options Secure Boot
7. Choisissez "Allow booting from external or removable media" parmi les options External Boot

#### Démarrer l'installation

1. Insérez la clé USB
2. Redémarrez votre Mac et appuyez _immédiatement_ sur Option et maintenez la touche enfoncée jusqu'à ce qu'un écran des périphériques de démarrage apparaisse
3. Sélectionnez le périphérique EFI Boot orange
4. Procédez à [l'installation comme d'habitude](02-getting-started.md)

L'installateur détecte le matériel Mac et applique automatiquement les correctifs nécessaires : les pilotes et le firmware Wi-Fi Broadcom, le pilote de clavier SPI sur les modèles de MacBook qui en ont besoin, et un correctif de mise en veille NVMe pour ces mêmes modèles.

### Limites connues

Les membres de la communauté travaillent constamment à des solutions pour ces difficultés, alors si elles vous posent problème, rejoignez #omarchy-on-other sur notre [Discord](https://discord.gg/tXFUdasqhY) et voyez s'il existe des méthodes à jour pour les résoudre.

#### Appareils avec puce T1

La puce Apple T1 a été introduite fin 2016 et utilisée exclusivement dans les modèles de MacBook Pro de première génération avec Touch Bar.
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

Sur ces modèles, l'installateur configure automatiquement le noyau `linux-t2` patché, la configuration audio T2, le firmware Wi-Fi/Bluetooth Broadcom d'Apple et le contrôle des ventilateurs via `t2fanrd`. La Touch Bar fonctionne avec la prise en charge intégrée de type Boot Camp du noyau.

#### iMac Retina 5K (2017)

L'iMac 27 pouces de 2017 n'a pas de puce T2, alors l'installateur le configure comme les autres Mac Intel.

- iMac (Retina 5K, 27 pouces, 2017) – Modèle : A1419

#### Problèmes connus

- L'écran ne fonctionne pas à sa résolution native de 5120×2880 : la dalle est composée de deux tuiles, et le pilote d'origine n'en allume qu'une
- Le son ne fonctionne pas
- Le réglage de la luminosité n'a aucun effet
- La mise en veille bloque la machine ; seul un cycle d'alimentation permet de la récupérer

Un patcher communautaire pour ce modèle corrige l'écran, le son et la luminosité : [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
