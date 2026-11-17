# Clavier, souris, trackpad

Hyprland vous permet de configurer toutes vos entrées dans les moindres détails. Vous pouvez rendre la répétition du clavier supersoniquement rapide ou faire utiliser le défilement naturel au trackpad. Vous modifiez tout cela dans `~/.config/hypr/input.lua`, que vous pouvez aussi atteindre via _Configuration > Entrée_ dans le menu Omarchy (`Super + Space`). Tout ce que vous définissez là remplace les réglages par défaut d'Omarchy.

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

CapsLock fonctionne comme un verrouillage majuscules normal, et `Shift + CapsLock` est la touche de composition pour les [emojis rapides](07-hotkeys.md#quick-emojis) et les [autres complétions](07-hotkeys.md#quick-completions). Si vous préférez placer la touche de composition ailleurs, remplacez `omarchy:shift_caps_compose` dans `kb_options`. Par exemple, ceci déplace la touche de composition vers Right Alt :

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Touches de fonction

La rangée supérieure d'un clavier d'ordinateur portable envoie les touches multimédias (volume, luminosité, etc.) par défaut, et maintenir `Fn` donne accès à F1-F12 ; `Fn + Esc` verrouille le comportement inverse jusqu'à ce que vous appuyiez à nouveau dessus. La plupart des claviers mémorisent eux-mêmes ce verrouillage. Les ordinateurs portables ASUS et les claviers de style Apple le laissent à Linux, qui les démarre sur les touches multimédias à chaque démarrage. Pour qu'ils démarrent sur F1-F12 à la place, exécutez `omarchy keyboard toprow fnkeys` (et `omarchy keyboard toprow mediakeys` pour revenir en arrière) ; sur certains ordinateurs portables, le changement prend effet après un redémarrage. Les Mac Apple Silicon conservent leur propre réglage.

### Gestes du trackpad

Balayez sur le trackpad pour vous déplacer sur le bureau :

| Geste | Action |
| --- | --- |
| Trois doigts vers la gauche / la droite | Espace de travail précédent / suivant, y compris les espaces vides |
| Trois doigts vers le haut | Afficher/masquer la console d'IA |
| Trois doigts vers le bas | Ouvrir le menu Omarchy |
| Quatre doigts vers la gauche / la droite | Déplacer la fenêtre active vers l'espace de travail précédent / suivant |
| Quatre doigts vers le bas | Activer/désactiver le plein écran |

Pour en modifier un, désactivez-le dans `~/.config/hypr/input.lua` avant d'ajouter votre propre [geste du trackpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), car Hyprland n'acceptera pas deux gestes avec les mêmes doigts et la même direction :

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Pour désactiver tous les gestes d'Omarchy, définissez `omarchy_default_gestures = false` près du haut de `~/.config/hypr/hyprland.lua`, avant le chargement des réglages par défaut d'Omarchy.

Sur les ordinateurs portables Dell XPS équipés d'un trackpad haptique, vous pouvez aussi régler l'intensité du clic sur faible, moyenne ou élevée sous _Trigger > Hardware > Touchpad Haptics_.

### Saisie en chinois, japonais et autres langues

Sélectionnez le japonais, le coréen, le chinois (simplifié, Pinyin), Taïwan (Zhuyin) ou Hong Kong (Cangjie) lorsque le programme d'installation vous demande votre clavier. Omarchy configure automatiquement le clavier et le moteur de saisie correspondant, y compris pendant la configuration hors ligne au premier démarrage. Le japonais utilise Mozc, le coréen utilise le Hangul standard à deux jeux, le chinois simplifié utilise Pinyin, Taïwan utilise la disposition Zhuyin standard de Chewing, et Hong Kong utilise Cangjie avec les formes de caractères de Hong Kong. Le japonais (clavier US) fournit Mozc avec une disposition de clavier américaine. Les touches Hangul, Zhuyin et Cangjie restent à leurs positions standard même lorsque vous saisissez des lettres latines avec Dvorak, Colemak ou AZERTY. Si vous avez ajouté Hangul ou Chewing avant cela, désélectionnez-le puis sélectionnez-le à nouveau sous _Configuration > Clavier > Méthodes de saisie_ pour déplacer ses touches à cet endroit ; Omarchy laisse tranquille un moteur que vous utilisez déjà pour saisir du texte.

La saisie commence en mode latin. Appuyez sur `Super + I` pour faire défiler les méthodes de saisie configurées, et sur `Super + Shift + I` pour revenir en arrière. Appuyez sur `Shift` seul pour sortir d'une méthode de saisie comme Pinyin et passer aux lettres latines, et appuyez à nouveau dessus pour y revenir, comme le font Sogou, Microsoft Pinyin et macOS ; `Shift` plus une lettre tape toujours une majuscule. Sur les claviers japonais, 全角/半角 bascule la saisie, 変換 l'active et 無変換 la désactive. Avec le coréen, 한/영 bascule en Hangul et 한자 convertit en Hanja, que votre clavier dispose de touches dédiées ou qu'il envoie Right Alt et Right Ctrl pour celles-ci, comme le font de nombreux ordinateurs portables, donc Right Alt et Right Ctrl n'y sont pas de simples modificateurs ; la dictée se bascule plutôt avec Alt + Space. `Ctrl + Space` reste disponible pour Tmux et Herdr ; `Shift + CapsLock` reste la touche de composition.

L'indicateur de clavier apparaît à droite de la barre lorsque vous avez plusieurs dispositions de clavier ou méthodes de saisie. Cliquez dessus pour changer de langue de saisie ; le japonais affiche あ pour les hiragana. Pour choisir des caractères japonais, passez en japonais, tapez un mot comme `nihongo`, puis appuyez deux fois sur Space. Appuyez sur Enter pour valider votre choix. Si vous avez aussi plusieurs dispositions de clavier, cliquez avec le bouton droit sur l'indicateur pour les faire défiler.

Utilisez _Configuration > Clavier > Dispositions du clavier_ pour sélectionner des dispositions comme l'anglais et le français, parmi les mêmes choix que ceux proposés pendant l'installation. Utilisez _Configuration > Clavier > Méthodes de saisie_ pour sélectionner les moteurs de composition actifs. Les deux sélecteurs s'ouvrent dans le menu Omarchy, avec vos sélections actuelles cochées. Cliquez ou appuyez sur Enter pour activer ou désactiver un choix ; chaque modification s'applique immédiatement. Désélectionner une méthode de saisie la retire du cycle sans la désinstaller ; le clavier reste disponible.

Exécutez `omarchy setup keyboard` ou `omarchy setup input` pour ouvrir les mêmes sélecteurs. Pour ajouter une langue depuis la ligne de commande, utilisez `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ou `cangjie5`. Quick, Boshiamy et Array sont fournis dans le même paquet que Cangjie et apparaissent dans le sélecteur Méthodes de saisie. Vos touches de bascule personnalisées sont conservées. Pour d'autres dispositions ou touches de moteur, installez `fcitx5-configtool` avec `omarchy pkg add fcitx5-configtool` et lancez-le depuis un terminal. Sélectionner une langue de saisie ne change pas la langue du bureau. Choisir le japonais, le coréen ou le chinois sous _Configuration > Langue_ ajoute sa méthode de saisie lorsque vous n'en avez encore aucune.

Utilisez `Super + I` pour faire défiler les méthodes de saisie ou les dispositions de clavier, et `Super + Shift + I` pour revenir dans l'autre sens, ainsi, avec trois options configurées, vous pouvez passer d'un voisin à l'autre. L'indicateur de saisie n'apparaît à droite de la barre que lorsque plus d'une méthode de saisie ou disposition est configurée. Cette combinaison de bureau fonctionne en parallèle de vos touches de bascule Fcitx existantes ; vous pouvez la remplacer dans `~/.config/hypr/bindings.lua`. Les moteurs de saisie et les séquences de composition utilisent le service [Fcitx5](https://fcitx-im.org/) déjà en cours d'exécution dans chaque session.

### Utiliser ALT comme SUPER

Sur certains claviers, il n'est pas pratique d'utiliser la touche méta principale (touche Windows/cmd) comme SUPER. Vous pouvez la remplacer par ALT à la place avec cette modification :

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
