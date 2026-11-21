# Klaviatūra, pelė, jutiklinis kilimėlis

Hyprland leidžia labai detaliai sukonfigūruoti visas įvestis. Galite pakeisti klaviatūros kartojimą, kad jis būtų viršgarsinio greičio, arba nustatyti, kad jutiklinis kilimėlis naudotų natūralų slinkimą. Visa tai keičiate faile `~/.config/hypr/input.lua`, kurį taip pat galite pasiekti per Omarchy meniu _Nustatymai > Įvestis_ (`Super + Space`). Viskas, ką ten nustatote, pakeičia Omarchy numatytuosius nustatymus.

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

Galite [pamatyti visas įvesties parinktis](https://wiki.hypr.land/Configuring/Basics/Variables/#input) Hyprland wiki puslapyje apie įvestis.

CapsLock veikia kaip įprastas Caps Lock, o `Shift + CapsLock` yra komponavimo klavišas, skirtas [greitiesiems jaustukams](07-hotkeys.md#quick-emojis) ir [kitiems užbaigimams](07-hotkeys.md#quick-completions). Jei norėtumėte, kad komponavimo klavišas būtų kitur, `kb_options` elemente pakeiskite `omarchy:shift_caps_compose`. Pavyzdžiui, taip komponavimo klavišas perkeliamas į Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkciniai klavišai

Viršutinė nešiojamojo kompiuterio klaviatūros eilė pagal numatytuosius nustatymus siunčia medijos klavišus (garsumą, ryškumą ir pan.), o laikant `Fn` gaunami F1-F12; `Fn + Esc` užfiksuoja tai atvirkščiai, kol vėl jo nepaspausite. Dauguma klaviatūrų pačios prisimena tą užraktą. ASUS nešiojamieji kompiuteriai ir Apple stiliaus klaviatūros palieka tai Linux, kuri kiekvieno paleidimo metu juos paleidžia su medijos klavišais. Kad vietoj to jie prasidėtų nuo F1-F12, paleiskite `omarchy device keyboard toprow fnkeys` (o norėdami grįžti atgal – `omarchy device keyboard toprow mediakeys`); kai kuriuose nešiojamuosiuose kompiuteriuose tai įsigalioja po perkrovimo. Apple Silicon Mac kompiuteriai išsaugo savo nustatymą.

### Jutiklinio kilimėlio gestai

Braukite jutikliniu kilimėliu, kad judėtumėte darbalaukyje:

| Gestas | Veiksmas |
| --- | --- |
| Trys pirštai į kairę / į dešinę | Ankstesnė / kita darbo sritis, įskaitant tuščias |
| Trys pirštai į viršų | Perjungti AI konsolę |
| Trys pirštai į apačią | Atidaryti Omarchy meniu |
| Keturi pirštai į kairę / į dešinę | Perkelti aktyvų langą į ankstesnę / kitą darbo sritį |
| Keturi pirštai į apačią | Perjungti viso ekrano režimą |

Norėdami pakeisti vieną, prieš pridėdami savo [jutiklinio kilimėlio gestą](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) atšaukite jį faile `~/.config/hypr/input.lua`, nes Hyprland nepriims dviejų gestų su tais pačiais pirštais ir ta pačia kryptimi:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Norėdami išjungti visus Omarchy gestus, nustatykite `omarchy_default_gestures = false` netoli failo `~/.config/hypr/hyprland.lua` viršaus, prieš įkeliant Omarchy numatytuosius nustatymus.

Dell XPS nešiojamuosiuose kompiuteriuose su haptiniu jutikliniu kilimėliu spustelėjimo stiprumą taip pat galite nustatyti į žemą, vidutinį arba aukštą skiltyje _Trigger > Hardware > Touchpad Haptics_.

### Rašymas kinų, japonų ir kitomis kalbomis

Kai diegimo programa paklaus jūsų klaviatūros, pasirinkite japonų, korėjiečių, kinų (supaprastintą, Pinyin), Taivano (Zhuyin) arba Honkongo (Cangjie). Omarchy automatiškai sukonfigūruoja klaviatūrą ir atitinkamą įvesties variklį, taip pat ir neprisijungus atliekamos pirmojo paleidimo sąrankos metu. Japonų kalba naudoja Mozc, korėjiečių – standartinį dviejų rinkinių Hangul, supaprastinta kinų – Pinyin, Taivanas – Chewing standartinį Zhuyin išdėstymą, o Honkongas – Cangjie su Honkongo rašmenų formomis. Japonų (US klaviatūra) suteikia Mozc su US klaviatūros išdėstymu. Hangul, Zhuyin ir Cangjie klavišai lieka savo standartinėse pozicijose, net kai lotyniškas raides renkate su Dvorak, Colemak arba AZERTY. Jei Hangul arba Chewing pridėjote anksčiau, skiltyje _Nustatymai > Klaviatūra > Įvesties metodai_ panaikinkite jų pasirinkimą ir pasirinkite juos iš naujo, kad jų klavišai būtų perkelti ten; Omarchy variklio, kuriuo jau rašote, neliečia.

Rašymas prasideda lotynišku režimu. Paspauskite `Super + I`, kad cikliškai pereitumėte sukonfigūruotus įvesties metodus, ir `Super + Shift + I`, kad cikliškai pereitumėte atgal. Paspauskite vien tik `Shift`, kad išeitumėte iš tokio įvesties metodo kaip Pinyin į lotyniškas raides, ir paspauskite jį dar kartą, kad grįžtumėte – taip, kaip veikia Sogou, Microsoft Pinyin ir macOS; `Shift` kartu su raide vis tiek įveda didžiąją raidę. Japonų klaviatūrose 全角/半角 perjungia įvestį, 変換 ją įjungia, o 無変換 ją išjungia. Naudojant korėjiečių kalbą, 한/영 perjungia Hangul, o 한자 konvertuoja į Hanja, nesvarbu, ar jūsų klaviatūra turi tam skirtus klavišus, ar jiems siunčia Right Alt ir Right Ctrl, kaip daro daugelis nešiojamųjų kompiuterių, todėl Right Alt ir Right Ctrl ten nėra paprasti modifikatoriai; vietoj to diktavimas perjungiamas su Alt + Space. `Ctrl + Space` lieka prieinamas Tmux ir Herdr; `Shift + CapsLock` lieka komponavimo klavišu.

Klaviatūros indikatorius pasirodo dešinėje juostos pusėje, kai turite kelis klaviatūros išdėstymus arba įvesties metodus. Spustelėkite jį, kad perjungtumėte įvesties kalbas; japonų kalba hiraganai rodo あ. Norėdami pasirinkti japonų rašmenis, perjunkite į japonų kalbą, įveskite tokį žodį kaip `nihongo`, tada dukart paspauskite Space. Paspauskite Enter, kad priimtumėte savo pasirinkimą. Jei taip pat turite kelis klaviatūros išdėstymus, dešiniuoju pelės mygtuku spustelėkite indikatorių, kad cikliškai juos pereitumėte.

Naudokite _Nustatymai > Klaviatūra > Klaviatūros įvestys_, kad pasirinktumėte tokius išdėstymus kaip anglų ir prancūzų, iš tų pačių pasirinkimų, kurie siūlomi diegimo metu. Naudokite _Nustatymai > Klaviatūra > Įvesties metodai_, kad pasirinktumėte, kurie komponavimo varikliai yra aktyvūs. Abu parinkikliai atsidaro Omarchy meniu viduje su pažymėtais dabartiniais jūsų pasirinkimais. Spustelėkite arba paspauskite Enter, kad perjungtumėte pasirinkimą; kiekvienas pakeitimas pritaikomas iš karto. Panaikinus įvesties metodo pasirinkimą, jis pašalinamas iš ciklo jo nepašalinant; klaviatūra lieka prieinama.

Paleiskite `omarchy setup keyboard` arba `omarchy setup input`, kad atidarytumėte tuos pačius parinkiklius. Norėdami iš komandinės eilutės pridėti vieną kalbą, naudokite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` arba `cangjie5`. Quick, Boshiamy ir Array yra tame pačiame pakete kaip Cangjie ir pasirodo Įvesties metodų parinkiklyje. Jūsų pasirinktiniai perjungimo klavišai išsaugomi. Norėdami alternatyvių variklio išdėstymų arba klavišų, su `omarchy pkg add fcitx5-configtool` įdiekite `fcitx5-configtool` ir paleiskite jį iš terminalo. Įvesties kalbos pasirinkimas nepakeičia darbalaukio kalbos. Pasirinkus japonų, korėjiečių arba kinų kalbą skiltyje _Nustatymai > Regionas > Kalba_, pridedamas jos įvesties metodas, kai dar neturite nė vieno.

Naudokite `Super + I`, kad cikliškai pereitumėte įvesties metodus arba klaviatūros išdėstymus, ir `Super + Shift + I`, kad grįžtumėte kitu keliu, tad sukonfigūravę tris, galite judėti tarp dviejų kaimyninių. Įvesties indikatorius dešinėje juostos pusėje pasirodo tik tada, kai sukonfigūruotas daugiau nei vienas įvesties metodas arba išdėstymas. Šis darbalaukio susiejimas veikia kartu su jūsų esamais Fcitx perjungimo klavišais; jį galite perrašyti faile `~/.config/hypr/bindings.lua`. Įvesties varikliai ir komponavimo sekos naudoja [Fcitx5](https://fcitx-im.org/) paslaugą, jau veikiančią kiekvienoje sesijoje.

### ALT naudojimas vietoj SUPER

Kai kuriose klaviatūrose nėra patogu naudoti pagrindinį meta klavišą (Windows/cmd klavišą) kaip SUPER. Vietoj to, naudodami šį pakeitimą, galite tai pakeisti į ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
