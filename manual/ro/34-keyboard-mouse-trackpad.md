# Tastatură, mouse, trackpad

Hyprland îți permite să configurezi în mare detaliu toate dispozitivele de intrare. Poți face repetarea tastaturii supersonică sau poți seta trackpadul să folosească derularea naturală. Schimbi toate acestea în `~/.config/hypr/input.lua`, la care poți ajunge și prin _Setup > Input_ din meniul Omarchy (`Super + Space`). Orice setezi acolo înlocuiește setările implicite din Omarchy.

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

Poți [vedea toate opțiunile de intrare](https://wiki.hypr.land/Configuring/Basics/Variables/#input) pe wiki-ul Hyprland pentru intrări.

CapsLock funcționează ca un Caps Lock normal, iar `Shift + CapsLock` este tasta compose pentru [emoji rapide](07-hotkeys.md#quick-emojis) și [alte completări](07-hotkeys.md#quick-completions). Dacă preferi să ai tasta compose în altă parte, înlocuiește `omarchy:shift_caps_compose` în `kb_options`. De exemplu, aceasta mută tasta compose pe Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Taste funcționale

Rândul de sus al unei tastaturi de laptop trimite tastele media (volum, luminozitate și așa mai departe) în mod implicit, iar ținerea apăsată a tastei `Fn` oferă F1-F12; `Fn + Esc` blochează invers până când o apeși din nou. Majoritatea tastaturilor țin minte singure această blocare. Laptopurile ASUS și tastaturile în stil Apple lasă asta în seama Linux, care le pornește cu tastele media la fiecare pornire. Pentru ca ele să pornească în schimb cu F1-F12, rulează `omarchy device keyboard toprow fnkeys` (și `omarchy device keyboard toprow mediakeys` ca să revii); la unele laptopuri, modificarea intră în vigoare după o repornire. Mac-urile Apple Silicon își păstrează propria setare.

### Gesturi pe trackpad

Glisează pe trackpad ca să te miști prin desktop:

| Gest | Acțiune |
| --- | --- |
| Trei degete spre stânga / dreapta | Spațiul de lucru anterior / următor, inclusiv cele goale |
| Trei degete în sus | Comută consola AI |
| Trei degete în jos | Deschide meniul Omarchy |
| Patru degete spre stânga / dreapta | Mută fereastra activă în spațiul de lucru anterior / următor |
| Patru degete în jos | Comută ecranul complet |

Pentru a schimba unul, dezactivează-l în `~/.config/hypr/input.lua` înainte să-l adaugi pe al tău [gest pentru touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), deoarece Hyprland nu acceptă două gesturi pe aceleași degete și în aceeași direcție:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Pentru a dezactiva toate gesturile din Omarchy, setează `omarchy_default_gestures = false` lângă începutul fișierului `~/.config/hypr/hyprland.lua`, înainte să se încarce setările implicite din Omarchy.

La laptopurile Dell XPS cu touchpad haptic, poți seta și intensitatea clicului la low, mid sau high sub _Trigger > Hardware > Touchpad Haptics_.

### Tastarea în chineză, japoneză și alte limbi

Selectează japoneză, coreeană, chineză (simplificată, Pinyin), Taiwan (Zhuyin) sau Hong Kong (Cangjie) când programul de instalare te întreabă ce tastatură ai. Omarchy configurează automat tastatura și motorul de intrare corespunzător, inclusiv în timpul configurării offline la prima pornire. Japoneza folosește Mozc, coreeana folosește Hangul standard cu două seturi, chineza simplificată folosește Pinyin, Taiwan folosește aranjamentul Zhuyin standard din Chewing, iar Hong Kong folosește Cangjie cu forme de caractere din Hong Kong. Japoneza (tastatură US) oferă Mozc cu o dispunere de tastatură US. Tastele Hangul, Zhuyin și Cangjie rămân în pozițiile lor standard chiar și atunci când tastezi litere latine cu Dvorak, Colemak sau AZERTY. Dacă ai adăugat Hangul sau Chewing înainte de asta, deselectează-le și reselectează-le sub _Setup > Keyboard > Input Methods_ ca să le muți tastele acolo; Omarchy lasă în pace un motor cu care tastezi deja.

Tastarea începe în modul latin. Apasă `Super + I` ca să parcurgi ciclic metodele de intrare configurate și `Super + Shift + I` ca să le parcurgi înapoi. Atinge `Shift` singur ca să ieși dintr-o metodă de intrare precum Pinyin către litere latine și atinge-l din nou ca să te întorci, așa cum funcționează Sogou, Microsoft Pinyin și macOS; `Shift` plus o literă tastează în continuare o literă mare. Pe tastaturile japoneze, 全角/半角 comută intrarea, 変換 o pornește, iar 無変換 o oprește. La coreeană, 한/영 comută Hangul, iar 한자 convertește în Hanja, indiferent dacă tastatura ta are taste dedicate sau trimite Right Alt și Right Ctrl pentru ele, cum fac multe laptopuri, așa că acolo Right Alt și Right Ctrl nu sunt modificatori simpli; dictarea se comută în schimb cu Alt + Space. `Ctrl + Space` rămâne disponibil pentru Tmux și Herdr; `Shift + CapsLock` rămâne tasta compose.

Indicatorul de tastatură apare în dreapta barei atunci când ai mai multe dispuneri de tastatură sau metode de intrare. Fă clic pe el ca să schimbi limbile de intrare; japoneza afișează あ pentru hiragana. Pentru opțiunile de caractere japoneze, comută la japoneză, tastează un cuvânt precum `nihongo`, apoi apasă Space de două ori. Apasă Enter ca să-ți accepți alegerea. Dacă ai și mai multe dispuneri de tastatură, fă clic dreapta pe indicator ca să le parcurgi ciclic.

Folosește _Setup > Keyboard > Keyboard Inputs_ ca să selectezi dispuneri precum engleză și franceză, dintre aceleași opțiuni oferite în timpul instalării. Folosește _Setup > Keyboard > Input Methods_ ca să selectezi ce motoare de compunere sunt active. Ambele selectoare se deschid în meniul Omarchy, cu selecțiile tale curente bifate. Fă clic sau apasă Enter ca să comuți o opțiune; fiecare modificare se aplică imediat. Deselectarea unei metode de intrare o scoate din ciclu fără să o dezinstaleze; tastatura rămâne disponibilă.

Rulează `omarchy setup keyboard` sau `omarchy setup input` ca să deschizi aceleași selectoare. Pentru a adăuga o limbă din linia de comandă, folosește `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` sau `cangjie5`. Quick, Boshiamy și Array vin în același pachet cu Cangjie și apar în selectorul Input Methods. Tastele tale personalizate de comutare sunt păstrate. Pentru dispuneri sau taste alternative ale motoarelor, instalează `fcitx5-configtool` cu `omarchy pkg add fcitx5-configtool` și lansează-l dintr-un terminal. Selectarea unei limbi de intrare nu schimbă limba desktopului. Alegerea japonezei, coreenei sau chinezei sub _Setup > Region > Language_ adaugă metoda sa de intrare atunci când nu ai încă niciuna.

Folosește `Super + I` ca să parcurgi ciclic metodele de intrare sau dispunerile de tastatură și `Super + Shift + I` ca să mergi înapoi în celălalt sens, așa că, având trei configurate, te poți mișca între doi vecini. Indicatorul de intrare apare în dreapta barei doar când este configurată mai mult de o metodă de intrare sau dispunere. Această combinație de pe desktop funcționează alături de tastele tale existente de comutare Fcitx; o poți suprascrie în `~/.config/hypr/bindings.lua`. Motoarele de intrare și secvențele compose folosesc serviciul [Fcitx5](https://fcitx-im.org/) care rulează deja în fiecare sesiune.

### Folosește ALT ca SUPER

La unele tastaturi, nu este convenabil să folosești tasta meta principală (tasta Windows/cmd) ca SUPER. Poți schimba asta ca să fie în schimb ALT, folosind această modificare:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
