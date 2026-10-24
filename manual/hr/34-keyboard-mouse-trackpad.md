# Tipkovnica, miš, dodirna ploha

Hyprland ti omogućuje konfiguriranje svih unosa do najsitnijih detalja. Možeš promijeniti ponavljanje tipkovnice da bude nadzvučno brzo ili natjerati dodirnu plohu da koristi prirodno pomicanje. Sve to mijenjaš u `~/.config/hypr/input.lua`, do čega možeš doći i putem _Postavke > Unos_ u izborniku Omarchy (`Super + Space`). Sve što tamo postaviš zamjenjuje Omarchyjeve zadane postavke.

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

Možeš [vidjeti sve opcije unosa](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na Hyprland wikiju za unose.

CapsLock radi kao normalan Caps Lock, a `Shift + CapsLock` compose je tipka za [brze emojije](07-hotkeys.md#quick-emojis) i [druga dovršavanja](07-hotkeys.md#quick-completions). Ako bi radije da compose tipka bude drugdje, zamijeni `omarchy:shift_caps_compose` u `kb_options`. Na primjer, ovo premješta compose tipku na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Geste dodirne plohe

Možeš uključiti i [geste dodirne plohe](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), poput prelazenja s tri prsta za promjenu radnih prostora:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Na prijenosnicima Dell XPS s haptičkom dodirnom plohom također možeš postaviti jačinu klika na nisku, srednju ili visoku pod _Pokreni > Hardver > Haptika dodirne plohe_.

### Tipkanje na kineskom, japanskom i drugim jezicima

Odaberi japanski, korejski, kineski (pojednostavljeni, Pinyin) ili kineski (tradicionalni, Zhuyin) kad instalater pita za tipkovnicu. Omarchy automatski konfigurira tipkovnicu i odgovarajući mehanizam unosa, uključujući tijekom izvanmrežnog postavljanja pri prvom pokretanju. Japanski koristi Mozc, korejski koristi standardni dvodijelni Hangul, pojednostavljeni kineski koristi Pinyin, a tradicionalni kineski koristi Chewingov standardni Zhuyin raspored. Japanese (US keyboard) pruža Mozc s US rasporedom tipkovnice.

Tipkanje počinje u latinici. Pritisni `Super + I` za cikličko kretanje kroz konfigurirane načine unosa, a `Super + Shift + I` za cikličko kretanje unatrag. Dodirni `Shift` samostalno za izlaz iz načina unosa poput Pinyina u latinicu i dodirni ga ponovno za povratak, onako kako rade Sogou, Microsoft Pinyin i macOS; `Shift` plus slovo i dalje upisuje veliko slovo. Na japanskim tipkovnicama 全角/半角 prebacuje unos, 変換 ga uključuje, a 無変換 ga isključuje. Na korejskom rasporedu tipkovnice namjenske tipke 한/영 i 한자 prebacuju Hangul i pretvaraju u Hanja. `Ctrl + Space` ostaje dostupan za Tmux i Herdr; `Shift + CapsLock` ostaje compose tipka.

Pokazatelj tipkovnice pojavljuje se desno na traci kad imaš više rasporeda tipkovnice ili načina unosa. Klikni ga za prebacivanje jezika unosa; japanski prikazuje あ za hiraganu. Za odabire japanskih znakova prebaci se na japanski, upiši riječ poput `nihongo`, a zatim dvaput pritisni Space. Pritisni Enter za prihvaćanje odabira. Ako također imaš više rasporeda tipkovnice, desnom tipkom miša klikni pokazatelj za cikličko kretanje kroz njih.

Koristi _Postavke > Tipkanje > Rasporedi tipkovnice_ za odabir rasporeda poput engleskog i francuskog, iz istih odabira ponuđenih tijekom instalacije. Koristi _Postavke > Tipkanje > Načini unosa_ za odabir koji su mehanizmi sastavljanja aktivni. Oba birača otvaraju se unutar izbornika Omarchy s tvojim trenutnim odabirima označenima. Klikni ili pritisni Enter za prebacivanje odabira; svaka promjena primjenjuje se odmah. Poništavanje odabira načina unosa uklanja ga iz ciklusa bez deinstalacije; tipkovnica ostaje dostupna.

Pokreni `omarchy setup keyboard` ili `omarchy setup input` za otvaranje istih birača. Za dodavanje jednog jezika iz naredbenog retka koristi `omarchy setup input mozc`, `hangul`, `pinyin` ili `chewing`. Tvoje prilagođene tipke za prebacivanje su sačuvane. Za alternativne rasporede ili tipke mehanizma instaliraj `fcitx5-configtool` s `omarchy pkg add fcitx5-configtool` i pokreni ga iz terminala. Odabir jezika unosa ne mijenja jezik radne površine.

Koristi `Super + I` za cikličko kretanje kroz načine unosa ili rasporede tipkovnice, a `Super + Shift + I` za povratak drugim smjerom, pa s tri konfigurirana možeš se kretati između dva susjeda. Pokazatelj unosa pojavljuje se desno na traci samo kad je konfigurirano više od jednog načina unosa ili rasporeda. Ovo vezanje radne površine radi zajedno s tvojim postojećim Fcitx tipkama za prebacivanje; možeš ga prebrisati u `~/.config/hypr/bindings.lua`. Mehanizmi unosa i sekvence sastavljanja koriste uslugu [Fcitx5](https://fcitx-im.org/) koja već radi u svakoj sesiji.

### Korištenje ALT kao SUPER

Na nekim tipkovnicama nije prikladno koristiti primarnu meta tipku (tipku Windows/cmd) kao SUPER. To možeš promijeniti u ALT umjesto toga koristeći ovu promjenu:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
