# Arrière-plans

Chaque thème est livré avec son propre ensemble d'arrière-plans, et tu peux en ajouter d'autres à toi dans `~/.config/omarchy/backgrounds/[theme]`. Si tu veux ajouter une image d'arrière-plan supplémentaire, disons au thème nord, mets simplement le fichier dans `~/.config/omarchy/backgrounds/nord`.

Le plus simple pour le faire est d'aller dans _Installation > Style > Arrière-plan_ dans le menu Omarchy. Cela ouvrira le dossier où sont stockés les arrière-plans de ce thème. Appuie sur `Super + Shift + F` pour ouvrir un autre gestionnaire de fichiers, trouve ton arrière-plan et copie-le dedans. Il fera désormais partie des arrière-plans que tu peux choisir avec `Super + Ctrl + W`.

Un thème sans aucun arrière-plan propre en reçoit un dessiné à partir de ses couleurs : le logo Omarchy dans la couleur d'accentuation du thème sur sa couleur d'arrière-plan. Ajoute les tiens pour le remplacer.

Les arrière-plans peuvent être des vidéos aussi bien que des images fixes. Dépose un fichier `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` dans le même dossier et il apparaîtra aux côtés des images. Les vidéos sont lues par le moteur de fond d'écran OWE. Il décode la vidéo une seule fois pour tous les moniteurs, joue son son via la sortie audio par défaut et arrête la lecture dès que rien ne peut la voir. Un fond d'écran vidéo consomme toujours bien plus d'énergie qu'un fond d'écran fixe.

Les thèmes peuvent inclure une courte intro pour un arrière-plan fixe. Pour `backgrounds/road.webp`, la vidéo correspondante se trouve dans `backgrounds/intros/road.mp4`. Elle est lue automatiquement au démarrage, quand tu passes à un thème avec cet arrière-plan sélectionné et quand tu choisis cet arrière-plan, puis l'affichage revient à l'image fixe. Les vidéos d'intro n'apparaissent pas dans le sélecteur d'arrière-plans et ne sont jamais lues en boucle.

Choisir _Apparence > Animations désactivées_ désactive aussi les intros d'arrière-plan. Omarchy le fait par défaut dans une machine virtuelle. La commande `omarchy theme bg intro toggle` permet d'activer ou de désactiver les intros séparément. Actualiser un thème ne lit pas d'intro.

Une image fixe peut aussi avoir une boucle, une version discrète de la même image qui continue de bouger, dans `backgrounds/loops/road.mp4`. Elle est lue à la place de l'image fixe, après son intro si elle en a une, et s'arrête quand les animations sont désactivées. Sur batterie, l'image fixe s'affiche à la place, et la boucle revient dès que tu branches l'alimentation. Les boucles n'apparaissent pas dans le sélecteur d'arrière-plans.

Tu peux trouver une énorme collection d'arrière-plans sympas et soigneusement sélectionnés dans [dharmx/walls](https://github.com/dharmx/walls).

L'écran de verrouillage affiche une image fixe d'un arrière-plan vidéo, de la même façon qu'il affiche une image fixe d'un GIF animé.
