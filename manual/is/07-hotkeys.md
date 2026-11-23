# Flýtilyklar

Þú getur séð allar helstu lyklabindingar með `Super + K` (Tmux-bindingar með `Super + Alt + K` og Herdr-bindingar með `Super + Ctrl + K`).

## Hvernig flýtilyklar eru skipulagðir

Sérhver flýtilykill er á ákveðnum fleti, sem aukalyklarnir ákvarða, og hver flötur hefur eitt hlutverk. Það er það sem kemur í veg fyrir að flýtilyklarnir renni saman og þýðir að þú getur yfirleitt giskað á hvar eitthvað er að finna.

| Flötur | Hvað er þar | Dæmi |
| --- | --- | --- |
| `Super + key` | Kerfið: gluggar, vinnusvæði, framsetningar og kjarnavalmyndir | `Super + Space` Omarchy-valmynd, `Super + W` loka glugga, `Super + F` fullur skjár |
| `Super + Shift + key` | Forrit | `Super + Shift + B` vafri, `Super + Shift + E` netpóstur, `Super + Shift + N` ritill |
| `Super + Ctrl + key` | Spjöld og kerfisvalmyndir | `Super + Ctrl + A` hljóð, `Super + Ctrl + N` net, `Super + Ctrl + C` tökuvalmynd |
| `Super + Ctrl + Alt + key` | Flýtiaðgerðir og stuttar tilkynningar | `Super + Ctrl + Alt + T` sýna klukku, `Super + Ctrl + Alt + B` rafhlaða, `Super + Ctrl + Alt + C` skjáskot |

Að bæta `Alt` við flýtilykil gefur þér afbrigði af sama hlutnum, aldrei eitthvað óskylt:

- `Super + Shift + B` opnar vafrann; `Super + Shift + Alt + B` opnar einkaglugga
- `Super + Shift + E` opnar netpóst; `Super + Shift + Alt + E` byrjar nýjan
- `Super + F` fer á fullan skjá; `Super + Alt + F` fer á fulla breidd
- `Super + Ctrl + C` opnar tökuvalmyndina; `Super + Ctrl + Alt + C` sleppir valmyndinni og tekur skjáskot

Þegar þú bætir við flýtilykli:

1. Veldu flötinn út frá því hvað hann gerir, veldu síðan lykilinn.
2. Ekki færa núverandi flýtilykil til að búa til pláss. Finndu lausan lykil á réttum fleti.
3. Notaðu `Alt` aðeins fyrir afbrigði af flýtilyklinum án hans.

Nokkrir flýtilyklar brjóta þessar reglur af því að það er þægilegt. `Shift` með ör eða `Tab` færir eða snýr við í stað þess að opna forrit, og `Print`, miðlunarlyklarnir, `Alt + Tab` og `Ctrl + Alt + Del` virka eins og þeir gera alls staðar annars staðar. Þeir eru undantekningar, ekki mynstur til að líkja eftir.

Ef sjálfgefinn lykill hentar þér ekki (segjum að þú viljir `Super + Shift + S` fyrir skjáskot eins og í Windows), skaltu endurbinda hann í `~/.config/hypr/bindings.lua`.

## Að fara um

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy-valmynd (forrit og allt annað) |
| `Super + Alt + Space` | Forritayfirlit |
| `Super + Escape` | Kerfisvalmynd (svæfa, endurræsa o.s.frv.) |
| `Super + Ctrl + L` | Læsa tölvu |
| `Super + W` or `Super + Q` | Loka glugga |
| `Ctrl + Alt + Del` | Loka öllum gluggum |
| `Super + K` | Sýna alla flýtilykla |
| `Super + Alt + K` | Sýna tmux-flýtilykla |
| `Super + Ctrl + K` | Sýna herdr-flýtilykla |
| `Super + M` | Lágmarka glugga í bryggjuna |
| `Super + T` | Skipta glugga á milli þess að vera flísalagður/fljótandi |
| `Super + J` | Skipta stöðu glugga (lárétt/lóðrétt) |
| `Super + O` | Skipta glugga yfir í límist og flýtur-stillingu |
| `Super + L` | Fara í gegnum dwindle-, rúllunar- og fljótandi framsetningarnar |
| `Super + Alt + L` | Fara í gegnum framsetningarnar í öfugri röð |
| `Super + P` | Skipta gervigluggastíl (náttúrulegur á móti teygður) |
| `Super + F` | Fara á fullan skjá |
| `Super + Alt + F` | Fara á fulla breidd |
| `Super + Ctrl + F` | Fara á fullan skjá inni í glugga |
| `Super + 1…9/0` | Fara á tiltekið vinnusvæði (0 er 10) á skjánum sem er í fókus |
| `Super + Tab` | Fara á næsta vinnusvæði á skjánum sem er í fókus |
| `Super + Shift + Tab` | Fara á fyrra vinnusvæði á skjánum sem er í fókus |
| `Super + Ctrl + Tab` | Fara á fyrra vinnusvæði á skjánum sem er í fókus |
| `Super + Shift + 1…9/0` | Færa glugga á vinnusvæði á skjánum sem er í fókus |
| `Super + Shift + Alt + 1…9/0` | Færa glugga á vinnusvæði á skjánum sem er í fókus án þess að fylgja eftir |
| `Super + S` | Skipta krotblaði í fullri stærð |
| `Super + Alt + S` | Færa glugga á krotblað í fullri stærð |
| `Super + the key above Tab` (grave on US layouts) | Skipta Quake-stjórnborði |
| `Super + Shift + the key above Tab` (grave on US layouts) | Færa glugga á Quake-stjórnborð |
| `Super + Shift + Ctrl + Arrows` | Færa glugga á skjáinn í þá átt |
| `Super + Shift + Alt + Arrows` | Færa vinnusvæði á skjáinn í þá átt |
| `Super + Arrow` | Færa fókus á glugga í átt örvarinnar, yfir á skjáinn þeim megin við jaðar skjásins |
| `Super + Shift + Arrow` | Skipta glugga við annan í átt örvarinnar, þar með talinn glugga á skjánum þeim megin |
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
| `Super + Scroll Wheel` | Fletta í gegnum vinnusvæði á skjánum sem er í fókus |
| `Super + G` | Skipta gluggahópun |
| `Super + Alt + G` | Færa glugga úr hópun |
| `Super + Alt + Tab` | Fara á milli glugga í hópun |
| `Super + Alt + Shift + Tab` | Fara aftur á bak á milli glugga í hópun |
| `Super + Alt + Scroll Wheel` | Fara á milli glugga í hópun |
| `Super + Alt + 1/2/3/4/5` | Fara á tiltekinn glugga í hópun |
| `Super + Alt + Arrow` | Færa glugga inn í hópun í átt örvarinnar, þar með talinn glugga á skjánum þeim megin |
| `Super + Ctrl + Left/Right` | Fara á milli glugga inni í flísahópi |
| `Super + Ctrl + Z` | Þysja inn á skjáinn (endurtaktu fyrir meiri þysjun) |
| `Super + Ctrl + Alt + Z` | Þysja alveg út frá skjánum |
| `Super + /` | Fara áfram í gegnum valkosti fyrir kvörðun skjás |
| `Super + Alt + /` | Fara aftur á bak í gegnum valkosti fyrir kvörðun skjás |
| `Alt + Tab` | Fara áfram í gegnum glugga á virka vinnusvæðinu |
| `Alt + Shift + Tab` | Fara aftur á bak í gegnum glugga á virka vinnusvæðinu |
| `Ctrl + Alt + Tab` | Færa fókus áfram í gegnum skjái |
| `Ctrl + Alt + Shift + Tab` | Færa fókus aftur á bak í gegnum skjái |
| `Super + I` | Skipta um innsláttarmál (þegar fleiri en eitt skipulag eða innsláttaraðferð er til staðar) |
| `Super + Shift + I` | Skipta aftur um innsláttarmál |

Á snertiborði skipta þriggja og fjögurra fingra strjúkingar um vinnusvæði, færa glugga og opna valmyndina og Quake-stjórnborðið; sjá [lyklaborð, mús og snertiborð](34-keyboard-mouse-trackpad.md) fyrir bendingarnar.

Stærðarbreyting notar tvo lyklana hægra megin við 0, hvað sem lyklaborðið þitt prentar á þá: `-` og `=` á bandarískum lyklaborðum, `+` og `´` á dönskum og sænskum, `+` og `\` á norskum, `ß` og `´` á þýskum, `'` og `¡` á spænskum og `-` og `^` á japönskum (JIS). `Super + K` sýnir þá eins og lyklaborðið þitt prentar þá. Á JIS er `Super + ^` `Super + Equal`, en `Super + Shift + -` (sem skrifar `=`) er `Super + Shift + Minus`. Kvörðun skjás og lykilorðastjórinn nota `/`; á skipulögum sem skrifa `/` aðeins með Shift, eins og flest evrópsk gera, nota þau lykilinn vinstra megin við hægri Shift í staðinn (`-` á dönskum og þýskum).

## Kerfisstýringar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Hljóðspjald |
| `Super + Ctrl + B` | Bluetooth-spjald |
| `Super + Ctrl + N` | Wi-Fi/netspjald |
| `Super + Ctrl + D` | Skjáspjald |
| `Super + Ctrl + P` | Orkuspjald |
| `Super + Ctrl + X` | Umboðaspjald |
| `Super + Ctrl + Alt + D` | Dagatalsspjald |
| `Super + Ctrl + Alt + E` | Heimsklukkuspjald |
| `Super + Ctrl + 1-9` | Skipta spjaldi á stikunni eftir stöðu |
| `Super + Ctrl + S` | Deilingarvalmynd (í gegnum LocalSend) |
| `Super + Ctrl + C` | Tökustýringar (skjáskot/-upptaka/val) |
| `Super + Ctrl + O` | Skipta valmynd |
| `Super + Ctrl + H` | Vélbúnaðarvalmynd |
| `Super + Ctrl + E` | Emoji-val |
| `Super + Ctrl + .` | Umkóða miðla |
| `Super + Shift + Ctrl + A` | Ræsa sjálfgefna umboðinn þinn |
| `Power` lykillinn | Kerfisvalmynd |
| `Super + Shift + Copilot` lykillinn | Omarchy-valmynd |

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
| `Display` lykillinn | Fara í gegnum framsetningu vinnusvæðis |
| `Alt + Play` | Næsta lag |
| `Alt + Shift + Play` | Fyrra lag |

## Að opna forrit

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Return` | Flugstöð |
| `Super + Alt + Return` | Tmux-flugstöð |
| `Super + Ctrl + Return` | Herdr (umboðsstjóri) |
| `Super + Shift + Return` or `Super + Shift + B` | Vafri |
| `Super + Shift + Alt + B` | Vafri (einka/huliðs) |
| `Super + Shift + F` | Skráarstjóri |
| `Super + Shift + Alt + F` | Skráarstjóri í cwd flugstöðvarinnar |
| `Super + Shift + M` | Tónlist (Spotify) |
| `Super + Shift + Alt + M` | Tónlist (cliamp) |
| `Super + Shift + /` | Lykilorðastjóri (1password) |
| `Super + Shift + Q` or `Calculator` lykillinn | Reiknivél (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, eftir uppsetningu) |
| `Super + Shift + T` | Virkni (btop) |
| `Super + Shift + N` | Ritill (Plain, eða sjálfgefni ritillinn þinn) |
| `Super + Shift + C` | Dagatal ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Netpóstur ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Nýr netpóstur ([HEY](https://hey.com/)) |
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

## Alhliða klemmuspjald

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + A` | Velja allt í forritum sem styðja `Ctrl + A` |
| `Super + C` | Afrita |
| `Super + X` | Klippa (ekki í flugstöð) |
| `Super + V` | Líma |
| `Super + Ctrl + V` | Klemmuspjaldsstjóri |

Venjulega á Linux þarftu `Ctrl + Shift + C/V` til að afrita og líma í flugstöðinni og `Ctrl + C/V` til að gera það alls staðar annars staðar. Þessir sameinuðu klemmuspjaldsflýtilyklar Omarchy virka alls staðar.

## Taka

| Flýtilykill | Virkni |
| ------------------- | ------------------------------ |
| `Print Screen` | Skjáskot |
| `Super + Ctrl + Alt + C` | Skjáskot (sama mynd, fyrir lyklaborð án Print Screen-lykils) |
| `Super + Ctrl + C` | Tökuvalmynd |
| `Alt + Print Screen` | Skjáupptaka |
| `Super + Shift + Ctrl + Alt + C` | Skjáupptaka án hljóðs, sleppir valmyndinni (ýttu aftur til að stöðva) |
| `Super + Print Screen` | Litaval |
| `Super + Ctrl + Print Screen` | Textaútdráttur á klemmuspjald |
| `Super + Alt + [` | Gera vefmyndavélaryfirlag minna meðan á upptöku stendur |
| `Super + Alt + ]` | Gera vefmyndavélaryfirlag stærra meðan á upptöku stendur |
| `Alt + Shift + L` | Afrita núverandi URL úr vefforriti eða vafra |
| `Alt + Shift + D` | Sækja myndbandið á núverandi síðu í `~/Videos` |
| `Alt + Space` | Byrja/stöðva talinnslátt (krefst _Uppsetning > Sjálfgefið > Talinnsláttur_) |
| `Right Alt` | Halda inni til að tala inn (krefst _Uppsetning > Sjálfgefið > Talinnsláttur_) |

Með skjáupptökum spyr flýtilykillinn fyrst hvaða hljóð þú vilt, byrjar síðan upptöku. Ýttu á hann aftur til að stöðva. Sjá [skjáskot og upptaka](12-screenshots-recording.md) fyrir nánari upplýsingar.

Allir tökuvalkostir eru líka aðgengilegir undir _Kveikja > Taka_ í Omarchy-valmyndinni (`Super + Space`).

## Tilkynningar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + ,` | Bregðast við nýjustu tilkynningu: opna hana eða ýta á eina hnappinn hennar, velja úr valkostum hennar eða vísa henni frá þegar hún hefur enga |
| `Super + Shift + ,` | Vísa öllum tilkynningum frá |
| `Super + Ctrl + ,` | Stjórna tilkynningum með lyklaborðinu |
| `Super + Alt + ,` | Vísa nýjustu tilkynningu frá |
| `Super + Shift + Alt + ,` | Opna tilkynningasögu |
| `Super + Ctrl + Alt + ,` | Skipta þöggun tilkynninga |

## Stíll

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Velja nýtt þema (líka `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Velja bakgrunn þema (líka `Super + Ctrl + Space`) |
| `Super + Backspace` | Skipta gegnsæi á glugga |
| `Super + Ctrl + Backspace` | Skipta ferningshlutfalli eins glugga |

Aukabakgrunnsmyndir eru í `~/.config/omarchy/backgrounds/<theme name>`. Einnig aðgengilegt í gegnum _Setja upp > Stíll > Bakgrunnur_ í Omarchy-valmyndinni.

Allir stílvalkostir eru líka aðgengilegir undir _Útlit_ í Omarchy-valmyndinni (`Super + Space`).

## Rofar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Skipta læsingu við aðgerðaleysi |
| `Super + Ctrl + Delete` | Kveikja/slökkva á skjá fartölvu |
| `Super + Ctrl + Alt + Delete` | Skipta speglun skjás fartölvu |
| `Super + Shift + Space` | Skipta efstu stikunni |
| `Shift + Mute` | Skipta yfir í næsta hljóðútgang |
| `Shift + Play` | Skipta yfir í næsta miðlunargjafa |
| `Super + Shift + Backspace` | Skipta gluggabilum |
| `Super + Ctrl + Alt + F` | Skipta fullskjásskrifborði (efsta stika + gluggabil) |

## Áminningar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Stilla áminningu |
| `Super + Ctrl + Alt + R` | Sjá allar áminningar |
| `Super + Ctrl + Shift + R` | Hreinsa allar áminningar |

## Stuttar tilkynningar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Sýna klukkuna sem tilkynningu |
| `Super + Ctrl + Alt + B` | Sýna rafhlöðu sem tilkynningu |
| `Super + Ctrl + Alt + W` | Skipta veðri sem tilkynningu |

## Tmux

Forskeytislykillinn er `Ctrl + Space` (`Ctrl + B` virkar líka). Þú getur breytt þessum bindingum í `~/.config/tmux/tmux.conf`.

### Reitir

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Prefix + v` | Skipta reit við hliðina (lóðrétt) |
| `Prefix + h` | Skipta reit fyrir neðan (lárétt) |
| `Prefix + x` | Loka reit |
| `Prefix + z` | Skipta þysjun reits (fullur skjár) |
| `Alt + Enter` | Skipta reit fyrir neðan (án forskeytis) |
| `Alt + Shift + Enter` | Skipta reit við hliðina (án forskeytis) |
| `Alt + Escape` | Loka reit (án forskeytis) |
| `Ctrl + Alt + Arrows` | Fara á milli reita |
| `Ctrl + Alt + Shift + Arrows` | Breyta stærð reita |

### Gluggar

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Prefix + c` | Nýr gluggi |
| `Prefix + k` | Loka glugga |
| `Prefix + r` | Endurnefna glugga |
| `Alt + 1-9` | Fara á tiltekinn glugga |
| `Alt + Arrow Left/Right` | Fara á milli glugga |
| `Alt + Shift + Arrow Left/Right` | Færa glugga til vinstri/hægri |

### Setur

| Flýtilykill | Virkni |
| ----------------------- | --------------------- |
| `Prefix + C` | Ný seta |
| `Prefix + K` | Loka setu |
| `Prefix + R` | Endurnefna setu |
| `Prefix + N` | Næsta seta |
| `Prefix + P` | Fyrri seta |
| `Alt + Arrow Up/Down` | Fara á milli seta |
| `Prefix + s` | Sýna lista yfir setur |
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
| `tdl <ai> [<second_ai>]` | Búa til þróunarframsetningu með ritli, AI og flugstöð |
| `tdlm <ai> [<second_ai>]` | Búa til þróunarframsetningu fyrir hverja undirmöppu |
| `tsl <count> <command>` | Búa til fjölreita sveimsframsetningu |

## Ghostty-flugstöð

Ghostty-flugstöðin er sett upp með _Setja upp > Flugstöð_ í gegnum Omarchy-valmyndina.

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
| `Shift + Pg Up/Down` | Fletta í gegnum söguna |
| `Ctrl + Left mouse` | Opna tengil í vafra |

## Skráarstjóri

| Flýtilykill | Virkni |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Fara á slóð |
| `Space` | Forskoða skrá (örvar færa) |
| `Alt + Up` | Fara upp í yfirmöppu |

## Neovim (með lazyvim)

### Flakk

| Flýtilykill | Virkni |
| ------------------------ | ------------------------------- |
| `Space` | Sýna skipanavalkosti |
| `Space Space` | Opna skrá með óskýrri leit |
| `Space E` | Skipta hliðarstiku |
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
| `D` | Eyða merktri skrá/möppu |
| `M` | Færa merkta skrá/möppu |
| `R` | Endurnefna merkta skrá/möppu |
| `?` | Sýna hjálp fyrir allar skipanir |

[Sjá alla Neovim-flýtilykla sem LazyVim stillir](https://www.lazyvim.org/keymaps).

## Flýtivalkostir fyrir emoji

Þú getur notað `Super + Ctrl + E` til að sýna heildstæðan emoji-veljara sem setur valið á klemmuspjald eða þú getur notað þessa flýtivalkosti.

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
| `Shift + CapsLock M E` | 🙄 | augnagot |
| `Shift + CapsLock M I` | 😉 | blikk |
| `Shift + CapsLock M P` | 🙏 | biðja |
| `Shift + CapsLock M D` | 🤤 | slefa |
| `Shift + CapsLock M M` | 💰 | peningar |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | skál |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | kveðja |
| `Shift + CapsLock M A` |💪 | handleggur |
| `Shift + CapsLock M B` |🤯 | springur |

## Flýtifyllingar

| Flýtilykill | Fylling |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Nafnið þitt (eins og það var slegið inn við uppsetningu) |
| `Shift + CapsLock Space E` | Netfangið þitt (eins og það var slegið inn við uppsetningu) |

Þú getur bætt við fleiri eigin með því að breyta `~/.XCompose`, keyra síðan `omarchy restart xcompose` í flugstöðinni til að breytingarnar taki gildi.
