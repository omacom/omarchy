# Tastatură, mouse, trackpad

Hyprland îți permite să-ți configurezi toate intrările în mare detaliu. Poți schimba repetarea tastaturii ca să fie supersonică sau poți face trackpadul să folosească derularea naturală. Schimbi tot în `~/.config/hypr/input.lua`, la care poți ajunge și prin _Configurare > Input_ în meniul Omarchy (`Super + Space`). Orice setezi acolo înlocuiește valorile implicite Omarchy.

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

CapsLock funcționează ca un Caps Lock normal, iar `Shift + CapsLock` este tasta compose pentru [emoji rapide](07-hotkeys.md#quick-emojis) și [alte completări](07-hotkeys.md#quick-completions). Dacă ai prefera tasta compose în altă parte, înlocuiește `omarchy:shift_caps_compose` în `kb_options`. De exemplu, asta mută tasta compose pe Alt dreapta:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gesturi pe trackpad

Poți porni și [gesturile pe touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), cum ar fi glisarea cu trei degete ca să schimbi spațiile de lucru:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Pe laptopurile Dell XPS cu touchpad haptic, poți seta și puterea clicului la mică, medie sau mare sub _Declanșator > Hardware > Haptică touchpad_.

### Tastarea în chineză, japoneză și alte limbi

Selectează japoneză, coreeană, chineză (simplificată, Pinyin) sau chineză (tradițională, Zhuyin) când programul de instalare te întreabă de tastatură. Omarchy configurează tastatura și motorul de intrare potrivit automat, inclusiv în timpul configurării offline la prima pornire. Japoneza folosește Mozc, coreeana folosește Hangul standard cu două seturi, chineza simplificată folosește Pinyin, iar chineza tradițională folosește aranjarea Zhuyin standard de la Chewing. Japoneza (tastatură SUA) oferă Mozc cu o aranjare de tastatură SUA.

Tastarea pornește în modul latin. Apasă `Super + I` ca să parcurgi metodele de intrare configurate și `Super + Shift + I` ca să mergi înapoi. Apasă `Shift` de unul singur ca să ieși dintr-o metodă de intrare precum Pinyin către litere latine și apasă-l din nou ca să mergi înapoi, așa cum funcționează Sogou, Microsoft Pinyin și macOS; `Shift` plus o literă tastează totuși o majusculă. Pe tastaturile japoneze, 全角/半角 comută intrarea, 変換 o pornește, iar 無変換 o oprește. Pe o aranjare de tastatură coreeană, tastele dedicate 한/영 și 한자 comută Hangul și convertesc în Hanja. `Ctrl + Space` rămâne disponibil pentru Tmux și Herdr; `Shift + CapsLock` rămâne tasta compose.

Indicatorul de tastatură apare în dreapta barei când ai mai multe aranjări de tastatură sau metode de intrare. Fă clic pe el ca să schimbi limbile de intrare; japoneza afișează あ pentru hiragana. Pentru alegerile de caractere japoneze, treci la japoneză, tastează un cuvânt precum `nihongo`, apoi apasă Space de două ori. Apasă Enter ca să accepți alegerea ta. Dacă ai și mai multe aranjări de tastatură, fă clic dreapta pe indicator ca să le parcurgi.

Folosește _Configurare > Tastare > Aranjări tastatură_ ca să selectezi aranjări cum ar fi engleza și franceza, dintre aceleași alegeri oferite în timpul instalării. Folosește _Configurare > Tastare > Metode de introducere_ ca să selectezi ce motoare de compoziție sunt active. Ambele selectoare se deschid în interiorul meniului Omarchy, cu selecțiile tale curente bifate. Fă clic sau apasă Enter ca să comuți o alegere; fiecare schimbare se aplică imediat. Deselectarea unei metode de intrare o elimină din ciclu fără să o dezinstaleze; tastatura rămâne disponibilă.

Rulează `omarchy setup keyboard` sau `omarchy setup input` ca să deschizi aceleași selectoare. Ca să adaugi o limbă din linia de comandă, folosește `omarchy setup input mozc`, `hangul`, `pinyin` sau `chewing`. Tastele tale de comutare personalizate sunt păstrate. Pentru aranjări sau taste alternative de motor, instalează `fcitx5-configtool` cu `omarchy pkg add fcitx5-configtool` și lansează-l dintr-un terminal. Selectarea unei limbi de intrare nu schimbă limba desktopului.

Folosește `Super + I` ca să parcurgi metodele de intrare sau aranjările de tastatură și `Super + Shift + I` ca să mergi în direcția cealaltă, așa că, având trei configurate, te poți mișca între doi vecini. Indicatorul de intrare apare în dreapta barei numai când este configurată mai mult de o metodă de intrare sau o aranjare. Această legătură de desktop funcționează alături de tastele tale de comutare Fcitx existente; o poți suprascrie în `~/.config/hypr/bindings.lua`. Motoarele de intrare și secvențele compose folosesc serviciul [Fcitx5](https://fcitx-im.org/) care rulează deja în fiecare sesiune.

### Folosește ALT ca SUPER

Pe unele tastaturi, nu este convenabil să folosești tasta meta primară (tasta Windows/cmd) ca SUPER. Poți schimba asta în ALT folosind în schimb această schimbare:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
