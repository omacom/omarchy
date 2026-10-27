# Tastatură, Mouse, Trackpad

Hyprland îți permite să configurezi toate dispozitivele de intrare în mare detaliu. Poți schimba repetarea tastaturii ca să fie supersonică de rapidă sau poți face trackpadul să folosească derularea naturală. Schimbi totul în `~/.config/hypr/input.lua`, la care poți ajunge și prin _Setup > Input_ din meniul Omarchy (`Super + Space`). Orice setezi acolo înlocuiește setările implicite Omarchy.

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

CapsLock funcționează ca un Caps Lock normal, iar `Shift + CapsLock` este tasta de compunere pentru [emoji-uri rapide](07-hotkeys.md#quick-emojis) și [alte completări](07-hotkeys.md#quick-completions). Dacă preferi tasta de compunere în altă parte, înlocuiește `omarchy:shift_caps_compose` în `kb_options`. De exemplu, asta mută tasta de compunere pe Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gesturi pe trackpad

Poți activa și [gesturi pe touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), cum ar fi glisarea cu trei degete pentru a schimba spațiile de lucru:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Pe laptopurile Dell XPS cu touchpad haptic, poți seta și intensitatea clicului la scăzută, medie sau ridicată în _Trigger > Hardware > Touchpad Haptics_.

### Tastarea în chineză, japoneză și alte limbi

Selectează japoneza, coreeana, chineza (simplificată, Pinyin), Taiwan (Zhuyin) sau Hong Kong (Cangjie) când programul de instalare te întreabă ce tastatură ai. Omarchy configurează automat tastatura și motorul de intrare potrivit, inclusiv în timpul configurării offline de la prima pornire. Japoneza folosește Mozc, coreeana folosește Hangul-ul standard cu două seturi, chineza simplificată folosește Pinyin, Taiwan folosește aranjamentul standard Zhuyin al Chewing, iar Hong Kong folosește Cangjie cu formele caracterelor din Hong Kong. Japoneza (tastatură US) oferă Mozc cu o dispunere de tastatură US. Tastele Hangul, Zhuyin și Cangjie rămân în pozițiile lor standard chiar și atunci când tastezi litere latine cu Dvorak, Colemak sau AZERTY. Dacă ai adăugat Hangul sau Chewing înainte de asta, deselectează-l și selectează-l din nou în _Setup > Typing > Input Methods_ ca să-i muți tastele acolo; Omarchy lasă în pace un motor cu care tastezi deja.

Tastarea începe în modul latin. Apasă `Super + I` pentru a parcurge metodele de intrare configurate și `Super + Shift + I` pentru a le parcurge înapoi. Apasă `Shift` de unul singur pentru a ieși dintr-o metodă de intrare precum Pinyin și a trece la litere latine, și apasă-l din nou pentru a te întoarce, la fel cum funcționează Sogou, Microsoft Pinyin și macOS; `Shift` plus o literă tastează tot o majusculă. Pe tastaturile japoneze, 全角/半角 comută intrarea, 変換 o activează și 無変換 o dezactivează. La coreeană, 한/영 comută Hangul, iar 한자 convertește în Hanja, indiferent dacă tastatura ta are taste dedicate sau trimite Right Alt și Right Ctrl pentru ele, cum fac multe laptopuri, așa că Right Alt și Right Ctrl nu sunt modificatori simpli acolo; dictarea push-to-talk rămâne pe F9. `Ctrl + Space` rămâne disponibil pentru Tmux și Herdr; `Shift + CapsLock` rămâne tasta de compunere.

Indicatorul tastaturii apare în partea dreaptă a barei atunci când ai mai multe dispuneri de tastatură sau metode de intrare. Fă clic pe el pentru a schimba limbile de intrare; japoneza afișează あ pentru hiragana. Pentru alegerile caracterelor japoneze, treci la japoneză, tastează un cuvânt precum `nihongo`, apoi apasă Space de două ori. Apasă Enter pentru a accepta alegerea. Dacă ai și mai multe dispuneri de tastatură, fă clic dreapta pe indicator pentru a le parcurge.

Folosește _Setup > Typing > Keyboard Layouts_ pentru a selecta dispuneri precum engleza și franceza, dintre aceleași opțiuni oferite în timpul instalării. Folosește _Setup > Typing > Input Methods_ pentru a selecta ce motoare de compunere sunt active. Ambele selectoare se deschid în meniul Omarchy cu selecțiile tale actuale bifate. Fă clic sau apasă Enter pentru a activa sau dezactiva o opțiune; fiecare modificare se aplică imediat. Deselectarea unei metode de intrare o elimină din ciclu fără să o dezinstaleze; tastatura rămâne disponibilă.

Rulează `omarchy setup keyboard` sau `omarchy setup input` pentru a deschide aceleași selectoare. Pentru a adăuga o limbă din linia de comandă, folosește `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` sau `cangjie5`. Quick, Boshiamy și Array vin în același pachet ca Cangjie și apar în selectorul Input Methods. Tastele tale personalizate de comutare sunt păstrate. Pentru dispuneri sau taste alternative ale motoarelor, instalează `fcitx5-configtool` cu `omarchy pkg add fcitx5-configtool` și lansează-l dintr-un terminal. Selectarea unei limbi de intrare nu schimbă limba desktopului. Alegerea japonezei, coreenei sau chinezei în _Setup > Language_ adaugă metoda ei de intrare atunci când nu ai încă niciuna.

Folosește `Super + I` pentru a parcurge metodele de intrare sau dispunerile de tastatură și `Super + Shift + I` pentru a merge în direcția opusă, așa că, cu trei configurate, te poți deplasa între doi vecini. Indicatorul de intrare apare în partea dreaptă a barei doar atunci când este configurată mai mult de o metodă de intrare sau o dispunere. Această asociere de desktop funcționează alături de tastele tale existente de comutare Fcitx; o poți suprascrie în `~/.config/hypr/bindings.lua`. Motoarele de intrare și secvențele de compunere folosesc serviciul [Fcitx5](https://fcitx-im.org/) care rulează deja în fiecare sesiune.

### Folosește ALT ca SUPER

Pe unele tastaturi, nu este convenabil să folosești tasta meta principală (tasta Windows/cmd) ca SUPER. Poți schimba asta ca să fie ALT în schimb, folosind această modificare:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
