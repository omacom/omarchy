# Lyklaborð, mús, snertiflötur

Hyprland gerir þér kleift að stilla öll inntök þín í miklum smáatriðum. Þú getur gert endurtekningu lyklaborðsins ógnarhraða eða látið snertiflötinn nota náttúrulega skrun. Þú breytir öllu þessu í `~/.config/hypr/input.lua`, sem þú getur líka opnað í gegnum _Setup > Input_ í Omarchy-valmyndinni (`Super + Space`). Allt sem þú stillir þar tekur yfir sjálfgefin gildi Omarchy.

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

Þú getur [séð alla inntaksmöguleikana](https://wiki.hypr.land/Configuring/Basics/Variables/#input) á Hyprland-wikinu fyrir inntök.

CapsLock virkar sem venjulegur Caps Lock og `Shift + CapsLock` er samsetningarlykillinn fyrir [flýtibroskalla](07-hotkeys.md#quick-emojis) og [aðrar útfyllingar](07-hotkeys.md#quick-completions). Ef þú vilt frekar hafa samsetningarlykilinn annars staðar skaltu skipta út `omarchy:shift_caps_compose` í `kb_options`. Þetta færir til dæmis samsetningarlykilinn yfir á Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Aðgerðarlyklar

Efsta röð fartölvulyklaborðs sendir margmiðlunarlyklana (hljóðstyrk, birtu og svo framvegis) sjálfgefið og með því að halda inni `Fn` færðu F1-F12; `Fn + Esc` læsir því öfugt þar til þú ýtir aftur á það. Flest lyklaborð muna þá læsingu sjálf. ASUS-fartölvur og lyklaborð í Apple-stíl láta Linux sjá um þetta, sem ræsir þau á margmiðlunarlyklunum við hverja ræsingu. Til að láta þau ræsast á F1-F12 í staðinn skaltu keyra `omarchy device keyboard toprow fnkeys` (og `omarchy device keyboard toprow mediakeys` til að fara til baka); á sumum fartölvum tekur það gildi eftir endurræsingu. Apple Silicon Mac-tölvur halda sinni eigin stillingu.

### Bendingar á snertifleti

Strjúktu á snertifletinum til að fara um skjáborðið:

| Bending | Aðgerð |
| --- | --- |
| Þrír fingur til vinstri / hægri | Fyrra / næsta vinnusvæði, líka þau sem eru tóm |
| Þrír fingur upp | Opna/loka AI-stjórnborðinu |
| Þrír fingur niður | Opna Omarchy-valmyndina |
| Fjórir fingur til vinstri / hægri | Færa virka gluggann á fyrra / næsta vinnusvæði |
| Fjórir fingur niður | Kveikja/slökkva á fullum skjá |

Til að breyta einni skaltu afstilla hana í `~/.config/hypr/input.lua` áður en þú bætir við þinni eigin [snertiflatarbendingu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), þar sem Hyprland tekur ekki við tveimur bendingum með sömu fingrum og í sömu átt:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Til að slökkva á öllum bendingum Omarchy skaltu setja `omarchy_default_gestures = false` nálægt efsta hluta `~/.config/hypr/hyprland.lua`, áður en sjálfgefin gildi Omarchy hlaðast inn.

Á Dell XPS-fartölvum með haptískum snertifleti geturðu líka stillt smellstyrkinn á low, mid eða high undir _Trigger > Hardware > Touchpad Haptics_.

### Að skrifa á kínversku, japönsku og öðrum tungumálum

Veldu japönsku, kóresku, kínversku (Simplified, Pinyin), Taívan (Zhuyin) eða Hong Kong (Cangjie) þegar uppsetningarforritið spyr um lyklaborðið þitt. Omarchy stillir lyklaborðið og samsvarandi inntaksvél sjálfkrafa, líka við fyrstu ræsingu án netsambands. Japanska notar Mozc, kóreska notar staðlað tvískipt Hangul, einfölduð kínverska notar Pinyin, Taívan notar staðlaða Zhuyin-uppröðun Chewing og Hong Kong notar Cangjie með táknformum frá Hong Kong. Japanese (US keyboard) veitir Mozc með bandarískri lyklaborðsuppröðun. Lyklar fyrir Hangul, Zhuyin og Cangjie haldast í stöðluðum stöðum sínum jafnvel þegar þú skrifar latneska stafi með Dvorak, Colemak eða AZERTY. Ef þú bættir Hangul eða Chewing við áður en þetta kom til skaltu afvelja það og velja það aftur undir _Setup > Keyboard > Input Methods_ til að færa lyklana þess þangað; Omarchy lætur vél sem þú skrifar nú þegar með vera í friði.

Skrifun hefst í latneskum ham. Ýttu á `Super + I` til að skipta á milli stilltra inntaksaðferða og `Super + Shift + I` til að fara til baka. Ýttu á `Shift` eitt og sér til að stíga út úr inntaksaðferð eins og Pinyin yfir í latneska stafi og ýttu aftur á það til að fara til baka, eins og Sogou, Microsoft Pinyin og macOS virka; `Shift` ásamt bókstaf skrifar enn hástaf. Á japönskum lyklaborðum skiptir 全角/半角 um inntak, 変換 kveikir á því og 無変換 slekkur á því. Með kóresku skiptir 한/영 um Hangul og 한자 breytir í Hanja, hvort sem lyklaborðið þitt er með sérstaka lykla eða sendir Right Alt og Right Ctrl fyrir þá, eins og margar fartölvur gera, þannig að Right Alt og Right Ctrl eru ekki venjulegir breytilyklar þar; í staðinn skiptir `Alt + Space` um talinnslátt. `Ctrl + Space` er áfram í boði fyrir Tmux og Herdr; `Shift + CapsLock` er áfram samsetningarlykillinn.

Lyklaborðsvísirinn birtist hægra megin á stikunni þegar þú ert með margar lyklaborðsuppröðanir eða inntaksaðferðir. Smelltu á hann til að skipta um inntakstungumál; japanska sýnir あ fyrir hiragana. Til að velja japönsk tákn skaltu skipta yfir í japönsku, skrifa orð eins og `nihongo` og ýta svo tvisvar á Space. Ýttu á Enter til að staðfesta valið. Ef þú ert líka með margar lyklaborðsuppröðanir skaltu hægrismella á vísinn til að skipta á milli þeirra.

Notaðu _Setup > Keyboard > Keyboard Inputs_ til að velja uppröðanir eins og ensku og frönsku, úr sömu valkostum og boðið var upp á við uppsetningu. Notaðu _Setup > Keyboard > Input Methods_ til að velja hvaða samsetningarvélar eru virkar. Báðir veljararnir opnast inni í Omarchy-valmyndinni með núverandi val þitt merkt. Smelltu eða ýttu á Enter til að kveikja eða slökkva á valkosti; hver breyting tekur gildi strax. Að afvelja inntaksaðferð fjarlægir hana úr hringnum án þess að fjarlægja uppsetningu hennar; lyklaborðið er áfram í boði.

Keyrðu `omarchy setup keyboard` eða `omarchy setup input` til að opna sömu veljara. Til að bæta við einu tungumáli af skipanalínunni skaltu nota `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` eða `cangjie5`. Quick, Boshiamy og Array fylgja í sama pakka og Cangjie og birtast í Input Methods-veljaranum. Sérsniðnu skiptilyklarnir þínir haldast. Fyrir aðrar uppröðanir eða lykla vélarinnar skaltu setja upp `fcitx5-configtool` með `omarchy pkg add fcitx5-configtool` og ræsa það úr skjáhermi. Að velja inntakstungumál breytir ekki tungumáli skjáborðsins. Að velja japönsku, kóresku eða kínversku undir _Setup > Region > Language_ bætir við inntaksaðferð hennar þegar þú ert ekki með neina enn.

Notaðu `Super + I` til að skipta á milli inntaksaðferða eða lyklaborðsuppröðana og `Super + Shift + I` til að fara til baka í hina áttina, þannig að með þrjú stillt geturðu farið á milli tveggja nágranna. Inntaksvísirinn birtist hægra megin á stikunni aðeins þegar fleiri en ein inntaksaðferð eða uppröðun er stillt. Þessi skjáborðsbinding virkar samhliða núverandi Fcitx-skiptilyklum þínum; þú getur tekið hana yfir í `~/.config/hypr/bindings.lua`. Inntaksvélarnar og samsetningarröðin nota [Fcitx5](https://fcitx-im.org/) þjónustuna sem er þegar í gangi í hverri setu.

### Notaðu ALT sem SUPER

Á sumum lyklaborðum er ekki þægilegt að nota aðalmetalykilinn (Windows/cmd-lykilinn) sem SUPER. Þú getur breytt þessu þannig að ALT verði notað í staðinn með þessari breytingu:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
