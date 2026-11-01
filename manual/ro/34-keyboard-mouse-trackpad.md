# Tastatură, mouse, trackpad

Hyprland îți permite să configurezi toate dispozitivele de intrare în detaliu. Poți face repetarea tastaturii supersonică de rapidă sau poți face trackpadul să folosească derularea naturală. Schimbi toate acestea în `~/.config/hypr/input.lua`, la care poți ajunge și prin _Setup > Input_ din meniul Omarchy (`Super + Space`). Orice setezi acolo înlocuiește setările implicite din Omarchy.

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

Poți [vedea toate opțiunile de intrare](https://wiki.hypr.land/Configuring/Basics/Variables/#input) pe wiki-ul Hyprland pentru dispozitive de intrare.

CapsLock funcționează ca un Caps Lock normal, iar `Shift + CapsLock` este tasta compose pentru [emoji-uri rapide](07-hotkeys.md#quick-emojis) și [alte completări](07-hotkeys.md#quick-completions). Dacă preferi să ai tasta compose în altă parte, înlocuiește `omarchy:shift_caps_compose` din `kb_options`. De exemplu, aceasta mută tasta compose pe Right Alt:

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
| Patru degete în jos | Comută modul ecran complet |

Pentru a schimba unul, anulează-l mai întâi în `~/.config/hypr/input.lua` înainte să-ți adaugi propriul [gest pentru touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), deoarece Hyprland nu acceptă două gesturi cu aceleași degete și în aceeași direcție:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Pentru a dezactiva toate gesturile din Omarchy, setează `omarchy_default_gestures = false` aproape de începutul fișierului `~/.config/hypr/hyprland.lua`, înainte să se încarce setările implicite din Omarchy.

Pe laptopurile Dell XPS cu touchpad haptic, poți seta și intensitatea clicului la low, mid sau high în _Trigger > Hardware > Touchpad Haptics_.

### Tastarea în chineză, japoneză și alte limbi

Selectează japoneza, coreeana, chineza (simplificată, Pinyin), Taiwan (Zhuyin) sau Hong Kong (Cangjie) atunci când programul de instalare îți cere tastatura. Omarchy configurează automat tastatura și motorul de introducere corespunzător, inclusiv în timpul configurării offline de la prima pornire. Japoneza folosește Mozc, coreeana folosește Hangul standard cu două seturi, chineza simplificată folosește Pinyin, Taiwan folosește aranjamentul Zhuyin standard de la Chewing, iar Hong Kong folosește Cangjie cu formele de caractere din Hong Kong. Japoneza (tastatură US) oferă Mozc cu un aranjament de tastatură US. Tastele Hangul, Zhuyin și Cangjie rămân în pozițiile lor standard chiar și atunci când tastezi litere latine cu Dvorak, Colemak sau AZERTY. Dacă ai adăugat Hangul sau Chewing înainte de asta, deselectează-l și selectează-l din nou în _Setup > Typing > Input Methods_ pentru a-i muta tastele acolo; Omarchy lasă în pace un motor cu care tastezi deja.

Tastarea începe în modul latin. Apasă `Super + I` pentru a parcurge metodele de introducere configurate și `Super + Shift + I` pentru a merge înapoi. Apasă scurt `Shift` singur pentru a ieși dintr-o metodă de introducere precum Pinyin către literele latine și apasă-l din nou pentru a reveni, așa cum funcționează Sogou, Microsoft Pinyin și macOS; `Shift` plus o literă tastează în continuare o majusculă. Pe tastaturile japoneze, 全角/半角 comută introducerea, 変換 o activează, iar 無変換 o dezactivează. La coreeană, 한/영 comută Hangul, iar 한자 convertește în Hanja, indiferent dacă tastatura ta are taste dedicate sau trimite Right Alt și Right Ctrl pentru ele, cum fac multe laptopuri, așa că Right Alt și Right Ctrl nu sunt modificatori simpli acolo; dictarea se comută în schimb cu Alt + Space. `Ctrl + Space` rămâne disponibil pentru Tmux și Herdr; `Shift + CapsLock` rămâne tasta compose.

Indicatorul de tastatură apare în dreapta barei atunci când ai mai multe aranjamente de tastatură sau metode de introducere. Dă clic pe el pentru a schimba limbile de introducere; japoneza afișează あ pentru hiragana. Pentru alegerile de caractere japoneze, comută la japoneză, tastează un cuvânt precum `nihongo`, apoi apasă Space de două ori. Apasă Enter pentru a accepta alegerea. Dacă ai și mai multe aranjamente de tastatură, dă clic dreapta pe indicator pentru a le parcurge pe rând.

Folosește _Setup > Typing > Keyboard Layouts_ pentru a selecta aranjamente precum engleza și franceza, dintre aceleași opțiuni oferite în timpul instalării. Folosește _Setup > Typing > Input Methods_ pentru a selecta ce motoare de compunere sunt active. Ambele selectoare se deschid în meniul Omarchy, cu selecțiile tale curente bifate. Dă clic sau apasă Enter pentru a comuta o opțiune; fiecare modificare se aplică imediat. Deselectarea unei metode de introducere o elimină din ciclu fără să o dezinstaleze; tastatura rămâne disponibilă.

Rulează `omarchy setup keyboard` sau `omarchy setup input` pentru a deschide aceleași selectoare. Pentru a adăuga o limbă din linia de comandă, folosește `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` sau `cangjie5`. Quick, Boshiamy și Array vin în același pachet ca Cangjie și apar în selectorul Input Methods. Tastele tale personalizate de comutare sunt păstrate. Pentru aranjamente sau taste alternative ale motoarelor, instalează `fcitx5-configtool` cu `omarchy pkg add fcitx5-configtool` și pornește-l dintr-un terminal. Selectarea unei limbi de introducere nu schimbă limba desktopului. Alegerea japonezei, coreenei sau chinezei în _Setup > Language_ adaugă metoda ei de introducere atunci când nu ai încă niciuna.

Folosește `Super + I` pentru a parcurge metodele de introducere sau aranjamentele de tastatură, iar `Super + Shift + I` pentru a merge înapoi în celălalt sens, așa că, având trei configurate, te poți deplasa între doi vecini. Indicatorul de introducere apare în dreapta barei numai atunci când sunt configurate mai multe metode de introducere sau aranjamente. Această combinație de pe desktop funcționează alături de tastele tale de comutare Fcitx existente; o poți suprascrie în `~/.config/hypr/bindings.lua`. Motoarele de introducere și secvențele compose folosesc serviciul [Fcitx5](https://fcitx-im.org/) care rulează deja în fiecare sesiune.

### Folosește ALT ca SUPER

Pe unele tastaturi, nu este comod să folosești tasta meta principală (tasta Windows/cmd) ca SUPER. Poți schimba acest lucru pentru a folosi în schimb ALT, cu această modificare:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
