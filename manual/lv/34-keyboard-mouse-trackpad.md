# Tastatūra, pele, skārienpaliktnis

Hyprland ļauj ļoti detalizēti konfigurēt visas ievades ierīces. Varat padarīt tastatūras atkārtošanos virsskaņas ātru vai likt skārienpaliktnim izmantot dabisko ritināšanu. To visu maināt failā `~/.config/hypr/input.lua`, kuram var piekļūt arī caur _Setup > Input_ Omarchy izvēlnē (`Super + Space`). Viss, ko tur iestatīsiet, aizstās Omarchy noklusējumus.

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

Visas ievades opcijas varat [skatīt Hyprland wiki lapā par ievadi](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock darbojas kā parasts Caps Lock, un `Shift + CapsLock` ir compose taustiņš [ātrajām emocijzīmēm](07-hotkeys.md#quick-emojis) un [citiem papildinājumiem](07-hotkeys.md#quick-completions). Ja vēlaties compose taustiņu citur, aizstājiet `omarchy:shift_caps_compose` parametrā `kb_options`. Piemēram, šādi compose taustiņš tiek pārvietots uz Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Skārienpaliktņa žesti

Velciet pa skārienpaliktni, lai pārvietotos pa darbvirsmu:

| Žests | Darbība |
| --- | --- |
| Trīs pirksti pa kreisi / pa labi | Iepriekšējā / nākamā darbvieta, ieskaitot tukšās |
| Trīs pirksti uz augšu | Pārslēgt AI konsoli |
| Trīs pirksti uz leju | Atvērt Omarchy izvēlni |
| Četri pirksti pa kreisi / pa labi | Pārvietot aktīvo logu uz iepriekšējo / nākamo darbvietu |
| Četri pirksti uz leju | Pārslēgt pilnekrāna režīmu |

Lai mainītu kādu no tiem, vispirms atiestatiet to failā `~/.config/hypr/input.lua`, pirms pievienojat savu [skārienpaliktņa žestu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), jo Hyprland nepieņems divus žestus ar vienādu pirkstu skaitu un virzienu:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Lai izslēgtu visus Omarchy žestus, iestatiet `omarchy_default_gestures = false` faila `~/.config/hypr/hyprland.lua` augšdaļā, pirms tiek ielādēti Omarchy noklusējumi.

Dell XPS klēpjdatoros ar haptisko skārienpaliktni klikšķa stiprumu var iestatīt uz zemu, vidēju vai augstu sadaļā _Trigger > Hardware > Touchpad Haptics_.

### Rakstīšana ķīniešu, japāņu un citās valodās

Izvēlieties japāņu, korejiešu, ķīniešu (vienkāršotā, Pinyin), Taivānas (Zhuyin) vai Honkongas (Cangjie) valodu, kad instalētājs jautā par jūsu tastatūru. Omarchy automātiski konfigurē tastatūru un atbilstošo ievades dzinēju, arī bezsaistes pirmās palaišanas iestatīšanas laikā. Japāņu valoda izmanto Mozc, korejiešu valoda izmanto standarta divu komplektu Hangul, vienkāršotā ķīniešu valoda izmanto Pinyin, Taivāna izmanto Chewing standarta Zhuyin izkārtojumu, un Honkonga izmanto Cangjie ar Honkongas rakstzīmju formām. Japanese (US keyboard) nodrošina Mozc ar US tastatūras izkārtojumu. Hangul, Zhuyin un Cangjie taustiņi paliek savās standarta vietās pat tad, ja latīņu burtus rakstāt ar Dvorak, Colemak vai AZERTY. Ja Hangul vai Chewing pievienojāt jau agrāk, noņemiet tā atlasi un atlasiet to vēlreiz sadaļā _Setup > Typing > Input Methods_, lai pārvietotu tā taustiņus uz šīm vietām; dzinēju, ar kuru jau rakstāt, Omarchy atstāj neskartu.

Rakstīšana sākas latīņu režīmā. Nospiediet `Super + I`, lai cikliski pārslēgtos starp konfigurētajām ievades metodēm, un `Super + Shift + I`, lai pārslēgtos pretējā virzienā. Pieskarieties atsevišķi taustiņam `Shift`, lai izietu no tādas ievades metodes kā Pinyin uz latīņu burtiem, un pieskarieties tam vēlreiz, lai atgrieztos — tā, kā darbojas Sogou, Microsoft Pinyin un macOS; `Shift` kopā ar burtu joprojām raksta lielo burtu. Japāņu tastatūrās 全角/半角 pārslēdz ievadi, 変換 to ieslēdz un 無変換 to izslēdz. Korejiešu valodā 한/영 pārslēdz Hangul un 한자 pārveido par Hanja neatkarīgi no tā, vai jūsu tastatūrai ir īpaši taustiņi vai tā tiem sūta Right Alt un Right Ctrl, kā to dara daudzi klēpjdatori, tāpēc tur Right Alt un Right Ctrl nav parasti pārveidotāji; diktēšanas push-to-talk paliek uz F9. `Ctrl + Space` joprojām ir pieejams Tmux un Herdr; `Shift + CapsLock` joprojām ir compose taustiņš.

Tastatūras indikators parādās joslas labajā pusē, kad jums ir vairāki tastatūras izkārtojumi vai ievades metodes. Noklikšķiniet uz tā, lai pārslēgtu ievades valodas; japāņu valodai hiraganai tiek rādīts あ. Lai izvēlētos japāņu rakstzīmes, pārslēdzieties uz japāņu valodu, ierakstiet kādu vārdu, piemēram, `nihongo`, un pēc tam divreiz nospiediet Space. Nospiediet Enter, lai apstiprinātu izvēli. Ja jums ir arī vairāki tastatūras izkārtojumi, ar peles labo pogu noklikšķiniet uz indikatora, lai tos cikliski pārslēgtu.

Izmantojiet _Setup > Typing > Keyboard Layouts_, lai atlasītu tādus izkārtojumus kā angļu un franču no tām pašām iespējām, kas tiek piedāvātas instalēšanas laikā. Izmantojiet _Setup > Typing > Input Methods_, lai atlasītu, kuri kompozīcijas dzinēji ir aktīvi. Abi atlasītāji atveras Omarchy izvēlnē ar atzīmētām jūsu pašreizējām izvēlēm. Noklikšķiniet vai nospiediet Enter, lai pārslēgtu izvēli; katras izmaiņas stājas spēkā nekavējoties. Ievades metodes atlases noņemšana to izņem no cikla, to neatinstalējot; tastatūra paliek pieejama.

Palaidiet `omarchy setup keyboard` vai `omarchy setup input`, lai atvērtu tos pašus atlasītājus. Lai no komandrindas pievienotu vienu valodu, izmantojiet `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` vai `cangjie5`. Quick, Boshiamy un Array ir iekļauti tajā pašā pakotnē, kur Cangjie, un parādās Input Methods atlasītājā. Jūsu pielāgotie pārslēgšanas taustiņi tiek saglabāti. Alternatīviem dzinēja izkārtojumiem vai taustiņiem instalējiet `fcitx5-configtool` ar komandu `omarchy pkg add fcitx5-configtool` un palaidiet to no termināļa. Ievades valodas atlase nemaina darbvirsmas valodu. Japāņu, korejiešu vai ķīniešu valodas izvēle sadaļā _Setup > Language_ pievieno tās ievades metodi, ja jums vēl nav nevienas.

Izmantojiet `Super + I`, lai cikliski pārslēgtos starp ievades metodēm vai tastatūras izkārtojumiem, un `Super + Shift + I`, lai dotos pretējā virzienā, tāpēc ar trim konfigurētām iespējām varat pārvietoties starp diviem kaimiņiem. Ievades indikators parādās joslas labajā pusē tikai tad, ja ir konfigurēta vairāk nekā viena ievades metode vai izkārtojums. Šī darbvirsmas saistīšana darbojas līdzās jūsu esošajiem Fcitx pārslēgšanas taustiņiem; varat to pārrakstīt failā `~/.config/hypr/bindings.lua`. Ievades dzinēji un compose secības izmanto [Fcitx5](https://fcitx-im.org/) pakalpojumu, kas jau darbojas katrā sesijā.

### ALT izmantošana SUPER vietā

Dažās tastatūrās galveno meta taustiņu (Windows/cmd taustiņu) nav ērti izmantot kā SUPER. Tā vietā varat to mainīt uz ALT, veicot šādas izmaiņas:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
