# Fonds d'écran

Chaque thème est livré avec son propre ensemble de fonds d'écran, et vous pouvez ajouter les vôtres dans `~/.config/omarchy/backgrounds/[theme]`. Si vous voulez ajouter une image de fond supplémentaire, disons au thème nord, il vous suffit de placer le fichier dans `~/.config/omarchy/backgrounds/nord`.

Le plus simple pour le faire est d'aller dans _Installer > Style > Fond d'écran_ dans le menu Omarchy. Cela ouvrira le dossier où sont stockés les fonds d'écran de ce thème. Appuyez sur `Super + Shift + F` pour ouvrir un autre gestionnaire de fichiers, trouvez votre fond d'écran, copiez-le dedans.  Il fera désormais partie des fonds d'écran entre lesquels vous pouvez choisir avec `Super + Ctrl + W`.

Les fonds d'écran peuvent être des vidéos aussi bien que des images fixes. Déposez un fichier `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` dans le même dossier et il apparaîtra aux côtés des images. Les vidéos sont lues par le moteur de fond d'écran OWE. Il décode la vidéo une seule fois pour tous les écrans, diffuse son son via la sortie audio par défaut et arrête la lecture dès que rien ne peut la voir. Un fond d'écran vidéo consomme quand même beaucoup plus d'énergie qu'un fond d'écran fixe.

Les thèmes peuvent inclure une courte introduction pour un fond d'écran fixe. Pour `backgrounds/road.webp`, la vidéo correspondante se trouve dans `backgrounds/intros/road.mp4`. Elle se lance automatiquement au démarrage, lorsque vous passez à un thème avec ce fond d'écran sélectionné et lorsque vous choisissez ce fond d'écran, puis revient à l'image fixe. Les vidéos d'introduction n'apparaissent pas dans le sélecteur de fonds d'écran et ne tournent jamais en boucle.

Désactiver _Apparence > Animations_ désactive aussi les introductions des fonds d'écran. Omarchy le fait par défaut dans une machine virtuelle. La commande `omarchy theme bg intro toggle` permet d'activer ou de désactiver les introductions séparément. Actualiser un thème ne lance pas d'introduction.

Une image fixe peut aussi avoir une boucle, une version discrète de la même image qui continue de bouger, dans `backgrounds/loops/road.mp4`. Elle se joue à la place de l'image fixe, après son introduction si elle en a une, et s'arrête lorsque les animations sont désactivées. Sur batterie, l'image fixe s'affiche à la place, et la boucle revient dès que vous branchez l'appareil. Les boucles n'apparaissent pas dans le sélecteur de fonds d'écran.

Vous trouverez une immense collection de fonds d'écran sympas et soigneusement sélectionnés dans [dharmx/walls](https://github.com/dharmx/walls).

L'écran de verrouillage affiche une image fixe d'un fond d'écran vidéo, de la même façon qu'il affiche une image fixe d'un GIF animé.
