# Venir de Mac ou de Windows

Si vous avez passé des années sous macOS ou Windows, vos doigts savent cent choses que votre cerveau a oublié avoir jamais apprises. Ce chapitre est la couche de traduction : où vont ces réflexes dans Omarchy. Les fonctionnalités elles-mêmes sont couvertes en profondeur ailleurs — ceci n'est que la carte.

### Super est le centre de tout

Toute la mémoire musculaire que vous avez construite autour de Cmd ou de la touche Windows se transfère sur une seule touche : Super. C'est la touche Windows d'un clavier PC, et c'est l'ancre de presque tous les raccourcis clavier d'Omarchy.

Votre réflexe Spotlight, Raycast ou menu Démarrer devient `Super + Space`. Cela ouvre le menu Omarchy, qui lance les applis, change les réglages, installe des logiciels, capture l'écran — à peu près tout. Commencez à taper pour filtrer. `Super + Alt + Space` affiche toutes les applis sur une grille, comme le fait Launchpad. Voir [navigation](04-navigation.md).

### Il n'y a ni dock ni icônes sur le bureau

Rien à cliquer pour lancer des choses, pas d'icônes à organiser sur le bureau. Les applis démarrent depuis un raccourci (`Super + Return` pour le terminal, `Super + Shift + Return` pour le navigateur, et `Super + K` pour une liste de tout ce qui est mappé) ou depuis le menu. Le seul élément d'interface persistant est [la barre supérieure](05-the-top-bar.md), qui couvre ce que la barre de menu, la zone de notification et le centre de notifications faisaient pour vous avant — et presque chaque widget dessus fait quelque chose au clic gauche, droit et central.

### Les fenêtres se placent toutes seules

Le plus grand changement d'état d'esprit : vous ne déplacez pas les fenêtres à la souris et vous ne les collez pas aux moitiés d'écran. Ouvrez une fenêtre et elle prend tout l'écran. Ouvrez-en une deuxième et elles se le partagent. Vous ne pêchez jamais une fenêtre sous une autre, parce que les fenêtres ne se chevauchent pas.

Quand vous avez vraiment besoin d'une fenêtre flottante, `Super + T` bascule la fenêtre active hors de la mosaïque (et inversement). Mais donnez d'abord une vraie chance à la mosaïque — c'est le cœur du tout. [Navigation](04-navigation.md) vous guide à travers tout cela.

Les espaces de travail vous sembleront familiers : ce sont les Spaces de macOS ou les bureaux virtuels de Windows, sauf que vous les utiliserez réellement, parce que `Super + 1/2/3/4` saute directement à l'un d'eux et `Super + Shift + 1/2/3/4` y envoie la fenêtre active. Aucun délai d'animation, juste des sauts instantanés. Cela signifie que vous n'aurez peut-être même pas besoin de plusieurs écrans, si vous y étiez habitué avant.

### Copier-coller fonctionne simplement

Sur Mac, vous aviez Cmd + C partout. Sur Windows, vous aviez Ctrl + C partout — sauf dans le terminal, où il tue votre programme. Omarchy vous donne `Super + C`, `Super + X` et `Super + V`, et ils fonctionnent partout, y compris dans le terminal. Aucun réflexe séparé à apprendre pour le shell.

Utilisateurs Windows : votre historique de presse-papiers Win + V vit sur `Super + Ctrl + V`, et il contient les images aussi bien que le texte. Voir [presse-papiers unifié et historique](08-unified-clipboard-history.md).

### Le tableau de traduction

| Ce que vous cherchez | Dans Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Démarrer | `Super + Space` — le menu Omarchy |
| AirDrop | LocalSend, via `Super + Ctrl + S` — voir [interfaces graphiques](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — voir [captures d'écran et enregistrement](12-screenshots-recording.md) |
| Centre de notifications | Historique des notifications sur `Super + Shift + Alt + ,` |
| Time Machine (pour le système) | [Snapshots système](47-system-snapshots.md) automatiques à chaque mise à jour |
| App Store / téléchargement d'un installateur | _Installer_ dans le menu, ou `omarchy pkg add` — voir [autres paquets](29-other-packages.md) |
| Réglages système / Panneau de configuration | _Configuration_ dans le menu, qui édite de simples fichiers de configuration — voir [dotfiles](31-dotfiles.md) |

### Certaines choses sont vraiment différentes

Beaucoup de réglages vivent dans des fichiers texte que vous éditez, pas dans des panneaux où vous cliquez. Cela semble primitif jusqu'à ce que vous réalisiez que cela signifie que chaque ajustement peut être vu, copié vers votre prochaine machine et placé sous contrôle de version. Le menu _Configuration_ vous dépose directement dans le bon fichier et redémarre ce qui doit l'être quand vous avez terminé.

Les mises à jour passent par une seule commande — _Mettre à jour > Omarchy_ — qui met à jour Omarchy lui-même et chaque paquet du système, en prenant d'abord un snapshot. Aucun programme de mise à jour par appli pour vous harceler au hasard. Voir [mises à jour](30-updates.md).

Les logiciels proviennent d'un gestionnaire de paquets, pas d'installateurs téléchargés.

Et quand vous fermez une fenêtre, l'appli se ferme réellement. Il n'y a aucun limbe macOS où le programme continue de tourner sans fenêtre. `Super + W` — ou `Super + Q`, si c'est la mémoire des doigts avec laquelle vous êtes arrivé — signifie parti.

### Sur du matériel Mac

Omarchy fonctionne bien sur les Mac Intel — voir [prise en charge Mac](44-mac-support.md). Et le clavier est gentil avec vous : Omarchy ne remappe rien, et Linux traite la touche Command comme Super, donc Super se trouve exactement là où Cmd a toujours été. Votre pouce ne remarquera pas le déménagement.

### Donnez-lui deux semaines

Les réflexes se transfèrent plus vite que vous ne le pensez. Parcourez le chapitre [raccourcis clavier](07-hotkeys.md) une fois, et chaque fois que vous séchez sur un raccourci, faites `Super + K` — il vous les montre tous. C'est le seul raccourci que vous ayez vraiment à mémoriser.
