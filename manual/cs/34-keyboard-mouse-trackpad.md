# Klávesnice, myš, trackpad

Hyprland vám umožňuje podrobně nakonfigurovat všechny vstupy. Opakování kláves si můžete nastavit nadzvukově rychle, nebo trackpadu zapnout přirozené posouvání. Vše měníte v `~/.config/hypr/input.lua`, kam se dostanete i přes _Nastavení > Vstup_ v nabídce Omarchy (`Super + Space`). Cokoli tam nastavíte, nahradí výchozí nastavení Omarchy.

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

Na wiki Hyprlandu si můžete [zobrazit všechny možnosti vstupu](https://wiki.hypr.land/Configuring/Basics/Variables/#input) pro vstupy.

CapsLock funguje jako běžný Caps Lock a `Shift + CapsLock` je klávesa compose pro [rychlá emoji](07-hotkeys.md#quick-emojis) a [další doplňování](07-hotkeys.md#quick-completions). Pokud chcete klávesu compose raději jinde, nahraďte v `kb_options` hodnotu `omarchy:shift_caps_compose`. Například tímto přesunete klávesu compose na pravý Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gesta trackpadu

Můžete si také zapnout [gesta touchpadu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), například přejetí třemi prsty pro přepínání pracovních ploch:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Na noteboocích Dell XPS s haptickým touchpadem můžete také nastavit sílu kliknutí na nízkou, střední nebo vysokou v _Trigger > Hardware > Haptika touchpadu_.

### Psaní v čínštině, japonštině a dalších jazycích

Když instalátor požádá o vaši klávesnici, vyberte japonštinu, korejštinu, čínštinu (zjednodušenou, Pinyin), Tchaj-wan (Zhuyin) nebo Hongkong (Cangjie). Omarchy automaticky nakonfiguruje klávesnici a odpovídající vstupní engine, a to i během offline nastavení při prvním spuštění. Japonština používá Mozc, korejština používá standardní dvousadový Hangul, zjednodušená čínština používá Pinyin, Tchaj-wan používá standardní uspořádání Zhuyin od Chewing a Hongkong používá Cangjie s hongkongskými tvary znaků. Japonština (americká klávesnice) poskytuje Mozc s americkým rozložením klávesnice. Klávesy pro Hangul, Zhuyin a Cangjie zůstávají na svých standardních pozicích, i když píšete latinkou s rozložením Dvorak, Colemak nebo AZERTY. Pokud jste Hangul nebo Chewing přidali už dříve, zrušte jejich výběr a znovu je vyberte v _Nastavení > Psaní > Vstupní metody_, aby se jejich klávesy přesunuly tam; engine, se kterým už píšete, nechá Omarchy na pokoji.

Psaní začíná v latinkovém režimu. Stiskem `Super + I` procházíte nakonfigurovanými vstupními metodami a stiskem `Super + Shift + I` procházíte zpět. Samostatným klepnutím na `Shift` vystoupíte ze vstupní metody jako Pinyin do latinky a dalším klepnutím se vrátíte zpět, stejně jako fungují Sogou, Microsoft Pinyin a macOS; `Shift` plus písmeno stále píše velké písmeno. Na japonských klávesnicích 全角/半角 přepíná vstup, 変換 ho zapíná a 無変換 ho vypíná. U korejštiny 한/영 přepíná Hangul a 한자 převádí na Hanja, ať už má vaše klávesnice vyhrazené klávesy, nebo za ně posílá pravý Alt a pravý Ctrl, jako to dělá mnoho notebooků, takže pravý Alt a pravý Ctrl tam nejsou obyčejné modifikátory; diktování podržením klávesy zůstává na F9. `Ctrl + Space` zůstává k dispozici pro Tmux a Herdr; `Shift + CapsLock` zůstává klávesou compose.

Indikátor klávesnice se zobrazí vpravo na liště, když máte více rozložení klávesnice nebo vstupních metod. Kliknutím na něj přepnete vstupní jazyky; japonština zobrazuje あ pro hiraganu. Pro výběr japonských znaků přepněte do japonštiny, napište slovo jako `nihongo` a pak dvakrát stiskněte Space. Stiskem Enter volbu potvrdíte. Pokud máte také více rozložení klávesnice, kliknutím pravým tlačítkem na indikátor mezi nimi procházíte.

Pomocí _Nastavení > Psaní > Rozložení klávesnice_ vyberete rozložení, jako je angličtina a francouzština, ze stejných možností, které se nabízejí během instalace. Pomocí _Nastavení > Psaní > Vstupní metody_ vyberete, které kompoziční enginy jsou aktivní. Oba výběry se otevřou uvnitř nabídky Omarchy s vašimi aktuálními volbami zaškrtnutými. Kliknutím nebo stiskem Enter volbu přepnete; každá změna se projeví okamžitě. Zrušení výběru vstupní metody ji odstraní z cyklu, aniž by ji odinstalovalo; klávesnice zůstává k dispozici.

Spuštěním `omarchy setup keyboard` nebo `omarchy setup input` otevřete stejné výběry. Chcete-li z příkazového řádku přidat jeden jazyk, použijte `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` nebo `cangjie5`. Quick, Boshiamy a Array jsou ve stejném balíčku jako Cangjie a objeví se ve výběru vstupních metod. Vaše vlastní klávesy pro přepínání zůstanou zachovány. Pro alternativní rozložení enginu nebo klávesy nainstalujte `fcitx5-configtool` příkazem `omarchy pkg add fcitx5-configtool` a spusťte ho z terminálu. Výběr vstupního jazyka nemění jazyk desktopu. Výběr japonštiny, korejštiny nebo čínštiny v _Nastavení > Jazyk_ přidá její vstupní metodu, pokud ještě žádnou nemáte.

Pomocí `Super + I` procházíte vstupními metodami nebo rozloženími klávesnice a pomocí `Super + Shift + I` jdete opačným směrem, takže se třemi nakonfigurovanými se můžete pohybovat mezi dvěma sousedy. Indikátor vstupu se vpravo na liště zobrazí, jen když je nakonfigurována více než jedna vstupní metoda nebo rozložení. Tato desktopová vazba funguje vedle vašich stávajících kláves pro přepínání Fcitx; můžete ji přepsat v `~/.config/hypr/bindings.lua`. Vstupní enginy a sekvence compose používají službu [Fcitx5](https://fcitx-im.org/), která už běží v každé relaci.

### Použití ALT jako SUPER

Na některých klávesnicích není pohodlné používat primární meta klávesu (klávesu Windows/cmd) jako SUPER. Místo toho si ji můžete touto změnou nastavit na ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
