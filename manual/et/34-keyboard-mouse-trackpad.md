# Klaviatuur, hiir, puuteplaat

Hyprland võimaldab sul kõiki sisendeid väga üksikasjalikult seadistada. Saad muuta klaviatuuri korduse ülikiireks või panna puuteplaadi kasutama loomulikku kerimist. Kõike seda muudad failis `~/.config/hypr/input.lua`, kuhu pääsed ka Omarchy menüüs valiku _Setup > Input_ kaudu (`Super + Space`). Kõik, mis sa seal määrad, asendab Omarchy vaikeseaded.

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

Kõiki sisendivalikuid näed [Hyprlandi wikis sisendite kohta](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock toimib tavalise Caps Lockina ja `Shift + CapsLock` on koosteklahv [kiirete emotikonide](07-hotkeys.md#quick-emojis) ja [muude täienduste](07-hotkeys.md#quick-completions) jaoks. Kui eelistad koosteklahvi mujal, asenda `kb_options` väärtuses `omarchy:shift_caps_compose`. Näiteks liigutab see koosteklahvi klahvile Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funktsiooniklahvid

Sülearvuti klaviatuuri ülemine rida saadab vaikimisi meediumiklahve (helitugevus, heledus jne) ja `Fn` all hoidmine annab F1-F12; `Fn + Esc` lukustab selle teistpidi, kuni vajutad seda uuesti. Enamik klaviatuure jätab selle luku ise meelde. ASUS-e sülearvutid ja Apple'i stiilis klaviatuurid jätavad selle Linuxi hooleks, mis käivitab need igal alglaadimisel meediumiklahvidel. Et need käivituksid hoopis F1-F12 klahvidel, käivita `omarchy keyboard toprow fnkeys` (ja tagasi minekuks `omarchy keyboard toprow mediakeys`); mõnel sülearvutil jõustub see pärast taaskäivitust. Apple Silicon Macid säilitavad oma seade.

### Puuteplaadi žestid

Libista puuteplaadil, et töölaual liikuda:

| Žest | Toiming |
| --- | --- |
| Kolm sõrme vasakule / paremale | Eelmine / järgmine tööala, sealhulgas tühjad |
| Kolm sõrme üles | Lülita AI-konsool ümber |
| Kolm sõrme alla | Ava Omarchy menüü |
| Neli sõrme vasakule / paremale | Teisalda aktiivne aken eelmisele / järgmisele tööalale |
| Neli sõrme alla | Lülita täisekraanvaade ümber |

Et üht muuta, tühista see failis `~/.config/hypr/input.lua` enne oma [puuteplaadi žesti](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) lisamist, sest Hyprland ei luba kahte žesti samade sõrmede ja suunaga:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Et kõik Omarchy žestid välja lülitada, määra `omarchy_default_gestures = false` faili `~/.config/hypr/hyprland.lua` ülaosa lähedal, enne kui Omarchy vaikeseaded laaditakse.

Haptilise puuteplaadiga Dell XPS sülearvutitel saad klõpsu tugevuse määrata ka madalaks, keskmiseks või kõrgeks valiku _Trigger > Hardware > Touchpad Haptics_ all.

### Hiina, jaapani ja teistes keeltes tippimine

Vali jaapani, korea, hiina (lihtsustatud, Pinyin), Taiwani (Zhuyin) või Hongkongi (Cangjie), kui installer küsib sinu klaviatuuri. Omarchy seadistab klaviatuuri ja sobiva sisendmootori automaatselt, sealhulgas võrguühenduseta esmakäivituse seadistuse ajal. Jaapani keel kasutab Mozc'i, korea keel tavalist kahest komplektist koosnevat Hangulit, lihtsustatud hiina keel Pinyini, Taiwan Chewingi tavalist Zhuyini paigutust ja Hongkong Cangjied koos Hongkongi märgivormidega. Japanese (US keyboard) pakub Mozc'i koos US klaviatuuripaigutusega. Hanguli, Zhuyini ja Cangjie klahvid jäävad oma tavapärastele kohtadele isegi siis, kui tipid ladina tähti Dvoraki, Colemaki või AZERTYga. Kui lisasid Hanguli või Chewingi enne seda, tühista selle valik ja vali see uuesti valiku _Setup > Keyboard > Input Methods_ all, et selle klahvid sinna liigutada; Omarchy jätab mootori, millega sa juba tipid, rahule.

Tippimine algab ladina režiimis. Vajuta `Super + I`, et liikuda järjest läbi seadistatud sisendmeetodite, ja `Super + Shift + I`, et liikuda tagasi. Puuduta üksinda `Shift`, et astuda sisendmeetodist nagu Pinyin välja ladina tähtedele, ja puuduta seda uuesti, et tagasi minna, nii nagu Sogou, Microsoft Pinyin ja macOS töötavad; `Shift` koos tähega tipib ikka suurtähe. Jaapani klaviatuuridel lülitab 全角/半角 sisendit ümber, 変換 lülitab selle sisse ja 無変換 lülitab selle välja. Korea keelega vahetab 한/영 Hangulit ja 한자 teisendab Hanjaks, olenemata sellest, kas sinu klaviatuuril on spetsiaalsed klahvid või saadab nende jaoks Right Alt ja Right Ctrl, nagu paljud sülearvutid teevad, nii et Right Alt ja Right Ctrl ei ole seal tavalised modifikaatorid; dikteerimine lülitub hoopis Alt + Space'iga ümber. `Ctrl + Space` jääb kättesaadavaks Tmuxi ja Herdri jaoks; `Shift + CapsLock` jääb koosteklahviks.

Klaviatuuriindikaator ilmub riba paremale küljele, kui sul on mitu klaviatuuripaigutust või sisendmeetodit. Klõpsa seda, et sisendkeeli vahetada; jaapani keel kuvab hiragana jaoks あ. Jaapani märgivalikute jaoks vaheta jaapani keelele, tipi sõna nagu `nihongo`, seejärel vajuta kaks korda Space. Valiku kinnitamiseks vajuta Enter. Kui sul on ka mitu klaviatuuripaigutust, paremklõpsa indikaatorit, et nende vahel järjest liikuda.

Kasuta valikut _Setup > Keyboard > Keyboard Inputs_, et valida paigutusi nagu inglise ja prantsuse keel, samade valikute seast, mida pakutakse installimise ajal. Kasuta valikut _Setup > Keyboard > Input Methods_, et valida, millised koostamismootorid on aktiivsed. Mõlemad valijad avanevad Omarchy menüüs, sinu praegused valikud on märgistatud. Valiku lülitamiseks klõpsa või vajuta Enter; iga muudatus rakendub kohe. Sisendmeetodi valiku tühistamine eemaldab selle tsüklist ilma seda desinstallimata; klaviatuur jääb kättesaadavaks.

Käivita `omarchy setup keyboard` või `omarchy setup input`, et avada samad valijad. Ühe keele lisamiseks käsurealt kasuta `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` või `cangjie5`. Quick, Boshiamy ja Array on Cangjie'ga samas paketis ja ilmuvad Input Methods valijas. Sinu kohandatud vahetusklahvid säilitatakse. Alternatiivsete mootoripaigutuste või klahvide jaoks installi `fcitx5-configtool` käsuga `omarchy pkg add fcitx5-configtool` ja käivita see terminalist. Sisendkeele valimine ei muuda töölaua keelt. Jaapani, korea või hiina keele valimine valiku _Setup > Language_ all lisab selle sisendmeetodi, kui sul veel ühtki ei ole.

Kasuta `Super + I`, et liikuda järjest läbi sisendmeetodite või klaviatuuripaigutuste, ja `Super + Shift + I`, et minna teist teed tagasi, nii et kolme seadistatu korral saad liikuda kahe naabri vahel. Sisendiindikaator ilmub riba paremale küljele ainult siis, kui seadistatud on rohkem kui üks sisendmeetod või paigutus. See töölaua sidumine töötab koos sinu olemasolevate Fcitx vahetusklahvidega; saad selle alistada failis `~/.config/hypr/bindings.lua`. Sisendmootorid ja koostejadad kasutavad [Fcitx5](https://fcitx-im.org/) teenust, mis juba töötab igas seansis.

### ALT kasutamine SUPERina

Mõnel klaviatuuril ei ole mugav kasutada peamist metaklahvi (Windowsi/cmd klahvi) SUPERina. Saad selle muuta hoopis ALTiks, kasutades seda muudatust:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
