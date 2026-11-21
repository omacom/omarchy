# Tastatūra, pele, skārienpaliktnis

Hyprland ļauj ļoti detalizēti konfigurēt visas ievades ierīces. Tastatūras atkārtošanu vari padarīt virsskaņas ātrumā vai iestatīt skārienpaliktnim dabisko ritināšanu. To visu maini failā `~/.config/hypr/input.lua`, kuram vari piekļūt arī caur _Setup > Input_ Omarchy izvēlnē (`Super + Space`). Viss, ko tur iestatīsi, aizstās Omarchy noklusējumus.

Lūk, piemērs:

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

Visas ievades opcijas vari [skatīt Hyprland wiki lapā par ievadēm](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock darbojas kā parasts Caps Lock, un `Shift + CapsLock` ir compose taustiņš [ātrajām emocijzīmēm](07-hotkeys.md#quick-emojis) un [citiem papildinājumiem](07-hotkeys.md#quick-completions). Ja compose taustiņu labprātāk novietotu citur, `kb_options` aizstāj `omarchy:shift_caps_compose`. Piemēram, šādi compose taustiņš tiek pārvietots uz Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkciju taustiņi

Klēpjdatora tastatūras augšējā rinda pēc noklusējuma sūta multivides taustiņus (skaļums, spilgtums un tā tālāk), un, turot `Fn`, iegūsti F1-F12; `Fn + Esc` noslēdz to otrādi, līdz to nospied vēlreiz. Lielākā daļa tastatūru šo slēdzēju atceras pašas. ASUS klēpjdatori un Apple stila tastatūras to atstāj Linux ziņā, kas katrā palaišanas reizē tos iedarbina multivides taustiņu režīmā. Lai tā vietā tie sāktu ar F1-F12, palaid `omarchy device keyboard toprow fnkeys` (un `omarchy device keyboard toprow mediakeys`, lai atgrieztos); dažos klēpjdatoros tas stājas spēkā pēc pārstartēšanas. Apple Silicon Mac datoriem ir savs iestatījums.

### Skārienpaliktņa žesti

Velc pa skārienpaliktni, lai pārvietotos pa darbvirsmu:

| Žests | Darbība |
| --- | --- |
| Trīs pirksti pa kreisi / pa labi | Iepriekšējā / nākamā darbvieta, tostarp tukšās |
| Trīs pirksti uz augšu | Pārslēgt AI konsoli |
| Trīs pirksti uz leju | Atvērt Omarchy izvēlni |
| Četri pirksti pa kreisi / pa labi | Pārvietot aktīvo logu uz iepriekšējo / nākamo darbvietu |
| Četri pirksti uz leju | Pārslēgt pilnekrāna režīmu |

Lai mainītu kādu žestu, atcel to failā `~/.config/hypr/input.lua`, pirms pievieno savu [skārienpaliktņa žestu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), jo Hyprland nepieņems divus žestus ar vienādu pirkstu skaitu un virzienu:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Lai izslēgtu visus Omarchy žestus, iestati `omarchy_default_gestures = false` tuvu faila `~/.config/hypr/hyprland.lua` sākumam, pirms tiek ielādēti Omarchy noklusējumi.

Dell XPS klēpjdatoros ar haptisku skārienpaliktni sadaļā _Trigger > Hardware > Touchpad Haptics_ vari iestatīt arī klikšķa stiprumu uz low, mid vai high.

### Rakstīšana ķīniešu, japāņu un citās valodās

Kad instalētājs jautā par tavu tastatūru, izvēlies Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) vai Hong Kong (Cangjie). Omarchy automātiski konfigurē tastatūru un atbilstošo ievades dzinēju, arī bezsaistes pirmās palaišanas iestatīšanas laikā. Japāņu valodā tiek izmantots Mozc, korejiešu valodā — standarta divkopu Hangul, vienkāršotajā ķīniešu valodā — Pinyin, Taivānā — Chewing standarta Zhuyin izkārtojums, bet Honkongā — Cangjie ar Honkongas rakstzīmju formām. Japanese (US keyboard) nodrošina Mozc ar US tastatūras izkārtojumu. Hangul, Zhuyin un Cangjie taustiņi paliek savās standarta vietās pat tad, ja latīņu burtus raksti ar Dvorak, Colemak vai AZERTY. Ja Hangul vai Chewing pievienoji pirms tam, noņem tam atzīmi un atzīmē to no jauna sadaļā _Setup > Keyboard > Input Methods_, lai tā taustiņi tiktu pārvietoti tur; Omarchy dzinēju, ar kuru jau raksti, atstāj mierā.

Rakstīšana sākas latīņu režīmā. Nospied `Super + I`, lai cikliski pārslēgtos starp konfigurētajām ievades metodēm, un `Super + Shift + I`, lai pārslēgtos atpakaļ. Pieskaries `Shift` atsevišķi, lai izietu no tādas ievades metodes kā Pinyin uz latīņu burtiem, un pieskaries tam vēlreiz, lai atgrieztos, tāpat kā darbojas Sogou, Microsoft Pinyin un macOS; `Shift` kopā ar burtu joprojām raksta lielo burtu. Japāņu tastatūrās 全角/半角 pārslēdz ievadi, 変換 to ieslēdz un 無変換 to izslēdz. Korejiešu valodā 한/영 pārslēdz Hangul un 한자 pārvērš par Hanja, neatkarīgi no tā, vai tavai tastatūrai ir īpaši taustiņi vai tā tiem sūta Right Alt un Right Ctrl, kā to dara daudzi klēpjdatori, tāpēc Right Alt un Right Ctrl tur nav parasti pārveidotāji; diktēšana tā vietā pārslēdzas ar Alt + Space. `Ctrl + Space` paliek pieejams Tmux un Herdr; `Shift + CapsLock` paliek compose taustiņš.

Tastatūras indikators parādās joslas labajā pusē, kad tev ir vairāki tastatūras izkārtojumi vai ievades metodes. Noklikšķini uz tā, lai pārslēgtu ievades valodas; japāņu valodā hiraganai tiek rādīts あ. Lai izvēlētos japāņu rakstzīmes, pārslēdzies uz japāņu valodu, ieraksti tādu vārdu kā `nihongo` un pēc tam divreiz nospied Space. Nospied Enter, lai apstiprinātu izvēli. Ja tev ir arī vairāki tastatūras izkārtojumi, ar labo pogu noklikšķini uz indikatora, lai cikliski pārslēgtos starp tiem.

Izmanto _Setup > Keyboard > Keyboard Inputs_, lai izvēlētos tādus izkārtojumus kā English un French no tām pašām izvēlēm, kas tiek piedāvātas instalēšanas laikā. Izmanto _Setup > Keyboard > Input Methods_, lai izvēlētos, kuri salikšanas dzinēji ir aktīvi. Abi atlasītāji atveras Omarchy izvēlnes iekšpusē ar atzīmētām tavām pašreizējām izvēlēm. Noklikšķini vai nospied Enter, lai pārslēgtu izvēli; katra izmaiņa stājas spēkā nekavējoties. Ievades metodes atzīmes noņemšana izņem to no cikla, to neatinstalējot; tastatūra paliek pieejama.

Palaid `omarchy setup keyboard` vai `omarchy setup input`, lai atvērtu tos pašus atlasītājus. Lai no komandrindas pievienotu vienu valodu, izmanto `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` vai `cangjie5`. Quick, Boshiamy un Array nāk tajā pašā pakotnē ar Cangjie un parādās Input Methods atlasītājā. Tavi pielāgotie pārslēgšanas taustiņi tiek saglabāti. Alternatīviem dzinēju izkārtojumiem vai taustiņiem instalē `fcitx5-configtool` ar `omarchy pkg add fcitx5-configtool` un palaid to no termināļa. Ievades valodas izvēle nemaina darbvirsmas valodu. Japāņu, korejiešu vai ķīniešu valodas izvēle sadaļā _Setup > Region > Language_ pievieno tās ievades metodi, kad tev tādas vēl nav.

Izmanto `Super + I`, lai cikliski pārslēgtos starp ievades metodēm vai tastatūras izkārtojumiem, un `Super + Shift + I`, lai dotos atpakaļ otrā virzienā, tāpēc ar trim konfigurētām iespējām vari pārvietoties starp diviem kaimiņiem. Ievades indikators parādās joslas labajā pusē tikai tad, kad ir konfigurēta vairāk nekā viena ievades metode vai izkārtojums. Šī darbvirsmas sasaiste darbojas līdzās taviem esošajiem Fcitx pārslēgšanas taustiņiem; vari to ignorēt failā `~/.config/hypr/bindings.lua`. Ievades dzinēji un compose secības izmanto [Fcitx5](https://fcitx-im.org/) pakalpojumu, kas jau darbojas katrā sesijā.

### ALT izmantošana SUPER vietā

Dažās tastatūrās nav ērti izmantot galveno meta taustiņu (Windows/cmd taustiņu) kā SUPER. Tā vietā to vari mainīt uz ALT, veicot šādu izmaiņu:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
