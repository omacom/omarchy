# Kiirklahvid

Kõiki peamisi klaviatuuri seoseid näed klahvidega `Super + K` (Tmuxi seoseid klahvidega `Super + Alt + K` ja Herdri seoseid klahvidega `Super + Ctrl + K`).

## Kuidas kiirklahvid on paigutatud

Iga kiirklahv asub ühel tasandil, mille määravad selle modifikaatorid, ja igal tasandil on üks ülesanne. Just see hoiab kiirklahvid omavahel segamini minemast ja tähendab, et tavaliselt oskad arvata, kus miski asub.

| Plane | What lives there | Examples |
| --- | --- | --- |
| `Super + key` | Süsteem: aknad, tööalad, paigutused ja põhimenuüd | `Super + Space` Omarchy menüü, `Super + W` sulge aken, `Super + F` täisekraan |
| `Super + Shift + key` | Rakendused | `Super + Shift + B` brauser, `Super + Shift + E` e-post, `Super + Shift + N` redaktor |
| `Super + Ctrl + key` | Paneelid ja süsteemimenüüd | `Super + Ctrl + A` heli, `Super + Ctrl + N` võrk, `Super + Ctrl + C` jäädvustamismenüü |
| `Super + Ctrl + Alt + key` | Kiirtoimingud ja märguanded | `Super + Ctrl + Alt + T` näita kellaaega, `Super + Ctrl + Alt + B` aku, `Super + Ctrl + Alt + C` ekraanipilt |

Table headers note translated in content above – actual table retained below
| Tasand | Mis sinna kuulub | Näited |
| --- | --- | --- |
| `Super + key` | Süsteem: aknad, tööalad, paigutused ja põhimenuüd | `Super + Space` Omarchy menüü, `Super + W` sulge aken, `Super + F` täisekraan |
| `Super + Shift + key` | Rakendused | `Super + Shift + B` brauser, `Super + Shift + E` e-post, `Super + Shift + N` redaktor |
| `Super + Ctrl + key` | Paneelid ja süsteemimenüüd | `Super + Ctrl + A` heli, `Super + Ctrl + N` võrk, `Super + Ctrl + C` jäädvustamismenüü |
| `Super + Ctrl + Alt + key` | Kiirtoimingud ja märguanded | `Super + Ctrl + Alt + T` näita kellaaega, `Super + Ctrl + Alt + B` aku, `Super + Ctrl + Alt + C` ekraanipilt |

`Alt` lisamine kiirklahvile annab sulle sama asja variandi, mitte kunagi midagi täiesti seotut:

- `Super + Shift + B` avab brauseri; `Super + Shift + Alt + B` avab privaatse akna
- `Super + Shift + E` avab e-posti; `Super + Shift + Alt + E` alustab uut kirja
- `Super + F` läheb täisekraanile; `Super + Alt + F` läheb täislaiusesse
- `Super + Ctrl + C` avab jäädvustamismenüü; `Super + Ctrl + Alt + C` jätab menüü vahele ja teeb ekraanipildi

Kiirklahvi lisamisel:

1. Vali tasand selle järgi, mida see teeb, seejärel vali klahv.
2. Ära nihuta olemasolevat kiirklahvi, et ruumi teha. Leia õigel tasandil vaba klahv.
3. Kasuta `Alt` ainult ilma selleta kiirklahvi variandi jaoks.

Mõned kiirklahvid rikuvad neid reegleid, sest nii on mugav. `Shift` koos nooleklahvi või `Tab`-iga liigutab või pöörab suunda, selle asemel et rakendust avada, ning `Print`, meediaklahvid, `Alt + Tab` ja `Ctrl + Alt + Del` töötavad samamoodi nagu igal pool mujal. Need on erandid, mitte mustrid, mida kopeerida.

Kui vaikeseade sulle ei sobi (näiteks tahad ekraanipiltide jaoks `Super + Shift + S`, nagu Windowsis), seo see ümber failis `~/.config/hypr/bindings.lua`.

## Navigeerimine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menüü (rakendused ja kõik muu)    |
| `Super + Alt + Space` | Rakenduste ruudustik |
| `Super + Escape` | Süsteemimenüü (peatamine, taaskäivitamine jne)  |
| `Super + Ctrl + L` | Lukusta arvuti |
| `Super + W` or `Super + Q` | Sulge aken             |
| `Ctrl + Alt + Del` | Sulge kõik aknad |
| `Super + K` | Näita kõiki kiirklahve |
| `Super + Alt + K` | Näita tmuxi kiirklahve |
| `Super + Ctrl + K` | Näita herdri kiirklahve |
| `Super + M` | Minimeeri aken dokki |
| `Super + T`               | Vaheta akna režiimi plaatija ja ujuva vahel             |
| `Super + J` | Lülita akna asendit (horisontaalne/vertikaalne) |
| `Super + O`               | Lülita akna esiletõstmine kleepuvasse ja ujuvasse režiimi |
| `Super + L`               | Vaheta järjest dwindle'i, keriva ja ujuva paigutuse vahel |
| `Super + Alt + L`         | Vaheta paigutusi vastupidises järjekorras |
| `Super + P`               | Lülita pseudoakna stiili (loomulik vs venitatud) |
| `Super + F`                 | Mine täisekraanile              |
| `Super + Alt + F`                 | Mine täislaiusele              |
| `Super + Ctrl + F`                 | Mine akna sees täisekraanile              |
| `Super + 1…9/0`         | Hüppa fookuses oleval monitoril konkreetsele tööalale (0 on 10) |
| `Super + Tab` | Hüppa fookuses oleval monitoril järgmisele tööalale |
| `Super + Shift + Tab` | Hüppa fookuses oleval monitoril eelmisele tööalale |
| `Super + Ctrl + Tab` | Hüppa fookuses oleval monitoril varasemale tööalale |
| `Super + Shift + 1…9/0` | Liiguta aken fookuses oleval monitoril tööalale |
| `Super + Shift + Alt + 1…9/0` | Liiguta aken fookuses oleval monitoril tööalale, ilma sellele järgnemata |
| `Super + S` | Lülita täielik scratchpad ümber |
| `Super + Alt + S` | Liiguta aken täielikku scratchpad'i |
| `Super + the key above Tab` (grave on US layouts) | Lülita Quake'i konsooli |
| `Super + Shift + the key above Tab` (grave on US layouts) | Liiguta aken Quake'i konsooli |
| `Super + Shift + Ctrl + Arrows` | Liiguta aken selles suunas olevale monitorile |
| `Super + Shift + Alt + Arrows` | Liiguta tööala selles suunas olevale monitorile |
| `Super + Arrow`  | Liiguta fookus noole suunas olevale aknale, ekraani serval ületades sellel poolel olevale monitorile |
| `Super + Shift + Arrow`  | Vaheta aken noole suunas oleva teise aknaga, kaasa arvatud sellel poolel oleval monitoril olevaga |
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
| `Super + Scroll Wheel` | Keri läbi fookuses oleva monitori tööalade |
| `Super + G`               | Lülita akende rühmitamist      |
| `Super + Alt + G`               | Liiguta aken rühmitusest välja      |
| `Super + Alt + Tab`               | Vaheta järjest rühmituses olevaid aknaid      |
| `Super + Alt + Shift + Tab`               | Vaheta järjest rühmituses olevaid aknaid tagurpidi      |
| `Super + Alt + Scroll Wheel` | Vaheta järjest rühmituses olevaid aknaid |
| `Super + Alt + 1/2/3/4/5`               | Hüppa rühmituses konkreetsele aknale      |
| `Super + Alt + Arrow`  | Liiguta aken noole suunas rühmitusse, kaasa arvatud sellel poolel oleval monitoril olev |
| `Super + Ctrl + Left/Right`  | Liigu plaatijarühma sees akende vahel |
| `Super + Ctrl + Z` | Suumi ekraanil sisse (korda suurema suumi jaoks) |
| `Super + Ctrl + Alt + Z` | Suumi ekraanilt täielikult välja |
| `Super + /` | Liigu monitori skaleerimisvalikutes edasi |
| `Super + Alt + /` | Liigu monitori skaleerimisvalikutes tagasi |
| `Alt + Tab` | Vaheta järjest edasi aktiivse tööala aknaid |
| `Alt + Shift + Tab` | Vaheta järjest tagasi aktiivse tööala aknaid |
| `Ctrl + Alt + Tab`| Vaheta fookust monitoride vahel edasi |
| `Ctrl + Alt + Shift + Tab`| Vaheta fookust monitoride vahel tagasi |
| `Super + I` | Vaheta sisendkeelt (kui on rohkem kui üks paigutus või sisendmeetod) |
| `Super + Shift + I` | Vaheta sisendkeel tagasi |

Puuteplaadil vahetavad kolme ja nelja sõrme pühked tööalasid, liigutavad aknaid ning avavad menüü ja Quake'i konsooli; žeste vaata jaotisest [klaviatuur, hiir ja puuteplaat](34-keyboard-mouse-trackpad.md).

Suuruse muutmine kasutab kahte klahvi, mis on 0-st paremal, ükskõik mis sinu klaviatuur neile trükib: USA klaviatuuridel `-` ja `=`, Taani ja Rootsi klaviatuuridel `+` ja `´`, Norra klaviatuuril `+` ja `\`, Saksa klaviatuuril `ß` ja `´`, Hispaania klaviatuuril `'` ja `¡` ning Jaapani (JIS) klaviatuuril `-` ja `^`. `Super + K` loetleb need nii, nagu sinu klaviatuur need trükib. JIS-il on `Super + ^` sama mis `Super + Equal`, samas kui `Super + Shift + -` (mis trükib `=`) on `Super + Shift + Minus`. Monitori skaleerimine ja paroolihaldur kasutavad `/`; paigutustel, mis trükivad `/` ainult koos Shiftiga, nagu enamik Euroopa omi, kasutavad nad selle asemel parempoolsest Shiftist vasakul olevat klahvi (`-` Taani ja Saksa puhul).

## Süsteemi juhtelemendid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Helipaneel    |
| `Super + Ctrl + B`           | Bluetoothi paneel    |
| `Super + Ctrl + N`           | Wi-Fi/võrgupaneel    |
| `Super + Ctrl + D`           | Ekraanipaneel    |
| `Super + Ctrl + P`           | Toitepaneel    |
| `Super + Ctrl + X`           | Agentide paneel    |
| `Super + Ctrl + Alt + X`           | Kohalike mudelite paneel    |
| `Super + Ctrl + Alt + D`           | Kalendripaneel    |
| `Super + Ctrl + Alt + E`           | Maailmakella paneel    |
| `Super + Ctrl + 1-9`           | Lülita ribapaneeli asendi järgi    |
| `Super + Ctrl + S` | Jagamismenüü (LocalSendi kaudu) |
| `Super + Ctrl + C` | Jäädvustamise juhtelemendid (ekraanipilt/-salvestus/valija) |
| `Super + Ctrl + O` | Lülita menüüd |
| `Super + Ctrl + H` | Riistvaramenüü |
| `Super + Ctrl + E` | Emotikonide valija |
| `Super + Ctrl + .` | Kodeeri meedia ümber |
| `Super + Shift + Ctrl + A` | Käivita oma vaikeagent |
| `Power` key | Süsteemimenüü |
| `Super + Shift + Copilot` key | Omarchy menüü |

## Kohandused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekraani maksimaalne heledus |
| `Shift + Brightness Down` | Ekraani minimaalne heledus |
| `Alt + Brightness Up/Down` | Täpsed 1% heleduse muutused |
| `Alt + Volume Up/Down` | Täpsed 1% helitugevuse muutused |
| `Keyboard Brightness Up/Down` | Klaviatuuri taustvalgus heledamaks/tumedamaks |
| `Keyboard Backlight` | Käi läbi klaviatuuri taustvalguse tasemed |
| `Ctrl + Brightness Up/Down` | Klaviatuuri taustvalgus heledamaks/tumedamaks klaviatuuridel, millel pole oma klahve |
| `Mic Mute` | Vaigista mikrofon |
| `Shift + Mute` | Vaheta heliväljundit |
| `Touchpad Toggle` | Lülita puuteplaat sisse või välja |
| `Display` key | Vaheta tööala paigutust järjest |
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
| `Super + Shift + D`           | Docker (lazydocker, kui see on installitud)    |
| `Super + Shift + T`           | Aktiivsus (btop)    |
| `Super + Shift + N`           | Redaktor (Plain või sinu valitud vaikeprogramm)  |
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

Tavaliselt on Linuxis terminalis kopeerimiseks ja kleepimiseks vaja `Ctrl + Shift + C/V` ning igal pool mujal selleks `Ctrl + C/V`. Need Omarchy ühtsed lõikelaua kiirklahvid töötavad igal pool.

## Jäädvustamine

| Kiirklahv              | Funktsioon                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekraanipilt                      |
| `Super + Ctrl + Alt + C`            | Ekraanipilt (sama võte klaviatuuridele, millel pole Print Screen klahvi) |
| `Super + Ctrl + C` | Jäädvustamismenüü |
| `Alt + Print Screen`            | Ekraanisalvestus                     |
| `Super + Shift + Ctrl + Alt + C` | Ekraanisalvestus ilma helita, menüü vahele jättes (peatamiseks vajuta uuesti) |
| `Super + Print Screen` | Värvivalija |
| `Super + Ctrl + Print Screen` | Teksti eraldamine lõikelauale |
| `Super + Alt + [` | Tee veebikaamera ülekatet salvestamise ajal väiksemaks |
| `Super + Alt + ]` | Tee veebikaamera ülekatet salvestamise ajal suuremaks |
| `Alt + Shift + L` | Kopeeri praegune URL veebirakendusest või brauserist |
| `Alt + Shift + D` | Laadi praegusel lehel olev video alla kausta `~/Videos` |
| `Alt + Space` | Alusta/peata dikteerimist (nõuab _Setup > Defaults > Dictation_) |
| `Right Alt` | Hoia dikteerimiseks all (nõuab _Setup > Defaults > Dictation_) |

Ekraanisalvestuste puhul küsib kiirklahv esmalt, millist heli sa tahad, seejärel alustab salvestamist. Peatamiseks vajuta seda uuesti. Üksikasju vaata jaotisest [ekraanipildid ja salvestamine](12-screenshots-recording.md).

Kõik jäädvustamisvalikud on saadaval ka Omarchy menüüs (`Super + Space`) jaotise _Trigger > Capture_ all.

## Teavitused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + ,` | Toimi viimase teavitusega: ava see või vajuta selle ainsat nuppu, vali selle valikute hulgast või eemalda see, kui sellel pole ühtegi  |
| `Super + Shift + ,` | Eemalda kõik teavitused |
| `Super + Ctrl + ,` | Juhi teavitusi klaviatuuriga  |
| `Super + Alt + ,` | Eemalda viimane teavitus  |
| `Super + Shift + Alt + ,` | Ava teavituste ajalugu  |
| `Super + Ctrl + Alt + ,` | Lülita teavituste vaigistamist  |

## Stiil

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vali uus teema (ka `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vali teema taust (ka `Super + Ctrl + Space`) |
| `Super + Backspace` | Lülita akna läbipaistvust |
| `Super + Ctrl + Backspace` | Lülita ühe akna ruudukujulist kuvasuhet |

Lisa taustapildid asuvad kaustas `~/.config/omarchy/backgrounds/<theme name>`. Saadaval ka Omarchy menüü kaudu _Install > Style > Background_.

Kõik stiilivalikud on saadaval ka Omarchy menüüs (`Super + Space`) jaotise _Appearance_ all.

## Lülitid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Lülita jõudeolekul lukustamist |
| `Super + Ctrl + Delete` | Lülita sülearvuti ekraan sisse/välja |
| `Super + Ctrl + Alt + Delete` | Lülita sülearvuti ekraani peegeldamist |
| `Super + Shift + Space` | Lülita ülemist riba  |
| `Shift + Mute` | Vaheta järgmisele heliväljundile |
| `Shift + Play` | Vaheta järgmisele meediaallikale |
| `Super + Shift + Backspace` | Lülita akna vahesid |
| `Super + Ctrl + Alt + F` | Lülita täisekraani töölauda (ülemine riba + akna vahed) |

## Meeldetuletused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Sea meeldetuletus  |
| `Super + Ctrl + Alt + R` | Vaata kõiki meeldetuletusi  |
| `Super + Ctrl + Shift + R` | Kustuta kõik meeldetuletused  |

## Märguanded

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Näita kellaaega teavitusena  |
| `Super + Ctrl + Alt + B` | Näita akut teavitusena  |
| `Super + Ctrl + Alt + W` | Lülita ilma teavitusena näitamist  |

## Tmux

Eesliiteklahv on `Ctrl + Space` (`Ctrl + B` töötab samuti). Neid seoseid saad muuta failis `~/.config/tmux/tmux.conf`.

### Paneelid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + v` | Jaga paneel kõrvale (vertikaalne) |
| `Prefix + h` | Jaga paneel alla (horisontaalne) |
| `Prefix + x` | Hävita paneel |
| `Prefix + z` | Lülita paneeli suumi (täisekraan) |
| `Alt + Enter` | Jaga paneel alla (ilma eesliiteta) |
| `Alt + Shift + Enter` | Jaga paneel kõrvale (ilma eesliiteta) |
| `Alt + Escape` | Hävita paneel (ilma eesliiteta) |
| `Ctrl + Alt + Arrows` | Liigu paneelide vahel |
| `Ctrl + Alt + Shift + Arrows` | Muuda paneelide suurust |

### Aknad

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + c` | Uus aken |
| `Prefix + k` | Hävita aken |
| `Prefix + r` | Nimeta aken ümber |
| `Alt + 1-9` | Mine konkreetsele aknale |
| `Alt + Arrow Left/Right` | Liigu akende vahel |
| `Alt + Shift + Arrow Left/Right` | Liiguta aken vasakule/paremale |

### Seansid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + C` | Uus seanss |
| `Prefix + K` | Hävita seanss |
| `Prefix + R` | Nimeta seanss ümber |
| `Prefix + N` | Järgmine seanss |
| `Prefix + P` | Eelmine seanss |
| `Alt + Arrow Up/Down` | Liigu seansside vahel |
| `Prefix + s` | Loetle seansid |
| `Prefix + d` | Lahku seansist |

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
| `tdlm <ai> [<second_ai>]` | Loo arenduspaigutus iga alamkataloogi jaoks |
| `tsl <count> <command>` | Loo mitme paneeliga parvpaigutus |

## Ghostty terminal

Ghostty terminal installitakse Omarchy menüü kaudu _Install > Terminal_ abil.

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Uus jaotus allpool |
| `Ctrl + Shift + O` | Uus jaotus kõrvale |
| `Ctrl + Alt + Arrows` | Liigu jaotuste vahel |
| `Super + Ctrl + Shift + Arrows` | Muuda jaotuse suurust 10 rea võrra |
| `Super + Ctrl + Shift + Alt + Arrows` | Muuda jaotuse suurust 100 rea võrra |
| `Ctrl + Shift + T` | Uus vahekaart  |
| `Ctrl + Shift + Arrows` | Liigu vahekaartide vahel |
| `Alt + Numbers` | Mine konkreetsele vahekaardile |
| `Shift + Pg Up/Down` | Keri ajalugu |
| `Ctrl + Left mouse` | Ava link brauseris |

## Failihaldur

| Kiirklahv              | Funktsioon                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Mine tee juurde                     |
| `Space`               | Faili eelvaade (nooled navigeerivad) |
| `Alt + Up`       | Mine üles ülemkausta        |

## Neovim (koos lazyvimiga)

### Navigeerimine

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Näita käsuvalikuid            |
| `Space Space`              | Ava fail hägusa otsingu kaudu      |
| `Space E`                  | Lülita külgriba                  |
| `Space G G`                | Näita giti juhtelemente               |
| `Space S G`                | Otsi faili sisust             |
| `Ctrl + W W`               | Hüppa külgriba ja redaktori vahel |
| `Ctrl + Left/right arrow`  | Muuda külgriba suurust          |
| `Shift + H`                      | Mine vasakpoolsele failikaardile             |
| `Shift + L`                      | Mine parempoolsele failikaardile            |
| `Space B D`                | Sulge failikaart                  |

### Külgribal olles

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `A`                        | Lisa uus fail ülemkataloogi      |
| `Shift + A`                | Lisa uus alamkataloog ülemkataloogi    |
| `D`                        | Kustuta esiletõstetud fail/kataloog     |
| `M`                        | Liiguta esiletõstetud faili/kataloogi       |
| `R`                        | Nimeta esiletõstetud fail/kataloog ümber     |
| `?`                        | Näita kõigi käskude abi      |

[Vaata kõiki LazyVimi seadistatud Neovimi kiirklahve](https://www.lazyvim.org/keymaps).

## Kiired emotikonid

Saad kasutada `Super + Ctrl + E`, et näidata täielikku emotikonide valijat, mis paneb valiku lõikelauale, või saad kasutada neid kiire juurdepääsu valikuid.

| Kiirklahv       | EM | Vihje       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | naeratus      |
| `Shift + CapsLock M C` | 😂 | nutt        |
| `Shift + CapsLock M L` | 😍 | armastus       |
| `Shift + CapsLock M V` | ✌️ | võit    |
| `Shift + CapsLock M H` | ❤️ | süda      |
| `Shift + CapsLock M Y` | 👍 | jah        |
| `Shift + CapsLock M N` | 👎 | ei         |
| `Shift + CapsLock M F` | 🖕 | vittu       |
| `Shift + CapsLock M W` | 🤞 | soov       |
| `Shift + CapsLock M R` | 🤘 | rokk       |
| `Shift + CapsLock M K` | 😘 | suudlus       |
| `Shift + CapsLock M E` | 🙄 | silmade pööritamine    |
| `Shift + CapsLock M I` | 😉 | silmapilgutus       |
| `Shift + CapsLock M P` | 🙏 | palve |
| `Shift + CapsLock M D` | 🤤 | ilastamine      |
| `Shift + CapsLock M M` | 💰 | raha      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | tervitus |
| `Shift + CapsLock M A` |💪 | käsivars |
| `Shift + CapsLock M B` |🤯 | plahvatav |

## Kiired tekstilõpetused

| Kiirklahv       | Lõpetus       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (pikk mõttekriips)   |
| `Shift + CapsLock Space N` | Sinu nimi (nagu seadistamisel sisestatud)  |
| `Shift + CapsLock Space E` | Sinu e-post (nagu seadistamisel sisestatud)  |

Saad enda omi lisada, muutes faili `~/.XCompose`, seejärel käivitades terminalis `omarchy restart xcompose`, et muudatused kasutusele võetaks.
