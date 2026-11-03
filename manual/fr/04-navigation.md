# Navigation

Tout dans Omarchy se fait au clavier — _TOUT !_ Quand le système démarre pour la première fois, tu ne peux littéralement rien faire avec la souris seule. Mais tu peux appuyer sur `Super + Space` pour afficher le menu Omarchy et, à partir de là, tu peux faire à peu près tout.

Mais le menu Omarchy n’est même pas censé être le principal moyen d’utiliser le système la plupart du temps. On peut aller plus vite que ça ! Toutes les applications les plus importantes sont liées directement à des raccourcis individuels. Tu lances le terminal avec `Super + Return` et un navigateur avec `Super + Shift + Return`. Essaie de faire l’un après l’autre, et tu verras la magie du tiling de Hyprland en action :

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Tu peux ensuite appuyer sur `Super + J` pour les empiler l’une sur l’autre au lieu de les mettre côte à côte :

 ![navigation-stacked](images/navigation-stacked.webp)

Appuie à nouveau sur `Super + J` pour les remettre côte à côte. Essaie ensuite `Super + Shift + Arrow Right` dans le navigateur pour échanger les fenêtres.

Essaie maintenant `Super + Shift + T` pour lancer le moniteur d’activité. Il apparaîtra sous forme de fenêtre flottante. Tu peux le mettre en mosaïque avec `Super + T` (et appuyer à nouveau dessus pour le rendre flottant à nouveau). Appuie maintenant sur `Super + Shift + F` pour ouvrir le gestionnaire de fichiers. Tu auras une belle disposition en quatre :

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Tu navigues entre les fenêtres pour choisir celle qui doit être active avec `Super + Arrow`. Cela change le focus et déplace le curseur au centre de la nouvelle application. Au bord d’un écran, cela continue vers le moniteur de ce côté.

Si tu appuies sur `Super + Shift + 2`, tu déplaceras l’application actuellement active vers le deuxième espace de travail. `Super + Shift + 1` la ramène. (Et `Super + Shift + Alt + 2` déplacera l’application actuellement active vers le deuxième espace de travail sans basculer dessus).

Avec plus d’un moniteur, chaque moniteur possède ses propres espaces de travail 1 à 10. `Super + 2` va au deuxième espace de travail du moniteur où tu te trouves, et la barre supérieure de chaque moniteur affiche ses propres espaces de travail et celui qu’il montre. `Super + Tab` fait défiler les espaces de travail du moniteur où tu te trouves. `Super + Shift + Ctrl + Arrows` déplace la fenêtre où tu te trouves vers le moniteur dans cette direction, sur l’espace de travail qu’il affiche, et `Super + Shift + Alt + Arrows` déplace l’espace de travail où tu te trouves vers le moniteur dans cette direction, où il prend le même numéro s’il est libre. Un moniteur conserve ses espaces de travail quand tu le débranches : ils rejoignent ceux d’un autre écran, numérotés après ceux qu’il a déjà, et retrouvent leurs anciens numéros quand le moniteur revient.

Si tu maintiens `Super` enfoncée et que tu utilises la souris pour cliquer sur une fenêtre, tu pourras réorganiser sa place. Si tu maintiens `Super` et que tu utilises le bouton droit de la souris, tu peux redimensionner librement la fenêtre.

Tu fermes une fenêtre avec `Super + W` ou `Super + Q` (et tu fermes toutes les fenêtres avec `Ctrl + Alt + Delete`).

Tu peux aussi passer en plein écran avec `Super + F`, ou même simplement en pleine largeur (en gardant la barre supérieure) avec `Super + Alt + F`, ou en plein écran à l’intérieur d’une fenêtre avec `Super + Ctrl + F` (parfait pour YouTube !).

### Disposition dwindle contre disposition scrolling

La disposition par défaut d’Omarchy s’appelle dwindle. Elle garde toutes les fenêtres que tu ouvres sur un seul espace de travail visibles en permanence, même si elle doit les réduire.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mais tu peux aussi choisir de transformer un espace de travail en disposition scrolling, où les fenêtres sont alignées côte à côte, au-delà du bord visible de l’écran. Tu transformes un seul espace de travail en cette disposition via `Super + L`.

Appuyer à nouveau sur `Super + L` rend l’espace de travail flottant, où les fenêtres se chevauchent librement et où tu les places toi-même, et une troisième pression le ramène à dwindle. `Super + Alt + L` les parcourt dans l’autre sens. Une fenêtre qui flotte de toute façon — une que tu as sortie avec `Super + T`, ou une application qui s’ouvre toujours en flottant — reste flottante quand l’espace de travail revient au tiling. La barre supérieure marque l’espace de travail où tu te trouves avec sa disposition : un carré pour dwindle, un cercle pour scrolling, et un triangle pour flottant. Cliquer sur cette marque fait aussi défiler les dispositions.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Le choix se fait par espace de travail, et il persiste. Tu peux donc garder l’espace de travail 1 en dwindle pour naviguer et l’espace de travail 2 en scrolling pour coder, et ils reviendront ainsi après un redémarrage.

Si tu souhaites utiliser la disposition scrolling par défaut, tu peux la définir dans `~/.config/hypr/looknfeel.lua` :

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espaces de travail flottants

Un espace de travail flottant fonctionne comme un bureau traditionnel : les fenêtres se chevauchent, et tu les déplaces et les dimensionnes toi-même. Chaque fenêtre reçoit une barre de titre aux couleurs de ton thème, avec des boutons pour réduire, agrandir et fermer. `Super + M` réduit aussi la fenêtre active. Une fenêtre réduite attend dans le dock ; clique sur son application pour la ramener. Clique sur une fenêtre pour la mettre au premier plan. Redimensionne-la depuis n’importe quel bord ou coin. Double-clique sur une barre de titre pour agrandir la fenêtre tout en gardant la barre supérieure en vue, et à nouveau pour retrouver son ancienne taille.

Un espace de travail flottant affiche aussi un dock, avec tes applications épinglées, tout ce qui est en cours d’exécution, et une grille de toutes les applications derrière le bouton des applications, que `Super + Alt + Space` et _Apps_ dans le menu Omarchy ouvrent aussi. Clique avec le bouton droit sur une application dans la grille, ou appuie sur `Delete`, pour la désinstaller. Clique sur une application pour l’ouvrir, ou pour mettre sa fenêtre au premier plan ; clique à nouveau pour faire défiler ses fenêtres. Un clic du milieu ouvre une nouvelle fenêtre. Fais glisser une icône le long du dock pour la déplacer ; faire glisser une application en cours d’exécution parmi les autres la garde là. Clique avec le bouton droit pour garder une application dans le dock, la retirer, ou la quitter. Le dock s’écarte devant une fenêtre en plein écran. Clique avec le bouton droit sur le bouton des applications pour déplacer le dock vers un autre bord ou le masquer jusqu’à ce que le pointeur atteigne son bord. La position se trouve aussi sous _Appearance > Dock > Dock Position_, et `omarchy dock position left` et `omarchy dock autohide on` définissent les deux depuis un terminal. Les applications que tu gardes dans le dock sont estompées tant qu’elles ne sont pas en cours d’exécution.

Les nouveaux espaces de travail, et tous ceux auxquels tu n’as pas donné leur propre disposition avec `Super + L`, utilisent la disposition par défaut. Changer la disposition par défaut réinitialise à celle-ci chaque espace de travail sans fenêtres, tandis qu’un espace de travail avec des fenêtres conserve la disposition qu’il a. Une fenêtre réduite dans le dock compte toujours comme une fenêtre sur l’espace de travail qu’elle a quitté. Choisis-la sous _Appearance > Workspace Layout_ : Tiling, Scrolling, ou Floating. `omarchy-hyprland-workspace-layout-default scrolling` la définit depuis un terminal.

### Grouper les fenêtres

Les fenêtres peuvent être groupées avec `Super + G`. Une fois que tu es dans un groupe, chaque fenêtre que tu lances tant que celui-ci est actif appartiendra au groupe. Tu peux te déplacer entre ces fenêtres groupées avec `Super + Ctrl + Arrow Left/Right` ou `Super + Alt + 1/2/3/4` pour aller directement aux fenêtres groupées dans l’ordre.

Tu peux sortir une fenêtre du groupe avec `Super + Alt + G` ou démonter tout le groupe en appuyant à nouveau sur `Super + G`. Enfin, tu peux déplacer des fenêtres extérieures au groupe vers celui-ci avec `Super + Alt + Arrows`.

### Extraire les fenêtres

Tu peux extraire une fenêtre de son allocation d’espace de travail avec `Super + O`. Cela l’épinglera comme une fenêtre flottante qui te suit sur n’importe quel espace de travail où tu vas. Parfait pour les lecteurs vidéo et les applications du même genre.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espace de travail scratchpad

Il existe un espace de travail scratchpad spécial en pleine taille qui se superpose à l’espace de travail où tu te trouves actuellement. Tu accèdes à ce qui s’y trouve avec `Super + S`, et tu y places des fenêtres avec `Super + Alt + S`.

Il fonctionne bien pour des contrôles ou un terminal avec lesquels tu veux interagir rapidement sans quitter l’espace de travail actuel.

### Console Quake

Enfin, il y a une console Quake à mi-hauteur qui descend sur l’espace de travail où tu te trouves actuellement. Bascule-la avec `Super + Grave`, et places-y une fenêtre avec `Super + Shift + Grave`.

Elle s’ouvre avec ton agent par défaut prêt à l’emploi. Tant que la console ne contient qu’une seule fenêtre, elle descend sous forme de panneau centré plutôt que de s’étendre sur tout l’écran. Mets une deuxième application dessus et elle revient à la pleine largeur, pour que les deux aient la place de se tenir côte à côte.

Pour déplacer une fenêtre hors du scratchpad ou de la console, envoie-la directement vers un autre espace de travail avec quelque chose comme `Super + Shift + 1`.

### Il faut un peu de temps pour s’y habituer !

Il faut un peu de temps pour s’habituer à naviguer sur ton bureau comme ça, mais une fois que tu y seras, il sera difficile de revenir à une expérience de bureau traditionnelle pilotée à la souris !
