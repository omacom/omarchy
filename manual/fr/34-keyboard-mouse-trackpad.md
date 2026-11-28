# Clavier, souris, pavé tactile

Hyprland vous permet de configurer toutes vos entrées dans les moindres détails. Vous pouvez rendre la répétition du clavier supersoniquement rapide ou faire utiliser le défilement naturel au pavé tactile. Vous modifiez tout cela dans `~/.config/hypr/input.lua`, que vous pouvez aussi atteindre via _Configuration > Saisie_ dans le menu Omarchy (`Super + Space`). Tout ce que vous définissez là remplace les réglages par défaut d'Omarchy.

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

Vous pouvez [voir toutes les options de saisie](https://wiki.hypr.land/Configuring/Basics/Variables/#input) sur le wiki Hyprland consacré aux entrées.

CapsLock fonctionne comme une touche Caps Lock normale, et `Shift + CapsLock` est la touche de composition pour les [émojis rapides](07-hotkeys.md#quick-emojis) et les [autres complétions](07-hotkeys.md#quick-completions). Si vous préférez placer la touche de composition ailleurs, remplacez `omarchy:shift_caps_compose` dans `kb_options`. Par exemple, ceci déplace la touche de composition vers Right Alt :

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Touches de fonction

La rangée supérieure d'un clavier d'ordinateur portable envoie par défaut les touches multimédias (volume, luminosité, etc.), et maintenir `Fn` donne F1-F12 ; `Fn + Esc` verrouille le comportement inverse jusqu'à ce que vous appuyiez de nouveau dessus. La plupart des claviers mémorisent eux-mêmes ce verrouillage. Les ordinateurs portables ASUS et les claviers de style Apple laissent cela à Linux, qui les démarre sur les touches multimédias à chaque démarrage. Pour qu'ils démarrent sur F1-F12 à la place, exécutez `omarchy device keyboard toprow fnkeys` (et `omarchy device keyboard toprow mediakeys` pour revenir en arrière) ; sur certains ordinateurs portables, cela prend effet après un redémarrage. Les Mac Apple Silicon conservent leur propre réglage.

### Gestes du pavé tactile

Balayez le pavé tactile pour vous déplacer sur le bureau :

| Geste | Action |
| --- | --- |
| Trois doigts vers la gauche / la droite | Espace de travail précédent / suivant, y compris les espaces vides |
| Trois doigts vers le haut | Basculer la console d'IA |
| Trois doigts vers le bas | Ouvrir le menu Omarchy |
| Quatre doigts vers la gauche / la droite | Déplacer la fenêtre active vers l'espace de travail précédent / suivant |
| Quatre doigts vers le bas | Basculer en plein écran |

Pour en changer un, désactivez-le dans `~/.config/hypr/input.lua` avant d'ajouter votre propre [geste du pavé tactile](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), car Hyprland n'acceptera pas deux gestes avec les mêmes doigts et la même direction :

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Pour désactiver tous les gestes d'Omarchy, définissez `omarchy_default_gestures = false` près du haut de `~/.config/hypr/hyprland.lua`, avant le chargement des réglages par défaut d'Omarchy.

Sur les ordinateurs portables Dell XPS dotés d'un pavé tactile haptique, vous pouvez aussi régler l'intensité du clic sur faible, moyenne ou élevée sous _Déclencheur > Matériel > Haptique du pavé tactile_.

### Saisie en chinois, en japonais et dans d'autres langues

Sélectionnez le japonais, le coréen, le chinois (simplifié, Pinyin), Taiwan (Zhuyin) ou Hong Kong (Cangjie) lorsque le programme d'installation vous demande votre clavier. Omarchy configure automatiquement le clavier et le moteur de saisie correspondant, y compris lors de la configuration hors ligne au premier démarrage. Le japonais utilise Mozc, le coréen utilise le Hangul standard à deux jeux, le chinois simplifié utilise Pinyin, Taiwan utilise la disposition Zhuyin standard de Chewing, et Hong Kong utilise Cangjie avec les formes de caractères de Hong Kong. Le japonais (clavier US) fournit Mozc avec une disposition de clavier US. Les touches Hangul, Zhuyin et Cangjie restent à leurs positions standard même lorsque vous saisissez des lettres latines avec Dvorak, Colemak ou AZERTY. Si vous avez ajouté Hangul ou Chewing avant cela, désélectionnez-le puis resélectionnez-le sous _Configuration > Clavier > Méthodes de saisie_ pour déplacer ses touches à cet endroit ; Omarchy laisse tranquille un moteur que vous utilisez déjà pour saisir du texte.

La saisie commence en mode latin. Appuyez sur `Super + I` pour faire défiler les méthodes de saisie configurées, et sur `Super + Shift + I` pour revenir en arrière. Touchez `Shift` seul pour sortir d'une méthode de saisie comme Pinyin et passer aux lettres latines, et touchez-le de nouveau pour y revenir, comme fonctionnent Sogou, Microsoft Pinyin et macOS ; `Shift` plus une lettre tape toujours une majuscule. Sur les claviers japonais, 全角/半角 bascule la saisie, 変換 l'active et 無変換 la désactive. Avec le coréen, 한/영 bascule Hangul et 한자 convertit en Hanja, que votre clavier ait des touches dédiées ou qu'il envoie Right Alt et Right Ctrl pour cela, comme le font de nombreux ordinateurs portables, donc Right Alt et Right Ctrl n'y sont pas de simples modificateurs ; la dictée se bascule plutôt avec Alt + Space. `Ctrl + Space` reste disponible pour Tmux et Herdr ; `Shift + CapsLock` reste la touche de composition.

L'indicateur de clavier apparaît à droite de la barre lorsque vous avez plusieurs dispositions de clavier ou méthodes de saisie. Cliquez dessus pour changer de langue de saisie ; le japonais affiche あ pour l'hiragana. Pour choisir des caractères japonais, passez au japonais, tapez un mot tel que `nihongo`, puis appuyez deux fois sur Space. Appuyez sur Enter pour accepter votre choix. Si vous avez aussi plusieurs dispositions de clavier, cliquez avec le bouton droit sur l'indicateur pour les faire défiler.

Utilisez _Configuration > Clavier > Dispositions du clavier_ pour sélectionner des dispositions telles que l'anglais et le français, parmi les mêmes choix proposés lors de l'installation. Utilisez _Configuration > Clavier > Méthodes de saisie_ pour sélectionner les moteurs de composition actifs. Les deux sélecteurs s'ouvrent dans le menu Omarchy avec vos sélections actuelles cochées. Cliquez ou appuyez sur Enter pour basculer un choix ; chaque changement s'applique immédiatement. Désélectionner une méthode de saisie la retire du cycle sans la désinstaller ; le clavier reste disponible.

Exécutez `omarchy setup keyboard` ou `omarchy setup input` pour ouvrir les mêmes sélecteurs. Pour ajouter une langue depuis la ligne de commande, utilisez `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ou `cangjie5`. Quick, Boshiamy et Array sont fournis dans le même paquet que Cangjie et apparaissent dans le sélecteur Méthodes de saisie. Vos touches de basculement personnalisées sont préservées. Pour d'autres dispositions ou touches de moteur, installez `fcitx5-configtool` avec `omarchy pkg add fcitx5-configtool` et lancez-le depuis un terminal. Sélectionner une langue de saisie ne change pas la langue du bureau. Choisir le japonais, le coréen ou le chinois sous _Configuration > Région > Langue_ ajoute sa méthode de saisie lorsque vous n'en avez pas encore.

Utilisez `Super + I` pour faire défiler les méthodes de saisie ou les dispositions de clavier, et `Super + Shift + I` pour revenir dans l'autre sens, ainsi, avec trois méthodes configurées, vous pouvez passer d'un voisin à l'autre. L'indicateur de saisie apparaît à droite de la barre uniquement lorsque plus d'une méthode de saisie ou disposition est configurée. Ce raccourci du bureau fonctionne en parallèle de vos touches de basculement Fcitx existantes ; vous pouvez le remplacer dans `~/.config/hypr/bindings.lua`. Les moteurs de saisie et les séquences de composition utilisent le service [Fcitx5](https://fcitx-im.org/) déjà en cours d'exécution dans chaque session.

### Utiliser ALT comme SUPER

Sur certains claviers, il n'est pas pratique d'utiliser la touche méta principale (touche Windows/cmd) comme SUPER. Vous pouvez la remplacer par ALT à la place avec ce changement :

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
