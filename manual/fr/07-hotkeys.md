# Raccourcis clavier

Vous pouvez voir tous les principaux raccourcis clavier avec `Super + K` (raccourcis Tmux avec `Super + Alt + K` et raccourcis Herdr avec `Super + Ctrl + K`).

## Comment les raccourcis sont organisés

Chaque raccourci se trouve sur un plan, défini par ses modificateurs, et chaque plan a une seule tâche. C'est ce qui évite que les raccourcis se mélangent, et cela signifie que vous pouvez généralement deviner où se trouve quelque chose.

| Plan | Ce qu'on y trouve | Exemples |
| --- | --- | --- |
| `Super + key` | Le système : fenêtres, espaces de travail, dispositions et menus principaux | `Super + Space` menu Omarchy, `Super + W` fermer la fenêtre, `Super + F` plein écran |
| `Super + Shift + key` | Applications | `Super + Shift + B` navigateur, `Super + Shift + E` e-mail, `Super + Shift + N` éditeur |
| `Super + Ctrl + key` | Panneaux et menus système | `Super + Ctrl + A` audio, `Super + Ctrl + N` réseau, `Super + Ctrl + C` menu de capture |
| `Super + Ctrl + Alt + key` | Actions rapides et avis | `Super + Ctrl + Alt + T` afficher l'heure, `Super + Ctrl + Alt + B` batterie, `Super + Ctrl + Alt + C` capture d'écran |

Ajouter `Alt` à un raccourci vous donne une variante de la même chose, jamais quelque chose sans rapport :

- `Super + Shift + B` ouvre le navigateur ; `Super + Shift + Alt + B` ouvre une fenêtre privée
- `Super + Shift + E` ouvre l'e-mail ; `Super + Shift + Alt + E` en commence un nouveau
- `Super + F` passe en plein écran ; `Super + Alt + F` passe en pleine largeur
- `Super + Ctrl + C` ouvre le menu de capture ; `Super + Ctrl + Alt + C` saute le menu et prend une capture d'écran

Quand vous ajoutez un raccourci :

1. Choisissez le plan en fonction de ce qu'il fait, puis choisissez la touche.
2. Ne déplacez pas un raccourci existant pour faire de la place. Trouvez une touche libre sur le bon plan.
3. N'utilisez `Alt` que pour une variante du raccourci sans `Alt`.

Quelques raccourcis enfreignent ces règles parce que c'est pratique. `Shift` avec une flèche ou `Tab` déplace ou inverse au lieu d'ouvrir une application, et `Print`, les touches multimédias, `Alt + Tab` et `Ctrl + Alt + Del` fonctionnent comme partout ailleurs. Ce sont des exceptions, pas des modèles à copier.

Si un réglage par défaut ne vous convient pas (disons que vous voulez `Super + Shift + S` pour les captures d'écran comme sur Windows), réattribuez-le dans `~/.config/hypr/bindings.lua`.

## Navigation

| Raccourci                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (applications et tout le reste)    |
| `Super + Alt + Space` | Grille d'applications |
| `Super + Escape` | Menu système (mise en veille, redémarrage, etc.)  |
| `Super + Ctrl + L` | Verrouiller l'ordinateur |
| `Super + W` ou `Super + Q` | Fermer la fenêtre             |
| `Ctrl + Alt + Del` | Fermer toutes les fenêtres |
| `Super + K` | Afficher tous les raccourcis |
| `Super + Alt + K` | Afficher les raccourcis tmux |
| `Super + Ctrl + K` | Afficher les raccourcis herdr |
| `Super + M` | Réduire la fenêtre dans le dock |
| `Super + T`               | Basculer la fenêtre entre mosaïque/flottante             |
| `Super + J` | Basculer la position de la fenêtre (horizontale/verticale) |
| `Super + O`               | Basculer la fenêtre détachée en mode épinglé et flottant |
| `Super + L`               | Faire défiler les dispositions dwindle, scrolling et flottante |
| `Super + Alt + L`         | Faire défiler les dispositions en sens inverse |
| `Super + P`               | Basculer le style de fenêtre pseudo (naturel contre étiré) |
| `Super + F`                 | Passer en plein écran              |
| `Super + Alt + F`                 | Passer en pleine largeur              |
| `Super + Ctrl + F`                 | Passer en plein écran à l'intérieur de la fenêtre              |
| `Super + 1…9/0`         | Aller à l'espace de travail spécifique (0 correspond à 10) sur le moniteur actif |
| `Super + Tab` | Aller à l'espace de travail suivant sur le moniteur actif |
| `Super + Shift + Tab` | Aller à l'espace de travail précédent sur le moniteur actif |
| `Super + Ctrl + Tab` | Aller à l'ancien espace de travail sur le moniteur actif |
| `Super + Shift + 1…9/0` | Déplacer la fenêtre vers l'espace de travail sur le moniteur actif |
| `Super + Shift + Alt + 1…9/0` | Déplacer la fenêtre vers l'espace de travail sur le moniteur actif sans la suivre |
| `Super + S` | Basculer le scratchpad complet |
| `Super + Alt + S` | Déplacer la fenêtre vers le scratchpad complet |
| `Super + the key above Tab` (accent grave sur les dispositions US) | Basculer la console Quake |
| `Super + Shift + the key above Tab` (accent grave sur les dispositions US) | Déplacer la fenêtre vers la console Quake |
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
| `Super + G`               | Basculer le regroupement de fenêtres      |
| `Super + Alt + G`               | Retirer la fenêtre du groupe      |
| `Super + Alt + Tab`               | Faire défiler les fenêtres du groupe      |
| `Super + Alt + Shift + Tab`               | Faire défiler les fenêtres du groupe en arrière      |
| `Super + Alt + Scroll Wheel` | Faire défiler les fenêtres du groupe |
| `Super + Alt + 1/2/3/4/5`               | Aller à une fenêtre spécifique du groupe      |
| `Super + Alt + Arrow`  | Déplacer la fenêtre dans le groupe dans la direction de la flèche, y compris une sur le moniteur de ce côté |
| `Super + Ctrl + Left/Right`  | Naviguer entre les fenêtres d'un groupe en mosaïque |
| `Super + Ctrl + Z` | Zoomer sur l'écran (répéter pour zoomer davantage) |
| `Super + Ctrl + Alt + Z` | Dézoomer complètement de l'écran |
| `Super + /` | Avancer parmi les options de mise à l'échelle du moniteur |
| `Super + Alt + /` | Reculer parmi les options de mise à l'échelle du moniteur |
| `Alt + Tab` | Faire défiler vers l'avant les fenêtres de l'espace de travail actif |
| `Alt + Shift + Tab` | Faire défiler vers l'arrière les fenêtres de l'espace de travail actif |
| `Ctrl + Alt + Tab`| Faire défiler le focus vers l'avant entre les moniteurs |
| `Ctrl + Alt + Shift + Tab`| Faire défiler le focus vers l'arrière entre les moniteurs |
| `Super + I` | Changer de langue de saisie (avec plus d'une disposition ou méthode de saisie) |
| `Super + Shift + I` | Revenir à la langue de saisie précédente |

Sur un pavé tactile, les balayages à trois et quatre doigts changent d'espace de travail, déplacent les fenêtres et ouvrent le menu et la console Quake ; voir [clavier, souris et trackpad](34-keyboard-mouse-trackpad.md) pour les gestes.

Le redimensionnement utilise les deux touches à droite du 0, quoi que votre clavier y imprime : `-` et `=` sur les claviers US, `+` et `´` sur les claviers danois et suédois, `+` et `\` sur les claviers norvégiens, `ß` et `´` sur les claviers allemands, `'` et `¡` sur les claviers espagnols, et `-` et `^` sur les claviers japonais (JIS). `Super + K` les affiche telles que votre clavier les imprime. Sur JIS, `Super + ^` correspond à `Super + Equal`, tandis que `Super + Shift + -` (qui tape `=`) correspond à `Super + Shift + Minus`. La mise à l'échelle du moniteur et le gestionnaire de mots de passe utilisent `/` ; sur les dispositions qui ne tapent `/` qu'avec Shift, comme la plupart des européennes, ils utilisent à la place la touche à gauche de Shift droit (`-` sur les claviers danois et allemands).

## Contrôles système

| Raccourci                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panneau audio    |
| `Super + Ctrl + B`           | Panneau Bluetooth    |
| `Super + Ctrl + N`           | Panneau Wi-Fi/réseau    |
| `Super + Ctrl + D`           | Panneau d'affichage    |
| `Super + Ctrl + P`           | Panneau d'alimentation    |
| `Super + Ctrl + X`           | Panneau des agents    |
| `Super + Ctrl + Alt + X`           | Panneau des modèles locaux    |
| `Super + Ctrl + Alt + D`           | Panneau du calendrier    |
| `Super + Ctrl + Alt + E`           | Panneau de l'horloge mondiale    |
| `Super + Ctrl + 1-9`           | Basculer le panneau de la barre par position    |
| `Super + Ctrl + S` | Menu de partage (via LocalSend) |
| `Super + Ctrl + C` | Contrôles de capture (capture d'écran/-enregistrement/sélecteur) |
| `Super + Ctrl + O` | Basculer le menu |
| `Super + Ctrl + H` | Menu matériel |
| `Super + Ctrl + E` | Sélecteur d'emoji |
| `Super + Ctrl + .` | Transcoder un média |
| `Super + Shift + Ctrl + A` | Lancer votre agent par défaut |
| `Power` touche | Menu système |
| `Super + Shift + Copilot` touche | Menu Omarchy |

## Réglages

| Raccourci                  | Fonction              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Luminosité d'écran maximale |
| `Shift + Brightness Down` | Luminosité d'écran minimale |
| `Alt + Brightness Up/Down` | Réglages précis de la luminosité par pas de 1 % |
| `Alt + Volume Up/Down` | Réglages précis du volume par pas de 1 % |
| `Keyboard Brightness Up/Down` | Rétroéclairage du clavier plus fort/plus faible |
| `Keyboard Backlight` | Faire défiler les niveaux de rétroéclairage du clavier |
| `Ctrl + Brightness Up/Down` | Rétroéclairage du clavier plus fort/plus faible, sur les claviers sans touches dédiées |
| `Mic Mute` | Couper le microphone |
| `Shift + Mute` | Changer de sortie audio |
| `Touchpad Toggle` | Activer ou désactiver le pavé tactile |
| `Display` touche | Faire défiler les dispositions d'espace de travail |
| `Alt + Play` | Piste suivante |
| `Alt + Shift + Play` | Piste précédente |

## Lancer des applications

| Raccourci                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (gestionnaire d'agents) |
| `Super + Shift + Return` ou `Super + Shift + B`  | Navigateur    |
| `Super + Shift + Alt + B`           | Navigateur (privé/incognito)    |
| `Super + Shift + F`           | Gestionnaire de fichiers    |
| `Super + Shift + Alt + F`           | Gestionnaire de fichiers dans le cwd du terminal    |
| `Super + Shift + M`           | Musique (Spotify)    |
| `Super + Shift + Alt + M`           | Musique (cliamp)    |
| `Super + Shift + /`           | Gestionnaire de mots de passe (1password)    |
| `Super + Shift + Q` ou `Calculator` touche  | Calculatrice (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, une fois installé)    |
| `Super + Shift + T`           | Activité (btop)    |
| `Super + Shift + N`           | Éditeur (Plain, ou celui par défaut que vous avez choisi)  |
| `Super + Shift + C`           | Calendrier ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nouvel e-mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Votre agent par défaut, ou ChatGPT jusqu'à ce que vous en choisissiez un |
| `Super + Shift + Alt + A`           | IA (Grok)  |
| `Super + Shift + G`           | Messagerie (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Messagerie (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Messagerie (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Écriture (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (nouvelle publication) |
| `Super + Shift + Y`           | YouTube |

Modifiez/ajoutez des raccourcis dans `~/.config/hypr/bindings.lua`.

## Presse-papiers universel

| Raccourci                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + A`           | Tout sélectionner dans les applications qui prennent en charge `Ctrl + A`    |
| `Super + C`           | Copier    |
| `Super + X`           | Couper (pas dans le terminal)    |
| `Super + V`           | Coller    |
| `Super + Ctrl + V`           | Gestionnaire du presse-papiers    |

Habituellement sous Linux, vous avez besoin de `Ctrl + Shift + C/V` pour copier-coller dans le terminal et de `Ctrl + C/V` pour le faire partout ailleurs. Ces raccourcis de presse-papiers unifiés d'Omarchy fonctionnent partout.

## Capture

| Raccourci              | Fonction                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Capture d'écran                      |
| `Super + Ctrl + Alt + C`            | Capture d'écran (la même capture, pour les claviers sans touche Print Screen) |
| `Super + Ctrl + C` | Menu de capture |
| `Alt + Print Screen`            | Enregistrement d'écran                     |
| `Super + Shift + Ctrl + Alt + C` | Enregistrement d'écran sans audio, sans passer par le menu (appuyez à nouveau pour arrêter) |
| `Super + Print Screen` | Sélecteur de couleur |
| `Super + Ctrl + Print Screen` | Extraction de texte vers le presse-papiers |
| `Super + Alt + [` | Réduire la superposition de la webcam pendant l'enregistrement |
| `Super + Alt + ]` | Agrandir la superposition de la webcam pendant l'enregistrement |
| `Alt + Shift + L` | Copier l'URL actuelle depuis l'application web ou le navigateur |
| `Alt + Shift + D` | Télécharger la vidéo de la page actuelle dans `~/Videos` |
| `Alt + Space` | Démarrer/arrêter la dictée (nécessite _Setup > Defaults > Dictation_) |
| `Right Alt` | Maintenir pour dicter (nécessite _Setup > Defaults > Dictation_) |

Pour les enregistrements d'écran, le raccourci demande d'abord quel audio vous voulez, puis démarre l'enregistrement. Appuyez à nouveau pour arrêter. Voir [captures d'écran et enregistrement](12-screenshots-recording.md) pour les détails.

Toutes les options de capture sont aussi accessibles sous _Trigger > Capture_ dans le menu Omarchy (`Super + Space`).

## Notifications

| Raccourci                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + ,` | Agir sur la dernière notification : l'ouvrir ou appuyer sur son seul bouton, choisir parmi ses options, ou l'ignorer quand elle n'en a aucune  |
| `Super + Shift + ,` | Ignorer toutes les notifications |
| `Super + Ctrl + ,` | Contrôler les notifications au clavier  |
| `Super + Alt + ,` | Ignorer la dernière notification  |
| `Super + Shift + Alt + ,` | Ouvrir l'historique des notifications  |
| `Super + Ctrl + Alt + ,` | Activer/désactiver le silence des notifications  |

## Style

| Raccourci                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Choisir un nouveau thème (aussi `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Choisir l'arrière-plan du thème (aussi `Super + Ctrl + Space`) |
| `Super + Backspace` | Basculer la transparence d'une fenêtre |
| `Super + Ctrl + Backspace` | Basculer l'aspect carré d'une seule fenêtre |

Les images d'arrière-plan supplémentaires se trouvent dans `~/.config/omarchy/backgrounds/<theme name>`. Également disponible via _Install > Style > Background_ dans le menu Omarchy.

Toutes les options de style sont aussi accessibles sous _Appearance_ dans le menu Omarchy (`Super + Space`).

## Bascules

| Raccourci                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Basculer le verrouillage en cas d'inactivité |
| `Super + Ctrl + Delete` | Activer/désactiver l'écran de l'ordinateur portable |
| `Super + Ctrl + Alt + Delete` | Basculer la recopie de l'écran de l'ordinateur portable |
| `Super + Shift + Space` | Basculer la barre supérieure  |
| `Shift + Mute` | Passer à la sortie audio suivante |
| `Shift + Play` | Passer à la source multimédia suivante |
| `Super + Shift + Backspace` | Basculer les espacements entre fenêtres |
| `Super + Ctrl + Alt + F` | Basculer le bureau plein écran (barre supérieure + espacements entre fenêtres) |

## Rappels

| Raccourci                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Définir un rappel  |
| `Super + Ctrl + Alt + R` | Voir tous les rappels  |
| `Super + Ctrl + Shift + R` | Effacer tous les rappels  |

## Avis

| Raccourci                  | Fonction              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Afficher l'heure en notification  |
| `Super + Ctrl + Alt + B` | Afficher la batterie en notification  |
| `Super + Ctrl + Alt + W` | Basculer la météo en notification  |

## Tmux

La touche préfixe est `Ctrl + Space` (`Ctrl + B` fonctionne aussi). Vous pouvez modifier ces raccourcis dans `~/.config/tmux/tmux.conf`.

### Volets

| Raccourci                  | Fonction              |
| ----------------------- | --------------------- |
| `Prefix + v` | Diviser le volet à côté (vertical) |
| `Prefix + h` | Diviser le volet en dessous (horizontal) |
| `Prefix + x` | Fermer le volet |
| `Prefix + z` | Basculer le zoom du volet (plein écran) |
| `Alt + Enter` | Diviser le volet en dessous (sans préfixe) |
| `Alt + Shift + Enter` | Diviser le volet à côté (sans préfixe) |
| `Alt + Escape` | Fermer le volet (sans préfixe) |
| `Ctrl + Alt + Arrows` | Naviguer entre les volets |
| `Ctrl + Alt + Shift + Arrows` | Redimensionner les volets |

### Fenêtres

| Raccourci                  | Fonction              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nouvelle fenêtre |
| `Prefix + k` | Fermer la fenêtre |
| `Prefix + r` | Renommer la fenêtre |
| `Alt + 1-9` | Aller à une fenêtre spécifique |
| `Alt + Arrow Left/Right` | Naviguer entre les fenêtres |
| `Alt + Shift + Arrow Left/Right` | Déplacer la fenêtre à gauche/droite |

### Sessions

| Raccourci                  | Fonction              |
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

| Raccourci                  | Fonction              |
| ----------------------- | --------------------- |
| `Prefix + [` | Entrer en mode copie |
| `v` | Commencer la sélection (en mode copie) |
| `y` | Copier la sélection (en mode copie) |

### Général

| Raccourci                  | Fonction              |
| ----------------------- | --------------------- |
| `Prefix + q` | Recharger la configuration |
| `Prefix + ?` | Afficher les raccourcis Tmux |
| `Prefix + :` | Invite de commande |

### Fonctions de disposition Tmux

Ces fonctions doivent être exécutées dans une session Tmux.

| Commande | Fonction |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Créer une disposition de développement avec éditeur, IA et terminal |
| `tdlm <ai> [<second_ai>]` | Créer une disposition de développement par sous-répertoire |
| `tsl <count> <command>` | Créer une disposition en essaim multi-volets |

## Terminal Ghostty

Le terminal Ghostty s'installe avec _Install > Terminal_ via le menu Omarchy.

| Raccourci                  | Fonction              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nouvelle division en dessous |
| `Ctrl + Shift + O` | Nouvelle division à côté |
| `Ctrl + Alt + Arrows` | Naviguer entre les divisions |
| `Super + Ctrl + Shift + Arrows` | Redimensionner la division de 10 lignes |
| `Super + Ctrl + Shift + Alt + Arrows` | Redimensionner la division de 100 lignes |
| `Ctrl + Shift + T` | Nouvel onglet  |
| `Ctrl + Shift + Arrows` | Naviguer entre les onglets |
| `Alt + Numbers` | Aller à un onglet spécifique |
| `Shift + Pg Up/Down` | Faire défiler l'historique |
| `Ctrl + Left mouse` | Ouvrir le lien dans le navigateur |

## Gestionnaire de fichiers

| Raccourci              | Fonction                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Aller au chemin                     |
| `Space`               | Aperçu du fichier (les flèches naviguent) |
| `Alt + Up`       | Remonter au dossier parent        |

## Neovim (avec lazyvim)

### Navigation

| Raccourci                   | Fonction                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Afficher les options de commande            |
| `Space Space`              | Ouvrir un fichier via la recherche floue      |
| `Space E`                  | Basculer la barre latérale                  |
| `Space G G`                | Afficher les contrôles git               |
| `Space S G`                | Rechercher dans le contenu des fichiers             |
| `Ctrl + W W`               | Passer de la barre latérale à l'éditeur |
| `Ctrl + Left/right arrow`  | Modifier la taille de la barre latérale          |
| `Shift + H`                      | Aller à l'onglet de fichier de gauche             |
| `Shift + L`                      | Aller à l'onglet de fichier de droite            |
| `Space B D`                | Fermer l'onglet de fichier                  |

### Dans la barre latérale

| Raccourci                   | Fonction                        |
| ------------------------ | ------------------------------- |
| `A`                        | Ajouter un nouveau fichier dans le répertoire parent      |
| `Shift + A`                | Ajouter un nouveau sous-répertoire dans le répertoire parent    |
| `D`                        | Supprimer le fichier/répertoire en surbrillance     |
| `M`                        | Déplacer le fichier/répertoire en surbrillance       |
| `R`                        | Renommer le fichier/répertoire en surbrillance     |
| `?`                        | Afficher l'aide pour toutes les commandes      |

[Voir tous les raccourcis Neovim configurés par LazyVim](https://www.lazyvim.org/keymaps).

## Emojis rapides

Vous pouvez utiliser `Super + Ctrl + E` pour afficher un sélecteur d'emoji complet qui placera la sélection dans le presse-papiers, ou vous pouvez utiliser ces options d'accès rapide.

| Raccourci       | EM | Indice       |
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
| `Shift + CapsLock M K` | 😘 | bisou       |
| `Shift + CapsLock M E` | 🙄 | roulement des yeux    |
| `Shift + CapsLock M I` | 😉 | clin d'œil       |
| `Shift + CapsLock M P` | 🙏 | prier |
| `Shift + CapsLock M D` | 🤤 | baver      |
| `Shift + CapsLock M M` | 💰 | argent      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | bonjour |
| `Shift + CapsLock M A` |💪 | bras |
| `Shift + CapsLock M B` |🤯 | explosion |

## Complétions rapides

| Raccourci       | Complétion       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (tiret cadratin)   |
| `Shift + CapsLock Space N` | Votre nom (tel que saisi lors de la configuration)  |
| `Shift + CapsLock Space E` | Votre e-mail (tel que saisi lors de la configuration)  |

Vous pouvez en ajouter d'autres vous-même en modifiant `~/.XCompose`, puis en exécutant `omarchy restart xcompose` dans le terminal pour que les changements soient pris en compte.
