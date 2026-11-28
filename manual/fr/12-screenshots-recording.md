# Captures d'écran et enregistrement

Tout ce que vous pouvez capturer à l'écran dépend de la touche Print Screen. Une touche seule prend une photo, et les modificateurs prennent un enregistrement, une couleur, ou le texte à l'intérieur d'une région. Si votre clavier n'a pas du tout de touche Print Screen, `Super + Ctrl + Alt + C` prend la même capture d'écran, et `Super + Ctrl + C` ouvre l'ensemble sous forme de menu.

| Raccourci clavier | Fonction |
| ------ | -------- |
| `Print Screen` | Capture d'écran |
| `Super + Ctrl + Alt + C` | Capture d'écran |
| `Alt + Print Screen` | Enregistrement d'écran (ou arrêter celui en cours) |
| `Super + Print Screen` | Sélecteur de couleur |
| `Super + Ctrl + Print Screen` | Extraire le texte d'une région |
| `Super + Ctrl + C` | Menu de capture |
| `Super + Ctrl + .` | Transcoder une image ou une vidéo |

## Captures d'écran

Appuyez sur `Print Screen` (ou `Super + Ctrl + Alt + C`) et Omasnap capture le moniteur actif avant l'apparition de sa superposition, pour que rien ne bouge pendant que vous visez. Faites glisser une région libre, cliquez sur une fenêtre pour la capturer, ou cliquez sur un espace vide pour capturer le moniteur entier. Appuyez sur `S` avant de tracer pour capturer une région défilante. Vous avez changé d'avis ? Appuyez à nouveau sur la même touche pour fermer Omasnap.

Après avoir sélectionné une zone, Omasnap enregistre la capture, la copie dans le presse-papiers, et affiche une notification avec sa miniature, comme le fait un enregistrement d'écran sauvegardé. Choisissez Open pour voir la capture sauvegardée dans votre visionneuse d'images, ou Edit pour l'annoter.

L'éditeur d'annotation peut dessiner des flèches, des lignes, des formes, des surlignages, des marqueurs numérotés, du texte et des masquages sécurisés ; recadrer ou découper une partie de l'image ; extraire son texte par OCR ; et ajouter un arrière-plan. Dans l'éditeur, appuyez sur `Enter` pour copier et enregistrer le PNG final, `Ctrl + C` pour le copier sans l'enregistrer, ou `Ctrl + S` pour l'enregistrer sans le copier.

Les captures d'écran sauvegardées arrivent dans `~/Pictures/Screenshots` par défaut, avec un nom tel que `screenshot-2026-08-13_14-22-05-firefox.png`. Définissez `OMASNAP_SCREENSHOT_DIR` pour utiliser un autre répertoire — voir [la FAQ](46-faq.md) pour savoir où placer les variables d'environnement de session. Omasnap crée le répertoire lorsqu'il enregistre la première capture. Définissez `[output] autosave = false` dans `~/.config/omasnap/omasnap.conf` pour désactiver l'enregistrement automatique ; les captures sont alors uniquement copiées, et affichées dans un aperçu pendant 7 secondes que vous pouvez garder à l'écran avec son bouton d'épinglage ou `Ctrl + P`.

Depuis le terminal, `omarchy screenshot` ouvre la même superposition, et vous pouvez choisir son mode de départ : `omarchy capture screenshot region`, `windows`, `fullscreen`, ou `scroll`. Un deuxième argument `copy` ou `save` envoie la capture directement vers cette destination. Pour modifier avant la sortie, utilisez `omarchy screenshot --editor=overlay` pour un éditeur plein écran ou `omarchy screenshot --editor=window` pour une fenêtre séparée.

### Piloter le sélecteur au clavier

Pendant que la sélection est affichée, vous n'avez pas du tout à utiliser la souris :

| Touche | Fonction |
| --- | -------- |
| `S` | Basculer le mode région défilante |
| `Super + Arrow keys` | Se déplacer parmi les fenêtres en mode Window |
| `Return` | Capturer la fenêtre mise en surbrillance |
| `Ctrl + A` | Capturer le moniteur actif entier |
| `R` | Restaurer la dernière région tracée dans cette session |
| `Esc` | Fermer Omasnap |

Ces raccourcis n'existent que pendant que Omasnap est ouvert, ils ne peuvent donc entrer en conflit avec quoi que ce soit dans votre propre configuration.

## Enregistrement d'écran

`Alt + Print Screen` ouvre _Trigger > Capture > Screenrecord_, qui demande ce que vous voulez sur la bande-son : aucun audio, l'audio du bureau, le bureau plus le microphone, ou le bureau plus le microphone plus la webcam. Cette dernière option n'apparaît que si vous avez réellement une caméra branchée. Choisissez-en une et le sélecteur d'enregistrement d'Omarchy vous permet de faire glisser une région ou de cliquer sur une fenêtre ou un moniteur.

L'enregistrement repose sur gpu-screen-recorder, qui encode sur le GPU à 60fps et repasse sur le CPU s'il le faut ; sur les GPU qu'il ne prend pas en charge, comme ceux d'Apple Silicon, Omarchy enregistre avec wf-recorder à la place. Le résultat est un MP4 dans `~/Videos`, nommé `screenrecording-2026-08-13_14-22-05.mp4`. Définissez `OMARCHY_SCREENRECORD_DIR` pour changer ça — mais notez que, contrairement au répertoire des captures d'écran, celui-ci doit déjà exister, sinon l'enregistrement refuse de démarrer.

Pendant que vous enregistrez, un petit indicateur apparaît dans la barre. Cliquez dessus pour arrêter. Vous pouvez aussi arrêter avec `Alt + Print Screen` à nouveau, ou avec l'entrée _Stop Screenrecording_ sous _Trigger > Capture > Screenrecord_, qui n'apparaît que pendant qu'un enregistrement est réellement en cours.

L'arrêt fait un peu de ménage avant de vous remettre le fichier : la première image est rognée, et s'il y a de l'audio, il est normalisé à -14 LUFS avec le pop de capture PipeWire tout au début coupé. Ensuite, une notification apparaît avec une miniature tirée de l'enregistrement. Choisissez _Open_ pour lire le fichier dans Omaview, ou _Cut_ pour le rogner dans Omacut.

### La superposition webcam

Quand vous enregistrez avec une webcam, la caméra apparaît comme une fenêtre portrait épinglée et recadrée dans le coin inférieur droit de ce que vous enregistrez. Si elle est par-dessus quelque chose dont vous avez besoin, redimensionnez-la à la volée :

| Raccourci clavier | Fonction |
| ------ | -------- |
| `Super + Alt + [` | Rendre la superposition webcam plus petite |
| `Super + Alt + ]` | Rendre la superposition webcam plus grande |

Il existe trois tailles — petite, moyenne et grande — et les raccourcis clavier passent de l'une à l'autre. Moyenne est la valeur par défaut. Elles sont proportionnelles à l'enregistrement, donc la caméra occupe la même part de l'image que vous enregistriez un moniteur 1080p ou un moniteur 6K. Et si vous avez enregistré une région plutôt qu'un écran entier, la superposition s'ancre au coin de cette région plutôt qu'à celui du moniteur, pour rester dans le champ.

Vous pouvez aussi l'appeler directement avec `omarchy-capture-webcam-resize small`, ou `reset` pour revenir à moyenne.

## Texte, codes QR et couleurs

`Super + Ctrl + Print Screen` sélectionne une région et en extrait le texte par OCR vers le presse-papiers. C'est traité correctement dans [Extraction de texte et dictée](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ fait le même tour pour les codes QR. Sélectionnez la région contenant le code, et la valeur décodée part dans le presse-papiers. Il ne cherche que les codes QR — le contenu d'écran dense a sinon tendance à être détecté à tort comme un code-barres. Bon à savoir : la valeur décodée va dans le presse-papiers et nulle part ailleurs. Elle n'est pas affichée, elle n'est pas dans la notification, et elle est marquée comme sensible pour ne pas rester dans l'[historique du presse-papiers](08-unified-clipboard-history.md). Les codes QR transportent couramment des secrets — l'URI `otpauth://` derrière un code de configuration 2FA, par exemple — et vous ne voulez pas de ça dans un journal. Le collage fonctionne toujours très bien.

`Super + Print Screen` (ou _Trigger > Capture > Color_) transforme le curseur en pipette. Cliquez sur n'importe quoi à l'écran et la couleur arrive dans le presse-papiers. Appuyez à nouveau sur le raccourci clavier pour quitter sans rien prélever.

## Transcoder avant de partager

Un enregistrement d'écran 4K ou un HEIC brut sorti de votre téléphone est souvent trop gros pour être simplement envoyé. `Super + Ctrl + .` (ou _Trigger > Transcode_) règle ça. Il vous propose un sélecteur de fichier à recherche approximative sur `~/Pictures` et `~/Videos`, puis demande un format et une taille.

Les images passent en jpg ou png en high, medium ou low, qui limitent la largeur à 3160, 2160 et 1080 pixels. Les vidéos passent en mp4 ou en gif animé en 4k, 1080p ou 720p. Le fichier converti est écrit à côté de l'original avec la résolution dans le nom — `demo-1080p.mp4` — et le chemin est copié dans le presse-papiers sous forme d'URI de fichier, pour que vous puissiez le coller directement dans une application qui accepte les dépôts de fichiers.

Ça fonctionne aussi depuis le terminal, si vous savez déjà ce que vous voulez : `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Il y a aussi `omarchy transcode ascii`, qui transforme une image en art ASCII — celui-là sert surtout pour le [branding](41-branding.md).

## L'envoyer quelque part

Une fois le fichier en main, `Super + Ctrl + S` ouvre le menu Share et l'envoie à un autre appareil de votre réseau via LocalSend. Voir [GUIs](22-guis.md) pour ça.
