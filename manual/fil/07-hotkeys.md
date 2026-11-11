# Mga Hotkey

Makikita mo ang lahat ng pangunahing keyboard binding gamit ang `Super + K` (mga binding ng Tmux gamit ang `Super + Alt + K` at mga binding ng Herdr gamit ang `Super + Ctrl + K`).

## Paano nakaayos ang mga hotkey

Ang bawat hotkey ay nasa isang plane, na itinakda ng mga modifier nito, at iisang trabaho lang ang bawat plane. Iyon ang pumipigil sa mga hotkey na magkagulo, at ibig sabihin nito, kadalasan ay mahuhulaan mo kung saan nakatira ang isang bagay.

| Plane | Ano ang nandoon | Mga halimbawa |
| --- | --- | --- |
| `Super + key` | Ang system: mga window, workspace, layout, at mga pangunahing menu | `Super + Space` menu ng Omarchy, `Super + W` isara ang window, `Super + F` full screen |
| `Super + Shift + key` | Mga app | `Super + Shift + B` browser, `Super + Shift + E` email, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Mga panel at menu ng system | `Super + Ctrl + A` audio, `Super + Ctrl + N` network, `Super + Ctrl + C` menu ng capture |
| `Super + Ctrl + Alt + key` | Mga mabilisang aksyon at abiso | `Super + Ctrl + Alt + T` ipakita ang oras, `Super + Ctrl + Alt + B` baterya, `Super + Ctrl + Alt + C` screenshot |

Ang pagdaragdag ng `Alt` sa isang hotkey ay nagbibigay sa iyo ng variant ng parehong bagay, hindi kailanman ng bagay na walang kaugnayan:

- Binubuksan ng `Super + Shift + B` ang browser; binubuksan ng `Super + Shift + Alt + B` ang pribadong window
- Binubuksan ng `Super + Shift + E` ang email; nagsisimula ng bago ang `Super + Shift + Alt + E`
- Nagfu-full screen ang `Super + F`; nagfu-full width ang `Super + Alt + F`
- Binubuksan ng `Super + Ctrl + C` ang menu ng capture; nilalaktawan ng `Super + Ctrl + Alt + C` ang menu at kumukuha ng screenshot

Kapag nagdaragdag ng hotkey:

1. Piliin ang plane mula sa ginagawa nito, pagkatapos ay piliin ang key.
2. Huwag ilipat ang umiiral na hotkey para magkaroon ng puwang. Maghanap ng bakanteng key sa tamang plane.
3. Gamitin lang ang `Alt` para sa variant ng hotkey na wala nito.

May ilang hotkey na lumalabag sa mga patakarang ito dahil maginhawa sila. Ang `Shift` na may arrow o `Tab` ay naglilipat o bumabaligtad sa halip na magbukas ng app, at ang `Print`, ang mga media key, `Alt + Tab`, at `Ctrl + Alt + Del` ay gumagana kung paano sila gumagana sa lahat ng iba pang lugar. Mga exception sila, hindi mga pattern na dapat gayahin.

Kung hindi bagay sa iyo ang isang default (halimbawa gusto mo ng `Super + Shift + S` para sa mga screenshot tulad sa Windows), i-rebind ito sa `~/.config/hypr/bindings.lua`.

## Pag-navigate

| Hotkey                  | Ginagawa              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu ng Omarchy (mga app at lahat ng iba pa)    |
| `Super + Alt + Space` | Grid ng mga app |
| `Super + Escape` | Menu ng system (suspend, restart, atbp.)  |
| `Super + Ctrl + L` | I-lock ang computer |
| `Super + W` or `Super + Q` | Isara ang window             |
| `Ctrl + Alt + Del` | Isara ang lahat ng window |
| `Super + T`               | I-toggle ang window sa pagitan ng tiling/floating             |
| `Super + J` | I-toggle ang posisyon ng window (pahalang/patayo) |
| `Super + O`               | I-toggle ang pag-pop ng window sa sticky'n'floating |
| `Super + L`               | Magpalit-palit sa mga layout na dwindle, scrolling, at floating |
| `Super + Alt + L`         | Magpalit-palit sa mga layout nang pabalik |
| `Super + P`               | I-toggle ang pseudo na style ng window (natural v stretch) |
| `Super + F`                 | Mag-full screen              |
| `Super + Alt + F`                 | Mag-full width              |
| `Super + Ctrl + F`                 | Mag-full screen sa loob ng window              |
| `Super + 1/2/3/4`         | Tumalon sa partikular na workspace sa nakatutok na monitor |
| `Super + Tab` | Tumalon sa susunod na workspace sa nakatutok na monitor |
| `Super + Shift + Tab` | Tumalon sa nakaraang workspace sa nakatutok na monitor |
| `Super + Ctrl + Tab` | Tumalon sa dating workspace sa nakatutok na monitor |
| `Super + Shift + 1/2/3/4` | Ilipat ang window sa workspace sa nakatutok na monitor |
| `Super + Shift + Alt + 1/2/3/4` | Ilipat ang window sa workspace sa nakatutok na monitor nang hindi sumusunod |
| `Super + S` | I-toggle ang full na scratchpad |
| `Super + Alt + S` | Ilipat ang window sa full na scratchpad |
| `Super + Grave` | I-toggle ang Quake console |
| `Super + Shift + Grave` | Ilipat ang window sa Quake console |
| `Super + Shift + Ctrl + Arrows` | Ilipat ang window sa monitor sa direksyong iyon |
| `Super + Shift + Alt + Arrows` | Ilipat ang workspace sa monitor sa direksyong iyon |
| `Super + Arrow`  | Ilipat ang focus sa window sa direksyon ng arrow, tumatawid sa monitor sa gilid na iyon sa dulo ng screen |
| `Super + Shift + Arrow`  | Ipalit ang window sa isa pa sa direksyon ng arrow, kabilang ang nasa monitor sa gilid na iyon |
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
| `Super + G`               | I-toggle ang pag-group ng window      |
| `Super + Alt + G`               | Ilabas ang window sa grouping      |
| `Super + Alt + Tab`               | Magpalit-palit sa mga window sa grouping      |
| `Super + Alt + Shift + Tab`               | Magpalit-palit nang pabalik sa mga window sa grouping      |
| `Super + Alt + Scroll Wheel` | Magpalit-palit sa mga window sa grouping |
| `Super + Alt + 1/2/3/4/5`               | Tumalon sa partikular na window sa grouping      |
| `Super + Alt + Arrow`  | Ilipat ang window sa grouping sa direksyon ng arrow, kabilang ang nasa monitor sa gilid na iyon |
| `Super + Ctrl + Left/Right`  | Lumipat sa pagitan ng mga window sa loob ng tiling group |
| `Super + Ctrl + Z` | Mag-zoom in sa screen (ulitin para sa mas maraming zoom) |
| `Super + Ctrl + Alt + Z` | Mag-zoom out nang buo mula sa screen |
| `Super + /` | Sumulong sa mga opsyon sa scaling ng monitor |
| `Super + Alt + /` | Bumalik sa mga opsyon sa scaling ng monitor |
| `Alt + Tab` | Magpalit-palit pasulong sa mga window sa aktibong workspace |
| `Alt + Shift + Tab` | Magpalit-palit pabalik sa mga window sa aktibong workspace |
| `Ctrl + Alt + Tab`| Ipalit ang focus pasulong sa mga monitor |
| `Ctrl + Alt + Shift + Tab`| Ipalit ang focus pabalik sa mga monitor |

Gumagamit ang mga shortcut sa pag-resize ng mga pisikal na key na `code:20` at `code:21` (XKB `<AE11>` at `<AE12>`), anuman ang mga character na nakaimprenta sa keyboard. Sa mga US keyboard, ang mga key na ito ay `-` at `=`; sa mga Japanese (JIS) keyboard, ang mga ito ay `-` at `^`; sa mga Spanish keyboard, ang mga ito ay `'` at `¡`. Sa JIS, ang `Super + ^` ay `Super + Equal`, habang ang `Super + Shift + -` (na nagta-type ng `=`) ay `Super + Shift + Minus`.

## Mga kontrol ng system

| Hotkey                  | Ginagawa              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel ng audio    |
| `Super + Ctrl + B`           | Panel ng Bluetooth    |
| `Super + Ctrl + N`           | Panel ng Wifi/network    |
| `Super + Ctrl + D`           | Panel ng display    |
| `Super + Ctrl + P`           | Panel ng power    |
| `Super + Ctrl + X`           | Panel ng mga agent    |
| `Super + Ctrl + Alt + D`           | Panel ng calendar    |
| `Super + Ctrl + Alt + E`           | Panel ng world clock    |
| `Super + Ctrl + 1-9`           | I-toggle ang panel ng bar ayon sa posisyon    |
| `Super + Ctrl + S` | Menu ng pag-share (sa pamamagitan ng LocalSend) |
| `Super + Ctrl + C` | Mga kontrol sa capture (screenshot/-recording/picker) |
| `Super + Ctrl + O` | Menu ng toggle |
| `Super + Ctrl + H` | Menu ng hardware |
| `Super + Ctrl + E` | Tagapili ng emoji |
| `Super + Ctrl + .` | I-transcode ang media |
| `Super + Shift + Ctrl + A` | Pumili ng AI agent |

## Mga pagsasaayos

| Hotkey                  | Ginagawa              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Pinakamataas na liwanag ng screen |
| `Shift + Brightness Down` | Pinakamababang liwanag ng screen |
| `Alt + Brightness Up/Down` | Tumpak na 1% na pagbabago sa liwanag |
| `Alt + Volume Up/Down` | Tumpak na 1% na pagbabago sa volume |
| `Keyboard Brightness Up/Down` | Mas maliwanag/mas madilim na backlight ng keyboard |
| `Keyboard Backlight` | Magpalit-palit sa mga level ng backlight ng keyboard |
| `Alt + Play` | Susunod na track |
| `Alt + Shift + Play` | Nakaraang track |

## Paglulunsad ng mga app

| Hotkey                  | Ginagawa              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminal |
| `Super + Ctrl + Return` | Herdr (agent manager) |
| `Super + Shift + Return`           | Browser    |
| `Super + Shift + Alt + B`           | Browser (pribado/incognito)    |
| `Super + Shift + F`           | File manager    |
| `Super + Shift + Alt + F`           | File manager sa cwd ng terminal    |
| `Super + Shift + M`           | Music (Spotify)    |
| `Super + Shift + Alt + M`           | Music (cliamp)    |
| `Super + Shift + /`           | Password manager (1password)    |
| `Super + Shift + Q`           | Calculator (Omacalc)    |
| `Super + Shift + T`           | Activity (btop)    |
| `Super + Shift + N`           | Editor (Neovim)  |
| `Super + Shift + C`           | Calendar ([HEY](https://hey.com/))  |
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
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Baguhin/magdagdag ng mga binding sa `~/.config/hypr/bindings.lua`.

## Universal na clipboard

| Hotkey                  | Ginagawa              |
| ----------------------- | --------------------- |
| `Super + A`           | Piliin lahat sa mga app na sumusuporta sa `Ctrl + A`    |
| `Super + C`           | Kopyahin    |
| `Super + X`           | I-cut (hindi sa terminal)    |
| `Super + V`           | I-paste    |
| `Super + Ctrl + V`           | Tagapamahala ng clipboard    |

Karaniwan sa Linux, kailangan mo ng `Ctrl + Shift + C/V` para mag-copy'n'paste sa terminal at `Ctrl + C/V` para gawin ito sa lahat ng iba pang lugar. Gumagana kahit saan ang mga pinag-isang clipboard hotkey na ito ng Omarchy.

## Pag-capture

| Hotkey              | Ginagawa                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Screenshot                      |
| `Super + Ctrl + Alt + C`            | Screenshot (parehong shot, para sa mga keyboard na walang Print Screen key) |
| `Super + Ctrl + C` | Menu ng capture |
| `Alt + Print Screen`            | Screenrecord                     |
| `Super + Print Screen` | Tagapili ng kulay |
| `Super + Ctrl + Print Screen` | Pag-extract ng text papunta sa clipboard |
| `Super + Alt + [` | Paliitin ang overlay ng webcam habang nagre-record |
| `Super + Alt + ]` | Palakihin ang overlay ng webcam habang nagre-record |
| `Alt + Shift + L` | Kopyahin ang kasalukuyang URL mula sa webapp o browser |
| `Alt + Shift + D` | I-download ang video sa kasalukuyang page papunta sa `~/Videos` |
| `Alt + Space` | Simulan/itigil ang dictation (nangangailangan ng _Setup > Defaults > Dictation_) |
| `Right Alt` | Hawakan para mag-dictate (nangangailangan ng _Setup > Defaults > Dictation_) |

Sa mga screenrecording, tatanungin ka muna ng hotkey kung aling audio ang gusto mo, pagkatapos ay magsisimula ang recording. Pindutin itong muli para itigil. Tingnan ang [mga screenshot at recording](12-screenshots-recording.md) para sa mga detalye.

Maa-access din ang lahat ng opsyon sa capture sa ilalim ng _Trigger > Capture_ sa menu ng Omarchy (`Super + Space`).

## Mga notification

| Hotkey                  | Ginagawa              |
| ----------------------- | --------------------- |
| `Super + ,` | Kumilos sa pinakabagong notification: buksan ito o pindutin ang tanging button nito, pumili mula sa mga pagpipilian nito, o i-dismiss ito kapag wala ito nito  |
| `Super + Shift + ,` | I-dismiss ang lahat ng notification |
| `Super + Ctrl + ,` | Kontrolin ang mga notification gamit ang keyboard  |
| `Super + Alt + ,` | I-dismiss ang pinakabagong notification  |
| `Super + Shift + Alt + ,` | Buksan ang history ng notification  |
| `Super + Ctrl + Alt + ,` | I-toggle ang pagtahimik sa mga notification  |

## Istilo

| Hotkey                  | Ginagawa              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Pumili ng bagong theme (din `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Pumili ng background ng theme (din `Super + Ctrl + Space`) |
| `Super + Backspace` | I-toggle ang transparency sa isang window |
| `Super + Ctrl + Backspace` | I-toggle ang square aspect ng iisang window |

Nasa `~/.config/omarchy/backgrounds/<theme name>` ang mga karagdagang background image. Maa-access din sa pamamagitan ng _Install > Style > Background_ sa menu ng Omarchy.

Maa-access din ang lahat ng opsyon sa style sa ilalim ng _Style_ sa menu ng Omarchy (`Super + Space`).

## Mga toggle

| Hotkey                  | Ginagawa              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | I-toggle ang pag-lock kapag idle |
| `Super + Ctrl + Delete` | I-toggle ang on/off ng display ng laptop |
| `Super + Ctrl + Alt + Delete` | I-toggle ang mirroring ng display ng laptop |
| `Super + Shift + Space` | I-toggle ang top bar  |
| `Shift + Mute` | Lumipat sa susunod na audio output |
| `Shift + Play` | Lumipat sa susunod na media source |
| `Super + Shift + Backspace` | I-toggle ang mga gap ng window |
| `Super + Ctrl + Alt + F` | I-toggle ang full screen desktop (top bar + mga gap ng window) |

## Mga paalala

| Hotkey                  | Ginagawa              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Magtakda ng paalala  |
| `Super + Ctrl + Alt + R` | Tingnan ang lahat ng paalala  |
| `Super + Ctrl + Shift + R` | I-clear ang lahat ng paalala  |

## Mga abiso

| Hotkey                  | Ginagawa              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Ipakita ang oras bilang notification  |
| `Super + Ctrl + Alt + B` | Ipakita ang baterya bilang notification  |
| `Super + Ctrl + Alt + W` | I-toggle ang panahon bilang notification  |

## Tmux

Ang prefix key ay `Ctrl + Space` (gumagana rin ang `Ctrl + B`). Maaari mong baguhin ang mga binding na ito sa `~/.config/tmux/tmux.conf`.

### Mga pane

| Hotkey                  | Ginagawa              |
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

### Mga window

| Hotkey                  | Ginagawa              |
| ----------------------- | --------------------- |
| `Prefix + c` | Bagong window |
| `Prefix + k` | Patayin ang window |
| `Prefix + r` | Palitan ang pangalan ng window |
| `Alt + 1-9` | Pumunta sa partikular na window |
| `Alt + Arrow Left/Right` | Lumipat sa pagitan ng mga window |
| `Alt + Shift + Arrow Left/Right` | Ilipat ang window pakaliwa/pakanan |

### Mga session

| Hotkey                  | Ginagawa              |
| ----------------------- | --------------------- |
| `Prefix + C` | Bagong session |
| `Prefix + K` | Patayin ang session |
| `Prefix + R` | Palitan ang pangalan ng session |
| `Prefix + N` | Susunod na session |
| `Prefix + P` | Nakaraang session |
| `Alt + Arrow Up/Down` | Lumipat sa pagitan ng mga session |
| `Prefix + s` | Ilista ang mga session |
| `Prefix + d` | Kumalas mula sa session |

### Copy mode (vi-style)

| Hotkey                  | Ginagawa              |
| ----------------------- | --------------------- |
| `Prefix + [` | Pumasok sa copy mode |
| `v` | Simulan ang pagpili (sa copy mode) |
| `y` | Kopyahin ang pinili (sa copy mode) |

### Pangkalahatan

| Hotkey                  | Ginagawa              |
| ----------------------- | --------------------- |
| `Prefix + q` | I-reload ang config |
| `Prefix + ?` | Ipakita ang mga keybinding ng Tmux |
| `Prefix + :` | Command prompt |

### Mga function ng layout ng Tmux

Dapat patakbuhin ang mga function na ito sa loob ng isang Tmux session.

| Command | Ginagawa |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Gumawa ng dev layout na may editor, AI, at terminal |
| `tdlm <ai> [<second_ai>]` | Gumawa ng dev layout bawat subdirectory |
| `tsl <count> <command>` | Gumawa ng multi-pane na swarm layout |

## Ghostty Terminal

Ini-install ang Ghostty terminal gamit ang _Install > Terminal_ sa pamamagitan ng menu ng Omarchy.

| Hotkey                  | Ginagawa              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Bagong split sa ibaba |
| `Ctrl + Shift + O` | Bagong split sa tabi |
| `Ctrl + Alt + Arrows` | Lumipat sa pagitan ng mga split |
| `Super + Ctrl + Shift + Arrows` | I-resize ang split ng 10 linya |
| `Super + Ctrl + Shift + Alt + Arrows` | I-resize ang split ng 100 linya |
| `Ctrl + Shift + T` | Bagong tab  |
| `Ctrl + Shift + Arrows` | Lumipat sa pagitan ng mga tab |
| `Alt + Numbers` | Pumunta sa partikular na tab |
| `Shift + Pg Up/Down` | I-scroll ang history |
| `Ctrl + Left mouse` | Buksan ang link sa browser |

## File Manager

| Hotkey              | Ginagawa                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Pumunta sa path                     |
| `Space`               | I-preview ang file (nagna-navigate ang mga arrow) |
| `Alt + Up`       | Umakyat sa parent folder        |

## Neovim (w/ lazyvim)

### Pag-navigate

| Hotkey                   | Ginagawa                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Ipakita ang mga opsyon sa command            |
| `Space Space`              | Buksan ang file sa pamamagitan ng fuzzy search      |
| `Space E`                  | I-toggle ang sidebar                  |
| `Space G G`                | Ipakita ang mga kontrol ng git               |
| `Space S G`                | Hanapin ang nilalaman ng file             |
| `Ctrl + W W`               | Tumalon sa pagitan ng sidebar at editor |
| `Ctrl + Left/right arrow`  | Baguhin ang laki ng sidebar          |
| `Shift + H`                      | Pumunta sa kaliwang file tab             |
| `Shift + L`                      | Pumunta sa kanang file tab            |
| `Space B D`                | Isara ang file tab                  |

### Habang nasa sidebar

| Hotkey                   | Ginagawa                        |
| ------------------------ | ------------------------------- |
| `A`                        | Magdagdag ng bagong file sa parent dir      |
| `Shift + A`                | Magdagdag ng bagong subdir sa parent dir    |
| `D`                        | Burahin ang naka-highlight na file/dir     |
| `M`                        | Ilipat ang naka-highlight na file/dir       |
| `R`                        | Palitan ang pangalan ng naka-highlight na file/dir     |
| `?`                        | Ipakita ang tulong para sa lahat ng command      |

[Tingnan ang lahat ng hotkey ng Neovim na naka-configure ng LazyVim](https://www.lazyvim.org/keymaps).

## Mga Mabilisang Emoji

Maaari mong gamitin ang `Super + Ctrl + E` para ipakita ang kumpletong emoji picker na maglalagay ng pinili sa clipboard o maaari mong gamitin ang mga opsyong ito para sa mabilisang access.

| Hotkey       | EM | Pahiwatig       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | ngiti      |
| `Shift + CapsLock M C` | 😂 | iyak        |
| `Shift + CapsLock M L` | 😍 | mahal       |
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
| `Shift + CapsLock M B` |🤯 | sumasabog |

## Mga Mabilisang Pagkumpleto

| Hotkey       | Pagkumpleto       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Ang pangalan mo (tulad ng inilagay sa setup)  |
| `Shift + CapsLock Space E` | Ang email mo (tulad ng inilagay sa setup)  |

Maaari kang magdagdag pa ng sarili mo sa pamamagitan ng pag-edit sa `~/.XCompose`, pagkatapos ay patakbuhin ang `omarchy-restart-xcompose` sa terminal para makuha ang mga pagbabago.
