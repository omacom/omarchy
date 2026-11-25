# Tipkovnica, miš, trackpad

Hyprland vam omogućuje da sve svoje ulaze konfigurirate do najsitnijih detalja. Ponavljanje tipkovnice možete učiniti nadzvučno brzim ili na trackpadu uključiti prirodno pomicanje. Sve to mijenjate u `~/.config/hypr/input.lua`, do čega možete doći i putem _Setup > Input_ u izborniku Omarchy (`Super + Space`). Sve što tamo postavite zamjenjuje zadane postavke sustava Omarchy.

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

Sve mogućnosti za ulaze možete [vidjeti](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wikiju sustava Hyprland posvećenom ulazima.

CapsLock radi kao obični Caps Lock, a `Shift + CapsLock` je tipka za sastavljanje za [brze emojije](07-hotkeys.md#quick-emojis) i [druga dovršavanja](07-hotkeys.md#quick-completions). Ako tipku za sastavljanje radije želite negdje drugdje, zamijenite `omarchy:shift_caps_compose` u `kb_options`. Primjerice, ovime se tipka za sastavljanje premješta na desni Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkcijske tipke

Gornji red tipkovnice na prijenosnom računalu prema zadanim postavkama šalje medijske tipke (glasnoću, svjetlinu i tako dalje), a držanjem tipke `Fn` dobivate F1-F12; `Fn + Esc` to zaključava u obrnutom načinu dok je ponovno ne pritisnete. Većina tipkovnica sama pamti to zaključavanje. Prijenosna računala ASUS i tipkovnice u Appleovu stilu to prepuštaju Linuxu, koji ih pri svakom pokretanju postavlja na medijske tipke. Da bi umjesto toga počinjale s F1-F12, pokrenite `omarchy device keyboard toprow fnkeys` (a za povratak `omarchy device keyboard toprow mediakeys`); na nekim prijenosnim računalima promjena stupa na snagu nakon ponovnog pokretanja. Računala Mac s čipom Apple Silicon zadržavaju vlastitu postavku.

### Geste na trackpadu

Kliznite prstima po trackpadu za kretanje po radnoj površini:

| Gesta | Radnja |
| --- | --- |
| Tri prsta lijevo / desno | Prethodni / sljedeći radni prostor, uključujući prazne |
| Tri prsta gore | Uključivanje/isključivanje AI konzole |
| Tri prsta dolje | Otvaranje izbornika Omarchy |
| Četiri prsta lijevo / desno | Premještanje aktivnog prozora na prethodni / sljedeći radni prostor |
| Četiri prsta dolje | Uključivanje/isključivanje prikaza preko cijelog zaslona |

Da biste jednu promijenili, prvo je poništite u `~/.config/hypr/input.lua`, a zatim dodajte vlastitu [gestu na dodirnoj ploči](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), jer Hyprland neće prihvatiti dvije geste s istim brojem prstiju i istim smjerom:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Da biste isključili sve geste sustava Omarchy, postavite `omarchy_default_gestures = false` pri vrhu datoteke `~/.config/hypr/hyprland.lua`, prije nego što se učitaju zadane postavke sustava Omarchy.

Na prijenosnim računalima Dell XPS s haptičkim trackpadom snagu klika možete postaviti i na nisku, srednju ili visoku pod _Trigger > Hardware > Touchpad Haptics_.

### Tipkanje na kineskom, japanskom i drugim jezicima

Kada vas instalacijski program pita za tipkovnicu, odaberite japanski, korejski, kineski (pojednostavljeni, Pinyin), Tajvan (Zhuyin) ili Hong Kong (Cangjie). Omarchy automatski konfigurira tipkovnicu i odgovarajući mehanizam za unos, uključujući i tijekom izvanmrežnog postavljanja pri prvom pokretanju. Japanski koristi Mozc, korejski koristi standardni dvosložni Hangul, pojednostavljeni kineski koristi Pinyin, Tajvan koristi Chewingov standardni raspored Zhuyin, a Hong Kong koristi Cangjie s hongkonškim oblicima znakova. Japanski (američka tipkovnica) pruža Mozc s američkim rasporedom tipkovnice. Tipke za Hangul, Zhuyin i Cangjie ostaju na svojim standardnim položajima čak i kada latinična slova tipkate s rasporedima Dvorak, Colemak ili AZERTY. Ako ste Hangul ili Chewing dodali prije ovoga, odznačite ih i ponovno odaberite pod _Setup > Keyboard > Input Methods_ kako bi se njihove tipke premjestile tamo; Omarchy mehanizam kojim već tipkate ostavlja na miru.

Tipkanje počinje u latiničnom načinu rada. Pritisnite `Super + I` za kruženje kroz konfigurirane načine unosa, a `Super + Shift + I` za kruženje unatrag. Dodirnite sam `Shift` da biste iz načina unosa poput Pinyina izašli u latinična slova, a dodirnite ga ponovno za povratak, onako kako rade Sogou, Microsoft Pinyin i macOS; `Shift` plus slovo i dalje tipka veliko slovo. Na japanskim tipkovnicama 全角/半角 prebacuje unos, 変換 ga uključuje, a 無変換 ga isključuje. Kod korejskog 한/영 prebacuje Hangul, a 한자 pretvara u Hanja, bez obzira ima li vaša tipkovnica namjenske tipke ili za njih šalje Right Alt i Right Ctrl, kao što to čine mnoga prijenosna računala, pa Right Alt i Right Ctrl tamo nisu obični modifikatori; diktiranje se umjesto toga prebacuje s Alt + Space. `Ctrl + Space` ostaje dostupan za Tmux i Herdr; `Shift + CapsLock` ostaje tipka za sastavljanje.

Pokazatelj tipkovnice pojavljuje se na desnoj strani trake kada imate više rasporeda tipkovnice ili načina unosa. Kliknite ga za prebacivanje jezika unosa; japanski za hiraganu prikazuje あ. Za odabir japanskih znakova prebacite se na japanski, upišite riječ poput `nihongo`, a zatim dvaput pritisnite Space. Pritisnite Enter da biste prihvatili svoj odabir. Ako imate i više rasporeda tipkovnice, desnom tipkom miša kliknite pokazatelj za kruženje kroz njih.

Koristite _Setup > Keyboard > Keyboard Inputs_ za odabir rasporeda poput engleskog i francuskog, među istim izborima koji se nude tijekom instalacije. Koristite _Setup > Keyboard > Input Methods_ za odabir aktivnih mehanizama za sastavljanje. Oba se birača otvaraju unutar izbornika Omarchy s označenim vašim trenutačnim odabirima. Kliknite ili pritisnite Enter za uključivanje ili isključivanje izbora; svaka se promjena primjenjuje odmah. Odznačivanje načina unosa uklanja ga iz ciklusa bez deinstalacije; tipkovnica ostaje dostupna.

Pokrenite `omarchy setup keyboard` ili `omarchy setup input` da biste otvorili iste birače. Da biste iz naredbenog retka dodali jedan jezik, upotrijebite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ili `cangjie5`. Quick, Boshiamy i Array dolaze u istom paketu kao Cangjie i pojavljuju se u biraču Input Methods. Vaše prilagođene tipke za prebacivanje ostaju sačuvane. Za alternativne rasporede ili tipke mehanizama instalirajte `fcitx5-configtool` naredbom `omarchy pkg add fcitx5-configtool` i pokrenite ga iz terminala. Odabir jezika unosa ne mijenja jezik radne površine. Odabirom japanskog, korejskog ili kineskog pod _Setup > Region > Language_ dodaje se njegov način unosa ako ga još nemate.

Koristite `Super + I` za kruženje kroz načine unosa ili rasporede tipkovnice, a `Super + Shift + I` za povratak u drugom smjeru, pa se s tri konfigurirana možete kretati između dvaju susjeda. Pokazatelj unosa pojavljuje se na desnoj strani trake samo kada je konfigurirano više od jednog načina unosa ili rasporeda. Ova poveznica na radnoj površini radi usporedo s vašim postojećim tipkama za prebacivanje u Fcitxu; možete je nadjačati u `~/.config/hypr/bindings.lua`. Mehanizmi za unos i nizovi za sastavljanje koriste uslugu [Fcitx5](https://fcitx-im.org/) koja već radi u svakoj sesiji.

### Korištenje tipke ALT kao SUPER

Na nekim tipkovnicama nije praktično koristiti primarnu metatipku (tipku Windows/cmd) kao SUPER. Umjesto nje možete postaviti ALT ovom promjenom:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
