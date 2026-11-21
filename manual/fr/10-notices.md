# Avis

Les notifications arrivent dans le coin supérieur droit de l'écran actif. Vous pouvez aussi accéder rapidement à la date et à l'heure, à l'état de la batterie et à la météo actuelle à l'aide des avis par raccourci clavier.

## Notifications

Les notifications d'une même application ou d'un même site s'empilent en un paquet, de sorte qu'un canal Slack bavard ne pousse pas votre échec de compilation hors de l'écran. Survolez un paquet pour le déployer en éventail ; rien de nouveau ne glisse sous votre pointeur pendant que vous lisez. Cliquez sur une carte pour aller à son origine, cliquez avec le bouton droit, cliquez avec le bouton du milieu ou cliquez sur le ✕ pour l'ignorer.

Les cartes proposent ce qu'elles contiennent : _Copier le code_ pour les codes de vérification (tenus à l'écart de l'[historique du presse-papiers](08-unified-clipboard-history.md) et effacés après une minute), plus tous les boutons fournis par l'application. Les liens présents dans le texte d'une notification s'ouvrent lorsqu'on clique dessus.

`Super + ,` ignore la notification la plus récente, ou ouvre ce vers quoi elle pointe lorsqu'elle le propose, `Super + Alt + ,` ignore uniquement la dernière, `Super + Shift + ,` les ignore toutes, et `Super + Shift + Alt + ,` ouvre l'historique. Pour les utiliser sans la souris, appuyez sur `Super + Ctrl + ,`. La notification la plus récente est sélectionnée et ses boutons sont numérotés : appuyez sur un numéro pour en utiliser un, `Enter` pour cliquer sur la notification, `↑` et `↓` pour passer d'une notification à l'autre, `Delete` pour en ignorer une, et `Esc` pour rendre le clavier. Elle se libère aussi d'elle-même après quelques secondes d'inactivité.

Mettre les notifications en silence les retient, à l'exception des propres confirmations d'Omarchy, des alertes d'urgence et des codes de vérification, que vous avez demandés il y a un instant. Remettez les dernières à l'écran, qu'elles aient été retenues ou non, avec `Super + Shift + Alt + ,`. L'historique est conservé pendant un jour.

## Avis par raccourci clavier

### Date et heure

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Météo

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

La localisation est détectée à partir de votre adresse IP, ce qui est généralement assez proche, mais pas toujours. Vous pouvez la préciser avec `omarchy weather location --set Malibu`, ou être exact à son sujet en ajoutant des coordonnées : `omarchy weather location --set Malibu 34.0259,-118.7798`. Exécutez `omarchy weather location` seul pour voir où il pense que vous êtes, et `--clear` pour revenir à la détection automatique.

### Batterie

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
