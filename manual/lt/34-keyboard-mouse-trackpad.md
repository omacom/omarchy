# Klaviatūra, pelė, jutiklinis kilimėlis

Hyprland leidžia labai detaliai sukonfigūruoti visus įvesties įrenginius. Galite nustatyti, kad klaviatūros kartojimas būtų viršgarsinio greičio, arba padaryti, kad jutiklinis kilimėlis naudotų natūralų slinkimą. Visa tai keičiate faile `~/.config/hypr/input.lua`, kurį taip pat galite pasiekti per _Sąranka > Įvestis_ Omarchy meniu (`Super + Space`). Viskas, ką ten nustatysite, pakeičia Omarchy numatytąsias reikšmes.

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

CapsLock veikia kaip įprastas Caps Lock, o `Shift + CapsLock` yra komponavimo klavišas [greitiesiems jaustukams](07-hotkeys.md#quick-emojis) ir [kitiems užbaigimams](07-hotkeys.md#quick-completions). Jei norėtumėte, kad komponavimo klavišas būtų kitur, pakeiskite `omarchy:shift_caps_compose` reikšmėje `kb_options`. Pavyzdžiui, taip komponavimo klavišas perkeliamas į Right Alt:

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
| Trys pirštai aukštyn | Perjungti AI konsolę |
| Trys pirštai žemyn | Atidaryti Omarchy meniu |
| Keturi pirštai į kairę / į dešinę | Perkelti aktyvų langą į ankstesnę / kitą darbo sritį |
| Keturi pirštai žemyn | Perjungti viso ekrano režimą |

Norėdami pakeisti kurį nors vieną, atšaukite jį faile `~/.config/hypr/input.lua` prieš pridėdami savo [jutiklinio kilimėlio gestą](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), nes Hyprland nepriims dviejų gestų su tais pačiais pirštais ir ta pačia kryptimi:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Norėdami išjungti visus Omarchy gestus, nustatykite `omarchy_default_gestures = false` netoli failo `~/.config/hypr/hyprland.lua` viršaus, prieš užsikraunant Omarchy numatytosioms reikšmėms.

Nešiojamuosiuose kompiuteriuose Dell XPS su haptiniu jutikliniu kilimėliu paspaudimo stiprumą taip pat galite nustatyti į žemą, vidutinį arba aukštą skiltyje _Paleidiklis > Aparatūra > Jutiklinio kilimėlio haptika_.

### Rašymas kinų, japonų ir kitomis kalbomis

Rinkitės japonų, korėjiečių, kinų (supaprastintą, Pinyin), Taivano (Zhuyin) arba Honkongo (Cangjie), kai diegimo programa paklaus apie jūsų klaviatūrą. Omarchy automatiškai sukonfigūruoja klaviatūrą ir atitinkamą įvesties variklį, įskaitant pirmąjį paleidimą neprisijungus atliekamos sąrankos metu. Japonų kalba naudoja Mozc, korėjiečių kalba naudoja standartinį dviejų rinkinių Hangul, supaprastinta kinų kalba naudoja Pinyin, Taivanas naudoja standartinį Chewing Zhuyin išdėstymą, o Honkongas naudoja Cangjie su Honkongo rašmenų formomis. Japonų (US klaviatūra) suteikia Mozc su US klaviatūros išdėstymu. Hangul, Zhuyin ir Cangjie klavišai lieka standartinėse vietose, net kai lotyniškas raides renkate su Dvorak, Colemak arba AZERTY. Jei Hangul arba Chewing pridėjote anksčiau, panaikinkite jo pasirinkimą ir pasirinkite iš naujo skiltyje _Sąranka > Rašymas > Įvesties metodai_, kad jo klavišai persikeltų ten; Omarchy palieka ramybėje variklį, su kuriuo jau rašote.

Rašymas prasideda lotynišku režimu. Paspauskite `Super + I`, kad pereitumėte per sukonfigūruotus įvesties metodus, ir `Super + Shift + I`, kad pereitumėte atgal. Bakstelėkite vieną `Shift`, kad išeitumėte iš tokio įvesties metodo kaip Pinyin į lotyniškas raides, ir bakstelėkite jį dar kartą, kad grįžtumėte, taip, kaip veikia Sogou, Microsoft Pinyin ir macOS; `Shift` kartu su raide vis tiek įveda didžiąją raidę. Japonų klaviatūrose 全角/半角 perjungia įvestį, 変換 ją įjungia, o 無変換 ją išjungia. Su korėjiečių kalba 한/영 perjungia Hangul, o 한자 konvertuoja į Hanja, nesvarbu, ar jūsų klaviatūra turi specialius klavišus, ar jiems siunčia Right Alt ir Right Ctrl, kaip daro daugelis nešiojamųjų kompiuterių, todėl Right Alt ir Right Ctrl ten nėra paprasti modifikavimo klavišai; vietoj to diktavimas perjungiamas su Alt + Space. `Ctrl + Space` lieka prieinamas Tmux ir Herdr; `Shift + CapsLock` lieka komponavimo klavišu.

Klaviatūros indikatorius atsiranda juostos dešinėje, kai turite kelis klaviatūros išdėstymus arba įvesties metodus. Spustelėkite jį, kad perjungtumėte įvesties kalbas; japonų kalba hiraganai rodo あ. Norėdami pasirinkti japonų rašmenis, perjunkite į japonų kalbą, įveskite tokį žodį kaip `nihongo`, tada dukart paspauskite Space. Paspauskite Enter, kad patvirtintumėte pasirinkimą. Jei taip pat turite kelis klaviatūros išdėstymus, dešiniuoju pelės mygtuku spustelėkite indikatorių, kad pereitumėte per juos.

Naudokite _Sąranka > Rašymas > Klaviatūros išdėstymai_, kad pasirinktumėte tokius išdėstymus kaip anglų ir prancūzų, iš tų pačių pasirinkimų, kurie siūlomi diegimo metu. Naudokite _Sąranka > Rašymas > Įvesties metodai_, kad pasirinktumėte, kurie komponavimo varikliai yra aktyvūs. Abu pasirinkikliai atsidaro Omarchy meniu viduje su pažymėtais dabartiniais jūsų pasirinkimais. Spustelėkite arba paspauskite Enter, kad perjungtumėte pasirinkimą; kiekvienas pakeitimas pritaikomas iš karto. Panaikinus įvesties metodo pasirinkimą, jis pašalinamas iš ciklo jo neišdiegiant; klaviatūra lieka prieinama.

Paleiskite `omarchy setup keyboard` arba `omarchy setup input`, kad atidarytumėte tuos pačius pasirinkiklius. Norėdami iš komandinės eilutės pridėti vieną kalbą, naudokite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` arba `cangjie5`. Quick, Boshiamy ir Array yra tame pačiame pakete kaip Cangjie ir atsiranda Įvesties metodų pasirinkiklyje. Jūsų pasirinktiniai perjungimo klavišai išsaugomi. Jei norite alternatyvių variklio išdėstymų ar klavišų, įdiekite `fcitx5-configtool` su `omarchy pkg add fcitx5-configtool` ir paleiskite jį iš terminalo. Įvesties kalbos pasirinkimas nepakeičia darbalaukio kalbos. Pasirinkus japonų, korėjiečių arba kinų kalbą skiltyje _Sąranka > Kalba_, pridedamas jos įvesties metodas, kai dar neturite nė vieno.

Naudokite `Super + I`, kad pereitumėte per įvesties metodus arba klaviatūros išdėstymus, ir `Super + Shift + I`, kad eitumėte atgal kita kryptimi, todėl turėdami tris sukonfigūruotus galite judėti tarp dviejų kaimyninių. Įvesties indikatorius juostos dešinėje atsiranda tik tada, kai sukonfigūruotas daugiau nei vienas įvesties metodas arba išdėstymas. Šis darbalaukio susiejimas veikia kartu su jūsų esamais Fcitx perjungimo klavišais; galite jį pakeisti faile `~/.config/hypr/bindings.lua`. Įvesties varikliai ir komponavimo sekos naudoja [Fcitx5](https://fcitx-im.org/) paslaugą, jau veikiančią kiekvienoje sesijoje.

### Naudokite ALT kaip SUPER

Kai kuriose klaviatūrose nėra patogu naudoti pagrindinį meta klavišą (Windows/cmd klavišą) kaip SUPER. Galite tai pakeisti, kad vietoj jo būtų ALT, naudodami šį pakeitimą:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
