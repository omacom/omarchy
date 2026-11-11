# Vitufe vya Mkato

Unaweza kuona vifungo vyote vikuu vya kibodi kwa `Super + K` (vifungo vya Tmux kwa `Super + Alt + K` na vifungo vya Herdr kwa `Super + Ctrl + K`).

## Jinsi vitufe vya mkato vilivyopangwa

Kila kitufe cha mkato hukaa kwenye safu, iliyowekwa na virekebishaji vyake, na kila safu ina kazi moja. Hilo ndilo linalozuia vitufe vya mkato kuchanganyika, na linamaanisha kwa kawaida unaweza kukisia kitu hukaa wapi.

| Safu | Kinachokaa hapo | Mifano |
| --- | --- | --- |
| `Super + key` | Mfumo: madirisha, nafasi za kazi, mipangilio, na menyu za msingi | `Super + Space` menyu ya Omarchy, `Super + W` funga dirisha, `Super + F` skrini nzima |
| `Super + Shift + key` | Programu | `Super + Shift + B` kivinjari, `Super + Shift + E` barua pepe, `Super + Shift + N` kihariri |
| `Super + Ctrl + key` | Paneli na menyu za mfumo | `Super + Ctrl + A` sauti, `Super + Ctrl + N` mtandao, `Super + Ctrl + C` menyu ya kunasa |
| `Super + Ctrl + Alt + key` | Vitendo vya haraka na ilani | `Super + Ctrl + Alt + T` onyesha muda, `Super + Ctrl + Alt + B` betri, `Super + Ctrl + Alt + C` picha ya skrini |

Kuongeza `Alt` kwenye kitufe cha mkato hukupa lahaja ya kitu kile kile, kamwe si kitu kisichohusiana:

- `Super + Shift + B` hufungua kivinjari; `Super + Shift + Alt + B` hufungua dirisha la binafsi
- `Super + Shift + E` hufungua barua pepe; `Super + Shift + Alt + E` huanzisha mpya
- `Super + F` huenda skrini nzima; `Super + Alt + F` huenda upana kamili
- `Super + Ctrl + C` hufungua menyu ya kunasa; `Super + Ctrl + Alt + C` huruka menyu na huchukua picha ya skrini

Wakati wa kuongeza kitufe cha mkato:

1. Chagua safu kutoka kwa kile kinachofanya, kisha chagua kitufe.
2. Usihamishe kitufe cha mkato kilichopo ili kupata nafasi. Tafuta kitufe kilicho wazi kwenye safu sahihi.
3. Tumia `Alt` tu kwa lahaja ya kitufe cha mkato kisicho nayo.

Vitufe vichache vya mkato huvunja sheria hizi kwa sababu ni rahisi kutumia. `Shift` ikiwa na mshale au `Tab` husogeza au hubadilisha mwelekeo badala ya kufungua programu, na `Print`, vitufe vya media, `Alt + Tab`, na `Ctrl + Alt + Del` hufanya kazi jinsi zinavyofanya kila mahali pengine. Ni vighairi, si mifumo ya kunakili.

Ikiwa chaguomsingi haikufai (tuseme unataka `Super + Shift + S` kwa picha za skrini kama kwenye Windows), kifunge upya katika `~/.config/hypr/bindings.lua`.

## Urambazaji

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menyu ya Omarchy (programu na kila kitu kingine)    |
| `Super + Alt + Space` | Gridi ya programu |
| `Super + Escape` | Menyu ya mfumo (simamisha, anzisha upya, n.k.)  |
| `Super + Ctrl + L` | Funga kompyuta |
| `Super + W` or `Super + Q` | Funga dirisha             |
| `Ctrl + Alt + Del` | Funga madirisha yote |
| `Super + T`               | Geuza dirisha kati ya kupangwa/kuelea             |
| `Super + J` | Geuza nafasi ya dirisha (mlalo/wima) |
| `Super + O`               | Geuza dirisha kuwa linalonata na kuelea |
| `Super + L`               | Zunguka kupitia mipangilio ya dwindle, scrolling, na floating |
| `Super + Alt + L`         | Zunguka kupitia mipangilio kwa nyuma |
| `Super + P`               | Geuza mtindo wa dirisha bandia (asili dhidi ya kunyoosha) |
| `Super + F`                 | Nenda skrini nzima              |
| `Super + Alt + F`                 | Nenda upana kamili              |
| `Super + Ctrl + F`                 | Nenda skrini nzima ndani ya dirisha              |
| `Super + 1/2/3/4`         | Ruka hadi nafasi maalum ya kazi kwenye monita iliyolengwa |
| `Super + Tab` | Ruka hadi nafasi ya kazi inayofuata kwenye monita iliyolengwa |
| `Super + Shift + Tab` | Ruka hadi nafasi ya kazi iliyopita kwenye monita iliyolengwa |
| `Super + Ctrl + Tab` | Ruka hadi nafasi ya kazi ya awali kwenye monita iliyolengwa |
| `Super + Shift + 1/2/3/4` | Hamisha dirisha hadi nafasi ya kazi kwenye monita iliyolengwa |
| `Super + Shift + Alt + 1/2/3/4` | Hamisha dirisha hadi nafasi ya kazi kwenye monita iliyolengwa bila kuifuata |
| `Super + S` | Geuza scratchpad kamili |
| `Super + Alt + S` | Hamisha dirisha hadi scratchpad kamili |
| `Super + Grave` | Geuza konsoli ya Quake |
| `Super + Shift + Grave` | Hamisha dirisha hadi konsoli ya Quake |
| `Super + Shift + Ctrl + Arrows` | Hamisha dirisha hadi monita iliyo upande huo |
| `Super + Shift + Alt + Arrows` | Hamisha nafasi ya kazi hadi monita iliyo upande huo |
| `Super + Arrow`  | Hamisha ulengaji hadi dirisha lililo upande wa mshale, ukivuka hadi monita iliyo upande huo kwenye ukingo wa skrini |
| `Super + Shift + Arrow`  | Badilishana dirisha na jingine lililo upande wa mshale, ikijumuisha lililo kwenye monita iliyo upande huo |
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
| `Super + Scroll Wheel` | Tembeza kupitia nafasi za kazi kwenye monita iliyolengwa |
| `Super + G`               | Geuza kikundi cha dirisha      |
| `Super + Alt + G`               | Hamisha dirisha kutoka kwenye kikundi      |
| `Super + Alt + Tab`               | Zunguka kati ya madirisha yaliyo kwenye kikundi      |
| `Super + Alt + Shift + Tab`               | Zunguka kwa nyuma kati ya madirisha yaliyo kwenye kikundi      |
| `Super + Alt + Scroll Wheel` | Zunguka kati ya madirisha yaliyo kwenye kikundi |
| `Super + Alt + 1/2/3/4/5`               | Ruka hadi dirisha maalum lililo kwenye kikundi      |
| `Super + Alt + Arrow`  | Hamisha dirisha hadi kwenye kikundi upande wa mshale, ikijumuisha lililo kwenye monita iliyo upande huo |
| `Super + Ctrl + Left/Right`  | Sogea kati ya madirisha ndani ya kikundi cha kupanga |
| `Super + Ctrl + Z` | Kuza skrini (rudia kwa kuza zaidi) |
| `Super + Ctrl + Alt + Z` | Punguza ukuzaji kabisa kutoka kwenye skrini |
| `Super + /` | Sogea mbele kupitia chaguo za upimaji wa monita |
| `Super + Alt + /` | Sogea nyuma kupitia chaguo za upimaji wa monita |
| `Alt + Tab` | Zunguka mbele kupitia madirisha kwenye nafasi ya kazi inayotumika |
| `Alt + Shift + Tab` | Zunguka kwa nyuma kupitia madirisha kwenye nafasi ya kazi inayotumika |
| `Ctrl + Alt + Tab`| Zunguka ulengaji mbele kupitia monita |
| `Ctrl + Alt + Shift + Tab`| Zunguka ulengaji kwa nyuma kupitia monita |

Vitufe vya mkato vya kubadilisha ukubwa hutumia vitufe halisi vya kimwili `code:20` na `code:21` (XKB `<AE11>` na `<AE12>`), bila kujali herufi zilizochapishwa kwenye kibodi. Kwenye kibodi za Marekani vitufe hivi ni `-` na `=`; kwenye kibodi za Kijapani (JIS) ni `-` na `^`; kwenye kibodi za Kihispania ni `'` na `¡`. Kwenye JIS, `Super + ^` ni `Super + Equal`, ilhali `Super + Shift + -` (inayoandika `=`) ni `Super + Shift + Minus`.

## Vidhibiti vya mfumo

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Paneli ya sauti    |
| `Super + Ctrl + B`           | Paneli ya Bluetooth    |
| `Super + Ctrl + N`           | Paneli ya Wifi/mtandao    |
| `Super + Ctrl + D`           | Paneli ya onyesho    |
| `Super + Ctrl + P`           | Paneli ya nishati    |
| `Super + Ctrl + X`           | Paneli ya mawakala    |
| `Super + Ctrl + Alt + D`           | Paneli ya kalenda    |
| `Super + Ctrl + Alt + E`           | Paneli ya saa ya dunia    |
| `Super + Ctrl + 1-9`           | Geuza paneli ya upau kulingana na nafasi    |
| `Super + Ctrl + S` | Menyu ya kushiriki (kupitia LocalSend) |
| `Super + Ctrl + C` | Vidhibiti vya kunasa (picha ya skrini/kurekodi/kichaguzi) |
| `Super + Ctrl + O` | Menyu ya kugeuza |
| `Super + Ctrl + H` | Menyu ya maunzi |
| `Super + Ctrl + E` | Kichaguzi cha emoji |
| `Super + Ctrl + .` | Badilisha msimbo wa media |
| `Super + Shift + Ctrl + A` | Chagua wakala wa AI |

## Marekebisho

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Mwangaza wa juu zaidi wa skrini |
| `Shift + Brightness Down` | Mwangaza wa chini zaidi wa skrini |
| `Alt + Brightness Up/Down` | Mabadiliko sahihi ya mwangaza ya 1% |
| `Alt + Volume Up/Down` | Mabadiliko sahihi ya sauti ya 1% |
| `Keyboard Brightness Up/Down` | Mwangaza wa nyuma wa kibodi ung'ae zaidi/upungue |
| `Keyboard Backlight` | Zunguka viwango vya mwangaza wa nyuma wa kibodi |
| `Alt + Play` | Wimbo unaofuata |
| `Alt + Shift + Play` | Wimbo uliopita |

## Kuzindua programu

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminali    |
| `Super + Alt + Return` | Terminali ya Tmux |
| `Super + Ctrl + Return` | Herdr (kidhibiti cha mawakala) |
| `Super + Shift + Return`           | Kivinjari    |
| `Super + Shift + Alt + B`           | Kivinjari (binafsi/incognito)    |
| `Super + Shift + F`           | Kidhibiti cha faili    |
| `Super + Shift + Alt + F`           | Kidhibiti cha faili katika cwd ya terminali    |
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
| `Super + Shift + G`           | Programu ya ujumbe (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Programu ya ujumbe (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Programu ya ujumbe (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Kuandika (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Badilisha/ongeza vifungo katika `~/.config/hypr/bindings.lua`.

## Ubao wa kunakili wa kila mahali

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + A`           | Chagua vyote katika programu zinazounga mkono `Ctrl + A`    |
| `Super + C`           | Nakili    |
| `Super + X`           | Kata (sio katika terminali)    |
| `Super + V`           | Bandika    |
| `Super + Ctrl + V`           | Kidhibiti cha ubao wa kunakili    |

Kwa kawaida kwenye Linux, unahitaji `Ctrl + Shift + C/V` kunakili na kubandika katika terminali na `Ctrl + C/V` kufanya hivyo kila mahali pengine. Vitufe hivi vya mkato vilivyounganishwa vya ubao wa kunakili vya Omarchy hufanya kazi kila mahali.

## Kunasa

| Kitufe cha mkato              | Kazi                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Picha ya skrini                      |
| `Super + Ctrl + Alt + C`            | Picha ya skrini (picha ile ile, kwa kibodi zisizo na kitufe cha Print Screen) |
| `Super + Ctrl + C` | Menyu ya kunasa |
| `Alt + Print Screen`            | Rekodi ya skrini                     |
| `Super + Print Screen` | Kichaguzi cha rangi |
| `Super + Ctrl + Print Screen` | Uchimbaji wa maandishi hadi kwenye ubao wa kunakili |
| `Super + Alt + [` | Fanya ufunikaji wa webcam kuwa mdogo zaidi wakati wa kurekodi |
| `Super + Alt + ]` | Fanya ufunikaji wa webcam kuwa mkubwa zaidi wakati wa kurekodi |
| `Alt + Shift + L` | Nakili URL ya sasa kutoka kwenye webapp au Chromium |
| `Alt + Shift + D` | Pakua video iliyo kwenye ukurasa wa sasa hadi `~/Videos` |
| `Alt + Space` | Anzisha/simamisha udiktaji (inahitaji _Usanidi > Chaguomsingi > Udiktaji_) |
| `Right Alt` | Shikilia ili kudikta (inahitaji _Usanidi > Chaguomsingi > Udiktaji_) |

Kwa rekodi za skrini, kitufe cha mkato kwanza huuliza sauti unayotaka, kisha huanza kurekodi. Kibonyeze tena kusimamisha. Tazama [picha za skrini na kurekodi](12-screenshots-recording.md) kwa maelezo.

Chaguo zote za kunasa pia zinapatikana chini ya _Kichochezi > Kunasa_ katika menyu ya Omarchy (`Super + Space`).

## Arifa

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + ,` | Tenda kwa arifa ya hivi punde zaidi: ifungue au bonyeza kitufe chake pekee, chagua kutoka kwenye chaguo zake, au iondoe inapokuwa haina chochote  |
| `Super + Shift + ,` | Ondoa arifa zote |
| `Super + Ctrl + ,` | Dhibiti arifa kwa kibodi  |
| `Super + Alt + ,` | Ondoa arifa ya hivi punde zaidi  |
| `Super + Shift + Alt + ,` | Fungua historia ya arifa  |
| `Super + Ctrl + Alt + ,` | Geuza kunyamazisha arifa  |

## Mtindo

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Chagua mandhari mpya (pia `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Chagua mandharinyuma ya mandhari (pia `Super + Ctrl + Space`) |
| `Super + Backspace` | Geuza uwazi kwenye dirisha |
| `Super + Ctrl + Backspace` | Geuza kipengele cha mraba cha dirisha moja |

Picha za ziada za mandharinyuma ziko katika `~/.config/omarchy/backgrounds/<theme name>`. Pia zinapatikana kupitia _Sakinisha > Mtindo > Mandharinyuma_ katika menyu ya Omarchy.

Chaguo zote za mtindo pia zinapatikana chini ya _Mtindo_ katika menyu ya Omarchy (`Super + Space`).

## Vigeuza

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Geuza kufunga wakati hautumiki |
| `Super + Ctrl + Delete` | Geuza onyesho la laptop kuwasha/kuzima |
| `Super + Ctrl + Alt + Delete` | Geuza uakisi wa onyesho la laptop |
| `Super + Shift + Space` | Geuza upau wa juu  |
| `Shift + Mute` | Badilisha hadi utokaji wa sauti unaofuata |
| `Shift + Play` | Badilisha hadi chanzo cha media kinachofuata |
| `Super + Shift + Backspace` | Geuza mapengo ya madirisha |
| `Super + Ctrl + Alt + F` | Geuza eneo-kazi la skrini nzima (upau wa juu + mapengo ya madirisha) |

## Vikumbusho

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Weka kikumbusho  |
| `Super + Ctrl + Alt + R` | Tazama vikumbusho vyote  |
| `Super + Ctrl + Shift + R` | Futa vikumbusho vyote  |

## Ilani

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Onyesha muda kama arifa  |
| `Super + Ctrl + Alt + B` | Onyesha betri kama arifa  |
| `Super + Ctrl + Alt + W` | Geuza hali ya hewa kama arifa  |

## Tmux

Kitufe cha kiambishi awali ni `Ctrl + Space` (`Ctrl + B` pia hufanya kazi). Unaweza kubadilisha vifungo hivi katika `~/.config/tmux/tmux.conf`.

### Paneli

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Prefix + v` | Gawanya paneli kando (wima) |
| `Prefix + h` | Gawanya paneli chini (mlalo) |
| `Prefix + x` | Ua paneli |
| `Prefix + z` | Geuza ukuzaji wa paneli (skrini nzima) |
| `Alt + Enter` | Gawanya paneli chini (bila kiambishi awali) |
| `Alt + Shift + Enter` | Gawanya paneli kando (bila kiambishi awali) |
| `Alt + Escape` | Ua paneli (bila kiambishi awali) |
| `Ctrl + Alt + Arrows` | Sogea kati ya paneli |
| `Ctrl + Alt + Shift + Arrows` | Badilisha ukubwa wa paneli |

### Madirisha

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Prefix + c` | Dirisha jipya |
| `Prefix + k` | Ua dirisha |
| `Prefix + r` | Badilisha jina la dirisha |
| `Alt + 1-9` | Nenda hadi dirisha maalum |
| `Alt + Arrow Left/Right` | Sogea kati ya madirisha |
| `Alt + Shift + Arrow Left/Right` | Hamisha dirisha kushoto/kulia |

### Vipindi

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Prefix + C` | Kipindi kipya |
| `Prefix + K` | Ua kipindi |
| `Prefix + R` | Badilisha jina la kipindi |
| `Prefix + N` | Kipindi kinachofuata |
| `Prefix + P` | Kipindi kilichopita |
| `Alt + Arrow Up/Down` | Sogea kati ya vipindi |
| `Prefix + s` | Orodhesha vipindi |
| `Prefix + d` | Jitenge kutoka kwenye kipindi |

### Hali ya kunakili (mtindo wa vi)

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Prefix + [` | Ingia hali ya kunakili |
| `v` | Anza uteuzi (katika hali ya kunakili) |
| `y` | Nakili uteuzi (katika hali ya kunakili) |

### Ya jumla

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Prefix + q` | Pakia upya usanidi |
| `Prefix + ?` | Onyesha vifungo vya vitufe vya Tmux |
| `Prefix + :` | Kidokezo cha amri |

### Vitendakazi vya mpangilio wa Tmux

Vitendakazi hivi lazima viendeshwe ndani ya kipindi cha Tmux.

| Amri | Kazi |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Unda mpangilio wa dev wenye kihariri, AI, na terminali |
| `tdlm <ai> [<second_ai>]` | Unda mpangilio wa dev kwa kila saraka ndogo |
| `tsl <count> <command>` | Unda mpangilio wa swarm wenye paneli nyingi |

## Terminali ya Ghostty

Terminali ya Ghostty husakinishwa kwa kutumia _Sakinisha > Terminali_ kupitia menyu ya Omarchy.

| Kitufe cha mkato                  | Kazi              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Mgawanyiko mpya chini |
| `Ctrl + Shift + O` | Mgawanyiko mpya kando |
| `Ctrl + Alt + Arrows` | Sogea kati ya migawanyiko |
| `Super + Ctrl + Shift + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 10 |
| `Super + Ctrl + Shift + Alt + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 100 |
| `Ctrl + Shift + T` | Kichupo kipya  |
| `Ctrl + Shift + Arrows` | Sogea kati ya vichupo |
| `Alt + Numbers` | Nenda hadi kichupo maalum |
| `Shift + Pg Up/Down` | Tembeza historia |
| `Ctrl + Left mouse` | Fungua kiungo katika kivinjari |

## Kidhibiti cha Faili

| Kitufe cha mkato              | Kazi                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Nenda hadi njia                     |
| `Space`               | Hakiki faili (mishale husogeza) |
| `Alt + Up`       | Nenda juu hadi folda mama        |

## Neovim (na lazyvim)

### Urambazaji

| Kitufe cha mkato                   | Kazi                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Onyesha chaguo za amri            |
| `Space Space`              | Fungua faili kupitia utafutaji wa fuzzy      |
| `Space E`                  | Geuza upau wa kando                  |
| `Space G G`                | Onyesha vidhibiti vya git               |
| `Space S G`                | Tafuta maudhui ya faili             |
| `Ctrl + W W`               | Ruka kati ya upau wa kando na kihariri |
| `Ctrl + Left/right arrow`  | Badilisha ukubwa wa upau wa kando          |
| `Shift + H`                      | Nenda hadi kichupo cha faili cha kushoto             |
| `Shift + L`                      | Nenda hadi kichupo cha faili cha kulia            |
| `Space B D`                | Funga kichupo cha faili                  |

### Ukiwa katika upau wa kando

| Kitufe cha mkato                   | Kazi                        |
| ------------------------ | ------------------------------- |
| `A`                        | Ongeza faili mpya katika saraka mama      |
| `Shift + A`                | Ongeza saraka ndogo mpya katika saraka mama    |
| `D`                        | Futa faili/saraka iliyoangaziwa     |
| `M`                        | Hamisha faili/saraka iliyoangaziwa       |
| `R`                        | Badilisha jina la faili/saraka iliyoangaziwa     |
| `?`                        | Onyesha msaada kwa amri zote      |

[Tazama vitufe vyote vya mkato vya Neovim vilivyosanidiwa na LazyVim](https://www.lazyvim.org/keymaps).

## Emoji za Haraka

Unaweza kutumia `Super + Ctrl + E` kuonyesha kichaguzi kamili cha emoji kitakachoweka uteuzi kwenye ubao wa kunakili au unaweza kutumia chaguo hizi za ufikiaji wa haraka.

| Kitufe cha mkato       | EM | Kidokezo       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | tabasamu      |
| `Shift + CapsLock M C` | 😂 | lia        |
| `Shift + CapsLock M L` | 😍 | upendo       |
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
| `Shift + CapsLock M D` | 🤤 | dondosha mate      |
| `Shift + CapsLock M M` | 💰 | pesa      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | salamu |
| `Shift + CapsLock M A` |💪 | mkono |
| `Shift + CapsLock M B` |🤯 | kupuliza |

## Ukamilishaji wa Haraka

| Kitufe cha mkato       | Ukamilishaji       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Jina lako (kama lilivyoingizwa wakati wa usanidi)  |
| `Shift + CapsLock Space E` | Barua pepe yako (kama ilivyoingizwa wakati wa usanidi)  |

Unaweza kuongeza zaidi yako mwenyewe kwa kuhariri `~/.XCompose`, kisha kuendesha `omarchy-restart-xcompose` katika terminali ili mabadiliko yachukuliwe.
