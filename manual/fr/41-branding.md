# Image de marque

Omarchy vous permet de définir le logo de votre entreprise ou une image personnelle pour le déverrouillage au démarrage, l'écran de veille et l'écran À propos.

### Déverrouillage au démarrage

Vous pouvez utiliser `omarchy plymouth preview` pour voir à quoi ressembleraient votre logo et vos couleurs personnalisés. Il prend une couleur de fond, une couleur de texte, un logo png et un chemin pour l'image d'aperçu :

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Appliquez ensuite la configuration avec `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, qui donnera aussi à l'écran de connexion SDDM les mêmes couleurs et le même logo. Si vous voulez revenir en arrière, vous pouvez utiliser `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Écran de veille

Vous pouvez changer le logo utilisé pour l'écran de veille sous _Style > Écran de veille_. C'est un logo ASCII, si bien que vous pouvez modifier le texte directement, mais vous pouvez aussi lui donner une image png ou svg, et nous la convertirons en ASCII. Ça a plutôt belle allure.

 ![branding-screensaver](images/branding-screensaver.webp)

Il y a trois entrées dans ce menu :

- **Modifier le texte** ouvre `~/.config/omarchy/branding/screensaver.txt` dans votre éditeur. Tapez ou collez ce que vous voulez — de l'art ASCII, votre nom, un gros mot. Enregistrez et quittez, et l'écran de veille se lance immédiatement pour que vous puissiez le voir.
- **Depuis une image** ouvre un sélecteur de fichier pour un png ou un svg, le convertit en ASCII et vous montre le résultat. Les logos à silhouette nette fonctionnent bien mieux que les photos.
- **Restaurer défaut** remet le logo Omarchy.

### Écran À propos

Les trois mêmes options se trouvent sous _Style > À propos_ pour l'écran _À propos_ que vous obtenez depuis le menu Omarchy, et elles fonctionnent à l'identique — le fichier est `~/.config/omarchy/branding/about.txt`, et la fenêtre À propos apparaît après chaque changement. L'art À propos est converti dans une taille plus petite que celui de l'écran de veille, puisqu'il doit tenir dans une fenêtre plutôt que remplir votre écran.

Tant que la fenêtre est ouverte, un éclat vert traverse l'art toutes les quelques secondes puis le laisse immobile à nouveau. Votre propre art y a droit aussi, tant que chaque caractère y fait une colonne de large — tout ce que _Depuis une image_ produit l'est. L'art construit à partir d'emoji ou de caractères double largeur reste immobile à la place, et l'écran aussi si vous gardez une configuration fastfetch à vous : un logo immobile dans ces cas-là, c'est l'animation qui s'écarte plutôt qu'un échec, puisque faire glisser un éclat dessus placerait le reste de la ligne au mauvais endroit.

 ![branding-about](images/branding-about.webp)

### Convertir les images vous-même

Les deux options _Depuis une image_ appellent simplement `omarchy transcode ascii`, que vous pouvez lancer directement si vous voulez contrôler la conversion :

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Il prend `--width` et `--height` en colonnes et lignes de terminal, un `--mode` valant soit `braille` (la valeur par défaut, et bien plus fin) soit `block`, un pourcentage `--threshold` pour décider quels pixels comptent comme faisant partie du logo, et `--invert` quand votre logo est clair sur fond sombre. Si une conversion ressort en pâté, le seuil est en général le bouton à tourner.

### Des mots plutôt qu'un logo

`omarchy ascii` dessine du texte en Delta Corps Priest 1, la police FIGlet dans laquelle la marque verbale Omarchy elle-même est dessinée, si bien qu'un écran de veille peut dire quelque chose plutôt que montrer une image :

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Il prend le texte en arguments, ou le lit depuis un pipe quand on ne lui en donne aucun. La police ne comporte que des lettres et des espaces — elle a été dessinée sans chiffres ni ponctuation — si bien que tout le reste est écarté et signalé sur stderr plutôt qu'avalé silencieusement.
