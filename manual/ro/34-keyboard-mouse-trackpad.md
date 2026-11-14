# Tastatură, Mouse, Trackpad

Hyprland îți permite să configurezi toate dispozitivele de intrare în mare detaliu. Poți face repetarea tastaturii supersonică de rapidă sau poți face trackpadul să folosească derularea naturală. Schimbi totul în `~/.config/hypr/input.lua`, la care poți ajunge și prin _Setup > Input_ din meniul Omarchy (`Super + Space`). Orice setezi acolo înlocuiește setările implicite Omarchy.

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

### Taste funcționale

Rândul de sus al tastaturii unui laptop trimite implicit tastele media (volum, luminozitate și așa mai departe), iar ținerea apăsată a tastei `Fn` dă F1-F12; `Fn + Esc` blochează invers până când o apeși din nou. Majoritatea tastaturilor rețin singure această blocare. Laptopurile ASUS și tastaturile în stil Apple lasă asta în seama Linux, care le pornește cu tastele media la fiecare pornire. Pentru ca în schimb să pornească pe F1-F12, rulează `omarchy keyboard toprow fnkeys` (și `omarchy keyboard toprow mediakeys` pentru a reveni); pe unele laptopuri, modificarea intră în vigoare după o repornire. Mac-urile Apple Silicon își păstrează propria setare.

### Gesturi pe trackpad

Glisează pe trackpad pentru a te deplasa pe desktop:

| Gest | Acțiune |
| --- | --- |
| Trei degete spre stânga / dreapta | Spațiul de lucru anterior / următor, inclusiv cele goale |
| Trei degete în sus | Comută consola AI |
| Trei degete în jos | Deschide meniul Omarchy |
| Patru degete spre stânga / dreapta | Mută fereastra activă în spațiul de lucru anterior / următor |
| Patru degete în jos | Comută modul ecran complet |

Pentru a schimba unul, dezactivează-l în `~/.config/hypr/input.lua` înainte să-l adaugi pe al tău [gest pentru touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), fiindcă Hyprland nu acceptă două gesturi cu aceleași degete și aceeași direcție:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Pentru a dezactiva toate gesturile Omarchy, setează `omarchy_default_gestures = false` aproape de începutul fișierului `~/.config/hypr/hyprland.lua`, înainte să se încarce setările implicite Omarchy.

Pe laptopurile Dell XPS cu touchpad haptic, poți seta și intensitatea clicului la scăzută, medie sau ridicată în _Trigger > Hardware > Touchpad Haptics_.

### Tastarea în chineză, japoneză și alte limbi

Selectează Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) sau Hong Kong (Cangjie) când programul de instalare îți cere tastatura. Omarchy configurează automat tastatura și motorul de intrare corespunzător, inclusiv în timpul configurării offline la prima pornire. Japoneza folosește Mozc, coreeana folosește Hangul standard cu două seturi, chineza simplificată folosește Pinyin, Taiwan folosește aranjamentul Zhuyin standard din Chewing, iar Hong Kong folosește Cangjie cu formele de caractere din Hong Kong. Japanese (US keyboard) oferă Mozc cu un aranjament de tastatură US. Tastele Hangul, Zhuyin și Cangjie rămân în pozițiile lor standard chiar și atunci când tastezi litere latine cu Dvorak, Colemak sau AZERTY. Dacă ai adăugat Hangul sau Chewing înainte de asta, deselectează-l și selectează-l din nou în _Setup > Keyboard > Input Methods_ pentru a-i muta tastele acolo; Omarchy lasă în pace un motor cu care tastezi deja.

Tastarea începe în modul Latin. Apasă `Super + I` pentru a parcurge metodele de intrare configurate și `Super + Shift + I` pentru a parcurge înapoi. Atinge `Shift` singur pentru a ieși dintr-o metodă de intrare precum Pinyin către literele latine și atinge-l din nou pentru a reveni, așa cum funcționează Sogou, Microsoft Pinyin și macOS; `Shift` plus o literă tastează în continuare o majusculă. Pe tastaturile japoneze, 全角/半角 comută intrarea, 変換 o pornește, iar 無変換 o oprește. Cu coreeana, 한/영 comută Hangul, iar 한자 convertește în Hanja, indiferent dacă tastatura ta are taste dedicate sau trimite Right Alt și Right Ctrl pentru ele, cum fac multe laptopuri, așa că Right Alt și Right Ctrl nu sunt acolo modificatori obișnuiți; dictarea se comută în schimb cu Alt + Space. `Ctrl + Space` rămâne disponibil pentru Tmux și Herdr; `Shift + CapsLock` rămâne tasta compose.

Indicatorul tastaturii apare în dreapta barei când ai mai multe aranjamente de tastatură sau metode de intrare. Fă clic pe el pentru a schimba limbile de intrare; Japanese afișează あ pentru hiragana. Pentru opțiunile de caractere japoneze, comută la Japanese, tastează un cuvânt precum `nihongo`, apoi apasă Space de două ori. Apasă Enter pentru a accepta alegerea. Dacă ai și mai multe aranjamente de tastatură, fă clic dreapta pe indicator pentru a le parcurge.

Folosește _Setup > Keyboard > Keyboard Inputs_ pentru a selecta aranjamente precum English și French, dintre aceleași opțiuni oferite în timpul instalării. Folosește _Setup > Keyboard > Input Methods_ pentru a selecta ce motoare de compunere sunt active. Ambele selectoare se deschid în meniul Omarchy, cu selecțiile tale curente bifate. Fă clic sau apasă Enter pentru a comuta o opțiune; fiecare modificare se aplică imediat. Deselectarea unei metode de intrare o elimină din ciclu fără să o dezinstaleze; tastatura rămâne disponibilă.

Rulează `omarchy setup keyboard` sau `omarchy setup input` pentru a deschide aceleași selectoare. Pentru a adăuga o limbă din linia de comandă, folosește `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` sau `cangjie5`. Quick, Boshiamy și Array vin în același pachet ca Cangjie și apar în selectorul Input Methods. Tastele tale personalizate de comutare sunt păstrate. Pentru aranjamente sau taste alternative ale motorului, instalează `fcitx5-configtool` cu `omarchy pkg add fcitx5-configtool` și lansează-l dintr-un terminal. Selectarea unei limbi de intrare nu schimbă limba desktopului. Alegerea Japanese, Korean sau Chinese în _Setup > Language_ adaugă metoda ei de intrare când nu ai încă niciuna.

Folosește `Super + I` pentru a parcurge metodele de intrare sau aranjamentele de tastatură și `Super + Shift + I` pentru a merge în direcția opusă, așa că, având trei configurate, te poți deplasa între doi vecini. Indicatorul de intrare apare în dreapta barei numai când este configurată mai mult de o metodă de intrare sau un aranjament. Această combinație de pe desktop funcționează alături de tastele tale Fcitx existente de comutare; o poți suprascrie în `~/.config/hypr/bindings.lua`. Motoarele de intrare și secvențele compose folosesc serviciul [Fcitx5](https://fcitx-im.org/) care rulează deja în fiecare sesiune.

### Folosește ALT ca SUPER

Pe unele tastaturi, nu este comod să folosești tasta meta principală (tasta Windows/cmd) ca SUPER. Poți schimba asta ca să fie ALT în schimb, folosind această modificare:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
