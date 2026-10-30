# Tastatură, Mouse, Trackpad

Hyprland îți permite să configurezi toate dispozitivele de intrare în mare detaliu. Poți face repetarea tastaturii supersonică sau poți seta trackpadul să folosească derularea naturală. Schimbi toate acestea în `~/.config/hypr/input.lua`, la care poți ajunge și prin _Configurare > Intrare_ în meniul Omarchy (`Super + Space`). Orice setezi acolo înlocuiește setările implicite Omarchy.

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

CapsLock funcționează ca un Caps Lock normal, iar `Shift + CapsLock` este tasta compose pentru [emoji rapide](07-hotkeys.md#quick-emojis) și [alte completări](07-hotkeys.md#quick-completions). Dacă preferi tasta compose în altă parte, înlocuiește `omarchy:shift_caps_compose` în `kb_options`. De exemplu, aceasta mută tasta compose pe Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gesturi pe trackpad

Glisează pe trackpad pentru a te deplasa pe desktop:

| Gest | Acțiune |
| --- | --- |
| Trei degete la stânga / la dreapta | Spațiul de lucru anterior / următor, inclusiv cele goale |
| Trei degete în sus | Comută consola AI |
| Trei degete în jos | Deschide meniul Omarchy |
| Patru degete la stânga / la dreapta | Mută fereastra activă în spațiul de lucru anterior / următor |
| Patru degete în jos | Comută ecranul complet |

Pentru a schimba unul, dezactivează-l în `~/.config/hypr/input.lua` înainte să adaugi propriul tău [gest pe touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), deoarece Hyprland nu va accepta două gesturi pe aceleași degete și în aceeași direcție:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Pentru a dezactiva toate gesturile Omarchy, setează `omarchy_default_gestures = false` aproape de începutul fișierului `~/.config/hypr/hyprland.lua`, înainte să se încarce setările implicite Omarchy.

Pe laptopurile Dell XPS cu touchpad haptic, poți seta și intensitatea clicului la scăzută, medie sau ridicată în _Declanșator > Hardware > Feedback haptic touchpad_.

### Tastarea în chineză, japoneză și alte limbi

Selectează japoneză, coreeană, chineză (simplificată, Pinyin), Taiwan (Zhuyin) sau Hong Kong (Cangjie) când programul de instalare te întreabă despre tastatură. Omarchy configurează automat tastatura și motorul de intrare corespunzător, inclusiv în timpul configurării offline la prima pornire. Japoneza folosește Mozc, coreeana folosește Hangul standard cu două seturi, chineza simplificată folosește Pinyin, Taiwan folosește aranjamentul standard Zhuyin al lui Chewing, iar Hong Kong folosește Cangjie cu forme de caractere din Hong Kong. Japoneza (tastatură US) oferă Mozc cu o dispunere de tastatură US. Tastele Hangul, Zhuyin și Cangjie rămân în pozițiile lor standard chiar și atunci când tastezi litere latine cu Dvorak, Colemak sau AZERTY. Dacă ai adăugat Hangul sau Chewing înainte de aceasta, deselectează-le și reselectează-le în _Configurare > Tastare > Metode de intrare_ pentru a le muta tastele acolo; Omarchy lasă în pace un motor cu care tastezi deja.

Tastarea începe în modul latin. Apasă `Super + I` pentru a parcurge metodele de intrare configurate și `Super + Shift + I` pentru a parcurge înapoi. Atinge `Shift` singur pentru a ieși dintr-o metodă de intrare precum Pinyin către litere latine și atinge-l din nou pentru a reveni, așa cum funcționează Sogou, Microsoft Pinyin și macOS; `Shift` plus o literă tastează în continuare o literă mare. Pe tastaturile japoneze, 全角/半角 comută intrarea, 変換 o activează, iar 無変換 o dezactivează. Cu coreeana, 한/영 comută Hangul și 한자 convertește în Hanja, indiferent dacă tastatura ta are taste dedicate sau trimite Right Alt și Right Ctrl pentru ele, cum fac multe laptopuri, așa că Right Alt și Right Ctrl nu sunt modificatori simpli acolo; dictarea push-to-talk rămâne pe F9. `Ctrl + Space` rămâne disponibil pentru Tmux și Herdr; `Shift + CapsLock` rămâne tasta compose.

Indicatorul de tastatură apare în dreapta barei când ai mai multe dispuneri de tastatură sau metode de intrare. Fă clic pe el pentru a comuta limbile de intrare; japoneza afișează あ pentru hiragana. Pentru alegerile de caractere japoneze, comută la japoneză, tastează un cuvânt precum `nihongo`, apoi apasă Space de două ori. Apasă Enter pentru a accepta alegerea. Dacă ai și mai multe dispuneri de tastatură, fă clic dreapta pe indicator pentru a le parcurge.

Folosește _Configurare > Tastare > Dispuneri de tastatură_ pentru a selecta dispuneri precum engleză și franceză, din aceleași opțiuni oferite în timpul instalării. Folosește _Configurare > Tastare > Metode de intrare_ pentru a selecta ce motoare de compunere sunt active. Ambele selectoare se deschid în interiorul meniului Omarchy cu selecțiile tale curente bifate. Fă clic sau apasă Enter pentru a comuta o opțiune; fiecare schimbare se aplică imediat. Deselectarea unei metode de intrare o elimină din ciclu fără să o dezinstaleze; tastatura rămâne disponibilă.

Rulează `omarchy setup keyboard` sau `omarchy setup input` pentru a deschide aceleași selectoare. Pentru a adăuga o limbă din linia de comandă, folosește `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` sau `cangjie5`. Quick, Boshiamy și Array vin în același pachet ca Cangjie și apar în selectorul Metode de intrare. Tastele tale personalizate de comutare sunt păstrate. Pentru dispuneri sau taste alternative ale motoarelor, instalează `fcitx5-configtool` cu `omarchy pkg add fcitx5-configtool` și lansează-l dintr-un terminal. Selectarea unei limbi de intrare nu schimbă limba desktopului. Alegerea japonezei, coreenei sau chinezei în _Configurare > Limbă_ adaugă metoda ei de intrare atunci când nu ai încă niciuna.

Folosește `Super + I` pentru a parcurge metodele de intrare sau dispunerile de tastatură și `Super + Shift + I` pentru a merge înapoi în celălalt sens, așa că, având trei configurate, te poți mișca între doi vecini. Indicatorul de intrare apare în dreapta barei numai când este configurată mai mult de o metodă de intrare sau dispunere. Această combinație de pe desktop funcționează alături de tastele tale existente de comutare Fcitx; o poți suprascrie în `~/.config/hypr/bindings.lua`. Motoarele de intrare și secvențele compose folosesc serviciul [Fcitx5](https://fcitx-im.org/) care rulează deja în fiecare sesiune.

### Folosește ALT ca SUPER

Pe unele tastaturi, nu este convenabil să folosești tasta meta principală (tasta Windows/cmd) ca SUPER. Poți schimba aceasta să fie ALT în schimb, folosind această modificare:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
