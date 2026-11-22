# Premiers pas

Omarchy s'installe à l'aide d'une ISO. Vous pouvez choisir entre une installation sur disque entier, qui prend le contrôle de tout le disque, ou une installation dans l'espace libre, qui installe Omarchy dans l'espace non alloué d'un disque — c'est ainsi que l'on fait un dual boot aux côtés de Windows ou d'un autre OS (voir [installation en dual boot](50-dual-boot-install.md) — notez que vous devrez d'abord désactiver BitLocker sous Windows). Dans les deux cas, l'installation utilise par défaut le chiffrement complet, et l'option disque entier effacera le disque sélectionné, alors assurez-vous de faire une sauvegarde avant d'utiliser un disque existant !

[Téléchargez l'ISO d'Omarchy](https://omarchy.org/) d'abord, mettez-la sur une clé USB (utilisez [Rufus](https://rufus.ie/) sur Windows, [balenaEtcher](https://etcher.balena.io/) sur Mac, ou [caligula](https://github.com/ifd3f/caligula) sur Linux), et démarrez sur la clé.

_Vous devez désactiver Secure Boot et/ou TPM dans le BIOS. Vous devez les désactiver pour pouvoir installer Omarchy. Ce sont des mécanismes de sécurité de Microsoft conçus pour Windows et les distributions Linux affiliées à Microsoft._

Ensuite, répondez aux questions de configuration, et confirmez-les comme ceci :

 ![install-config](images/install-config.webp)

Ensuite, sélectionnez un disque pour votre installation, et détendez-vous en regardant le spectacle de l'installation. Cela peut être fait en moins d'une minute sur les machines modernes les plus rapides, mais cela ne devrait pas prendre plus de 5 minutes même sur un ordinateur plus ancien.

 ![install-done](images/install-done.webp)

Vous voilà prêt pour Omarchy !

### Utilisez un clavier filaire ou 2.4ghz !

Le chiffrement complet du disque ne vous permettra pas de saisir le mot de passe depuis un clavier Bluetooth au démarrage. Tout comme vous ne pouvez pas utiliser un clavier Bluetooth pour accéder au BIOS sur un PC. Il vous faudra un clavier qui utilise soit un dongle 2.4ghz, soit un câble (ce qui est de toute façon bien mieux pour la latence !). Personnellement, j'adore le [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) !

### Installation pour un autre propriétaire

Si vous préparez une machine pour quelqu'un d'autre — un membre de la famille, un nouvel employé, un acheteur — vous ne devriez pas répondre aux questions personnelles à sa place. Appuyez sur `Ctrl + C` sur le tout premier écran de l'installateur (la sélection du clavier), et Omarchy vous proposera de préparer la machine pour un autre propriétaire à la place. Le système s'installe tout de suite, mais toute la configuration personnelle — disposition du clavier, nom d'utilisateur, mot de passe — est repoussée jusqu'au premier démarrage de la machine. Le disque reste chiffré par défaut, et le mot de passe que le nouveau propriétaire choisit lors de ce premier démarrage devient aussi le mot de passe de chiffrement. (Une machine que vous avez déjà utilisée peut aussi être transmise sans réinstallation — voir [réinitialisation de l'ordinateur](48-security.md).)

### Installations sans surveillance

L'ISO peut aussi s'installer entièrement toute seule — sans clavier, sans assistant — quand on lui fournit sa configuration sur un second disque. C'est la manière de traiter Omarchy comme une image de base pour les VM et les parcs de machines. Voir [installations sans surveillance](51-unattended-installs.md).

### Installations sans chiffrement

Omarchy s'installe avec chiffrement par défaut. C'est le choix sûr et responsable pour tout ordinateur susceptible d'être perdu ou volé. Vous ne voulez pas que quiconque ayant accès à votre matériel puisse obtenir vos données !

Mais dans des circonstances particulières, comme des installations d'Omarchy à distance sur des ordinateurs protégés ou pour des installations jetables sans données sensibles, vous pouvez vouloir installer sans chiffrement. Vous pouvez appuyer sur `Ctrl + C` lors de la confirmation du formatage du disque pour passer à une installation sans chiffrement.

### Langue

Omarchy parle 50 langues — le même ensemble qu'omarchy.org — et l'anglais est la langue par défaut. Pour en changer, ouvrez le menu Omarchy et allez dans _Configuration > Région > Langue_, ou exécutez `omarchy language <code>` dans un terminal (`omarchy language list` affiche les codes). Le menu, le bureau et les notifications propres à Omarchy changent de langue immédiatement, et chaque application que vous ouvrez ensuite suit aussi. Les applications déjà ouvertes changent une fois que vous les redémarrez.

Pour conserver la langue mais écrire les dates, les heures, les nombres, l'argent, les unités et les formats de papier comme le fait une autre région (l'anglais avec des dates européennes et une horloge 24 heures, par exemple), choisissez une région sous _Configuration > Région > Formats_, où chaque choix affiche un exemple, ou exécutez `omarchy region formats <code>` (`omarchy region formats list` affiche les codes). _Identique à la langue_ revient aux formats propres à la langue. Comme un changement de langue, cela s'applique aux applications que vous ouvrez ensuite.

### De l'aide si vous êtes bloqué

Si vous êtes bloqué, vous pouvez généralement trouver quelqu'un prêt à vous aider dans le canal _#omarchy-help_ sur [le Discord de la communauté](https://omarchy.org/discord).
