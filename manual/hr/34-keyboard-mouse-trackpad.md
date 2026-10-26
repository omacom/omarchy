# Tipkovnica, miš, dodirna pločica

Hyprland vam omogućuje detaljno konfiguriranje svih unosa. Možete postaviti ponavljanje tipkovnice da bude nadzvučno brzo ili postaviti dodirnu pločicu na prirodno pomicanje. Sve to mijenjate u `~/.config/hypr/input.lua`, do čega možete doći i putem _Setup > Input_ u Omarchy izborniku (`Super + Space`). Sve što tamo postavite zamjenjuje zadane postavke Omarchyja.

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

Možete [vidjeti sve opcije unosa](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na Hyprland wikiju za unose.

CapsLock radi kao obični Caps Lock, a `Shift + CapsLock` je tipka za sastavljanje za [brze emojije](07-hotkeys.md#quick-emojis) i [ostala dovršavanja](07-hotkeys.md#quick-completions). Ako radije želite tipku za sastavljanje negdje drugdje, zamijenite `omarchy:shift_caps_compose` u `kb_options`. Na primjer, ovo pomiče tipku za sastavljanje na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Geste dodirne pločice

Možete uključiti i [geste dodirne pločice](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), kao što je povlačenje s tri prsta za promjenu radnih prostora:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Na prijenosnim računalima Dell XPS s haptičkom dodirnom pločicom možete postaviti i jačinu klika na nisku, srednju ili visoku pod _Trigger > Hardware > Touchpad Haptics_.

### Tipkanje na kineskom, japanskom i drugim jezicima

Odaberite japanski, korejski, kineski (pojednostavljeni, Pinyin), Taiwan (Zhuyin) ili Hong Kong (Cangjie) kada vas instalacijski program pita za tipkovnicu. Omarchy automatski konfigurira tipkovnicu i odgovarajući mehanizam unosa, uključujući tijekom izvanmrežnog prvog pokretanja. Japanski koristi Mozc, korejski koristi standardni dvosložni Hangul, pojednostavljeni kineski koristi Pinyin, Taiwan koristi standardni Chewingov raspored Zhuyin, a Hong Kong koristi Cangjie s hongkonškim oblicima znakova. Japanese (US keyboard) pruža Mozc s US rasporedom tipkovnice. Tipke za Hangul, Zhuyin i Cangjie ostaju na svojim standardnim položajima čak i kada latinična slova tipkate s rasporedima Dvorak, Colemak ili AZERTY. Ako ste prije ovoga dodali Hangul ili Chewing, odznačite ga i ponovno odaberite pod _Setup > Typing > Input Methods_ kako biste mu tipke premjestili tamo; Omarchy ne dira mehanizam kojim već tipkate.

Tipkanje počinje u latiničnom načinu. Pritisnite `Super + I` za kruženje kroz konfigurirane metode unosa, a `Super + Shift + I` za kruženje unatrag. Dodirnite sam `Shift` da biste izašli iz metode unosa kao što je Pinyin na latinična slova i dodirnite ga ponovno za povratak, na način na koji rade Sogou, Microsoft Pinyin i macOS; `Shift` plus slovo i dalje tipka veliko slovo. Na japanskim tipkovnicama 全角/半角 prebacuje unos, 変換 ga uključuje, a 無変換 ga isključuje. Kod korejskog 한/영 prebacuje Hangul, a 한자 pretvara u Hanja, bez obzira ima li vaša tipkovnica namjenske tipke ili za njih šalje Right Alt i Right Ctrl, kao što to rade mnoga prijenosna računala, pa Right Alt i Right Ctrl tamo nisu obični modifikatori; diktiranje pritiskom za govor ostaje na F9. `Ctrl + Space` ostaje dostupan za Tmux i Herdr; `Shift + CapsLock` ostaje tipka za sastavljanje.

Pokazatelj tipkovnice pojavljuje se na desnoj strani trake kada imate više rasporeda tipkovnice ili metoda unosa. Kliknite ga za promjenu jezika unosa; japanski prikazuje あ za hiraganu. Za odabir japanskih znakova prebacite se na japanski, utipkajte riječ kao što je `nihongo`, zatim dvaput pritisnite Space. Pritisnite Enter za prihvaćanje odabira. Ako također imate više rasporeda tipkovnice, desnom tipkom miša kliknite pokazatelj za kruženje kroz njih.

Koristite _Setup > Typing > Keyboard Layouts_ za odabir rasporeda kao što su English i French, među istim odabirima ponuđenima tijekom instalacije. Koristite _Setup > Typing > Input Methods_ za odabir aktivnih mehanizama za sastavljanje. Oba se birača otvaraju unutar Omarchy izbornika s označenim vašim trenutačnim odabirima. Kliknite ili pritisnite Enter za uključivanje ili isključivanje odabira; svaka se promjena odmah primjenjuje. Odznačivanje metode unosa uklanja je iz ciklusa bez deinstaliranja; tipkovnica ostaje dostupna.

Pokrenite `omarchy setup keyboard` ili `omarchy setup input` za otvaranje istih birača. Za dodavanje jednog jezika iz naredbenog retka koristite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ili `cangjie5`. Quick, Boshiamy i Array dolaze u istom paketu kao Cangjie i pojavljuju se u biraču Input Methods. Vaše prilagođene tipke za prebacivanje zadržavaju se. Za alternativne rasporede ili tipke mehanizama instalirajte `fcitx5-configtool` pomoću `omarchy pkg add fcitx5-configtool` i pokrenite ga iz terminala. Odabir jezika unosa ne mijenja jezik radne površine. Odabir japanskog, korejskog ili kineskog pod _Setup > Language_ dodaje njegovu metodu unosa kada je još nemate.

Koristite `Super + I` za kruženje kroz metode unosa ili rasporede tipkovnice, a `Super + Shift + I` za povratak u drugom smjeru, pa se s tri konfigurirana možete kretati između dvaju susjeda. Pokazatelj unosa pojavljuje se na desnoj strani trake samo kada je konfigurirano više od jedne metode unosa ili rasporeda. Ova poveznica radne površine radi zajedno s vašim postojećim tipkama za prebacivanje Fcitxa; možete je nadjačati u `~/.config/hypr/bindings.lua`. Mehanizmi unosa i sekvence sastavljanja koriste uslugu [Fcitx5](https://fcitx-im.org/) koja već radi u svakoj sesiji.

### Korištenje tipke ALT kao SUPER

Na nekim tipkovnicama nije praktično koristiti primarnu meta tipku (tipku Windows/cmd) kao SUPER. Umjesto toga to možete promijeniti na ALT pomoću ove promjene:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
