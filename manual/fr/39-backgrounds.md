# Arrière-plans

Chaque thème est livré avec son propre ensemble d’arrière-plans, et vous pouvez en ajouter d’autres dans `~/.config/omarchy/backgrounds/[theme]`. Si vous voulez ajouter une image d’arrière-plan supplémentaire, par exemple, au thème nord, il vous suffit de placer le fichier dans `~/.config/omarchy/backgrounds/nord`.

Le plus simple pour le faire est d’aller dans _Install > Style > Background_ dans le Omarchy Menu. Cela ouvrira le dossier où sont stockés les arrière-plans de ce thème. Appuyez sur `Super + Shift + F` pour ouvrir un autre gestionnaire de fichiers, trouvez votre arrière-plan, copiez-le dedans. Il sera désormais inclus dans les choix d’arrière-plans entre lesquels vous pouvez basculer avec `Super + Ctrl + W`.

Les arrière-plans peuvent être des vidéos aussi bien que des images fixes. Déposez un fichier `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` dans le même dossier et il apparaîtra aux côtés des images. Les vidéos sont lues par le moteur de fond d’écran OWE. Il décode la vidéo une seule fois pour tous les écrans, joue son son via la sortie audio par défaut, et arrête la lecture dès que rien ne peut la voir. Un fond d’écran vidéo consomme tout de même bien plus d’énergie qu’un fond d’écran fixe.

Les thèmes peuvent inclure une courte intro pour un arrière-plan fixe. Pour `backgrounds/road.webp`, la vidéo correspondante se trouve dans `backgrounds/intros/road.mp4`. Elle se joue automatiquement au démarrage et lorsque vous basculez vers un thème avec cet arrière-plan sélectionné, puis revient à l’image fixe. Les vidéos d’intro n’apparaissent pas dans le sélecteur d’arrière-plans et ne tournent jamais en boucle.

Désactiver _Appearance > Animations_ désactive aussi les intros d’arrière-plan. Omarchy le fait par défaut dans une machine virtuelle. La commande `omarchy theme bg intro toggle` permet d’activer ou de désactiver les intros séparément. Actualiser un thème ou choisir un autre arrière-plan au sein du même thème ne joue pas d’intro.

Vous pouvez trouver une immense collection d’arrière-plans géniaux et soigneusement sélectionnés sur https://github.com/dharmx/walls.

L’écran de verrouillage affiche une image fixe d’un arrière-plan vidéo, de la même façon qu’il affiche une image fixe d’un GIF animé.
