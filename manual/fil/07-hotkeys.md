# Mga Hotkey

Makikita mo ang lahat ng pangunahing keyboard bindings sa `Super + K` (Tmux bindings sa `Super + Alt + K` at Herdr bindings sa `Super + Ctrl + K`).

## Paano nakaayos ang mga hotkey

Nakaupo ang bawat hotkey sa isang plane, na itinatakda ng mga modifier nito, at may isang trabaho ang bawat plane. Iyon ang pumipigil sa mga hotkey na magkagulo, at nangangahulugan ito na kadalasan ay mahuhulaan mo kung saan nakatira ang isang bagay.

| Plane | Ano ang naroon | Mga halimbawa |
| --- | --- | --- |
| `Super + key` | Ang sistema: mga window, workspace, layout, at mga pangunahing menu | `Super + Space` menu ng Omarchy, `Super + W` isara ang window, `Super + F` full screen |
| `Super + Shift + key` | Mga app | `Super + Shift + B` browser, `Super + Shift + E` email, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Mga panel at menu ng sistema | `Super + Ctrl + A` audio, `Super + Ctrl + N` network, `Super + Ctrl + C` menu ng pagkuha |
| `Super + Ctrl + Alt + key` | Mga mabilisang aksyon at notice | `Super + Ctrl + Alt + T` ipakita ang oras, `Super + Ctrl + Alt + B` baterya, `Super + Ctrl + Alt + C` screenshot |

Ang pagdaragdag ng `Alt` sa isang hotkey ay nagbibigay sa iyo ng variant ng parehong bagay, hindi kailanman ng isang bagay na walang kaugnayan:

- Binubuksan ng `Super + Shift + B` ang browser; binubuksan ng `Super + Shift + Alt + B` ang isang pribadong window
- Binubuksan ng `Super + Shift + E` ang email; nagsisimula ng bago ang `Super + Shift + Alt + E`
- Nagfu-full screen ang `Super + F`; nagfu-full width ang `Super + Alt + F`
- Binubuksan ng `Super + Ctrl + C` ang menu ng pagkuha; nilalaktawan ng `Super + Ctrl + Alt + C` ang menu at kumukuha ng screenshot

Kapag nagdaragdag ng hotkey:

1. Piliin ang plane mula sa kung ano ang ginagawa nito, pagkatapos ay piliin ang key.
2. Huwag ilipat ang isang umiiral na hotkey para magkaroon ng puwang. Maghanap ng bakanteng key sa tamang plane.
3. Gamitin lang ang `Alt` para sa isang variant ng hotkey na wala nito.

Lumalabag ang ilang hotkey sa mga patakarang ito dahil maginhawa ang mga ito. Ang `Shift` na may arrow o `Tab` ay naglilipat o bumabaliktad sa halip na magbukas ng app, at gumagana ang `Print`, ang mga media key, `Alt + Tab`, at `Ctrl + Alt + Del` sa paraang ginagawa nila sa lahat ng iba pang lugar. Mga exception ang mga ito, hindi mga pattern na gagayahin.

Kung hindi angkop sa iyo ang isang default (halimbawa gusto mo ng `Super + Shift + S` para sa mga screenshot tulad sa Windows), i-rebind ito sa `~/.config/hypr/bindings.lua`.

## Pag-navigate

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu ng Omarchy (mga app at lahat ng iba pa)    |
| `Super + Alt + Space` | Grid ng mga app |
| `Super + Escape` | Menu ng sistema (suspend, restart, atbp.)  |
| `Super + Ctrl + L` | I-lock ang computer |
| `Super + W` or `Super + Q` | Isara ang window             |
| `Ctrl + Alt + Del` | Isara ang lahat ng window |
| `Super + K` | Ipakita ang lahat ng hotkey |
| `Super + Alt + K` | Ipakita ang mga hotkey ng tmux |
| `Super + Ctrl + K` | Ipakita ang mga hotkey ng herdr |
| `Super + M` | I-minimize ang window sa dock |
| `Super + T`               | I-toggle ang window sa pagitan ng tiling/floating             |
| `Super + J` | I-toggle ang posisyon ng window (pahalang/patayo) |
| `Super + O`               | I-toggle ang pag-pop ng window papuntang sticky'n'floating |
| `Super + L`               | Magpalit-palit sa dwindle, scrolling, at floating na mga layout |
| `Super + Alt + L`         | Magpalit-palit sa mga layout nang pabaliktad |
| `Super + P`               | I-toggle ang pseudo na estilo ng window (natural v stretch) |
| `Super + F`                 | Mag-full screen              |
| `Super + Alt + F`                 | Mag-full width              |
| `Super + Ctrl + F`                 | Mag-full screen sa loob ng window              |
| `Super + 1…9/0`         | Tumalon sa partikular na workspace (ang 0 ay 10) sa nakatutok na monitor |
| `Super + Tab` | Tumalon sa susunod na workspace sa nakatutok na monitor |
| `Super + Shift + Tab` | Tumalon sa nakaraang workspace sa nakatutok na monitor |
| `Super + Ctrl + Tab` | Tumalon sa dating workspace sa nakatutok na monitor |
| `Super + Shift + 1…9/0` | Ilipat ang window sa workspace sa nakatutok na monitor |
| `Super + Shift + Alt + 1…9/0` | Ilipat ang window sa workspace sa nakatutok na monitor nang hindi sumusunod |
| `Super + S` | I-toggle ang buong scratchpad |
| `Super + Alt + S` | Ilipat ang window sa buong scratchpad |
| `Super + Grave` | I-toggle ang Quake console |
| `Super + Shift + Grave` | Ilipat ang window sa Quake console |
| `Super + Shift + Ctrl + Arrows` | Ilipat ang window sa monitor sa direksyong iyon |
| `Super + Shift + Alt + Arrows` | Ilipat ang workspace sa monitor sa direksyong iyon |
| `Super + Arrow`  | Ilipat ang focus sa window sa direksyon ng arrow, tumatawid sa monitor sa panig na iyon sa gilid ng screen |
| `Super + Shift + Arrow`  | Pagpalitin ang window sa isa pa sa direksyon ng arrow, kasama ang nasa monitor sa panig na iyon |
| `Super + Minus` | Palawakin ang window pakaliwa |
| `Super + Equal` | Paliitin ang window pakaliwa |
| `Super + Shift + Minus` | Paliitin ang window pataas |
| `Super + Shift + Equal` | Palawakin ang window pababa |
| `Super + Alt + Minus/Equal` | Parehong pag-resize sa mas maliliit na hakbang |
| `Super + Ctrl + Minus/Equal` | Parehong pag-resize sa mas malalaking hakbang |
| `Super + Alt + Home` | I-save ang lapad ng window |
| `Super + Home` | Ibalik ang na-save na lapad ng window |
| `Super + Left Mouse` | I-drag ang window kung saan-saan |
| `Super + Right Mouse` | I-resize ang window |
| `Super + Scroll Wheel` | Mag-scroll sa mga workspace sa nakatutok na monitor |
| `Super + G`               | I-toggle ang pagpapangkat ng window      |
| `Super + Alt + G`               | Ilabas ang window sa pagpapangkat      |
| `Super + Alt + Tab`               | Magpalit-palit sa mga window sa pagpapangkat      |
| `Super + Alt + Shift + Tab`               | Magpalit-palit nang pabaliktad sa mga window sa pagpapangkat      |
| `Super + Alt + Scroll Wheel` | Magpalit-palit sa mga window sa pagpapangkat |
| `Super + Alt + 1/2/3/4/5`               | Tumalon sa partikular na window sa pagpapangkat      |
| `Super + Alt + Arrow`  | Ilipat ang window papasok sa pagpapangkat sa direksyon ng arrow, kasama ang nasa monitor sa panig na iyon |
| `Super + Ctrl + Left/Right`  | Lumipat sa pagitan ng mga window sa loob ng isang tiling group |
| `Super + Ctrl + Z` | Mag-zoom in sa screen (ulitin para sa mas maraming zoom) |
| `Super + Ctrl + Alt + Z` | Mag-zoom out nang buo mula sa screen |
| `Super + /` | Humakbang pasulong sa mga opsyon sa pag-scale ng monitor |
| `Super + Alt + /` | Humakbang paatras sa mga opsyon sa pag-scale ng monitor |
| `Alt + Tab` | Magpalit-palit pasulong sa mga window sa aktibong workspace |
| `Alt + Shift + Tab` | Magpalit-palit paatras sa mga window sa aktibong workspace |
| `Ctrl + Alt + Tab`| Ipalit-palit ang focus pasulong sa mga monitor |
| `Ctrl + Alt + Shift + Tab`| Ipalit-palit ang focus paatras sa mga monitor |
| `Super + I` | Magpalit ng wika ng input (kung may higit sa isang layout o paraan ng input) |
| `Super + Shift + I` | Ibalik ang wika ng input |

Sa isang touchpad, ang mga swipe na may tatlo at apat na daliri ay nagpapalit ng mga workspace, naglilipat ng mga window, at nagbubukas ng menu at ng Quake console; tingnan ang [keyboard, mouse, at trackpad](34-keyboard-mouse-trackpad.md) para sa mga gesture.

Gumagamit ang mga shortcut sa pag-resize ng mga pisikal na key na `code:20` at `code:21` (XKB `<AE11>` at `<AE12>`), anuman ang mga karakter na nakaimprenta sa keyboard. Sa mga US keyboard ang mga key na ito ay `-` at `=`; sa mga Japanese (JIS) keyboard ay `-` at `^` ang mga ito; sa mga Spanish keyboard ay `'` at `¡` ang mga ito. Sa JIS, ang `Super + ^` ay `Super + Equal`, habang ang `Super + Shift + -` (na nagta-type ng `=`) ay `Super + Shift + Minus`.

## Mga kontrol ng sistema

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel ng audio    |
| `Super + Ctrl + B`           | Panel ng Bluetooth    |
| `Super + Ctrl + N`           | Panel ng Wifi/network    |
| `Super + Ctrl + D`           | Panel ng display    |
| `Super + Ctrl + P`           | Panel ng power    |
| `Super + Ctrl + X`           | Panel ng mga agent    |
| `Super + Ctrl + Alt + X`           | Panel ng mga lokal na modelo    |
| `Super + Ctrl + Alt + D`           | Panel ng kalendaryo    |
| `Super + Ctrl + Alt + E`           | Panel ng orasan ng mundo    |
| `Super + Ctrl + 1-9`           | I-toggle ang panel ng bar ayon sa posisyon    |
| `Super + Ctrl + S` | Menu ng pagbabahagi (sa pamamagitan ng LocalSend) |
| `Super + Ctrl + C` | Mga kontrol sa pagkuha (screenshot/-recording/picker) |
| `Super + Ctrl + O` | I-toggle ang menu |
| `Super + Ctrl + H` | Menu ng hardware |
| `Super + Ctrl + E` | Tagapili ng emoji |
| `Super + Ctrl + .` | I-transcode ang media |
| `Super + Shift + Ctrl + A` | Pumili ng isang AI agent |
| `Power` key | Menu ng sistema |
| `Super + Shift + Copilot` key | Menu ng Omarchy |

## Mga pagsasaayos

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Pinakamataas na liwanag ng screen |
| `Shift + Brightness Down` | Pinakamababang liwanag ng screen |
| `Alt + Brightness Up/Down` | Tumpak na 1% na pagbabago sa liwanag |
| `Alt + Volume Up/Down` | Tumpak na 1% na pagbabago sa volume |
| `Keyboard Brightness Up/Down` | Mas maliwanag/mas madilim na backlight ng keyboard |
| `Keyboard Backlight` | Magpalit-palit sa mga antas ng backlight ng keyboard |
| `Ctrl + Brightness Up/Down` | Mas maliwanag/mas madilim na backlight ng keyboard, sa mga keyboard na walang sariling mga key |
| `Mic Mute` | I-mute ang mikropono |
| `Shift + Mute` | Magpalit ng audio output |
| `Touchpad Toggle` | I-on o i-off ang touchpad |
| `Display` key | Magpalit-palit sa layout ng workspace |
| `Alt + Play` | Susunod na track |
| `Alt + Shift + Play` | Nakaraang track |

## Pagbubukas ng mga app

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminal |
| `Super + Ctrl + Return` | Herdr (tagapamahala ng mga agent) |
| `Super + Shift + Return` or `Super + Shift + B`  | Browser    |
| `Super + Shift + Alt + B`           | Browser (pribado/incognito)    |
| `Super + Shift + F`           | Tagapamahala ng file    |
| `Super + Shift + Alt + F`           | Tagapamahala ng file sa cwd ng terminal    |
| `Super + Shift + M`           | Musika (Spotify)    |
| `Super + Shift + Alt + M`           | Musika (cliamp)    |
| `Super + Shift + /`           | Tagapamahala ng password (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kalkulador (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, kapag na-install na)    |
| `Super + Shift + T`           | Aktibidad (btop)    |
| `Super + Shift + N`           | Editor (Plain, o ang pinili mong default)  |
| `Super + Shift + C`           | Kalendaryo ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Email ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Bagong email ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
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

Baguhin/magdagdag ng mga binding sa `~/.config/hypr/bindings.lua`.

## Pangkalahatang clipboard

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + A`           | Piliin lahat sa mga app na sumusuporta sa `Ctrl + A`    |
| `Super + C`           | Kopyahin    |
| `Super + X`           | I-cut (hindi sa terminal)    |
| `Super + V`           | I-paste    |
| `Super + Ctrl + V`           | Tagapamahala ng clipboard    |

Karaniwan sa Linux, kailangan mo ng `Ctrl + Shift + C/V` para mag-copy'n'paste sa terminal at `Ctrl + C/V` para gawin ito sa lahat ng iba pang lugar. Gumagana saanman ang mga pinag-isang clipboard hotkey na ito ng Omarchy.

## Pagkuha

| Hotkey              | Tungkulin                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Screenshot                      |
| `Super + Ctrl + Alt + C`            | Screenshot (parehong kuha, para sa mga keyboard na walang Print Screen key) |
| `Super + Ctrl + C` | Menu ng pagkuha |
| `Alt + Print Screen`            | Screenrecord                     |
| `Super + Shift + Ctrl + Alt + C` | Screenrecord na walang audio, nilalaktawan ang menu (pindutin ulit para huminto) |
| `Super + Print Screen` | Tagapili ng kulay |
| `Super + Ctrl + Print Screen` | Pagkuha ng teksto papunta sa clipboard |
| `Super + Alt + [` | Paliitin ang webcam overlay habang nagre-record |
| `Super + Alt + ]` | Palakihin ang webcam overlay habang nagre-record |
| `Alt + Shift + L` | Kopyahin ang kasalukuyang URL mula sa webapp o browser |
| `Alt + Shift + D` | I-download ang video sa kasalukuyang pahina papunta sa `~/Videos` |
| `Alt + Space` | Simulan/itigil ang pagdidikta (nangangailangan ng _Setup > Defaults > Dictation_) |
| `Right Alt` | Hawakan para magdikta (nangangailangan ng _Setup > Defaults > Dictation_) |

Sa mga screenrecording, tatanungin ka muna ng hotkey kung aling audio ang gusto mo, pagkatapos ay sisimulan ang pag-record. Pindutin itong muli para huminto. Tingnan ang [mga screenshot at recording](12-screenshots-recording.md) para sa mga detalye.

Makukuha rin ang lahat ng opsyon sa pagkuha sa ilalim ng _Trigger > Capture_ sa menu ng Omarchy (`Super + Space`).

## Mga abiso

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + ,` | Kumilos sa pinakabagong abiso: buksan ito o pindutin ang nag-iisa nitong button, pumili mula sa mga pagpipilian nito, o i-dismiss ito kapag wala ito  |
| `Super + Shift + ,` | I-dismiss ang lahat ng abiso |
| `Super + Ctrl + ,` | Kontrolin ang mga abiso gamit ang keyboard  |
| `Super + Alt + ,` | I-dismiss ang pinakabagong abiso  |
| `Super + Shift + Alt + ,` | Buksan ang kasaysayan ng mga abiso  |
| `Super + Ctrl + Alt + ,` | I-toggle ang pagtahimik ng mga abiso  |

## Istilo

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Pumili ng bagong tema (din `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Pumili ng background ng tema (din `Super + Ctrl + Space`) |
| `Super + Backspace` | I-toggle ang transparency sa isang window |
| `Super + Ctrl + Backspace` | I-toggle ang parisukat na aspect ng iisang window |

Nasa `~/.config/omarchy/backgrounds/<theme name>` ang mga karagdagang larawan ng background. Makukuha rin sa pamamagitan ng _Install > Style > Background_ sa menu ng Omarchy.

Makukuha rin ang lahat ng opsyon sa estilo sa ilalim ng _Appearance_ sa menu ng Omarchy (`Super + Space`).

## Mga Toggle

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | I-toggle ang pag-lock kapag idle |
| `Super + Ctrl + Delete` | I-toggle ang on/off ng display ng laptop |
| `Super + Ctrl + Alt + Delete` | I-toggle ang pag-mirror ng display ng laptop |
| `Super + Shift + Space` | I-toggle ang top bar  |
| `Shift + Mute` | Lumipat sa susunod na audio output |
| `Shift + Play` | Lumipat sa susunod na pinagmulan ng media |
| `Super + Shift + Backspace` | I-toggle ang mga puwang ng window |
| `Super + Ctrl + Alt + F` | I-toggle ang full screen na desktop (top bar + mga puwang ng window) |

## Mga Paalala

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Magtakda ng paalala  |
| `Super + Ctrl + Alt + R` | Tingnan ang lahat ng paalala  |
| `Super + Ctrl + Shift + R` | Burahin ang lahat ng paalala  |

## Mga Notice

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Ipakita ang oras bilang abiso  |
| `Super + Ctrl + Alt + B` | Ipakita ang baterya bilang abiso  |
| `Super + Ctrl + Alt + W` | I-toggle ang panahon bilang abiso  |

## Tmux

Ang prefix key ay `Ctrl + Space` (gumagana rin ang `Ctrl + B`). Maaari mong baguhin ang mga binding na ito sa `~/.config/tmux/tmux.conf`.

### Mga Pane

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Prefix + v` | Hatiin ang pane sa tabi (patayo) |
| `Prefix + h` | Hatiin ang pane sa ibaba (pahalang) |
| `Prefix + x` | Patayin ang pane |
| `Prefix + z` | I-toggle ang zoom ng pane (fullscreen) |
| `Alt + Enter` | Hatiin ang pane sa ibaba (walang prefix) |
| `Alt + Shift + Enter` | Hatiin ang pane sa tabi (walang prefix) |
| `Alt + Escape` | Patayin ang pane (walang prefix) |
| `Ctrl + Alt + Arrows` | Lumipat sa pagitan ng mga pane |
| `Ctrl + Alt + Shift + Arrows` | I-resize ang mga pane |

### Mga Window

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Prefix + c` | Bagong window |
| `Prefix + k` | Patayin ang window |
| `Prefix + r` | Palitan ang pangalan ng window |
| `Alt + 1-9` | Pumunta sa partikular na window |
| `Alt + Arrow Left/Right` | Lumipat sa pagitan ng mga window |
| `Alt + Shift + Arrow Left/Right` | Ilipat ang window pakaliwa/pakanan |

### Mga Session

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Prefix + C` | Bagong session |
| `Prefix + K` | Patayin ang session |
| `Prefix + R` | Palitan ang pangalan ng session |
| `Prefix + N` | Susunod na session |
| `Prefix + P` | Nakaraang session |
| `Alt + Arrow Up/Down` | Lumipat sa pagitan ng mga session |
| `Prefix + s` | Ilista ang mga session |
| `Prefix + d` | Mag-detach mula sa session |

### Copy mode (vi-style)

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Prefix + [` | Pumasok sa copy mode |
| `v` | Simulan ang pagpili (sa copy mode) |
| `y` | Kopyahin ang pinili (sa copy mode) |

### Pangkalahatan

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Prefix + q` | I-reload ang config |
| `Prefix + ?` | Ipakita ang mga keybinding ng Tmux |
| `Prefix + :` | Prompt ng command |

### Mga function ng layout ng Tmux

Dapat patakbuhin ang mga function na ito sa loob ng isang Tmux session.

| Command | Tungkulin |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Gumawa ng dev layout na may editor, AI, at terminal |
| `tdlm <ai> [<second_ai>]` | Gumawa ng dev layout bawat subdirectory |
| `tsl <count> <command>` | Gumawa ng multi-pane na swarm layout |

## Ghostty Terminal

Ini-install ang Ghostty terminal gamit ang _Install > Terminal_ sa pamamagitan ng menu ng Omarchy.

| Hotkey                  | Tungkulin              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Bagong split sa ibaba |
| `Ctrl + Shift + O` | Bagong split sa tabi |
| `Ctrl + Alt + Arrows` | Lumipat sa pagitan ng mga split |
| `Super + Ctrl + Shift + Arrows` | I-resize ang split ng 10 linya |
| `Super + Ctrl + Shift + Alt + Arrows` | I-resize ang split ng 100 linya |
| `Ctrl + Shift + T` | Bagong tab  |
| `Ctrl + Shift + Arrows` | Lumipat sa pagitan ng mga tab |
| `Alt + Numbers` | Pumunta sa partikular na tab |
| `Shift + Pg Up/Down` | Mag-scroll sa kasaysayan |
| `Ctrl + Left mouse` | Buksan ang link sa browser |

## Tagapamahala ng File

| Hotkey              | Tungkulin                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Pumunta sa path                     |
| `Space`               | I-preview ang file (mag-navigate gamit ang mga arrow) |
| `Alt + Up`       | Umakyat sa parent folder        |

## Neovim (w/ lazyvim)

### Pag-navigate

| Hotkey                   | Tungkulin                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Ipakita ang mga opsyon ng command            |
| `Space Space`              | Buksan ang file sa pamamagitan ng fuzzy search      |
| `Space E`                  | I-toggle ang sidebar                  |
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
| `D`                        | Burahin ang naka-highlight na file/dir     |
| `M`                        | Ilipat ang naka-highlight na file/dir       |
| `R`                        | Palitan ang pangalan ng naka-highlight na file/dir     |
| `?`                        | Ipakita ang tulong para sa lahat ng command      |

[Tingnan ang lahat ng Neovim hotkeys na ikinonfigura ng LazyVim](https://www.lazyvim.org/keymaps).

## Mabilisang Emojis

Maaari mong gamitin ang `Super + Ctrl + E` para magpakita ng kumpletong emoji picker na maglalagay ng pinili sa clipboard o maaari mong gamitin ang mga mabilisang opsyon sa pag-access na ito.

| Hotkey       | EM | Palatandaan       |
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
| `Shift + CapsLock M E` | 🙄 | pag-ikot ng mata    |
| `Shift + CapsLock M I` | 😉 | kindat       |
| `Shift + CapsLock M P` | 🙏 | dasal |
| `Shift + CapsLock M D` | 🤤 | paglalaway      |
| `Shift + CapsLock M M` | 💰 | pera      |
| `Shift + CapsLock M X` | 🎉 | pagdiriwang |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pagbati |
| `Shift + CapsLock M A` |💪 | braso |
| `Shift + CapsLock M B` |🤯 | pagsabog |

## Mabilisang Pagkumpleto

| Hotkey       | Pagkumpleto       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Pangalan mo (gaya ng inilagay sa setup)  |
| `Shift + CapsLock Space E` | Email mo (gaya ng inilagay sa setup)  |

Maaari kang magdagdag ng sarili mo pa sa pamamagitan ng pag-edit sa `~/.XCompose`, pagkatapos ay pagpapatakbo ng `omarchy restart xcompose` sa terminal para makuha ang mga pagbabago.
