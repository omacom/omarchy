# Réseau

Le réseau dans Omarchy est géré par NetworkManager, et vous le pilotez depuis l'icône réseau de la [barre du haut](05-the-top-bar.md) ou avec `Super + Ctrl + W`.

Ce panneau recherche les réseaux Wi-Fi, affiche l'intensité du signal et établit la connexion. L'Ethernet n'a besoin de rien du tout — branchez-le et ça fonctionne. Si vous préférez rester dans le terminal, `nmtui` vous donne les mêmes contrôles, et il existe aussi un groupe de commandes `omarchy network`.

## Partager votre Wi-Fi

Plutôt que de dicter un long mot de passe à voix haute, lancez _Configuration > Réseau > Code QR_ pendant que vous êtes en Wi-Fi. Cela affiche à l'écran un code QR que n'importe quel appareil photo de téléphone peut scanner pour rejoindre le réseau. C'est l'un de ces trucs que vous utiliserez plus souvent que vous ne l'imaginiez une fois que vous savez qu'il existe.

Si vous avez vraiment besoin du mot de passe lui-même, `omarchy network password <interface>` l'affiche.

## DNS

Omarchy utilise le DNS que votre réseau fournit via DHCP. Vous pouvez remplacer cela pour toute la machine sous _Configuration > Réseau > DNS_, où Cloudflare et Google sont à un clic. Choisissez _Personnalisé_ pour saisir vos propres serveurs.

Depuis le terminal, `omarchy dns` affiche le fournisseur actuel et `omarchy dns Cloudflare` en définit un.

## Fixer la bande Wi-Fi

Si votre routeur place le 2,4 GHz, le 5 GHz et le 6 GHz sous le même nom de réseau, votre portable s'accrochera parfois au plus lent. `omarchy network band` indique sur quelle bande vous êtes, et `omarchy network band 5` la fixe. Utilisez `auto` pour le laisser choisir à nouveau.

Cela fixe la bande plutôt qu'un point d'accès spécifique, si bien que vous continuez à basculer normalement entre les points d'accès.

## À quelle vitesse ça va ?

_Déclencher > Test de vitesse > Test débit réseau_ mesure votre débit réel montant et descendant avec deux jauges. Depuis le terminal, c'est `omarchy network speedtest down` ou `up`. (Un test de débit disque se trouve juste à côté dans ce menu, si vous testez l'autre goulot d'étranglement.)

## Le pare-feu

Le pare-feu est activé par défaut et bloque tout le trafic entrant, avec une seule exception : le port 53317, pour que [LocalSend](22-guis.md) fonctionne d'emblée.

SSH est désactivé jusqu'à ce que vous l'activiez avec _Configuration > Sécurité > SSHD_, qui démarre le démon, ouvre le port 22 avec une limitation de débit contre la force brute et autorise une clé. Docker est verrouillé lui aussi, si bien que les conteneurs ne peuvent pas s'exposer accidentellement au monde entier. Voir [sécurité](48-security.md) pour toute l'histoire.

## Tailscale

[Tailscale](https://tailscale.com/) est un VPN maillé qui rend l'accès à tous vos ordinateurs et serveurs sur Internet simple et sécurisé. Installez-le avec _Installer > Service > Tailscale_.

Cela vous donne un panneau Tailscale dans la barre, qui connecte et déconnecte le tailnet, change de compte et choisit un nœud de sortie — vos propres machines et les régions Mullvad apparaissent tous deux dans la liste. Il parcourt aussi vos machines, et c'est là que vit Taildrop : sélectionnez une machine et appuyez sur `s` pour lui envoyer des fichiers, ou sur `c`, `n` et `d` pour copier son IP, son nom ou son nom DNS complet. L'équivalent dans le terminal est `omarchy tailscale send <machine> [file...]`, et les fichiers qu'on vous envoie atterrissent automatiquement dans `~/Downloads`. La notification annonçant une arrivée attend que vous cliquiez pour l'ouvrir ou la fermiez, si bien qu'un fichier qui arrive pendant votre absence est toujours là à votre retour.

L'installer ajoute aussi une application web pour la console d'administration Tailscale.

## Quand ça cesse de fonctionner

Avant de redémarrer, essayez de redémarrer le composant fautif tout seul. _Mettre à jour > Matériel_ propose Wi-Fi, Bluetooth, Audio et Pavé tactile, et en recharger un résout la plupart des situations du type « ça marchait il y a cinq minutes ». Voir [dépannage](45-troubleshooting.md).
