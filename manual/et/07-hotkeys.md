# Kiirklahvid

Kõiki peamisi klahvikombinatsioone näed klahvidega `Super + K` (Tmuxi seosed klahvidega `Super + Alt + K` ja Herdr seosed klahvidega `Super + Ctrl + K`).

## Kuidas kiirklahvid on paigutatud

Iga kiirklahv asub ühel tasandil, mille määravad selle modifikaatorid, ja igal tasandil on üks ülesanne. Just see hoiab kiirklahvid omavahel segamini minemast ja tähendab, et tavaliselt oskad arvata, kus miski asub.

| Tasand | Mis seal asub | Näited |
| --- | --- | --- |
| `Super + key` | Süsteem: aknad, tööruumid, paigutused ja põhimenuüd | `Super + Space` Omarchy menüü, `Super + W` akna sulgemine, `Super + F` täisekraan |
| `Super + Shift + key` | Rakendused | `Super + Shift + B` brauser, `Super + Shift + E` e-post, `Super + Shift + N` redaktor |
| `Super + Ctrl + key` | Paneelid ja süsteemimenüüd | `Super + Ctrl + A` heli, `Super + Ctrl + N` võrk, `Super + Ctrl + C` jäädvustamise menüü |
| `Super + Ctrl + Alt + key` | Kiirtoimingud ja teated | `Super + Ctrl + Alt + T` kellaaja näitamine, `Super + Ctrl + Alt + B` aku, `Super + Ctrl + Alt + C` ekraanipilt |

Klahvi `Alt` lisamine kiirklahvile annab sulle sama asja variandi, mitte kunagi millegi täiesti seosetu:

- `Super + Shift + B` avab brauseri; `Super + Shift + Alt + B` avab privaatse akna
- `Super + Shift + E` avab e-posti; `Super + Shift + Alt + E` alustab uut kirja
- `Super + F` läheb täisekraanile; `Super + Alt + F` läheb täislaiusesse
- `Super + Ctrl + C` avab jäädvustamise menüü; `Super + Ctrl + Alt + C` jätab menüü vahele ja teeb ekraanipildi

Kiirklahvi lisades:

1. Vali tasand selle järgi, mida see teeb, seejärel vali klahv.
2. Ära nihuta olemasolevat kiirklahvi, et ruumi teha. Leia õigel tasandil vaba klahv.
3. Kasuta klahvi `Alt` ainult ilma selleta kiirklahvi variandi jaoks.

Mõni kiirklahv rikub neid reegleid, sest nii on mugav. `Shift` koos nooleklahvi või klahviga `Tab` liigutab või pöörab suunda ümber, selle asemel et rakendust avada, ning `Print`, meediaklahvid, `Alt + Tab` ja `Ctrl + Alt + Del` toimivad samamoodi nagu igal pool mujal. Need on erandid, mitte mustrid, mida kopeerida.

Kui vaikesäte sulle ei sobi (ütleme, et tahad ekraanipiltide jaoks klahve `Super + Shift + S` nagu Windowsis), seo see ümber failis `~/.config/hypr/bindings.lua`.

## Navigeerimine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menüü (rakendused ja kõik muu)    |
| `Super + Alt + Space` | Rakenduste ruudustik |
| `Super + Escape` | Süsteemimenüü (peatamine, taaskäivitamine jne)  |
| `Super + Ctrl + L` | Arvuti lukustamine |
| `Super + W` või `Super + Q` | Akna sulgemine             |
| `Ctrl + Alt + Del` | Kõigi akende sulgemine |
| `Super + T`               | Akna ümberlülitamine paigutatud ja ujuva vahel             |
| `Super + J` | Akna asendi ümberlülitamine (horisontaalne/vertikaalne) |
| `Super + O`               | Akna ümberlülitamine kleepuvaks ja ujuvaks esiletoomiseks |
| `Super + L`               | Liigu järjest läbi dwindle-, kerimis- ja ujuva paigutuse |
| `Super + Alt + L`         | Liigu läbi paigutuste vastupidises järjekorras |
| `Super + P`               | Pseudoakna stiili ümberlülitamine (loomulik vs venitatud) |
| `Super + F`                 | Mine täisekraanile              |
| `Super + Alt + F`                 | Mine täislaiusesse              |
| `Super + Ctrl + F`                 | Mine täisekraanile akna sees              |
| `Super + 1/2/3/4`         | Hüppa kindlale tööruumile fokuseeritud monitoril |
| `Super + Tab` | Hüppa järgmisele tööruumile fokuseeritud monitoril |
| `Super + Shift + Tab` | Hüppa eelmisele tööruumile fokuseeritud monitoril |
| `Super + Ctrl + Tab` | Hüppa varasemale tööruumile fokuseeritud monitoril |
| `Super + Shift + 1/2/3/4` | Teisalda aken tööruumile fokuseeritud monitoril |
| `Super + Shift + Alt + 1/2/3/4` | Teisalda aken tööruumile fokuseeritud monitoril ilma järgnemata |
| `Super + S` | Lülita täielik scratchpad ümber |
| `Super + Alt + S` | Teisalda aken täielikku scratchpad'i |
| `Super + Grave` | Lülita Quake konsool ümber |
| `Super + Shift + Grave` | Teisalda aken Quake konsooli |
| `Super + Shift + Ctrl + Arrows` | Teisalda aken selles suunas asuvale monitorile |
| `Super + Shift + Alt + Arrows` | Teisalda tööruum selles suunas asuvale monitorile |
| `Super + Arrow`  | Liiguta fookus noole suunas asuvale aknale, liikudes ekraani serval selle poole monitorile |
| `Super + Shift + Arrow`  | Vaheta aken noole suunas asuva teisega, kaasa arvatud selle poole monitoril asuvaga |
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
| `Super + Scroll Wheel` | Keri läbi tööruumide fokuseeritud monitoril |
| `Super + G`               | Lülita akende rühmitamine ümber      |
| `Super + Alt + G`               | Teisalda aken rühmast välja      |
| `Super + Alt + Tab`               | Liigu rühma akende vahel      |
| `Super + Alt + Shift + Tab`               | Liigu rühma akende vahel tagurpidi      |
| `Super + Alt + Scroll Wheel` | Liigu rühma akende vahel |
| `Super + Alt + 1/2/3/4/5`               | Hüppa rühmas kindlale aknale      |
| `Super + Alt + Arrow`  | Teisalda aken rühma noole suunas, kaasa arvatud selle poole monitoril asuvasse |
| `Super + Ctrl + Left/Right`  | Liigu paigutatud rühma akende vahel |
| `Super + Ctrl + Z` | Suumi ekraanil sisse (korda suurema suumi jaoks) |
| `Super + Ctrl + Alt + Z` | Suumi ekraanilt täielikult välja |
| `Super + /` | Liigu monitori skaleerimisvalikute seas edasi |
| `Super + Alt + /` | Liigu monitori skaleerimisvalikute seas tagasi |
| `Alt + Tab` | Liigu aktiivse tööruumi akende vahel edasi |
| `Alt + Shift + Tab` | Liigu aktiivse tööruumi akende vahel tagasi |
| `Ctrl + Alt + Tab`| Liiguta fookust monitoride vahel edasi |
| `Ctrl + Alt + Shift + Tab`| Liiguta fookust monitoride vahel tagasi |

Suuruse muutmise otseteed kasutavad füüsilisi klahve `code:20` ja `code:21` (XKB `<AE11>` ja `<AE12>`), olenemata klaviatuurile trükitud märkidest. USA klaviatuuridel on need klahvid `-` ja `=`; jaapani (JIS) klaviatuuridel on need `-` ja `^`; hispaania klaviatuuridel on need `'` ja `¡`. JIS-il on `Super + ^` sama mis `Super + Equal`, samas kui `Super + Shift + -` (mis tipib `=`) on `Super + Shift + Minus`.

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
| `Super + Ctrl + 1-9`           | Lülita ribapaneel asendi järgi ümber    |
| `Super + Ctrl + S` | Jagamismenüü (LocalSendi kaudu) |
| `Super + Ctrl + C` | Jäädvustamise juhtelemendid (ekraanipilt/-salvestus/valija) |
| `Super + Ctrl + O` | Lülita menüü ümber |
| `Super + Ctrl + H` | Riistvara menüü |
| `Super + Ctrl + E` | Emoji valija |
| `Super + Ctrl + .` | Transkodeeri meediat |
| `Super + Shift + Ctrl + A` | Vali AI agent |

## Kohandused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekraani maksimaalne heledus |
| `Shift + Brightness Down` | Ekraani minimaalne heledus |
| `Alt + Brightness Up/Down` | Täpsed 1% heleduse muudatused |
| `Alt + Volume Up/Down` | Täpsed 1% helitugevuse muudatused |
| `Keyboard Brightness Up/Down` | Klaviatuuri taustvalgus heledamaks/tumedamaks |
| `Keyboard Backlight` | Liigu läbi klaviatuuri taustvalguse tasemete |
| `Alt + Play` | Järgmine lugu |
| `Alt + Shift + Play` | Eelmine lugu |

## Rakenduste käivitamine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmuxi terminal |
| `Super + Ctrl + Return` | Herdr (agentide haldur) |
| `Super + Shift + Return`           | Brauser    |
| `Super + Shift + Alt + B`           | Brauser (privaatne/inkognito)    |
| `Super + Shift + F`           | Failihaldur    |
| `Super + Shift + Alt + F`           | Failihaldur terminali cwd-s    |
| `Super + Shift + M`           | Muusika (Spotify)    |
| `Super + Shift + Alt + M`           | Muusika (cliamp)    |
| `Super + Shift + /`           | Paroolihaldur (1password)    |
| `Super + Shift + Q`           | Kalkulaator (Omacalc)    |
| `Super + Shift + T`           | Aktiivsus (btop)    |
| `Super + Shift + N`           | Redaktor (Neovim)  |
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
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Muuda/lisa seoseid failis `~/.config/hypr/bindings.lua`.

## Universaalne lõikelaud

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + A`           | Vali kõik rakendustes, mis toetavad klahve `Ctrl + A`    |
| `Super + C`           | Kopeeri    |
| `Super + X`           | Lõika (mitte terminalis)    |
| `Super + V`           | Kleebi    |
| `Super + Ctrl + V`           | Lõikelaua haldur    |

Tavaliselt vajad Linuxis terminalis kopeerimiseks ja kleepimiseks klahve `Ctrl + Shift + C/V` ja kõikjal mujal klahve `Ctrl + C/V`. Need Omarchy ühendatud lõikelaua kiirklahvid töötavad kõikjal.

## Jäädvustamine

| Kiirklahv              | Funktsioon                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekraanipilt                      |
| `Super + Ctrl + Alt + C`            | Ekraanipilt (sama võte klaviatuuridele, millel puudub Print Screen-klahv) |
| `Super + Ctrl + C` | Jäädvustamise menüü |
| `Alt + Print Screen`            | Ekraanisalvestus                     |
| `Super + Print Screen` | Värvivalija |
| `Super + Ctrl + Print Screen` | Teksti eraldamine lõikelauale |
| `Super + Alt + [` | Tee veebikaamera ülekate salvestamise ajal väiksemaks |
| `Super + Alt + ]` | Tee veebikaamera ülekate salvestamise ajal suuremaks |
| `Alt + Shift + L` | Kopeeri praegune URL veebirakendusest või brauserist |
| `Alt + Shift + D` | Laadi praegusel lehel olev video alla kausta `~/Videos` |
| `Alt + Space` | Alusta/peata dikteerimine (nõuab _Setup > Defaults > Dictation_) |
| `Right Alt` | Hoia dikteerimiseks (nõuab _Setup > Defaults > Dictation_) |

Ekraanisalvestuste puhul küsib kiirklahv esmalt, millist heli soovid, seejärel alustab salvestamist. Peatamiseks vajuta seda uuesti. Üksikasju vaata jaotisest [ekraanipildid ja salvestamine](12-screenshots-recording.md).

Kõik jäädvustamisvalikud on saadaval ka Omarchy menüü jaotises _Trigger > Capture_ (`Super + Space`).

## Teavitused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + ,` | Tegutse viimase teavituse põhjal: ava see või vajuta selle ainsat nuppu, vali selle valikute seast või eira seda, kui sellel valikuid pole  |
| `Super + Shift + ,` | Eira kõiki teavitusi |
| `Super + Ctrl + ,` | Juhi teavitusi klaviatuuriga  |
| `Super + Alt + ,` | Eira viimast teavitust  |
| `Super + Shift + Alt + ,` | Ava teavituste ajalugu  |
| `Super + Ctrl + Alt + ,` | Lülita teavituste vaigistamine ümber  |

## Stiil

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vali uus teema (ka `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vali teema taust (ka `Super + Ctrl + Space`) |
| `Super + Backspace` | Lülita akna läbipaistvus ümber |
| `Super + Ctrl + Backspace` | Lülita ühe akna ruudukujuline kuvasuhe ümber |

Täiendavad taustapildid asuvad kaustas `~/.config/omarchy/backgrounds/<theme name>`. Saadaval ka Omarchy menüü jaotise _Install > Style > Background_ kaudu.

Kõik stiilivalikud on saadaval ka Omarchy menüü jaotises _Style_ (`Super + Space`).

## Lülitid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Lülita jõudeolekul lukustamine ümber |
| `Super + Ctrl + Delete` | Lülita sülearvuti ekraan sisse/välja |
| `Super + Ctrl + Alt + Delete` | Lülita sülearvuti ekraani peegeldamine ümber |
| `Super + Shift + Space` | Lülita ülemine riba ümber  |
| `Shift + Mute` | Lülitu järgmisele heliväljundile |
| `Shift + Play` | Lülitu järgmisele meediaallikale |
| `Super + Shift + Backspace` | Lülita aknavahed ümber |
| `Super + Ctrl + Alt + F` | Lülita täisekraani töölaud ümber (ülemine riba + aknavahed) |

## Meeldetuletused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Sea meeldetuletus  |
| `Super + Ctrl + Alt + R` | Vaata kõiki meeldetuletusi  |
| `Super + Ctrl + Shift + R` | Kustuta kõik meeldetuletused  |

## Teated

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Näita kellaaega teatisena  |
| `Super + Ctrl + Alt + B` | Näita akut teatisena  |
| `Super + Ctrl + Alt + W` | Lülita ilm teatisena ümber  |

## Tmux

Prefiksklahv on `Ctrl + Space` (toimib ka `Ctrl + B`). Neid seoseid saad muuta failis `~/.config/tmux/tmux.conf`.

### Paanid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + v` | Jaga paan kõrvale (vertikaalselt) |
| `Prefix + h` | Jaga paan alla (horisontaalselt) |
| `Prefix + x` | Sulge paan |
| `Prefix + z` | Lülita paani suum ümber (täisekraan) |
| `Alt + Enter` | Jaga paan alla (prefiksita) |
| `Alt + Shift + Enter` | Jaga paan kõrvale (prefiksita) |
| `Alt + Escape` | Sulge paan (prefiksita) |
| `Ctrl + Alt + Arrows` | Liigu paanide vahel |
| `Ctrl + Alt + Shift + Arrows` | Muuda paanide suurust |

### Aknad

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + c` | Uus aken |
| `Prefix + k` | Sulge aken |
| `Prefix + r` | Nimeta aken ümber |
| `Alt + 1-9` | Mine kindlale aknale |
| `Alt + Arrow Left/Right` | Liigu akende vahel |
| `Alt + Shift + Arrow Left/Right` | Teisalda akent vasakule/paremale |

### Seansid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + C` | Uus seanss |
| `Prefix + K` | Sulge seanss |
| `Prefix + R` | Nimeta seanss ümber |
| `Prefix + N` | Järgmine seanss |
| `Prefix + P` | Eelmine seanss |
| `Alt + Arrow Up/Down` | Liigu seansside vahel |
| `Prefix + s` | Seansside loend |
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
| `Prefix + ?` | Näita Tmuxi klahvikombinatsioone |
| `Prefix + :` | Käsuviip |

### Tmuxi paigutusfunktsioonid

Neid funktsioone tuleb käivitada Tmuxi seansi sees.

| Käsk | Funktsioon |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Loo arenduspaigutus redaktori, AI ja terminaliga |
| `tdlm <ai> [<second_ai>]` | Loo arenduspaigutus iga alamkataloogi kohta |
| `tsl <count> <command>` | Loo mitme paaniga swarm-paigutus |

## Ghostty terminal

Ghostty terminal installitakse Omarchy menüü jaotise _Install > Terminal_ kaudu.

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Uus jaotus alla |
| `Ctrl + Shift + O` | Uus jaotus kõrvale |
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
| `Ctrl + L`            | Mine asukohta                     |
| `Space`               | Faili eelvaade (nooled navigeerivad) |
| `Alt + Up`       | Mine ülemkausta        |

## Neovim (koos lazyvimiga)

### Navigeerimine

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Näita käsuvalikuid            |
| `Space Space`              | Ava fail häguotsingu kaudu      |
| `Space E`                  | Lülita külgriba ümber                  |
| `Space G G`                | Näita giti juhtelemente               |
| `Space S G`                | Otsi faili sisust             |
| `Ctrl + W W`               | Hüppa külgriba ja redaktori vahel |
| `Ctrl + Left/right arrow`  | Muuda külgriba suurust          |
| `Shift + H`                      | Mine vasakule failivahekaardile             |
| `Shift + L`                      | Mine paremale failivahekaardile            |
| `Space B D`                | Sulge failivahekaart                  |

### Külgribal olles

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `A`                        | Lisa uus fail ülemkataloogi      |
| `Shift + A`                | Lisa uus alamkataloog ülemkataloogi    |
| `D`                        | Kustuta esiletõstetud fail/kataloog     |
| `M`                        | Teisalda esiletõstetud fail/kataloog       |
| `R`                        | Nimeta esiletõstetud fail/kataloog ümber     |
| `?`                        | Näita kõigi käskude abi      |

[Vaata kõiki LazyVimi konfigureeritud Neovimi kiirklahve](https://www.lazyvim.org/keymaps).

## Kiired emojid

Saad kasutada klahve `Super + Ctrl + E`, et näidata täielikku emoji valijat, mis paneb valiku lõikelauale, või saad kasutada neid kiire juurdepääsu valikuid.

| Kiirklahv       | EM | Vihje       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | naeratus      |
| `Shift + CapsLock M C` | 😂 | nutt        |
| `Shift + CapsLock M L` | 😍 | armastus       |
| `Shift + CapsLock M V` | ✌️ | võit    |
| `Shift + CapsLock M H` | ❤️ | süda      |
| `Shift + CapsLock M Y` | 👍 | jah        |
| `Shift + CapsLock M N` | 👎 | ei         |
| `Shift + CapsLock M F` | 🖕 | kurat       |
| `Shift + CapsLock M W` | 🤞 | soov       |
| `Shift + CapsLock M R` | 🤘 | rokk       |
| `Shift + CapsLock M K` | 😘 | suudlus       |
| `Shift + CapsLock M E` | 🙄 | silmade pööritamine    |
| `Shift + CapsLock M I` | 😉 | silmapilgutus       |
| `Shift + CapsLock M P` | 🙏 | palve |
| `Shift + CapsLock M D` | 🤤 | ila      |
| `Shift + CapsLock M M` | 💰 | raha      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | terviseks      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | tervitus |
| `Shift + CapsLock M A` |💪 | käsivars |
| `Shift + CapsLock M B` |🤯 | plahvatus |

## Kiired täiendused

| Kiirklahv       | Täiendus       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (pikk kriips)   |
| `Shift + CapsLock Space N` | Sinu nimi (nii nagu seadistamisel sisestatud)  |
| `Shift + CapsLock Space E` | Sinu e-post (nii nagu seadistamisel sisestatud)  |

Saad ise rohkem lisada, muutes faili `~/.XCompose`, seejärel käivitades terminalis käsu `omarchy-restart-xcompose`, et muudatused kasutusele võetaks.
