# Sécurité

Omarchy prend la sécurité très au sérieux. C'est censé être un système d'exploitation que vous pouvez utiliser pour faire du _Vrai Travail_ dans le _Monde Réel_. Où perdre un portable ne peut pas mener à une urgence de sécurité. Voici donc ce que nous faisons :

1. *Le chiffrement intégral du disque est obligatoire* : c'est l'étape la plus importante pour sécuriser la protection physique de vos données. Si votre ordinateur est perdu ou volé, les données sont entièrement chiffrées avec LUKS standard (Linux Unified Key Setup).
2. *Le pare-feu est activé par défaut* : tout le trafic entrant est bloqué par défaut, sauf le port 53317 pour [LocalSend](https://localsend.org/). Même ssh est désactivé jusqu'à ce que vous l'activiez via _Configuration > Sécurité > SSHD_, qui ouvre le port 22 (avec limitation de débit contre la force brute) dans le cadre de la configuration. Nous verrouillons même l'accès Docker avec la configuration [ufw-docker](https://github.com/chaifeng/ufw-docker) pour empêcher que vos conteneurs soient accidentellement exposés au monde entier.
3. *Arch a toujours les dernières mises à jour* : Arch, la distribution sous-jacente sur laquelle Omarchy est construit, est une distribution en publication continue. Cela signifie que toute vulnérabilité de sécurité découverte et corrigée dans un paquet est rapidement disponible à l'installation avec `omarchy-update`. Vous exécutez ainsi toujours les dernières versions les plus sûres de tout.
4. *Omarchy maintient ses propres paquets et son propre miroir* : Omarchy ne repose par défaut que sur les paquets des dépôts core/extra/multilib d'Arch et de son propre Dépôt de paquets Omarchy. Vous pouvez installer des logiciels directement depuis l'AUR, mais l'installation de base ne le fait pas — seules quelques installations optionnelles, comme les navigateurs tiers, tirent depuis l'AUR.
5. *Cloudflare nous protège des DDoS* : toute l'infrastructure de distribution d'Omarchy — les ISO, les paquets Omarchy, le miroir Arch — est protégée derrière le formidable bouclier anti-DDoS de Cloudflare et hébergée sur son CDN. Cela offre une disponibilité superbe.

## Changer vos mots de passe

Vous avez deux mots de passe sur une installation chiffrée : celui qui déverrouille le disque au démarrage, et celui avec lequel vous vous connectez et utilisez `sudo`. La configuration les rend identiques. Tous deux peuvent être changés sous _Mettre à jour > Mot de passe_ dans le menu Omarchy — _Chiffrement du disque_ pour le premier, _Utilisateur_ pour le second. Changer le mot de passe du disque demande d'abord l'actuel, ayez-le donc sous la main. Si un changement est interrompu, lancez _Chiffrement du disque_ à nouveau : il demande le mot de passe qui déverrouille le disque maintenant et termine le changement.

## Transmettre une machine que vous avez déjà utilisée

Si vous transmettez votre machine à quelqu'un d'autre, vous n'avez pas à la réinstaller. Lancez _Configuration > Réinitialiser l'ordinateur_ dans le menu Omarchy, tapez `reset` pour confirmer, et redémarrez. Cela efface chaque compte utilisateur et tout ce qui se trouve dans `/home`, jette tous les paquets et changements système que vous avez faits depuis l'installation, et efface l'identité de la machine — connexions réseau, clés d'hôte et tout. Ce qui revient, c'est l'assistant de configuration du premier démarrage, prêt pour que son nouveau propriétaire saisisse son propre nom, son mot de passe et son mot de passe de chiffrement.

Cela fonctionne en restaurant l'instantané de base que prend l'installateur, ce n'est donc disponible que sur les machines installées depuis l'ISO Omarchy. Et sur un disque sans chiffrement, une réinitialisation est une suppression plutôt qu'un effacement sécurisé, si bien que si les données étaient sensibles, faites plutôt une installation fraîche.

## Sudo sans mot de passe

Parfois, vous voulez que `sudo` cesse de demander, le plus souvent quand un agent IA fait une longue série de travaux système pour vous. _Configuration > Sécurité > Sudo sans mot de passe_ demande combien de temps autoriser l'accès : **15 minutes**, **1 heure**, **1 jour** ou **Définitivement**. Une icône d'avertissement rouge apparaît à côté des autres indicateurs de la barre de menu tant que l'accès est actif. Cliquez dessus ou relancez la commande pour désactiver l'accès. Vous pouvez aussi passer votre propre nombre de minutes (de 1 à 1440) avec `omarchy-sudo-passwordless 30`, ou utiliser `omarchy-sudo-passwordless permanent`.

L'accès minuté expire automatiquement, y compris immédiatement après la reprise d'une suspension qui a dépassé l'échéance. Redémarrer l'ordinateur y met fin plus tôt. L'accès permanent survit aux redémarrages et reste activé jusqu'à ce que vous le désactiviez.

Mettre à jour ou retirer le paquet de réglages d'Omarchy met fin à tout accès temporaire avant que sa prise en charge de l'expiration ne change. Si la commande signale une erreur d'autorisation ou de nettoyage, résolvez-la avant d'essayer d'activer un autre accès ; une erreur ne signifie pas que l'accès sans mot de passe est inactif.

Soyez lucide sur ce point : tant qu'il est actif, tout ce qui s'exécute sous votre utilisateur peut tout faire en root sans qu'on le lui demande. C'est tout l'intérêt, et c'est aussi tout le risque.

## Clés de signature

La clé publique pour toutes les signatures d'ISO et les paquets du dépôt Omarchy est `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([vérifier sur openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Le paquet `omarchy/omarchy-keyring` la contient aussi et servira à déployer sans accroc d'éventuelles mises à jour.

Vous pouvez trouver la signature de toute version d'ISO en ajoutant .sig à l'URL. Comme https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
