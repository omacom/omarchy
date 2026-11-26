# Billentyűzet, egér, érintőpad

A Hyprland lehetővé teszi az összes beviteli eszközöd részletes beállítását. A billentyűzet ismétlését szuperszonikusan gyorsra állíthatod, vagy beállíthatod, hogy az érintőpad természetes görgetést használjon. Mindezt a `~/.config/hypr/input.lua` fájlban módosíthatod, amelyet az Omarchy menü (`Super + Space`) _Setup > Input_ pontján keresztül is elérhetsz. Amit ott beállítasz, felülírja az Omarchy alapértelmezéseit.

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

A Hyprland beviteli wikijében [megnézheted az összes beviteli lehetőséget](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

A CapsLock normál Caps Lockként működik, a `Shift + CapsLock` pedig a compose billentyű a [gyors emojikhoz](07-hotkeys.md#quick-emojis) és [egyéb kiegészítésekhez](07-hotkeys.md#quick-completions). Ha inkább máshová tennéd a compose billentyűt, cseréld le az `omarchy:shift_caps_compose` értéket a `kb_options` beállításban. Ez a példa például a Right Alt billentyűre teszi a compose billentyűt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkcióbillentyűk

Egy laptopbillentyűzet felső sora alapértelmezetten a médiabillentyűket (hangerő, fényerő és így tovább) küldi, az `Fn` nyomva tartásával pedig az F1-F12 érhető el; az `Fn + Esc` ezt fordítva zárolja, amíg újra meg nem nyomod. A legtöbb billentyűzet maga megjegyzi ezt a zárolást. Az ASUS laptopok és az Apple-stílusú billentyűzetek a Linuxra hagyják ezt, amely minden rendszerindításkor a médiabillentyűkkel indítja őket. Ha azt szeretnéd, hogy helyette az F1-F12 billentyűkkel induljanak, futtasd az `omarchy device keyboard toprow fnkeys` parancsot (a visszatéréshez pedig az `omarchy device keyboard toprow mediakeys` parancsot); egyes laptopokon ez újraindítás után lép érvénybe. Az Apple Silicon Mac gépek megtartják a saját beállításukat.

### Érintőpados gesztusok

Húzd az ujjad az érintőpadon az asztalon való mozgáshoz:

| Gesztus | Művelet |
| --- | --- |
| Három ujj balra / jobbra | Előző / következő munkaterület, az üreseket is beleértve |
| Három ujj felfelé | Az AI-konzol ki-/bekapcsolása |
| Három ujj lefelé | Az Omarchy menü megnyitása |
| Négy ujj balra / jobbra | Az aktív ablak áthelyezése az előző / következő munkaterületre |
| Négy ujj lefelé | Teljes képernyős mód ki-/bekapcsolása |

Ha meg szeretnél változtatni egyet, előbb töröld azt a `~/.config/hypr/input.lua` fájlban, mielőtt hozzáadod a saját [érintőpados gesztusodat](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), mivel a Hyprland nem fogad el két gesztust ugyanazokra az ujjakra és ugyanabba az irányba:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Az Omarchy összes gesztusának kikapcsolásához állítsd az `omarchy_default_gestures = false` értéket a `~/.config/hypr/hyprland.lua` fájl teteje közelébe, még az Omarchy alapértelmezéseinek betöltése előtt.

A haptikus érintőpaddal rendelkező Dell XPS laptopokon a kattintás erősségét alacsonyra, közepesre vagy magasra is állíthatod a _Trigger > Hardware > Touchpad Haptics_ alatt.

### Gépelés kínaiul, japánul és más nyelveken

Válaszd a japánt, a koreait, a kínait (egyszerűsített, Pinyin), a tajvanit (Zhuyin) vagy a hongkongit (Cangjie), amikor a telepítő a billentyűzetedről kérdez. Az Omarchy automatikusan beállítja a billentyűzetet és a hozzá illő beviteli motort, az offline első indításos beállítás során is. A japán a Mozc motort használja, a koreai a szabványos kétsoros Hangul kiosztást, az egyszerűsített kínai a Pinyint, Tajvan a Chewing szabványos Zhuyin kiosztását, Hongkong pedig a Cangjie motort hongkongi karakterformákkal. A Japanese (US keyboard) a Mozc motort adja US billentyűzetkiosztással. A Hangul, Zhuyin és Cangjie billentyűk a szabványos helyükön maradnak akkor is, ha latin betűket Dvorak, Colemak vagy AZERTY kiosztással gépelsz. Ha a Hangul vagy a Chewing motort ezelőtt adtad hozzá, töröld a kijelölését, majd jelöld ki újra a _Setup > Keyboard > Input Methods_ alatt, hogy a billentyűi oda kerüljenek; egy olyan motort, amellyel már gépelsz, az Omarchy békén hagy.

A gépelés Latin módban indul. Nyomd meg a `Super + I` billentyűkombinációt a beállított beviteli módok közötti lépegetéshez, a `Super + Shift + I` billentyűkombinációt pedig a visszafelé lépegetéshez. Koppints önmagában a `Shift` billentyűre, hogy kilépj egy beviteli módból, például a Pinyinből, a latin betűkhöz, és koppints rá újra a visszatéréshez, ahogyan a Sogou, a Microsoft Pinyin és a macOS működik; a `Shift` plusz egy betű továbbra is nagybetűt ír. Japán billentyűzeteken a 全角/半角 kapcsolja át a bevitelt, a 変換 kapcsolja be, a 無変換 pedig kikapcsolja. Koreai esetén a 한/영 váltja a Hangult, a 한자 pedig Hanjára alakít, függetlenül attól, hogy a billentyűzetednek vannak-e dedikált billentyűi, vagy Right Alt és Right Ctrl jelet küld értük, ahogyan sok laptop teszi, így a Right Alt és a Right Ctrl ott nem sima módosítóbillentyű; a diktálás helyette az Alt + Space billentyűkombinációval kapcsolható. A `Ctrl + Space` továbbra is elérhető marad a Tmux és a Herdr számára; a `Shift + CapsLock` továbbra is a compose billentyű.

A billentyűzetjelző a sáv jobb oldalán jelenik meg, ha több billentyűzetkiosztásod vagy beviteli módod van. Kattints rá a beviteli nyelvek váltásához; a japán hiragana esetén あ karaktert jelenít meg. Japán karakterválasztáshoz válts japánra, gépelj be egy szót, például `nihongo`, majd nyomd meg kétszer a Space billentyűt. Nyomd meg az Enter billentyűt a választásod elfogadásához. Ha több billentyűzetkiosztásod is van, kattints jobb gombbal a jelzőre azok közötti lépegetéshez.

A _Setup > Keyboard > Keyboard Inputs_ alatt választhatsz kiosztásokat, például az angolt és a franciát, ugyanazok közül a lehetőségek közül, amelyeket a telepítés során felkínált a rendszer. A _Setup > Keyboard > Input Methods_ alatt választhatod ki, mely összeállító motorok legyenek aktívak. Mindkét választó az Omarchy menün belül nyílik meg, az aktuális kijelöléseid bejelölésével. Kattints vagy nyomd meg az Enter billentyűt egy lehetőség átkapcsolásához; minden változtatás azonnal érvénybe lép. Egy beviteli mód kijelölésének törlése eltávolítja azt a ciklusból anélkül, hogy eltávolítaná a rendszerből; a billentyűzet továbbra is elérhető marad.

Futtasd az `omarchy setup keyboard` vagy az `omarchy setup input` parancsot ugyanazok a választók megnyitásához. Egy nyelv parancssorból való hozzáfűzéséhez használd az `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` vagy `cangjie5` parancsot. A Quick, a Boshiamy és az Array a Cangjie csomagjával együtt érkezik, és megjelenik az Input Methods választóban. Az egyéni váltóbillentyűid megmaradnak. Alternatív motorkiosztásokhoz vagy billentyűkhöz telepítsd az `fcitx5-configtool` eszközt az `omarchy pkg add fcitx5-configtool` paranccsal, és indítsd el egy terminálból. Egy beviteli nyelv kiválasztása nem változtatja meg az asztal nyelvét. Ha a _Setup > Region > Language_ alatt japánt, koreait vagy kínait választasz, az hozzáadja annak beviteli módját, ha még egy sincs.

Használd a `Super + I` billentyűkombinációt a beviteli módok vagy billentyűzetkiosztások közötti lépegetéshez, a `Super + Shift + I` billentyűkombinációt pedig az ellenkező irányba való lépegetéshez, így három beállított elem esetén két szomszéd között mozoghatsz. A beviteli jelző csak akkor jelenik meg a sáv jobb oldalán, ha egynél több beviteli mód vagy kiosztás van beállítva. Ez az asztali billentyűkötés a meglévő Fcitx váltóbillentyűid mellett működik; felülírhatod a `~/.config/hypr/bindings.lua` fájlban. A beviteli motorok és a compose sorozatok a minden munkamenetben már futó [Fcitx5](https://fcitx-im.org/) szolgáltatást használják.

### Az ALT használata SUPER-ként

Egyes billentyűzeteken nem kényelmes az elsődleges meta billentyűt (Windows/cmd billentyűt) SUPER-ként használni. Ezzel a módosítással helyette az ALT-ra cserélheted:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
