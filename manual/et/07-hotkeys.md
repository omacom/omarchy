# Kiirklahvid

Kõiki peamisi klahviseoseid näed klahvidega `Super + K` (Tmuxi seoseid klahvidega `Super + Alt + K` ja Herdr seoseid klahvidega `Super + Ctrl + K`).

## Kuidas kiirklahvid on paigutatud

Iga kiirklahv asub tasandil, mille määravad selle modifikaatorid, ja igal tasandil on üks ülesanne. Just see hoiab kiirklahvid üksteisest eristatavana ja tähendab, et saad tavaliselt ära arvata, kus miski asub.

| Tasand | Mis seal asub | Näited |
| --- | --- | --- |
| `Super + key` | Süsteem: aknad, tööalad, paigutused ja põhimenüüd | `Super + Space` Omarchy menüü, `Super + W` sulge aken, `Super + F` täisekraan |
| `Super + Shift + key` | Rakendused | `Super + Shift + B` brauser, `Super + Shift + E` e-post, `Super + Shift + N` redaktor |
| `Super + Ctrl + key` | Paneelid ja süsteemimenüüd | `Super + Ctrl + A` heli, `Super + Ctrl + N` võrk, `Super + Ctrl + C` hõivemenüü |
| `Super + Ctrl + Alt + key` | Kiirtoimingud ja teated | `Super + Ctrl + Alt + T` näita kellaaega, `Super + Ctrl + Alt + B` aku, `Super + Ctrl + Alt + C` ekraanipilt |

`Alt` lisamine kiirklahvile annab sulle sama asja variandi, mitte kunagi midagi seosetut:

- `Super + Shift + B` avab brauseri; `Super + Shift + Alt + B` avab privaatse akna
- `Super + Shift + E` avab e-posti; `Super + Shift + Alt + E` alustab uut
- `Super + F` läheb täisekraanile; `Super + Alt + F` läheb täislaiusele
- `Super + Ctrl + C` avab hõivemenüü; `Super + Ctrl + Alt + C` jätab menüü vahele ja teeb ekraanipildi

Kiirklahvi lisamisel:

1. Vali tasand selle järgi, mida see teeb, seejärel vali klahv.
2. Ära liiguta olemasolevat kiirklahvi, et ruumi teha. Leia õigel tasandil vaba klahv.
3. Kasuta `Alt` ainult ilma selleta kiirklahvi variandi jaoks.

Mõned kiirklahvid rikuvad neid reegleid, sest need on mugavad. `Shift` koos noolega või `Tab` liigutab või pöörab suunda ümber, selle asemel et rakendust avada, ning `Print`, meediaklahvid, `Alt + Tab` ja `Ctrl + Alt + Del` töötavad nii, nagu nad kõikjal mujal töötavad. Need on erandid, mitte mustrid, mida kopeerida.

Kui vaikevalik sulle ei sobi (ütleme, et soovid ekraanipiltide jaoks `Super + Shift + S` nagu Windowsis), seo see uuesti failis `~/.config/hypr/bindings.lua`.

## Navigeerimine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menüü (rakendused ja kõik muu)    |
| `Super + Alt + Space` | Rakenduste ruudustik |
| `Super + Escape` | Süsteemimenüü (peatamine, taaskäivitus jne)  |
| `Super + Ctrl + L` | Lukusta arvuti |
| `Super + W` or `Super + Q` | Sulge aken             |
| `Ctrl + Alt + Del` | Sulge kõik aknad |
| `Super + K` | Näita kõiki kiirklahve |
| `Super + Alt + K` | Näita tmuxi kiirklahve |
| `Super + Ctrl + K` | Näita herdri kiirklahve |
| `Super + M` | Minimeeri aken dokki |
| `Super + T`               | Lülita aken paanipaigutuse/ujuva režiimi vahel             |
| `Super + J` | Lülita akna asendit (horisontaalne/vertikaalne) |
| `Super + O`               | Lülita aken esilekerkivasse sticky'n'floating režiimi |
| `Super + L`               | Liigu ringiga läbi dwindle-, kerimis- ja ujuva paigutuse |
| `Super + Alt + L`         | Liigu ringiga läbi paigutuste vastassuunas |
| `Super + P`               | Lülita pseudoakna stiili (loomulik vs venitatud) |
| `Super + F`                 | Mine täisekraanile              |
| `Super + Alt + F`                 | Mine täislaiusele              |
| `Super + Ctrl + F`                 | Mine akna sees täisekraanile              |
| `Super + 1…9/0`         | Hüppa fokuseeritud monitoril kindlale tööalale (0 on 10) |
| `Super + Tab` | Hüppa fokuseeritud monitoril järgmisele tööalale |
| `Super + Shift + Tab` | Hüppa fokuseeritud monitoril eelmisele tööalale |
| `Super + Ctrl + Tab` | Hüppa fokuseeritud monitoril varasemale tööalale |
| `Super + Shift + 1…9/0` | Liiguta aken fokuseeritud monitoril tööalale |
| `Super + Shift + Alt + 1…9/0` | Liiguta aken fokuseeritud monitoril tööalale ilma järgnemata |
| `Super + S` | Lülita täis-scratchpad |
| `Super + Alt + S` | Liiguta aken täis-scratchpadile |
| `Super + the key above Tab` (grave on US layouts) | Lülita Quake konsool |
| `Super + Shift + the key above Tab` (grave on US layouts) | Liiguta aken Quake konsooli |
| `Super + Shift + Ctrl + Arrows` | Liiguta aken selles suunas asuvale monitorile |
| `Super + Shift + Alt + Arrows` | Liiguta tööala selles suunas asuvale monitorile |
| `Super + Arrow`  | Liiguta fookus noole suunas asuvale aknale, ekraani serval ületades selle poole monitori |
| `Super + Shift + Arrow`  | Vaheta aken noole suunas asuva teisega, kaasa arvatud selle poole monitoril asuv |
| `Super + Minus` | Laienda akent vasakule |
| `Super + Equal` | Kahanda akent vasakult |
| `Super + Shift + Minus` | Kahanda akent üles |
| `Super + Shift + Equal` | Laienda akent alla |
| `Super + Alt + Minus/Equal` | Sama suuruse muutmine väiksemate sammudega |
| `Super + Ctrl + Minus/Equal` | Sama suuruse muutmine suuremate sammudega |
| `Super + Alt + Home` | Salvesta akna laius |
| `Super + Home` | Taasta salvestatud akna laius |
| `Super + Left Mouse` | Lohista akent ringi |
| `Super + Right Mouse` | Muuda akna suurust |
| `Super + Scroll Wheel` | Keri fokuseeritud monitoril läbi tööalade |
| `Super + G`               | Lülita akende rühmitamist      |
| `Super + Alt + G`               | Liiguta aken rühmitusest välja      |
| `Super + Alt + Tab`               | Liigu ringiga rühmituse akende vahel      |
| `Super + Alt + Shift + Tab`               | Liigu ringiga rühmituse akende vahel tagasisuunas      |
| `Super + Alt + Scroll Wheel` | Liigu ringiga rühmituse akende vahel |
| `Super + Alt + 1/2/3/4/5`               | Hüppa rühmituses kindla akna juurde      |
| `Super + Alt + Arrow`  | Liiguta aken noole suunas rühmitusse, kaasa arvatud selle poole monitoril asuv |
| `Super + Ctrl + Left/Right`  | Liigu paanipaigutusega rühma akende vahel |
| `Super + Ctrl + Z` | Suumi ekraanil sisse (korda suurema suumi jaoks) |
| `Super + Ctrl + Alt + Z` | Suumi ekraanilt täielikult välja |
| `Super + /` | Liigu edasi läbi monitori skaleerimise valikute |
| `Super + Alt + /` | Liigu tagasi läbi monitori skaleerimise valikute |
| `Alt + Tab` | Liigu ringiga edasi läbi aktiivse tööala akende |
| `Alt + Shift + Tab` | Liigu ringiga tagasi läbi aktiivse tööala akende |
| `Ctrl + Alt + Tab`| Liiguta fookust edasi läbi monitoride |
| `Ctrl + Alt + Shift + Tab`| Liiguta fookust tagasi läbi monitoride |
| `Super + I` | Vaheta sisestuskeelt (kui on rohkem kui üks paigutus või sisestusmeetod) |
| `Super + Shift + I` | Vaheta sisestuskeel tagasi |

Puuteplaadil lülitavad kolme ja nelja sõrme pühked tööalasid, liigutavad aknaid ning avavad menüü ja Quake konsooli; žeste vaata jaotisest [klaviatuur, hiir ja puuteplaat](34-keyboard-mouse-trackpad.md).

Suuruse muutmine kasutab 0-st paremal asuvaid kahte klahvi, mida iganes sinu klaviatuur neile trükib: `-` ja `=` USA klaviatuuridel, `+` ja `´` Taani ja Rootsi omadel, `+` ja `\` Norra omal, `ß` ja `´` Saksa omal, `'` ja `¡` Hispaania omal ning `-` ja `^` Jaapani (JIS) omal. `Super + K` loetleb need nii, nagu sinu klaviatuur need trükib. JIS-il on `Super + ^` sama mis `Super + Equal`, samas kui `Super + Shift + -` (mis trükib `=`) on `Super + Shift + Minus`. Monitori skaleerimine ja paroolihaldur kasutavad `/`; paigutustel, mis trükivad `/` ainult koos Shiftiga, nagu enamik Euroopa omi, kasutavad nad selle asemel paremast Shiftist vasakul asuvat klahvi (`-` Taani ja Saksa omadel).

## Süsteemi juhtelemendid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Helipaneel    |
| `Super + Ctrl + B`           | Bluetoothi paneel    |
| `Super + Ctrl + N`           | Wifi-/võrgupaneel    |
| `Super + Ctrl + D`           | Kuvapaneel    |
| `Super + Ctrl + P`           | Toitepaneel    |
| `Super + Ctrl + X`           | Agentide paneel    |
| `Super + Ctrl + Alt + D`           | Kalendripaneel    |
| `Super + Ctrl + Alt + E`           | Maailmakella paneel    |
| `Super + Ctrl + 1-9`           | Lülita ribapaneeli asendi järgi    |
| `Super + Ctrl + S` | Jagamismenüü (LocalSendi kaudu) |
| `Super + Ctrl + C` | Hõive juhtelemendid (ekraanipilt/-salvestus/valija) |
| `Super + Ctrl + O` | Lülita menüüd |
| `Super + Ctrl + H` | Riistvara menüü |
| `Super + Ctrl + E` | Emoji valija |
| `Super + Ctrl + .` | Transkoodi meediat |
| `Super + Shift + Ctrl + A` | Käivita oma vaikeagent |
| `Power` key | Süsteemimenüü |
| `Super + Shift + Copilot` key | Omarchy menüü |

## Reguleerimised

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekraani maksimaalne heledus |
| `Shift + Brightness Down` | Ekraani minimaalne heledus |
| `Alt + Brightness Up/Down` | Täpsed 1% heleduse muudatused |
| `Alt + Volume Up/Down` | Täpsed 1% helitugevuse muudatused |
| `Keyboard Brightness Up/Down` | Klaviatuuri taustvalgus heledamaks/tumedamaks |
| `Keyboard Backlight` | Liigu ringiga läbi klaviatuuri taustvalguse tasemete |
| `Ctrl + Brightness Up/Down` | Klaviatuuri taustvalgus heledamaks/tumedamaks klaviatuuridel, millel pole oma klahve |
| `Mic Mute` | Vaigista mikrofon |
| `Shift + Mute` | Vaheta heliväljundit |
| `Touchpad Toggle` | Lülita puuteplaat sisse või välja |
| `Display` key | Liigu ringiga läbi tööala paigutuse |
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
| `Super + Shift + D`           | Docker (lazydocker, kui on paigaldatud)    |
| `Super + Shift + T`           | Aktiivsus (btop)    |
| `Super + Shift + N`           | Redaktor (Plain või sinu valitud vaikevalik)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-post ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Uus e-kiri ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
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

Tavaliselt on Linuxis terminalis kopeerimiseks ja kleepimiseks vaja `Ctrl + Shift + C/V` ja kõikjal mujal `Ctrl + C/V`. Need Omarchy ühtsed lõikelaua kiirklahvid töötavad kõikjal.

## Hõive

| Kiirklahv              | Funktsioon                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekraanipilt                      |
| `Super + Ctrl + Alt + C`            | Ekraanipilt (sama võte klaviatuuridele, millel pole Print Screen klahvi) |
| `Super + Ctrl + C` | Hõivemenüü |
| `Alt + Print Screen`            | Ekraanisalvestus                     |
| `Super + Shift + Ctrl + Alt + C` | Ekraanisalvestus ilma helita, menüü vahele jättes (peatamiseks vajuta uuesti) |
| `Super + Print Screen` | Värvivalija |
| `Super + Ctrl + Print Screen` | Teksti eraldamine lõikelauale |
| `Super + Alt + [` | Tee veebikaamera ülekate salvestamise ajal väiksemaks |
| `Super + Alt + ]` | Tee veebikaamera ülekate salvestamise ajal suuremaks |
| `Alt + Shift + L` | Kopeeri praegune URL veebirakendusest või brauserist |
| `Alt + Shift + D` | Laadi praegusel lehel olev video alla kausta `~/Videos` |
| `Alt + Space` | Alusta/peata dikteerimine (nõuab _Setup > Defaults > Dictation_) |
| `Right Alt` | Hoia dikteerimiseks all (nõuab _Setup > Defaults > Dictation_) |

Ekraanisalvestuste puhul küsib kiirklahv esmalt, millist heli soovid, seejärel alustab salvestamist. Peatamiseks vajuta seda uuesti. Üksikasju vaata jaotisest [ekraanipildid ja salvestamine](12-screenshots-recording.md).

Kõik hõivevalikud on kättesaadavad ka Omarchy menüüs (`Super + Space`) jaotises _Trigger > Capture_.

## Teavitused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + ,` | Toimi viimase teavitusega: ava see või vajuta selle ainsat nuppu, vali selle valikute hulgast või loobu sellest, kui sellel pole ühtegi  |
| `Super + Shift + ,` | Loobu kõigist teavitustest |
| `Super + Ctrl + ,` | Juhi teavitusi klaviatuuriga  |
| `Super + Alt + ,` | Loobu viimasest teavitusest  |
| `Super + Shift + Alt + ,` | Ava teavituste ajalugu  |
| `Super + Ctrl + Alt + ,` | Lülita teavituste vaigistamist  |

## Stiil

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vali uus teema (ka `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vali teema taust (ka `Super + Ctrl + Space`) |
| `Super + Backspace` | Lülita akna läbipaistvust |
| `Super + Ctrl + Backspace` | Lülita ühe akna ruudukujulist kuvasuhet |

Lisataustapildid asuvad kaustas `~/.config/omarchy/backgrounds/<theme name>`. Saadaval ka Omarchy menüüs jaotises _Install > Style > Background_.

Kõik stiilivalikud on kättesaadavad ka Omarchy menüüs (`Super + Space`) jaotises _Appearance_.

## Lülitid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Lülita jõudeolekul lukustamist |
| `Super + Ctrl + Delete` | Lülita sülearvuti ekraan sisse/välja |
| `Super + Ctrl + Alt + Delete` | Lülita sülearvuti ekraani peegeldamist |
| `Super + Shift + Space` | Lülita ülemist riba  |
| `Shift + Mute` | Vaheta järgmisele heliväljundile |
| `Shift + Play` | Vaheta järgmisele meediaallikale |
| `Super + Shift + Backspace` | Lülita aknavahesid |
| `Super + Ctrl + Alt + F` | Lülita täisekraani töölauda (ülemine riba + aknavahed) |

## Meeldetuletused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Sea meeldetuletus  |
| `Super + Ctrl + Alt + R` | Vaata kõiki meeldetuletusi  |
| `Super + Ctrl + Shift + R` | Kustuta kõik meeldetuletused  |

## Teated

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Näita kellaaega teavitusena  |
| `Super + Ctrl + Alt + B` | Näita akut teavitusena  |
| `Super + Ctrl + Alt + W` | Lülita ilma teavitusena  |

## Tmux

Eelklahv on `Ctrl + Space` (`Ctrl + B` töötab samuti). Neid seoseid saad muuta failis `~/.config/tmux/tmux.conf`.

### Paanid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + v` | Jaga paan kõrvale (vertikaalne) |
| `Prefix + h` | Jaga paan alla (horisontaalne) |
| `Prefix + x` | Lõpeta paan |
| `Prefix + z` | Lülita paani suumi (täisekraan) |
| `Alt + Enter` | Jaga paan alla (ilma eelklahvita) |
| `Alt + Shift + Enter` | Jaga paan kõrvale (ilma eelklahvita) |
| `Alt + Escape` | Lõpeta paan (ilma eelklahvita) |
| `Ctrl + Alt + Arrows` | Liigu paanide vahel |
| `Ctrl + Alt + Shift + Arrows` | Muuda paanide suurust |

### Aknad

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + c` | Uus aken |
| `Prefix + k` | Lõpeta aken |
| `Prefix + r` | Nimeta aken ümber |
| `Alt + 1-9` | Mine kindla akna juurde |
| `Alt + Arrow Left/Right` | Liigu akende vahel |
| `Alt + Shift + Arrow Left/Right` | Liiguta akent vasakule/paremale |

### Seansid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + C` | Uus seanss |
| `Prefix + K` | Lõpeta seanss |
| `Prefix + R` | Nimeta seanss ümber |
| `Prefix + N` | Järgmine seanss |
| `Prefix + P` | Eelmine seanss |
| `Alt + Arrow Up/Down` | Liigu seansside vahel |
| `Prefix + s` | Loetle seansid |
| `Prefix + d` | Eemaldu seansist |

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

Neid funktsioone tuleb käitada Tmuxi seansi sees.

| Käsk | Funktsioon |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Loo arenduspaigutus redaktori, AI ja terminaliga |
| `tdlm <ai> [<second_ai>]` | Loo arenduspaigutus iga alamkataloogi kohta |
| `tsl <count> <command>` | Loo mitme paaniga parvepaigutus |

## Ghostty terminal

Ghostty terminal paigaldatakse Omarchy menüü kaudu jaotises _Install > Terminal_.

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Uus jaotus alla |
| `Ctrl + Shift + O` | Uus jaotus kõrvale |
| `Ctrl + Alt + Arrows` | Liigu jaotuste vahel |
| `Super + Ctrl + Shift + Arrows` | Muuda jaotuse suurust 10 rea võrra |
| `Super + Ctrl + Shift + Alt + Arrows` | Muuda jaotuse suurust 100 rea võrra |
| `Ctrl + Shift + T` | Uus vahekaart  |
| `Ctrl + Shift + Arrows` | Liigu vahekaartide vahel |
| `Alt + Numbers` | Mine kindla vahekaardi juurde |
| `Shift + Pg Up/Down` | Keri ajalugu |
| `Ctrl + Left mouse` | Ava link brauseris |

## Failihaldur

| Kiirklahv              | Funktsioon                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Mine teele                     |
| `Space`               | Faili eelvaade (nooled navigeerivad) |
| `Alt + Up`       | Mine üles ülemkausta        |

## Neovim (koos lazyvimiga)

### Navigeerimine

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Näita käsuvalikuid            |
| `Space Space`              | Ava fail hägusotsinguga      |
| `Space E`                  | Lülita külgriba                  |
| `Space G G`                | Näita giti juhtelemente               |
| `Space S G`                | Otsi faili sisust             |
| `Ctrl + W W`               | Hüppa külgriba ja redaktori vahel |
| `Ctrl + Left/right arrow`  | Muuda külgriba suurust          |
| `Shift + H`                      | Mine vasakpoolse failivahekaardi juurde             |
| `Shift + L`                      | Mine parempoolse failivahekaardi juurde            |
| `Space B D`                | Sulge failivahekaart                  |

### Külgribas olles

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `A`                        | Lisa uus fail ülemkataloogi      |
| `Shift + A`                | Lisa uus alamkataloog ülemkataloogi    |
| `D`                        | Kustuta esiletõstetud fail/kataloog     |
| `M`                        | Liiguta esiletõstetud faili/kataloogi       |
| `R`                        | Nimeta esiletõstetud fail/kataloog ümber     |
| `?`                        | Näita kõigi käskude abi      |

[Vaata kõiki Neovimi kiirklahve, mille LazyVim on seadistanud](https://www.lazyvim.org/keymaps).

## Kiiremotikonid

Saad kasutada klahve `Super + Ctrl + E`, et näidata täielikku emoji-valijat, mis paneb valiku lõikelauale, või saad kasutada neid kiirpääsuvalikuid.

| Kiirklahv       | EM | Vihje       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | naeratus      |
| `Shift + CapsLock M C` | 😂 | nutt        |
| `Shift + CapsLock M L` | 😍 | armastus       |
| `Shift + CapsLock M V` | ✌️ | võit    |
| `Shift + CapsLock M H` | ❤️ | süda      |
| `Shift + CapsLock M Y` | 👍 | jah        |
| `Shift + CapsLock M N` | 👎 | ei         |
| `Shift + CapsLock M F` | 🖕 | keskmine sõrm       |
| `Shift + CapsLock M W` | 🤞 | soov       |
| `Shift + CapsLock M R` | 🤘 | rokk       |
| `Shift + CapsLock M K` | 😘 | musi       |
| `Shift + CapsLock M E` | 🙄 | silmapööre    |
| `Shift + CapsLock M I` | 😉 | silmapilgutus       |
| `Shift + CapsLock M P` | 🙏 | palve |
| `Shift + CapsLock M D` | 🤤 | ila      |
| `Shift + CapsLock M M` | 💰 | raha      |
| `Shift + CapsLock M X` | 🎉 | pidu |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | terviseks      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | tervitus |
| `Shift + CapsLock M A` |💪 | muskel |
| `Shift + CapsLock M B` |🤯 | plahvatav pea |

## Kiirtäiendused

| Kiirklahv       | Täiendus       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mõttekriips)   |
| `Shift + CapsLock Space N` | Sinu nimi (nagu seadistamisel sisestatud)  |
| `Shift + CapsLock Space E` | Sinu e-post (nagu seadistamisel sisestatud)  |

Saad enda omi lisada, muutes faili `~/.XCompose` ja käivitades seejärel terminalis `omarchy restart xcompose`, et muudatused rakenduksid.
