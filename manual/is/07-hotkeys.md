# Flýtilyklar

Þú getur séð öll helstu lyklaborðsbindingarnar með `Super + K` (Tmux-bindingar með `Super + Alt + K` og Herdr-bindingar með `Super + Ctrl + K`).

## Hvernig flýtilyklar eru skipulagðir

Sérhver flýtilykill situr á plani, sem ákvarðast af breytilyklunum hans, og hvert plan hefur eitt hlutverk. Það er það sem kemur í veg fyrir að flýtilyklarnir renni saman, og það þýðir að þú getur yfirleitt giskað á hvar eitthvað býr.

| Plan | Hvað býr þar | Dæmi |
| --- | --- | --- |
| `Super + key` | Kerfið: gluggar, vinnusvæði, skipulag og kjarnavalmyndir | `Super + Space` Omarchy-valmynd, `Super + W` loka glugga, `Super + F` fullskjár |
| `Super + Shift + key` | Forrit | `Super + Shift + B` vafri, `Super + Shift + E` tölvupóstur, `Super + Shift + N` ritill |
| `Super + Ctrl + key` | Spjöld og kerfisvalmyndir | `Super + Ctrl + A` hljóð, `Super + Ctrl + N` netkerfi, `Super + Ctrl + C` föngunarvalmynd |
| `Super + Ctrl + Alt + key` | Flýtiaðgerðir og tilkynningar | `Super + Ctrl + Alt + T` sýna tíma, `Super + Ctrl + Alt + B` rafhlaða, `Super + Ctrl + Alt + C` skjámynd |

Að bæta `Alt` við flýtilykil gefur þér afbrigði af sama hlutnum, aldrei eitthvað ótengt:

- `Super + Shift + B` opnar vafrann; `Super + Shift + Alt + B` opnar einkaglugga
- `Super + Shift + E` opnar tölvupóst; `Super + Shift + Alt + E` byrjar nýjan
- `Super + F` fer á fullskjá; `Super + Alt + F` fer á fulla breidd
- `Super + Ctrl + C` opnar föngunarvalmyndina; `Super + Ctrl + Alt + C` sleppir valmyndinni og tekur skjámynd

Þegar þú bætir við flýtilykli:

1. Veldu planið út frá því hvað hann gerir, veldu síðan lyklinn.
2. Ekki færa núverandi flýtilykil til að búa til pláss. Finndu lausan lykil á réttu plani.
3. Notaðu `Alt` aðeins fyrir afbrigði af flýtilyklinum án þess.

Nokkrir flýtilyklar brjóta þessar reglur af því að það er þægilegt. `Shift` með ör eða `Tab` færir eða snýr við í stað þess að opna forrit, og `Print`, margmiðlunarlyklarnir, `Alt + Tab` og `Ctrl + Alt + Del` virka eins og þeir gera alls staðar annars staðar. Þeir eru undantekningar, ekki mynstur til að apa eftir.

Ef sjálfgefin binding hentar þér ekki (segjum að þú viljir `Super + Shift + S` fyrir skjámyndir eins og í Windows), skaltu endurbinda hana í `~/.config/hypr/bindings.lua`.

## Flakk

| Flýtilykill | Fall |
| --- | --- |
| `Super + Space` | Omarchy-valmynd (forrit og allt annað) |
| `Super + Alt + Space` | Forritarist |
| `Super + Escape` | Kerfisvalmynd (svefn, endurræsing o.s.frv.) |
| `Super + Ctrl + L` | Læsa tölvu |
| `Super + W` eða `Super + Q` | Loka glugga |
| `Ctrl + Alt + Del` | Loka öllum gluggum |
| `Super + K` | Sýna alla flýtilykla |
| `Super + Alt + K` | Sýna tmux-flýtilykla |
| `Super + Ctrl + K` | Sýna herdr-flýtilykla |
| `Super + M` | Lágmarka glugga í bryggjuna |
| `Super + T` | Skipta glugga á milli flísaleggingar/fljótandi |
| `Super + J` | Skipta um stöðu glugga (lárétt/lóðrétt) |
| `Super + O` | Skipta um að skjóta glugga í sticky'n'floating |
| `Super + L` | Fara í gegnum dwindle-, scrolling- og floating-skipulögin |
| `Super + Alt + L` | Fara í gegnum skipulögin í öfugri röð |
| `Super + P` | Skipta um gerviglugga-stíl (náttúrulegur á móti teygður) |
| `Super + F` | Fara á fullskjá |
| `Super + Alt + F` | Fara á fulla breidd |
| `Super + Ctrl + F` | Fara á fullskjá inni í glugga |
| `Super + 1…9/0` | Hoppa á tiltekið vinnusvæði (0 er 10) á virka skjánum |
| `Super + Tab` | Hoppa á næsta vinnusvæði á virka skjánum |
| `Super + Shift + Tab` | Hoppa á fyrra vinnusvæði á virka skjánum |
| `Super + Ctrl + Tab` | Hoppa á fyrra vinnusvæði á virka skjánum |
| `Super + Shift + 1…9/0` | Færa glugga á vinnusvæði á virka skjánum |
| `Super + Shift + Alt + 1…9/0` | Færa glugga á vinnusvæði á virka skjánum án þess að fylgja eftir |
| `Super + S` | Kveikja/slökkva á fullu kladdasvæði |
| `Super + Alt + S` | Færa glugga á fullt kladdasvæði |
| `Super + Grave` | Kveikja/slökkva á Quake console |
| `Super + Shift + Grave` | Færa glugga á Quake console |
| `Super + Shift + Ctrl + Arrows` | Færa glugga á skjáinn í þá átt |
| `Super + Shift + Alt + Arrows` | Færa vinnusvæði á skjáinn í þá átt |
| `Super + Arrow` | Færa fókus á glugga í átt örvarinnar, fara yfir á skjáinn þeim megin við jaðar skjásins |
| `Super + Shift + Arrow` | Skipta glugga við annan í átt örvarinnar, þar með talinn einn á skjánum þeim megin |
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
| `Super + Scroll Wheel` | Skruna í gegnum vinnusvæði á virka skjánum |
| `Super + G` | Kveikja/slökkva á hópun glugga |
| `Super + Alt + G` | Færa glugga úr hópun |
| `Super + Alt + Tab` | Fara á milli glugga í hópun |
| `Super + Alt + Shift + Tab` | Fara aftur á bak á milli glugga í hópun |
| `Super + Alt + Scroll Wheel` | Fara á milli glugga í hópun |
| `Super + Alt + 1/2/3/4/5` | Hoppa á tiltekinn glugga í hópun |
| `Super + Alt + Arrow` | Færa glugga inn í hópun í átt örvarinnar, þar með talinn einn á skjánum þeim megin |
| `Super + Ctrl + Left/Right` | Fara á milli glugga inni í flísahópi |
| `Super + Ctrl + Z` | Aðdráttur inn á skjá (endurtaktu fyrir meiri aðdrátt) |
| `Super + Ctrl + Alt + Z` | Aðdráttur alveg út af skjá |
| `Super + /` | Stíga áfram í gegnum valkosti fyrir skjákvarða |
| `Super + Alt + /` | Stíga aftur á bak í gegnum valkosti fyrir skjákvarða |
| `Alt + Tab` | Fara áfram í gegnum glugga á virka vinnusvæðinu |
| `Alt + Shift + Tab` | Fara aftur á bak í gegnum glugga á virka vinnusvæðinu |
| `Ctrl + Alt + Tab` | Færa fókus áfram í gegnum skjái |
| `Ctrl + Alt + Shift + Tab` | Færa fókus aftur á bak í gegnum skjái |
| `Super + I` | Skipta um inntakstungumál (með fleiri en einu skipulagi eða inntaksaðferð) |
| `Super + Shift + I` | Skipta inntakstungumáli til baka |

Á snertifleti skipta þriggja og fjögurra fingra strjúkingar um vinnusvæði, færa glugga og opna valmyndina og Quake console; sjá [lyklaborð, mús og snertiflötur](34-keyboard-mouse-trackpad.md) fyrir bendingarnar.

Flýtilyklar fyrir stærðarbreytingu nota efnislega lyklana `code:20` og `code:21` (XKB `<AE11>` og `<AE12>`), óháð stöfunum sem prentaðir eru á lyklaborðið. Á bandarískum lyklaborðum eru þessir lyklar `-` og `=`; á japönskum (JIS) lyklaborðum eru þeir `-` og `^`; á spænskum lyklaborðum eru þeir `'` og `¡`. Á JIS er `Super + ^` `Super + Equal`, en `Super + Shift + -` (sem skrifar `=`) er `Super + Shift + Minus`.

## Kerfisstýringar

| Flýtilykill | Fall |
| --- | --- |
| `Super + Ctrl + A` | Hljóðspjald |
| `Super + Ctrl + B` | Bluetooth-spjald |
| `Super + Ctrl + N` | Wi-Fi/netkerfisspjald |
| `Super + Ctrl + D` | Skjáspjald |
| `Super + Ctrl + P` | Aflspjald |
| `Super + Ctrl + X` | Agents-spjald |
| `Super + Ctrl + Alt + X` | Spjald fyrir staðbundin líkön |
| `Super + Ctrl + Alt + D` | Dagatalsspjald |
| `Super + Ctrl + Alt + E` | Heimsklukkuspi ald |
| `Super + Ctrl + 1-9` | Kveikja/slökkva á spjaldi á stiku eftir staðsetningu |
| `Super + Ctrl + S` | Deilingarvalmynd (í gegnum LocalSend) |
| `Super + Ctrl + C` | Föngunarstýringar (skjámynd/-upptaka/val) |
| `Super + Ctrl + O` | Skiptivalmynd |
| `Super + Ctrl + H` | Vélbúnaðarvalmynd |
| `Super + Ctrl + E` | Broskallaval |
| `Super + Ctrl + .` | Umkóða margmiðlunarefni |
| `Super + Shift + Ctrl + A` | Ræsa sjálfgefna umboðinn þinn |
| `Power` lykill | Kerfisvalmynd |
| `Super + Shift + Copilot` lykill | Omarchy-valmynd |

## Stillingar

| Flýtilykill | Fall |
| --- | --- |
| `Shift + Brightness Up` | Hámarksbirta skjás |
| `Shift + Brightness Down` | Lágmarksbirta skjás |
| `Alt + Brightness Up/Down` | Nákvæmar 1% birtubreytingar |
| `Alt + Volume Up/Down` | Nákvæmar 1% hljóðstyrksbreytingar |
| `Keyboard Brightness Up/Down` | Baklýsing lyklaborðs bjartari/daufari |
| `Keyboard Backlight` | Fara í gegnum stig baklýsingar lyklaborðs |
| `Ctrl + Brightness Up/Down` | Baklýsing lyklaborðs bjartari/daufari, á lyklaborðum án eigin lykla |
| `Mic Mute` | Þagga hljóðnemann |
| `Shift + Mute` | Skipta um hljóðútgang |
| `Touchpad Toggle` | Kveikja eða slökkva á snertifletinum |
| `Display` lykill | Fara í gegnum skipulag vinnusvæðis |
| `Alt + Play` | Næsta lag |
| `Alt + Shift + Play` | Fyrra lag |

## Að ræsa forrit

| Flýtilykill | Fall |
| --- | --- |
| `Super + Return` | Útstöð |
| `Super + Alt + Return` | Tmux-útstöð |
| `Super + Ctrl + Return` | Herdr (umboðastjóri) |
| `Super + Shift + Return` eða `Super + Shift + B` | Vafri |
| `Super + Shift + Alt + B` | Vafri (einka/incognito) |
| `Super + Shift + F` | Skráastjóri |
| `Super + Shift + Alt + F` | Skráastjóri í cwd útstöðvarinnar |
| `Super + Shift + M` | Tónlist (Spotify) |
| `Super + Shift + Alt + M` | Tónlist (cliamp) |
| `Super + Shift + /` | Lykilorðastjóri (1password) |
| `Super + Shift + Q` eða `Calculator` lykill | Reiknivél (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, þegar það er uppsett) |
| `Super + Shift + T` | Virkni (btop) |
| `Super + Shift + N` | Ritill (Plain, eða sá sem þú valdir sem sjálfgefinn) |
| `Super + Shift + C` | Dagatal ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Tölvupóstur ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Nýr tölvupóstur ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Sjálfgefni umboðinn þinn, eða ChatGPT þar til þú velur einn |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Skilaboð (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Skilaboð (WhatsApp) |
| `Super + Shift + Ctrl + G` | Skilaboð (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Ritun (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (ný færsla) |
| `Super + Shift + Y` | YouTube |

Breyttu/bættu við bindingum í `~/.config/hypr/bindings.lua`.

## Alhliða klippiborð

| Flýtilykill | Fall |
| --- | --- |
| `Super + A` | Velja allt í forritum sem styðja `Ctrl + A` |
| `Super + C` | Afrita |
| `Super + X` | Klippa (ekki í útstöð) |
| `Super + V` | Líma |
| `Super + Ctrl + V` | Klippiborðsstjóri |

Venjulega í Linux þarftu `Ctrl + Shift + C/V` til að afrita og líma í útstöðinni og `Ctrl + C/V` til að gera það alls staðar annars staðar. Þessir sameinuðu klippiborðsflýtilyklar Omarchy virka alls staðar.

## Föngun

| Flýtilykill | Fall |
| --- | --- |
| `Print Screen` | Skjámynd |
| `Super + Ctrl + Alt + C` | Skjámynd (sama mynd, fyrir lyklaborð án Print Screen lykils) |
| `Super + Ctrl + C` | Föngunarvalmynd |
| `Alt + Print Screen` | Skjáupptaka |
| `Super + Shift + Ctrl + Alt + C` | Skjáupptaka án hljóðs, valmynd sleppt (ýttu aftur til að stöðva) |
| `Super + Print Screen` | Litaval |
| `Super + Ctrl + Print Screen` | Textaútdráttur á klippiborð |
| `Super + Alt + [` | Gera yfirlögn vefmyndavélar minni meðan á upptöku stendur |
| `Super + Alt + ]` | Gera yfirlögn vefmyndavélar stærri meðan á upptöku stendur |
| `Alt + Shift + L` | Afrita núverandi URL úr vefforriti eða vafra |
| `Alt + Shift + D` | Sækja myndbandið á núverandi síðu í `~/Videos` |
| `Alt + Space` | Hefja/stöðva inntal (þarf _Uppsetning > Sjálfgefið > Inntal_) |
| `Right Alt` | Haltu inni til að tala inn (þarf _Uppsetning > Sjálfgefið > Inntal_) |

Með skjáupptökum spyr flýtilykillinn fyrst hvaða hljóð þú vilt, byrjar síðan upptöku. Ýttu á hann aftur til að stöðva. Sjá [skjámyndir og upptaka](12-screenshots-recording.md) fyrir nánari upplýsingar.

Allir föngunarvalkostir eru einnig aðgengilegir undir _Kveikja > Föngun_ í Omarchy-valmyndinni (`Super + Space`).

## Tilkynningar

| Flýtilykill | Fall |
| --- | --- |
| `Super + ,` | Bregðast við nýjustu tilkynningu: opna hana eða ýta á eina hnappinn hennar, velja úr valkostum hennar, eða hunsa hana þegar hún hefur enga |
| `Super + Shift + ,` | Hunsa allar tilkynningar |
| `Super + Ctrl + ,` | Stjórna tilkynningum með lyklaborðinu |
| `Super + Alt + ,` | Hunsa nýjustu tilkynningu |
| `Super + Shift + Alt + ,` | Opna tilkynningasögu |
| `Super + Ctrl + Alt + ,` | Kveikja/slökkva á þöggun tilkynninga |

## Stíll

| Flýtilykill | Fall |
| --- | --- |
| `Super + Ctrl + T` | Velja nýtt þema (einnig `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Velja bakgrunn þema (einnig `Super + Ctrl + Space`) |
| `Super + Backspace` | Kveikja/slökkva á gegnsæi á glugga |
| `Super + Ctrl + Backspace` | Kveikja/slökkva á ferköntuðu hlutfalli fyrir einn glugga |

Aukabakgrunnsmyndir eru í `~/.config/omarchy/backgrounds/<theme name>`. Einnig aðgengilegt í gegnum _Setja upp > Stíll > Bakgrunnur_ í Omarchy-valmyndinni.

Allir stílvalkostir eru einnig aðgengilegir undir _Útlit_ í Omarchy-valmyndinni (`Super + Space`).

## Rofar

| Flýtilykill | Fall |
| --- | --- |
| `Super + Ctrl + I` | Kveikja/slökkva á læsingu við aðgerðaleysi |
| `Super + Ctrl + Delete` | Kveikja/slökkva á skjá fartölvu |
| `Super + Ctrl + Alt + Delete` | Kveikja/slökkva á speglun skjás fartölvu |
| `Super + Shift + Space` | Kveikja/slökkva á efstu stikunni |
| `Shift + Mute` | Skipta yfir í næsta hljóðútgang |
| `Shift + Play` | Skipta yfir í næsta margmiðlunargjafa |
| `Super + Shift + Backspace` | Kveikja/slökkva á bilum á milli glugga |
| `Super + Ctrl + Alt + F` | Kveikja/slökkva á fullskjá skjáborði (efsta stika + bil á milli glugga) |

## Áminningar

| Flýtilykill | Fall |
| --- | --- |
| `Super + Ctrl + R` | Stilla áminningu |
| `Super + Ctrl + Alt + R` | Sjá allar áminningar |
| `Super + Ctrl + Shift + R` | Hreinsa allar áminningar |

## Stuttar tilkynningar

| Flýtilykill | Fall |
| --- | --- |
| `Super + Ctrl + Alt + T` | Sýna tíma sem tilkynningu |
| `Super + Ctrl + Alt + B` | Sýna rafhlöðu sem tilkynningu |
| `Super + Ctrl + Alt + W` | Kveikja/slökkva á veðri sem tilkynningu |

## Tmux

Forskeytislykillinn er `Ctrl + Space` (`Ctrl + B` virkar líka). Þú getur breytt þessum bindingum í `~/.config/tmux/tmux.conf`.

### Rúður

| Flýtilykill | Fall |
| --- | --- |
| `Prefix + v` | Skipta rúðu við hliðina (lóðrétt) |
| `Prefix + h` | Skipta rúðu fyrir neðan (lárétt) |
| `Prefix + x` | Drepa rúðu |
| `Prefix + z` | Kveikja/slökkva á aðdrætti rúðu (fullskjár) |
| `Alt + Enter` | Skipta rúðu fyrir neðan (án forskeytis) |
| `Alt + Shift + Enter` | Skipta rúðu við hliðina (án forskeytis) |
| `Alt + Escape` | Drepa rúðu (án forskeytis) |
| `Ctrl + Alt + Arrows` | Fara á milli rúða |
| `Ctrl + Alt + Shift + Arrows` | Breyta stærð rúða |

### Gluggar

| Flýtilykill | Fall |
| --- | --- |
| `Prefix + c` | Nýr gluggi |
| `Prefix + k` | Drepa glugga |
| `Prefix + r` | Endurnefna glugga |
| `Alt + 1-9` | Fara í tiltekinn glugga |
| `Alt + Arrow Left/Right` | Fara á milli glugga |
| `Alt + Shift + Arrow Left/Right` | Færa glugga til vinstri/hægri |

### Setur

| Flýtilykill | Fall |
| --- | --- |
| `Prefix + C` | Ný seta |
| `Prefix + K` | Drepa setu |
| `Prefix + R` | Endurnefna setu |
| `Prefix + N` | Næsta seta |
| `Prefix + P` | Fyrri seta |
| `Alt + Arrow Up/Down` | Fara á milli seta |
| `Prefix + s` | Lista setur |
| `Prefix + d` | Aftengjast setu |

### Afritunarhamur (vi-stíll)

| Flýtilykill | Fall |
| --- | --- |
| `Prefix + [` | Fara í afritunarham |
| `v` | Byrja val (í afritunarham) |
| `y` | Afrita val (í afritunarham) |

### Almennt

| Flýtilykill | Fall |
| --- | --- |
| `Prefix + q` | Endurhlaða stillingum |
| `Prefix + ?` | Sýna Tmux lyklabindingar |
| `Prefix + :` | Skipanalína |

### Tmux skipulagsföll

Þessi föll verður að keyra inni í Tmux-setu.

| Skipun | Fall |
| --- | --- |
| `tdl <ai> [<second_ai>]` | Búa til þróunarskipulag með ritli, AI og útstöð |
| `tdlm <ai> [<second_ai>]` | Búa til þróunarskipulag fyrir hverja undirmöppu |
| `tsl <count> <command>` | Búa til þyrpingarskipulag með mörgum rúðum |

## Ghostty Terminal

Ghostty-útstöð er sett upp með _Setja upp > Útstöð_ í gegnum Omarchy-valmyndina.

| Flýtilykill | Fall |
| --- | --- |
| `Ctrl + Shift + E` | Ný skipting fyrir neðan |
| `Ctrl + Shift + O` | Ný skipting við hliðina |
| `Ctrl + Alt + Arrows` | Fara á milli skiptinga |
| `Super + Ctrl + Shift + Arrows` | Breyta stærð skiptingar um 10 línur |
| `Super + Ctrl + Shift + Alt + Arrows` | Breyta stærð skiptingar um 100 línur |
| `Ctrl + Shift + T` | Nýr flipi |
| `Ctrl + Shift + Arrows` | Fara á milli flipa |
| `Alt + Numbers` | Fara í tiltekinn flipa |
| `Shift + Pg Up/Down` | Skruna í gegnum söguna |
| `Ctrl + Left mouse` | Opna tengil í vafra |

## Skráastjóri

| Flýtilykill | Fall |
| --- | --- |
| `Ctrl + L` | Fara á slóð |
| `Space` | Forskoða skrá (örvar fletta) |
| `Alt + Up` | Fara upp í yfirmöppu |

## Neovim (með lazyvim)

### Flakk

| Flýtilykill | Fall |
| --- | --- |
| `Space` | Sýna skipunavalkosti |
| `Space Space` | Opna skrá með óljósri leit |
| `Space E` | Kveikja/slökkva á hliðarstiku |
| `Space G G` | Sýna git-stýringar |
| `Space S G` | Leita í innihaldi skráa |
| `Ctrl + W W` | Hoppa á milli hliðarstiku og ritils |
| `Ctrl + Left/right arrow` | Breyta stærð hliðarstiku |
| `Shift + H` | Fara í vinstra skráarflipa |
| `Shift + L` | Fara í hægra skráarflipa |
| `Space B D` | Loka skráarflipa |

### Þegar í hliðarstiku

| Flýtilykill | Fall |
| --- | --- |
| `A` | Bæta við nýrri skrá í yfirmöppu |
| `Shift + A` | Bæta við nýrri undirmöppu í yfirmöppu |
| `D` | Eyða merktri skrá/möppu |
| `M` | Færa merkta skrá/möppu |
| `R` | Endurnefna merkta skrá/möppu |
| `?` | Sýna hjálp fyrir allar skipanir |

[Sjá alla Neovim-flýtilykla sem LazyVim stillir](https://www.lazyvim.org/keymaps).

## Flýtibroskallar

Þú getur notað `Super + Ctrl + E` til að sýna heildstætt broskallaval sem setur valið á klippiborðið, eða þú getur notað þessa flýtivalkosti.

| Flýtilykill | EM | Vísbending |
| --- | --- | --- |
| `Shift + CapsLock M S` | 😄 | bros |
| `Shift + CapsLock M C` | 😂 | grátur |
| `Shift + CapsLock M L` | 😍 | ást |
| `Shift + CapsLock M V` | ✌️ | sigur |
| `Shift + CapsLock M H` | ❤️ | hjarta |
| `Shift + CapsLock M Y` | 👍 | já |
| `Shift + CapsLock M N` | 👎 | nei |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | ósk |
| `Shift + CapsLock M R` | 🤘 | rokk |
| `Shift + CapsLock M K` | 😘 | koss |
| `Shift + CapsLock M E` | 🙄 | augnrullingur |
| `Shift + CapsLock M I` | 😉 | blikk |
| `Shift + CapsLock M P` | 🙏 | bæn |
| `Shift + CapsLock M D` | 🤤 | slefa |
| `Shift + CapsLock M M` | 💰 | peningar |
| `Shift + CapsLock M X` | 🎉 | fagnaður |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | skál |
| `Shift + CapsLock M O` | 👌 | ok |
| `Shift + CapsLock M G` | 👋 | kveðja |
| `Shift + CapsLock M A` | 💪 | armur |
| `Shift + CapsLock M B` | 🤯 | höfuð að springa |

## Flýtifyllingar

| Flýtilykill | Fylling |
| --- | --- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Nafnið þitt (eins og það var slegið inn við uppsetningu) |
| `Shift + CapsLock Space E` | Netfangið þitt (eins og það var slegið inn við uppsetningu) |

Þú getur bætt við fleiri eigin með því að breyta `~/.XCompose`, keyra síðan `omarchy restart xcompose` í útstöðinni til að breytingarnar verði teknar upp.
