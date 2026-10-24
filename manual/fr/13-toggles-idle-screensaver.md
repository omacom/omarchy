# Bascules, inactivité et écran de veille

Une grande partie de ce que vous changez au quotidien n'est pas vraiment un réglage. C'est un mode que vous activez pendant une heure puis désactivez : l'éclairage nocturne pendant que vous travaillez tard, ne pas déranger pendant que vous présentez, rester éveillé pendant que vous regardez quelque chose. Omarchy les appelle des bascules, et elles fonctionnent toutes de la même façon — un raccourci, une entrée de menu et une commande, tous frappant le même interrupteur.

### Le menu des bascules

`Super + Ctrl + O` ouvre directement _Déclencher > Basculer_, ou vous pouvez y aller depuis le menu Omarchy (`Super + Space`). Tout dans cette liste est un interrupteur que vous pouvez actionner sans penser à l'endroit où vit l'état. Les interrupteurs pour l'apparence du bureau se trouvent juste à côté, sous _Déclencher > Apparence_.

Depuis le terminal, les mêmes interrupteurs sont `omarchy toggle <thing>`. Exécutez `omarchy toggle` tout seul pour voir tout le groupe.

| Bascule | Raccourci | Commande |
| ------ | ------ | ------- |
| Éclairage nocturne | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Silencer les notifications | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Rester éveillé (pas de verrouillage inactif) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Capture de crash | — | `omarchy toggle crash-capture` |
| Écran de veille | — | `omarchy toggle screensaver` |
| Synchro thème [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barre de menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Pavé tactile | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Écran tactile | — | `omarchy toggle touchscreen` |
| Suspendre | — | `omarchy toggle suspend` |
| GPU hybride | — | `omarchy toggle hybrid gpu` |

Les interrupteurs pavé tactile, écran tactile et GPU hybride vivent sous _Déclencher > Matériel_ (`Super + Ctrl + H`) plutôt que sous Basculer, puisqu'ils n'apparaissent que lorsque vous avez réellement ce matériel. Ceux du pavé tactile et de l'écran tactile survivent à un rechargement de Hyprland — le nom du périphérique désactivé est enregistré dans un petit fichier d'état que Hyprland lit au démarrage pour le désactiver à nouveau.

_Déclencher > Apparence_ contient la barre de menu et les animations, plus quelques éléments qui ne sont pas des commandes `omarchy toggle` mais se comportent de la même façon : le pourcentage batterie dans la barre, la disposition d'espace par défaut, les espacements fenêtres (`Super + Shift + Backspace`), et le ratio carré 1 fenêtre (`Super + Ctrl + Backspace`).

La plupart d'entre eux ne sont qu'un fichier indicateur sous `~/.local/state/omarchy/toggles/`. Si vous voulez brancher sur l'un d'eux dans un script, `omarchy-toggle-enabled` vous donne un code de sortie au lieu de vous faire chercher :

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Les indicateurs sont nommés pour l'état désactivé — `screensaver-off`, `suspend-off`, `bar-off` — donc leur présence signifie que la fonctionnalité est désactivée.

### Indicateurs dans la barre

Lorsqu'un mode est activé, vous obtenez un petit glyphe au milieu de la barre supérieure, à côté de l'horloge. C'est le widget indicateurs, et il porte la dictée, l'enregistrement d'écran, les rappels en attente, l'éclairage nocturne, ne pas déranger, et rester éveillé.

Les indicateurs inactifs sont masqués. Survolez la zone autour d'eux et ils apparaissent en fondu atténué, de sorte que vous pouvez en cliquer un pour l'activer sans connaître son raccourci. Cliquer sur un indicateur actif le désactive. Si vous préférez les voir tous en permanence, définissez `alwaysShow` à `true` sur l'entrée `omarchy.indicators` dans `~/.config/omarchy/shell.json` — voir [la barre supérieure](05-the-top-bar.md) pour la façon dont les widgets de la barre sont configurés.

### Éclairage nocturne

`Super + Ctrl + N` réchauffe l'écran à 4000K, et le refaire le remet à 6500K. Il est piloté par hyprsunset, que la bascule démarre pour vous s'il ne tourne pas déjà.

Par défaut, hyprsunset ne fait rien du tout à votre écran. `~/.config/hypr/hyprsunset.conf` est livré avec un profil identité précisément pour que l'affichage reste intact jusqu'à ce que vous demandiez de la chaleur. Si vous préférez qu'il bascule selon l'horloge, remplacez-le par un profil horaire :

```
profile {
    time = 20:00
    temperature = 4000
}
```

Démarrez ensuite hyprsunset à la connexion en ajoutant `o.launch_on_start("hyprsunset")` à `~/.config/hypr/autostart.lua`. La paire 4000K/6500K utilisée par la bascule est fixe, donc le fichier de configuration est l'endroit où aller si vous voulez une autre température.

### Ne pas déranger

`Super + Ctrl + ,` silence les notifications. Aucun toast n'apparaît pendant qu'il est actif, et l'indicateur de cloche barrée se trouve dans la barre pour vous rappeler pourquoi le bureau est devenu silencieux.

Rien n'est perdu, cependant. Une notification silenciée est écrite directement dans votre historique de notifications, qui est exactement l'enregistrement que vous voulez lorsque vous revenez et vous demandez ce que vous avez manqué. Ouvrez-le avec `Super + Shift + Alt + ,`. Voir [avis](10-notices.md) pour le reste de l'histoire des notifications.

Deux types de messages passent encore : les propres toasts de confirmation d'Omarchy pour quelque chose que vous venez de faire (« Theme changed », « Screenshot saved »), et les alertes critiques envoyées depuis la ligne de commande. Les applis de chat qui marquent tout comme critique pour se forcer devant vous ne sont pas qualifiées.

### Inactivité

Le shell Omarchy détient le comportement d'inactivité, et les délais sont un bloc `idle` de niveau supérieur dans `~/.config/omarchy/shell.json` :

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Les deux nombres sont des secondes comptées à partir du moment où vous êtes devenu inactif — pas l'un par rapport à l'autre. Ainsi, avec les valeurs par défaut, l'écran de veille apparaît après deux minutes et demie et l'écran de verrouillage prend le relais à cinq minutes, que l'écran de veille ait tourné ou non. Enregistrez le fichier et le shell prend les nouveaux délais tout de suite.

Si vous fermez l'écran de veille avant l'échéance de verrouillage, cela compte comme une activité et le verrouillage en attente est annulé. Vous n'êtes pas verrouillé dehors pour avoir jeté un coup d'œil à votre machine.

Pour arrêter complètement le verrouillage en cas d'inactivité, `Super + Ctrl + I` — ou `omarchy toggle idle` — active rester éveillé, et l'indicateur tasse de café apparaît dans la barre. C'est celui à actionner avant une longue présentation ou un build que vous voulez regarder. Réactionnez-le pour revenir à la normale. `omarchy toggle idle status` affiche l'état actuel en JSON si vous en avez besoin depuis un script.

Il s'agit du verrouillage et de l'écran de veille, pas de l'alimentation. La suspension et l'hibernation ont leur propre configuration dans [veille système](36-system-sleep.md).

### L'écran de veille

L'écran de veille d'Omarchy est de l'art ASCII traversant des effets de texte aléatoires, une instance par écran. N'importe quelle touche ou mouvement de souris en sort.

Vous pouvez le démarrer à la demande depuis _Système > Écran de veille_ (`Super + Esc`), ce qui le force même si vous avez désactivé l'écran de veille inactif. Aucun raccourci ne lui est lié par défaut.

`omarchy toggle screensaver` est ce qui désactive celui de l'inactivité, si vous préférez passer directement du travail au verrouillé. Il a besoin d'un terminal qu'il sait configurer — Alacritty, Foot, Ghostty ou Kitty — et vous le dira si votre terminal par défaut est autre chose.

Le logo qu'il dessine vous appartient, sous _Style > Écran de veille_. Téléversez un png ou un svg et Omarchy le convertit en ASCII. Voir [branding](41-branding.md).

### L'écran de verrouillage

`Super + Ctrl + L` verrouille la machine. Cela exécute l'écran de verrouillage du shell Omarchy, éteint l'affichage, réinitialise votre disposition de clavier à la première pour que vous ne tapiez pas votre mot de passe dans le mauvais alphabet, et — si vous l'avez en cours — verrouille 1Password en sortant.

L'écran de verrouillage accepte un mot de passe, et il acceptera aussi une empreinte digitale une fois que vous en aurez configuré une. Cela, et les autres façons de s'authentifier, sont couverts dans [authentification matérielle](37-hardware-authentication.md).
