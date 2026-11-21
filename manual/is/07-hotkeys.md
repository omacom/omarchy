# Flýtilyklar

Þú getur séð alla helstu lyklaborðsbindingar með `Super + K` (Tmux-bindingar með `Super + Alt + K` og Herdr-bindingar með `Super + Ctrl + K`).

## Hvernig flýtilyklar eru skipulagðir

Sérhver flýtilykill situr á plani, ákvarðað af breytilyklum hans, og hvert plan hefur eitt hlutverk. Það er það sem kemur í veg fyrir að flýtilyklarnir renni saman, og það þýðir að þú getur yfirleitt giskað á hvar eitthvað býr.

| Plan | Hvað býr þar | Dæmi |
| --- | --- | --- |
| `Super + key` | Kerfið: gluggar, vinnusvæði, útlit og kjarnavalmyndir | `Super + Space` Omarchy-valmynd, `Super + W` loka glugga, `Super + F` fullur skjár |
| `Super + Shift + key` | Forrit | `Super + Shift + B` vafri, `Super + Shift + E` tölvupóstur, `Super + Shift + N` ritill |
| `Super + Ctrl + key` | Spjöld og kerfisvalmyndir | `Super + Ctrl + A` hljóð, `Super + Ctrl + N` net, `Super + Ctrl + C` upptökuvalmynd |
| `Super + Ctrl + Alt + key` | Flýtiaðgerðir og tilkynningar | `Super + Ctrl + Alt + T` sýna tíma, `Super + Ctrl + Alt + B` rafhlaða, `Super + Ctrl + Alt + C` skjámynd |

Að bæta `Alt` við flýtilykil gefur þér afbrigði af sama hlutnum, aldrei eitthvað óskylt:

- `Super + Shift + B` opnar vafrann; `Super + Shift + Alt + B` opnar einkaglugga
- `Super + Shift + E` opnar tölvupóst; `Super + Shift + Alt + E` byrjar nýjan
- `Super + F` fer í fullan skjá; `Super + Alt + F` fer í fulla breidd
- `Super + Ctrl + C` opnar upptökuvalmyndina; `Super + Ctrl + Alt + C` sleppir valmyndinni og tekur skjámynd

Þegar þú bætir við flýtilykli:

1. Veldu planið út frá því hvað hann gerir, veldu síðan lykilinn.
2. Ekki færa núverandi flýtilykil til að búa til pláss. Finndu lausan lykil á rétta planinu.
3. Notaðu `Alt` aðeins fyrir afbrigði af flýtilyklinum án hans.

Nokkrir flýtilyklar brjóta þessar reglur vegna þess að þeir eru þægilegir. `Shift` með ör eða `Tab` færir eða snýr við í stað þess að opna forrit, og `Print`, fjölmiðlalyklarnir, `Alt + Tab` og `Ctrl + Alt + Del` virka eins og þeir gera alls staðar annars staðar. Þeir eru undantekningar, ekki mynstur til að afrita.

Ef sjálfgefin stilling hentar þér ekki (segjum að þú viljir `Super + Shift + S` fyrir skjámyndir eins og í Windows), skaltu endurbinda hana í `~/.config/hypr/bindings.lua`.

## Leiðsögn

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy-valmynd (forrit og allt annað) |
| `Super + Alt + Space` | Forritarist |
| `Super + Escape` | Kerfisvalmynd (sofna, endurræsa o.s.frv.) |
| `Super + Ctrl + L` | Læsa tölvu |
| `Super + W` eða `Super + Q` | Loka glugga |
| `Ctrl + Alt + Del` | Loka öllum gluggum |
| `Super + K` | Sýna alla flýtilykla |
| `Super + Alt + K` | Sýna tmux-flýtilykla |
| `Super + Ctrl + K` | Sýna herdr-flýtilykla |
| `Super + M` | Lágmarka glugga í bryggjuna |
| `Super + T` | Víxla glugga á milli flísaleggingar/fljótandi |
| `Super + J` | Víxla stöðu glugga (lárétt/lóðrétt) |
| `Super + O` | Víxla því að skjóta glugga í klístraðan og fljótandi |
| `Super + L` | Fara í gegnum dwindle-, scrolling- og floating-útlitin |
| `Super + Alt + L` | Fara í gegnum útlitin í öfugri röð |
| `Super + P` | Víxla gerviglugga-stíl (náttúrulegur á móti teygður) |
| `Super + F` | Fara í fullan skjá |
| `Super + Alt + F` | Fara í fulla breidd |
| `Super + Ctrl + F` | Fara í fullan skjá inni í glugga |
| `Super + 1…9/0` | Hoppa á ákveðið vinnusvæði (0 er 10) á skjánum sem er í fókus |
| `Super + Tab` | Hoppa á næsta vinnusvæði á skjánum sem er í fókus |
| `Super + Shift + Tab` | Hoppa á fyrra vinnusvæði á skjánum sem er í fókus |
| `Super + Ctrl + Tab` | Hoppa á fyrra vinnusvæði á skjánum sem er í fókus |
| `Super + Shift + 1…9/0` | Færa glugga á vinnusvæði á skjánum sem er í fókus |
| `Super + Shift + Alt + 1…9/0` | Færa glugga á vinnusvæði á skjánum sem er í fókus án þess að fylgja eftir |
| `Super + S` | Víxla fullu kladdablaði |
| `Super + Alt + S` | Færa glugga á fullt kladdablað |
| `Super + Grave` | Víxla Quake-stjórnborði |
| `Super + Shift + Grave` | Færa glugga á Quake-stjórnborð |
| `Super + Shift + Ctrl + Arrows` | Færa glugga á skjáinn í þá átt |
| `Super + Shift + Alt + Arrows` | Færa vinnusvæði á skjáinn í þá átt |
| `Super + Arrow` | Færa fókus á glugga í átt örvarinnar, fara yfir á skjáinn á þeirri hlið við jaðar skjásins |
| `Super + Shift + Arrow` | Víxla glugga við annan í átt örvarinnar, þar á meðal einn á skjánum á þeirri hlið |
| `Super + Minus` | Víkka glugga til vinstri |
| `Super + Equal` | Minnka glugga til vinstri |
| `Super + Shift + Minus` | Minnka glugga upp |
| `Super + Shift + Equal` | Víkka glugga niður |
| `Super + Alt + Minus/Equal` | Sama stærðarbreyting í minni skrefum |
| `Super + Ctrl + Minus/Equal` | Sama stærðarbreyting í stærri skrefum |
| `Super + Alt + Home` | Vista breidd glugga |
| `Super + Home` | Endurheimta vistaða breidd glugga |
| `Super + Left Mouse` | Draga glugga um |
| `Super + Right Mouse` | Breyta stærð glugga |
| `Super + Scroll Wheel` | Skruna í gegnum vinnusvæði á skjánum sem er í fókus |
| `Super + G` | Víxla hópun glugga |
| `Super + Alt + G` | Færa glugga út úr hópun |
| `Super + Alt + Tab` | Fara í gegnum glugga í hópun |
| `Super + Alt + Shift + Tab` | Fara afturábak í gegnum glugga í hópun |
| `Super + Alt + Scroll Wheel` | Fara í gegnum glugga í hópun |
| `Super + Alt + 1/2/3/4/5` | Hoppa á ákveðinn glugga í hópun |
| `Super + Alt + Arrow` | Færa glugga inn í hópun í átt örvarinnar, þar á meðal einn á skjánum á þeirri hlið |
| `Super + Ctrl + Left/Right` | Fara á milli glugga inni í flísahópi |
| `Super + Ctrl + Z` | Aðdráttur á skjá (endurtaka fyrir meiri aðdrátt) |
| `Super + Ctrl + Alt + Z` | Frádráttur alveg af skjá |
| `Super + /` | Stíga áfram í gegnum valkosti fyrir kvörðun skjás |
| `Super + Alt + /` | Stíga afturábak í gegnum valkosti fyrir kvörðun skjás |
| `Alt + Tab` | Fara áfram í gegnum glugga á virka vinnusvæðinu |
| `Alt + Shift + Tab` | Fara afturábak í gegnum glugga á virka vinnusvæðinu |
| `Ctrl + Alt + Tab` | Fara með fókus áfram í gegnum skjái |
| `Ctrl + Alt + Shift + Tab` | Fara með fókus afturábak í gegnum skjái |
| `Super + I` | Skipta um inntakstungumál (með fleiri en einu útliti eða inntaksaðferð) |
| `Super + Shift + I` | Skipta inntakstungumáli til baka |

Á snertiborði skipta þriggja og fjögurra fingra strjúkingar um vinnusvæði, færa glugga og opna valmyndina og Quake-stjórnborðið; sjá [lyklaborð, mús og snertiborð](34-keyboard-mouse-trackpad.md) fyrir bendingarnar.

Flýtilyklar fyrir stærðarbreytingu nota efnislega lykla `code:20` og `code:21` (XKB `<AE11>` og `<AE12>`), óháð stöfunum sem prentaðir eru á lyklaborðið. Á bandarískum lyklaborðum eru þessir lyklar `-` og `=`; á japönskum (JIS) lyklaborðum eru þeir `-` og `^`; á spænskum lyklaborðum eru þeir `'` og `¡`. Á JIS er `Super + ^` `Super + Equal`, en `Super + Shift + -` (sem skrifar `=`) er `Super + Shift + Minus`.

## Kerfisstýringar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Hljóðspjald |
| `Super + Ctrl + B` | Bluetooth-spjald |
| `Super + Ctrl + N` | Wifi/netspjald |
| `Super + Ctrl + D` | Skjáspjald |
| `Super + Ctrl + P` | Orkuspjald |
| `Super + Ctrl + X` | Umboðsspjöld-spjald |
| `Super + Ctrl + Alt + X` | Staðbundin líkön-spjald |
| `Super + Ctrl + Alt + D` | Dagatalsspjald |
| `Super + Ctrl + Alt + E` | Heims-klukkusspjald |
| `Super + Ctrl + 1-9` | Víxla stikuspjaldi eftir stöðu |
| `Super + Ctrl + S` | Deilingarvalmynd (í gegnum LocalSend) |
| `Super + Ctrl + C` | Upptökustýringar (skjámynd/-upptaka/veljari) |
| `Super + Ctrl + O` | Víxla valmynd |
| `Super + Ctrl + H` | Vélbúnaðarvalmynd |
| `Super + Ctrl + E` | Emoji-veljari |
| `Super + Ctrl + .` | Umkóða margmiðlun |
| `Super + Shift + Ctrl + A` | Velja gervigreindarumboð |
| `Power` lykill | Kerfisvalmynd |
| `Super + Shift + Copilot` lykill | Omarchy-valmynd |

## Stillingar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Hámarksbirta skjás |
| `Shift + Brightness Down` | Lágmarksbirta skjás |
| `Alt + Brightness Up/Down` | Nákvæmar 1% birtubreytingar |
| `Alt + Volume Up/Down` | Nákvæmar 1% hljóðstyrksbreytingar |
| `Keyboard Brightness Up/Down` | Baklýsing lyklaborðs bjartari/daufari |
| `Keyboard Backlight` | Fara í gegnum stig baklýsingar lyklaborðs |
| `Ctrl + Brightness Up/Down` | Baklýsing lyklaborðs bjartari/daufari, á lyklaborðum án eigin lykla |
| `Mic Mute` | Þagga hljóðnemann |
| `Shift + Mute` | Skipta um hljóðútgang |
| `Touchpad Toggle` | Kveikja eða slökkva á snertiborðinu |
| `Display` lykill | Fara í gegnum útlit vinnusvæðis |
| `Alt + Play` | Næsta lag |
| `Alt + Shift + Play` | Fyrra lag |

## Ræsa forrit

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Return` | Flugstöð |
| `Super + Alt + Return` | Tmux-flugstöð |
| `Super + Ctrl + Return` | Herdr (umboðsstjóri) |
| `Super + Shift + Return` eða `Super + Shift + B` | Vafri |
| `Super + Shift + Alt + B` | Vafri (einka/huliðs) |
| `Super + Shift + F` | Skráarstjóri |
| `Super + Shift + Alt + F` | Skráarstjóri í cwd flugstöðvar |
| `Super + Shift + M` | Tónlist (Spotify) |
| `Super + Shift + Alt + M` | Tónlist (cliamp) |
| `Super + Shift + /` | Lykilorðastjóri (1password) |
| `Super + Shift + Q` eða `Calculator` lykill | Reiknivél (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, þegar það hefur verið sett upp) |
| `Super + Shift + T` | Virkni (btop) |
| `Super + Shift + N` | Ritill (Plain, eða valinn sjálfgefinn ritill þinn) |
| `Super + Shift + C` | Dagatal ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Tölvupóstur ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Nýr tölvupóstur ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Gervigreind (ChatGPT) |
| `Super + Shift + Alt + A` | Gervigreind (Grok) |
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

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + A` | Velja allt í forritum sem styðja `Ctrl + A` |
| `Super + C` | Afrita |
| `Super + X` | Klippa (ekki í flugstöð) |
| `Super + V` | Líma |
| `Super + Ctrl + V` | Klippiborðsstjóri |

Venjulega í Linux þarftu `Ctrl + Shift + C/V` til að afrita og líma í flugstöðinni og `Ctrl + C/V` til að gera það alls staðar annars staðar. Þessir sameinuðu klippiborðsflýtilyklar Omarchy virka alls staðar.

## Upptaka

| Flýtilykill | Virkni |
| ------------------- | ------------------------------ |
| `Print Screen` | Skjámynd |
| `Super + Ctrl + Alt + C` | Skjámynd (sama mynd, fyrir lyklaborð án Print Screen-lykils) |
| `Super + Ctrl + C` | Upptökuvalmynd |
| `Alt + Print Screen` | Skjáupptaka |
| `Super + Shift + Ctrl + Alt + C` | Skjáupptaka án hljóðs, sleppir valmyndinni (ýttu aftur til að stöðva) |
| `Super + Print Screen` | Litaveljari |
| `Super + Ctrl + Print Screen` | Textaútdráttur á klippiborð |
| `Super + Alt + [` | Gera vefmyndavélar-yfirlag minna meðan á upptöku stendur |
| `Super + Alt + ]` | Gera vefmyndavélar-yfirlag stærra meðan á upptöku stendur |
| `Alt + Shift + L` | Afrita núverandi vefslóð úr vefforriti eða vafra |
| `Alt + Shift + D` | Sækja myndbandið á núverandi síðu í `~/Videos` |
| `Alt + Space` | Byrja/stöðva fyrirlestur (krefst _Setup > Defaults > Dictation_) |
| `Right Alt` | Halda til að fyrirlesa (krefst _Setup > Defaults > Dictation_) |

Með skjáupptökum spyr flýtilykillinn fyrst hvaða hljóð þú vilt, byrjar síðan upptöku. Ýttu á hann aftur til að stöðva. Sjá [skjámyndir og upptaka](12-screenshots-recording.md) fyrir nánari upplýsingar.

Allir upptökuvalkostir eru einnig aðgengilegir undir _Trigger > Capture_ í Omarchy-valmyndinni (`Super + Space`).

## Tilkynningar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + ,` | Bregðast við nýjustu tilkynningu: opna hana eða ýta á eina hnapp hennar, velja úr valkostum hennar, eða vísa henni frá þegar hún hefur enga |
| `Super + Shift + ,` | Vísa öllum tilkynningum frá |
| `Super + Ctrl + ,` | Stjórna tilkynningum með lyklaborðinu |
| `Super + Alt + ,` | Vísa nýjustu tilkynningu frá |
| `Super + Shift + Alt + ,` | Opna tilkynningasögu |
| `Super + Ctrl + Alt + ,` | Víxla þöggun tilkynninga |

## Stíll

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Velja nýtt þema (einnig `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Velja bakgrunn þema (einnig `Super + Ctrl + Space`) |
| `Super + Backspace` | Víxla gagnsæi á glugga |
| `Super + Ctrl + Backspace` | Víxla ferninga-hlutföllum eins glugga |

Aukabakgrunnsmyndir búa í `~/.config/omarchy/backgrounds/<theme name>`. Einnig fáanlegt í gegnum _Install > Style > Background_ í Omarchy-valmyndinni.

Allir stílvalkostir eru einnig aðgengilegir undir _Appearance_ í Omarchy-valmyndinni (`Super + Space`).

## Víxlar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Víxla læsingu við aðgerðaleysi |
| `Super + Ctrl + Delete` | Víxla skjá fartölvu á/af |
| `Super + Ctrl + Alt + Delete` | Víxla speglun skjás fartölvu |
| `Super + Shift + Space` | Víxla efstu stikunni |
| `Shift + Mute` | Skipta yfir í næsta hljóðútgang |
| `Shift + Play` | Skipta yfir í næsta margmiðlunargjafa |
| `Super + Shift + Backspace` | Víxla gluggabilum |
| `Super + Ctrl + Alt + F` | Víxla fullum skjá skjáborðs (efsta stika + gluggabil) |

## Áminningar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Stilla áminningu |
| `Super + Ctrl + Alt + R` | Sjá allar áminningar |
| `Super + Ctrl + Shift + R` | Hreinsa allar áminningar |

## Tilkynningarathuganir

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Sýna tíma sem tilkynningu |
| `Super + Ctrl + Alt + B` | Sýna rafhlöðu sem tilkynningu |
| `Super + Ctrl + Alt + W` | Víxla veðri sem tilkynningu |

## Tmux

Forskeytislykillinn er `Ctrl + Space` (`Ctrl + B` virkar líka). Þú getur breytt þessum bindingum í `~/.config/tmux/tmux.conf`.

### Spjöld

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Prefix + v` | Skipta spjaldi við hliðina (lóðrétt) |
| `Prefix + h` | Skipta spjaldi fyrir neðan (lárétt) |
| `Prefix + x` | Drepa spjald |
| `Prefix + z` | Víxla aðdrætti spjalds (fullur skjár) |
| `Alt + Enter` | Skipta spjaldi fyrir neðan (ekkert forskeyti) |
| `Alt + Shift + Enter` | Skipta spjaldi við hliðina (ekkert forskeyti) |
| `Alt + Escape` | Drepa spjald (ekkert forskeyti) |
| `Ctrl + Alt + Arrows` | Fara á milli spjalda |
| `Ctrl + Alt + Shift + Arrows` | Breyta stærð spjalda |

### Gluggar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Prefix + c` | Nýr gluggi |
| `Prefix + k` | Drepa glugga |
| `Prefix + r` | Endurnefna glugga |
| `Alt + 1-9` | Fara á ákveðinn glugga |
| `Alt + Arrow Left/Right` | Fara á milli glugga |
| `Alt + Shift + Arrow Left/Right` | Færa glugga til vinstri/hægri |

### Lotur

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Prefix + C` | Ný lota |
| `Prefix + K` | Drepa lotu |
| `Prefix + R` | Endurnefna lotu |
| `Prefix + N` | Næsta lota |
| `Prefix + P` | Fyrri lota |
| `Alt + Arrow Up/Down` | Fara á milli lota |
| `Prefix + s` | Lista lotur |
| `Prefix + d` | Aftengjast lotu |

### Afritunarhamur (vi-stíll)

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Prefix + [` | Fara í afritunarham |
| `v` | Byrja val (í afritunarham) |
| `y` | Afrita val (í afritunarham) |

### Almennt

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Prefix + q` | Endurhlaða stillingum |
| `Prefix + ?` | Sýna Tmux-lyklabindingar |
| `Prefix + :` | Skipanaleit |

### Tmux-útlitsaðgerðir

Þessar aðgerðir verður að keyra inni í Tmux-lotu.

| Skipun | Virkni |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Búa til þróunarútlit með ritli, gervigreind og flugstöð |
| `tdlm <ai> [<second_ai>]` | Búa til þróunarútlit fyrir hverja undirmöppu |
| `tsl <count> <command>` | Búa til útlit með mörgum spjöldum í kvikum hópi |

## Ghostty-flugstöð

Ghostty-flugstöð er sett upp með _Install > Terminal_ í gegnum Omarchy-valmyndina.

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Ný skipting fyrir neðan |
| `Ctrl + Shift + O` | Ný skipting við hliðina |
| `Ctrl + Alt + Arrows` | Fara á milli skiptinga |
| `Super + Ctrl + Shift + Arrows` | Breyta stærð skiptingar um 10 línur |
| `Super + Ctrl + Shift + Alt + Arrows` | Breyta stærð skiptingar um 100 línur |
| `Ctrl + Shift + T` | Nýr flipi |
| `Ctrl + Shift + Arrows` | Fara á milli flipa |
| `Alt + Numbers` | Fara á ákveðinn flipa |
| `Shift + Pg Up/Down` | Skruna söguna |
| `Ctrl + Left mouse` | Opna tengil í vafra |

## Skráarstjóri

| Flýtilykill | Virkni |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Fara á slóð |
| `Space` | Forskoða skrá (örvar fletta) |
| `Alt + Up` | Fara upp í foreldramöppu |

## Neovim (með lazyvim)

### Leiðsögn

| Flýtilykill | Virkni |
| ------------------------ | ------------------------------- |
| `Space` | Sýna skipanavalkosti |
| `Space Space` | Opna skrá með óskýrri leit |
| `Space E` | Víxla hliðarstiku |
| `Space G G` | Sýna git-stýringar |
| `Space S G` | Leita í innihaldi skráar |
| `Ctrl + W W` | Hoppa á milli hliðarstiku og ritils |
| `Ctrl + Left/right arrow` | Breyta stærð hliðarstiku |
| `Shift + H` | Fara á vinstri skráarflipa |
| `Shift + L` | Fara á hægri skráarflipa |
| `Space B D` | Loka skráarflipa |

### Á meðan í hliðarstiku

| Flýtilykill | Virkni |
| ------------------------ | ------------------------------- |
| `A` | Bæta við nýrri skrá í foreldramöppu |
| `Shift + A` | Bæta við nýrri undirmöppu í foreldramöppu |
| `D` | Eyða auðkenndri skrá/möppu |
| `M` | Færa auðkennda skrá/möppu |
| `R` | Endurnefna auðkennda skrá/möppu |
| `?` | Sýna hjálp fyrir allar skipanir |

[Sjá alla Neovim-flýtilykla sem LazyVim stillir](https://www.lazyvim.org/keymaps).

## Flýtibroskallar

Þú getur notað `Super + Ctrl + E` til að sýna heildstæðan emoji-veljara sem setur valið á klippiborðið eða þú getur notað þessa flýtiaðgangsvalkosti.

| Flýtilykill | EM | Vísbending |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smile |
| `Shift + CapsLock M C` | 😂 | cry |
| `Shift + CapsLock M L` | 😍 | love |
| `Shift + CapsLock M V` | ✌️ | victory |
| `Shift + CapsLock M H` | ❤️ | heart |
| `Shift + CapsLock M Y` | 👍 | yes |
| `Shift + CapsLock M N` | 👎 | no |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | wish |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | kiss |
| `Shift + CapsLock M E` | 🙄 | eyeroll |
| `Shift + CapsLock M I` | 😉 | wink |
| `Shift + CapsLock M P` | 🙏 | pray |
| `Shift + CapsLock M D` | 🤤 | drool |
| `Shift + CapsLock M M` | 💰 | money |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | toast |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | greeting |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blowing |

## Flýtifyllingar

| Flýtilykill | Fylling |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Nafnið þitt (eins og það var slegið inn við uppsetningu) |
| `Shift + CapsLock Space E` | Tölvupósturinn þinn (eins og hann var sleginn inn við uppsetningu) |

Þú getur bætt við fleiri eigin með því að breyta `~/.XCompose`, keyra síðan `omarchy restart xcompose` í flugstöðinni til að breytingarnar séu teknar upp.
