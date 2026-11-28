# Klávesnice, myš, trackpad

Hyprland vám umožňuje podrobně nakonfigurovat všechny vaše vstupy. Můžete nastavit opakování kláves na nadzvukovou rychlost nebo na trackpadu používat přirozené posouvání. Všechno změníte v `~/.config/hypr/input.lua`, kam se dostanete také přes _Nastavení > Vstup_ v nabídce Omarchy (`Super + Space`). Cokoli tam nastavíte, nahradí výchozí nastavení Omarchy.

Zde je příklad:

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

Na wiki Hyprlandu pro vstupy si můžete [zobrazit všechny možnosti vstupu](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock funguje jako normální Caps Lock a `Shift + CapsLock` je klávesa compose pro [rychlé emoji](07-hotkeys.md#quick-emojis) a [další doplňování](07-hotkeys.md#quick-completions). Pokud byste klávesu compose měli raději jinde, nahraďte `omarchy:shift_caps_compose` v `kb_options`. Tento příklad například přesune klávesu compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkční klávesy

Horní řada klávesnice notebooku ve výchozím nastavení odesílá multimediální klávesy (hlasitost, jas a tak dále) a podržením `Fn` získáte F1-F12; `Fn + Esc` to uzamkne opačným směrem, dokud to znovu nestisknete. Většina klávesnic si toto uzamčení pamatuje sama. Notebooky ASUS a klávesnice ve stylu Apple to nechávají na Linuxu, který je při každém spuštění nastaví na multimediální klávesy. Chcete-li, aby místo toho začínaly na F1-F12, spusťte `omarchy device keyboard toprow fnkeys` (a `omarchy device keyboard toprow mediakeys` pro návrat zpět); u některých notebooků se to projeví až po restartu. Počítače Mac s Apple Silicon si zachovávají vlastní nastavení.

### Gesta trackpadu

Přejetím po trackpadu se můžete pohybovat po ploše:

| Gesto | Akce |
| --- | --- |
| Tři prsty doleva / doprava | Předchozí / další pracovní plocha, včetně prázdných |
| Tři prsty nahoru | Přepnout AI konzoli |
| Tři prsty dolů | Otevřít nabídku Omarchy |
| Čtyři prsty doleva / doprava | Přesunout aktivní okno na předchozí / další pracovní plochu |
| Čtyři prsty dolů | Přepnout celoobrazovkový režim |

Chcete-li některé gesto změnit, zrušte jeho nastavení v `~/.config/hypr/input.lua` před přidáním vlastního [gesta trackpadu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), protože Hyprland nepřijme dvě gesta pro stejné prsty a směr:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Chcete-li všechna gesta Omarchy vypnout, nastavte `omarchy_default_gestures = false` blízko horní části `~/.config/hypr/hyprland.lua`, než se načte výchozí nastavení Omarchy.

Na noteboocích Dell XPS s haptickým touchpadem můžete také nastavit sílu kliknutí na nízkou, střední nebo vysokou v _Trigger > Hardware > Touchpad Haptics_.

### Psaní v čínštině, japonštině a dalších jazycích

Vyberte japonštinu, korejštinu, čínštinu (zjednodušenou, Pinyin), Tchaj-wan (Zhuyin) nebo Hongkong (Cangjie), když se instalátor zeptá na vaši klávesnici. Omarchy nakonfiguruje klávesnici a odpovídající vstupní engine automaticky, včetně offline nastavení při prvním spuštění. Japonština používá Mozc, korejština používá standardní dvousadový Hangul, zjednodušená čínština používá Pinyin, Tchaj-wan používá standardní uspořádání Zhuyin od Chewing a Hongkong používá Cangjie s hongkongskými tvary znaků. Japonština (US klávesnice) poskytuje Mozc s rozložením klávesnice US. Klávesy Hangul, Zhuyin a Cangjie zůstávají na svých standardních pozicích, i když píšete latinkou s rozložením Dvorak, Colemak nebo AZERTY. Pokud jste Hangul nebo Chewing přidali před tímto, zrušte jeho výběr a znovu jej vyberte v _Nastavení > Klávesnice > Vstupní metody_, aby se jeho klávesy přesunuly tam; Omarchy nechá engine, se kterým už píšete, být.

Psaní začíná v latinském režimu. Stisknutím `Super + I` procházíte nakonfigurované vstupní metody a stisknutím `Super + Shift + I` procházíte zpět. Samotným klepnutím na `Shift` vystoupíte ze vstupní metody, jako je Pinyin, do latinských písmen a dalším klepnutím se vrátíte zpět, tak jak fungují Sogou, Microsoft Pinyin a macOS; `Shift` plus písmeno stále píše velké písmeno. Na japonských klávesnicích 全角/半角 přepíná vstup, 変換 jej zapíná a 無変換 jej vypíná. U korejštiny 한/영 přepíná Hangul a 한자 převádí na Hanja, ať už má vaše klávesnice vyhrazené klávesy, nebo pro ně odesílá Right Alt a Right Ctrl, jako to dělá mnoho notebooků, takže Right Alt a Right Ctrl tam nejsou obyčejné modifikátory; diktování se místo toho přepíná pomocí Alt + Space. `Ctrl + Space` zůstává k dispozici pro Tmux a Herdr; `Shift + CapsLock` zůstává klávesou compose.

Indikátor klávesnice se zobrazí napravo na liště, když máte více rozložení klávesnice nebo vstupních metod. Kliknutím na něj přepnete vstupní jazyky; japonština zobrazuje あ pro hiraganu. Pro výběr japonských znaků přepněte na japonštinu, napište slovo, jako je `nihongo`, a pak dvakrát stiskněte Space. Stisknutím Enter volbu potvrdíte. Pokud máte také více rozložení klávesnice, kliknutím pravým tlačítkem na indikátor je můžete procházet.

Pomocí _Nastavení > Klávesnice > Vstupy klávesnice_ vyberte rozložení, jako je angličtina a francouzština, ze stejných možností nabízených během instalace. Pomocí _Nastavení > Klávesnice > Vstupní metody_ vyberte, které enginy pro skládání znaků jsou aktivní. Oba výběry se otevřou uvnitř nabídky Omarchy s vašimi aktuálními volbami zaškrtnutými. Kliknutím nebo stisknutím Enter volbu přepnete; každá změna se projeví okamžitě. Zrušením výběru vstupní metody ji odeberete z cyklu, aniž byste ji odinstalovali; klávesnice zůstává k dispozici.

Spuštěním `omarchy setup keyboard` nebo `omarchy setup input` otevřete stejné výběry. Chcete-li z příkazového řádku přidat jeden jazyk, použijte `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` nebo `cangjie5`. Quick, Boshiamy a Array jsou ve stejném balíčku jako Cangjie a objeví se ve výběru Vstupní metody. Vaše vlastní přepínací klávesy zůstanou zachovány. Pro alternativní rozložení nebo klávesy enginu nainstalujte `fcitx5-configtool` pomocí `omarchy pkg add fcitx5-configtool` a spusťte jej z terminálu. Výběr vstupního jazyka nezmění jazyk plochy. Výběr japonštiny, korejštiny nebo čínštiny v _Nastavení > Oblast > Jazyk_ přidá její vstupní metodu, když ještě žádnou nemáte.

Pomocí `Super + I` procházíte vstupní metody nebo rozložení klávesnice a pomocí `Super + Shift + I` jdete opačným směrem, takže se třemi nakonfigurovanými můžete přecházet mezi dvěma sousedy. Indikátor vstupu se zobrazí napravo na liště pouze tehdy, když je nakonfigurována více než jedna vstupní metoda nebo rozložení. Tato vazba plochy funguje vedle vašich stávajících přepínacích kláves Fcitx; můžete ji přepsat v `~/.config/hypr/bindings.lua`. Vstupní enginy a sekvence compose používají službu [Fcitx5](https://fcitx-im.org/), která již běží v každé relaci.

### Použití ALT jako SUPER

Na některých klávesnicích není pohodlné používat primární meta klávesu (klávesu Windows/cmd) jako SUPER. Můžete to místo toho změnit na ALT pomocí této změny:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
