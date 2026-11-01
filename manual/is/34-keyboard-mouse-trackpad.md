# Lyklaborð, mús, snertiflötur

Hyprland gerir þér kleift að stilla öll inntök þín mjög nákvæmlega. Þú getur gert endurtekningu lyklaborðsins ofsahraða eða látið snertiflötinn nota náttúrulega skrun. Þú breytir öllu þessu í `~/.config/hypr/input.lua`, sem þú getur líka opnað í gegnum _Setup > Input_ í Omarchy-valmyndinni (`Super + Space`). Allt sem þú stillir þar kemur í stað sjálfgefinna stillinga Omarchy.

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

Þú getur [séð alla inntakskosti](https://wiki.hypr.land/Configuring/Basics/Variables/#input) á Hyprland wiki fyrir inntök.

CapsLock virkar sem venjulegur Caps Lock og `Shift + CapsLock` er compose-lykillinn fyrir [fljótleg emoji](07-hotkeys.md#quick-emojis) og [aðrar útfyllingar](07-hotkeys.md#quick-completions). Ef þú vilt frekar hafa compose-lykilinn annars staðar skaltu skipta út `omarchy:shift_caps_compose` í `kb_options`. Þetta færir til dæmis compose-lykilinn yfir á Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Bendingar á snertifleti

Strjúktu á snertifletinum til að fara um skjáborðið:

| Bending | Aðgerð |
| --- | --- |
| Þrír fingur til vinstri / hægri | Fyrra / næsta vinnusvæði, þar á meðal tómt |
| Þrír fingur upp | Kveikja/slökkva á AI-stjórnborðinu |
| Þrír fingur niður | Opna Omarchy-valmyndina |
| Fjórir fingur til vinstri / hægri | Færa virka gluggann á fyrra / næsta vinnusvæði |
| Fjórir fingur niður | Kveikja/slökkva á fullum skjá |

Til að breyta einni þeirra skaltu aftengja hana í `~/.config/hypr/input.lua` áður en þú bætir við þinni eigin [bendingu á snertifleti](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), því Hyprland tekur ekki við tveimur bendingum með sömu fingrum og í sömu átt:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Til að slökkva á öllum bendingum Omarchy skaltu stilla `omarchy_default_gestures = false` nálægt efsta hluta `~/.config/hypr/hyprland.lua`, áður en sjálfgefnar stillingar Omarchy hlaðast inn.

Á Dell XPS fartölvum með haptic-snertifleti geturðu líka stillt smellstyrkinn á lágan, miðlungs eða háan undir _Trigger > Hardware > Touchpad Haptics_.

### Innsláttur á kínversku, japönsku og öðrum tungumálum

Veldu japönsku, kóresku, kínversku (einfölduð, Pinyin), Taívan (Zhuyin) eða Hong Kong (Cangjie) þegar uppsetningarforritið spyr um lyklaborðið þitt. Omarchy stillir lyklaborðið og samsvarandi inntaksvél sjálfkrafa, líka við fyrstu ræsingu án nets. Japanska notar Mozc, kóreska notar staðlað tveggja-setta Hangul, einfölduð kínverska notar Pinyin, Taívan notar staðlaða Zhuyin-uppröðun Chewing og Hong Kong notar Cangjie með stafformum frá Hong Kong. Japanese (US keyboard) býður upp á Mozc með bandarískri lyklaborðsuppröðun. Lyklar fyrir Hangul, Zhuyin og Cangjie haldast á stöðluðum stöðum sínum jafnvel þegar þú slærð inn latneska stafi með Dvorak, Colemak eða AZERTY. Ef þú bættir Hangul eða Chewing við áður en þetta kom til skaltu afvelja og velja það aftur undir _Setup > Typing > Input Methods_ til að færa lykla þess þangað; Omarchy lætur vél sem þú slærð þegar inn með í friði.

Innsláttur byrjar í latneskum ham. Ýttu á `Super + I` til að fletta í gegnum stilltar inntaksaðferðir og `Super + Shift + I` til að fletta til baka. Ýttu á `Shift` eitt og sér til að stíga út úr inntaksaðferð eins og Pinyin yfir í latneska stafi, og ýttu aftur á það til að fara til baka, eins og Sogou, Microsoft Pinyin og macOS virka; `Shift` ásamt bókstaf slær samt inn hástaf. Á japönskum lyklaborðum skiptir 全角/半角 um inntak, 変換 kveikir á því og 無変換 slekkur á því. Með kóresku skiptir 한/영 um Hangul og 한자 breytir í Hanja, hvort sem lyklaborðið þitt er með sérstaka lykla eða sendir Right Alt og Right Ctrl fyrir þá, eins og margar fartölvur gera, svo Right Alt og Right Ctrl eru ekki venjulegir breytilyklar þar; raddinnsláttur skiptist með Alt + Space í staðinn. `Ctrl + Space` helst laust fyrir Tmux og Herdr; `Shift + CapsLock` helst compose-lykillinn.

Lyklaborðsvísirinn birtist hægra megin á stikunni þegar þú ert með margar lyklaborðsuppröðanir eða inntaksaðferðir. Smelltu á hann til að skipta um inntakstungumál; japanska sýnir あ fyrir hiragana. Fyrir val á japönskum stöfum skaltu skipta yfir í japönsku, slá inn orð eins og `nihongo` og ýta síðan tvisvar á Space. Ýttu á Enter til að samþykkja valið. Ef þú ert líka með margar lyklaborðsuppröðanir skaltu hægrismella á vísinn til að fletta í gegnum þær.

Notaðu _Setup > Typing > Keyboard Layouts_ til að velja uppröðanir eins og ensku og frönsku, úr sömu valkostum og boðið er upp á við uppsetningu. Notaðu _Setup > Typing > Input Methods_ til að velja hvaða samsetningarvélar eru virkar. Báðir veljararnir opnast inni í Omarchy-valmyndinni með núverandi val þitt merkt. Smelltu eða ýttu á Enter til að kveikja eða slökkva á valkosti; hver breyting tekur gildi strax. Að afvelja inntaksaðferð fjarlægir hana úr hringnum án þess að fjarlægja hana; lyklaborðið helst tiltækt.

Keyrðu `omarchy setup keyboard` eða `omarchy setup input` til að opna sömu veljara. Til að bæta við einu tungumáli af skipanalínunni skaltu nota `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` eða `cangjie5`. Quick, Boshiamy og Array koma í sama pakka og Cangjie og birtast í Input Methods-veljaranum. Sérsniðnu skiptilyklarnir þínir varðveitast. Fyrir aðrar uppröðanir eða lykla vélar skaltu setja upp `fcitx5-configtool` með `omarchy pkg add fcitx5-configtool` og ræsa það úr útstöð. Að velja inntakstungumál breytir ekki tungumáli skjáborðsins. Að velja japönsku, kóresku eða kínversku undir _Setup > Language_ bætir inntaksaðferð hennar við þegar þú ert ekki með neina ennþá.

Notaðu `Super + I` til að fletta í gegnum inntaksaðferðir eða lyklaborðsuppröðanir og `Super + Shift + I` til að fara hina leiðina til baka, svo með þrjár stilltar geturðu farið á milli tveggja nágranna. Inntaksvísirinn birtist hægra megin á stikunni aðeins þegar fleiri en ein inntaksaðferð eða uppröðun er stillt. Þessi skjáborðsbinding virkar samhliða núverandi Fcitx-skiptilyklum þínum; þú getur hnekkt henni í `~/.config/hypr/bindings.lua`. Inntaksvélarnar og compose-runanirnar nota [Fcitx5](https://fcitx-im.org/) þjónustuna sem þegar keyrir í hverri setu.

### Notaðu ALT sem SUPER

Á sumum lyklaborðum er ekki þægilegt að nota aðalmeta-lykilinn (Windows/cmd-lykilinn) sem SUPER. Þú getur breytt þessu þannig að það sé ALT í staðinn með þessari breytingu:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
