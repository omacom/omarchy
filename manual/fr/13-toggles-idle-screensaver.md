# Bascules, inactivité et l'économiseur d'écran

Une bonne partie de ce que tu changes au quotidien n'est pas vraiment un réglage. C'est un mode que tu actives pour une heure, puis que tu désactives : l'éclairage nocturne quand tu travailles tard, le mode ne pas déranger quand tu présentes, le maintien éveillé quand tu regardes quelque chose. Omarchy appelle ça des bascules, et elles fonctionnent toutes de la même façon — un raccourci clavier, une entrée de menu et une commande, qui agissent tous sur le même interrupteur.

### Le menu des bascules

`Super + Ctrl + O` ouvre directement _Trigger > Toggle_, ou tu peux y accéder depuis le menu Omarchy (`Super + Space`). Tout ce qui figure dans cette liste est un interrupteur que tu peux basculer sans te demander où vit l'état. Les interrupteurs liés à l'apparence du bureau se trouvent juste à côté, sous _Appearance_.

Depuis le terminal, les mêmes interrupteurs sont `omarchy toggle <thing>`. Exécute `omarchy toggle` tout seul pour voir tout le groupe.

| Bascule | Raccourci clavier | Commande |
| ------ | ------ | ------- |
| Éclairage nocturne | — | `omarchy toggle nightlight` |
| Silence des notifications | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Rester éveillé (pas de verrouillage pour inactivité) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Capture en cas de plantage | — | `omarchy toggle crash-capture` |
| Économiseur d'écran | — | `omarchy toggle screensaver` |
| Synchronisation du thème de [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barre de menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Pavé tactile | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Écran tactile | — | `omarchy toggle touchscreen` |
| Veille | — | `omarchy toggle suspend` |
| GPU hybride | — | `omarchy toggle hybrid gpu` |

Les interrupteurs du pavé tactile, de l'écran tactile et du GPU hybride se trouvent sous _Trigger > Hardware_ (`Super + Ctrl + H`) plutôt que sous Toggle, puisqu'ils n'apparaissent que si tu possèdes réellement ce matériel. Ceux du pavé tactile et de l'écran tactile survivent à un rechargement de Hyprland — le nom du périphérique désactivé est enregistré dans un petit fichier d'état que Hyprland lit au démarrage pour le désactiver à nouveau.

_Appearance_ regroupe la barre de menu et les animations, plus quelques éléments qui ne sont pas des commandes `omarchy toggle` mais se comportent de la même façon : le pourcentage de batterie dans la barre, la disposition par défaut des espaces de travail, et sous _Windows_, les espacements des fenêtres (`Super + Shift + Backspace`) et le format carré pour 1 fenêtre (`Super + Ctrl + Backspace`).

La plupart ne sont qu'un fichier drapeau sous `~/.local/state/omarchy/toggles/`. Si tu veux tester l'un d'eux dans un script, `omarchy-toggle-enabled` te donne un code de sortie au lieu de t'obliger à aller chercher toi-même :

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Les drapeaux sont nommés d'après l'état désactivé — `screensaver-off`, `suspend-off`, `bar-off` — donc leur présence signifie que la fonctionnalité est désactivée.

### Les indicateurs dans la barre

Quand un mode est activé, tu obtiens un petit glyphe au milieu de la barre supérieure, à côté de l'horloge. C'est le widget des indicateurs, et il regroupe la dictée, l'enregistrement d'écran, les rappels en attente, l'éclairage nocturne, le mode ne pas déranger et le maintien éveillé.

Les indicateurs inactifs sont masqués. Survole n'importe quel endroit de la barre et ils apparaissent en fondu, en atténué, pour que tu puisses cliquer sur l'un d'eux pour l'activer sans connaître son raccourci clavier. Cliquer sur un indicateur actif le désactive à nouveau. Si tu préfères les voir tous en permanence, définis `alwaysShow` sur `true` sur l'entrée `omarchy.indicators` dans `~/.config/omarchy/shell.json` — voir [la barre supérieure](05-the-top-bar.md) pour savoir comment les widgets de la barre sont configurés.

### Éclairage nocturne

L'éclairage nocturne réchauffe l'écran à 4000K, et le basculer à nouveau le ramène à 6500K. Bascule-le depuis le menu des bascules (`Super + Ctrl + O`) ou avec `omarchy toggle nightlight`. Il est piloté par hyprsunset, que la bascule démarre pour toi s'il n'est pas déjà en cours d'exécution.

Par défaut, hyprsunset ne fait absolument rien à ton écran. `~/.config/hypr/hyprsunset.conf` est livré avec un profil identité précisément pour que l'affichage reste intact jusqu'à ce que tu demandes de la chaleur. Si tu préfères qu'il bascule selon l'heure, remplace-le par un profil horaire :

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ensuite, démarre hyprsunset à la connexion en ajoutant `o.launch_on_start("hyprsunset")` à `~/.config/hypr/autostart.lua`. La paire 4000K/6500K utilisée par la bascule est fixe, donc c'est dans le fichier de configuration que tu dois aller si tu veux une autre température.

### Ne pas déranger

`Super + Ctrl + Alt + ,` met les notifications en silence. Aucun toast n'apparaît tant qu'il est actif, et l'indicateur de cloche barrée se trouve dans la barre pour te rappeler pourquoi le bureau est devenu silencieux.

Rien n'est perdu pour autant. Les notifications mises en silence sont retenues : réaffiche les dernières à l'écran avec `Super + Shift + Alt + ,`. Voir [les notices](10-notices.md) pour le reste.

Deux types de messages passent quand même : les toasts de confirmation propres à Omarchy pour quelque chose que tu viens de faire (« Theme changed », « Screenshot saved »), et les alertes critiques envoyées depuis la ligne de commande. Les applications de chat qui marquent tout comme critique pour s'imposer à toi ne comptent pas.

### Inactivité

Le shell Omarchy gère le comportement en cas d'inactivité, et les délais se trouvent dans un bloc `idle` de premier niveau dans `~/.config/omarchy/shell.json` :

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Les deux nombres sont des secondes comptées à partir du moment où tu es devenu inactif — pas l'un par rapport à l'autre. Donc avec les valeurs par défaut, l'économiseur d'écran apparaît au bout de deux minutes et demie et l'écran de verrouillage prend le relais à cinq minutes, que l'économiseur d'écran se soit lancé ou non. Enregistre le fichier et le shell prend en compte les nouveaux délais immédiatement.

Si tu fermes l'économiseur d'écran avant l'échéance de verrouillage, cela compte comme une activité et le verrouillage en attente est annulé. Tu ne te retrouves pas verrouillé dehors pour avoir jeté un coup d'œil à ta machine.

Pour arrêter complètement le verrouillage en cas d'inactivité, `Super + Ctrl + I` — ou `omarchy toggle idle` — active le maintien éveillé, et l'indicateur de tasse de café apparaît dans la barre. C'est celui-là qu'il faut activer avant une longue présentation ou une compilation que tu veux surveiller. Active-le à nouveau pour revenir à la normale. `omarchy toggle idle status` affiche l'état actuel en JSON si tu en as besoin depuis un script.

Il s'agit ici du verrouillage et de l'économiseur d'écran, pas de l'alimentation. La veille et l'hibernation ont leur propre configuration dans [la mise en veille du système](36-system-sleep.md).

### L'économiseur d'écran

L'économiseur d'écran d'Omarchy est un art ASCII traversé par des effets de texte aléatoires, avec une instance par moniteur. N'importe quelle touche ou mouvement de souris le quitte.

Tu peux le lancer à la demande depuis _System > Screensaver_ (`Super + Esc`), ce qui le force à apparaître même si tu as désactivé l'économiseur d'écran en cas d'inactivité. Aucun raccourci clavier ne lui est assigné par défaut.

`omarchy toggle screensaver` est ce qui désactive celui lié à l'inactivité, si tu préfères passer directement du travail au verrouillage. N'importe quelle touche, clic, défilement ou mouvement de souris le ferme.

Le logo qu'il dessine peut être changé par le tien, sous _Appearance > Branding > Screensaver_. Envoie un png ou un svg et Omarchy le convertit en ASCII. Voir [l'identité visuelle](41-branding.md).

### L'écran de verrouillage

`Super + Ctrl + L` verrouille la machine. Cela lance l'écran de verrouillage du shell Omarchy, éteint l'affichage, réinitialise ta disposition de clavier à la première pour que tu ne tapes pas ton mot de passe dans le mauvais alphabet, et — si tu l'as en cours d'exécution — verrouille 1Password au passage.

L'écran de verrouillage accepte un mot de passe, et il acceptera aussi une empreinte digitale une fois que tu en auras configuré une. Cela, et les autres façons de s'authentifier, sont traités dans [l'authentification matérielle](37-hardware-authentication.md).
