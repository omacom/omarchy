# La barre supérieure

La bande le long du haut de votre écran est la barre Omarchy. Ce n'est pas une barre d'état boulonnée, mais une partie du shell Omarchy, le processus Quickshell de longue durée qui dessine aussi le menu, les notifications, les popups OSD et l'écran de verrouillage. C'est pourquoi elle s'accorde parfaitement en thème avec tout le reste et pourquoi un panneau s'ouvre instantanément au lieu de lancer une nouvelle appli.

C'est aussi le seul élément du bureau toujours à l'écran, donc cela vaut la peine de savoir ce que font tous ces petits glyphes.

## Ce qu'elle contient par défaut

La barre a trois sections. À gauche se trouve le logo Omarchy (le lanceur de menu) et les indicateurs d'espaces de travail. Au centre, vous avez les indicateurs d'état, l'horloge, Elsewhen (une horloge mondiale), la météo et un badge de mise à jour Omarchy. À droite : la disposition du clavier (lorsque plusieurs sont configurées), la zone de notification système, les agents, le bluetooth, le réseau, l'audio, l'affichage et l'alimentation.

Quelques-uns n'apparaissent que lorsqu'ils ont quelque chose à dire. La disposition du clavier n'apparaît que si vous en avez configuré plus d'une. Le badge de mise à jour n'apparaît que lorsqu'une mise à jour Omarchy attend. Et l'icône agents apparaît la première fois qu'Omarchy trouve une utilisation d'IA de codage sur la machine (voir [IA](17-ai.md)).

## Cliquer partout

Presque chaque widget fait quelque chose au clic gauche, droit et central, et plusieurs répondent au défilement. C'est la partie que les gens manquent — les boutons droit et central sont là où se cache une grande partie des bonnes choses.

| Widget | Gauche | Droit | Centre / défilement |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Nouveau terminal | — |
| Espaces de travail | Focus sur cet espace | — | Défilement : espace suivant/précédent |
| Horloge | Popup calendrier | Faire défiler le format du libellé | Centre : sélecteur de fuseau horaire |
| Météo | Popup prévisions | Météo complète en notification | Centre : actualiser |
| Audio | Panneau audio | Couper le son | Centre : panneau · défilement : volume |
| Microphone | Couper le micro | — | Centre : panneau audio · défilement : volume d'entrée |
| Réseau | Panneau réseau | — | — |
| Bluetooth | Panneau Bluetooth | Basculer la radio | — |
| Affichage | Panneau affichage | — | Défilement : luminosité |
| Alimentation | Panneau alimentation | Basculer le pourcentage batterie | — |
| Média | Lecture/pause | Popup pochette | Centre : suivant · défilement : précédent/suivant |
| Agents | Panneau agents | Lancer votre agent | Centre : abonnement suivant |
| Zone de notification | Survoler pour révéler le tiroir | Clic droit sur le chevron pour gérer | — |
| Mise à jour Omarchy | Lancer la mise à jour | — | — |

Tout ce qui figure dans ce tableau n'est pas sur votre barre dès l'installation. Le widget média (lecture en cours MPRIS, avec piste et artiste défilants) et le widget microphone sont tous deux intégrés mais désactivés par défaut — ajoutez-les si vous les voulez, comme décrit ci-dessous.

## Les panneaux

Cliquer sur une icône de la barre ouvre un panneau, qui est un vrai popup avec curseurs, listes et navigation au clavier plutôt qu'une infobulle. Chacun a aussi un raccourci, de sorte que vous n'avez jamais à viser un glyphe de 16 pixels :

| Raccourci | Panneau |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + W` | Réseau |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Affichage |
| `Super + Ctrl + P` | Alimentation |
| `Super + Ctrl + Alt + D` | Calendrier |
| `Super + Ctrl + Alt + E` | Horloge mondiale |
| `Super + Ctrl + 1-9` | Basculer le nième panneau de la section de droite |

Les panneaux ne sont pas de simples lectures. C'est là où vous faites réellement la chose :

- **Audio** a un curseur de volume principal, un sélecteur de périphérique de sortie et un mélangeur par appli, de sorte que vous pouvez baisser ce seul onglet de navigateur sans toucher au reste.
- **Réseau** recherche les réseaux Wi-Fi, affiche la puissance du signal, connecte, et vous laisse choisir un fournisseur DNS.
- **Bluetooth** liste vos appareils avec connexion/déconnexion et niveaux de batterie.
- **Alimentation** affiche les statistiques de batterie, change les profils d'alimentation (il se souvient d'un choix séparé pour la batterie et le secteur), et affiche quelques informations système.
- **Affichage** comporte un curseur de luminosité, la taille du texte, des préréglages d'échelle d'écran, et — lorsque vous avez plus d'un écran — des contrôles par écran. Voir [écrans](33-monitors.md) pour l'histoire complète.
- **Horloge** ouvre une grille mensuelle avec numéros de semaine ISO et navigation par mois.

Chaque panneau accepte le clavier aussi bien que la souris : les flèches déplacent, Entrée active, Tab passe au panneau voisin, et Échap ferme.

`Super + Ctrl + 1-9` compte les panneaux de gauche à droite dans la section de droite, en sautant la zone de notification puisqu'elle n'a pas de panneau propre. Le numéro correspond donc à l'icône que vous viseriez.

### Tailscale et Dropbox

Deux widgets supplémentaires apparaissent sur la barre seulement une fois que vous avez installé le service correspondant depuis **Installer → Service**, et les deux valent la peine d'être connus parce qu'ils font plus que rapporter un état.

Le panneau **Tailscale** connecte et déconnecte le tailnet, bascule entre les comptes et choisit un nœud de sortie (vos propres machines et les régions Mullvad apparaissent tous deux dans cette liste). Il parcourt aussi vos machines — et avec l'une sélectionnée, `s` lui envoie des fichiers via Taildrop, ce qui est le moyen le plus rapide de déplacer un fichier vers votre téléphone ou un autre portable. `c` copie l'IP de la machine, `n` son nom, et `d` son nom DNS complet. Il y a aussi un bouton d'envoi sur chaque ligne de machine, si vous préférez cliquer. La même chose depuis le terminal est `omarchy tailscale send <machine> [file...]`.

Le panneau **Dropbox** gère la connexion, montre combien de stockage vous avez utilisé, et liste les fichiers récemment synchronisés.

Supprimer l'un ou l'autre service retire son widget de la barre.

## Indicateurs

Le petit groupe au centre est le widget indicateurs. Ce sont des glyphes d'état pour les modes que vous avez activés : ne pas déranger, éclairage nocturne, un [rappel](09-reminders.md) en file, un enregistrement d'écran actif, rester éveillé, et [dictée](11-text-extraction-dictation.md). Ils s'allument lorsque le mode est actif et restent sinon à l'écart — survolez à gauche de l'horloge (au-dessus sur une barre verticale) pour apercevoir les inactifs. Cliquer sur un indicateur bascule ce mode. Un de plus est seulement un état : une session distante s'allume en rouge pendant que quelqu'un est connecté à cette machine via gliff.

Si vous préférez qu'ils soient toujours visibles, définissez `alwaysShow` à `true` sur le widget. Et si seuls certains vous intéressent, listez ceux que vous voulez dans `items` : `["Dnd", "Reminder", "NightLight"]`. Vous pouvez avoir plus d'un widget indicateurs, de sorte que différentes sections peuvent afficher des sous-ensembles différents.

## Réorganiser la barre

La barre se configure elle-même. Vous n'avez pas à ouvrir de fichier de configuration pour déplacer des choses.

Attrapez une zone vide de la barre autour du centre et faites-la glisser vers un autre bord d'écran, et la barre s'y déplacera — gauche, droite, haut ou bas fonctionnent tous, et chaque widget s'adapte (les barres verticales reviennent à des formes compactes icône seule). Un clic maintenu démarre le même glissement. Double-cliquez avec le bouton gauche sur ce même espace vide pour faire passer le fond de la barre de transparent à vitré à opaque. Et faites glisser n'importe quel widget pour le réordonner ou le jeter dans une autre section.

Un widget que vous souhaitez garder à portée de main sans l'avoir toujours sous les yeux peut aller dans le tiroir de la zone de notification : faites-le glisser sur la zone de notification, et le tiroir s'ouvre pour l'accueillir. Il y prend place après les icônes des applis, apparaît chaque fois que le tiroir s'ouvre, et garde son tiroir ouvert tant que son panneau est affiché. Faites-le glisser en sens inverse sur la barre pour le remettre en place.

Si vous préférez choisir depuis un menu, **Déclencher → Apparence → Barre de menu** a la position, et **Fond de la barre** choisit comment la barre est dessinée : **Barre opaque**, **Barre vitrée** (transparente, avec ce qu'il y a derrière flouté), ou **Barre transparente**.

Les mêmes choses ont des commandes, ce qui est ce que vous voulez pour une configuration [dotfiles](31-dotfiles.md) :

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Pour ajouter ou retirer complètement un widget, utilisez les commandes plugin. `omarchy plugin list` affiche chaque widget que le shell connaît avec son id, et ensuite :

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Masquer la barre

`Super + Shift + Space` bascule la barre entre éteinte et allumée sans tuer le shell — panneaux et raccourcis continuent de fonctionner, vous récupérez simplement les pixels. C'est aussi dans le menu sous **Déclencher → Apparence → Barre de menu → Masquer la barre**.

## Le fichier de configuration

Tout est stocké dans `~/.config/omarchy/shell.json`, sous la clé `bar`. Voici une version allégée :

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Chaque widget est une entrée dans l'un des trois tableaux de disposition, et ses réglages se trouvent en ligne sur cette entrée — il n'y a pas de fichier de réglages séparé ni de sous-objet `config`. Le `format` de l'horloge, `formatAlt` (ce vers quoi le clic droit fait défiler) et `verticalFormat` vivent tous là, sur `{ "id": "omarchy.clock" }`.

`centerAnchor` nomme le seul widget central épinglé au centre exact de l'écran, les autres le flanquant. C'est ainsi que l'horloge reste bien au centre même lorsque la météo et le badge de mise à jour vont et viennent. Définissez-le à une chaîne vide et la liste centrale est simplement centrée en tant que groupe.

Une règle à assimiler : **une fois que vous avez votre propre `shell.json`, il est canonique**. Jusqu'à ce que vous personnalisiez quoi que ce soit, le shell lit le fichier par défaut d'Omarchy. Au moment où vous faites glisser un widget, exécutez `omarchy bar`, ou éditez le fichier vous-même, il vous appartient — il n'y a aucune fusion profonde, de sorte que les nouveaux widgets par défaut des futures versions d'Omarchy n'apparaîtront pas automatiquement sur votre barre. `omarchy bar defaults` remet la disposition livrée quand vous voulez repartir de zéro.

Le même fichier contient aussi vos délais d'inactivité au niveau supérieur, en dehors de la clé `bar` : `idle.screensaver` et `idle.lock`, tous deux en secondes depuis que vous êtes devenu inactif. Ainsi, l'écran de veille par défaut se déclenche à 150 secondes et le verrouillage à 300.
