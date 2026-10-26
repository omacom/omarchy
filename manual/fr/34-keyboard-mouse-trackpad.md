# Clavier, souris, pavé tactile

Hyprland vous permet de configurer toutes vos entrées dans les moindres détails. Vous pouvez rendre la répétition du clavier supersoniquement rapide ou faire utiliser le défilement naturel au pavé tactile. Vous modifiez tout cela dans `~/.config/hypr/input.lua`, que vous pouvez aussi atteindre via _Setup > Input_ dans le menu Omarchy (`Super + Space`). Tout ce que vous y définissez remplace les valeurs par défaut d'Omarchy.

Voici un exemple :

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

Vous pouvez [voir toutes les options d'entrée](https://wiki.hypr.land/Configuring/Basics/Variables/#input) sur le wiki Hyprland consacré aux entrées.

CapsLock fonctionne comme un verrouillage des majuscules normal, et `Shift + CapsLock` est la touche de composition pour les [emojis rapides](07-hotkeys.md#quick-emojis) et les [autres complétions](07-hotkeys.md#quick-completions). Si vous préférez placer la touche de composition ailleurs, remplacez `omarchy:shift_caps_compose` dans `kb_options`. Par exemple, ceci déplace la touche de composition vers Right Alt :

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestes du pavé tactile

Vous pouvez aussi activer les [gestes du pavé tactile](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), comme glisser avec trois doigts pour changer d'espace de travail :

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Sur les ordinateurs portables Dell XPS dotés d'un pavé tactile haptique, vous pouvez aussi régler la force du clic sur faible, moyenne ou élevée sous _Trigger > Hardware > Touchpad Haptics_.

### Saisie en chinois, japonais et autres langues

Sélectionnez Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) ou Hong Kong (Cangjie) lorsque le programme d'installation vous demande votre clavier. Omarchy configure automatiquement le clavier et le moteur de saisie correspondant, y compris pendant la configuration hors ligne au premier démarrage. Le japonais utilise Mozc, le coréen utilise le Hangul standard à deux ensembles, le chinois simplifié utilise Pinyin, Taïwan utilise l'agencement Zhuyin standard de Chewing, et Hong Kong utilise Cangjie avec les formes de caractères de Hong Kong. Japanese (US keyboard) fournit Mozc avec un agencement de clavier américain. Les touches Hangul, Zhuyin et Cangjie restent à leurs positions standard même lorsque vous tapez des lettres latines avec Dvorak, Colemak ou AZERTY. Si vous avez ajouté Hangul ou Chewing avant cela, désélectionnez-le puis resélectionnez-le sous _Setup > Typing > Input Methods_ pour déplacer ses touches à cet endroit ; Omarchy laisse tranquille un moteur que vous utilisez déjà pour taper.

La saisie commence en mode latin. Appuyez sur `Super + I` pour faire défiler les méthodes de saisie configurées, et sur `Super + Shift + I` pour revenir en arrière. Appuyez sur `Shift` seul pour sortir d'une méthode de saisie comme Pinyin et passer aux lettres latines, et appuyez à nouveau dessus pour y revenir, comme fonctionnent Sogou, Microsoft Pinyin et macOS ; `Shift` plus une lettre tape toujours une majuscule. Sur les claviers japonais, 全角/半角 bascule la saisie, 変換 l'active, et 無変換 la désactive. Avec le coréen, 한/영 bascule le Hangul et 한자 convertit en Hanja, que votre clavier ait des touches dédiées ou qu'il envoie Right Alt et Right Ctrl pour celles-ci, comme le font de nombreux ordinateurs portables, donc Right Alt et Right Ctrl ne sont pas de simples modificateurs dans ce cas ; la dictée en push-to-talk reste sur F9. `Ctrl + Space` reste disponible pour Tmux et Herdr ; `Shift + CapsLock` reste la touche de composition.

L'indicateur de clavier apparaît à droite de la barre lorsque vous avez plusieurs agencements de clavier ou méthodes de saisie. Cliquez dessus pour changer de langue de saisie ; le japonais affiche あ pour l'hiragana. Pour choisir des caractères japonais, passez au japonais, tapez un mot tel que `nihongo`, puis appuyez deux fois sur Space. Appuyez sur Enter pour accepter votre choix. Si vous avez aussi plusieurs agencements de clavier, faites un clic droit sur l'indicateur pour les faire défiler.

Utilisez _Setup > Typing > Keyboard Layouts_ pour sélectionner des agencements tels que English et French, parmi les mêmes choix proposés pendant l'installation. Utilisez _Setup > Typing > Input Methods_ pour sélectionner les moteurs de composition actifs. Les deux sélecteurs s'ouvrent dans le menu Omarchy avec vos sélections actuelles cochées. Cliquez ou appuyez sur Enter pour basculer un choix ; chaque changement s'applique immédiatement. Désélectionner une méthode de saisie la retire du cycle sans la désinstaller ; le clavier reste disponible.

Exécutez `omarchy setup keyboard` ou `omarchy setup input` pour ouvrir les mêmes sélecteurs. Pour ajouter une langue depuis la ligne de commande, utilisez `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ou `cangjie5`. Quick, Boshiamy et Array sont fournis dans le même paquet que Cangjie et apparaissent dans le sélecteur Input Methods. Vos touches de basculement personnalisées sont préservées. Pour d'autres agencements ou touches de moteur, installez `fcitx5-configtool` avec `omarchy pkg add fcitx5-configtool` et lancez-le depuis un terminal. Sélectionner une langue de saisie ne change pas la langue du bureau. Choisir Japanese, Korean ou Chinese sous _Setup > Language_ ajoute sa méthode de saisie lorsque vous n'en avez pas encore.

Utilisez `Super + I` pour faire défiler les méthodes de saisie ou les agencements de clavier, et `Super + Shift + I` pour revenir dans l'autre sens, donc avec trois éléments configurés, vous pouvez passer entre deux voisins. L'indicateur de saisie n'apparaît à droite de la barre que lorsque plus d'une méthode de saisie ou d'un agencement est configuré. Ce raccourci de bureau fonctionne parallèlement à vos touches de basculement Fcitx existantes ; vous pouvez le remplacer dans `~/.config/hypr/bindings.lua`. Les moteurs de saisie et les séquences de composition utilisent le service [Fcitx5](https://fcitx-im.org/) déjà en cours d'exécution dans chaque session.

### Utiliser ALT comme SUPER

Sur certains claviers, il n'est pas pratique d'utiliser la touche méta principale (touche Windows/cmd) comme SUPER. Vous pouvez la remplacer par ALT à la place avec ce changement :

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
