# Arrière-plans

Chaque thème est livré avec son propre jeu d'arrière-plans, et vous pouvez en ajouter d'autres dans `~/.config/omarchy/backgrounds/[theme]`. Si vous voulez ajouter une image d'arrière-plan supplémentaire au thème nord, par exemple, placez simplement le fichier dans `~/.config/omarchy/backgrounds/nord`.

Le plus simple est de passer par _Install > Style > Background_ dans le menu Omarchy. Cela ouvrira le dossier où sont stockés les arrière-plans de ce thème. Appuyez sur `Super + Shift + F` pour ouvrir un autre gestionnaire de fichiers, trouvez votre arrière-plan et copiez-le dedans. Il figurera désormais parmi les arrière-plans que vous pouvez choisir avec `Super + Ctrl + W`.

Les arrière-plans peuvent être des vidéos aussi bien que des images fixes. Déposez un fichier `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` dans le même dossier et il apparaîtra aux côtés des images. Les vidéos sont lues par le moteur de fond d'écran OWE. Il décode la vidéo une seule fois pour tous les écrans et diffuse son son via la sortie audio par défaut, et il arrête la lecture dès que plus rien ne peut la voir. Un fond d'écran vidéo consomme toujours bien plus d'énergie qu'un fond fixe.

Les thèmes peuvent inclure une courte intro pour un arrière-plan fixe. Pour `backgrounds/road.webp`, la vidéo correspondante se trouve dans `backgrounds/intros/road.mp4`. Elle se lance automatiquement au démarrage, lorsque vous basculez vers un thème avec cet arrière-plan sélectionné et lorsque vous choisissez cet arrière-plan, puis revient à l'image fixe. Les vidéos d'intro n'apparaissent pas dans le sélecteur d'arrière-plans et ne tournent jamais en boucle.

Choisir _Appearance > Animations Off_ désactive aussi les intros d'arrière-plan. Omarchy le fait par défaut dans une machine virtuelle. La commande `omarchy theme bg intro toggle` permet d'activer ou de désactiver les intros séparément. Actualiser un thème ne lance pas d'intro.

Une image fixe peut aussi avoir une boucle, une version discrète de la même image qui continue de bouger, dans `backgrounds/loops/road.mp4`. Elle se joue à la place de l'image fixe, après son intro si elle en a une, et s'arrête lorsque les animations sont désactivées. Sur batterie, l'image fixe s'affiche à la place, et la boucle revient dès que vous branchez l'alimentation. Les boucles n'apparaissent pas dans le sélecteur d'arrière-plans.

Vous trouverez une immense collection d'arrière-plans superbes et soigneusement sélectionnés dans [dharmx/walls](https://github.com/dharmx/walls).

L'écran de verrouillage affiche une image fixe d'un arrière-plan vidéo, de la même façon qu'il affiche une image fixe d'un GIF animé.
