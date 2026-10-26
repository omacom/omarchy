# Bascules, inactivité et l'économiseur d'écran

Beaucoup de ce que vous changez au quotidien n'est pas vraiment un réglage. C'est un mode que vous activez pour une heure puis que vous désactivez : la lumière nocturne quand vous travaillez tard, ne pas déranger quand vous faites une présentation, rester éveillé quand vous regardez quelque chose. Omarchy appelle cela des bascules, et elles fonctionnent toutes de la même manière — un raccourci clavier, une entrée de menu et une commande, tous sur le même interrupteur.

### Le menu des bascules

`Super + Ctrl + O` ouvre directement _Déclencheur > Bascules_, ou vous pouvez y aller depuis le menu Omarchy (`Super + Space`). Tout ce qui figure dans cette liste est un interrupteur que vous pouvez basculer sans vous demander où vit l'état. Les interrupteurs pour l'apparence du bureau se trouvent juste à côté, sous _Apparence_.

Depuis le terminal, les mêmes interrupteurs sont `omarchy toggle <thing>`. Lancez `omarchy toggle` tout seul pour voir tout le groupe.

| Basculement | Raccourci clavier | Commande |
| ------ | ------ | ------- |
| Lumière nocturne | — | `omarchy toggle nightlight` |
| Silence des notifications | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Rester éveillé (pas de verrouillage pour inactivité) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Capture des plantages | — | `omarchy toggle crash-capture` |
| Économiseur d'écran | — | `omarchy toggle screensaver` |
| Synchronisation du thème [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barre de menus | `Super + Shift + Space` | `omarchy toggle bar` |
| Pavé tactile | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Écran tactile | — | `omarchy toggle touchscreen` |
| Mise en veille | — | `omarchy toggle suspend` |
| GPU hybride | — | `omarchy toggle hybrid gpu` |

Les interrupteurs du pavé tactile, de l'écran tactile et du GPU hybride se trouvent sous _Déclencheur > Matériel_ (`Super + Ctrl + H`) plutôt que sous Bascules, puisqu'ils n'apparaissent que lorsque vous avez réellement ce matériel. Ceux du pavé tactile et de l'écran tactile survivent à un rechargement de Hyprland — le nom de l'appareil désactivé est enregistré dans un petit fichier d'état que Hyprland lit au démarrage pour le désactiver à nouveau.

_Apparence_ contient la barre de menus et les animations, plus quelques éléments qui ne sont pas des commandes `omarchy toggle` mais se comportent de la même manière : le pourcentage de batterie dans la barre, la disposition par défaut de l'espace de travail, et sous _Fenêtres_, les écarts entre fenêtres (`Super + Shift + Backspace`) et le format carré pour 1 fenêtre (`Super + Ctrl + Backspace`).

La plupart sont simplement un fichier drapeau sous `~/.local/state/omarchy/toggles/`. Si vous voulez tester l'un d'eux dans un script, `omarchy-toggle-enabled` vous donne un code de sortie au lieu de vous obliger à aller chercher :

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Les drapeaux sont nommés d'après l'état désactivé — `screensaver-off`, `suspend-off`, `bar-off` — donc leur présence signifie que la fonctionnalité est désactivée.

### Indicateurs dans la barre

Quand un mode est actif, vous obtenez un petit glyphe au milieu de la barre supérieure, à côté de l'horloge. C'est le widget des indicateurs, et il regroupe la dictée, l'enregistrement d'écran, les rappels en attente, la lumière nocturne, ne pas déranger et rester éveillé.

Les indicateurs inactifs sont masqués. Survolez n'importe où sur la barre et ils apparaissent en fondu atténué, pour que vous puissiez cliquer sur l'un d'eux pour l'activer sans connaître son raccourci clavier. Cliquer sur un indicateur actif le désactive. Si vous préférez les voir tous en permanence, définissez `alwaysShow` à `true` sur l'entrée `omarchy.indicators` dans `~/.config/omarchy/shell.json` — voir [la barre supérieure](05-the-top-bar.md) pour savoir comment les widgets de la barre sont configurés.

### Lumière nocturne

La lumière nocturne réchauffe l'écran à 4000K, et la basculer à nouveau le remet à 6500K. Basculez-la depuis le menu des bascules (`Super + Ctrl + O`) ou avec `omarchy toggle nightlight`. Elle est pilotée par hyprsunset, que la bascule démarre pour vous s'il ne tourne pas déjà.

Par défaut, hyprsunset ne fait absolument rien à votre écran. `~/.config/hypr/hyprsunset.conf` est livré avec un profil neutre précisément pour que l'affichage reste intact jusqu'à ce que vous demandiez de la chaleur. Si vous préférez qu'il bascule selon l'horloge, remplacez-le par un profil horaire :

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ensuite, démarrez hyprsunset à la connexion en ajoutant `o.launch_on_start("hyprsunset")` à `~/.config/hypr/autostart.lua`. La paire 4000K/6500K utilisée par la bascule est fixe, donc le fichier de configuration est l'endroit où aller si vous voulez une température différente.

### Ne pas déranger

`Super + Ctrl + Alt + ,` met les notifications en silence. Aucun toast n'apparaît tant qu'il est actif, et l'indicateur de cloche barrée se trouve dans la barre pour vous rappeler pourquoi le bureau est devenu silencieux.

Rien n'est perdu, cependant. Les notifications mises en silence sont retenues : remettez les dernières à l'écran avec `Super + Shift + Alt + ,`. Voir [les notifications](10-notices.md) pour le reste.

Deux types de messages passent quand même : les toasts de confirmation propres à Omarchy pour quelque chose que vous venez de faire ("Theme changed", "Screenshot saved"), et les alertes critiques envoyées depuis la ligne de commande. Les applications de discussion qui marquent tout comme critique pour se frayer un chemin devant vous ne sont pas concernées.

### Inactivité

Le shell Omarchy possède le comportement d'inactivité, et les délais sont un bloc `idle` de premier niveau dans `~/.config/omarchy/shell.json` :

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Les deux nombres sont des secondes comptées à partir du moment où vous êtes devenu inactif — pas l'un par rapport à l'autre. Donc avec les valeurs par défaut, l'économiseur d'écran apparaît après deux minutes et demie et l'écran de verrouillage prend le relais à cinq minutes, que l'économiseur d'écran ait tourné ou non. Enregistrez le fichier et le shell prend en compte les nouveaux délais immédiatement.

Si vous fermez l'économiseur d'écran avant l'échéance du verrouillage, cela compte comme une activité et le verrouillage en attente est annulé. Vous ne vous faites pas verrouiller dehors pour avoir jeté un œil à votre machine.

Pour arrêter complètement le verrouillage en cas d'inactivité, `Super + Ctrl + I` — ou `omarchy toggle idle` — active rester éveillé, et l'indicateur tasse de café apparaît dans la barre. C'est celui à actionner avant une longue présentation ou une compilation que vous voulez surveiller. Actionnez-le à nouveau pour revenir à la normale. `omarchy toggle idle status` affiche l'état actuel en JSON si vous en avez besoin depuis un script.

Il s'agit du verrouillage et de l'économiseur d'écran, pas de l'alimentation. La mise en veille et l'hibernation ont leur propre configuration dans [la mise en veille du système](36-system-sleep.md).

### L'économiseur d'écran

L'économiseur d'écran d'Omarchy est de l'art ASCII passant par des effets de texte aléatoires, une instance par moniteur. N'importe quelle touche ou mouvement de souris en sort.

Vous pouvez le démarrer à la demande depuis _Système > Économiseur d'écran_ (`Super + Esc`), ce qui le force à s'afficher même si vous avez désactivé l'économiseur d'écran d'inactivité. Aucun raccourci clavier ne lui est attribué par défaut.

`omarchy toggle screensaver` est ce qui désactive celui d'inactivité, si vous préférez passer directement du travail au verrouillage. Il a besoin d'un terminal qu'il sait configurer — Alacritty, Foot, Ghostty ou Kitty — et vous le dira si votre terminal par défaut est autre chose.

Le logo qu'il dessine est à vous de changer, sous _Apparence > Image de marque > Économiseur d'écran_. Téléversez un png ou un svg et Omarchy le convertit en ASCII. Voir [l'image de marque](41-branding.md).

### L'écran de verrouillage

`Super + Ctrl + L` verrouille la machine. Cela lance l'écran de verrouillage du shell Omarchy, éteint l'affichage, réinitialise la disposition de votre clavier sur la première pour que vous ne tapiez pas votre mot de passe dans le mauvais alphabet, et — si vous l'avez en cours d'exécution — verrouille 1Password en sortant.

L'écran de verrouillage accepte un mot de passe, et il acceptera aussi une empreinte digitale une fois que vous en aurez configuré une. Cela, et les autres moyens de s'authentifier, sont couverts dans [l'authentification matérielle](37-hardware-authentication.md).
