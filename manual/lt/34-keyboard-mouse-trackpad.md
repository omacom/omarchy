# Klaviatūra, pelė, jutiklinis kilimėlis

Hyprland leidžia labai detaliai sukonfigūruoti visus įvesties įrenginius. Galite nustatyti supersoniškai greitą klaviatūros kartojimą arba priversti jutiklinį kilimėlį naudoti natūralų slinkimą. Visa tai keičiate faile `~/.config/hypr/input.lua`, kurį taip pat galite pasiekti per _Setup > Input_ Omarchy meniu (`Super + Space`). Viskas, ką ten nustatysite, pakeičia Omarchy numatytuosius nustatymus.

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

Galite [peržiūrėti visas įvesties parinktis](https://wiki.hypr.land/Configuring/Basics/Variables/#input) Hyprland wiki puslapyje apie įvestis.

CapsLock veikia kaip įprastas Caps Lock, o `Shift + CapsLock` yra komponavimo klavišas [sparčiųjų jaustukų](07-hotkeys.md#quick-emojis) ir [kitų užbaigimų](07-hotkeys.md#quick-completions) funkcijoms. Jei komponavimo klavišą verčiau turėtumėte kitur, `kb_options` pakeiskite `omarchy:shift_caps_compose`. Pavyzdžiui, tai perkelia komponavimo klavišą į Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Jutiklinio kilimėlio gestai

Taip pat galite įjungti [jutiklinio kilimėlio gestus](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), pavyzdžiui, braukimą trimis pirštais darbo erdvėms keisti:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Dell XPS nešiojamuosiuose kompiuteriuose su haptiniu jutikliniu kilimėliu spustelėjimo stiprumą taip pat galite nustatyti į žemą, vidutinį arba aukštą skiltyje _Trigger > Hardware > Touchpad Haptics_.

### Rašymas kinų, japonų ir kitomis kalbomis

Kai diegimo programa paklaus apie jūsų klaviatūrą, pasirinkite japonų, korėjiečių, kinų (supaprastintą, Pinyin), Taivano (Zhuyin) arba Honkongo (Cangjie). Omarchy automatiškai sukonfigūruoja klaviatūrą ir atitinkamą įvesties variklį, taip pat ir neprisijungus atliekamos pirmojo paleidimo sąrankos metu. Japonų kalba naudoja Mozc, korėjiečių kalba naudoja standartinį dviejų rinkinių Hangul, supaprastinta kinų kalba naudoja Pinyin, Taivanas naudoja standartinį Chewing Zhuyin išdėstymą, o Honkongas naudoja Cangjie su Honkongo rašmenų formomis. Japanese (US keyboard) suteikia Mozc su US klaviatūros išdėstymu. Hangul, Zhuyin ir Cangjie klavišai lieka standartinėse vietose, net kai lotyniškas raides rašote su Dvorak, Colemak arba AZERTY. Jei Hangul arba Chewing pridėjote anksčiau, panaikinkite jų pasirinkimą ir pasirinkite iš naujo skiltyje _Setup > Typing > Input Methods_, kad jų klavišai būtų perkelti ten; Omarchy palieka ramybėje variklį, su kuriuo jau rašote.

Rašymas prasideda lotyniškos abėcėlės režimu. Paspauskite `Super + I`, kad pereitumėte per sukonfigūruotus įvesties metodus, ir `Super + Shift + I`, kad pereitumėte atgal. Bakstelėkite vieną `Shift`, kad išeitumėte iš tokio įvesties metodo kaip Pinyin į lotyniškas raides, ir bakstelėkite jį dar kartą, kad grįžtumėte – taip, kaip veikia Sogou, Microsoft Pinyin ir macOS; `Shift` kartu su raide vis tiek rašo didžiąją raidę. Japonų klaviatūrose 全角/半角 perjungia įvestį, 変換 ją įjungia, o 無変換 ją išjungia. Su korėjiečių kalba 한/영 perjungia Hangul, o 한자 konvertuoja į Hanja, nesvarbu, ar jūsų klaviatūra turi tam skirtus klavišus, ar siunčia jiems Right Alt ir Right Ctrl, kaip daro daugelis nešiojamųjų kompiuterių, todėl Right Alt ir Right Ctrl ten nėra paprasti modifikatoriai; diktavimo funkcija „paspausk ir kalbėk“ lieka priskirta F9. `Ctrl + Space` lieka prieinamas Tmux ir Herdr; `Shift + CapsLock` lieka komponavimo klavišu.

Klaviatūros indikatorius atsiranda juostos dešinėje, kai turite kelis klaviatūros išdėstymus arba įvesties metodus. Spustelėkite jį, kad perjungtumėte įvesties kalbas; japonų kalba hiraganai rodo あ. Norėdami pasirinkti japonų rašmenis, perjunkite į japonų kalbą, įveskite tokį žodį kaip `nihongo`, tada dukart paspauskite Space. Paspauskite Enter, kad patvirtintumėte savo pasirinkimą. Jei taip pat turite kelis klaviatūros išdėstymus, dešiniuoju pelės mygtuku spustelėkite indikatorių, kad pereitumėte per juos.

Naudokite _Setup > Typing > Keyboard Layouts_, kad pasirinktumėte tokius išdėstymus kaip anglų ir prancūzų, iš tų pačių pasirinkimų, kurie siūlomi diegimo metu. Naudokite _Setup > Typing > Input Methods_, kad pasirinktumėte, kurie komponavimo varikliai yra aktyvūs. Abu parinkikliai atsidaro Omarchy meniu, o jūsų dabartiniai pasirinkimai yra pažymėti. Spustelėkite arba paspauskite Enter, kad perjungtumėte pasirinkimą; kiekvienas pakeitimas pritaikomas iš karto. Panaikinus įvesties metodo pasirinkimą, jis pašalinamas iš ciklo jo neišdiegiant; klaviatūra lieka prieinama.

Paleiskite `omarchy setup keyboard` arba `omarchy setup input`, kad atidarytumėte tuos pačius parinkiklius. Norėdami iš komandinės eilutės pridėti vieną kalbą, naudokite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` arba `cangjie5`. Quick, Boshiamy ir Array yra tame pačiame pakete kaip Cangjie ir rodomi Input Methods parinkiklyje. Jūsų pasirinktiniai perjungimo klavišai išsaugomi. Norėdami naudoti alternatyvius variklių išdėstymus arba klavišus, įdiekite `fcitx5-configtool` naudodami `omarchy pkg add fcitx5-configtool` ir paleiskite jį iš terminalo. Įvesties kalbos pasirinkimas nepakeičia darbalaukio kalbos. Japonų, korėjiečių arba kinų kalbos pasirinkimas skiltyje _Setup > Language_ prideda jos įvesties metodą, kai dar neturite jokio.

Naudokite `Super + I`, kad pereitumėte per įvesties metodus arba klaviatūros išdėstymus, ir `Super + Shift + I`, kad eitumėte atgal kita kryptimi, tad turėdami sukonfigūruotus tris, galite judėti tarp dviejų kaimyninių. Įvesties indikatorius juostos dešinėje rodomas tik tada, kai sukonfigūruotas daugiau nei vienas įvesties metodas arba išdėstymas. Šis darbalaukio susiejimas veikia kartu su jūsų esamais Fcitx perjungimo klavišais; galite jį pakeisti faile `~/.config/hypr/bindings.lua`. Įvesties varikliai ir komponavimo sekos naudoja [Fcitx5](https://fcitx-im.org/) paslaugą, jau veikiančią kiekvienoje sesijoje.

### ALT naudojimas vietoj SUPER

Kai kuriose klaviatūrose nėra patogu naudoti pagrindinį meta klavišą (Windows/cmd klavišą) kaip SUPER. Galite tai pakeisti į ALT naudodami šį pakeitimą:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
