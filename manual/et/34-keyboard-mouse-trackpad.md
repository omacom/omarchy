# Klaviatuur, hiir ja puuteplaat

Hyprland võimaldab sul kõiki sisendeid väga üksikasjalikult seadistada. Saad muuta klaviatuuri korduse ülehelikiirusel kiireks või panna puuteplaadi kasutama loomulikku kerimist. Kõike seda muudad failis `~/.config/hypr/input.lua`, kuhu pääsed ka Omarchy menüüs (`Super + Space`) valiku _Setup > Input_ kaudu. Kõik, mille seal määrad, asendab Omarchy vaikeseaded.

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

Kõik sisendivalikud leiad [Hyprlandi sisendite wikist](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock töötab tavalise Caps Lockina ja `Shift + CapsLock` on koosteklahv [kiirete emojide](07-hotkeys.md#quick-emojis) ja [muude täienduste](07-hotkeys.md#quick-completions) jaoks. Kui eelistad koosteklahvi mujale, asenda `kb_options` väärtuses `omarchy:shift_caps_compose`. Näiteks viib see koosteklahvi paremale Alt-klahvile:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Puuteplaadi žestid

Saad sisse lülitada ka [puuteplaadi žestid](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), näiteks kolme sõrmega pühkimise tööalade vahetamiseks:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Haptilise puuteplaadiga Dell XPS sülearvutitel saad valikus _Trigger > Hardware > Touchpad Haptics_ määrata ka klõpsu tugevuseks madala, keskmise või kõrge.

### Hiina, jaapani ja teistes keeltes tippimine

Vali jaapani, korea, hiina (lihtsustatud, Pinyin), Taiwani (Zhuyin) või Hongkongi (Cangjie) keel, kui installer küsib sinu klaviatuuri kohta. Omarchy seadistab klaviatuuri ja sobiva sisestusmootori automaatselt, sealhulgas võrguühenduseta esmakäivituse seadistuse ajal. Jaapani keel kasutab Mozc mootorit, korea keel standardset kahekomplektilist Hangulit, lihtsustatud hiina keel Pinyini, Taiwan Chewingi standardset Zhuyini paigutust ja Hongkong Cangjied koos Hongkongi märgivormidega. Jaapani (US keyboard) pakub Mozc mootorit koos US klaviatuuripaigutusega. Hanguli, Zhuyini ja Cangjie klahvid püsivad oma standardsetel kohtadel isegi siis, kui tipid ladina tähti Dvoraki, Colemaki või AZERTY paigutusega. Kui lisasid Hanguli või Chewingi enne seda, tühista selle valik ja vali see uuesti valikus _Setup > Typing > Input Methods_, et selle klahvid sinna viia; Omarchy jätab mootori, millega juba tipid, rahule.

Tippimine algab ladina režiimis. Vajuta `Super + I`, et liikuda läbi seadistatud sisestusmeetodite, ja `Super + Shift + I`, et liikuda tagasi. Puuduta üksinda `Shift` klahvi, et astuda sisestusmeetodist nagu Pinyin välja ladina tähtede juurde, ja puuduta seda uuesti, et tagasi minna, nii nagu töötavad Sogou, Microsoft Pinyin ja macOS; `Shift` koos tähega tipib endiselt suurtähe. Jaapani klaviatuuridel lülitab 全角/半角 sisestust, 変換 lülitab selle sisse ja 無変換 lülitab selle välja. Korea keelega vahetab 한/영 Hangulit ja 한자 teisendab Hanjaks, olenemata sellest, kas sinu klaviatuuril on spetsiaalsed klahvid või saadab see nende asemel parema Alt ja parema Ctrl klahvi, nagu paljud sülearvutid teevad, nii et parem Alt ja parem Ctrl ei ole seal tavalised muuteklahvid; dikteerimise push-to-talk jääb F9 klahvile. `Ctrl + Space` jääb kättesaadavaks Tmuxi ja Herdri jaoks; `Shift + CapsLock` jääb koosteklahviks.

Klaviatuuriindikaator ilmub riba paremasse serva, kui sul on mitu klaviatuuripaigutust või sisestusmeetodit. Klõpsa seda sisestuskeelte vahetamiseks; jaapani keel kuvab hiragana tähistamiseks あ. Jaapani märgivalikute jaoks vaheta jaapani keelele, tipi sõna nagu `nihongo` ja vajuta seejärel kaks korda Space. Vajuta valiku kinnitamiseks Enter. Kui sul on ka mitu klaviatuuripaigutust, paremklõpsa indikaatorit nende vahel liikumiseks.

Kasuta valikut _Setup > Typing > Keyboard Layouts_, et valida paigutusi nagu inglise ja prantsuse keel samade valikute seast, mida pakutakse installimise ajal. Kasuta valikut _Setup > Typing > Input Methods_, et valida, millised koostemootorid on aktiivsed. Mõlemad valijad avanevad Omarchy menüü sees ja sinu praegused valikud on märgitud. Klõpsa valikut või vajuta selle lülitamiseks Enter; iga muudatus rakendub kohe. Sisestusmeetodi valiku tühistamine eemaldab selle tsüklist ilma seda desinstallimata; klaviatuur jääb kättesaadavaks.

Käivita samade valijate avamiseks `omarchy setup keyboard` või `omarchy setup input`. Ühe keele lisamiseks käsurealt kasuta käsku `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` või `cangjie5`. Quick, Boshiamy ja Array on Cangjiega samas paketis ja ilmuvad Input Methods valijas. Sinu kohandatud vahetusklahvid säilivad. Alternatiivsete mootoripaigutuste või klahvide jaoks installi `fcitx5-configtool` käsuga `omarchy pkg add fcitx5-configtool` ja käivita see terminalist. Sisestuskeele valimine ei muuda töölaua keelt. Jaapani, korea või hiina keele valimine valikus _Setup > Language_ lisab selle sisestusmeetodi, kui sul veel ühtegi ei ole.

Kasuta `Super + I` klahve sisestusmeetodite või klaviatuuripaigutuste vahel liikumiseks ja `Super + Shift + I` klahve teistpidi tagasi liikumiseks, nii et kolme seadistatud valiku korral saad liikuda kahe naabri vahel. Sisestusindikaator ilmub riba paremasse serva ainult siis, kui seadistatud on rohkem kui üks sisestusmeetod või paigutus. See töölauasidumine töötab koos sinu olemasolevate Fcitx vahetusklahvidega; saad selle alistada failis `~/.config/hypr/bindings.lua`. Sisestusmootorid ja koostejadad kasutavad [Fcitx5](https://fcitx-im.org/) teenust, mis juba töötab igas seansis.

### ALT kasutamine SUPER-ina

Mõnel klaviatuuril ei ole mugav kasutada peamist metaklahvi (Windows/cmd klahvi) SUPER-ina. Saad selle asemel muuta ALT-iks selle muudatusega:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
