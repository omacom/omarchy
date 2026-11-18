# Tipkovnica, miš, dodirna pločica

Hyprland vam omogućuje da vrlo detaljno konfigurirate sve svoje ulazne uređaje. Ponovljanje tipkovnice možete postaviti na nadzvučnu brzinu ili postaviti dodirnu pločicu da koristi prirodno pomicanje. Sve to mijenjate u `~/.config/hypr/input.lua`, do čega možete doći i putem _Setup > Input_ u izborniku Omarchy (`Super + Space`). Sve što tamo postavite zamjenjuje zadane postavke Omarchyja.

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

Na wikiju Hyprlanda možete [pogledati sve mogućnosti unosa](https://wiki.hypr.land/Configuring/Basics/Variables/#input) za unose.

CapsLock radi kao obični Caps Lock, a `Shift + CapsLock` je tipka compose za [brze emojije](07-hotkeys.md#quick-emojis) i [ostala dovršavanja](07-hotkeys.md#quick-completions). Ako biste radije tipku compose imali negdje drugdje, zamijenite `omarchy:shift_caps_compose` u `kb_options`. Na primjer, ovo pomiče tipku compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkcijske tipke

Gornji red tipkovnice prijenosnog računala prema zadanim postavkama šalje medijske tipke (glasnoća, svjetlina i tako dalje), a držanjem tipke `Fn` dobivate F1-F12; `Fn + Esc` zaključava to u obrnutom načinu dok je ponovno ne pritisnete. Većina tipkovnica sama pamti to zaključavanje. Prijenosna računala ASUS i tipkovnice u Appleovu stilu to prepuštaju Linuxu, koji ih pri svakom pokretanju postavlja na medijske tipke. Da bi umjesto toga kretale od F1-F12, pokrenite `omarchy keyboard toprow fnkeys` (a `omarchy keyboard toprow mediakeys` za povratak); na nekim prijenosnim računalima to stupa na snagu nakon ponovnog pokretanja. Računala Mac s Apple Siliconom zadržavaju vlastitu postavku.

### Geste dodirne pločice

Kliznite po dodirnoj pločici za kretanje po radnoj površini:

| Gesta | Radnja |
| --- | --- |
| Tri prsta lijevo / desno | Prethodna / sljedeća radna površina, uključujući prazne |
| Tri prsta gore | Uključivanje/isključivanje AI konzole |
| Tri prsta dolje | Otvaranje izbornika Omarchy |
| Četiri prsta lijevo / desno | Premještanje aktivnog prozora na prethodnu / sljedeću radnu površinu |
| Četiri prsta dolje | Uključivanje/isključivanje prikaza preko cijelog zaslona |

Da biste promijenili neku gestu, najprije je poništite u `~/.config/hypr/input.lua` prije nego što dodate vlastitu [gestu dodirne pločice](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), jer Hyprland neće prihvatiti dvije geste s istim prstima i istim smjerom:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Da biste isključili sve geste Omarchyja, postavite `omarchy_default_gestures = false` pri vrhu datoteke `~/.config/hypr/hyprland.lua`, prije nego što se učitaju zadane postavke Omarchyja.

Na prijenosnim računalima Dell XPS s haptičkom dodirnom pločicom snagu klika možete postaviti i na nisku, srednju ili visoku pod _Trigger > Hardware > Touchpad Haptics_.

### Tipkanje na kineskom, japanskom i drugim jezicima

Kada vas instalacijski program upita za tipkovnicu, odaberite japanski, korejski, kineski (pojednostavljeni, Pinyin), tajvanski (Zhuyin) ili hongkonški (Cangjie). Omarchy automatski konfigurira tipkovnicu i odgovarajući mehanizam unosa, uključujući tijekom izvanmrežnog postavljanja pri prvom pokretanju. Japanski koristi Mozc, korejski koristi standardni Hangul s dva skupa, pojednostavljeni kineski koristi Pinyin, Tajvan koristi standardni raspored Zhuyin sustava Chewing, a Hong Kong koristi Cangjie s hongkonškim oblicima znakova. Japanski (američka tipkovnica) pruža Mozc s američkim rasporedom tipkovnice. Tipke za Hangul, Zhuyin i Cangjie ostaju na svojim standardnim položajima čak i kada latinična slova tipkate s rasporedima Dvorak, Colemak ili AZERTY. Ako ste Hangul ili Chewing dodali prije ovoga, poništite njegov odabir i ponovno ga odaberite pod _Setup > Keyboard > Input Methods_ da biste mu tipke premjestili tamo; Omarchy mehanizam kojim već tipkate ostavlja na miru.

Tipkanje započinje u latiničnom načinu. Pritisnite `Super + I` za kruženje kroz konfigurirane metode unosa, a `Super + Shift + I` za kruženje unatrag. Dodirnite sam `Shift` da biste iz metode unosa kao što je Pinyin izašli u latinična slova i dodirnite ga ponovno za povratak, onako kako rade Sogou, Microsoft Pinyin i macOS; `Shift` plus slovo i dalje tipka veliko slovo. Na japanskim tipkovnicama 全角/半角 uključuje/isključuje unos, 変換 ga uključuje, a 無変換 ga isključuje. S korejskim 한/영 prebacuje Hangul, a 한자 pretvara u Hanja, bez obzira ima li vaša tipkovnica namjenske tipke ili za njih šalje Right Alt i Right Ctrl, kao što to čine mnoga prijenosna računala, pa Right Alt i Right Ctrl tamo nisu obični modifikatori; diktiranje se umjesto toga prebacuje pomoću Alt + Space. `Ctrl + Space` ostaje dostupan za Tmux i Herdr; `Shift + CapsLock` ostaje tipka compose.

Pokazivač tipkovnice pojavljuje se na desnoj strani trake kada imate više rasporeda tipkovnice ili metoda unosa. Kliknite ga za promjenu jezika unosa; japanski prikazuje あ za hiraganu. Za odabir japanskih znakova prebacite se na japanski, upišite riječ kao što je `nihongo`, zatim dvaput pritisnite Space. Pritisnite Enter za prihvaćanje odabira. Ako imate i više rasporeda tipkovnice, desnom tipkom miša kliknite pokazivač za kruženje kroz njih.

Koristite _Setup > Keyboard > Keyboard Inputs_ za odabir rasporeda kao što su engleski i francuski, među istim izborima koji se nude tijekom instalacije. Koristite _Setup > Keyboard > Input Methods_ za odabir aktivnih mehanizama za sastavljanje teksta. Oba birača otvaraju se unutar izbornika Omarchy s označenim vašim trenutačnim odabirima. Kliknite ili pritisnite Enter za uključivanje/isključivanje izbora; svaka promjena primjenjuje se odmah. Poništavanje odabira metode unosa uklanja je iz ciklusa bez njezina deinstaliranja; tipkovnica ostaje dostupna.

Pokrenite `omarchy setup keyboard` ili `omarchy setup input` da biste otvorili iste birače. Da biste iz naredbenog retka dodali jedan jezik, upotrijebite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ili `cangjie5`. Quick, Boshiamy i Array dolaze u istom paketu kao Cangjie i pojavljuju se u biraču Input Methods. Vaše prilagođene tipke za prebacivanje ostaju sačuvane. Za alternativne rasporede ili tipke mehanizma instalirajte `fcitx5-configtool` pomoću `omarchy pkg add fcitx5-configtool` i pokrenite ga iz terminala. Odabir jezika unosa ne mijenja jezik radne površine. Odabir japanskog, korejskog ili kineskog pod _Setup > Language_ dodaje njegovu metodu unosa kada još nemate nijednu.

Koristite `Super + I` za kruženje kroz metode unosa ili rasporede tipkovnice, a `Super + Shift + I` za povratak u drugom smjeru, pa se s tri konfigurirane metode možete kretati između dviju susjednih. Pokazivač unosa pojavljuje se na desnoj strani trake samo kada je konfigurirano više od jedne metode unosa ili rasporeda. Ova poveznica radne površine radi uz vaše postojeće tipke za prebacivanje Fcitxa; možete je nadjačati u `~/.config/hypr/bindings.lua`. Mehanizmi unosa i sekvence compose koriste uslugu [Fcitx5](https://fcitx-im.org/) koja već radi u svakoj sesiji.

### Korištenje tipke ALT kao SUPER

Na nekim tipkovnicama nije praktično koristiti primarnu metatipku (tipku Windows/cmd) kao SUPER. To umjesto toga možete promijeniti u ALT pomoću ove promjene:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
