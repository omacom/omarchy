# Vous venez de Mac ou de Windows

Si vous avez passé des années sur macOS ou Windows, vos doigts savent une centaine de choses que votre cerveau a oublié avoir jamais apprises. Ce chapitre est la couche de traduction : où vont ces instincts dans Omarchy. Les fonctionnalités elles-mêmes sont traitées en profondeur ailleurs — ceci n’est que la carte.

### Super est au centre de tout

Toute la mémoire musculaire que vous avez construite autour de Cmd ou de la touche Windows se transfère sur une seule touche : Super. C’est la touche Windows sur un clavier PC, et c’est le point d’ancrage de presque tous les raccourcis clavier dans Omarchy.

Votre réflexe Spotlight ou Raycast ou menu Démarrer devient `Super + Space`. Cela ouvre le menu Omarchy, qui lance les applications, modifie les réglages, installe des logiciels, capture l’écran — à peu près tout. Commencez à taper pour filtrer. `Super + Alt + Space` affiche toutes les applications sur une seule grille, comme le fait Launchpad. Voir [navigation](04-navigation.md).

### Aucune icône sur le bureau, et le dock n’apparaît que lorsque vous flottez

Aucune icône à disposer sur le bureau, et aucun dock sur un espace de travail en mosaïque — le dock n’apparaît que sur un espace de travail flottant (voir [navigation](04-navigation.md)). Les applications se lancent avec un raccourci clavier (`Super + Return` pour le terminal, `Super + Shift + Return` pour le navigateur, et `Super + K` pour une liste de tout ce qui est assigné) ou depuis le menu. Le seul élément d’interface persistant est [la barre supérieure](05-the-top-bar.md), qui couvre ce que la barre de menus, la zone de notification et le Notification Center faisaient pour vous auparavant — et presque chaque widget qui s’y trouve fait quelque chose au clic gauche, droit et central.

### Les fenêtres se placent toutes seules

Le plus grand changement de mentalité : vous ne déplacez pas les fenêtres à la souris et vous ne les accrochez pas à des moitiés d’écran. Ouvrez une fenêtre et elle prend tout l’écran. Ouvrez-en une deuxième et elles se partagent l’écran. Vous ne déterrez jamais une fenêtre de sous une autre, parce que les fenêtres ne se chevauchent pas.

Quand vous avez vraiment besoin d’une fenêtre flottante, `Super + T` fait sortir la fenêtre active de la mosaïque (et l’y remet). Mais donnez d’abord une vraie chance à la mosaïque — c’est le cœur de tout le système. [Navigation](04-navigation.md) vous guide pas à pas.

Les espaces de travail vous sembleront familiers : ce sont les Spaces de macOS ou les bureaux virtuels de Windows, sauf que vous les utiliserez vraiment, parce que `Super + 1/2/3/4` saute directement à l’un d’eux et `Super + Shift + 1/2/3/4` y envoie la fenêtre active. Aucun délai d’animation, juste des sauts instantanés. Cela signifie que vous n’aurez peut-être même pas besoin de plusieurs moniteurs, si vous en aviez l’habitude auparavant.

### Le copier-coller fonctionne, tout simplement

Sur Mac, vous aviez Cmd + C partout. Sur Windows, vous aviez Ctrl + C partout — sauf dans le terminal, où cela tue votre programme. Omarchy vous donne `Super + C`, `Super + X` et `Super + V`, et ils fonctionnent partout, y compris dans le terminal. Aucun réflexe distinct à apprendre pour le shell.

Utilisateurs de Windows : votre historique du presse-papiers avec Win + V vit sur `Super + Ctrl + V`, et il contient les images aussi bien que le texte. Voir [presse-papiers unifié et historique](08-unified-clipboard-history.md).

### Le tableau de traduction

| Vous cherchez | Dans Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Démarrer | `Super + Space` — le menu Omarchy |
| AirDrop | LocalSend, via `Super + Ctrl + S` — voir [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ou `Print Screen` — voir [captures d’écran et enregistrement](12-screenshots-recording.md) |
| Notification Center | Historique des notifications sur `Super + Shift + Alt + ,` |
| Time Machine (pour le système) | [Instantanés système](47-system-snapshots.md) automatiques à chaque mise à jour |
| App Store / téléchargement d’un programme d’installation | _Install_ dans le menu, ou `omarchy pkg add` — voir [autres paquets](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ dans le menu, qui modifie de simples fichiers de configuration — voir [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, sur `Super + Shift + F` — voir [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome sur `Super + Shift + Return` ; choisissez-en un autre sous _Setup > Defaults > Browser_ — voir [navigateurs](23-browsers.md) |
| Preview / Photos | Omaview pour les images, la vidéo et la musique, Document Viewer pour les PDF — voir [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, sur `Super + Shift + N` ; choisissez-en un autre sous _Setup > Defaults > Editor_ |

### Certaines choses sont vraiment différentes

Beaucoup de réglages vivent dans des fichiers texte que vous modifiez, pas dans des panneaux que vous parcourez en cliquant. Cela semble primitif jusqu’à ce que vous réalisiez que cela signifie que chaque ajustement peut être vu, copié sur votre prochaine machine et placé sous contrôle de version. Le menu _Setup_ vous dépose directement dans le bon fichier et redémarre ce qui doit l’être quand vous avez terminé.

Les mises à jour passent par une seule commande — _Update > Omarchy_ — qui met à jour Omarchy lui-même et chaque paquet du système, en prenant un instantané d’abord. Aucun programme de mise à jour par application pour vous harceler au hasard. Voir [mises à jour](30-updates.md).

Les logiciels viennent d’un gestionnaire de paquets, pas de programmes d’installation téléchargés.

Et quand vous fermez une fenêtre, l’application se quitte vraiment. Il n’y a pas de limbes macOS où le programme continue de tourner sans aucune fenêtre. `Super + W` — ou `Super + Q`, si c’est la mémoire des doigts avec laquelle vous êtes arrivé — signifie disparu.

### Sur le matériel Mac

Omarchy fonctionne bien sur les Mac Intel — voir [prise en charge des Mac](44-mac-support.md). Et le clavier est gentil avec vous : Omarchy ne réassigne rien, et Linux traite la touche Command comme Super, donc Super se trouve exactement là où Cmd a toujours été. Votre pouce ne remarquera pas le déménagement.

### Donnez-lui deux semaines

Les instincts se transfèrent plus vite que vous ne le pensez. Parcourez le chapitre [raccourcis clavier](07-hotkeys.md) une fois, et chaque fois que vous avez un trou sur une assignation, appuyez sur `Super + K` — il vous les montre toutes. C’est le seul raccourci clavier que vous devez vraiment mémoriser.
