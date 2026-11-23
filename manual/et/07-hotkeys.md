# Kiirklahvid

Kõiki peamisi klahvikombinatsioone näed `Super + K` abil (Tmuxi seosed `Super + Alt + K` ja Herdri seosed `Super + Ctrl + K` abil).

## Kuidas kiirklahvid on üles ehitatud

Iga kiirklahv asub tasandil, mille määravad selle modifikaatorid, ja igal tasandil on üks ülesanne. Just see hoiab kiirklahvid omavahel segunemast ja tähendab, et tavaliselt saad arvata, kus miski asub.

| Tasand | Mis seal asub | Näited |
| --- | --- | --- |
| `Super + key` | Süsteem: aknad, tööruumid, paigutused ja põhimenüüd | `Super + Space` Omarchy menüü, `Super + W` akna sulgemine, `Super + F` täisekraan |
| `Super + Shift + key` | Rakendused | `Super + Shift + B` brauser, `Super + Shift + E` e-post, `Super + Shift + N` redaktor |
| `Super + Ctrl + key` | Paneelid ja süsteemimenüüd | `Super + Ctrl + A` heli, `Super + Ctrl + N` võrk, `Super + Ctrl + C` jäädvustamise menüü |
| `Super + Ctrl + Alt + key` | Kiirtoimingud ja märguanded | `Super + Ctrl + Alt + T` aja kuvamine, `Super + Ctrl + Alt + B` aku, `Super + Ctrl + Alt + C` ekraanipilt |

`Alt` lisamine kiirklahvile annab sama asja variandi, mitte kunagi midagi seosetut:

- `Super + Shift + B` avab brauseri; `Super + Shift + Alt + B` avab privaatse akna
- `Super + Shift + E` avab e-posti; `Super + Shift + Alt + E` alustab uut e-kirja
- `Super + F` läheb täisekraanile; `Super + Alt + F` läheb täislaiusele
- `Super + Ctrl + C` avab jäädvustamise menüü; `Super + Ctrl + Alt + C` jätab menüü vahele ja teeb ekraanipildi

Kiirklahvi lisamisel:

1. Vali tasand selle järgi, mida see teeb, seejärel vali klahv.
2. Ära nihuta olemasolevat kiirklahvi, et ruumi teha. Leia õigel tasandil vaba klahv.
3. Kasuta `Alt` ainult ilma selleta kiirklahvi variandi jaoks.

Mõned kiirklahvid rikuvad neid reegleid, sest nii on mugav. `Shift` koos noole või `Tab`-iga liigutab või pöörab suunda, selle asemel et rakendust avada, ning `Print`, meediaklahvid, `Alt + Tab` ja `Ctrl + Alt + Del` töötavad nii, nagu nad töötavad kõikjal mujal. Need on erandid, mitte mustrid, mida kopeerida.

Kui vaikeseade sulle ei sobi (näiteks tahad ekraanipiltide jaoks `Super + Shift + S` nagu Windowsis), seo see ümber failis `~/.config/hypr/bindings.lua`.

## Navigeerimine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menüü (rakendused ja kõik muu)    |
| `Super + Alt + Space` | Rakenduste ruudustik |
| `Super + Escape` | Süsteemimenüü (peatamine, taaskäivitamine jne)  |
| `Super + Ctrl + L` | Arvuti lukustamine |
| `Super + W` or `Super + Q` | Akna sulgemine             |
| `Ctrl + Alt + Del` | Kõigi akende sulgemine |
| `Super + K` | Kõigi kiirklahvide kuvamine |
| `Super + Alt + K` | Tmuxi kiirklahvide kuvamine |
| `Super + Ctrl + K` | Herdri kiirklahvide kuvamine |
| `Super + M` | Akna minimeerimine dokki |
| `Super + T`               | Akna lülitamine plaatimise/ujuva vahel             |
| `Super + J` | Akna asendi lülitamine (horisontaalne/vertikaalne) |
| `Super + O`               | Akna lülitamine kleepuvasse ja ujuvasse režiimi |
| `Super + L`               | Dwindle-, kerimis- ja ujuva paigutuse vahel tsükliline liikumine |
| `Super + Alt + L`         | Paigutuste vahel tsükliline liikumine vastupidises suunas |
| `Super + P`               | Pseudoakna stiili lülitamine (loomulik vs venitatud) |
| `Super + F`                 | Täisekraanile minek              |
| `Super + Alt + F`                 | Täislaiusele minek              |
| `Super + Ctrl + F`                 | Täisekraanile minek akna sees              |
| `Super + 1…9/0`         | Fookuses oleval monitoril kindlale tööruumile hüppamine (0 on 10) |
| `Super + Tab` | Fookuses oleval monitoril järgmisele tööruumile hüppamine |
| `Super + Shift + Tab` | Fookuses oleval monitoril eelmisele tööruumile hüppamine |
| `Super + Ctrl + Tab` | Fookuses oleval monitoril varasemale tööruumile hüppamine |
| `Super + Shift + 1…9/0` | Akna teisaldamine tööruumile fookuses oleval monitoril |
| `Super + Shift + Alt + 1…9/0` | Akna teisaldamine tööruumile fookuses oleval monitoril ilma kaasa järgimata |
| `Super + S` | Täieliku scratchpad'i lülitamine |
| `Super + Alt + S` | Akna teisaldamine täielikku scratchpad'i |
| `Super + the key above Tab` (grave on US layouts) | Quake'i konsooli lülitamine |
| `Super + Shift + the key above Tab` (grave on US layouts) | Akna teisaldamine Quake'i konsooli |
| `Super + Shift + Ctrl + Arrows` | Akna teisaldamine selles suunas asuvale monitorile |
| `Super + Shift + Alt + Arrows` | Tööruumi teisaldamine selles suunas asuvale monitorile |
| `Super + Arrow`  | Fookuse liigutamine noole suunas asuvale aknale, ekraani serval sellel küljel asuvale monitorile üleminekuga |
| `Super + Shift + Arrow`  | Akna vahetamine noole suunas asuva teisega, kaasa arvatud sellel küljel asuval monitoril olevaga |
| `Super + Minus` | Akna laiendamine vasakule |
| `Super + Equal` | Akna kahandamine vasakult |
| `Super + Shift + Minus` | Akna kahandamine üles |
| `Super + Shift + Equal` | Akna laiendamine alla |
| `Super + Alt + Minus/Equal` | Sama suuruse muutmine väiksemate sammudega |
| `Super + Ctrl + Minus/Equal` | Sama suuruse muutmine suuremate sammudega |
| `Super + Alt + Home` | Akna laiuse salvestamine |
| `Super + Home` | Salvestatud akna laiuse taastamine |
| `Super + Left Mouse` | Akna lohistamine |
| `Super + Right Mouse` | Akna suuruse muutmine |
| `Super + Scroll Wheel` | Tööruumide kerimine fookuses oleval monitoril |
| `Super + G`               | Akende grupeerimise lülitamine      |
| `Super + Alt + G`               | Akna grupeeringust välja liigutamine      |
| `Super + Alt + Tab`               | Grupeeringus akende vahel tsükliline liikumine      |
| `Super + Alt + Shift + Tab`               | Grupeeringus akende vahel tagurpidi tsükliline liikumine      |
| `Super + Alt + Scroll Wheel` | Grupeeringus akende vahel tsükliline liikumine |
| `Super + Alt + 1/2/3/4/5`               | Grupeeringus kindlale aknale hüppamine      |
| `Super + Alt + Arrow`  | Akna liigutamine grupeeringusse noole suunas, kaasa arvatud sellel küljel asuval monitoril olevaga |
| `Super + Ctrl + Left/Right`  | Plaatide rühma sees akende vahel liikumine |
| `Super + Ctrl + Z` | Ekraanile sisse suumimine (korda suurema suumi jaoks) |
| `Super + Ctrl + Alt + Z` | Ekraanilt täielikult välja suumimine |
| `Super + /` | Monitori skaleerimisvalikutes edasi astumine |
| `Super + Alt + /` | Monitori skaleerimisvalikutes tagasi astumine |
| `Alt + Tab` | Aktiivsel tööruumil akende vahel edasi tsükliline liikumine |
| `Alt + Shift + Tab` | Aktiivsel tööruumil akende vahel tagurpidi tsükliline liikumine |
| `Ctrl + Alt + Tab`| Fookuse tsükliline liigutamine monitoride vahel edasi |
| `Ctrl + Alt + Shift + Tab`| Fookuse tsükliline liigutamine monitoride vahel tagurpidi |
| `Super + I` | Sisendkeele vahetamine (rohkem kui ühe paigutuse või sisendmeetodi korral) |
| `Super + Shift + I` | Sisendkeele tagasi vahetamine |

Puuteplaadil lülitavad kolme ja nelja sõrme pühked tööruume, liigutavad aknaid ning avavad menüü ja Quake'i konsooli; žeste vaata jaotisest [klaviatuur, hiir ja puuteplaat](34-keyboard-mouse-trackpad.md).

Suuruse muutmine kasutab kahte 0-st paremal asuvat klahvi, ükskõik mida sinu klaviatuur neile trükib: `-` ja `=` USA klaviatuuridel, `+` ja `´` Taani ja Rootsi omadel, `+` ja `\` Norra omal, `ß` ja `´` Saksa omal, `'` ja `¡` Hispaania omal ning `-` ja `^` Jaapani (JIS) omal. `Super + K` loetleb need nii, nagu sinu klaviatuur need trükib. JIS-il on `Super + ^` sama mis `Super + Equal`, samas kui `Super + Shift + -` (mis trükib `=`) on `Super + Shift + Minus`. Monitori skaleerimine ja paroolihaldur kasutavad `/`; paigutustel, mis trükivad `/` ainult koos Shiftiga, nagu enamik Euroopa omi teeb, kasutavad nad selle asemel parempoolsest Shiftist vasakul asuvat klahvi (`-` Taani ja Saksa puhul).

## Süsteemi juhtimine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Helipaneel    |
| `Super + Ctrl + B`           | Bluetoothi paneel    |
| `Super + Ctrl + N`           | Wifi/võrgu paneel    |
| `Super + Ctrl + D`           | Ekraanipaneel    |
| `Super + Ctrl + P`           | Toitepaneel    |
| `Super + Ctrl + X`           | Agentide paneel    |
| `Super + Ctrl + Alt + D`           | Kalendripaneel    |
| `Super + Ctrl + Alt + E`           | Maailmakella paneel    |
| `Super + Ctrl + 1-9`           | Ribapaneeli lülitamine asendi järgi    |
| `Super + Ctrl + S` | Jagamismenüü (LocalSendi kaudu) |
| `Super + Ctrl + C` | Jäädvustamise juhtnupud (ekraanipilt/-salvestus/valija) |
| `Super + Ctrl + O` | Menüü lülitamine |
| `Super + Ctrl + H` | Riistvaramenüü |
| `Super + Ctrl + E` | Emoji valija |
| `Super + Ctrl + .` | Meedia transkodeerimine |
| `Super + Shift + Ctrl + A` | Vaikeagendi käivitamine |
| `Power` key | Süsteemimenüü |
| `Super + Shift + Copilot` key | Omarchy menüü |

## Kohandused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekraani maksimaalne heledus |
| `Shift + Brightness Down` | Ekraani minimaalne heledus |
| `Alt + Brightness Up/Down` | Täpsed 1% heleduse muutused |
| `Alt + Volume Up/Down` | Täpsed 1% helitugevuse muutused |
| `Keyboard Brightness Up/Down` | Klaviatuuri taustvalgustus heledamaks/tumedamaks |
| `Keyboard Backlight` | Klaviatuuri taustvalgustuse tasemete vahel tsükliline liikumine |
| `Ctrl + Brightness Up/Down` | Klaviatuuri taustvalgustus heledamaks/tumedamaks klaviatuuridel, millel pole oma klahve |
| `Mic Mute` | Mikrofoni vaigistamine |
| `Shift + Mute` | Heliväljundi vahetamine |
| `Touchpad Toggle` | Puuteplaadi sisse- või väljalülitamine |
| `Display` key | Tööruumi paigutuse tsükliline vahetamine |
| `Alt + Play` | Järgmine lugu |
| `Alt + Shift + Play` | Eelmine lugu |

## Rakenduste käivitamine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmuxi terminal |
| `Super + Ctrl + Return` | Herdr (agentide haldur) |
| `Super + Shift + Return` or `Super + Shift + B`  | Brauser    |
| `Super + Shift + Alt + B`           | Brauser (privaatne/inkognito)    |
| `Super + Shift + F`           | Failihaldur    |
| `Super + Shift + Alt + F`           | Failihaldur terminali cwd-s    |
| `Super + Shift + M`           | Muusika (Spotify)    |
| `Super + Shift + Alt + M`           | Muusika (cliamp)    |
| `Super + Shift + /`           | Paroolihaldur (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kalkulaator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, kui installitud)    |
| `Super + Shift + T`           | Aktiivsus (btop)    |
| `Super + Shift + N`           | Redaktor (Plain või sinu valitud vaikeseade)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-post ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Uus e-kiri ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Sinu vaikeagent või ChatGPT, kuni sa ühe valid |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Sõnumirakendus (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Sõnumirakendus (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Sõnumirakendus (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Kirjutamine (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (uus postitus) |
| `Super + Shift + Y`           | YouTube |

Muuda/lisa seoseid failis `~/.config/hypr/bindings.lua`.

## Universaalne lõikelaud

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + A`           | Kõige valimine rakendustes, mis toetavad `Ctrl + A`    |
| `Super + C`           | Kopeerimine    |
| `Super + X`           | Lõikamine (mitte terminalis)    |
| `Super + V`           | Kleepimine    |
| `Super + Ctrl + V`           | Lõikelaua haldur    |

Tavaliselt Linuxis on sul terminalis kopeerimiseks ja kleepimiseks vaja `Ctrl + Shift + C/V` ja kõikjal mujal `Ctrl + C/V`. Need Omarchy ühtsed lõikelaua kiirklahvid töötavad kõikjal.

## Jäädvustamine

| Kiirklahv              | Funktsioon                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekraanipilt                      |
| `Super + Ctrl + Alt + C`            | Ekraanipilt (sama võte klaviatuuridele, millel pole Print Screen klahvi) |
| `Super + Ctrl + C` | Jäädvustamise menüü |
| `Alt + Print Screen`            | Ekraanisalvestus                     |
| `Super + Shift + Ctrl + Alt + C` | Ekraanisalvestus ilma helita, menüü vahele jättes (peatamiseks vajuta uuesti) |
| `Super + Print Screen` | Värvivalija |
| `Super + Ctrl + Print Screen` | Teksti eraldamine lõikelauale |
| `Super + Alt + [` | Veebikaamera ülekatte väiksemaks tegemine salvestamise ajal |
| `Super + Alt + ]` | Veebikaamera ülekatte suuremaks tegemine salvestamise ajal |
| `Alt + Shift + L` | Praeguse URL-i kopeerimine veebirakendusest või brauserist |
| `Alt + Shift + D` | Praegusel lehel oleva video allalaadimine kausta `~/Videos` |
| `Alt + Space` | Dikteerimise alustamine/peatamine (nõuab _Setup > Defaults > Dictation_) |
| `Right Alt` | Dikteerimiseks all hoidmine (nõuab _Setup > Defaults > Dictation_) |

Ekraanisalvestuste puhul küsib kiirklahv esmalt, millist heli sa tahad, seejärel alustab salvestamist. Peatamiseks vajuta seda uuesti. Üksikasju vaata jaotisest [ekraanipildid ja salvestamine](12-screenshots-recording.md).

Kõik jäädvustamisvalikud on saadaval ka Omarchy menüü (`Super + Space`) jaotises _Trigger > Capture_.

## Teavitused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + ,` | Viimase teavituse suhtes tegutsemine: selle avamine või selle ainsa nupu vajutamine, selle valikute hulgast valimine või selle sulgemine, kui valikuid pole  |
| `Super + Shift + ,` | Kõigi teavituste sulgemine |
| `Super + Ctrl + ,` | Teavituste juhtimine klaviatuuriga  |
| `Super + Alt + ,` | Viimase teavituse sulgemine  |
| `Super + Shift + Alt + ,` | Teavituste ajaloo avamine  |
| `Super + Ctrl + Alt + ,` | Teavituste vaigistamise lülitamine  |

## Stiil

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Uue teema valimine (ka `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Teema tausta valimine (ka `Super + Ctrl + Space`) |
| `Super + Backspace` | Akna läbipaistvuse lülitamine |
| `Super + Ctrl + Backspace` | Ühe akna ruudukujulise kuvasuhte lülitamine |

Lisa taustapildid asuvad kaustas `~/.config/omarchy/backgrounds/<theme name>`. Saadaval ka Omarchy menüü jaotise _Install > Style > Background_ kaudu.

Kõik stiilivalikud on saadaval ka Omarchy menüü (`Super + Space`) jaotises _Appearance_.

## Lülitid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Jõudeolekul lukustamise lülitamine |
| `Super + Ctrl + Delete` | Sülearvuti ekraani sisse-/väljalülitamine |
| `Super + Ctrl + Alt + Delete` | Sülearvuti ekraani peegeldamise lülitamine |
| `Super + Shift + Space` | Ülemise riba lülitamine  |
| `Shift + Mute` | Järgmisele heliväljundile lülitumine |
| `Shift + Play` | Järgmisele meediaallikale lülitumine |
| `Super + Shift + Backspace` | Aknavahede lülitamine |
| `Super + Ctrl + Alt + F` | Täisekraani töölaua lülitamine (ülemine riba + aknavahed) |

## Meeldetuletused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Meeldetuletuse seadmine  |
| `Super + Ctrl + Alt + R` | Kõigi meeldetuletuste vaatamine  |
| `Super + Ctrl + Shift + R` | Kõigi meeldetuletuste tühjendamine  |

## Märguanded

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Aja kuvamine märguandena  |
| `Super + Ctrl + Alt + B` | Aku kuvamine märguandena  |
| `Super + Ctrl + Alt + W` | Ilma kuvamise lülitamine märguandena  |

## Tmux

Prefiksiklahv on `Ctrl + Space` (`Ctrl + B` töötab samuti). Neid seoseid saad muuta failis `~/.config/tmux/tmux.conf`.

### Paanid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + v` | Paani jagamine kõrvale (vertikaalne) |
| `Prefix + h` | Paani jagamine alla (horisontaalne) |
| `Prefix + x` | Paani hävitamine |
| `Prefix + z` | Paani suumi lülitamine (täisekraan) |
| `Alt + Enter` | Paani jagamine alla (ilma prefiksita) |
| `Alt + Shift + Enter` | Paani jagamine kõrvale (ilma prefiksita) |
| `Alt + Escape` | Paani hävitamine (ilma prefiksita) |
| `Ctrl + Alt + Arrows` | Paanide vahel liikumine |
| `Ctrl + Alt + Shift + Arrows` | Paanide suuruse muutmine |

### Aknad

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + c` | Uus aken |
| `Prefix + k` | Akna hävitamine |
| `Prefix + r` | Akna ümbernimetamine |
| `Alt + 1-9` | Kindlale aknale minek |
| `Alt + Arrow Left/Right` | Akende vahel liikumine |
| `Alt + Shift + Arrow Left/Right` | Akna liigutamine vasakule/paremale |

### Seansid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + C` | Uus seanss |
| `Prefix + K` | Seansi hävitamine |
| `Prefix + R` | Seansi ümbernimetamine |
| `Prefix + N` | Järgmine seanss |
| `Prefix + P` | Eelmine seanss |
| `Alt + Arrow Up/Down` | Seansside vahel liikumine |
| `Prefix + s` | Seansside loetlemine |
| `Prefix + d` | Seansist lahti ühendamine |

### Kopeerimisrežiim (vi-stiilis)

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + [` | Kopeerimisrežiimi sisenemine |
| `v` | Valiku alustamine (kopeerimisrežiimis) |
| `y` | Valiku kopeerimine (kopeerimisrežiimis) |

### Üldine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguratsiooni uuesti laadimine |
| `Prefix + ?` | Tmuxi klahviseoste kuvamine |
| `Prefix + :` | Käsuviip |

### Tmuxi paigutusfunktsioonid

Neid funktsioone tuleb käitada Tmuxi seansi sees.

| Käsk | Funktsioon |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Arenduspaigutuse loomine redaktori, AI ja terminaliga |
| `tdlm <ai> [<second_ai>]` | Arenduspaigutuse loomine iga alamkataloogi jaoks |
| `tsl <count> <command>` | Mitme paaniga parvepaigutuse loomine |

## Ghostty Terminal

Ghostty terminal installitakse Omarchy menüü jaotise _Install > Terminal_ abil.

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Uus jaotus all |
| `Ctrl + Shift + O` | Uus jaotus kõrval |
| `Ctrl + Alt + Arrows` | Jaotuste vahel liikumine |
| `Super + Ctrl + Shift + Arrows` | Jaotuse suuruse muutmine 10 rea võrra |
| `Super + Ctrl + Shift + Alt + Arrows` | Jaotuse suuruse muutmine 100 rea võrra |
| `Ctrl + Shift + T` | Uus vahekaart  |
| `Ctrl + Shift + Arrows` | Vahekaartide vahel liikumine |
| `Alt + Numbers` | Kindlale vahekaardile minek |
| `Shift + Pg Up/Down` | Ajaloo kerimine |
| `Ctrl + Left mouse` | Lingi avamine brauseris |

## Failihaldur

| Kiirklahv              | Funktsioon                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Teele liikumine                     |
| `Space`               | Faili eelvaade (nooled navigeerivad) |
| `Alt + Up`       | Ülemkausta minek        |

## Neovim (w/ lazyvim)

### Navigeerimine

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Käsuvalikute kuvamine            |
| `Space Space`              | Faili avamine hägusa otsinguga      |
| `Space E`                  | Külgriba lülitamine                  |
| `Space G G`                | Giti juhtnuppude kuvamine               |
| `Space S G`                | Faili sisu otsimine             |
| `Ctrl + W W`               | Külgriba ja redaktori vahel hüppamine |
| `Ctrl + Left/right arrow`  | Külgriba suuruse muutmine          |
| `Shift + H`                      | Vasakpoolsele failivahekaardile minek             |
| `Shift + L`                      | Parempoolsele failivahekaardile minek            |
| `Space B D`                | Failivahekaardi sulgemine                  |

### Külgribas olles

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `A`                        | Uue faili lisamine ülemkataloogi      |
| `Shift + A`                | Uue alamkataloogi lisamine ülemkataloogi    |
| `D`                        | Esiletõstetud faili/kataloogi kustutamine     |
| `M`                        | Esiletõstetud faili/kataloogi liigutamine       |
| `R`                        | Esiletõstetud faili/kataloogi ümbernimetamine     |
| `?`                        | Kõigi käskude abi kuvamine      |

[Vaata kõiki LazyVimi konfigureeritud Neovimi kiirklahve](https://www.lazyvim.org/keymaps).

## Kiired emojid

Saad kasutada `Super + Ctrl + E`, et kuvada täielik emoji valija, mis asetab valiku lõikelauale, või saad kasutada neid kiirpääsuvalikuid.

| Kiirklahv       | EM | Vihje       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | naeratus      |
| `Shift + CapsLock M C` | 😂 | nutt        |
| `Shift + CapsLock M L` | 😍 | armastus       |
| `Shift + CapsLock M V` | ✌️ | võit    |
| `Shift + CapsLock M H` | ❤️ | süda      |
| `Shift + CapsLock M Y` | 👍 | jah        |
| `Shift + CapsLock M N` | 👎 | ei         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | soov       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | suudlus       |
| `Shift + CapsLock M E` | 🙄 | silmade pööritamine    |
| `Shift + CapsLock M I` | 😉 | silmapilgutus       |
| `Shift + CapsLock M P` | 🙏 | palve |
| `Shift + CapsLock M D` | 🤤 | ila      |
| `Shift + CapsLock M M` | 💰 | raha      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | tost      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | tervitus |
| `Shift + CapsLock M A` |💪 | käsivars |
| `Shift + CapsLock M B` |🤯 | puhumine |

## Kiirtäitmised

| Kiirklahv       | Täitmine       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (pikk kriips)   |
| `Shift + CapsLock Space N` | Sinu nimi (nagu seadistamisel sisestatud)  |
| `Shift + CapsLock Space E` | Sinu e-post (nagu seadistamisel sisestatud)  |

Saad ise rohkem lisada, muutes faili `~/.XCompose`, seejärel käivitades terminalis `omarchy restart xcompose`, et muudatused rakenduksid.
