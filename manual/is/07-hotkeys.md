# Flýtilyklar

Þú getur séð allar helstu lyklabindingar með `Super + K` (Tmux-bindingar með `Super + Alt + K` og Herdr-bindingar með `Super + Ctrl + K`).

## Hvernig flýtilyklar eru lagðir upp

Sérhver flýtilykill situr á plani, ákveðnu af breytilyklum hans, og hvert plan hefur eitt verk. Það er það sem kemur í veg fyrir að flýtilyklarnir renni saman, og það þýðir að þú getur yfirleitt giskað á hvar eitthvað býr.

| Plan | Hvað býr þar | Dæmi |
| --- | --- | --- |
| `Super + key` | Kerfið: gluggar, vinnusvæði, framsetningar og kjarnavalmyndir | `Super + Space` Omarchy-valmynd, `Super + W` loka glugga, `Super + F` heilskjár |
| `Super + Shift + key` | Forrit | `Super + Shift + B` vafri, `Super + Shift + E` tölvupóstur, `Super + Shift + N` ritill |
| `Super + Ctrl + key` | Spjöld og kerfisvalmyndir | `Super + Ctrl + A` hljóð, `Super + Ctrl + N` net, `Super + Ctrl + C` tökuvalmynd |
| `Super + Ctrl + Alt + key` | Flýtisaðgerðir og tilkynningar | `Super + Ctrl + Alt + T` sýna klukkuna, `Super + Ctrl + Alt + B` rafhlaða, `Super + Ctrl + Alt + C` skjámynd |

Að bæta `Alt` við flýtilykil gefur þér afbrigði af sama hlutnum, aldrei eitthvað óskylt:

- `Super + Shift + B` opnar vafrann; `Super + Shift + Alt + B` opnar einkaglugga
- `Super + Shift + E` opnar tölvupóst; `Super + Shift + Alt + E` byrjar nýjan
- `Super + F` fer á heilskjá; `Super + Alt + F` fer í fulla breidd
- `Super + Ctrl + C` opnar tökuvalmyndina; `Super + Ctrl + Alt + C` sleppir valmyndinni og tekur skjámynd

Þegar þú bætir við flýtilykli:

1. Veldu planið út frá því hvað hann gerir, veldu svo lykilinn.
2. Ekki færa núverandi flýtilykil til að búa til pláss. Finndu lausan lykil á rétta planinu.
3. Notaðu `Alt` aðeins fyrir afbrigði af flýtilyklinum án hans.

Nokkrir flýtilyklar brjóta þessar reglur af því að það er þægilegt. `Shift` með ör eða `Tab` færir eða snýr við í stað þess að opna forrit, og `Print`, miðlunarlyklarnir, `Alt + Tab` og `Ctrl + Alt + Del` virka eins og þeir gera alls staðar annars staðar. Þeir eru undantekningar, ekki mynstur til að afrita.

Ef sjálfgefið val hentar þér ekki (segjum að þú viljir `Super + Shift + S` fyrir skjámyndir eins og á Windows), skaltu endurbinda það í `~/.config/hypr/bindings.lua`.

## Leiðsögn

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy-valmynd (forrit og allt annað) |
| `Super + Alt + Space` | Forritarist |
| `Super + Escape` | Kerfisvalmynd (setja í bið, endurræsa o.s.frv.) |
| `Super + Ctrl + L` | Læsa tölvu |
| `Super + W` or `Super + Q` | Loka glugga |
| `Ctrl + Alt + Del` | Loka öllum gluggum |
| `Super + T` | Víxla glugga á milli flísalagningar/fljótandi |
| `Super + J` | Víxla staðsetningu glugga (lárétt/lóðrétt) |
| `Super + O` | Víxla því að gluggi skjótist upp í límda'n'fljótandi stöðu |
| `Super + L` | Fara í gegnum dwindle-, rúllunar- og fljótandi framsetningarnar |
| `Super + Alt + L` | Fara í gegnum framsetningarnar í öfugri röð |
| `Super + P` | Víxla gerviglugga-stíl (náttúrulegur á móti teygður) |
| `Super + F` | Fara á heilskjá |
| `Super + Alt + F` | Fara í fulla breidd |
| `Super + Ctrl + F` | Fara á heilskjá inni í glugga |
| `Super + 1/2/3/4` | Fara á tiltekið vinnusvæði á skjánum sem er í fókus |
| `Super + Tab` | Fara á næsta vinnusvæði á skjánum sem er í fókus |
| `Super + Shift + Tab` | Fara á fyrra vinnusvæði á skjánum sem er í fókus |
| `Super + Ctrl + Tab` | Fara á fyrrverandi vinnusvæði á skjánum sem er í fókus |
| `Super + Shift + 1/2/3/4` | Færa glugga á vinnusvæði á skjánum sem er í fókus |
| `Super + Shift + Alt + 1/2/3/4` | Færa glugga á vinnusvæði á skjánum sem er í fókus án þess að fylgja á eftir |
| `Super + S` | Víxla fullum kladda |
| `Super + Alt + S` | Færa glugga á fullan kladda |
| `Super + Grave` | Víxla Quake-stjórnborði |
| `Super + Shift + Grave` | Færa glugga á Quake-stjórnborð |
| `Super + Shift + Ctrl + Arrows` | Færa glugga á skjáinn í þá átt |
| `Super + Shift + Alt + Arrows` | Færa vinnusvæði á skjáinn í þá átt |
| `Super + Arrow` | Færa fókus á glugga í átt örvarinnar, yfir á skjáinn þeim megin við jaðar skjásins |
| `Super + Shift + Arrow` | Skipta glugga við annan í átt örvarinnar, þar með talinn þann á skjánum þeim megin |
| `Super + Minus` | Stækka glugga til vinstri |
| `Super + Equal` | Minnka glugga til vinstri |
| `Super + Shift + Minus` | Minnka glugga upp |
| `Super + Shift + Equal` | Stækka glugga niður |
| `Super + Alt + Minus/Equal` | Sama stærðarbreyting í minni skrefum |
| `Super + Ctrl + Minus/Equal` | Sama stærðarbreyting í stærri skrefum |
| `Super + Alt + Home` | Vista breidd glugga |
| `Super + Home` | Endurheimta vistaða breidd glugga |
| `Super + Left Mouse` | Draga glugga til |
| `Super + Right Mouse` | Breyta stærð glugga |
| `Super + Scroll Wheel` | Skruna í gegnum vinnusvæði á skjánum sem er í fókus |
| `Super + G` | Víxla hópun glugga |
| `Super + Alt + G` | Færa glugga úr hópun |
| `Super + Alt + Tab` | Fara á milli glugga í hópun |
| `Super + Alt + Shift + Tab` | Fara aftur á bak á milli glugga í hópun |
| `Super + Alt + Scroll Wheel` | Fara á milli glugga í hópun |
| `Super + Alt + 1/2/3/4/5` | Fara á tiltekinn glugga í hópun |
| `Super + Alt + Arrow` | Færa glugga inn í hópun í átt örvarinnar, þar með talinn þann á skjánum þeim megin |
| `Super + Ctrl + Left/Right` | Fara á milli glugga inni í flísahópi |
| `Super + Ctrl + Z` | Þysja inn á skjáinn (endurtaka fyrir meiri þysjun) |
| `Super + Ctrl + Alt + Z` | Þysja alveg út af skjánum |
| `Super + /` | Fara áfram í gegnum kvörðunarmöguleika skjás |
| `Super + Alt + /` | Fara aftur á bak í gegnum kvörðunarmöguleika skjás |
| `Alt + Tab` | Fara áfram í gegnum glugga á virka vinnusvæðinu |
| `Alt + Shift + Tab` | Fara aftur á bak í gegnum glugga á virka vinnusvæðinu |
| `Ctrl + Alt + Tab` | Fara með fókus áfram í gegnum skjái |
| `Ctrl + Alt + Shift + Tab` | Fara með fókus aftur á bak í gegnum skjái |

Flýtilyklar fyrir stærðarbreytingu nota efnislega lyklana `code:20` og `code:21` (XKB `<AE11>` og `<AE12>`), óháð því hvaða tákn eru prentuð á lyklaborðið. Á bandarískum lyklaborðum eru þessir lyklar `-` og `=`; á japönskum (JIS) lyklaborðum eru þeir `-` og `^`; á spænskum lyklaborðum eru þeir `'` og `¡`. Á JIS er `Super + ^` það sama og `Super + Equal`, en `Super + Shift + -` (sem skrifar `=`) er `Super + Shift + Minus`.

## Kerfisstýringar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Hljóðspjald |
| `Super + Ctrl + B` | Bluetooth-spjald |
| `Super + Ctrl + N` | Wi-Fi/netspjald |
| `Super + Ctrl + D` | Skjáspjald |
| `Super + Ctrl + P` | Orkuspjald |
| `Super + Ctrl + X` | Umboðsspjal |
| `Super + Ctrl + Alt + D` | Dagatalsspjald |
| `Super + Ctrl + Alt + E` | Heimsklukkuspjald |
| `Super + Ctrl + 1-9` | Víxla spjaldi á stikunni eftir staðsetningu |
| `Super + Ctrl + S` | Deilingarvalmynd (í gegnum LocalSend) |
| `Super + Ctrl + C` | Tökustýringar (skjámynd/-upptaka/veljari) |
| `Super + Ctrl + O` | Víxla valmynd |
| `Super + Ctrl + H` | Vélbúnaðarvalmynd |
| `Super + Ctrl + E` | Veljari fyrir táknmyndir |
| `Super + Ctrl + .` | Umkóða miðla |
| `Super + Shift + Ctrl + A` | Velja gervigreindarumboð |

## Stillingar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Hámarksbirta skjás |
| `Shift + Brightness Down` | Lágmarksbirta skjás |
| `Alt + Brightness Up/Down` | Nákvæmar 1% birtubreytingar |
| `Alt + Volume Up/Down` | Nákvæmar 1% hljóðstyrksbreytingar |
| `Keyboard Brightness Up/Down` | Baklýsing lyklaborðs bjartari/dekkri |
| `Keyboard Backlight` | Fara í gegnum stig baklýsingar lyklaborðs |
| `Alt + Play` | Næsta lag |
| `Alt + Shift + Play` | Fyrra lag |

## Að ræsa forrit

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Return` | Útstöð |
| `Super + Alt + Return` | Tmux-útstöð |
| `Super + Ctrl + Return` | Herdr (umboðsstjóri) |
| `Super + Shift + Return` | Vafri |
| `Super + Shift + Alt + B` | Vafri (einka/huliðs) |
| `Super + Shift + F` | Skráarstjóri |
| `Super + Shift + Alt + F` | Skráarstjóri í cwd útstöðvarinnar |
| `Super + Shift + M` | Tónlist (Spotify) |
| `Super + Shift + Alt + M` | Tónlist (cliamp) |
| `Super + Shift + /` | Lykilorðastjóri (1password) |
| `Super + Shift + Q` | Reiknivél (Omacalc) |
| `Super + Shift + T` | Virkni (btop) |
| `Super + Shift + N` | Ritill (Neovim) |
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
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

Breyttu/bættu við bindingum í `~/.config/hypr/bindings.lua`.

## Almennt klippiborð

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + A` | Velja allt í forritum sem styðja `Ctrl + A` |
| `Super + C` | Afrita |
| `Super + X` | Klippa (ekki í útstöð) |
| `Super + V` | Líma |
| `Super + Ctrl + V` | Klippiborðsstjóri |

Venjulega á Linux þarftu `Ctrl + Shift + C/V` til að afrita og líma í útstöðinni og `Ctrl + C/V` til að gera það alls staðar annars staðar. Þessir sameinuðu flýtilyklar Omarchy fyrir klippiborð virka alls staðar.

## Taka

| Flýtilykill | Virkni |
| ------------------- | ------------------------------ |
| `Print Screen` | Skjámynd |
| `Super + Ctrl + Alt + C` | Skjámynd (sama taka, fyrir lyklaborð án Print Screen lykils) |
| `Super + Ctrl + C` | Tökuvalmynd |
| `Alt + Print Screen` | Skjáupptaka |
| `Super + Shift + Ctrl + Alt + C` | Skjáupptaka án hljóðs, sleppa valmyndinni (ýta aftur til að stöðva) |
| `Super + Print Screen` | Litaveljari |
| `Super + Ctrl + Print Screen` | Textaútdráttur á klippiborð |
| `Super + Alt + [` | Gera yfirlögn vefmyndavélar minni meðan á upptöku stendur |
| `Super + Alt + ]` | Gera yfirlögn vefmyndavélar stærri meðan á upptöku stendur |
| `Alt + Shift + L` | Afrita núverandi URL úr vefforriti eða vafra |
| `Alt + Shift + D` | Sækja myndbandið á núverandi síðu í `~/Videos` |
| `Alt + Space` | Ræsa/stöðva inntal (þarfnast _Setup > Defaults > Dictation_) |
| `Right Alt` | Halda inni til að tala inn (þarfnast _Setup > Defaults > Dictation_) |

Með skjáupptökum spyr flýtilykillinn fyrst hvaða hljóð þú vilt, byrjar svo upptökuna. Ýttu á hann aftur til að stöðva. Sjá [skjámyndir og upptaka](12-screenshots-recording.md) fyrir nánari upplýsingar.

Allir tökuvalkostir eru líka aðgengilegir undir _Trigger > Capture_ í Omarchy-valmyndinni (`Super + Space`).

## Tilkynningar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + ,` | Bregðast við nýjustu tilkynningu: opna hana eða ýta á eina hnappinn hennar, velja úr valkostum hennar, eða hunsa hana þegar hún hefur enga |
| `Super + Shift + ,` | Hunsa allar tilkynningar |
| `Super + Ctrl + ,` | Stjórna tilkynningum með lyklaborðinu |
| `Super + Alt + ,` | Hunsa nýjustu tilkynningu |
| `Super + Shift + Alt + ,` | Opna tilkynningasögu |
| `Super + Ctrl + Alt + ,` | Víxla þöggun tilkynninga |

## Stíll

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Velja nýtt þema (einnig `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Velja bakgrunn þema (einnig `Super + Ctrl + Space`) |
| `Super + Backspace` | Víxla gegnsæi á glugga |
| `Super + Ctrl + Backspace` | Víxla ferköntuðu hlutfalli fyrir einn glugga |

Auka bakgrunnsmyndir búa í `~/.config/omarchy/backgrounds/<theme name>`. Einnig fáanlegt í gegnum _Install > Style > Background_ í Omarchy-valmyndinni.

Allir stílvalkostir eru líka aðgengilegir undir _Style_ í Omarchy-valmyndinni (`Super + Space`).

## Víxlar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Víxla læsingu við aðgerðaleysi |
| `Super + Ctrl + Delete` | Víxla fartölvuskjá á/af |
| `Super + Ctrl + Alt + Delete` | Víxla speglun fartölvuskjás |
| `Super + Shift + Space` | Víxla efstu stikunni |
| `Shift + Mute` | Skipta yfir í næsta hljóðúttak |
| `Shift + Play` | Skipta yfir í næsta miðlunargjafa |
| `Super + Shift + Backspace` | Víxla gluggabilum |
| `Super + Ctrl + Alt + F` | Víxla heilskjáborði (efsta stika + gluggabil) |

## Áminningar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Stilla áminningu |
| `Super + Ctrl + Alt + R` | Sjá allar áminningar |
| `Super + Ctrl + Shift + R` | Hreinsa allar áminningar |

## Ábendingar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Sýna klukkuna sem tilkynningu |
| `Super + Ctrl + Alt + B` | Sýna rafhlöðu sem tilkynningu |
| `Super + Ctrl + Alt + W` | Víxla veðri sem tilkynningu |

## Tmux

Forskeytislykillinn er `Ctrl + Space` (`Ctrl + B` virkar líka). Þú getur breytt þessum bindingum í `~/.config/tmux/tmux.conf`.

### Rúður

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Prefix + v` | Skipta rúðu við hliðina (lóðrétt) |
| `Prefix + h` | Skipta rúðu fyrir neðan (lárétt) |
| `Prefix + x` | Drepa rúðu |
| `Prefix + z` | Víxla þysjun rúðu (heilskjár) |
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
| `Alt + 1-9` | Fara á tiltekinn glugga |
| `Alt + Arrow Left/Right` | Fara á milli glugga |
| `Alt + Shift + Arrow Left/Right` | Færa glugga til vinstri/hægri |

### Setur

| Flýtilykill | Virkni |
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
| `Prefix + :` | Skipanalína |

### Tmux-framsetningarföll

Þessi föll verður að keyra inni í Tmux-setu.

| Skipun | Virkni |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Búa til þróunarframsetningu með ritli, gervigreind og útstöð |
| `tdlm <ai> [<second_ai>]` | Búa til þróunarframsetningu fyrir hverja undirmöppu |
| `tsl <count> <command>` | Búa til margra-rúðu sveimframsetningu |

## Ghostty útstöð

Ghostty-útstöð er sett upp með _Install > Terminal_ í gegnum Omarchy-valmyndina.

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Ný skipting fyrir neðan |
| `Ctrl + Shift + O` | Ný skipting við hliðina |
| `Ctrl + Alt + Arrows` | Fara á milli skiptinga |
| `Super + Ctrl + Shift + Arrows` | Breyta stærð skiptingar um 10 línur |
| `Super + Ctrl + Shift + Alt + Arrows` | Breyta stærð skiptingar um 100 línur |
| `Ctrl + Shift + T` | Nýr flipi |
| `Ctrl + Shift + Arrows` | Fara á milli flipa |
| `Alt + Numbers` | Fara á tiltekinn flipa |
| `Shift + Pg Up/Down` | Skruna söguna |
| `Ctrl + Left mouse` | Opna tengil í vafra |

## Skráarstjóri

| Flýtilykill | Virkni |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Fara á slóð |
| `Space` | Forskoða skrá (örvar fletta) |
| `Alt + Up` | Fara upp í yfirmöppu |

## Neovim (með lazyvim)

### Leiðsögn

| Flýtilykill | Virkni |
| ------------------------ | ------------------------------- |
| `Space` | Sýna skipanavalkosti |
| `Space Space` | Opna skrá með loðinni leit |
| `Space E` | Víxla hliðarstiku |
| `Space G G` | Sýna git-stýringar |
| `Space S G` | Leita í innihaldi skrár |
| `Ctrl + W W` | Hoppa á milli hliðarstiku og ritils |
| `Ctrl + Left/right arrow` | Breyta stærð hliðarstiku |
| `Shift + H` | Fara á vinstri skráarflipa |
| `Shift + L` | Fara á hægri skráarflipa |
| `Space B D` | Loka skráarflipa |

### Meðan í hliðarstiku er

| Flýtilykill | Virkni |
| ------------------------ | ------------------------------- |
| `A` | Bæta við nýrri skrá í yfirmöppu |
| `Shift + A` | Bæta við nýrri undirmöppu í yfirmöppu |
| `D` | Eyða auðkenndri skrá/möppu |
| `M` | Færa auðkenda skrá/möppu |
| `R` | Endurnefna auðkenda skrá/möppu |
| `?` | Sýna hjálp fyrir allar skipanir |

[Sjá alla Neovim-flýtilykla sem LazyVim stillir](https://www.lazyvim.org/keymaps).

## Fljótlegar táknmyndir

Þú getur notað `Super + Ctrl + E` til að sýna heildstæðan táknmyndaveljara sem setur valið á klippiborðið, eða þú getur notað þessa fljótlegu aðgangskosti.

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
| `Shift + CapsLock M E` | 🙄 | augnarúll |
| `Shift + CapsLock M I` | 😉 | blikk |
| `Shift + CapsLock M P` | 🙏 | biðja |
| `Shift + CapsLock M D` | 🤤 | slef |
| `Shift + CapsLock M M` | 💰 | peningar |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | skál |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | kveðja |
| `Shift + CapsLock M A` |💪 | armur |
| `Shift + CapsLock M B` |🤯 | sprenging |

## Fljótlegar útfyllingar

| Flýtilykill | Útfylling |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (langt þankastrik) |
| `Shift + CapsLock Space N` | Nafnið þitt (eins og það var slegið inn við uppsetningu) |
| `Shift + CapsLock Space E` | Netfangið þitt (eins og það var slegið inn við uppsetningu) |

Þú getur bætt við fleiri þínum eigin með því að breyta `~/.XCompose`, keyra svo `omarchy-restart-xcompose` í útstöðinni til að breytingarnar taki gildi.
