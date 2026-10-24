# Tipkovnica, miška, sledilna ploščica

Hyprland omogoča izredno podrobno konfiguracijo vseh vhodov. Ponavljanje tipkovnice lahko nastavite na nadzvočno hitrost ali sledilni ploščici nastavite naravno drsenje. Vse spreminjate v `~/.config/hypr/input.lua`, ki ga dosežete tudi prek _Nastavitve > Vnos_ v meniju Omarchy (`Super + Space`). Kar koli nastavite tam, nadomesti privzete vrednosti Omarchy.

Tu je primer:

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

Vse [možnosti vnosa](https://wiki.hypr.land/Configuring/Basics/Variables/#input) si lahko ogledate na wiki strani Hyprland za vnose.

CapsLock deluje kot običajen Caps Lock, `Shift + CapsLock` pa je sestavna tipka za [hitre emojije](07-hotkeys.md#quick-emojis) in [druga dopolnjevanja](07-hotkeys.md#quick-completions). Če želite sestavno tipko drugje, zamenjajte `omarchy:shift_caps_compose` v `kb_options`. Na primer, to premakne sestavno tipko na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gibi sledilne ploščice

Vklopite lahko tudi [gibe sledilne ploščice](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), kot je drs s tremi prsti za spreminjanje delovnih prostorov:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Na prenosnikih Dell XPS s haptično sledilno ploščico lahko moč klika nastavite na nizko, srednjo ali visoko pod _Sproži > Strojna oprema > Haptičnost ploščice_.

### Tipkanje v kitajščini, japonščini in drugih jezikih

Ko namestitveni program vpraša po tipkovnici, izberite japonščino, korejščino, kitajščino (poenostavljeno, Pinyin) ali kitajščino (tradicionalno, Zhuyin). Omarchy samodejno konfigurira tipkovnico in ustrezni vnosni pogon, tudi med namestitvijo ob prvem zagonu brez povezave. Japonščina uporablja Mozc, korejščina standardni dvonaborni Hangul, poenostavljena kitajščina Pinyin ter tradicionalna kitajščina standardno razporeditev Zhuyin programa Chewing. Japonščina (tipkovnica ZDA) ponuja Mozc z ameriško razporeditvijo tipkovnice.

Tipkanje se začne v latiničnem načinu. Pritisnite `Super + I` za kroženje skozi konfigurirane metode vnosa in `Super + Shift + I` za kroženje nazaj. Tapnite samo `Shift`, da iz metode vnosa, kot je Pinyin, stopite v latinične črke, in znova tapnite za vrnitev, enako kot delujejo Sogou, Microsoft Pinyin in macOS; `Shift` in črka še vedno vneseta veliko črko. Na japonskih tipkovnicah 全角/半角 preklaplja vnos, 変換 ga vklopi in 無変換 izklopi. Na korejski razporeditvi tipkovnice namenske tipke 한/영 in 한자 preklopijo Hangul in pretvorijo v Hanja. `Ctrl + Space` ostane na voljo za Tmux in Herdr; `Shift + CapsLock` ostane sestavna tipka.

Indikator tipkovnice se pojavi na desni strani vrstice, ko imate več razporeditev tipkovnice ali metod vnosa. Kliknite ga za zamenjavo vnosnih jezikov; japonščina prikazuje あ za hiragano. Za izbiro japonskih znakov preklopite na japonščino, vnesite besedo, kot je `nihongo`, nato dvakrat pritisnite Space. Pritisnite Enter, da sprejmete izbiro. Če imate tudi več razporeditev tipkovnice, indikator kliknite z desno tipko za kroženje med njimi.

Uporabite _Nastavitve > Tipkanje > Razporeditve tipkovnic_ za izbiro razporeditev, kot sta angleščina in francoščina, iz enakih izbir, ponujenih med namestitvijo. Uporabite _Nastavitve > Tipkanje > Načini vnosa_ za izbiro, kateri sestavni pogoni so aktivni. Oba izbirnika se odpreta znotraj menija Omarchy s kljukicami pri trenutnih izbirah. Kliknite ali pritisnite Enter za preklop izbire; vsaka sprememba se uporabi takoj. Izbira metode vnosa jo odstrani iz cikla, ne da bi jo odstranila; tipkovnica ostane na voljo.

Zaženite `omarchy setup keyboard` ali `omarchy setup input`, da odprete ista izbirnika. Če želite en jezik pripeti iz ukazne vrstice, uporabite `omarchy setup input mozc`, `hangul`, `pinyin` ali `chewing`. Preklopne tipke po meri se ohranijo. Za alternativne razporeditve ali tipke pogona namestite `fcitx5-configtool` z `omarchy pkg add fcitx5-configtool` in ga zaženite iz terminala. Izbira vnosnega jezika ne spremeni jezika namizja.

Uporabite `Super + I` za kroženje skozi metode vnosa ali razporeditve tipkovnice in `Super + Shift + I` za nazaj v drugo smer, tako da se s tremi konfiguriranimi lahko premikate med dvema sosedoma. Indikator vnosa se prikaže na desni strani vrstice le, ko je konfiguriranih več metod vnosa ali razporeditev. Ta vezava na namizju deluje ob vaših obstoječih preklopnih tipkah Fcitx; lahko jo prepišete v `~/.config/hypr/bindings.lua`. Vnosni pogoni in sestavna zaporedja uporabljajo storitev [Fcitx5](https://fcitx-im.org/), ki že teče v vsaki seji.

### Uporaba ALT kot SUPER

Na nekaterih tipkovnicah ni prikladno uporabljati primarno metatipko (tipka Windows/cmd) kot SUPER. To lahko namesto nje spremenite v ALT s to spremembo:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
