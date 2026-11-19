# Klaviatuur, hiir, puuteplaat

Hyprland laseb sul kõiki sisendeid väga üksikasjalikult seadistada. Saad klaviatuuri korduse supersoniliselt kiireks panna või panna puuteplaadi kasutama loomulikku kerimist. Muudad seda kõike failis `~/.config/hypr/input.lua`, kuhu pääsed ka Omarchy menüüs (`Super + Space`) valiku _Seadistus > Sisend_ kaudu. Kõik, mis sa sinna paned, asendab Omarchy vaikeseaded.

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

Saad [vaadata kõiki sisendivalikuid](https://wiki.hypr.land/Configuring/Basics/Variables/#input) Hyprlandi wikis sisendite kohta.

CapsLock töötab tavalise Caps Lockina ja `Shift + CapsLock` on koosteklahv [kiirete emojide](07-hotkeys.md#quick-emojis) ja [muude täienduste](07-hotkeys.md#quick-completions) jaoks. Kui eelistad koosteklahvi mujale, asenda `kb_options`-is `omarchy:shift_caps_compose`. Näiteks viib see koosteklahvi Right Altile:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funktsiooniklahvid

Sülearvuti klaviatuuri ülemine rida saadab vaikimisi meediaklahve (helitugevus, heledus jne) ja `Fn`-i all hoidmine annab F1-F12; `Fn + Esc` lukustab selle teistpidi, kuni seda uuesti vajutad. Enamik klaviatuure jätab selle luku ise meelde. ASUS-e sülearvutid ja Apple'i stiilis klaviatuurid jätavad selle Linuxi hooleks, mis käivitab need igal alglaadimisel meediaklahvidega. Et need käivituksid hoopis F1-F12-ga, käivita `omarchy device keyboard toprow fnkeys` (ja tagasi minemiseks `omarchy device keyboard toprow mediakeys`); mõnel sülearvutil jõustub see pärast taaskäivitust. Apple Siliconiga Macid hoiavad oma seadet.

### Puuteplaadi žestid

Pühi puuteplaadil, et töölaual ringi liikuda:

| Žest | Toiming |
| --- | --- |
| Kolm sõrme vasakule / paremale | Eelmine / järgmine tööala, sealhulgas tühjad |
| Kolm sõrme üles | Lülita AI-konsool sisse/välja |
| Kolm sõrme alla | Ava Omarchy menüü |
| Neli sõrme vasakule / paremale | Teisalda aktiivne aken eelmisele / järgmisele tööalale |
| Neli sõrme alla | Lülita täisekraan sisse/välja |

Ühe muutmiseks tühista see failis `~/.config/hypr/input.lua` enne oma [puuteplaadi žesti](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) lisamist, sest Hyprland ei võta vastu kahte žesti samade sõrmede ja suunaga:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Kõikide Omarchy žestide väljalülitamiseks pane `omarchy_default_gestures = false` faili `~/.config/hypr/hyprland.lua` alguse lähedale, enne kui Omarchy vaikeseaded laaditakse.

Haptilise puuteplaadiga Dell XPS sülearvutitel saad klõpsu tugevuseks määrata ka madala, keskmise või kõrge valikus _Päästik > Riistvara > Puuteplaadi haptika_.

### Tippimine hiina, jaapani ja muudes keeltes

Vali jaapani, korea, hiina (lihtsustatud, Pinyin), Taiwani (Zhuyin) või Hongkongi (Cangjie), kui installer sinu klaviatuuri kohta küsib. Omarchy seadistab klaviatuuri ja sobiva sisestusmootori automaatselt, ka võrguühenduseta esmakäivituse seadistuse ajal. Jaapani keel kasutab Mozci, korea keel standardset kahese komplektiga Hangulit, lihtsustatud hiina keel Pinyini, Taiwan Chewingu standardset Zhuyini paigutust ja Hongkong Hongkongi märgivormidega Cangjied. Jaapani (US klaviatuur) pakub Mozci US klaviatuuripaigutusega. Hanguli, Zhuyini ja Cangjie klahvid jäävad oma standardkohtadele ka siis, kui tipid ladina tähti Dvoraki, Colemaki või AZERTYga. Kui lisasid Hanguli või Chewingu juba enne seda, tühista selle valik ja vali see uuesti valikus _Seadistus > Klaviatuur > Sisestusmeetodid_, et selle klahvid sinna viia; Omarchy jätab mootori, millega juba tipid, rahule.

Tippimine algab ladina režiimis. Vajuta `Super + I`, et liikuda läbi seadistatud sisestusmeetodite, ja `Super + Shift + I`, et liikuda tagasi. Koputa `Shift`-i omaette, et väljuda sisestusmeetodist, näiteks Pinyinist, ladina tähtede juurde, ja koputa seda uuesti, et tagasi minna, nii nagu töötavad Sogou, Microsoft Pinyin ja macOS; `Shift` koos tähega tipib ikka suurtähe. Jaapani klaviatuuridel lülitab 全角/半角 sisestust, 変換 lülitab selle sisse ja 無変換 lülitab selle välja. Korea keelega vahetab 한/영 Hangulit ja 한자 teisendab Hanjaks, olenemata sellest, kas sinu klaviatuuril on selleks eraldi klahvid või saadab see nende jaoks Right Alt ja Right Ctrl, nagu paljud sülearvutid teevad, nii et Right Alt ja Right Ctrl ei ole seal tavalised modifikaatorid; dikteerimine lülitub hoopis Alt + Space'iga. `Ctrl + Space` jääb Tmuxi ja Herdri jaoks kättesaadavaks; `Shift + CapsLock` jääb koosteklahviks.

Klaviatuuriindikaator ilmub riba paremale poole, kui sul on mitu klaviatuuripaigutust või sisestusmeetodit. Klõpsa seda sisestuskeelte vahetamiseks; jaapani keel kuvab hiragana jaoks あ. Jaapani märkide valimiseks vaheta jaapani keelele, tipi sõna, näiteks `nihongo`, ja vajuta seejärel kaks korda Space. Vajuta valiku kinnitamiseks Enter. Kui sul on ka mitu klaviatuuripaigutust, paremklõpsa indikaatorit, et nende vahel liikuda.

Kasuta valikut _Seadistus > Klaviatuur > Klaviatuuri sisendid_, et valida paigutusi, näiteks inglise ja prantsuse keel, samade valikute seast, mida installimisel pakuti. Kasuta valikut _Seadistus > Klaviatuur > Sisestusmeetodid_, et valida, millised koostemootorid on aktiivsed. Mõlemad valijad avanevad Omarchy menüüs nii, et sinu praegused valikud on märgitud. Valiku lülitamiseks klõpsa või vajuta Enter; iga muudatus rakendub kohe. Sisestusmeetodi valiku tühistamine eemaldab selle tsüklist ilma seda desinstallimata; klaviatuur jääb kättesaadavaks.

Käivita `omarchy setup keyboard` või `omarchy setup input`, et samad valijad avada. Ühe keele lisamiseks käsurealt kasuta käsku `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` või `cangjie5`. Quick, Boshiamy ja Array on Cangjiega samas paketis ja ilmuvad Sisestusmeetodite valijas. Sinu kohandatud vahetusklahvid säilivad. Alternatiivsete mootoripaigutuste või klahvide jaoks installi `fcitx5-configtool` käsuga `omarchy pkg add fcitx5-configtool` ja käivita see terminalist. Sisestuskeele valimine ei muuda töölaua keelt. Jaapani, korea või hiina keele valimine valikus _Seadistus > Keel_ lisab selle sisestusmeetodi, kui sul veel ühtegi ei ole.

Kasuta `Super + I`, et liikuda läbi sisestusmeetodite või klaviatuuripaigutuste, ja `Super + Shift + I`, et minna teistpidi tagasi, nii et kolme seadistatu korral saad liikuda kahe naabri vahel. Sisestusindikaator ilmub riba paremale poole ainult siis, kui seadistatud on rohkem kui üks sisestusmeetod või paigutus. See töölaua otsetee töötab koos sinu olemasolevate Fcitx vahetusklahvidega; saad selle failis `~/.config/hypr/bindings.lua` üle kirjutada. Sisestusmootorid ja koostejadad kasutavad [Fcitx5](https://fcitx-im.org/) teenust, mis juba igas seansis töötab.

### Kasuta ALT-i SUPER-ina

Mõnel klaviatuuril ei ole mugav kasutada peamist metaklahvi (Windows/cmd klahvi) SUPER-ina. Saad selle asemel ALT-iks muuta selle muudatusega:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
