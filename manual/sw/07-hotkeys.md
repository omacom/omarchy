# Vitufe vya Haraka

Unaweza kuona vifungo vyote vikuu vya kibodi kwa `Super + K` (vifungo vya Tmux kwa `Super + Alt + K` na vifungo vya Herdr kwa `Super + Ctrl + K`).

## Jinsi vitufe vya haraka vilivyopangwa

Kila kitufe cha haraka kipo kwenye tanda, inayowekwa na virekebishaji vyake, na kila tanda ina kazi moja. Hilo ndilo linalozuia vitufe vya haraka kuchanganyikana, na inamaanisha kwa kawaida unaweza kukisia kitu kipo wapi.

| Tanda | Kinachoishi hapo | Mifano |
| --- | --- | --- |
| `Super + key` | Mfumo: madirisha, nafasi za kazi, mipangilio, na menyu kuu | `Super + Space` menyu ya Omarchy, `Super + W` funga dirisha, `Super + F` skrini nzima |
| `Super + Shift + key` | Programu | `Super + Shift + B` kivinjari, `Super + Shift + E` barua pepe, `Super + Shift + N` kihariri |
| `Super + Ctrl + key` | Paneli na menyu za mfumo | `Super + Ctrl + A` sauti, `Super + Ctrl + N` mtandao, `Super + Ctrl + C` menyu ya kurekodi |
| `Super + Ctrl + Alt + key` | Vitendo vya haraka na notisi | `Super + Ctrl + Alt + T` onyesha saa, `Super + Ctrl + Alt + B` betri, `Super + Ctrl + Alt + C` picha ya skrini |

Kuongeza `Alt` kwenye kitufe cha haraka kunakupa lahaja ya kitu kile kile, kamwe si kitu kisichohusiana:

- `Super + Shift + B` hufungua kivinjari; `Super + Shift + Alt + B` hufungua dirisha la faragha
- `Super + Shift + E` hufungua barua pepe; `Super + Shift + Alt + E` huanzisha mpya
- `Super + F` huenda skrini nzima; `Super + Alt + F` huenda upana mzima
- `Super + Ctrl + C` hufungua menyu ya kurekodi; `Super + Ctrl + Alt + C` huruka menyu na kupiga picha ya skrini

Unapoongeza kitufe cha haraka:

1. Chagua tanda kutokana na kile kinachofanya, kisha chagua kitufe.
2. Usihamishe kitufe cha haraka kilichopo ili kupata nafasi. Tafuta kitufe kisichotumika kwenye tanda sahihi.
3. Tumia `Alt` tu kwa lahaja ya kitufe cha haraka kisicho nayo.

Vitufe vichache vya haraka huvunja sheria hizi kwa sababu ni rahisi kutumia. `Shift` pamoja na mshale au `Tab` huhamisha au hubadilisha mwelekeo badala ya kufungua programu, na `Print`, vitufe vya media, `Alt + Tab`, na `Ctrl + Alt + Del` hufanya kazi kama zinavyofanya kila mahali pengine. Ni tofauti na kanuni, si mifumo ya kuiga.

Ikiwa chaguomsingi hakikufai (tuseme unataka `Super + Shift + S` kwa picha za skrini kama kwenye Windows), kibadilishe katika `~/.config/hypr/bindings.lua`.

## Kusogeza

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menyu ya Omarchy (programu na kila kitu kingine)    |
| `Super + Alt + Space` | Gridi ya programu |
| `Super + Escape` | Menyu ya mfumo (sitisha, anzisha upya, n.k.)  |
| `Super + Ctrl + L` | Funga kompyuta |
| `Super + W` or `Super + Q` | Funga dirisha             |
| `Ctrl + Alt + Del` | Funga madirisha yote |
| `Super + K` | Onyesha vitufe vyote vya haraka |
| `Super + Alt + K` | Onyesha vitufe vya haraka vya tmux |
| `Super + Ctrl + K` | Onyesha vitufe vya haraka vya herdr |
| `Super + M` | Punguza dirisha hadi kwenye doki |
| `Super + T`               | Badilisha dirisha kati ya kuweka tiles/kuelea             |
| `Super + J` | Badilisha nafasi ya dirisha (mlalo/wima) |
| `Super + O`               | Badilisha kuibua dirisha kuwa linalonata na kuelea |
| `Super + L`               | Zunguka kupitia mipangilio ya dwindle, scrolling, na floating |
| `Super + Alt + L`         | Zunguka kupitia mipangilio kinyume chake |
| `Super + P`               | Badilisha mtindo wa dirisha bandia (wa asili dhidi ya kunyoosha) |
| `Super + F`                 | Nenda skrini nzima              |
| `Super + Alt + F`                 | Nenda upana mzima              |
| `Super + Ctrl + F`                 | Nenda skrini nzima ndani ya dirisha              |
| `Super + 1…9/0`         | Rukia nafasi maalum ya kazi (0 ni 10) kwenye monita iliyolengwa |
| `Super + Tab` | Rukia nafasi inayofuata ya kazi kwenye monita iliyolengwa |
| `Super + Shift + Tab` | Rukia nafasi ya awali ya kazi kwenye monita iliyolengwa |
| `Super + Ctrl + Tab` | Rukia nafasi ya kazi ya zamani kwenye monita iliyolengwa |
| `Super + Shift + 1…9/0` | Hamisha dirisha hadi nafasi ya kazi kwenye monita iliyolengwa |
| `Super + Shift + Alt + 1…9/0` | Hamisha dirisha hadi nafasi ya kazi kwenye monita iliyolengwa bila kulifuata |
| `Super + S` | Badilisha scratchpad kamili |
| `Super + Alt + S` | Hamisha dirisha hadi scratchpad kamili |
| `Super + the key above Tab` (grave on US layouts) | Badilisha konsoli ya Quake |
| `Super + Shift + the key above Tab` (grave on US layouts) | Hamisha dirisha hadi konsoli ya Quake |
| `Super + Shift + Ctrl + Arrows` | Hamisha dirisha hadi monita katika mwelekeo huo |
| `Super + Shift + Alt + Arrows` | Hamisha nafasi ya kazi hadi monita katika mwelekeo huo |
| `Super + Arrow`  | Hamisha lengo hadi dirisha katika mwelekeo wa mshale, ukivuka hadi monita ya upande huo kwenye ukingo wa skrini |
| `Super + Shift + Arrow`  | Badilishana dirisha na jingine katika mwelekeo wa mshale, ikijumuisha lililo kwenye monita ya upande huo |
| `Super + Minus` | Panua dirisha kushoto |
| `Super + Equal` | Punguza dirisha kushoto |
| `Super + Shift + Minus` | Punguza dirisha juu |
| `Super + Shift + Equal` | Panua dirisha chini |
| `Super + Alt + Minus/Equal` | Ubadilishaji ukubwa ule ule kwa hatua ndogo zaidi |
| `Super + Ctrl + Minus/Equal` | Ubadilishaji ukubwa ule ule kwa hatua kubwa zaidi |
| `Super + Alt + Home` | Hifadhi upana wa dirisha |
| `Super + Home` | Rejesha upana wa dirisha uliohifadhiwa |
| `Super + Left Mouse` | Buruta dirisha huku na huko |
| `Super + Right Mouse` | Badilisha ukubwa wa dirisha |
| `Super + Scroll Wheel` | Pitia nafasi za kazi kwenye monita iliyolengwa |
| `Super + G`               | Badilisha uwekaji wa dirisha katika kikundi      |
| `Super + Alt + G`               | Toa dirisha katika kikundi      |
| `Super + Alt + Tab`               | Zunguka kati ya madirisha katika kikundi      |
| `Super + Alt + Shift + Tab`               | Zunguka nyuma kati ya madirisha katika kikundi      |
| `Super + Alt + Scroll Wheel` | Zunguka kati ya madirisha katika kikundi |
| `Super + Alt + 1/2/3/4/5`               | Rukia dirisha maalum katika kikundi      |
| `Super + Alt + Arrow`  | Hamisha dirisha kuingia katika kikundi katika mwelekeo wa mshale, ikijumuisha lililo kwenye monita ya upande huo |
| `Super + Ctrl + Left/Right`  | Sogea kati ya madirisha ndani ya kikundi cha kuweka tiles |
| `Super + Ctrl + Z` | Kuza kwenye skrini (r repeat kwa kuza zaidi) |
| `Super + Ctrl + Alt + Z` | Kuza kabisa nje ya skrini |
| `Super + /` | Sogea mbele kupitia chaguo za kuongeza ukubwa wa monita |
| `Super + Alt + /` | Sogea nyuma kupitia chaguo za kuongeza ukubwa wa monita |
| `Alt + Tab` | Zunguka mbele kupitia madirisha kwenye nafasi ya kazi inayotumika |
| `Alt + Shift + Tab` | Zunguka nyuma kupitia madirisha kwenye nafasi ya kazi inayotumika |
| `Ctrl + Alt + Tab`| Zunguka lengo mbele kupitia monita |
| `Ctrl + Alt + Shift + Tab`| Zunguka lengo nyuma kupitia monita |
| `Super + I` | Badilisha lugha ya kuingiza (ukiwa na mpangilio au mbinu ya kuingiza zaidi ya moja) |
| `Super + Shift + I` | Badilisha lugha ya kuingiza nyuma |

Kwenye pedi ya kugusa, kupangusa kwa vidole vitatu na vinne hubadilisha nafasi za kazi, huhamisha madirisha, na hufungua menyu na konsoli ya Quake; angalia [kibodi, kipanya, na pedi ya kugusa](34-keyboard-mouse-trackpad.md) kwa ishara hizo.

Kubadilisha ukubwa hutumia vitufe viwili vilivyo kulia mwa 0, chochote kibodi yako inachochapisha juu yake: `-` na `=` kwenye kibodi za US, `+` na `´` kwenye za Kidenmaki na Kiswidi, `+` na `\` kwenye za Kinorwe, `ß` na `´` kwenye za Kijerumani, `'` na `¡` kwenye za Kihispania, na `-` na `^` kwenye za Kijapani (JIS). `Super + K` huvi orodhesha kama kibodi yako inavyovichapisha. Kwenye JIS, `Super + ^` ni `Super + Equal`, huku `Super + Shift + -` (ambayo huchapa `=`) ni `Super + Shift + Minus`. Kuongeza ukubwa wa monita na kidhibiti cha nenosiri hutumia `/`; kwenye mipangilio inayochapa `/` tu na Shift, kama mipangilio mingi ya Ulaya inavyofanya, hutumia kitufe kilicho kushoto mwa Shift ya kulia badala yake (`-` kwenye za Kidenmaki na Kijerumani).

## Vidhibiti vya mfumo

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Paneli ya sauti    |
| `Super + Ctrl + B`           | Paneli ya Bluetooth    |
| `Super + Ctrl + N`           | Paneli ya Wifi/mtandao    |
| `Super + Ctrl + D`           | Paneli ya onyesho    |
| `Super + Ctrl + P`           | Paneli ya nishati    |
| `Super + Ctrl + X`           | Paneli ya Agents    |
| `Super + Ctrl + Alt + D`           | Paneli ya kalenda    |
| `Super + Ctrl + Alt + E`           | Paneli ya saa za dunia    |
| `Super + Ctrl + 1-9`           | Badilisha paneli ya upau kulingana na nafasi    |
| `Super + Ctrl + S` | Menyu ya kushiriki (kupitia LocalSend) |
| `Super + Ctrl + C` | Vidhibiti vya kurekodi (picha ya skrini/-kurekodi/kiteua rangi) |
| `Super + Ctrl + O` | Badilisha menyu |
| `Super + Ctrl + H` | Menyu ya vifaa |
| `Super + Ctrl + E` | Kiteua emoji |
| `Super + Ctrl + .` | Badilisha umbizo la media |
| `Super + Shift + Ctrl + A` | Anzisha wakala wako chaguomsingi |
| `Power` key | Menyu ya mfumo |
| `Super + Shift + Copilot` key | Menyu ya Omarchy |

## Marekebisho

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Mwangaza wa juu kabisa wa skrini |
| `Shift + Brightness Down` | Mwangaza wa chini kabisa wa skrini |
| `Alt + Brightness Up/Down` | Mabadiliko sahihi ya mwangaza ya 1% |
| `Alt + Volume Up/Down` | Mabadiliko sahihi ya sauti ya 1% |
| `Keyboard Brightness Up/Down` | Mwangaza wa nyuma wa kibodi uwe mkali/uliofifia zaidi |
| `Keyboard Backlight` | Zunguka viwango vya mwangaza wa nyuma wa kibodi |
| `Ctrl + Brightness Up/Down` | Mwangaza wa nyuma wa kibodi uwe mkali/uliofifia zaidi, kwenye kibodi zisizo na vitufe vyao wenyewe |
| `Mic Mute` | Nyamazisha maikrofoni |
| `Shift + Mute` | Badilisha chanzo cha sauti kinachotoka |
| `Touchpad Toggle` | Washa au zima pedi ya kugusa |
| `Display` key | Zunguka mpangilio wa nafasi ya kazi |
| `Alt + Play` | Wimbo unaofuata |
| `Alt + Shift + Play` | Wimbo uliotangulia |

## Kufungua programu

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal ya Tmux |
| `Super + Ctrl + Return` | Herdr (kidhibiti cha mawakala) |
| `Super + Shift + Return` or `Super + Shift + B`  | Kivinjari    |
| `Super + Shift + Alt + B`           | Kivinjari (cha faragha/incognito)    |
| `Super + Shift + F`           | Kidhibiti cha faili    |
| `Super + Shift + Alt + F`           | Kidhibiti cha faili katika cwd ya terminal    |
| `Super + Shift + M`           | Muziki (Spotify)    |
| `Super + Shift + Alt + M`           | Muziki (cliamp)    |
| `Super + Shift + /`           | Kidhibiti cha nenosiri (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kikokotoo (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, ikishasakinishwa)    |
| `Super + Shift + T`           | Shughuli (btop)    |
| `Super + Shift + N`           | Kihariri (Plain, au chaguomsingi ulichochagua)  |
| `Super + Shift + C`           | Kalenda ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Barua pepe ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Barua pepe mpya ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Wakala wako chaguomsingi, au ChatGPT hadi utakapochagua mmoja |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Mjumbe (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Mjumbe (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Mjumbe (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Kuandika (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (chapisho jipya) |
| `Super + Shift + Y`           | YouTube |

Badilisha/ongeza vifungo katika `~/.config/hypr/bindings.lua`.

## Ubao wa kunakili wa ulimwengu wote

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + A`           | Chagua vyote katika programu zinazotumia `Ctrl + A`    |
| `Super + C`           | Nakili    |
| `Super + X`           | Kata (si katika terminal)    |
| `Super + V`           | Bandika    |
| `Super + Ctrl + V`           | Kidhibiti cha ubao wa kunakili    |

Kwa kawaida kwenye Linux, unahitaji `Ctrl + Shift + C/V` kunakili na kubandika katika terminal na `Ctrl + C/V` kufanya hivyo kila mahali pengine. Vitufe hivi vya haraka vya ubao wa kunakili vilivyounganishwa vya Omarchy hufanya kazi kila mahali.

## Kurekodi

| Kitufe cha Haraka              | Kazi                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Picha ya skrini                      |
| `Super + Ctrl + Alt + C`            | Picha ya skrini (picha ile ile, kwa kibodi zisizo na kitufe cha Print Screen) |
| `Super + Ctrl + C` | Menyu ya kurekodi |
| `Alt + Print Screen`            | Kurekodi skrini                     |
| `Super + Shift + Ctrl + Alt + C` | Kurekodi skrini bila sauti, ukiruka menyu (gusa tena kusimamisha) |
| `Super + Print Screen` | Kiteua rangi |
| `Super + Ctrl + Print Screen` | Uchukuaji wa maandishi hadi ubao wa kunakili |
| `Super + Alt + [` | Fanya safu ya webcam iwe ndogo zaidi wakati wa kurekodi |
| `Super + Alt + ]` | Fanya safu ya webcam iwe kubwa zaidi wakati wa kurekodi |
| `Alt + Shift + L` | Nakili URL ya sasa kutoka webapp au kivinjari |
| `Alt + Shift + D` | Pakua video iliyo kwenye ukurasa wa sasa hadi `~/Videos` |
| `Alt + Space` | Anzisha/simamisha kuagiza kwa sauti (inahitaji _Setup > Defaults > Dictation_) |
| `Right Alt` | Shikilia ili kuagiza kwa sauti (inahitaji _Setup > Defaults > Dictation_) |

Kwa kurekodi skrini, kitufe cha haraka kwanza huuliza sauti unayoitaka, kisha huanza kurekodi. Kiguse tena kusimamisha. Angalia [picha za skrini na kurekodi](12-screenshots-recording.md) kwa maelezo.

Chaguo zote za kurekodi zinapatikana pia chini ya _Trigger > Capture_ katika menyu ya Omarchy (`Super + Space`).

## Arifa

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + ,` | Chukua hatua kuhusu arifa ya hivi karibuni zaidi: ifungue au bonyeza kitufe chake pekee, chagua kutoka chaguo zake, au iondoe ikiwa haina chochote  |
| `Super + Shift + ,` | Ondoa arifa zote |
| `Super + Ctrl + ,` | Dhibiti arifa kwa kibodi  |
| `Super + Alt + ,` | Ondoa arifa ya hivi karibuni zaidi  |
| `Super + Shift + Alt + ,` | Fungua historia ya arifa  |
| `Super + Ctrl + Alt + ,` | Badilisha kunyamazisha arifa  |

## Mtindo

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Chagua mandhari mapya (pia `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Chagua mandharinyuma ya mandhari (pia `Super + Ctrl + Space`) |
| `Super + Backspace` | Badilisha uwazi kwenye dirisha |
| `Super + Ctrl + Backspace` | Badilisha uwiano wa mraba wa dirisha moja |

Picha za ziada za mandharinyuma zipo katika `~/.config/omarchy/backgrounds/<theme name>`. Zinapatikana pia kupitia _Install > Style > Background_ katika menyu ya Omarchy.

Chaguo zote za mtindo zinapatikana pia chini ya _Appearance_ katika menyu ya Omarchy (`Super + Space`).

## Vibadilishi

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Badilisha kufunga wakati wa kutofanya kazi |
| `Super + Ctrl + Delete` | Badilisha onyesho la laptop kuwasha/kuzima |
| `Super + Ctrl + Alt + Delete` | Badilisha uakisi wa onyesho la laptop |
| `Super + Shift + Space` | Badilisha upau wa juu  |
| `Shift + Mute` | Badilisha hadi chanzo kinachofuata cha sauti kinachotoka |
| `Shift + Play` | Badilisha hadi chanzo kinachofuata cha media |
| `Super + Shift + Backspace` | Badilisha mapengo ya madirisha |
| `Super + Ctrl + Alt + F` | Badilisha eneo-kazi la skrini nzima (upau wa juu + mapengo ya madirisha) |

## Vikumbusho

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Weka kikumbusho  |
| `Super + Ctrl + Alt + R` | Ona vikumbusho vyote  |
| `Super + Ctrl + Shift + R` | Futa vikumbusho vyote  |

## Notisi

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Onyesha saa kama arifa  |
| `Super + Ctrl + Alt + B` | Onyesha betri kama arifa  |
| `Super + Ctrl + Alt + W` | Badilisha hali ya hewa kama arifa  |

## Tmux

Kitufe cha kiambishi awali ni `Ctrl + Space` (`Ctrl + B` pia hufanya kazi). Unaweza kubadilisha vifungo hivi katika `~/.config/tmux/tmux.conf`.

### Paneli ndogo

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Prefix + v` | Gawanya paneli ndogo kando (wima) |
| `Prefix + h` | Gawanya paneli ndogo chini (mlalo) |
| `Prefix + x` | Ua paneli ndogo |
| `Prefix + z` | Badilisha kukuza paneli ndogo (skrini nzima) |
| `Alt + Enter` | Gawanya paneli ndogo chini (bila kiambishi awali) |
| `Alt + Shift + Enter` | Gawanya paneli ndogo kando (bila kiambishi awali) |
| `Alt + Escape` | Ua paneli ndogo (bila kiambishi awali) |
| `Ctrl + Alt + Arrows` | Sogea kati ya paneli ndogo |
| `Ctrl + Alt + Shift + Arrows` | Badilisha ukubwa wa paneli ndogo |

### Madirisha

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Prefix + c` | Dirisha jipya |
| `Prefix + k` | Ua dirisha |
| `Prefix + r` | Badilisha jina la dirisha |
| `Alt + 1-9` | Nenda dirisha maalum |
| `Alt + Arrow Left/Right` | Sogea kati ya madirisha |
| `Alt + Shift + Arrow Left/Right` | Hamisha dirisha kushoto/kulia |

### Vipindi

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Prefix + C` | Kipindi kipya |
| `Prefix + K` | Ua kipindi |
| `Prefix + R` | Badilisha jina la kipindi |
| `Prefix + N` | Kipindi kinachofuata |
| `Prefix + P` | Kipindi kilichotangulia |
| `Alt + Arrow Up/Down` | Sogea kati ya vipindi |
| `Prefix + s` | Orodhesha vipindi |
| `Prefix + d` | Tenganisha kutoka kipindi |

### Hali ya kunakili (mtindo wa vi)

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Prefix + [` | Ingia hali ya kunakili |
| `v` | Anza uteuzi (katika hali ya kunakili) |
| `y` | Nakili uteuzi (katika hali ya kunakili) |

### Kwa ujumla

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Prefix + q` | Pakia upya usanidi |
| `Prefix + ?` | Onyesha vifungo vya vitufe vya Tmux |
| `Prefix + :` | Kidokezo cha amri |

### Vitendakazi vya mpangilio wa Tmux

Vitendakazi hivi lazima viendeshwe ndani ya kipindi cha Tmux.

| Amri | Kazi |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Unda mpangilio wa uendelezaji wenye kihariri, AI, na terminal |
| `tdlm <ai> [<second_ai>]` | Unda mpangilio wa uendelezaji kwa kila saraka ndogo |
| `tsl <count> <command>` | Unda mpangilio wa kundi wenye paneli ndogo nyingi |

## Terminal ya Ghostty

Terminal ya Ghostty husakinishwa kwa kutumia _Install > Terminal_ kupitia menyu ya Omarchy.

| Kitufe cha Haraka                  | Kazi              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Mgawanyiko mpya chini |
| `Ctrl + Shift + O` | Mgawanyiko mpya kando |
| `Ctrl + Alt + Arrows` | Sogea kati ya migawanyiko |
| `Super + Ctrl + Shift + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 10 |
| `Super + Ctrl + Shift + Alt + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 100 |
| `Ctrl + Shift + T` | Kichupo kipya  |
| `Ctrl + Shift + Arrows` | Sogea kati ya vichupo |
| `Alt + Numbers` | Nenda kichupo maalum |
| `Shift + Pg Up/Down` | Pitia historia |
| `Ctrl + Left mouse` | Fungua kiungo katika kivinjari |

## Kidhibiti cha Faili

| Kitufe cha Haraka              | Kazi                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Nenda kwenye njia                     |
| `Space`               | Hakiki faili (mishale husogeza) |
| `Alt + Up`       | Nenda juu hadi folda mzazi        |

## Neovim (w/ lazyvim)

### Kusogeza

| Kitufe cha Haraka                   | Kazi                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Onyesha chaguo za amri            |
| `Space Space`              | Fungua faili kupitia utafutaji usio wazi      |
| `Space E`                  | Badilisha upau wa kando                  |
| `Space G G`                | Onyesha vidhibiti vya git               |
| `Space S G`                | Tafuta maudhui ya faili             |
| `Ctrl + W W`               | Rukia kati ya upau wa kando na kihariri |
| `Ctrl + Left/right arrow`  | Badilisha ukubwa wa upau wa kando          |
| `Shift + H`                      | Nenda kichupo cha faili cha kushoto             |
| `Shift + L`                      | Nenda kichupo cha faili cha kulia            |
| `Space B D`                | Funga kichupo cha faili                  |

### Ukiwa katika upau wa kando

| Kitufe cha Haraka                   | Kazi                        |
| ------------------------ | ------------------------------- |
| `A`                        | Ongeza faili mpya katika saraka mzazi      |
| `Shift + A`                | Ongeza saraka ndogo mpya katika saraka mzazi    |
| `D`                        | Futa faili/saraka iliyoangaziwa     |
| `M`                        | Hamisha faili/saraka iliyoangaziwa       |
| `R`                        | Badilisha jina la faili/saraka iliyoangaziwa     |
| `?`                        | Onyesha usaidizi kwa amri zote      |

[Angalia vitufe vyote vya haraka vya Neovim vilivyosanidiwa na LazyVim](https://www.lazyvim.org/keymaps).

## Emoji za Haraka

Unaweza kutumia `Super + Ctrl + E` kuonyesha kiteua kamili cha emoji ambacho kitaweka uteuzi kwenye ubao wa kunakili au unaweza kutumia chaguo hizi za ufikiaji wa haraka.

| Kitufe cha Haraka       | EM | Kidokezo       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | tabasamu      |
| `Shift + CapsLock M C` | 😂 | kulia        |
| `Shift + CapsLock M L` | 😍 | upendo       |
| `Shift + CapsLock M V` | ✌️ | ushindi    |
| `Shift + CapsLock M H` | ❤️ | moyo      |
| `Shift + CapsLock M Y` | 👍 | ndiyo        |
| `Shift + CapsLock M N` | 👎 | hapana         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | tamanio       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | busu       |
| `Shift + CapsLock M E` | 🙄 | kuviringisha macho    |
| `Shift + CapsLock M I` | 😉 | konyeza       |
| `Shift + CapsLock M P` | 🙏 | omba |
| `Shift + CapsLock M D` | 🤤 | kutoa mate      |
| `Shift + CapsLock M M` | 💰 | pesa      |
| `Shift + CapsLock M X` | 🎉 | sherehe |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | sawa |
| `Shift + CapsLock M G` |👋 | salamu |
| `Shift + CapsLock M A` |💪 | mkono |
| `Shift + CapsLock M B` |🤯 | kulipuka |

## Ukamilishaji wa Haraka

| Kitufe cha Haraka       | Ukamilishaji       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Jina lako (kama lilivyoingizwa wakati wa usanidi)  |
| `Shift + CapsLock Space E` | Barua pepe yako (kama ilivyoingizwa wakati wa usanidi)  |

Unaweza kuongeza zaidi yako mwenyewe kwa kuhariri `~/.XCompose`, kisha kuendesha `omarchy restart xcompose` katika terminal ili mabadiliko yachukuliwe.
