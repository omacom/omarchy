# Bascules, veille et l’économiseur d’écran

Une bonne partie de ce que tu changes au jour le jour n’est pas vraiment un réglage. C’est un mode que tu actives pour une heure puis que tu désactives : la lumière nocturne quand tu travailles tard, ne pas déranger quand tu présentes, rester éveillé quand tu regardes quelque chose. Omarchy appelle ça des bascules, et elles fonctionnent toutes de la même façon — un raccourci clavier, une entrée de menu et une commande, qui agissent tous sur le même interrupteur.

### Le menu des bascules

`Super + Ctrl + O` ouvre directement _Trigger > Toggle_, ou tu peux y accéder depuis le menu Omarchy (`Super + Space`). Tout ce qui figure dans cette liste est un interrupteur que tu peux basculer sans te soucier de l’endroit où l’état est stocké. Les interrupteurs qui concernent l’apparence du bureau se trouvent juste à côté, sous _Appearance_.

Depuis le terminal, les mêmes interrupteurs sont `omarchy toggle <thing>`. Lance `omarchy toggle` seul pour voir l’ensemble du groupe.

| Bascule | Raccourci clavier | Commande |
| ------ | ------ | ------- |
| Lumière nocturne | — | `omarchy toggle nightlight` |
| Couper les notifications | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Rester éveillé (pas de verrouillage en veille) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Capture de plantage | — | `omarchy toggle crash-capture` |
| Économiseur d’écran | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) synchronisation du thème | — | `omarchy toggle theme sync` |
| Barre de menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Pavé tactile | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Écran tactile | — | `omarchy toggle touchscreen` |
| Suspension | — | `omarchy toggle suspend` |
| GPU hybride | — | `omarchy toggle hybrid gpu` |

Les interrupteurs du pavé tactile, de l’écran tactile et du GPU hybride se trouvent sous _Trigger > Hardware_ (`Super + Ctrl + H`) plutôt que sous Toggle, puisqu’ils n’apparaissent que si tu possèdes réellement ce matériel. Ceux du pavé tactile et de l’écran tactile survivent à un rechargement de Hyprland — le nom du périphérique désactivé est enregistré dans un petit fichier d’état que Hyprland lit au démarrage pour le désactiver à nouveau.

_Appearance_ contient la barre de menu et les animations, plus quelques éléments qui ne sont pas des commandes `omarchy toggle` mais qui se comportent de la même façon : le pourcentage de batterie dans la barre, la disposition par défaut des espaces de travail et, sous _Windows_, les espacements entre fenêtres (`Super + Shift + Backspace`) et le format carré pour 1 fenêtre (`Super + Ctrl + Backspace`).

Quand Hyprland n’a aucun GPU pour afficher et rend à la place sur le processeur (llvmpipe), comme sur les Mac dont le GPU n’est pas encore pris en charge, dans la plupart des machines virtuelles, ou quand un pilote graphique ne parvient pas à se charger, Omarchy désactive les animations, le flou et les ombres pour cette session et te le signale une fois par une notification. _Appearance > Animations On_ les réactive, et Omarchy s’en souvient aussi pour les sessions suivantes.

La plupart d’entre elles ne sont qu’un fichier drapeau sous `~/.local/state/omarchy/toggles/`. Si tu veux tester l’une d’elles dans un script, `omarchy-toggle-enabled` te donne un code de sortie au lieu de t’obliger à aller chercher :

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Les drapeaux sont nommés d’après l’état désactivé — `screensaver-off`, `suspend-off`, `bar-off` — donc leur présence signifie que la fonctionnalité est désactivée.

### Les indicateurs dans la barre

Quand un mode est actif, tu obtiens un petit glyphe au milieu de la barre supérieure, à côté de l’horloge. C’est le widget des indicateurs, et il regroupe la dictée, l’enregistrement d’écran, les rappels en attente, la lumière nocturne, ne pas déranger et rester éveillé.

Les indicateurs inactifs sont masqués. Survole n’importe où sur la barre et ils apparaissent en fondu, en grisé, pour que tu puisses cliquer sur l’un d’eux pour l’activer sans connaître son raccourci clavier. Cliquer sur un indicateur actif le désactive à nouveau. Si tu préfères les voir tous en permanence, définis `alwaysShow` sur `true` dans l’entrée `omarchy.indicators` de `~/.config/omarchy/shell.json` — voir [la barre supérieure](05-the-top-bar.md) pour savoir comment les widgets de la barre sont configurés.

### Lumière nocturne

La lumière nocturne réchauffe l’écran à 4000K, et la basculer à nouveau le ramène à 6500K. Bascule-la depuis le menu des bascules (`Super + Ctrl + O`) ou avec `omarchy toggle nightlight`. Elle est pilotée par hyprsunset, que la bascule démarre pour toi s’il ne tourne pas déjà.

Par défaut, hyprsunset ne fait absolument rien à ton écran. `~/.config/hypr/hyprsunset.conf` est livré avec un profil identité précisément pour que l’affichage reste intact jusqu’à ce que tu demandes de la chaleur. Si tu préfères qu’il bascule selon l’heure, remplace-le par un profil horaire :

```
profile {
    time = 20:00
    temperature = 4000
}
```

Démarre ensuite hyprsunset à la connexion en ajoutant `o.launch_on_start("hyprsunset")` à `~/.config/hypr/autostart.lua`. La paire 4000K/6500K utilisée par la bascule est fixe, donc c’est dans le fichier de configuration que tu dois aller si tu veux une température différente.

### Ne pas déranger

`Super + Ctrl + Alt + ,` coupe les notifications. Aucun toast n’apparaît tant qu’il est actif, et l’indicateur en forme de cloche barrée se trouve dans la barre pour te rappeler pourquoi le bureau est devenu silencieux.

Rien n’est perdu, cependant. Les notifications coupées sont retenues : réaffiche les dernières à l’écran avec `Super + Shift + Alt + ,`. Voir [les notifications](10-notices.md) pour le reste.

Deux types de messages passent quand même : les toasts de confirmation d’Omarchy pour quelque chose que tu viens de faire (« Theme changed », « Screenshot saved »), et les alertes critiques envoyées depuis la ligne de commande. Les applications de chat qui marquent tout comme critique pour s’imposer devant toi n’en font pas partie.

### Veille

Le shell Omarchy gère le comportement en veille, et les délais se trouvent dans un bloc `idle` de premier niveau dans `~/.config/omarchy/shell.json` :

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Les deux nombres sont des secondes comptées à partir du moment où tu es passé en veille — pas l’un à partir de l’autre. Donc, avec les valeurs par défaut, l’économiseur d’écran apparaît après deux minutes et demie et l’écran de verrouillage prend le relais à cinq minutes, que l’économiseur d’écran se soit lancé ou non. Enregistre le fichier et le shell prend en compte les nouveaux délais immédiatement.

Si tu fermes l’économiseur d’écran avant l’échéance de verrouillage, cela compte comme une activité et le verrouillage en attente est annulé. Tu ne te retrouves pas verrouillé pour avoir jeté un coup d’œil à ta machine.

Pour arrêter complètement le verrouillage en veille, `Super + Ctrl + I` — ou `omarchy toggle idle` — active le mode rester éveillé, et l’indicateur en forme de tasse de café apparaît dans la barre. C’est celui qu’il faut activer avant une longue présentation ou un build que tu veux surveiller. Active-le à nouveau pour revenir à la normale. `omarchy toggle idle status` affiche l’état actuel en JSON si tu en as besoin depuis un script.

Il s’agit du verrouillage et de l’économiseur d’écran, pas de l’alimentation. La suspension et l’hibernation ont leur propre configuration dans [la mise en veille du système](36-system-sleep.md).

### L’économiseur d’écran

L’économiseur d’écran d’Omarchy est de l’art ASCII animé par des effets de texte aléatoires, à raison d’une instance par moniteur. N’importe quelle touche ou n’importe quel mouvement de souris le quitte.

Tu peux le démarrer à la demande depuis _System > Screensaver_ (`Super + Esc`), ce qui le force à apparaître même si tu as désactivé l’économiseur d’écran en veille. Aucun raccourci clavier ne lui est associé par défaut.

`omarchy toggle screensaver` est ce qui désactive celui en veille, si tu préfères passer directement du travail au verrouillage. N’importe quelle touche, n’importe quel clic, défilement ou mouvement de souris le ferme.

Le logo qu’il dessine, c’est à toi de le changer, sous _Appearance > Branding > Screensaver_. Téléverse un png ou un svg et Omarchy le convertit en ASCII. Voir [l’identité visuelle](41-branding.md).

### L’écran de verrouillage

`Super + Ctrl + L` verrouille la machine. Cela lance l’écran de verrouillage du shell Omarchy, éteint l’affichage, réinitialise la disposition de ton clavier sur la première pour que tu ne tapes pas ton mot de passe dans le mauvais alphabet et — si tu l’as en cours d’exécution — verrouille 1Password au passage.

L’écran de verrouillage accepte un mot de passe, et il acceptera aussi une empreinte digitale une fois que tu en auras configuré une. Cela, ainsi que les autres moyens de s’authentifier, est couvert dans [l’authentification matérielle](37-hardware-authentication.md).
