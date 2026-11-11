# Flýtilyklar

Þú getur séð allar helstu lyklaborðsbindingar með `Super + K` (Tmux-bindingar með `Super + Alt + K` og Herdr-bindingar með `Super + Ctrl + K`).

## Hvernig flýtilyklar eru skipulagðir

Sérhver flýtilykill situr á fleti, sem aukalyklarnir ákvarða, og hver flötur hefur eitt hlutverk. Það heldur flýtilyklunum aðgreindum og þýðir að þú getur yfirleitt giskað á hvar eitthvað býr.

| Flötur | Hvað býr þar | Dæmi |
| --- | --- | --- |
| `Super + key` | Kerfið: gluggar, vinnusvæði, framsetningar og kjarnavalmyndir | `Super + Space` Omarchy-valmynd, `Super + W` loka glugga, `Super + F` fullur skjár |
| `Super + Shift + key` | Forrit | `Super + Shift + B` vafri, `Super + Shift + E` tölvupóstur, `Super + Shift + N` ritill |
| `Super + Ctrl + key` | Spjöld og kerfisvalmyndir | `Super + Ctrl + A` hljóð, `Super + Ctrl + N` net, `Super + Ctrl + C` upptökuvalmynd |
| `Super + Ctrl + Alt + key` | Flýtiaðgerðir og tilkynningar | `Super + Ctrl + Alt + T` sýna tíma, `Super + Ctrl + Alt + B` rafhlaða, `Super + Ctrl + Alt + C` skjáskot |

Að bæta `Alt` við flýtilykil gefur þér afbrigði af sama hlutnum, aldrei eitthvað óskylt:

- `Super + Shift + B` opnar vafrann; `Super + Shift + Alt + B` opnar einkaglugga
- `Super + Shift + E` opnar tölvupóst; `Super + Shift + Alt + E` byrjar nýjan
- `Super + F` fer á fullan skjá; `Super + Alt + F` fer á fulla breidd
- `Super + Ctrl + C` opnar upptökuvalmyndina; `Super + Ctrl + Alt + C` sleppir valmyndinni og tekur skjáskot

Þegar þú bætir við flýtilykli:

1. Veldu flötinn út frá því hvað hann gerir, veldu síðan lykilinn.
2. Ekki færa núverandi flýtilykil til að búa til pláss. Finndu lausan lykil á réttum fleti.
3. Notaðu `Alt` aðeins fyrir afbrigði af flýtilyklinum án þess.

Nokkrir flýtilyklar brjóta þessar reglur af því að það er þægilegt. `Shift` með ör eða `Tab` færir eða snýr við í stað þess að opna forrit, og `Print`, miðlunarlyklarnir, `Alt + Tab` og `Ctrl + Alt + Del` virka eins og alls staðar annars staðar. Þeir eru undantekningar, ekki mynstur til að herma eftir.

Ef sjálfgefin binding hentar þér ekki (segjum að þú viljir `Super + Shift + S` fyrir skjáskot eins og í Windows), skaltu endurbinda hana í `~/.config/hypr/bindings.lua`.

## Að flakka

| Flýtilykill                  | Aðgerð              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-valmynd (forrit og allt annað)    |
| `Super + Alt + Space` | Forritarist |
| `Super + Escape` | Kerfisvalmynd (setja í bið, endurræsa o.s.frv.)  |
| `Super + Ctrl + L` | Læsa tölvu |
| `Super + W` or `Super + Q` | Loka glugga             |
| `Ctrl + Alt + Del` | Loka öllum gluggum |
| `Super + T`               | Víxla glugga á milli flísalagðs/fljótandi             |
| `Super + J` | Víxla stöðu glugga (lárétt/lóðrétt) |
| `Super + O`               | Víxla því að gluggi skjótist fram sem klístraður og fljótandi |
| `Super + L`               | Fara í gegnum framsetningarnar dwindle, scrolling og floating |
| `Super + Alt + L`         | Fara í gegnum framsetningarnar í öfugri röð |
| `Super + P`               | Víxla gerviglugga-stíl (náttúrulegur á móti teygður) |
| `Super + F`                 | Fara á fullan skjá              |
| `Super + Alt + F`                 | Fara á fulla breidd              |
| `Super + Ctrl + F`                 | Fara á fullan skjá inni í glugga              |
| `Super + 1/2/3/4`         | Hoppa á ákveðið vinnusvæði á skjánum í fókus |
| `Super + Tab` | Hoppa á næsta vinnusvæði á skjánum í fókus |
| `Super + Shift + Tab` | Hoppa á fyrra vinnusvæði á skjánum í fókus |
| `Super + Ctrl + Tab` | Hoppa á vinnusvæðið sem var notað áður á skjánum í fókus |
| `Super + Shift + 1/2/3/4` | Færa glugga á vinnusvæði á skjánum í fókus |
| `Super + Shift + Alt + 1/2/3/4` | Færa glugga á vinnusvæði á skjánum í fókus án þess að fylgja eftir |
| `Super + S` | Víxla fullum kladda |
| `Super + Alt + S` | Færa glugga á fullan kladda |
| `Super + Grave` | Víxla Quake-stjórnborði |
| `Super + Shift + Grave` | Færa glugga á Quake-stjórnborð |
| `Super + Shift + Ctrl + Arrows` | Færa glugga á skjáinn í þá átt |
| `Super + Shift + Alt + Arrows` | Færa vinnusvæði á skjáinn í þá átt |
| `Super + Arrow`  | Færa fókus á glugga í átt örvarinnar, yfir á skjáinn þeim megin við jaðar skjásins |
| `Super + Shift + Arrow`  | Skipta glugga við annan í átt örvarinnar, þar með talinn glugga á skjánum þeim megin |
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
| `Super + G`               | Víxla gluggahópun      |
| `Super + Alt + G`               | Færa glugga út úr hópun      |
| `Super + Alt + Tab`               | Fara í gegnum glugga í hópun      |
| `Super + Alt + Shift + Tab`               | Fara aftur á bak í gegnum glugga í hópun      |
| `Super + Alt + Scroll Wheel` | Fara í gegnum glugga í hópun |
| `Super + Alt + 1/2/3/4/5`               | Hoppa á ákveðinn glugga í hópun      |
| `Super + Alt + Arrow`  | Færa glugga inn í hópun í átt örvarinnar, þar með talinn glugga á skjánum þeim megin |
| `Super + Ctrl + Left/Right`  | Fara á milli glugga inni í flísahópi |
| `Super + Ctrl + Z` | Þysja inn á skjáinn (endurtaktu fyrir meiri þysjun) |
| `Super + Ctrl + Alt + Z` | Þysja alveg út af skjánum |
| `Super + /` | Fara áfram í gegnum valkosti fyrir skölun skjás |
| `Super + Alt + /` | Fara aftur á bak í gegnum valkosti fyrir skölun skjás |
| `Alt + Tab` | Fara áfram í gegnum glugga á virka vinnusvæðinu |
| `Alt + Shift + Tab` | Fara aftur á bak í gegnum glugga á virka vinnusvæðinu |
| `Ctrl + Alt + Tab`| Fara með fókus áfram í gegnum skjái |
| `Ctrl + Alt + Shift + Tab`| Fara með fókus aftur á bak í gegnum skjái |

Flýtilyklar fyrir stærðarbreytingu nota efnislega lykla `code:20` og `code:21` (XKB `<AE11>` og `<AE12>`), óháð því hvaða stafir eru prentaðir á lyklaborðið. Á bandarískum lyklaborðum eru þessir lyklar `-` og `=`; á japönskum (JIS) lyklaborðum eru þeir `-` og `^`; á spænskum lyklaborðum eru þeir `'` og `¡`. Á JIS er `Super + ^` það sama og `Super + Equal`, en `Super + Shift + -` (sem skrifar `=`) er `Super + Shift + Minus`.

## Kerfisstýringar

| Flýtilykill                  | Aðgerð              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Hljóðspjald    |
| `Super + Ctrl + B`           | Bluetooth-spjald    |
| `Super + Ctrl + N`           | Wi-Fi/netspjald    |
| `Super + Ctrl + D`           | Skjáspjald    |
| `Super + Ctrl + P`           | Orkuspjald    |
| `Super + Ctrl + X`           | Umboðsspjal​d    |
| `Super + Ctrl + Alt + D`           | Dagatalsspjald    |
| `Super + Ctrl + Alt + E`           | Heimsklukkuspjald    |
| `Super + Ctrl + 1-9`           | Víxla spjaldi á stikunni eftir stöðu    |
| `Super + Ctrl + S` | Deilingarvalmynd (í gegnum LocalSend) |
| `Super + Ctrl + C` | Upptökustýringar (skjáskot/-upptaka/veljari) |
| `Super + Ctrl + O` | Víxlavalmynd |
| `Super + Ctrl + H` | Vélbúnaðarvalmynd |
| `Super + Ctrl + E` | Emoji-veljari |
| `Super + Ctrl + .` | Umkóða miðla |
| `Super + Shift + Ctrl + A` | Velja AI-umboð |

## Stillingar

| Flýtilykill                  | Aðgerð              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Hámarksbirta skjás |
| `Shift + Brightness Down` | Lágmarksbirta skjás |
| `Alt + Brightness Up/Down` | Nákvæmar breytingar á birtu um 1% |
| `Alt + Volume Up/Down` | Nákvæmar breytingar á hljóðstyrk um 1% |
| `Keyboard Brightness Up/Down` | Baklýsing lyklaborðs bjartari/dekkri |
| `Keyboard Backlight` | Fara í gegnum stig baklýsingar lyklaborðs |
| `Alt + Play` | Næsta lag |
| `Alt + Shift + Play` | Fyrra lag |

## Að ræsa forrit

| Flýtilykill                  | Aðgerð              |
| ----------------------- | --------------------- |
| `Super + Return`           | Skjáhermir    |
| `Super + Alt + Return` | Tmux-skjáhermir |
| `Super + Ctrl + Return` | Herdr (umboðsstjóri) |
| `Super + Shift + Return`           | Vafri    |
| `Super + Shift + Alt + B`           | Vafri (einka/huliðs)    |
| `Super + Shift + F`           | Skráastjóri    |
| `Super + Shift + Alt + F`           | Skráastjóri í cwd skjáhermis    |
| `Super + Shift + M`           | Tónlist (Spotify)    |
| `Super + Shift + Alt + M`           | Tónlist (cliamp)    |
| `Super + Shift + /`           | Lykilorðastjóri (1password)    |
| `Super + Shift + Q`           | Reiknivél (Omacalc)    |
| `Super + Shift + T`           | Virkni (btop)    |
| `Super + Shift + N`           | Ritill (Neovim)  |
| `Super + Shift + C`           | Dagatal ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Tölvupóstur ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nýr tölvupóstur ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Gervigreind (ChatGPT)  |
| `Super + Shift + Alt + A`           | Gervigreind (Grok)  |
| `Super + Shift + G`           | Skilaboðaforrit (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Skilaboðaforrit (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Skilaboðaforrit (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Ritun (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Breyttu/bættu við bindingum í `~/.config/hypr/bindings.lua`.

## Alhliða klemmuspjald

| Flýtilykill                  | Aðgerð              |
| ----------------------- | --------------------- |
| `Super + A`           | Velja allt í forritum sem styðja `Ctrl + A`    |
| `Super + C`           | Afrita    |
| `Super + X`           | Klippa (ekki í skjáhermi)    |
| `Super + V`           | Líma    |
| `Super + Ctrl + V`           | Klemmuspjaldsstjóri    |

Venjulega á Linux þarftu `Ctrl + Shift + C/V` til að afrita og líma í skjáherminum og `Ctrl + C/V` til að gera það alls staðar annars staðar. Þessir sameinuðu klemmuspjaldsflýtilyklar Omarchy virka alls staðar.

## Upptaka

| Flýtilykill              | Aðgerð                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Skjáskot                      |
| `Super + Ctrl + Alt + C`            | Skjáskot (sama skot, fyrir lyklaborð án Print Screen-lykils) |
| `Super + Ctrl + C` | Upptökuvalmynd |
| `Alt + Print Screen`            | Skjáupptaka                     |
| `Super + Print Screen` | Litaveljari |
| `Super + Ctrl + Print Screen` | Textaútdráttur á klemmuspjald |
| `Super + Alt + [` | Minnka yfirlag vefmyndavélar meðan á upptöku stendur |
| `Super + Alt + ]` | Stækka yfirlag vefmyndavélar meðan á upptöku stendur |
| `Alt + Shift + L` | Afrita núverandi URL úr vefforriti eða Chromium |
| `Alt + Shift + D` | Sækja myndbandið á núverandi síðu í `~/Videos` |
| `Alt + Space` | Byrja/stöðva inntal (krefst _Setup > Defaults > Dictation_) |
| `Right Alt` | Haltu inni til að tala inn (krefst _Setup > Defaults > Dictation_) |

Með skjáupptökum spyr flýtilykillinn fyrst hvaða hljóð þú vilt, byrjar síðan upptöku. Ýttu á hann aftur til að stöðva. Sjá [skjáskot og upptaka](12-screenshots-recording.md) fyrir nánari upplýsingar.

Allir upptökuvalkostir eru líka aðgengilegir undir _Trigger > Capture_ í Omarchy-valmyndinni (`Super + Space`).

## Tilkynningar

| Flýtilykill                  | Aðgerð              |
| ----------------------- | --------------------- |
| `Super + ,` | Bregðast við nýjustu tilkynningu: opna hana eða ýta á eina hnappinn hennar, velja úr valkostum hennar, eða fjarlægja hana þegar hún hefur enga  |
| `Super + Shift + ,` | Fjarlægja allar tilkynningar |
| `Super + Ctrl + ,` | Stjórna tilkynningum með lyklaborðinu  |
| `Super + Alt + ,` | Fjarlægja nýjustu tilkynningu  |
| `Super + Shift + Alt + ,` | Opna tilkynningasögu  |
| `Super + Ctrl + Alt + ,` | Víxla þöggun tilkynninga  |

## Stíll

| Flýtilykill                  | Aðgerð              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Velja nýtt þema (einnig `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Velja bakgrunn þema (einnig `Super + Ctrl + Space`) |
| `Super + Backspace` | Víxla gegnsæi á glugga |
| `Super + Ctrl + Backspace` | Víxla ferköntuðu hlutfalli fyrir einn glugga |

Auka bakgrunnsmyndir búa í `~/.config/omarchy/backgrounds/<theme name>`. Einnig aðgengilegt í gegnum _Install > Style > Background_ í Omarchy-valmyndinni.

Allir stílvalkostir eru líka aðgengilegir undir _Style_ í Omarchy-valmyndinni (`Super + Space`).

## Víxlar

| Flýtilykill                  | Aðgerð              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Víxla læsingu við aðgerðaleysi |
| `Super + Ctrl + Delete` | Kveikja/slökkva á skjá fartölvu |
| `Super + Ctrl + Alt + Delete` | Víxla speglun á skjá fartölvu |
| `Super + Shift + Space` | Víxla efstu stikunni  |
| `Shift + Mute` | Skipta yfir á næsta hljóðútgang |
| `Shift + Play` | Skipta yfir á næsta miðlunargjafa |
| `Super + Shift + Backspace` | Víxla gluggabilum |
| `Super + Ctrl + Alt + F` | Víxla fullskjáborði (efsta stika + gluggabil) |

## Áminningar

| Flýtilykill                  | Aðgerð              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Stilla áminningu  |
| `Super + Ctrl + Alt + R` | Sjá allar áminningar  |
| `Super + Ctrl + Shift + R` | Hreinsa allar áminningar  |

## Skilaboð

| Flýtilykill                  | Aðgerð              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Sýna tímann sem tilkynningu  |
| `Super + Ctrl + Alt + B` | Sýna rafhlöðu sem tilkynningu  |
| `Super + Ctrl + Alt + W` | Víxla veðri sem tilkynningu  |

## Tmux

Forskeytislykillinn er `Ctrl + Space` (`Ctrl + B` virkar líka). Þú getur breytt þessum bindingum í `~/.config/tmux/tmux.conf`.

### Rúður

| Flýtilykill                  | Aðgerð              |
| ----------------------- | --------------------- |
| `Prefix + v` | Skipta rúðu við hliðina (lóðrétt) |
| `Prefix + h` | Skipta rúðu fyrir neðan (lárétt) |
| `Prefix + x` | Drepa rúðu |
| `Prefix + z` | Víxla þysjun rúðu (fullur skjár) |
| `Alt + Enter` | Skipta rúðu fyrir neðan (án forskeytis) |
| `Alt + Shift + Enter` | Skipta rúðu við hliðina (án forskeytis) |
| `Alt + Escape` | Drepa rúðu (án forskeytis) |
| `Ctrl + Alt + Arrows` | Fara á milli rúða |
| `Ctrl + Alt + Shift + Arrows` | Breyta stærð rúða |

### Gluggar

| Flýtilykill                  | Aðgerð              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nýr gluggi |
| `Prefix + k` | Drepa glugga |
| `Prefix + r` | Endurnefna glugga |
| `Alt + 1-9` | Fara á ákveðinn glugga |
| `Alt + Arrow Left/Right` | Fara á milli glugga |
| `Alt + Shift + Arrow Left/Right` | Færa glugga til vinstri/hægri |

### Setur

| Flýtilykill                  | Aðgerð              |
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

| Flýtilykill                  | Aðgerð              |
| ----------------------- | --------------------- |
| `Prefix + [` | Fara í afritunarham |
| `v` | Byrja val (í afritunarham) |
| `y` | Afrita val (í afritunarham) |

### Almennt

| Flýtilykill                  | Aðgerð              |
| ----------------------- | --------------------- |
| `Prefix + q` | Endurhlaða stillingum |
| `Prefix + ?` | Sýna Tmux-lyklabindingar |
| `Prefix + :` | Skipanalína |

### Tmux-framsetningaraðgerðir

Þessar aðgerðir verður að keyra inni í Tmux-setu.

| Skipun | Aðgerð |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Búa til þróunarframsetningu með ritli, AI og skjáhermi |
| `tdlm <ai> [<second_ai>]` | Búa til þróunarframsetningu fyrir hverja undirmöppu |
| `tsl <count> <command>` | Búa til svemframsetningu með mörgum rúðum |

## Ghostty-skjáhermir

Ghostty-skjáhermir er settur upp með _Install > Terminal_ í gegnum Omarchy-valmyndina.

| Flýtilykill                  | Aðgerð              |
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

## Skráastjóri

| Flýtilykill              | Aðgerð                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Fara á slóð                     |
| `Space`               | Forskoða skrá (örvar flakka) |
| `Alt + Up`       | Fara upp í yfirmöppu        |

## Neovim (með lazyvim)

### Flakk

| Flýtilykill                   | Aðgerð                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Sýna skipanavalkosti            |
| `Space Space`              | Opna skrá með óskýrri leit      |
| `Space E`                  | Víxla hliðarstiku                  |
| `Space G G`                | Sýna git-stýringar               |
| `Space S G`                | Leita í innihaldi skrár             |
| `Ctrl + W W`               | Hoppa á milli hliðarstiku og ritils |
| `Ctrl + Left/right arrow`  | Breyta stærð hliðarstiku          |
| `Shift + H`                      | Fara á skráarflipa til vinstri             |
| `Shift + L`                      | Fara á skráarflipa til hægri            |
| `Space B D`                | Loka skráarflipa                  |

### Á meðan í hliðarstiku

| Flýtilykill                   | Aðgerð                        |
| ------------------------ | ------------------------------- |
| `A`                        | Bæta við nýrri skrá í yfirmöppu      |
| `Shift + A`                | Bæta við nýrri undirmöppu í yfirmöppu    |
| `D`                        | Eyða auðkenndri skrá/möppu     |
| `M`                        | Færa auðkennda skrá/möppu       |
| `R`                        | Endurnefna auðkennda skrá/möppu     |
| `?`                        | Sýna hjálp fyrir allar skipanir      |

[Sjá alla Neovim-flýtilykla sem LazyVim stillir](https://www.lazyvim.org/keymaps).

## Fljótleg Emoji-tákn

Þú getur notað `Super + Ctrl + E` til að sýna heildstæðan emoji-veljara sem setur valið á klemmuspjald, eða þú getur notað þessa flýtivalkosti.

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
| `Shift + CapsLock M E` | 🙄 | augnrúll    |
| `Shift + CapsLock M I` | 😉 | blikk       |
| `Shift + CapsLock M P` | 🙏 | biðja |
| `Shift + CapsLock M D` | 🤤 | slef      |
| `Shift + CapsLock M M` | 💰 | peningar      |
| `Shift + CapsLock M X` | 🎉 | fögnuður |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | skál      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | kveðja |
| `Shift + CapsLock M A` |💪 | handleggur |
| `Shift + CapsLock M B` |🤯 | heilasprenging |

## Fljótlegar útfyllingar

| Flýtilykill       | Útfylling       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Nafnið þitt (eins og það var slegið inn við uppsetningu)  |
| `Shift + CapsLock Space E` | Tölvupóstfangið þitt (eins og það var slegið inn við uppsetningu)  |

Þú getur bætt við fleiri af þínum eigin með því að breyta `~/.XCompose`, keyra síðan `omarchy-restart-xcompose` í skjáherminum til að breytingarnar taki gildi.
