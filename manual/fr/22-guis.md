# Interfaces graphiques

## Fichiers

Files (Nautilus) est le gestionnaire de fichiers graphique. `Super + Shift + F` l'ouvre, et `Super + Shift + Alt + F` l'ouvre dans le répertoire où se trouve votre terminal, ce qui évite beaucoup de clics. `Ctrl + L` vous permet de saisir un chemin, et appuyer sur `Space` sur n'importe quel fichier vous donne un aperçu rapide sans rien ouvrir.

Branchez une clé USB ou une carte SD et elle est montée automatiquement, elle apparaît donc simplement dans la barre latérale. Pour tout ce qui est plus poussé — formater un disque, vérifier l'état de santé SMART, créer des partitions — lancez _Disks_ depuis le lanceur d'applications (`Super + Space`).

Le double-clic suit des réglages par défaut sensés : les images, les vidéos et la musique s'ouvrent dans Omaview, les PDF dans Document Viewer, le Markdown dans Omawrite, et le texte brut dans l'éditeur choisi sous _Setup > Default > Editor_.

## Disktree

Quand le disque se remplit et que vous n'avez aucune idée de ce qui le dévore, lancez [Disktree](https://github.com/tobi/disktree) depuis le lanceur d'applications (`Super + Space`). Il affiche une treemap graphique de votre répertoire personnel. Plus les blocs sont grands, plus ils prennent de place ; parcourez les répertoires au clavier ou à la souris, marquez ce qui doit partir, et vérifiez vos sélections avant de supprimer quoi que ce soit. Exécutez `disktree --disk` pour analyser le disque entier.

## Obsidian

[Obsidian](https://obsidian.md/) est une application de prise de notes gratuite et très extensible qui utilise de simples fichiers Markdown pour le stockage.

Obsidian est gratuit pour tous les usages, y compris l'usage personnel, commercial et à but non lucratif.

Obsidian propose aussi un [module complémentaire commercial pour la synchronisation](https://obsidian.md/sync) avec les applications mobiles sur iOS et Android. (https://obsidian.md/pricing).

Vous lancez Obsidian avec `Super + Shift + O`. Pour utiliser la synchronisation des thèmes, vous devez sélectionner le thème `Omarchy` dans les paramètres.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) est l'application d'écriture Markdown d'une simplicité enfantine propre à Omarchy. Pas de coffres, pas de plugins, juste vous et les mots.

Vous lancez Omawrite avec `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) est un outil de retouche d'image basique, parfait pour recadrer, redimensionner et d'autres manipulations de base. N'attendez pas pour autant une alternative à Photoshop. Mais il dispose quand même de la Magic Wand et des calques !

Vous lancez Pinta via le lanceur d'applications (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) est une application de thématisation qui peut extraire les couleurs d'une image d'arrière-plan et les transformer en un thème complet et cohérent. C'est le moyen le plus simple de [créer votre propre thème](43-making-your-own-theme.md).

Vous lancez Aether via le lanceur d'applications (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vous permet d'envoyer des fichiers à d'autres appareils sur le même réseau qui exécutent l'application, comme l'AirDrop d'Apple. Il est toutefois multiplateforme, vous pouvez donc envoyer des fichiers vers et depuis Windows, macOS, Android, iOS et, bien sûr, Linux.

Vous pouvez ouvrir le menu Share sur `Super + Ctrl + S` ou sous _Trigger > Share_ dans le menu Omarchy. Il vous propose quatre options :

- **Clipboard** envoie tout ce que vous avez copié sous forme de fichier texte. Parfait pour envoyer un lien ou un extrait sur votre téléphone sans vous envoyer un e-mail à vous-même.
- **File** ouvre un sélecteur de fichiers où vous pouvez en sélectionner plusieurs à la fois.
- **Folder** envoie un répertoire entier.
- **Receive** ouvre LocalSend proprement dit pour qu'un autre appareil puisse vous envoyer quelque chose.

La même chose fonctionne depuis le terminal avec `omarchy share clipboard`, `omarchy share file [path]` et `omarchy share folder [path]`. Omettez le chemin et vous obtenez le sélecteur.

Vous pouvez aussi envoyer directement depuis le gestionnaire de fichiers : faites un clic droit sur n'importe quelle sélection dans Nautilus et choisissez _Send via LocalSend_.

Le pare-feu d'Omarchy est fermé par défaut, sauf pour le port de LocalSend, donc cela fonctionne dès l'installation, sur un système fraîchement installé. Voir [sécurité](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) est une suite bureautique complète avec traitement de texte, tableur, présentations, application de dessin, et plus encore. Elle est compatible avec les fichiers de Microsoft Office, c'est donc un excellent moyen de pouvoir ouvrir ces documents Word.

Vous lancez LibreOffice via le lanceur d'applications (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) est l'application de présentation d'une simplicité enfantine propre à Omarchy. Votre présentation est un seul fichier Markdown, avec ses images et vidéos à côté : écrivez chaque diapositive sous un aperçu en temps réel, faites glisser les diapositives pour les mettre dans l'ordre, puis présentez en plein écran ou exportez en PDF et PowerPoint. Elle reprend même votre thème Omarchy.

Vous lancez Hype via le lanceur d'applications (`Super + Space`). Appuyez sur `?` à l'intérieur pour voir tous les raccourcis.

## Signed

[Signed](https://github.com/omacom/signed) est le moyen d'une simplicité enfantine propre à Omarchy pour signer des PDF et les remplir. Placez votre signature enregistrée, du texte et la date du jour où vous voulez sur une page, puis enregistrez une copie signée à côté de l'original. Voir [Remplir des PDF](27-filling-out-pdfs.md) pour savoir comment faire.

Vous lancez Signed via le lanceur d'applications (`Super + Space`), ou ouvrez un PDF avec lui depuis le gestionnaire de fichiers.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) est la calculatrice d'une simplicité enfantine propre à Omarchy, qui s'ouvre dans une fenêtre flottante.

Vous lancez Omacalc avec `Super + Shift + Q` (ou la touche calculatrice, si votre clavier en possède une).

## Signal

[Signal](https://signal.org/) est le pionnier de la messagerie chiffrée E2E, et une excellente option de communication pour quiconque préfère ne pas passer par l'un des grands conglomérats de la tech.

Vous lancez Signal avec `Super + Shift + G`. Il ne fait pas partie de l'installation de base, donc la première fois que vous appuierez sur ces touches, Omarchy vous proposera de l'installer pour vous (il se trouve aussi sous _Install > Service_ dans le menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) est le visionneur d'images et lecteur multimédia d'une simplicité enfantine propre à Omarchy : une seule fenêtre pour vos photos, vos vidéos et votre musique. Ouvrez une photo et les touches fléchées font défiler le reste de son dossier, `N` et `P` le font pour n'importe quel contenu, et `Ctrl + M` affiche l'ensemble du dossier sous forme de grille. Il affiche aussi les photos HEIC, AVIF et JPEG XL, et reprend là où vous vous étiez arrêté dans tout contenu long.

Appuyez sur `F` pour le plein écran, `E` pour modifier une image dans Omasnap ou rogner une vidéo dans Omacut, `Ctrl + P` pour imprimer une image, et `Delete` pour déplacer un fichier vers la Corbeille (`Ctrl + Z` le ramènera). Appuyez sur `?` à l'intérieur pour voir tous les raccourcis.

Vous lancez Omaview sous le nom de _Media Viewer_ via le lanceur d'applications (`Super + Space`), ou double-cliquez simplement sur une image, une vidéo ou un morceau dans le gestionnaire de fichiers.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) est l'outil de rognage vidéo d'une simplicité enfantine propre à Omarchy. Quand tout ce dont vous avez besoin, c'est de couper le début et la fin d'un clip, c'est bien mieux que de lancer un éditeur vidéo complet.

Vous lancez Omacut via le lanceur d'applications (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) est l'enregistreur webcam d'une simplicité enfantine propre à Omarchy. Choisissez votre caméra et votre microphone une fois, puis appuyez sur `Space` pour enregistrer, et à nouveau pour mettre en pause et reprendre la même prise. Il enregistre toujours à la résolution la plus élevée de votre caméra, avec un vumètre de microphone en temps réel pour que vous puissiez vérifier vos niveaux avant de commencer.

Arrêtez la prise et elle s'ouvre immédiatement dans un éditeur intégré. Double-cliquez sur un clip pour le diviser, faites glisser les poignées pour rogner chaque morceau, et supprimez les parties dont vous ne voulez pas. Enregistrez-le ensuite au format MP4. Votre enregistrement original est conservé jusqu'à ce que vous le jetiez, vous pouvez donc toujours y revenir et le monter différemment.

Vous lancez Monologue via le lanceur d'applications (`Super + Space`).
