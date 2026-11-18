# Image de marque

Omarchy vous permet de définir le logo de votre entreprise ou une image personnelle pour le déverrouillage au démarrage, l'écran de veille et l'écran À propos.

### Déverrouillage au démarrage

Vous pouvez utiliser `omarchy plymouth preview` pour voir à quoi ressembleraient votre logo et vos couleurs personnalisés. Cela prend une couleur d'arrière-plan, une couleur de texte, un logo png et un chemin pour l'image d'aperçu :

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Appliquez ensuite la configuration avec `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, ce qui donnera aussi à l'écran de connexion SDDM les mêmes couleurs et le même logo. Si vous voulez revenir en arrière, vous pouvez utiliser `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Écran de veille

Vous pouvez changer le logo utilisé pour l'écran de veille sous _Apparence > Image de marque > Écran de veille_. C'est un logo ASCII, donc vous pouvez modifier le texte directement, mais vous pouvez aussi lui fournir une image png ou svg, et nous la convertirons en ASCII. Le rendu est plutôt cool.

 ![branding-screensaver](images/branding-screensaver.webp)

Ce menu contient trois entrées :

- **Modifier le texte** ouvre `~/.config/omarchy/branding/screensaver.txt` dans votre éditeur. Tapez ou collez ce que vous voulez — de l'art ASCII, votre nom, un gros mot. Enregistrez et quittez, et l'écran de veille se lance immédiatement pour que vous puissiez le voir.
- **Définir à partir d'une image** ouvre un sélecteur de fichier pour un png ou un svg, le convertit en ASCII et vous montre le résultat. Les logos avec une silhouette nette fonctionnent bien mieux que les photos.
- **Restaurer la valeur par défaut** remet le logo Omarchy en place.

### Écran À propos

Les trois mêmes options se trouvent sous _Apparence > Image de marque > À propos_ pour l'écran _À propos_ que vous obtenez depuis le menu Omarchy, et elles fonctionnent de manière identique — le fichier est `~/.config/omarchy/branding/about.txt`, et la fenêtre À propos s'affiche après chaque changement. L'art À propos est converti dans une taille plus petite que celle de l'écran de veille, puisqu'il doit tenir dans une fenêtre plutôt que remplir votre écran.

Pendant que la fenêtre est ouverte, un reflet vert traverse l'art en diagonale toutes les quelques secondes, puis le laisse à nouveau immobile. Votre propre art y a droit aussi, tant que chaque caractère qu'il contient occupe une seule colonne — c'est le cas de tout ce que produit _Définir à partir d'une image_. L'art construit à partir d'emoji ou de caractères double largeur reste immobile à la place, et il en va de même pour l'écran si vous conservez votre propre config fastfetch : dans ces cas, un logo immobile signifie que l'animation se tient à l'écart plutôt qu'elle échoue, car faire glisser un reflet dessus placerait le reste de la ligne au mauvais endroit.

 ![branding-about](images/branding-about.webp)

### Convertir les images vous-même

Les deux options _Définir à partir d'une image_ ne font qu'appeler `omarchy transcode ascii`, que vous pouvez exécuter directement si vous voulez contrôler la conversion :

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Cela prend `--width` et `--height` en colonnes et en lignes du terminal, un `--mode` valant soit `braille` (par défaut, et bien plus fin), soit `block`, un `--threshold` en pourcentage pour décider quels pixels font partie du logo, et `--invert` pour les cas où votre logo est clair sur un fond sombre. Si une conversion ressort comme une masse informe, c'est généralement le seuil qu'il faut ajuster.

### Des mots au lieu d'un logo

`omarchy ascii` dessine du texte en Delta Corps Priest 1, la police FIGlet dans laquelle le logotype Omarchy lui-même est dessiné, pour qu'un écran de veille puisse dire quelque chose plutôt que montrer une image :

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Cela prend le texte en arguments, ou le lit depuis un pipe quand on ne lui en donne aucun. La police ne contient que des lettres et des espaces — elle a été dessinée sans chiffres ni ponctuation — donc tout le reste est abandonné et signalé sur stderr plutôt qu'avalé en silence.
