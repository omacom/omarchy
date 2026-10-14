# GUI

## Fichiers

Fichiers (Nautilus) est le gestionnaire de fichiers graphique. `Super + Shift + F` l'ouvre, et `Super + Shift + Alt + F` l'ouvre dans le répertoire où se trouve votre terminal, ce qui évite beaucoup de clics. `Ctrl + L` vous permet de taper un chemin, et appuyer sur `Space` sur n'importe quel fichier vous donne un aperçu rapide sans rien ouvrir.

Branchez une clé USB ou une carte SD et elle est montée automatiquement, elle apparaît donc simplement dans la barre latérale. Pour tout ce qui est plus poussé — formater un lecteur, vérifier l'état de santé SMART, créer des partitions — lancez _Disks_ depuis le lanceur d'applis (`Super + Space`).

Le double-clic suit des valeurs par défaut sensées : les images s'ouvrent dans imv, les vidéos dans mpv, les PDF dans Document Viewer, et le texte brut dans Neovim.

## Disktree

Quand le lecteur se remplit et que vous n'avez aucune idée de ce qui le dévore, lancez [Disktree](https://github.com/tobi/disktree) depuis le lanceur d'applis (`Super + Space`). Il affiche une treemap graphique de votre répertoire personnel. Les blocs les plus gros occupent plus d'espace ; naviguez dans les répertoires au clavier ou à la souris, marquez ce qui doit partir, et vérifiez vos sélections avant de supprimer quoi que ce soit. Lancez `disktree --disk` pour analyser l'ensemble du disque.

## Obsidian

[Obsidian](https://obsidian.md/) est une application de prise de notes gratuite et hautement extensible qui utilise de simples fichiers Markdown pour le stockage.

Obsidian est gratuit pour tous les usages, y compris personnels, commerciaux et à but non lucratif.

Obsidian propose aussi un [module complémentaire commercial pour la synchronisation](https://obsidian.md/sync) avec des applis mobiles sur iOS et Android. (https://obsidian.md/pricing).

Vous démarrez Obsidian avec `Super + Shift + O`. Pour utiliser la synchronisation de thème, vous devez sélectionner le thème `Omarchy` dans les paramètres.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) est l'appli d'écriture Markdown ultra-simple d'Omarchy. Ni coffres, ni plugins, juste vous et les mots.

Vous démarrez Omawrite avec `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) est un outil d'édition d'images basique, parfait pour recadrer, redimensionner et faire d'autres manipulations de base. N'attendez juste pas une alternative à Photoshop. Mais il a quand même une Baguette magique et des calques !

Vous démarrez Pinta via le lanceur d'applications (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) est une application de thème qui peut extraire des couleurs d'une image d'arrière-plan et les transformer en un thème complet et cohérent. C'est la façon la plus simple de [créer votre propre thème](43-making-your-own-theme.md).

Vous démarrez Aether via le lanceur d'applications (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) vous permet d'envoyer des fichiers vers d'autres appareils sur le même réseau qui exécutent l'appli, comme AirDrop d'Apple. C'est multiplateforme, par contre, donc vous pouvez envoyer des fichiers vers et depuis Windows, macOS, Android, iOS et bien sûr Linux.

Vous pouvez ouvrir le menu Partager avec `Super + Ctrl + S` ou sous _Déclencher > Partager_ dans le menu Omarchy. Il vous donne quatre options :

- **Presse-papiers** envoie ce que vous avez copié sous forme de fichier texte. Parfait pour mettre un lien ou un extrait sur votre téléphone sans vous envoyer un e-mail.
- **Fichier** ouvre un sélecteur de fichiers où vous pouvez en sélectionner plusieurs à la fois.
- **Dossier** envoie un répertoire entier.
- **Recevoir** ouvre LocalSend proprement dit pour qu'un autre appareil puisse vous envoyer quelque chose.

La même chose fonctionne depuis le terminal avec `omarchy share clipboard`, `omarchy share file [path]` et `omarchy share folder [path]`. Omettez le chemin et vous obtenez le sélecteur.

Vous pouvez aussi envoyer directement depuis le gestionnaire de fichiers : faites un clic droit sur n'importe quelle sélection dans Nautilus et choisissez _Send via LocalSend_.

Le pare-feu d'Omarchy est fermé par défaut sauf pour le port de LocalSend, donc cela fonctionne dès l'installation sur un système neuf. Voir [sécurité](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) est une suite bureautique complète avec traitement de texte, tableur, présentations, application de dessin, et plus encore. Il est compatible avec les fichiers de Microsoft Office, donc c'est un excellent moyen de pouvoir ouvrir ces documents Word.

Vous démarrez LibreOffice via le lanceur d'applications (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) est l'appli de présentation ultra-simple d'Omarchy. Votre présentation est un seul fichier Markdown avec ses images et vidéos à côté : écrivez chaque diapositive sous un aperçu en direct, glissez les diapositives pour les ordonner, puis présentez en plein écran ou exportez en PDF et PowerPoint. Elle récupère même votre thème Omarchy.

Vous démarrez Hype via le lanceur d'applications (`Super + Space`). Appuyez sur `?` à l'intérieur pour voir tous les raccourcis.

## Signed

[Signed](https://github.com/omacom/signed) est le moyen ultra-simple d'Omarchy pour signer des PDF et les remplir. Placez votre signature enregistrée, du texte et la date du jour n'importe où sur une page, puis enregistrez une copie signée à côté de l'original. Voir [Remplir des PDF](27-filling-out-pdfs.md) pour savoir comment faire.

Vous démarrez Signed via le lanceur d'applications (`Super + Space`), ou vous ouvrez un PDF avec lui depuis le gestionnaire de fichiers.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) est la calculatrice ultra-simple d'Omarchy, qui s'ouvre dans une fenêtre flottante.

Vous démarrez Omacalc avec `Super + Ctrl + Q` (ou la touche calculatrice, si votre clavier en a une).

## Signal

[Signal](https://signal.org/) est le pionnier de la messagerie chiffrée de bout en bout, et une excellente option de communication pour quiconque préfère ne pas passer par l'un des grands conglomérats de la tech.

Vous démarrez Signal avec `Super + Shift + G`. Il ne fait pas partie de l'installation de base, donc la première fois que vous appuyez là-dessus, Omarchy vous proposera de l'installer pour vous (il est aussi sous _Installer > Service_ dans le menu Omarchy).

## mpv

[mpv](https://mpv.io/) est un lecteur multimédia simple et rapide qui lira presque n'importe quoi depuis n'importe quelle source. Parfait pour regarder des vidéos.

Vous démarrez mpv via le lanceur d'applications (`Super + Space`) ou vous double-cliquez simplement sur une vidéo dans le gestionnaire de fichiers.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) est le coupe-video ultra-simple d'Omarchy. Quand tout ce dont vous avez besoin est de couper le début et la fin d'un clip, il vaut mieux que de lancer un éditeur vidéo complet.

Vous démarrez Omacut via le lanceur d'applications (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) est l'enregistreur webcam ultra-simple d'Omarchy. Choisissez votre caméra et votre micro une fois, puis appuyez sur `Space` pour enregistrer, et à nouveau pour mettre en pause et reprendre la même prise. Il enregistre toujours à la résolution la plus élevée de votre caméra, avec un indicateur de micro en direct pour que vous puissiez vérifier vos niveaux avant de commencer.

Arrêtez la prise et elle s'ouvre immédiatement dans un éditeur intégré. Double-cliquez sur un clip pour le diviser, faites glisser les poignées pour couper chaque morceau, et supprimez les parties que vous ne voulez pas. Puis enregistrez-le en MP4. Votre enregistrement d'origine est conservé jusqu'à ce que vous le jetiez, donc vous pouvez toujours revenir et le découper différemment.

Vous démarrez Monologue via le lanceur d'applications (`Super + Space`).
