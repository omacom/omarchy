# Mga Hotkey

Makikita mo ang lahat ng pangunahing keyboard binding sa `Super + K` (mga binding ng Tmux sa `Super + Alt + K` at mga binding ng Herdr sa `Super + Ctrl + K`).

## Paano nakaayos ang mga hotkey

Nasa isang plane ang bawat hotkey, na itinatakda ng mga modifier nito, at may iisang trabaho ang bawat plane. Iyon ang pumipigil sa mga hotkey na magkagulo, at nangangahulugan itong kadalasan ay mahuhulaan mo kung saan naroon ang isang bagay.

| Plane | Ano ang naroon | Mga halimbawa |
| --- | --- | --- |
| `Super + key` | Ang system: mga window, workspace, layout, at pangunahing menu | `Super + Space` menu ng Omarchy, `Super + W` isara ang window, `Super + F` full screen |
| `Super + Shift + key` | Mga app | `Super + Shift + B` browser, `Super + Shift + E` email, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Mga panel at menu ng system | `Super + Ctrl + A` audio, `Super + Ctrl + N` network, `Super + Ctrl + C` menu ng pagkuha |
| `Super + Ctrl + Alt + key` | Mga mabilisang pagkilos at paunawa | `Super + Ctrl + Alt + T` ipakita ang oras, `Super + Ctrl + Alt + B` baterya, `Super + Ctrl + Alt + C` screenshot |

Ang pagdaragdag ng `Alt` sa isang hotkey ay nagbibigay sa iyo ng variant ng parehong bagay, hindi kailanman ng ibang bagay na walang kaugnayan:

- Binubuksan ng `Super + Shift + B` ang browser; binubuksan ng `Super + Shift + Alt + B` ang isang private window
- Binubuksan ng `Super + Shift + E` ang email; nagsisimula ng bago ang `Super + Shift + Alt + E`
- Nagfu-full screen ang `Super + F`; nagfu-full width ang `Super + Alt + F`
- Binubuksan ng `Super + Ctrl + C` ang menu ng pagkuha; nilalaktawan ng `Super + Ctrl + Alt + C` ang menu at kumukuha ng screenshot

Kapag nagdaragdag ng hotkey:

1. Piliin ang plane mula sa ginagawa nito, pagkatapos ay piliin ang key.
2. Huwag ilipat ang isang umiiral na hotkey para magkaroon ng puwang. Maghanap ng bakanteng key sa tamang plane.
3. Gamitin lamang ang `Alt` para sa variant ng hotkey na wala nito.

Binabasag ng ilang hotkey ang mga patakarang ito dahil maginhawa ang mga ito. Ang `Shift` na may arrow o `Tab` ay naglilipat o bumabaligtad sa halip na magbukas ng app, at ang `Print`, ang mga media key, `Alt + Tab`, at `Ctrl + Alt + Del` ay gumagana sa paraang gumagana ang mga ito sa lahat ng iba pang lugar. Mga exception ang mga ito, hindi mga pattern na dapat gayahin.

Kung hindi angkop sa iyo ang isang default (halimbawa ay gusto mo ang `Super + Shift + S` para sa mga screenshot gaya sa Windows), i-rebind ito sa `~/.config/hypr/bindings.lua`.

## Pag-navigate

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu ng Omarchy (mga app at lahat ng iba pa)    |
| `Super + Alt + Space` | Grid ng app |
| `Super + Escape` | Menu ng system (suspend, restart, atbp.)  |
| `Super + Ctrl + L` | I-lock ang computer |
| `Super + W` or `Super + Q` | Isara ang window             |
| `Ctrl + Alt + Del` | Isara ang lahat ng window |
| `Super + K` | Ipakita ang lahat ng hotkey |
| `Super + Alt + K` | Ipakita ang mga hotkey ng tmux |
| `Super + Ctrl + K` | Ipakita ang mga hotkey ng herdr |
| `Super + M` | I-minimize ang window sa dock |
| `Super + T`               | Ilipat ang window sa pagitan ng tiling/floating             |
| `Super + J` | Ilipat ang posisyon ng window (pahalang/patayo) |
| `Super + O`               | Ilipat ang pag-pop ng window sa sticky'n'floating |
| `Super + L`               | Magpalit-palit sa mga layout na dwindle, scrolling, at floating |
| `Super + Alt + L`         | Magpalit-palit sa mga layout nang pabaligtad |
| `Super + P`               | Ilipat ang estilo ng pseudo window (natural v stretch) |
| `Super + F`                 | Mag-full screen              |
| `Super + Alt + F`                 | Mag-full width              |
| `Super + Ctrl + F`                 | Mag-full screen sa loob ng window              |
| `Super + 1…9/0`         | Tumalon sa partikular na workspace (ang 0 ay 10) sa nakatuong monitor |
| `Super + Tab` | Tumalon sa susunod na workspace sa nakatuong monitor |
| `Super + Shift + Tab` | Tumalon sa nakaraang workspace sa nakatuong monitor |
| `Super + Ctrl + Tab` | Tumalon sa dating workspace sa nakatuong monitor |
| `Super + Shift + 1…9/0` | Ilipat ang window sa workspace sa nakatuong monitor |
| `Super + Shift + Alt + 1…9/0` | Ilipat ang window sa workspace sa nakatuong monitor nang hindi sumusunod |
| `Super + S` | Ilipat ang buong scratchpad |
| `Super + Alt + S` | Ilipat ang window sa buong scratchpad |
| `Super + the key above Tab` (grave on US layouts) | Ilipat ang Quake console |
| `Super + Shift + the key above Tab` (grave on US layouts) | Ilipat ang window sa Quake console |
| `Super + Shift + Ctrl + Arrows` | Ilipat ang window sa monitor sa direksyong iyon |
| `Super + Shift + Alt + Arrows` | Ilipat ang workspace sa monitor sa direksyong iyon |
| `Super + Arrow`  | Ilipat ang focus sa window sa direksyon ng arrow, tumatawid sa monitor sa panig na iyon sa gilid ng screen |
| `Super + Shift + Arrow`  | Ipalit ang window sa isa pa sa direksyon ng arrow, kabilang ang nasa monitor sa panig na iyon |
| `Super + Minus` | Palawakin ang window pakaliwa |
| `Super + Equal` | Paliitin ang window pakaliwa |
| `Super + Shift + Minus` | Paliitin ang window pataas |
| `Super + Shift + Equal` | Palawakin ang window pababa |
| `Super + Alt + Minus/Equal` | Parehong pag-resize sa mas maliliit na hakbang |
| `Super + Ctrl + Minus/Equal` | Parehong pag-resize sa mas malalaking hakbang |
| `Super + Alt + Home` | I-save ang lapad ng window |
| `Super + Home` | Ibalik ang na-save na lapad ng window |
| `Super + Left Mouse` | I-drag ang window sa paligid |
| `Super + Right Mouse` | I-resize ang window |
| `Super + Scroll Wheel` | Mag-scroll sa mga workspace sa nakatuong monitor |
| `Super + G`               | Ilipat ang pagpapangkat ng window      |
| `Super + Alt + G`               | Ilipat ang window palabas ng pagpapangkat      |
| `Super + Alt + Tab`               | Magpalit-palit sa mga window sa pagpapangkat      |
| `Super + Alt + Shift + Tab`               | Magpalit-palit nang paatras sa mga window sa pagpapangkat      |
| `Super + Alt + Scroll Wheel` | Magpalit-palit sa mga window sa pagpapangkat |
| `Super + Alt + 1/2/3/4/5`               | Tumalon sa partikular na window sa pagpapangkat      |
| `Super + Alt + Arrow`  | Ilipat ang window sa pagpapangkat sa direksyon ng arrow, kabilang ang nasa monitor sa panig na iyon |
| `Super + Ctrl + Left/Right`  | Lumipat sa mga window sa loob ng isang tiling group |
| `Super + Ctrl + Z` | Mag-zoom in sa screen (ulitin para sa mas maraming zoom) |
| `Super + Ctrl + Alt + Z` | Mag-zoom out nang buo mula sa screen |
| `Super + /` | Humakbang pasulong sa mga opsyon sa pag-scale ng monitor |
| `Super + Alt + /` | Humakbang paatras sa mga opsyon sa pag-scale ng monitor |
| `Alt + Tab` | Magpalit-palit pasulong sa mga window sa aktibong workspace |
| `Alt + Shift + Tab` | Magpalit-palit paatras sa mga window sa aktibong workspace |
| `Ctrl + Alt + Tab`| Magpalit ng focus pasulong sa mga monitor |
| `Ctrl + Alt + Shift + Tab`| Magpalit ng focus paatras sa mga monitor |
| `Super + I` | Palitan ang input language (na may higit sa isang layout o input method) |
| `Super + Shift + I` | Ibalik ang input language |

Sa isang touchpad, ang mga swipe na may tatlo at apat na daliri ay nagpapalit ng mga workspace, naglilipat ng mga window, at nagbubukas ng menu at ng Quake console; tingnan ang [keyboard, mouse, at trackpad](34-keyboard-mouse-trackpad.md) para sa mga gesture.

Ginagamit ng pag-resize ang dalawang key sa kanan ng 0, anuman ang nakalimbag sa mga ito ng iyong keyboard: `-` at `=` sa mga keyboard na US, `+` at `´` sa Danish at Swedish, `+` at `\` sa Norwegian, `ß` at `´` sa German, `'` at `¡` sa Spanish, at `-` at `^` sa Japanese (JIS). Inililista ng `Super + K` ang mga ito gaya ng pagkakalimbag ng iyong keyboard sa mga ito. Sa JIS, ang `Super + ^` ay `Super + Equal`, habang ang `Super + Shift + -` (na nagta-type ng `=`) ay `Super + Shift + Minus`. Ginagamit ng pag-scale ng monitor at ng password manager ang `/`; sa mga layout na nagta-type lamang ng `/` gamit ang Shift, gaya ng karamihan sa mga European, ginagamit ng mga ito ang key sa kaliwa ng right Shift sa halip (`-` sa Danish at German).

## Mga kontrol ng system

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel ng audio    |
| `Super + Ctrl + B`           | Panel ng Bluetooth    |
| `Super + Ctrl + N`           | Panel ng Wi-Fi/network    |
| `Super + Ctrl + D`           | Panel ng display    |
| `Super + Ctrl + P`           | Panel ng power    |
| `Super + Ctrl + X`           | Panel ng mga agent    |
| `Super + Ctrl + Alt + X`           | Panel ng mga lokal na modelo    |
| `Super + Ctrl + Alt + D`           | Panel ng kalendaryo    |
| `Super + Ctrl + Alt + E`           | Panel ng orasan ng mundo    |
| `Super + Ctrl + 1-9`           | Ilipat ang panel ng bar ayon sa posisyon    |
| `Super + Ctrl + S` | Menu ng pagbabahagi (sa pamamagitan ng LocalSend) |
| `Super + Ctrl + C` | Mga kontrol sa pagkuha (screenshot/-recording/picker) |
| `Super + Ctrl + O` | Ilipat ang menu |
| `Super + Ctrl + H` | Menu ng hardware |
| `Super + Ctrl + E` | Tagapili ng emoji |
| `Super + Ctrl + .` | I-transcode ang media |
| `Super + Shift + Ctrl + A` | Simulan ang iyong default na agent |
| `Power` key | Menu ng system |
| `Super + Shift + Copilot` key | Menu ng Omarchy |

## Mga pagsasaayos

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Pinakamataas na liwanag ng screen |
| `Shift + Brightness Down` | Pinakamababang liwanag ng screen |
| `Alt + Brightness Up/Down` | Mga tumpak na pagbabago ng liwanag na 1% |
| `Alt + Volume Up/Down` | Mga tumpak na pagbabago ng volume na 1% |
| `Keyboard Brightness Up/Down` | Mas maliwanag/mas madilim na backlight ng keyboard |
| `Keyboard Backlight` | Magpalit-palit sa mga antas ng backlight ng keyboard |
| `Ctrl + Brightness Up/Down` | Mas maliwanag/mas madilim na backlight ng keyboard, sa mga keyboard na walang sariling mga key |
| `Mic Mute` | I-mute ang mikropono |
| `Shift + Mute` | Palitan ang audio output |
| `Touchpad Toggle` | I-on o i-off ang touchpad |
| `Display` key | Magpalit-palit sa layout ng workspace |
| `Alt + Play` | Susunod na track |
| `Alt + Shift + Play` | Nakaraang track |

## Paglulunsad ng mga app

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal ng Tmux |
| `Super + Ctrl + Return` | Herdr (tagapamahala ng agent) |
| `Super + Shift + Return` or `Super + Shift + B`  | Browser    |
| `Super + Shift + Alt + B`           | Browser (private/incognito)    |
| `Super + Shift + F`           | Tagapamahala ng file    |
| `Super + Shift + Alt + F`           | Tagapamahala ng file sa cwd ng terminal    |
| `Super + Shift + M`           | Musika (Spotify)    |
| `Super + Shift + Alt + M`           | Musika (cliamp)    |
| `Super + Shift + /`           | Tagapamahala ng password (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Calculator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, kapag na-install na)    |
| `Super + Shift + T`           | Aktibidad (btop)    |
| `Super + Shift + N`           | Editor (Plain, o ang napili mong default)  |
| `Super + Shift + C`           | Kalendaryo ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Email ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Bagong email ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Ang iyong default na agent, o ChatGPT hanggang sa pumili ka ng isa |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Messenger (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Messenger (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Messenger (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Pagsusulat (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (bagong post) |
| `Super + Shift + Y`           | YouTube |

Baguhin/idagdag ang mga binding sa `~/.config/hypr/bindings.lua`.

## Universal na clipboard

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + A`           | Piliin ang lahat sa mga app na sumusuporta sa `Ctrl + A`    |
| `Super + C`           | Kopyahin    |
| `Super + X`           | I-cut (hindi sa terminal)    |
| `Super + V`           | I-paste    |
| `Super + Ctrl + V`           | Tagapamahala ng clipboard    |

Kadalasan sa Linux, kailangan mo ang `Ctrl + Shift + C/V` para mag-copy'n'paste sa terminal at `Ctrl + C/V` para gawin ito sa lahat ng iba pang lugar. Gumagana ang mga pinag-isang hotkey ng clipboard ng Omarchy na ito sa lahat ng lugar.

## Pagkuha

| Hotkey              | Tungkulin                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Screenshot                      |
| `Super + Ctrl + Alt + C`            | Screenshot (ang parehong kuha, para sa mga keyboard na walang Print Screen key) |
| `Super + Ctrl + C` | Menu ng pagkuha |
| `Alt + Print Screen`            | Screenrecord                     |
| `Super + Shift + Ctrl + Alt + C` | Screenrecord na walang audio, nilalaktawan ang menu (pindutin muli upang ihinto) |
| `Super + Print Screen` | Tagapili ng kulay |
| `Super + Ctrl + Print Screen` | Pagkuha ng teksto sa clipboard |
| `Super + Alt + [` | Paliitin ang overlay ng webcam habang nagre-record |
| `Super + Alt + ]` | Palakihin ang overlay ng webcam habang nagre-record |
| `Alt + Shift + L` | Kopyahin ang kasalukuyang URL mula sa webapp o browser |
| `Alt + Shift + D` | I-download ang video sa kasalukuyang pahina sa `~/Videos` |
| `Alt + Space` | Simulan/ihinto ang pagdidikta (nangangailangan ng _Setup > Defaults > Dictation_) |
| `Right Alt` | Hawakan upang magdikta (nangangailangan ng _Setup > Defaults > Dictation_) |

Sa mga screenrecording, tinatanong muna ng hotkey kung aling audio ang gusto mo, pagkatapos ay magsisimula ng pag-record. Pindutin muli upang ihinto. Tingnan ang [mga screenshot at pag-record](12-screenshots-recording.md) para sa mga detalye.

Maa-access din ang lahat ng opsyon sa pagkuha sa ilalim ng _Trigger > Capture_ sa menu ng Omarchy (`Super + Space`).

## Mga abiso

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + ,` | Kumilos sa pinakabagong abiso: buksan ito o pindutin ang nag-iisa nitong button, pumili mula sa mga pagpipilian nito, o i-dismiss ito kapag wala ito ng mga ito  |
| `Super + Shift + ,` | I-dismiss ang lahat ng abiso |
| `Super + Ctrl + ,` | Kontrolin ang mga abiso gamit ang keyboard  |
| `Super + Alt + ,` | I-dismiss ang pinakabagong abiso  |
| `Super + Shift + Alt + ,` | Buksan ang kasaysayan ng abiso  |
| `Super + Ctrl + Alt + ,` | Ilipat ang pagpapatahimik sa mga abiso  |

## Estilo

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Pumili ng bagong tema (din ang `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Pumili ng background ng tema (din ang `Super + Ctrl + Space`) |
| `Super + Backspace` | Ilipat ang transparency sa isang window |
| `Super + Ctrl + Backspace` | Ilipat ang single-window square aspect |

Nasa `~/.config/omarchy/backgrounds/<theme name>` ang mga karagdagang larawan ng background. Magagamit din sa pamamagitan ng _Install > Style > Background_ sa menu ng Omarchy.

Maa-access din ang lahat ng opsyon sa estilo sa ilalim ng _Appearance_ sa menu ng Omarchy (`Super + Space`).

## Mga toggle

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Ilipat ang pag-lock kapag idle |
| `Super + Ctrl + Delete` | Ilipat ang display ng laptop sa on/off |
| `Super + Ctrl + Alt + Delete` | Ilipat ang pag-mirror ng display ng laptop |
| `Super + Shift + Space` | Ilipat ang top bar  |
| `Shift + Mute` | Lumipat sa susunod na audio output |
| `Shift + Play` | Lumipat sa susunod na media source |
| `Super + Shift + Backspace` | Ilipat ang mga gap ng window |
| `Super + Ctrl + Alt + F` | Ilipat ang full screen desktop (top bar + mga gap ng window) |

## Mga paalala

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Magtakda ng paalala  |
| `Super + Ctrl + Alt + R` | Tingnan ang lahat ng paalala  |
| `Super + Ctrl + Shift + R` | I-clear ang lahat ng paalala  |

## Mga paunawa

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Ipakita ang oras bilang abiso  |
| `Super + Ctrl + Alt + B` | Ipakita ang baterya bilang abiso  |
| `Super + Ctrl + Alt + W` | Ilipat ang panahon bilang abiso  |

## Tmux

Ang prefix key ay `Ctrl + Space` (gumagana rin ang `Ctrl + B`). Maaari mong baguhin ang mga binding na ito sa `~/.config/tmux/tmux.conf`.

### Mga pane

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Prefix + v` | Hatiin ang pane sa tabi (patayo) |
| `Prefix + h` | Hatiin ang pane sa ibaba (pahalang) |
| `Prefix + x` | Patayin ang pane |
| `Prefix + z` | Ilipat ang zoom ng pane (fullscreen) |
| `Alt + Enter` | Hatiin ang pane sa ibaba (walang prefix) |
| `Alt + Shift + Enter` | Hatiin ang pane sa tabi (walang prefix) |
| `Alt + Escape` | Patayin ang pane (walang prefix) |
| `Ctrl + Alt + Arrows` | Lumipat sa mga pane |
| `Ctrl + Alt + Shift + Arrows` | I-resize ang mga pane |

### Mga window

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Prefix + c` | Bagong window |
| `Prefix + k` | Patayin ang window |
| `Prefix + r` | Palitan ang pangalan ng window |
| `Alt + 1-9` | Pumunta sa partikular na window |
| `Alt + Arrow Left/Right` | Lumipat sa mga window |
| `Alt + Shift + Arrow Left/Right` | Ilipat ang window pakaliwa/pakanan |

### Mga session

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Prefix + C` | Bagong session |
| `Prefix + K` | Patayin ang session |
| `Prefix + R` | Palitan ang pangalan ng session |
| `Prefix + N` | Susunod na session |
| `Prefix + P` | Nakaraang session |
| `Alt + Arrow Up/Down` | Lumipat sa mga session |
| `Prefix + s` | Ilista ang mga session |
| `Prefix + d` | Kumalas mula sa session |

### Copy mode (istilong vi)

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Prefix + [` | Pumasok sa copy mode |
| `v` | Simulan ang pagpili (sa copy mode) |
| `y` | Kopyahin ang napili (sa copy mode) |

### Pangkalahatan

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Prefix + q` | I-reload ang config |
| `Prefix + ?` | Ipakita ang mga keybinding ng Tmux |
| `Prefix + :` | Prompt ng command |

### Mga function ng layout ng Tmux

Dapat patakbuhin ang mga function na ito sa loob ng isang session ng Tmux.

| Command | Tungkulin |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Gumawa ng dev layout na may editor, AI, at terminal |
| `tdlm <ai> [<second_ai>]` | Gumawa ng dev layout bawat subdirectory |
| `tsl <count> <command>` | Gumawa ng multi-pane swarm layout |

## Terminal ng Ghostty

Ini-install ang terminal ng Ghostty gamit ang _Install > Terminal_ sa pamamagitan ng menu ng Omarchy.

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Bagong split sa ibaba |
| `Ctrl + Shift + O` | Bagong split sa tabi |
| `Ctrl + Alt + Arrows` | Lumipat sa mga split |
| `Super + Ctrl + Shift + Arrows` | I-resize ang split ng 10 linya |
| `Super + Ctrl + Shift + Alt + Arrows` | I-resize ang split ng 100 linya |
| `Ctrl + Shift + T` | Bagong tab  |
| `Ctrl + Shift + Arrows` | Lumipat sa mga tab |
| `Alt + Numbers` | Pumunta sa partikular na tab |
| `Shift + Pg Up/Down` | I-scroll ang kasaysayan |
| `Ctrl + Left mouse` | Buksan ang link sa browser |

## Tagapamahala ng file

| Hotkey              | Tungkulin                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Pumunta sa path                     |
| `Space`               | I-preview ang file (nagna-navigate ang mga arrow) |
| `Alt + Up`       | Umakyat sa parent folder        |

## Neovim (w/ lazyvim)

### Pag-navigate

| Hotkey                   | Tungkulin                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Ipakita ang mga opsyon ng command            |
| `Space Space`              | Buksan ang file sa pamamagitan ng fuzzy search      |
| `Space E`                  | Ilipat ang sidebar                  |
| `Space G G`                | Ipakita ang mga kontrol ng git               |
| `Space S G`                | Hanapin ang nilalaman ng file             |
| `Ctrl + W W`               | Tumalon sa pagitan ng sidebar at editor |
| `Ctrl + Left/right arrow`  | Baguhin ang laki ng sidebar          |
| `Shift + H`                      | Pumunta sa kaliwang tab ng file             |
| `Shift + L`                      | Pumunta sa kanang tab ng file            |
| `Space B D`                | Isara ang tab ng file                  |

### Habang nasa sidebar

| Hotkey                   | Tungkulin                        |
| ------------------------ | ------------------------------- |
| `A`                        | Magdagdag ng bagong file sa parent dir      |
| `Shift + A`                | Magdagdag ng bagong subdir sa parent dir    |
| `D`                        | Tanggalin ang naka-highlight na file/dir     |
| `M`                        | Ilipat ang naka-highlight na file/dir       |
| `R`                        | Palitan ang pangalan ng naka-highlight na file/dir     |
| `?`                        | Ipakita ang tulong para sa lahat ng command      |

[Tingnan ang lahat ng hotkey ng Neovim na naka-configure ng LazyVim](https://www.lazyvim.org/keymaps).

## Mabilisang mga Emoji

Maaari mong gamitin ang `Super + Ctrl + E` upang ipakita ang isang kumpletong tagapili ng emoji na maglalagay ng napili sa clipboard o maaari mong gamitin ang mga opsyon sa mabilisang pag-access na ito.

| Hotkey       | EM | Pahiwatig       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | ngiti      |
| `Shift + CapsLock M C` | 😂 | iyak        |
| `Shift + CapsLock M L` | 😍 | pag-ibig       |
| `Shift + CapsLock M V` | ✌️ | tagumpay    |
| `Shift + CapsLock M H` | ❤️ | puso      |
| `Shift + CapsLock M Y` | 👍 | oo        |
| `Shift + CapsLock M N` | 👎 | hindi         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | hiling       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | halik       |
| `Shift + CapsLock M E` | 🙄 | eyeroll    |
| `Shift + CapsLock M I` | 😉 | kindat       |
| `Shift + CapsLock M P` | 🙏 | dasal |
| `Shift + CapsLock M D` | 🤤 | laway      |
| `Shift + CapsLock M M` | 💰 | pera      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pagbati |
| `Shift + CapsLock M A` |💪 | braso |
| `Shift + CapsLock M B` |🤯 | pagsabog |

## Mabilisang mga Pagkumpleto

| Hotkey       | Pagkumpleto       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Ang pangalan mo (gaya ng inilagay sa setup)  |
| `Shift + CapsLock Space E` | Ang email mo (gaya ng inilagay sa setup)  |

Maaari kang magdagdag pa ng sarili mo sa pamamagitan ng pag-edit sa `~/.XCompose`, pagkatapos ay patakbuhin ang `omarchy restart xcompose` sa terminal upang makuha ang mga pagbabago.
