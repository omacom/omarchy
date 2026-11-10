# Klávesnice, myš, trackpad

Hyprland vám umožňuje podrobně nakonfigurovat všechny vstupy. Opakování kláves můžete nastavit na nadzvukovou rychlost nebo u trackpadu zapnout přirozené posouvání. Všechno změníte v `~/.config/hypr/input.lua`, kam se dostanete také přes _Setup > Input_ v nabídce Omarchy (`Super + Space`). Cokoli tam nastavíte, nahradí výchozí nastavení Omarchy.

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

Na wiki Hyprlandu věnované vstupům si můžete [prohlédnout všechny možnosti vstupu](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock funguje jako normální Caps Lock a `Shift + CapsLock` je klávesa compose pro [rychlé emoji](07-hotkeys.md#quick-emojis) a [další doplňování](07-hotkeys.md#quick-completions). Pokud byste klávesu compose měli raději jinde, nahraďte `omarchy:shift_caps_compose` v `kb_options`. Takto například přesunete klávesu compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkční klávesy

Horní řada klávesnice notebooku ve výchozím nastavení odesílá multimediální klávesy (hlasitost, jas a tak dále) a podržením `Fn` získáte F1-F12; `Fn + Esc` to zamkne opačným směrem, dokud to znovu nestisknete. Většina klávesnic si tento zámek pamatuje sama. Notebooky ASUS a klávesnice ve stylu Apple to nechávají na Linuxu, který je při každém spuštění nastaví na multimediální klávesy. Chcete-li, aby místo toho začínaly na F1-F12, spusťte `omarchy keyboard toprow fnkeys` (a `omarchy keyboard toprow mediakeys` pro návrat zpět); na některých noteboocích se to projeví až po restartu. Počítače Apple Silicon Mac si zachovávají vlastní nastavení.

### Gesta na trackpadu

Přejetím po trackpadu se pohybujete po ploše:

| Gesto | Akce |
| --- | --- |
| Tři prsty doleva / doprava | Předchozí / další pracovní plocha, včetně prázdných |
| Tři prsty nahoru | Přepnout AI konzoli |
| Tři prsty dolů | Otevřít nabídku Omarchy |
| Čtyři prsty doleva / doprava | Přesunout aktivní okno na předchozí / další pracovní plochu |
| Čtyři prsty dolů | Přepnout režim celé obrazovky |

Chcete-li některé gesto změnit, nejprve ho zrušte v `~/.config/hypr/input.lua` a teprve potom přidejte vlastní [gesto na touchpadu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), protože Hyprland nepřijme dvě gesta pro stejné prsty a stejný směr:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Chcete-li všechna gesta Omarchy vypnout, nastavte `omarchy_default_gestures = false` blízko horní části `~/.config/hypr/hyprland.lua`, ještě předtím, než se načte výchozí nastavení Omarchy.

Na noteboocích Dell XPS s haptickým touchpadem můžete také nastavit sílu kliknutí na nízkou, střední nebo vysokou v _Trigger > Hardware > Touchpad Haptics_.

### Psaní v čínštině, japonštině a dalších jazycích

Když se vás instalátor zeptá na klávesnici, vyberte japonštinu, korejštinu, čínštinu (zjednodušená, Pinyin), Tchaj-wan (Zhuyin) nebo Hongkong (Cangjie). Omarchy nakonfiguruje klávesnici a odpovídající vstupní engine automaticky, a to i během offline nastavení při prvním spuštění. Japonština používá Mozc, korejština používá standardní dvousestavové Hangul, zjednodušená čínština používá Pinyin, Tchaj-wan používá standardní uspořádání Zhuyin od Chewing a Hongkong používá Cangjie s hongkongskými tvary znaků. Japonština (americká klávesnice) poskytuje Mozc s americkým rozložením klávesnice. Klávesy Hangul, Zhuyin a Cangjie zůstávají na svých standardních pozicích, i když píšete latinkou s rozložením Dvorak, Colemak nebo AZERTY. Pokud jste Hangul nebo Chewing přidali už dříve, zrušte jejich výběr a znovu je vyberte v _Setup > Keyboard > Input Methods_, aby se jejich klávesy přesunuly na tato místa; engine, se kterým už píšete, nechá Omarchy na pokoji.

Psaní začíná v režimu latinky. Stisknutím `Super + I` procházíte nakonfigurované metody vstupu a stisknutím `Super + Shift + I` procházíte zpět. Samotným klepnutím na `Shift` vystoupíte z metody vstupu, jako je Pinyin, do latinky a dalším klepnutím se vrátíte zpět, tak jak to funguje u Sogou, Microsoft Pinyin a macOS; `Shift` plus písmeno stále píše velké písmeno. Na japonských klávesnicích 全角/半角 přepíná vstup, 変換 ho zapíná a 無変換 ho vypíná. U korejštiny 한/영 přepíná Hangul a 한자 převádí na Hanja, ať už má vaše klávesnice vyhrazené klávesy, nebo pro ně odesílá Right Alt a Right Ctrl, jako to dělá mnoho notebooků, takže Right Alt a Right Ctrl tam nejsou obyčejné modifikátory; diktování se místo toho přepíná pomocí Alt + Space. `Ctrl + Space` zůstává k dispozici pro Tmux a Herdr; `Shift + CapsLock` zůstává klávesou compose.

Indikátor klávesnice se zobrazí napravo na liště, když máte více rozložení klávesnice nebo metod vstupu. Kliknutím na něj přepínáte vstupní jazyky; japonština zobrazuje あ pro hiraganu. Chcete-li vybírat japonské znaky, přepněte na japonštinu, napište slovo jako `nihongo` a poté dvakrát stiskněte Space. Stisknutím Enter volbu potvrdíte. Pokud máte také více rozložení klávesnice, kliknutím pravým tlačítkem na indikátor mezi nimi procházíte.

V _Setup > Keyboard > Keyboard Inputs_ vyberte rozložení, jako je angličtina a francouzština, ze stejných možností, které se nabízejí během instalace. V _Setup > Keyboard > Input Methods_ vyberte, které kompoziční enginy jsou aktivní. Oba výběry se otevírají uvnitř nabídky Omarchy s vašimi aktuálními volbami zaškrtnutými. Kliknutím nebo stisknutím Enter volbu přepnete; každá změna se projeví okamžitě. Zrušením výběru metody vstupu ji odstraníte z cyklu, aniž byste ji odinstalovali; klávesnice zůstane k dispozici.

Spuštěním `omarchy setup keyboard` nebo `omarchy setup input` otevřete stejné výběry. Chcete-li z příkazového řádku připojit jeden jazyk, použijte `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` nebo `cangjie5`. Quick, Boshiamy a Array jsou ve stejném balíčku jako Cangjie a zobrazují se ve výběru Input Methods. Vaše vlastní klávesy pro přepínání zůstanou zachovány. Pro alternativní rozložení enginu nebo klávesy nainstalujte `fcitx5-configtool` pomocí `omarchy pkg add fcitx5-configtool` a spusťte ho z terminálu. Výběr vstupního jazyka nemění jazyk plochy. Volba japonštiny, korejštiny nebo čínštiny v _Setup > Language_ přidá její metodu vstupu, když ještě žádnou nemáte.

Pomocí `Super + I` procházejte metody vstupu nebo rozložení klávesnice a pomocí `Super + Shift + I` jděte opačným směrem, takže se třemi nakonfigurovanými se můžete pohybovat mezi dvěma sousedními. Indikátor vstupu se zobrazí napravo na liště pouze tehdy, když je nakonfigurována více než jedna metoda vstupu nebo rozložení. Tato vazba pro plochu funguje vedle vašich stávajících kláves pro přepínání Fcitx; můžete ji přepsat v `~/.config/hypr/bindings.lua`. Vstupní enginy a sekvence compose používají službu [Fcitx5](https://fcitx-im.org/), která už běží v každé relaci.

### Použití ALT jako SUPER

Na některých klávesnicích není pohodlné používat primární meta klávesu (klávesu Windows/cmd) jako SUPER. Pomocí této změny to můžete změnit na ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
