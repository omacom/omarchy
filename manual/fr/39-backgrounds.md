# Arrière-plans

Chaque thème est livré avec son propre ensemble d'arrière-plans, et tu peux en ajouter à toi dans `~/.config/omarchy/backgrounds/[theme]`. Si tu veux ajouter une image d'arrière-plan supplémentaire, disons au thème nord, il suffit de placer le fichier dans `~/.config/omarchy/backgrounds/nord`.

Le plus simple pour le faire, c'est d'aller dans _Installer > Style > Arrière-plan_ dans le Omarchy Menu. Ça ouvrira le dossier où sont stockés les arrière-plans de ce thème. Appuie sur `Super + Shift + F` pour lancer un autre gestionnaire de fichiers, trouve ton arrière-plan, copie-le dedans. Il fera désormais partie des arrière-plans entre lesquels tu peux choisir avec `Super + Ctrl + W`.

Les arrière-plans peuvent être des vidéos aussi bien que des images fixes. Dépose un fichier `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` dans le même dossier et il apparaîtra aux côtés des images. Les vidéos sont lues par le moteur de fond d'écran OWE. Il décode la vidéo une seule fois pour tous les écrans et diffuse son son via la sortie audio par défaut, et il arrête la lecture dès que plus rien ne peut la voir. Un fond d'écran vidéo coûte quand même bien plus d'énergie qu'un fond d'écran fixe.

Les thèmes peuvent inclure une courte intro pour un arrière-plan fixe. Pour `backgrounds/road.webp`, la vidéo correspondante se trouve dans `backgrounds/intros/road.mp4`. Elle est lue automatiquement au démarrage, quand tu passes à un thème avec cet arrière-plan sélectionné, et quand tu choisis cet arrière-plan, puis elle revient à l'image fixe. Les vidéos d'intro n'apparaissent pas dans le sélecteur d'arrière-plans et ne bouclent jamais.

Désactiver _Apparence > Animations_ désactive aussi les intros d'arrière-plan. Omarchy le fait par défaut dans une machine virtuelle. La commande `omarchy theme bg intro toggle` permet d'activer ou de désactiver les intros séparément. Actualiser un thème ne lit pas d'intro.

Tu trouveras une énorme collection d'arrière-plans sympas et soigneusement sélectionnés dans [dharmx/walls](https://github.com/dharmx/walls).

L'écran de verrouillage affiche une image fixe d'un arrière-plan vidéo, de la même façon qu'il affiche une image fixe d'un GIF animé.
