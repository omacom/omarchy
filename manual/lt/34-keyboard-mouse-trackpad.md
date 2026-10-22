# Klaviatūra, pelė, jutiklinis kilimėlis

Hyprland leidžia konfigūruoti visas savo įvestis labai detaliai. Gali padaryti klaviatūros kartojimą viršgarsinį greitą arba priversti jutiklinį kilimėlį naudoti natūralų slinktį. Tai viską keiti `~/.config/hypr/input.lua`, kurį taip pat gali pasiekti per _Nuostatos > Įvestis_ Omarchy meniu (`Super + Space`). Viskas, ką ten nustatysi, pakeičia Omarchy numatytuosius.

Štai pavyzdys:

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

Visas įvesties parinktis gali [pamatyti](https://wiki.hypr.land/Configuring/Basics/Variables/#input) Hyprland wiki apie įvestis.

CapsLock veikia kaip įprastas Caps Lock, o `Shift + CapsLock` yra compose klavišas [greitiems emoji](07-hotkeys.md#quick-emojis) ir [kitiems užbaigimams](07-hotkeys.md#quick-completions). Jei mieliau norėtum compose klavišo kur kitur, pakeisk `omarchy:shift_caps_compose` į `kb_options`. Pavyzdžiui, tai perkelia compose klavišą į Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Jutiklinio kilimėlio gestai

Taip pat gali įjungti [jutiklinio kilimėlio gestus](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), pavyzdžiui, braukimą trimis pirštais, kad pakeistum darbo sritis:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Dell XPS nešiojamuosiuose su haptiniu jutikliniu kilimėliu taip pat gali nustatyti spustelėjimo stiprumą į žemą, vidutinį arba aukštą skiltyje _Veiksmai > Aparatinė įranga > Kilimėlio vibracija_.

### Rašymas kinų, japonų ir kitomis kalbomis

Pasirink japonų, korėjiečių, kinų (supaprastintą, Pinyin) arba kinų (tradicinę, Zhuyin), kai diegimo programa klausia apie tavo klaviatūrą. Omarchy automatiškai sukonfigūruoja klaviatūrą ir atitinkamą įvesties variklį, įskaitant pirmojo paleidimo sąranką neprisijungus. Japonų kalba naudoja Mozc, korėjiečių — standartinį dviejų rinkinių Hangul, supaprastinta kinų — Pinyin, o tradicinė kinų — Chewing standartinį Zhuyin išdėstymą. Japonų (JAV klaviatūra) teikia Mozc su JAV klaviatūros išdėstymu.

Rašymas prasideda lotyniškuoju režimu. Paspausk `Super + I`, kad pereitum per sukonfigūruotus įvesties metodus, ir `Super + Shift + I`, kad eitumei atgal. Bakstelėk `Shift` vieną, kad iš įvesties metodo, pavyzdžiui, Pinyin, išeitis į lotyniškas raides, ir bakstelėk jį dar kartą, kad grįžtu, taip, kaip veikia Sogou, Microsoft Pinyin ir macOS; `Shift` kartu su raide vis dar įveda didžiąją raidę. Japonų klaviatūrose 全角/半角 perjungia įvestį, 変換 įjungia, o 無変換 išjungia. Korėjiečių klaviatūros išdėstyme tam skirti 한/영 ir 한자 klavišai perjungia Hangul ir konvertuoja į Hanja. `Ctrl + Space` lieka prieinamas Tmux ir Herdr; `Shift + CapsLock` lieka compose klavišas.

Klaviatūros indikatorius pasirodo juostos dešinėje, kai turi kelis klaviatūros išdėstymus ar įvesties metodus. Spustelėk jį, kad perjungtum įvesties kalbas; japonų kalba rodo あ hiraganai. Japonų simbolių pasirinkimams pereik prie japonų kalbos, įvesk žodį, pavyzdžiui, `nihongo`, tada du kartus paspausk Space. Paspausk Enter, kad priimtum savo pasirinkimą. Jei taip pat turi kelis klaviatūros išdėstymus, dešiniuoju pelės klavišu spustelėk indikatorių, kad juos peržvelgtum.

Naudok _Nuostatos > Rašymas > Klaviatūros išdėstymai_, kad pasirinktum išdėstymus, pavyzdžiui, anglų ir prancūzų, iš tų pačių pasirinkimų, siūlomų diegimo metu. Naudok _Nuostatos > Rašymas > Įvesties metodai_, kad pasirinktum, kurie kompozicijos varikliai aktyvūs. Abu rinkikliai atsidaro Omarchy meniu viduje su pažymėtais tavo esamais pasirinkimais. Spustelėk arba paspausk Enter, kad perjungtum pasirinkimą; kiekvienas pakeitimas pritaikomas iškart. Atžymėjus įvesties metodą jis pašalinamas iš ciklo jo neišdiegiant; klaviatūra lieka prieinama.

Paleisk `omarchy setup keyboard` arba `omarchy setup input`, kad atvertum tuos pačius rinkiklius. Kad iš komandinės eilutės prijungtum vieną kalbą, naudok `omarchy setup input mozc`, `hangul`, `pinyin` arba `chewing`. Tavo pasirinktiniai perjungimo klavišai išsaugomi. Alternatyvių variklių išdėstymų ar klavišų atvejais įdiek `fcitx5-configtool` su `omarchy pkg add fcitx5-configtool` ir paleisk jį iš terminalo. Įvesties kalbos pasirinkimas nekeičia darbalaukio kalbos.

Naudok `Super + I`, kad pereitum per įvesties metodus arba klaviatūros išdėstymus, ir `Super + Shift + I`, kad eitum atgal kitu keliu, tad su trimis sukonfigūruotomis gali judėti tarp dviejų kaimynų. Įvesties indikatorius pasirodo juostos dešinėje tik tada, kai sukonfigūruota daugiau nei vienas įvesties metodas ar išdėstymas. Šis darbalaukio susiejimas veikia kartu su tavo esamais Fcitx perjungimo klavišais; gali jį perrašyti `~/.config/hypr/bindings.lua`. Įvesties varikliai ir compose sekos naudoja [Fcitx5](https://fcitx-im.org/) paslaugą, jau veikiančią kiekvienoje sesijoje.

### Naudok ALT kaip SUPER

Kai kuriose klaviatūrose nėra patogu naudoti pagrindinį meta klavišą (Windows/cmd klavišą) kaip SUPER. Vietoje to gali tai pakeisti į ALT naudodamas šį pakeitimą:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
