# Kiirklahvid

Kõiki peamisi klaviatuuriseoseid näed klahvikombinatsiooniga `Super + K` (Tmuxi seoseid `Super + Alt + K` ja Herdr'i seoseid `Super + Ctrl + K`).

## Kuidas kiirklahvid on paigutatud

Iga kiirklahv asub ühel tasandil, mille määravad selle muuteklahvid, ja igal tasandil on üks ülesanne. Just see hoiab kiirklahvid omavahel segamini minemast ja tähendab, et tavaliselt oskad ära arvata, kus miski asub.

| Tasand | Mis sinna kuulub | Näited |
| --- | --- | --- |
| `Super + key` | Süsteem: aknad, tööruumid, paigutused ja põhimenüüd | `Super + Space` Omarchy menüü, `Super + W` sulge aken, `Super + F` täisekraan |
| `Super + Shift + key` | Rakendused | `Super + Shift + B` brauser, `Super + Shift + E` e-post, `Super + Shift + N` redaktor |
| `Super + Ctrl + key` | Paneelid ja süsteemimenüüd | `Super + Ctrl + A` heli, `Super + Ctrl + N` võrk, `Super + Ctrl + C` jäädvustamismenüü |
| `Super + Ctrl + Alt + key` | Kiirtoimingud ja teated | `Super + Ctrl + Alt + T` näita kellaaega, `Super + Ctrl + Alt + B` aku, `Super + Ctrl + Alt + C` ekraanipilt |

Kiirklahvile `Alt` lisamine annab sulle sama asja variandi, mitte kunagi midagi seosetut:

- `Super + Shift + B` avab brauseri; `Super + Shift + Alt + B` avab privaatakna
- `Super + Shift + E` avab e-posti; `Super + Shift + Alt + E` alustab uut e-kirja
- `Super + F` läheb täisekraanile; `Super + Alt + F` läheb täislaiusele
- `Super + Ctrl + C` avab jäädvustamismenüü; `Super + Ctrl + Alt + C` jätab menüü vahele ja teeb ekraanipildi

Kiirklahvi lisamisel:

1. Vali tasand selle järgi, mida see teeb, seejärel vali klahv.
2. Ära nihuta olemasolevat kiirklahvi, et ruumi teha. Leia õigel tasandil vaba klahv.
3. Kasuta `Alt` klahvi ainult ilma selleta kiirklahvi variandi jaoks.

Mõned kiirklahvid rikuvad neid reegleid, sest nii on mugav. `Shift` koos nooleklahvi või `Tab` klahviga liigutab või pöörab suunda, selle asemel et rakendust avada, ning `Print`, meediaklahvid, `Alt + Tab` ja `Ctrl + Alt + Del` toimivad nii, nagu nad toimivad kõikjal mujal. Need on erandid, mitte mustrid, mida kopeerida.

Kui vaikeseade sulle ei sobi (ütleme, et tahad ekraanipiltide jaoks `Super + Shift + S` nagu Windowsis), seo see ümber failis `~/.config/hypr/bindings.lua`.

## Navigeerimine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menüü (rakendused ja kõik muu)    |
| `Super + Alt + Space` | Rakenduste ruudustik |
| `Super + Escape` | Süsteemimenüü (peatamine, taaskäivitamine jne)  |
| `Super + Ctrl + L` | Lukusta arvuti |
| `Super + W` või `Super + Q` | Sulge aken             |
| `Ctrl + Alt + Del` | Sulge kõik aknad |
| `Super + K` | Näita kõiki kiirklahve |
| `Super + Alt + K` | Näita tmuxi kiirklahve |
| `Super + Ctrl + K` | Näita herdri kiirklahve |
| `Super + M` | Minimeeri aken dokki |
| `Super + T`               | Lülita aken plaaditud/ujuva režiimi vahel             |
| `Super + J` | Lülita akna asendit (horisontaalne/vertikaalne) |
| `Super + O`               | Lülita aken kleepuvaks hõljuvaks hüpikaknaks |
| `Super + L`               | Liigu ringiga läbi dwindle-, kerimis- ja ujuvate paigutuste |
| `Super + Alt + L`         | Liigu ringiga läbi paigutuste vastupidises suunas |
| `Super + P`               | Lülita pseudoakna stiili (loomulik vs venitatud) |
| `Super + F`                 | Mine täisekraanile              |
| `Super + Alt + F`                 | Mine täislaiusele              |
| `Super + Ctrl + F`                 | Mine akna sees täisekraanile              |
| `Super + 1…9/0`         | Hüppa fokuseeritud monitoril kindlasse tööruumi (0 on 10) |
| `Super + Tab` | Hüppa fokuseeritud monitoril järgmisse tööruumi |
| `Super + Shift + Tab` | Hüppa fokuseeritud monitoril eelmisse tööruumi |
| `Super + Ctrl + Tab` | Hüppa fokuseeritud monitoril varasemasse tööruumi |
| `Super + Shift + 1…9/0` | Teisalda aken fokuseeritud monitoril tööruumi |
| `Super + Shift + Alt + 1…9/0` | Teisalda aken fokuseeritud monitoril tööruumi ilma järgnemata |
| `Super + S` | Lülita täielik scratchpad sisse/välja |
| `Super + Alt + S` | Teisalda aken täielikku scratchpad'i |
| `Super + the key above Tab` (USA paigutustel grave-klahv) | Lülita Quake'i konsool sisse/välja |
| `Super + Shift + the key above Tab` (USA paigutustel grave-klahv) | Teisalda aken Quake'i konsooli |
| `Super + Shift + Ctrl + Arrows` | Teisalda aken selles suunas olevale monitorile |
| `Super + Shift + Alt + Arrows` | Teisalda tööruum selles suunas olevale monitorile |
| `Super + Arrow`  | Teisalda fookus noole suunas olevale aknale, liikudes ekraani serval sellel küljel olevale monitorile |
| `Super + Shift + Arrow`  | Vaheta aken noole suunas oleva teise aknaga, kaasa arvatud sellel küljel oleval monitoril olevaga |
| `Super + Minus` | Laienda akent vasakule |
| `Super + Equal` | Kahanda akent vasakule |
| `Super + Shift + Minus` | Kahanda akent üles |
| `Super + Shift + Equal` | Laienda akent alla |
| `Super + Alt + Minus/Equal` | Sama suuruse muutmine väiksemate sammudega |
| `Super + Ctrl + Minus/Equal` | Sama suuruse muutmine suuremate sammudega |
| `Super + Alt + Home` | Salvesta akna laius |
| `Super + Home` | Taasta salvestatud akna laius |
| `Super + Left Mouse` | Lohista akent ringi |
| `Super + Right Mouse` | Muuda akna suurust |
| `Super + Scroll Wheel` | Keri läbi fokuseeritud monitori tööruumide |
| `Super + G`               | Lülita akende rühmitamine sisse/välja      |
| `Super + Alt + G`               | Teisalda aken rühmitusest välja      |
| `Super + Alt + Tab`               | Liigu ringiga rühmituse akende vahel      |
| `Super + Alt + Shift + Tab`               | Liigu ringiga tagurpidi rühmituse akende vahel      |
| `Super + Alt + Scroll Wheel` | Liigu ringiga rühmituse akende vahel |
| `Super + Alt + 1/2/3/4/5`               | Hüppa rühmituses kindlasse aknasse      |
| `Super + Alt + Arrow`  | Teisalda aken noole suunas rühmitusse, kaasa arvatud sellel küljel oleval monitoril olev |
| `Super + Ctrl + Left/Right`  | Liigu plaaditud rühma sees akende vahel |
| `Super + Ctrl + Z` | Suumi ekraanil sisse (korda suurema suumi jaoks) |
| `Super + Ctrl + Alt + Z` | Suumi ekraanilt täielikult välja |
| `Super + /` | Liigu samm-sammult edasi läbi monitori skaleerimisvalikute |
| `Super + Alt + /` | Liigu samm-sammult tagasi läbi monitori skaleerimisvalikute |
| `Alt + Tab` | Liigu ringiga edasi läbi aktiivse tööruumi akende |
| `Alt + Shift + Tab` | Liigu ringiga tagurpidi läbi aktiivse tööruumi akende |
| `Ctrl + Alt + Tab`| Liigu fookusega ringiga edasi läbi monitoride |
| `Ctrl + Alt + Shift + Tab`| Liigu fookusega ringiga tagurpidi läbi monitoride |
| `Super + I` | Vaheta sisestuskeelt (kui on rohkem kui üks paigutus või sisestusmeetod) |
| `Super + Shift + I` | Vaheta sisestuskeel tagasi |

Puuteplaadil vahetavad kolme ja nelja sõrme pühked tööruume, teisaldavad aknaid ning avavad menüü ja Quake'i konsooli; žeste vaata jaotisest [klaviatuur, hiir ja puuteplaat](34-keyboard-mouse-trackpad.md).

Suuruse muutmise kiirklahvid kasutavad füüsilisi klahve `code:20` ja `code:21` (XKB `<AE11>` ja `<AE12>`), olenemata klaviatuurile trükitud märkidest. USA klaviatuuridel on need klahvid `-` ja `=`; Jaapani (JIS) klaviatuuridel `-` ja `^`; Hispaania klaviatuuridel `'` ja `¡`. JIS-il on `Super + ^` sama mis `Super + Equal`, samas kui `Super + Shift + -` (mis sisestab `=`) on `Super + Shift + Minus`.

## Süsteemi juhtimine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Heli paneel    |
| `Super + Ctrl + B`           | Bluetoothi paneel    |
| `Super + Ctrl + N`           | Wi-Fi/võrgu paneel    |
| `Super + Ctrl + D`           | Ekraani paneel    |
| `Super + Ctrl + P`           | Toite paneel    |
| `Super + Ctrl + X`           | Agentide paneel    |
| `Super + Ctrl + Alt + X`           | Kohalike mudelite paneel    |
| `Super + Ctrl + Alt + D`           | Kalendri paneel    |
| `Super + Ctrl + Alt + E`           | Maailmakella paneel    |
| `Super + Ctrl + 1-9`           | Lülita ribapaneeli asendi järgi sisse/välja    |
| `Super + Ctrl + S` | Jagamismenüü (LocalSendi kaudu) |
| `Super + Ctrl + C` | Jäädvustamise juhtnupud (ekraanipilt/-salvestus/-valija) |
| `Super + Ctrl + O` | Lülita menüü sisse/välja |
| `Super + Ctrl + H` | Riistvaramenüü |
| `Super + Ctrl + E` | Emoji-valija |
| `Super + Ctrl + .` | Transkoodi meediat |
| `Super + Shift + Ctrl + A` | Käivita oma vaikeagent |
| `Power` klahv | Süsteemimenüü |
| `Super + Shift + Copilot` klahv | Omarchy menüü |

## Reguleerimine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekraani maksimaalne heledus |
| `Shift + Brightness Down` | Ekraani minimaalne heledus |
| `Alt + Brightness Up/Down` | Täpsed 1% heleduse muutused |
| `Alt + Volume Up/Down` | Täpsed 1% helitugevuse muutused |
| `Keyboard Brightness Up/Down` | Klaviatuuri taustvalgus heledamaks/tumedamaks |
| `Keyboard Backlight` | Liigu ringiga klaviatuuri taustvalguse tasemete vahel |
| `Ctrl + Brightness Up/Down` | Klaviatuuri taustvalgus heledamaks/tumedamaks klaviatuuridel, millel pole oma klahve |
| `Mic Mute` | Vaigista mikrofon |
| `Shift + Mute` | Vaheta heliväljundit |
| `Touchpad Toggle` | Lülita puuteplaat sisse või välja |
| `Display` klahv | Liigu ringiga tööruumi paigutuste vahel |
| `Alt + Play` | Järgmine lugu |
| `Alt + Shift + Play` | Eelmine lugu |

## Rakenduste käivitamine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmuxi terminal |
| `Super + Ctrl + Return` | Herdr (agentide haldur) |
| `Super + Shift + Return` või `Super + Shift + B`  | Brauser    |
| `Super + Shift + Alt + B`           | Brauser (privaatne/inkognito)    |
| `Super + Shift + F`           | Failihaldur    |
| `Super + Shift + Alt + F`           | Failihaldur terminali cwd-s    |
| `Super + Shift + M`           | Muusika (Spotify)    |
| `Super + Shift + Alt + M`           | Muusika (cliamp)    |
| `Super + Shift + /`           | Paroolihaldur (1password)    |
| `Super + Shift + Q` või `Calculator` klahv  | Kalkulaator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, kui see on installitud)    |
| `Super + Shift + T`           | Aktiivsus (btop)    |
| `Super + Shift + N`           | Redaktor (Plain või sinu valitud vaikeredaktor)  |
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
| `Super + A`           | Vali kõik rakendustes, mis toetavad `Ctrl + A`    |
| `Super + C`           | Kopeeri    |
| `Super + X`           | Lõika (mitte terminalis)    |
| `Super + V`           | Kleebi    |
| `Super + Ctrl + V`           | Lõikelaua haldur    |

Tavaliselt on Linuxis terminalis kopeerimiseks ja kleepimiseks vaja `Ctrl + Shift + C/V` ja kõikjal mujal `Ctrl + C/V`. Need Omarchy ühtsed lõikelaua kiirklahvid toimivad kõikjal.

## Jäädvustamine

| Kiirklahv              | Funktsioon                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekraanipilt                      |
| `Super + Ctrl + Alt + C`            | Ekraanipilt (sama võte klaviatuuridele, millel pole Print Screen klahvi) |
| `Super + Ctrl + C` | Jäädvustamismenüü |
| `Alt + Print Screen`            | Ekraanisalvestus                     |
| `Super + Shift + Ctrl + Alt + C` | Ekraanisalvestus ilma helita, menüüd vahele jättes (peata uuesti vajutades) |
| `Super + Print Screen` | Värvivalija |
| `Super + Ctrl + Print Screen` | Teksti eraldamine lõikelauale |
| `Super + Alt + [` | Tee veebikaamera ülekate salvestamise ajal väiksemaks |
| `Super + Alt + ]` | Tee veebikaamera ülekate salvestamise ajal suuremaks |
| `Alt + Shift + L` | Kopeeri praegune URL veebirakendusest või brauserist |
| `Alt + Shift + D` | Laadi praegusel lehel olev video alla kausta `~/Videos` |
| `Alt + Space` | Alusta/peata dikteerimine (nõuab _Setup > Defaults > Dictation_) |
| `Right Alt` | Hoia dikteerimiseks all (nõuab _Setup > Defaults > Dictation_) |

Ekraanisalvestuste puhul küsib kiirklahv esmalt, millist heli sa soovid, seejärel alustab salvestamist. Peatamiseks vajuta seda uuesti. Üksikasju vaata jaotisest [ekraanipildid ja salvestamine](12-screenshots-recording.md).

Kõik jäädvustamisvalikud on saadaval ka Omarchy menüü (`Super + Space`) jaotises _Trigger > Capture_.

## Teavitused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + ,` | Toimi viimase teavitusega: ava see või vajuta selle ainsat nuppu, vali selle valikute hulgast või eemalda see, kui valikuid pole  |
| `Super + Shift + ,` | Eemalda kõik teavitused |
| `Super + Ctrl + ,` | Juhti teavitusi klaviatuuriga  |
| `Super + Alt + ,` | Eemalda viimane teavitus  |
| `Super + Shift + Alt + ,` | Ava teavituste ajalugu  |
| `Super + Ctrl + Alt + ,` | Lülita teavituste vaigistamine sisse/välja  |

## Stiil

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vali uus teema (ka `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vali teema taust (ka `Super + Ctrl + Space`) |
| `Super + Backspace` | Lülita akna läbipaistvus sisse/välja |
| `Super + Ctrl + Backspace` | Lülita ühe akna ruudukujuline kuvasuhe sisse/välja |

Täiendavad taustapildid asuvad kaustas `~/.config/omarchy/backgrounds/<theme name>`. Saadaval ka Omarchy menüü jaotises _Install > Style > Background_.

Kõik stiilivalikud on saadaval ka Omarchy menüü (`Super + Space`) jaotises _Appearance_.

## Lülitid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Lülita jõudeolekul lukustamine sisse/välja |
| `Super + Ctrl + Delete` | Lülita sülearvuti ekraan sisse/välja |
| `Super + Ctrl + Alt + Delete` | Lülita sülearvuti ekraani peegeldamine sisse/välja |
| `Super + Shift + Space` | Lülita ülemine riba sisse/välja  |
| `Shift + Mute` | Vaheta järgmisele heliväljundile |
| `Shift + Play` | Vaheta järgmisele meediaallikale |
| `Super + Shift + Backspace` | Lülita aknavahed sisse/välja |
| `Super + Ctrl + Alt + F` | Lülita täisekraani töölaud sisse/välja (ülemine riba + aknavahed) |

## Meeldetuletused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Määra meeldetuletus  |
| `Super + Ctrl + Alt + R` | Vaata kõiki meeldetuletusi  |
| `Super + Ctrl + Shift + R` | Kustuta kõik meeldetuletused  |

## Teated

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Näita kellaaega teavitusena  |
| `Super + Ctrl + Alt + B` | Näita akut teavitusena  |
| `Super + Ctrl + Alt + W` | Lülita ilmateade teavitusena sisse/välja  |

## Tmux

Prefiksiklahv on `Ctrl + Space` (toimib ka `Ctrl + B`). Neid seoseid saad muuta failis `~/.config/tmux/tmux.conf`.

### Paanid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + v` | Jaga paan kõrvuti (vertikaalne) |
| `Prefix + h` | Jaga paan alla (horisontaalne) |
| `Prefix + x` | Sulge paan |
| `Prefix + z` | Lülita paani suum sisse/välja (täisekraan) |
| `Alt + Enter` | Jaga paan alla (ilma prefiksita) |
| `Alt + Shift + Enter` | Jaga paan kõrvuti (ilma prefiksita) |
| `Alt + Escape` | Sulge paan (ilma prefiksita) |
| `Ctrl + Alt + Arrows` | Liigu paanide vahel |
| `Ctrl + Alt + Shift + Arrows` | Muuda paanide suurust |

### Aknad

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + c` | Uus aken |
| `Prefix + k` | Sulge aken |
| `Prefix + r` | Nimeta aken ümber |
| `Alt + 1-9` | Mine kindlasse aknasse |
| `Alt + Arrow Left/Right` | Liigu akende vahel |
| `Alt + Shift + Arrow Left/Right` | Teisalda aken vasakule/paremale |

### Seansid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + C` | Uus seanss |
| `Prefix + K` | Sulge seanss |
| `Prefix + R` | Nimeta seanss ümber |
| `Prefix + N` | Järgmine seanss |
| `Prefix + P` | Eelmine seanss |
| `Alt + Arrow Up/Down` | Liigu seansside vahel |
| `Prefix + s` | Loetle seansid |
| `Prefix + d` | Ühenda seansist lahti |

### Kopeerimisrežiim (vi-stiilis)

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + [` | Sisene kopeerimisrežiimi |
| `v` | Alusta valikut (kopeerimisrežiimis) |
| `y` | Kopeeri valik (kopeerimisrežiimis) |

### Üldine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + q` | Laadi konfiguratsioon uuesti |
| `Prefix + ?` | Näita Tmuxi klahviseoseid |
| `Prefix + :` | Käsuviip |

### Tmuxi paigutusfunktsioonid

Neid funktsioone tuleb käivitada Tmuxi seansi sees.

| Käsk | Funktsioon |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Loo arenduspaigutus redaktori, AI ja terminaliga |
| `tdlm <ai> [<second_ai>]` | Loo arenduspaigutus iga alamkataloogi kohta |
| `tsl <count> <command>` | Loo mitmepaaniline sülempaigutus |

## Ghostty terminal

Ghostty terminal installitakse Omarchy menüü jaotise _Install > Terminal_ kaudu.

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Uus jaotus all |
| `Ctrl + Shift + O` | Uus jaotus kõrval |
| `Ctrl + Alt + Arrows` | Liigu jaotuste vahel |
| `Super + Ctrl + Shift + Arrows` | Muuda jaotuse suurust 10 rea võrra |
| `Super + Ctrl + Shift + Alt + Arrows` | Muuda jaotuse suurust 100 rea võrra |
| `Ctrl + Shift + T` | Uus vahekaart  |
| `Ctrl + Shift + Arrows` | Liigu vahekaartide vahel |
| `Alt + Numbers` | Mine kindlale vahekaardile |
| `Shift + Pg Up/Down` | Keri ajalugu |
| `Ctrl + Left mouse` | Ava link brauseris |

## Failihaldur

| Kiirklahv              | Funktsioon                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Mine aadressile                     |
| `Space`               | Vaata faili eelvaadet (nooled liiguvad) |
| `Alt + Up`       | Mine üles ülemkausta        |

## Neovim (w/ lazyvim)

### Navigeerimine

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Näita käsuvalikuid            |
| `Space Space`              | Ava fail häguotsinguga      |
| `Space E`                  | Lülita külgriba sisse/välja                  |
| `Space G G`                | Näita giti juhtnuppe               |
| `Space S G`                | Otsi faili sisust             |
| `Ctrl + W W`               | Hüppa külgriba ja redaktori vahel |
| `Ctrl + Left/right arrow`  | Muuda külgriba suurust          |
| `Shift + H`                      | Mine vasakule failivahekaardile             |
| `Shift + L`                      | Mine paremale failivahekaardile            |
| `Space B D`                | Sulge failivahekaart                  |

### Külgribal olles

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `A`                        | Lisa ülemkataloogi uus fail      |
| `Shift + A`                | Lisa ülemkataloogi uus alamkataloog    |
| `D`                        | Kustuta esiletõstetud fail/kataloog     |
| `M`                        | Teisalda esiletõstetud fail/kataloog       |
| `R`                        | Nimeta esiletõstetud fail/kataloog ümber     |
| `?`                        | Näita kõigi käskude abi      |

[Vaata kõiki LazyVimi konfigureeritud Neovimi kiirklahve](https://www.lazyvim.org/keymaps).

## Kiiremojid

Täieliku emoji-valija kuvamiseks, mis asetab valiku lõikelauale, saad kasutada klahvikombinatsiooni `Super + Ctrl + E`, või saad kasutada neid kiirpääsuvalikuid.

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
| `Shift + CapsLock M R` | 🤘 | rokk       |
| `Shift + CapsLock M K` | 😘 | suudlus       |
| `Shift + CapsLock M E` | 🙄 | silmade pööritamine    |
| `Shift + CapsLock M I` | 😉 | silmapilgutamine       |
| `Shift + CapsLock M P` | 🙏 | palve |
| `Shift + CapsLock M D` | 🤤 | ilastamine      |
| `Shift + CapsLock M M` | 💰 | raha      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toost      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | tervitus |
| `Shift + CapsLock M A` |💪 | käsi |
| `Shift + CapsLock M B` |🤯 | plahvatus |

## Kiirtäiendused

| Kiirklahv       | Täiendus       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Sinu nimi (nagu seadistamisel sisestatud)  |
| `Shift + CapsLock Space E` | Sinu e-post (nagu seadistamisel sisestatud)  |

Saad enda omi lisada, muutes faili `~/.XCompose` ja käivitades seejärel terminalis käsu `omarchy restart xcompose`, et muudatused rakenduksid.
