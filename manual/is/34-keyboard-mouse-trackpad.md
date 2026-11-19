# Lyklaborð, mús, snertiflötur

Hyprland gerir þér kleift að stilla öll inntök þín í miklum smáatriðum. Þú getur stillt endurtekningu lyklaborðsins á ógnarhraða eða látið snertiflötinn nota náttúrulega skrun. Þú breytir öllu þessu í `~/.config/hypr/input.lua`, sem þú getur líka opnað í gegnum _Uppsetning > Inntak_ í Omarchy-valmyndinni (`Super + Space`). Allt sem þú stillir þar kemur í stað sjálfgefinna stillinga Omarchy.

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

Þú getur [séð alla inntaksmöguleikana](https://wiki.hypr.land/Configuring/Basics/Variables/#input) á Hyprland-wiki fyrir inntök.

CapsLock virkar sem venjulegur Caps Lock og `Shift + CapsLock` er samsetningarlykillinn fyrir [flýtibroskalla](07-hotkeys.md#quick-emojis) og [aðrar útfyllingar](07-hotkeys.md#quick-completions). Ef þú vilt frekar hafa samsetningarlykilinn annars staðar skaltu skipta út `omarchy:shift_caps_compose` í `kb_options`. Þetta færir til dæmis samsetningarlykilinn yfir á Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Aðgerðarlyklar

Efsta röðin á fartölvulyklaborði sendir sjálfgefið margmiðlunarlyklana (hljóðstyrk, birtustig og svo framvegis) og með því að halda inni `Fn` færðu F1-F12; `Fn + Esc` læsir þessu í hina áttina þar til þú ýtir aftur á hann. Flest lyklaborð muna þessa læsingu sjálf. Fartölvur frá ASUS og lyklaborð í Apple-stíl fela Linux þetta, sem ræsir þau með margmiðlunarlyklunum við hverja ræsingu. Til að þau ræsist í staðinn með F1-F12 skaltu keyra `omarchy device keyboard toprow fnkeys` (og `omarchy device keyboard toprow mediakeys` til að fara til baka); á sumum fartölvum tekur þetta gildi eftir endurræsingu. Apple Silicon Mac-tölvur halda sinni eigin stillingu.

### Bendingar á snertifleti

Strjúktu á snertifletinum til að fara um skjáborðið:

| Bending | Aðgerð |
| --- | --- |
| Þrír fingur til vinstri / hægri | Fyrra / næsta vinnusvæði, líka þau sem eru tóm |
| Þrír fingur upp | Víxla AI-stjórnborðinu |
| Þrír fingur niður | Opna Omarchy-valmyndina |
| Fjórir fingur til vinstri / hægri | Færa virka gluggann á fyrra / næsta vinnusvæði |
| Fjórir fingur niður | Víxla fullum skjá |

Til að breyta einni þeirra skaltu afstilla hana í `~/.config/hypr/input.lua` áður en þú bætir við þinni eigin [bendingu fyrir snertiflöt](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), því Hyprland tekur ekki við tveimur bendingum með sömu fingrum og í sömu átt:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Til að slökkva á öllum bendingum Omarchy skaltu setja `omarchy_default_gestures = false` nálægt efsta hluta `~/.config/hypr/hyprland.lua`, áður en sjálfgefnar stillingar Omarchy hlaðast inn.

Á Dell XPS-fartölvum með haptískum snertifleti getur þú líka stillt smellstyrkinn á lágan, miðlungs eða háan undir _Kveikja > Vélbúnaður > Snertiflatarhaptík_.

### Að skrifa á kínversku, japönsku og öðrum tungumálum

Veldu japönsku, kóresku, kínversku (einfölduð, Pinyin), Taívan (Zhuyin) eða Hong Kong (Cangjie) þegar uppsetningarforritið spyr um lyklaborðið þitt. Omarchy stillir lyklaborðið og samsvarandi inntaksvél sjálfkrafa, líka við uppsetningu án nettengingar við fyrstu ræsingu. Japanska notar Mozc, kóreska notar staðlað Hangul með tveimur settum, einfölduð kínverska notar Pinyin, Taívan notar staðlaða Zhuyin-uppröðun Chewing og Hong Kong notar Cangjie með stafformum frá Hong Kong. Japanska (bandarískt lyklaborð) veitir Mozc með bandarískri lyklaborðsuppröðun. Lyklar fyrir Hangul, Zhuyin og Cangjie haldast á stöðluðum stöðum sínum jafnvel þegar þú skrifar latneska stafi með Dvorak, Colemak eða AZERTY. Ef þú hafðir áður bætt við Hangul eða Chewing skaltu afvelja það og velja það aftur undir _Uppsetning > Lyklaborð > Inntaksaðferðir_ til að færa lyklana þess á þá staði; Omarchy lætur vél sem þú ert þegar að skrifa með vera í friði.

Innslátturinn byrjar í latneskum ham. Ýttu á `Super + I` til að fara í gegnum stilltar inntaksaðferðir og `Super + Shift + I` til að fara til baka. Ýttu stutt á `Shift` eitt og sér til að stíga út úr inntaksaðferð eins og Pinyin yfir í latneska stafi og ýttu aftur stutt til að fara til baka, eins og hjá Sogou, Microsoft Pinyin og macOS; `Shift` ásamt bókstaf skrifar samt hástaf. Á japönskum lyklaborðum víxlar 全角/半角 inntaki, 変換 kveikir á því og 無変換 slekkur á því. Í kóresku skiptir 한/영 um Hangul og 한자 breytir í Hanja, hvort sem lyklaborðið þitt er með sérlykla fyrir þau eða sendir Right Alt og Right Ctrl í þeirra stað, eins og margar fartölvur gera, svo Right Alt og Right Ctrl eru ekki venjulegir breytilyklar þar; talinnsláttur víxlast í staðinn með Alt + Space. `Ctrl + Space` er áfram tiltækt fyrir Tmux og Herdr; `Shift + CapsLock` er áfram samsetningarlykillinn.

Lyklaborðsvísirinn birtist hægra megin á stikunni þegar þú ert með mörg lyklaborðsútilög eða inntaksaðferðir. Smelltu á hann til að skipta um inntakstungumál; japanska sýnir あ fyrir hiragana. Til að velja japönsk tákn skaltu skipta yfir í japönsku, skrifa orð eins og `nihongo` og ýta svo tvisvar á Space. Ýttu á Enter til að staðfesta val þitt. Ef þú ert líka með mörg lyklaborðsútilög skaltu hægrismella á vísinn til að fara í gegnum þau.

Notaðu _Uppsetning > Lyklaborð > Lyklaborðsinntök_ til að velja útilög eins og ensku og frönsku, úr sömu valkostum og boðið er upp á við uppsetningu. Notaðu _Uppsetning > Lyklaborð > Inntaksaðferðir_ til að velja hvaða samsetningarvélar eru virkar. Báðir veljararnir opnast innan Omarchy-valmyndarinnar með núverandi val þitt merkt. Smelltu eða ýttu á Enter til að víxla valkosti; hver breyting tekur gildi strax. Að afvelja inntaksaðferð fjarlægir hana úr hringnum án þess að fjarlægja hana af tölvunni; lyklaborðið er áfram tiltækt.

Keyrðu `omarchy setup keyboard` eða `omarchy setup input` til að opna sömu veljarana. Til að bæta einu tungumáli við frá skipanalínunni skaltu nota `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` eða `cangjie5`. Quick, Boshiamy og Array fylgja í sama pakka og Cangjie og birtast í veljaranum fyrir inntaksaðferðir. Sérsniðnu skiptilyklarnir þínir haldast. Fyrir aðrar uppröðanir eða lykla fyrir vélar skaltu setja upp `fcitx5-configtool` með `omarchy pkg add fcitx5-configtool` og ræsa það úr útstöð. Að velja inntakstungumál breytir ekki tungumáli skjáborðsins. Að velja japönsku, kóresku eða kínversku undir _Uppsetning > Tungumál_ bætir við inntaksaðferð hennar þegar þú ert ekki enn með neina.

Notaðu `Super + I` til að fara í gegnum inntaksaðferðir eða lyklaborðsútilög og `Super + Shift + I` til að fara hina leiðina til baka, svo með þremur stilltum geturðu færst á milli tveggja aðliggjandi valkosta. Inntaksvísirinn birtist hægra megin á stikunni aðeins þegar fleiri en ein inntaksaðferð eða útilag er stillt. Þessi skjáborðstenging virkar samhliða núverandi Fcitx-skiptilyklunum þínum; þú getur hnekkt henni í `~/.config/hypr/bindings.lua`. Inntaksvélar og samsetningarrunur nota [Fcitx5](https://fcitx-im.org/) þjónustuna sem er þegar í gangi í hverri setu.

### Að nota ALT sem SUPER

Á sumum lyklaborðum er ekki þægilegt að nota aðalbreytilykilinn (Windows/cmd-lykilinn) sem SUPER. Þú getur breytt þessu þannig að ALT verði notað í staðinn með þessari breytingu:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
