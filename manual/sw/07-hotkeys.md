# Vitufe vya Mkato

Unaweza kuona vifungo vyote vikuu vya kibodi kwa `Super + K` (vifungo vya Tmux kwa `Super + Alt + K` na vifungo vya Herdr kwa `Super + Ctrl + K`).

## Jinsi vitufe vya mkato vilivyopangwa

Kila kitufe cha mkato kiko kwenye safu, inayowekwa na vibadilishi vyake, na kila safu ina kazi moja. Hiyo ndiyo inayozuia vitufe vya mkato kuchanganyikana, na inamaanisha kwa kawaida unaweza kukisia kitu kiko wapi.

| Safu | Kile kinachoishi hapo | Mifano |
| --- | --- | --- |
| `Super + key` | Mfumo: madirisha, maeneo ya kazi, mipangilio, na menyu za msingi | `Super + Space` menyu ya Omarchy, `Super + W` funga dirisha, `Super + F` skrini nzima |
| `Super + Shift + key` | Programu | `Super + Shift + B` kivinjari, `Super + Shift + E` barua pepe, `Super + Shift + N` kihariri |
| `Super + Ctrl + key` | Paneli na menyu za mfumo | `Super + Ctrl + A` sauti, `Super + Ctrl + N` mtandao, `Super + Ctrl + C` menyu ya kunasa |
| `Super + Ctrl + Alt + key` | Vitendo vya haraka na taarifa | `Super + Ctrl + Alt + T` onyesha muda, `Super + Ctrl + Alt + B` betri, `Super + Ctrl + Alt + C` picha ya skrini |

Kuongeza `Alt` kwenye kitufe cha mkato hukupa lahaja ya kitu kile kile, kamwe si kitu kisichohusiana:

- `Super + Shift + B` hufungua kivinjari; `Super + Shift + Alt + B` hufungua dirisha la faragha
- `Super + Shift + E` hufungua barua pepe; `Super + Shift + Alt + E` huanzisha mpya
- `Super + F` huenda skrini nzima; `Super + Alt + F` huenda upana kamili
- `Super + Ctrl + C` hufungua menyu ya kunasa; `Super + Ctrl + Alt + C` huruka menyu na kuchukua picha ya skrini

Unapoongeza kitufe cha mkato:

1. Chagua safu kutoka na kile kinachofanya, kisha chagua kitufe.
2. Usihamishe kitufe cha mkato kilichopo ili kupata nafasi. Tafuta kitufe kilicho wazi kwenye safu sahihi.
3. Tumia `Alt` pekee kwa lahaja ya kitufe cha mkato kisicho nayo.

Vitufe vichache vya mkato huvunja sheria hizi kwa sababu ni rahisi kutumia. `Shift` pamoja na mshale au `Tab` huhamisha au hubadilisha mwelekeo badala ya kufungua programu, na `Print`, vitufe vya media, `Alt + Tab`, na `Ctrl + Alt + Del` hufanya kazi jinsi zinavyofanya kila mahali pengine. Ni vighairi, si mifumo ya kuiga.

Ikiwa chaguo-msingi halikufai (tuseme unataka `Super + Shift + S` kwa picha za skrini kama kwenye Windows), libadilishe katika `~/.config/hypr/bindings.lua`.

## Kupitia

| Kitufe cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + Space` | Menyu ya Omarchy (programu na kila kitu kingine) |
| `Super + Alt + Space` | Gridi ya programu |
| `Super + Escape` | Menyu ya mfumo (sitisha, anzisha upya, n.k.) |
| `Super + Ctrl + L` | Funga kompyuta |
| `Super + W` or `Super + Q` | Funga dirisha |
| `Ctrl + Alt + Del` | Funga madirisha yote |
| `Super + K` | Onyesha vitufe vyote vya mkato |
| `Super + Alt + K` | Onyesha vitufe vya mkato vya tmux |
| `Super + Ctrl + K` | Onyesha vitufe vya mkato vya herdr |
| `Super + M` | Punguza dirisha hadi kwenye doki |
| `Super + T` | Geuza dirisha kati ya mpangilio wa vigae na kuelea |
| `Super + J` | Geuza nafasi ya dirisha (mlalo/wima) |
| `Super + O` | Geuza dirisha linalojitokeza kuwa linalonata na kuelea |
| `Super + L` | Pitia mipangilio ya dwindle, scrolling, na floating kwa mzunguko |
| `Super + Alt + L` | Pitia mipangilio kwa mzunguko kinyume chake |
| `Super + P` | Geuza mtindo wa dirisha bandia (asili dhidi ya kunyoosha) |
| `Super + F` | Nenda skrini nzima |
| `Super + Alt + F` | Nenda upana kamili |
| `Super + Ctrl + F` | Nenda skrini nzima ndani ya dirisha |
| `Super + 1…9/0` | Ruka hadi eneo mahususi la kazi (0 ni 10) kwenye kifuatilia kilicholengwa |
| `Super + Tab` | Ruka hadi eneo linalofuata la kazi kwenye kifuatilia kilicholengwa |
| `Super + Shift + Tab` | Ruka hadi eneo lililotangulia la kazi kwenye kifuatilia kilicholengwa |
| `Super + Ctrl + Tab` | Ruka hadi eneo la kazi la awali kwenye kifuatilia kilicholengwa |
| `Super + Shift + 1…9/0` | Hamisha dirisha hadi eneo la kazi kwenye kifuatilia kilicholengwa |
| `Super + Shift + Alt + 1…9/0` | Hamisha dirisha hadi eneo la kazi kwenye kifuatilia kilicholengwa bila kulifuata |
| `Super + S` | Geuza scratchpad kamili |
| `Super + Alt + S` | Hamisha dirisha hadi scratchpad kamili |
| `Super + the key above Tab` (grave on US layouts) | Geuza konsoli ya Quake |
| `Super + Shift + the key above Tab` (grave on US layouts) | Hamisha dirisha hadi konsoli ya Quake |
| `Super + Shift + Ctrl + Arrows` | Hamisha dirisha hadi kifuatilia katika mwelekeo huo |
| `Super + Shift + Alt + Arrows` | Hamisha eneo la kazi hadi kifuatilia katika mwelekeo huo |
| `Super + Arrow` | Hamisha lengo hadi dirisha katika mwelekeo wa mshale, ukivuka hadi kifuatilia kilicho upande huo kwenye ukingo wa skrini |
| `Super + Shift + Arrow` | Badilishana dirisha na jingine katika mwelekeo wa mshale, ikiwa ni pamoja na lililo kwenye kifuatilia kilicho upande huo |
| `Super + Minus` | Panua dirisha kushoto |
| `Super + Equal` | Punguza dirisha kushoto |
| `Super + Shift + Minus` | Punguza dirisha juu |
| `Super + Shift + Equal` | Panua dirisha chini |
| `Super + Alt + Minus/Equal` | Upanuzi huo huo kwa hatua ndogo zaidi |
| `Super + Ctrl + Minus/Equal` | Upanuzi huo huo kwa hatua kubwa zaidi |
| `Super + Alt + Home` | Hifadhi upana wa dirisha |
| `Super + Home` | Rejesha upana wa dirisha uliohifadhiwa |
| `Super + Left Mouse` | Buruta dirisha huku na huko |
| `Super + Right Mouse` | Badilisha ukubwa wa dirisha |
| `Super + Scroll Wheel` | Tembeza kupitia maeneo ya kazi kwenye kifuatilia kilicholengwa |
| `Super + G` | Geuza uwekaji wa madirisha katika kikundi |
| `Super + Alt + G` | Hamisha dirisha kutoka katika kikundi |
| `Super + Alt + Tab` | Pitia madirisha katika kikundi kwa mzunguko |
| `Super + Alt + Shift + Tab` | Pitia madirisha katika kikundi kwa mzunguko kurudi nyuma |
| `Super + Alt + Scroll Wheel` | Pitia madirisha katika kikundi kwa mzunguko |
| `Super + Alt + 1/2/3/4/5` | Ruka hadi dirisha mahususi katika kikundi |
| `Super + Alt + Arrow` | Hamisha dirisha kuingia katika kikundi katika mwelekeo wa mshale, ikiwa ni pamoja na lililo kwenye kifuatilia kilicho upande huo |
| `Super + Ctrl + Left/Right` | Sogea kati ya madirisha ndani ya kikundi cha vigae |
| `Super + Ctrl + Z` | Kuza skrini (rudioa kwa ukuzaji zaidi) |
| `Super + Ctrl + Alt + Z` | Ondoa ukuzaji kabisa kutoka skrini |
| `Super + /` | Songa mbele kupitia chaguo za upimaji wa kifuatilia |
| `Super + Alt + /` | Songa nyuma kupitia chaguo za upimaji wa kifuatilia |
| `Alt + Tab` | Pitia madirisha kwenye eneo amilifu la kazi kwa mzunguko kwenda mbele |
| `Alt + Shift + Tab` | Pitia madirisha kwenye eneo amilifu la kazi kwa mzunguko kurudi nyuma |
| `Ctrl + Alt + Tab` | Pitia lengo kwenda mbele kupitia vifuatilia kwa mzunguko |
| `Ctrl + Alt + Shift + Tab` | Pitia lengo kurudi nyuma kupitia vifuatilia kwa mzunguko |
| `Super + I` | Badilisha lugha ya ingizo (ukiwa na mpangilio au mbinu ya ingizo zaidi ya moja) |
| `Super + Shift + I` | Badilisha lugha ya ingizo kurudi |

Kwenye pedi ya kugusa, miitelezo ya vidole vitatu na vinne hubadilisha maeneo ya kazi, huhamisha madirisha, na hufungua menyu na konsoli ya Quake; angalia [kibodi, kipanya, na pedi ya kufuatilia](34-keyboard-mouse-trackpad.md) kwa ishara hizo.

Vifupisho vya kubadilisha ukubwa hutumia vitufe halisi `code:20` na `code:21` (XKB `<AE11>` na `<AE12>`), bila kujali herufi zilizochapishwa kwenye kibodi. Kwenye kibodi za US vitufe hivi ni `-` na `=`; kwenye kibodi za Kijapani (JIS) ni `-` na `^`; kwenye kibodi za Kihispania ni `'` na `¡`. Kwenye JIS, `Super + ^` ni `Super + Equal`, ilhali `Super + Shift + -` (ambayo huandika `=`) ni `Super + Shift + Minus`.

## Vidhibiti vya mfumo

| Kitufe cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Paneli ya sauti |
| `Super + Ctrl + B` | Paneli ya Bluetooth |
| `Super + Ctrl + N` | Paneli ya Wi-Fi/mtandao |
| `Super + Ctrl + D` | Paneli ya onyesho |
| `Super + Ctrl + P` | Paneli ya nishati |
| `Super + Ctrl + X` | Paneli ya mawakala |
| `Super + Ctrl + Alt + X` | Paneli ya modeli za ndani |
| `Super + Ctrl + Alt + D` | Paneli ya kalenda |
| `Super + Ctrl + Alt + E` | Paneli ya saa ya dunia |
| `Super + Ctrl + 1-9` | Geuza paneli ya mwambaa kulingana na nafasi |
| `Super + Ctrl + S` | Menyu ya kushiriki (kupitia LocalSend) |
| `Super + Ctrl + C` | Vidhibiti vya kunasa (picha ya skrini/kurekodi/kichaguzi) |
| `Super + Ctrl + O` | Geuza menyu |
| `Super + Ctrl + H` | Menyu ya maunzi |
| `Super + Ctrl + E` | Kichaguzi cha emoji |
| `Super + Ctrl + .` | Badilisha umbizo la media |
| `Super + Shift + Ctrl + A` | Anzisha wakala wako chaguo-msingi |
| `Power` key | Menyu ya mfumo |
| `Super + Shift + Copilot` key | Menyu ya Omarchy |

## Marekebisho

| Kitufe cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Mwangaza wa juu kabisa wa skrini |
| `Shift + Brightness Down` | Mwangaza wa chini kabisa wa skrini |
| `Alt + Brightness Up/Down` | Mabadiliko sahihi ya mwangaza ya 1% |
| `Alt + Volume Up/Down` | Mabadiliko sahihi ya sauti ya 1% |
| `Keyboard Brightness Up/Down` | Mwangaza wa nyuma wa kibodi ung'ae zaidi/ufifie zaidi |
| `Keyboard Backlight` | Pitia viwango vya mwangaza wa nyuma wa kibodi kwa mzunguko |
| `Ctrl + Brightness Up/Down` | Mwangaza wa nyuma wa kibodi ung'ae zaidi/ufifie zaidi, kwenye kibodi zisizo na vitufe vyake |
| `Mic Mute` | Nyamazisha maikrofoni |
| `Shift + Mute` | Badilisha towe la sauti |
| `Touchpad Toggle` | Washa au zima pedi ya kugusa |
| `Display` key | Pitia mpangilio wa eneo la kazi kwa mzunguko |
| `Alt + Play` | Wimbo unaofuata |
| `Alt + Shift + Play` | Wimbo uliotangulia |

## Kufungua programu

| Kitufe cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + Return` | Terminali |
| `Super + Alt + Return` | Terminali ya Tmux |
| `Super + Ctrl + Return` | Herdr (kidhibiti cha mawakala) |
| `Super + Shift + Return` or `Super + Shift + B` | Kivinjari |
| `Super + Shift + Alt + B` | Kivinjari (faragha/incognito) |
| `Super + Shift + F` | Kidhibiti cha faili |
| `Super + Shift + Alt + F` | Kidhibiti cha faili katika cwd ya terminali |
| `Super + Shift + M` | Muziki (Spotify) |
| `Super + Shift + Alt + M` | Muziki (cliamp) |
| `Super + Shift + /` | Kidhibiti cha nywila (1password) |
| `Super + Shift + Q` or `Calculator` key | Kikokotoo (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, mara baada ya kusakinisha) |
| `Super + Shift + T` | Shughuli (btop) |
| `Super + Shift + N` | Kihariri (Plain, au chaguo-msingi ulichochagua) |
| `Super + Shift + C` | Kalenda ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Barua pepe ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Barua pepe mpya ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Wakala wako chaguo-msingi, au ChatGPT hadi uchague mmoja |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Programu ya ujumbe (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Programu ya ujumbe (WhatsApp) |
| `Super + Shift + Ctrl + G` | Programu ya ujumbe (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Kuandika (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (chapisho jipya) |
| `Super + Shift + Y` | YouTube |

Badilisha/ongeza vifungo katika `~/.config/hypr/bindings.lua`.

## Ubao wa kunakili wa jumla

| Kitufe cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + A` | Chagua vyote katika programu zinazotumia `Ctrl + A` |
| `Super + C` | Nakili |
| `Super + X` | Kata (si katika terminali) |
| `Super + V` | Bandika |
| `Super + Ctrl + V` | Kidhibiti cha ubao wa kunakili |

Kwa kawaida kwenye Linux, unahitaji `Ctrl + Shift + C/V` ili kunakili na kubandika katika terminali na `Ctrl + C/V` kufanya hivyo kila mahali pengine. Vitufe hivi vya mkato vya ubao wa kunakili vilivyounganishwa vya Omarchy hufanya kazi kila mahali.

## Kunasa

| Kitufe cha Mkato | Kazi |
| ------------------- | ------------------------------ |
| `Print Screen` | Picha ya skrini |
| `Super + Ctrl + Alt + C` | Picha ya skrini (picha hiyo hiyo, kwa kibodi zisizo na kitufe cha Print Screen) |
| `Super + Ctrl + C` | Menyu ya kunasa |
| `Alt + Print Screen` | Rekodi ya skrini |
| `Super + Shift + Ctrl + Alt + C` | Rekodi ya skrini bila sauti, ukiruka menyu (bonyeza tena kuacha) |
| `Super + Print Screen` | Kichaguzi cha rangi |
| `Super + Ctrl + Print Screen` | Utoaji wa maandishi hadi ubao wa kunakili |
| `Super + Alt + [` | Fanya wekeleo la webcam liwe dogo zaidi wakati wa kurekodi |
| `Super + Alt + ]` | Fanya wekeleo la webcam liwe kubwa zaidi wakati wa kurekodi |
| `Alt + Shift + L` | Nakili URL ya sasa kutoka programu ya wavuti au kivinjari |
| `Alt + Shift + D` | Pakua video iliyo kwenye ukurasa wa sasa hadi `~/Videos` |
| `Alt + Space` | Anzisha/acha kuamuru kwa sauti (inahitaji _Setup > Defaults > Dictation_) |
| `Right Alt` | Shikilia ili kuamuru kwa sauti (inahitaji _Setup > Defaults > Dictation_) |

Ukiwa na rekodi za skrini, kitufe cha mkato kwanza huuliza sauti unayotaka, kisha huanza kurekodi. Kibonyeze tena kuacha. Angalia [picha za skrini na kurekodi](12-screenshots-recording.md) kwa maelezo.

Chaguo zote za kunasa zinapatikana pia chini ya _Trigger > Capture_ katika menyu ya Omarchy (`Super + Space`).

## Arifa

| Kitufe cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + ,` | Tekeleza kwenye arifa ya hivi punde: ifungue au bonyeza kitufe chake pekee, chagua kutoka chaguo zake, au iondoe ikiwa haina chochote |
| `Super + Shift + ,` | Ondoa arifa zote |
| `Super + Ctrl + ,` | Dhibiti arifa kwa kibodi |
| `Super + Alt + ,` | Ondoa arifa ya hivi punde |
| `Super + Shift + Alt + ,` | Fungua historia ya arifa |
| `Super + Ctrl + Alt + ,` | Geuza kunyamazisha arifa |

## Mtindo

| Kitufe cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Chagua mandhari mpya (pia `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Chagua usuli wa mandhari (pia `Super + Ctrl + Space`) |
| `Super + Backspace` | Geuza uwazi kwenye dirisha |
| `Super + Ctrl + Backspace` | Geuza uwiano wa mraba wa dirisha moja |

Picha za ziada za usuli huishi katika `~/.config/omarchy/backgrounds/<theme name>`. Zinapatikana pia kupitia _Install > Style > Background_ katika menyu ya Omarchy.

Chaguo zote za mtindo zinapatikana pia chini ya _Appearance_ katika menyu ya Omarchy (`Super + Space`).

## Vigeuzi

| Kitufe cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Geuza kufunga wakati wa kutofanya kazi |
| `Super + Ctrl + Delete` | Geuza onyesho la laptop kuwasha/kuzima |
| `Super + Ctrl + Alt + Delete` | Geuza uakisi wa onyesho la laptop |
| `Super + Shift + Space` | Geuza mwambaa wa juu |
| `Shift + Mute` | Badilisha hadi towe linalofuata la sauti |
| `Shift + Play` | Badilisha hadi chanzo kinachofuata cha media |
| `Super + Shift + Backspace` | Geuza mapengo ya madirisha |
| `Super + Ctrl + Alt + F` | Geuza eneo-kazi la skrini nzima (mwambaa wa juu + mapengo ya madirisha) |

## Vikumbusho

| Kitufe cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Weka kikumbusho |
| `Super + Ctrl + Alt + R` | Tazama vikumbusho vyote |
| `Super + Ctrl + Shift + R` | Futa vikumbusho vyote |

## Taarifa

| Kitufe cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Onyesha muda kama arifa |
| `Super + Ctrl + Alt + B` | Onyesha betri kama arifa |
| `Super + Ctrl + Alt + W` | Geuza hali ya hewa kama arifa |

## Tmux

Kitufe cha kiambishi awali ni `Ctrl + Space` (`Ctrl + B` pia hufanya kazi). Unaweza kubadilisha vifungo hivi katika `~/.config/tmux/tmux.conf`.

### Pane

| Kitufe cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Prefix + v` | Gawa pane kando (wima) |
| `Prefix + h` | Gawa pane chini (mlalo) |
| `Prefix + x` | Ua pane |
| `Prefix + z` | Geuza ukuzaji wa pane (skrini nzima) |
| `Alt + Enter` | Gawa pane chini (bila kiambishi awali) |
| `Alt + Shift + Enter` | Gawa pane kando (bila kiambishi awali) |
| `Alt + Escape` | Ua pane (bila kiambishi awali) |
| `Ctrl + Alt + Arrows` | Sogea kati ya pane |
| `Ctrl + Alt + Shift + Arrows` | Badilisha ukubwa wa pane |

### Madirisha

| Kitufe cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Prefix + c` | Dirisha jipya |
| `Prefix + k` | Ua dirisha |
| `Prefix + r` | Badilisha jina la dirisha |
| `Alt + 1-9` | Nenda hadi dirisha mahususi |
| `Alt + Arrow Left/Right` | Sogea kati ya madirisha |
| `Alt + Shift + Arrow Left/Right` | Hamisha dirisha kushoto/kulia |

### Vipindi

| Kitufe cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Prefix + C` | Kipindi kipya |
| `Prefix + K` | Ua kipindi |
| `Prefix + R` | Badilisha jina la kipindi |
| `Prefix + N` | Kipindi kinachofuata |
| `Prefix + P` | Kipindi kilichotangulia |
| `Alt + Arrow Up/Down` | Sogea kati ya vipindi |
| `Prefix + s` | Orodhesha vipindi |
| `Prefix + d` | Jitenge na kipindi |

### Hali ya kunakili (mtindo wa vi)

| Kitufe cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Prefix + [` | Ingia hali ya kunakili |
| `v` | Anza uteuzi (katika hali ya kunakili) |
| `y` | Nakili uteuzi (katika hali ya kunakili) |

### Jumla

| Kitufe cha Mkato | Kazi |
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
| `tsl <count> <command>` | Unda mpangilio wa kundi wa pane nyingi |

## Terminali ya Ghostty

Terminali ya Ghostty husakinishwa kwa kutumia _Install > Terminal_ kupitia menyu ya Omarchy.

| Kitufe cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Mgawanyiko mpya chini |
| `Ctrl + Shift + O` | Mgawanyiko mpya kando |
| `Ctrl + Alt + Arrows` | Sogea kati ya migawanyiko |
| `Super + Ctrl + Shift + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 10 |
| `Super + Ctrl + Shift + Alt + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 100 |
| `Ctrl + Shift + T` | Kichupo kipya |
| `Ctrl + Shift + Arrows` | Sogea kati ya vichupo |
| `Alt + Numbers` | Nenda hadi kichupo mahususi |
| `Shift + Pg Up/Down` | Tembeza historia |
| `Ctrl + Left mouse` | Fungua kiungo katika kivinjari |

## Kidhibiti cha Faili

| Kitufe cha Mkato | Kazi |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Nenda hadi njia |
| `Space` | Hakiki faili (mishale hupitia) |
| `Alt + Up` | Panda hadi folda mama |

## Neovim (w/ lazyvim)

### Kupitia

| Kitufe cha Mkato | Kazi |
| ------------------------ | ------------------------------- |
| `Space` | Onyesha chaguo za amri |
| `Space Space` | Fungua faili kupitia utafutaji usio wazi |
| `Space E` | Geuza mwambaa wa kando |
| `Space G G` | Onyesha vidhibiti vya git |
| `Space S G` | Tafuta maudhui ya faili |
| `Ctrl + W W` | Ruka kati ya mwambaa wa kando na kihariri |
| `Ctrl + Left/right arrow` | Badilisha ukubwa wa mwambaa wa kando |
| `Shift + H` | Nenda hadi kichupo cha faili cha kushoto |
| `Shift + L` | Nenda hadi kichupo cha faili cha kulia |
| `Space B D` | Funga kichupo cha faili |

### Ukiwa katika mwambaa wa kando

| Kitufe cha Mkato | Kazi |
| ------------------------ | ------------------------------- |
| `A` | Ongeza faili mpya katika saraka mama |
| `Shift + A` | Ongeza saraka ndogo mpya katika saraka mama |
| `D` | Futa faili/saraka iliyoangaziwa |
| `M` | Hamisha faili/saraka iliyoangaziwa |
| `R` | Badilisha jina la faili/saraka iliyoangaziwa |
| `?` | Onyesha usaidizi kwa amri zote |

[Tazama vitufe vyote vya mkato vya Neovim vilivyosanidiwa na LazyVim](https://www.lazyvim.org/keymaps).

## Emoji za Haraka

Unaweza kutumia `Super + Ctrl + E` kuonyesha kichaguzi kamili cha emoji ambacho kitaweka uteuzi kwenye ubao wa kunakili au unaweza kutumia chaguo hizi za ufikiaji wa haraka.

| Kitufe cha Mkato | EM | Kidokezo |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | tabasamu |
| `Shift + CapsLock M C` | 😂 | lia |
| `Shift + CapsLock M L` | 😍 | upendo |
| `Shift + CapsLock M V` | ✌️ | ushindi |
| `Shift + CapsLock M H` | ❤️ | moyo |
| `Shift + CapsLock M Y` | 👍 | ndiyo |
| `Shift + CapsLock M N` | 👎 | hapana |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | tamani |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | busu |
| `Shift + CapsLock M E` | 🙄 | zungusha macho |
| `Shift + CapsLock M I` | 😉 | konyeza |
| `Shift + CapsLock M P` | 🙏 | omba |
| `Shift + CapsLock M D` | 🤤 | dondosha mate |
| `Shift + CapsLock M M` | 💰 | pesa |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | toast |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | salamu |
| `Shift + CapsLock M A` |💪 | mkono |
| `Shift + CapsLock M B` |🤯 | kupuliza |

## Ukamilishaji wa Haraka

| Kitufe cha Mkato | Ukamilishaji |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Jina lako (kama lilivyoingizwa wakati wa usanidi) |
| `Shift + CapsLock Space E` | Barua pepe yako (kama ilivyoingizwa wakati wa usanidi) |

Unaweza kuongeza zaidi yako mwenyewe kwa kuhariri `~/.XCompose`, kisha kuendesha `omarchy restart xcompose` katika terminali ili mabadiliko yachukuliwe.
