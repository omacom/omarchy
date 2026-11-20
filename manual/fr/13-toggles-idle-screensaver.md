# Bascules, inactivité et économiseur d’écran

Beaucoup de ce que vous changez au quotidien n’est pas vraiment un réglage. C’est un mode que vous activez pour une heure puis que vous désactivez : lumière nocturne pendant que vous travaillez tard, ne pas déranger pendant que vous présentez, rester éveillé pendant que vous regardez quelque chose. Omarchy appelle cela des bascules, et elles fonctionnent toutes de la même manière — un raccourci clavier, une entrée de menu et une commande, qui agissent tous sur le même interrupteur.

### Le menu des bascules

`Super + Ctrl + O` ouvre directement _Déclencheur > Bascule_, ou vous pouvez vous y rendre depuis le menu Omarchy (`Super + Space`). Tout ce qui se trouve dans cette liste est un interrupteur que vous pouvez actionner sans réfléchir à l’endroit où vit l’état. Les interrupteurs pour l’apparence du bureau se trouvent juste à côté, sous _Apparence_.

Depuis le terminal, les mêmes interrupteurs sont `omarchy toggle <thing>`. Exécutez `omarchy toggle` tout seul pour voir l’ensemble du groupe.

| Bascule | Raccourci clavier | Commande |
| ------ | ------ | ------- |
| Lumière nocturne | — | `omarchy toggle nightlight` |
| Silencer les notifications | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Rester éveillé (pas de verrouillage en cas d’inactivité) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Capture de plantage | — | `omarchy toggle crash-capture` |
| Économiseur d’écran | — | `omarchy toggle screensaver` |
| Synchronisation du thème [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barre de menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Pavé tactile | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Écran tactile | — | `omarchy device touchscreen` |
| Suspendre | — | `omarchy toggle suspend` |
| GPU hybride | — | `omarchy toggle hybrid gpu` |

Les interrupteurs du pavé tactile, de l’écran tactile et du GPU hybride se trouvent sous _Déclencheur > Matériel_ (`Super + Ctrl + H`) plutôt que sous Bascule, car ils n’apparaissent que lorsque vous disposez réellement de ce matériel. Ceux du pavé tactile et de l’écran tactile survivent à un rechargement de Hyprland — le nom de l’appareil désactivé est enregistré dans un petit fichier d’état que Hyprland lit au démarrage pour le désactiver à nouveau.

_Apparence_ contient la barre de menu et les animations, plus quelques éléments qui ne sont pas des commandes `omarchy toggle` mais se comportent de la même manière : le pourcentage de batterie dans la barre, la disposition par défaut de l’espace de travail, et sous _Fenêtres_, les espacements entre fenêtres (`Super + Shift + Backspace`) et le format carré pour 1 fenêtre (`Super + Ctrl + Backspace`).

Lorsque Hyprland n’a aucun GPU avec lequel dessiner et effectue le rendu sur le CPU à la place (llvmpipe), comme sur les Mac dont le GPU n’est pas encore pris en charge, dans la plupart des machines virtuelles, ou lorsqu’un pilote graphique ne parvient pas à se charger, Omarchy désactive les animations, le flou et les ombres pour cette session et vous en informe une seule fois par une notification. _Apparence > Animations activées_ les réactive, et Omarchy s’en souvient aussi pour les sessions suivantes.

La plupart d’entre elles ne sont qu’un fichier indicateur sous `~/.local/state/omarchy/toggles/`. Si vous voulez bifurquer sur l’une d’elles dans un script, `omarchy-toggle-enabled` vous donne un code de sortie au lieu de vous obliger à aller le chercher :

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Les indicateurs sont nommés d’après l’état désactivé — `screensaver-off`, `suspend-off`, `bar-off` — donc leur présence signifie que la fonctionnalité est désactivée.

### Indicateurs dans la barre

Lorsqu’un mode est actif, vous obtenez un petit glyphe au milieu de la barre supérieure, à côté de l’horloge. C’est le widget des indicateurs, et il regroupe la dictée, l’enregistrement d’écran, les rappels en attente, la lumière nocturne, le mode ne pas déranger et le mode rester éveillé.

Les indicateurs inactifs sont masqués. Survolez n’importe quel endroit de la barre et ils apparaissent en fondu, atténués, pour que vous puissiez cliquer sur l’un d’eux pour l’activer sans connaître son raccourci clavier. Cliquez sur un indicateur actif pour le désactiver à nouveau. Si vous préférez les voir tous en permanence, définissez `alwaysShow` sur `true` sur l’entrée `omarchy.indicators` dans `~/.config/omarchy/shell.json` — voir [la barre supérieure](05-the-top-bar.md) pour savoir comment les widgets de la barre sont configurés.

### Lumière nocturne

La lumière nocturne réchauffe l’écran à 4000K, et la basculer à nouveau le ramène à 6500K. Activez-la depuis le menu des bascules (`Super + Ctrl + O`) ou avec `omarchy toggle nightlight`. Elle est pilotée par hyprsunset, que la bascule démarre pour vous s’il n’est pas déjà en cours d’exécution.

Par défaut, hyprsunset ne fait absolument rien à votre écran. `~/.config/hypr/hyprsunset.conf` est livré avec un profil d’identité précisément pour que l’affichage reste intact jusqu’à ce que vous demandiez de la chaleur. Si vous préférez qu’il bascule selon l’horloge, remplacez cela par un profil horaire :

```
profile {
    time = 20:00
    temperature = 4000
}
```

Démarrez ensuite hyprsunset à la connexion en ajoutant `o.launch_on_start("hyprsunset")` à `~/.config/hypr/autostart.lua`. La paire 4000K/6500K utilisée par la bascule est fixe, donc le fichier de configuration est l’endroit où aller si vous voulez une température différente.

### Ne pas déranger

`Super + Ctrl + Alt + ,` coupe les notifications. Aucun toast ne s’affiche pendant qu’il est actif, et l’indicateur en forme de cloche barrée se trouve dans la barre pour vous rappeler pourquoi le bureau est devenu silencieux.

Rien n’est perdu pour autant. Les notifications coupées sont mises en attente : remettez les dernières à l’écran avec `Super + Shift + Alt + ,`. Voir [notifications](10-notices.md) pour le reste.

Deux types de messages passent quand même : les toasts de confirmation d’Omarchy pour quelque chose que vous venez de faire (« Theme changed », « Screenshot saved »), et les alertes critiques envoyées depuis la ligne de commande. Les applications de messagerie qui marquent tout comme critique pour se frayer un chemin devant vous n’en font pas partie.

### Inactivité

Le shell Omarchy gère le comportement en cas d’inactivité, et les délais se trouvent dans un bloc `idle` de niveau supérieur dans `~/.config/omarchy/shell.json` :

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Les deux nombres sont des secondes comptées à partir du moment où vous êtes devenu inactif — pas l’un à partir de l’autre. Ainsi, avec les valeurs par défaut, l’économiseur d’écran apparaît après deux minutes et demie et l’écran de verrouillage prend le relais à cinq minutes, que l’économiseur d’écran se soit lancé ou non. Enregistrez le fichier et le shell récupère immédiatement les nouveaux délais.

Si vous fermez l’économiseur d’écran avant l’échéance du verrouillage, cela compte comme une activité et le verrouillage en attente est annulé. Vous ne vous faites pas verrouiller dehors pour avoir jeté un coup d’œil à votre machine.

Pour arrêter complètement le verrouillage en cas d’inactivité, `Super + Ctrl + I` — ou `omarchy toggle idle` — active le mode rester éveillé, et l’indicateur en forme de tasse de café apparaît dans la barre. C’est celui à activer avant une longue présentation ou une compilation que vous voulez surveiller. Appuyez à nouveau pour revenir à la normale. `omarchy toggle idle status` affiche l’état actuel au format JSON si vous en avez besoin depuis un script.

Il s’agit du verrouillage et de l’économiseur d’écran, pas de l’alimentation. La suspension et l’hibernation ont leur propre configuration dans [veille du système](36-system-sleep.md).

### L’économiseur d’écran

L’économiseur d’écran d’Omarchy est un art ASCII traversé par des effets de texte aléatoires, une instance par moniteur. N’importe quelle touche ou n’importe quel mouvement de souris le quitte.

Vous pouvez le démarrer à la demande depuis _Système > Économiseur d’écran_ (`Super + Esc`), ce qui le force à s’afficher même si vous avez désactivé l’économiseur d’écran en cas d’inactivité. Aucun raccourci clavier ne lui est attribué par défaut.

`omarchy toggle screensaver` est ce qui désactive celui lié à l’inactivité, si vous préférez passer directement du travail au verrouillage. N’importe quelle touche, n’importe quel clic, défilement ou mouvement de souris le ferme.

Le logo qu’il dessine vous appartient et peut être modifié, sous _Apparence > Image de marque > Économiseur d’écran_. Téléversez un png ou un svg et Omarchy le convertit en ASCII. Voir [image de marque](41-branding.md).

### L’écran de verrouillage

`Super + Ctrl + L` verrouille la machine. Cela lance l’écran de verrouillage depuis le shell Omarchy, éteint l’affichage, réinitialise la disposition de votre clavier sur la première pour que vous ne tapiez pas votre mot de passe dans le mauvais alphabet, et — si vous l’avez en cours d’exécution — verrouille 1Password au passage.

L’écran de verrouillage accepte un mot de passe, et il acceptera aussi une empreinte digitale une fois que vous en aurez configuré une. Cela, et les autres moyens d’authentification, sont couverts dans [authentification matérielle](37-hardware-authentication.md).
