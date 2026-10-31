# Klávesnice, myš, trackpad

Hyprland vám umožňuje konfigurovat všechny vstupy do velkých podrobností. Rychlost opakování kláves můžete nastavit na nadzvukově rychlou nebo trackpadu zapnout přirozené posouvání. Všechno to změníte v `~/.config/hypr/input.lua`, kam se dostanete také přes _Nastavení > Vstup_ v nabídce Omarchy (`Super + Space`). Cokoli tam nastavíte, nahradí výchozí nastavení Omarchy.

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

Všechny možnosti vstupu [si můžete prohlédnout](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wiki Hyprlandu o vstupech.

CapsLock funguje jako běžný Caps Lock a `Shift + CapsLock` je klávesa Compose pro [rychlé emoji](07-hotkeys.md#quick-emojis) a [další dokončování](07-hotkeys.md#quick-completions). Pokud byste klávesu Compose raději měli jinde, nahraďte `omarchy:shift_caps_compose` v `kb_options`. Tímto se například klávesa Compose přesune na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gesta trackpadu

Přejetím po trackpadu se můžete pohybovat po ploše:

| Gesto | Akce |
| --- | --- |
| Tři prsty doleva / doprava | Předchozí / další pracovní plocha, včetně prázdných |
| Tři prsty nahoru | Přepnout konzoli AI |
| Tři prsty dolů | Otevřít nabídku Omarchy |
| Čtyři prsty doleva / doprava | Přesunout aktivní okno na předchozí / další pracovní plochu |
| Čtyři prsty dolů | Přepnout režim celé obrazovky |

Chcete-li některé změnit, zrušte jeho nastavení v `~/.config/hypr/input.lua` před přidáním vlastního [gesta trackpadu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), protože Hyprland nepřijme dvě gesta na stejném počtu prstů a ve stejném směru:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Chcete-li všechny gesta Omarchy vypnout, nastavte `omarchy_default_gestures = false` poblíž začátku `~/.config/hypr/hyprland.lua`, ještě před načtením výchozích nastavení Omarchy.

Na laptopech Dell XPS s haptickým touchpadem můžete také nastavit sílu kliknutí na nízkou, střední nebo vysokou v _Trigger > Hardware > Touchpad Haptics_.

### Psaní v čínštině, japonštině a dalších jazycích

Když se instalátor zeptá na klávesnici, vyberte japonštinu, korejštinu, čínštinu (zjednodušenou, Pinyin), Tchaj-wan (Zhuyin) nebo Hongkong (Cangjie). Omarchy automaticky nakonfiguruje klávesnici a odpovídající vstupní engine, včetně offline nastavení při prvním spuštění. Japonština používá Mozc, korejština používá standardní dvousouborové Hangul, zjednodušená čínština používá Pinyin, Tchaj-wan používá standardní uspořádání Zhuyin od Chewing a Hongkong používá Cangjie s hongkongskými tvary znaků. Japonština (americká klávesnice) poskytuje Mozc s americkým rozložením klávesnice. Klávesy Hangul, Zhuyin a Cangjie zůstávají na svých standardních pozicích, i když píšete latinská písmena na Dvorak, Colemak nebo AZERTY. Pokud jste předtím přidali Hangul nebo Chewing, zrušte jejich výběr a znovu je vyberte v _Nastavení > Psaní > Metody vstupu_, aby se jejich klávesy přesunuly tam; engine, kterým už píšete, Omarchy nechá na pokoji.

Psaní začíná v režimu latinky. Stisknutím `Super + I` procházíte nakonfigurované metody vstupu a `Super + Shift + I` procházíte zpět. Samotným klepnutím na `Shift` vyskočíte z metody vstupu, jako je Pinyin, do latinských písmen a dalším klepnutím se vrátíte zpět, stejně jako fungují Sogou, Microsoft Pinyin a macOS; `Shift` plus písmeno stále píše velké písmeno. Na japonských klávesnicích 全角/半角 přepíná vstup, 変換 jej zapíná a 無変換 jej vypíná. U korejštiny 한/영 přepíná Hangul a 한자 převádí na Hanja, ať už má vaše klávesnice vyhrazené klávesy, nebo pro ně odesílá Right Alt a Right Ctrl, jako to dělá mnoho laptopů, takže Right Alt a Right Ctrl tam nejsou obyčejné modifikátory; diktování se místo toho přepíná pomocí Alt + Space. `Ctrl + Space` zůstává k dispozici pro Tmux a Herdr; `Shift + CapsLock` zůstává klávesou Compose.

Indikátor klávesnice se zobrazuje vpravo na liště, když máte více rozložení klávesnice nebo metod vstupu. Kliknutím na něj přepnete vstupní jazyky; japonština zobrazuje あ pro hiraganu. Pro výběr japonských znaků přepněte na japonštinu, napište slovo jako `nihongo` a poté dvakrát stiskněte Space. Stisknutím Enter přijmete svou volbu. Pokud máte také více rozložení klávesnice, kliknutím pravým tlačítkem na indikátor je můžete procházet.

Použijte _Nastavení > Psaní > Rozložení klávesnice_ k výběru rozložení, jako je angličtina a francouzština, ze stejných možností nabízených při instalaci. Použijte _Nastavení > Psaní > Metody vstupu_ k výběru, které kompoziční enginy jsou aktivní. Oba výběry se otevírají uvnitř nabídky Omarchy s vašimi aktuálními výběry zaškrtnutými. Kliknutím nebo stisknutím Enter přepnete volbu; každá změna se použije okamžitě. Zrušením výběru metody vstupu ji odstraníte z cyklu bez odinstalace; klávesnice zůstává k dispozici.

Spusťte `omarchy setup keyboard` nebo `omarchy setup input` pro otevření stejných výběrů. Pro připojení jednoho jazyka z příkazového řádku použijte `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` nebo `cangjie5`. Quick, Boshiamy a Array jsou ve stejném balíčku jako Cangjie a objevují se ve výběru Metody vstupu. Vaše vlastní přepínací klávesy budou zachovány. Pro alternativní rozložení engine nebo kláves nainstalujte `fcitx5-configtool` pomocí `omarchy pkg add fcitx5-configtool` a spusťte jej z terminálu. Výběr vstupního jazyka nemění jazyk plochy. Výběrem japonštiny, korejštiny nebo čínštiny v _Nastavení > Jazyk_ přidáte její metodu vstupu, když ještě žádnou nemáte.

Pomocí `Super + I` můžete procházet metody vstupu nebo rozložení klávesnice a pomocí `Super + Shift + I` se vrátit opačným směrem, takže se třemi nakonfigurovanými se můžete pohybovat mezi dvěma sousedy. Indikátor vstupu se vpravo na liště zobrazí pouze tehdy, je-li nakonfigurováno více než jedna metoda vstupu nebo rozložení. Tato vazba plochy funguje vedle vašich stávajících přepínacích kláves Fcitx; můžete ji přepsat v `~/.config/hypr/bindings.lua`. Vstupní enginy a sekvence Compose používají službu [Fcitx5](https://fcitx-im.org/) již běžící v každé relaci.

### Použití ALT jako SUPER

Na některých klávesnicích není pohodlné používat primární meta klávesu (klávesu Windows/cmd) jako SUPER. Pomocí této změny to můžete změnit na ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
