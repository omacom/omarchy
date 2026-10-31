# Klávesnice, myš, trackpad

Hyprland vám umožňuje podrobně nakonfigurovat všechny vaše vstupy. Opakování kláves může být nadzvukově rychlé, nebo můžete na trackpadu používat přirozené posouvání. Vše změníte v `~/.config/hypr/input.lua`, kam se dostanete také přes _Nastavení > Vstup_ v nabídce Omarchy (`Super + Space`). Cokoli tam nastavíte, nahradí výchozí nastavení Omarchy.

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

[Všechny možnosti vstupu](https://wiki.hypr.land/Configuring/Basics/Variables/#input) si můžete prohlédnout na wiki Hyprlandu o vstupech.

CapsLock funguje jako běžný Caps Lock a kombinace `Shift + CapsLock` je klávesa Compose pro zadávání znaků posloupností kláves, například pro [rychlá emoji](07-hotkeys.md#quick-emojis) a [další doplňování](07-hotkeys.md#quick-completions). Pokud byste raději měli klávesu Compose jinde, nahraďte řetězec `omarchy:shift_caps_compose` v možnosti `kb_options`. Tento příklad například přesouvá klávesu Compose na pravý Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gesta touchpadu

Přejetím prstů po touchpadu se pohybujete po ploše:

| Gesto | Akce |
| --- | --- |
| Tři prsty doleva / doprava | Předchozí / další pracovní plocha, včetně prázdných |
| Tři prsty nahoru | Přepnout konzoli AI |
| Tři prsty dolů | Otevřít nabídku Omarchy |
| Čtyři prsty doleva / doprava | Přesunout aktivní okno na předchozí / další pracovní plochu |
| Čtyři prsty dolů | Přepnout celou obrazovku |

Chcete-li některé gesto změnit, nejprve ho v `~/.config/hypr/input.lua` zrušte a až potom přidejte vlastní [gesto na touchpadu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), protože Hyprland nepřijme dvě gesta pro stejné prsty a stejný směr:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Chcete-li všechna gesta Omarchy vypnout, nastavte `omarchy_default_gestures = false` poblíž začátku souboru `~/.config/hypr/hyprland.lua`, ještě před načtením výchozího nastavení Omarchy.

Na noteboocích Dell XPS s haptickým touchpadem můžete sílu kliknutí nastavit na nízkou, střední nebo vysokou v nabídce _Akce > Hardware > Haptika touchpadu_.

### Psaní v čínštině, japonštině a dalších jazycích

Když se instalátor zeptá na vaši klávesnici, vyberte japonštinu, korejštinu, čínštinu (zjednodušenou, Pinyin), Tchaj-wan (Zhuyin) nebo Hongkong (Cangjie). Omarchy klávesnici a odpovídající vstupní engine nakonfiguruje automaticky, včetně offline nastavení při prvním spuštění. Japonština používá Mozc, korejština používá standardní dvousadový Hangul, zjednodušená čínština používá Pinyin, Tchaj-wan používá standardní uspořádání Zhuyin od Chewing a Hongkong používá Cangjie s hongkongskými tvary znaků. Japonština (klávesnice US) poskytuje Mozc s rozložením klávesnice US. Klávesy Hangul, Zhuyin a Cangjie zůstávají na svých standardních pozicích, i když latinská písmena píšete na rozložení Dvorak, Colemak nebo AZERTY. Pokud jste Hangul nebo Chewing přidali už dříve, zrušte jejich výběr a znovu je vyberte v nabídce _Nastavení > Psaní > Metody vstupu_, aby se jejich klávesy přesunuly tam; vstupní engine, se kterým už píšete, Omarchy nechá na pokoji.

Psaní začíná v latinkovém režimu. Stisknutím klávesové zkratky `Super + I` procházejte nakonfigurovanými metodami vstupu a klávesovou zkratkou `Super + Shift + I` procházejte zpět. Klepnutím na klávesu `Shift` samotnou vystoupíte z metody vstupu, jako je Pinyin, do latinkových písmen, a opětovným klepnutím se vrátíte zpět, způsobem, jakým fungují Sogou, Microsoft Pinyin a macOS; klávesa `Shift` plus písmeno stále napíše velké písmeno. Na japonských klávesnicích klávesa 全角/半角 vstup přepíná, klávesa 変換 ho zapíná a klávesa 無変換 ho vypíná. U korejštiny klávesa 한/영 přepíná Hangul a klávesa 한자 převádí na Hanja, ať už má vaše klávesnice vyhrazené klávesy, nebo za ně posílá pravý Alt a pravý Ctrl, jako to dělá mnoho notebooků. Pravý Alt a pravý Ctrl proto u korejštiny nefungují jako běžné modifikátory; diktování při podržení klávesy zůstává na F9. Klávesová zkratka `Ctrl + Space` zůstává k dispozici pro Tmux a Herdr; klávesová zkratka `Shift + CapsLock` zůstává klávesou Compose.

Indikátor klávesnice se zobrazí vpravo na liště, když máte více rozložení klávesnice nebo vstupních metod. Kliknutím na něj přepnete vstupní jazyky; japonština zobrazuje あ pro hiraganu. Pro výběr japonských znaků přepněte na japonštinu, napište slovo jako `nihongo` a potom dvakrát stiskněte Space. Stisknutím Enter svou volbu potvrdíte. Pokud máte také více rozložení klávesnice, kliknutím pravým tlačítkem na indikátor mezi nimi procházíte.

Pomocí části _Nastavení > Psaní > Rozložení klávesnice_ vyberte rozložení, například angličtinu a francouzštinu, ze stejných možností nabízených během instalace. Pomocí části _Nastavení > Psaní > Metody vstupu_ vyberte, které metody vstupu jsou aktivní. Oba výběry se otevírají uvnitř nabídky Omarchy s vašimi aktuálními volbami zaškrtnutými. Kliknutím nebo stisknutím klávesy Enter volbu přepnete; každá změna se projeví okamžitě. Odškrtnutí metody vstupu ji odebere z cyklu, aniž by ji odinstalovalo; klávesnice zůstává k dispozici.

Spuštěním `omarchy setup keyboard` nebo `omarchy setup input` otevřete stejné výběry. Chcete-li jeden jazyk přidat z příkazového řádku, použijte `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` nebo `cangjie5`. Quick, Boshiamy a Array jsou ve stejném balíčku jako Cangjie a zobrazují se ve výběru _Metody vstupu_. Vaše vlastní klávesy pro přepínání zůstanou zachovány. Pro alternativní rozložení nebo klávesy enginu nainstalujte `fcitx5-configtool` pomocí `omarchy pkg add fcitx5-configtool` a spusťte ho z terminálu. Výběr vstupního jazyka nezmění jazyk plochy. Výběrem japonštiny, korejštiny nebo čínštiny v části _Nastavení > Jazyk_ přidáte její vstupní metodu, pokud ještě žádnou nemáte.

Pomocí `Super + I` procházíte vstupní metody nebo rozložení klávesnice a pomocí `Super + Shift + I` jdete opačným směrem, takže se třemi nakonfigurovanými můžete přecházet mezi dvěma sousedy. Indikátor vstupu se vpravo na liště zobrazí, pouze když je nakonfigurována více než jedna vstupní metoda nebo jedno rozložení. Tato vazba pro plochu funguje vedle vašich stávajících kláves pro přepínání Fcitx; můžete ji přepsat v `~/.config/hypr/bindings.lua`. Vstupní enginy a sekvence compose používají službu [Fcitx5](https://fcitx-im.org/), která už běží v každé relaci.

### Použití Alt jako Super

Na některých klávesnicích není pohodlné používat primární metaklávesu (klávesu Windows/cmd) jako SUPER. Pomocí této změny ji místo toho můžete nastavit na ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
