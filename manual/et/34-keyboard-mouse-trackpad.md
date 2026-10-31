# Klaviatuur, hiir, puuteplaat

Hyprland võimaldab sul kõiki sisendeid väga üksikasjalikult seadistada. Saad muuta klaviatuuri korduse ülehelikiirusel kiireks või panna puuteplaadi kasutama loomulikku kerimist. Kõike seda muudad failis `~/.config/hypr/input.lua`, kuhu pääsed ka Omarchy menüüs (`Super + Space`) valiku _Seadistus > Sisend_ kaudu. Kõik, mis sa seal määrad, asendab Omarchy vaikesätted.

Siin on näide:

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

Kõiki sisendivalikuid saad [vaadata Hyprlandi wikist](https://wiki.hypr.land/Configuring/Basics/Variables/#input) sisendite kohta.

CapsLock töötab tavalise Caps Lock klahvina ja `Shift + CapsLock` on koostamisklahv [kiirete emojide](07-hotkeys.md#quick-emojis) ja [muude täienduste](07-hotkeys.md#quick-completions) jaoks. Kui eelistad koostamisklahvi mujale, asenda `kb_options` all `omarchy:shift_caps_compose`. Näiteks see liigutab koostamisklahvi Right Alt peale:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Puuteplaadi žestid

Libista puuteplaadil, et töölaual ringi liikuda:

| Žest | Toiming |
| --- | --- |
| Kolm sõrme vasakule / paremale | Eelmine / järgmine tööala, sealhulgas tühjad |
| Kolm sõrme üles | AI-konsooli sisse-/väljalülitamine |
| Kolm sõrme alla | Omarchy menüü avamine |
| Neli sõrme vasakule / paremale | Aktiivse akna liigutamine eelmisele / järgmisele tööalale |
| Neli sõrme alla | Täisekraani sisse-/väljalülitamine |

Žesti muutmiseks tühista see kõigepealt failis `~/.config/hypr/input.lua`, enne kui lisad oma [puuteplaadi žesti](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), sest Hyprland ei võta vastu kahte žesti samade sõrmede ja sama suunaga:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Kõigi Omarchy žestide väljalülitamiseks määra `omarchy_default_gestures = false` faili `~/.config/hypr/hyprland.lua` alguse lähedal, enne kui Omarchy vaikesätted laaditakse.

Haptilise puuteplaadiga Dell XPS sülearvutitel saad klõpsu tugevuseks määrata ka madala, keskmise või kõrge valiku _Käivitaja > Riistvara > Puuteplaadi haptika_ all.

### Tippimine hiina, jaapani ja muudes keeltes

Vali jaapani, korea, hiina (lihtsustatud, Pinyin), Taiwani (Zhuyin) või Hongkongi (Cangjie), kui installer küsib sinu klaviatuuri kohta. Omarchy seadistab klaviatuuri ja sobiva sisestusmootori automaatselt, sealhulgas võrguühenduseta esmakäivituse seadistuse ajal. Jaapani keel kasutab Mozc mootorit, korea keel tavalist kaherealist Hangul paigutust, lihtsustatud hiina keel Pinyin paigutust, Taiwan Chewingi tavalist Zhuyin paigutust ja Hongkong Cangjie paigutust koos Hongkongi märgivormidega. Jaapani (US klaviatuur) pakub Mozc mootorit koos US klaviatuuripaigutusega. Hangul, Zhuyin ja Cangjie klahvid jäävad oma tavalistele kohtadele isegi siis, kui tipid ladina tähti Dvorak, Colemak või AZERTY paigutusega. Kui lisasid Hangul või Chewing enne seda, tühista selle valik ja vali see uuesti valiku _Seadistus > Tippimine > Sisestusmeetodid_ all, et selle klahvid sinna liigutada; Omarchy jätab mootori, millega sa juba tipid, rahule.

Tippimine algab ladina režiimis. Vajuta `Super + I`, et liikuda seadistatud sisestusmeetodite vahel edasi, ja `Super + Shift + I`, et liikuda tagasi. Puuduta `Shift` klahvi eraldi, et astuda sisestusmeetodist nagu Pinyin välja ladina tähtede juurde, ja puuduta seda uuesti, et tagasi minna, samamoodi nagu Sogou, Microsoft Pinyin ja macOS töötavad; `Shift` koos tähega tipib ikka suurtähe. Jaapani klaviatuuridel lülitab 全角/半角 sisestust, 変換 lülitab selle sisse ja 無変換 lülitab selle välja. Korea keele puhul vahetab 한/영 Hangul paigutust ja 한자 teisendab Hanja märkideks, olenemata sellest, kas sinu klaviatuuril on selleks eraldi klahvid või saadab see nende asemel Right Alt ja Right Ctrl, nagu paljud sülearvutid teevad, nii et Right Alt ja Right Ctrl ei ole seal tavalised muuteklahvid; dikteerimine lülitub selle asemel Alt + Space abil. `Ctrl + Space` jääb Tmux ja Herdr jaoks saadaval; `Shift + CapsLock` jääb koostamisklahviks.

Klaviatuuriindikaator ilmub riba paremale poole, kui sul on mitu klaviatuuripaigutust või sisestusmeetodit. Klõpsa seda, et sisestuskeeli vahetada; jaapani keele puhul kuvatakse hiragana tähistamiseks あ. Jaapani märkide valimiseks vaheta jaapani keelele, tipi sõna nagu `nihongo` ja vajuta seejärel kaks korda Space. Valiku kinnitamiseks vajuta Enter. Kui sul on ka mitu klaviatuuripaigutust, tee indikaatoril paremklõps, et nende vahel liikuda.

Valiku _Seadistus > Tippimine > Klaviatuuripaigutused_ abil saad valida paigutusi nagu inglise ja prantsuse keel samade valikute seast, mida pakuti installimise ajal. Valiku _Seadistus > Tippimine > Sisestusmeetodid_ abil saad valida, millised koostamismootorid on aktiivsed. Mõlemad valijad avanevad Omarchy menüü sees ja sinu praegused valikud on märgitud. Valiku ümberlülitamiseks klõpsa seda või vajuta Enter; iga muudatus rakendub kohe. Sisestusmeetodi valiku tühistamine eemaldab selle tsüklist ilma seda desinstallimata; klaviatuur jääb saadaval.

Käivita `omarchy setup keyboard` või `omarchy setup input`, et samad valijad avada. Ühe keele lisamiseks käsurealt kasuta käsku `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` või `cangjie5`. Quick, Boshiamy ja Array on samas paketis nagu Cangjie ja ilmuvad Sisestusmeetodite valijas. Sinu kohandatud vahetusklahvid säilivad. Alternatiivsete mootoripaigutuste või klahvide jaoks installi `fcitx5-configtool` käsuga `omarchy pkg add fcitx5-configtool` ja käivita see terminalist. Sisestuskeele valimine ei muuda töölaua keelt. Jaapani, korea või hiina keele valimine valiku _Seadistus > Keel_ all lisab selle sisestusmeetodi, kui sul veel ühtegi ei ole.

Kasuta `Super + I`, et liikuda sisestusmeetodite või klaviatuuripaigutuste vahel edasi, ja `Super + Shift + I`, et minna teistpidi tagasi, nii saad kolme seadistatud valiku puhul liikuda kahe naabri vahel. Sisestusindikaator ilmub riba paremale poole ainult siis, kui seadistatud on rohkem kui üks sisestusmeetod või paigutus. See töölaua kiirklahv töötab koos sinu olemasolevate Fcitx vahetusklahvidega; saad selle failis `~/.config/hypr/bindings.lua` üle kirjutada. Sisestusmootorid ja koostamisjadad kasutavad [Fcitx5](https://fcitx-im.org/) teenust, mis juba töötab igas sessioonis.

### ALT kasutamine SUPER asemel

Mõnel klaviatuuril ei ole mugav kasutada peamist metaklahvi (Windows/cmd klahvi) SUPER klahvina. Saad selle selle muudatusega hoopis ALT klahviks muuta:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
