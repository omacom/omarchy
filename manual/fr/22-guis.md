# GUIs

## Files

Files (Nautilus) est le gestionnaire de fichiers graphique. `Super + Shift + F` l'ouvre, et `Super + Shift + Alt + F` l'ouvre dans le dossier où se trouve votre terminal, ce qui vous épargne beaucoup de clics. `Ctrl + L` vous permet de saisir un chemin, et appuyer sur `Space` sur n'importe quel fichier vous donne un aperçu rapide sans rien ouvrir.

Branchez une clé USB ou une carte SD et elle est montée automatiquement, donc elle apparaît simplement dans la barre latérale. Pour tout ce qui est plus avancé — formater un disque, vérifier l'état SMART, créer des partitions — lancez _Disks_ depuis le lanceur d'applications (`Super + Space`).

Le double-clic suit des valeurs par défaut sensées : les images, les vidéos et la musique s'ouvrent dans Omaview, les PDF dans Document Viewer, le Markdown dans Omawrite, et le texte brut dans l'éditeur choisi sous _Setup > Default > Editor_.

## Disktree

Quand le disque se remplit et que vous n'avez aucune idée de ce qui le dévore, lancez [Disktree](https://github.com/tobi/disktree) depuis le lanceur d'applications (`Super + Space`). Il affiche une carte proportionnelle graphique de votre dossier personnel. Plus les blocs sont grands, plus ils occupent d'espace ; parcourez les dossiers au clavier ou à la souris, marquez ce qui doit disparaître, et vérifiez vos sélections avant de supprimer quoi que ce soit. Exécutez `disktree --disk` pour analyser le disque entier.

## Obsidian

[Obsidian](https://obsidian.md/) est une application de prise de notes gratuite et très extensible qui utilise de simples fichiers Markdown pour le stockage.

Obsidian est gratuit pour tous les usages, y compris l'usage personnel, commercial et à but non lucratif.

Obsidian propose également un [module complémentaire commercial pour la synchronisation](https://obsidian.md/sync) avec les applications mobiles sur iOS et Android. (https://obsidian.md/pricing).

Vous lancez Obsidian avec `Super + Shift + O`. Pour utiliser la synchronisation des thèmes, vous devez sélectionner le thème `Omarchy` dans les paramètres.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) est l'application d'écriture Markdown ultra-simple d'Omarchy. Pas de coffres, pas de plugins, juste vous et les mots.

Vous lancez Omawrite avec `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) est un outil d'édition d'images basique qui est parfait pour recadrer, redimensionner et autres manipulations de base. N'attendez simplement pas une alternative à Photoshop. Mais il a quand même la Baguette magique et les calques !

Vous lancez Pinta via le lanceur d'applications (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) est une application de création de thèmes qui peut extraire les couleurs d'une image d'arrière-plan et les transformer en un thème complet et cohérent. C'est le moyen le plus simple de [créer votre propre thème](43-making-your-own-theme.md).

Vous lancez Aether via le lanceur d'applications (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vous permet d'envoyer des fichiers vers d'autres appareils sur le même réseau qui exécutent l'application, comme AirDrop d'Apple. Il est toutefois multiplateforme, donc vous pouvez envoyer des fichiers vers et depuis Windows, macOS, Android, iOS et, bien sûr, Linux.

Vous pouvez ouvrir le menu Share avec `Super + Ctrl + S` ou sous _Trigger > Share_ dans le menu Omarchy. Il vous propose quatre options :

- **Clipboard** envoie tout ce que vous avez copié sous forme de fichier texte. Parfait pour mettre un lien ou un extrait sur votre téléphone sans vous envoyer un e-mail à vous-même.
- **File** ouvre un sélecteur de fichiers où vous pouvez en sélectionner plusieurs à la fois.
- **Folder** envoie un dossier entier.
- **Receive** ouvre LocalSend à proprement parler pour qu'un autre appareil puisse vous envoyer quelque chose.

La même chose fonctionne depuis le terminal avec `omarchy share clipboard`, `omarchy share file [path]`, et `omarchy share folder [path]`. Laissez le chemin de côté et vous obtenez le sélecteur.

Vous pouvez également envoyer directement depuis le gestionnaire de fichiers : faites un clic droit sur n'importe quelle sélection dans Nautilus et choisissez _Send via LocalSend_.

Le pare-feu d'Omarchy est fermé par défaut, sauf pour le port de LocalSend, donc cela fonctionne dès l'installation. Voir [sécurité](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) est une suite bureautique complète avec traitement de texte, tableur, présentations, application de dessin, et bien plus. Elle est compatible avec les fichiers de Microsoft Office, donc c'est un excellent moyen de pouvoir ouvrir ces documents Word.

Vous lancez LibreOffice via le lanceur d'applications (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) est l'application de présentation ultra-simple d'Omarchy. Votre présentation est un seul fichier Markdown avec ses images et vidéos à côté : écrivez chaque diapositive sous un aperçu en direct, faites glisser les diapositives pour les réordonner, puis présentez en plein écran ou exportez en PDF et PowerPoint. Elle récupère même votre thème Omarchy.

Vous lancez Hype via le lanceur d'applications (`Super + Space`). Appuyez sur `?` à l'intérieur pour voir tous les raccourcis.

## Signed

[Signed](https://github.com/omacom/signed) est le moyen ultra-simple d'Omarchy pour signer des PDF et les remplir. Placez votre signature enregistrée, du texte et la date du jour où vous voulez sur une page, puis enregistrez une copie signée à côté de l'original. Voir [Remplir des PDF](27-filling-out-pdfs.md) pour savoir comment faire.

Vous lancez Signed via le lanceur d'applications (`Super + Space`), ou ouvrez un PDF avec Signed depuis le gestionnaire de fichiers.

## Game Vibes

Game Vibes, dans le lanceur d'applications (`Super + Space`), est l'endroit où vivent les petits jeux d'Omarchy : Checkmate, un jeu d'échecs 3D contre un ami ou l'adversaire intégré ; Cards, un solitaire Klondike ; et Neon Swarm, un jeu de tir arcade. Chacun est une seule page web qui suit votre thème. Choisissez-en un avec les flèches et `Enter`, et revenez à la liste avec `Esc` depuis l'écran titre d'un jeu ou `Q` pendant qu'il est en pause. Il s'ouvre en plein écran : `Super + F` en fait une fenêtre, et `Super + W` le ferme.

Les jeux que vous créez avec un agent apparaissent ici aussi : choisissez _Make something cool → Game_ dans le panneau des agents et décrivez-en un, ou nommez un jeu déjà présent dans Game Vibes pour continuer à travailler dessus. L'agent le copie dans `~/Games/vibes`, où il vous appartient et vous pouvez le modifier, et l'ouvre quand il a terminé. Vous pouvez faire cette copie vous-même avec `omarchy games vibes copy <game>`. Un jeu partagé par quelqu'un d'autre s'installe comme un thème : choisissez _Install > Gaming > Game Vibes_ et collez son adresse git, ou exécutez `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ en retire un, et _Update > Game Vibes Games_ récupère les nouvelles versions. Les jeux chargent three.js depuis le web, donc ils ont besoin d'une connexion pour démarrer.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) est la calculatrice ultra-simple d'Omarchy, qui s'ouvre dans une fenêtre flottante.

Vous lancez Omacalc avec `Super + Shift + Q` (ou la touche calculatrice, si votre clavier en possède une).

## Signal

[Signal](https://signal.org/) est le pionnier de la messagerie chiffrée E2E, et une excellente option de communication pour quiconque préfère ne pas passer par l'un des grands conglomérats technologiques.

Vous lancez Signal avec `Super + Shift + G`. Il ne fait pas partie de l'installation de base, donc la première fois que vous appuierez dessus, Omarchy vous proposera de l'installer pour vous (il se trouve également sous _Install > Service_ dans le menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) est le visionneur d'images et lecteur multimédia ultra-simple d'Omarchy : une seule fenêtre pour vos photos, vidéos et musiques. Ouvrez une photo et les touches fléchées parcourent le reste de son dossier, `N` et `P` le font pour n'importe quoi, et `Ctrl + M` affiche tout le dossier sous forme de grille. Il affiche également les photos HEIC, AVIF et JPEG XL, et reprend où vous vous étiez arrêté dans tout ce qui est long.

Appuyez sur `F` pour le plein écran, `E` pour modifier une image dans Omasnap ou rogner une vidéo dans Omacut, `Ctrl + P` pour imprimer une image, et `Delete` pour déplacer un fichier vers la Corbeille (`Ctrl + Z` le ramène). Appuyez sur `?` à l'intérieur pour voir tous les raccourcis.

Vous lancez Omaview sous le nom _Media Viewer_ via le lanceur d'applications (`Super + Space`), ou double-cliquez simplement sur une image, une vidéo ou une chanson dans le gestionnaire de fichiers.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) est l'outil de rognage vidéo ultra-simple d'Omarchy. Quand tout ce dont vous avez besoin, c'est de couper le début et la fin d'un clip, ça bat le fait de lancer un éditeur vidéo complet.

Vous lancez Omacut via le lanceur d'applications (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) est l'enregistreur de webcam ultra-simple d'Omarchy. Choisissez votre caméra et votre microphone une fois, puis appuyez sur `Space` pour enregistrer, et à nouveau pour mettre en pause et reprendre la même prise. Il enregistre toujours à la résolution la plus élevée de votre caméra, avec un indicateur de niveau du microphone en direct pour que vous puissiez vérifier vos niveaux avant de commencer.

Arrêtez la prise et elle s'ouvre immédiatement dans un éditeur intégré. Double-cliquez sur un clip pour le diviser, faites glisser les poignées pour rogner chaque morceau, et supprimez les parties dont vous ne voulez pas. Puis enregistrez-le au format MP4. Votre enregistrement original est conservé jusqu'à ce que vous le jetiez, donc vous pouvez toujours revenir et le découper différemment.

Vous lancez Monologue via le lanceur d'applications (`Super + Space`).
