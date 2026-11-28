# Navigation

Tout dans Omarchy se fait au clavier — _TOUT !_ Quand le système démarre pour la première fois, vous ne pouvez littéralement rien faire avec la seule souris. Mais vous pouvez appuyer sur `Super + Space` pour afficher le menu Omarchy et, à partir de là, vous pouvez faire à peu près tout.

Mais le menu Omarchy n'est même pas censé être le principal moyen d'utiliser le système la plupart du temps. On peut aller plus vite que ça ! Toutes les applications les plus importantes sont directement associées à des raccourcis individuels. Vous lancez le terminal avec `Super + Return` et un navigateur avec `Super + Shift + Return`. Essayez de faire l'un après l'autre, et vous verrez la magie du pavage de Hyprland à l'œuvre :

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Vous pouvez ensuite appuyer sur `Super + J` pour les empiler l'une sur l'autre au lieu de les mettre côte à côte :

 ![navigation-stacked](images/navigation-stacked.webp)

Appuyez de nouveau sur `Super + J` pour les remettre côte à côte. Essayez ensuite `Super + Shift + Arrow Right` pendant que vous êtes dans le navigateur pour échanger les fenêtres.

Essayez maintenant `Super + Shift + T` pour lancer le moniteur d'activité. Il apparaîtra sous forme de fenêtre flottante, avec une barre de titre pour le faire glisser et des boutons pour le réduire, l'agrandir et le fermer. Chaque fenêtre flottante en reçoit une, où qu'elle soit. Vous pouvez la mettre en pavage avec `Super + T` (et appuyer de nouveau dessus pour la rendre à nouveau flottante). Appuyez maintenant sur `Super + Shift + F` pour ouvrir le gestionnaire de fichiers. Vous obtiendrez une belle configuration en quatre parties :

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Vous naviguez entre les fenêtres pour choisir celle que vous voulez rendre active avec `Super + Arrow`. Cela changera la fenêtre active et déplacera le curseur au centre de la nouvelle application. Au bord d'un écran, il continue vers le moniteur situé de ce côté.

Si vous appuyez sur `Super + Shift + 2`, vous déplacerez l'application active actuelle sur le deuxième espace de travail. `Super + Shift + 1` la ramène. (Et `Super + Shift + Alt + 2` déplacera l'application active actuelle sur le deuxième espace de travail sans basculer dessus).

Avec plus d'un moniteur, chaque moniteur possède ses propres espaces de travail 1 à 10. `Super + 2` va au deuxième espace de travail du moniteur où vous vous trouvez, et la barre supérieure de chaque moniteur affiche ses propres espaces de travail et celui qu'elle affiche. `Super + Tab` fait défiler les espaces de travail du moniteur où vous vous trouvez. `Super + Shift + Ctrl + Arrows` déplace la fenêtre où vous vous trouvez vers le moniteur dans cette direction, sur l'espace de travail qu'il affiche, et `Super + Shift + Alt + Arrows` déplace l'espace de travail où vous vous trouvez vers le moniteur dans cette direction, où il prend le même numéro s'il est libre. Un moniteur conserve ses espaces de travail lorsque vous le débranchez : ils rejoignent ceux d'un autre écran, numérotés après ceux qu'il possède déjà, et retrouvent leurs anciens numéros lorsque le moniteur revient.

Si vous maintenez `Super` enfoncé et utilisez la souris pour cliquer sur une fenêtre, vous pourrez réorganiser l'endroit où elle se trouve. Si vous maintenez `Super` enfoncé et utilisez le bouton droit de la souris, vous pouvez redimensionner librement la fenêtre.

Vous fermez une fenêtre avec `Super + W` ou `Super + Q` (et vous fermez toutes les fenêtres avec `Ctrl + Alt + Delete`).

Vous pouvez aussi passer en plein écran avec `Super + F` ou même simplement en pleine largeur (en conservant la barre supérieure) avec `Super + Alt + F` ou en plein écran à l'intérieur d'une fenêtre avec `Super + Ctrl + F` (parfait pour YouTube !).

### Disposition dwindle ou défilante

La disposition par défaut d'Omarchy s'appelle dwindle. Elle garde toutes les fenêtres que vous ouvrez sur un seul espace de travail visibles à tout moment, même si elle doit les réduire.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mais vous pouvez aussi choisir de transformer un espace de travail en disposition défilante, où les fenêtres sont alignées côte à côte, au-delà du bord visible de l'écran. Vous transformez un seul espace de travail en cette disposition via `Super + L`.

Appuyer de nouveau sur `Super + L` rend l'espace de travail flottant, où les fenêtres se chevauchent librement et où vous les placez vous-même, et une troisième pression le ramène à dwindle. `Super + Alt + L` les parcourt dans l'autre sens. Une fenêtre qui flotte de toute façon — celle que vous avez sortie avec `Super + T`, ou une application qui s'ouvre toujours en mode flottant — reste flottante lorsque l'espace de travail revient au pavage. La barre supérieure marque l'espace de travail où vous vous trouvez avec sa disposition : un carré pour dwindle, un cercle pour défilante et un triangle pour flottante. Cliquer sur cette marque fait aussi défiler la disposition, tout comme la touche d'affichage sur les ordinateurs portables qui en possèdent une.

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

Un espace de travail flottant fonctionne comme un bureau traditionnel : les fenêtres se chevauchent, et vous les déplacez et les dimensionnez vous-même. Chaque fenêtre reçoit une barre de titre aux couleurs de votre thème, avec des boutons pour réduire, agrandir et fermer. `Super + M` réduit aussi la fenêtre active. Une fenêtre réduite attend dans le dock ; cliquez sur son application pour la ramener. Cliquez sur une fenêtre pour la mettre au premier plan. Redimensionnez-la depuis n'importe quel bord ou coin. Double-cliquez sur une barre de titre pour agrandir la fenêtre tout en gardant la barre supérieure visible, et de nouveau pour retrouver son ancienne taille. Chrome et les autres navigateurs basés sur Chromium, Disks et Document Viewer ignorent la barre de titre et utilisent leur propre en-tête à la place ; `Super + Alt + F` les agrandit, et `Super + M` les réduit.

Chaque espace de travail possède un dock, avec vos applications épinglées, tout ce qui est en cours d'exécution, et une grille de toutes les applications derrière le bouton des applications, que `Super + Alt + Space` et _Applications_ dans le menu Omarchy ouvrent également. Faites un clic droit sur une application dans la grille, ou appuyez sur `Delete`, pour la désinstaller. Cliquez sur une application pour l'ouvrir, ou pour mettre sa fenêtre au premier plan ; cliquez de nouveau pour faire défiler ses fenêtres. Files ramène seulement une fenêtre depuis l'espace de travail où vous vous trouvez et en ouvre sinon une nouvelle, et Terminal et Agent en lancent toujours une autre, bien qu'une fenêtre réduite revienne d'abord. Le clic milieu ouvre une nouvelle fenêtre. Faites glisser une icône le long du dock pour la déplacer ; faire glisser une application en cours d'exécution parmi les autres la conserve à cet endroit. Faites un clic droit pour conserver une application dans le dock, l'en retirer ou la quitter. Le dock reste visible tant qu'un espace de travail est vide, et dès que l'espace de travail possède une fenêtre, il se cache jusqu'à ce que le pointeur atteigne son bord. Une fenêtre en plein écran le cache complètement. Faites glisser le bouton des applications vers un autre bord de l'écran pour y déplacer le dock. Faites un clic droit dessus pour _Position_, afin de choisir un bord, et _Disposition_, afin de définir la disposition par défaut comme le fait _Apparence > Disposition des espaces de travail_. La position se trouve aussi sous _Apparence > Dock > Position du dock_, et `omarchy dock position left` la définit depuis un terminal. Les applications que vous conservez dans le dock sont estompées tant qu'elles ne sont pas en cours d'exécution. Pour réserver le dock aux espaces de travail flottants, utilisez _Apparence > Dock > Dock uniquement sur les espaces flottants_ ou `omarchy dock tiling off`.

Les nouveaux espaces de travail, et tous ceux auxquels vous n'avez pas donné leur propre disposition avec `Super + L`, utilisent la disposition par défaut. Changer la disposition par défaut la réapplique à chaque espace de travail sans fenêtre, tandis qu'un espace qui possède des fenêtres conserve la disposition qu'il a. Une fenêtre réduite dans le dock compte toujours comme une fenêtre sur l'espace de travail qu'elle a quitté. Choisissez-la sous _Apparence > Disposition des espaces de travail_ : Pavage, Défilante ou Flottante. `omarchy hyprland workspace layout default scrolling` la définit depuis un terminal.

### Regrouper les fenêtres

Les fenêtres peuvent être regroupées avec `Super + G`. Une fois que vous êtes dans un groupe, chaque fenêtre que vous lancez pendant qu'il est actif appartiendra au groupe. Vous pouvez vous déplacer entre ces fenêtres regroupées avec `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` pour aller directement aux fenêtres regroupées dans l'ordre.

Vous pouvez déplacer une fenêtre hors du groupe avec `Super + Alt + G` ou démonter tout le groupe en appuyant de nouveau sur `Super + G`. Enfin, vous pouvez déplacer des fenêtres extérieures au groupe vers celui-ci avec `Super + Alt + Arrows`.

### Sortir une fenêtre

Vous pouvez sortir une fenêtre de son affectation à un espace de travail avec `Super + O`. Cela l'épinglera comme une fenêtre flottante qui vous suit sur n'importe quel espace de travail où vous allez. Parfait pour les lecteurs vidéo et ce genre de choses.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espace de travail scratchpad

Il existe un espace de travail scratchpad spécial, pleine taille, qui se superpose à l'espace de travail où vous vous trouvez actuellement. Vous accédez à ce qui s'y trouve avec `Super + S`, et vous y placez des fenêtres avec `Super + Alt + S`.

Il fonctionne bien pour des contrôles ou un terminal avec lesquels vous voulez interagir rapidement sans quitter l'espace de travail actuel.

### Console Quake

Enfin, il existe une console Quake à mi-hauteur qui descend sur l'espace de travail où vous vous trouvez actuellement. Affichez-la ou masquez-la avec `Super + the key above Tab` (accent grave sur les dispositions US), et placez-y une fenêtre avec `Super + Shift + the key above Tab`.

La première fois qu'elle s'ouvre, elle lance votre agent par défaut, ou vous demande d'en choisir un si vous n'en avez pas encore choisi. Tant que la console ne contient qu'une seule fenêtre, elle descend sous forme de panneau centré au lieu de couvrir toute la largeur de l'écran. Placez-y une deuxième application et elle revient à la pleine largeur, afin que les deux aient la place de se tenir côte à côte.

Pour déplacer une fenêtre hors du scratchpad ou de la console, envoyez-la directement sur un autre espace de travail avec quelque chose comme `Super + Shift + 1`.

### Il faut un peu de temps pour s'y habituer !

Il faut un peu de temps pour s'habituer à naviguer sur votre bureau comme ça, mais une fois que vous y serez, il sera difficile de revenir à une expérience de bureau traditionnelle pilotée à la souris !
