# Sécurité

Omarchy prend la sécurité extrêmement au sérieux. C'est un système d'exploitation pensé pour faire du _Vrai Travail_ dans le _Monde Réel_. Où perdre un ordinateur portable ne peut pas tourner à l'urgence de sécurité. Voici donc ce que nous faisons :

1. *Le chiffrement complet du disque est obligatoire* : c'est l'étape la plus importante pour sécuriser la protection physique de vos données. Si votre ordinateur est perdu ou volé, les données sont entièrement chiffrées à l'aide de LUKS (Linux Unified Key Setup) standard.
2. *Le pare-feu est activé par défaut* : tout le trafic entrant est bloqué par défaut, à l'exception du port 53317 pour [LocalSend](https://localsend.org/). Même ssh est désactivé jusqu'à ce que vous l'activiez via _Configuration > Sécurité > SSHD_, ce qui ouvre le port 22 (avec une limitation de débit contre les attaques par force brute) dans le cadre de la configuration. Nous verrouillons même l'accès à Docker à l'aide de la configuration [ufw-docker](https://github.com/chaifeng/ufw-docker) pour empêcher vos conteneurs d'être accidentellement exposés au monde entier.
3. *Arch dispose toujours des dernières mises à jour* : Arch, la distribution sous-jacente sur laquelle Omarchy est construit, est une distribution en publication continue. Cela signifie que toute vulnérabilité de sécurité découverte et corrigée dans un paquet devient rapidement disponible à l'installation à l'aide de `omarchy-update`. De cette façon, vous exécutez toujours les versions les plus récentes et les plus sûres de tout.
4. *Omarchy maintient ses propres paquets et son propre miroir* : par défaut, Omarchy ne s'appuie que sur les paquets des dépôts core/extra/multilib d'Arch et sur son propre dépôt de paquets Omarchy. Vous pouvez installer des logiciels directement depuis AUR, mais l'installation de base ne le fait pas — seuls quelques programmes optionnels, comme les navigateurs tiers, proviennent d'AUR.
5. *Cloudflare nous protège des DDoS* : l'infrastructure de distribution d'Omarchy — les ISO, les paquets Omarchy, le miroir Arch — est protégée derrière le formidable bouclier anti-DDoS de Cloudflare et hébergée sur leur CDN. Cela offre une excellente disponibilité.

## Changer vos mots de passe

Sur une installation chiffrée, vous avez deux mots de passe : celui qui déverrouille le disque au démarrage, et celui avec lequel vous vous connectez et utilisez `sudo`. La configuration les définit à l'identique. Tous deux peuvent être modifiés sous _Mise à jour > Mot de passe_ dans le menu Omarchy — _Chiffrement du disque_ pour le premier, _Utilisateur_ pour le second. Changer le mot de passe du disque demande d'abord le mot de passe actuel, gardez-le donc à portée de main. Si un changement est interrompu, relancez _Chiffrement du disque_ : il demande le mot de passe qui déverrouille le disque actuellement et termine le changement.

## Transmettre une machine que vous avez déjà utilisée

Si vous transmettez votre machine à quelqu'un d'autre, vous n'avez pas à la réinstaller. Lancez _Configuration > Réinitialiser l'ordinateur_ dans le menu Omarchy, tapez `reset` pour confirmer, et redémarrez. Cela efface tous les comptes utilisateur et tout ce qui se trouve dans `/home`, supprime tous les paquets et toutes les modifications système que vous avez apportés depuis l'installation, et efface l'identité de la machine — connexions réseau, clés d'hôte, tout. Au redémarrage, vous retrouvez l'assistant de configuration du premier démarrage, prêt pour que son nouveau propriétaire saisisse son propre nom, son mot de passe et son mot de passe de chiffrement.

Cela fonctionne en restaurant l'instantané de référence pris par l'installateur, donc ce n'est disponible que sur les machines installées à partir de l'ISO Omarchy. Et sur un disque sans chiffrement, une réinitialisation est une suppression plutôt qu'un effacement sécurisé, donc si les données étaient sensibles, faites plutôt une installation fraîche.

## Sudo sans mot de passe

Parfois, vous voulez que `sudo` cesse de demander, le plus souvent quand un agent IA effectue pour vous une longue série de tâches système. _Configuration > Sécurité > Sudo sans mot de passe_ demande pendant combien de temps autoriser l'accès : **15 minutes**, **1 heure**, **1 jour** ou **Définitivement**. Une icône d'avertissement rouge apparaît à côté des autres indicateurs de la barre de menu tant que l'accès est actif. Cliquez dessus ou relancez la commande pour désactiver l'accès. Vous pouvez aussi indiquer votre propre nombre de minutes (de 1 à 1440) avec `omarchy-sudo-passwordless 30`, ou utiliser `omarchy-sudo-passwordless permanent`.

L'accès à durée limitée expire automatiquement, y compris immédiatement après une reprise suivant une mise en veille qui a dépassé l'échéance. Redémarrer l'ordinateur y met fin prématurément. L'accès permanent survit aux redémarrages et reste activé jusqu'à ce que vous le désactiviez.

La mise à jour ou la suppression du paquet de paramètres d'Omarchy met fin à toute autorisation temporaire avant que sa prise en charge de l'expiration ne change. Si la commande signale une erreur d'autorisation ou de nettoyage, résolvez-la avant d'essayer d'activer une autre autorisation ; une erreur ne signifie pas que l'accès sans mot de passe est inactif.

Soyez lucide sur ce point : tant qu'il est activé, tout programme exécuté sous votre utilisateur peut tout faire en tant que root sans qu'on lui demande quoi que ce soit. C'est tout l'intérêt, et c'est aussi tout le risque.

## Clés de signature

La clé publique pour toutes les signatures d'ISO et les paquets du dépôt Omarchy est `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([vérifier sur openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Le paquet `omarchy/omarchy-keyring` la contient également et sera utilisé pour déployer sans accroc toute mise à jour éventuelle.

Vous pouvez trouver la signature de n'importe quelle version d'ISO en ajoutant `.sig` à son URL, comme `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
