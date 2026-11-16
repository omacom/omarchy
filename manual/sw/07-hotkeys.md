# Vifunguo vya Haraka

Unaweza kuona vifunguo vyote vikuu vya kibodi kwa `Super + K` (vifunguo vya Tmux kwa `Super + Alt + K` na vifunguo vya Herdr kwa `Super + Ctrl + K`).

## Jinsi vifunguo vya haraka vilivyopangwa

Kila kifunguo cha haraka kiko kwenye tabaka moja, lililowekwa na virekebishaji vyake, na kila tabaka lina kazi moja. Hilo ndilo linalozuia vifunguo vya haraka visichanganyike, na linamaanisha kwa kawaida unaweza kukisia kitu kiko wapi.

| Tabaka | Kinachoishi huko | Mifano |
| --- | --- | --- |
| `Super + key` | Mfumo: madirisha, nafasi za kazi, mipangilio, na menyu za msingi | `Super + Space` menyu ya Omarchy, `Super + W` funga dirisha, `Super + F` skrini nzima |
| `Super + Shift + key` | Programu | `Super + Shift + B` kivinjari, `Super + Shift + E` barua pepe, `Super + Shift + N` kihariri |
| `Super + Ctrl + key` | Paneli na menyu za mfumo | `Super + Ctrl + A` sauti, `Super + Ctrl + N` mtandao, `Super + Ctrl + C` menyu ya kunasa |
| `Super + Ctrl + Alt + key` | Vitendo vya haraka na taarifa | `Super + Ctrl + Alt + T` onyesha saa, `Super + Ctrl + Alt + B` betri, `Super + Ctrl + Alt + C` picha ya skrini |

Kuongeza `Alt` kwenye kifunguo cha haraka hukupa lahaja ya kitu kile kile, kamwe si kitu kisichohusiana:

- `Super + Shift + B` hufungua kivinjari; `Super + Shift + Alt + B` hufungua dirisha la faragha
- `Super + Shift + E` hufungua barua pepe; `Super + Shift + Alt + E` huanzisha mpya
- `Super + F` huenda skrini nzima; `Super + Alt + F` huenda upana mzima
- `Super + Ctrl + C` hufungua menyu ya kunasa; `Super + Ctrl + Alt + C` huruka menyu na kupiga picha ya skrini

Unapoongeza kifunguo cha haraka:

1. Chagua tabaka kutokana na kile kinachofanya, kisha chagua kifunguo.
2. Usisogeze kifunguo cha haraka kilichopo ili kupata nafasi. Tafuta kifunguo kilicho wazi kwenye tabaka sahihi.
3. Tumia `Alt` tu kwa lahaja ya kifunguo cha haraka kisicho nayo.

Vifunguo vichache vya haraka huvunja sheria hizi kwa sababu ni rahisi. `Shift` ikiwa na mshale au `Tab` husogeza au hubadilisha mwelekeo badala ya kufungua programu, na `Print`, vifunguo vya media, `Alt + Tab`, na `Ctrl + Alt + Del` hufanya kazi kama zinavyofanya kwingineko. Hizo ni tofauti, si mifumo ya kuiga.

Ikiwa chaguo-msingi halikufai (tuseme unataka `Super + Shift + S` kwa picha za skrini kama kwenye Windows), libadilishe katika `~/.config/hypr/bindings.lua`.

## Urambazaji

| Kifunguo cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + Space` | Menyu ya Omarchy (programu na kila kitu kingine) |
| `Super + Alt + Space` | Gridi ya programu |
| `Super + Escape` | Menyu ya mfumo (simamisha, anzisha upya, n.k.) |
| `Super + Ctrl + L` | Funga kompyuta |
| `Super + W` or `Super + Q` | Funga dirisha |
| `Ctrl + Alt + Del` | Funga madirisha yote |
| `Super + T` | Geuza dirisha kati ya kuweka vigae/kuelea |
| `Super + J` | Geuza nafasi ya dirisha (mlalo/wima) |
| `Super + O` | Geuza dirisha linalojitokeza kuwa linalonata na kuelea |
| `Super + L` | Zunguka kupitia mipangilio ya dwindle, scrolling, na floating |
| `Super + Alt + L` | Zunguka kupitia mipangilio kinyume chake |
| `Super + P` | Geuza mtindo wa dirisha bandia (asili dhidi ya kunyoosha) |
| `Super + F` | Nenda skrini nzima |
| `Super + Alt + F` | Nenda upana mzima |
| `Super + Ctrl + F` | Nenda skrini nzima ndani ya dirisha |
| `Super + 1/2/3/4` | Ruka hadi kwenye nafasi maalum ya kazi kwenye kifuatilia kilicholengwa |
| `Super + Tab` | Ruka hadi kwenye nafasi ya kazi inayofuata kwenye kifuatilia kilicholengwa |
| `Super + Shift + Tab` | Ruka hadi kwenye nafasi ya kazi iliyopita kwenye kifuatilia kilicholengwa |
| `Super + Ctrl + Tab` | Ruka hadi kwenye nafasi ya kazi ya awali kwenye kifuatilia kilicholengwa |
| `Super + Shift + 1/2/3/4` | Sogeza dirisha hadi kwenye nafasi ya kazi kwenye kifuatilia kilicholengwa |
| `Super + Shift + Alt + 1/2/3/4` | Sogeza dirisha hadi kwenye nafasi ya kazi kwenye kifuatilia kilicholengwa bila kulifuata |
| `Super + S` | Geuza scratchpad nzima |
| `Super + Alt + S` | Sogeza dirisha hadi kwenye scratchpad nzima |
| `Super + Grave` | Geuza koni ya Quake |
| `Super + Shift + Grave` | Sogeza dirisha hadi kwenye koni ya Quake |
| `Super + Shift + Ctrl + Arrows` | Sogeza dirisha hadi kwenye kifuatilia katika mwelekeo huo |
| `Super + Shift + Alt + Arrows` | Sogeza nafasi ya kazi hadi kwenye kifuatilia katika mwelekeo huo |
| `Super + Arrow` | Sogeza lengo hadi kwenye dirisha katika mwelekeo wa mshale, ukivuka hadi kwenye kifuatilia kilicho upande huo kwenye ukingo wa skrini |
| `Super + Shift + Arrow` | Badilishana dirisha na jingine katika mwelekeo wa mshale, ikiwa ni pamoja na lililo kwenye kifuatilia kilicho upande huo |
| `Super + Minus` | Panua dirisha kushoto |
| `Super + Equal` | Punguza dirisha kushoto |
| `Super + Shift + Minus` | Punguza dirisha juu |
| `Super + Shift + Equal` | Panua dirisha chini |
| `Super + Alt + Minus/Equal` | Ubadilishaji ukubwa ule ule katika hatua ndogo zaidi |
| `Super + Ctrl + Minus/Equal` | Ubadilishaji ukubwa ule ule katika hatua kubwa zaidi |
| `Super + Alt + Home` | Hifadhi upana wa dirisha |
| `Super + Home` | Rejesha upana wa dirisha uliohifadhiwa |
| `Super + Left Mouse` | Buruta dirisha huku na huku |
| `Super + Right Mouse` | Badilisha ukubwa wa dirisha |
| `Super + Scroll Wheel` | Tembeza kupitia nafasi za kazi kwenye kifuatilia kilicholengwa |
| `Super + G` | Geuza uwekaji wa dirisha katika kikundi |
| `Super + Alt + G` | Sogeza dirisha kutoka kwenye kikundi |
| `Super + Alt + Tab` | Zunguka kati ya madirisha katika kikundi |
| `Super + Alt + Shift + Tab` | Zunguka nyuma kati ya madirisha katika kikundi |
| `Super + Alt + Scroll Wheel` | Zunguka kati ya madirisha katika kikundi |
| `Super + Alt + 1/2/3/4/5` | Ruka hadi kwenye dirisha maalum katika kikundi |
| `Super + Alt + Arrow` | Sogeza dirisha kuingia kwenye kikundi katika mwelekeo wa mshale, ikiwa ni pamoja na lililo kwenye kifuatilia kilicho upande huo |
| `Super + Ctrl + Left/Right` | Sogeza kati ya madirisha ndani ya kikundi cha kuweka vigae |
| `Super + Ctrl + Z` | Kuza ndani kwenye skrini (r repeat kwa ukuzaji zaidi) |
| `Super + Ctrl + Alt + Z` | Kuza nje kabisa kutoka kwenye skrini |
| `Super + /` | Piga hatua mbele kupitia chaguo za upimaji wa kifuatilia |
| `Super + Alt + /` | Piga hatua nyuma kupitia chaguo za upimaji wa kifuatilia |
| `Alt + Tab` | Zunguka mbele kupitia madirisha kwenye nafasi ya kazi inayotumika |
| `Alt + Shift + Tab` | Zunguka nyuma kupitia madirisha kwenye nafasi ya kazi inayotumika |
| `Ctrl + Alt + Tab` | Zungusha lengo mbele kupitia vifuatilia |
| `Ctrl + Alt + Shift + Tab` | Zungusha lengo nyuma kupitia vifuatilia |

Mikato ya kubadilisha ukubwa hutumia vifunguo halisi `code:20` na `code:21` (XKB `<AE11>` na `<AE12>`), bila kujali herufi zilizochapishwa kwenye kibodi. Kwenye kibodi za US vifunguo hivi ni `-` na `=`; kwenye kibodi za Kijapani (JIS) ni `-` na `^`; kwenye kibodi za Kihispania ni `'` na `¡`. Kwenye JIS, `Super + ^` ni `Super + Equal`, ilhali `Super + Shift + -` (ambayo huchapa `=`) ni `Super + Shift + Minus`.

## Vidhibiti vya mfumo

| Kifunguo cha Haraka | Kazi |
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
| `Super + Ctrl + C` | Vidhibiti vya kunasa (picha ya skrini/-kurekodi/kiteua) |
| `Super + Ctrl + O` | Menyu ya kugeuza |
| `Super + Ctrl + H` | Menyu ya vifaa |
| `Super + Ctrl + E` | Kiteua emoji |
| `Super + Ctrl + .` | Badilisha umbizo la media |
| `Super + Shift + Ctrl + A` | Chagua wakala wa AI |

## Marekebisho

| Kifunguo cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Mwangaza wa juu kabisa wa skrini |
| `Shift + Brightness Down` | Mwangaza wa chini kabisa wa skrini |
| `Alt + Brightness Up/Down` | Mabadiliko sahihi ya mwangaza ya 1% |
| `Alt + Volume Up/Down` | Mabadiliko sahihi ya sauti ya 1% |
| `Keyboard Brightness Up/Down` | Mwangaza wa nyuma wa kibodi uwe mkali zaidi/mdogo zaidi |
| `Keyboard Backlight` | Zunguka viwango vya mwangaza wa nyuma wa kibodi |
| `Alt + Play` | Wimbo unaofuata |
| `Alt + Shift + Play` | Wimbo uliopita |

## Kufungua programu

| Kifunguo cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Terminal ya Tmux |
| `Super + Ctrl + Return` | Herdr (kidhibiti cha mawakala) |
| `Super + Shift + Return` | Kivinjari |
| `Super + Shift + Alt + B` | Kivinjari (faragha/incognito) |
| `Super + Shift + F` | Kidhibiti faili |
| `Super + Shift + Alt + F` | Kidhibiti faili katika cwd ya terminal |
| `Super + Shift + M` | Muziki (Spotify) |
| `Super + Shift + Alt + M` | Muziki (cliamp) |
| `Super + Shift + /` | Kidhibiti cha manenosiri (1password) |
| `Super + Shift + Q` | Kikokotoo (Omacalc) |
| `Super + Shift + T` | Shughuli (btop) |
| `Super + Shift + N` | Kihariri (Neovim) |
| `Super + Shift + C` | Kalenda ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Barua pepe ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Barua pepe mpya ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Programu ya ujumbe (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Programu ya ujumbe (WhatsApp) |
| `Super + Shift + Ctrl + G` | Programu ya ujumbe (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Kuandika (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

Badilisha/ongeza vifunguo katika `~/.config/hypr/bindings.lua`.

## Ubao wa kunakili wa kila mahali

| Kifunguo cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + A` | Chagua vyote katika programu zinazotumia `Ctrl + A` |
| `Super + C` | Nakili |
| `Super + X` | Kata (si katika terminal) |
| `Super + V` | Bandika |
| `Super + Ctrl + V` | Kidhibiti cha ubao wa kunakili |

Kwa kawaida kwenye Linux, unahitaji `Ctrl + Shift + C/V` ili kunakili na kubandika katika terminal na `Ctrl + C/V` kufanya hivyo kwingineko. Vifunguo hivi vya haraka vya ubao wa kunakili vilivyounganishwa vya Omarchy hufanya kazi kila mahali.

## Kunasa

| Kifunguo cha Haraka | Kazi |
| ------------------- | ------------------------------ |
| `Print Screen` | Picha ya skrini |
| `Super + Ctrl + Alt + C` | Picha ya skrini (picha ile ile, kwa kibodi zisizo na kifunguo cha Print Screen) |
| `Super + Ctrl + C` | Menyu ya kunasa |
| `Alt + Print Screen` | Rekodi skrini |
| `Super + Print Screen` | Kiteua rangi |
| `Super + Ctrl + Print Screen` | Kutoa maandishi hadi kwenye ubao wa kunakili |
| `Super + Alt + [` | Fanya ufunikaji wa webcam uwe mdogo wakati wa kurekodi |
| `Super + Alt + ]` | Fanya ufunikaji wa webcam uwe mkubwa wakati wa kurekodi |
| `Alt + Shift + L` | Nakili URL ya sasa kutoka kwenye webapp au kivinjari |
| `Alt + Shift + D` | Pakua video iliyo kwenye ukurasa wa sasa hadi `~/Videos` |
| `Alt + Space` | Anza/simamisha uandikaji wa sauti (inahitaji _Setup > Defaults > Dictation_) |
| `Right Alt` | Shikilia ili kuandika kwa sauti (inahitaji _Setup > Defaults > Dictation_) |

Ukiwa na rekodi za skrini, kifunguo cha haraka kwanza huuliza ni sauti gani unayotaka, kisha huanza kurekodi. Kibonyeze tena ili kusimamisha. Tazama [picha za skrini na kurekodi](12-screenshots-recording.md) kwa maelezo.

Chaguo zote za kunasa pia zinapatikana chini ya _Trigger > Capture_ katika menyu ya Omarchy (`Super + Space`).

## Arifa

| Kifunguo cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + ,` | Tenda kwenye arifa ya hivi karibuni: ifungue au bonyeza kitufe chake pekee, chagua kutoka kwenye chaguo zake, au iondoe ikiwa haina chochote |
| `Super + Shift + ,` | Ondoa arifa zote |
| `Super + Ctrl + ,` | Dhibiti arifa kwa kibodi |
| `Super + Alt + ,` | Ondoa arifa ya hivi karibuni |
| `Super + Shift + Alt + ,` | Fungua historia ya arifa |
| `Super + Ctrl + Alt + ,` | Geuza kunyamazisha arifa |

## Mtindo

| Kifunguo cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Chagua mandhari mpya (pia `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Chagua usuli wa mandhari (pia `Super + Ctrl + Space`) |
| `Super + Backspace` | Geuza uwazi kwenye dirisha |
| `Super + Ctrl + Backspace` | Geuza uwiano wa mraba wa dirisha moja |

Picha za ziada za usuli ziko katika `~/.config/omarchy/backgrounds/<theme name>`. Pia zinapatikana kupitia _Install > Style > Background_ katika menyu ya Omarchy.

Chaguo zote za mtindo pia zinapatikana chini ya _Style_ katika menyu ya Omarchy (`Super + Space`).

## Vigeuzaji

| Kifunguo cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Geuza kufunga wakati wa kutofanya kazi |
| `Super + Ctrl + Delete` | Geuza onyesho la laptop kuwasha/kuzima |
| `Super + Ctrl + Alt + Delete` | Geuza kuakisi onyesho la laptop |
| `Super + Shift + Space` | Geuza upau wa juu |
| `Shift + Mute` | Badilisha hadi kwenye kitoa sauti kinachofuata |
| `Shift + Play` | Badilisha hadi kwenye chanzo cha media kinachofuata |
| `Super + Shift + Backspace` | Geuza mapengo ya madirisha |
| `Super + Ctrl + Alt + F` | Geuza eneo-kazi la skrini nzima (upau wa juu + mapengo ya madirisha) |

## Vikumbusho

| Kifunguo cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Weka kikumbusho |
| `Super + Ctrl + Alt + R` | Tazama vikumbusho vyote |
| `Super + Ctrl + Shift + R` | Futa vikumbusho vyote |

## Taarifa

| Kifunguo cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Onyesha saa kama arifa |
| `Super + Ctrl + Alt + B` | Onyesha betri kama arifa |
| `Super + Ctrl + Alt + W` | Geuza hali ya hewa kama arifa |

## Tmux

Kifunguo cha kiambishi awali ni `Ctrl + Space` (`Ctrl + B` pia hufanya kazi). Unaweza kubadilisha vifunguo hivi katika `~/.config/tmux/tmux.conf`.

### Paneli

| Kifunguo cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Prefix + v` | Gawanya paneli kando (wima) |
| `Prefix + h` | Gawanya paneli chini (mlalo) |
| `Prefix + x` | Ua paneli |
| `Prefix + z` | Geuza ukuzaji wa paneli (skrini nzima) |
| `Alt + Enter` | Gawanya paneli chini (hakuna kiambishi awali) |
| `Alt + Shift + Enter` | Gawanya paneli kando (hakuna kiambishi awali) |
| `Alt + Escape` | Ua paneli (hakuna kiambishi awali) |
| `Ctrl + Alt + Arrows` | Sogeza kati ya paneli |
| `Ctrl + Alt + Shift + Arrows` | Badilisha ukubwa wa paneli |

### Madirisha

| Kifunguo cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Prefix + c` | Dirisha jipya |
| `Prefix + k` | Ua dirisha |
| `Prefix + r` | Badilisha jina la dirisha |
| `Alt + 1-9` | Nenda kwenye dirisha maalum |
| `Alt + Arrow Left/Right` | Sogeza kati ya madirisha |
| `Alt + Shift + Arrow Left/Right` | Sogeza dirisha kushoto/kulia |

### Vipindi

| Kifunguo cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Prefix + C` | Kipindi kipya |
| `Prefix + K` | Ua kipindi |
| `Prefix + R` | Badilisha jina la kipindi |
| `Prefix + N` | Kipindi kinachofuata |
| `Prefix + P` | Kipindi kilichopita |
| `Alt + Arrow Up/Down` | Sogeza kati ya vipindi |
| `Prefix + s` | Orodhesha vipindi |
| `Prefix + d` | Jitenge na kipindi |

### Hali ya kunakili (mtindo wa vi)

| Kifunguo cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Prefix + [` | Ingia hali ya kunakili |
| `v` | Anza uteuzi (katika hali ya kunakili) |
| `y` | Nakili uteuzi (katika hali ya kunakili) |

### Jumla

| Kifunguo cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Prefix + q` | Pakia upya usanidi |
| `Prefix + ?` | Onyesha vifunguo vya Tmux |
| `Prefix + :` | Kidokezo cha amri |

### Vitendaji vya mpangilio wa Tmux

Vitendaji hivi lazima viendeshwe ndani ya kipindi cha Tmux.

| Amri | Kazi |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Unda mpangilio wa uendelezaji wenye kihariri, AI, na terminal |
| `tdlm <ai> [<second_ai>]` | Unda mpangilio wa uendelezaji kwa kila saraka ndogo |
| `tsl <count> <command>` | Unda mpangilio wa kundi wa paneli nyingi |

## Terminal ya Ghostty

Terminal ya Ghostty husakinishwa kwa kutumia _Install > Terminal_ kupitia menyu ya Omarchy.

| Kifunguo cha Haraka | Kazi |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Mgawanyiko mpya chini |
| `Ctrl + Shift + O` | Mgawanyiko mpya kando |
| `Ctrl + Alt + Arrows` | Sogeza kati ya migawanyiko |
| `Super + Ctrl + Shift + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 10 |
| `Super + Ctrl + Shift + Alt + Arrows` | Badilisha ukubwa wa mgawanyiko kwa mistari 100 |
| `Ctrl + Shift + T` | Kichupo kipya |
| `Ctrl + Shift + Arrows` | Sogeza kati ya vichupo |
| `Alt + Numbers` | Nenda kwenye kichupo maalum |
| `Shift + Pg Up/Down` | Tembeza historia |
| `Ctrl + Left mouse` | Fungua kiungo katika kivinjari |

## Kidhibiti Faili

| Kifunguo cha Haraka | Kazi |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Nenda kwenye njia |
| `Space` | Hakiki faili (mishale hupita) |
| `Alt + Up` | Nenda juu kwenye folda mzazi |

## Neovim (w/ lazyvim)

### Urambazaji

| Kifunguo cha Haraka | Kazi |
| ------------------------ | ------------------------------- |
| `Space` | Onyesha chaguo za amri |
| `Space Space` | Fungua faili kupitia utafutaji wa fuzzy |
| `Space E` | Geuza upau wa pembeni |
| `Space G G` | Onyesha vidhibiti vya git |
| `Space S G` | Tafuta maudhui ya faili |
| `Ctrl + W W` | Ruka kati ya upau wa pembeni na kihariri |
| `Ctrl + Left/right arrow` | Badilisha ukubwa wa upau wa pembeni |
| `Shift + H` | Nenda kwenye kichupo cha faili cha kushoto |
| `Shift + L` | Nenda kwenye kichupo cha faili cha kulia |
| `Space B D` | Funga kichupo cha faili |

### Ukiwa katika upau wa pembeni

| Kifunguo cha Haraka | Kazi |
| ------------------------ | ------------------------------- |
| `A` | Ongeza faili mpya katika saraka mzazi |
| `Shift + A` | Ongeza saraka ndogo mpya katika saraka mzazi |
| `D` | Futa faili/saraka iliyoangaziwa |
| `M` | Sogeza faili/saraka iliyoangaziwa |
| `R` | Badilisha jina la faili/saraka iliyoangaziwa |
| `?` | Onyesha usaidizi kwa amri zote |

[Tazama vifunguo vyote vya haraka vya Neovim vilivyosanidiwa na LazyVim](https://www.lazyvim.org/keymaps).

## Emoji za Haraka

Unaweza kutumia `Super + Ctrl + E` kuonyesha kiteua kamili cha emoji ambacho kitaweka uteuzi kwenye ubao wa kunakili au unaweza kutumia chaguo hizi za ufikiaji wa haraka.

| Kifunguo cha Haraka | EM | Kidokezo |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | tabasamu |
| `Shift + CapsLock M C` | 😂 | lia |
| `Shift + CapsLock M L` | 😍 | upendo |
| `Shift + CapsLock M V` | ✌️ | ushindi |
| `Shift + CapsLock M H` | ❤️ | moyo |
| `Shift + CapsLock M Y` | 👍 | ndio |
| `Shift + CapsLock M N` | 👎 | hapana |
| `Shift + CapsLock M F` | 🖕 | tusi |
| `Shift + CapsLock M W` | 🤞 | tamani |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | busu |
| `Shift + CapsLock M E` | 🙄 | zungusha macho |
| `Shift + CapsLock M I` | 😉 | konyeza |
| `Shift + CapsLock M P` | 🙏 | omba |
| `Shift + CapsLock M D` | 🤤 | dondosha mate |
| `Shift + CapsLock M M` | 💰 | pesa |
| `Shift + CapsLock M X` | 🎉 | sherehekea |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | shangilia |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | salamu |
| `Shift + CapsLock M A` |💪 | mkono |
| `Shift + CapsLock M B` |🤯 | butwaa |

## Ukamilishaji wa Haraka

| Kifunguo cha Haraka | Ukamilishaji |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Jina lako (kama lilivyoingizwa wakati wa usanidi) |
| `Shift + CapsLock Space E` | Barua pepe yako (kama ilivyoingizwa wakati wa usanidi) |

Unaweza kuongeza zaidi yako mwenyewe kwa kuhariri `~/.XCompose`, kisha kuendesha `omarchy-restart-xcompose` katika terminal ili mabadiliko yachukuliwe.
