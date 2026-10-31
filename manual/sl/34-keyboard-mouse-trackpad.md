# Tipkovnica, miška, sledilna ploščica

Hyprland omogoča, da vse svoje vnose konfigurirate zelo podrobno. Ponovitev tipkovnice lahko nastavite na nadzvočno hitrost ali pa za sledilno ploščico uporabite naravno drsenje. Vse to spremenite v `~/.config/hypr/input.lua`, do česar lahko dostopate tudi prek _Nastavitve > Vnos_ v meniju Omarchy (`Super + Space`). Vse, kar tam nastavite, nadomesti privzete nastavitve Omarchy.

Tukaj je primer:

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

Vse možnosti za vnose si lahko [ogledate](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wikiju Hyprland za vnose.

CapsLock deluje kot običajna tipka Caps Lock, `Shift + CapsLock` pa je tipka compose za [hitre emojije](07-hotkeys.md#quick-emojis) in [druga dopolnjevanja](07-hotkeys.md#quick-completions). Če želite tipko compose raje drugje, v `kb_options` nadomestite `omarchy:shift_caps_compose`. Ta primer na primer premakne tipko compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Geste na sledilni ploščici

Podrsajte po sledilni ploščici, da se premikate po namizju:

| Gesta | Dejanje |
| --- | --- |
| Trije prsti levo / desno | Prejšnje / naslednje delovno okolje, vključno s praznimi |
| Trije prsti gor | Preklopi konzolo AI |
| Trije prsti dol | Odpri meni Omarchy |
| Štirje prsti levo / desno | Premakni aktivno okno na prejšnje / naslednje delovno okolje |
| Štirje prsti dol | Preklopi celozaslonski način |

Če želite katero spremeniti, jo v `~/.config/hypr/input.lua` razveljavite, preden dodate svojo [gesto na sledilni ploščici](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), saj Hyprland ne bo sprejel dveh gest z istim številom prstov in v isto smer:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Če želite izklopiti vse geste Omarchy, nastavite `omarchy_default_gestures = false` blizu vrha `~/.config/hypr/hyprland.lua`, preden se naložijo privzete nastavitve Omarchy.

Pri prenosnikih Dell XPS s haptično sledilno ploščico lahko moč klika nastavite tudi na nizko, srednjo ali visoko pod _Sprožilec > Strojna oprema > Haptika sledilne ploščice_.

### Tipkanje v kitajščini, japonščini in drugih jezikih

Ko vas namestitveni program vpraša po tipkovnici, izberite japonščino, korejščino, kitajščino (poenostavljeno, Pinyin), Tajvan (Zhuyin) ali Hongkong (Cangjie). Omarchy samodejno konfigurira tipkovnico in ustrezni vnosni mehanizem, tudi med namestitvijo brez povezave ob prvem zagonu. Japonščina uporablja Mozc, korejščina standardni dvosklopni Hangul, poenostavljena kitajščina uporablja Pinyin, Tajvan uporablja standardno razporeditev Zhuyin v Chewing, Hongkong pa Cangjie s hongkonškimi oblikami znakov. Japonščina (tipkovnica US) zagotavlja Mozc z ameriško razporeditvijo tipkovnice. Tipke Hangul, Zhuyin in Cangjie ostanejo na svojih standardnih mestih, tudi ko latinske črke tipkate z Dvorak, Colemak ali AZERTY. Če ste Hangul ali Chewing dodali že prej, ju pod _Nastavitve > Tipkanje > Načini vnosa_ odznačite in znova izberite, da se njune tipke premaknejo tja; Omarchy pusti mehanizem, s katerim že tipkate, pri miru.

Tipkanje se začne v latinskem načinu. Pritisnite `Super + I` za kroženje med konfiguriranimi načini vnosa in `Super + Shift + I` za kroženje nazaj. Pritisnite samo `Shift`, da iz načina vnosa, kot je Pinyin, preklopite na latinske črke, in jo pritisnite znova, da se vrnete, tako kot delujejo Sogou, Microsoft Pinyin in macOS; `Shift` skupaj s črko še vedno vpiše veliko črko. Na japonskih tipkovnicah 全角/半角 preklaplja vnos, 変換 ga vklopi in 無変換 ga izklopi. Pri korejščini 한/영 preklaplja Hangul, 한자 pa pretvarja v Hanja, ne glede na to, ali ima vaša tipkovnica namenske tipke ali zanje pošilja Right Alt in Right Ctrl, kot to počnejo številni prenosniki, zato Right Alt in Right Ctrl tam nista običajna modifikatorja; funkcija push-to-talk za narekovanje ostane na F9. `Ctrl + Space` ostane na voljo za Tmux in Herdr; `Shift + CapsLock` ostane tipka compose.

Kazalnik tipkovnice se prikaže na desni strani vrstice, ko imate več razporeditev tipkovnice ali načinov vnosa. Kliknite ga, da preklopite jezike vnosa; japonščina za hiragano prikaže あ. Za izbire japonskih znakov preklopite na japonščino, vtipkajte besedo, kot je `nihongo`, nato dvakrat pritisnite Space. Pritisnite Enter, da sprejmete izbiro. Če imate tudi več razporeditev tipkovnice, z desno tipko kliknite kazalnik, da krožite med njimi.

Uporabite _Nastavitve > Tipkanje > Razporeditve tipkovnice_, da izberete razporeditve, kot sta angleščina in francoščina, med istimi izbirami, ki so ponujene med namestitvijo. Uporabite _Nastavitve > Tipkanje > Načini vnosa_, da izberete, kateri mehanizmi za sestavljanje so aktivni. Oba izbirnika se odpreta v meniju Omarchy z označenimi vašimi trenutnimi izbirami. Kliknite ali pritisnite Enter, da preklopite izbiro; vsaka sprememba se uveljavi takoj. Če način vnosa odznačite, ga odstranite iz kroženja, ne da bi ga odstranili iz sistema; tipkovnica ostane na voljo.

Zaženite `omarchy setup keyboard` ali `omarchy setup input`, da odprete ista izbirnika. Če želite iz ukazne vrstice dodati en jezik, uporabite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ali `cangjie5`. Quick, Boshiamy in Array so v istem paketu kot Cangjie in se prikažejo v izbirniku načinov vnosa. Vaše prilagojene tipke za preklapljanje se ohranijo. Za alternativne razporeditve ali tipke mehanizmov namestite `fcitx5-configtool` z `omarchy pkg add fcitx5-configtool` in ga zaženite iz terminala. Izbira jezika vnosa ne spremeni jezika namizja. Če pod _Nastavitve > Jezik_ izberete japonščino, korejščino ali kitajščino, se njen način vnosa doda, ko ga še nimate.

Uporabite `Super + I` za kroženje med načini vnosa ali razporeditvami tipkovnice in `Super + Shift + I` za vrnitev v drugo smer, tako da se lahko pri treh konfiguriranih premikate med dvema sosedoma. Kazalnik vnosa se prikaže na desni strani vrstice le, ko je konfiguriran več kot en način vnosa ali razporeditev. Ta vezava na namizju deluje skupaj z vašimi obstoječimi tipkami za preklapljanje Fcitx; preglasite jo lahko v `~/.config/hypr/bindings.lua`. Vnosni mehanizmi in zaporedja compose uporabljajo storitev [Fcitx5](https://fcitx-im.org/), ki že teče v vsaki seji.

### Uporaba ALT kot SUPER

Pri nekaterih tipkovnicah ni priročno uporabljati primarne meta tipke (tipke Windows/cmd) kot SUPER. Namesto tega lahko to s to spremembo spremenite na ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
