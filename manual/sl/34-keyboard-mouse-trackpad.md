# Tipkovnica, miška, sledilna ploščica

Hyprland vam omogoča, da vse svoje vhode podrobno konfigurirate. Hitrost ponavljanja tipkovnice lahko nastavite na nadzvočno hitrost ali pa za sledilno ploščico uporabite naravno drsenje. Vse to spremenite v `~/.config/hypr/input.lua`, do katerega lahko dostopate tudi prek _Setup > Input_ v meniju Omarchy (`Super + Space`). Vse, kar tam nastavite, zamenja privzete nastavitve Omarchy.

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

Na wikiju Hyprland za vhode si lahko [ogledate vse možnosti vnosa](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock deluje kot običajna tipka Caps Lock, `Shift + CapsLock` pa je tipka za sestavljanje za [hitre emojije](07-hotkeys.md#quick-emojis) in [druga dopolnjevanja](07-hotkeys.md#quick-completions). Če želite tipko za sestavljanje raje drugje, zamenjajte `omarchy:shift_caps_compose` v `kb_options`. Ta primer na primer premakne tipko za sestavljanje na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Poteze na sledilni ploščici

Podrsajte po sledilni ploščici za premikanje po namizju:

| Poteza | Dejanje |
| --- | --- |
| Trije prsti levo / desno | Prejšnji / naslednji delovni prostor, vključno s praznimi |
| Trije prsti gor | Preklopi konzolo AI |
| Trije prsti dol | Odpri meni Omarchy |
| Štirje prsti levo / desno | Premakni aktivno okno na prejšnji / naslednji delovni prostor |
| Štirje prsti dol | Preklopi celozaslonski način |

Če želite eno spremeniti, jo razveljavite v `~/.config/hypr/input.lua`, preden dodate svojo [potezo na sledilni ploščici](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), saj Hyprland ne bo sprejel dveh potez z istima prstoma in v isti smeri:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Če želite izklopiti vse poteze Omarchy, nastavite `omarchy_default_gestures = false` blizu vrha `~/.config/hypr/hyprland.lua`, preden se naložijo privzete nastavitve Omarchy.

Pri prenosnikih Dell XPS s haptično sledilno ploščico lahko nastavite tudi moč klika na nizko, srednjo ali visoko pod _Trigger > Hardware > Touchpad Haptics_.

### Tipkanje v kitajščini, japonščini in drugih jezikih

Izberite japonščino, korejščino, kitajščino (poenostavljeno, Pinyin), Tajvan (Zhuyin) ali Hong Kong (Cangjie), ko vas namestitveni program vpraša za tipkovnico. Omarchy tipkovnico in ustrezen vnosni mehanizem konfigurira samodejno, tudi med namestitvijo ob prvem zagonu brez povezave. Japonščina uporablja Mozc, korejščina standardni dvosklopni Hangul, poenostavljena kitajščina Pinyin, Tajvan standardno razporeditev Zhuyin mehanizma Chewing, Hong Kong pa Cangjie z oblikami znakov za Hong Kong. Japonščina (tipkovnica US) ponuja Mozc z razporeditvijo tipkovnice US. Tipke Hangul, Zhuyin in Cangjie ostanejo na svojih standardnih mestih, tudi ko latinske črke tipkate z Dvorak, Colemak ali AZERTY. Če ste Hangul ali Chewing dodali pred tem, ga počistite in znova izberite pod _Setup > Typing > Input Methods_, da se njegove tipke premaknejo tja; Omarchy pusti mehanizem, s katerim že tipkate, pri miru.

Tipkanje se začne v latinskem načinu. Pritisnite `Super + I` za kroženje med konfiguriranimi vnosnimi metodami in `Super + Shift + I` za kroženje nazaj. Tapnite samo `Shift`, da iz vnosne metode, kot je Pinyin, preklopite na latinske črke, in jo tapnite znova za vrnitev, tako kot delujejo Sogou, Microsoft Pinyin in macOS; `Shift` skupaj s črko še vedno vtipka veliko črko. Na japonskih tipkovnicah 全角/半角 preklopi vnos, 変換 ga vklopi in 無変換 ga izklopi. Pri korejščini 한/영 preklopi Hangul in 한자 pretvori v Hanja, ne glede na to, ali ima vaša tipkovnica namenski tipki ali zanje pošilja Right Alt in Right Ctrl, kot to počnejo številni prenosniki, zato Right Alt in Right Ctrl tam nista navadna modifikatorja; narekovanje namesto tega preklopite z Alt + Space. `Ctrl + Space` ostane na voljo za Tmux in Herdr; `Shift + CapsLock` ostane tipka za sestavljanje.

Kazalnik tipkovnice se prikaže na desni strani vrstice, ko imate več razporeditev tipkovnice ali vnosnih metod. Kliknite ga za preklop vnosnih jezikov; japonščina prikaže あ za hiragano. Za izbire japonskih znakov preklopite na japonščino, vtipkajte besedo, kot je `nihongo`, nato dvakrat pritisnite Space. Pritisnite Enter za potrditev svoje izbire. Če imate tudi več razporeditev tipkovnice, z desnim klikom na kazalnik krožite med njimi.

Uporabite _Setup > Typing > Keyboard Layouts_ za izbiro razporeditev, kot sta English in French, med istimi izbirami, ki so na voljo med namestitvijo. Uporabite _Setup > Typing > Input Methods_ za izbiro, kateri mehanizmi za sestavljanje so aktivni. Oba izbirnika se odpreta v meniju Omarchy, vaše trenutne izbire pa so označene. Kliknite ali pritisnite Enter za preklop izbire; vsaka sprememba začne veljati takoj. Odstranitev izbire vnosne metode jo odstrani iz cikla, ne da bi jo odstranili iz sistema; tipkovnica ostane na voljo.

Poženite `omarchy setup keyboard` ali `omarchy setup input`, da odprete ista izbirnika. Za dodajanje enega jezika iz ukazne vrstice uporabite `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` ali `cangjie5`. Quick, Boshiamy in Array so v istem paketu kot Cangjie in se prikažejo v izbirniku Input Methods. Vaše tipke za preklop po meri se ohranijo. Za alternativne razporeditve ali tipke mehanizmov namestite `fcitx5-configtool` z `omarchy pkg add fcitx5-configtool` in ga zaženite iz terminala. Izbira vnosnega jezika ne spremeni jezika namizja. Izbira japonščine, korejščine ali kitajščine pod _Setup > Language_ doda njeno vnosno metodo, ko je še nimate nobene.

Uporabite `Super + I` za kroženje med vnosnimi metodami ali razporeditvami tipkovnice in `Super + Shift + I` za vrnitev v drugo smer, tako da se lahko pri treh konfiguriranih premikate med dvema sosedoma. Kazalnik vnosa se na desni strani vrstice prikaže le, ko je konfiguriranih več kot ena vnosna metoda ali razporeditev. Ta vezava na namizju deluje skupaj z vašimi obstoječimi tipkami za preklop Fcitx; prepišete jo lahko v `~/.config/hypr/bindings.lua`. Vnosni mehanizmi in zaporedja za sestavljanje uporabljajo storitev [Fcitx5](https://fcitx-im.org/), ki že teče v vsaki seji.

### Uporaba ALT kot SUPER

Na nekaterih tipkovnicah ni priročno uporabljati primarne tipke meta (tipke Windows/cmd) kot SUPER. To lahko spremenite, da namesto nje uporabite ALT, s to spremembo:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
