# Tipkovnica, miš, dodirna pločica

Hyprland vam omogućuje da sve svoje ulaze podesite do najsitnijih detalja. Ponovni unos na tipkovnici možete ubrzati do nadzvučne brzine ili učiniti da dodirna pločica koristi prirodno pomicanje. Sve to mijenjate u `~/.config/hypr/input.lua`, do čega možete doći i putem _Postavljanje > Unos_ u izborniku Omarchy (`Super + Space`). Sve što tamo postavite zamjenjuje zadane postavke Omarchyja.

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

Sve mogućnosti unosa možete [pogledati](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wikiju Hyprlanda za unose.

CapsLock radi kao obični Caps Lock, a `Shift + CapsLock` je tipka za sastavljanje za [brze emojije](07-hotkeys.md#quick-emojis) i [druga dovršavanja](07-hotkeys.md#quick-completions). Ako biste tipku za sastavljanje radije imali negdje drugdje, zamijenite `omarchy:shift_caps_compose` u `kb_options`. Na primjer, ovime se tipka za sastavljanje premješta na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkcijske tipke

Gornji red tipkovnice prijenosnog računala prema zadanim postavkama šalje medijske tipke (glasnoću, svjetlinu i tako dalje), a držanjem tipke `Fn` dobivate F1-F12; `Fn + Esc` to zaključava u obrnutom redoslijedu dok je ponovno ne pritisnete. Većina tipkovnica sama pamti to zaključavanje. Prijenosna računala ASUS i tipkovnice u Appleovu stilu to prepuštaju Linuxu, koji ih pri svakom pokretanju postavlja na medijske tipke. Da bi umjesto toga počinjale s F1-F12, pokrenite `omarchy device keyboard toprow fnkeys` (a `omarchy device keyboard toprow mediakeys` za povratak); na nekim prijenosnim računalima to stupa na snagu nakon ponovnog pokretanja. Apple Silicon Macovi zadržavaju vlastitu postavku.

### Geste na dodirnoj pločici

Prijeđite prstima po dodirnoj pločici za kretanje po radnoj površini:

| Gesta | Radnja |
| --- | --- |
| Tri prsta ulijevo / udesno | Prethodna / sljedeća radna površina, uključujući prazne |
| Tri prsta prema gore | Uključivanje/isključivanje AI konzole |
| Tri prsta prema dolje | Otvaranje izbornika Omarchy |
| Četiri prsta ulijevo / udesno | Premještanje aktivnog prozora na prethodnu / sljedeću radnu površinu |
| Četiri prsta prema dolje | Uključivanje/isključivanje prikaza preko cijelog zaslona |

Da biste jednu promijenili, prvo je poništite u `~/.config/hypr/input.lua` prije nego što dodate vlastitu [gestu na dodirnoj pločici](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), jer Hyprland neće prihvatiti dvije geste s istim prstima i u istom smjeru:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Da biste isključili sve geste Omarchyja, postavite `omarchy_default_gestures = false` pri vrhu datoteke `~/.config/hypr/hyprland.lua`, prije nego što se učitaju zadane postavke Omarchyja.

Na prijenosnim računalima Dell XPS s haptičkom dodirnom pločicom možete postaviti i jačinu klika na nisku, srednju ili visoku pod _Okidač > Hardver > Haptika dodirne pločice_.

### Tipkanje na kineskom, japanskom i drugim jezicima

Odaberite japanski, korejski, kineski (pojednostavljeni, Pinyin), tajvanski (Zhuyin) ili hongkonški (Cangjie) kada vas instalacijski program pita za tipkovnicu. Omarchy automatski konfigurira tipkovnicu i odgovarajući mehanizam za unos, uključujući tijekom izvanmrežnog postavljanja pri prvom pokretanju. Japanski koristi Mozc, korejski koristi standardni Hangul s dva skupa, pojednostavljeni kineski koristi Pinyin, Tajvan koristi standardni Zhuyin raspored sustava Chewing, a Hong Kong koristi Cangjie s hongkonškim oblicima znakova. Japanski (američka tipkovnica) pruža Mozc s američkim rasporedom tipkovnice. Tipke za Hangul, Zhuyin i Cangjie ostaju na svojim standardnim mjestima čak i kada latinična slova tipkate s rasporedima Dvorak, Colemak ili AZERTY. Ako ste prije ovoga dodali Hangul ili Chewing, poništite njegov odabir i ponovno ga odaberite pod _Postavljanje > Tipkovnica > Načini unosa_ kako biste mu tipke premjestili tamo; Omarchy mehanizam kojim već tipkate ostavlja na miru.

Tipkanje započinje u latiničnom načinu. Pritisnite `Super + I` za kruženje kroz konfigurirane načine unosa, a `Super + Shift + I` za kruženje unatrag. Dodirnite sam `Shift` da biste iz načina unosa poput Pinyina izašli u latinična slova, i dodirnite ga ponovno za povratak, onako kako rade Sogou, Microsoft Pinyin i macOS; `Shift` plus slovo i dalje tipka veliko slovo. Na japanskim tipkovnicama 全角/半角 uključuje i isključuje unos, 変換 ga uključuje, a 無変換 ga isključuje. Kod korejskog 한/영 prebacuje Hangul, a 한자 pretvara u Hanju, bez obzira ima li vaša tipkovnica namjenske tipke ili za njih šalje Right Alt i Right Ctrl, kao što to čine mnoga prijenosna računala, pa Right Alt i Right Ctrl tamo nisu obični modifikatori; diktiranje se umjesto toga uključuje i isključuje s Alt + Space. `Ctrl + Space` ostaje dostupan za Tmux i Herdr; `Shift + CapsLock` ostaje tipka za sastavljanje.

Pokazatelj tipkovnice pojavljuje se na desnoj strani trake kada imate više rasporeda tipkovnice ili načina unosa. Kliknite ga za prebacivanje jezika unosa; japanski za hiraganu prikazuje あ. Za odabir japanskih znakova prebacite se na japanski, utipkajte riječ poput `nihongo`, zatim dvaput pritisnite Space. Pritisnite Enter za prihvaćanje svojeg odabira. Ako imate i više rasporeda tipkovnice, desnom tipkom miša kliknite pokazatelj za kruženje kroz njih.

Koristite _Postavljanje > Tipkovnica > Unosi tipkovnice_ za odabir rasporeda poput engleskog i francuskog, među istim izborima koji se nude tijekom instalacije. Koristite _Postavljanje > Tipkovnica > Načini unosa_ za odabir aktivnih mehanizama za sastavljanje. Oba se birača otvaraju unutar izbornika Omarchy s označenim vašim trenutnim odabirima. Kliknite ili pritisnite Enter za uključivanje ili isključivanje izbora; svaka se promjena primjenjuje odmah. Poništavanjem odabira načina unosa uklanjate ga iz ciklusa bez deinstalacije; tipkovnica ostaje dostupna.

Pokrenite `omarchy setup keyboard` ili `omarchy setup input` da biste otvorili iste birače. Za dodavanje jednog jezika iz naredbenog retka koristite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ili `cangjie5`. Quick, Boshiamy i Array dolaze u istom paketu kao Cangjie i pojavljuju se u biraču Načini unosa. Vaše prilagođene tipke za prebacivanje ostaju sačuvane. Za alternativne rasporede mehanizama ili tipke instalirajte `fcitx5-configtool` naredbom `omarchy pkg add fcitx5-configtool` i pokrenite ga iz terminala. Odabir jezika unosa ne mijenja jezik radne površine. Odabirom japanskog, korejskog ili kineskog pod _Postavljanje > Jezik_ dodaje se njegov način unosa kada ga još nemate.

Koristite `Super + I` za kruženje kroz načine unosa ili rasporede tipkovnice, a `Super + Shift + I` za povratak u drugom smjeru, pa se s tri konfigurirana možete kretati između dva susjeda. Pokazatelj unosa pojavljuje se na desnoj strani trake samo kada je konfigurirano više od jednog načina unosa ili rasporeda. Ovo povezivanje na radnoj površini radi usporedno s vašim postojećim tipkama za prebacivanje Fcitxa; možete ga nadjačati u `~/.config/hypr/bindings.lua`. Mehanizmi za unos i nizovi za sastavljanje koriste uslugu [Fcitx5](https://fcitx-im.org/) koja već radi u svakoj sesiji.

### Korištenje tipke ALT kao SUPER

Na nekim tipkovnicama nije praktično koristiti primarnu meta tipku (tipku Windows/cmd) kao SUPER. Umjesto toga to možete promijeniti u ALT koristeći ovu promjenu:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
