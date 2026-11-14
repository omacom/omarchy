# Captures d'écran et enregistrement

Tout ce que vous pouvez capturer à l'écran dépend de la touche Print Screen. La touche seule prend une image, et les modificateurs prennent un enregistrement, une couleur, ou le texte à l'intérieur d'une zone. Si votre clavier n'a pas du tout de touche Print Screen, `Super + Ctrl + Alt + C` prend la même capture d'écran, et `Super + Ctrl + C` ouvre l'ensemble sous forme de menu.

| Raccourci | Fonction |
| ------ | -------- |
| `Print Screen` | Capture d'écran |
| `Super + Ctrl + Alt + C` | Capture d'écran |
| `Alt + Print Screen` | Enregistrement d'écran (ou arrêter celui en cours) |
| `Super + Print Screen` | Pipette à couleurs |
| `Super + Ctrl + Print Screen` | Extraire le texte d'une zone |
| `Super + Ctrl + C` | Menu de capture |
| `Super + Ctrl + .` | Transcoder une image ou une vidéo |

## Captures d'écran

Appuyez sur `Print Screen` (ou `Super + Ctrl + Alt + C`) et Omasnap capture le moniteur actif avant que son interface ne s'affiche, de sorte que rien ne bouge sous votre visée pendant que vous visez. Faites glisser pour délimiter une zone libre, cliquez sur une fenêtre pour la capturer, ou cliquez sur un espace vide pour capturer tout le moniteur. Appuyez sur `S` avant de dessiner pour capturer une zone défilante. Vous avez changé d'avis ? Appuyez à nouveau sur la même touche pour fermer Omasnap.

Après avoir sélectionné une zone, Omasnap enregistre la capture, la copie dans le presse-papiers et affiche une notification avec sa miniature, comme le fait un enregistrement d'écran sauvegardé. Choisissez Open pour afficher la capture enregistrée dans votre visionneuse d'images, ou Edit pour l'annoter.

L'éditeur d'annotation peut dessiner des flèches, des lignes, des formes, des surlignages, des marqueurs numérotés, du texte et des masquages sécurisés ; recadrer ou découper une partie de l'image ; extraire son texte par OCR ; et ajouter un arrière-plan. Dans l'éditeur, appuyez sur `Enter` pour copier et enregistrer le PNG final, sur `Ctrl + C` pour le copier sans l'enregistrer, ou sur `Ctrl + S` pour l'enregistrer sans le copier.

Les captures d'écran enregistrées arrivent par défaut dans `~/Pictures/Screenshots`, avec un nom tel que `screenshot-2026-08-13_14-22-05-firefox.png`. Définissez `OMASNAP_SCREENSHOT_DIR` pour utiliser un autre répertoire — voir [la FAQ](46-faq.md) pour savoir où placer les variables d'environnement de session. Omasnap crée le répertoire lorsqu'il enregistre la première capture. Définissez `[output] autosave = false` dans `~/.config/omasnap/omasnap.conf` pour désactiver l'enregistrement automatique ; les captures sont alors uniquement copiées, et affichées dans un aperçu pendant 10 secondes que vous pouvez garder à l'écran avec son bouton d'épingle ou `Ctrl + P`.

Depuis le terminal, `omarchy screenshot` ouvre la même interface, et vous pouvez choisir son mode de départ : `omarchy capture screenshot region`, `windows`, `fullscreen`, ou `scroll`. Un second argument `copy` ou `save` envoie la capture directement vers cette destination. Pour modifier avant la sortie, utilisez `omarchy screenshot --editor=overlay` pour un éditeur plein écran ou `omarchy screenshot --editor=window` pour une fenêtre séparée.

### Piloter le sélecteur au clavier

Pendant que la sélection est affichée, vous n'avez pas du tout besoin d'utiliser la souris :

| Touche | Fonction |
| --- | -------- |
| `S` | Basculer le mode zone défilante |
| `Super + Arrow keys` | Se déplacer parmi les fenêtres en mode Fenêtre |
| `Return` | Capturer la fenêtre mise en surbrillance |
| `Ctrl + A` | Capturer tout le moniteur actif |
| `R` | Restaurer la dernière zone dessinée dans cette session |
| `Esc` | Fermer Omasnap |

Ces raccourcis n'existent que pendant qu'Omasnap est ouvert, ils ne peuvent donc entrer en conflit avec rien dans votre propre configuration.

## Enregistrement d'écran

`Alt + Print Screen` ouvre _Trigger > Capture > Screenrecord_, qui demande ce que vous voulez sur la bande-son : aucun audio, l'audio du bureau, le bureau plus le microphone, ou le bureau plus le microphone plus la webcam. Cette dernière option ne s'affiche que si vous avez réellement une caméra branchée. Choisissez-en une et le sélecteur d'enregistrement d'Omarchy vous permet de faire glisser pour délimiter une zone ou de cliquer sur une fenêtre ou un moniteur.

L'enregistrement repose sur gpu-screen-recorder, qui encode sur le GPU à 60fps et bascule sur le CPU s'il le faut. Le résultat est un MP4 dans `~/Videos`, nommé `screenrecording-2026-08-13_14-22-05.mp4`. Définissez `OMARCHY_SCREENRECORD_DIR` pour changer cela — mais notez que, contrairement au répertoire des captures d'écran, celui-ci doit déjà exister, sinon l'enregistrement refuse de démarrer.

Pendant que vous enregistrez, un petit indicateur s'affiche dans la barre. Cliquez dessus pour arrêter. Vous pouvez aussi arrêter avec `Alt + Print Screen` à nouveau, ou avec l'entrée _Stop Screenrecording_ sous _Trigger > Capture > Screenrecord_, qui n'apparaît que pendant qu'un enregistrement est réellement en cours.

L'arrêt fait un peu de ménage avant de vous remettre le fichier : la première image est supprimée, et s'il y a de l'audio, il est normalisé à -14 LUFS avec le pop de capture PipeWire tout au début coupé. Ensuite, une notification apparaît avec une miniature tirée de l'enregistrement. Cliquez dessus pour lire le fichier dans mpv.

### L'incrustation de la webcam

Lorsque vous enregistrez avec une webcam, la caméra apparaît comme une fenêtre portrait épinglée et recadrée dans le coin inférieur droit de ce que vous enregistrez. Si elle recouvre quelque chose dont vous avez besoin, redimensionnez-la à la volée :

| Raccourci | Fonction |
| ------ | -------- |
| `Super + Alt + [` | Réduire l'incrustation de la webcam |
| `Super + Alt + ]` | Agrandir l'incrustation de la webcam |

Il y a trois tailles — petite, moyenne et grande — et les raccourcis passent de l'une à l'autre. Moyenne est la taille par défaut. Elles sont proportionnelles à l'enregistrement, de sorte que la caméra occupe la même part de l'image que vous enregistriez un moniteur 1080p ou un moniteur 6K. Et si vous avez enregistré une zone plutôt qu'un écran entier, l'incrustation s'ancre au coin de cette zone plutôt qu'à celui du moniteur, de sorte qu'elle reste dans le champ de la capture.

Vous pouvez aussi l'appeler directement avec `omarchy-capture-webcam-resize small`, ou `reset` pour revenir à la taille moyenne.

## Texte, codes QR et couleurs

`Super + Ctrl + Print Screen` sélectionne une zone et en extrait le texte par OCR vers le presse-papiers. C'est traité correctement dans [Extraction de texte et dictée](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ fait la même chose pour les codes QR. Sélectionnez la zone contenant le code, et la valeur décodée va dans le presse-papiers. Il ne cherche que les codes QR — le contenu d'écran dense a sinon tendance à être détecté à tort comme un code-barres. Bon à savoir : la valeur décodée va dans le presse-papiers et nulle part ailleurs. Elle n'est pas affichée, elle n'est pas dans la notification, et elle est marquée comme sensible pour ne pas rester dans [l'historique du presse-papiers](08-unified-clipboard-history.md). Les codes QR transportent régulièrement des secrets — l'URI `otpauth://` derrière un code de configuration 2FA, par exemple — et vous ne voulez pas de cela dans un journal. Le collage fonctionne toujours très bien.

`Super + Print Screen` (ou _Trigger > Capture > Color_) transforme le curseur en pipette. Cliquez sur n'importe quoi à l'écran et la couleur arrive dans le presse-papiers. Appuyez à nouveau sur le raccourci pour abandonner sans rien prélever.

## Transcoder avant de partager

Un enregistrement d'écran 4K ou un HEIC brut sorti de votre téléphone est souvent trop gros pour être simplement envoyé. `Super + Ctrl + .` (ou _Trigger > Transcode_) règle cela. Il vous propose un sélecteur de fichiers flou sur `~/Pictures` et `~/Videos`, puis demande un format et une taille.

Les images vont en jpg ou png en qualité haute, moyenne ou basse, ce qui limite la largeur à 3160, 2160 et 1080 pixels. Les vidéos vont en mp4 ou en gif animé en 4k, 1080p ou 720p. Le fichier converti est écrit à côté de l'original avec la résolution dans le nom — `demo-1080p.mp4` — et le chemin est copié dans le presse-papiers sous forme d'URI de fichier, de sorte que vous pouvez le coller directement dans une application qui accepte les dépôts de fichiers.

Cela fonctionne aussi depuis le terminal, si vous savez déjà ce que vous voulez : `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Il y a aussi `omarchy transcode ascii`, qui transforme une image en art ASCII — celle-là sert surtout pour [l'identité visuelle](41-branding.md).

## L'envoyer quelque part

Une fois que vous avez le fichier, `Super + Ctrl + S` ouvre le menu Share et l'envoie à un autre appareil sur votre réseau via LocalSend. Voir [Interfaces graphiques](22-guis.md) pour cela.
