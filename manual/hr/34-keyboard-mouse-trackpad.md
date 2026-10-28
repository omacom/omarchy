# Tipkovnica, miš, trackpad

Hyprland vam omogućuje da sve svoje ulazne uređaje konfigurirate u najsitnije detalje. Možete promijeniti ponavljanje tipkovnice da bude nadzvučno brzo ili postaviti trackpad da koristi prirodno pomicanje. Sve to mijenjate u `~/.config/hypr/input.lua`, do čega možete doći i putem _Setup > Input_ u izborniku Omarchy (`Super + Space`). Sve što tamo postavite zamjenjuje zadane postavke Omarchyja.

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

Možete [vidjeti sve mogućnosti unosa](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na Hyprland wikiju za unose.

CapsLock radi kao obični Caps Lock, a `Shift + CapsLock` je tipka za sastavljanje za [brze emojije](07-hotkeys.md#quick-emojis) i [druga dovršavanja](07-hotkeys.md#quick-completions). Ako biste radije tipku za sastavljanje imali negdje drugdje, zamijenite `omarchy:shift_caps_compose` u `kb_options`. Na primjer, ovo pomiče tipku za sastavljanje na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Geste na trackpadu

Prevucite prstima po trackpadu za kretanje po radnoj površini:

| Gesta | Radnja |
| --- | --- |
| Tri prsta ulijevo / udesno | Prethodni / sljedeći radni prostor, uključujući prazne |
| Tri prsta prema gore | Uključivanje/isključivanje AI konzole |
| Tri prsta prema dolje | Otvaranje izbornika Omarchy |
| Četiri prsta ulijevo / udesno | Premještanje aktivnog prozora na prethodni / sljedeći radni prostor |
| Četiri prsta prema dolje | Uključivanje/isključivanje cijelog zaslona |

Za promjenu jedne, najprije je poništite u `~/.config/hypr/input.lua` prije dodavanja vlastite [geste na trackpadu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), jer Hyprland neće prihvatiti dvije geste na istim prstima i u istom smjeru:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Za isključivanje svih gesti Omarchyja postavite `omarchy_default_gestures = false` pri vrhu `~/.config/hypr/hyprland.lua`, prije nego što se učitaju zadane postavke Omarchyja.

Na prijenosnim računalima Dell XPS s haptičkim trackpadom možete i postaviti snagu klika na nisku, srednju ili visoku pod _Trigger > Hardware > Touchpad Haptics_.

### Tipkanje na kineskom, japanskom i drugim jezicima

Odaberite japanski, korejski, kineski (pojednostavljeni, Pinyin), tajvanski (Zhuyin) ili hongkonški (Cangjie) kada vas instalacijski program pita za tipkovnicu. Omarchy automatski konfigurira tipkovnicu i odgovarajući motor unosa, uključujući tijekom izvanmrežnog postavljanja pri prvom pokretanju. Japanski koristi Mozc, korejski koristi standardni dvosložni Hangul, pojednostavljeni kineski koristi Pinyin, Tajvan koristi standardni Zhuyin raspored Chewinga, a Hong Kong koristi Cangjie s hongkonškim oblicima znakova. Japanski (američka tipkovnica) pruža Mozc s američkim rasporedom tipkovnice. Tipke za Hangul, Zhuyin i Cangjie ostaju na svojim standardnim položajima čak i kada latinična slova upisujete s Dvorakom, Colemakom ili AZERTY-jem. Ako ste prije ovoga dodali Hangul ili Chewing, poništite njegov odabir i ponovno ga odaberite pod _Setup > Typing > Input Methods_ kako biste mu tipke premjestili tamo; Omarchy motor s kojim već tipkate ostavlja na miru.

Tipkanje započinje u latiničnom načinu. Pritisnite `Super + I` za kruženje kroz konfigurirane metode unosa, a `Super + Shift + I` za kruženje unatrag. Dodirnite `Shift` samostalno za izlazak iz metode unosa poput Pinyina u latinična slova i dodirnite ga ponovno za povratak, na način na koji rade Sogou, Microsoft Pinyin i macOS; `Shift` plus slovo i dalje upisuje veliko slovo. Na japanskim tipkovnicama 全角/半角 uključuje/isključuje unos, 変換 ga uključuje, a 無変換 ga isključuje. S korejskim 한/영 prebacuje Hangul, a 한자 pretvara u Hanju, bez obzira ima li vaša tipkovnica namjenske tipke ili za njih šalje Right Alt i Right Ctrl, kao što to čine mnoga prijenosna računala, pa Right Alt i Right Ctrl tamo nisu obični modifikatori; push-to-talk kod diktiranja ostaje na F9. `Ctrl + Space` ostaje dostupan za Tmux i Herdr; `Shift + CapsLock` ostaje tipka za sastavljanje.

Pokazatelj tipkovnice pojavljuje se na desnoj strani trake kada imate više rasporeda tipkovnice ili metoda unosa. Kliknite ga za promjenu jezika unosa; japanski prikazuje あ za hiraganu. Za odabir japanskih znakova prebacite se na japanski, upišite riječ poput `nihongo`, zatim dvaput pritisnite Space. Pritisnite Enter za prihvaćanje odabira. Ako imate i više rasporeda tipkovnice, desnom tipkom miša kliknite pokazatelj za kruženje kroz njih.

Koristite _Setup > Typing > Keyboard Layouts_ za odabir rasporeda poput engleskog i francuskog, među istim izborima koji se nude tijekom instalacije. Koristite _Setup > Typing > Input Methods_ za odabir koji su motori za sastavljanje aktivni. Oba se birača otvaraju unutar izbornika Omarchy s vašim trenutačnim odabirima označenima. Kliknite ili pritisnite Enter za uključivanje/isključivanje izbora; svaka se promjena primjenjuje odmah. Poništavanje odabira metode unosa uklanja je iz ciklusa bez deinstalacije; tipkovnica ostaje dostupna.

Pokrenite `omarchy setup keyboard` ili `omarchy setup input` za otvaranje istih birača. Za dodavanje jednog jezika iz naredbenog retka koristite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ili `cangjie5`. Quick, Boshiamy i Array dolaze u istom paketu kao Cangjie i pojavljuju se u biraču Input Methods. Vaše prilagođene tipke za prebacivanje ostaju sačuvane. Za alternativne rasporede ili tipke motora instalirajte `fcitx5-configtool` naredbom `omarchy pkg add fcitx5-configtool` i pokrenite ga iz terminala. Odabir jezika unosa ne mijenja jezik radne površine. Odabir japanskog, korejskog ili kineskog pod _Setup > Language_ dodaje njegovu metodu unosa kada je još nemate.

Koristite `Super + I` za kruženje kroz metode unosa ili rasporede tipkovnice, a `Super + Shift + I` za povratak u drugom smjeru, pa se s tri konfigurirane možete kretati između dvaju susjeda. Pokazatelj unosa pojavljuje se na desnoj strani trake samo kada je konfigurirano više od jedne metode unosa ili rasporeda. Ova poveznica na radnoj površini radi uz vaše postojeće tipke za prebacivanje u Fcitxu; možete je nadjačati u `~/.config/hypr/bindings.lua`. Motori unosa i sekvence za sastavljanje koriste uslugu [Fcitx5](https://fcitx-im.org/) koja je već pokrenuta u svakoj sesiji.

### Koristite ALT kao SUPER

Na nekim tipkovnicama nije praktično koristiti primarnu meta tipku (tipku Windows/cmd) kao SUPER. To možete promijeniti u ALT pomoću ove promjene:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
