# Tipkovnica, miška, sledilna ploščica

Hyprland vam omogoča podrobno konfiguriranje vseh vhodnih naprav. Ponavljanje tipkovnice lahko nastavite na nadzvočno hitrost ali na sledilni ploščici uporabite naravno drsenje. Vse to spremenite v `~/.config/hypr/input.lua`, do katere lahko dostopate tudi prek _Setup > Input_ v meniju Omarchy (`Super + Space`). Kar koli tam nastavite, nadomesti privzete nastavitve Omarchyja.

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

CapsLock deluje kot običajna tipka Caps Lock, `Shift + CapsLock` pa je tipka compose za [hitre emojije](07-hotkeys.md#quick-emojis) in [druga dopolnjevanja](07-hotkeys.md#quick-completions). Če želite tipko compose raje drugje, zamenjajte `omarchy:shift_caps_compose` v `kb_options`. Ta primer na primer premakne tipko compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkcijske tipke

Zgornja vrsta prenosnikove tipkovnice privzeto pošilja predstavnostne tipke (glasnost, svetlost itd.), s pridržanim `Fn` pa dobite F1-F12; `Fn + Esc` to zaklene v obratni smeri, dokler ga znova ne pritisnete. Večina tipkovnic si ta zaklep zapomni sama. Prenosniki ASUS in tipkovnice v slogu Apple to prepustijo Linuxu, ki jih ob vsakem zagonu zažene na predstavnostnih tipkah. Če želite, da se namesto tega začnejo na F1-F12, zaženite `omarchy device keyboard toprow fnkeys` (in `omarchy device keyboard toprow mediakeys` za vrnitev); pri nekaterih prenosnikih začne veljati po ponovnem zagonu. Maci z Apple Silicon ohranijo svojo nastavitev.

### Poteze na sledilni ploščici

Podrsajte po sledilni ploščici za premikanje po namizju:

| Poteza | Dejanje |
| --- | --- |
| Trije prsti levo / desno | Prejšnji / naslednji delovni prostor, vključno s praznimi |
| Trije prsti navzgor | Preklopi konzolo AI |
| Trije prsti navzdol | Odpri meni Omarchy |
| Štiri prsti levo / desno | Premakni aktivno okno na prejšnji / naslednji delovni prostor |
| Štiri prsti navzdol | Preklopi celozaslonski način |

Če želite eno spremeniti, jo v `~/.config/hypr/input.lua` najprej prekličite, preden dodate svojo [potezo na sledilni ploščici](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), saj Hyprland ne sprejme dveh potez z istimi prsti in v isti smeri:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Če želite izklopiti vse poteze Omarchyja, nastavite `omarchy_default_gestures = false` blizu vrha `~/.config/hypr/hyprland.lua`, preden se naložijo privzete nastavitve Omarchyja.

Pri prenosnikih Dell XPS s haptično sledilno ploščico lahko pod _Trigger > Hardware > Touchpad Haptics_ nastavite tudi moč klika na nizko, srednjo ali visoko.

### Tipkanje v kitajščini, japonščini in drugih jezikih

Ko vas namestitveni program vpraša po tipkovnici, izberite japonščino, korejščino, kitajščino (poenostavljeno, Pinyin), Tajvan (Zhuyin) ali Hongkong (Cangjie). Omarchy samodejno konfigurira tipkovnico in ustrezen vnosni mehanizem, tudi med namestitvijo brez povezave ob prvem zagonu. Japonščina uporablja Mozc, korejščina uporablja standardni dvosklopni Hangul, poenostavljena kitajščina uporablja Pinyin, Tajvan uporablja standardno razporeditev Zhuyin v Chewing, Hongkong pa uporablja Cangjie s hongkonškimi oblikami znakov. Japonščina (tipkovnica US) zagotavlja Mozc z razporeditvijo tipkovnice US. Tipke Hangul, Zhuyin in Cangjie ostanejo na svojih standardnih mestih, tudi ko latinske črke tipkate z Dvorak, Colemak ali AZERTY. Če ste pred tem dodali Hangul ali Chewing, ju pod _Setup > Keyboard > Input Methods_ odznačite in znova izberite, da se njune tipke premaknejo tja; Omarchy pusti mehanizem, s katerim že tipkate, pri miru.

Tipkanje se začne v latinskem načinu. Pritisnite `Super + I` za kroženje med konfiguriranimi vnosnimi metodami in `Super + Shift + I` za kroženje nazaj. Samostojno tapnite `Shift`, da iz vnosne metode, kot je Pinyin, izstopite v latinske črke, in ga znova tapnite za vrnitev, tako kot delujejo Sogou, Microsoft Pinyin in macOS; `Shift` skupaj s črko še vedno vtipka veliko črko. Na japonskih tipkovnicah 全角/半角 preklaplja vnos, 変換 ga vklopi, 無変換 pa ga izklopi. Pri korejščini 한/영 preklaplja Hangul, 한자 pa pretvarja v Hanja, ne glede na to, ali ima vaša tipkovnica namenske tipke ali zanje pošilja Right Alt in Right Ctrl, kot to počnejo številni prenosniki, zato Right Alt in Right Ctrl tam nista navadna modifikatorja; narekovanje se namesto tega preklaplja z Alt + Space. `Ctrl + Space` ostane na voljo za Tmux in Herdr; `Shift + CapsLock` ostane tipka compose.

Indikator tipkovnice se prikaže na desni strani vrstice, ko imate več razporeditev tipkovnice ali vnosnih metod. Kliknite ga za preklop vnosnih jezikov; japonščina za hiragano prikaže あ. Za izbiro japonskih znakov preklopite na japonščino, vtipkajte besedo, kot je `nihongo`, nato dvakrat pritisnite Space. Pritisnite Enter za potrditev izbire. Če imate tudi več razporeditev tipkovnice, z desno tipko kliknite indikator za kroženje med njimi.

Z _Setup > Keyboard > Keyboard Inputs_ izberite razporeditve, kot sta angleščina in francoščina, med istimi izbirami, ki so na voljo med namestitvijo. Z _Setup > Keyboard > Input Methods_ izberite, kateri mehanizmi za sestavljanje so aktivni. Oba izbirnika se odpreta v meniju Omarchy z označenimi trenutnimi izbirami. Kliknite ali pritisnite Enter za preklop izbire; vsaka sprememba začne veljati takoj. Če vnosno metodo odznačite, jo odstranite iz kroženja, ne da bi jo odstranili iz sistema; tipkovnica ostane na voljo.

Zaženite `omarchy setup keyboard` ali `omarchy setup input`, da odprete ista izbirnika. Če želite iz ukazne vrstice dodati en jezik, uporabite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ali `cangjie5`. Quick, Boshiamy in Array so v istem paketu kot Cangjie in se prikažejo v izbirniku Input Methods. Vaše prilagojene tipke za preklapljanje se ohranijo. Za alternativne razporeditve ali tipke mehanizmov namestite `fcitx5-configtool` z `omarchy pkg add fcitx5-configtool` in ga zaženite iz terminala. Izbira vnosnega jezika ne spremeni jezika namizja. Če pod _Setup > Region > Language_ izberete japonščino, korejščino ali kitajščino, to doda njeno vnosno metodo, kadar je še nimate.

Uporabite `Super + I` za kroženje med vnosnimi metodami ali razporeditvami tipkovnice in `Super + Shift + I` za pot v drugo smer, tako da se lahko pri treh konfiguriranih premikate med dvema sosedoma. Indikator vnosa se na desni strani vrstice prikaže le, kadar je konfigurirana več kot ena vnosna metoda ali razporeditev. Ta bližnjica na namizju deluje skupaj z vašimi obstoječimi tipkami za preklapljanje Fcitx; prepišete jo lahko v `~/.config/hypr/bindings.lua`. Vnosni mehanizmi in zaporedja compose uporabljajo storitev [Fcitx5](https://fcitx-im.org/), ki že teče v vsaki seji.

### Uporaba ALT kot SUPER

Pri nekaterih tipkovnicah ni priročno uporabljati primarne metatipke (tipke Windows/cmd) kot SUPER. Namesto tega jo lahko s to spremembo zamenjate za ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
