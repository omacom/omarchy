# La barre supérieure

La bande en haut de votre écran est la barre Omarchy. Ce n'est pas une barre d'état rapportée, mais une partie du shell Omarchy, l'unique processus Quickshell de longue durée qui dessine aussi le menu, les notifications, les popups OSD et l'écran de verrouillage. C'est pour ça qu'elle s'harmonise parfaitement avec tout le reste et qu'un panneau s'ouvre instantanément au lieu de lancer une nouvelle application.

C'est aussi le seul élément du bureau toujours à l'écran, alors ça vaut le coup de savoir à quoi servent tous ces petits glyphes.

## Ce qu'elle affiche par défaut

La barre comporte trois sections. À gauche se trouvent le logo Omarchy (le lanceur de menu) et les indicateurs d'espaces de travail. Au centre, vous avez les indicateurs d'état, l'horloge, Elsewhen (une horloge mondiale), la météo et un badge de mise à jour Omarchy. À droite : la zone de notification système, la disposition du clavier (quand plusieurs sont configurées), les agents, le bluetooth, le réseau, l'audio, l'affichage et l'alimentation.

Certains n'apparaissent que quand ils ont quelque chose à dire. La disposition du clavier n'apparaît que si vous en avez configuré plusieurs. Le badge de mise à jour n'apparaît que quand une mise à jour Omarchy est en attente. Et l'icône des agents apparaît la première fois qu'Omarchy trouve une utilisation d'IA de codage sur la machine (voir [IA](17-ai.md)).

## Cliquer partout

Presque chaque widget fait quelque chose au clic gauche, droit et du milieu, et plusieurs réagissent au défilement. C'est la partie que les gens ratent — c'est sur les boutons droit et du milieu que se cache une bonne partie des meilleures choses.

| Widget | Clic gauche | Clic droit | Clic du milieu / défilement |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Nouveau terminal | — |
| Espaces de travail | Placer le focus sur cet espace de travail sur ce moniteur | — | Défilement : espace de travail suivant/précédent |
| Horloge | Popup de calendrier | Faire défiler les formats d'étiquette | Clic du milieu : sélecteur de fuseau horaire |
| Météo | Popup de prévisions | Météo complète sous forme de notification | Clic du milieu : actualiser |
| Audio | Panneau audio | Couper le son | Clic du milieu : panneau · défilement : volume |
| Microphone | Couper le micro | — | Clic du milieu : panneau audio · défilement : volume d'entrée |
| Réseau | Panneau réseau | — | — |
| Bluetooth | Panneau Bluetooth | Activer/désactiver la radio | — |
| Affichage | Panneau d'affichage | — | Défilement : luminosité |
| Alimentation | Panneau d'alimentation | Activer/désactiver le pourcentage de batterie | — |
| Média | Lecture/pause | Popup de la pochette | Clic du milieu : suivant · défilement : précédent/suivant |
| Agents | Panneau des agents | Lancer votre agent | Clic du milieu : abonnement suivant |
| Zone de notification | Survoler pour révéler le tiroir | Clic droit sur le chevron pour gérer | — |
| Mise à jour Omarchy | Lancer la mise à jour | — | — |

Tout ce qui figure dans ce tableau n'est pas sur votre barre dès l'installation. Le widget média (lecture en cours MPRIS, avec piste et artiste défilants) et le widget microphone sont tous deux intégrés mais désactivés par défaut — ajoutez-les si vous les voulez, comme décrit ci-dessous.

## Les panneaux

Cliquer sur une icône de la barre ouvre un panneau, qui est un vrai popup avec curseurs, listes et navigation au clavier plutôt qu'une infobulle. Chacun a aussi un raccourci clavier, pour ne jamais avoir à viser un glyphe de 16 pixels :

| Raccourci clavier | Panneau |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Réseau |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Affichage |
| `Super + Ctrl + P` | Alimentation |
| `Super + Ctrl + Alt + D` | Calendrier |
| `Super + Ctrl + Alt + E` | Horloge mondiale |
| `Super + Ctrl + 1-9` | Activer/désactiver le énième panneau dans la section de droite |

Les panneaux ne sont pas des affichages en lecture seule. C'est là que vous faites vraiment la chose :

- **Audio** a un curseur de volume principal, un sélecteur de périphérique de sortie et un mixeur par application, pour pouvoir baisser le son de cet onglet de navigateur sans toucher à tout le reste.
- **Réseau** recherche les réseaux Wi-Fi, affiche la force du signal, se connecte et vous laisse choisir un fournisseur DNS.
- **Bluetooth** liste vos appareils avec connexion/déconnexion et niveaux de batterie.
- **Alimentation** affiche les statistiques de batterie, change de profil d'alimentation (il retient un choix distinct pour la batterie et pour le secteur AC) et affiche quelques informations système.
- **Affichage** propose un curseur de luminosité, la taille du texte, des préréglages de mise à l'échelle du moniteur et — quand vous avez plus d'un écran — des contrôles par moniteur. Voir [moniteurs](33-monitors.md) pour aller plus loin.
- **Horloge** ouvre une grille mensuelle avec numéros de semaine ISO et navigation de mois en mois.
- **Horloge mondiale** conserve une ligne par ville, avec sa météo et le déroulement de sa journée. La recherche trouve les villes aussi bien que les fuseaux horaires, donc Fort Lauderdale est Fort Lauderdale et pas New York. Si la ligne en haut indique la mauvaise ville, cliquez dessus et dites où vous êtes ; choisissez un endroit dans un autre fuseau horaire et l'horloge système s'y déplace aussi, ce qui est pratique quand vous voyagez. Survolez une ville et cliquez sur le bouton en forme de personne pour dire qui y vit — des noms simples, ou des identifiants GitHub `@` pour y faire venir leurs visages.

Chaque panneau accepte le clavier aussi bien que la souris : les flèches déplacent, Return active, Tab passe au panneau voisin et Escape ferme.

`Super + Ctrl + 1-9` compte les panneaux de gauche à droite dans la section de droite, en sautant la zone de notification puisqu'elle n'a pas de panneau propre. Le numéro correspond donc à l'icône que vous montreriez du doigt.

### Tailscale et Dropbox

Deux widgets supplémentaires n'apparaissent sur la barre qu'une fois que vous avez installé le service correspondant depuis **Install → Service**, et les deux méritent d'être connus parce qu'ils font plus que rapporter un état.

Le panneau **Tailscale** connecte et déconnecte le tailnet, passe d'un compte à l'autre et choisit un nœud de sortie (vos propres machines et les régions Mullvad apparaissent toutes dans cette liste). Il parcourt aussi vos machines — et avec une machine sélectionnée, `s` lui envoie des fichiers via Taildrop, ce qui est le moyen le plus rapide de déplacer un fichier vers votre téléphone ou un autre ordinateur portable. `c` copie l'IP de la machine, `n` son nom et `d` son nom DNS complet. Il y a aussi un bouton d'envoi sur chaque ligne de machine, si vous préférez cliquer. La même chose depuis le terminal est `omarchy tailscale send <machine> [file...]`.

Le panneau **Dropbox** gère la connexion, affiche l'espace de stockage que vous avez utilisé et liste les fichiers récemment synchronisés.

Retirer l'un ou l'autre service enlève aussi son widget de la barre.

## Indicateurs

Le petit groupe au centre est le widget des indicateurs. Ce sont des glyphes d'état pour les modes que vous avez activés : ne pas déranger, lumière nocturne, un [rappel](09-reminders.md) en file d'attente, un enregistrement d'écran actif, rester éveillé et la [dictée](11-text-extraction-dictation.md). Ils s'allument quand le mode est actif et sinon se font discrets — survolez n'importe quel endroit de la barre pour jeter un œil aux inactifs. Cliquer sur un indicateur active ou désactive ce mode. Un autre est en lecture seule : une session à distance s'allume en rouge tant que quelqu'un est connecté à cette machine via gliff.

Si vous préférez qu'ils soient toujours visibles, définissez `alwaysShow` sur `true` sur le widget. Et si seuls certains d'entre eux vous intéressent, listez ceux que vous voulez dans `items` : `["Dnd", "Reminder", "NightLight"]`. Vous pouvez avoir plus d'un widget d'indicateurs, pour que différentes sections affichent différents sous-ensembles.

## Réorganiser la barre

La barre se configure elle-même. Vous n'avez pas à ouvrir un fichier de configuration pour déplacer les choses.

Attrapez un coin vide de la barre autour du centre et faites-le glisser vers un autre bord de l'écran, et la barre s'y déplace — gauche, droite, haut ou bas fonctionnent tous, et chaque widget s'adapte (les barres verticales reviennent à des formes compactes avec icônes seules). Un clic maintenu lance le même glisser. Double-cliquez avec le bouton gauche sur ce même espace vide pour faire défiler l'arrière-plan de la barre de transparent à vitré à opaque. Et faites glisser n'importe quel widget pour le réordonner ou le jeter dans une autre section ; les autres widgets s'écartent pour faire de la place là où il atterrira.

Le milieu de la barre est une boîte : tout ce qui s'y trouve reste centré comme un seul groupe, et les widgets de chaque côté pendent à ses bords. Pendant que vous faites glisser un widget, la boîte s'affiche comme un contour, ou comme une ligne à travers la barre quand elle est vide, et vous pouvez déposer dedans ou à côté. Quand un dépôt atterrirait dans la boîte, la boîte grandit pour accueillir le widget.

Un widget que vous voulez garder sous la main mais pas toujours en vue peut aller dans le tiroir de la zone de notification : faites-le glisser sur la zone de notification, et le tiroir s'ouvre pour le prendre. Il y reste après les icônes d'applications, apparaît chaque fois que le tiroir le fait et garde son tiroir ouvert pendant que son panneau est affiché. Faites-le glisser à nouveau sur la barre pour le remettre en place.

Si vous préférez choisir depuis un menu, **Appearance → Menu Bar** propose la position, et **Bar Background** choisit la façon dont la barre est dessinée : **Opaque Bar**, **Glassy Bar** (transparente, avec ce qui se trouve derrière flouté) ou **Clear Bar**.

Les mêmes choses existent en commandes, ce qui est ce qu'il vous faut pour une installation [dotfiles](31-dotfiles.md) :

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Pour ajouter ou retirer entièrement un widget, utilisez les commandes de plugin. `omarchy plugin list` affiche chaque widget connu du shell avec son id, et ensuite :

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Masquer la barre

`Super + Shift + Space` masque la barre et la réaffiche sans tuer le shell — les panneaux et les raccourcis clavier continuent de fonctionner, vous récupérez juste les pixels. C'est aussi dans le menu sous **Appearance → Menu Bar → Hide Bar**.

## Le fichier de configuration

Tout est stocké dans `~/.config/omarchy/shell.json`, sous la clé `bar`. Voici une version réduite :

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Chaque widget est une entrée dans l'un des cinq tableaux de disposition, et ses réglages se trouvent en ligne sur cette entrée — il n'y a pas de fichier de réglages séparé et pas de sous-objet `config`. Le `format` de l'horloge, `formatAlt` (ce vers quoi le clic droit fait défiler) et `verticalFormat` vivent tous là, sur `{ "id": "omarchy.clock" }`.

`center` est la boîte au milieu de la barre : tout ce qui s'y trouve est centré sur l'écran comme un seul groupe. `centerBegin` et `centerEnd` pendent de chaque côté de la boîte, ce qui permet à l'horloge de rester parfaitement au centre même quand la météo et le badge de mise à jour vont et viennent. Mettez plus d'un widget dans `center` et ils sont centrés ensemble ; laissez-le vide et `centerBegin` et `centerEnd` se rejoignent au milieu de la barre.

Une règle qui vaut la peine d'être intériorisée : **une fois que vous avez votre propre `shell.json`, il fait foi**. Tant que vous ne personnalisez rien, le shell lit le fichier par défaut d'Omarchy. Dès que vous faites glisser un widget, lancez `omarchy bar` ou modifiez le fichier vous-même, il vous appartient — il n'y a pas de fusion profonde, donc les nouveaux widgets par défaut des futures versions d'Omarchy n'apparaîtront pas automatiquement sur votre barre. `omarchy bar defaults` remet la disposition livrée en place dès que vous voulez repartir d'une page blanche.

Le même fichier contient aussi vos délais d'inactivité au niveau supérieur, en dehors de la clé `bar` : `idle.screensaver` et `idle.lock`, tous deux en secondes depuis que vous êtes devenu inactif. Donc l'économiseur d'écran par défaut se déclenche à 150 secondes et le verrouillage à 300.
