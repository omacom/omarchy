# Tipkovnica, miška in sledilna ploščica

Hyprland vam omogoča zelo podrobno konfiguracijo vseh vnosnih naprav. Hitrost ponavljanja tipkovnice lahko nastavite na nadzvočno hitrost ali pa za sledilno ploščico uporabite naravno drsenje. Vse to spremenite v `~/.config/hypr/input.lua`, do česar lahko pridete tudi prek _Nastavitve > Vnos_ v meniju Omarchy (`Super + Space`). Vse, kar tam nastavite, nadomesti privzete nastavitve Omarchy.

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

Vse možnosti vnosa [si lahko ogledate](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wikiju Hyprland za vnose.

CapsLock deluje kot običajna tipka Caps Lock, `Shift + CapsLock` pa je tipka za sestavljanje za [hitre emojije](07-hotkeys.md#quick-emojis) in [druga dopolnjevanja](07-hotkeys.md#quick-completions). Če želite tipko za sestavljanje raje drugje, zamenjajte `omarchy:shift_caps_compose` v `kb_options`. Ta primer na primer premakne tipko za sestavljanje na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Poteze na sledilni ploščici

Vklopite lahko tudi [poteze na sledilni ploščici](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), na primer podrsanje s tremi prsti za preklapljanje med delovnimi prostori:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Na prenosnikih Dell XPS s haptično sledilno ploščico lahko pod _Sprožilec > Strojna oprema > Haptika sledilne ploščice_ nastavite tudi moč klika na nizko, srednjo ali visoko.

### Tipkanje v kitajščini, japonščini in drugih jezikih

Ko vas namestitveni program vpraša po vaši tipkovnici, izberite japonsko, korejsko, kitajsko (poenostavljeno, Pinyin), tajvansko (Zhuyin) ali hongkonško (Cangjie). Omarchy samodejno konfigurira tipkovnico in ustrezni vnosni mehanizem, tudi med namestitvijo brez povezave ob prvem zagonu. Japonščina uporablja Mozc, korejščina standardno dvosklopno postavitev Hangul, poenostavljena kitajščina uporablja Pinyin, Tajvan uporablja standardno postavitev Zhuyin programa Chewing, Hongkong pa uporablja Cangjie s hongkonškimi oblikami znakov. Japanese (US keyboard) ponuja Mozc s postavitvijo tipkovnice US. Tipke Hangul, Zhuyin in Cangjie ostanejo na svojih standardnih položajih, tudi ko latinične črke tipkate z Dvorak, Colemak ali AZERTY. Če ste Hangul ali Chewing dodali že prej, ju pod _Nastavitve > Tipkanje > Metode vnosa_ odznačite in znova izberite, da se njune tipke premaknejo tja; Omarchy pusti mehanizem, s katerim že tipkate, pri miru.

Tipkanje se začne v latiničnem načinu. Pritisnite `Super + I` za kroženje med konfiguriranimi metodami vnosa in `Super + Shift + I` za kroženje nazaj. Enkrat tapnite samo `Shift`, da iz metode vnosa, kot je Pinyin, stopite v latinične črke, in jo tapnite še enkrat, da se vrnete, tako kot delujejo Sogou, Microsoft Pinyin in macOS; `Shift` skupaj s črko še vedno vpiše veliko črko. Na japonskih tipkovnicah 全角/半角 preklopi vnos, 変換 ga vklopi, 無変換 pa ga izklopi. Pri korejščini 한/영 preklaplja Hangul, 한자 pa pretvori v Hanja, ne glede na to, ali ima vaša tipkovnica namenske tipke ali zanje pošilja Right Alt in Right Ctrl, kot to počnejo številni prenosniki, zato Right Alt in Right Ctrl tam nista običajna modifikatorja; narekovanje s pritiskom in govorjenjem ostane na F9. `Ctrl + Space` ostane na voljo za Tmux in Herdr; `Shift + CapsLock` ostane tipka za sestavljanje.

Kazalnik tipkovnice se prikaže na desni strani vrstice, ko imate več postavitev tipkovnice ali metod vnosa. Kliknite ga za preklapljanje med vnosnimi jeziki; japonščina za hiragano prikazuje あ. Za izbiro japonskih znakov preklopite na japonščino, vtipkajte besedo, kot je `nihongo`, nato dvakrat pritisnite Space. Pritisnite Enter, da sprejmete svojo izbiro. Če imate tudi več postavitev tipkovnice, z desno tipko kliknite kazalnik za kroženje med njimi.

Uporabite _Nastavitve > Tipkanje > Postavitve tipkovnice_ za izbiro postavitev, kot sta English in French, med istimi izbirami, ki so na voljo med namestitvijo. Uporabite _Nastavitve > Tipkanje > Metode vnosa_ za izbiro, kateri mehanizmi za sestavljanje so dejavni. Oba izbirnika se odpreta znotraj menija Omarchy z označenimi vašimi trenutnimi izbirami. Kliknite ali pritisnite Enter za preklop izbire; vsaka sprememba začne veljati takoj. Odznačitev metode vnosa jo odstrani iz kroženja, ne da bi jo odstranila iz sistema; tipkovnica ostane na voljo.

Zaženite `omarchy setup keyboard` ali `omarchy setup input`, da odprete ista izbirnika. Za dodajanje enega jezika iz ukazne vrstice uporabite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ali `cangjie5`. Quick, Boshiamy in Array so v istem paketu kot Cangjie in se pojavijo v izbirniku Metode vnosa. Vaše tipke za preklapljanje po meri se ohranijo. Za alternativne postavitve ali tipke mehanizmov namestite `fcitx5-configtool` z `omarchy pkg add fcitx5-configtool` in ga zaženite iz terminala. Izbira vnosnega jezika ne spremeni jezika namizja. Izbira japonščine, korejščine ali kitajščine pod _Nastavitve > Jezik_ doda njeno metodo vnosa, ko je še nimate nobene.

Uporabite `Super + I` za kroženje med metodami vnosa ali postavitvami tipkovnice in `Super + Shift + I` za vrnitev v drugo smer, tako da se lahko pri treh konfiguriranih premikate med dvema sosedoma. Kazalnik vnosa se prikaže na desni strani vrstice le, ko je konfiguriranih več kot ena metoda vnosa ali postavitev. Ta vezava na namizju deluje skupaj z vašimi obstoječimi tipkami za preklapljanje Fcitx; preglasite jo lahko v `~/.config/hypr/bindings.lua`. Vnosni mehanizmi in zaporedja za sestavljanje uporabljajo storitev [Fcitx5](https://fcitx-im.org/), ki že teče v vsaki seji.

### Uporabite ALT kot SUPER

Na nekaterih tipkovnicah ni priročno uporabljati primarne metatipke (tipke Windows/cmd) kot SUPER. S to spremembo jo lahko namesto tega spremenite v ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
