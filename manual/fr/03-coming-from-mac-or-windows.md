# Venir de Mac ou de Windows

Si vous avez passé des années sur macOS ou Windows, vos doigts connaissent une centaine de choses que votre cerveau a oublié avoir jamais apprises. Ce chapitre est la couche de traduction : où vont ces instincts dans Omarchy. Les fonctionnalités elles-mêmes sont couvertes en profondeur ailleurs — ceci n'est que la carte.

### Super est le centre de tout

Toute la mémoire musculaire que vous avez construite autour de Cmd ou de la touche Windows se transfère sur une seule touche : Super. C'est la touche Windows sur un clavier PC, et c'est le point d'ancrage de presque tous les raccourcis clavier dans Omarchy.

Votre réflexe Spotlight, Raycast ou menu Démarrer devient `Super + Space`. Cela ouvre le menu Omarchy, qui lance les applications, modifie les réglages, installe des logiciels, capture l'écran — à peu près tout. Commencez à taper pour filtrer. `Super + Alt + Space` affiche toutes les applications sur une seule grille, comme le fait Launchpad. Voir [navigation](04-navigation.md).

### Il n'y a ni dock ni icônes sur le bureau

Rien à cliquer pour lancer des choses, aucune icône à ranger sur le bureau. Les applications démarrent depuis un raccourci clavier (`Super + Return` pour le terminal, `Super + Shift + Return` pour le navigateur, et `Super + K` pour une liste de tout ce qui est mappé) ou depuis le menu. Le seul élément d'interface persistant est [la barre supérieure](05-the-top-bar.md), qui couvre ce que la barre de menus, la zone de notification et Notification Center faisaient pour vous avant — et presque chaque widget qu'elle contient fait quelque chose au clic gauche, droit et central.

### Les fenêtres se placent toutes seules

Le plus grand changement de mentalité : vous ne déplacez pas les fenêtres à la souris et vous ne les accrochez pas aux moitiés de l'écran. Ouvrez une fenêtre et elle prend tout l'écran. Ouvrez-en une deuxième et elles se le partagent. Vous ne pêchez jamais une fenêtre sous une autre, parce que les fenêtres ne se chevauchent pas.

Quand vous avez vraiment besoin d'une fenêtre flottante, `Super + T` sort la fenêtre active du tiling, et l'y remet. Mais donnez d'abord une vraie chance au tiling — c'est le cœur de tout le système. [Navigation](04-navigation.md) vous guide à travers tout cela.

Les workspaces vous sembleront familiers : ce sont les Spaces de macOS ou les bureaux virtuels de Windows, sauf que vous les utiliserez vraiment, parce que `Super + 1/2/3/4` saute directement à l'un d'eux et que `Super + Shift + 1/2/3/4` y envoie la fenêtre active. Aucun délai d'animation, juste des sauts instantanés. Cela signifie que vous n'aurez peut-être même pas besoin de plusieurs moniteurs, si c'était votre habitude avant.

### Copier et coller fonctionnent, tout simplement

Sur Mac, vous aviez Cmd + C partout. Sur Windows, vous aviez Ctrl + C partout — sauf dans le terminal, où cela tue votre programme. Omarchy vous donne `Super + C`, `Super + X` et `Super + V`, et ils fonctionnent partout, y compris dans le terminal. Aucun réflexe distinct à apprendre pour le shell.

Utilisateurs Windows : votre historique du presse-papiers Win + V se trouve sur `Super + Ctrl + V`, et il conserve les images aussi bien que le texte. Voir [presse-papiers unifié et historique](08-unified-clipboard-history.md).

### Le tableau de traduction

| Vous cherchez | Dans Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — le menu Omarchy |
| AirDrop | LocalSend, via `Super + Ctrl + S` — voir [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ou `Print Screen` — voir [captures d'écran et enregistrement](12-screenshots-recording.md) |
| Notification Center | Historique des notifications sur `Super + Shift + Alt + ,` |
| Time Machine (pour le système) | [instantanés système](47-system-snapshots.md) automatiques à chaque mise à jour |
| App Store / téléchargement d'un programme d'installation | _Install_ dans le menu, ou `omarchy pkg add` — voir [autres paquets](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ dans le menu, qui modifie de simples fichiers de configuration — voir [dotfiles](31-dotfiles.md) |

### Certaines choses sont vraiment différentes

Beaucoup de réglages vivent dans des fichiers texte que vous modifiez, pas dans des panneaux que vous parcourez à coups de clics. Cela semble primitif jusqu'à ce que vous réalisiez que cela signifie que chaque ajustement peut être vu, copié sur votre prochaine machine et placé sous contrôle de version. Le menu _Setup_ vous dépose directement dans le bon fichier et redémarre ce qui doit l'être quand vous avez terminé.

Les mises à jour passent par une seule commande — _Update > Omarchy_ — qui met à jour Omarchy lui-même et chaque paquet du système, en prenant d'abord un instantané. Aucun programme de mise à jour propre à chaque application pour vous harceler au hasard. Voir [mises à jour](30-updates.md).

Les logiciels viennent d'un gestionnaire de paquets, pas de programmes d'installation téléchargés.

Et quand vous fermez une fenêtre, l'application quitte vraiment. Il n'y a pas de limbes macOS où le programme continue de tourner sans aucune fenêtre. `Super + W` — ou `Super + Q`, si c'est avec cette mémoire des doigts que vous êtes arrivé — signifie disparu.

### Sur le matériel Mac

Omarchy fonctionne bien sur les Mac Intel — voir [prise en charge Mac](44-mac-support.md). Et le clavier est gentil avec vous : Omarchy ne remappe rien, et Linux traite la touche Command comme Super, donc Super se trouve exactement là où Cmd a toujours été. Votre pouce ne remarquera pas le déménagement.

### Donnez-lui deux semaines

Les instincts se transfèrent plus vite que vous ne le pensez. Parcourez le chapitre [raccourcis clavier](07-hotkeys.md) une fois, et chaque fois que vous avez un trou sur une combinaison, frappez `Super + K` — il vous les montre toutes. C'est le seul raccourci clavier que vous avez vraiment à mémoriser.
