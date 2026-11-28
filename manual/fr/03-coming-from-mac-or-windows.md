# Vous venez de Mac ou de Windows

Si vous avez passé des années sur macOS ou Windows, vos doigts connaissent une centaine de choses que votre cerveau a oublié avoir jamais apprises. Ce chapitre sert de couche de traduction : il indique où ces réflexes trouvent leur place dans Omarchy. Les fonctionnalités elles-mêmes sont traitées en profondeur ailleurs — ceci n'est que la carte.

### Super est au centre de tout

Toute la mémoire musculaire que vous avez construite autour de Cmd ou de la touche Windows se transfère sur une seule touche : Super. C'est la touche Windows sur un clavier PC, et c'est le point d'ancrage de presque tous les raccourcis clavier dans Omarchy.

Votre réflexe Spotlight, Raycast ou menu Démarrer devient `Super + Space`. Cela ouvre le menu Omarchy, qui lance les applications, modifie les réglages, installe des logiciels, capture l'écran — à peu près tout. Commencez à taper pour filtrer. `Super + Alt + Space` affiche toutes les applications sur une seule grille, comme le fait Launchpad. Voir [navigation](04-navigation.md).

### Aucune icône sur le bureau, et le dock reste à l'écart

Aucune icône à disposer sur le bureau, et le dock se masque dès qu'un espace de travail contient une fenêtre, jusqu'à ce que vous poussiez le pointeur vers son bord de l'écran, celui du bas sauf si vous le déplacez (voir [navigation](04-navigation.md)). Les applications se lancent depuis un raccourci clavier (`Super + Return` pour le terminal, `Super + Shift + Return` pour le navigateur, et `Super + K` pour la liste de tout ce qui est assigné) ou depuis le menu. Le seul élément d'interface persistant est [la barre supérieure](05-the-top-bar.md), qui couvre ce que la barre de menus, la zone de notification système et le Centre de notifications faisaient pour vous auparavant — et presque chaque widget qu'elle contient fait quelque chose au clic gauche, droit et central.

### Les fenêtres se placent toutes seules

Le plus grand changement de mentalité : vous ne déplacez pas les fenêtres à la souris et vous ne les accrochez pas à une moitié de l'écran. Ouvrez une fenêtre et elle occupe tout l'écran. Ouvrez-en une deuxième et elles se le partagent. Vous n'avez jamais à aller repêcher une fenêtre sous une autre, parce que les fenêtres ne se chevauchent pas.

Quand vous avez vraiment besoin d'une fenêtre flottante, `Super + T` fait sortir la fenêtre active du pavage (et l'y remet). Mais donnez d'abord une vraie chance au pavage — c'est le cœur de tout le système. [Navigation](04-navigation.md) vous guide pas à pas.

Les espaces de travail vous sembleront familiers : ce sont les Spaces de macOS ou les bureaux virtuels de Windows, sauf que vous les utiliserez vraiment, parce que `Super + 1/2/3/4` passe directement à l'un d'eux et que `Super + Shift + 1/2/3/4` y envoie la fenêtre active. Aucun délai d'animation, juste des sauts instantanés. Cela signifie que vous n'aurez peut-être même plus besoin de plusieurs écrans, si c'était votre habitude auparavant.

### Le copier-coller fonctionne, tout simplement

Sur Mac, vous aviez Cmd + C partout. Sur Windows, vous aviez Ctrl + C partout — sauf dans le terminal, où cela tue votre programme. Omarchy vous donne `Super + C`, `Super + X` et `Super + V`, et ils fonctionnent partout, y compris dans le terminal. Aucun réflexe distinct à apprendre pour le shell.

Utilisateurs de Windows : votre historique du presse-papiers Win + V se trouve sur `Super + Ctrl + V`, et il conserve les images aussi bien que le texte. Voir [presse-papiers unifié et historique](08-unified-clipboard-history.md).

### Le tableau de traduction

| Vous cherchez | Dans Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Démarrer | `Super + Space` — le menu Omarchy |
| AirDrop | LocalSend, via `Super + Ctrl + S` — voir [interfaces graphiques](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ou `Print Screen` — voir [captures d'écran et enregistrement](12-screenshots-recording.md) |
| Centre de notifications | Historique des notifications sur `Super + Shift + Alt + ,` |
| Time Machine (pour le système) | [Instantanés système](47-system-snapshots.md) automatiques à chaque mise à jour |
| App Store / téléchargement d'un programme d'installation | _Installer_ dans le menu, ou `omarchy pkg add` — voir [autres paquets](29-other-packages.md) |
| Réglages Système / Panneau de configuration | _Configuration_ dans le menu, qui modifie de simples fichiers de configuration — voir [dotfiles](31-dotfiles.md) |
| Finder / Explorateur de fichiers | Files, sur `Super + Shift + F` — voir [interfaces graphiques](22-guis.md) |
| Safari / Edge | Google Chrome sur `Super + Shift + Return` ; choisissez-en un autre sous _Configuration > Par défaut > Navigateur_ — voir [navigateurs](23-browsers.md) |
| Aperçu / Photos | Omaview pour les images, la vidéo et la musique, Document Viewer pour les PDF — voir [interfaces graphiques](22-guis.md) |
| TextEdit / Bloc-notes | Plain, sur `Super + Shift + N` ; choisissez-en un autre sous _Configuration > Par défaut > Éditeur_ |

### Certaines choses sont vraiment différentes

Beaucoup de réglages vivent dans des fichiers texte que vous modifiez, et non dans des panneaux que vous parcourez à coups de clics. Cela semble primitif jusqu'à ce que vous réalisiez que cela signifie que chaque ajustement peut être vu, copié sur votre prochaine machine et placé sous contrôle de version. Le menu _Configuration_ vous dépose directement dans le bon fichier et redémarre ce qui doit l'être quand vous avez terminé.

Les mises à jour passent par une seule commande — _Mettre à jour > Omarchy_ — qui met à jour Omarchy lui-même et chaque paquet du système, en prenant d'abord un instantané. Aucun programme de mise à jour par application pour vous harceler au hasard. Voir [mises à jour](30-updates.md).

Les logiciels viennent d'un gestionnaire de paquets, et non de programmes d'installation téléchargés.

Et quand vous fermez une fenêtre, l'application se quitte vraiment. Il n'y a pas de limbes à la macOS où le programme continue de tourner sans aucune fenêtre. `Super + W` — ou `Super + Q`, si c'est la mémoire musculaire avec laquelle vous arrivez — signifie disparu.

### Sur le matériel Mac

Omarchy fonctionne bien sur les Mac Intel, et sur les Mac M1, M2 et M3 avec Omarchy pour Apple Silicon. Voir [prise en charge Mac](44-mac-support.md). Et le clavier est bienveillant avec vous : Omarchy ne réassigne rien, et Linux traite la touche Command comme Super, donc Super se trouve exactement là où Cmd a toujours été. Votre pouce ne remarquera pas le déménagement.

### Donnez-lui deux semaines

Les réflexes se transfèrent plus vite que vous ne le pensez. Parcourez une fois le chapitre [raccourcis clavier](07-hotkeys.md), et chaque fois que vous avez un trou sur une assignation, appuyez sur `Super + K` — il vous les montre toutes. C'est le seul raccourci clavier que vous avez vraiment à mémoriser.
