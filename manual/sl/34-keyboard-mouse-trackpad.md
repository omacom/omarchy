# Tipkovnica, miška, sledilna ploščica

Hyprland vam omogoča, da vse svoje vhode konfigurirate zelo podrobno. Ponovitev tipkovnice lahko nastavite na nadzvočno hitrost ali pa sledilno ploščico nastavite na naravno drsenje. Vse to spremenite v `~/.config/hypr/input.lua`, do katerega lahko dostopate tudi prek _Nastavitve > Vnos_ v meniju Omarchy (`Super + Space`). Vse, kar tam nastavite, nadomesti privzete nastavitve Omarchy.

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

Vse možnosti vnosa si lahko [ogledate](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wikiju Hyprland za vnose.

CapsLock deluje kot običajna tipka Caps Lock, `Shift + CapsLock` pa je tipka za sestavljanje za [hitre emojije](07-hotkeys.md#quick-emojis) in [druga dopolnjevanja](07-hotkeys.md#quick-completions). Če želite tipko za sestavljanje raje drugje, zamenjajte `omarchy:shift_caps_compose` v `kb_options`. Na primer, naslednje tipko za sestavljanje premakne na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkcijske tipke

Zgornja vrsta tipkovnice na prenosniku privzeto pošilja predstavnostne tipke (glasnost, svetlost itd.), ob držanju tipke `Fn` pa dobite F1-F12; `Fn + Esc` to zaklene v obratni smeri, dokler je ne pritisnete znova. Večina tipkovnic si ta zaklep zapomni sama. Prenosniki ASUS in tipkovnice v slogu Apple to prepuščajo Linuxu, ki jih ob vsakem zagonu zažene s predstavnostnimi tipkami. Če želite, da se namesto tega začnejo s F1-F12, zaženite `omarchy device keyboard toprow fnkeys` (in `omarchy device keyboard toprow mediakeys`, če želite nazaj); pri nekaterih prenosnikih to začne veljati po ponovnem zagonu. Računalniki Apple Silicon Mac ohranijo svojo lastno nastavitev.

### Poteze na sledilni ploščici

Podrsajte po sledilni ploščici za premikanje po namizju:

| Poteza | Dejanje |
| --- | --- |
| Trije prsti levo / desno | Prejšnji / naslednji delovni prostor, vključno s praznimi |
| Trije prsti navzgor | Preklop konzole AI |
| Trije prsti navzdol | Odpri meni Omarchy |
| Štirje prsti levo / desno | Premakni aktivno okno na prejšnji / naslednji delovni prostor |
| Štirje prsti navzdol | Preklop celozaslonskega načina |

Če želite eno spremeniti, jo najprej razveljavite v `~/.config/hypr/input.lua`, preden dodate svojo lastno [potezo na sledilni ploščici](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), saj Hyprland ne bo sprejel dveh potez na istih prstih in v isti smeri:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Če želite izklopiti vse poteze Omarchy, nastavite `omarchy_default_gestures = false` blizu vrha `~/.config/hypr/hyprland.lua`, preden se naložijo privzete nastavitve Omarchy.

Pri prenosnikih Dell XPS s haptično sledilno ploščico lahko jakost klika nastavite tudi na nizko, srednjo ali visoko pod _Sprožilec > Strojna oprema > Haptika sledilne ploščice_.

### Tipkanje v kitajščini, japonščini in drugih jezikih

Ko vas namestitveni program vpraša za tipkovnico, izberite japonščino, korejščino, kitajščino (poenostavljeno, Pinyin), Tajvan (Zhuyin) ali Hongkong (Cangjie). Omarchy tipkovnico in ustrezen mehanizem za vnos konfigurira samodejno, tudi med namestitvijo brez povezave ob prvem zagonu. Japonščina uporablja Mozc, korejščina uporablja standardni dvosklopni Hangul, poenostavljena kitajščina uporablja Pinyin, Tajvan uporablja standardno razporeditev Zhuyin sistema Chewing, Hongkong pa uporablja Cangjie z oblikami znakov za Hongkong. Japonščina (tipkovnica US) zagotavlja Mozc z razporeditvijo tipkovnice US. Tipke za Hangul, Zhuyin in Cangjie ostanejo na svojih standardnih položajih, tudi ko latinske črke tipkate z Dvorak, Colemak ali AZERTY. Če ste pred tem dodali Hangul ali Chewing, ga pod _Nastavitve > Tipkovnica > Načini vnosa_ odznačite in znova izberite, da se njegove tipke premaknejo tja; Omarchy mehanizem, s katerim že tipkate, pusti pri miru.

Tipkanje se začne v latinskem načinu. Pritisnite `Super + I` za kroženje med konfiguriranimi načini vnosa in `Super + Shift + I` za kroženje nazaj. Tapnite samo `Shift`, da iz načina vnosa, kot je Pinyin, preklopite na latinske črke, in ga tapnite znova, da se vrnete, tako kot delujejo Sogou, Microsoft Pinyin in macOS; `Shift` skupaj s črko še vedno vpiše veliko črko. Na japonskih tipkovnicah 全角/半角 preklopi vnos, 変換 ga vklopi in 無変換 ga izklopi. Pri korejščini 한/영 preklopi Hangul, 한자 pa pretvori v Hanja, ne glede na to, ali ima vaša tipkovnica namenske tipke ali zanje pošilja Right Alt in Right Ctrl, kot to počnejo številni prenosniki, zato Right Alt in Right Ctrl tam nista navadni modifikacijski tipki; narekovanje se namesto tega preklopi z Alt + Space. `Ctrl + Space` ostane na voljo za Tmux in Herdr; `Shift + CapsLock` ostane tipka za sestavljanje.

Indikator tipkovnice se prikaže na desni strani vrstice, ko imate več razporeditev tipkovnice ali načinov vnosa. Kliknite ga za preklop jezikov vnosa; japonščina prikaže あ za hiragano. Za izbire japonskih znakov preklopite na japonščino, vtipkajte besedo, kot je `nihongo`, nato dvakrat pritisnite Space. Pritisnite Enter, da sprejmete svojo izbiro. Če imate tudi več razporeditev tipkovnice, z desno tipko miške kliknite indikator za kroženje med njimi.

Uporabite _Nastavitve > Tipkovnica > Vnosi tipkovnice_ za izbiro razporeditev, kot sta English in French, med istimi izbirami, ki so na voljo med namestitvijo. Uporabite _Nastavitve > Tipkovnica > Načini vnosa_ za izbiro, kateri mehanizmi za sestavljanje so aktivni. Oba izbirnika se odpreta v meniju Omarchy z označenimi vašimi trenutnimi izbirami. Kliknite ali pritisnite Enter za preklop izbire; vsaka sprememba začne veljati takoj. Odznačitev načina vnosa ga odstrani iz kroženja, ne da bi ga odstranila iz sistema; tipkovnica ostane na voljo.

Zaženite `omarchy setup keyboard` ali `omarchy setup input`, da odprete ista izbirnika. Za dodajanje enega jezika iz ukazne vrstice uporabite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ali `cangjie5`. Quick, Boshiamy in Array so v istem paketu kot Cangjie in se prikažejo v izbirniku Načini vnosa. Vaše tipke za preklapljanje po meri se ohranijo. Za alternativne razporeditve ali tipke mehanizmov namestite `fcitx5-configtool` z `omarchy pkg add fcitx5-configtool` in ga zaženite iz terminala. Izbira jezika vnosa ne spremeni jezika namizja. Izbira japonščine, korejščine ali kitajščine pod _Nastavitve > Jezik_ doda njen način vnosa, ko še nimate nobenega.

Uporabite `Super + I` za kroženje med načini vnosa ali razporeditvami tipkovnice in `Super + Shift + I` za nazaj v drugo smer, tako da se lahko s tremi konfiguriranimi premikate med dvema sosedoma. Indikator vnosa se prikaže na desni strani vrstice le, ko je konfiguriranih več kot en način vnosa ali razporeditev. Ta vezava namizja deluje skupaj z vašimi obstoječimi tipkami za preklapljanje Fcitx; preglasite jo lahko v `~/.config/hypr/bindings.lua`. Mehanizmi za vnos in zaporedja za sestavljanje uporabljajo storitev [Fcitx5](https://fcitx-im.org/), ki že teče v vsaki seji.

### Uporaba ALT kot SUPER

Pri nekaterih tipkovnicah ni priročno uporabljati primarne metatipke (tipke Windows/cmd) kot SUPER. To lahko z naslednjo spremembo spremenite tako, da namesto nje uporabljate ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
