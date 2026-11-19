# Tastatūra, pele, skārienpaliktnis

Hyprland ļauj ļoti detalizēti konfigurēt visas ievadierīces. Vari iestatīt tastatūras atkārtošanos virsskaņas ātru vai likt skārienpaliktnim izmantot dabisko ritināšanu. Visu to maini failā `~/.config/hypr/input.lua`, kuram vari piekļūt arī caur _Setup > Input_ Omarchy izvēlnē (`Super + Space`). Viss, ko tur iestatīsi, aizstās Omarchy noklusējumus.

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

Visas ievades opcijas vari [skatīt Hyprland wiki par ievadēm](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock darbojas kā parasts Caps Lock, un `Shift + CapsLock` ir rakstzīmes veidošanas taustiņš [ātrajām emocijzīmēm](07-hotkeys.md#quick-emojis) un [citiem papildinājumiem](07-hotkeys.md#quick-completions). Ja vēlies, lai rakstzīmes veidošanas taustiņš būtu citur, `kb_options` aizstāj `omarchy:shift_caps_compose`. Piemēram, šis pārvieto rakstzīmes veidošanas taustiņu uz Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkciju taustiņi

Klēpjdatora tastatūras augšējā rinda pēc noklusējuma sūta multivides taustiņus (skaļums, spilgtums utt.), un, turot `Fn`, iegūsti F1-F12; `Fn + Esc` pārslēdz to otrādi, līdz to nospied vēlreiz. Lielākā daļa tastatūru šo bloķēšanu atceras pašas. ASUS klēpjdatori un Apple stila tastatūras to atstāj Linux ziņā, kas katrā palaišanas reizē tās sāk ar multivides taustiņiem. Lai tās tā vietā sāktos ar F1-F12, palaid `omarchy device keyboard toprow fnkeys` (un `omarchy device keyboard toprow mediakeys`, lai atgrieztos atpakaļ); dažos klēpjdatoros tas stājas spēkā pēc pārstartēšanas. Apple Silicon Mac datori saglabā savu iestatījumu.

### Skārienpaliktņa žesti

Velc pa skārienpaliktni, lai pārvietotos pa darbvirsmu:

| Žests | Darbība |
| --- | --- |
| Trīs pirksti pa kreisi / pa labi | Iepriekšējā / nākamā darbvieta, tostarp tukšās |
| Trīs pirksti uz augšu | Pārslēgt AI konsoli |
| Trīs pirksti uz leju | Atvērt Omarchy izvēlni |
| Četri pirksti pa kreisi / pa labi | Pārvietot aktīvo logu uz iepriekšējo / nākamo darbvietu |
| Četri pirksti uz leju | Pārslēgt pilnekrāna režīmu |

Lai mainītu kādu žestu, vispirms atiestati to failā `~/.config/hypr/input.lua`, pirms pievieno savu [skārienpaliktņa žestu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), jo Hyprland nepieņems divus žestus ar vieniem un tiem pašiem pirkstiem un virzienu:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Lai izslēgtu visus Omarchy žestus, faila `~/.config/hypr/hyprland.lua` augšdaļā, pirms tiek ielādēti Omarchy noklusējumi, iestati `omarchy_default_gestures = false`.

Dell XPS klēpjdatoros ar haptisko skārienpaliktni klikšķa stiprumu vari iestatīt kā low, mid vai high sadaļā _Trigger > Hardware > Touchpad Haptics_.

### Rakstīšana ķīniešu, japāņu un citās valodās

Kad instalētājs jautā par tastatūru, izvēlies japāņu, korejiešu, ķīniešu (vienkāršotā, Pinyin), Taivānas (Zhuyin) vai Honkongas (Cangjie). Omarchy tastatūru un atbilstošo ievades dzini konfigurē automātiski, arī bezsaistes pirmās palaišanas iestatīšanas laikā. Japāņu valodai tiek lietots Mozc, korejiešu valodai — standarta divu kopu Hangul, vienkāršotajai ķīniešu valodai — Pinyin, Taivānai — Chewing standarta Zhuyin izkārtojums, bet Honkongai — Cangjie ar Honkongas rakstzīmju formām. Japāņu (US keyboard) nodrošina Mozc ar US tastatūras izkārtojumu. Hangul, Zhuyin un Cangjie taustiņi paliek savās standarta vietās arī tad, ja latīņu burtus raksti ar Dvorak, Colemak vai AZERTY. Ja Hangul vai Chewing pievienoji jau iepriekš, sadaļā _Setup > Keyboard > Input Methods_ noņem tam atlasi un atlasi to no jauna, lai pārvietotu tā taustiņus tur; Omarchy dzini, ar kuru jau raksti, atstāj mierā.

Rakstīšana sākas latīņu režīmā. Nospied `Super + I`, lai cikliski pārslēgtos cauri konfigurētajām ievades metodēm, un `Super + Shift + I`, lai cikliski pārslēgtos atpakaļ. Pieskaries `Shift` atsevišķi, lai izkāptu no tādas ievades metodes kā Pinyin uz latīņu burtiem, un pieskaries tam vēlreiz, lai atgrieztos atpakaļ — tā, kā darbojas Sogou, Microsoft Pinyin un macOS; `Shift` kopā ar burtu joprojām raksta lielo burtu. Japāņu tastatūrās 全角/半角 pārslēdz ievadi, 変換 to ieslēdz un 無変換 to izslēdz. Korejiešu valodā 한/영 pārslēdz Hangul un 한자 pārveido par Hanja neatkarīgi no tā, vai tastatūrai ir īpaši taustiņi šim nolūkam vai tā tiem sūta Right Alt un Right Ctrl, kā to dara daudzi klēpjdatori, tāpēc Right Alt un Right Ctrl tur nav parasti pārveidotāji; diktēšana tā vietā pārslēdzas ar Alt + Space. `Ctrl + Space` paliek pieejams Tmux un Herdr; `Shift + CapsLock` paliek rakstzīmes veidošanas taustiņš.

Tastatūras indikators parādās joslas labajā pusē, kad tev ir vairāki tastatūras izkārtojumi vai ievades metodes. Noklikšķini uz tā, lai pārslēgtu ievades valodas; japāņu valoda hiraganai rāda あ. Lai izvēlētos japāņu rakstzīmes, pārslēdzies uz japāņu valodu, ieraksti vārdu, piemēram, `nihongo`, pēc tam divreiz nospied Space. Nospied Enter, lai apstiprinātu izvēli. Ja tev ir arī vairāki tastatūras izkārtojumi, ar labo pogu noklikšķini uz indikatora, lai cikliski pārslēgtos starp tiem.

Izmanto _Setup > Keyboard > Keyboard Inputs_, lai izvēlētos tādus izkārtojumus kā angļu un franču no tām pašām izvēlēm, kas tiek piedāvātas instalēšanas laikā. Izmanto _Setup > Keyboard > Input Methods_, lai izvēlētos, kuri sastādīšanas dziņi ir aktīvi. Abas izvēlētājas atveras Omarchy izvēlnes iekšpusē ar atzīmētām tavām pašreizējām izvēlēm. Noklikšķini vai nospied Enter, lai pārslēgtu izvēli; katras izmaiņas stājas spēkā nekavējoties. Ievades metodes atlases noņemšana izņem to no cikla, to neatinstalējot; tastatūra paliek pieejama.

Palaid `omarchy setup keyboard` vai `omarchy setup input`, lai atvērtu tās pašas izvēlētājas. Lai no komandrindas pievienotu vienu valodu, izmanto `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` vai `cangjie5`. Quick, Boshiamy un Array nāk tajā pašā pakotnē kā Cangjie un parādās Input Methods izvēlētājā. Tavi pielāgotie pārslēgšanas taustiņi tiek saglabāti. Alternatīviem dziņu izkārtojumiem vai taustiņiem instalē `fcitx5-configtool` ar `omarchy pkg add fcitx5-configtool` un palaid to no termināļa. Ievades valodas izvēle nemaina darbvirsmas valodu. Japāņu, korejiešu vai ķīniešu valodas izvēle sadaļā _Setup > Language_ pievieno tās ievades metodi, ja tev vēl nav nevienas.

Izmanto `Super + I`, lai cikliski pārslēgtos cauri ievades metodēm vai tastatūras izkārtojumiem, un `Super + Shift + I`, lai ietu atpakaļ otrā virzienā, tāpēc ar trim konfigurētām vari pārvietoties starp diviem kaimiņiem. Ievades indikators joslas labajā pusē parādās tikai tad, ja ir konfigurēta vairāk nekā viena ievades metode vai izkārtojums. Šī darbvirsmas saīsne darbojas līdzās taviem esošajiem Fcitx pārslēgšanas taustiņiem; vari to pārrakstīt failā `~/.config/hypr/bindings.lua`. Ievades dziņi un rakstzīmes veidošanas secības izmanto [Fcitx5](https://fcitx-im.org/) pakalpojumu, kas jau darbojas katrā sesijā.

### ALT izmantošana kā SUPER

Dažās tastatūrās nav ērti izmantot primāro meta taustiņu (Windows/cmd taustiņu) kā SUPER. Tā vietā to vari nomainīt uz ALT, izmantojot šīs izmaiņas:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
