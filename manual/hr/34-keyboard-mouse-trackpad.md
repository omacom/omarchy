# Tipkovnica, miš, trackpad

Hyprland ti omogućuje da sve svoje ulazne uređaje podesiš do najsitnijih detalja. Možeš postaviti ponavljanje tipkovnice da bude nadzvučno brzo ili trackpadu uključiti prirodno pomicanje. Sve to mijenjaš u `~/.config/hypr/input.lua`, do kojeg možeš doći i putem _Setup > Input_ u izborniku Omarchy (`Super + Space`). Sve što tamo postaviš zamjenjuje zadane postavke sustava Omarchy.

Evo primjera:

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

Sve opcije unosa možeš [pogledati](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wikiju sustava Hyprland za unose.

CapsLock radi kao obična tipka Caps Lock, a `Shift + CapsLock` je tipka za sastavljanje za [brze emojije](07-hotkeys.md#quick-emojis) i [ostala dovršavanja](07-hotkeys.md#quick-completions). Ako bi tipku za sastavljanje radije imao drugdje, zamijeni `omarchy:shift_caps_compose` u `kb_options`. Na primjer, ovime se tipka za sastavljanje premješta na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Geste na trackpadu

Prevlači po trackpadu da se krećeš po radnoj površini:

| Gesta | Radnja |
| --- | --- |
| Tri prsta lijevo / desno | Prethodna / sljedeća radna površina, uključujući prazne |
| Tri prsta gore | Uključi/isključi AI konzolu |
| Tri prsta dolje | Otvori izbornik Omarchy |
| Četiri prsta lijevo / desno | Premjesti aktivni prozor na prethodnu / sljedeću radnu površinu |
| Četiri prsta dolje | Uključi/isključi cijeli zaslon |

Da bi promijenio jednu, prvo je deaktiviraj u `~/.config/hypr/input.lua` prije nego što dodaš vlastitu [gestu na trackpadu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), jer Hyprland neće prihvatiti dvije geste za isti broj prstiju i isti smjer:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Da bi isključio sve geste sustava Omarchy, postavi `omarchy_default_gestures = false` pri vrhu datoteke `~/.config/hypr/hyprland.lua`, prije nego što se učitaju zadane postavke sustava Omarchy.

Na prijenosnim računalima Dell XPS s haptičkim trackpadom možeš i postaviti jačinu klika na low, mid ili high pod _Trigger > Hardware > Touchpad Haptics_.

### Tipkanje na kineskom, japanskom i drugim jezicima

Odaberi japanski, korejski, kineski (pojednostavljeni, Pinyin), tajvanski (Zhuyin) ili hongkonški (Cangjie) kada te instalacijski program upita za tipkovnicu. Omarchy automatski konfigurira tipkovnicu i odgovarajući mehanizam za unos, uključujući tijekom izvanmrežnog postavljanja pri prvom pokretanju. Japanski koristi Mozc, korejski koristi standardni dvokomponentni Hangul, pojednostavljeni kineski koristi Pinyin, Tajvan koristi standardni raspored Zhuyin sustava Chewing, a Hong Kong koristi Cangjie s hongkonškim oblicima znakova. Japanski (američka tipkovnica) pruža Mozc s američkim rasporedom tipkovnice. Tipke za Hangul, Zhuyin i Cangjie ostaju na svojim standardnim položajima čak i kada latinična slova tipkaš s rasporedima Dvorak, Colemak ili AZERTY. Ako si prije ovoga dodao Hangul ili Chewing, poništi mu odabir i ponovno ga odaberi pod _Setup > Typing > Input Methods_ da mu tipke premjestiš tamo; Omarchy mehanizam kojim već tipkaš ostavlja na miru.

Tipkanje započinje u latiničnom načinu rada. Pritisni `Super + I` za kruženje kroz konfigurirane metode unosa, a `Super + Shift + I` za kruženje unatrag. Dodirni sam `Shift` da izađeš iz metode unosa poput Pinyina u latinična slova i dodirni ga ponovno da se vratiš, onako kako rade Sogou, Microsoft Pinyin i macOS; `Shift` plus slovo i dalje tipka veliko slovo. Na japanskim tipkovnicama 全角/半角 prebacuje unos, 変換 ga uključuje, a 無変換 ga isključuje. Kod korejskog, 한/영 prebacuje Hangul, a 한자 pretvara u Hanju, bez obzira ima li tvoja tipkovnica namjenske tipke ili za njih šalje Right Alt i Right Ctrl, kao što to čine mnoga prijenosna računala, pa Right Alt i Right Ctrl ondje nisu obični modifikatori; diktiranje se umjesto toga uključuje/isključuje s Alt + Space. `Ctrl + Space` ostaje dostupan za Tmux i Herdr; `Shift + CapsLock` ostaje tipka za sastavljanje.

Pokazatelj tipkovnice pojavljuje se na desnoj strani trake kada imaš više rasporeda tipkovnice ili metoda unosa. Klikni ga da promijeniš jezike unosa; japanski za hiraganu prikazuje あ. Za odabir japanskih znakova prebaci na japanski, upiši riječ poput `nihongo`, zatim dvaput pritisni Space. Pritisni Enter da prihvatiš odabir. Ako imaš i više rasporeda tipkovnice, desnim klikom na pokazatelj kruži kroz njih.

Koristi _Setup > Typing > Keyboard Layouts_ da odabereš rasporede poput engleskog i francuskog, među istim izborima koji se nude tijekom instalacije. Koristi _Setup > Typing > Input Methods_ da odabereš koji su mehanizmi za sastavljanje aktivni. Oba se birača otvaraju unutar izbornika Omarchy s označenim tvojim trenutnim odabirima. Klikni ili pritisni Enter da uključiš/isključiš izbor; svaka se promjena primjenjuje odmah. Poništavanje odabira metode unosa uklanja je iz ciklusa, ali je ne deinstalira; tipkovnica ostaje dostupna.

Pokreni `omarchy setup keyboard` ili `omarchy setup input` da otvoriš iste birače. Da iz naredbenog retka dodaš jedan jezik, koristi `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ili `cangjie5`. Quick, Boshiamy i Array dolaze u istom paketu kao Cangjie i pojavljuju se u biraču Input Methods. Tvoje prilagođene tipke za prebacivanje ostaju sačuvane. Za alternativne rasporede ili tipke mehanizama instaliraj `fcitx5-configtool` pomoću `omarchy pkg add fcitx5-configtool` i pokreni ga iz terminala. Odabir jezika unosa ne mijenja jezik radne površine. Odabir japanskog, korejskog ili kineskog pod _Setup > Language_ dodaje njegovu metodu unosa ako je još nemaš.

Koristi `Super + I` da kružiš kroz metode unosa ili rasporede tipkovnice, a `Super + Shift + I` da ideš natrag u drugom smjeru, pa se s tri konfigurirane metode možeš kretati između dva susjeda. Pokazatelj unosa pojavljuje se na desnoj strani trake samo kada je konfigurirano više od jedne metode unosa ili rasporeda. Ova poveznica za radnu površinu radi uz tvoje postojeće tipke za prebacivanje u Fcitxu; možeš je nadjačati u `~/.config/hypr/bindings.lua`. Mehanizmi za unos i nizovi za sastavljanje koriste uslugu [Fcitx5](https://fcitx-im.org/) koja već radi u svakoj sesiji.

### Koristi ALT kao SUPER

Na nekim tipkovnicama nije praktično koristiti primarnu meta tipku (tipku Windows/cmd) kao SUPER. To možeš promijeniti u ALT pomoću ove promjene:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
