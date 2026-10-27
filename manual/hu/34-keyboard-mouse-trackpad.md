# Billentyűzet, egér, érintőpad

A Hyprland lehetővé teszi, hogy minden beviteli eszközt részletesen beállíts. A billentyűzetismétlést szuperszonikusan gyorssá teheted, vagy az érintőpadon bekapcsolhatod a természetes görgetést. Mindezt a `~/.config/hypr/input.lua` fájlban módosíthatod, amelyet az Omarchy menüben (`Super + Space`) a _Beállítás > Bevitel_ útvonalon is elérhetsz. Minden, amit ott beállítasz, felülírja az Omarchy alapértelmezéseit.

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

A beviteli beállításokról szóló Hyprland-wikiben [megnézheted az összes beviteli beállítást](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

A CapsLock normál Caps Lock billentyűként működik, a `Shift + CapsLock` pedig a kompozíciós billentyű a [gyors emojikhoz](07-hotkeys.md#quick-emojis) és [más kiegészítésekhez](07-hotkeys.md#quick-completions). Ha inkább máshová tennéd a kompozíciós billentyűt, cseréld le az `omarchy:shift_caps_compose` értéket a `kb_options` beállításban. Ez a példa például a Right Alt billentyűre teszi a kompozíciós billentyűt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Érintőpadgesztusok

Bekapcsolhatod az [érintőpadgesztusokat](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) is, például a munkaterületek váltását háromujjas legyintéssel:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Haptikus érintőpaddal felszerelt Dell XPS laptopokon a kattintás erősségét alacsonyra, közepesre vagy magasra is állíthatod a _Trigger > Hardware > Touchpad Haptics_ alatt.

### Gépelés kínaiul, japánul és más nyelveken

Válaszd a japán, koreai, kínai (egyszerűsített, Pinyin), tajvani (Zhuyin) vagy hongkongi (Cangjie) lehetőséget, amikor a telepítő a billentyűzetedről kérdez. Az Omarchy automatikusan beállítja a billentyűzetet és a hozzá illő beviteli motort, az offline első indítási beállítás során is. A japán a Mozc motort használja, a koreai a szabványos kétsoros Hangul kiosztást, az egyszerűsített kínai a Pinyin motort, Tajvan a Chewing szabványos Zhuyin kiosztását, Hongkong pedig a Cangjie motort hongkongi karakterformákkal. A japán (US billentyűzet) a Mozc motort biztosítja US billentyűzetkiosztással. A Hangul, Zhuyin és Cangjie billentyűk a szokásos helyükön maradnak akkor is, ha latin betűket Dvorak, Colemak vagy AZERTY kiosztással gépelsz. Ha korábban adtad hozzá a Hangul vagy Chewing motort, szüntesd meg a kijelölését, majd jelöld ki újra a _Beállítás > Gépelés > Beviteli módok_ alatt, hogy a billentyűi oda kerüljenek; az Omarchy békén hagyja azt a motort, amellyel már gépelsz.

A gépelés latin módban indul. A `Super + I` megnyomásával végiglépegethetsz a beállított beviteli módokon, a `Super + Shift + I` megnyomásával pedig visszafelé haladhatsz. Érintsd meg önmagában a `Shift` billentyűt, hogy egy beviteli módból, például a Pinyin módból kilépj a latin betűkhöz, majd érintsd meg ismét, hogy visszamenj, ahogyan a Sogou, a Microsoft Pinyin és a macOS működik; a `Shift` és egy betű együtt továbbra is nagybetűt ír. Japán billentyűzeteken a 全角/半角 váltja a bevitelt, a 変換 bekapcsolja, a 無変換 pedig kikapcsolja. Koreai nyelvnél a 한/영 vált a Hangul módra, a 한자 pedig Hanja karakterekre alakít, függetlenül attól, hogy a billentyűzetednek vannak-e erre dedikált billentyűi, vagy Right Alt és Right Ctrl jeleket küld értük, ahogyan sok laptop teszi, ezért a Right Alt és a Right Ctrl ott nem egyszerű módosítóbillentyű; a diktálás push-to-talk funkciója az F9 billentyűn marad. A `Ctrl + Space` továbbra is elérhető a Tmux és a Herdr számára; a `Shift + CapsLock` továbbra is a kompozíciós billentyű.

A billentyűzetjelző a sáv jobb oldalán jelenik meg, ha több billentyűzetkiosztásod vagy beviteli módod van. Kattints rá a beviteli nyelvek váltásához; a japán nyelv hiragana módban a あ jelet mutatja. Japán karakterválasztáshoz válts japánra, gépelj be egy szót, például a `nihongo` szót, majd nyomd meg kétszer a Space billentyűt. A választás elfogadásához nyomd meg az Enter billentyűt. Ha több billentyűzetkiosztásod is van, kattints jobb gombbal a jelzőre azok végigléptetéséhez.

A _Beállítás > Gépelés > Billentyűzetkiosztások_ alatt olyan kiosztásokat választhatsz, mint az angol és a francia, a telepítés során felkínált lehetőségek közül. A _Beállítás > Gépelés > Beviteli módok_ alatt választhatod ki, mely kompozíciós motorok legyenek aktívak. Mindkét választó az Omarchy menüben nyílik meg, az aktuális választásaid bejelölésével. Kattints egy lehetőségre, vagy nyomd meg rajta az Enter billentyűt a ki- és bekapcsolásához; minden módosítás azonnal érvénybe lép. Egy beviteli mód kijelölésének megszüntetése eltávolítja azt a ciklusból anélkül, hogy eltávolítaná a rendszerből; a billentyűzet továbbra is elérhető marad.

Futtasd az `omarchy setup keyboard` vagy az `omarchy setup input` parancsot ugyanazok a választók megnyitásához. Ha a parancssorból szeretnél hozzáadni egy nyelvet, használd az `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` vagy `cangjie5` parancsot. A Quick, a Boshiamy és az Array ugyanabban a csomagban érkezik, mint a Cangjie, és megjelenik a Beviteli módok választóban. Az egyéni váltóbillentyűid megmaradnak. Alternatív motorkiosztásokért vagy billentyűkért telepítsd a `fcitx5-configtool` csomagot az `omarchy pkg add fcitx5-configtool` paranccsal, és indítsd el egy terminálból. Egy beviteli nyelv kiválasztása nem változtatja meg az asztali környezet nyelvét. Ha a _Beállítás > Nyelv_ alatt japán, koreai vagy kínai nyelvet választasz, az hozzáadja annak beviteli módját, ha még nincs ilyened.

A `Super + I` billentyűkombinációval előre, a `Super + Shift + I` billentyűkombinációval pedig visszafelé lépegethetsz a beviteli módok vagy billentyűzetkiosztások között, így három beállított lehetőség esetén két szomszédos lehetőség között mozoghatsz. A beviteli jelző csak akkor jelenik meg a sáv jobb oldalán, ha egynél több beviteli mód vagy kiosztás van beállítva. Ez az asztali billentyűparancs a meglévő Fcitx váltóbillentyűid mellett működik; felülírhatod a `~/.config/hypr/bindings.lua` fájlban. A beviteli motorok és a kompozíciós sorozatok minden munkamenetben már futó [Fcitx5](https://fcitx-im.org/) szolgáltatást használnak.

### Az ALT használata SUPER helyett

Egyes billentyűzeteken nem kényelmes az elsődleges metabilletűt (Windows/cmd billentyűt) SUPER billentyűként használni. Ezzel a módosítással ehelyett az ALT billentyűt használhatod:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
