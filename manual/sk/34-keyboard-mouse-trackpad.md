# Klávesnica, myš, trackpad

Hyprland vám umožňuje podrobne nakonfigurovať všetky vaše vstupy. Môžete nastaviť opakovanie kláves na nadzvukovú rýchlosť alebo na trackpade používať prirodzené posúvanie. Všetko zmeníte v `~/.config/hypr/input.lua`, kam sa dostanete aj cez _Setup > Input_ v menu Omarchy (`Super + Space`). Všetko, čo tam nastavíte, nahradí predvolené nastavenia Omarchy.

Tu je príklad:

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

Na wiki Hyprlandu o vstupoch si môžete [pozrieť všetky možnosti vstupu](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock funguje ako bežný Caps Lock a `Shift + CapsLock` je kláves Compose pre [rýchle emoji](07-hotkeys.md#quick-emojis) a [ďalšie dokončovanie](07-hotkeys.md#quick-completions). Ak chcete mať kláves Compose radšej inde, nahraďte `omarchy:shift_caps_compose` v `kb_options`. Tento príklad napríklad presunie kláves Compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestá na trackpade

Potiahnutím po trackpade sa môžete pohybovať po pracovnej ploche:

| Gesture | Action |
| --- | --- |
| Three fingers left / right | Previous / next workspace, including empty ones |
| Three fingers up | Toggle the AI console |
| Three fingers down | Open the Omarchy menu |
| Four fingers left / right | Move the active window to the previous / next workspace |
| Four fingers down | Toggle fullscreen |

Ak chcete niektoré gesto zmeniť, zrušte ho v `~/.config/hypr/input.lua` skôr, než pridáte vlastné [gesto na trackpade](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), pretože Hyprland neprijme dve gestá pre rovnaké prsty a smer:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Ak chcete vypnúť všetky gestá Omarchy, nastavte `omarchy_default_gestures = false` blízko začiatku súboru `~/.config/hypr/hyprland.lua`, ešte pred načítaním predvolených nastavení Omarchy.

Na notebookoch Dell XPS s haptickým touchpadom môžete tiež nastaviť silu kliknutia na nízku, strednú alebo vysokú v časti _Trigger > Hardware > Touchpad Haptics_.

### Písanie v čínštine, japončine a ďalších jazykoch

Keď sa vás inštalátor spýta na klávesnicu, vyberte japončinu, kórejčinu, čínštinu (zjednodušenú, Pinyin), Taiwan (Zhuyin) alebo Hongkong (Cangjie). Omarchy automaticky nakonfiguruje klávesnicu a zodpovedajúci vstupný engine, a to aj počas offline nastavenia pri prvom spustení. Japončina používa Mozc, kórejčina používa štandardný dvojznakový Hangul, zjednodušená čínština používa Pinyin, Taiwan používa štandardné rozloženie Zhuyin od Chewing a Hongkong používa Cangjie s hongkonskými tvarmi znakov. Japončina (americká klávesnica) poskytuje Mozc s rozložením americkej klávesnice. Klávesy Hangul, Zhuyin a Cangjie zostávajú na svojich štandardných pozíciách, aj keď latinské písmená píšete s rozložením Dvorak, Colemak alebo AZERTY. Ak ste predtým pridali Hangul alebo Chewing, zrušte ich výber a znova ich vyberte v časti _Setup > Typing > Input Methods_, aby sa ich klávesy presunuli tam; engine, s ktorým už píšete, nechá Omarchy na pokoji.

Písanie sa začína v latinskom režime. Stlačením `Super + I` môžete prechádzať nakonfigurovanými metódami vstupu a stlačením `Super + Shift + I` môžete prechádzať späť. Ťuknutím na samotný `Shift` vystúpite z metódy vstupu, ako je Pinyin, do latinských písmen a ďalším ťuknutím sa vrátite späť, tak ako fungujú Sogou, Microsoft Pinyin a macOS; `Shift` plus písmeno stále napíše veľké písmeno. Na japonských klávesniciach prepína vstup 全角/半角, 変換 ho zapína a 無変換 ho vypína. Pri kórejčine prepína 한/영 Hangul a 한자 prevádza na Hanja, či už má vaša klávesnica vyhradené klávesy, alebo pre ne odosiela Right Alt a Right Ctrl, ako to robí mnoho notebookov, takže Right Alt a Right Ctrl tam nie sú obyčajné modifikátory; diktovanie stlačením a podržaním zostáva na F9. `Ctrl + Space` zostáva k dispozícii pre Tmux a Herdr; `Shift + CapsLock` zostáva klávesom Compose.

Indikátor klávesnice sa zobrazí vpravo na paneli, keď máte viacero rozložení klávesnice alebo metód vstupu. Kliknutím naň môžete prepínať vstupné jazyky; japončina zobrazuje あ pre hiraganu. Ak chcete vybrať japonské znaky, prepnite na japončinu, napíšte slovo ako `nihongo` a potom dvakrát stlačte Space. Stlačením Enter výber potvrdíte. Ak máte aj viacero rozložení klávesnice, kliknutím pravým tlačidlom na indikátor ich môžete prechádzať.

Na výber rozložení, ako sú angličtina a francúzština, z rovnakých možností, aké sa ponúkajú počas inštalácie, použite _Setup > Typing > Keyboard Layouts_. Na výber aktívnych enginov na skladanie znakov použite _Setup > Typing > Input Methods_. Oba výbery sa otvoria v menu Omarchy s označenými vašimi aktuálnymi voľbami. Kliknutím alebo stlačením Enter voľbu prepnete; každá zmena sa uplatní okamžite. Zrušením výberu metódy vstupu ju odstránite z cyklu bez toho, aby ste ju odinštalovali; klávesnica zostane k dispozícii.

Rovnaké výbery otvoríte spustením `omarchy setup keyboard` alebo `omarchy setup input`. Ak chcete z príkazového riadka pridať jeden jazyk, použite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` alebo `cangjie5`. Quick, Boshiamy a Array sa dodávajú v rovnakom balíku ako Cangjie a zobrazujú sa vo výbere Input Methods. Vaše vlastné klávesy na prepínanie zostanú zachované. Ak chcete alternatívne rozloženia alebo klávesy enginov, nainštalujte `fcitx5-configtool` príkazom `omarchy pkg add fcitx5-configtool` a spustite ho z terminálu. Výber vstupného jazyka nezmení jazyk pracovnej plochy. Výber japončiny, kórejčiny alebo čínštiny v časti _Setup > Language_ pridá jej metódu vstupu, keď ešte žiadnu nemáte.

Stlačením `Super + I` môžete prechádzať metódami vstupu alebo rozloženiami klávesnice a stlačením `Super + Shift + I` môžete prechádzať opačným smerom, takže s tromi nakonfigurovanými možnosťami sa môžete pohybovať medzi dvoma susedmi. Indikátor vstupu sa zobrazí vpravo na paneli len vtedy, keď je nakonfigurovaná viac ako jedna metóda vstupu alebo rozloženie. Táto väzba pracovnej plochy funguje popri vašich existujúcich klávesoch na prepínanie Fcitx; môžete ju prepísať v `~/.config/hypr/bindings.lua`. Vstupné enginy a sekvencie Compose používajú službu [Fcitx5](https://fcitx-im.org/), ktorá už beží v každej relácii.

### Používanie ALT ako SUPER

Na niektorých klávesniciach nie je pohodlné používať primárny meta kláves (kláves Windows/cmd) ako SUPER. Touto zmenou to môžete zmeniť na ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
