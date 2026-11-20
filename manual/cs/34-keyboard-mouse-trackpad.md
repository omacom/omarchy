# Klávesnice, myš, trackpad

Hyprland vám umožňuje nakonfigurovat všechny vstupy do velkých detailů. Můžete nastavit opakování kláves na nadzvukovou rychlost nebo trackpadu zapnout přirozené posouvání. Vše měníte v `~/.config/hypr/input.lua`, kam se dostanete také přes _Setup > Input_ v nabídce Omarchy (`Super + Space`). Cokoli tam nastavíte, nahradí výchozí nastavení Omarchy.

Tady je příklad:

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

Na wiki Hyprlandu věnované vstupům si můžete [zobrazit všechny možnosti vstupu](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock funguje jako běžný Caps Lock a `Shift + CapsLock` je klávesa compose pro [rychlá emoji](07-hotkeys.md#quick-emojis) a [další doplňování](07-hotkeys.md#quick-completions). Pokud byste klávesu compose raději měli jinde, nahraďte `omarchy:shift_caps_compose` v `kb_options`. Tento příklad například přesune klávesu compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkční klávesy

Horní řada klávesnice notebooku ve výchozím nastavení odesílá multimediální klávesy (hlasitost, jas a tak dále) a podržením `Fn` získáte F1-F12; `Fn + Esc` to zamkne opačně, dokud to znovu nestisknete. Většina klávesnic si tento zámek pamatuje sama. Notebooky ASUS a klávesnice ve stylu Apple to nechávají na Linuxu, který je při každém spuštění nastaví na multimediální klávesy. Chcete-li, aby místo toho začínaly na F1-F12, spusťte `omarchy device keyboard toprow fnkeys` (a `omarchy device keyboard toprow mediakeys` pro návrat zpět); na některých noteboocích se změna projeví až po restartu. Počítače Apple Silicon Mac si zachovávají vlastní nastavení.

### Gesta trackpadu

Přejetím po trackpadu se pohybujete po ploše:

| Gesto | Akce |
| --- | --- |
| Tři prsty doleva / doprava | Předchozí / další pracovní plocha, včetně prázdných |
| Tři prsty nahoru | Přepnout AI konzoli |
| Tři prsty dolů | Otevřít nabídku Omarchy |
| Čtyři prsty doleva / doprava | Přesunout aktivní okno na předchozí / další pracovní plochu |
| Čtyři prsty dolů | Přepnout režim celé obrazovky |

Chcete-li některé gesto změnit, nejprve ho zrušte v `~/.config/hypr/input.lua` a teprve pak přidejte vlastní [gesto trackpadu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), protože Hyprland nepřijme dvě gesta pro stejné prsty a směr:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Chcete-li všechna gesta Omarchy vypnout, nastavte `omarchy_default_gestures = false` blízko začátku souboru `~/.config/hypr/hyprland.lua`, ještě před načtením výchozího nastavení Omarchy.

Na noteboocích Dell XPS s haptickým touchpadem můžete také nastavit sílu kliknutí na low, mid nebo high v části _Trigger > Hardware > Touchpad Haptics_.

### Psaní v čínštině, japonštině a dalších jazycích

Když se vás instalátor zeptá na klávesnici, vyberte Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) nebo Hong Kong (Cangjie). Omarchy nakonfiguruje klávesnici a odpovídající vstupní motor automaticky, včetně offline nastavení při prvním spuštění. Japonština používá Mozc, korejština standardní dvousadové Hangul, zjednodušená čínština Pinyin, Tchaj-wan standardní uspořádání Zhuyin metody Chewing a Hongkong Cangjie s hongkongskými tvary znaků. Japanese (US keyboard) poskytuje Mozc s americkým rozložením klávesnice. Klávesy Hangul, Zhuyin a Cangjie zůstávají na svých standardních pozicích, i když píšete latinkou na Dvorak, Colemak nebo AZERTY. Pokud jste Hangul nebo Chewing přidali už dříve, zrušte jejich výběr a znovu je vyberte v části _Setup > Keyboard > Input Methods_, aby se jejich klávesy přesunuly tam; motor, se kterým už píšete, nechá Omarchy na pokoji.

Psaní začíná v latinském režimu. Stisknutím `Super + I` procházíte nakonfigurovanými vstupními metodami a stisknutím `Super + Shift + I` procházíte zpět. Klepnutím na samotný `Shift` vystoupíte ze vstupní metody, jako je Pinyin, do latinky a dalším klepnutím se vrátíte zpět, stejně jako to funguje v Sogou, Microsoft Pinyin a macOS; `Shift` plus písmeno stále napíše velké písmeno. Na japonských klávesnicích přepíná vstup 全角/半角, 変換 ho zapíná a 無変換 ho vypíná. U korejštiny přepíná 한/영 Hangul a 한자 převádí na Hanja, ať už má vaše klávesnice vyhrazené klávesy, nebo pro ně odesílá Right Alt a Right Ctrl, jak to dělá mnoho notebooků, takže Right Alt a Right Ctrl tam nejsou obyčejné modifikátory; diktování se místo toho přepíná pomocí Alt + Space. `Ctrl + Space` zůstává k dispozici pro Tmux a Herdr; `Shift + CapsLock` zůstává klávesou compose.

Indikátor klávesnice se zobrazí vpravo na liště, když máte více rozložení klávesnice nebo vstupních metod. Kliknutím na něj přepínáte vstupní jazyky; japonština zobrazuje あ pro hiraganu. Pro výběr japonských znaků přepněte na japonštinu, napište slovo, například `nihongo`, a pak dvakrát stiskněte Space. Volbu potvrdíte stisknutím Enter. Pokud máte také více rozložení klávesnice, kliknutím pravým tlačítkem na indikátor mezi nimi procházíte.

V části _Setup > Keyboard > Keyboard Inputs_ vybíráte rozložení, například English a French, ze stejných možností, které se nabízejí během instalace. V části _Setup > Keyboard > Input Methods_ vybíráte, které motory pro skládání znaků jsou aktivní. Oba výběry se otevírají uvnitř nabídky Omarchy s vašimi aktuálními volbami zaškrtnutými. Volbu přepnete kliknutím nebo stisknutím Enter; každá změna se projeví okamžitě. Zrušením výběru vstupní metody ji odstraníte z cyklu, aniž byste ji odinstalovali; klávesnice zůstává k dispozici.

Spuštěním `omarchy setup keyboard` nebo `omarchy setup input` otevřete stejné výběry. Chcete-li z příkazového řádku přidat jeden jazyk, použijte `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` nebo `cangjie5`. Quick, Boshiamy a Array jsou ve stejném balíčku jako Cangjie a zobrazují se ve výběru Input Methods. Vaše vlastní klávesy pro přepínání zůstanou zachovány. Pro alternativní rozložení motorů nebo kláves nainstalujte `fcitx5-configtool` pomocí `omarchy pkg add fcitx5-configtool` a spusťte ho z terminálu. Výběr vstupního jazyka nezmění jazyk plochy. Výběrem Japanese, Korean nebo Chinese v části _Setup > Language_ přidáte příslušnou vstupní metodu, pokud zatím žádnou nemáte.

Pomocí `Super + I` procházíte vstupními metodami nebo rozloženími klávesnice a pomocí `Super + Shift + I` jdete opačným směrem, takže se třemi nakonfigurovanými se můžete pohybovat mezi dvěma sousedy. Indikátor vstupu se vpravo na liště zobrazí pouze tehdy, když je nakonfigurována více než jedna vstupní metoda nebo rozložení. Tato zkratka plochy funguje vedle vašich stávajících kláves pro přepínání Fcitx; můžete ji přepsat v `~/.config/hypr/bindings.lua`. Vstupní motory a sekvence compose používají službu [Fcitx5](https://fcitx-im.org/), která už běží v každé relaci.

### Použití ALT jako SUPER

Na některých klávesnicích není pohodlné používat primární klávesu meta (klávesu Windows/cmd) jako SUPER. Pomocí této změny ji můžete místo toho nastavit na ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
