# Lyklaborð, mús, snertiflötur

Hyprland gerir þér kleift að stilla öll inntökin þín mjög nákvæmlega. Þú getur gert endurtekningu lyklaborðsins ofsahraða eða látið snertiflötinn nota náttúrulegt skrun. Þú breytir öllu þessu í `~/.config/hypr/input.lua`, sem þú getur líka opnað í gegnum _Setup > Input_ í Omarchy-valmyndinni (`Super + Space`). Allt sem þú stillir þar kemur í stað sjálfgefnu stillinganna í Omarchy.

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

Þú getur [séð alla inntaksvalkostina](https://wiki.hypr.land/Configuring/Basics/Variables/#input) á Hyprland-wikinu fyrir inntök.

CapsLock virkar sem venjulegur Caps Lock og `Shift + CapsLock` er samsetningarlykillinn fyrir [snögg emoji](07-hotkeys.md#quick-emojis) og [aðrar útfyllingar](07-hotkeys.md#quick-completions). Ef þú vilt frekar hafa samsetningarlykilinn annars staðar skaltu skipta út `omarchy:shift_caps_compose` í `kb_options`. Þetta færir til dæmis samsetningarlykilinn yfir á Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Bendingar á snertifleti

Þú getur líka kveikt á [bendingum á snertifleti](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), eins og að strjúka með þremur fingrum til að skipta um vinnusvæði:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Á Dell XPS fartölvum með haptískum snertifleti geturðu líka stillt smellstyrkinn á lágan, miðlungs eða háan undir _Trigger > Hardware > Touchpad Haptics_.

### Að skrifa á kínversku, japönsku og öðrum tungumálum

Veldu japönsku, kóresku, kínversku (einfölduð, Pinyin), Taívan (Zhuyin) eða Hong Kong (Cangjie) þegar uppsetningarforritið spyr um lyklaborðið þitt. Omarchy stillir lyklaborðið og samsvarandi inntaksvél sjálfkrafa, líka við offline uppsetningu við fyrstu ræsingu. Japanska notar Mozc, kóreska notar staðlað tveggja-setja Hangul, einfölduð kínverska notar Pinyin, Taívan notar staðlaða Zhuyin-röðun Chewing og Hong Kong notar Cangjie með Hong Kong stafformum. Japanska (US lyklaborð) býður Mozc með US lyklaborðsuppsetningu. Hangul, Zhuyin og Cangjie lyklar haldast í stöðluðum stöðum sínum jafnvel þegar þú skrifar latneska stafi með Dvorak, Colemak eða AZERTY. Ef þú bættir Hangul eða Chewing við áður en þetta kom skaltu afvelja og velja það aftur undir _Setup > Typing > Input Methods_ til að færa lykla þess þangað; Omarchy lætur vél sem þú skrifar nú þegar með í friði.

Innsláttur byrjar í Latin ham. Ýttu á `Super + I` til að fara í gegnum stilltar inntaksaðferðir og `Super + Shift + I` til að fara til baka. Bankaðu á `Shift` eitt og sér til að stíga út úr inntaksaðferð eins og Pinyin yfir í latneska stafi og bankaðu aftur til að fara til baka, eins og Sogou, Microsoft Pinyin og macOS virka; `Shift` ásamt staf skrifar samt hástaf. Á japönskum lyklaborðum skiptir 全角/半角 um inntak, 変換 kveikir á því og 無変換 slekkur á því. Með kóresku skiptir 한/영 um Hangul og 한자 breytir í Hanja, hvort sem lyklaborðið þitt hefur sérstaka lykla eða sendir Right Alt og Right Ctrl fyrir þá, eins og margar fartölvur gera, svo Right Alt og Right Ctrl eru ekki venjulegir breytilyklar þar; þrýsta-og-tala fyrir talgreiningu helst á F9. `Ctrl + Space` helst tiltækt fyrir Tmux og Herdr; `Shift + CapsLock` helst samsetningarlykillinn.

Vísir lyklaborðsins birtist hægra megin á stikunni þegar þú ert með margar lyklaborðsuppsetningar eða inntaksaðferðir. Smelltu á hann til að skipta um inntakstungumál; japanska sýnir あ fyrir hiragana. Fyrir japanskt stafaval skaltu skipta yfir í japönsku, skrifa orð eins og `nihongo` og ýta svo tvisvar á Space. Ýttu á Enter til að staðfesta valið. Ef þú ert líka með margar lyklaborðsuppsetningar skaltu hægrismella á vísinn til að fara í gegnum þær.

Notaðu _Setup > Typing > Keyboard Layouts_ til að velja uppsetningar eins og ensku og frönsku, úr sömu valkostum og í boði eru við uppsetningu. Notaðu _Setup > Typing > Input Methods_ til að velja hvaða samsetningarvélar eru virkar. Báðir veljararnir opnast inni í Omarchy-valmyndinni með núverandi val þitt merkt. Smelltu eða ýttu á Enter til að víxla valkosti; hver breyting tekur gildi strax. Að afvelja inntaksaðferð fjarlægir hana úr hringnum án þess að fjarlægja hana; lyklaborðið helst tiltækt.

Keyrðu `omarchy setup keyboard` eða `omarchy setup input` til að opna sömu veljara. Til að bæta við einu tungumáli úr skipanalínunni skaltu nota `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` eða `cangjie5`. Quick, Boshiamy og Array koma í sama pakka og Cangjie og birtast í Input Methods veljaranum. Sérsniðnir skiptilyklar þínir haldast. Fyrir aðrar uppsetningar á vélum eða lyklum skaltu setja upp `fcitx5-configtool` með `omarchy pkg add fcitx5-configtool` og ræsa það úr skel. Að velja inntakstungumál breytir ekki tungumáli skjáborðsins. Að velja japönsku, kóresku eða kínversku undir _Setup > Language_ bætir við inntaksaðferð þess þegar þú ert ekki með neina enn.

Notaðu `Super + I` til að fara í gegnum inntaksaðferðir eða lyklaborðsuppsetningar og `Super + Shift + I` til að fara hina leiðina til baka, svo með þrjár stilltar geturðu fært þig á milli tveggja nágranna. Inntaksvísirinn birtist hægra megin á stikunni aðeins þegar fleiri en ein inntaksaðferð eða uppsetning er stillt. Þessi skjáborðsbinding virkar samhliða núverandi Fcitx skiptilyklum þínum; þú getur yfirskrifað hana í `~/.config/hypr/bindings.lua`. Inntaksvélarnar og samsetningarrunurnar nota [Fcitx5](https://fcitx-im.org/) þjónustuna sem þegar keyrir í hverri setu.

### Nota ALT sem SUPER

Á sumum lyklaborðum er ekki þægilegt að nota aðal meta-lykilinn (Windows/cmd lykilinn) sem SUPER. Þú getur breytt þessu í ALT í staðinn með þessari breytingu:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
