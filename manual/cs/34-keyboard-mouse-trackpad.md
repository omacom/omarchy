# Klávesnice, myš, trackpad

Hyprland vám umožní konfigurovat všechny vstupy do velkých podrobností. Opakování klávesnice můžete změnit tak, aby bylo nadzvukově rychlé, nebo trackpad nechat používat přirozené posouvání. Vše měníte v souboru `~/.config/hypr/input.lua`, ke kterému se dostanete také prostřednictvím části _Nastavení > Vstup_ v nabídce Omarchy (`Super + Space`). Cokoli, co tam nastavíte, nahradí výchozí nastavení Omarchy.

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

Na wiki Hyprlandu pro vstupy si můžete [prohlédnout všechny možnosti vstupu](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock funguje jako běžný Caps Lock a kombinace `Shift + CapsLock` je klávesa pro skládání pro [rychlá emoji](07-hotkeys.md#quick-emojis) a [další doplňování](07-hotkeys.md#quick-completions). Pokud byste raději měli klávesu pro skládání jinde, nahraďte řetězec `omarchy:shift_caps_compose` v možnosti `kb_options`. Tento příklad například přesouvá klávesu pro skládání na pravý Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gesta trackpadu

Můžete také zapnout [gesta pro touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), například přejetí třemi prsty pro změnu pracovní plochy:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Na noteboocích Dell XPS s haptickým touchpadem můžete také nastavit sílu kliknutí na nízkou, střední nebo vysokou v části _Akce > Hardware > Haptika touchpadu_.

### Psaní v čínštině, japonštině a dalších jazycích

Když se vás instalační program zeptá na klávesnici, vyberte japonštinu, korejštinu, čínštinu (zjednodušenou, Pinyin) nebo čínštinu (tradiční, Zhuyin). Omarchy konfiguruje klávesnici a odpovídající vstupní modul automaticky, včetně nastavení při prvním spuštění offline. Japonština používá Mozc, korejština používá standardní dvousadový Hangul, zjednodušená čínština používá Pinyin a tradiční čínština používá standardní uspořádání Zhuyin od Chewing. Japonština (americká klávesnice) poskytuje Mozc s americkým rozložením klávesnice.

Psaní začíná v latinkovém režimu. Stisknutím klávesové zkratky `Super + I` procházejte nakonfigurovanými metodami vstupu a klávesovou zkratkou `Super + Shift + I` procházejte zpět. Klepnutím na klávesu `Shift` samotnou vystoupíte z metody vstupu, jako je Pinyin, do latinkových písmen, a opětovným klepnutím se vrátíte zpět, způsobem, jakým fungují Sogou, Microsoft Pinyin a macOS; klávesa `Shift` plus písmeno stále napíše velké písmeno. Na japonských klávesnicích klávesa 全角/半角 vstup přepíná, klávesa 変換 ho zapíná a klávesa 無変換 ho vypíná. Při korejském rozložení klávesnice přepínají vyhrazené klávesy 한/영 a 한자 Hangul a převádějí na Hanja. Klávesová zkratka `Ctrl + Space` zůstává k dispozici pro Tmux a Herdr; klávesová zkratka `Shift + CapsLock` zůstává klávesou pro skládání.

Indikátor klávesnice se objeví napravo od panelu, když máte více rozložení klávesnice nebo metod vstupu. Kliknutím na něj přepnete vstupní jazyky; japonština zobrazuje pro hiraganu znak あ. Pro výběr japonských znaků přepněte na japonštinu, napište slovo, například `nihongo`, a poté dvakrát stiskněte mezerník. Svou volbu přijmete stisknutím klávesy Enter. Pokud máte také více rozložení klávesnice, kliknutím pravým tlačítkem na indikátor je procházejte.

Pomocí části _Nastavení > Psaní > Rozložení klávesnice_ vyberte rozložení, například angličtinu a francouzštinu, ze stejných možností nabízených během instalace. Pomocí části _Nastavení > Psaní > Metody vstupu_ vyberte, které kompoziční moduly jsou aktivní. Oba výběry se otevírají uvnitř nabídky Omarchy s vašimi aktuálními volbami zaškrtnutými. Kliknutím nebo stisknutím klávesy Enter volbu přepnete; každá změna se projeví okamžitě. Odškrtnutí metody vstupu ji odebere z cyklu, aniž by ji odinstalovalo; klávesnice zůstává k dispozici.

Spuštěním příkazu `omarchy setup keyboard` nebo `omarchy setup input` otevřete stejné výběry. Chcete-li z příkazového řádku připojit jeden jazyk, použijte příkaz `omarchy setup input mozc`, `hangul`, `pinyin` nebo `chewing`. Vaše vlastní přepínací klávesy budou zachovány. Pro alternativní rozložení modulů nebo klávesy nainstalujte pomocí příkazu `omarchy pkg add fcitx5-configtool` balíček `fcitx5-configtool` a spusťte ho z terminálu. Výběr vstupního jazyka nemění jazyk pracovního prostředí.

Pomocí klávesové zkratky `Super + I` procházejte metodami vstupu nebo rozloženími klávesnice a klávesovou zkratkou `Super + Shift + I` jděte zpět opačným směrem, takže se třemi nakonfigurovanými můžete pohybovat mezi dvěma sousedy. Indikátor vstupu se objeví napravo od panelu pouze tehdy, když je nakonfigurována více než jedna metoda vstupu nebo rozložení. Tato vazba pracovního prostředí funguje vedle vašich stávajících přepínacích kláves Fcitxu; můžete ji přepsat v souboru `~/.config/hypr/bindings.lua`. Vstupní moduly a skládací sekvence používají službu [Fcitx5](https://fcitx-im.org/), která již běží v každé relaci.

### Použití klávesy ALT jako SUPER

Na některých klávesnicích není pohodlné používat primární klávesu meta (klávesu Windows/cmd) jako SUPER. Místo toho to můžete změnit na klávesu ALT pomocí této změny:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
