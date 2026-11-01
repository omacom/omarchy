# Billentyűzet, egér, érintőpad

A Hyprland lehetővé teszi, hogy minden beviteli eszközödet részletesen beállítsd. Beállíthatod, hogy a billentyűzetismétlés szuperszonikusan gyors legyen, vagy hogy az érintőpad természetes görgetést használjon. Mindezt a `~/.config/hypr/input.lua` fájlban módosíthatod, amelyet az Omarchy menüben (`Super + Space`) a _Setup > Input_ útvonalon is elérhetsz. Amit ott beállítasz, felülírja az Omarchy alapértelmezéseit.

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

A Hyprland wikin [megnézheted az összes beviteli beállítást](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

A CapsLock normál Caps Lockként működik, a `Shift + CapsLock` pedig a compose billentyű a [gyors emojikhoz](07-hotkeys.md#quick-emojis) és a [gyors kiegészítésekhez](07-hotkeys.md#quick-completions). Ha inkább máshová tennéd a compose billentyűt, cseréld le az `omarchy:shift_caps_compose` értéket a `kb_options` beállításban. Ez például a Right Alt billentyűre teszi a compose billentyűt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkcióbillentyűk

A laptop billentyűzetének felső sora alapértelmezetten a médiabillentyűket (hangerő, fényerő és így tovább) küldi, az `Fn` nyomva tartásával pedig az F1-F12 billentyűket érheted el; az `Fn + Esc` az ellenkező irányba rögzíti ezt, amíg újra meg nem nyomod. A legtöbb billentyűzet maga megjegyzi ezt a zárolást. Az ASUS laptopok és az Apple-stílusú billentyűzetek ezt a Linuxra hagyják, amely minden rendszerindításkor a médiabillentyűkkel indítja őket. Ha azt szeretnéd, hogy ehelyett az F1-F12 billentyűkkel induljanak, futtasd az `omarchy keyboard toprow fnkeys` parancsot (a visszaállításhoz pedig az `omarchy keyboard toprow mediakeys` parancsot); egyes laptopokon ez újraindítás után lép érvénybe. Az Apple Silicon Mac gépek megtartják a saját beállításukat.

### Érintőpados gesztusok

Csúsztasd az ujjad az érintőpadon az asztalon való mozgáshoz:

| Gesztus | Művelet |
| --- | --- |
| Három ujj balra / jobbra | Előző / következő munkaterület, az üreseket is beleértve |
| Három ujj felfelé | Az AI-konzol be-/kikapcsolása |
| Három ujj lefelé | Az Omarchy menü megnyitása |
| Négy ujj balra / jobbra | Az aktív ablak áthelyezése az előző / következő munkaterületre |
| Négy ujj lefelé | Teljes képernyős mód be-/kikapcsolása |

Egy gesztus megváltoztatásához először vedd ki azt a `~/.config/hypr/input.lua` fájlban, mielőtt hozzáadnád a saját [érintőpados gesztusodat](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), mivel a Hyprland nem fogad el két gesztust ugyanazokra az ujjakra és ugyanabba az irányba:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Az Omarchy összes gesztusának kikapcsolásához állítsd be az `omarchy_default_gestures = false` értéket a `~/.config/hypr/hyprland.lua` fájl tetejének közelében, még az Omarchy alapértelmezéseinek betöltése előtt.

A haptikus érintőpaddal szerelt Dell XPS laptopokon a kattintási erősséget alacsonyra, közepesre vagy magasra is állíthatod a _Trigger > Hardware > Touchpad Haptics_ alatt.

### Gépelés kínaiul, japánul és más nyelveken

Válaszd a japánt, a koreait, a kínait (egyszerűsített, Pinyin), a tajvanit (Zhuyin) vagy a hongkongit (Cangjie), amikor a telepítő a billentyűzetedről kérdez. Az Omarchy automatikusan beállítja a billentyűzetet és a hozzá illő beviteli motort, beleértve az offline első rendszerindítási beállítást is. A japán a Mozc motort használja, a koreai a szabványos kétkészletes Hangult, az egyszerűsített kínai a Pinyint, Tajvan a Chewing szabványos Zhuyin kiosztását, Hongkong pedig a Cangjie-t hongkongi karakterformákkal. A japán (US billentyűzet) US billentyűzetkiosztással biztosítja a Mozc motort. A Hangul, a Zhuyin és a Cangjie billentyűi a szabványos helyükön maradnak akkor is, ha latin betűket Dvorak, Colemak vagy AZERTY kiosztással gépelsz. Ha korábban adtad hozzá a Hangult vagy a Chewingot, a _Setup > Keyboard > Input Methods_ alatt vedd ki, majd válaszd ki újra, hogy a billentyűi oda kerüljenek; azt a motort, amellyel már gépelsz, az Omarchy békén hagyja.

A gépelés latin módban indul. Nyomd meg a `Super + I` billentyűkombinációt a beállított beviteli módok közötti lépegetéshez, a `Super + Shift + I` kombinációt pedig a visszafelé lépegetéshez. Nyomd meg önmagában röviden a `Shift` billentyűt, hogy kilépj egy olyan beviteli módból, mint a Pinyin, a latin betűkhöz, majd nyomd meg újra röviden a visszatéréshez, ahogyan a Sogou, a Microsoft Pinyin és a macOS is működik; a `Shift` és egy betű együtt továbbra is nagybetűt ír. Japán billentyűzeteken a 全角/半角 kapcsolja a bevitelt, a 変換 bekapcsolja, a 無変換 pedig kikapcsolja. Koreai használatakor a 한/영 váltja a Hangult, a 한자 pedig Hanja karakterekre alakít, akár dedikált billentyűi vannak a billentyűzetednek, akár a Right Alt és a Right Ctrl billentyűket küldi értük, ahogyan sok laptop teszi, ezért a Right Alt és a Right Ctrl ott nem sima módosítóbillentyű; ehelyett a diktálás az Alt + Space billentyűkombinációval kapcsolható. A `Ctrl + Space` továbbra is elérhető marad a Tmux és a Herdr számára; a `Shift + CapsLock` továbbra is a compose billentyű marad.

A billentyűzetjelző a sáv jobb oldalán jelenik meg, ha több billentyűzetkiosztásod vagy beviteli módod van. Kattints rá a beviteli nyelvek közötti váltáshoz; a japán あ karaktert jelenít meg a hiraganához. Japán karakterválasztáshoz válts japánra, gépelj be egy szót, például `nihongo`, majd nyomd meg kétszer a Space billentyűt. Nyomd meg az Enter billentyűt a választásod elfogadásához. Ha több billentyűzetkiosztásod is van, kattints jobb gombbal a jelzőre azok közötti lépegetéshez.

Használd a _Setup > Keyboard > Keyboard Inputs_ lehetőséget olyan kiosztások kiválasztásához, mint az angol és a francia, ugyanazok közül a lehetőségek közül, amelyeket a telepítés során is felkínál a rendszer. Használd a _Setup > Keyboard > Input Methods_ lehetőséget annak kiválasztásához, mely kompozíciós motorok aktívak. Mindkét választó az Omarchy menüben nyílik meg, az aktuális választásaid bejelölésével. Kattints vagy nyomd meg az Enter billentyűt egy választás be-/kikapcsolásához; minden változtatás azonnal érvénybe lép. Egy beviteli mód kiválasztásának visszavonása eltávolítja azt a ciklusból anélkül, hogy eltávolítaná a rendszerből; a billentyűzet továbbra is elérhető marad.

Futtasd az `omarchy setup keyboard` vagy az `omarchy setup input` parancsot ugyanazok a választók megnyitásához. Egy nyelv parancssorból való hozzáfűzéséhez használd az `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` vagy `cangjie5` parancsot. A Quick, a Boshiamy és az Array ugyanabban a csomagban érkezik, mint a Cangjie, és megjelenik az Input Methods választóban. Az egyéni váltóbillentyűid megmaradnak. Alternatív motorkiosztásokhoz vagy billentyűkhöz telepítsd a `fcitx5-configtool` csomagot az `omarchy pkg add fcitx5-configtool` paranccsal, és indítsd el egy terminálból. Egy beviteli nyelv kiválasztása nem változtatja meg az asztal nyelvét. Ha a _Setup > Language_ alatt japánt, koreait vagy kínait választasz, az hozzáadja annak beviteli módját, ha még egy sincs.

Használd a `Super + I` billentyűkombinációt a beviteli módok vagy billentyűzetkiosztások közötti lépegetéshez, a `Super + Shift + I` kombinációt pedig az ellenkező irányba való lépegetéshez, így három beállított elem esetén két szomszéd között mozoghatsz. A beviteli jelző csak akkor jelenik meg a sáv jobb oldalán, ha egynél több beviteli mód vagy kiosztás van beállítva. Ez az asztali billentyűparancs a meglévő Fcitx váltóbillentyűid mellett működik; felülírhatod a `~/.config/hypr/bindings.lua` fájlban. A beviteli motorok és a compose sorozatok a minden munkamenetben már futó [Fcitx5](https://fcitx-im.org/) szolgáltatást használják.

### Az ALT használata SUPER-ként

Egyes billentyűzeteken nem kényelmes az elsődleges meta billentyűt (Windows/cmd billentyű) SUPER-ként használni. Ezzel a módosítással ehelyett az ALT-ra cserélheted:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
