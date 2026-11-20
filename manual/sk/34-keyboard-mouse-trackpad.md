# Klávesnica, myš, trackpad

Hyprland vám umožňuje nakonfigurovať všetky vstupy do veľkých detailov. Opakovanie klávesnice si môžete nastaviť na nadzvukovo rýchle alebo trackpadu zapnúť prirodzené posúvanie. Všetko to meníte v `~/.config/hypr/input.lua`, kam sa dostanete aj cez _Nastavenie > Vstup_ v ponuke Omarchy (`Super + Space`). Čokoľvek tam nastavíte, nahradí predvolené nastavenia Omarchy.

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

Všetky možnosti vstupu [si môžete pozrieť](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wiki Hyprlandu pre vstupy.

CapsLock funguje ako bežný Caps Lock a `Shift + CapsLock` je kláves compose pre [rýchle emoji](07-hotkeys.md#quick-emojis) a [ďalšie dokončovania](07-hotkeys.md#quick-completions). Ak chcete mať kláves compose radšej inde, nahraďte `omarchy:shift_caps_compose` v `kb_options`. Tento príklad napríklad presunie kláves compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkčné klávesy

Horný rad klávesnice notebooku predvolene odosiela multimediálne klávesy (hlasitosť, jas a podobne) a podržaním `Fn` získate F1-F12; `Fn + Esc` to uzamkne naopak, kým to znova nestlačíte. Väčšina klávesníc si tento zámok pamätá sama. Notebooky ASUS a klávesnice v štýle Apple to nechávajú na Linux, ktorý ich pri každom štarte spustí na multimediálnych klávesoch. Ak majú namiesto toho štartovať na F1-F12, spustite `omarchy device keyboard toprow fnkeys` (a `omarchy device keyboard toprow mediakeys` na návrat späť); na niektorých notebookoch sa to prejaví až po reštarte. Počítače Mac s Apple Silicon si zachovávajú vlastné nastavenie.

### Gestá trackpadu

Po pracovnej ploche sa pohybujete potiahnutím po trackpade:

| Gesto | Akcia |
| --- | --- |
| Tri prsty doľava / doprava | Predchádzajúca / nasledujúca pracovná plocha vrátane prázdnych |
| Tri prsty nahor | Prepnúť konzolu AI |
| Tri prsty nadol | Otvoriť ponuku Omarchy |
| Štyri prsty doľava / doprava | Presunúť aktívne okno na predchádzajúcu / nasledujúcu pracovnú plochu |
| Štyri prsty nadol | Prepnúť režim celej obrazovky |

Ak chcete niektoré zmeniť, najprv ho zrušte v `~/.config/hypr/input.lua` a až potom pridajte vlastné [gesto touchpadu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), pretože Hyprland neprijme dve gestá na rovnakých prstoch a v rovnakom smere:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Ak chcete všetky gestá Omarchy vypnúť, nastavte `omarchy_default_gestures = false` blízko začiatku súboru `~/.config/hypr/hyprland.lua`, ešte pred načítaním predvolených nastavení Omarchy.

Na notebookoch Dell XPS s haptickým touchpadom môžete tiež nastaviť silu kliknutia na nízku, strednú alebo vysokú v časti _Spúšťač > Hardvér > Haptika touchpadu_.

### Písanie v čínštine, japončine a ďalších jazykoch

Keď vás inštalátor požiada o výber klávesnice, vyberte japončinu, kórejčinu, čínštinu (zjednodušenú, Pinyin), Taiwan (Zhuyin) alebo Hongkong (Cangjie). Omarchy automaticky nakonfiguruje klávesnicu aj zodpovedajúci vstupný nástroj, a to aj počas offline nastavenia pri prvom spustení. Japončina používa Mozc, kórejčina štandardný dvojradový Hangul, zjednodušená čínština Pinyin, Taiwan štandardné rozloženie Zhuyin od Chewing a Hongkong Cangjie s hongkonskými tvarmi znakov. Japončina (americká klávesnica) poskytuje Mozc s americkým rozložením klávesnice. Klávesy Hangul, Zhuyin a Cangjie zostávajú na svojich štandardných pozíciách, aj keď píšete latinkou v rozložení Dvorak, Colemak alebo AZERTY. Ak ste Hangul alebo Chewing pridali už skôr, zrušte ich výber a znova ich vyberte v časti _Nastavenie > Klávesnica > Metódy vstupu_, aby sa ich klávesy presunuli tam; nástroj, s ktorým už píšete, nechá Omarchy na pokoji.

Písanie sa začína v režime latinky. Stlačením `Super + I` prechádzate nakonfigurovanými metódami vstupu a stlačením `Super + Shift + I` sa vraciate späť. Samostatným ťuknutím na `Shift` vystúpite z metódy vstupu, ako je Pinyin, do latinky a ďalším ťuknutím sa vrátite späť, tak ako fungujú Sogou, Microsoft Pinyin a macOS; `Shift` plus písmeno stále píše veľké písmeno. Na japonských klávesniciach 全角/半角 prepína vstup, 変換 ho zapína a 無変換 ho vypína. Pri kórejčine 한/영 prepína Hangul a 한자 prevádza na Hanja, či už má vaša klávesnica vyhradené klávesy, alebo pre ne odosiela Right Alt a Right Ctrl, ako to robí mnoho notebookov, takže Right Alt a Right Ctrl tam nie sú obyčajné modifikátory; diktovanie sa namiesto toho prepína pomocou Alt + Space. `Ctrl + Space` zostáva k dispozícii pre Tmux a Herdr; `Shift + CapsLock` zostáva klávesom compose.

Indikátor klávesnice sa zobrazí vpravo na paneli, keď máte viac rozložení klávesnice alebo metód vstupu. Kliknutím naň prepínate jazyky vstupu; japončina zobrazuje あ pre hiraganu. Ak chcete vybrať japonské znaky, prepnite na japončinu, napíšte slovo, napríklad `nihongo`, a potom dvakrát stlačte Space. Stlačením Enter výber potvrdíte. Ak máte aj viac rozložení klávesnice, kliknutím pravým tlačidlom na indikátor medzi nimi prechádzate.

V časti _Nastavenie > Klávesnica > Vstupy klávesnice_ vyberáte rozloženia, ako je angličtina a francúzština, z rovnakých možností, aké sa ponúkajú počas inštalácie. V časti _Nastavenie > Klávesnica > Metódy vstupu_ vyberáte, ktoré nástroje na skladanie znakov sú aktívne. Oba výbery sa otvárajú vnútri ponuky Omarchy s vašimi aktuálnymi voľbami začiarknutými. Voľbu prepnete kliknutím alebo stlačením Enter; každá zmena sa prejaví okamžite. Zrušením výberu metódy vstupu ju odstránite z cyklu bez toho, aby ste ju odinštalovali; klávesnica zostáva k dispozícii.

Spustením `omarchy setup keyboard` alebo `omarchy setup input` otvoríte rovnaké výbery. Ak chcete z príkazového riadka pridať jeden jazyk, použite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` alebo `cangjie5`. Quick, Boshiamy a Array sa dodávajú v rovnakom balíku ako Cangjie a zobrazujú sa vo výbere Metódy vstupu. Vaše vlastné klávesy na prepínanie sa zachovajú. Pre alternatívne rozloženia alebo klávesy nástroja nainštalujte `fcitx5-configtool` pomocou `omarchy pkg add fcitx5-configtool` a spustite ho z terminálu. Výber jazyka vstupu nemení jazyk pracovnej plochy. Výberom japončiny, kórejčiny alebo čínštiny v časti _Nastavenie > Jazyk_ pridáte príslušnú metódu vstupu, ak ešte žiadnu nemáte.

Pomocou `Super + I` prechádzate metódami vstupu alebo rozloženiami klávesnice a pomocou `Super + Shift + I` idete opačným smerom, takže pri troch nakonfigurovaných sa môžete pohybovať medzi dvoma susedmi. Indikátor vstupu sa zobrazí vpravo na paneli len vtedy, keď je nakonfigurovaná viac ako jedna metóda vstupu alebo rozloženie. Táto skratka pracovnej plochy funguje popri vašich existujúcich klávesoch na prepínanie Fcitx; môžete ju prepísať v súbore `~/.config/hypr/bindings.lua`. Nástroje vstupu a sekvencie compose používajú službu [Fcitx5](https://fcitx-im.org/), ktorá už beží v každej relácii.

### Používanie ALT ako SUPER

Na niektorých klávesniciach nie je pohodlné používať primárny metakláves (kláves Windows/cmd) ako SUPER. Namiesto toho to môžete touto zmenou prepnúť na ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
