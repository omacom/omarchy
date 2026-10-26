# Navigation

Tout dans Omarchy se fait au clavier — _TOUT !_ Quand le système démarre pour la première fois, vous ne pouvez littéralement rien faire avec la seule souris. Mais vous pouvez appuyer sur `Super + Space` pour afficher le menu Omarchy et, à partir de là, vous pouvez faire à peu près tout.

Mais le menu Omarchy n'est même pas censé être le principal moyen d'utiliser le système la plupart du temps. On peut faire plus rapide que ça ! Toutes les applications les plus importantes sont liées directement à des raccourcis individuels. Vous lancez le terminal avec `Super + Return` et un navigateur avec `Super + Shift + Return`. Essayez de faire l'un après l'autre, et vous verrez la magie du tiling de Hyprland en action :

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Vous pouvez ensuite appuyer sur `Super + J` pour les empiler l'une sur l'autre au lieu de les mettre côte à côte :

 ![navigation-stacked](images/navigation-stacked.webp)

Appuyez à nouveau sur `Super + J` pour les remettre côte à côte. Essayez ensuite `Super + Shift + Arrow Right` depuis le navigateur pour échanger les fenêtres.

Essayez maintenant `Super + Shift + T` pour lancer le moniteur d'activité. Il apparaîtra sous forme de fenêtre flottante. Vous pouvez le mettre en mosaïque avec `Super + T` (et appuyer à nouveau pour le rendre flottant à nouveau). Appuyez maintenant sur `Super + Shift + F` pour ouvrir le gestionnaire de fichiers. Vous aurez une belle configuration en quatre parties :

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Vous naviguez entre les fenêtres pour choisir celle qui sera active avec `Super + Arrow`. Cela changera le focus et déplacera le curseur au centre de la nouvelle application. Au bord d'un écran, cela continue vers le moniteur situé de ce côté.

Si vous appuyez sur `Super + Shift + 2`, vous déplacerez l'application actuellement active vers le deuxième espace de travail. `Super + Shift + 1` la ramène. (Et `Super + Shift + Alt + 2` déplacera l'application actuellement active vers le deuxième espace de travail sans y basculer).

Avec plusieurs moniteurs, chaque moniteur possède ses propres espaces de travail 1 à 10. `Super + 2` va au deuxième espace de travail du moniteur où vous vous trouvez, et la barre supérieure de chaque moniteur affiche ses propres espaces de travail et celui qu'elle montre. `Super + Tab` fait défiler les espaces de travail sur le moniteur où vous vous trouvez. `Super + Shift + Ctrl + Arrows` déplace la fenêtre où vous vous trouvez vers le moniteur dans cette direction, sur l'espace de travail qu'il affiche, et `Super + Shift + Alt + Arrows` déplace l'espace de travail où vous vous trouvez vers le moniteur dans cette direction, où il prend le même numéro s'il est libre. Un moniteur conserve ses espaces de travail quand vous le débranchez : ils rejoignent ceux d'un autre écran, numérotés après ceux qu'il a déjà, et retrouvent leurs anciens numéros quand le moniteur revient.

Si vous maintenez `Super` enfoncée et utilisez la souris pour cliquer sur une fenêtre, vous pourrez réorganiser sa position. Si vous maintenez `Super` et utilisez le bouton droit de la souris, vous pouvez redimensionner librement la fenêtre.

Vous fermez une fenêtre avec `Super + W` ou `Super + Q` (et fermez toutes les fenêtres avec `Ctrl + Alt + Delete`).

Vous pouvez aussi passer en plein écran avec `Super + F`, ou même simplement en pleine largeur (en gardant la barre supérieure) avec `Super + Alt + F`, ou en plein écran à l'intérieur d'une fenêtre avec `Super + Ctrl + F` (parfait pour YouTube !).

### Disposition dwindle vs défilante

La disposition par défaut d'Omarchy s'appelle dwindle. Elle garde toutes les fenêtres que vous ouvrez sur un même espace de travail visibles en permanence, même si elle doit les réduire.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mais vous pouvez aussi choisir de transformer un espace de travail en disposition défilante, où les fenêtres sont alignées côte à côte, au-delà du bord visible de l'écran. Vous transformez un seul espace de travail dans cette disposition via `Super + L`.

Appuyer à nouveau sur `Super + L` rend l'espace de travail flottant, où les fenêtres se chevauchent librement et où vous les placez vous-même, et une troisième pression le ramène à dwindle. `Super + Alt + L` les parcourt dans l'autre sens. Une fenêtre qui flotte de toute façon — une que vous avez fait sortir avec `Super + T`, ou une application qui s'ouvre toujours en flottant — reste flottante quand l'espace de travail repasse en mosaïque. La barre supérieure marque l'espace de travail où vous vous trouvez avec sa disposition : un carré pour dwindle, un cercle pour défilante et un triangle pour flottante. Cliquer sur cette marque fait aussi défiler les dispositions.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Le choix se fait par espace de travail, et il persiste. Vous pouvez donc garder l'espace de travail 1 en dwindle pour la navigation et l'espace de travail 2 en défilante pour le code, et ils reviendront ainsi après un redémarrage.

Si vous souhaitez utiliser la disposition défilante par défaut, vous pouvez le définir dans `~/.config/hypr/looknfeel.lua` :

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espaces de travail flottants

Un espace de travail flottant fonctionne comme un bureau traditionnel : les fenêtres se chevauchent, et vous les déplacez et les dimensionnez vous-même. Chaque fenêtre reçoit une barre de titre aux couleurs de votre thème, avec des boutons pour minimiser, maximiser et fermer. `Super + M` minimise aussi la fenêtre active. Une fenêtre minimisée attend dans le dock ; cliquez sur son application pour la ramener. Cliquez sur une fenêtre pour la mettre au premier plan. Redimensionnez-la depuis n'importe quel bord ou coin. Double-cliquez sur une barre de titre pour maximiser la fenêtre tout en gardant la barre supérieure visible, et à nouveau pour retrouver son ancienne taille.

Un espace de travail flottant affiche aussi un dock, avec vos applications épinglées, tout ce qui est en cours d'exécution, et une grille de toutes les applications derrière le bouton des applications, que `Super + Alt + Space` et _Applications_ dans le menu Omarchy ouvrent aussi. Faites un clic droit sur une application dans la grille, ou appuyez sur `Delete`, pour la désinstaller. Cliquez sur une application pour l'ouvrir, ou pour mettre sa fenêtre au premier plan ; cliquez à nouveau pour faire défiler ses fenêtres. Un clic du milieu ouvre une nouvelle fenêtre. Faites glisser une icône le long du dock pour la déplacer ; faire glisser une application en cours d'exécution parmi les autres la garde là. Faites un clic droit pour garder une application dans le dock, l'en retirer ou la quitter. Le dock s'écarte devant une fenêtre en plein écran. Faites un clic droit sur le bouton des applications pour déplacer le dock vers un autre bord ou le faire se masquer jusqu'à ce que le pointeur atteigne son bord. La position se trouve aussi sous _Apparence > Dock > Position du dock_, et `omarchy dock position left` et `omarchy dock autohide on` définissent les deux depuis un terminal. Les applications que vous gardez dans le dock sont estompées tant qu'elles ne sont pas en cours d'exécution.

Les nouveaux espaces de travail, et ceux auxquels vous n'avez pas donné leur propre disposition avec `Super + L`, utilisent la disposition par défaut. Changer la disposition par défaut la réapplique à tous les espaces de travail sans fenêtres, tandis qu'un espace avec des fenêtres garde la disposition qu'il a. Une fenêtre minimisée dans le dock compte toujours comme une fenêtre sur l'espace de travail qu'elle a quitté. Choisissez-la sous _Apparence > Disposition de l'espace de travail_ : Mosaïque, Défilante ou Flottante. `omarchy-hyprland-workspace-layout-default scrolling` la définit depuis un terminal.

### Regrouper les fenêtres

Les fenêtres peuvent être regroupées avec `Super + G`. Une fois dans un groupe, chaque fenêtre que vous lancez tant qu'il est actif appartiendra au groupe. Vous pouvez passer d'une de ces fenêtres regroupées à l'autre avec `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` pour aller directement à une fenêtre regroupée dans l'ordre.

Vous pouvez sortir une fenêtre du regroupement avec `Super + Alt + G` ou démonter tout le groupe en appuyant à nouveau sur `Super + G`. Enfin, vous pouvez faire entrer dans le groupe des fenêtres qui sont à l'extérieur avec `Super + Alt + Arrows`.

### Faire sortir les fenêtres

Vous pouvez faire sortir une fenêtre de son espace de travail avec `Super + O`. Cela l'épinglera comme une fenêtre flottante qui vous suit dans l'espace de travail où vous allez. Parfait pour les lecteurs vidéo et ce genre de choses.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espace de travail scratchpad

Il existe un espace de travail scratchpad spécial, en pleine taille, qui se superpose à l'espace de travail où vous vous trouvez. Vous accédez à ce qui s'y trouve avec `Super + S`, et vous y placez des fenêtres avec `Super + Alt + S`.

Il fonctionne bien pour des contrôles ou un terminal avec lesquels vous voulez interagir rapidement sans quitter l'espace de travail actuel.

### Console Quake

Enfin, il existe une console Quake à mi-hauteur qui descend par-dessus l'espace de travail où vous vous trouvez. Basculez-la avec `Super + Grave`, et placez-y une fenêtre avec `Super + Shift + Grave`.

Elle s'ouvre avec votre agent par défaut, prêt à l'emploi. Tant que la console ne contient qu'une seule fenêtre, elle descend sous forme de panneau centré plutôt que de s'étendre sur tout l'écran. Placez-y une deuxième application et elle revient à la pleine largeur, pour que les deux aient la place de s'asseoir côte à côte.

Pour sortir une fenêtre du scratchpad ou de la console, envoyez-la directement vers un autre espace de travail avec quelque chose comme `Super + Shift + 1`.

### Il faut un peu de temps pour s'y habituer !

Il faut un petit moment pour s'habituer à naviguer sur son bureau comme ça, mais une fois que c'est fait, il sera difficile de revenir à une expérience de bureau traditionnelle pilotée à la souris !
