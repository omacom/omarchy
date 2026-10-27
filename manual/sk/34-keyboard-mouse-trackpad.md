# Klávesnica, myš, trackpad

Hyprland vám umožňuje podrobne nakonfigurovať všetky vaše vstupy. Opakovanie klávesnice môžete nastaviť na nadzvukovo rýchle alebo môžete na trackpade nastaviť prirodzené posúvanie. Všetko zmeníte v `~/.config/hypr/input.lua`, kam sa dostanete aj cez _Nastavenie > Vstup_ v ponuke Omarchy (`Super + Space`). Čokoľvek tam nastavíte, nahradí predvolené nastavenia Omarchy.

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

Na wiki Hyprlandu venovanej vstupom si môžete [pozrieť všetky možnosti vstupu](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock funguje ako bežný Caps Lock a `Shift + CapsLock` je kláves compose pre [rýchle emoji](07-hotkeys.md#quick-emojis) a [ďalšie dopĺňania](07-hotkeys.md#quick-completions). Ak by ste radšej mali kláves compose inde, nahraďte `omarchy:shift_caps_compose` v `kb_options`. Napríklad toto presunie kláves compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestá trackpadu

Môžete zapnúť aj [gestá touchpadu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), napríklad potiahnutie tromi prstami na zmenu pracovných plôch:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Na notebookoch Dell XPS s haptickým touchpadom môžete tiež nastaviť silu kliknutia na nízku, strednú alebo vysokú v časti _Trigger > Hardware > Touchpad Haptics_.

### Písanie v čínštine, japončine a ďalších jazykoch

Vyberte japončinu, kórejčinu, čínštinu (zjednodušenú, Pinyin), Taiwan (Zhuyin) alebo Hongkong (Cangjie), keď sa vás inštalátor opýta na vašu klávesnicu. Omarchy nakonfiguruje klávesnicu a zodpovedajúci vstupný nástroj automaticky, vrátane offline nastavenia pri prvom spustení. Japončina používa Mozc, kórejčina používa štandardné dvojradové rozloženie Hangul, zjednodušená čínština používa Pinyin, Taiwan používa štandardné rozloženie Zhuyin nástroja Chewing a Hongkong používa Cangjie s hongkonskými tvarmi znakov. Japončina (americká klávesnica) poskytuje Mozc s americkým rozložením klávesnice. Klávesy Hangul, Zhuyin a Cangjie zostávajú na svojich štandardných pozíciách, aj keď píšete latinské písmená pomocou Dvorak, Colemak alebo AZERTY. Ak ste predtým pridali Hangul alebo Chewing, zrušte jeho výber a znova ho vyberte v časti _Nastavenie > Písanie > Metódy vstupu_, aby sa jeho klávesy presunuli tam; nástroj, ktorým už píšete, nechá Omarchy na pokoji.

Písanie sa začína v latinskom režime. Stlačením `Super + I` prechádzate medzi nakonfigurovanými metódami vstupu a stlačením `Super + Shift + I` prechádzate späť. Samostatným ťuknutím na `Shift` vystúpite z metódy vstupu, ako je Pinyin, do latinských písmen a ďalším ťuknutím sa vrátite späť, tak ako fungujú Sogou, Microsoft Pinyin a macOS; `Shift` spolu s písmenom stále napíše veľké písmeno. Na japonských klávesniciach 全角/半角 prepína vstup, 変換 ho zapína a 無変換 ho vypína. Pri kórejčine 한/영 prepína Hangul a 한자 prevádza na Hanja, či už má vaša klávesnica vyhradené klávesy, alebo pre ne odosiela Right Alt a Right Ctrl, ako to robí mnoho notebookov, takže Right Alt a Right Ctrl tam nie sú obyčajné modifikátory; funkcia push-to-talk pri diktovaní zostáva na F9. `Ctrl + Space` zostáva k dispozícii pre Tmux a Herdr; `Shift + CapsLock` zostáva klávesom compose.

Indikátor klávesnice sa zobrazí vpravo na lište, keď máte viacero rozložení klávesnice alebo metód vstupu. Kliknutím naň prepínate vstupné jazyky; japončina zobrazuje あ pre hiraganu. Pre výber japonských znakov prepnite na japončinu, napíšte slovo, napríklad `nihongo`, a potom dvakrát stlačte Space. Stlačením Enter výber potvrdíte. Ak máte aj viacero rozložení klávesnice, kliknutím pravým tlačidlom na indikátor medzi nimi prechádzate.

Pomocou _Nastavenie > Písanie > Rozloženia klávesnice_ vyberiete rozloženia, ako napríklad anglické a francúzske, z rovnakých možností, ktoré sa ponúkajú počas inštalácie. Pomocou _Nastavenie > Písanie > Metódy vstupu_ vyberiete, ktoré nástroje na skladanie znakov sú aktívne. Obe ponuky výberu sa otvoria vnútri ponuky Omarchy s označenými vašimi aktuálnymi výbermi. Kliknutím alebo stlačením Enter možnosť prepnete; každá zmena sa použije okamžite. Zrušením výberu metódy vstupu ju odstránite z cyklu bez jej odinštalovania; klávesnica zostáva k dispozícii.

Spustením `omarchy setup keyboard` alebo `omarchy setup input` otvoríte rovnaké ponuky výberu. Na pridanie jedného jazyka z príkazového riadka použite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` alebo `cangjie5`. Quick, Boshiamy a Array sú v rovnakom balíku ako Cangjie a zobrazia sa vo výbere Metódy vstupu. Vaše vlastné klávesy na prepínanie zostanú zachované. Pre alternatívne rozloženia alebo klávesy nástroja nainštalujte `fcitx5-configtool` pomocou `omarchy pkg add fcitx5-configtool` a spustite ho z terminálu. Výber vstupného jazyka nezmení jazyk pracovného prostredia. Výber japončiny, kórejčiny alebo čínštiny v časti _Nastavenie > Jazyk_ pridá jej metódu vstupu, keď ešte žiadnu nemáte.

Použite `Super + I` na prechádzanie medzi metódami vstupu alebo rozloženiami klávesnice a `Super + Shift + I` na prechádzanie opačným smerom, takže s tromi nakonfigurovanými možnosťami sa môžete pohybovať medzi dvoma susednými. Indikátor vstupu sa zobrazí vpravo na lište iba vtedy, keď je nakonfigurovaná viac ako jedna metóda vstupu alebo jedno rozloženie. Táto skratka pracovného prostredia funguje spolu s vašimi existujúcimi klávesmi na prepínanie Fcitx; môžete ju prepísať v `~/.config/hypr/bindings.lua`. Vstupné nástroje a sekvencie compose používajú službu [Fcitx5](https://fcitx-im.org/), ktorá už beží v každej relácii.

### Používanie ALT ako SUPER

Na niektorých klávesniciach nie je pohodlné používať primárny meta kláves (kláves Windows/cmd) ako SUPER. Pomocou tejto zmeny ho namiesto toho môžete zmeniť na ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
