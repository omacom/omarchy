# Billentyűzet, egér, érintőpad

A Hyprland részletesen konfigurálhatóvá teszi az összes beviteli eszközt. Szuperszonikusan gyorsra állíthatod a billentyűzetismétlést, vagy természetes görgetést adhatsz az érintőpadnak. Mindezt a `~/.config/hypr/input.lua` fájlban módosíthatod, amelyet az Omarchy menüben (`Super + Space`) a _Setup > Input_ útvonalon is elérhetsz. Amit ott beállítasz, felülírja az Omarchy alapértelmezéseit.

Íme egy példa:

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

A Hyprland wikiben [megnézheted az összes beviteli beállítást](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

A CapsLock normál Caps Lockként működik, a `Shift + CapsLock` pedig a compose billentyű a [gyors emojikhoz](07-hotkeys.md#quick-emojis) és [egyéb kiegészítésekhez](07-hotkeys.md#quick-completions). Ha máshova szeretnéd tenni a compose billentyűt, cseréld le az `omarchy:shift_caps_compose` értéket a `kb_options` beállításban. Ez például a Jobb Alt-ra helyezi a compose billentyűt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkcióbillentyűk

A laptopbillentyűzet felső sora alapértelmezetten a médiabillentyűket (hangerő, fényerő és így tovább) küldi, az `Fn` nyomva tartásával pedig az F1-F12 érhető el; az `Fn + Esc` zárolja ezt fordított módon, amíg újra meg nem nyomod. A legtöbb billentyűzet maga megjegyzi ezt a zárolást. Az ASUS laptopok és az Apple-stílusú billentyűzetek a Linuxra hagyják, amely minden rendszerindításkor a médiabillentyűkkel indítja őket. Ha inkább az F1-F12-vel szeretnéd indítani őket, futtasd az `omarchy device keyboard toprow fnkeys` parancsot (a visszaállításhoz pedig az `omarchy device keyboard toprow mediakeys` parancsot); egyes laptopokon ez újraindítás után lép érvénybe. Az Apple Silicon Mac gépek megtartják a saját beállításukat.

### Érintőpados gesztusok

Húzd az ujjad az érintőpadon az asztalon való mozgáshoz:

| Gesztus | Művelet |
| --- | --- |
| Három ujj balra / jobbra | Előző / következő munkaterület, az üreseket is beleértve |
| Három ujj felfelé | Az AI-konzol be-/kikapcsolása |
| Három ujj lefelé | Az Omarchy menü megnyitása |
| Négy ujj balra / jobbra | Az aktív ablak áthelyezése az előző / következő munkaterületre |
| Négy ujj lefelé | Teljes képernyős mód be-/kikapcsolása |

Egy gesztus módosításához szüntesd meg azt a `~/.config/hypr/input.lua` fájlban, mielőtt hozzáadod a saját [érintőpados gesztusodat](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), mivel a Hyprland nem fogad el két gesztust ugyanazokra az ujjakra és irányra:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Az Omarchy összes gesztusának kikapcsolásához állítsd az `omarchy_default_gestures = false` értéket a `~/.config/hypr/hyprland.lua` fájl teteje közelében, még az Omarchy alapértelmezéseinek betöltése előtt.

A haptikus érintőpaddal rendelkező Dell XPS laptopokon a kattintási erősséget is beállíthatod alacsony, közepes vagy magas értékre a _Trigger > Hardware > Touchpad Haptics_ alatt.

### Gépelés kínaiul, japánul és más nyelveken

Válaszd a japánt, a koreait, a kínait (egyszerűsített, Pinyin), a tajvanit (Zhuyin) vagy a hongkongit (Cangjie), amikor a telepítő a billentyűzetedről kérdez. Az Omarchy automatikusan konfigurálja a billentyűzetet és a hozzá illő beviteli motort, az offline első rendszerindítási beállítás során is. A japán a Mozc motort használja, a koreai a szabványos kétkészletes Hangul elrendezést, az egyszerűsített kínai a Pinyint, a tajvani a Chewing szabványos Zhuyin elrendezését, a hongkongi pedig a Cangjie motort hongkongi karakterformákkal. A japán (US billentyűzet) a Mozc motort biztosítja US billentyűzetkiosztással. A Hangul, a Zhuyin és a Cangjie billentyűi a szabványos helyükön maradnak akkor is, ha Dvorak, Colemak vagy AZERTY kiosztással írsz latin betűket. Ha korábban adtad hozzá a Hangult vagy a Chewingot, töröld a kijelölését, majd jelöld ki újra a _Setup > Keyboard > Input Methods_ alatt, hogy a billentyűi oda kerüljenek; az Omarchy békén hagyja azt a motort, amellyel már gépelsz.

A gépelés latin módban indul. Nyomd meg a `Super + I` billentyűkombinációt a konfigurált beviteli módok közötti lépegetéshez, a `Super + Shift + I` kombinációt pedig a visszafelé lépegetéshez. Koppints önmagában a `Shift` billentyűre, hogy kilépj egy beviteli módból, például a Pinyinből, a latin betűkhöz, majd koppints rá újra a visszatéréshez, ahogyan a Sogou, a Microsoft Pinyin és a macOS működik; a `Shift` plusz egy betű továbbra is nagybetűt ír. Japán billentyűzeteken a 全角/半角 kapcsolja a bevitelt, a 変換 bekapcsolja, a 無変換 pedig kikapcsolja. Koreai esetén a 한/영 vált a Hangul módra, a 한자 pedig Hanja karakterekre alakít, akár dedikált billentyűi vannak a billentyűzetednek, akár Jobb Alt és Jobb Ctrl billentyűket küld értük, ahogyan sok laptop teszi, így a Jobb Alt és a Jobb Ctrl ott nem sima módosító billentyű; a diktálás ehelyett az Alt + Space kombinációval kapcsolható. A `Ctrl + Space` továbbra is elérhető marad a Tmux és a Herdr számára; a `Shift + CapsLock` továbbra is a compose billentyű marad.

A billentyűzetjelző a sáv jobb oldalán jelenik meg, ha több billentyűzetkiosztásod vagy beviteli módod van. Kattints rá a beviteli nyelvek váltásához; a japán あ karaktert jelenít meg a hiraganához. Japán karakterválasztáshoz válts japánra, írj be egy szót, például `nihongo`, majd nyomd meg kétszer a Space billentyűt. Nyomd meg az Enter billentyűt a választásod elfogadásához. Ha több billentyűzetkiosztásod is van, kattints jobb gombbal a jelzőre azok közötti lépegetéshez.

Használd a _Setup > Keyboard > Keyboard Inputs_ lehetőséget olyan kiosztások kiválasztásához, mint az angol és a francia, a telepítés során felajánlott lehetőségek közül. Használd a _Setup > Keyboard > Input Methods_ lehetőséget annak kiválasztásához, mely kompozíciós motorok legyenek aktívak. Mindkét választó az Omarchy menüben nyílik meg, az aktuális választásaid bejelölve. Kattints vagy nyomd meg az Enter billentyűt egy választás be-/kikapcsolásához; minden módosítás azonnal érvénybe lép. Egy beviteli mód kijelölésének törlése eltávolítja azt a ciklusból anélkül, hogy eltávolítaná; a billentyűzet továbbra is elérhető marad.

Futtasd az `omarchy setup keyboard` vagy az `omarchy setup input` parancsot ugyanazok a választók megnyitásához. Egy nyelv parancssorból való hozzáfűzéséhez használd az `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` vagy `cangjie5` parancsot. A Quick, a Boshiamy és az Array ugyanabban a csomagban érkezik, mint a Cangjie, és megjelenik az Input Methods választóban. Az egyéni váltóbillentyűid megmaradnak. Alternatív motorkiosztásokhoz vagy billentyűkhöz telepítsd a `fcitx5-configtool` csomagot az `omarchy pkg add fcitx5-configtool` paranccsal, és indítsd el egy terminálból. Egy beviteli nyelv kiválasztása nem módosítja az asztal nyelvét. Ha a _Setup > Language_ alatt japánt, koreait vagy kínait választasz, az hozzáadja a beviteli módját, ha még nincs egy sem.

Használd a `Super + I` billentyűkombinációt a beviteli módok vagy billentyűzetkiosztások közötti lépegetéshez, a `Super + Shift + I` kombinációt pedig a másik irányba való visszalépegetéshez, így három konfigurált elem esetén két szomszéd között mozoghatsz. A beviteli jelző csak akkor jelenik meg a sáv jobb oldalán, ha egynél több beviteli mód vagy kiosztás van konfigurálva. Ez az asztali billentyűparancs a meglévő Fcitx váltóbillentyűid mellett működik; felülírhatod a `~/.config/hypr/bindings.lua` fájlban. A beviteli motorok és a compose sorozatok a minden munkamenetben már futó [Fcitx5](https://fcitx-im.org/) szolgáltatást használják.

### Az ALT használata SUPER-ként

Egyes billentyűzeteken nem kényelmes az elsődleges meta billentyűt (Windows/cmd billentyű) SUPER-ként használni. Ezzel a módosítással ehelyett az ALT-ra cserélheted:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
