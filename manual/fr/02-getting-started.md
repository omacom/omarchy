# Prise en main

Omarchy s'installe à l'aide d'une ISO. Vous pouvez choisir entre une installation sur tout le disque, qui prend le contrôle de l'intégralité du lecteur, ou une installation dans l'espace libre, qui place Omarchy dans l'espace non alloué d'un lecteur — c'est ainsi que vous pouvez démarrer en dual boot aux côtés de Windows ou d'un autre OS (voir [installation en dual boot](50-dual-boot-install.md) — notez que vous devrez d'abord désactiver BitLocker dans Windows). Dans les deux cas, l'installation active par défaut le chiffrement complet, et l'option sur tout le disque effacera le lecteur sélectionné, alors assurez-vous de faire une sauvegarde avant d'utiliser un lecteur existant !

[Téléchargez d'abord l'ISO d'Omarchy](https://omarchy.org/), placez-la sur une clé USB (utilisez [balenaEtcher](https://etcher.balena.io/) sur Mac/Windows ou [caligula](https://github.com/ifd3f/caligula) sur Linux), et démarrez depuis la clé.

_Vous devez désactiver Secure Boot et/ou TPM dans le BIOS. Vous devez les désactiver pour pouvoir installer Omarchy. Ce sont des mécanismes de sécurité de Microsoft destinés à Windows et aux distributions Linux affiliées à Microsoft._

Répondez ensuite aux questions de configuration, et confirmez-les comme ceci :

 ![install-config](images/install-config.webp)

Sélectionnez ensuite un lecteur pour votre installation, détendez-vous et regardez le spectacle de l'installation. Elle peut se terminer en moins d'une minute sur les machines modernes les plus rapides, mais elle ne devrait pas prendre plus de 5 minutes, même sur un ordinateur plus ancien.

 ![install-done](images/install-done.webp)

Vous êtes maintenant prêt pour Omarchy !

### Utilisez un clavier filaire ou 2.4ghz !

Le chiffrement complet du disque ne vous permettra pas de saisir le mot de passe depuis un clavier Bluetooth au démarrage. Tout comme vous ne pouvez pas utiliser un clavier Bluetooth pour entrer dans le BIOS sur un PC. Vous aurez besoin d'un clavier qui utilise soit un dongle 2.4ghz, soit un câble (ce qui est de toute façon bien meilleur pour la latence !). Personnellement, j'adore le [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) !

### Installer pour un autre propriétaire

Si vous configurez une machine pour quelqu'un d'autre — un membre de votre famille, un nouvel employé, un acheteur — vous ne devriez pas répondre aux questions personnelles à sa place. Appuyez sur `Ctrl + C` sur le tout premier écran de l'installateur (la sélection du clavier), et Omarchy proposera plutôt de préparer la machine pour un autre propriétaire. Le système s'installe immédiatement, mais toute la configuration personnelle — disposition du clavier, nom d'utilisateur, mot de passe — est reportée jusqu'au premier démarrage de la machine. Le lecteur est toujours chiffré par défaut, et le mot de passe que le nouveau propriétaire choisit lors de ce premier démarrage devient aussi le mot de passe de chiffrement. (Une machine que vous utilisez déjà peut aussi être transmise sans réinstallation — voir [réinitialisation de l'ordinateur](48-security.md).)

### Installations sans surveillance

L'ISO peut aussi s'installer complètement toute seule — sans clavier, sans assistant — quand on lui fournit sa configuration sur un second lecteur. C'est la façon de traiter Omarchy comme une image de base pour les VM et les machines d'un parc. Voir [installations sans surveillance](51-unattended-installs.md).

### Installations sans chiffrement

Omarchy est installé avec le chiffrement par défaut. C'est le choix sûr et responsable pour tout ordinateur susceptible d'être perdu ou volé. Vous ne voulez pas que quiconque ayant accès à votre matériel puisse obtenir vos données !

Mais dans des circonstances particulières, comme des installations d'Omarchy à distance sur des ordinateurs protégés ou pour des installations jetables sans données sensibles, vous pouvez vouloir installer sans chiffrement. Vous pouvez appuyer sur `Ctrl + C` sur la confirmation de formatage du disque pour basculer vers une installation sans chiffrement.

### Langue

Omarchy parle 50 langues — le même ensemble que omarchy.org — et l'anglais est la langue par défaut. Pour en changer, ouvrez le menu Omarchy et allez dans _Setup > Language_, ou exécutez `omarchy language <code>` dans un terminal (`omarchy language list` affiche les codes). Le menu, le bureau et les notifications propres à Omarchy changent de langue immédiatement, et chaque application que vous ouvrez ensuite suit aussi. Les applications qui étaient déjà ouvertes changent une fois que vous les redémarrez.

### De l'aide si vous êtes bloqué

Si vous êtes bloqué, vous pouvez généralement trouver quelqu'un prêt à vous aider dans le canal _#omarchy-help_ sur [le Discord de la communauté](https://omarchy.org/discord).
