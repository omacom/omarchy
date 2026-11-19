# Navigation

Tout dans Omarchy se fait au clavier — _TOUT !_ Quand le système démarre pour la première fois, vous ne pouvez littéralement rien faire avec la seule souris. Mais vous pouvez appuyer sur `Super + Space` pour afficher l'Omarchy Menu et, à partir de là, vous pouvez faire à peu près tout.

Mais l'Omarchy Menu n'est même pas censé être le principal moyen d'utiliser le système la plupart du temps. On peut faire plus rapide ! Toutes les applications les plus importantes sont directement associées à des raccourcis individuels. Vous lancez le terminal avec `Super + Return` et un navigateur avec `Super + Shift + Return`. Essayez de faire l'un après l'autre, et vous verrez la magie du pavage de Hyprland en action :

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Vous pouvez ensuite appuyer sur `Super + J` pour les empiler l'une sur l'autre au lieu de les mettre côte à côte :

 ![navigation-stacked](images/navigation-stacked.webp)

Appuyez à nouveau sur `Super + J` pour les remettre côte à côte. Essayez ensuite `Super + Shift + Arrow Right` dans le navigateur pour échanger les fenêtres.

Essayez maintenant `Super + Shift + T` pour lancer le moniteur d'activité. Il apparaîtra sous forme de fenêtre flottante. Vous pouvez le mettre en pavage avec `Super + T` (et appuyer à nouveau pour le rendre à nouveau flottant). Appuyez maintenant sur `Super + Shift + F` pour ouvrir le gestionnaire de fichiers. Vous obtiendrez une belle configuration en quatre parties :

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Vous naviguez entre les fenêtres pour choisir celle qui doit être active avec `Super + Arrow`. Cela change la fenêtre active et déplace le curseur au centre de la nouvelle application. Au bord d'un écran, cela continue vers le moniteur situé de ce côté.

Si vous appuyez sur `Super + Shift + 2`, vous déplacerez l'application actuellement active vers le deuxième espace de travail. `Super + Shift + 1` la ramène. (Et `Super + Shift + Alt + 2` déplacera l'application actuellement active vers le deuxième espace de travail sans basculer vers celui-ci).

Avec plus d'un moniteur, chaque moniteur possède ses propres espaces de travail 1 à 10. `Super + 2` va au deuxième espace de travail du moniteur où vous vous trouvez, et la barre supérieure de chaque moniteur affiche ses propres espaces de travail et celui qu'il affiche. `Super + Tab` fait défiler les espaces de travail du moniteur où vous vous trouvez. `Super + Shift + Ctrl + Arrows` déplace la fenêtre où vous vous trouvez vers le moniteur dans cette direction, sur l'espace de travail qu'il affiche, et `Super + Shift + Alt + Arrows` déplace l'espace de travail où vous vous trouvez vers le moniteur dans cette direction, où il prend le même numéro s'il est libre. Un moniteur conserve ses espaces de travail lorsque vous le débranchez : ils rejoignent ceux d'un autre écran, numérotés après ceux qu'il possède déjà, et retrouvent leurs anciens numéros lorsque le moniteur revient.

Si vous maintenez `Super` enfoncée et utilisez la souris pour cliquer sur une fenêtre, vous pourrez réorganiser sa position. Si vous maintenez `Super` et utilisez le bouton droit de la souris, vous pouvez redimensionner librement la fenêtre.

Vous fermez une fenêtre avec `Super + W` ou `Super + Q` (et fermez toutes les fenêtres avec `Ctrl + Alt + Delete`).

Vous pouvez aussi passer en plein écran avec `Super + F`, ou même simplement en pleine largeur (en gardant la barre supérieure) avec `Super + Alt + F`, ou en plein écran à l'intérieur d'une fenêtre avec `Super + Ctrl + F` (parfait pour YouTube !).

### Disposition dwindle ou défilante

La disposition par défaut d'Omarchy s'appelle dwindle. Elle garde toutes les fenêtres que vous ouvrez sur un même espace de travail visibles en permanence, même si elle doit les réduire.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mais vous pouvez aussi choisir de transformer un espace de travail en disposition défilante, où les fenêtres sont alignées côte à côte, au-delà du bord visible de l'écran. Vous transformez un seul espace de travail en cette disposition avec `Super + L`.

Appuyer à nouveau sur `Super + L` rend l'espace de travail flottant, où les fenêtres se chevauchent librement et où vous les placez vous-même, et une troisième pression le ramène à dwindle. `Super + Alt + L` les parcourt dans l'autre sens. Une fenêtre qui flotte de toute façon — celle que vous avez détachée avec `Super + T`, ou une application qui s'ouvre toujours en mode flottant — reste flottante lorsque l'espace de travail revient au pavage. La barre supérieure marque l'espace de travail où vous vous trouvez avec sa disposition : un carré pour dwindle, un cercle pour la disposition défilante et un triangle pour la disposition flottante. Cliquer sur cette marque fait aussi défiler les dispositions.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Le choix se fait par espace de travail, et il persiste. Vous pouvez donc garder l'espace de travail 1 en dwindle pour la navigation et l'espace de travail 2 en disposition défilante pour le code, et ils reviendront ainsi après un redémarrage.

Si vous souhaitez utiliser la disposition défilante par défaut, vous pouvez le définir dans `~/.config/hypr/looknfeel.lua` :

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espaces de travail flottants

Un espace de travail flottant fonctionne comme un bureau traditionnel : les fenêtres se chevauchent, et vous les déplacez et les dimensionnez vous-même. Chaque fenêtre reçoit une barre de titre aux couleurs de votre thème, avec des boutons pour réduire, agrandir et fermer. `Super + M` réduit aussi la fenêtre active. Une fenêtre réduite attend dans le dock ; cliquez sur son application pour la ramener. Cliquez sur une fenêtre pour la mettre au premier plan. Redimensionnez-la depuis n'importe quel bord ou coin. Double-cliquez sur une barre de titre pour agrandir la fenêtre tout en gardant la barre supérieure visible, et à nouveau pour retrouver son ancienne taille. Chrome et les autres navigateurs basés sur Chromium, Disks et Document Viewer ignorent la barre de titre et utilisent leur propre en-tête à la place ; `Super + Alt + F` les agrandit, et `Super + M` les réduit.

Un espace de travail flottant affiche aussi un dock, avec vos applications épinglées, tout ce qui est en cours d'exécution, et une grille de toutes les applications derrière le bouton des applications, que `Super + Alt + Space` et _Apps_ dans le menu Omarchy ouvrent aussi. Faites un clic droit sur une application dans la grille, ou appuyez sur `Delete`, pour la désinstaller. Cliquez sur une application pour l'ouvrir, ou pour mettre sa fenêtre au premier plan ; cliquez à nouveau pour faire défiler ses fenêtres. Files ramène uniquement une fenêtre de l'espace de travail où vous vous trouvez et ouvre sinon une nouvelle fenêtre, et Terminal et Agent en démarrent toujours un autre exemplaire, bien qu'une fenêtre réduite revienne d'abord. Un clic du milieu ouvre une nouvelle fenêtre. Faites glisser une icône le long du dock pour la déplacer ; faire glisser une application en cours d'exécution parmi les autres la conserve à cet endroit. Faites un clic droit pour garder une application dans le dock, la retirer ou la quitter. Le dock s'écarte devant une fenêtre en plein écran. Faites un clic droit sur le bouton des applications pour déplacer le dock vers un autre bord ou le masquer jusqu'à ce que le pointeur atteigne son bord. La position se trouve aussi sous _Appearance > Dock > Dock Position_, et `omarchy dock position left` et `omarchy dock autohide on` définissent les deux depuis un terminal. Les applications que vous gardez dans le dock sont estompées lorsqu'elles ne sont pas en cours d'exécution.

Les nouveaux espaces de travail, et ceux auxquels vous n'avez pas donné leur propre disposition avec `Super + L`, utilisent la disposition par défaut. Modifier la disposition par défaut réinitialise à celle-ci chaque espace de travail sans fenêtres, tandis qu'un espace avec des fenêtres conserve la disposition qu'il a. Une fenêtre réduite dans le dock compte toujours comme une fenêtre sur l'espace de travail qu'elle a quitté. Choisissez-la sous _Appearance > Workspace Layout_ : Tiling, Scrolling ou Floating. `omarchy-hyprland-workspace-layout-default scrolling` la définit depuis un terminal.

### Regrouper les fenêtres

Les fenêtres peuvent être regroupées avec `Super + G`. Une fois que vous êtes dans un groupe, chaque fenêtre que vous lancez pendant qu'il est actif appartiendra au groupe. Vous pouvez naviguer entre ces fenêtres regroupées avec `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` pour aller directement aux fenêtres regroupées dans l'ordre.

Vous pouvez sortir une fenêtre du groupe avec `Super + Alt + G` ou dissoudre l'ensemble du groupe en appuyant à nouveau sur `Super + G`. Enfin, vous pouvez déplacer des fenêtres extérieures au groupe vers celui-ci avec `Super + Alt + Arrows`.

### Détacher les fenêtres

Vous pouvez détacher une fenêtre de son affectation d'espace de travail avec `Super + O`. Cela l'épinglera comme une fenêtre flottante qui vous suit sur n'importe quel espace de travail où vous allez. Parfait pour les lecteurs vidéo et autres applications du même genre.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espace de travail scratchpad

Il existe un espace de travail scratchpad spécial en pleine taille qui se superpose à l'espace de travail où vous vous trouvez actuellement. Vous accédez à ce qu'il contient avec `Super + S`, et vous y placez des fenêtres avec `Super + Alt + S`.

Il fonctionne bien pour des contrôles ou un terminal avec lesquels vous voulez interagir rapidement sans quitter l'espace de travail actuel.

### Console Quake

Enfin, il existe une console Quake d'une demi-hauteur qui descend sur l'espace de travail où vous vous trouvez actuellement. Basculez-la avec `Super + Grave`, et placez-y une fenêtre avec `Super + Shift + Grave`.

Elle s'ouvre avec votre agent par défaut prêt à l'emploi. Lorsque la console ne contient qu'une seule fenêtre, elle descend sous forme de panneau centré plutôt que de couvrir tout l'écran. Placez-y une deuxième application et elle retrouve sa pleine largeur, afin que les deux aient la place de se tenir côte à côte.

Pour déplacer une fenêtre hors du scratchpad ou de la console, envoyez-la directement vers un autre espace de travail avec quelque chose comme `Super + Shift + 1`.

### Il faut un peu de temps pour s'y habituer !

Il faut un petit moment pour s'habituer à naviguer sur votre bureau de cette façon, mais une fois que ce sera fait, il sera difficile de revenir à une expérience de bureau traditionnelle pilotée à la souris !
