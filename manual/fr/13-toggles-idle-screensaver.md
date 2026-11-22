# Bascules, inactivité et économiseur d'écran

Un tas de choses que vous changez au quotidien ne sont pas vraiment des réglages. Ce sont des modes que vous activez pour une heure, puis que vous désactivez : l'éclairage nocturne quand vous travaillez tard, le mode ne pas déranger quand vous faites une présentation, rester éveillé quand vous regardez quelque chose. Omarchy appelle ça des bascules, et elles fonctionnent toutes de la même façon — un raccourci clavier, une entrée de menu et une commande, qui frappent tous le même interrupteur.

### Le menu des bascules

`Super + Ctrl + O` ouvre directement _Déclencheur > Bascules_, ou vous pouvez y aller depuis le menu Omarchy (`Super + Space`). Tout ce qui se trouve dans cette liste est un interrupteur que vous pouvez basculer sans réfléchir à l'endroit où l'état est stocké. Les interrupteurs pour l'apparence du bureau se trouvent juste à côté, sous _Apparence_.

Depuis le terminal, les mêmes interrupteurs sont `omarchy toggle <thing>`. Lancez `omarchy toggle` tout seul pour voir tout le groupe.

| Bascule | Raccourci | Commande |
| ------ | ------ | ------- |
| Éclairage nocturne | — | `omarchy toggle nightlight` |
| Mettre les notifications en silence | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Rester éveillé (pas de verrouillage en inactivité) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Capture de plantage | — | `omarchy toggle crash-capture` |
| Économiseur d'écran | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) synchronisation du thème | — | `omarchy toggle theme sync` |
| Barre de menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Bureau plein écran (pas de barre, pas d'espaces) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animations, flou et ombres | — | `omarchy toggle animations` |
| Pavé tactile | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Écran tactile | — | `omarchy device touchscreen` |
| Mise en veille | — | `omarchy toggle suspend` |
| GPU hybride | — | `omarchy device gpu hybrid` |

Le pavé tactile, l'écran tactile et le GPU hybride se trouvent sous _Déclencheur > Matériel_ (`Super + Ctrl + H`) plutôt que sous Bascules, puisqu'ils ne s'affichent que quand vous avez réellement ce matériel. Ceux du pavé tactile et de l'écran tactile survivent à un rechargement de Hyprland — le nom de l'appareil désactivé est enregistré dans un petit fichier d'état que Hyprland lit au démarrage pour le désactiver à nouveau.

_Apparence_ contient la barre de menu et les animations, plus quelques choses qui ne sont pas des commandes `omarchy toggle` mais qui se comportent de la même façon : le pourcentage de batterie dans la barre, la disposition par défaut des espaces de travail, et sous _Fenêtres_, les espaces entre fenêtres (`Super + Shift + Backspace`) et le format carré à 1 fenêtre (`Super + Ctrl + Backspace`).

Quand Hyprland n'a aucun GPU avec lequel dessiner et fait le rendu sur le CPU à la place (llvmpipe), comme sur les Mac dont le GPU n'est pas encore pris en charge, dans la plupart des machines virtuelles, ou quand un pilote graphique ne se charge pas, Omarchy désactive les animations, le flou et les ombres pour cette session et vous le dit une fois avec une notification. _Apparence > Animations activées_ les ramène, et Omarchy s'en souvient aussi pour les sessions suivantes.

La plupart de ces bascules ne sont qu'un fichier drapeau sous `~/.local/state/omarchy/toggles/`. Si vous voulez brancher sur l'une d'elles dans un script, `omarchy-toggle-enabled` vous donne un code de sortie au lieu de vous obliger à aller chercher :

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Les drapeaux sont nommés pour l'état désactivé — `screensaver-off`, `suspend-off`, `bar-off` — donc leur présence signifie que la fonctionnalité est désactivée.

### Indicateurs dans la barre

Quand un mode est actif, vous obtenez un petit glyphe au milieu de la barre supérieure, à côté de l'horloge. C'est le widget des indicateurs, et il porte l'enregistrement d'écran, les rappels en attente, l'éclairage nocturne, le mode ne pas déranger et rester éveillé, plus des avertissements quand sudo sans mot de passe est actif ou que quelqu'un est connecté à une session distante.

Les indicateurs inactifs sont masqués. Survolez n'importe où sur la barre et ils apparaissent en atténué, pour que vous puissiez cliquer sur l'un d'eux pour l'activer sans connaître son raccourci clavier. Cliquer sur un indicateur actif le désactive à nouveau. Si vous préférez tous les voir tout le temps, mettez `alwaysShow` à `true` sur l'entrée `omarchy.indicators` dans `~/.config/omarchy/shell.json` — voir [la barre supérieure](05-the-top-bar.md) pour savoir comment les widgets de la barre sont configurés.

### Éclairage nocturne

L'éclairage nocturne réchauffe l'écran à 4000K, et le basculer à nouveau le remet à 6500K. Basculez-le depuis le menu des bascules (`Super + Ctrl + O`) ou avec `omarchy toggle nightlight`. Il est piloté par hyprsunset, que la bascule démarre pour vous s'il n'est pas déjà en cours d'exécution.

Par défaut, hyprsunset ne fait absolument rien à votre écran. `~/.config/hypr/hyprsunset.conf` est livré avec un profil d'identité précisément pour que l'affichage reste intact jusqu'à ce que vous demandiez de la chaleur. Si vous préférez qu'il bascule selon l'horloge, remplacez ça par un profil horaire :

```
profile {
    time = 20:00
    temperature = 4000
}
```

Démarrez ensuite hyprsunset à la connexion en ajoutant `o.launch_on_start("hyprsunset")` à `~/.config/hypr/autostart.lua`. La paire 4000K/6500K utilisée par la bascule est fixe, donc le fichier de configuration est l'endroit où aller si vous voulez une température différente.

### Ne pas déranger

`Super + Ctrl + Alt + ,` met les notifications en silence. Aucun toast ne surgit tant qu'il est actif, et l'indicateur de cloche barrée se trouve dans la barre pour vous rappeler pourquoi le bureau est devenu silencieux.

Rien n'est perdu, cependant. Les notifications mises en silence sont retenues : remettez les dernières à l'écran avec `Super + Shift + Alt + ,`. Voir [avis](10-notices.md) pour le reste.

Trois sortes de messages passent quand même : les toasts de confirmation propres à Omarchy pour quelque chose que vous venez de faire (« Thème changé », « Capture d'écran enregistrée »), les alertes critiques envoyées depuis la ligne de commande, et les codes de vérification. Les applications de chat qui marquent tout comme critique pour se frayer un chemin devant vous n'entrent pas dans cette catégorie.

### Inactivité

Le shell Omarchy est responsable du comportement d'inactivité, et les délais sont un bloc `idle` de niveau supérieur dans `~/.config/omarchy/shell.json` :

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Les deux nombres sont des secondes comptées à partir du moment où vous êtes devenu inactif — pas l'un à partir de l'autre. Donc avec les valeurs par défaut, l'économiseur d'écran arrive après deux minutes et demie et l'écran de verrouillage prend le relais à cinq minutes, que l'économiseur d'écran ait fonctionné ou non. Enregistrez le fichier et le shell récupère les nouveaux délais tout de suite.

Si vous fermez l'économiseur d'écran avant l'échéance de verrouillage, ça compte comme une activité et le verrouillage en attente est annulé. Vous ne vous faites pas verrouiller dehors pour avoir jeté un coup d'œil à votre machine.

Pour arrêter complètement le verrouillage en inactivité, `Super + Ctrl + I` — ou `omarchy toggle idle` — active rester éveillé, et l'indicateur de tasse de café apparaît dans la barre. C'est celui sur lequel frapper avant une longue présentation ou un build que vous voulez regarder. Frappez-le à nouveau pour revenir à la normale. `omarchy toggle idle status` affiche l'état actuel en JSON si vous en avez besoin depuis un script.

Il s'agit ici du verrouillage et de l'économiseur d'écran, pas de l'alimentation. La mise en veille et l'hibernation ont leur propre configuration dans [veille du système](36-system-sleep.md).

### L'économiseur d'écran

L'économiseur d'écran d'Omarchy est de l'art ASCII qui passe par des effets de texte aléatoires, une instance par moniteur. N'importe quelle touche ou n'importe quel mouvement de souris en sort.

Vous pouvez le démarrer à la demande depuis _Système > Économiseur d'écran_ (`Super + Esc`), ce qui le force à s'afficher même si vous avez désactivé l'économiseur d'écran d'inactivité. Aucun raccourci clavier ne lui est associé par défaut.

`omarchy toggle screensaver` est ce qui désactive celui d'inactivité, si vous préférez passer directement du travail au verrouillage. N'importe quelle touche, clic, défilement ou mouvement de souris le ferme.

Le logo qu'il dessine est à vous de changer, sous _Apparence > Image de marque > Économiseur d'écran_. Téléversez un png ou un svg et Omarchy le convertit en ASCII. Voir [image de marque](41-branding.md).

### L'écran de verrouillage

`Super + Ctrl + L` verrouille la machine. Ça lance l'écran de verrouillage depuis le shell Omarchy, éteint l'affichage, réinitialise la disposition de votre clavier sur la première pour que vous ne tapiez pas votre mot de passe dans le mauvais alphabet, et — si vous l'avez en cours d'exécution — verrouille 1Password en sortant.

L'écran de verrouillage accepte un mot de passe, et il acceptera aussi une empreinte digitale une fois que vous en aurez configuré une. Ça, et les autres façons de s'authentifier, sont couverts dans [authentification matérielle](37-hardware-authentication.md).
