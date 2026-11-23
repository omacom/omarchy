# Vifunguo vya Mkato

Unaweza kuona vifunguo vyote vikuu vya kibodi kwa `Super + K` (vifunguo vya Tmux kwa `Super + Alt + K` na vifunguo vya Herdr kwa `Super + Ctrl + K`).

## Jinsi vifunguo vya mkato vilivyopangwa

Kila kifunguo cha mkato kiko kwenye safu moja, iliyowekwa na virekebishaji vyake, na kila safu ina kazi moja. Hilo ndilo linalozuia vifunguo vya mkato kuchanganyikana, na inamaanisha kwa kawaida unaweza kukisia kitu kiko wapi.

| Safu | Kile kinachoishi hapo | Mifano |
| --- | --- | --- |
| `Super + key` | Mfumo: madirisha, nafasi za kazi, mipangilio, na menyu za msingi | `Super + Space` menyu ya Omarchy, `Super + W` funga dirisha, `Super + F` skrini nzima |
| `Super + Shift + key` | Programu | `Super + Shift + B` kivinjari, `Super + Shift + E` barua pepe, `Super + Shift + N` kihariri |
| `Super + Ctrl + key` | Paneli na menyu za mfumo | `Super + Ctrl + A` sauti, `Super + Ctrl + N` mtandao, `Super + Ctrl + C` menyu ya kunasa |
| `Super + Ctrl + Alt + key` | Vitendo vya haraka na taarifa | `Super + Ctrl + Alt + T` onyesha muda, `Super + Ctrl + Alt + B` betri, `Super + Ctrl + Alt + C` picha ya skrini |

Kuongeza `Alt` kwenye kifunguo cha mkato hukupa lahaja ya kitu kile kile, kamwe si kitu kisichohusiana:

- `Super + Shift + B` hufungua kivinjari; `Super + Shift + Alt + B` hufungua dirisha la faragha
- `Super + Shift + E` hufungua barua pepe; `Super + Shift + Alt + E` huanzisha mpya
- `Super + F` huenda skrini nzima; `Super + Alt + F` huenda upana kamili
- `Super + Ctrl + C` hufungua menyu ya kunasa; `Super + Ctrl + Alt + C` huruka menyu na kuchukua picha ya skrini

Wakati wa kuongeza kifunguo cha mkato:

1. Chagua safu kutokana na kile kinachofanya, kisha chagua kitufe.
2. Usihamishe kifunguo cha mkato kilichopo ili kupata nafasi. Tafuta kitufe kilicho wazi kwenye safu sahihi.
3. Tumia `Alt` tu kwa lahaja ya kifunguo cha mkato kisicho nayo.

Baadhi ya vifunguo vya mkato huvunja sheria hizi kwa sababu ni rahisi. `Shift` ukiwa na mshale au `Tab` huhamisha au hubadilisha mwelekeo badala ya kufungua programu, na `Print`, vitufe vya media, `Alt + Tab`, na `Ctrl + Alt + Del` hufanya kazi jinsi zinavyofanya kila mahali pengine. Ni vighairi, si mifumo ya kunakili.

Ikiwa chaguo-msingi halikufai (tuseme unataka `Super + Shift + S` kwa picha za skrini kama kwenye Windows), libadilishe katika `~/.config/hypr/bindings.lua`.

## Urambazaji

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + Space` | Menyu ya Omarchy (programu na kila kitu kingine) |
| `Super + Alt + Space` | Gridi ya programu |
| `Super + Escape` | Menyu ya mfumo (sitisha, anzisha upya, n.k.) |
| `Super + Ctrl + L` | Funga kompyuta |
| `Super + W` or `Super + Q` | Funga dirisha |
| `Ctrl + Alt + Del` | Funga madirisha yote |
| `Super + K` | Onyesha vifunguo vyote vya mkato |
| `Super + Alt + K` | Onyesha vifunguo vya mkato vya tmux |
| `Super + Ctrl + K` | Onyesha vifunguo vya mkato vya herdr |
| `Super + M` | Punguza dirisha hadi kwenye doki |
| `Super + T` | Geuza dirisha kati ya hali ya vigae na kuelea |
| `Super + J` | Geuza nafasi ya dirisha (ya mlalo/wima) |
| `Super + O` | Geuza dirisha litokee kuwa la kunata na kuelea |
| `Super + L` | Zunguka kupitia mipangilio ya dwindle, scrolling, na floating |
| `Super + Alt + L` | Zunguka kupitia mipangilio kwa mwelekeo wa nyuma |
| `Super + P` | Geuza mtindo wa dirisha bandia (asili dhidi ya kunyoosha) |
| `Super + F` | Nenda skrini nzima |
| `Super + Alt + F` | Nenda upana kamili |
| `Super + Ctrl + F` | Nenda skrini nzima ndani ya dirisha |
| `Super + 1…9/0` | Ruka hadi nafasi maalum ya kazi (0 ni 10) kwenye kifuatilia kilicholengwa |
| `Super + Tab` | Ruka hadi nafasi inayofuata ya kazi kwenye kifuatilia kilicholengwa |
| `Super + Shift + Tab` | Ruka hadi nafasi iliyotangulia ya kazi kwenye kifuatilia kilicholengwa |
| `Super + Ctrl + Tab` | Ruka hadi nafasi ya awali ya kazi kwenye kifuatilia kilicholengwa |
| `Super + Shift + 1…9/0` | Hamisha dirisha hadi nafasi ya kazi kwenye kifuatilia kilicholengwa |
| `Super + Shift + Alt + 1…9/0` | Hamisha dirisha hadi nafasi ya kazi kwenye kifuatilia kilicholengwa bila kuifuata |
| `Super + S` | Geuza scratchpad kamili |
| `Super + Alt + S` | Hamisha dirisha hadi scratchpad kamili |
| `Super + the key above Tab` (grave kwenye mipangilio ya US) | Geuza koni ya Quake |
| `Super + Shift + the key above Tab` (grave kwenye mipangilio ya US) | Hamisha dirisha hadi koni ya Quake |
| `Super + Shift + Ctrl + Arrows` | Hamisha dirisha hadi kifuatilia kilicho katika mwelekeo huo |
| `Super + Shift + Alt + Arrows` | Hamisha nafasi ya kazi hadi kifuatilia kilicho katika mwelekeo huo |
| `Super + Arrow` | Hamisha lengo hadi dirisha lililo katika mwelekeo wa mshale, ukivuka hadi kifuatilia kilicho upande huo kwenye ukingo wa skrini |
| `Super + Shift + Arrow` | Badilishana dirisha na jingine lililo katika mwelekeo wa mshale, ikiwa ni pamoja na lililo kwenye kifuatilia kilicho upande huo |
| `Super + Minus` | Panua dirisha kushoto |
| `Super + Equal` | Punguza dirisha kushoto |
| `Super + Shift + Minus` | Punguza dirisha juu |
| `Super + Shift + Equal` | Panua dirisha chini |
| `Super + Alt + Minus/Equal` | Kubadilisha ukubwa vile vile kwa hatua ndogo zaidi |
| `Super + Ctrl + Minus/Equal` | Kubadilisha ukubwa vile vile kwa hatua kubwa zaidi |
| `Super + Alt + Home` | Hifadhi upana wa dirisha |
| `Super + Home` | Rejesha upana wa dirisha uliohifadhiwa |
| `Super + Left Mouse` | Buruta dirisha huku na huku |
| `Super + Right Mouse` | Badilisha ukubwa wa dirisha |
| `Super + Scroll Wheel` | Sogeza kupitia nafasi za kazi kwenye kifuatilia kilicholengwa |
| `Super + G` | Geuza uunganishaji wa dirisha katika kikundi |
| `Super + Alt + G` | Toa dirisha nje ya kikundi |
| `Super + Alt + Tab` | Zunguka kati ya madirisha katika kikundi |
| `Super + Alt + Shift + Tab` | Zunguka nyuma kati ya madirisha katika kikundi |
| `Super + Alt + Scroll Wheel` | Zunguka kati ya madirisha katika kikundi |
| `Super + Alt + 1/2/3/4/5` | Ruka hadi dirisha maalum katika kikundi |
| `Super + Alt + Arrow` | Hamisha dirisha liingie katika kikundi katika mwelekeo wa mshale, ikiwa ni pamoja na lililo kwenye kifuatilia kilicho upande huo |
| `Super + Ctrl + Left/Right` | Sogea kati ya madirisha ndani ya kikundi cha vigae |
| `Super + Ctrl + Z` | Kuza kwenye skrini (r repeat kwa ukuzaji zaidi) |
| `Super + Ctrl + Alt + Z` | Kuza nje kabisa kutoka kwenye skrini |
| `Super + /` | Nenda mbele kupitia chaguzi za kuongeza ukubwa wa kifuatilia |
| `Super + Alt + /` | Nenda nyuma kupitia chaguzi za kuongeza ukubwa wa kifuatilia |
| `Alt + Tab` | Zunguka mbele kupitia madirisha kwenye nafasi ya kazi inayotumika |
| `Alt + Shift + Tab` | Zunguka nyuma kupitia madirisha kwenye nafasi ya kazi inayotumika |
| `Ctrl + Alt + Tab` | Zungusha lengo mbele kupitia vifuatilia |
| `Ctrl + Alt + Shift + Tab` | Zungusha lengo nyuma kupitia vifuatilia |
| `Super + I` | Badilisha lugha ya ingizo (ukiwa na mpangilio au mbinu ya ingizo zaidi ya moja) |
| `Super + Shift + I` | Badilisha lugha ya ingizo kurudi nyuma |

Kwenye padi ya kugusa, mi telezo ya vidole vitatu na vinne hubadilisha nafasi za kazi, huhamisha madirisha, na kufungua menyu na koni ya Quake; angalia [kibodi, kipanya, na padi ya kugusa](34-keyboard-mouse-trackpad.md) kwa ishara hizo.

Kubadilisha ukubwa hutumia vitufe viwili vilivyo kulia mwa 0, chochote kibodi yako inachapisha juu yake: `-` na `=` kwenye kibodi za US, `+` na `´` kwenye za Kidenmaki na Kiswidi, `+` na `\` kwenye za Kinorwe, `ß` na `´` kwenye za Kijerumani, `'` na `¡` kwenye za Kihispania, na `-` na `^` kwenye za Kijapani (JIS). `Super + K` huorodhesha jinsi kibodi yako inavyovichapisha. Kwenye JIS, `Super + ^` ni `Super + Equal`, huku `Super + Shift + -` (ambayo huchapisha `=`) ni `Super + Shift + Minus`. Kuongeza ukubwa wa kifuatilia na kidhibiti cha nenosiri hutumia `/`; kwenye mipangilio ambayo huchapisha `/` tu kwa Shift, kama nyingi za Ulaya zinavyofanya, hutumia kitufe kilicho kushoto mwa Shift ya kulia badala yake (`-` kwenye Kidenmaki na Kijerumani).

## Vidhibiti vya mfumo

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Paneli ya sauti |
| `Super + Ctrl + B` | Paneli ya Bluetooth |
| `Super + Ctrl + N` | Paneli ya Wi-Fi/mtandao |
| `Super + Ctrl + D` | Paneli ya onyesho |
| `Super + Ctrl + P` | Paneli ya nishati |
| `Super + Ctrl + X` | Paneli ya mawakala |
| `Super + Ctrl + Alt + X` | Paneli ya miundo ya ndani |
| `Super + Ctrl + Alt + D` | Paneli ya kalenda |
| `Super + Ctrl + Alt + E` | Paneli ya saa ya dunia |
| `Super + Ctrl + 1-9` | Geuza paneli ya upau kulingana na nafasi |
| `Super + Ctrl + S` | Menyu ya kushiriki (kupitia LocalSend) |
| `Super + Ctrl + C` | Vidhibiti vya kunasa (picha ya skrini/kurekodi/kichaguzi) |
| `Super + Ctrl + O` | Geuza menyu |
| `Super + Ctrl + H` | Menyu ya vifaa |
| `Super + Ctrl + E` | Kichaguzi cha emoji |
| `Super + Ctrl + .` | Badilisha umbizo la media |
| `Super + Shift + Ctrl + A` | Anzisha wakala wako chaguo-msingi |
| `Power` key | Menyu ya mfumo |
| `Super + Shift + Copilot` key | Menyu ya Omarchy |

## Marekebisho

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Mwangaza wa juu kabisa wa skrini |
| `Shift + Brightness Down` | Mwangaza wa chini kabisa wa skrini |
| `Alt + Brightness Up/Down` | Mabadiliko sahihi ya mwangaza ya 1% |
| `Alt + Volume Up/Down` | Mabadiliko sahihi ya sauti ya 1% |
| `Keyboard Brightness Up/Down` | Mwangaza wa nyuma wa kibodi uwe mkali zaidi/mdogo zaidi |
| `Keyboard Backlight` | Zunguka viwango vya mwangaza wa nyuma wa kibodi |
| `Ctrl + Brightness Up/Down` | Mwangaza wa nyuma wa kibodi uwe mkali zaidi/mdogo zaidi, kwenye kibodi zisizo na vitufe vyao |
| `Mic Mute` | Nyamazisha maikrofoni |
| `Shift + Mute` | Badilisha utoaji wa sauti |
| `Touchpad Toggle` | Washa au zima padi ya kugusa |
| `Display` key | Zunguka mpangilio wa nafasi ya kazi |
| `Alt + Play` | Wimbo unaofuata |
| `Alt + Shift + Play` | Wimbo uliotangulia |

## Kuanzisha programu

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + Return` | Terminali |
| `Super + Alt + Return` | Terminali ya Tmux |
| `Super + Ctrl + Return` | Herdr (kidhibiti cha mawakala) |
| `Super + Shift + Return` or `Super + Shift + B` | Kivinjari |
| `Super + Shift + Alt + B` | Kivinjari (ya faragha/incognito) |
| `Super + Shift + F` | Kidhibiti cha faili |
| `Super + Shift + Alt + F` | Kidhibiti cha faili katika cwd ya terminali |
| `Super + Shift + M` | Muziki (Spotify) |
| `Super + Shift + Alt + M` | Muziki (cliamp) |
| `Super + Shift + /` | Kidhibiti cha nenosiri (1password) |
| `Super + Shift + Q` or `Calculator` key | Kikokotoo (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, baada ya kusakinisha) |
| `Super + Shift + T` | Shughuli (btop) |
| `Super + Shift + N` | Kihariri (Plain, au chaguo-msingi ulilochagua) |
| `Super + Shift + C` | Kalenda ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Barua pepe ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Barua pepe mpya ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Wakala wako chaguo-msingi, au ChatGPT hadi uchague mmoja |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Mjumbe (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Mjumbe (WhatsApp) |
| `Super + Shift + Ctrl + G` | Mjumbe (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Kuandika (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (chapisho jipya) |
| `Super + Shift + Y` | YouTube |

Badilisha/ongeza vifunguo katika `~/.config/hypr/bindings.lua`.

## Ubao wa kunakili wa jumla

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + A` | Chagua vyote katika programu zinazotumia `Ctrl + A` |
| `Super + C` | Nakili |
| `Super + X` | Kata (si katika terminali) |
| `Super + V` | Bandika |
| `Super + Ctrl + V` | Kidhibiti cha ubao wa kunakili |

Kwa kawaida kwenye Linux, unahitaji `Ctrl + Shift + C/V` kunakili na kubandika katika terminali na `Ctrl + C/V` kufanya hivyo kila mahali pengine. Vifunguo hivi vya mkato vya ubao wa kunakili vilivyounganishwa vya Omarchy hufanya kazi kila mahali.

## Kunasa

| Kifunguo cha Mkato | Kazi |
| ------------------- | ------------------------------ |
| `Print Screen` | Picha ya skrini |
| `Super + Ctrl + Alt + C` | Picha ya skrini (picha ile ile, kwa kibodi zisizo na kitufe cha Print Screen) |
| `Super + Ctrl + C` | Menyu ya kunasa |
| `Alt + Print Screen` | Rekodi skrini |
| `Super + Shift + Ctrl + Alt + C` | Rekodi skrini bila sauti, ukiruka menyu (bonyeza tena kuacha) |
| `Super + Print Screen` | Kichaguzi cha rangi |
| `Super + Ctrl + Print Screen` | Kutoa maandishi hadi kwenye ubao wa kunakili |
| `Super + Alt + [` | Fanya wekeleaji wa kamera ya wavuti kuwa mdogo zaidi wakati wa kurekodi |
| `Super + Alt + ]` | Fanya wekeleaji wa kamera ya wavuti kuwa mkubwa zaidi wakati wa kurekodi |
| `Alt + Shift + L` | Nakili URL ya sasa kutoka kwenye programu ya wavuti au kivinjari |
| `Alt + Shift + D` | Pakua video iliyo kwenye ukurasa wa sasa hadi `~/Videos` |
| `Alt + Space` | Anza/acha kuamuru kwa sauti (inahitaji _Setup > Defaults > Dictation_) |
| `Right Alt` | Shikilia ili kuamuru kwa sauti (inahitaji _Setup > Defaults > Dictation_) |

Ukiwa na rekodi za skrini, kifunguo cha mkato huuliza kwanza sauti unayotaka, kisha huanza kurekodi. Bonyeza tena kuacha. Angalia [picha za skrini na kurekodi](12-screenshots-recording.md) kwa maelezo.

Chaguzi zote za kunasa zinapatikana pia chini ya _Trigger > Capture_ katika menyu ya Omarchy (`Super + Space`).

## Arifa

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + ,` | Tekeleza arifa ya hivi punde zaidi: ifungue au bonyeza kitufe chake pekee, chagua kutoka kwenye chaguzi zake, au iondoe ikiwa haina chochote |
| `Super + Shift + ,` | Ondoa arifa zote |
| `Super + Ctrl + ,` | Dhibiti arifa kwa kibodi |
| `Super + Alt + ,` | Ondoa arifa ya hivi punde zaidi |
| `Super + Shift + Alt + ,` | Fungua historia ya arifa |
| `Super + Ctrl + Alt + ,` | Geuza kunyamazisha arifa |

## Mtindo

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Chagua mandhari mapya (pia `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Chagua mandharinyuma ya mandhari (pia `Super + Ctrl + Space`) |
| `Super + Backspace` | Geuza uwazi kwenye dirisha |
| `Super + Ctrl + Backspace` | Geuza uwiano wa mraba wa dirisha moja |

Picha za ziada za mandharinyuma ziko katika `~/.config/omarchy/backgrounds/<theme name>`. Zinapatikana pia kupitia _Install > Style > Background_ katika menyu ya Omarchy.

Chaguzi zote za mtindo zinapatikana pia chini ya _Appearance_ katika menyu ya Omarchy (`Super + Space`).

## Vigeuzo

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Geuza kufunga wakati wa kutofanya kazi |
| `Super + Ctrl + Delete` | Geuza onyesho la laptop kuwasha/kuzima |
| `Super + Ctrl + Alt + Delete` | Geuza kuakisi onyesho la laptop |
| `Super + Shift + Space` | Geuza upau wa juu |
| `Shift + Mute` | Badilisha hadi utoaji unaofuata wa sauti |
| `Shift + Play` | Badilisha hadi chanzo kinachofuata cha media |
| `Super + Shift + Backspace` | Geuza mapengo ya madirisha |
| `Super + Ctrl + Alt + F` | Geuza eneo-kazi la skrini nzima (upau wa juu + mapengo ya madirisha) |

## Vikumbusho

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Weka kikumbusho |
| `Super + Ctrl + Alt + R` | Tazama vikumbusho vyote |
| `Super + Ctrl + Shift + R` | Futa vikumbusho vyote |

## Taarifa

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Onyesha muda kama arifa |
| `Super + Ctrl + Alt + B` | Onyesha betri kama arifa |
| `Super + Ctrl + Alt + W` | Geuza hali ya hewa kama arifa |

## Tmux

Kitufe cha kiambishi awali ni `Ctrl + Space` (`Ctrl + B` pia hufanya kazi). Unaweza kubadilisha vifunguo hivi katika `~/.config/tmux/tmux.conf`.

### Paneli

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Prefix + v` | Gawa paneli kando (wima) |
| `Prefix + h` | Gawa paneli chini (mlalo) |
| `Prefix + x` | Ua paneli |
| `Prefix + z` | Geuza ukuzaji wa paneli (skrini nzima) |
| `Alt + Enter` | Gawa paneli chini (hakuna kiambishi awali) |
| `Alt + Shift + Enter` | Gawa paneli kando (hakuna kiambishi awali) |
| `Alt + Escape` | Ua paneli (hakuna kiambishi awali) |
| `Ctrl + Alt + Arrows` | Sogea kati ya paneli |
| `Ctrl + Alt + Shift + Arrows` | Badilisha ukubwa wa paneli |

### Madirisha

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Prefix + c` | Dirisha jipya |
| `Prefix + k` | Ua dirisha |
| `Prefix + r` | Badilisha jina la dirisha |
| `Alt + 1-9` | Nenda kwenye dirisha maalum |
| `Alt + Arrow Left/Right` | Sogea kati ya madirisha |
| `Alt + Shift + Arrow Left/Right` | Hamisha dirisha kushoto/kulia |

### Vipindi

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Prefix + C` | Kipindi kipya |
| `Prefix + K` | Ua kipindi |
| `Prefix + R` | Badilisha jina la kipindi |
| `Prefix + N` | Kipindi kinachofuata |
| `Prefix + P` | Kipindi kilichotangulia |
| `Alt + Arrow Up/Down` | Sogea kati ya vipindi |
| `Prefix + s` | Orodhesha vipindi |
| `Prefix + d` | Tenganisha kutoka kwenye kipindi |

### Hali ya kunakili (mtindo wa vi)

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Prefix + [` | Ingia hali ya kunakili |
| `v` | Anza uteuzi (katika hali ya kunakili) |
| `y` | Nakili uteuzi (katika hali ya kunakili) |

### Jumla

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Prefix + q` | Pakia upya usanidi |
| `Prefix + ?` | Onyesha vifunguo vya Tmux |
| `Prefix + :` | Kianzio cha amri |

### Vitendakazi vya mpangilio wa Tmux

Vitendakazi hivi lazima viendeshwe ndani ya kipindi cha Tmux.

| Amri | Kazi |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Unda mpangilio wa ukuzaji ukiwa na kihariri, AI, na terminali |
| `tdlm <ai> [<second_ai>]` | Unda mpangilio wa ukuzaji kwa kila saraka ndogo |
| `tsl <count> <command>` | Unda mpangilio wa kundi wa paneli nyingi |

## Ghostty Terminal

Terminali ya Ghostty husakinishwa kwa kutumia _Install > Terminal_ kupitia menyu ya Omarchy.

| Kifunguo cha Mkato | Kazi |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Mgawanyiko mpya chini |
| `Ctrl + Shift + O` | Mgawanyiko mpya kando |
| `Ctrl + Alt + Arrows` | Sogea kati ya migawanyiko |
| `Super + Ctrl + Shift + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 10 |
| `Super + Ctrl + Shift + Alt + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 100 |
| `Ctrl + Shift + T` | Kichupo kipya |
| `Ctrl + Shift + Arrows` | Sogea kati ya vichupo |
| `Alt + Numbers` | Nenda kwenye kichupo maalum |
| `Shift + Pg Up/Down` | Sogeza historia |
| `Ctrl + Left mouse` | Fungua kiungo katika kivinjari |

## Kidhibiti cha Faili

| Kifunguo cha Mkato | Kazi |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Nenda kwenye njia |
| `Space` | Hakiki faili (mishale husogeza) |
| `Alt + Up` | Nenda juu hadi folda mzazi |

## Neovim (w/ lazyvim)

### Urambazaji

| Kifunguo cha Mkato | Kazi |
| ------------------------ | ------------------------------- |
| `Space` | Onyesha chaguzi za amri |
| `Space Space` | Fungua faili kupitia utafutaji wa fuzzy |
| `Space E` | Geuza upau wa kando |
| `Space G G` | Onyesha vidhibiti vya git |
| `Space S G` | Tafuta maudhui ya faili |
| `Ctrl + W W` | Ruka kati ya upau wa kando na kihariri |
| `Ctrl + Left/right arrow` | Badilisha ukubwa wa upau wa kando |
| `Shift + H` | Nenda kwenye kichupo cha faili cha kushoto |
| `Shift + L` | Nenda kwenye kichupo cha faili cha kulia |
| `Space B D` | Funga kichupo cha faili |

### Wakati uko kwenye upau wa kando

| Kifunguo cha Mkato | Kazi |
| ------------------------ | ------------------------------- |
| `A` | Ongeza faili mpya katika saraka mzazi |
| `Shift + A` | Ongeza saraka ndogo mpya katika saraka mzazi |
| `D` | Futa faili/saraka iliyoangaziwa |
| `M` | Hamisha faili/saraka iliyoangaziwa |
| `R` | Badilisha jina la faili/saraka iliyoangaziwa |
| `?` | Onyesha msaada kwa amri zote |

[Tazama vifunguo vyote vya mkato vya Neovim vilivyosanidiwa na LazyVim](https://www.lazyvim.org/keymaps).

## Emoji za Haraka

Unaweza kutumia `Super + Ctrl + E` kuonyesha kichaguzi kamili cha emoji ambacho kitaweka uteuzi kwenye ubao wa kunakili au unaweza kutumia chaguzi hizi za ufikiaji wa haraka.

| Kifunguo cha Mkato | EM | Kidokezo |
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
| `Shift + CapsLock M O` |👌 | sawa |
| `Shift + CapsLock M G` |👋 | salamu |
| `Shift + CapsLock M A` |💪 | mkono |
| `Shift + CapsLock M B` |🤯 | kulipuka |

## Ukamilishaji wa Haraka

| Kifunguo cha Mkato | Ukamilishaji |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Jina lako (kama lilivyoingizwa wakati wa usanidi) |
| `Shift + CapsLock Space E` | Barua pepe yako (kama ilivyoingizwa wakati wa usanidi) |

Unaweza kuongeza zaidi yako mwenyewe kwa kuhariri `~/.XCompose`, kisha uendeshe `omarchy restart xcompose` katika terminali ili mabadiliko yachukuliwe.
