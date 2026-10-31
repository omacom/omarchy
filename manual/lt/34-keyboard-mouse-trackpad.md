# Klaviatūra, pelė, jutiklinis kilimėlis

Hyprland leidžia labai detaliai sukonfigūruoti visus įvesties įrenginius. Galite padaryti klaviatūros kartojimą viršgarsinį arba priversti jutiklinį kilimėlį naudoti natūralų slinkimą. Visa tai keičiate faile `~/.config/hypr/input.lua`, kurį taip pat galite pasiekti Omarchy meniu per _Nustatymai > Įvestis_ (`Super + Space`). Viskas, ką ten nustatysite, pakeičia Omarchy numatytąsias reikšmes.

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

Hyprland wiki puslapyje galite [peržiūrėti visas įvesties parinktis](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock veikia kaip įprastas Caps Lock, o `Shift + CapsLock` yra sudarymo klavišas [greitiems emoji](07-hotkeys.md#quick-emojis) ir [kitiems užbaigimams](07-hotkeys.md#quick-completions). Jei sudarymo klavišą mieliau turėtumėte kitur, pakeiskite `omarchy:shift_caps_compose` elemente `kb_options`. Pavyzdžiui, tai perkelia sudarymo klavišą į Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Jutiklinio kilimėlio gestai

Braukite per jutiklinį kilimėlį, kad judėtumėte darbalaukyje:

| Gestas | Veiksmas |
| --- | --- |
| Trys pirštai į kairę / į dešinę | Ankstesnė / kita darbo sritis, įskaitant tuščias |
| Trys pirštai aukštyn | Perjungti DI konsolę |
| Trys pirštai žemyn | Atidaryti Omarchy meniu |
| Keturi pirštai į kairę / į dešinę | Perkelti aktyvų langą į ankstesnę / kitą darbo sritį |
| Keturi pirštai žemyn | Perjungti viso ekrano režimą |

Norėdami pakeisti vieną iš jų, pirmiausia atšaukite jį faile `~/.config/hypr/input.lua`, o tada pridėkite savo [jutiklinio kilimėlio gestą](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), nes Hyprland nepriims dviejų gestų su tais pačiais pirštais ir ta pačia kryptimi:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Norėdami išjungti visus Omarchy gestus, nustatykite `omarchy_default_gestures = false` netoli `~/.config/hypr/hyprland.lua` viršaus, prieš įkeliant Omarchy numatytąsias reikšmes.

Dell XPS nešiojamuosiuose kompiuteriuose su haptiniu jutikliniu kilimėliu taip pat galite nustatyti spustelėjimo stiprumą į žemą, vidutinį arba aukštą per _Trigger > Aparatūra > Jutiklinio kilimėlio haptika_.

### Rašymas kinų, japonų ir kitomis kalbomis

Kai diegimo programa paklaus apie jūsų klaviatūrą, pasirinkite japonų, korėjiečių, kinų (supaprastintoji, Pinyin), Taivano (Zhuyin) arba Honkongo (Cangjie). Omarchy automatiškai sukonfigūruoja klaviatūrą ir atitinkamą įvesties variklį, įskaitant pirmojo paleidimo neprisijungus sąrankos metu. Japonų kalba naudoja Mozc, korėjiečių kalba naudoja standartinį dviejų rinkinių Hangul, supaprastintoji kinų kalba naudoja Pinyin, Taivanas naudoja Chewing standartinį Zhuyin išdėstymą, o Honkongas naudoja Cangjie su Honkongo rašmenų formomis. Japonų (US klaviatūra) suteikia Mozc su US klaviatūros išdėstymu. Hangul, Zhuyin ir Cangjie klavišai lieka savo standartinėse vietose, net kai lotyniškas raides rašote su Dvorak, Colemak arba AZERTY. Jei Hangul arba Chewing pridėjote anksčiau, atžymėkite ir vėl pažymėkite jį per _Nustatymai > Rašymas > Įvesties metodai_, kad jo klavišai būtų perkelti ten; Omarchy variklio, kuriuo jau rašote, neliečia.

Rašymas prasideda lotyniškuoju režimu. Paspauskite `Super + I`, kad pereitumėte per sukonfigūruotus įvesties metodus, ir `Super + Shift + I`, kad pereitumėte atgal. Bakstelėkite vieną `Shift`, kad iš įvesties metodo, pavyzdžiui, Pinyin, išeitumėte į lotyniškas raides, ir bakstelėkite jį dar kartą, kad grįžtumėte atgal, taip, kaip veikia Sogou, Microsoft Pinyin ir macOS; `Shift` kartu su raide vis tiek įveda didžiąją raidę. Japonų klaviatūrose 全角/半角 perjungia įvestį, 変換 ją įjungia, o 無変換 ją išjungia. Su korėjiečių kalba 한/영 perjungia Hangul, o 한자 konvertuoja į Hanja, nesvarbu, ar jūsų klaviatūra turi tam skirtus klavišus, ar jiems siunčia Right Alt ir Right Ctrl, kaip daro daugelis nešiojamųjų kompiuterių, todėl Right Alt ir Right Ctrl ten nėra paprasti modifikavimo klavišai; diktavimo „push-to-talk“ lieka ant F9. `Ctrl + Space` lieka pasiekiamas Tmux ir Herdr; `Shift + CapsLock` lieka sudarymo klavišu.

Klaviatūros indikatorius atsiranda dešinėje juostos pusėje, kai turite kelis klaviatūros išdėstymus arba įvesties metodus. Spustelėkite jį, kad perjungtumėte įvesties kalbas; japonų kalba hiraganai rodo あ. Norėdami pasirinkti japonų rašmenis, perjunkite į japonų kalbą, įveskite žodį, pavyzdžiui, `nihongo`, tada dukart paspauskite Space. Paspauskite Enter, kad patvirtintumėte savo pasirinkimą. Jei taip pat turite kelis klaviatūros išdėstymus, dešiniuoju pelės mygtuku spustelėkite indikatorių, kad pereitumėte per juos.

Naudokite _Nustatymai > Rašymas > Klaviatūros išdėstymai_, kad pasirinktumėte išdėstymus, pavyzdžiui, anglų ir prancūzų, iš tų pačių pasirinkimų, kurie siūlomi diegimo metu. Naudokite _Nustatymai > Rašymas > Įvesties metodai_, kad pasirinktumėte, kurie sudarymo varikliai yra aktyvūs. Abi parinkikliai atsidaro Omarchy meniu, o jūsų dabartiniai pasirinkimai yra pažymėti. Spustelėkite arba paspauskite Enter, kad perjungtumėte pasirinkimą; kiekvienas pakeitimas pritaikomas iš karto. Atžymėjus įvesties metodą, jis pašalinamas iš ciklo jo neišdiegiant; klaviatūra lieka pasiekiama.

Paleiskite `omarchy setup keyboard` arba `omarchy setup input`, kad atidarytumėte tuos pačius parinkiklius. Norėdami iš komandinės eilutės pridėti vieną kalbą, naudokite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` arba `cangjie5`. Quick, Boshiamy ir Array yra tame pačiame pakete kaip Cangjie ir atsiranda Įvesties metodų parinkiklyje. Jūsų pasirinktiniai perjungimo klavišai išsaugomi. Norėdami gauti alternatyvius variklių išdėstymus arba klavišus, įdiekite `fcitx5-configtool` su `omarchy pkg add fcitx5-configtool` ir paleiskite jį iš terminalo. Įvesties kalbos pasirinkimas nepakeičia darbalaukio kalbos. Pasirinkus japonų, korėjiečių arba kinų kalbą per _Nustatymai > Kalba_, jos įvesties metodas pridedamas, kai dar neturite nė vieno.

Naudokite `Super + I`, kad pereitumėte per įvesties metodus arba klaviatūros išdėstymus, ir `Super + Shift + I`, kad eitumėte atgal į kitą pusę, todėl su trimis sukonfigūruotais galite judėti tarp dviejų kaimynų. Įvesties indikatorius dešinėje juostos pusėje atsiranda tik tada, kai sukonfigūruotas daugiau nei vienas įvesties metodas arba išdėstymas. Šis darbalaukio susiejimas veikia kartu su jūsų esamais Fcitx perjungimo klavišais; galite jį pakeisti faile `~/.config/hypr/bindings.lua`. Įvesties varikliai ir sudarymo sekos naudoja [Fcitx5](https://fcitx-im.org/) paslaugą, jau veikiančią kiekvienoje sesijoje.

### ALT naudojimas vietoj SUPER

Kai kuriose klaviatūrose nėra patogu naudoti pagrindinį meta klavišą (Windows/cmd klavišą) kaip SUPER. Galite tai pakeisti, kad vietoj jo būtų ALT, naudodami šį pakeitimą:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
