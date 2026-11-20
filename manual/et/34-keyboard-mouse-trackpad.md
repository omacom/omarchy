# Klaviatuur, hiir, puuteplaat

Hyprland võimaldab sul kõiki sisendseadmeid väga üksikasjalikult seadistada. Saad klaviatuuri korduse ülehelikiirusel kiireks panna või panna puuteplaadi kasutama loomulikku kerimist. Seda kõike muudad failis `~/.config/hypr/input.lua`, kuhu pääsed ka Omarchy menüü kaudu valikust _Setup > Input_ (`Super + Space`). Kõik, mille seal määrad, asendab Omarchy vaikeseaded.

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

Kõiki sisendivalikuid saad [vaadata Hyprlandi wiki sisendite lehelt](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock töötab tavalise Caps Lockina ja `Shift + CapsLock` on koosteklahv [kiirete emojide](07-hotkeys.md#quick-emojis) ja [muude täienduste](07-hotkeys.md#quick-completions) jaoks. Kui eelistad koosteklahvi mujale, asenda `kb_options` valikus `omarchy:shift_caps_compose`. Näiteks viib see koosteklahvi Right Alt klahvile:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funktsiooniklahvid

Sülearvuti klaviatuuri ülemine rida saadab vaikimisi meediaklahve (helitugevus, heledus ja nii edasi) ning `Fn` all hoides saad F1-F12; `Fn + Esc` lukustab selle vastupidiseks, kuni vajutad seda uuesti. Enamik klaviatuure jätab selle luku ise meelde. ASUS sülearvutid ja Apple'i stiilis klaviatuurid jätavad selle Linuxi hooleks, mis käivitab need igal käivitamisel meediaklahvidel. Et need käivituksid hoopis F1-F12 klahvidel, käivita `omarchy device keyboard toprow fnkeys` (ja tagasi minemiseks `omarchy device keyboard toprow mediakeys`); mõnel sülearvutil jõustub see pärast taaskäivitust. Apple Silicon Macid hoiavad oma seadet.

### Puuteplaadižestid

Puuteplaadil pühkimisega liigud desktopil ringi:

| Žest | Toiming |
| --- | --- |
| Kolm sõrme vasakule / paremale | Eelmine / järgmine workspace, sealhulgas tühjad |
| Kolm sõrme üles | AI konsooli lülitamine |
| Kolm sõrme alla | Ava Omarchy menüü |
| Neli sõrme vasakule / paremale | Vii aktiivne aken eelmisele / järgmisele workspace'ile |
| Neli sõrme alla | Täisekraani lülitamine |

Ühe muutmiseks tühista see failis `~/.config/hypr/input.lua` enne oma [puuteplaadižesti](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) lisamist, sest Hyprland ei võta vastu kahte žesti samade sõrmede ja suunaga:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Kõigi Omarchy žestide väljalülitamiseks määra `omarchy_default_gestures = false` faili `~/.config/hypr/hyprland.lua` alguse lähedale, enne kui Omarchy vaikeseaded laaditakse.

Haptilise puuteplaadiga Dell XPS sülearvutitel saad klõpsu tugevuseks määrata ka madala, keskmise või kõrge valikus _Trigger > Hardware > Touchpad Haptics_.

### Hiina, jaapani ja muudes keeltes trükkimine

Vali jaapani, korea, hiina (lihtsustatud, Pinyin), Taiwani (Zhuyin) või Hongkongi (Cangjie), kui installer küsib sinu klaviatuuri kohta. Omarchy seadistab klaviatuuri ja sobiva sisendmootori automaatselt, sealhulgas võrguühenduseta esmakäivituse seadistuse ajal. Jaapani keel kasutab Mozc mootorit, korea keel standardset kaherealist Hangul paigutust, lihtsustatud hiina keel Pinyini, Taiwan Chewingi standardset Zhuyin paigutust ja Hongkong Cangjie paigutust Hongkongi märgivormidega. Japanese (US keyboard) pakub Mozc mootorit koos US klaviatuuripaigutusega. Hangul, Zhuyin ja Cangjie klahvid jäävad oma standardkohtadele ka siis, kui trükid ladina tähti Dvorak, Colemak või AZERTY paigutusega. Kui lisasid Hangul või Chewing mootori enne seda, tühista selle valik ja vali see uuesti valikus _Setup > Keyboard > Input Methods_, et selle klahvid sinna viia; mootorit, millega juba trükid, Omarchy ei puutu.

Trükkimine algab ladina režiimis. Vajuta `Super + I`, et liikuda läbi seadistatud sisendmeetodite, ja `Super + Shift + I`, et liikuda tagasi. Puuduta `Shift` klahvi üksinda, et väljuda sellisest sisendmeetodist nagu Pinyin ladina tähtedele, ja puuduta seda uuesti, et tagasi minna, nii nagu töötavad Sogou, Microsoft Pinyin ja macOS; `Shift` koos tähega trükib endiselt suurtähe. Jaapani klaviatuuridel lülitab 全角/半角 sisendit, 変換 lülitab selle sisse ja 無変換 lülitab välja. Korea keele korral vahetab 한/영 Hangul paigutust ja 한자 teisendab Hanja märkideks, olenemata sellest, kas sinu klaviatuuril on selleks eraldi klahvid või saadab see nende asemel Right Alt ja Right Ctrl, nagu paljud sülearvutid teevad, nii et Right Alt ja Right Ctrl ei ole seal tavalised modifikaatoriklahvid; dikteerimine lülitub hoopis Alt + Space abil. `Ctrl + Space` jääb Tmux ja Herdr jaoks saadaval; `Shift + CapsLock` jääb koosteklahviks.

Klaviatuuriindikaator ilmub riba paremale küljele, kui sul on mitu klaviatuuripaigutust või sisendmeetodit. Klõpsa sellel, et sisendkeeli vahetada; jaapani keel kuvab hiragana tähistamiseks あ. Jaapani märgivalikute jaoks vaheta jaapani keelele, trüki sõna, näiteks `nihongo`, ja vajuta seejärel kaks korda Space. Valiku kinnitamiseks vajuta Enter. Kui sul on ka mitu klaviatuuripaigutust, tee indikaatoril paremklõps, et nende vahel liikuda.

Kasuta valikut _Setup > Keyboard > Keyboard Inputs_, et valida paigutusi, näiteks English ja French, samade valikute seast, mida pakutakse installimise ajal. Kasuta valikut _Setup > Keyboard > Input Methods_, et valida, millised koostemootorid on aktiivsed. Mõlemad valijad avanevad Omarchy menüüs nii, et sinu praegused valikud on märgistatud. Valiku lülitamiseks klõpsa või vajuta Enter; iga muudatus rakendub kohe. Sisendmeetodi valiku tühistamine eemaldab selle tsüklist, ilma seda desinstallimata; klaviatuur jääb saadaval.

Käivita `omarchy setup keyboard` või `omarchy setup input`, et avada samad valijad. Ühe keele lisamiseks käsurealt kasuta käsku `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` või `cangjie5`. Quick, Boshiamy ja Array on samas paketis nagu Cangjie ja ilmuvad Input Methods valijas. Sinu kohandatud vahetusklahvid säilivad. Alternatiivsete mootoripaigutuste või klahvide jaoks installi `fcitx5-configtool` käsuga `omarchy pkg add fcitx5-configtool` ja käivita see terminalist. Sisendkeele valimine ei muuda desktopi keelt. Jaapani, korea või hiina keele valimine valikus _Setup > Region > Language_ lisab selle sisendmeetodi, kui sul veel ühtegi ei ole.

Kasuta `Super + I`, et liikuda läbi sisendmeetodite või klaviatuuripaigutuste, ja `Super + Shift + I`, et minna teises suunas tagasi, nii saad kolme seadistatu korral liikuda kahe naabri vahel. Sisendiindikaator ilmub riba paremale küljele ainult siis, kui seadistatud on rohkem kui üks sisendmeetod või paigutus. See desktopi klahviseos töötab koos sinu olemasolevate Fcitx vahetusklahvidega; saad selle alistada failis `~/.config/hypr/bindings.lua`. Sisendmootorid ja koostejadad kasutavad [Fcitx5](https://fcitx-im.org/) teenust, mis juba töötab igas sessioonis.

### ALT kasutamine SUPER klahvina

Mõnel klaviatuuril ei ole mugav kasutada peamist metaklahvi (Windows/cmd klahvi) SUPER klahvina. Saad selle asemel ALT klahviks muuta selle muudatusega:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
