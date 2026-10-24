# Arrière-plans

Chaque thème est livré avec son propre jeu d'arrière-plans, et vous pouvez en ajouter dans `~/.config/omarchy/backgrounds/[theme]`. Si vous voulez ajouter une image d'arrière-plan supplémentaire au thème nord, par exemple, placez simplement le fichier dans `~/.config/omarchy/backgrounds/nord`.

Le plus simple est d'aller dans _Installer > Style > Arrière-plan_ dans le menu Omarchy. Cela ouvrira le dossier où sont stockés les arrière-plans de ce thème. Appuyez sur `Super + Shift + F` pour lancer un autre gestionnaire de fichiers, trouvez votre arrière-plan, copiez-le. Il figurera désormais parmi les arrière-plans entre lesquels vous pouvez choisir avec `Super + Ctrl + Space`.

Les arrière-plans peuvent être des vidéos aussi bien que des images fixes. Déposez un fichier `mp4`, `m4v`, `mov`, `webm`, `mkv` ou `avi` dans le même dossier et il apparaît aux côtés des images. Les vidéos sont lues par le moteur de fond d'écran OWE. Il décode la vidéo une fois pour tous les écrans et joue son son via la sortie audio par défaut, et il arrête la lecture dès que rien ne peut le voir. L'écran de verrouillage dessine le même décodage, en sourdine, via OWE. Un fond d'écran vidéo coûte toujours bien plus d'énergie qu'un fond fixe.

Les thèmes peuvent inclure une courte intro pour un arrière-plan fixe. Pour `backgrounds/road.webp`, la vidéo correspondante se trouve dans `backgrounds/intros/road.mp4`. Elle se joue automatiquement au démarrage et lors d'un changement vers un thème avec cet arrière-plan sélectionné, puis revient à l'image fixe. Les vidéos d'intro restent hors du sélecteur d'arrière-plan et ne bouclent jamais.

Désactiver _Déclencher > Apparence > Animations_ désactive aussi les intros d'arrière-plan. Omarchy le fait par défaut dans une machine virtuelle. La commande `omarchy theme bg intro toggle` peut basculer les intros séparément. Actualiser un thème ou choisir un autre arrière-plan au sein du même thème ne joue pas d'intro.

Vous pouvez trouver une immense collection d'arrière-plans curatés et sympas sur https://github.com/dharmx/walls.

Les arrière-plans vidéo gardent une image fixe en cache sur l'écran de verrouillage pendant que la lecture est en pause ou indisponible. Les GIF animés se jouent sur le bureau et affichent une image fixe sur l'écran de verrouillage.
