# Lyklaborð, mús, snertiflötur

Hyprland gerir þér kleift að stilla allt ílagið þitt mjög nákvæmlega. Þú getur látið lyklaborðsendurtekninguna vera yfirhljóðshraða eða látið snertiflötinn nota náttúrulegt skrun. Þú breytir öllu í `~/.config/hypr/input.lua`, sem þú getur líka opnað í gegnum _Uppsetning > Ílag_ í Omarchy-valmyndinni (`Super + Space`). Allt sem þú stillir þar kemur í stað sjálfgefinna stillinga Omarchy.

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

Þú getur [séð alla ílagsmöguleikana](https://wiki.hypr.land/Configuring/Basics/Variables/#input) á Hyprland-wikinu fyrir ílag.

CapsLock virkar sem venjulegt Caps Lock og `Shift + CapsLock` er compose-lykillinn fyrir [flýtitextatákn](07-hotkeys.md#quick-emojis) og [aðrar flýtiútfyllingar](07-hotkeys.md#quick-completions). Ef þú vilt frekar hafa compose-lykilinn annars staðar skaltu skipta út `omarchy:shift_caps_compose` í `kb_options`. Til dæmis færir þetta compose-lykilinn á Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Snertiflatarbendingar

Strjúktu á snertifletinum til að færa þig um skjáborðið:

| Bending | Aðgerð |
| --- | --- |
| Þrír fingur til vinstri / hægri | Fyrra / næsta vinnusvæði, þar á meðal tóm |
| Þrír fingur upp | Kveikja / slökkva á AI-stjórnborðinu |
| Þrír fingur niður | Opna Omarchy-valmyndina |
| Fjórir fingur til vinstri / hægri | Færa virka gluggann á fyrra / næsta vinnusvæði |
| Fjórir fingur niður | Kveikja / slökkva á fullum skjá |

Til að breyta einni skaltu afstilla hana í `~/.config/hypr/input.lua` áður en þú bætir við þinni eigin [snertiflatarbendingu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), því Hyprland tekur ekki við tveimur bendingum með sömu fingrum og í sömu átt:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Til að slökkva á öllum bendingum Omarchy skaltu stilla `omarchy_default_gestures = false` nálægt efsta hluta `~/.config/hypr/hyprland.lua`, áður en sjálfgefnar stillingar Omarchy hlaðast inn.

Á Dell XPS-fartölvum með haptískum snertifleti geturðu líka stillt smellstyrkinn á lágan, miðlungs eða háan undir _Trigger > Hardware > Touchpad Haptics_.

### Ritun á kínversku, japönsku og öðrum tungumálum

Veldu japönsku, kóresku, kínversku (einfölduð, Pinyin), Taívan (Zhuyin) eða Hong Kong (Cangjie) þegar uppsetningarforritið spyr um lyklaborðið þitt. Omarchy stillir lyklaborðið og samsvarandi ílagsvél sjálfkrafa, líka við fyrstu ræsingu án nettengingar. Japanska notar Mozc, kóreska notar staðlað tveggja-setta Hangul, einfölduð kínverska notar Pinyin, Taívan notar staðlaða Zhuyin-uppröðun Chewing og Hong Kong notar Cangjie með táknformum frá Hong Kong. Japanska (bandarískt lyklaborð) býður upp á Mozc með bandarískri lyklaborðsuppröðun. Lyklar fyrir Hangul, Zhuyin og Cangjie haldast í stöðluðum stöðum sínum jafnvel þegar þú skrifar latneska stafi með Dvorak, Colemak eða AZERTY. Ef þú bættir Hangul eða Chewing við áður en þetta kom til skaltu afvelja það og velja það aftur undir _Uppsetning > Ritun > Ílagsaðferðir_ til að færa lyklana þess þangað; Omarchy lætur vél sem þú skrifar þegar með í friði.

Ritun byrjar í latneskum ham. Ýttu á `Super + I` til að fletta í gegnum stilltar ílagsaðferðir og `Super + Shift + I` til að fletta til baka. Ýttu á `Shift` eitt og sér til að stíga út úr ílagsaðferð á borð við Pinyin yfir í latneska stafi og ýttu aftur á það til að fara til baka, eins og Sogou, Microsoft Pinyin og macOS gera; `Shift` ásamt staf skrifar samt hástaf. Á japönskum lyklaborðum kveikir og slekkur 全角/半角 á ílagi, 変換 kveikir á því og 無変換 slekkur á því. Í kóresku skiptir 한/영 um Hangul og 한자 breytir í Hanja, hvort sem lyklaborðið þitt er með sérstaka lykla eða sendir Right Alt og Right Ctrl fyrir þá, eins og margar fartölvur gera, svo Right Alt og Right Ctrl eru ekki venjulegir breytilyklar þar; þrýstið-og-talið fyrir talgreiningu helst á F9. `Ctrl + Space` helst tiltækt fyrir Tmux og Herdr; `Shift + CapsLock` helst compose-lykillinn.

Lyklaborðsvísirinn birtist hægra megin á stikunni þegar þú ert með margar lyklaborðsuppröðanir eða ílagsaðferðir. Smelltu á hann til að skipta um ílagstungumál; japanska sýnir あ fyrir hiragana. Til að velja japönsk tákn skaltu skipta yfir í japönsku, skrifa orð á borð við `nihongo` og ýta síðan tvisvar á Space. Ýttu á Enter til að samþykkja valið þitt. Ef þú ert líka með margar lyklaborðsuppröðanir skaltu hægrismella á vísinn til að fletta í gegnum þær.

Notaðu _Uppsetning > Ritun > Lyklaborðsuppröðanir_ til að velja uppröðanir á borð við ensku og frönsku, úr sömu valkostum og boðið er upp á við uppsetningu. Notaðu _Uppsetning > Ritun > Ílagsaðferðir_ til að velja hvaða samsetningarvélar eru virkar. Báðir veljararnir opnast inni í Omarchy-valmyndinni með núverandi val þitt merkt. Smelltu eða ýttu á Enter til að kveikja eða slökkva á valkosti; hver breyting tekur strax gildi. Að afvelja ílagsaðferð fjarlægir hana úr hringnum án þess að fjarlægja hana; lyklaborðið helst tiltækt.

Keyrðu `omarchy setup keyboard` eða `omarchy setup input` til að opna sömu veljara. Til að bæta við einu tungumáli af skipanalínunni skaltu nota `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` eða `cangjie5`. Quick, Boshiamy og Array fylgja í sama pakka og Cangjie og birtast í veljaranum fyrir ílagsaðferðir. Sérsniðnir skiptilyklarnir þínir haldast. Fyrir aðrar uppröðanir eða lykla véla skaltu setja upp `fcitx5-configtool` með `omarchy pkg add fcitx5-configtool` og ræsa það úr útstöð. Að velja ílagstungumál breytir ekki tungumáli skjáborðsins. Að velja japönsku, kóresku eða kínversku undir _Uppsetning > Tungumál_ bætir ílagsaðferð hennar við þegar þú ert ekki þegar með neina.

Notaðu `Super + I` til að fletta í gegnum ílagsaðferðir eða lyklaborðsuppröðanir og `Super + Shift + I` til að fara hina leiðina til baka, svo með þrjár stilltar geturðu fært þig á milli tveggja nágranna. Ílagsvísirinn birtist hægra megin á stikunni aðeins þegar fleiri en ein ílagsaðferð eða uppröðun er stillt. Þessi skjáborðsbinding virkar samhliða núverandi Fcitx-skiptilyklum þínum; þú getur hnekkt henni í `~/.config/hypr/bindings.lua`. Ílagsvélarnar og compose-rununar nota [Fcitx5](https://fcitx-im.org/) þjónustuna sem þegar er í gangi í hverri setu.

### Nota ALT sem SUPER

Á sumum lyklaborðum er ekki þægilegt að nota aðalmetalyklinn (Windows/cmd-lykilinn) sem SUPER. Þú getur breytt þessu þannig að ALT sé notað í staðinn með þessari breytingu:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
