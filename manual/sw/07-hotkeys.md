# Vibonye vya Haraka

Unaweza kuona vifungo vikuu vyote vya kibodi kwa `Super + K` (vifungo vya Tmux kwa `Super + Alt + K` na vifungo vya Herdr kwa `Super + Ctrl + K`).

## Jinsi vibonye vya haraka vilivyopangwa

Kila kibonye cha haraka kiko kwenye tabaka, linalowekwa na virekebishaji vyake, na kila tabaka lina kazi moja. Hilo ndilo linalozuia vibonye vya haraka visichanganyike, na linamaanisha kwa kawaida unaweza kukisia kitu kiko wapi.

| Tabaka | Kile kilicho hapo | Mifano |
| --- | --- | --- |
| `Super + key` | Mfumo: madirisha, nafasi za kazi, mipangilio, na menyu za msingi | `Super + Space` menyu ya Omarchy, `Super + W` funga dirisha, `Super + F` skrini nzima |
| `Super + Shift + key` | Programu | `Super + Shift + B` kivinjari, `Super + Shift + E` barua pepe, `Super + Shift + N` kihariri |
| `Super + Ctrl + key` | Paneli na menyu za mfumo | `Super + Ctrl + A` sauti, `Super + Ctrl + N` mtandao, `Super + Ctrl + C` menyu ya kunasa |
| `Super + Ctrl + Alt + key` | Vitendo vya haraka na taarifa | `Super + Ctrl + Alt + T` onyesha saa, `Super + Ctrl + Alt + B` betri, `Super + Ctrl + Alt + C` picha ya skrini |

Kuongeza `Alt` kwenye kibonye cha haraka hukupa lahaja ya kitu kilekile, kamwe si kitu kisichohusiana:

- `Super + Shift + B` hufungua kivinjari; `Super + Shift + Alt + B` hufungua dirisha la faragha
- `Super + Shift + E` hufungua barua pepe; `Super + Shift + Alt + E` huanzisha mpya
- `Super + F` huenda skrini nzima; `Super + Alt + F` huenda upana kamili
- `Super + Ctrl + C` hufungua menyu ya kunasa; `Super + Ctrl + Alt + C` huruka menyu na kuchukua picha ya skrini

Unapoongeza kibonye cha haraka:

1. Chagua tabaka kutokana na kile kinachofanya, kisha chagua kitufe.
2. Usihamishe kibonye cha haraka kilichopo ili kupata nafasi. Tafuta kitufe kilicho wazi kwenye tabaka sahihi.
3. Tumia `Alt` tu kwa lahaja ya kibonye cha haraka kisicho nayo.

Vibonye vichache vya haraka huvunja sheria hizi kwa sababu vinafaa. `Shift` pamoja na mshale au `Tab` huhamisha au hubadili mwelekeo badala ya kufungua programu, na `Print`, vitufe vya media, `Alt + Tab`, na `Ctrl + Alt + Del` hufanya kazi kama zinavyofanya kila mahali pengine. Hizo ni tofauti, si mifumo ya kuiga.

Kama chaguo-msingi halikufai (tuseme unataka `Super + Shift + S` kwa picha za skrini kama kwenye Windows), libadilishe katika `~/.config/hypr/bindings.lua`.

## Kuvinjari

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menyu ya Omarchy (programu na kila kitu kingine)    |
| `Super + Alt + Space` | Gridi ya programu |
| `Super + Escape` | Menyu ya mfumo (simamisha kwa muda, anzisha upya, n.k.)  |
| `Super + Ctrl + L` | Funga kompyuta |
| `Super + W` or `Super + Q` | Funga dirisha             |
| `Ctrl + Alt + Del` | Funga madirisha yote |
| `Super + T`               | Badilisha dirisha kati ya kupanga vigae/kuelea             |
| `Super + J` | Badilisha mkao wa dirisha (mlalo/wima) |
| `Super + O`               | Badilisha dirisha linalojitokeza kuwa la kunata na kuelea |
| `Super + L`               | Zunguka kati ya mipangilio ya dwindle, scrolling, na floating |
| `Super + Alt + L`         | Zunguka kati ya mipangilio kinyume chake |
| `Super + P`               | Badilisha mtindo wa dirisha bandia (asili dhidi ya kunyoosha) |
| `Super + F`                 | Nenda skrini nzima              |
| `Super + Alt + F`                 | Nenda upana kamili              |
| `Super + Ctrl + F`                 | Nenda skrini nzima ndani ya dirisha              |
| `Super + 1/2/3/4`         | Ruka hadi nafasi maalum ya kazi kwenye monita inayolengwa |
| `Super + Tab` | Ruka hadi nafasi inayofuata ya kazi kwenye monita inayolengwa |
| `Super + Shift + Tab` | Ruka hadi nafasi iliyotangulia ya kazi kwenye monita inayolengwa |
| `Super + Ctrl + Tab` | Ruka hadi nafasi ya awali ya kazi kwenye monita inayolengwa |
| `Super + Shift + 1/2/3/4` | Hamisha dirisha hadi nafasi ya kazi kwenye monita inayolengwa |
| `Super + Shift + Alt + 1/2/3/4` | Hamisha dirisha hadi nafasi ya kazi kwenye monita inayolengwa bila kulifuata |
| `Super + S` | Badilisha scratchpad kamili |
| `Super + Alt + S` | Hamisha dirisha hadi scratchpad kamili |
| `Super + Grave` | Badilisha koni ya Quake |
| `Super + Shift + Grave` | Hamisha dirisha hadi koni ya Quake |
| `Super + Shift + Ctrl + Arrows` | Hamisha dirisha hadi monita katika mwelekeo huo |
| `Super + Shift + Alt + Arrows` | Hamisha nafasi ya kazi hadi monita katika mwelekeo huo |
| `Super + Arrow`  | Hamisha umakini hadi dirisha katika mwelekeo wa mshale, ukivuka hadi monita iliyo upande huo kwenye ukingo wa skrini |
| `Super + Shift + Arrow`  | Badilishana dirisha na jingine katika mwelekeo wa mshale, ikiwemo lililo kwenye monita iliyo upande huo |
| `Super + Minus` | Panua dirisha kushoto |
| `Super + Equal` | Punguza dirisha kushoto |
| `Super + Shift + Minus` | Punguza dirisha juu |
| `Super + Shift + Equal` | Panua dirisha chini |
| `Super + Alt + Minus/Equal` | Kubadilisha ukubwa kule kule kwa hatua ndogo zaidi |
| `Super + Ctrl + Minus/Equal` | Kubadilisha ukubwa kule kule kwa hatua kubwa zaidi |
| `Super + Alt + Home` | Hifadhi upana wa dirisha |
| `Super + Home` | Rejesha upana wa dirisha uliohifadhiwa |
| `Super + Left Mouse` | Buruta dirisha huku na huko |
| `Super + Right Mouse` | Badilisha ukubwa wa dirisha |
| `Super + Scroll Wheel` | Tembeza kati ya nafasi za kazi kwenye monita inayolengwa |
| `Super + G`               | Badilisha uunganishaji wa dirisha katika kikundi      |
| `Super + Alt + G`               | Toa dirisha nje ya kikundi      |
| `Super + Alt + Tab`               | Zunguka kati ya madirisha katika kikundi      |
| `Super + Alt + Shift + Tab`               | Zunguka nyuma kati ya madirisha katika kikundi      |
| `Super + Alt + Scroll Wheel` | Zunguka kati ya madirisha katika kikundi |
| `Super + Alt + 1/2/3/4/5`               | Ruka hadi dirisha maalum katika kikundi      |
| `Super + Alt + Arrow`  | Hamisha dirisha kwenye kikundi katika mwelekeo wa mshale, ikiwemo lililo kwenye monita iliyo upande huo |
| `Super + Ctrl + Left/Right`  | Sogea kati ya madirisha ndani ya kikundi cha kupanga vigae |
| `Super + Ctrl + Z` | Kuza kwenye skrini (rudi kwa ukuzaji zaidi) |
| `Super + Ctrl + Alt + Z` | Punguza kabisa kutoka kwenye skrini |
| `Super + /` | Kwenda mbele kupitia chaguo za upimaji wa monita |
| `Super + Alt + /` | Kwenda nyuma kupitia chaguo za upimaji wa monita |
| `Alt + Tab` | Zunguka mbele kati ya madirisha kwenye nafasi amilifu ya kazi |
| `Alt + Shift + Tab` | Zunguka nyuma kati ya madirisha kwenye nafasi amilifu ya kazi |
| `Ctrl + Alt + Tab`| Zunguka umakini mbele kati ya monita |
| `Ctrl + Alt + Shift + Tab`| Zunguka umakini nyuma kati ya monita |

Njia za mkato za kubadilisha ukubwa hutumia vitufe halisi vya kimwili `code:20` na `code:21` (XKB `<AE11>` na `<AE12>`), bila kujali herufi zilizochapishwa kwenye kibodi. Kwenye kibodi za US vitufe hivi ni `-` na `=`; kwenye kibodi za Kijapani (JIS) ni `-` na `^`; kwenye kibodi za Kihispania ni `'` na `¡`. Kwenye JIS, `Super + ^` ni `Super + Equal`, huku `Super + Shift + -` (inayoandika `=`) ni `Super + Shift + Minus`.

## Vidhibiti vya mfumo

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Paneli ya sauti    |
| `Super + Ctrl + B`           | Paneli ya Bluetooth    |
| `Super + Ctrl + N`           | Paneli ya Wifi/mtandao    |
| `Super + Ctrl + D`           | Paneli ya onyesho    |
| `Super + Ctrl + P`           | Paneli ya nishati    |
| `Super + Ctrl + Alt + D`           | Paneli ya kalenda    |
| `Super + Ctrl + Alt + E`           | Paneli ya saa ya dunia    |
| `Super + Ctrl + 1-9`           | Badilisha paneli ya upau kulingana na mkao    |
| `Super + Ctrl + S` | Menyu ya kushiriki (kupitia LocalSend) |
| `Super + Ctrl + C` | Vidhibiti vya kunasa (picha ya skrini/-kurekodi/kiteua) |
| `Super + Ctrl + O` | Badilisha menyu |
| `Super + Ctrl + H` | Menyu ya vifaa |
| `Super + Ctrl + E` | Kiteua emoji |
| `Super + Ctrl + .` | Badilisha umbizo la media |
| `Super + Shift + Ctrl + A` | Chagua wakala wa AI |

## Marekebisho

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Mwangaza wa juu kabisa wa skrini |
| `Shift + Brightness Down` | Mwangaza wa chini kabisa wa skrini |
| `Alt + Brightness Up/Down` | Mabadiliko sahihi ya mwangaza ya 1% |
| `Alt + Volume Up/Down` | Mabadiliko sahihi ya sauti ya 1% |
| `Keyboard Brightness Up/Down` | Mwanga wa nyuma wa kibodi uwe mkali zaidi/mdogo zaidi |
| `Keyboard Backlight` | Zunguka viwango vya mwanga wa nyuma wa kibodi |
| `Alt + Play` | Wimbo unaofuata |
| `Alt + Shift + Play` | Wimbo uliopita |

## Kuzindua programu

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminali    |
| `Super + Alt + Return` | Terminali ya Tmux |
| `Super + Ctrl + Return` | Herdr (kidhibiti cha mawakala) |
| `Super + Shift + Return`           | Kivinjari    |
| `Super + Shift + Alt + B`           | Kivinjari (faragha/incognito)    |
| `Super + Shift + F`           | Kidhibiti faili    |
| `Super + Shift + Alt + F`           | Kidhibiti faili katika cwd ya terminali    |
| `Super + Shift + M`           | Muziki (Spotify)    |
| `Super + Shift + Alt + M`           | Muziki (cliamp)    |
| `Super + Shift + /`           | Kidhibiti cha nywila (1password)    |
| `Super + Shift + Q`           | Kikokotoo (Omacalc)    |
| `Super + Shift + T`           | Shughuli (btop)    |
| `Super + Shift + N`           | Kihariri (Neovim)  |
| `Super + Shift + C`           | Kalenda ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Barua pepe ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Barua pepe mpya ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Mjumbe (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Mjumbe (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Mjumbe (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Kuandika (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Badilisha/ongeza vifungo katika `~/.config/hypr/bindings.lua`.

## Ubao wa kunakili wa jumla

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + A`           | Chagua vyote katika programu zinazotumia `Ctrl + A`    |
| `Super + C`           | Nakili    |
| `Super + X`           | Kata (si katika terminali)    |
| `Super + V`           | Bandika    |
| `Super + Ctrl + V`           | Kidhibiti cha ubao wa kunakili    |

Kwa kawaida kwenye Linux, unahitaji `Ctrl + Shift + C/V` kunakili na kubandika katika terminali na `Ctrl + C/V` kufanya hivyo kila mahali pengine. Vibonye hivi vya haraka vya ubao wa kunakili vilivyounganishwa vya Omarchy hufanya kazi kila mahali.

## Kunasa

| Kibonye cha Haraka              | Kazi                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Picha ya skrini                      |
| `Super + Ctrl + Alt + C`            | Picha ya skrini (picha ileile, kwa kibodi zisizo na kitufe cha Print Screen) |
| `Super + Ctrl + C` | Menyu ya kunasa |
| `Alt + Print Screen`            | Rekodi skrini                     |
| `Super + Print Screen` | Kiteua rangi |
| `Super + Ctrl + Print Screen` | Kutoa maandishi hadi kwenye ubao wa kunakili |
| `Super + Alt + [` | Fanya ufunikaji wa webcam uwe mdogo zaidi wakati wa kurekodi |
| `Super + Alt + ]` | Fanya ufunikaji wa webcam uwe mkubwa zaidi wakati wa kurekodi |
| `Alt + Shift + L` | Nakili URL ya sasa kutoka webapp au Chromium |
| `Alt + Shift + D` | Pakua video iliyo kwenye ukurasa wa sasa hadi `~/Videos` |
| `Alt + Space` | Anzisha/simamisha udikteti (inahitaji _Setup > Defaults > Dictation_) |
| `Right Alt` | Shikilia ili kudikta (inahitaji _Setup > Defaults > Dictation_) |

Kwa rekodi za skrini, kibonye cha haraka kwanza hukuuliza sauti unayotaka, kisha huanza kurekodi. Kibonye tena ili kusimamisha. Tazama [picha za skrini na kurekodi](12-screenshots-recording.md) kwa maelezo.

Chaguo zote za kunasa pia zinapatikana chini ya _Trigger > Capture_ katika menyu ya Omarchy (`Super + Space`).

## Arifa

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + ,` | Tenda kwenye arifa ya hivi karibuni zaidi: ifungue au bonyeza kitufe chake pekee, chagua kutoka chaguo zake, au iondoe inapokuwa haina chochote  |
| `Super + Shift + ,` | Ondoa arifa zote |
| `Super + Ctrl + ,` | Dhibiti arifa kwa kibodi  |
| `Super + Alt + ,` | Ondoa arifa ya hivi karibuni zaidi  |
| `Super + Shift + Alt + ,` | Fungua historia ya arifa  |
| `Super + Ctrl + Alt + ,` | Badilisha kunyamazisha arifa  |

## Mtindo

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Chagua mandhari mapya (pia `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Chagua mandharinyuma ya mandhari (pia `Super + Ctrl + Space`) |
| `Super + Backspace` | Badilisha uwazi kwenye dirisha |
| `Super + Ctrl + Backspace` | Badilisha uwiano wa mraba wa dirisha moja |

Picha za ziada za mandharinyuma ziko katika `~/.config/omarchy/backgrounds/<theme name>`. Pia zinapatikana kupitia _Install > Style > Background_ katika menyu ya Omarchy.

Chaguo zote za mtindo pia zinapatikana chini ya _Style_ katika menyu ya Omarchy (`Super + Space`).

## Kugeuza

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Badilisha kufunga wakati wa kutofanya kazi |
| `Super + Ctrl + Delete` | Badilisha onyesho la kompyuta mpakato kuwasha/kuzima |
| `Super + Ctrl + Alt + Delete` | Badilisha uakisi wa onyesho la kompyuta mpakato |
| `Super + Shift + Space` | Badilisha upau wa juu  |
| `Shift + Mute` | Badilisha hadi towe linalofuata la sauti |
| `Shift + Play` | Badilisha hadi chanzo kinachofuata cha media |
| `Super + Shift + Backspace` | Badilisha mapengo ya madirisha |
| `Super + Ctrl + Alt + F` | Badilisha eneo-kazi la skrini nzima (upau wa juu + mapengo ya madirisha) |

## Vikumbusho

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Weka kikumbusho  |
| `Super + Ctrl + Alt + R` | Tazama vikumbusho vyote  |
| `Super + Ctrl + Shift + R` | Futa vikumbusho vyote  |

## Taarifa

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Onyesha saa kama arifa  |
| `Super + Ctrl + Alt + B` | Onyesha betri kama arifa  |
| `Super + Ctrl + Alt + W` | Badilisha hali ya hewa kama arifa  |

## Tmux

Kitufe cha kiambishi awali ni `Ctrl + Space` (`Ctrl + B` pia hufanya kazi). Unaweza kubadilisha vifungo hivi katika `~/.config/tmux/tmux.conf`.

### Paneli

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Prefix + v` | Gawa paneli kando (wima) |
| `Prefix + h` | Gawa paneli chini (mlalo) |
| `Prefix + x` | Ua paneli |
| `Prefix + z` | Badilisha ukuzaji wa paneli (skrini nzima) |
| `Alt + Enter` | Gawa paneli chini (hakuna kiambishi awali) |
| `Alt + Shift + Enter` | Gawa paneli kando (hakuna kiambishi awali) |
| `Alt + Escape` | Ua paneli (hakuna kiambishi awali) |
| `Ctrl + Alt + Arrows` | Sogea kati ya paneli |
| `Ctrl + Alt + Shift + Arrows` | Badilisha ukubwa wa paneli |

### Madirisha

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Prefix + c` | Dirisha jipya |
| `Prefix + k` | Ua dirisha |
| `Prefix + r` | Badilisha jina la dirisha |
| `Alt + 1-9` | Nenda kwenye dirisha maalum |
| `Alt + Arrow Left/Right` | Sogea kati ya madirisha |
| `Alt + Shift + Arrow Left/Right` | Hamisha dirisha kushoto/kulia |

### Vipindi

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Prefix + C` | Kipindi kipya |
| `Prefix + K` | Ua kipindi |
| `Prefix + R` | Badilisha jina la kipindi |
| `Prefix + N` | Kipindi kinachofuata |
| `Prefix + P` | Kipindi kilichopita |
| `Alt + Arrow Up/Down` | Sogea kati ya vipindi |
| `Prefix + s` | Orodhesha vipindi |
| `Prefix + d` | Jitenge na kipindi |

### Hali ya kunakili (mtindo wa vi)

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Prefix + [` | Ingia hali ya kunakili |
| `v` | Anza uteuzi (katika hali ya kunakili) |
| `y` | Nakili uteuzi (katika hali ya kunakili) |

### Jumla

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Prefix + q` | Pakia upya usanidi |
| `Prefix + ?` | Onyesha vifungo vya vitufe vya Tmux |
| `Prefix + :` | Kidokezo cha amri |

### Vitendakazi vya mpangilio wa Tmux

Vitendakazi hivi lazima viendeshwe ndani ya kipindi cha Tmux.

| Amri | Kazi |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Unda mpangilio wa uendelezaji wenye kihariri, AI, na terminali |
| `tdlm <ai> [<second_ai>]` | Unda mpangilio wa uendelezaji kwa kila saraka ndogo |
| `tsl <count> <command>` | Unda mpangilio wa kundi wa paneli nyingi |

## Terminali ya Ghostty

Terminali ya Ghostty husakinishwa kwa kutumia _Install > Terminal_ kupitia menyu ya Omarchy.

| Kibonye cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Mgawanyiko mpya chini |
| `Ctrl + Shift + O` | Mgawanyiko mpya kando |
| `Ctrl + Alt + Arrows` | Sogea kati ya migawanyiko |
| `Super + Ctrl + Shift + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 10 |
| `Super + Ctrl + Shift + Alt + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 100 |
| `Ctrl + Shift + T` | Kichupo kipya  |
| `Ctrl + Shift + Arrows` | Sogea kati ya vichupo |
| `Alt + Numbers` | Nenda kwenye kichupo maalum |
| `Shift + Pg Up/Down` | Tembeza historia |
| `Ctrl + Left mouse` | Fungua kiungo katika kivinjari |

## Kidhibiti Faili

| Kibonye cha Haraka              | Kazi                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Nenda kwenye njia                     |
| `Space`               | Hakiki faili (mishale husogeza) |
| `Alt + Up`       | Nenda juu hadi folda kuu        |

## Neovim (w/ lazyvim)

### Urambazaji

| Kibonye cha Haraka                   | Kazi                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Onyesha chaguo za amri            |
| `Space Space`              | Fungua faili kupitia utafutaji usio wazi      |
| `Space E`                  | Badilisha upau wa kando                  |
| `Space G G`                | Onyesha vidhibiti vya git               |
| `Space S G`                | Tafuta maudhui ya faili             |
| `Ctrl + W W`               | Ruka kati ya upau wa kando na kihariri |
| `Ctrl + Left/right arrow`  | Badilisha ukubwa wa upau wa kando          |
| `Shift + H`                      | Nenda kwenye kichupo cha faili cha kushoto             |
| `Shift + L`                      | Nenda kwenye kichupo cha faili cha kulia            |
| `Space B D`                | Funga kichupo cha faili                  |

### Ukiwa katika upau wa kando

| Kibonye cha Haraka                   | Kazi                        |
| ------------------------ | ------------------------------- |
| `A`                        | Ongeza faili mpya katika saraka kuu      |
| `Shift + A`                | Ongeza saraka ndogo mpya katika saraka kuu    |
| `D`                        | Futa faili/saraka iliyoangaziwa     |
| `M`                        | Hamisha faili/saraka iliyoangaziwa       |
| `R`                        | Badilisha jina la faili/saraka iliyoangaziwa     |
| `?`                        | Onyesha usaidizi kwa amri zote      |

[Tazama vibonye vyote vya haraka vya Neovim vilivyosanidiwa na LazyVim](https://www.lazyvim.org/keymaps).

## Emoji za Haraka

Unaweza kutumia `Super + Ctrl + E` kuonyesha kiteua kamili cha emoji ambacho kitaweka uteuzi kwenye ubao wa kunakili au unaweza kutumia chaguo hizi za ufikiaji wa haraka.

| Kibonye cha Haraka       | EM | Kidokezo       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | tabasamu      |
| `Shift + CapsLock M C` | 😂 | lia        |
| `Shift + CapsLock M L` | 😍 | penda       |
| `Shift + CapsLock M V` | ✌️ | ushindi    |
| `Shift + CapsLock M H` | ❤️ | moyo      |
| `Shift + CapsLock M Y` | 👍 | ndiyo        |
| `Shift + CapsLock M N` | 👎 | hapana         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | tamani       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | busu       |
| `Shift + CapsLock M E` | 🙄 | zungusha macho    |
| `Shift + CapsLock M I` | 😉 | konyeza       |
| `Shift + CapsLock M P` | 🙏 | omba |
| `Shift + CapsLock M D` | 🤤 | tokwa mate      |
| `Shift + CapsLock M M` | 💰 | pesa      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | sawa |
| `Shift + CapsLock M G` |👋 | salamu |
| `Shift + CapsLock M A` |💪 | mkono |
| `Shift + CapsLock M B` |🤯 | kupasuka |

## Ukamilishaji wa Haraka

| Kibonye cha Haraka       | Ukamilishaji       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Jina lako (kama lilivyoingizwa wakati wa usanidi)  |
| `Shift + CapsLock Space E` | Barua pepe yako (kama ilivyoingizwa wakati wa usanidi)  |

Unaweza kuongeza zaidi yako mwenyewe kwa kuhariri `~/.XCompose`, kisha endesha `omarchy-restart-xcompose` katika terminali ili mabadiliko yachukuliwe.
