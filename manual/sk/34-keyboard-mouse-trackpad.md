# Klávesnica, myš, trackpad

Hyprland ti umožňuje konfigurovať všetky tvoje vstupy veľmi podrobne. Môžeš zmeniť opakovanie klávesnice tak, aby bolo nadzvukovo rýchle, alebo zariadiť, aby trackpad používal prirodzené posúvanie. Všetko to meníš v súbore `~/.config/hypr/input.lua`, ku ktorému sa dostaneš aj prostredníctvom _Nastavenie > Vstup_ v menu Omarchy (`Super + Space`). Čokoľvek tam nastavíš, nahradí predvolené nastavenia Omarchy.

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

Na wiki Hyprlandu pre vstupy môžeš [vidieť všetky možnosti vstupu](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock funguje ako bežný Caps Lock a `Shift + CapsLock` je kláves compose pre [rýchle emoji](07-hotkeys.md#quick-emojis) a [ďalšie doplňovania](07-hotkeys.md#quick-completions). Ak by si chcel mať kláves compose inde, nahraď v `kb_options` reťazec `omarchy:shift_caps_compose`. Napríklad, toto presunie kláves compose na pravý Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestá trackpadu

Môžeš tiež zapnúť [gestá touchpadu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), napríklad potiahnutie tromi prstami na zmenu pracovných plôch:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Na notebookoch Dell XPS s haptickým touchpadom môžeš tiež nastaviť silu kliknutia na nízku, strednú alebo vysokú v časti _Akcie > Hardvér > Haptika touchpadu_.

### Písanie v čínštine, japončine a iných jazykoch

Keď sa inštalátor opýta na tvoju klávesnicu, vyber japončinu, kórejčinu, čínštinu (zjednodušenú, Pinyin) alebo čínštinu (tradičnú, Zhuyin). Omarchy klávesnicu a zodpovedajúci vstupný engine nastaví automaticky, a to aj počas offline prvého spustenia. Japončina používa Mozc, kórejčina používa štandardný dvojznakový Hangul, zjednodušená čínština používa Pinyin a tradičná čínština používa štandardné rozloženie Zhuyin od Chewing. Japončina (klávesnica US) poskytuje Mozc s rozložením klávesnice US.

Písanie sa začína v režime latinky. Stlačením `Super + I` budeš prechádzať nakonfigurovanými metódami vstupu a stlačením `Super + Shift + I` sa budeš vracať späť. Ťuknutím na samotný `Shift` vystúpiš z metódy vstupu ako Pinyin do latinkových písmen a opätovným ťuknutím sa vrátiš späť, tak ako to funguje v Sogou, Microsoft Pinyin a macOS; `Shift` plus písmeno stále napíše veľké písmeno. Na japonských klávesniciach kláves 全角/半角 prepína vstup, 変換 ho zapne a 無変換 ho vypne. Na rozložení kórejskej klávesnice dedikované klávesy 한/영 a 한자 prepínajú Hangul a prevádzajú na Hanja. `Ctrl + Space` zostáva dostupné pre Tmux a Herdr; `Shift + CapsLock` zostáva klávesom compose.

Indikátor klávesnice sa objaví napravo od lišty, keď máš viacero rozložení klávesnice alebo metód vstupu. Klikni naň, aby si prepol vstupné jazyky; japončina zobrazuje あ pre hiraganu. Ak chceš vybrať japonské znaky, prepni na japončinu, napíš slovo ako `nihongo` a potom dvakrát stlač medzerník (Space). Svoju voľbu potvrdíš stlačením Enter. Ak máš aj viacero rozložení klávesnice, klikni pravým tlačidlom myši na indikátor, aby si nimi prechádzal.

Pomocou časti _Nastavenie > Písanie > Rozloženia klávesnice_ môžeš vybrať rozloženia, napríklad angličtinu a francúzštinu, z tých istých možností, ktoré sa ponúkajú počas inštalácie. Pomocou časti _Nastavenie > Písanie > Metódy vstupu_ môžeš vybrať, ktoré enginy skladania sú aktívne. Oba výbery sa otvárajú vnútri menu Omarchy s označením tvojich aktuálnych výberov. Možnosť prepneš kliknutím alebo stlačením Enter; každá zmena sa použije okamžite. Zrušenie výberu metódy vstupu ju odstráni z cyklu bez toho, aby ju odinštalovalo; klávesnica zostáva dostupná.

Spustením `omarchy setup keyboard` alebo `omarchy setup input` otvoríš tie isté výbery. Ak chceš pridať jeden jazyk z príkazového riadka, použi `omarchy setup input mozc`, `hangul`, `pinyin` alebo `chewing`. Tvoje vlastné klávesy na prepínanie sa zachovajú. Pre alternatívne rozloženia alebo klávesy enginu nainštaluj `fcitx5-configtool` pomocou `omarchy pkg add fcitx5-configtool` a spusti ho z terminálu. Výber vstupného jazyka nemení jazyk pracovnej plochy.

Na prechádzanie metódami vstupu alebo rozloženiami klávesnice používaj `Super + I` a na opačnú cestu `Super + Shift + I`, takže s tromi nakonfigurovanými sa môžeš pohybovať medzi dvomi susedmi. Indikátor vstupu sa objaví napravo od lišty, len keď je nakonfigurovaná viac než jedna metóda vstupu alebo rozloženie. Táto skratka na pracovnej ploche funguje popri tvojich existujúcich klávesoch na prepínanie Fcitx; môžeš ju prepísať v súbore `~/.config/hypr/bindings.lua`. Vstupné enginy a sekvencie compose používajú službu [Fcitx5](https://fcitx-im.org/), ktorá už beží v každej relácii.

### Použitie ALT ako SUPER

Na niektorých klávesniciach nie je pohodlné používať primárny meta kláves (kláves Windows/cmd) ako SUPER. Pomocou tejto zmeny to môžeš zmeniť na ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
