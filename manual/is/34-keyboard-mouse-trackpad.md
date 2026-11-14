# Lyklaborð, mús, snertiflötur

Hyprland gerir þér kleift að stilla öll inntök þín mjög nákvæmlega. Þú getur gert endurtekningu lyklaborðsins ofsahraða eða látið snertiflötinn nota náttúrulega skrun. Þú breytir öllu þessu í `~/.config/hypr/input.lua`, sem þú getur líka opnað í gegnum _Setup > Input_ í Omarchy valmyndinni (`Super + Space`). Allt sem þú stillir þar kemur í stað sjálfgefna gilda Omarchy.

Hér er dæmi:

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

Þú getur [séð alla inntaksvalkostina](https://wiki.hypr.land/Configuring/Basics/Variables/#input) á Hyprland wiki fyrir inntök.

CapsLock virkar sem venjulegur Caps Lock og `Shift + CapsLock` er samsetningarlykillinn fyrir [fljótleg emoji](07-hotkeys.md#quick-emojis) og [aðrar viðbætur](07-hotkeys.md#quick-completions). Ef þú vilt frekar hafa samsetningarlykilinn annars staðar skaltu skipta út `omarchy:shift_caps_compose` í `kb_options`. Í þessu dæmi færist samsetningarlykillinn til dæmis yfir á Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Virknilyklar

Efsta röðin á fartölvulyklaborði sendir sjálfgefið margmiðlunarlyklana (hljóðstyrk, birtu og svo framvegis) og með því að halda inni `Fn` færðu F1-F12; `Fn + Esc` læsir þessu í hina áttina þar til þú ýtir aftur á það. Flest lyklaborð muna þá læsingu sjálf. Fartölvur frá ASUS og lyklaborð í Apple-stíl skilja þetta eftir Linux, sem ræsir þau með margmiðlunarlyklunum við hverja ræsingu. Til að láta þau byrja á F1-F12 í staðinn skaltu keyra `omarchy keyboard toprow fnkeys` (og `omarchy keyboard toprow mediakeys` til að fara til baka); á sumum fartölvum tekur þetta gildi eftir endurræsingu. Apple Silicon Mac vélar halda sinni eigin stillingu.

### Bendingar á snertifleti

Strjúktu á snertifletinum til að fara um skjáborðið:

| Bending | Aðgerð |
| --- | --- |
| Þrír fingur til vinstri / hægri | Fyrra / næsta vinnusvæði, þar á meðal auð |
| Þrír fingur upp | Víxla AI stjórnborðinu |
| Þrír fingur niður | Opna Omarchy valmyndina |
| Fjórir fingur til vinstri / hægri | Færa virka gluggann á fyrra / næsta vinnusvæði |
| Fjórir fingur niður | Víxla heilskjá |

Til að breyta einni skaltu afstilla hana í `~/.config/hypr/input.lua` áður en þú bætir þinni eigin [bendingu á snertifleti](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) við, því Hyprland tekur ekki við tveimur bendingum með sömu fingrum og í sömu átt:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Til að slökkva á öllum bendingum Omarchy skaltu stilla `omarchy_default_gestures = false` ofarlega í `~/.config/hypr/hyprland.lua`, áður en sjálfgefin gildi Omarchy hlaðast inn.

Á Dell XPS fartölvum með haptískum snertifleti geturðu líka stillt smellstyrkinn á lágan, miðlungs eða háan undir _Trigger > Hardware > Touchpad Haptics_.

### Ritun á kínversku, japönsku og öðrum tungumálum

Veldu japönsku, kóresku, kínversku (einfaldaða, Pinyin), Taívan (Zhuyin) eða Hong Kong (Cangjie) þegar uppsetningarforritið spyr um lyklaborðið þitt. Omarchy stillir lyklaborðið og samsvarandi inntaksvél sjálfkrafa, þar á meðal við fyrstu ræsingu án netsambands. Japanska notar Mozc, kóreska notar staðlað tveggja-setta Hangul, einfölduð kínverska notar Pinyin, Taívan notar staðlaða Zhuyin uppröðun Chewing og Hong Kong notar Cangjie með táknformum frá Hong Kong. Japanska (US lyklaborð) býður upp á Mozc með US lyklaborðsuppröðun. Lyklar fyrir Hangul, Zhuyin og Cangjie haldast á stöðluðum stöðum sínum jafnvel þegar þú skrifar latneska stafi með Dvorak, Colemak eða AZERTY. Ef þú bættir Hangul eða Chewing við áður en þetta kom til skaltu afvelja það og velja aftur undir _Setup > Keyboard > Input Methods_ til að færa lyklana þess þangað; Omarchy lætur vél sem þú skrifar nú þegar með í friði.

Ritun byrjar í latneskum ham. Ýttu á `Super + I` til að fara í gegnum stilltar inntaksaðferðir og `Super + Shift + I` til að fara til baka. Pikkaðu á `Shift` eitt og sér til að stíga út úr inntaksaðferð á borð við Pinyin yfir í latneska stafi og pikkaðu aftur til að fara til baka, eins og Sogou, Microsoft Pinyin og macOS virka; `Shift` ásamt bókstaf skrifar samt hástaf. Á japönskum lyklaborðum víxlar 全角/半角 inntaki, 変換 kveikir á því og 無変換 slekkur á því. Á kóresku skiptir 한/영 um Hangul og 한자 breytir í Hanja, hvort sem lyklaborðið þitt hefur sérstaka lykla eða sendir Right Alt og Right Ctrl fyrir þá, eins og margar fartölvur gera, svo Right Alt og Right Ctrl eru ekki venjulegir breytilyklar þar; talgreining víxlast í staðinn með Alt + Space. `Ctrl + Space` er áfram tiltækt fyrir Tmux og Herdr; `Shift + CapsLock` er áfram samsetningarlykillinn.

Lyklaborðsvísirinn birtist hægra megin á stikunni þegar þú ert með mörg lyklaborðsuppröðun eða inntaksaðferðir. Smelltu á hann til að skipta um inntakstungumál; japanska sýnir あ fyrir hiragana. Til að velja japönsk tákn skaltu skipta yfir í japönsku, skrifa orð á borð við `nihongo` og ýta svo tvisvar á Space. Ýttu á Enter til að staðfesta valið. Ef þú ert líka með mörg lyklaborðsuppröðun skaltu hægrismella á vísinn til að fara í gegnum þau.

Notaðu _Setup > Keyboard > Keyboard Inputs_ til að velja uppröðun á borð við ensku og frönsku, úr sömu valkostum og boðið er upp á við uppsetningu. Notaðu _Setup > Keyboard > Input Methods_ til að velja hvaða samsetningarvélar eru virkar. Báðir veljararnir opnast inni í Omarchy valmyndinni með núverandi val þitt merkt. Smelltu eða ýttu á Enter til að víxla valkosti; hver breyting tekur gildi strax. Að afvelja inntaksaðferð fjarlægir hana úr hringnum án þess að fjarlægja hana; lyklaborðið er áfram tiltækt.

Keyrðu `omarchy setup keyboard` eða `omarchy setup input` til að opna sömu veljara. Til að bæta við einu tungumáli af skipanalínunni skaltu nota `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` eða `cangjie5`. Quick, Boshiamy og Array koma í sama pakka og Cangjie og birtast í Input Methods veljaranum. Sérsniðnu skiptilyklarnir þínir haldast. Fyrir aðrar uppröðun véla eða lykla skaltu setja upp `fcitx5-configtool` með `omarchy pkg add fcitx5-configtool` og ræsa það úr skjáhermi. Að velja inntakstungumál breytir ekki tungumáli skjáborðsins. Að velja japönsku, kóresku eða kínversku undir _Setup > Language_ bætir við inntaksaðferð þess þegar þú ert ekki með neina enn.

Notaðu `Super + I` til að fara í gegnum inntaksaðferðir eða lyklaborðsuppröðun og `Super + Shift + I` til að fara til baka í hina áttina, svo með þremur stilltum geturðu farið á milli tveggja nágranna. Inntaksvísirinn birtist hægra megin á stikunni aðeins þegar fleiri en ein inntaksaðferð eða uppröðun er stillt. Þessi skjáborðsbinding virkar samhliða núverandi Fcitx skiptilyklum þínum; þú getur hnekkt henni í `~/.config/hypr/bindings.lua`. Inntaksvélar og samsetningarrunurnar nota [Fcitx5](https://fcitx-im.org/) þjónustuna sem er nú þegar í gangi í hverri setu.

### Notaðu ALT sem SUPER

Á sumum lyklaborðum er ekki þægilegt að nota aðal meta-lykilinn (Windows/cmd lykilinn) sem SUPER. Þú getur breytt þessu þannig að ALT sé notað í staðinn með þessari breytingu:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
