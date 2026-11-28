# Vitefio vya Haraka

Unaweza kuona viunganisho vyote vikuu vya kibodi kwa `Super + K` (viunganisho vya Tmux kwa `Super + Alt + K` na viunganisho vya Herdr kwa `Super + Ctrl + K`).

## Jinsi vitefio vya haraka vilivyopangwa

Kila kitefio cha haraka hukaa kwenye safu, inayowekwa na virekebishaji vyake, na kila safu ina kazi moja. Hiyo ndiyo inayozuia vitefio vya haraka kuchanganyika, na ina maana kwamba kwa kawaida unaweza kukisia kitu kiko wapi.

| Safu | Kinachokaa hapo | Mifano |
| --- | --- | --- |
| `Super + key` | Mfumo: madirisha, nafasi za kazi, mipangilio, na menyu kuu | `Super + Space` menyu ya Omarchy, `Super + W` funga dirisha, `Super + F` skrini nzima |
| `Super + Shift + key` | Programu | `Super + Shift + B` kivinjari, `Super + Shift + E` barua pepe, `Super + Shift + N` kihariri |
| `Super + Ctrl + key` | Paneli na menyu za mfumo | `Super + Ctrl + A` sauti, `Super + Ctrl + N` mtandao, `Super + Ctrl + C` menyu ya kunasa |
| `Super + Ctrl + Alt + key` | Vitendo vya haraka na taarifa | `Super + Ctrl + Alt + T` onyesha saa, `Super + Ctrl + Alt + B` betri, `Super + Ctrl + Alt + C` picha ya skrini |

Kuongeza `Alt` kwenye kitefio cha haraka hukupa aina tofauti ya kitu kile kile, kamwe si kitu kisichohusiana:

- `Super + Shift + B` hufungua kivinjari; `Super + Shift + Alt + B` hufungua dirisha la faragha
- `Super + Shift + E` hufungua barua pepe; `Super + Shift + Alt + E` huanzisha mpya
- `Super + F` huenda skrini nzima; `Super + Alt + F` huenda upana kamili
- `Super + Ctrl + C` hufungua menyu ya kunasa; `Super + Ctrl + Alt + C` huruka menyu na kuchukua picha ya skrini

Unapoongeza kitefio cha haraka:

1. Chagua safu kutokana na kile kinachofanya, kisha chagua kitufe.
2. Usisogeze kitefio cha haraka kilichopo ili kupata nafasi. Tafuta kitufe kilicho wazi kwenye safu sahihi.
3. Tumia `Alt` tu kwa aina tofauti ya kitefio cha haraka kisicho nayo.

Vitefio vichache vya haraka huvunja sheria hizi kwa sababu ni rahisi kutumia. `Shift` ikiwa na mshale au `Tab` husogeza au hubadilisha mwelekeo badala ya kufungua programu, na `Print`, vitefio vya midia, `Alt + Tab`, na `Ctrl + Alt + Del` hufanya kazi kama zinavyofanya kila mahali pengine. Ni tofauti na kanuni, si mifumo ya kuiga.

Kama chaguo-msingi halikufai (tuseme unataka `Super + Shift + S` kwa picha za skrini kama kwenye Windows), libadilishe katika `~/.config/hypr/bindings.lua`.

## Kuabiri

| Kitefio cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + Space`           | Menyu ya Omarchy (programu na kila kitu kingine)    |
| `Super + Alt + Space` | Gridi ya programu |
| `Super + Escape` | Menyu ya mfumo (sitisha, anzisha upya, n.k.)  |
| `Super + Ctrl + L` | Funga kompyuta |
| `Super + W` or `Super + Q` | Funga dirisha             |
| `Ctrl + Alt + Del` | Funga madirisha yote |
| `Super + K` | Onyesha vitefio vyote vya haraka |
| `Super + Alt + K` | Onyesha vitefio vya haraka vya tmux |
| `Super + Ctrl + K` | Onyesha vitefio vya haraka vya herdr |
| `Super + M` | Punguza dirisha hadi kwenye doki |
| `Super + T`               | Geuza dirisha kati ya hali ya vigae/kuelea             |
| `Super + J` | Geuza nafasi ya dirisha (mlalo/wima) |
| `Super + O`               | Geuza dirisha kuwa hali ya kunata na kuelea |
| `Super + L`               | Zunguka katika mipangilio ya dwindle, scrolling, na floating |
| `Super + Alt + L`         | Zunguka katika mipangilio kinyume chake |
| `Super + P`               | Geuza mtindo wa dirisha bandia (asili dhidi ya kunyoosha) |
| `Super + F`                 | Nenda skrini nzima              |
| `Super + Alt + F`                 | Nenda upana kamili              |
| `Super + Ctrl + F`                 | Nenda skrini nzima ndani ya dirisha              |
| `Super + 1…9/0`         | Ruka hadi nafasi maalum ya kazi (0 ni 10) kwenye kifuatilia kilicholengwa |
| `Super + Tab` | Ruka hadi nafasi inayofuata ya kazi kwenye kifuatilia kilicholengwa |
| `Super + Shift + Tab` | Ruka hadi nafasi ya awali ya kazi kwenye kifuatilia kilicholengwa |
| `Super + Ctrl + Tab` | Ruka hadi nafasi ya kazi ya zamani kwenye kifuatilia kilicholengwa |
| `Super + Shift + 1…9/0` | Sogeza dirisha hadi nafasi ya kazi kwenye kifuatilia kilicholengwa |
| `Super + Shift + Alt + 1…9/0` | Sogeza dirisha hadi nafasi ya kazi kwenye kifuatilia kilicholengwa bila kulifuata |
| `Super + S` | Geuza scratchpad kamili |
| `Super + Alt + S` | Sogeza dirisha hadi scratchpad kamili |
| `Super + the key above Tab` (grave on US layouts) | Geuza konsoli ya Quake |
| `Super + Shift + the key above Tab` (grave on US layouts) | Sogeza dirisha hadi konsoli ya Quake |
| `Super + Shift + Ctrl + Arrows` | Sogeza dirisha hadi kifuatilia katika mwelekeo huo |
| `Super + Shift + Alt + Arrows` | Sogeza nafasi ya kazi hadi kifuatilia katika mwelekeo huo |
| `Super + Arrow`  | Sogeza mwelekeo hadi dirisha katika mwelekeo wa mshale, ukivuka hadi kifuatilia kilicho upande huo kwenye ukingo wa skrini |
| `Super + Shift + Arrow`  | Badilishana dirisha na jingine katika mwelekeo wa mshale, ikijumuisha lililo kwenye kifuatilia kilicho upande huo |
| `Super + Minus` | Panua dirisha kushoto |
| `Super + Equal` | Punguza dirisha kushoto |
| `Super + Shift + Minus` | Punguza dirisha juu |
| `Super + Shift + Equal` | Panua dirisha chini |
| `Super + Alt + Minus/Equal` | Kubadilisha ukubwa kule kule katika hatua ndogo zaidi |
| `Super + Ctrl + Minus/Equal` | Kubadilisha ukubwa kule kule katika hatua kubwa zaidi |
| `Super + Alt + Home` | Hifadhi upana wa dirisha |
| `Super + Home` | Rejesha upana wa dirisha uliohifadhiwa |
| `Super + Left Mouse` | Buruta dirisha huku na huko |
| `Super + Right Mouse` | Badilisha ukubwa wa dirisha |
| `Super + Scroll Wheel` | Tembeza katika nafasi za kazi kwenye kifuatilia kilicholengwa |
| `Super + G`               | Geuza uundaji wa vikundi vya madirisha      |
| `Super + Alt + G`               | Toa dirisha kutoka kwenye kikundi      |
| `Super + Alt + Tab`               | Zunguka kati ya madirisha katika kikundi      |
| `Super + Alt + Shift + Tab`               | Zunguka kinyume kati ya madirisha katika kikundi      |
| `Super + Alt + Scroll Wheel` | Zunguka kati ya madirisha katika kikundi |
| `Super + Alt + 1/2/3/4/5`               | Ruka hadi dirisha maalum katika kikundi      |
| `Super + Alt + Arrow`  | Sogeza dirisha kuingia katika kikundi katika mwelekeo wa mshale, ikijumuisha lililo kwenye kifuatilia kilicho upande huo |
| `Super + Ctrl + Left/Right`  | Sogeza kati ya madirisha ndani ya kikundi cha vigae |
| `Super + Ctrl + Z` | Kuza skrini (rudia kwa ukuzaji zaidi) |
| `Super + Ctrl + Alt + Z` | Kuza nje kabisa kutoka skrini |
| `Super + /` | Songa mbele katika chaguo za upimaji wa kifuatilia |
| `Super + Alt + /` | Songa nyuma katika chaguo za upimaji wa kifuatilia |
| `Alt + Tab` | Zunguka mbele katika madirisha kwenye nafasi ya kazi inayotumika |
| `Alt + Shift + Tab` | Zunguka nyuma katika madirisha kwenye nafasi ya kazi inayotumika |
| `Ctrl + Alt + Tab`| Zunguka mwelekeo mbele katika vifuatilia |
| `Ctrl + Alt + Shift + Tab`| Zunguka mwelekeo nyuma katika vifuatilia |
| `Super + I` | Badilisha lugha ya ingizo (ukiwa na mpangilio au mbinu ya ingizo zaidi ya moja) |
| `Super + Shift + I` | Badilisha lugha ya ingizo kurudi |

Kwenye padi ya mguso, miinamo ya vidole vitatu na vinne hubadilisha nafasi za kazi, husogeza madirisha, na kufungua menyu na konsoli ya Quake; tazama [kibodi, kipanya, na padi ya mguso](34-keyboard-mouse-trackpad.md) kwa ishara hizo.

Kubadilisha ukubwa hutumia vitefio viwili vilivyo kulia mwa 0, chochote kibodi yako inachapisha juu yake: `-` na `=` kwenye kibodi za US, `+` na `´` kwenye za Kidenmaki na Kiswidi, `+` na `\` kwenye za Kinorwe, `ß` na `´` kwenye za Kijerumani, `'` na `¡` kwenye za Kihispania, na `-` na `^` kwenye za Kijapani (JIS). `Super + K` huvi orodhesha kama kibodi yako inavyovichapisha. Kwenye JIS, `Super + ^` ni `Super + Equal`, ilhali `Super + Shift + -` (ambayo huchapa `=`) ni `Super + Shift + Minus`. Upimaji wa kifuatilia na kidhibiti cha manenosiri hutumia `/`; kwenye mipangilio inayochapa `/` tu ikiwa na Shift, kama mipangilio mingi ya Ulaya inavyofanya, hutumia kitufe kilicho kushoto mwa Shift ya kulia badala yake (`-` kwenye Kidenmaki na Kijerumani).

## Vidhibiti vya mfumo

| Kitefio cha Haraka | Kazi |
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
| `Super + Ctrl + C` | Vidhibiti vya kunasa (picha ya skrini/-kurekodi/kichaguzi) |
| `Super + Ctrl + O` | Geuza menyu |
| `Super + Ctrl + H` | Menyu ya maunzi |
| `Super + Ctrl + E` | Kichaguzi cha emoji |
| `Super + Ctrl + .` | Badilisha umbizo la midia |
| `Super + Shift + Ctrl + A` | Anzisha wakala wako chaguo-msingi |
| `Power` key | Menyu ya mfumo |
| `Super + Shift + Copilot` key | Menyu ya Omarchy |

## Marekebisho

| Kitefio cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Mwangaza wa juu zaidi wa skrini |
| `Shift + Brightness Down` | Mwangaza wa chini zaidi wa skrini |
| `Alt + Brightness Up/Down` | Mabadiliko sahihi ya mwangaza ya 1% |
| `Alt + Volume Up/Down` | Mabadiliko sahihi ya sauti ya 1% |
| `Keyboard Brightness Up/Down` | Mwangaza wa nyuma wa kibodi ung'ae zaidi/ufifie zaidi |
| `Keyboard Backlight` | Zunguka katika viwango vya mwangaza wa nyuma wa kibodi |
| `Ctrl + Brightness Up/Down` | Mwangaza wa nyuma wa kibodi ung'ae zaidi/ufifie zaidi, kwenye kibodi zisizo na vitefio vyake |
| `Mic Mute` | Nyamazisha kipaza sauti |
| `Shift + Mute` | Badilisha towe la sauti |
| `Touchpad Toggle` | Washa au zima padi ya mguso |
| `Display` key | Zunguka katika mpangilio wa nafasi ya kazi |
| `Alt + Play` | Wimbo unaofuata |
| `Alt + Shift + Play` | Wimbo uliopita |

## Kuzindua programu

| Kitefio cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminali    |
| `Super + Alt + Return` | Terminali ya Tmux |
| `Super + Ctrl + Return` | Herdr (kidhibiti cha mawakala) |
| `Super + Shift + Return` or `Super + Shift + B`  | Kivinjari    |
| `Super + Shift + Alt + B`           | Kivinjari (faragha/isiyojulikana)    |
| `Super + Shift + F`           | Kidhibiti cha faili    |
| `Super + Shift + Alt + F`           | Kidhibiti cha faili katika cwd ya terminali    |
| `Super + Shift + M`           | Muziki (Spotify)    |
| `Super + Shift + Alt + M`           | Muziki (cliamp)    |
| `Super + Shift + /`           | Kidhibiti cha manenosiri (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kikokotoo (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, ikishasakinishwa)    |
| `Super + Shift + T`           | Shughuli (btop)    |
| `Super + Shift + N`           | Kihariri (Plain, au chaguo-msingi ulilochagua)  |
| `Super + Shift + C`           | Kalenda ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Barua pepe ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Barua pepe mpya ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Ujumbe (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Ujumbe (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Ujumbe (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Kuandika (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (chapisho jipya) |
| `Super + Shift + Y`           | YouTube |

Badilisha/ongeza viunganisho katika `~/.config/hypr/bindings.lua`.

## Ubao wa kunakili wa jumla

| Kitefio cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + A`           | Chagua vyote katika programu zinazotumia `Ctrl + A`    |
| `Super + C`           | Nakili    |
| `Super + X`           | Kata (si katika terminali)    |
| `Super + V`           | Bandika    |
| `Super + Ctrl + V`           | Kidhibiti cha ubao wa kunakili    |

Kwa kawaida kwenye Linux, unahitaji `Ctrl + Shift + C/V` kunakili na kubandika katika terminali na `Ctrl + C/V` kufanya hivyo kila mahali pengine. Vitefio hivi vya haraka vya ubao wa kunakili vilivyounganishwa vya Omarchy hufanya kazi kila mahali.

## Kunasa

| Kitefio cha Haraka | Kazi |
| ------------------- | ------------------------------ |
| `Print Screen`            | Picha ya skrini                      |
| `Super + Ctrl + Alt + C`            | Picha ya skrini (picha ile ile, kwa kibodi zisizo na kitufe cha Print Screen) |
| `Super + Ctrl + C` | Menyu ya kunasa |
| `Alt + Print Screen`            | Rekodi skrini                     |
| `Super + Shift + Ctrl + Alt + C` | Rekodi skrini bila sauti, ukiruka menyu (bonyeza tena kusitisha) |
| `Super + Print Screen` | Kichaguzi cha rangi |
| `Super + Ctrl + Print Screen` | Uchimbaji wa maandishi hadi ubao wa kunakili |
| `Super + Alt + [` | Fanya wekeleo la webcam kuwa dogo zaidi wakati wa kurekodi |
| `Super + Alt + ]` | Fanya wekeleo la webcam kuwa kubwa zaidi wakati wa kurekodi |
| `Alt + Shift + L` | Nakili URL ya sasa kutoka programu ya wavuti au kivinjari |
| `Alt + Shift + D` | Pakua video iliyo kwenye ukurasa wa sasa hadi `~/Videos` |
| `Alt + Space` | Anzisha/sitisha kuandikisha kwa sauti (inahitaji _Mipangilio > Chaguo-msingi > Kuandikisha kwa sauti_) |
| `Right Alt` | Shikilia ili kuandikisha kwa sauti (inahitaji _Mipangilio > Chaguo-msingi > Kuandikisha kwa sauti_) |

Ukiwa na rekodi za skrini, kitefio cha haraka huuliza kwanza sauti unayotaka, kisha huanza kurekodi. Kibonyeze tena kusitisha. Tazama [picha za skrini na kurekodi](12-screenshots-recording.md) kwa maelezo.

Chaguo zote za kunasa zinapatikana pia chini ya _Kichocheo > Kunasa_ katika menyu ya Omarchy (`Super + Space`).

## Arifa

| Kitefio cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + ,` | Tenda kwenye arifa ya hivi punde zaidi: ifungue au bonyeza kitufe chake pekee, chagua kutoka chaguo zake, au iondoe ikiwa haina chochote  |
| `Super + Shift + ,` | Ondoa arifa zote |
| `Super + Ctrl + ,` | Dhibiti arifa kwa kibodi  |
| `Super + Alt + ,` | Ondoa arifa ya hivi punde zaidi  |
| `Super + Shift + Alt + ,` | Fungua historia ya arifa  |
| `Super + Ctrl + Alt + ,` | Geuza kunyamazisha arifa  |

## Mtindo

| Kitefio cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Chagua mandhari mpya (pia `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Chagua mandharinyuma ya mandhari (pia `Super + Ctrl + Space`) |
| `Super + Backspace` | Geuza uwazi kwenye dirisha |
| `Super + Ctrl + Backspace` | Geuza kipengele cha mraba cha dirisha moja |

Picha za ziada za mandharinyuma hukaa katika `~/.config/omarchy/backgrounds/<theme name>`. Inapatikana pia kupitia _Sakinisha > Mtindo > Mandharinyuma_ katika menyu ya Omarchy.

Chaguo zote za mtindo zinapatikana pia chini ya _Mwonekano_ katika menyu ya Omarchy (`Super + Space`).

## Kugeuza

| Kitefio cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Geuza kufunga wakati hakuna shughuli |
| `Super + Ctrl + Delete` | Geuza onyesho la laptop kuwasha/kuzima |
| `Super + Ctrl + Alt + Delete` | Geuza uakisi wa onyesho la laptop |
| `Super + Shift + Space` | Geuza upau wa juu  |
| `Shift + Mute` | Badilisha hadi towe linalofuata la sauti |
| `Shift + Play` | Badilisha hadi chanzo kinachofuata cha midia |
| `Super + Shift + Backspace` | Geuza mapengo ya madirisha |
| `Super + Ctrl + Alt + F` | Geuza eneo-kazi la skrini nzima (upau wa juu + mapengo ya madirisha) |

## Vikumbusho

| Kitefio cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Weka kikumbusho  |
| `Super + Ctrl + Alt + R` | Tazama vikumbusho vyote  |
| `Super + Ctrl + Shift + R` | Futa vikumbusho vyote  |

## Taarifa

| Kitefio cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Onyesha saa kama arifa  |
| `Super + Ctrl + Alt + B` | Onyesha betri kama arifa  |
| `Super + Ctrl + Alt + W` | Geuza hali ya hewa kama arifa  |

## Tmux

Kitufe cha kiambishi awali ni `Ctrl + Space` (`Ctrl + B` pia hufanya kazi). Unaweza kubadilisha viunganisho hivi katika `~/.config/tmux/tmux.conf`.

### Vipande

| Kitefio cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Prefix + v` | Gawanya kipande kando (wima) |
| `Prefix + h` | Gawanya kipande chini (mlalo) |
| `Prefix + x` | Ua kipande |
| `Prefix + z` | Geuza ukuzaji wa kipande (skrini nzima) |
| `Alt + Enter` | Gawanya kipande chini (hakuna kiambishi awali) |
| `Alt + Shift + Enter` | Gawanya kipande kando (hakuna kiambishi awali) |
| `Alt + Escape` | Ua kipande (hakuna kiambishi awali) |
| `Ctrl + Alt + Arrows` | Sogeza kati ya vipande |
| `Ctrl + Alt + Shift + Arrows` | Badilisha ukubwa wa vipande |

### Madirisha

| Kitefio cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Prefix + c` | Dirisha jipya |
| `Prefix + k` | Ua dirisha |
| `Prefix + r` | Badilisha jina la dirisha |
| `Alt + 1-9` | Nenda hadi dirisha maalum |
| `Alt + Arrow Left/Right` | Sogeza kati ya madirisha |
| `Alt + Shift + Arrow Left/Right` | Sogeza dirisha kushoto/kulia |

### Vipindi

| Kitefio cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Prefix + C` | Kipindi kipya |
| `Prefix + K` | Ua kipindi |
| `Prefix + R` | Badilisha jina la kipindi |
| `Prefix + N` | Kipindi kinachofuata |
| `Prefix + P` | Kipindi kilichopita |
| `Alt + Arrow Up/Down` | Sogeza kati ya vipindi |
| `Prefix + s` | Orodhesha vipindi |
| `Prefix + d` | Jitenge kutoka kipindi |

### Hali ya kunakili (mtindo wa vi)

| Kitefio cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Prefix + [` | Ingia hali ya kunakili |
| `v` | Anza uteuzi (katika hali ya kunakili) |
| `y` | Nakili uteuzi (katika hali ya kunakili) |

### Jumla

| Kitefio cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Prefix + q` | Pakia upya usanidi |
| `Prefix + ?` | Onyesha viunganisho vya vitefio vya Tmux |
| `Prefix + :` | Kidokezo cha amri |

### Vitendakazi vya mpangilio wa Tmux

Vitendakazi hivi lazima viendeshwe ndani ya kipindi cha Tmux.

| Amri | Kazi |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Unda mpangilio wa uendelezaji na kihariri, AI, na terminali |
| `tdlm <ai> [<second_ai>]` | Unda mpangilio wa uendelezaji kwa kila saraka ndogo |
| `tsl <count> <command>` | Unda mpangilio wa kundi wa vipande vingi |

## Terminali ya Ghostty

Terminali ya Ghostty husakinishwa kwa kutumia _Sakinisha > Terminali_ kupitia menyu ya Omarchy.

| Kitefio cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Mgawanyiko mpya chini |
| `Ctrl + Shift + O` | Mgawanyiko mpya kando |
| `Ctrl + Alt + Arrows` | Sogeza kati ya migawanyiko |
| `Super + Ctrl + Shift + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 10 |
| `Super + Ctrl + Shift + Alt + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 100 |
| `Ctrl + Shift + T` | Kichupo kipya  |
| `Ctrl + Shift + Arrows` | Sogeza kati ya vichupo |
| `Alt + Numbers` | Nenda hadi kichupo maalum |
| `Shift + Pg Up/Down` | Tembeza historia |
| `Ctrl + Left mouse` | Fungua kiungo katika kivinjari |

## Kidhibiti cha Faili

| Kitefio cha Haraka | Kazi |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Nenda hadi njia                     |
| `Space`               | Hakiki faili mapema (mishale hupitia) |
| `Alt + Up`       | Nenda juu hadi folda mzazi        |

## Neovim (na lazyvim)

### Kuabiri

| Kitefio cha Haraka | Kazi |
| ------------------------ | ------------------------------- |
| `Space`                    | Onyesha chaguo za amri            |
| `Space Space`              | Fungua faili kupitia utafutaji fuzzy      |
| `Space E`                  | Geuza upau wa pembeni                  |
| `Space G G`                | Onyesha vidhibiti vya git               |
| `Space S G`                | Tafuta maudhui ya faili             |
| `Ctrl + W W`               | Ruka kati ya upau wa pembeni na kihariri |
| `Ctrl + Left/right arrow`  | Badilisha ukubwa wa upau wa pembeni          |
| `Shift + H`                      | Nenda hadi kichupo cha faili cha kushoto             |
| `Shift + L`                      | Nenda hadi kichupo cha faili cha kulia            |
| `Space B D`                | Funga kichupo cha faili                  |

### Ukiwa kwenye upau wa pembeni

| Kitefio cha Haraka | Kazi |
| ------------------------ | ------------------------------- |
| `A`                        | Ongeza faili mpya katika saraka mzazi      |
| `Shift + A`                | Ongeza saraka ndogo mpya katika saraka mzazi    |
| `D`                        | Futa faili/saraka iliyoangaziwa     |
| `M`                        | Sogeza faili/saraka iliyoangaziwa       |
| `R`                        | Badilisha jina la faili/saraka iliyoangaziwa     |
| `?`                        | Onyesha msaada kwa amri zote      |

[Tazama vitefio vyote vya haraka vya Neovim vilivyosanidiwa na LazyVim](https://www.lazyvim.org/keymaps).

## Emoji za Haraka

Unaweza kutumia `Super + Ctrl + E` kuonyesha kichaguzi kamili cha emoji ambacho kitaweka ulichochagua kwenye ubao wa kunakili au unaweza kutumia chaguo hizi za ufikiaji wa haraka.

| Kitefio cha Haraka | EM | Kidokezo |
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
| `Shift + CapsLock M B` |🤯 | kulipuka |

## Ukamilishaji wa Haraka

| Kitefio cha Haraka | Ukamilishaji |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Jina lako (kama lilivyoingizwa wakati wa usanidi)  |
| `Shift + CapsLock Space E` | Barua pepe yako (kama ilivyoingizwa wakati wa usanidi)  |

Unaweza kuongeza zaidi yako mwenyewe kwa kuhariri `~/.XCompose`, kisha kuendesha `omarchy restart xcompose` katika terminali ili mabadiliko yachukuliwe.
