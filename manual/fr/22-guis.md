# GUIs

## Files

Files (Nautilus) est le gestionnaire de fichiers graphique. `Super + Shift + F` l'ouvre, et `Super + Shift + Alt + F` l'ouvre dans le répertoire où se trouve ton terminal, ce qui t'évite pas mal de clics. `Ctrl + L` te permet de saisir un chemin, et appuyer sur `Space` sur n'importe quel fichier t'en donne un aperçu rapide sans rien ouvrir.

Branche une clé USB ou une carte SD et elle est montée automatiquement, donc elle apparaît simplement dans la barre latérale. Pour tout ce qui est plus poussé — formater un disque, vérifier l'état de santé SMART, créer des partitions — lance _Disks_ depuis le lanceur d'applications (`Super + Space`).

Le double-clic suit des réglages par défaut sensés : les images, les vidéos et la musique s'ouvrent dans Omaview, les PDF dans Document Viewer, le Markdown dans Omawrite, et le texte brut dans l'éditeur choisi sous _Setup > Default > Editor_.

## Disktree

Quand le disque se remplit et que tu n'as aucune idée de ce qui le dévore, lance [Disktree](https://github.com/tobi/disktree) depuis le lanceur d'applications (`Super + Space`). Il affiche une carte arborescente graphique de ton répertoire personnel. Les blocs les plus grands occupent plus d'espace ; navigue dans les répertoires au clavier ou à la souris, marque ce qui doit disparaître, et vérifie tes sélections avant de supprimer quoi que ce soit. Exécute `disktree --disk` pour analyser le disque entier.

## Obsidian

[Obsidian](https://obsidian.md/) est une application de prise de notes gratuite et hautement extensible qui utilise de simples fichiers Markdown pour le stockage.

Obsidian est gratuit pour tous les usages, y compris l'usage personnel, commercial et à but non lucratif.

Obsidian propose aussi un [module complémentaire commercial pour la synchronisation](https://obsidian.md/sync) avec les applications mobiles sur iOS et Android. (https://obsidian.md/pricing).

Tu lances Obsidian avec `Super + Shift + O`. Pour utiliser la synchronisation du thème, tu dois sélectionner le thème `Omarchy` dans les paramètres.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) est l'application d'écriture Markdown ultra simple, maison, d'Omarchy. Pas de coffres, pas de plugins, juste toi et les mots.

Tu lances Omawrite avec `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) est un outil d'édition d'images basique qui est parfait pour recadrer, redimensionner et autres manipulations de base. N'attends juste pas une alternative à Photoshop. Mais il a quand même une baguette magique et des calques !

Tu lances Pinta via le lanceur d'applications (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) est une application de thématisation qui peut extraire les couleurs d'une image d'arrière-plan et les transformer en un thème complet et cohérent. C'est le moyen le plus simple de [créer ton propre thème](43-making-your-own-theme.md).

Tu lances Aether via le lanceur d'applications (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) te permet d'envoyer des fichiers vers d'autres appareils sur le même réseau qui exécutent l'application, comme AirDrop d'Apple. Il est multiplateforme, par contre, donc tu peux envoyer des fichiers vers et depuis Windows, macOS, Android, iOS et, bien sûr, Linux.

Tu peux ouvrir le menu Share sur `Super + Ctrl + S` ou sous _Trigger > Share_ dans le menu Omarchy. Il te propose quatre options :

- **Clipboard** envoie tout ce que tu as copié sous forme de fichier texte. Parfait pour mettre un lien ou un extrait sur ton téléphone sans t'envoyer un e-mail à toi-même.
- **File** ouvre un sélecteur de fichiers où tu peux en sélectionner plusieurs à la fois.
- **Folder** envoie un répertoire entier.
- **Receive** ouvre LocalSend à proprement parler pour qu'un autre appareil puisse t'envoyer quelque chose.

La même chose fonctionne depuis le terminal avec `omarchy share clipboard`, `omarchy share file [path]` et `omarchy share folder [path]`. Omets le chemin et tu obtiens le sélecteur.

Tu peux aussi envoyer directement depuis le gestionnaire de fichiers : clique droit sur n'importe quelle sélection dans Nautilus et choisis _Send via LocalSend_.

Le pare-feu d'Omarchy est fermé par défaut, sauf pour le port de LocalSend, donc ça fonctionne dès l'installation, sans rien configurer. Voir [sécurité](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) est une suite bureautique complète avec traitement de texte, tableur, présentations, application de dessin, et plus encore. Elle est compatible avec les fichiers de Microsoft Office, donc c'est un excellent moyen de pouvoir ouvrir ces documents Word.

Tu lances LibreOffice via le lanceur d'applications (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) est l'application de présentation ultra simple, maison, d'Omarchy. Ta présentation est un unique fichier Markdown avec ses images et vidéos à côté de lui : écris chaque diapositive sous un aperçu en direct, fais glisser les diapositives pour les réordonner, puis présente en plein écran ou exporte en PDF et PowerPoint. Elle récupère même ton thème Omarchy.

Tu lances Hype via le lanceur d'applications (`Super + Space`). Appuie sur `?` à l'intérieur pour voir tous les raccourcis.

## Signed

[Signed](https://github.com/omacom/signed) est le moyen ultra simple, maison, d'Omarchy pour signer des PDF et les remplir. Place ta signature enregistrée, du texte et la date du jour n'importe où sur une page, puis enregistre une copie signée à côté de l'original. Voir [Remplir des PDF](27-filling-out-pdfs.md) pour savoir comment faire.

Tu lances Signed via le lanceur d'applications (`Super + Space`), ou ouvre un PDF avec lui depuis le gestionnaire de fichiers.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) est le jeu d'échecs 3D maison d'Omarchy. Joue contre un ami sur le même ordinateur ou contre l'adversaire intégré à trois niveaux, sur quatre jeux sculptés qui se déplacent chacun à leur manière : vaisseaux orbitaux, bois sculpté et ivoire, créatures des bois, et bonbons. Les parties n'ont pas d'horloge et sont sauvegardées après chaque coup.

Tu lances Checkmate via le lanceur d'applications (`Super + Space`), où il est répertorié sous le nom de Chess. Appuie sur `?` à l'intérieur pour voir tous les raccourcis.

## Cards

[Cards](https://github.com/omacom/cards) est le solitaire Klondike maison d'Omarchy. Tire trois cartes, sans limite de passages, dans quatre séries de cartes : une dessinée aux couleurs de ton thème, et trois avec un style propre. Clique sur une carte puis sur l'endroit où elle va, fais-la glisser, ou double-clique pour l'envoyer au meilleur endroit. Les parties sont sauvegardées après chaque coup.

Tu lances Cards via le lanceur d'applications (`Super + Space`). Clique sur son nom, ou appuie sur `?`, pour voir tous les raccourcis.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) est la calculatrice ultra simple, maison, d'Omarchy, qui s'ouvre dans une fenêtre flottante.

Tu lances Omacalc avec `Super + Shift + Q` (ou la touche calculatrice, si ton clavier en a une).

## Signal

[Signal](https://signal.org/) est le pionnier de la messagerie chiffrée E2E, et une excellente option de communication pour quiconque préfère ne pas passer par l'un des grands conglomérats de la tech.

Tu lances Signal avec `Super + Shift + G`. Il ne fait pas partie de l'installation de base, donc la première fois que tu appuies là-dessus, Omarchy te proposera de l'installer pour toi (il se trouve aussi sous _Install > Service_ dans le menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) est le visionneur d'images et lecteur multimédia ultra simple, maison, d'Omarchy : une seule fenêtre pour tes photos, vidéos et ta musique. Ouvre une photo et les touches fléchées font défiler le reste de son dossier, `N` et `P` le font pour n'importe quel contenu, et `Ctrl + M` affiche tout le dossier sous forme de grille. Il affiche aussi les photos HEIC, AVIF et JPEG XL, et reprend là où tu t'étais arrêté dans tout ce qui est long.

Appuie sur `F` pour le plein écran, `E` pour modifier une image dans Omasnap ou rogner une vidéo dans Omacut, `Ctrl + P` pour imprimer une image, et `Delete` pour déplacer un fichier vers la Corbeille (`Ctrl + Z` le ramène). Appuie sur `?` à l'intérieur pour voir tous les raccourcis.

Tu lances Omaview sous le nom de _Media Viewer_ via le lanceur d'applications (`Super + Space`), ou double-clique simplement sur une image, une vidéo ou une chanson dans le gestionnaire de fichiers.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) est l'outil de rognage vidéo ultra simple, maison, d'Omarchy. Quand tout ce dont tu as besoin, c'est de couper le début et la fin d'un clip, ça vaut mieux que de lancer un éditeur vidéo complet.

Tu lances Omacut via le lanceur d'applications (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) est l'enregistreur webcam ultra simple, maison, d'Omarchy. Choisis ta caméra et ton microphone une fois, puis appuie sur `Space` pour enregistrer, et à nouveau pour mettre en pause et reprendre la même prise. Il enregistre toujours à la résolution la plus élevée de ta caméra, avec un indicateur de niveau du microphone en direct pour que tu puisses vérifier tes niveaux avant de commencer.

Arrête la prise et elle s'ouvre immédiatement dans un éditeur intégré. Double-clique sur un clip pour le diviser, fais glisser les poignées pour rogner chaque morceau, et supprime les parties dont tu ne veux pas. Puis enregistre-le au format MP4. Ton enregistrement original est conservé jusqu'à ce que tu le jettes, donc tu peux toujours revenir et le découper différemment.

Tu lances Monologue via le lanceur d'applications (`Super + Space`).
