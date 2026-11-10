# Premiers pas

Omarchy s'installe à l'aide d'une ISO. Vous pouvez choisir entre une installation sur l'intégralité du disque, qui s'empare de tout le disque, ou une installation dans l'espace libre, qui place Omarchy dans l'espace non alloué d'un disque — c'est comme ça que vous démarrez en dual boot aux côtés de Windows ou d'un autre OS (voir [installation en dual boot](50-dual-boot-install.md) — notez que vous devrez d'abord désactiver BitLocker dans Windows). Dans les deux cas, l'installation active le chiffrement complet par défaut, et l'option d'installation sur l'intégralité du disque effacera le disque sélectionné, alors assurez-vous de faire une sauvegarde avant d'en utiliser un existant !

[Téléchargez l'ISO d'Omarchy](https://omarchy.org/) d'abord, mettez-la sur une clé USB (utilisez [Rufus](https://rufus.ie/) sur Windows, [balenaEtcher](https://etcher.balena.io/) sur Mac, ou [caligula](https://github.com/ifd3f/caligula) sur Linux), et démarrez depuis la clé.

_Vous devez désactiver Secure Boot et/ou TPM dans le BIOS. Vous devez les désactiver pour pouvoir installer Omarchy. Ce sont des dispositifs de sécurité de Microsoft pensés pour Windows et les distributions Linux affiliées à Microsoft._

Répondez ensuite aux questions de configuration, et confirmez-les comme ceci :

 ![install-config](images/install-config.webp)

Sélectionnez ensuite un disque pour votre installation, et installez-vous confortablement pour regarder le spectacle de l'installation. Cela peut se faire en moins d'une minute sur les machines modernes les plus rapides, mais cela ne devrait pas prendre plus de 5 minutes même sur un ordinateur plus ancien.

 ![install-done](images/install-done.webp)

Vous êtes maintenant prêt pour Omarchy !

### Utilisez un clavier filaire ou 2.4ghz !

Le chiffrement complet du disque ne vous permettra pas de saisir le mot de passe depuis un clavier Bluetooth au démarrage. Tout comme vous ne pouvez pas utiliser un clavier Bluetooth pour entrer dans le BIOS sur un PC. Vous aurez besoin d'un clavier qui utilise soit un dongle 2.4ghz, soit un câble (ce qui est de toute façon bien meilleur pour la latence !). Personnellement, j'adore le [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) !

### Installation pour un autre propriétaire

Si vous configurez une machine pour quelqu'un d'autre — un membre de votre famille, un nouvel employé, un acheteur — vous ne devriez pas répondre aux questions personnelles à sa place. Appuyez sur `Ctrl + C` sur le tout premier écran de l'installateur (la sélection du clavier), et Omarchy vous proposera de préparer la machine pour un autre propriétaire à la place. Le système s'installe immédiatement, mais toute la configuration personnelle — disposition du clavier, nom d'utilisateur, mot de passe — est repoussée jusqu'au premier démarrage de la machine. Le disque reste chiffré par défaut, et le mot de passe que le nouveau propriétaire choisit lors de ce premier démarrage devient aussi le mot de passe de chiffrement. (Une machine que vous avez déjà utilisée peut aussi être transmise sans réinstallation — voir [réinitialisation de l'ordinateur](48-security.md).)

### Installations sans intervention

L'ISO peut aussi s'installer entièrement seule — sans clavier, sans assistant — quand on lui fournit sa configuration sur un second disque. C'est la façon de traiter Omarchy comme une image de base pour les VM et les parcs de machines. Voir [installations sans intervention](51-unattended-installs.md).

### Installations sans chiffrement

Omarchy est installé avec chiffrement par défaut. C'est le choix sûr et responsable pour tout ordinateur susceptible d'être perdu ou volé. Vous ne voulez pas que quiconque ayant accès à votre matériel puisse récupérer vos données !

Mais dans des circonstances particulières, comme des installations distantes d'Omarchy sur des ordinateurs protégés ou pour des installations jetables sans données sensibles, vous pouvez vouloir installer sans chiffrement. Vous pouvez appuyer sur `Ctrl + C` à la confirmation du formatage du disque pour passer à une installation sans chiffrement.

### Langue

Omarchy parle 50 langues — le même ensemble que omarchy.org — et l'anglais est la langue par défaut. Pour en changer, ouvrez le menu Omarchy et allez dans _Setup > Language_, ou lancez `omarchy language <code>` dans un terminal (`omarchy language list` affiche les codes). Le menu, le bureau et les notifications propres à Omarchy changent de langue immédiatement, et toutes les applications que vous ouvrez ensuite suivent aussi. Les applications déjà ouvertes changent une fois que vous les redémarrez.

### De l'aide si vous êtes bloqué

Si vous êtes bloqué, vous pouvez généralement trouver quelqu'un prêt à vous aider dans le canal _#omarchy-help_ sur [le Discord de la communauté](https://omarchy.org/discord).
