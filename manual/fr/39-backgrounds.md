# Arrière-plans

Chaque thème est livré avec son propre ensemble d'arrière-plans, et vous pouvez en ajouter d'autres dans `~/.config/omarchy/backgrounds/[theme]`. Si vous voulez ajouter une image d'arrière-plan supplémentaire au thème nord, par exemple, il vous suffit de placer le fichier dans `~/.config/omarchy/backgrounds/nord`.

Le moyen le plus simple de le faire est d'aller dans _Installer > Style > Arrière-plan_ dans le menu Omarchy. Cela ouvrira le dossier où sont stockés les arrière-plans de ce thème. Appuyez sur `Super + Shift + F` pour lancer un autre gestionnaire de fichiers, trouvez votre arrière-plan, copiez-le. Il fera désormais partie des arrière-plans que vous pouvez choisir avec `Super + Ctrl + W`.

Les arrière-plans peuvent être des vidéos aussi bien que des images fixes. Déposez un fichier `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` dans le même dossier et il apparaîtra aux côtés des images. Les vidéos sont lues par le moteur de fond d'écran OWE. Il décode la vidéo une seule fois pour tous les écrans et diffuse son son via la sortie audio par défaut, et il arrête la lecture dès que rien ne peut la voir. Un fond d'écran vidéo coûte quand même bien plus d'énergie qu'un fond fixe.

Les thèmes peuvent inclure une courte introduction pour un arrière-plan fixe. Pour `backgrounds/road.webp`, la vidéo correspondante se trouve dans `backgrounds/intros/road.mp4`. Elle est lue automatiquement au démarrage, lorsque vous passez à un thème avec cet arrière-plan sélectionné et lorsque vous choisissez cet arrière-plan, puis revient à l'image fixe. Les vidéos d'introduction n'apparaissent pas dans le sélecteur d'arrière-plans et ne sont jamais lues en boucle.

Désactiver _Apparence > Animations_ désactive également les introductions d'arrière-plan. Omarchy le fait par défaut dans une machine virtuelle. La commande `omarchy theme bg intro toggle` permet d'activer ou de désactiver les introductions séparément. Actualiser un thème ne lit pas d'introduction.

Une image fixe peut aussi avoir une boucle, une version discrète de la même image qui continue de bouger, dans `backgrounds/loops/road.mp4`. Elle est lue à la place de l'image fixe, après son introduction si elle en a une, et s'arrête lorsque les animations sont désactivées. Les boucles n'apparaissent pas dans le sélecteur d'arrière-plans et, comme tout arrière-plan vidéo, coûtent plus d'énergie qu'une image fixe.

Vous trouverez une immense collection d'arrière-plans soigneusement sélectionnés dans [dharmx/walls](https://github.com/dharmx/walls).

L'écran de verrouillage affiche une image fixe d'un arrière-plan vidéo, de la même manière qu'il affiche une image fixe d'un GIF animé.
