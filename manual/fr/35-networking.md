# Réseau

La mise en réseau dans Omarchy est gérée par NetworkManager, et vous la pilotez depuis l'icône réseau dans la [barre supérieure](05-the-top-bar.md) ou avec `Super + Ctrl + N`.

Ce panneau recherche les réseaux Wi-Fi, affiche la puissance du signal et se connecte. L'Ethernet ne demande absolument rien — branchez-le et ça fonctionne. Si vous préférez rester dans le terminal, `nmtui` vous donne les mêmes contrôles, et il existe aussi un groupe de commandes `omarchy network`.

## Partager votre Wi-Fi

Plutôt que de lire un long mot de passe à voix haute, lancez _Setup > Network > QR Code_ pendant que vous êtes en Wi-Fi. Cela affiche un QR code à l'écran que n'importe quel appareil photo de téléphone peut scanner pour rejoindre le réseau. C'est une de ces choses que vous utiliserez plus que vous ne l'imaginez une fois que vous saurez qu'elle est là.

Si vous avez vraiment besoin du mot de passe lui-même, `omarchy network password <interface>` l'affiche.

## DNS

Omarchy utilise le DNS que votre réseau lui transmet via DHCP. Vous pouvez le remplacer pour toute la machine sous _Setup > Network > DNS_, où Cloudflare et Google sont à un clic. Choisissez _Custom_ pour saisir vos propres serveurs.

Depuis le terminal, `omarchy dns` affiche le fournisseur actuel et `omarchy dns Cloudflare` en définit un.

## Épingler la bande Wi-Fi

Si votre routeur met le 2.4GHz, le 5GHz et le 6GHz sous le même nom de réseau, votre ordinateur portable s'accrochera parfois au plus lent. `omarchy network band` indique sur quelle bande vous êtes, et `omarchy network band 5` l'épingle. Utilisez `auto` pour le laisser choisir à nouveau.

Cela épingle la bande plutôt qu'un point d'accès précis, donc vous continuez à passer d'un AP à l'autre normalement.

## À quelle vitesse ?

_Trigger > Speed Test > Network Speed Test_ mesure votre débit réel montant et descendant avec une paire de cadrans. Depuis le terminal, c'est `omarchy network speedtest down` ou `up`. La mesure se fait auprès du service propre à Omarchy et ne compte que ses transferts de test. D'autres téléchargements peuvent se disputer la bande passante, mais ils ne sont pas ajoutés au résultat du test de vitesse. (Il y a un test de vitesse du disque juste à côté dans ce menu, si vous voulez mesurer l'autre goulot d'étranglement.)

## Le pare-feu

Le pare-feu est activé par défaut et bloque tout le trafic entrant, avec une seule exception : le port 53317, pour que [LocalSend](22-guis.md) fonctionne dès l'installation.

SSH est désactivé jusqu'à ce que vous l'activiez avec _Setup > Security > SSHD_, ce qui démarre le démon, ouvre le port 22 avec une limitation de débit contre la force brute et autorise une clé. Docker est verrouillé aussi, pour que les conteneurs ne puissent pas s'exposer accidentellement au monde entier. Voir [sécurité](48-security.md) pour tout savoir.

## Tailscale

[Tailscale](https://tailscale.com/) est un VPN maillé qui rend l'accès à tous vos ordinateurs et serveurs sur Internet simple et sécurisé. Installez-le avec _Install > Service > Tailscale_.

Cela vous donne un panneau Tailscale dans la barre, qui connecte et déconnecte le tailnet, change de compte et choisit un nœud de sortie — vos propres machines et les régions Mullvad apparaissent toutes dans la liste. Il parcourt aussi vos machines, et c'est là que vit Taildrop : sélectionnez une machine et appuyez sur `s` pour lui envoyer des fichiers, ou sur `c`, `n` et `d` pour copier son IP, son nom ou son nom DNS complet. L'équivalent dans le terminal est `omarchy tailscale send <machine> [file...]`, et les fichiers qui vous sont envoyés atterrissent automatiquement dans `~/Downloads`. La notification annonçant une arrivée attend que vous cliquiez dessus pour l'ouvrir ou que vous l'ignoriez, donc un fichier qui arrive pendant que vous êtes loin de la machine est toujours là pour y répondre à votre retour.

L'installation ajoute aussi une application web pour la console d'administration Tailscale.

## Quand ça cesse de fonctionner

Avant de redémarrer, essayez de relancer le morceau fautif tout seul. _Update > Hardware_ propose Wi-Fi, Bluetooth, Audio et Trackpad, et en recharger un suffit à régler la plupart des situations « ça fonctionnait il y a cinq minutes ». Voir [dépannage](45-troubleshooting.md).
