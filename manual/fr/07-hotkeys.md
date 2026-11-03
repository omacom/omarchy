# Raccourcis clavier

Vous pouvez voir tous les principaux raccourcis clavier avec `Super + K` (raccourcis Tmux avec `Super + Alt + K` et raccourcis Herdr avec `Super + Ctrl + K`).

## Comment les raccourcis clavier sont organisés

Chaque raccourci clavier se trouve sur un plan, défini par ses modificateurs, et chaque plan a une seule fonction. C'est ce qui empêche les raccourcis clavier de se confondre, et cela signifie que vous pouvez généralement deviner où se trouve quelque chose.

| Plan | Ce qui s'y trouve | Exemples |
| --- | --- | --- |
| `Super + key` | Le système : fenêtres, espaces de travail, dispositions et menus principaux | `Super + Space` menu Omarchy, `Super + W` fermer la fenêtre, `Super + F` plein écran |
| `Super + Shift + key` | Applications | `Super + Shift + B` navigateur, `Super + Shift + E` e-mail, `Super + Shift + N` éditeur |
| `Super + Ctrl + key` | Panneaux et menus système | `Super + Ctrl + A` audio, `Super + Ctrl + N` réseau, `Super + Ctrl + C` menu de capture |
| `Super + Ctrl + Alt + key` | Actions rapides et avis | `Super + Ctrl + Alt + T` afficher l'heure, `Super + Ctrl + Alt + B` batterie, `Super + Ctrl + Alt + C` capture d'écran |

Ajouter `Alt` à un raccourci clavier vous donne une variante de la même chose, jamais quelque chose sans rapport :

- `Super + Shift + B` ouvre le navigateur ; `Super + Shift + Alt + B` ouvre une fenêtre privée
- `Super + Shift + E` ouvre l'e-mail ; `Super + Shift + Alt + E` en commence un nouveau
- `Super + F` passe en plein écran ; `Super + Alt + F` passe en pleine largeur
- `Super + Ctrl + C` ouvre le menu de capture ; `Super + Ctrl + Alt + C` saute le menu et prend une capture d'écran

Quand vous ajoutez un raccourci clavier :

1. Choisissez le plan en fonction de ce qu'il fait, puis choisissez la touche.
2. Ne déplacez pas un raccourci clavier existant pour faire de la place. Trouvez une touche libre sur le bon plan.
3. N'utilisez `Alt` que pour une variante du raccourci clavier sans lui.

Quelques raccourcis clavier dérogent à ces règles parce que c'est pratique. `Shift` avec une flèche ou `Tab` déplace ou inverse au lieu d'ouvrir une application, et `Print`, les touches multimédias, `Alt + Tab` et `Ctrl + Alt + Del` fonctionnent comme partout ailleurs. Ce sont des exceptions, pas des modèles à copier.

Si un raccourci par défaut ne vous convient pas (par exemple vous voulez `Super + Shift + S` pour les captures d'écran comme sur Windows), reconfigurez-le dans `~/.config/hypr/bindings.lua`.

## Navigation

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (applications et tout le reste)    |
| `Super + Alt + Space` | Grille d'applications |
| `Super + Escape` | Menu système (mise en veille, redémarrage, etc.)  |
| `Super + Ctrl + L` | Verrouiller l'ordinateur |
| `Super + W` or `Super + Q` | Fermer la fenêtre             |
| `Ctrl + Alt + Del` | Fermer toutes les fenêtres |
| `Super + T`               | Basculer la fenêtre entre tuilage/flottant             |
| `Super + J` | Basculer la position de la fenêtre (horizontale/verticale) |
| `Super + O`               | Basculer la fenêtre détachée en épinglée et flottante |
| `Super + L`               | Faire défiler les dispositions dwindle, scrolling et floating |
| `Super + Alt + L`         | Faire défiler les dispositions en sens inverse |
| `Super + P`               | Basculer le style de fenêtre pseudo (naturel ou étiré) |
| `Super + F`                 | Passer en plein écran              |
| `Super + Alt + F`                 | Passer en pleine largeur              |
| `Super + Ctrl + F`                 | Passer en plein écran à l'intérieur de la fenêtre              |
| `Super + 1/2/3/4`         | Aller à l'espace de travail indiqué sur le moniteur actif |
| `Super + Tab` | Aller à l'espace de travail suivant sur le moniteur actif |
| `Super + Shift + Tab` | Aller à l'espace de travail précédent sur le moniteur actif |
| `Super + Ctrl + Tab` | Aller à l'ancien espace de travail sur le moniteur actif |
| `Super + Shift + 1/2/3/4` | Déplacer la fenêtre vers l'espace de travail sur le moniteur actif |
| `Super + Shift + Alt + 1/2/3/4` | Déplacer la fenêtre vers l'espace de travail sur le moniteur actif sans la suivre |
| `Super + S` | Activer/désactiver le scratchpad plein écran |
| `Super + Alt + S` | Déplacer la fenêtre vers le scratchpad plein écran |
| `Super + Grave` | Activer/désactiver la console Quake |
| `Super + Shift + Grave` | Déplacer la fenêtre vers la console Quake |
| `Super + Shift + Ctrl + Arrows` | Déplacer la fenêtre vers le moniteur dans cette direction |
| `Super + Shift + Alt + Arrows` | Déplacer l'espace de travail vers le moniteur dans cette direction |
| `Super + Arrow`  | Déplacer le focus vers la fenêtre dans la direction de la flèche, en passant au moniteur de ce côté au bord de l'écran |
| `Super + Shift + Arrow`  | Échanger la fenêtre avec une autre dans la direction de la flèche, y compris une sur le moniteur de ce côté |
| `Super + Minus` | Élargir la fenêtre vers la gauche |
| `Super + Equal` | Rétrécir la fenêtre vers la gauche |
| `Super + Shift + Minus` | Rétrécir la fenêtre vers le haut |
| `Super + Shift + Equal` | Élargir la fenêtre vers le bas |
| `Super + Alt + Minus/Equal` | Même redimensionnement par plus petits pas |
| `Super + Ctrl + Minus/Equal` | Même redimensionnement par plus grands pas |
| `Super + Alt + Home` | Enregistrer la largeur de la fenêtre |
| `Super + Home` | Restaurer la largeur de fenêtre enregistrée |
| `Super + Left Mouse` | Faire glisser la fenêtre |
| `Super + Right Mouse` | Redimensionner la fenêtre |
| `Super + Scroll Wheel` | Faire défiler les espaces de travail sur le moniteur actif |
| `Super + G`               | Activer/désactiver le regroupement de fenêtres      |
| `Super + Alt + G`               | Retirer la fenêtre du regroupement      |
| `Super + Alt + Tab`               | Faire défiler les fenêtres du regroupement      |
| `Super + Alt + Shift + Tab`               | Faire défiler les fenêtres du regroupement en sens inverse      |
| `Super + Alt + Scroll Wheel` | Faire défiler les fenêtres du regroupement |
| `Super + Alt + 1/2/3/4/5`               | Aller à la fenêtre indiquée dans le regroupement      |
| `Super + Alt + Arrow`  | Déplacer la fenêtre dans le regroupement dans la direction de la flèche, y compris une sur le moniteur de ce côté |
| `Super + Ctrl + Left/Right`  | Naviguer entre les fenêtres à l'intérieur d'un groupe en tuilage |
| `Super + Ctrl + Z` | Zoomer sur l'écran (répéter pour zoomer davantage) |
| `Super + Ctrl + Alt + Z` | Dézoomer complètement de l'écran |
| `Super + /` | Passer à l'option suivante de mise à l'échelle du moniteur |
| `Super + Alt + /` | Passer à l'option précédente de mise à l'échelle du moniteur |
| `Alt + Tab` | Faire défiler vers l'avant les fenêtres de l'espace de travail actif |
| `Alt + Shift + Tab` | Faire défiler vers l'arrière les fenêtres de l'espace de travail actif |
| `Ctrl + Alt + Tab`| Faire défiler le focus vers l'avant entre les moniteurs |
| `Ctrl + Alt + Shift + Tab`| Faire défiler le focus vers l'arrière entre les moniteurs |

Les raccourcis de redimensionnement utilisent les touches physiques `code:20` et `code:21` (XKB `<AE11>` et `<AE12>`), quels que soient les caractères imprimés sur le clavier. Sur les claviers US, ces touches sont `-` et `=` ; sur les claviers japonais (JIS), ce sont `-` et `^` ; sur les claviers espagnols, ce sont `'` et `¡`. Sur JIS, `Super + ^` correspond à `Super + Equal`, tandis que `Super + Shift + -` (qui tape `=`) correspond à `Super + Shift + Minus`.

## Contrôles système

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panneau audio    |
| `Super + Ctrl + B`           | Panneau Bluetooth    |
| `Super + Ctrl + N`           | Panneau Wi-Fi/réseau    |
| `Super + Ctrl + D`           | Panneau d'affichage    |
| `Super + Ctrl + P`           | Panneau d'alimentation    |
| `Super + Ctrl + Alt + D`           | Panneau calendrier    |
| `Super + Ctrl + Alt + E`           | Panneau horloge mondiale    |
| `Super + Ctrl + 1-9`           | Activer/désactiver le panneau de la barre selon sa position    |
| `Super + Ctrl + S` | Menu de partage (via LocalSend) |
| `Super + Ctrl + C` | Contrôles de capture (capture d'écran/enregistrement/sélecteur) |
| `Super + Ctrl + O` | Menu des bascules |
| `Super + Ctrl + H` | Menu matériel |
| `Super + Ctrl + E` | Sélecteur d'emoji |
| `Super + Ctrl + .` | Transcoder un média |
| `Super + Shift + Ctrl + A` | Choisir un agent IA |

## Réglages

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Luminosité maximale de l'écran |
| `Shift + Brightness Down` | Luminosité minimale de l'écran |
| `Alt + Brightness Up/Down` | Réglages précis de la luminosité par pas de 1 % |
| `Alt + Volume Up/Down` | Réglages précis du volume par pas de 1 % |
| `Keyboard Brightness Up/Down` | Rétroéclairage du clavier plus fort/plus faible |
| `Keyboard Backlight` | Faire défiler les niveaux de rétroéclairage du clavier |
| `Alt + Play` | Piste suivante |
| `Alt + Shift + Play` | Piste précédente |

## Lancement d'applications

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (gestionnaire d'agents) |
| `Super + Shift + Return`           | Navigateur    |
| `Super + Shift + Alt + B`           | Navigateur (privé/incognito)    |
| `Super + Shift + F`           | Gestionnaire de fichiers    |
| `Super + Shift + Alt + F`           | Gestionnaire de fichiers dans le répertoire de travail actuel du terminal    |
| `Super + Shift + M`           | Musique (Spotify)    |
| `Super + Shift + Alt + M`           | Musique (cliamp)    |
| `Super + Shift + /`           | Gestionnaire de mots de passe (1password)    |
| `Super + Shift + Q`           | Calculatrice (Omacalc)    |
| `Super + Shift + T`           | Activité (btop)    |
| `Super + Shift + N`           | Éditeur (Neovim)  |
| `Super + Shift + C`           | Calendrier ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nouvel e-mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | IA (ChatGPT)  |
| `Super + Shift + Alt + A`           | IA (Grok)  |
| `Super + Shift + G`           | Messagerie (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Messagerie (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Messagerie (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Écriture (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Modifiez/ajoutez des raccourcis dans `~/.config/hypr/bindings.lua`.

## Presse-papiers universel

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + A`           | Tout sélectionner dans les applications qui prennent en charge `Ctrl + A`    |
| `Super + C`           | Copier    |
| `Super + X`           | Couper (pas dans le terminal)    |
| `Super + V`           | Coller    |
| `Super + Ctrl + V`           | Gestionnaire de presse-papiers    |

D'habitude sous Linux, il faut `Ctrl + Shift + C/V` pour copier-coller dans le terminal et `Ctrl + C/V` pour le faire partout ailleurs. Ces raccourcis de presse-papiers unifiés d'Omarchy fonctionnent partout.

## Capture

| Raccourci clavier              | Fonction                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Capture d'écran                      |
| `Super + Ctrl + Alt + C`            | Capture d'écran (la même capture, pour les claviers sans touche Print Screen) |
| `Super + Ctrl + C` | Menu de capture |
| `Alt + Print Screen`            | Enregistrement d'écran                     |
| `Super + Print Screen` | Sélecteur de couleurs |
| `Super + Ctrl + Print Screen` | Extraction de texte vers le presse-papiers |
| `Super + Alt + [` | Réduire la superposition de la webcam pendant l'enregistrement |
| `Super + Alt + ]` | Agrandir la superposition de la webcam pendant l'enregistrement |
| `Alt + Shift + L` | Copier l'URL actuelle depuis une webapp ou Chromium |
| `Alt + Shift + D` | Télécharger la vidéo de la page actuelle dans `~/Videos` |
| `Alt + Space` | Démarrer/arrêter la dictée (nécessite _Setup > Defaults > Dictation_) |
| `Right Alt` | Maintenir pour dicter (nécessite _Setup > Defaults > Dictation_) |

Avec les enregistrements d'écran, le raccourci demande d'abord quel audio vous voulez, puis démarre l'enregistrement. Appuyez à nouveau dessus pour arrêter. Voir [captures d'écran et enregistrement](12-screenshots-recording.md) pour les détails.

Toutes les options de capture sont aussi accessibles sous _Trigger > Capture_ dans le menu Omarchy (`Super + Space`).

## Notifications

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + ,` | Agir sur la dernière notification : l'ouvrir ou appuyer sur son unique bouton, choisir parmi ses options, ou l'ignorer lorsqu'elle n'en a aucune  |
| `Super + Shift + ,` | Ignorer toutes les notifications |
| `Super + Ctrl + ,` | Contrôler les notifications au clavier  |
| `Super + Alt + ,` | Ignorer la dernière notification  |
| `Super + Shift + Alt + ,` | Ouvrir l'historique des notifications  |
| `Super + Ctrl + Alt + ,` | Activer/désactiver le silence des notifications  |

## Style

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Choisir un nouveau thème (aussi `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Choisir l'arrière-plan du thème (aussi `Super + Ctrl + Space`) |
| `Super + Backspace` | Activer/désactiver la transparence d'une fenêtre |
| `Super + Ctrl + Backspace` | Activer/désactiver le format carré pour une fenêtre unique |

Les images d'arrière-plan supplémentaires se trouvent dans `~/.config/omarchy/backgrounds/<theme name>`. Également disponible via _Install > Style > Background_ dans le menu Omarchy.

Toutes les options de style sont aussi accessibles sous _Style_ dans le menu Omarchy (`Super + Space`).

## Bascules

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Activer/désactiver le verrouillage en cas d'inactivité |
| `Super + Ctrl + Delete` | Activer/désactiver l'écran de l'ordinateur portable |
| `Super + Ctrl + Alt + Delete` | Activer/désactiver la recopie de l'écran de l'ordinateur portable |
| `Super + Shift + Space` | Afficher/masquer la barre supérieure  |
| `Shift + Mute` | Passer à la sortie audio suivante |
| `Shift + Play` | Passer à la source multimédia suivante |
| `Super + Shift + Backspace` | Activer/désactiver les espacements entre fenêtres |
| `Super + Ctrl + Alt + F` | Activer/désactiver le bureau plein écran (barre supérieure + espacements entre fenêtres) |

## Rappels

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Définir un rappel  |
| `Super + Ctrl + Alt + R` | Voir tous les rappels  |
| `Super + Ctrl + Shift + R` | Effacer tous les rappels  |

## Avis

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Afficher l'heure sous forme de notification  |
| `Super + Ctrl + Alt + B` | Afficher la batterie sous forme de notification  |
| `Super + Ctrl + Alt + W` | Afficher/masquer la météo sous forme de notification  |

## Tmux

La touche préfixe est `Ctrl + Space` (`Ctrl + B` fonctionne aussi). Vous pouvez modifier ces raccourcis dans `~/.config/tmux/tmux.conf`.

### Volets

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Prefix + v` | Diviser le volet à côté (vertical) |
| `Prefix + h` | Diviser le volet en dessous (horizontal) |
| `Prefix + x` | Fermer le volet |
| `Prefix + z` | Activer/désactiver le zoom du volet (plein écran) |
| `Alt + Enter` | Diviser le volet en dessous (sans préfixe) |
| `Alt + Shift + Enter` | Diviser le volet à côté (sans préfixe) |
| `Alt + Escape` | Fermer le volet (sans préfixe) |
| `Ctrl + Alt + Arrows` | Naviguer entre les volets |
| `Ctrl + Alt + Shift + Arrows` | Redimensionner les volets |

### Fenêtres

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nouvelle fenêtre |
| `Prefix + k` | Fermer la fenêtre |
| `Prefix + r` | Renommer la fenêtre |
| `Alt + 1-9` | Aller à la fenêtre indiquée |
| `Alt + Arrow Left/Right` | Naviguer entre les fenêtres |
| `Alt + Shift + Arrow Left/Right` | Déplacer la fenêtre vers la gauche/la droite |

### Sessions

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nouvelle session |
| `Prefix + K` | Fermer la session |
| `Prefix + R` | Renommer la session |
| `Prefix + N` | Session suivante |
| `Prefix + P` | Session précédente |
| `Alt + Arrow Up/Down` | Naviguer entre les sessions |
| `Prefix + s` | Lister les sessions |
| `Prefix + d` | Se détacher de la session |

### Mode copie (style vi)

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Prefix + [` | Entrer en mode copie |
| `v` | Commencer la sélection (en mode copie) |
| `y` | Copier la sélection (en mode copie) |

### Général

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Prefix + q` | Recharger la configuration |
| `Prefix + ?` | Afficher les raccourcis clavier Tmux |
| `Prefix + :` | Invite de commande |

### Fonctions de disposition Tmux

Ces fonctions doivent être exécutées à l'intérieur d'une session Tmux.

| Commande | Fonction |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Créer une disposition de développement avec éditeur, IA et terminal |
| `tdlm <ai> [<second_ai>]` | Créer une disposition de développement par sous-répertoire |
| `tsl <count> <command>` | Créer une disposition en essaim à plusieurs volets |

## Terminal Ghostty

Le terminal Ghostty s'installe à l'aide de _Install > Terminal_ via le menu Omarchy.

| Raccourci clavier                  | Fonction              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nouvelle division en dessous |
| `Ctrl + Shift + O` | Nouvelle division à côté |
| `Ctrl + Alt + Arrows` | Naviguer entre les divisions |
| `Super + Ctrl + Shift + Arrows` | Redimensionner la division de 10 lignes |
| `Super + Ctrl + Shift + Alt + Arrows` | Redimensionner la division de 100 lignes |
| `Ctrl + Shift + T` | Nouvel onglet  |
| `Ctrl + Shift + Arrows` | Naviguer entre les onglets |
| `Alt + Numbers` | Aller à l'onglet indiqué |
| `Shift + Pg Up/Down` | Faire défiler l'historique |
| `Ctrl + Left mouse` | Ouvrir le lien dans le navigateur |

## Gestionnaire de fichiers

| Raccourci clavier              | Fonction                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Aller au chemin                     |
| `Space`               | Prévisualiser le fichier (les flèches permettent de naviguer) |
| `Alt + Up`       | Remonter au dossier parent        |

## Neovim (avec lazyvim)

### Navigation

| Raccourci clavier                   | Fonction                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Afficher les options de commande            |
| `Space Space`              | Ouvrir un fichier via la recherche floue      |
| `Space E`                  | Afficher/masquer la barre latérale                  |
| `Space G G`                | Afficher les contrôles git               |
| `Space S G`                | Rechercher dans le contenu des fichiers             |
| `Ctrl + W W`               | Passer de la barre latérale à l'éditeur et inversement |
| `Ctrl + Left/right arrow`  | Modifier la taille de la barre latérale          |
| `Shift + H`                      | Aller à l'onglet de fichier de gauche             |
| `Shift + L`                      | Aller à l'onglet de fichier de droite            |
| `Space B D`                | Fermer l'onglet de fichier                  |

### Dans la barre latérale

| Raccourci clavier                   | Fonction                        |
| ------------------------ | ------------------------------- |
| `A`                        | Ajouter un nouveau fichier dans le répertoire parent      |
| `Shift + A`                | Ajouter un nouveau sous-répertoire dans le répertoire parent    |
| `D`                        | Supprimer le fichier/répertoire en surbrillance     |
| `M`                        | Déplacer le fichier/répertoire en surbrillance       |
| `R`                        | Renommer le fichier/répertoire en surbrillance     |
| `?`                        | Afficher l'aide pour toutes les commandes      |

[Voir tous les raccourcis clavier Neovim configurés par LazyVim](https://www.lazyvim.org/keymaps).

## Emojis rapides

Vous pouvez utiliser `Super + Ctrl + E` pour afficher un sélecteur d'emoji complet qui placera la sélection dans le presse-papiers, ou vous pouvez utiliser ces options d'accès rapide.

| Raccourci clavier       | EM | Indice       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | sourire      |
| `Shift + CapsLock M C` | 😂 | pleurer        |
| `Shift + CapsLock M L` | 😍 | amour       |
| `Shift + CapsLock M V` | ✌️ | victoire    |
| `Shift + CapsLock M H` | ❤️ | cœur      |
| `Shift + CapsLock M Y` | 👍 | oui        |
| `Shift + CapsLock M N` | 👎 | non         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | souhait       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | baiser       |
| `Shift + CapsLock M E` | 🙄 | yeux au ciel    |
| `Shift + CapsLock M I` | 😉 | clin d'œil       |
| `Shift + CapsLock M P` | 🙏 | prier |
| `Shift + CapsLock M D` | 🤤 | baver      |
| `Shift + CapsLock M M` | 💰 | argent      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | salut |
| `Shift + CapsLock M A` |💪 | bras |
| `Shift + CapsLock M B` |🤯 | explosion |

## Complétions rapides

| Raccourci clavier       | Complétion       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (tiret cadratin)   |
| `Shift + CapsLock Space N` | Votre nom (tel que saisi lors de la configuration)  |
| `Shift + CapsLock Space E` | Votre e-mail (tel que saisi lors de la configuration)  |

Vous pouvez en ajouter d'autres en modifiant `~/.XCompose`, puis en exécutant `omarchy-restart-xcompose` dans le terminal pour que les modifications soient prises en compte.
