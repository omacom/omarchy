# Tastatūra, pele, skārienpaliktnis

Hyprland ļauj ļoti detalizēti konfigurēt visas ievadierīces. Vari padarīt tastatūras atkārtošanos virsskaņas ātru vai likt skārienpaliktnim izmantot dabisko ritināšanu. To visu maini failā `~/.config/hypr/input.lua`, kuram vari piekļūt arī caur _Setup > Input_ Omarchy izvēlnē (`Super + Space`). Viss, ko tur iestatīsi, aizstāj Omarchy noklusējumus.

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

Visas ievades opcijas vari [apskatīt Hyprland wiki](https://wiki.hypr.land/Configuring/Basics/Variables/#input) ievades sadaļā.

CapsLock darbojas kā parasts Caps Lock, un `Shift + CapsLock` ir salikšanas taustiņš [ātrajām emocijzīmēm](07-hotkeys.md#quick-emojis) un [citiem papildinājumiem](07-hotkeys.md#quick-completions). Ja labāk vēlies salikšanas taustiņu citur, aizstāj `omarchy:shift_caps_compose` parametrā `kb_options`. Piemēram, šādi salikšanas taustiņš tiek pārvietots uz Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funkciju taustiņi

Klēpjdatora tastatūras augšējā rinda pēc noklusējuma sūta multivides taustiņus (skaļumu, spilgtumu un tā tālāk), un, turot nospiestu `Fn`, iegūsti F1-F12; `Fn + Esc` to bloķē pretējā režīmā, līdz to nospied vēlreiz. Lielākā daļa tastatūru šo bloķēšanu atceras pašas. ASUS klēpjdatoriem un Apple stila tastatūrām tas ir atstāts Linux ziņā, kas katrā sāknēšanās reizē tos palaiž multivides taustiņu režīmā. Lai tā vietā tie sāktos F1-F12 režīmā, palaid `omarchy keyboard toprow fnkeys` (un `omarchy keyboard toprow mediakeys`, lai atgrieztos atpakaļ); dažos klēpjdatoros tas stājas spēkā pēc pārstartēšanas. Apple Silicon Mac datoriem ir savs iestatījums.

### Skārienpaliktņa žesti

Velc pa skārienpaliktni, lai pārvietotos pa darbvirsmu:

| Žests | Darbība |
| --- | --- |
| Trīs pirksti pa kreisi / pa labi | Iepriekšējā / nākamā darbvieta, ieskaitot tukšās |
| Trīs pirksti uz augšu | Pārslēgt AI konsoli |
| Trīs pirksti uz leju | Atvērt Omarchy izvēlni |
| Četri pirksti pa kreisi / pa labi | Pārvietot aktīvo logu uz iepriekšējo / nākamo darbvietu |
| Četri pirksti uz leju | Pārslēgt pilnekrāna režīmu |

Lai mainītu kādu no tiem, vispirms to atiestati failā `~/.config/hypr/input.lua`, pirms pievieno savu [skārienpaliktņa žestu](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), jo Hyprland nepieņems divus žestus ar vienādu pirkstu skaitu un virzienu:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Lai izslēgtu visus Omarchy žestus, iestati `omarchy_default_gestures = false` faila `~/.config/hypr/hyprland.lua` augšdaļā, pirms ielādējas Omarchy noklusējumi.

Dell XPS klēpjdatoros ar haptisko skārienpaliktni klikšķa stiprumu vari iestatīt kā zemu, vidēju vai augstu sadaļā _Trigger > Hardware > Touchpad Haptics_.

### Rakstīšana ķīniešu, japāņu un citās valodās

Kad instalētājs prasa tastatūru, izvēlies japāņu, korejiešu, ķīniešu (vienkāršotā, Pinyin), Taivānas (Zhuyin) vai Honkongas (Cangjie). Omarchy automātiski konfigurē tastatūru un atbilstošo ievades dzinēju, arī bezsaistes pirmās sāknēšanās iestatīšanas laikā. Japāņu valodai izmanto Mozc, korejiešu valodai — standarta divu komplektu Hangul, vienkāršotajai ķīniešu valodai — Pinyin, Taivānai — Chewing standarta Zhuyin izkārtojumu, bet Honkongai — Cangjie ar Honkongas rakstzīmju formām. Japanese (US keyboard) nodrošina Mozc ar US tastatūras izkārtojumu. Hangul, Zhuyin un Cangjie taustiņi paliek savās standarta pozīcijās pat tad, ja latīņu burtus raksti ar Dvorak, Colemak vai AZERTY. Ja Hangul vai Chewing pievienoji pirms tam, noņem tā atlasi un atlasi to vēlreiz sadaļā _Setup > Keyboard > Input Methods_, lai tā taustiņi pārvietotos turp; Omarchy dzinēju, ar kuru jau raksti, atstāj mierā.

Rakstīšana sākas latīņu režīmā. Nospied `Super + I`, lai cikliski pārslēgtos starp konfigurētajām ievades metodēm, un `Super + Shift + I`, lai pārslēgtos atpakaļ. Pieskaries `Shift` atsevišķi, lai izietu no tādas ievades metodes kā Pinyin uz latīņu burtiem, un pieskaries tam vēlreiz, lai atgrieztos atpakaļ, tāpat kā darbojas Sogou, Microsoft Pinyin un macOS; `Shift` plus burts joprojām raksta lielo burtu. Japāņu tastatūrās 全角/半角 pārslēdz ievadi, 変換 to ieslēdz un 無変換 to izslēdz. Korejiešu valodā 한/영 pārslēdz Hangul un 한자 pārveido par Hanja neatkarīgi no tā, vai tastatūrai ir īpaši taustiņi vai tā tiem sūta Right Alt un Right Ctrl, kā to dara daudzi klēpjdatori, tāpēc Right Alt un Right Ctrl tur nav parasti modificētāji; diktēšanu tā vietā pārslēdz ar Alt + Space. `Ctrl + Space` paliek pieejams Tmux un Herdr; `Shift + CapsLock` paliek salikšanas taustiņš.

Tastatūras indikators parādās joslas labajā pusē, kad tev ir vairāki tastatūras izkārtojumi vai ievades metodes. Noklikšķini uz tā, lai pārslēgtu ievades valodas; japāņu valodai hiraganai rāda あ. Japāņu rakstzīmju izvēlei pārslēdzies uz japāņu valodu, ieraksti vārdu, piemēram, `nihongo`, un pēc tam divreiz nospied Space. Nospied Enter, lai apstiprinātu izvēli. Ja tev ir arī vairāki tastatūras izkārtojumi, ar labo pogu noklikšķini uz indikatora, lai cikliski pārslēgtos starp tiem.

Izmanto _Setup > Keyboard > Keyboard Inputs_, lai izvēlētos izkārtojumus, piemēram, English un French, no tām pašām izvēlēm, kas tiek piedāvātas instalēšanas laikā. Izmanto _Setup > Keyboard > Input Methods_, lai izvēlētos, kuri salikšanas dzinēji ir aktīvi. Abi atlasītāji atveras Omarchy izvēlnē ar atzīmētām tavām pašreizējām izvēlēm. Noklikšķini vai nospied Enter, lai pārslēgtu izvēli; katra izmaiņa stājas spēkā nekavējoties. Ievades metodes atlases noņemšana to izņem no cikla, to neatinstalējot; tastatūra paliek pieejama.

Palaid `omarchy setup keyboard` vai `omarchy setup input`, lai atvērtu tos pašus atlasītājus. Lai no komandrindas pievienotu vienu valodu, izmanto `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` vai `cangjie5`. Quick, Boshiamy un Array nāk tajā pašā pakotnē ar Cangjie un parādās Input Methods atlasītājā. Tavi pielāgotie pārslēgšanas taustiņi tiek saglabāti. Alternatīviem dzinēja izkārtojumiem vai taustiņiem instalē `fcitx5-configtool` ar `omarchy pkg add fcitx5-configtool` un palaid to no termināļa. Ievades valodas izvēle nemaina darbvirsmas valodu. Japāņu, korejiešu vai ķīniešu valodas izvēle sadaļā _Setup > Language_ pievieno tās ievades metodi, ja tev vēl nav nevienas.

Izmanto `Super + I`, lai cikliski pārslēgtos starp ievades metodēm vai tastatūras izkārtojumiem, un `Super + Shift + I`, lai ietu atpakaļ pretējā virzienā, tāpēc ar trim konfigurētām vari pārvietoties starp diviem kaimiņiem. Ievades indikators joslas labajā pusē parādās tikai tad, kad ir konfigurēta vairāk nekā viena ievades metode vai izkārtojums. Šī darbvirsmas taustiņsaite darbojas līdzās taviem esošajiem Fcitx pārslēgšanas taustiņiem; vari to pārrakstīt failā `~/.config/hypr/bindings.lua`. Ievades dzinēji un salikšanas secības izmanto [Fcitx5](https://fcitx-im.org/) pakalpojumu, kas jau darbojas katrā sesijā.

### Izmanto ALT kā SUPER

Dažās tastatūrās nav ērti izmantot primāro metataustiņu (Windows/cmd taustiņu) kā SUPER. Tā vietā vari to mainīt uz ALT, veicot šādas izmaiņas:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
