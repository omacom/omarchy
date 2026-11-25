# Image de marque

Omarchy vous permet de définir le logo de votre entreprise ou une image personnelle pour le déverrouillage au démarrage, l'écran de veille et l'écran À propos.

### Déverrouillage au démarrage

Vous pouvez utiliser `omarchy plymouth preview` pour voir à quoi ressembleraient votre logo et vos couleurs personnalisés. Elle prend une couleur d'arrière-plan, une couleur de texte, un png de logo et un chemin pour l'image d'aperçu :

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Appliquez ensuite la configuration avec `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, qui donnera aussi à l'écran de connexion SDDM les mêmes couleurs et le même logo. Si vous voulez revenir en arrière, vous pouvez utiliser `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Écran de veille

Vous pouvez changer le logo utilisé pour l'écran de veille sous _Apparence > Image de marque > Écran de veille_. C'est un logo ASCII, vous pouvez donc modifier le texte directement, mais vous pouvez aussi lui fournir une image png ou svg, et nous la convertirons en ASCII. Ça rend plutôt bien.

 ![branding-screensaver](images/branding-screensaver.webp)

Il y a trois entrées dans ce menu :

- **Modifier le texte** ouvre `~/.config/omarchy/branding/screensaver.txt` dans votre éditeur. Tapez ou collez ce que vous voulez — de l'art ASCII, votre nom, un gros mot. Enregistrez et quittez, et l'écran de veille se lance immédiatement pour que vous puissiez le voir.
- **Définir à partir d'une image** ouvre un sélecteur de fichier pour un png ou un svg, le convertit en ASCII et vous montre le résultat. Les logos avec une silhouette nette fonctionnent bien mieux que les photos.
- **Restaurer par défaut** remet le logo Omarchy.

### Écran À propos

Les trois mêmes options se trouvent sous _Apparence > Image de marque > À propos_ pour l'écran _À propos_ que vous obtenez depuis le menu Omarchy, et elles fonctionnent de manière identique — le fichier est `~/.config/omarchy/branding/about.txt`, et la fenêtre À propos s'affiche après chaque modification. L'illustration À propos est convertie à une taille plus petite que celle de l'écran de veille, puisqu'elle doit tenir dans une fenêtre plutôt que remplir votre écran.

Pendant que la fenêtre est ouverte, une bande de lumière blanche vive traverse l'illustration en diagonale toutes les quelques secondes, puis la laisse à nouveau immobile. Votre propre illustration en bénéficie aussi, tant que chaque caractère qu'elle contient occupe une seule colonne — c'est le cas de tout ce que produit _Définir à partir d'une image_. Une illustration construite à partir d'emoji ou de caractères double largeur reste immobile à la place, et l'écran aussi si vous conservez votre propre configuration fastfetch : un logo immobile dans ces cas, c'est l'animation qui s'écarte du chemin plutôt qu'un échec, car faire glisser un reflet dessus placerait le reste de la ligne au mauvais endroit.

 ![branding-about](images/branding-about.webp)

### Convertir les images vous-même

Les deux options _Définir à partir d'une image_ ne font qu'appeler `omarchy transcode ascii`, que vous pouvez exécuter directement si vous voulez contrôler la conversion :

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Elle prend `--width` et `--height` en colonnes et lignes du terminal, un `--mode` valant soit `braille` (le mode par défaut, et bien plus fin), soit `block`, un pourcentage `--threshold` pour décider quels pixels font partie du logo, et `--invert` pour quand votre logo est clair sur un fond sombre. Si une conversion donne une masse informe, le seuil est généralement le réglage à tourner.

### Des mots plutôt qu'un logo

`omarchy ascii` dessine du texte en Delta Corps Priest 1, la police FIGlet dans laquelle le logotype Omarchy lui-même est dessiné, pour qu'un écran de veille puisse dire quelque chose plutôt que montrer une image :

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Elle prend le texte en arguments, ou le lit depuis un pipe quand on ne lui en donne aucun. La police ne contient que des lettres et des espaces — elle a été dessinée sans chiffres ni ponctuation — donc tout le reste est supprimé et signalé sur stderr plutôt qu'avalé silencieusement.
