# Flýtilyklar

Þú getur séð allar helstu lyklaborðsbindingar með `Super + K` (Tmux-bindingar með `Super + Alt + K` og Herdr-bindingar með `Super + Ctrl + K`).

## Hvernig flýtilyklar eru lagðir upp

Sérhver flýtilykill situr á plani, ákvarðað af breytilyklum hans, og hvert plan hefur eitt verk. Það heldur flýtilyklunum aðgreindum og þýðir að þú getur yfirleitt giskað á hvar eitthvað býr.

| Plan | Hvað býr þar | Dæmi |
| --- | --- | --- |
| `Super + key` | Kerfið: gluggar, vinnusvæði, útlit og kjarnavalmyndir | `Super + Space` Omarchy-valmynd, `Super + W` loka glugga, `Super + F` fullur skjár |
| `Super + Shift + key` | Forrit | `Super + Shift + B` vafri, `Super + Shift + E` tölvupóstur, `Super + Shift + N` ritill |
| `Super + Ctrl + key` | Spjöld og kerfisvalmyndir | `Super + Ctrl + A` hljóð, `Super + Ctrl + N` net, `Super + Ctrl + C` upptökuvalmynd |
| `Super + Ctrl + Alt + key` | Flýtiaðgerðir og tilkynningar | `Super + Ctrl + Alt + T` sýna tíma, `Super + Ctrl + Alt + B` rafhlaða, `Super + Ctrl + Alt + C` skjámynd |

Að bæta `Alt` við flýtilykil gefur þér afbrigði af sama hlut, aldrei eitthvað ótengt:

- `Super + Shift + B` opnar vafrann; `Super + Shift + Alt + B` opnar einkaglugga
- `Super + Shift + E` opnar tölvupóst; `Super + Shift + Alt + E` byrjar nýjan
- `Super + F` fer í fullan skjá; `Super + Alt + F` fer í fulla breidd
- `Super + Ctrl + C` opnar upptökuvalmyndina; `Super + Ctrl + Alt + C` sleppir valmyndinni og tekur skjámynd

Þegar þú bætir við flýtilykli:

1. Veldu planið út frá því hvað hann gerir, veldu síðan lykilinn.
2. Ekki færa núverandi flýtilykil til að búa til pláss. Finndu lausan lykil á réttu plani.
3. Notaðu `Alt` aðeins fyrir afbrigði af flýtilyklinum án hans.

Nokkrir flýtilyklar brjóta þessar reglur því þeir eru þægilegir. `Shift` með ör eða `Tab` færir eða snýr við í stað þess að opna forrit, og `Print`, miðlunarlyklarnir, `Alt + Tab` og `Ctrl + Alt + Del` virka eins og þeir gera alls staðar annars staðar. Þeir eru undantekningar, ekki mynstur til að afrita.

Ef sjálfgefin binding hentar þér ekki (segjum að þú viljir `Super + Shift + S` fyrir skjámyndir eins og á Windows), skaltu endurbinda hana í `~/.config/hypr/bindings.lua`.

## Leiðsögn

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-valmynd (forrit og allt annað)    |
| `Super + Alt + Space` | Forritarist |
| `Super + Escape` | Kerfisvalmynd (setja í bið, endurræsa o.s.frv.)  |
| `Super + Ctrl + L` | Læsa tölvu |
| `Super + W` or `Super + Q` | Loka glugga             |
| `Ctrl + Alt + Del` | Loka öllum gluggum |
| `Super + K` | Sýna alla flýtilykla |
| `Super + Alt + K` | Sýna tmux-flýtilykla |
| `Super + Ctrl + K` | Sýna herdr-flýtilykla |
| `Super + M` | Lágmarka glugga í dokkuna |
| `Super + T`               | Skipta glugga á milli flísalagningar/fljótandi             |
| `Super + J` | Skipta um stöðu glugga (lárétt/lóðrétt) |
| `Super + O`               | Skipta glugga yfir í sticky'n'floating |
| `Super + L`               | Fara í gegnum útlitin dwindle, scrolling og floating |
| `Super + Alt + L`         | Fara í gegnum útlitin í öfugri röð |
| `Super + P`               | Skipta um pseudo-gluggastíl (náttúrulegur á móti teygður) |
| `Super + F`                 | Fara í fullan skjá              |
| `Super + Alt + F`                 | Fara í fulla breidd              |
| `Super + Ctrl + F`                 | Fara í fullan skjá inni í glugga              |
| `Super + 1…9/0`         | Hoppa á ákveðið vinnusvæði (0 er 10) á skjánum sem er í fókus |
| `Super + Tab` | Hoppa á næsta vinnusvæði á skjánum sem er í fókus |
| `Super + Shift + Tab` | Hoppa á fyrra vinnusvæði á skjánum sem er í fókus |
| `Super + Ctrl + Tab` | Hoppa á fyrrum vinnusvæði á skjánum sem er í fókus |
| `Super + Shift + 1…9/0` | Færa glugga á vinnusvæði á skjánum sem er í fókus |
| `Super + Shift + Alt + 1…9/0` | Færa glugga á vinnusvæði á skjánum sem er í fókus án þess að fylgja eftir |
| `Super + S` | Skipta um fulla kladdablokk |
| `Super + Alt + S` | Færa glugga á fulla kladdablokk |
| `Super + the key above Tab` (grave on US layouts) | Skipta um Quake-stjórnborð |
| `Super + Shift + the key above Tab` (grave on US layouts) | Færa glugga á Quake-stjórnborð |
| `Super + Shift + Ctrl + Arrows` | Færa glugga á skjáinn í þá átt |
| `Super + Shift + Alt + Arrows` | Færa vinnusvæði á skjáinn í þá átt |
| `Super + Arrow`  | Færa fókus á glugga í örvarátt, yfir á skjáinn þeim megin við jaðar skjásins |
| `Super + Shift + Arrow`  | Skipta glugga við annan í örvarátt, þar með talinn einn á skjánum þeim megin |
| `Super + Minus` | Stækka glugga til vinstri |
| `Super + Equal` | Minnka glugga til vinstri |
| `Super + Shift + Minus` | Minnka glugga upp |
| `Super + Shift + Equal` | Stækka glugga niður |
| `Super + Alt + Minus/Equal` | Sama stærðarbreyting í minni skrefum |
| `Super + Ctrl + Minus/Equal` | Sama stærðarbreyting í stærri skrefum |
| `Super + Alt + Home` | Vista breidd glugga |
| `Super + Home` | Endurheimta vistaða breidd glugga |
| `Super + Left Mouse` | Draga glugga um |
| `Super + Right Mouse` | Breyta stærð glugga |
| `Super + Scroll Wheel` | Skruna í gegnum vinnusvæði á skjánum sem er í fókus |
| `Super + G`               | Skipta um flokkun glugga      |
| `Super + Alt + G`               | Færa glugga úr flokkun      |
| `Super + Alt + Tab`               | Fara á milli glugga í flokkun      |
| `Super + Alt + Shift + Tab`               | Fara aftur á bak á milli glugga í flokkun      |
| `Super + Alt + Scroll Wheel` | Fara á milli glugga í flokkun |
| `Super + Alt + 1/2/3/4/5`               | Hoppa á ákveðinn glugga í flokkun      |
| `Super + Alt + Arrow`  | Færa glugga inn í flokkun í örvarátt, þar með talinn einn á skjánum þeim megin |
| `Super + Ctrl + Left/Right`  | Fara á milli glugga inni í flísahópi |
| `Super + Ctrl + Z` | Þysja inn á skjá (endurtaka fyrir meiri þysjun) |
| `Super + Ctrl + Alt + Z` | Þysja alveg út af skjánum |
| `Super + /` | Fara áfram í gegnum valkosti fyrir kvörðun skjás |
| `Super + Alt + /` | Fara aftur á bak í gegnum valkosti fyrir kvörðun skjás |
| `Alt + Tab` | Fara áfram í gegnum glugga á virka vinnusvæðinu |
| `Alt + Shift + Tab` | Fara aftur á bak í gegnum glugga á virka vinnusvæðinu |
| `Ctrl + Alt + Tab`| Færa fókus áfram í gegnum skjái |
| `Ctrl + Alt + Shift + Tab`| Færa fókus aftur á bak í gegnum skjái |
| `Super + I` | Skipta um innsláttartungumál (með fleiri en einu útliti eða innsláttaraðferð) |
| `Super + Shift + I` | Skipta aftur um innsláttartungumál |

Á snertiborði skipta þriggja og fjögurra fingra strjúkingar um vinnusvæði, færa glugga og opna valmyndina og Quake-stjórnborðið; sjá [lyklaborð, mús og snertiborð](34-keyboard-mouse-trackpad.md) fyrir bendingarnar.

Flýtilyklar fyrir stærðarbreytingu nota efnislega lykla `code:20` og `code:21` (XKB `<AE11>` og `<AE12>`), óháð stöfunum sem prentaðir eru á lyklaborðið. Á bandarískum lyklaborðum eru þessir lyklar `-` og `=`; á japönskum (JIS) lyklaborðum eru þeir `-` og `^`; á spænskum lyklaborðum eru þeir `'` og `¡`. Á JIS er `Super + ^` það sama og `Super + Equal`, en `Super + Shift + -` (sem skrifar `=`) er `Super + Shift + Minus`.

## Kerfisstýringar

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Hljóðspjald    |
| `Super + Ctrl + B`           | Bluetooth-spjald    |
| `Super + Ctrl + N`           | Wifi/netspjald    |
| `Super + Ctrl + D`           | Skjáspjald    |
| `Super + Ctrl + P`           | Aflspjald    |
| `Super + Ctrl + X`           | Agents-spjald    |
| `Super + Ctrl + Alt + X`           | Spjald fyrir staðbundin líkön    |
| `Super + Ctrl + Alt + D`           | Dagatalsspjald    |
| `Super + Ctrl + Alt + E`           | Spjald fyrir heimsklukku    |
| `Super + Ctrl + 1-9`           | Skipta um spjald á stikunni eftir stöðu    |
| `Super + Ctrl + S` | Deilingarvalmynd (í gegnum LocalSend) |
| `Super + Ctrl + C` | Upptökustýringar (skjámynd/-upptaka/veljari) |
| `Super + Ctrl + O` | Skipta um valmynd |
| `Super + Ctrl + H` | Vélbúnaðarvalmynd |
| `Super + Ctrl + E` | Emoji-veljari |
| `Super + Ctrl + .` | Umkóða miðla |
| `Super + Shift + Ctrl + A` | Ræsa sjálfgefna agentinn þinn |
| `Power` key | Kerfisvalmynd |
| `Super + Shift + Copilot` key | Omarchy-valmynd |

## Stillingar

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Hámarks birtustig skjás |
| `Shift + Brightness Down` | Lágmarks birtustig skjás |
| `Alt + Brightness Up/Down` | Nákvæmar 1% breytingar á birtustigi |
| `Alt + Volume Up/Down` | Nákvæmar 1% breytingar á hljóðstyrk |
| `Keyboard Brightness Up/Down` | Baklýsing lyklaborðs sterkari/veikari |
| `Keyboard Backlight` | Fara í gegnum stig baklýsingar lyklaborðs |
| `Ctrl + Brightness Up/Down` | Baklýsing lyklaborðs sterkari/veikari, á lyklaborðum án eigin lykla |
| `Mic Mute` | Þagga hljóðnemann |
| `Shift + Mute` | Skipta um hljóðúttak |
| `Touchpad Toggle` | Kveikja eða slökkva á snertiborðinu |
| `Display` key | Fara í gegnum útlit vinnusvæðis |
| `Alt + Play` | Næsta lag |
| `Alt + Shift + Play` | Fyrra lag |

## Að ræsa forrit

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Super + Return`           | Útstöð    |
| `Super + Alt + Return` | Tmux-útstöð |
| `Super + Ctrl + Return` | Herdr (agentastjóri) |
| `Super + Shift + Return` or `Super + Shift + B`  | Vafri    |
| `Super + Shift + Alt + B`           | Vafri (einka/huliðs)    |
| `Super + Shift + F`           | Skráarstjóri    |
| `Super + Shift + Alt + F`           | Skráarstjóri í cwd útstöðvarinnar    |
| `Super + Shift + M`           | Tónlist (Spotify)    |
| `Super + Shift + Alt + M`           | Tónlist (cliamp)    |
| `Super + Shift + /`           | Lykilorðastjóri (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Reiknivél (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, þegar það er uppsett)    |
| `Super + Shift + T`           | Virkni (btop)    |
| `Super + Shift + N`           | Ritill (Plain, eða sjálfgefni ritillinn þinn)  |
| `Super + Shift + C`           | Dagatal ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Tölvupóstur ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nýr tölvupóstur ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Sjálfgefni agentinn þinn, eða ChatGPT þangað til þú velur einn |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Skilaboð (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Skilaboð (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Skilaboð (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Ritun (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (ný færsla) |
| `Super + Shift + Y`           | YouTube |

Breyttu/bættu við bindingum í `~/.config/hypr/bindings.lua`.

## Alhliða klippiborð

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Super + A`           | Velja allt í forritum sem styðja `Ctrl + A`    |
| `Super + C`           | Afrita    |
| `Super + X`           | Klippa (ekki í útstöð)    |
| `Super + V`           | Líma    |
| `Super + Ctrl + V`           | Klippiborðsstjóri    |

Venjulega á Linux þarftu `Ctrl + Shift + C/V` til að copy'n'paste í útstöðinni og `Ctrl + C/V` til að gera það alls staðar annars staðar. Þessir sameinuðu klippiborðsflýtilyklar Omarchy virka alls staðar.

## Upptaka

| Flýtilykill              | Virkni                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Skjámynd                      |
| `Super + Ctrl + Alt + C`            | Skjámynd (sama mynd, fyrir lyklaborð án Print Screen lykils) |
| `Super + Ctrl + C` | Upptökuvalmynd |
| `Alt + Print Screen`            | Skjáupptaka                     |
| `Super + Shift + Ctrl + Alt + C` | Skjáupptaka án hljóðs, sleppa valmynd (ýta aftur til að stöðva) |
| `Super + Print Screen` | Litaveljari |
| `Super + Ctrl + Print Screen` | Textaútdráttur á klippiborð |
| `Super + Alt + [` | Gera yfirlögn vefmyndavélar minni meðan á upptöku stendur |
| `Super + Alt + ]` | Gera yfirlögn vefmyndavélar stærri meðan á upptöku stendur |
| `Alt + Shift + L` | Afrita núverandi URL úr vefforriti eða vafra |
| `Alt + Shift + D` | Sækja myndbandið á núverandi síðu í `~/Videos` |
| `Alt + Space` | Ræsa/stöðva innlestur (krefst _Setup > Defaults > Dictation_) |
| `Right Alt` | Halda til að lesa inn (krefst _Setup > Defaults > Dictation_) |

Við skjáupptökur spyr flýtilykillinn fyrst hvaða hljóð þú vilt, byrjar síðan upptöku. Ýttu á hann aftur til að stöðva. Sjá [skjámyndir og upptaka](12-screenshots-recording.md) fyrir nánari upplýsingar.

Allir upptökuvalkostir eru einnig aðgengilegir undir _Trigger > Capture_ í Omarchy-valmyndinni (`Super + Space`).

## Tilkynningar

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Super + ,` | Bregðast við nýjustu tilkynningu: opna hana eða ýta á eina hnappinn hennar, velja úr valkostum hennar eða vísa henni frá þegar hún hefur enga  |
| `Super + Shift + ,` | Vísa öllum tilkynningum frá |
| `Super + Ctrl + ,` | Stjórna tilkynningum með lyklaborðinu  |
| `Super + Alt + ,` | Vísa nýjustu tilkynningu frá  |
| `Super + Shift + Alt + ,` | Opna tilkynningasögu  |
| `Super + Ctrl + Alt + ,` | Skipta um að þagga tilkynningar  |

## Stíll

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Velja nýtt þema (einnig `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Velja bakgrunn þema (einnig `Super + Ctrl + Space`) |
| `Super + Backspace` | Skipta um gagnsæi á glugga |
| `Super + Ctrl + Backspace` | Skipta um ferkantað hlutfall fyrir einn glugga |

Auka bakgrunnsmyndir eru í `~/.config/omarchy/backgrounds/<theme name>`. Einnig fáanlegt í gegnum _Install > Style > Background_ í Omarchy-valmyndinni.

Allir stílvalkostir eru einnig aðgengilegir undir _Appearance_ í Omarchy-valmyndinni (`Super + Space`).

## Rofar

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Skipta um læsingu í aðgerðaleysi |
| `Super + Ctrl + Delete` | Kveikja/slökkva á skjá fartölvu |
| `Super + Ctrl + Alt + Delete` | Skipta um speglun á skjá fartölvu |
| `Super + Shift + Space` | Skipta um efstu stikuna  |
| `Shift + Mute` | Skipta yfir í næsta hljóðúttak |
| `Shift + Play` | Skipta yfir í næsta miðlunargjafa |
| `Super + Shift + Backspace` | Skipta um bil á milli glugga |
| `Super + Ctrl + Alt + F` | Skipta um fullskjá skjáborð (efsta stika + bil á milli glugga) |

## Áminningar

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Stilla áminningu  |
| `Super + Ctrl + Alt + R` | Sjá allar áminningar  |
| `Super + Ctrl + Shift + R` | Hreinsa allar áminningar  |

## Upplýsingatilkynningar

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Sýna tíma sem tilkynningu  |
| `Super + Ctrl + Alt + B` | Sýna rafhlöðu sem tilkynningu  |
| `Super + Ctrl + Alt + W` | Skipta um veður sem tilkynningu  |

## Tmux

Forskeytislykillinn er `Ctrl + Space` (`Ctrl + B` virkar líka). Þú getur breytt þessum bindingum í `~/.config/tmux/tmux.conf`.

### Rúður

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Prefix + v` | Skipta rúðu við hliðina (lóðrétt) |
| `Prefix + h` | Skipta rúðu fyrir neðan (lárétt) |
| `Prefix + x` | Drepa rúðu |
| `Prefix + z` | Skipta um þysjun rúðu (fullur skjár) |
| `Alt + Enter` | Skipta rúðu fyrir neðan (ekkert forskeyti) |
| `Alt + Shift + Enter` | Skipta rúðu við hliðina (ekkert forskeyti) |
| `Alt + Escape` | Drepa rúðu (ekkert forskeyti) |
| `Ctrl + Alt + Arrows` | Fara á milli rúða |
| `Ctrl + Alt + Shift + Arrows` | Breyta stærð rúða |

### Gluggar

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nýr gluggi |
| `Prefix + k` | Drepa glugga |
| `Prefix + r` | Endurnefna glugga |
| `Alt + 1-9` | Fara á ákveðinn glugga |
| `Alt + Arrow Left/Right` | Fara á milli glugga |
| `Alt + Shift + Arrow Left/Right` | Færa glugga til vinstri/hægri |

### Setur

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Prefix + C` | Ný seta |
| `Prefix + K` | Drepa setu |
| `Prefix + R` | Endurnefna setu |
| `Prefix + N` | Næsta seta |
| `Prefix + P` | Fyrri seta |
| `Alt + Arrow Up/Down` | Fara á milli seta |
| `Prefix + s` | Lista setur |
| `Prefix + d` | Aftengjast setu |

### Afritunarhamur (vi-stíll)

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Prefix + [` | Fara í afritunarham |
| `v` | Byrja val (í afritunarham) |
| `y` | Afrita val (í afritunarham) |

### Almennt

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Prefix + q` | Endurhlaða stillingum |
| `Prefix + ?` | Sýna Tmux lyklabindingar |
| `Prefix + :` | Skipanalína |

### Tmux útlitsföll

Þessi föll verður að keyra inni í Tmux setu.

| Skipun | Virkni |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Búa til þróunarútlit með ritli, AI og útstöð |
| `tdlm <ai> [<second_ai>]` | Búa til þróunarútlit fyrir hverja undirmöppu |
| `tsl <count> <command>` | Búa til swarm-útlit með mörgum rúðum |

## Ghostty Terminal

Ghostty útstöð er sett upp með _Install > Terminal_ í gegnum Omarchy-valmyndina.

| Flýtilykill                  | Virkni              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Ný skipting fyrir neðan |
| `Ctrl + Shift + O` | Ný skipting við hliðina |
| `Ctrl + Alt + Arrows` | Fara á milli skiptinga |
| `Super + Ctrl + Shift + Arrows` | Breyta stærð skiptingar um 10 línur |
| `Super + Ctrl + Shift + Alt + Arrows` | Breyta stærð skiptingar um 100 línur |
| `Ctrl + Shift + T` | Nýr flipi  |
| `Ctrl + Shift + Arrows` | Fara á milli flipa |
| `Alt + Numbers` | Fara á ákveðinn flipa |
| `Shift + Pg Up/Down` | Skruna söguna |
| `Ctrl + Left mouse` | Opna tengil í vafra |

## File Manager

| Flýtilykill              | Virkni                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Fara á slóð                     |
| `Space`               | Forskoða skrá (örvar færa um) |
| `Alt + Up`       | Fara upp í yfirmöppu        |

## Neovim (w/ lazyvim)

### Leiðsögn

| Flýtilykill                   | Virkni                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Sýna skipanavalkosti            |
| `Space Space`              | Opna skrá með óljósri leit      |
| `Space E`                  | Skipta um hliðarstiku                  |
| `Space G G`                | Sýna git-stýringar               |
| `Space S G`                | Leita í innihaldi skráa             |
| `Ctrl + W W`               | Hoppa á milli hliðarstiku og ritils |
| `Ctrl + Left/right arrow`  | Breyta stærð hliðarstiku          |
| `Shift + H`                      | Fara á vinstri skráarflipa             |
| `Shift + L`                      | Fara á hægri skráarflipa            |
| `Space B D`                | Loka skráarflipa                  |

### Á meðan í hliðarstiku

| Flýtilykill                   | Virkni                        |
| ------------------------ | ------------------------------- |
| `A`                        | Bæta við nýrri skrá í yfirmöppu      |
| `Shift + A`                | Bæta við nýrri undirmöppu í yfirmöppu    |
| `D`                        | Eyða auðkenndri skrá/möppu     |
| `M`                        | Færa auðkennda skrá/möppu       |
| `R`                        | Endurnefna auðkennda skrá/möppu     |
| `?`                        | Sýna hjálp fyrir allar skipanir      |

[Sjá alla Neovim flýtilykla sem LazyVim stillir](https://www.lazyvim.org/keymaps).

## Fljótleg Emoji

Þú getur notað `Super + Ctrl + E` til að sýna heildstæðan emoji-veljara sem setur valið á klippiborðið eða þú getur notað þessa fljótvirku aðgangskosti.

| Flýtilykill       | EM | Vísbending       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | bros      |
| `Shift + CapsLock M C` | 😂 | grátur        |
| `Shift + CapsLock M L` | 😍 | ást       |
| `Shift + CapsLock M V` | ✌️ | sigur    |
| `Shift + CapsLock M H` | ❤️ | hjarta      |
| `Shift + CapsLock M Y` | 👍 | já        |
| `Shift + CapsLock M N` | 👎 | nei         |
| `Shift + CapsLock M F` | 🖕 | fokk       |
| `Shift + CapsLock M W` | 🤞 | ósk       |
| `Shift + CapsLock M R` | 🤘 | rokk       |
| `Shift + CapsLock M K` | 😘 | koss       |
| `Shift + CapsLock M E` | 🙄 | augnvelta    |
| `Shift + CapsLock M I` | 😉 | blikk       |
| `Shift + CapsLock M P` | 🙏 | biðja |
| `Shift + CapsLock M D` | 🤤 | slefa      |
| `Shift + CapsLock M M` | 💰 | peningar      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | skál      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | kveðja |
| `Shift + CapsLock M A` |💪 | handleggur |
| `Shift + CapsLock M B` |🤯 | blástur |

## Fljótlegar útfyllingar

| Flýtilykill       | Útfylling       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Nafnið þitt (eins og það var slegið inn við uppsetningu)  |
| `Shift + CapsLock Space E` | Netfangið þitt (eins og það var slegið inn við uppsetningu)  |

Þú getur bætt við fleiri sjálfur með því að breyta `~/.XCompose`, keyra síðan `omarchy restart xcompose` í útstöðinni til að breytingarnar taki gildi.
