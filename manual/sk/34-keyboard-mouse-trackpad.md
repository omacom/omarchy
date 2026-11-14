# Klávesnica, myš, trackpad

Hyprland vám umožňuje podrobne nakonfigurovať všetky vaše vstupy. Môžete nastaviť opakovanie klávesnice na nadzvukovo rýchle alebo nastaviť trackpad na prirodzené posúvanie. Všetko zmeníte v `~/.config/hypr/input.lua`, kam sa dostanete aj cez _Setup > Input_ v ponuke Omarchy (`Super + Space`). Všetko, čo tam nastavíte, nahradí predvolené nastavenia Omarchy.

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

Všetky možnosti vstupu si môžete [pozrieť](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wiki Hyprlandu pre vstupy.

CapsLock funguje ako normálny Caps Lock a `Shift + CapsLock` je kláves compose pre [rýchle emoji](07-hotkeys.md#quick-emojis) a [ďalšie dokončovanie](07-hotkeys.md#quick-completions). Ak chcete mať kláves compose inde, nahraďte `omarchy:shift_caps_compose` v `kb_options`. Tento príklad napríklad presunie kláves compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkčné klávesy

Horný rad klávesnice notebooku predvolene odosiela multimediálne klávesy (hlasitosť, jas atď.) a podržaním `Fn` získate F1-F12; `Fn + Esc` to uzamkne naopak, kým ho znova nestlačíte. Väčšina klávesníc si tento zámok pamätá sama. Notebooky ASUS a klávesnice v štýle Apple to nechávajú na Linux, ktorý ich pri každom štarte zapne na multimediálnych klávesoch. Ak chcete, aby namiesto toho začínali na F1-F12, spustite `omarchy keyboard toprow fnkeys` (a `omarchy keyboard toprow mediakeys` na návrat späť); na niektorých notebookoch sa to prejaví až po reštarte. Macy s Apple Silicon si zachovávajú vlastné nastavenie.

### Gestá trackpadu

Potiahnutím po trackpade sa pohybujete po pracovnej ploche:

| Gesto | Akcia |
| --- | --- |
| Tri prsty doľava / doprava | Predchádzajúca / nasledujúca pracovná plocha vrátane prázdnych |
| Tri prsty nahor | Prepnúť konzolu AI |
| Tri prsty nadol | Otvoriť ponuku Omarchy |
| Štyri prsty doľava / doprava | Presunúť aktívne okno na predchádzajúcu / nasledujúcu pracovnú plochu |
| Štyri prsty nadol | Prepnúť režim celej obrazovky |

Ak chcete niektoré zmeniť, zrušte ho v `~/.config/hypr/input.lua` pred pridaním vlastného [gesta trackpadu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), pretože Hyprland neprijme dve gestá na rovnakých prstoch a v rovnakom smere:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Ak chcete vypnúť všetky gestá Omarchy, nastavte `omarchy_default_gestures = false` blízko začiatku `~/.config/hypr/hyprland.lua`, pred načítaním predvolených nastavení Omarchy.

Na notebookoch Dell XPS s haptickým touchpadom môžete tiež nastaviť silu kliknutia na nízku, strednú alebo vysokú v časti _Trigger > Hardware > Touchpad Haptics_.

### Písanie v čínštine, japončine a ďalších jazykoch

Pri otázke inštalátora na vašu klávesnicu vyberte japončinu, kórejčinu, čínštinu (zjednodušenú, Pinyin), Taiwan (Zhuyin) alebo Hong Kong (Cangjie). Omarchy nakonfiguruje klávesnicu a zodpovedajúci vstupný engine automaticky, vrátane offline nastavenia pri prvom spustení. Japončina používa Mozc, kórejčina používa štandardné dvojradové rozloženie Hangul, zjednodušená čínština používa Pinyin, Taiwan používa štandardné rozloženie Zhuyin systému Chewing a Hong Kong používa Cangjie s hongkonskými tvarmi znakov. Japončina (americká klávesnica) poskytuje Mozc s americkým rozložením klávesnice. Klávesy Hangul, Zhuyin a Cangjie zostávajú na svojich štandardných pozíciách, aj keď píšete latinské písmená pomocou Dvorak, Colemak alebo AZERTY. Ak ste Hangul alebo Chewing pridali už predtým, zrušte jeho výber a znova ho vyberte v časti _Setup > Keyboard > Input Methods_, aby sa jeho klávesy presunuli tam; engine, s ktorým už píšete, nechá Omarchy na pokoji.

Písanie začína v latinskom režime. Stlačením `Super + I` prechádzate nakonfigurovanými vstupnými metódami a stlačením `Super + Shift + I` prechádzate späť. Samostatným ťuknutím na `Shift` vystúpite zo vstupnej metódy, ako je Pinyin, do latinských písmen a ďalším ťuknutím sa vrátite späť, tak ako fungujú Sogou, Microsoft Pinyin a macOS; `Shift` plus písmeno stále píše veľké písmeno. Na japonských klávesniciach 全角/半角 prepína vstup, 変換 ho zapína a 無変換 ho vypína. Pri kórejčine 한/영 prepína Hangul a 한자 prevádza na Hanja, či už má klávesnica vyhradené klávesy, alebo pre ne odosiela Right Alt a Right Ctrl, ako to robí mnoho notebookov, takže Right Alt a Right Ctrl tam nie sú obyčajné modifikátory; diktovanie sa namiesto toho prepína pomocou Alt + Space. `Ctrl + Space` zostáva k dispozícii pre Tmux a Herdr; `Shift + CapsLock` zostáva klávesom compose.

Indikátor klávesnice sa zobrazí vpravo na paneli, keď máte viacero rozložení klávesnice alebo vstupných metód. Kliknutím naň prepínate vstupné jazyky; japončina zobrazuje あ pre hiraganu. Ak chcete vybrať japonské znaky, prepnite na japončinu, napíšte slovo, napríklad `nihongo`, a potom dvakrát stlačte Space. Stlačením Enter výber potvrdíte. Ak máte aj viacero rozložení klávesnice, kliknutím pravým tlačidlom na indikátor ich prechádzate.

Pomocou _Setup > Keyboard > Keyboard Inputs_ vyberte rozloženia, ako je angličtina a francúzština, z rovnakých možností, aké sa ponúkajú počas inštalácie. Pomocou _Setup > Keyboard > Input Methods_ vyberte, ktoré enginy na skladanie znakov sú aktívne. Oba výbery sa otvoria vnútri ponuky Omarchy s označenými aktuálnymi voľbami. Voľbu prepnete kliknutím alebo stlačením Enter; každá zmena sa použije okamžite. Zrušením výberu vstupnej metódy ju odstránite z cyklu bez jej odinštalovania; klávesnica zostáva k dispozícii.

Spustením `omarchy setup keyboard` alebo `omarchy setup input` otvoríte rovnaké výbery. Ak chcete z príkazového riadka pridať jeden jazyk, použite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` alebo `cangjie5`. Quick, Boshiamy a Array sú v rovnakom balíku ako Cangjie a zobrazia sa vo výbere Input Methods. Vaše vlastné klávesy na prepínanie zostanú zachované. Pre alternatívne rozloženia alebo klávesy enginu nainštalujte `fcitx5-configtool` pomocou `omarchy pkg add fcitx5-configtool` a spustite ho z terminálu. Výber vstupného jazyka nezmení jazyk pracovnej plochy. Výber japončiny, kórejčiny alebo čínštiny v časti _Setup > Language_ pridá jej vstupnú metódu, keď ešte žiadnu nemáte.

Pomocou `Super + I` prechádzajte vstupnými metódami alebo rozloženiami klávesnice a pomocou `Super + Shift + I` prechádzajte opačným smerom, takže pri troch nakonfigurovaných sa môžete pohybovať medzi dvoma susedmi. Indikátor vstupu sa zobrazí vpravo na paneli, iba keď je nakonfigurovaná viac ako jedna vstupná metóda alebo rozloženie. Táto skratka pracovnej plochy funguje popri vašich existujúcich klávesoch na prepínanie Fcitx; môžete ju prepísať v `~/.config/hypr/bindings.lua`. Vstupné enginy a sekvencie compose používajú službu [Fcitx5](https://fcitx-im.org/), ktorá už beží v každej relácii.

### Používanie ALT ako SUPER

Na niektorých klávesniciach nie je pohodlné používať primárny metakláves (kláves Windows/cmd) ako SUPER. Pomocou tejto zmeny to namiesto toho môžete zmeniť na ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
