# Tastatūra, pele, skārienpaliktnis

Hyprland ļauj ļoti detalizēti konfigurēt visas ievades ierīces. Varat iestatīt tastatūras atkārtošanos virsskaņas ātrumā vai likt skārienpaliktnim izmantot dabisko ritināšanu. Visu to maināt failā `~/.config/hypr/input.lua`, kuram varat piekļūt arī caur _Iestatīšana > Ievade_ Omarchy izvēlnē (`Super + Space`). Viss, ko tur iestatāt, aizstāj Omarchy noklusējumus.

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

Varat [skatīt visas ievades opcijas](https://wiki.hypr.land/Configuring/Basics/Variables/#input) Hyprland wiki lapā par ievadēm.

CapsLock darbojas kā parasts Caps Lock, un `Shift + CapsLock` ir compose taustiņš [ātrajiem emoji](07-hotkeys.md#quick-emojis) un [citām pabeigšanām](07-hotkeys.md#quick-completions). Ja compose taustiņu vēlaties citur, `kb_options` aizstājiet `omarchy:shift_caps_compose`. Piemēram, šis pārvieto compose taustiņu uz Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Skārienpaliktņa žesti

Varat arī ieslēgt [skārienpaliktņa žestus](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), piemēram, vilkšanu ar trim pirkstiem, lai mainītu darbvietas:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Dell XPS klēpjdatoros ar haptisko skārienpaliktni klikšķa stiprumu varat iestatīt uz zemu, vidēju vai augstu sadaļā _Trigger > Hardware > Touchpad Haptics_.

### Rakstīšana ķīniešu, japāņu un citās valodās

Izvēlieties japāņu, korejiešu, ķīniešu (vienkāršotā, Pinyin), Taivānas (Zhuyin) vai Honkongas (Cangjie), kad instalētājs prasa jūsu tastatūru. Omarchy automātiski konfigurē tastatūru un atbilstošo ievades dzinēju, tostarp bezsaistes pirmās palaišanas iestatīšanas laikā. Japāņu valodai tiek izmantots Mozc, korejiešu valodai — standarta divu komplektu Hangul, vienkāršotajai ķīniešu valodai — Pinyin, Taivānai — Chewing standarta Zhuyin izkārtojums, bet Honkongai — Cangjie ar Honkongas rakstzīmju formām. Japāņu (US keyboard) nodrošina Mozc ar US tastatūras izkārtojumu. Hangul, Zhuyin un Cangjie taustiņi paliek savās standarta vietās pat tad, ja latīņu burtus rakstāt ar Dvorak, Colemak vai AZERTY. Ja Hangul vai Chewing pievienojāt pirms tam, noņemiet tā atlasi un atlasiet to no jauna sadaļā _Iestatīšana > Rakstīšana > Ievades metodes_, lai pārvietotu tā taustiņus tur; Omarchy dzinēju, ar kuru jau rakstāt, atstāj mierā.

Rakstīšana sākas latīņu režīmā. Nospiediet `Super + I`, lai pārslēgtos cauri konfigurētajām ievades metodēm, un `Super + Shift + I`, lai pārslēgtos atpakaļ. Pieskarieties atsevišķi taustiņam `Shift`, lai izietu no tādas ievades metodes kā Pinyin uz latīņu burtiem, un pieskarieties tam vēlreiz, lai atgrieztos, tāpat kā darbojas Sogou, Microsoft Pinyin un macOS; `Shift` plus burts joprojām raksta lielo burtu. Japāņu tastatūrās 全角/半角 pārslēdz ievadi, 変換 to ieslēdz un 無変換 to izslēdz. Ar korejiešu valodu 한/영 pārslēdz Hangul un 한자 pārveido par Hanja neatkarīgi no tā, vai jūsu tastatūrai ir īpaši taustiņi vai tā tiem sūta Right Alt un Right Ctrl, kā to dara daudzi klēpjdatori, tāpēc Right Alt un Right Ctrl tur nav parasti modifikatori; diktēšanas push-to-talk paliek uz F9. `Ctrl + Space` paliek pieejams Tmux un Herdr; `Shift + CapsLock` paliek compose taustiņš.

Tastatūras indikators parādās joslas labajā pusē, kad jums ir vairāki tastatūras izkārtojumi vai ievades metodes. Noklikšķiniet uz tā, lai pārslēgtu ievades valodas; japāņu valodai hiraganai tiek rādīts あ. Japāņu rakstzīmju izvēlēm pārslēdzieties uz japāņu valodu, ierakstiet tādu vārdu kā `nihongo`, pēc tam divreiz nospiediet Space. Nospiediet Enter, lai apstiprinātu savu izvēli. Ja jums ir arī vairāki tastatūras izkārtojumi, ar labo pogu noklikšķiniet uz indikatora, lai pārslēgtos cauri tiem.

Izmantojiet _Iestatīšana > Rakstīšana > Tastatūras izkārtojumi_, lai atlasītu tādus izkārtojumus kā angļu un franču valoda no tām pašām izvēlēm, kas tiek piedāvātas instalēšanas laikā. Izmantojiet _Iestatīšana > Rakstīšana > Ievades metodes_, lai atlasītu, kuri kompozīcijas dzinēji ir aktīvi. Abi atlasītāji atveras Omarchy izvēlnē ar jūsu pašreizējām izvēlēm atzīmētām. Noklikšķiniet vai nospiediet Enter, lai pārslēgtu izvēli; katra izmaiņa tiek piemērota nekavējoties. Ievades metodes atlases noņemšana to izņem no cikla, to neatinstalējot; tastatūra paliek pieejama.

Palaidiet `omarchy setup keyboard` vai `omarchy setup input`, lai atvērtu tos pašus atlasītājus. Lai no komandrindas pievienotu vienu valodu, izmantojiet `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` vai `cangjie5`. Quick, Boshiamy un Array nāk tajā pašā pakotnē ar Cangjie un parādās Input Methods atlasītājā. Jūsu pielāgotie pārslēgšanas taustiņi tiek saglabāti. Alternatīviem dzinēja izkārtojumiem vai taustiņiem instalējiet `fcitx5-configtool` ar `omarchy pkg add fcitx5-configtool` un palaidiet to no termināļa. Ievades valodas atlasīšana nemaina darbvirsmas valodu. Izvēloties japāņu, korejiešu vai ķīniešu valodu sadaļā _Iestatīšana > Valoda_, tiek pievienota tās ievades metode, ja jums vēl nav nevienas.

Izmantojiet `Super + I`, lai pārslēgtos cauri ievades metodēm vai tastatūras izkārtojumiem, un `Super + Shift + I`, lai ietu atpakaļ pretējā virzienā, tāpēc ar trim konfigurētām varat pārvietoties starp diviem kaimiņiem. Ievades indikators parādās joslas labajā pusē tikai tad, kad ir konfigurēta vairāk nekā viena ievades metode vai izkārtojums. Šī darbvirsmas saīsne darbojas līdzās jūsu esošajiem Fcitx pārslēgšanas taustiņiem; varat to pārrakstīt failā `~/.config/hypr/bindings.lua`. Ievades dzinēji un compose secības izmanto [Fcitx5](https://fcitx-im.org/) pakalpojumu, kas jau darbojas katrā sesijā.

### ALT izmantošana kā SUPER

Dažās tastatūrās nav ērti izmantot primāro meta taustiņu (Windows/cmd taustiņu) kā SUPER. Tā vietā varat to mainīt uz ALT, izmantojot šādas izmaiņas:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
