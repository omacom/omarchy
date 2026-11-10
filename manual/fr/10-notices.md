# Notifications

Les notifications arrivent dans le coin supérieur droit de l'écran qui a le focus. Tu peux aussi accéder rapidement à la date et à l'heure, à l'état de la batterie et à la météo actuelle grâce aux notifications par raccourci clavier.

## Notifications

Les notifications d'une même application ou d'un même site s'empilent en un paquet, pour qu'un canal Slack bavard ne pousse pas ton échec de build hors de l'écran. Survole un paquet pour le déployer en éventail ; rien de nouveau ne glisse sous ton pointeur pendant que tu lis. Clique sur une carte pour sauter à son origine, clique avec le bouton droit, clique avec le bouton du milieu ou appuie sur le ✕ pour l'ignorer.

Les cartes proposent ce qu'elles transportent : _Copier le code_ pour les codes de vérification (tenus à l'écart de l'[historique du presse-papiers](08-unified-clipboard-history.md) et effacés au bout d'une minute), plus tous les boutons fournis par l'application. Les liens dans le texte d'une notification s'ouvrent quand on clique dessus.

Pour les utiliser sans la souris, appuie sur `Super + Ctrl + ,`. La notification la plus récente est sélectionnée et ses boutons sont numérotés : appuie sur un chiffre pour en utiliser un, sur `Enter` pour cliquer sur la notification, sur `↑` et `↓` pour passer d'une notification à l'autre, sur `Delete` pour en ignorer une, et sur `Esc` pour rendre le clavier. Elle lâche aussi prise d'elle-même au bout de quelques secondes d'inactivité.

Mettre les notifications en silence les retient, sauf les confirmations d'Omarchy lui-même, les alertes d'urgence et les codes de vérification, que tu as demandés il y a un instant. Remets les dernières à l'écran, retenues ou non, avec `Super + Shift + Alt + ,`. L'historique est conservé pendant un jour.

## Notifications par raccourci clavier

### Date et heure

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Météo

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

L'emplacement est détecté à partir de ton adresse IP, ce qui est généralement assez proche, mais pas toujours. Tu peux le verrouiller avec `omarchy weather location --set Malibu`, ou être précis en ajoutant des coordonnées : `omarchy weather location --set Malibu 34.0259,-118.7798`. Lance `omarchy weather location` seul pour voir où il pense que tu es, et `--clear` pour revenir à la détection automatique.

### Batterie

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
