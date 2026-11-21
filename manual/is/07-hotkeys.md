# Flýtilyklar

Þú getur séð allar helstu lyklaborðstengingar með `Super + K` (Tmux-tengingar með `Super + Alt + K` og Herdr-tengingar með `Super + Ctrl + K`).

## Hvernig flýtilyklar eru skipulagðir

Sérhver flýtilykill situr á plani, ákvarðað af breytilyklum hans, og hvert plan hefur eitt hlutverk. Það heldur flýtilyklunum aðskildum og þýðir að þú getur yfirleitt giskað á hvar eitthvað býr.

| Plan | Hvað býr þar | Dæmi |
| --- | --- | --- |
| `Super + key` | Kerfið: gluggar, vinnusvæði, útlit og kjarnavalmyndir | `Super + Space` Omarchy-valmynd, `Super + W` loka glugga, `Super + F` fullur skjár |
| `Super + Shift + key` | Forrit | `Super + Shift + B` vafri, `Super + Shift + E` tölvupóstur, `Super + Shift + N` ritill |
| `Super + Ctrl + key` | Spjöld og kerfisvalmyndir | `Super + Ctrl + A` hljóð, `Super + Ctrl + N` net, `Super + Ctrl + C` upptökuvalmynd |
| `Super + Ctrl + Alt + key` | Flýtisaðgerðir og tilkynningar | `Super + Ctrl + Alt + T` sýna tíma, `Super + Ctrl + Alt + B` rafhlaða, `Super + Ctrl + Alt + C` skjámynd |

Að bæta `Alt` við flýtilykil gefur þér afbrigði af sama hlutnum, aldrei eitthvað ótengt:

- `Super + Shift + B` opnar vafrann; `Super + Shift + Alt + B` opnar einkaglugga
- `Super + Shift + E` opnar tölvupóst; `Super + Shift + Alt + E` byrjar nýjan
- `Super + F` fer á fullan skjá; `Super + Alt + F` fer á fulla breidd
- `Super + Ctrl + C` opnar upptökuvalmyndina; `Super + Ctrl + Alt + C` sleppir valmyndinni og tekur skjámynd

Þegar þú bætir við flýtilykli:

1. Veldu planið út frá því hvað það gerir, veldu síðan lykilinn.
2. Ekki færa núverandi flýtilykil til að búa til pláss. Finndu lausan lykil á rétta planinu.
3. Notaðu `Alt` aðeins fyrir afbrigði af flýtilyklinum án þess.

Nokkrir flýtilyklar brjóta þessar reglur af því að það er þægilegt. `Shift` með ör eða `Tab` færir eða snýr við í stað þess að opna forrit, og `Print`, miðlunarlyklarnir, `Alt + Tab` og `Ctrl + Alt + Del` virka eins og þeir gera alls staðar annars staðar. Þeir eru undantekningar, ekki mynstur til að afrita.

Ef sjálfgefið val hentar þér ekki (segjum að þú viljir `Super + Shift + S` fyrir skjámyndir eins og á Windows), endurtengdu það í `~/.config/hypr/bindings.lua`.

## Leiðsögn

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy-valmynd (forrit og allt annað) |
| `Super + Alt + Space` | Forritarist |
| `Super + Escape` | Kerfisvalmynd (svæfa, endurræsa o.s.frv.) |
| `Super + Ctrl + L` | Læsa tölvu |
| `Super + W` or `Super + Q` | Loka glugga |
| `Ctrl + Alt + Del` | Loka öllum gluggum |
| `Super + K` | Sýna alla flýtilykla |
| `Super + Alt + K` | Sýna tmux-flýtilykla |
| `Super + Ctrl + K` | Sýna herdr-flýtilykla |
| `Super + M` | Lágmarka glugga í dokkuna |
| `Super + T` | Skipta glugga á milli flísalagningar/fljótandi |
| `Super + J` | Skipta um stöðu glugga (lárétt/lóðrétt) |
| `Super + O` | Skipta glugga í sticky'n'floating |
| `Super + L` | Fara í gegnum dwindle-, scrolling- og floating-útlitin |
| `Super + Alt + L` | Fara í gegnum útlitin í öfugri röð |
| `Super + P` | Skipta um pseudo-glugga­stíl (náttúrulegur á móti teygður) |
| `Super + F` | Fara á fullan skjá |
| `Super + Alt + F` | Fara á fulla breidd |
| `Super + Ctrl + F` | Fara á fullan skjá inni í glugga |
| `Super + 1…9/0` | Hoppa á ákveðið vinnusvæði (0 er 10) á skjánum í fókus |
| `Super + Tab` | Hoppa á næsta vinnusvæði á skjánum í fókus |
| `Super + Shift + Tab` | Hoppa á fyrra vinnusvæði á skjánum í fókus |
| `Super + Ctrl + Tab` | Hoppa á fyrrverandi vinnusvæði á skjánum í fókus |
| `Super + Shift + 1…9/0` | Færa glugga á vinnusvæði á skjánum í fókus |
| `Super + Shift + Alt + 1…9/0` | Færa glugga á vinnusvæði á skjánum í fókus án þess að fylgja eftir |
| `Super + S` | Skipta á fullt scratchpad |
| `Super + Alt + S` | Færa glugga á fullt scratchpad |
| `Super + Grave` | Skipta á Quake-stjórnborð |
| `Super + Shift + Grave` | Færa glugga á Quake-stjórnborð |
| `Super + Shift + Ctrl + Arrows` | Færa glugga á skjáinn í þá átt |
| `Super + Shift + Alt + Arrows` | Færa vinnusvæði á skjáinn í þá átt |
| `Super + Arrow` | Færa fókus á glugga í átt örvarinnar, fara yfir á skjáinn þeim megin við jaðar skjásins |
| `Super + Shift + Arrow` | Skipta á glugga við annan í átt örvarinnar, þar á meðal einn á skjánum þeim megin |
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
| `Super + Scroll Wheel` | Skruna í gegnum vinnusvæði á skjánum í fókus |
| `Super + G` | Skipta á gluggahópun |
| `Super + Alt + G` | Færa glugga úr hópun |
| `Super + Alt + Tab` | Fara á milli glugga í hópun |
| `Super + Alt + Shift + Tab` | Fara afturábak á milli glugga í hópun |
| `Super + Alt + Scroll Wheel` | Fara á milli glugga í hópun |
| `Super + Alt + 1/2/3/4/5` | Hoppa á ákveðinn glugga í hópun |
| `Super + Alt + Arrow` | Færa glugga inn í hópun í átt örvarinnar, þar á meðal einn á skjánum þeim megin |
| `Super + Ctrl + Left/Right` | Fara á milli glugga inni í flísahópi |
| `Super + Ctrl + Z` | Þysja inn á skjáinn (endurtaktu fyrir meiri þysjun) |
| `Super + Ctrl + Alt + Z` | Þysja alveg út af skjánum |
| `Super + /` | Fara áfram í gegnum kvörðunarmöguleika skjás |
| `Super + Alt + /` | Fara afturábak í gegnum kvörðunarmöguleika skjás |
| `Alt + Tab` | Fara áfram í gegnum glugga á virka vinnusvæðinu |
| `Alt + Shift + Tab` | Fara afturábak í gegnum glugga á virka vinnusvæðinu |
| `Ctrl + Alt + Tab` | Fara með fókus áfram í gegnum skjái |
| `Ctrl + Alt + Shift + Tab` | Fara með fókus afturábak í gegnum skjái |
| `Super + I` | Skipta um inntakstungumál (með fleiri en einu útliti eða inntaksaðferð) |
| `Super + Shift + I` | Skipta inntakstungumáli til baka |

Á snertiborði skipta þriggja og fjögurra fingra strjúkingar um vinnusvæði, færa glugga og opna valmyndina og Quake-stjórnborðið; sjá [lyklaborð, mús og snertiborð](34-keyboard-mouse-trackpad.md) fyrir bendingarnar.

Flýtilyklar fyrir stærðarbreytingu nota efnislega lykla `code:20` og `code:21` (XKB `<AE11>` og `<AE12>`), óháð stöfunum sem prentaðir eru á lyklaborðið. Á bandarískum lyklaborðum eru þessir lyklar `-` og `=`; á japönskum (JIS) lyklaborðum eru þeir `-` og `^`; á spænskum lyklaborðum eru þeir `'` og `¡`. Á JIS er `Super + ^` það sama og `Super + Equal`, en `Super + Shift + -` (sem skrifar `=`) er `Super + Shift + Minus`.

## Kerfisstýringar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Hljóðspjald |
| `Super + Ctrl + B` | Bluetooth-spjald |
| `Super + Ctrl + N` | Wi-Fi/netspjald |
| `Super + Ctrl + D` | Skjáspjald |
| `Super + Ctrl + P` | Aflspjald |
| `Super + Ctrl + X` | Umboðaspjald |
| `Super + Ctrl + Shift + X` | Spjald fyrir staðbundin líkön |
| `Super + Ctrl + Alt + D` | Dagatalsspjald |
| `Super + Ctrl + Alt + E` | Heimsklukkuspjald |
| `Super + Ctrl + 1-9` | Skipta á spjald á stikunni eftir stöðu |
| `Super + Ctrl + S` | Deilivalmynd (í gegnum LocalSend) |
| `Super + Ctrl + C` | Upptökustýringar (skjámynd/-upptaka/val) |
| `Super + Ctrl + O` | Skipta á valmynd |
| `Super + Ctrl + H` | Vélbúnaðarvalmynd |
| `Super + Ctrl + E` | Táknmyndaval |
| `Super + Ctrl + .` | Umbreyta miðlum |
| `Super + Shift + Ctrl + A` | Velja AI-umboðsmann |
| `Power` key | Kerfisvalmynd |
| `Super + Shift + Copilot` key | Omarchy-valmynd |

## Stillingar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Hámarksbirta skjás |
| `Shift + Brightness Down` | Lágmarksbirta skjás |
| `Alt + Brightness Up/Down` | Nákvæmar 1% birtubreytingar |
| `Alt + Volume Up/Down` | Nákvæmar 1% hljóðstyrksbreytingar |
| `Keyboard Brightness Up/Down` | Baklýsing lyklaborðs bjartari/daufari |
| `Keyboard Backlight` | Fara í gegnum baklýsingarstig lyklaborðs |
| `Ctrl + Brightness Up/Down` | Baklýsing lyklaborðs bjartari/daufari, á lyklaborðum án eigin lykla |
| `Mic Mute` | Þagga hljóðnemann |
| `Shift + Mute` | Skipta um hljóðútgang |
| `Touchpad Toggle` | Kveikja eða slökkva á snertiborði |
| `Display` key | Fara í gegnum útlit vinnusvæðis |
| `Alt + Play` | Næsta lag |
| `Alt + Shift + Play` | Fyrra lag |

## Að ræsa forrit

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Return` | Flugstöð |
| `Super + Alt + Return` | Tmux-flugstöð |
| `Super + Ctrl + Return` | Herdr (umboðsmannastjóri) |
| `Super + Shift + Return` or `Super + Shift + B` | Vafri |
| `Super + Shift + Alt + B` | Vafri (einka/huliðs) |
| `Super + Shift + F` | Skráarstjóri |
| `Super + Shift + Alt + F` | Skráarstjóri í cwd flugstöðvarinnar |
| `Super + Shift + M` | Tónlist (Spotify) |
| `Super + Shift + Alt + M` | Tónlist (cliamp) |
| `Super + Shift + /` | Lykilorðastjóri (1password) |
| `Super + Shift + Q` or `Calculator` key | Reiknivél (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, þegar það er sett upp) |
| `Super + Shift + T` | Virkni (btop) |
| `Super + Shift + N` | Ritill (Plain, eða sjálfgefni ritillinn þinn) |
| `Super + Shift + C` | Dagatal ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Tölvupóstur ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Nýr tölvupóstur ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
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

Breyttu/bættu við tengingum í `~/.config/hypr/bindings.lua`.

## Alhliða klippiborð

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + A` | Velja allt í forritum sem styðja `Ctrl + A` |
| `Super + C` | Afrita |
| `Super + X` | Klippa (ekki í flugstöð) |
| `Super + V` | Líma |
| `Super + Ctrl + V` | Klippiborðsstjóri |

Venjulega á Linux þarftu `Ctrl + Shift + C/V` til að afrita og líma í flugstöðinni og `Ctrl + C/V` til að gera það alls staðar annars staðar. Þessir sameinuðu klippiborðsflýtilyklar Omarchy virka alls staðar.

## Upptaka

| Flýtilykill | Virkni |
| ------------------- | ------------------------------ |
| `Print Screen` | Skjámynd |
| `Super + Ctrl + Alt + C` | Skjámynd (sama mynd, fyrir lyklaborð án Print Screen-lykils) |
| `Super + Ctrl + C` | Upptökuvalmynd |
| `Alt + Print Screen` | Skjáupptaka |
| `Super + Shift + Ctrl + Alt + C` | Skjáupptaka án hljóðs, sleppa valmynd (ýttu aftur til að stöðva) |
| `Super + Print Screen` | Litaval |
| `Super + Ctrl + Print Screen` | Textaútdráttur á klippiborð |
| `Super + Alt + [` | Gera vefmyndavélaryfirlag minna meðan á upptöku stendur |
| `Super + Alt + ]` | Gera vefmyndavélaryfirlag stærra meðan á upptöku stendur |
| `Alt + Shift + L` | Afrita núverandi URL frá vefforriti eða vafra |
| `Alt + Shift + D` | Sækja myndbandið á núverandi síðu í `~/Videos` |
| `Alt + Space` | Ræsa/stöðva innlestur (krefst _Setup > Defaults > Dictation_) |
| `Right Alt` | Haltu inni til að lesa inn (krefst _Setup > Defaults > Dictation_) |

Við skjáupptökur spyr flýtilykillinn fyrst hvaða hljóð þú vilt, byrjar síðan upptöku. Ýttu á hann aftur til að stöðva. Sjá [skjámyndir og upptaka](12-screenshots-recording.md) fyrir nánari upplýsingar.

Allir upptökumöguleikar eru líka aðgengilegir undir _Trigger > Capture_ í Omarchy-valmyndinni (`Super + Space`).

## Tilkynningar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + ,` | Bregðast við nýjustu tilkynningu: opna hana eða ýta á eina hnappinn hennar, velja úr valkostum hennar, eða vísa henni frá þegar hún hefur enga |
| `Super + Shift + ,` | Vísa öllum tilkynningum frá |
| `Super + Ctrl + ,` | Stjórna tilkynningum með lyklaborðinu |
| `Super + Alt + ,` | Vísa nýjustu tilkynningu frá |
| `Super + Shift + Alt + ,` | Opna tilkynningasögu |
| `Super + Ctrl + Alt + ,` | Skipta á að þagga tilkynningar |

## Stíll

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Velja nýtt þema (líka `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Velja bakgrunn þema (líka `Super + Ctrl + Space`) |
| `Super + Backspace` | Skipta á gegnsæi á glugga |
| `Super + Ctrl + Backspace` | Skipta á ferkantað hlutfall fyrir einn glugga |

Aukabakgrunnsmyndir eru í `~/.config/omarchy/backgrounds/<theme name>`. Einnig fáanlegt í gegnum _Install > Style > Background_ í Omarchy-valmyndinni.

Allir stílvalkostir eru líka aðgengilegir undir _Appearance_ í Omarchy-valmyndinni (`Super + Space`).

## Rofar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Skipta á læsingu í aðgerðaleysi |
| `Super + Ctrl + Delete` | Kveikja/slökkva á skjá fartölvu |
| `Super + Ctrl + Alt + Delete` | Skipta á speglun skjás fartölvu |
| `Super + Shift + Space` | Skipta á efstu stikuna |
| `Shift + Mute` | Skipta yfir í næsta hljóðútgang |
| `Shift + Play` | Skipta yfir í næsta miðlunargjafa |
| `Super + Shift + Backspace` | Skipta á gluggabil |
| `Super + Ctrl + Alt + F` | Skipta á fullskjás skjáborð (efsta stika + gluggabil) |

## Áminningar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Stilla áminningu |
| `Super + Ctrl + Alt + R` | Sjá allar áminningar |
| `Super + Ctrl + Shift + R` | Hreinsa allar áminningar |

## Ábendingar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Sýna tíma sem tilkynningu |
| `Super + Ctrl + Alt + B` | Sýna rafhlöðu sem tilkynningu |
| `Super + Ctrl + Alt + W` | Skipta á veður sem tilkynningu |

## Tmux

Forskeytislykillinn er `Ctrl + Space` (`Ctrl + B` virkar líka). Þú getur breytt þessum tengingum í `~/.config/tmux/tmux.conf`.

### Rúður

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Prefix + v` | Skipta rúðu við hliðina (lóðrétt) |
| `Prefix + h` | Skipta rúðu fyrir neðan (lárétt) |
| `Prefix + x` | Drepa rúðu |
| `Prefix + z` | Skipta á þysjun rúðu (fullur skjár) |
| `Alt + Enter` | Skipta rúðu fyrir neðan (án forskeytis) |
| `Alt + Shift + Enter` | Skipta rúðu við hliðina (án forskeytis) |
| `Alt + Escape` | Drepa rúðu (án forskeytis) |
| `Ctrl + Alt + Arrows` | Fara á milli rúða |
| `Ctrl + Alt + Shift + Arrows` | Breyta stærð rúða |

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
| `Prefix + ?` | Sýna Tmux-lyklatengingar |
| `Prefix + :` | Skipanalína |

### Tmux-útlitsföll

Þessi föll verður að keyra inni í Tmux-lotu.

| Skipun | Virkni |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Búa til þróunarútlit með ritli, AI og flugstöð |
| `tdlm <ai> [<second_ai>]` | Búa til þróunarútlit fyrir hverja undirmöppu |
| `tsl <count> <command>` | Búa til fjölrúðu hópútlit |

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
| `Shift + Pg Up/Down` | Skruna í gegnum söguna |
| `Ctrl + Left mouse` | Opna tengil í vafra |

## Skráarstjóri

| Flýtilykill | Virkni |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Fara á slóð |
| `Space` | Forskoða skrá (örvar fletta) |
| `Alt + Up` | Fara upp í yfirmöppu |

## Neovim (w/ lazyvim)

### Leiðsögn

| Flýtilykill | Virkni |
| ------------------------ | ------------------------------- |
| `Space` | Sýna skipanavalkosti |
| `Space Space` | Opna skrá með óskýrri leit |
| `Space E` | Skipta á hliðarstiku |
| `Space G G` | Sýna git-stýringar |
| `Space S G` | Leita í innihaldi skrár |
| `Ctrl + W W` | Hoppa á milli hliðarstiku og ritils |
| `Ctrl + Left/right arrow` | Breyta stærð hliðarstiku |
| `Shift + H` | Fara á vinstri skráarflipa |
| `Shift + L` | Fara á hægri skráarflipa |
| `Space B D` | Loka skráarflipa |

### Í hliðarstikunni

| Flýtilykill | Virkni |
| ------------------------ | ------------------------------- |
| `A` | Bæta við nýrri skrá í yfirmöppu |
| `Shift + A` | Bæta við nýrri undirmöppu í yfirmöppu |
| `D` | Eyða auðkenndri skrá/möppu |
| `M` | Færa auðkennda skrá/möppu |
| `R` | Endurnefna auðkennda skrá/möppu |
| `?` | Sýna hjálp fyrir allar skipanir |

[Sjáðu öll Neovim-flýtilykla sem LazyVim stillir](https://www.lazyvim.org/keymaps).

## Flýtistáknmyndir

Þú getur notað `Super + Ctrl + E` til að sýna fullkomið táknmyndaval sem setur valið á klippiborðið, eða þú getur notað þessa flýtisaðgangsmöguleika.

| Flýtilykill | EM | Vísbending |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | bros |
| `Shift + CapsLock M C` | 😂 | grátur |
| `Shift + CapsLock M L` | 😍 | ást |
| `Shift + CapsLock M V` | ✌️ | sigur |
| `Shift + CapsLock M H` | ❤️ | hjarta |
| `Shift + CapsLock M Y` | 👍 | já |
| `Shift + CapsLock M N` | 👎 | nei |
| `Shift + CapsLock M F` | 🖕 | fokk |
| `Shift + CapsLock M W` | 🤞 | ósk |
| `Shift + CapsLock M R` | 🤘 | rokk |
| `Shift + CapsLock M K` | 😘 | koss |
| `Shift + CapsLock M E` | 🙄 | augnvelta |
| `Shift + CapsLock M I` | 😉 | blikk |
| `Shift + CapsLock M P` | 🙏 | biðja |
| `Shift + CapsLock M D` | 🤤 | slefa |
| `Shift + CapsLock M M` | 💰 | peningar |
| `Shift + CapsLock M X` | 🎉 | fögnuður |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | skál |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | kveðja |
| `Shift + CapsLock M A` |💪 | handleggur |
| `Shift + CapsLock M B` |🤯 | sprenging |

## Flýtifyllingar

| Flýtilykill | Útfylling |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Nafnið þitt (eins og það var slegið inn við uppsetningu) |
| `Shift + CapsLock Space E` | Netfangið þitt (eins og það var slegið inn við uppsetningu) |

Þú getur bætt við fleiri eigin með því að breyta `~/.XCompose`, keyra síðan `omarchy restart xcompose` í flugstöðinni til að breytingarnar taki gildi.
