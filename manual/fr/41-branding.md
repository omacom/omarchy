# Image de marque

Omarchy vous permet de définir le logo de votre entreprise ou une image personnelle pour l'économiseur d'écran comme pour l'écran À propos.

### Économiseur d'écran

Vous pouvez changer le logo utilisé pour l'économiseur d'écran sous _Apparence > Image de marque > Économiseur d'écran_. C'est un logo ASCII, donc vous pouvez modifier le texte directement, mais vous pouvez aussi lui fournir une image png ou svg, et nous la convertirons en ASCII. Le résultat est plutôt cool.

 ![branding-screensaver](images/branding-screensaver.webp)

Ce menu comporte trois entrées :

- **Modifier le texte** ouvre `~/.config/omarchy/branding/screensaver.txt` dans votre éditeur. Tapez ou collez ce que vous voulez — de l'art ASCII, votre nom, un gros mot. Enregistrez et quittez, et l'économiseur d'écran se lance immédiatement pour que vous puissiez le voir.
- **Définir à partir d'une image** ouvre un sélecteur de fichier pour un png ou un svg, le convertit en ASCII et vous montre le résultat. Les logos avec une silhouette nette fonctionnent bien mieux que les photos.
- **Restaurer par défaut** remet le logo Omarchy.

### Écran À propos

Les trois mêmes options se trouvent sous _Apparence > Image de marque > À propos_ pour l'écran _À propos_ que vous obtenez depuis le menu Omarchy, et elles fonctionnent à l'identique — le fichier est `~/.config/omarchy/branding/about.txt`, et la fenêtre À propos s'affiche après chaque modification. L'illustration À propos est convertie dans une taille plus petite que celle de l'économiseur d'écran, puisqu'elle doit tenir dans une fenêtre plutôt que remplir votre écran.

Pendant que la fenêtre est ouverte, une bande de lumière blanche éclatante traverse l'illustration en diagonale toutes les quelques secondes, puis la laisse de nouveau immobile. Votre propre illustration y a droit aussi, tant que chaque caractère qu'elle contient occupe une seule colonne — c'est le cas de tout ce que produit _Définir à partir d'une image_. Une illustration composée d'emoji ou de caractères double largeur reste immobile à la place, et il en va de même pour l'écran si vous conservez votre propre configuration fastfetch : dans ces cas, un logo immobile signifie que l'animation reste à l'écart plutôt qu'elle échoue, car faire glisser un reflet dessus placerait le reste de la ligne au mauvais endroit.

 ![branding-about](images/branding-about.webp)

### Convertir des images vous-même

Les deux options _Définir à partir d'une image_ appellent simplement `omarchy transcode ascii`, que vous pouvez exécuter directement si vous voulez contrôler la conversion :

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Elle accepte `--width` et `--height` en colonnes et en lignes de terminal, un `--mode` valant soit `braille` (par défaut, et bien plus fin) soit `block`, un `--threshold` en pourcentage pour décider quels pixels font partie du logo, et `--invert` lorsque votre logo est clair sur fond sombre. Si une conversion donne une masse informe, le seuil est généralement le réglage à ajuster.

### Des mots plutôt qu'un logo

`omarchy ascii` dessine du texte en Delta Corps Priest 1, la police FIGlet dans laquelle le logotype Omarchy lui-même est dessiné, de sorte qu'un économiseur d'écran peut dire quelque chose plutôt que montrer une image :

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Elle prend le texte en arguments, ou le lit depuis un pipe quand on ne lui en donne aucun. La police ne contient que des lettres et des espaces — elle a été dessinée sans chiffres ni ponctuation — donc tout le reste est abandonné et signalé sur stderr plutôt qu'avalé en silence.
