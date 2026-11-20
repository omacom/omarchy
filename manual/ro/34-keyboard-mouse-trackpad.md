# Tastatură, Mouse, Trackpad

Hyprland îți permite să configurezi toate intrările în mare detaliu. Poți seta repetarea tastaturii să fie supersonic de rapidă sau poți face trackpadul să folosească derularea naturală. Schimbi totul în `~/.config/hypr/input.lua`, la care poți ajunge și prin _Setup > Input_ în meniul Omarchy (`Super + Space`). Orice setezi acolo înlocuiește setările implicite Omarchy.

Iată un exemplu:

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

Poți [vezi toate opțiunile de intrare](https://wiki.hypr.land/Configuring/Basics/Variables/#input) pe wiki-ul Hyprland pentru intrări.

CapsLock funcționează ca un Caps Lock normal, iar `Shift + CapsLock` este tasta de compunere pentru [emoji-uri rapide](07-hotkeys.md#quick-emojis) și [alte completări](07-hotkeys.md#quick-completions). Dacă preferi tasta de compunere în altă parte, înlocuiește `omarchy:shift_caps_compose` în `kb_options`. De exemplu, aceasta mută tasta de compunere pe Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Taste funcționale

Rândul de sus al unei tastaturi de laptop trimite implicit tastele media (volum, luminozitate și așa mai departe), iar ținând apăsat `Fn` obții F1-F12; `Fn + Esc` o blochează în sens invers până îl apeși din nou. Majoritatea tastaturilor țin minte singure această blocare. Laptopurile ASUS și tastaturile în stil Apple lasă asta în seama Linux, care le pornește cu tastele media la fiecare pornire. Ca să pornească în schimb cu F1-F12, rulează `omarchy device keyboard toprow fnkeys` (și `omarchy device keyboard toprow mediakeys` ca să revii); la unele laptopuri intră în vigoare după o repornire. Mac-urile Apple Silicon își păstrează propria setare.

### Gesturi pe trackpad

Glisează pe trackpad ca să te miști pe desktop:

| Gest | Acțiune |
| --- | --- |
| Trei degete la stânga / la dreapta | Spațiul de lucru anterior / următor, inclusiv cele goale |
| Trei degete în sus | Comută consola AI |
| Trei degete în jos | Deschide meniul Omarchy |
| Patru degete la stânga / la dreapta | Mută fereastra activă în spațiul de lucru anterior / următor |
| Patru degete în jos | Comută ecranul complet |

Ca să schimbi unul, dezactivează-l în `~/.config/hypr/input.lua` înainte să-l adaugi pe al tău [gest de touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), deoarece Hyprland nu va accepta două gesturi pe aceleași degete și în aceeași direcție:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Ca să dezactivezi toate gesturile Omarchy, setează `omarchy_default_gestures = false` aproape de începutul fișierului `~/.config/hypr/hyprland.lua`, înainte să se încarce setările implicite Omarchy.

La laptopurile Dell XPS cu touchpad haptic, poți seta și intensitatea clicului la low, mid sau high sub _Trigger > Hardware > Touchpad Haptics_.

### Tastarea în chineză, japoneză și alte limbi

Selectează Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) sau Hong Kong (Cangjie) când programul de instalare îți cere tastatura. Omarchy configurează automat tastatura și motorul de intrare potrivit, inclusiv în timpul configurării offline la prima pornire. Japanese folosește Mozc, Korean folosește Hangul standard cu două seturi, Simplified Chinese folosește Pinyin, Taiwan folosește aranjamentul Zhuyin standard de la Chewing, iar Hong Kong folosește Cangjie cu formele de caractere din Hong Kong. Japanese (US keyboard) oferă Mozc cu o dispunere de tastatură US. Tastele Hangul, Zhuyin și Cangjie rămân în pozițiile lor standard chiar și când tastezi litere latine cu Dvorak, Colemak sau AZERTY. Dacă ai adăugat Hangul sau Chewing înainte de asta, deselectează-l și reselectează-l sub _Setup > Keyboard > Input Methods_ ca să-i muți tastele acolo; Omarchy lasă în pace un motor cu care tastezi deja.

Tastarea începe în modul Latin. Apasă `Super + I` ca să parcurgi ciclic metodele de intrare configurate și `Super + Shift + I` ca să parcurgi înapoi. Atinge `Shift` singur ca să ieși dintr-o metodă de intrare precum Pinyin spre litere latine și atinge-l din nou ca să te întorci, așa cum funcționează Sogou, Microsoft Pinyin și macOS; `Shift` plus o literă tastează în continuare o majusculă. Pe tastaturile japoneze, 全角/半角 comută intrarea, 変換 o pornește, iar 無変換 o oprește. Cu Korean, 한/영 comută Hangul și 한자 convertește în Hanja, indiferent dacă tastatura ta are taste dedicate sau trimite Right Alt și Right Ctrl pentru ele, cum fac multe laptopuri, așa că acolo Right Alt și Right Ctrl nu sunt modificatori simpli; dictarea se comută în schimb cu Alt + Space. `Ctrl + Space` rămâne disponibil pentru Tmux și Herdr; `Shift + CapsLock` rămâne tasta de compunere.

Indicatorul de tastatură apare în dreapta barei când ai mai multe dispuneri de tastatură sau metode de intrare. Fă clic pe el ca să schimbi limbile de intrare; Japanese afișează あ pentru hiragana. Pentru alegerile de caractere japoneze, comută la Japanese, tastează un cuvânt precum `nihongo`, apoi apasă Space de două ori. Apasă Enter ca să accepți alegerea. Dacă ai și mai multe dispuneri de tastatură, fă clic dreapta pe indicator ca să le parcurgi ciclic pe acelea.

Folosește _Setup > Keyboard > Keyboard Inputs_ ca să selectezi dispuneri precum English și French, dintre aceleași opțiuni oferite în timpul instalării. Folosește _Setup > Keyboard > Input Methods_ ca să selectezi ce motoare de compunere sunt active. Ambele selectoare se deschid în meniul Omarchy cu selecțiile tale curente bifate. Fă clic sau apasă Enter ca să comuti o opțiune; fiecare schimbare se aplică imediat. Deselectarea unei metode de intrare o scoate din ciclu fără să o dezinstaleze; tastatura rămâne disponibilă.

Rulează `omarchy setup keyboard` sau `omarchy setup input` ca să deschizi aceleași selectoare. Ca să adaugi o limbă din linia de comandă, folosește `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` sau `cangjie5`. Quick, Boshiamy și Array vin în același pachet ca Cangjie și apar în selectorul Input Methods. Tastele tale personalizate de comutare sunt păstrate. Pentru dispuneri sau taste alternative ale motoarelor, instalează `fcitx5-configtool` cu `omarchy pkg add fcitx5-configtool` și lansează-l dintr-un terminal. Selectarea unei limbi de intrare nu schimbă limba desktopului. Alegerea Japanese, Korean sau Chinese sub _Setup > Language_ îi adaugă metoda de intrare atunci când nu ai încă niciuna.

Folosește `Super + I` ca să parcurgi ciclic metodele de intrare sau dispunerile de tastatură și `Super + Shift + I` ca să mergi înapoi în celălalt sens, așa că, având trei configurate, te poți mișca între doi vecini. Indicatorul de intrare apare în dreapta barei doar când este configurată mai mult de o metodă de intrare sau o dispunere. Această combinație de pe desktop funcționează alături de tastele tale existente de comutare Fcitx; o poți suprascrie în `~/.config/hypr/bindings.lua`. Motoarele de intrare și secvențele de compunere folosesc serviciul [Fcitx5](https://fcitx-im.org/) care rulează deja în fiecare sesiune.

### Folosirea ALT ca SUPER

La unele tastaturi, nu este convenabil să folosești tasta meta principală (tasta Windows/cmd) ca SUPER. Poți schimba asta în ALT în schimb, folosind această modificare:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
