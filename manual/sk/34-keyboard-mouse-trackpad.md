# Klávesnica, myš, trackpad

Hyprland vám umožňuje podrobne nakonfigurovať všetky vaše vstupy. Môžete nastaviť opakovanie klávesnice tak, aby bolo nadzvukovo rýchle, alebo nastaviť trackpad na prirodzené posúvanie. Všetko meníte v `~/.config/hypr/input.lua`, kam sa dostanete aj cez _Setup > Input_ v ponuke Omarchy (`Super + Space`). Čokoľvek tam nastavíte, nahradí predvolené nastavenia Omarchy.

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

Na wiki Hyprlandu pre vstupy si môžete [pozrieť všetky možnosti vstupu](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock funguje ako bežný Caps Lock a `Shift + CapsLock` je kláves compose pre [rýchle emoji](07-hotkeys.md#quick-emojis) a [ďalšie dopĺňania](07-hotkeys.md#quick-completions). Ak chcete mať kláves compose radšej inde, nahraďte `omarchy:shift_caps_compose` v `kb_options`. Napríklad takto presuniete kláves compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestá trackpadu

Pohybujte sa po pracovnej ploche potiahnutím po trackpade:

| Gesto | Akcia |
| --- | --- |
| Tri prsty doľava / doprava | Predchádzajúci / nasledujúci pracovný priestor vrátane prázdnych |
| Tri prsty nahor | Prepnúť konzolu AI |
| Tri prsty nadol | Otvoriť ponuku Omarchy |
| Štyri prsty doľava / doprava | Presunúť aktívne okno na predchádzajúci / nasledujúci pracovný priestor |
| Štyri prsty nadol | Prepnúť režim celej obrazovky |

Ak chcete niektoré zmeniť, najprv ho zrušte v `~/.config/hypr/input.lua` a až potom pridajte vlastné [gesto trackpadu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), pretože Hyprland neprijme dve gestá pre rovnaké prsty a smer:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Ak chcete vypnúť všetky gestá Omarchy, nastavte `omarchy_default_gestures = false` blízko začiatku súboru `~/.config/hypr/hyprland.lua`, ešte pred načítaním predvolených nastavení Omarchy.

Na laptopoch Dell XPS s haptickým touchpadom môžete tiež nastaviť silu kliknutia na nízku, strednú alebo vysokú v časti _Trigger > Hardware > Touchpad Haptics_.

### Písanie v čínštine, japončine a ďalších jazykoch

Keď sa vás inštalátor opýta na klávesnicu, vyberte japončinu, kórejčinu, čínštinu (zjednodušenú, Pinyin), Taiwan (Zhuyin) alebo Hongkong (Cangjie). Omarchy automaticky nakonfiguruje klávesnicu a zodpovedajúci vstupný nástroj, a to aj počas offline nastavenia pri prvom spustení. Japončina používa Mozc, kórejčina štandardné dvojradové rozloženie Hangul, zjednodušená čínština používa Pinyin, Taiwan používa štandardné rozloženie Zhuyin nástroja Chewing a Hongkong používa Cangjie s hongkonskými tvarmi znakov. Japončina (klávesnica US) poskytuje Mozc s rozložením klávesnice US. Klávesy Hangul, Zhuyin a Cangjie zostávajú na svojich štandardných pozíciách, aj keď píšete latinské písmená s rozložením Dvorak, Colemak alebo AZERTY. Ak ste Hangul alebo Chewing pridali už predtým, zrušte ich výber a znova ich vyberte v časti _Setup > Typing > Input Methods_, aby sa ich klávesy presunuli tam; nástroj, s ktorým už píšete, Omarchy nechá na pokoji.

Písanie sa začína v režime latinky. Stlačením `Super + I` prechádzate nakonfigurovanými metódami vstupu a stlačením `Super + Shift + I` prechádzate späť. Samostatným ťuknutím na `Shift` vystúpite z metódy vstupu, ako je Pinyin, do latinských písmen a opätovným ťuknutím sa vrátite späť, tak ako fungujú Sogou, Microsoft Pinyin a macOS; `Shift` plus písmeno stále napíše veľké písmeno. Na japonských klávesniciach 全角/半角 prepína vstup, 変換 ho zapína a 無変換 ho vypína. Pri kórejčine 한/영 prepína Hangul a 한자 prevádza na Hanja, či už má vaša klávesnica vyhradené klávesy, alebo pre ne posiela Right Alt a Right Ctrl, ako to robí mnoho laptopov, takže Right Alt a Right Ctrl tam nie sú obyčajné modifikátory; diktovanie sa namiesto toho prepína pomocou Alt + Space. `Ctrl + Space` zostáva k dispozícii pre Tmux a Herdr; `Shift + CapsLock` zostáva klávesom compose.

Indikátor klávesnice sa zobrazí v pravej časti panela, keď máte viacero rozložení klávesnice alebo metód vstupu. Kliknutím naň prepínate vstupné jazyky; japončina zobrazuje あ pre hiraganu. Ak chcete vyberať japonské znaky, prepnite na japončinu, napíšte slovo, napríklad `nihongo`, a potom dvakrát stlačte Space. Stlačením Enter výber potvrdíte. Ak máte aj viacero rozložení klávesnice, kliknutím pravým tlačidlom na indikátor medzi nimi prechádzate.

V časti _Setup > Typing > Keyboard Layouts_ vyberiete rozloženia, ako sú anglické a francúzske, z rovnakých možností, aké sa ponúkajú počas inštalácie. V časti _Setup > Typing > Input Methods_ vyberiete, ktoré nástroje na skladanie znakov sú aktívne. Oba výbery sa otvoria vnútri ponuky Omarchy s vašimi aktuálnymi voľbami začiarknutými. Voľbu prepnete kliknutím alebo stlačením Enter; každá zmena sa použije okamžite. Zrušením výberu metódy vstupu ju odstránite z cyklu bez toho, aby ste ju odinštalovali; klávesnica zostáva k dispozícii.

Rovnaké výbery otvoríte spustením `omarchy setup keyboard` alebo `omarchy setup input`. Ak chcete z príkazového riadka pridať jeden jazyk, použite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` alebo `cangjie5`. Quick, Boshiamy a Array sú v rovnakom balíku ako Cangjie a zobrazia sa vo výbere Input Methods. Vaše vlastné klávesy na prepínanie zostanú zachované. Pre alternatívne rozloženia alebo klávesy nástroja nainštalujte `fcitx5-configtool` pomocou `omarchy pkg add fcitx5-configtool` a spustite ho z terminálu. Výber vstupného jazyka nezmení jazyk prostredia pracovnej plochy. Výber japončiny, kórejčiny alebo čínštiny v časti _Setup > Language_ pridá jej metódu vstupu, ak ešte žiadnu nemáte.

Pomocou `Super + I` prechádzate metódami vstupu alebo rozloženiami klávesnice a pomocou `Super + Shift + I` idete opačným smerom, takže pri troch nakonfigurovaných môžete prechádzať medzi dvoma susedmi. Indikátor vstupu sa zobrazí v pravej časti panela len vtedy, keď je nakonfigurovaných viac ako jedna metóda vstupu alebo rozloženie. Táto väzba pracovnej plochy funguje spolu s vašimi existujúcimi klávesmi na prepínanie Fcitx; môžete ju prepísať v `~/.config/hypr/bindings.lua`. Vstupné nástroje a sekvencie compose používajú službu [Fcitx5](https://fcitx-im.org/), ktorá už beží v každej relácii.

### Používanie ALT ako SUPER

Na niektorých klávesniciach nie je pohodlné používať primárny metakláves (kláves Windows/cmd) ako SUPER. Namiesto toho ho môžete touto zmenou nastaviť na ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
