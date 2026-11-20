# Navigation

Tout dans Omarchy se fait au clavier — _TOUT !_ Quand le système démarre pour la première fois, vous ne pouvez littéralement rien faire avec la seule souris. Mais vous pouvez appuyer sur `Super + Space` pour afficher le menu Omarchy et, de là, vous pouvez faire à peu près tout.

Mais le menu Omarchy n'est même pas censé être le principal moyen d'utiliser le système la plupart du temps. On peut aller plus vite que ça ! Toutes les applications les plus importantes sont liées directement à des raccourcis individuels. Vous lancez le terminal avec `Super + Return` et un navigateur avec `Super + Shift + Return`. Essayez de faire l'un après l'autre, et vous verrez la magie du tiling de Hyprland en action :

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Vous pouvez ensuite appuyer sur `Super + J` pour les empiler l'une sur l'autre au lieu de les mettre côte à côte :

 ![navigation-stacked](images/navigation-stacked.webp)

Appuyez de nouveau sur `Super + J` pour les remettre côte à côte. Essayez ensuite `Super + Shift + Arrow Right` pendant que vous êtes dans le navigateur pour échanger les fenêtres.

Essayez maintenant `Super + Shift + T` pour lancer le moniteur d'activité. Il apparaîtra sous forme de fenêtre flottante. Vous pouvez le mettre en mosaïque avec `Super + T` (et appuyer de nouveau dessus pour le rendre à nouveau flottant). Appuyez maintenant sur `Super + Shift + F` pour ouvrir le gestionnaire de fichiers. Vous aurez une belle configuration en quatre parties :

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Vous naviguez entre les fenêtres pour choisir celle qui doit être active avec `Super + Arrow`. Cela change le focus et déplace le curseur au centre de la nouvelle application. Au bord d'un écran, cela se poursuit sur le moniteur situé de ce côté.

Si vous appuyez sur `Super + Shift + 2`, vous déplacerez l'application active actuelle vers le deuxième espace de travail. `Super + Shift + 1` la ramène. (Et `Super + Shift + Alt + 2` déplacera l'application active actuelle vers le deuxième espace de travail sans y basculer).

Avec plusieurs moniteurs, chaque moniteur possède ses propres espaces de travail 1 à 10. `Super + 2` va au deuxième espace de travail du moniteur où vous vous trouvez, et la barre supérieure de chaque moniteur affiche ses propres espaces de travail et celui qu'il affiche. `Super + Tab` fait défiler les espaces de travail du moniteur où vous vous trouvez. `Super + Shift + Ctrl + Arrows` déplace la fenêtre où vous vous trouvez vers le moniteur dans cette direction, sur l'espace de travail qu'il affiche, et `Super + Shift + Alt + Arrows` déplace l'espace de travail où vous vous trouvez vers le moniteur dans cette direction, où il prend le même numéro s'il est libre. Un moniteur conserve ses espaces de travail quand vous le débranchez : ils rejoignent ceux d'un autre écran, numérotés après ceux qu'il a déjà, et reprennent leurs anciens numéros quand le moniteur revient.

Si vous maintenez `Super` et utilisez la souris pour cliquer sur une fenêtre, vous pourrez réorganiser sa position. Si vous maintenez `Super` et utilisez le bouton droit de la souris, vous pouvez redimensionner librement la fenêtre.

Vous fermez une fenêtre avec `Super + W` ou `Super + Q` (et fermez toutes les fenêtres avec `Ctrl + Alt + Delete`).

Vous pouvez aussi passer en plein écran avec `Super + F` ou même simplement en pleine largeur (en gardant la barre supérieure) avec `Super + Alt + F` ou en plein écran à l'intérieur d'une fenêtre avec `Super + Ctrl + F` (parfait pour YouTube !).

### Dwindle contre la disposition défilante

La disposition par défaut d'Omarchy s'appelle dwindle. Elle garde toutes les fenêtres que vous ouvrez sur un seul espace de travail visibles à tout moment, même si elle doit les réduire.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mais vous pouvez aussi choisir de transformer un espace de travail en disposition défilante, où les fenêtres sont alignées côte à côte, au-delà du bord visible de l'écran. Vous transformez un espace de travail unique en cette disposition via `Super + L`.

Appuyer de nouveau sur `Super + L` rend l'espace de travail flottant, où les fenêtres se chevauchent librement et où vous les placez vous-même, et une troisième pression le ramène à dwindle. `Super + Alt + L` les parcourt dans l'autre sens. Une fenêtre qui flotte de toute façon — celle que vous avez détachée avec `Super + T`, ou une application qui s'ouvre toujours en flottant — continue de flotter quand l'espace de travail revient en mosaïque. La barre supérieure marque l'espace de travail où vous vous trouvez avec sa disposition : un carré pour dwindle, un cercle pour scrolling, et un triangle pour floating. Cliquer sur cette marque fait aussi défiler les dispositions, tout comme la touche d'affichage sur les ordinateurs portables qui en ont une.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Le choix se fait par espace de travail, et il persiste. Vous pouvez donc garder l'espace de travail 1 en dwindle pour naviguer et l'espace de travail 2 en scrolling pour coder, et ils reviendront ainsi après un redémarrage.

Si vous souhaitez utiliser la disposition défilante par défaut, vous pouvez la définir dans `~/.config/hypr/looknfeel.lua` :

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espaces de travail flottants

Un espace de travail flottant fonctionne comme un bureau traditionnel : les fenêtres se chevauchent, et vous les déplacez et les dimensionnez vous-même. Chaque fenêtre reçoit une barre de titre aux couleurs de votre thème, avec des boutons pour réduire, agrandir et fermer. `Super + M` réduit aussi la fenêtre active. Une fenêtre réduite attend dans le dock ; cliquez sur son application pour la ramener. Cliquez sur une fenêtre pour la mettre au premier plan. Redimensionnez-la depuis n'importe quel bord ou coin. Double-cliquez sur une barre de titre pour agrandir la fenêtre tout en gardant la barre supérieure en vue, et de nouveau pour retrouver son ancienne taille. Chrome et les autres navigateurs basés sur Chromium, Disks et Document Viewer ignorent la barre de titre et utilisent leur propre en-tête à la place ; `Super + Alt + F` les agrandit, et `Super + M` les réduit.

Un espace de travail flottant affiche aussi un dock, avec vos applications épinglées, tout ce qui est en cours d'exécution, et une grille de toutes les applications derrière le bouton des applications, que `Super + Alt + Space` et _Apps_ dans le menu Omarchy ouvrent aussi. Faites un clic droit sur une application dans la grille, ou appuyez sur `Delete`, pour la désinstaller. Cliquez sur une application pour l'ouvrir, ou pour mettre sa fenêtre au premier plan ; cliquez de nouveau pour faire défiler ses fenêtres. Files ne ramène une fenêtre que depuis l'espace de travail où vous vous trouvez et en ouvre sinon une nouvelle, et Terminal et Agent en lancent toujours une autre, même si une fenêtre réduite revient d'abord. Un clic du milieu ouvre une nouvelle fenêtre. Faites glisser une icône le long du dock pour la déplacer ; faire glisser une application en cours d'exécution parmi les autres la conserve à cet endroit. Faites un clic droit pour garder une application dans le dock, l'en retirer, ou la quitter. Le dock s'écarte devant une fenêtre en plein écran. Faites un clic droit sur le bouton des applications pour déplacer le dock vers un autre bord ou pour le masquer jusqu'à ce que le pointeur atteigne son bord. La position se trouve aussi sous _Appearance > Dock > Dock Position_, et `omarchy dock position left` et `omarchy dock autohide on` définissent les deux depuis un terminal. Les applications que vous gardez dans le dock sont estompées quand elles ne sont pas en cours d'exécution.

Les nouveaux espaces de travail, et tous ceux auxquels vous n'avez pas donné leur propre disposition avec `Super + L`, utilisent la disposition par défaut. Changer la disposition par défaut y réinitialise chaque espace de travail sans fenêtres, tandis qu'un espace de travail avec des fenêtres conserve la disposition qu'il a. Une fenêtre réduite dans le dock compte toujours comme une fenêtre sur l'espace de travail qu'elle a quitté. Choisissez-la sous _Appearance > Workspace Layout_ : Tiling, Scrolling, ou Floating. `omarchy hyprland workspace layout default scrolling` la définit depuis un terminal.

### Regrouper les fenêtres

Les fenêtres peuvent être regroupées avec `Super + G`. Une fois que vous êtes dans un groupe, chaque fenêtre que vous lancez pendant qu'il est actif appartiendra au groupe. Vous pouvez vous déplacer entre ces fenêtres regroupées avec `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` pour aller directement aux fenêtres regroupées dans l'ordre.

Vous pouvez sortir une fenêtre du groupe avec `Super + Alt + G` ou démonter tout le groupe en appuyant de nouveau sur `Super + G`. Enfin, vous pouvez déplacer des fenêtres extérieures au groupe vers celui-ci avec `Super + Alt + Arrows`.

### Détacher des fenêtres

Vous pouvez détacher une fenêtre de son affectation à un espace de travail avec `Super + O`. Cela l'épinglera comme une fenêtre flottante qui vous suit sur n'importe quel espace de travail où vous allez. Parfait pour les lecteurs vidéo et ce genre de choses.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espace de travail scratchpad

Il existe un espace de travail scratchpad spécial, plein écran, qui se superpose à l'espace de travail où vous vous trouvez actuellement. Vous accédez à ce qu'il contient avec `Super + S`, et vous y placez des fenêtres avec `Super + Alt + S`.

Il fonctionne bien pour des contrôles ou un terminal avec lequel vous voulez interagir rapidement sans quitter l'espace de travail actuel.

### Console Quake

Enfin, il existe une console Quake à mi-hauteur qui descend sur l'espace de travail où vous vous trouvez actuellement. Basculez-la avec `Super + Grave`, et placez-y une fenêtre avec `Super + Shift + Grave`.

La première fois qu'elle s'ouvre, elle lance votre agent par défaut, ou vous demande d'en choisir un si vous n'en avez pas encore choisi. Quand la console ne contient qu'une seule fenêtre, elle descend sous forme de panneau centré au lieu de s'étendre sur tout l'écran. Placez-y une deuxième application et elle reprend toute la largeur, pour que les deux aient la place de se tenir côte à côte.

Pour retirer une fenêtre du scratchpad ou de la console, envoyez-la directement vers un autre espace de travail avec quelque chose comme `Super + Shift + 1`.

### Il faut un peu de temps pour s'y habituer !

Il faut un peu de temps pour s'habituer à naviguer sur votre bureau comme ça, mais une fois que vous y serez, il sera difficile de revenir à une expérience de bureau traditionnelle pilotée à la souris !
