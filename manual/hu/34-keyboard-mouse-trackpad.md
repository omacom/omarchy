# Billentyűzet, egér, érintőpad

A Hyprland lehetővé teszi, hogy minden beviteli eszközödet részletesen beállítsd. Megteheted, hogy a billentyűismétlés szuperszonikus sebességű legyen, vagy beállíthatod, hogy az érintőpad természetes görgetést használjon. Mindezt a `~/.config/hypr/input.lua` fájlban módosíthatod, amelyet az Omarchy menüben (`Super + Space`) a _Setup > Input_ útvonalon is elérhetsz. Bármi, amit ott beállítasz, felülírja az Omarchy alapértelmezéseit.

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

A Hyprland wiki beviteli oldalán [megnézheted az összes beviteli lehetőséget](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

A CapsLock normál Caps Lockként működik, a `Shift + CapsLock` pedig a compose billentyű a [gyors emojikhoz](07-hotkeys.md#quick-emojis) és a [más kiegészítésekhez](07-hotkeys.md#quick-completions). Ha inkább máshová tennéd a compose billentyűt, cseréld le az `omarchy:shift_caps_compose` értéket a `kb_options` beállításban. Ez a példa például a Right Alt billentyűre teszi a compose billentyűt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Érintőpadgesztusok

Húzd az ujjad az érintőpadon, hogy mozogj az asztalon:

| Gesztus | Művelet |
| --- | --- |
| Három ujj balra / jobbra | Előző / következő munkaterület, az üreseket is beleértve |
| Három ujj fel | Az AI-konzol be-/kikapcsolása |
| Három ujj le | Az Omarchy menü megnyitása |
| Négy ujj balra / jobbra | Az aktív ablak áthelyezése az előző / következő munkaterületre |
| Négy ujj le | A teljes képernyős mód be-/kikapcsolása |

Ha meg akarsz változtatni egyet, előbb vedd ki a `~/.config/hypr/input.lua` fájlban, mielőtt hozzáadod a saját [érintőpadgesztusodat](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), mivel a Hyprland nem fogad el két gesztust ugyanazokra az ujjakra és ugyanabba az irányba:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Ha ki akarod kapcsolni az Omarchy összes gesztusát, állítsd az `omarchy_default_gestures = false` értéket a `~/.config/hypr/hyprland.lua` fájl teteje közelében, még azelőtt, hogy az Omarchy alapértelmezései betöltődnének.

A haptikus érintőpaddal rendelkező Dell XPS laptopokon a kattintás erősségét alacsony, közepes vagy magas értékre is beállíthatod a _Trigger > Hardware > Touchpad Haptics_ alatt.

### Gépelés kínaiul, japánul és más nyelveken

Válaszd a japánt, a koreait, a kínait (egyszerűsített, Pinyin), a tajvanit (Zhuyin) vagy a hongkongit (Cangjie), amikor a telepítő a billentyűzetedről kérdez. Az Omarchy automatikusan beállítja a billentyűzetet és a hozzá illő beviteli motort, az offline első indításkori beállítás során is. A japán a Mozc motort használja, a koreai a szabványos kétkészletes Hangul elrendezést, az egyszerűsített kínai a Pinyin motort, Tajvan a Chewing szabványos Zhuyin elrendezését, Hongkong pedig a Cangjie motort hongkongi karakterformákkal. A japán (US billentyűzet) Mozc motort biztosít US billentyűzetkiosztással. A Hangul, a Zhuyin és a Cangjie billentyűi a szabványos helyükön maradnak akkor is, ha latin betűket Dvorak, Colemak vagy AZERTY kiosztással gépelsz. Ha a Hangul vagy a Chewing motort ezelőtt adtad hozzá, vedd ki, majd válaszd ki újra a _Setup > Typing > Input Methods_ alatt, hogy a billentyűi oda kerüljenek; egy olyan motort, amellyel már gépelsz, az Omarchy békén hagy.

A gépelés latin módban indul. Nyomd meg a `Super + I` billentyűkombinációt a beállított beviteli módok közötti lépegetéshez, a `Super + Shift + I` kombinációt pedig a visszafelé lépegetéshez. Nyomd meg önmagában a `Shift` billentyűt, hogy egy olyan beviteli módból, mint a Pinyin, kilépj a latin betűkhöz, majd nyomd meg újra a visszatéréshez, ahogyan a Sogou, a Microsoft Pinyin és a macOS működik; a `Shift` és egy betű együtt továbbra is nagybetűt ír. Japán billentyűzeteken a 全角/半角 kapcsolja a bevitelt, a 変換 bekapcsolja, a 無変換 pedig kikapcsolja. Koreai esetén a 한/영 vált Hangul módra, a 한자 pedig Hanja karakterekre konvertál, akár dedikált billentyűi vannak a billentyűzetednek, akár a Right Alt és a Right Ctrl billentyűt küldi értük, ahogyan sok laptop teszi, így ott a Right Alt és a Right Ctrl nem egyszerű módosító billentyűk; a diktálás ehelyett az Alt + Space kombinációval kapcsolható. A `Ctrl + Space` továbbra is elérhető marad a Tmux és a Herdr számára; a `Shift + CapsLock` továbbra is a compose billentyű.

A billentyűzetjelző a sáv jobb oldalán jelenik meg, ha több billentyűzetkiosztásod vagy beviteli módod van. Kattints rá a beviteli nyelvek váltásához; a japán あ karaktert jelenít meg hiragana esetén. Japán karakterválasztáshoz válts japánra, gépelj be egy szót, például `nihongo`, majd nyomd meg kétszer a Space billentyűt. Nyomd meg az Enter billentyűt a választásod elfogadásához. Ha több billentyűzetkiosztásod is van, kattints jobb gombbal a jelzőre azok közötti lépegetéshez.

A _Setup > Typing > Keyboard Layouts_ alatt választhatsz olyan kiosztásokat, mint az angol és a francia, ugyanazok közül a lehetőségek közül, amelyeket a telepítés során is felkínál a rendszer. A _Setup > Typing > Input Methods_ alatt választhatod ki, mely összetételi motorok aktívak. Mindkét választó az Omarchy menüben nyílik meg, az aktuális kiválasztásaid bejelölve. Kattints vagy nyomd meg az Enter billentyűt egy lehetőség ki-/bekapcsolásához; minden változtatás azonnal érvénybe lép. Egy beviteli mód kiválasztásának visszavonása eltávolítja azt a ciklusból anélkül, hogy eltávolítaná a rendszerből; a billentyűzet továbbra is elérhető marad.

Futtasd az `omarchy setup keyboard` vagy az `omarchy setup input` parancsot ugyanazok a választók megnyitásához. Egy nyelv parancssorból való hozzáfűzéséhez használd az `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` vagy `cangjie5` parancsot. A Quick, a Boshiamy és az Array ugyanabban a csomagban érkezik, mint a Cangjie, és megjelenik az Input Methods választóban. Az egyéni váltóbillentyűid megmaradnak. Alternatív motorkiosztásokhoz vagy billentyűkhöz telepítsd az `fcitx5-configtool` csomagot az `omarchy pkg add fcitx5-configtool` paranccsal, és indítsd el egy terminálból. Egy beviteli nyelv kiválasztása nem változtatja meg az asztal nyelvét. Ha a _Setup > Language_ alatt japánt, koreait vagy kínait választasz, az hozzáadja annak beviteli módját, ha még nincs ilyened.

Használd a `Super + I` billentyűkombinációt a beviteli módok vagy billentyűzetkiosztások közötti lépegetéshez, a `Super + Shift + I` kombinációt pedig az ellenkező irányba való visszalépegetéshez, így három beállított lehetőség esetén két szomszéd között mozoghatsz. A beviteli jelző csak akkor jelenik meg a sáv jobb oldalán, ha egynél több beviteli mód vagy kiosztás van beállítva. Ez az asztali billentyűparancs a meglévő Fcitx váltóbillentyűid mellett működik; felülírhatod a `~/.config/hypr/bindings.lua` fájlban. A beviteli motorok és a compose sorozatok a minden munkamenetben már futó [Fcitx5](https://fcitx-im.org/) szolgáltatást használják.

### Az ALT használata SUPER-ként

Egyes billentyűzeteken nem kényelmes az elsődleges meta billentyűt (Windows/cmd billentyű) SUPER-ként használni. Ezzel a módosítással ehelyett az ALT billentyűre cserélheted:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
