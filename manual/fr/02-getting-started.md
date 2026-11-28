# Prise en main

Omarchy s'installe à l'aide d'un ISO. Vous pouvez choisir entre une installation sur disque entier, qui prend le contrôle de l'intégralité du disque, ou une installation dans l'espace libre, qui place Omarchy dans l'espace non alloué d'un disque — c'est ainsi que vous démarrez en dual boot aux côtés de Windows ou d'un autre OS (voir [installation en dual boot](50-dual-boot-install.md) — notez que vous devrez d'abord désactiver BitLocker dans Windows). Dans les deux cas, l'installation utilise par défaut un chiffrement complet, et l'option disque entier effacera le disque sélectionné, alors pensez bien à faire une sauvegarde avant d'utiliser un disque existant !

Sur un Mac Apple Silicon, vous installez plutôt depuis macOS, sans ISO ni clé USB. Voir [Omarchy pour Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

[Téléchargez d'abord l'ISO d'Omarchy](https://omarchy.org/), mettez-le sur une clé USB (utilisez [Rufus](https://rufus.ie/) sous Windows, [balenaEtcher](https://etcher.balena.io/) sur Mac, ou [caligula](https://github.com/ifd3f/caligula) sous Linux), et démarrez depuis la clé.

_Vous devez désactiver Secure Boot et/ou TPM dans le BIOS. Vous devez les désactiver pour pouvoir installer Omarchy. Ce sont des mécanismes de sécurité de Microsoft destinés à Windows et aux distributions Linux affiliées à Microsoft._

Répondez ensuite aux questions de configuration, et confirmez-les comme ceci :

 ![install-config](images/install-config.webp)

Sélectionnez ensuite un disque pour votre installation, puis détendez-vous et regardez le spectacle de l'installation. Elle peut être terminée en moins d'une minute sur les machines modernes les plus rapides, mais elle ne devrait pas prendre plus de 5 minutes même sur un ordinateur plus ancien.

 ![install-done](images/install-done.webp)

Vous êtes maintenant prêt à Omarchy !

### Utilisez un clavier filaire ou 2.4ghz !

Le chiffrement complet du disque ne vous permettra pas de saisir le mot de passe depuis un clavier Bluetooth au démarrage. Tout comme vous ne pouvez pas utiliser un clavier Bluetooth pour entrer dans le BIOS d'un PC. Il vous faudra un clavier qui utilise soit un dongle 2.4ghz, soit un câble (ce qui est de toute façon bien plus agréable pour la latence !). Personnellement, j'adore le [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) !

### Installation pour un autre propriétaire

Si vous préparez une machine pour quelqu'un d'autre — un membre de votre famille, un nouvel employé, un acheteur — vous ne devriez pas répondre aux questions personnelles à sa place. Appuyez sur `Ctrl + C` sur le tout premier écran du programme d'installation (la sélection du clavier), et Omarchy vous proposera plutôt de préparer la machine pour un autre propriétaire. Le système s'installe immédiatement, mais toute la configuration personnelle — disposition du clavier, nom d'utilisateur, mot de passe — est reportée jusqu'au premier démarrage de la machine. Le disque est toujours chiffré par défaut, et le mot de passe que le nouveau propriétaire choisit lors de ce premier démarrage devient aussi le mot de passe de chiffrement. (Une machine que vous avez déjà utilisée peut aussi être transmise sans réinstallation — voir [réinitialisation de l'ordinateur](48-security.md).)

### Installations sans surveillance

L'ISO peut aussi s'installer entièrement tout seul — sans clavier, sans assistant — lorsqu'on lui fournit sa configuration sur un second disque. C'est la façon de traiter Omarchy comme une image de base pour les VM et les parcs de machines. Voir [installations sans surveillance](51-unattended-installs.md).

### Installations sans chiffrement

Omarchy est installé avec chiffrement par défaut. C'est le choix sûr et responsable pour tout ordinateur susceptible d'être perdu ou volé. Vous ne voulez pas que quiconque ayant accès à votre matériel puisse récupérer vos données !

Mais dans des circonstances particulières, comme les installations distantes d'Omarchy sur des ordinateurs protégés ou les installations jetables sans données sensibles, vous pouvez vouloir installer sans chiffrement. Vous pouvez appuyer sur `Ctrl + C` sur la confirmation du formatage du disque pour passer à une installation sans chiffrement.

### Langue

Omarchy parle 50 langues — le même ensemble qu'omarchy.org — et l'anglais est la langue par défaut. Pour en changer, ouvrez le menu Omarchy et allez dans _Configuration > Région > Langue_, ou exécutez `omarchy language <code>` dans un terminal (`omarchy language list` affiche les codes). Le menu, le bureau et les notifications propres à Omarchy changent de langue immédiatement, et toutes les applications que vous ouvrez ensuite suivent aussi. Les applications déjà ouvertes changent une fois que vous les redémarrez.

Pour conserver la langue mais écrire les dates, les heures, les nombres, les montants, les unités et les formats de papier comme le fait une autre région (de l'anglais avec des dates européennes et une horloge 24 heures, par exemple), choisissez une région sous _Configuration > Région > Formats_, où chaque choix affiche un exemple, ou exécutez `omarchy region formats <code>` (`omarchy region formats list` affiche les codes). _Identique à la langue_ revient aux formats propres à la langue. Comme un changement de langue, il s'applique aux applications que vous ouvrez ensuite.

### De l'aide si vous êtes bloqué

Si vous êtes bloqué, vous pouvez généralement trouver quelqu'un disposé à vous aider dans le canal _#omarchy-help_ sur [le Discord de la communauté](https://omarchy.org/discord).
