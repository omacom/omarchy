# Klaviatūra, pelė, jutiklinis kilimėlis

Hyprland leidžia labai detaliai konfigūruoti visus įvesties įrenginius. Galite nustatyti, kad klaviatūra kartotų supersoniniu greičiu, arba padaryti, kad jutiklinis kilimėlis naudotų natūralų slinkimą. Visa tai keičiate faile `~/.config/hypr/input.lua`, kurį taip pat galite pasiekti Omarchy meniu (`Super + Space`) per _Setup > Input_. Viskas, ką ten nustatysite, pakeičia numatytuosius Omarchy nustatymus.

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

Galite [žiūrėti visus įvesties parametrus](https://wiki.hypr.land/Configuring/Basics/Variables/#input) Hyprland wiki puslapyje apie įvestis.

CapsLock veikia kaip įprastas Caps Lock, o `Shift + CapsLock` yra compose klavišas [greitiems jaustukams](07-hotkeys.md#quick-emojis) ir [kitiems greitiesiems užbaigimams](07-hotkeys.md#quick-completions). Jei compose klavišą norėtumėte kitur, pakeiskite `omarchy:shift_caps_compose` elemente `kb_options`. Pavyzdžiui, taip compose klavišas perkeliamas į Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkciniai klavišai

Nešiojamojo kompiuterio klaviatūros viršutinė eilutė pagal numatytuosius nustatymus siunčia medijos klavišus (garsumą, ryškumą ir pan.), o laikant `Fn` gaunami F1-F12; `Fn + Esc` užrakina atvirkščiai, kol vėl jį paspausite. Dauguma klaviatūrų pačios atsimena tą užraktą. ASUS nešiojamieji kompiuteriai ir Apple stiliaus klaviatūros tai palieka Linux, kuri kiekvieną kartą paleidžiant sistemą juos pradeda nuo medijos klavišų. Kad jie vietoj to prasidėtų nuo F1-F12, paleiskite `omarchy device keyboard toprow fnkeys` (o `omarchy device keyboard toprow mediakeys`, kad grįžtumėte atgal); kai kuriuose nešiojamuosiuose kompiuteriuose tai įsigalioja po perkrovimo. Apple Silicon Mac kompiuteriai išlaiko savo nustatymą.

### Jutiklinio kilimėlio gestai

Braukite per jutiklinį kilimėlį, kad judėtumėte darbalaukyje:

| Gestas | Veiksmas |
| --- | --- |
| Trys pirštai į kairę / į dešinę | Ankstesnė / kita darbo sritis, įskaitant tuščias |
| Trys pirštai aukštyn | Perjungti AI konsolę |
| Trys pirštai žemyn | Atidaryti Omarchy meniu |
| Keturi pirštai į kairę / į dešinę | Perkelti aktyvų langą į ankstesnę / kitą darbo sritį |
| Keturi pirštai žemyn | Perjungti viso ekrano režimą |

Norėdami pakeisti vieną, pirmiausia jį išjunkite faile `~/.config/hypr/input.lua` prieš pridėdami savo [jutiklinio kilimėlio gestą](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), nes Hyprland nepriims dviejų gestų su tais pačiais pirštais ir ta pačia kryptimi:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Norėdami išjungti visus Omarchy gestus, nustatykite `omarchy_default_gestures = false` netoli failo `~/.config/hypr/hyprland.lua` viršaus, prieš įkeliant numatytuosius Omarchy nustatymus.

Dell XPS nešiojamuosiuose kompiuteriuose su haptiniu jutikliniu kilimėliu taip pat galite nustatyti paspaudimo stiprumą į low, mid arba high skiltyje _Trigger > Hardware > Touchpad Haptics_.

### Rašymas kinų, japonų ir kitomis kalbomis

Diegimo programai paklausus apie klaviatūrą, pasirinkite japonų, korėjiečių, kinų (supaprastintą, Pinyin), Taivano (Zhuyin) arba Honkongo (Cangjie). Omarchy automatiškai sukonfigūruoja klaviatūrą ir atitinkamą įvesties variklį, įskaitant ir neprisijungus atliekamą pirmojo paleidimo sąranką. Japonų kalba naudoja Mozc, korėjiečių kalba naudoja standartinę dviejų rinkinių Hangul, supaprastinta kinų kalba naudoja Pinyin, Taivanas naudoja standartinį Chewing Zhuyin išdėstymą, o Honkongas naudoja Cangjie su Honkongo rašmenų formomis. Japanese (US keyboard) suteikia Mozc su US klaviatūros išdėstymu. Hangul, Zhuyin ir Cangjie klavišai lieka standartinėse pozicijose, net kai lotyniškas raides rašote su Dvorak, Colemak arba AZERTY. Jei Hangul arba Chewing pridėjote anksčiau, atžymėkite ir vėl pasirinkite jį skiltyje _Setup > Keyboard > Input Methods_, kad jo klavišai būtų perkelti ten; variklio, su kuriuo jau rašote, Omarchy neliečia.

Rašymas prasideda lotynišku režimu. Spauskite `Super + I`, kad pereitumėte per sukonfigūruotus įvesties metodus, o `Super + Shift + I`, kad pereitumėte atgal. Palieskite vieną `Shift`, kad iš įvesties metodo, pavyzdžiui, Pinyin, išeitumėte į lotyniškas raides, ir palieskite jį dar kartą, kad grįžtumėte, taip, kaip veikia Sogou, Microsoft Pinyin ir macOS; `Shift` kartu su raide vis tiek įveda didžiąją raidę. Japonų klaviatūrose 全角/半角 perjungia įvestį, 変換 ją įjungia, o 無変換 ją išjungia. Su korėjiečių kalba 한/영 perjungia Hangul, o 한자 konvertuoja į Hanja, nesvarbu, ar jūsų klaviatūra turi tam skirtus klavišus, ar jiems siunčia Right Alt ir Right Ctrl, kaip daro daugelis nešiojamųjų kompiuterių, todėl Right Alt ir Right Ctrl ten nėra paprasti modifikatoriai; vietoj to diktavimas perjungiamas su Alt + Space. `Ctrl + Space` lieka prieinamas Tmux ir Herdr; `Shift + CapsLock` lieka compose klavišas.

Klaviatūros indikatorius atsiranda juostos dešinėje, kai turite kelis klaviatūros išdėstymus arba įvesties metodus. Spustelėkite jį, kad perjungtumėte įvesties kalbas; japonų kalba hiraganai rodo あ. Japonų rašmenų pasirinkimams perjunkite į japonų kalbą, įveskite žodį, pavyzdžiui, `nihongo`, tada dukart paspauskite Space. Paspauskite Enter, kad patvirtintumėte savo pasirinkimą. Jei taip pat turite kelis klaviatūros išdėstymus, dešiniuoju pelės mygtuku spustelėkite indikatorių, kad juos pereitumėte.

Naudokite _Setup > Keyboard > Keyboard Inputs_, kad pasirinktumėte išdėstymus, pavyzdžiui, English ir French, iš tų pačių pasirinkimų, kurie siūlomi diegimo metu. Naudokite _Setup > Keyboard > Input Methods_, kad pasirinktumėte, kurie komponavimo varikliai yra aktyvūs. Abu parinkikliai atsidaro Omarchy meniu viduje, o jūsų dabartiniai pasirinkimai yra pažymėti. Spustelėkite arba paspauskite Enter, kad perjungtumėte pasirinkimą; kiekvienas pakeitimas pritaikomas iš karto. Atžymėjus įvesties metodą, jis pašalinamas iš ciklo jo nepašalinant iš sistemos; klaviatūra lieka prieinama.

Paleiskite `omarchy setup keyboard` arba `omarchy setup input`, kad atidarytumėte tuos pačius parinkiklius. Norėdami iš komandinės eilutės pridėti vieną kalbą, naudokite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` arba `cangjie5`. Quick, Boshiamy ir Array yra tame pačiame pakete kaip Cangjie ir atsiranda Input Methods parinkiklyje. Jūsų pasirinktiniai perjungimo klavišai išsaugomi. Norėdami naudoti alternatyvius variklių išdėstymus arba klavišus, įdiekite `fcitx5-configtool` su `omarchy pkg add fcitx5-configtool` ir paleiskite jį iš terminalo. Įvesties kalbos pasirinkimas nepakeičia darbalaukio kalbos. Pasirinkus japonų, korėjiečių arba kinų kalbą skiltyje _Setup > Language_, jos įvesties metodas pridedamas, kai dar neturite nė vieno.

Naudokite `Super + I`, kad pereitumėte per įvesties metodus arba klaviatūros išdėstymus, o `Super + Shift + I`, kad grįžtumėte kitu keliu, tad su trimis sukonfigūruotais galite judėti tarp dviejų kaimynų. Įvesties indikatorius juostos dešinėje atsiranda tik tada, kai sukonfigūruotas daugiau nei vienas įvesties metodas arba išdėstymas. Šis darbalaukio susiejimas veikia kartu su jūsų esamais Fcitx perjungimo klavišais; galite jį perrašyti faile `~/.config/hypr/bindings.lua`. Įvesties varikliai ir compose sekos naudoja [Fcitx5](https://fcitx-im.org/) paslaugą, jau veikiančią kiekvienoje sesijoje.

### ALT naudojimas kaip SUPER

Kai kuriose klaviatūrose nėra patogu naudoti pagrindinį meta klavišą (Windows/cmd klavišą) kaip SUPER. Vietoj to galite jį pakeisti į ALT naudodami šį pakeitimą:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
