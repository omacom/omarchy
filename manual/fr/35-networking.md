# Réseau

Le réseau dans Omarchy est géré par NetworkManager, et vous le pilotez depuis l'icône réseau dans la [barre supérieure](05-the-top-bar.md) ou avec `Super + Ctrl + N`.

Ce panneau recherche les réseaux Wi-Fi, affiche la puissance du signal et se connecte. L'Ethernet ne demande rien du tout — branchez-le et ça marche. Si vous préférez rester dans le terminal, `nmtui` vous donne les mêmes commandes, et il existe aussi un groupe de commandes `omarchy network`.

## Partager votre Wi-Fi

Plutôt que de lire un long mot de passe à voix haute, lancez _Configuration > Réseau > Code QR_ pendant que vous êtes en Wi-Fi. Cela affiche un code QR à l'écran que l'appareil photo de n'importe quel téléphone peut scanner pour se connecter. C'est l'une de ces choses que vous utiliserez plus souvent que vous ne l'imaginez une fois que vous saurez qu'elle est là.

Si vous avez vraiment besoin du mot de passe lui-même, `omarchy network password <interface>` l'affiche.

## DNS

Omarchy utilise le DNS que votre réseau lui fournit via DHCP. Vous pouvez remplacer cela pour l'ensemble de la machine sous _Configuration > Réseau > DNS_, où Cloudflare et Google sont à un clic. Choisissez _Personnalisé_ pour saisir vos propres serveurs.

Depuis le terminal, `omarchy dns` affiche le fournisseur actuel et `omarchy dns Cloudflare` en définit un.

## Fixer la bande Wi-Fi

Si votre routeur place le 2.4GHz, le 5GHz et le 6GHz sous le même nom de réseau, votre portable s'accrochera parfois à la bande la plus lente. `omarchy network band` montre sur quelle bande vous êtes, et `omarchy network band 5` la fixe. Utilisez `auto` pour le laisser choisir à nouveau.

Cela fixe la bande plutôt qu'un point d'accès précis, donc vous continuez à passer normalement d'un AP à l'autre.

## À quelle vitesse ?

_Déclencheur > Test de vitesse > Test de vitesse réseau_ mesure votre débit réel en téléchargement et en envoi à l'aide d'une paire de cadrans. Depuis le terminal, c'est `omarchy network speedtest down` ou `up`. (Il y a un test de vitesse du disque juste à côté dans ce menu, si vous testez l'autre goulot d'étranglement.)

## Le pare-feu

Le pare-feu est activé par défaut et bloque tout le trafic entrant, avec une exception : le port 53317, pour que [LocalSend](22-guis.md) fonctionne dès l'installation.

SSH est désactivé jusqu'à ce que vous l'activiez avec _Configuration > Sécurité > SSHD_, ce qui démarre le démon, ouvre le port 22 avec une limitation du débit contre les attaques par force brute et autorise une clé. Docker est verrouillé lui aussi, donc les conteneurs ne peuvent pas s'exposer accidentellement au monde entier. Voir [sécurité](48-security.md) pour toute l'histoire.

## Tailscale

[Tailscale](https://tailscale.com/) est un VPN maillé qui rend l'accès à tous vos ordinateurs et serveurs via internet simple et sécurisé. Installez-le avec _Installation > Service > Tailscale_.

Cela vous donne un panneau Tailscale dans la barre, qui connecte et déconnecte le tailnet, change de compte et choisit un nœud de sortie — vos propres machines et les régions Mullvad apparaissent toutes dans la liste. Il permet aussi de parcourir vos machines, et c'est là que se trouve Taildrop : sélectionnez une machine et appuyez sur `s` pour lui envoyer des fichiers, ou sur `c`, `n` et `d` pour copier son IP, son nom ou son nom DNS complet. L'équivalent dans le terminal est `omarchy tailscale send <machine> [file...]`, et les fichiers qui vous sont envoyés arrivent automatiquement dans `~/Downloads`. La notification annonçant une arrivée attend que vous cliquiez dessus pour l'ouvrir ou que vous l'écartiez, donc un fichier qui arrive pendant que vous êtes loin de la machine est toujours là pour que vous puissiez y répondre à votre retour.

Son installation ajoute aussi une application web pour la console d'administration Tailscale.

## Quand ça cesse de fonctionner

Avant de redémarrer, essayez de redémarrer le seul élément fautif. _Mise à jour > Matériel_ propose Wi-Fi, Bluetooth, Audio et Trackpad, et recharger l'un d'eux résout la plupart des situations « ça marchait il y a cinq minutes ». Voir [dépannage](45-troubleshooting.md).
