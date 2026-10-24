# Captures d'écran et enregistrement

Tout ce que vous pouvez récupérer de l'écran dépend de la touche Print Screen. Une touche seule prend une image, et les modificateurs prennent un enregistrement, une couleur, ou le texte à l'intérieur d'une région. Si votre clavier n'a pas du tout de touche Print Screen, `Super + Ctrl + C` ouvre le même ensemble sous forme de menu.

| Raccourci | Fonction |
| ------ | -------- |
| `Print Screen` | Capture d'écran |
| `Alt + Print Screen` | Enregistrement d'écran (ou arrêter celui en cours) |
| `Super + Print Screen` | Sélecteur de couleur |
| `Super + Ctrl + Print Screen` | Extraire le texte d'une région |
| `Super + Ctrl + C` | Menu de capture |
| `Super + Ctrl + .` | Transcoder une image ou une vidéo |

## Captures d'écran

Appuyez sur `Print Screen` et Omasnap capture l'écran actif avant que son overlay n'apparaisse, de sorte que rien ne bouge sous vous pendant que vous visez. Faites glisser une région libre, cliquez sur une fenêtre pour la capturer, ou cliquez sur un espace libre pour capturer tout l'écran. Appuyez sur `S` avant de dessiner pour capturer une région défilante. Vous avez changé d'avis ? Réappuyez sur `Print Screen` pour fermer Omasnap.

Après avoir sélectionné une zone, Omasnap enregistre la capture, la copie dans le presse-papiers et affiche un aperçu pendant 10 secondes. Utilisez le bouton épingle de l'aperçu ou `Ctrl + P` pour le garder à l'écran, ou choisissez Modifier pour l'annoter.

L'éditeur d'annotation peut dessiner des flèches, des lignes, des formes, des surbrillances, des marqueurs numérotés, du texte et des masquages sécurisés ; recadrer ou découper une partie de l'image ; OCR son texte ; et ajouter un fond. Dans l'éditeur, appuyez sur `Enter` pour copier et enregistrer le PNG terminé, `Ctrl + C` pour le copier sans l'enregistrer, ou `Ctrl + S` pour l'enregistrer sans le copier.

Les captures enregistrées atterrissent par défaut dans `~/Pictures/Screenshots`, avec un nom tel que `screenshot-2026-08-13_14-22-05-firefox.png`. Définissez `OMASNAP_SCREENSHOT_DIR` pour utiliser un autre répertoire — voir [la FAQ](46-faq.md) pour savoir où placer les variables d'environnement de session. Omasnap crée le répertoire lorsqu'il enregistre la première capture. Définissez `[output] autosave = false` dans `~/.config/omasnap/omasnap.conf` pour désactiver l'enregistrement automatique.

Depuis le terminal, `omarchy screenshot` ouvre le même overlay, et vous pouvez choisir son mode de départ : `omarchy capture screenshot region`, `windows`, `fullscreen` ou `scroll`. Un deuxième argument `copy` ou `save` saute l'aperçu et envoie la capture directement à cette destination. Pour éditer avant la sortie, utilisez `omarchy screenshot --editor=overlay` pour un éditeur plein écran ou `omarchy screenshot --editor=window` pour une fenêtre séparée.

### Piloter le sélecteur au clavier

Pendant que la sélection est affichée, vous n'avez pas du tout à utiliser la souris :

| Touche | Fonction |
| --- | -------- |
| `S` | Basculer le mode région défilante |
| `Super + Arrow keys` | Se déplacer entre les fenêtres en mode Fenêtre |
| `Return` | Capturer la fenêtre surlignée |
| `Ctrl + A` | Capturer tout l'écran actif |
| `R` | Restaurer la dernière région dessinée dans cette session |
| `Esc` | Fermer Omasnap |

Ces raccourcis n'existent que pendant qu'Omasnap est ouvert, donc ils ne peuvent entrer en conflit avec rien dans votre propre configuration.

## Enregistrement d'écran

`Alt + Print Screen` ouvre _Déclencher > Capture > Enregistrement d'écran_, qui demande ce que vous voulez sur la bande-son : pas d'audio, audio du bureau, bureau plus microphone, ou bureau plus microphone plus webcam. Ce dernier n'apparaît que si vous avez réellement une caméra branchée. Choisissez-en un et le sélecteur d'enregistrement d'Omarchy vous laisse faire glisser une région ou cliquer sur une fenêtre ou un écran.

L'enregistrement tourne sur gpu-screen-recorder, qui encode sur le GPU à 60 ips et revient au CPU si nécessaire. Le résultat est un MP4 dans `~/Videos`, nommé `screenrecording-2026-08-13_14-22-05.mp4`. Définissez `OMARCHY_SCREENRECORD_DIR` pour changer cela — mais notez que, contrairement au répertoire des captures d'écran, celui-ci doit déjà exister, sinon l'enregistrement refuse de démarrer.

Pendant que vous enregistrez, un petit indicateur apparaît dans la barre. Cliquez dessus pour arrêter. Vous pouvez aussi arrêter en refaisant `Alt + Print Screen`, ou avec l'entrée _Arrêter l'enregistrement_ sous _Déclencher > Capture > Enregistrement d'écran_, qui n'apparaît que pendant qu'un enregistrement est réellement en cours.

L'arrêt fait un peu de ménage avant de vous remettre le fichier : la première image est rognée, et s'il y a de l'audio, il est normalisé à -14 LUFS avec le pop de capture PipeWire du tout début rendu muet. Ensuite, une notification apparaît avec une vignette de l'enregistrement. Cliquez dessus pour lire le fichier dans mpv.

### L'overlay webcam

Lorsque vous enregistrez avec une webcam, la caméra apparaît comme une fenêtre portrait épinglée et recadrée dans le coin inférieur droit de ce que vous enregistrez. Si elle est par-dessus quelque chose dont vous avez besoin, redimensionnez-la à la volée :

| Raccourci | Fonction |
| ------ | -------- |
| `Super + Alt + [` | Réduire l'overlay webcam |
| `Super + Alt + ]` | Agrandir l'overlay webcam |

Il existe trois tailles — petite, moyenne et grande — et les raccourcis passent de l'une à l'autre. Moyenne est la valeur par défaut. Elles sont proportionnelles à l'enregistrement, de sorte que la caméra occupe la même part de l'image que vous enregistriez un écran 1080p ou 6K. Et si vous avez enregistré une région plutôt qu'un écran entier, l'overlay s'ancre au coin de cette région plutôt qu'à celui de l'écran, de sorte qu'il reste dans le champ.

Vous pouvez aussi l'appeler directement avec `omarchy-capture-webcam-resize small`, ou `reset` pour revenir à moyen.

## Texte, codes QR et couleurs

`Super + Ctrl + Print Screen` sélectionne une région et l'OCR vers le presse-papiers. C'est couvert correctement dans [Extraction de texte et dictée](11-text-extraction-dictation.md).

_Déclencher > Capture > Code QR_ fait le même tour pour les codes QR. Sélectionnez la région contenant le code, et la valeur décodée va dans le presse-papiers. Il ne cherche que les codes QR — un contenu d'écran dense a sinon l'habitude de produire des faux positifs comme code-barres. À savoir : la valeur décodée va dans le presse-papiers et nulle part ailleurs. Elle n'est pas affichée, elle n'est pas dans la notification, et elle est marquée sensible pour ne pas persister dans [l'historique du presse-papiers](08-unified-clipboard-history.md). Les codes QR transportent régulièrement des secrets — l'URI `otpauth://` derrière un code de configuration 2FA, par exemple — et vous ne voulez pas cela dans un journal. Le collage fonctionne toujours très bien.

`Super + Print Screen` (ou _Déclencher > Capture > Couleur_) transforme le curseur en pipette. Cliquez sur n'importe quoi à l'écran et la couleur atterrit dans le presse-papiers. Réappuyez sur le raccourci pour reculer sans choisir.

## Transcoder avant de partager

Un enregistrement d'écran 4K ou un HEIC brut de votre téléphone est souvent trop gros pour être simplement envoyé. `Super + Ctrl + .` (ou _Déclencher > Transcoder_) corrige cela. Il vous offre un sélecteur de fichiers flou sur `~/Pictures` et `~/Videos`, puis demande un format et une taille.

Les images vont en jpg ou png à élevée, moyenne ou basse, qui plafonnent la largeur à 3160, 2160 et 1080 pixels. Les vidéos vont en mp4 ou en gif animé à 4k, 1080p ou 720p. Le fichier converti est écrit à côté de l'original avec la résolution dans le nom — `demo-1080p.mp4` — et le chemin est copié dans le presse-papiers comme URI de fichier, de sorte que vous pouvez le coller directement dans une appli qui accepte les dépôts de fichiers.

Cela fonctionne aussi depuis le terminal, si vous savez déjà ce que vous voulez : `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Il y a aussi `omarchy transcode ascii`, qui transforme une image en art ASCII — celui-là est surtout pour le [branding](41-branding.md).

## L'envoyer quelque part

Une fois que vous avez le fichier, `Super + Ctrl + S` ouvre le menu Partager et l'envoie à un autre appareil de votre réseau via LocalSend. Voir [interfaces graphiques](22-guis.md) pour cela.
