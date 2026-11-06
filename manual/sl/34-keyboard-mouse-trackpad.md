# Tipkovnica, miška, sledilna ploščica

Hyprland vam omogoča, da vse svoje vnose konfigurirate zelo podrobno. Ponavljanje tipkovnice lahko nastavite na nadzvočno hitrost ali pa sledilno ploščico nastavite na naravno pomikanje. Vse to spremenite v `~/.config/hypr/input.lua`, do katere lahko dostopate tudi prek _Setup > Input_ v meniju Omarchy (`Super + Space`). Vse, kar tam nastavite, nadomesti privzete nastavitve Omarchy.

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

Vse možnosti vnosa si lahko [ogledate vse možnosti vnosa](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wikiju Hyprland za vnose.

CapsLock deluje kot običajna tipka Caps Lock, `Shift + CapsLock` pa je tipka za sestavljanje za [hitre emojije](07-hotkeys.md#quick-emojis) in [druga dopolnjevanja](07-hotkeys.md#quick-completions). Če želite tipko za sestavljanje raje drugje, zamenjajte `omarchy:shift_caps_compose` v `kb_options`. Ta primer na primer premakne tipko za sestavljanje na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkcijske tipke

Zgornja vrstica tipkovnice prenosnika privzeto pošilja večpredstavnostne tipke (glasnost, svetlost in tako naprej), držanje tipke `Fn` pa da F1-F12; `Fn + Esc` to zaklene v obratni smeri, dokler je ne pritisnete znova. Večina tipkovnic si ta zaklep zapomni sama. Prenosniki ASUS in tipkovnice v slogu Apple to prepustijo Linuxu, ki jih ob vsakem zagonu zažene na večpredstavnostnih tipkah. Da se namesto tega zaženejo na F1-F12, zaženite `omarchy keyboard toprow fnkeys` (in `omarchy keyboard toprow mediakeys`, da se vrnete nazaj); pri nekaterih prenosnikih to začne veljati po ponovnem zagonu. Računalniki Mac z Apple Silicon ohranijo svojo nastavitev.

### Poteze na sledilni ploščici

Podrsajte po sledilni ploščici za premikanje po namizju:

| Poteza | Dejanje |
| --- | --- |
| Trije prsti levo / desno | Prejšnji / naslednji delovni prostor, vključno s praznimi |
| Trije prsti gor | Preklopi konzolo AI |
| Trije prsti dol | Odpre meni Omarchy |
| Štirje prsti levo / desno | Premakne aktivno okno na prejšnji / naslednji delovni prostor |
| Štirje prsti dol | Preklopi celozaslonski način |

Če želite eno spremeniti, jo najprej prekličite v `~/.config/hypr/input.lua`, preden dodate svojo [potezo na sledilni ploščici](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), saj Hyprland ne bo sprejel dveh potez na istih prstih in v isti smeri:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Če želite izklopiti vse poteze Omarchy, nastavite `omarchy_default_gestures = false` blizu vrha `~/.config/hypr/hyprland.lua`, preden se naložijo privzete nastavitve Omarchy.

Pri prenosnikih Dell XPS s haptično sledilno ploščico lahko pod _Trigger > Hardware > Touchpad Haptics_ nastavite tudi moč klika na nizko, srednjo ali visoko.

### Tipkanje v kitajščini, japonščini in drugih jezikih

Ko vas namestitveni program vpraša za tipkovnico, izberite japonščino, korejščino, kitajščino (poenostavljeno, Pinyin), Tajvan (Zhuyin) ali Hongkong (Cangjie). Omarchy samodejno konfigurira tipkovnico in ustrezni vnosni mehanizem, tudi med namestitvijo ob prvem zagonu brez povezave. Japonščina uporablja Mozc, korejščina uporablja standardni dvonaborni Hangul, poenostavljena kitajščina uporablja Pinyin, Tajvan uporablja standardno razporeditev Zhuyin mehanizma Chewing, Hongkong pa uporablja Cangjie s hongkonškimi oblikami znakov. Japonščina (tipkovnica US) zagotavlja Mozc z razporeditvijo tipkovnice US. Tipke Hangul, Zhuyin in Cangjie ostanejo na svojih standardnih mestih, tudi ko latinične črke tipkate z Dvorak, Colemak ali AZERTY. Če ste Hangul ali Chewing dodali že pred tem, ga pod _Setup > Keyboard > Input Methods_ odznačite in znova izberite, da tja premaknete njegove tipke; Omarchy pusti mehanizem, s katerim že tipkate, pri miru.

Tipkanje se začne v latiničnem načinu. Pritisnite `Super + I` za kroženje med konfiguriranimi načini vnosa in `Super + Shift + I` za kroženje nazaj. Pritisnite `Shift` samo, da iz načina vnosa, kot je Pinyin, preklopite na latinične črke, in jo pritisnite znova, da se vrnete nazaj, tako kot delujejo Sogou, Microsoft Pinyin in macOS; `Shift` skupaj s črko še vedno vtipka veliko črko. Na japonskih tipkovnicah 全角/半角 preklopi vnos, 変換 ga vklopi in 無変換 ga izklopi. Pri korejščini 한/영 preklopi Hangul in 한자 pretvori v Hanja, ne glede na to, ali ima vaša tipkovnica namenski tipki ali zanju pošilja Right Alt in Right Ctrl, kot to počnejo številni prenosniki, zato Right Alt in Right Ctrl tam nista navadna modifikatorja; narekovanje se namesto tega preklopi z Alt + Space. `Ctrl + Space` ostane na voljo za Tmux in Herdr; `Shift + CapsLock` ostane tipka za sestavljanje.

Indikator tipkovnice se prikaže na desni strani vrstice, ko imate več razporeditev tipkovnice ali načinov vnosa. Kliknite ga, da preklopite jezike vnosa; japonščina za hiragano prikaže あ. Za izbiro japonskih znakov preklopite na japonščino, vtipkajte besedo, kot je `nihongo`, nato dvakrat pritisnite Space. Pritisnite Enter, da sprejmete svojo izbiro. Če imate tudi več razporeditev tipkovnice, z desno tipko kliknite indikator, da krožite med njimi.

S pomočjo _Setup > Keyboard > Keyboard Inputs_ izberite razporeditve, kot sta angleščina in francoščina, med istimi izbirami, ki so na voljo med namestitvijo. S pomočjo _Setup > Keyboard > Input Methods_ izberite, kateri mehanizmi za sestavljanje so aktivni. Oba izbirnika se odpreta v meniju Omarchy z označenimi vašimi trenutnimi izbirami. Kliknite ali pritisnite Enter, da preklopite izbiro; vsaka sprememba začne veljati takoj. Odznačitev načina vnosa ga odstrani iz kroženja, ne da bi ga odstranila iz sistema; tipkovnica ostane na voljo.

Zaženite `omarchy setup keyboard` ali `omarchy setup input`, da odprete ista izbirnika. Če želite iz ukazne vrstice dodati en jezik, uporabite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ali `cangjie5`. Quick, Boshiamy in Array so v istem paketu kot Cangjie in se prikažejo v izbirniku Input Methods. Vaše tipke za preklapljanje po meri se ohranijo. Za alternativne razporeditve ali tipke mehanizma namestite `fcitx5-configtool` z `omarchy pkg add fcitx5-configtool` in ga zaženite iz terminala. Izbira jezika vnosa ne spremeni jezika namizja. Izbira japonščine, korejščine ali kitajščine pod _Setup > Language_ doda njen način vnosa, kadar ga še nimate.

Uporabite `Super + I` za kroženje med načini vnosa ali razporeditvami tipkovnice in `Super + Shift + I`, da greste nazaj v drugo smer, tako da se lahko pri treh konfiguriranih premikate med dvema sosedoma. Indikator vnosa se prikaže na desni strani vrstice le, ko je konfiguriran več kot en način vnosa ali razporeditev. Ta vezava namizja deluje skupaj z vašimi obstoječimi tipkami za preklapljanje Fcitx; preglasite jo lahko v `~/.config/hypr/bindings.lua`. Vnosni mehanizmi in zaporedja za sestavljanje uporabljajo storitev [Fcitx5](https://fcitx-im.org/), ki že teče v vsaki seji.

### Uporabite ALT kot SUPER

Pri nekaterih tipkovnicah ni priročno uporabljati primarne metatipke (tipke Windows/cmd) kot SUPER. Namesto tega lahko to spremenite v ALT s to spremembo:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
