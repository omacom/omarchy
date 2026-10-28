# Klaviatuur, hiir, puuteplaat

Hyprland laseb sul kõiki sisendeid väga üksikasjalikult seadistada. Saad muuta klaviatuuri korduse ülehelikiirusega kiireks või panna puuteplaadi kasutama loomulikku kerimist. Kõike seda muudad failis `~/.config/hypr/input.lua`, kuhu pääsed ka Omarchy menüüs (`Super + Space`) valiku _Seadistus > Sisend_ kaudu. Kõik, mis sa sinna paned, asendab Omarchy vaikeseaded.

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

Kõiki sisendivalikuid näed Hyprland wiki sisendite lehel: [vaata kõiki sisendivalikuid](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock toimib tavalise Caps Lockina ja `Shift + CapsLock` on koosteklahv [kiiremojide](07-hotkeys.md#quick-emojis) ja [muude täienduste](07-hotkeys.md#quick-completions) jaoks. Kui eelistad koosteklahvi mujale, asenda `kb_options` all `omarchy:shift_caps_compose`. Näiteks liigutab see koosteklahvi Right Altile:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Puuteplaadi liigutused

Libista puuteplaadil, et töölaual ringi liikuda:

| Liigutus | Tegevus |
| --- | --- |
| Kolm sõrme vasakule / paremale | Eelmine / järgmine tööruum, sealhulgas tühjad |
| Kolm sõrme üles | Lülita AI konsool sisse/välja |
| Kolm sõrme alla | Ava Omarchy menüü |
| Neli sõrme vasakule / paremale | Teisalda aktiivne aken eelmisse / järgmisse tööruumi |
| Neli sõrme alla | Lülita täisekraan sisse/välja |

Ühe muutmiseks tühista see failis `~/.config/hypr/input.lua`, enne kui lisad oma [puuteplaadi liigutuse](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), sest Hyprland ei võta vastu kahte liigutust samade sõrmede ja suunaga:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Kõigi Omarchy liigutuste väljalülitamiseks pane `omarchy_default_gestures = false` faili `~/.config/hypr/hyprland.lua` ülaosa lähedale, enne kui Omarchy vaikeseaded laaditakse.

Haptilise puuteplaadiga Dell XPS sülearvutitel saad klõpsu tugevuseks määrata ka madala, keskmise või kõrge valiku _Käiviti > Riistvara > Puuteplaadi haptika_ all.

### Tippimine hiina, jaapani ja teistes keeltes

Vali jaapani, korea, hiina (lihtsustatud, Pinyin), Taiwani (Zhuyin) või Hongkongi (Cangjie), kui installer küsib sinu klaviatuuri. Omarchy seadistab klaviatuuri ja sobiva sisestusmootori automaatselt, sealhulgas võrguühenduseta esmakäivituse seadistuse ajal. Jaapani keel kasutab Mozci, korea keel tavalist kaherealist Hanguli, lihtsustatud hiina keel Pinyini, Taiwan Chewingu tavalist Zhuyini paigutust ja Hongkong Cangjied koos Hongkongi märgivormidega. Jaapani keel (US klaviatuur) pakub Mozci koos US klaviatuuripaigutusega. Hanguli, Zhuyini ja Cangjie klahvid jäävad oma tavapärastesse kohtadesse ka siis, kui tipid ladina tähti Dvoraki, Colemaki või AZERTYga. Kui lisasid Hanguli või Chewingu varem, tühista ja vali see uuesti valiku _Seadistus > Tippimine > Sisestusmeetodid_ all, et selle klahvid sinna liigutada; Omarchy jätab mootori, millega juba tipid, rahule.

Tippimine algab ladina režiimis. Vajuta `Super + I`, et liikuda seadistatud sisestusmeetodite vahel ringis edasi, ja `Super + Shift + I`, et liikuda ringis tagasi. Puuduta `Shift` omaette, et väljuda sisestusmeetodist nagu Pinyin ladina tähtede juurde, ja puuduta seda uuesti, et tagasi minna, nii nagu Sogou, Microsoft Pinyin ja macOS töötavad; `Shift` koos tähega tipib ikka suurtähe. Jaapani klaviatuuridel lülitab 全角/半角 sisestust, 変換 lülitab selle sisse ja 無変換 lülitab selle välja. Korea keele korral lülitab 한/영 Hanguli ja 한자 teisendab Hanjaks, olenemata sellest, kas sinu klaviatuuril on selleks eraldi klahvid või saadab see nende asemel Right Alt ja Right Ctrl, nagu paljud sülearvutid teevad, nii et Right Alt ja Right Ctrl ei ole seal tavalised modifikaatoriklahvid; dikteerimise push-to-talk jääb klahvile F9. `Ctrl + Space` jääb Tmuxi ja Herdri jaoks saadaval; `Shift + CapsLock` jääb koosteklahviks.

Klaviatuuriindikaator ilmub riba paremasse serva, kui sul on mitu klaviatuuripaigutust või sisestusmeetodit. Klõpsa seda sisestuskeelte vahetamiseks; jaapani keel kuvab hiragana puhul あ. Jaapani märgivalikute jaoks lülitu jaapani keelele, tipi sõna nagu `nihongo`, seejärel vajuta kaks korda Space. Valiku kinnitamiseks vajuta Enter. Kui sul on ka mitu klaviatuuripaigutust, paremklõpsa indikaatorit, et nende vahel ringis liikuda.

Kasuta valikut _Seadistus > Tippimine > Klaviatuuripaigutused_, et valida paigutusi nagu inglise ja prantsuse keel samade valikute seast, mida pakutakse installimise ajal. Kasuta valikut _Seadistus > Tippimine > Sisestusmeetodid_, et valida, millised koostemootorid on aktiivsed. Mõlemad valijad avanevad Omarchy menüü sees nii, et sinu praegused valikud on märgistatud. Klõpsa või vajuta Enter valiku sisse- või väljalülitamiseks; iga muudatus rakendub kohe. Sisestusmeetodi valiku tühistamine eemaldab selle ringist ilma seda desinstallimata; klaviatuur jääb saadaval.

Käivita `omarchy setup keyboard` või `omarchy setup input`, et avada samad valijad. Ühe keele lisamiseks käsurealt kasuta `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` või `cangjie5`. Quick, Boshiamy ja Array on samas paketis nagu Cangjie ja ilmuvad Sisestusmeetodite valijas. Sinu kohandatud vahetusklahvid säilivad. Alternatiivsete mootoripaigutuste või klahvide jaoks installi `fcitx5-configtool` käsuga `omarchy pkg add fcitx5-configtool` ja käivita see terminalist. Sisestuskeele valimine ei muuda töölaua keelt. Jaapani, korea või hiina keele valimine valiku _Seadistus > Keel_ all lisab selle sisestusmeetodi, kui sul veel ühtegi ei ole.

Kasuta `Super + I`, et liikuda sisestusmeetodite või klaviatuuripaigutuste vahel ringis edasi, ja `Super + Shift + I`, et liikuda teises suunas tagasi, nii saad kolme seadistatu korral liikuda kahe naabri vahel. Sisestusindikaator ilmub riba paremasse serva ainult siis, kui seadistatud on rohkem kui üks sisestusmeetod või paigutus. See töölaua sidumine töötab koos sinu olemasolevate Fcitx vahetusklahvidega; saad selle alistada failis `~/.config/hypr/bindings.lua`. Sisestusmootorid ja koostejadad kasutavad [Fcitx5](https://fcitx-im.org/) teenust, mis juba töötab igas sessioonis.

### Kasuta ALT SUPERina

Mõnel klaviatuuril ei ole mugav kasutada peamist metaklahvi (Windows/cmd klahvi) SUPERina. Saad selle asemel muuta ALTiks selle muudatusega:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
