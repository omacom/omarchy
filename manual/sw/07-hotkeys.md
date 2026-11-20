# Mikato ya Kibodi

Unaweza kuona vifungo vikuu vyote vya kibodi kwa `Super + K` (vifungo vya Tmux kwa `Super + Alt + K` na vifungo vya Herdr kwa `Super + Ctrl + K`).

## Jinsi mikato ya kibodi ilivyopangwa

Kila mkato wa kibodi umekaa kwenye ngazi, iliyowekwa na virekebishaji vyake, na kila ngazi ina kazi moja. Hilo ndilo linalozuia mikato ya kibodi kuchanganyikiana, na inamaanisha kwa kawaida unaweza kukisia kitu kinapatikana wapi.

| Ngazi | Kinachopatikana hapo | Mifano |
| --- | --- | --- |
| `Super + key` | Mfumo: madirisha, maeneo ya kazi, mipangilio, na menyu za msingi | `Super + Space` menyu ya Omarchy, `Super + W` funga dirisha, `Super + F` skrini nzima |
| `Super + Shift + key` | Programu | `Super + Shift + B` kivinjari, `Super + Shift + E` barua pepe, `Super + Shift + N` kihariri |
| `Super + Ctrl + key` | Paneli na menyu za mfumo | `Super + Ctrl + A` sauti, `Super + Ctrl + N` mtandao, `Super + Ctrl + C` menyu ya kunasa |
| `Super + Ctrl + Alt + key` | Vitendo vya haraka na taarifa | `Super + Ctrl + Alt + T` onyesha saa, `Super + Ctrl + Alt + B` betri, `Super + Ctrl + Alt + C` picha ya skrini |

Kuongeza `Alt` kwenye mkato wa kibodi hukupa lahaja ya kitu kile kile, kamwe si kitu kisichohusiana:

- `Super + Shift + B` hufungua kivinjari; `Super + Shift + Alt + B` hufungua dirisha la binafsi
- `Super + Shift + E` hufungua barua pepe; `Super + Shift + Alt + E` huanzisha mpya
- `Super + F` huenda skrini nzima; `Super + Alt + F` huenda upana mzima
- `Super + Ctrl + C` hufungua menyu ya kunasa; `Super + Ctrl + Alt + C` huruka menyu na kuchukua picha ya skrini

Wakati wa kuongeza mkato wa kibodi:

1. Chagua ngazi kutokana na kile inachofanya, kisha chagua kitufe.
2. Usihamishe mkato wa kibodi uliopo ili kupata nafasi. Tafuta kitufe kilicho wazi kwenye ngazi sahihi.
3. Tumia `Alt` tu kwa lahaja ya mkato wa kibodi usio nayo.

Mikato michache ya kibodi huvunja sheria hizi kwa sababu ni rahisi kutumia. `Shift` pamoja na mshale au `Tab` husogeza au hurudisha nyuma badala ya kufungua programu, na `Print`, vitufe vya media, `Alt + Tab`, na `Ctrl + Alt + Del` hufanya kazi kama zinavyofanya kila mahali pengine. Ni vighairi, si mifumo ya kuiga.

Ikiwa chaguomsingi haikufai (tuseme unataka `Super + Shift + S` kwa picha za skrini kama kwenye Windows), ibadilishe katika `~/.config/hypr/bindings.lua`.

## Kupita

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Super + Space` | Menyu ya Omarchy (programu na kila kitu kingine) |
| `Super + Alt + Space` | Gridi ya programu |
| `Super + Escape` | Menyu ya mfumo (simamisha kwa muda, anzisha upya, n.k.) |
| `Super + Ctrl + L` | Funga kompyuta |
| `Super + W` au `Super + Q` | Funga dirisha |
| `Ctrl + Alt + Del` | Funga madirisha yote |
| `Super + K` | Onyesha mikato yote ya kibodi |
| `Super + Alt + K` | Onyesha mikato ya kibodi ya tmux |
| `Super + Ctrl + K` | Onyesha mikato ya kibodi ya herdr |
| `Super + M` | Punguza dirisha hadi kwenye doki |
| `Super + T` | Geuza dirisha kati ya tiling/floating |
| `Super + J` | Geuza nafasi ya dirisha (mlalo/wima) |
| `Super + O` | Geuza dirisha kuwa la kunata na kuelea linalojitokeza |
| `Super + L` | Zunguka kati ya mipangilio ya dwindle, scrolling, na floating |
| `Super + Alt + L` | Zunguka kati ya mipangilio kwa mwelekeo wa kinyume |
| `Super + P` | Geuza mtindo wa dirisha bandia (asili dhidi ya kunyoosha) |
| `Super + F` | Nenda skrini nzima |
| `Super + Alt + F` | Nenda upana mzima |
| `Super + Ctrl + F` | Nenda skrini nzima ndani ya dirisha |
| `Super + 1…9/0` | Ruka hadi eneo mahususi la kazi (0 ni 10) kwenye kifuatiliaji kilicholengwa |
| `Super + Tab` | Ruka hadi eneo la kazi linalofuata kwenye kifuatiliaji kilicholengwa |
| `Super + Shift + Tab` | Ruka hadi eneo la kazi lililotangulia kwenye kifuatiliaji kilicholengwa |
| `Super + Ctrl + Tab` | Ruka hadi eneo la kazi la awali kwenye kifuatiliaji kilicholengwa |
| `Super + Shift + 1…9/0` | Hamisha dirisha hadi eneo la kazi kwenye kifuatiliaji kilicholengwa |
| `Super + Shift + Alt + 1…9/0` | Hamisha dirisha hadi eneo la kazi kwenye kifuatiliaji kilicholengwa bila kulifuata |
| `Super + S` | Geuza scratchpad nzima |
| `Super + Alt + S` | Hamisha dirisha hadi scratchpad nzima |
| `Super + Grave` | Geuza konsoli ya Quake |
| `Super + Shift + Grave` | Hamisha dirisha hadi konsoli ya Quake |
| `Super + Shift + Ctrl + Arrows` | Hamisha dirisha hadi kifuatiliaji kilicho katika mwelekeo huo |
| `Super + Shift + Alt + Arrows` | Hamisha eneo la kazi hadi kifuatiliaji kilicho katika mwelekeo huo |
| `Super + Arrow` | Sogeza mwelekeo wa umakini hadi dirisha lililo katika mwelekeo wa mshale, ukivuka hadi kifuatiliaji kilicho upande huo kwenye ukingo wa skrini |
| `Super + Shift + Arrow` | Badilishana dirisha na jingine lililo katika mwelekeo wa mshale, ikiwa ni pamoja na lililo kwenye kifuatiliaji kilicho upande huo |
| `Super + Minus` | Panua dirisha kushoto |
| `Super + Equal` | Punguza dirisha kushoto |
| `Super + Shift + Minus` | Punguza dirisha juu |
| `Super + Shift + Equal` | Panua dirisha chini |
| `Super + Alt + Minus/Equal` | Kubadilisha ukubwa kuko huko kwa hatua ndogo zaidi |
| `Super + Ctrl + Minus/Equal` | Kubadilisha ukubwa kuko huko kwa hatua kubwa zaidi |
| `Super + Alt + Home` | Hifadhi upana wa dirisha |
| `Super + Home` | Rejesha upana wa dirisha uliohifadhiwa |
| `Super + Left Mouse` | Buruta dirisha huku na huku |
| `Super + Right Mouse` | Badilisha ukubwa wa dirisha |
| `Super + Scroll Wheel` | Pitia maeneo ya kazi kwenye kifuatiliaji kilicholengwa |
| `Super + G` | Geuza upanganaji wa madirisha kwa vikundi |
| `Super + Alt + G` | Toa dirisha kutoka kwenye kikundi |
| `Super + Alt + Tab` | Zunguka kati ya madirisha yaliyo katika kikundi |
| `Super + Alt + Shift + Tab` | Zunguka kinyume kati ya madirisha yaliyo katika kikundi |
| `Super + Alt + Scroll Wheel` | Zunguka kati ya madirisha yaliyo katika kikundi |
| `Super + Alt + 1/2/3/4/5` | Ruka hadi dirisha mahususi katika kikundi |
| `Super + Alt + Arrow` | Ingiza dirisha katika kikundi katika mwelekeo wa mshale, ikiwa ni pamoja na lililo kwenye kifuatiliaji kilicho upande huo |
| `Super + Ctrl + Left/Right` | Sogea kati ya madirisha ndani ya kikundi cha tiling |
| `Super + Ctrl + Z` | Kuza skrini (rudia kwa ukuzaji zaidi) |
| `Super + Ctrl + Alt + Z` | Punguza ukuzaji wa skrini kabisa |
| `Super + /` | Songa mbele kupitia chaguo za upimaji wa kifuatiliaji |
| `Super + Alt + /` | Songa nyuma kupitia chaguo za upimaji wa kifuatiliaji |
| `Alt + Tab` | Zunguka mbele kupitia madirisha kwenye eneo la kazi linalotumika |
| `Alt + Shift + Tab` | Zunguka kinyume kupitia madirisha kwenye eneo la kazi linalotumika |
| `Ctrl + Alt + Tab` | Zunguka mwelekeo wa umakini mbele kupitia vifuatiliaji |
| `Ctrl + Alt + Shift + Tab` | Zunguka mwelekeo wa umakini kinyume kupitia vifuatiliaji |
| `Super + I` | Badilisha lugha ya uingizaji (ukiwa na mpangilio au mbinu ya uingizaji zaidi ya moja) |
| `Super + Shift + I` | Badilisha lugha ya uingizaji kurudi |

Kwenye padi ya mguso, miotelezo ya vidole vitatu na vinne hubadilisha maeneo ya kazi, husogeza madirisha, na hufungua menyu na konsoli ya Quake; tazama [kibodi, kipanya, na padi ya mguso](34-keyboard-mouse-trackpad.md) kwa ishara hizo.

Mikato ya kubadilisha ukubwa hutumia vitufe halisi `code:20` na `code:21` (XKB `<AE11>` na `<AE12>`), bila kujali herufi zilizochapishwa kwenye kibodi. Kwenye kibodi za US vitufe hivi ni `-` na `=`; kwenye kibodi za Kijapani (JIS) ni `-` na `^`; kwenye kibodi za Kihispania ni `'` na `¡`. Kwenye JIS, `Super + ^` ni `Super + Equal`, ilhali `Super + Shift + -` (ambayo huchapa `=`) ni `Super + Shift + Minus`.

## Vidhibiti vya mfumo

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Paneli ya sauti |
| `Super + Ctrl + B` | Paneli ya Bluetooth |
| `Super + Ctrl + N` | Paneli ya Wifi/mtandao |
| `Super + Ctrl + D` | Paneli ya onyesho |
| `Super + Ctrl + P` | Paneli ya nishati |
| `Super + Ctrl + X` | Paneli ya Agents |
| `Super + Ctrl + Alt + D` | Paneli ya kalenda |
| `Super + Ctrl + Alt + E` | Paneli ya saa ya dunia |
| `Super + Ctrl + 1-9` | Geuza paneli ya upau kulingana na nafasi |
| `Super + Ctrl + S` | Menyu ya kushiriki (kupitia LocalSend) |
| `Super + Ctrl + C` | Vidhibiti vya kunasa (picha ya skrini/-kurekodi/kichaguzi) |
| `Super + Ctrl + O` | Geuza menyu |
| `Super + Ctrl + H` | Menyu ya vifaa |
| `Super + Ctrl + E` | Kichaguzi cha emoji |
| `Super + Ctrl + .` | Badilisha umbizo la media |
| `Super + Shift + Ctrl + A` | Chagua wakala wa AI |
| `Power` key | Menyu ya mfumo |
| `Super + Shift + Copilot` key | Menyu ya Omarchy |

## Marekebisho

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Mwangaza wa juu zaidi wa skrini |
| `Shift + Brightness Down` | Mwangaza wa chini zaidi wa skrini |
| `Alt + Brightness Up/Down` | Mabadiliko sahihi ya mwangaza ya 1% |
| `Alt + Volume Up/Down` | Mabadiliko sahihi ya sauti ya 1% |
| `Keyboard Brightness Up/Down` | Mwangaza wa nyuma wa kibodi uwe mkali zaidi/mdogo zaidi |
| `Keyboard Backlight` | Zunguka viwango vya mwangaza wa nyuma wa kibodi |
| `Ctrl + Brightness Up/Down` | Mwangaza wa nyuma wa kibodi uwe mkali zaidi/mdogo zaidi, kwenye kibodi zisizo na vitufe vyao vyenyewe |
| `Mic Mute` | Nyamazisha maikrofoni |
| `Shift + Mute` | Badilisha kifaa cha kutoa sauti |
| `Touchpad Toggle` | Washa au zima padi ya mguso |
| `Display` key | Zunguka mpangilio wa eneo la kazi |
| `Alt + Play` | Wimbo unaofuata |
| `Alt + Shift + Play` | Wimbo uliotangulia |

## Kuzindua programu

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Terminal ya Tmux |
| `Super + Ctrl + Return` | Herdr (kidhibiti cha mawakala) |
| `Super + Shift + Return` au `Super + Shift + B` | Kivinjari |
| `Super + Shift + Alt + B` | Kivinjari (binafsi/incognito) |
| `Super + Shift + F` | Kidhibiti cha faili |
| `Super + Shift + Alt + F` | Kidhibiti cha faili katika cwd ya terminal |
| `Super + Shift + M` | Muziki (Spotify) |
| `Super + Shift + Alt + M` | Muziki (cliamp) |
| `Super + Shift + /` | Kidhibiti cha manenosiri (1password) |
| `Super + Shift + Q` au `Calculator` key | Kikokotoo (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, baada ya kusakinishwa) |
| `Super + Shift + T` | Shughuli (btop) |
| `Super + Shift + N` | Kihariri (Plain, au chaguomsingi ulichochagua) |
| `Super + Shift + C` | Kalenda ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Barua pepe ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Barua pepe mpya ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Kutuma ujumbe (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Kutuma ujumbe (WhatsApp) |
| `Super + Shift + Ctrl + G` | Kutuma ujumbe (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Kuandika (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (chapisho jipya) |
| `Super + Shift + Y` | YouTube |

Badilisha/ongeza vifungo katika `~/.config/hypr/bindings.lua`.

## Ubao wa kunakili unaotumika kila mahali

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Super + A` | Chagua vyote katika programu zinazotumia `Ctrl + A` |
| `Super + C` | Nakili |
| `Super + X` | Kata (si katika terminal) |
| `Super + V` | Bandika |
| `Super + Ctrl + V` | Kidhibiti cha ubao wa kunakili |

Kwa kawaida kwenye Linux, unahitaji `Ctrl + Shift + C/V` ili kunakili na kubandika katika terminal na `Ctrl + C/V` ili kufanya hivyo kila mahali pengine. Mikato hii ya Omarchy ya ubao wa kunakili iliyounganishwa hufanya kazi kila mahali.

## Kunasa

| Mkato wa Kibodi | Kazi |
| ------------------- | ------------------------------ |
| `Print Screen` | Picha ya skrini |
| `Super + Ctrl + Alt + C` | Picha ya skrini (picha hiyo hiyo, kwa kibodi zisizo na kitufe cha Print Screen) |
| `Super + Ctrl + C` | Menyu ya kunasa |
| `Alt + Print Screen` | Rekodi skrini |
| `Super + Shift + Ctrl + Alt + C` | Rekodi skrini bila sauti, ukiruka menyu (ibonyeze tena ili kusitisha) |
| `Super + Print Screen` | Kichaguzi cha rangi |
| `Super + Ctrl + Print Screen` | Uchimbaji wa maandishi hadi kwenye ubao wa kunakili |
| `Super + Alt + [` | Fanya ufunikaji wa kamera ya wavuti uwe mdogo zaidi wakati wa kurekodi |
| `Super + Alt + ]` | Fanya ufunikaji wa kamera ya wavuti uwe mkubwa zaidi wakati wa kurekodi |
| `Alt + Shift + L` | Nakili URL ya sasa kutoka kwenye programu ya wavuti au kivinjari |
| `Alt + Shift + D` | Pakua video iliyo kwenye ukurasa wa sasa hadi `~/Videos` |
| `Alt + Space` | Anzisha/sitisha uandikaji kwa sauti (inahitaji _Usanidi > Chaguomsingi > Uandikaji kwa Sauti_) |
| `Right Alt` | Shikilia ili kuandikisha kwa sauti (inahitaji _Usanidi > Chaguomsingi > Uandikaji kwa Sauti_) |

Ukiwa na rekodi za skrini, mkato wa kibodi huuliza kwanza sauti unayotaka, kisha huanza kurekodi. Ubonyeze tena ili kusitisha. Tazama [picha za skrini na kurekodi](12-screenshots-recording.md) kwa maelezo.

Chaguo zote za kunasa zinapatikana pia chini ya _Kichocheo > Kunasa_ katika menyu ya Omarchy (`Super + Space`).

## Taarifa

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Super + ,` | Tenda kwenye taarifa ya hivi karibuni zaidi: ifungue au bonyeza kitufe chake pekee, chagua kutoka kwenye chaguo zake, au iondoe ikiwa haina chochote |
| `Super + Shift + ,` | Ondoa taarifa zote |
| `Super + Ctrl + ,` | Dhibiti taarifa kwa kibodi |
| `Super + Alt + ,` | Ondoa taarifa ya hivi karibuni zaidi |
| `Super + Shift + Alt + ,` | Fungua historia ya taarifa |
| `Super + Ctrl + Alt + ,` | Geuza kunyamazisha taarifa |

## Mtindo

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Chagua mandhari mpya (pia `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Chagua mandharinyuma ya mandhari (pia `Super + Ctrl + Space`) |
| `Super + Backspace` | Geuza uwazi kwenye dirisha |
| `Super + Ctrl + Backspace` | Geuza uwiano wa mraba wa dirisha moja |

Picha za ziada za mandharinyuma zinapatikana katika `~/.config/omarchy/backgrounds/<theme name>`. Zinapatikana pia kupitia _Sakinisha > Mtindo > Mandharinyuma_ katika menyu ya Omarchy.

Chaguo zote za mtindo zinapatikana pia chini ya _Muonekano_ katika menyu ya Omarchy (`Super + Space`).

## Vigeuzo

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Geuza kufunga wakati wa kutofanya kazi |
| `Super + Ctrl + Delete` | Geuza onyesho la laptop kuwasha/kuzima |
| `Super + Ctrl + Alt + Delete` | Geuza uakisi wa onyesho la laptop |
| `Super + Shift + Space` | Geuza upau wa juu |
| `Shift + Mute` | Badilisha hadi kifaa kinachofuata cha kutoa sauti |
| `Shift + Play` | Badilisha hadi chanzo kinachofuata cha media |
| `Super + Shift + Backspace` | Geuza mapengo ya madirisha |
| `Super + Ctrl + Alt + F` | Geuza eneo-kazi la skrini nzima (upau wa juu + mapengo ya madirisha) |

## Vikumbusho

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Weka kikumbusho |
| `Super + Ctrl + Alt + R` | Tazama vikumbusho vyote |
| `Super + Ctrl + Shift + R` | Futa vikumbusho vyote |

## Taarifa maalum

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Onyesha saa kama taarifa |
| `Super + Ctrl + Alt + B` | Onyesha betri kama taarifa |
| `Super + Ctrl + Alt + W` | Geuza hali ya hewa kama taarifa |

## Tmux

Kitufe cha kiambishi awali ni `Ctrl + Space` (`Ctrl + B` pia hufanya kazi). Unaweza kubadilisha vifungo hivi katika `~/.config/tmux/tmux.conf`.

### Paneli

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Prefix + v` | Gawa paneli kando (wima) |
| `Prefix + h` | Gawa paneli chini (mlalo) |
| `Prefix + x` | Ondoa paneli |
| `Prefix + z` | Geuza ukuzaji wa paneli (skrini nzima) |
| `Alt + Enter` | Gawa paneli chini (hakuna kiambishi awali) |
| `Alt + Shift + Enter` | Gawa paneli kando (hakuna kiambishi awali) |
| `Alt + Escape` | Ondoa paneli (hakuna kiambishi awali) |
| `Ctrl + Alt + Arrows` | Sogea kati ya paneli |
| `Ctrl + Alt + Shift + Arrows` | Badilisha ukubwa wa paneli |

### Madirisha

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Prefix + c` | Dirisha jipya |
| `Prefix + k` | Ondoa dirisha |
| `Prefix + r` | Badilisha jina la dirisha |
| `Alt + 1-9` | Nenda kwenye dirisha mahususi |
| `Alt + Arrow Left/Right` | Sogea kati ya madirisha |
| `Alt + Shift + Arrow Left/Right` | Sogeza dirisha kushoto/kulia |

### Vipindi

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Prefix + C` | Kipindi kipya |
| `Prefix + K` | Ondoa kipindi |
| `Prefix + R` | Badilisha jina la kipindi |
| `Prefix + N` | Kipindi kinachofuata |
| `Prefix + P` | Kipindi kilichotangulia |
| `Alt + Arrow Up/Down` | Sogea kati ya vipindi |
| `Prefix + s` | Orodhesha vipindi |
| `Prefix + d` | Jitenge na kipindi |

### Hali ya kunakili (mtindo wa vi)

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Prefix + [` | Ingia hali ya kunakili |
| `v` | Anza uteuzi (katika hali ya kunakili) |
| `y` | Nakili uteuzi (katika hali ya kunakili) |

### Jumla

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Prefix + q` | Pakia upya usanidi |
| `Prefix + ?` | Onyesha vifungo vya vitufe vya Tmux |
| `Prefix + :` | Kianzio cha amri |

### Vitendakazi vya mpangilio wa Tmux

Vitendakazi hivi lazima viendeshwe ndani ya kipindi cha Tmux.

| Amri | Kazi |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Unda mpangilio wa uendelezaji wenye kihariri, AI, na terminal |
| `tdlm <ai> [<second_ai>]` | Unda mpangilio wa uendelezaji kwa kila saraka ndogo |
| `tsl <count> <command>` | Unda mpangilio wa swarm wenye paneli nyingi |

## Ghostty Terminal

Terminal ya Ghostty husakinishwa kwa kutumia _Sakinisha > Terminal_ kupitia menyu ya Omarchy.

| Mkato wa Kibodi | Kazi |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Mgawanyiko mpya chini |
| `Ctrl + Shift + O` | Mgawanyiko mpya kando |
| `Ctrl + Alt + Arrows` | Sogea kati ya migawanyiko |
| `Super + Ctrl + Shift + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 10 |
| `Super + Ctrl + Shift + Alt + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 100 |
| `Ctrl + Shift + T` | Kichupo kipya |
| `Ctrl + Shift + Arrows` | Sogea kati ya vichupo |
| `Alt + Numbers` | Nenda kwenye kichupo mahususi |
| `Shift + Pg Up/Down` | Pitia historia |
| `Ctrl + Left mouse` | Fungua kiungo katika kivinjari |

## Kidhibiti cha Faili

| Mkato wa Kibodi | Kazi |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Nenda kwenye njia |
| `Space` | Hakiki faili (mishale hupitia) |
| `Alt + Up` | Nenda juu hadi folda kuu |

## Neovim (na lazyvim)

### Urambazaji

| Mkato wa Kibodi | Kazi |
| ------------------------ | ------------------------------- |
| `Space` | Onyesha chaguo za amri |
| `Space Space` | Fungua faili kupitia utafutaji wa fuzzy |
| `Space E` | Geuza upau wa kando |
| `Space G G` | Onyesha vidhibiti vya git |
| `Space S G` | Tafuta maudhui ya faili |
| `Ctrl + W W` | Ruka kati ya upau wa kando na kihariri |
| `Ctrl + Left/right arrow` | Badilisha ukubwa wa upau wa kando |
| `Shift + H` | Nenda kwenye kichupo cha faili cha kushoto |
| `Shift + L` | Nenda kwenye kichupo cha faili cha kulia |
| `Space B D` | Funga kichupo cha faili |

### Ukiwa katika upau wa kando

| Mkato wa Kibodi | Kazi |
| ------------------------ | ------------------------------- |
| `A` | Ongeza faili mpya katika saraka kuu |
| `Shift + A` | Ongeza saraka ndogo mpya katika saraka kuu |
| `D` | Futa faili/saraka iliyoangaziwa |
| `M` | Sogeza faili/saraka iliyoangaziwa |
| `R` | Badilisha jina la faili/saraka iliyoangaziwa |
| `?` | Onyesha usaidizi kwa amri zote |

[Tazama mikato yote ya kibodi ya Neovim iliyosanidiwa na LazyVim](https://www.lazyvim.org/keymaps).

## Emoji za Haraka

Unaweza kutumia `Super + Ctrl + E` kuonyesha kichaguzi kamili cha emoji ambacho kitaweka uteuzi kwenye ubao wa kunakili au unaweza kutumia chaguo hizi za ufikiaji wa haraka.

| Mkato wa Kibodi | EM | Kidokezo |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | tabasamu |
| `Shift + CapsLock M C` | 😂 | kilio |
| `Shift + CapsLock M L` | 😍 | upendo |
| `Shift + CapsLock M V` | ✌️ | ushindi |
| `Shift + CapsLock M H` | ❤️ | moyo |
| `Shift + CapsLock M Y` | 👍 | ndiyo |
| `Shift + CapsLock M N` | 👎 | hapana |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | tamanio |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | busu |
| `Shift + CapsLock M E` | 🙄 | kuzungusha macho |
| `Shift + CapsLock M I` | 😉 | kukonyeza |
| `Shift + CapsLock M P` | 🙏 | kuomba |
| `Shift + CapsLock M D` | 🤤 | kudondosha mate |
| `Shift + CapsLock M M` | 💰 | pesa |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | toast |
| `Shift + CapsLock M O` |👌 | sawa |
| `Shift + CapsLock M G` |👋 | salamu |
| `Shift + CapsLock M A` |💪 | mkono |
| `Shift + CapsLock M B` |🤯 | kupuliza |

## Ukamilishaji wa Haraka

| Mkato wa Kibodi | Ukamilishaji |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (dashi ndefu) |
| `Shift + CapsLock Space N` | Jina lako (kama lilivyoingizwa wakati wa usanidi) |
| `Shift + CapsLock Space E` | Barua pepe yako (kama ilivyoingizwa wakati wa usanidi) |

Unaweza kuongeza zaidi yako mwenyewe kwa kuhariri `~/.XCompose`, kisha kuendesha `omarchy restart xcompose` katika terminal ili mabadiliko yatambuliwe.
