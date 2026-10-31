# Billentyűzet, Egér, Érintőpad

A Hyprland lehetővé teszi, hogy minden bemeneti eszközödet részletesen beállítsd. A billentyűzetismétlést szuperszonikusan gyorsra állíthatod, vagy bekapcsolhatod az érintőpadon a természetes görgetést. Mindezt a `~/.config/hypr/input.lua` fájlban változtatod meg, amelyet az Omarchy menüből (`Super + Space`) a _Setup > Input_ útvonalon is elérhetsz. Amit ott beállítasz, felülírja az Omarchy alapértelmezéseit.

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

A Hyprland bemenetekről szóló wikijén [megtekintheted az összes bemeneti beállítást](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

A CapsLock normál Caps Lockként működik, a `Shift + CapsLock` pedig a compose billentyű a [gyors emojikhoz](07-hotkeys.md#quick-emojis) és [egyéb kiegészítésekhez](07-hotkeys.md#quick-completions). Ha inkább máshol szeretnéd a compose billentyűt, cseréld le a `kb_options` értékében az `omarchy:shift_caps_compose` részt. Ez például a Right Alt billentyűre teszi a compose billentyűt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Érintőpados gesztusok

Csúsztass az érintőpadon az asztalon való mozgáshoz:

| Gesztus | Művelet |
| --- | --- |
| Három ujj balra / jobbra | Előző / következő munkaterület, az üreseket is beleértve |
| Három ujj felfelé | Az AI-konzol ki-/bekapcsolása |
| Három ujj lefelé | Az Omarchy menü megnyitása |
| Négy ujj balra / jobbra | Az aktív ablak áthelyezése az előző / következő munkaterületre |
| Négy ujj lefelé | Teljes képernyő ki-/bekapcsolása |

Ha valamelyiket meg akarod változtatni, töröld a `~/.config/hypr/input.lua` fájlban, mielőtt hozzáadod a saját [érintőpados gesztusodat](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), mivel a Hyprland nem fogad el két gesztust ugyanazokkal az ujjakkal és ugyanabban az irányban:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Az Omarchy összes gesztusának kikapcsolásához állítsd az `omarchy_default_gestures = false` értéket a `~/.config/hypr/hyprland.lua` fájl tetejének közelébe, még az Omarchy alapértelmezéseinek betöltődése előtt.

Haptikus érintőpaddal rendelkező Dell XPS laptopokon a kattintás erősségét alacsonyra, közepesre vagy magasra is beállíthatod a _Trigger > Hardware > Touchpad Haptics_ alatt.

### Gépelés kínaiul, japánul és más nyelveken

Válaszd a japánt, a koreait, a kínait (egyszerűsített, Pinyin), a tajvanit (Zhuyin) vagy a hongkongit (Cangjie), amikor a telepítő a billentyűzetedről kérdez. Az Omarchy automatikusan beállítja a billentyűzetet és a hozzá illő beviteli motort, az offline első indításkori beállítás során is. A japán a Mozc motort használja, a koreai a szabványos kétkészletes Hangul kiosztást, az egyszerűsített kínai a Pinyint, Tajvan a Chewing szabványos Zhuyin kiosztását, Hongkong pedig a Cangjie motort hongkongi karakterformákkal. A Japanese (US keyboard) a Mozc motort adja US billentyűzetkiosztással. A Hangul, Zhuyin és Cangjie billentyűk a szabványos helyükön maradnak akkor is, ha latin betűket Dvorak, Colemak vagy AZERTY kiosztással gépelsz. Ha korábban már hozzáadtad a Hangul vagy a Chewing motort, töröld a jelölését, majd jelöld ki újra a _Setup > Typing > Input Methods_ alatt, hogy a billentyűi oda kerüljenek; az Omarchy békén hagyja azt a motort, amellyel már gépelsz.

A gépelés latin módban indul. Nyomd meg a `Super + I` billentyűkombinációt a beállított beviteli módok közötti előre léptetéshez, a `Super + Shift + I` kombinációt pedig a visszafelé léptetéshez. Érintsd meg önmagában a `Shift` billentyűt, hogy egy olyan beviteli módból, mint a Pinyin, kilépj a latin betűkhöz, majd érintsd meg újra a visszalépéshez, ahogyan a Sogou, a Microsoft Pinyin és a macOS működik; a `Shift` egy betűvel együtt továbbra is nagybetűt ír. Japán billentyűzeteken a 全角/半角 kapcsolja a bevitelt, a 変換 bekapcsolja, a 無変換 pedig kikapcsolja. Koreai esetén a 한/영 kapcsolja a Hangult, a 한자 pedig Hanja karakterekre alakít, akár dedikált billentyűi vannak a billentyűzetednek, akár a Right Alt és a Right Ctrl billentyűket küldi értük, ahogyan sok laptop teszi, így a Right Alt és a Right Ctrl ott nem sima módosító billentyű; a diktálás push-to-talk funkciója az F9 billentyűn marad. A `Ctrl + Space` továbbra is elérhető a Tmux és a Herdr számára; a `Shift + CapsLock` marad a compose billentyű.

A billentyűzetjelző a sáv jobb oldalán jelenik meg, ha több billentyűzetkiosztásod vagy beviteli módod van. Kattints rá a beviteli nyelvek közötti váltáshoz; a japán あ karaktert jelenít meg a hiragana jelölésére. Japán karakterválasztáshoz válts japánra, gépelj be egy szót, például `nihongo`, majd nyomd meg kétszer a Space billentyűt. Nyomd meg az Enter billentyűt a választásod elfogadásához. Ha több billentyűzetkiosztásod is van, kattints jobb gombbal a jelzőre azok közötti léptetéshez.

A _Setup > Typing > Keyboard Layouts_ segítségével olyan kiosztásokat választhatsz ki, mint az angol és a francia, ugyanazok közül a lehetőségek közül, amelyeket a telepítés során is felkínál a rendszer. A _Setup > Typing > Input Methods_ segítségével választhatod ki, mely összeállító motorok legyenek aktívak. Mindkét választó az Omarchy menün belül nyílik meg, az aktuális választásaid bejelölésével. Kattints vagy nyomd meg az Enter billentyűt egy lehetőség ki-/bekapcsolásához; minden változtatás azonnal érvénybe lép. Egy beviteli mód jelölésének törlése eltávolítja azt a léptetési körből anélkül, hogy eltávolítaná a rendszerből; a billentyűzet továbbra is elérhető marad.

Futtasd az `omarchy setup keyboard` vagy az `omarchy setup input` parancsot ugyanazok a választók megnyitásához. Egy nyelv parancssorból való hozzáfűzéséhez használd az `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` vagy `cangjie5` parancsot. A Quick, a Boshiamy és az Array a Cangjie csomagjával együtt érkezik, és megjelenik az Input Methods választóban. Az egyéni váltóbillentyűid megmaradnak. Alternatív motorkiosztásokhoz vagy billentyűkhöz telepítsd az `fcitx5-configtool` csomagot az `omarchy pkg add fcitx5-configtool` paranccsal, és indítsd el egy terminálból. Egy beviteli nyelv kiválasztása nem változtatja meg az asztal nyelvét. Ha a _Setup > Language_ alatt japánt, koreait vagy kínait választasz, a rendszer hozzáadja annak beviteli módját, ha még egy sincs.

Használd a `Super + I` billentyűkombinációt a beviteli módok vagy billentyűzetkiosztások közötti előre léptetéshez, a `Super + Shift + I` kombinációt pedig a visszafelé léptetéshez, így három beállított lehetőség esetén két szomszéd között mozoghatsz. A beviteli jelző csak akkor jelenik meg a sáv jobb oldalán, ha egynél több beviteli mód vagy kiosztás van beállítva. Ez az asztali billentyűkötés a meglévő Fcitx váltóbillentyűid mellett működik; felülírhatod a `~/.config/hypr/bindings.lua` fájlban. A beviteli motorok és a compose sorozatok a minden munkamenetben már futó [Fcitx5](https://fcitx-im.org/) szolgáltatást használják.

### Az ALT használata SUPER helyett

Egyes billentyűzeteken nem kényelmes az elsődleges meta billentyűt (Windows/cmd billentyű) SUPER-ként használni. Ezzel a módosítással ehelyett az ALT billentyűre cserélheted:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
