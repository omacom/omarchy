# Klávesnica, myš, trackpad

Hyprland vám umožňuje podrobne nakonfigurovať všetky vaše vstupy. Môžete nastaviť opakovanie klávesov na nadzvukovo rýchle alebo nastaviť trackpad tak, aby používal prirodzené rolovanie. Všetko to zmeníte v `~/.config/hypr/input.lua`, kam sa dostanete aj cez _Setup > Input_ v menu Omarchy (`Super + Space`). Čokoľvek tam nastavíte, nahradí predvolené nastavenia Omarchy.

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

Na wiki Hyprland si môžete [zobraziť všetky možnosti vstupov](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock funguje ako bežný Caps Lock a `Shift + CapsLock` je kláves compose pre [rýchle emodži](07-hotkeys.md#quick-emojis) a [ďalšie dopĺňania](07-hotkeys.md#quick-completions). Ak chcete mať radšej kláves compose inde, nahraďte `omarchy:shift_caps_compose` v `kb_options`. Tento príklad napríklad presunie kláves compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkčné klávesy

Horný rad klávesnice notebooku predvolene odosiela multimediálne klávesy (hlasitosť, jas a tak ďalej) a podržaním `Fn` získate F1-F12; `Fn + Esc` to uzamkne opačným smerom, kým ho znova nestlačíte. Väčšina klávesníc si tento zámok pamätá sama. Notebooky ASUS a klávesnice v štýle Apple to nechávajú na Linux, ktorý ich pri každom spustení štartuje na multimediálnych klávesoch. Ak chcete, aby namiesto toho štartovali na F1-F12, spustite `omarchy device keyboard toprow fnkeys` (a `omarchy device keyboard toprow mediakeys` pre návrat späť); na niektorých notebookoch sa to prejaví až po reštarte. Počítače Apple Silicon Mac si ponechávajú svoje vlastné nastavenie.

### Gestá trackpadu

Potiahnutím po trackpade sa môžete pohybovať po pracovnej ploche:

| Gesto | Akcia |
| --- | --- |
| Tri prsty doľava / doprava | Predchádzajúca / nasledujúca pracovná plocha vrátane prázdnych |
| Tri prsty nahor | Prepnutie AI konzoly |
| Tri prsty nadol | Otvorenie menu Omarchy |
| Štyri prsty doľava / doprava | Presunutie aktívneho okna na predchádzajúcu / nasledujúcu pracovnú plochu |
| Štyri prsty nadol | Prepnutie celej obrazovky |

Ak chcete jedno zmeniť, zrušte ho v `~/.config/hypr/input.lua` pred pridaním vlastného [gesta touchpadu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), pretože Hyprland neprijme dve gestá na rovnakých prstoch a v rovnakom smere:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Ak chcete všetky gestá Omarchy vypnúť, nastavte `omarchy_default_gestures = false` blízko začiatku `~/.config/hypr/hyprland.lua`, skôr než sa načítajú predvolené nastavenia Omarchy.

Na notebookoch Dell XPS s haptickým touchpadom môžete tiež nastaviť silu kliknutia na nízku, strednú alebo vysokú v časti _Trigger > Hardware > Touchpad Haptics_.

### Písanie v čínštine, japončine a iných jazykoch

Keď sa vás inštalátor spýta na klávesnicu, vyberte japončinu, kórejčinu, čínštinu (zjednodušenú, Pinyin), Taiwan (Zhuyin) alebo Hong Kong (Cangjie). Omarchy automaticky nakonfiguruje klávesnicu a zodpovedajúci vstupný engine, a to aj počas offline nastavenia pri prvom spustení. Japončina používa Mozc, kórejčina používa štandardný dvojradový Hangul, zjednodušená čínština používa Pinyin, Taiwan používa štandardné usporiadanie Zhuyin od Chewing a Hong Kong používa Cangjie s hongkonskými formami znakov. Japončina (US klávesnica) poskytuje Mozc s rozložením klávesnice US. Klávesy Hangul, Zhuyin a Cangjie zostávajú na svojich štandardných pozíciách, aj keď píšete latinské písmená s Dvorak, Colemak alebo AZERTY. Ak ste predtým pridali Hangul alebo Chewing, zrušte jeho výber a znova ho vyberte v časti _Setup > Keyboard > Input Methods_, aby sa jeho klávesy presunuli tam; Omarchy nechá engine, s ktorým už píšete, na pokoji.

Písanie začína v režime Latin. Stlačením `Super + I` môžete cyklicky prepínať medzi nakonfigurovanými vstupnými metódami a stlačením `Super + Shift + I` cyklicky prepínať späť. Samostatným ťuknutím na `Shift` vystúpite zo vstupnej metódy, ako je Pinyin, do latinských písmen a opätovným ťuknutím sa vrátite späť, tak ako fungujú Sogou, Microsoft Pinyin a macOS; `Shift` plus písmeno stále píše veľké písmeno. Na japonských klávesniciach 全角/半角 prepína vstup, 変換 ho zapína a 無変換 ho vypína. Pri kórejčine 한/영 prepína Hangul a 한자 prevádza na Hanja, či už má vaša klávesnica vyhradené klávesy, alebo pre ne odosiela Right Alt a Right Ctrl, ako to robí veľa notebookov, takže Right Alt a Right Ctrl tam nie sú obyčajné modifikátory; diktovanie sa namiesto toho prepína pomocou Alt + Space. `Ctrl + Space` zostáva k dispozícii pre Tmux a Herdr; `Shift + CapsLock` zostáva klávesom compose.

Indikátor klávesnice sa zobrazí vpravo na paneli, keď máte viacero rozložení klávesnice alebo vstupných metód. Kliknutím naň prepnete vstupné jazyky; japončina zobrazuje あ pre hiraganu. Pre výber japonských znakov prepnite na japončinu, napíšte slovo, ako napríklad `nihongo`, a potom dvakrát stlačte Space. Stlačením Enter potvrdíte svoj výber. Ak máte aj viacero rozložení klávesnice, kliknutím pravým tlačidlom na indikátor ich budete cyklicky prepínať.

V časti _Setup > Keyboard > Keyboard Inputs_ vyberte rozloženia, ako sú English a French, z rovnakých možností, aké sa ponúkajú počas inštalácie. V časti _Setup > Keyboard > Input Methods_ vyberte, ktoré enginy na skladanie znakov sú aktívne. Oba výbery sa otvoria v menu Omarchy s označenými vašimi aktuálnymi výbermi. Kliknutím alebo stlačením Enter prepnete voľbu; každá zmena sa použije okamžite. Zrušením výberu vstupnej metódy ju odstránite z cyklu bez toho, aby ste ju odinštalovali; klávesnica zostane k dispozícii.

Spustením `omarchy setup keyboard` alebo `omarchy setup input` otvoríte rovnaké výbery. Ak chcete z príkazového riadka pridať jeden jazyk, použite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` alebo `cangjie5`. Quick, Boshiamy a Array sú v rovnakom balíku ako Cangjie a zobrazia sa vo výbere Input Methods. Vaše vlastné klávesy na prepínanie zostanú zachované. Pre alternatívne rozloženia alebo klávesy enginov nainštalujte `fcitx5-configtool` pomocou `omarchy pkg add fcitx5-configtool` a spustite ho z terminálu. Výber vstupného jazyka nezmení jazyk pracovnej plochy. Výber japončiny, kórejčiny alebo čínštiny v časti _Setup > Region > Language_ pridá jej vstupnú metódu, keď ešte žiadnu nemáte.

Pomocou `Super + I` cyklicky prepínajte medzi vstupnými metódami alebo rozloženiami klávesnice a pomocou `Super + Shift + I` prechádzajte opačným smerom, takže s tromi nakonfigurovanými sa môžete pohybovať medzi dvoma susedmi. Indikátor vstupu sa zobrazí vpravo na paneli iba vtedy, keď je nakonfigurovaná viac ako jedna vstupná metóda alebo rozloženie. Táto skratka pracovnej plochy funguje popri vašich existujúcich klávesoch na prepínanie Fcitx; môžete ju prepísať v `~/.config/hypr/bindings.lua`. Vstupné enginy a sekvencie compose používajú službu [Fcitx5](https://fcitx-im.org/), ktorá už beží v každej relácii.

### Použitie ALT ako SUPER

Na niektorých klávesniciach nie je pohodlné používať primárny kláves meta (kláves Windows/cmd) ako SUPER. Pomocou tejto zmeny to môžete zmeniť tak, aby ním namiesto toho bol ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
