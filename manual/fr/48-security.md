# Sécurité

Omarchy prend la sécurité extrêmement au sérieux. Il est conçu pour être un système d'exploitation que vous pouvez utiliser pour faire du _vrai travail_ dans le _monde réel_. Où perdre un ordinateur portable ne peut pas conduire à une urgence de sécurité. Voici donc ce que nous faisons :

1. *Le chiffrement complet du disque est obligatoire* : C'est l'étape la plus importante pour assurer la protection physique de vos données. Si votre ordinateur est perdu ou volé, les données sont entièrement chiffrées à l'aide du standard LUKS (Linux Unified Key Setup).
2. *Le pare-feu est activé par défaut* : Tout le trafic entrant est bloqué par défaut, à l'exception du port 53317 pour [LocalSend](https://localsend.org/). Même ssh est désactivé jusqu'à ce que vous l'activiez via _Setup > Security > SSHD_, qui ouvre le port 22 (avec limitation du débit contre les attaques par force brute) dans le cadre de la configuration. Nous verrouillons même l'accès à Docker à l'aide de la configuration [ufw-docker](https://github.com/chaifeng/ufw-docker) pour empêcher vos conteneurs d'être accidentellement exposés au monde entier.
3. *Arch dispose toujours des dernières mises à jour* : Arch, la distribution sous-jacente sur laquelle Omarchy est construit, est une distribution en publication continue. Cela signifie que toute vulnérabilité de sécurité découverte et corrigée dans un paquet quelconque est rapidement disponible à l'installation à l'aide de `omarchy-update`. De cette façon, vous utilisez toujours les versions les plus récentes et les plus sûres de tout.
4. *Omarchy maintient ses propres paquets et son propre miroir* : Par défaut, Omarchy ne s'appuie que sur les paquets des dépôts core/extra/multilib d'Arch et sur son propre Omarchy Package Repository. Vous pouvez installer des logiciels directement depuis AUR, mais l'installation de base ne le fait pas — seules quelques installations optionnelles, comme les navigateurs tiers, passent par AUR.
5. *Cloudflare nous protège contre les DDoS* : L'infrastructure de distribution d'Omarchy — les ISO, les paquets Omarchy, le miroir Arch — est protégée derrière le redoutable bouclier anti-DDoS de Cloudflare et hébergée sur son CDN. Cela offre une disponibilité exceptionnelle.

## Changer vos mots de passe

Sur une installation chiffrée, vous avez deux mots de passe : celui qui déverrouille le disque au démarrage, et celui avec lequel vous vous connectez et utilisez `sudo`. La configuration les rend identiques. Les deux peuvent être modifiés sous _Update > Password_ dans le menu Omarchy — _Drive Encryption_ pour le premier, _User_ pour le second. Changer le mot de passe du disque demande d'abord le mot de passe actuel, alors gardez-le à portée de main. Si un changement est interrompu, relancez _Drive Encryption_ : il demande le mot de passe qui déverrouille le disque actuellement et termine le changement.

## Transmettre une machine que vous avez déjà utilisée

Si vous transmettez votre machine à quelqu'un d'autre, vous n'avez pas besoin de la réinstaller. Lancez _Setup > Reset Computer_ dans le menu Omarchy, tapez `reset` pour confirmer, puis redémarrez. Cela efface tous les comptes utilisateur et tout ce qui se trouve dans `/home`, supprime tous les paquets et changements système que vous avez effectués depuis l'installation, et efface l'identité de la machine — connexions réseau, clés d'hôte, tout. Au redémarrage, c'est l'assistant de configuration du premier démarrage qui apparaît, prêt pour que son nouveau propriétaire saisisse son propre nom, son mot de passe et son mot de passe de chiffrement.

Cela fonctionne en restaurant l'instantané de référence pris par l'installateur, donc ce n'est disponible que sur les machines installées à partir de l'ISO Omarchy. Et sur un disque sans chiffrement, une réinitialisation est une suppression plutôt qu'un effacement sécurisé, donc si les données étaient sensibles, faites plutôt une nouvelle installation.

## sudo sans mot de passe

Parfois, vous voulez que `sudo` arrête de demander, le plus souvent lorsqu'un agent IA effectue pour vous une longue série de tâches système. _Setup > Security > Passwordless Sudo_ demande combien de temps autoriser l'accès : **15 minutes**, **1 Hour**, **1 Day**, ou **Permanently**. Une icône d'avertissement rouge apparaît à côté des autres indicateurs de la barre de menu tant que l'accès est actif. Cliquez dessus ou relancez la commande pour désactiver l'accès. Vous pouvez aussi indiquer votre propre nombre de minutes (de 1 à 1440) avec `omarchy-sudo-passwordless 30`, ou utiliser `omarchy-sudo-passwordless permanent`.

L'accès à durée limitée expire automatiquement, y compris immédiatement après la reprise d'une mise en veille qui a franchi l'échéance. Redémarrer l'ordinateur y met fin plus tôt. L'accès permanent survit aux redémarrages et reste activé jusqu'à ce que vous le désactiviez.

Mettre à jour ou supprimer le paquet de paramètres d'Omarchy met fin à toute autorisation temporaire avant que sa prise en charge de l'expiration ne change. Si la commande signale une erreur d'autorisation ou de nettoyage, résolvez-la avant d'essayer d'activer une autre autorisation ; une erreur ne signifie pas que l'accès sans mot de passe est inactif.

Soyez lucide sur ce point : tant que c'est activé, tout ce qui s'exécute sous votre utilisateur peut tout faire en tant que root sans qu'on le lui demande. C'est tout l'intérêt, et c'est aussi tout le risque.

## Clés de signature

La clé publique pour toutes les signatures d'ISO et les paquets du dépôt Omarchy est `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([vérifier sur openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Le paquet `omarchy/omarchy-keyring` la contient également et sera utilisé pour déployer d'éventuelles mises à jour en toute transparence.

Vous pouvez trouver la signature de n'importe quelle version ISO en ajoutant .sig à l'URL. Par exemple https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
