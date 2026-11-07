# Kiirklahvid

Kõiki peamisi klahvikombinatsioone näed klahvidega `Super + K` (Tmuxi seosed klahvidega `Super + Alt + K` ja Herdr seosed klahvidega `Super + Ctrl + K`).

## Kuidas kiirklahvid on korraldatud

Iga kiirklahv asub tasandil, mille määravad selle modifikaatorid, ja igal tasandil on üks ülesanne. See hoiab kiirklahvid omavahel segamini minemast ja tähendab, et tavaliselt oskad arvata, kus miski asub.

| Tasand | Mis seal asub | Näited |
| --- | --- | --- |
| `Super + key` | Süsteem: aknad, tööruumid, paigutused ja põhimenüüd | `Super + Space` Omarchy menüü, `Super + W` sulge aken, `Super + F` täisekraan |
| `Super + Shift + key` | Rakendused | `Super + Shift + B` brauser, `Super + Shift + E` e-post, `Super + Shift + N` redaktor |
| `Super + Ctrl + key` | Paneelid ja süsteemimenüüd | `Super + Ctrl + A` heli, `Super + Ctrl + N` võrk, `Super + Ctrl + C` jäädvustamismenüü |
| `Super + Ctrl + Alt + key` | Kiirtoimingud ja teated | `Super + Ctrl + Alt + T` näita kellaaega, `Super + Ctrl + Alt + B` aku, `Super + Ctrl + Alt + C` ekraanipilt |

`Alt` lisamine kiirklahvile annab sulle sama asja variandi, mitte kunagi midagi seosetut:

- `Super + Shift + B` avab brauseri; `Super + Shift + Alt + B` avab privaatse akna
- `Super + Shift + E` avab e-posti; `Super + Shift + Alt + E` alustab uut kirja
- `Super + F` läheb täisekraanile; `Super + Alt + F` läheb täislaiusele
- `Super + Ctrl + C` avab jäädvustamismenüü; `Super + Ctrl + Alt + C` jätab menüü vahele ja teeb ekraanipildi

Kiirklahvi lisamisel:

1. Vali tasand selle järgi, mida see teeb, seejärel vali klahv.
2. Ära nihuta olemasolevat kiirklahvi ruumi tegemiseks. Leia õigel tasandil vaba klahv.
3. Kasuta `Alt` ainult ilma selleta kiirklahvi variandi jaoks.

Mõned kiirklahvid rikuvad neid reegleid, sest nii on mugav. `Shift` koos noole või `Tab` klahviga liigutab või pöörab suunda, selle asemel et rakendust avada, ning `Print`, meediaklahvid, `Alt + Tab` ja `Ctrl + Alt + Del` töötavad nii nagu igal pool mujalgi. Need on erandid, mitte mustrid, mida kopeerida.

Kui vaikeseade sulle ei sobi (näiteks tahad ekraanipiltide jaoks `Super + Shift + S` nagu Windowsis), seo see ümber failis `~/.config/hypr/bindings.lua`.

## Navigeerimine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menüü (rakendused ja kõik muu)    |
| `Super + Alt + Space` | Rakenduste ruudustik |
| `Super + Escape` | Süsteemimenüü (peatamine, taaskäivitus jne)  |
| `Super + Ctrl + L` | Lukusta arvuti |
| `Super + W` or `Super + Q` | Sulge aken             |
| `Ctrl + Alt + Del` | Sulge kõik aknad |
| `Super + T`               | Lülita aken plaaditud/ujuva režiimi vahel             |
| `Super + J` | Lülita akna asendit (horisontaalne/vertikaalne) |
| `Super + O`               | Lülita akna kleepuv ja ujuv olek |
| `Super + L`               | Vaheta järjest dwindle, scrolling ja floating paigutusi |
| `Super + Alt + L`         | Vaheta paigutusi vastupidises järjekorras |
| `Super + P`               | Lülita pseudoakna stiili (loomulik vs venitatud) |
| `Super + F`                 | Mine täisekraanile              |
| `Super + Alt + F`                 | Mine täislaiusele              |
| `Super + Ctrl + F`                 | Mine akna sees täisekraanile              |
| `Super + 1/2/3/4`         | Hüppa fokuseeritud monitoril kindlasse tööruumi |
| `Super + Tab` | Hüppa fokuseeritud monitoril järgmisse tööruumi |
| `Super + Shift + Tab` | Hüppa fokuseeritud monitoril eelmisse tööruumi |
| `Super + Ctrl + Tab` | Hüppa fokuseeritud monitoril varasemasse tööruumi |
| `Super + Shift + 1/2/3/4` | Liiguta aken fokuseeritud monitori tööruumi |
| `Super + Shift + Alt + 1/2/3/4` | Liiguta aken fokuseeritud monitori tööruumi ilma järgnemata |
| `Super + S` | Lülita täisscratchpad |
| `Super + Alt + S` | Liiguta aken täisscratchpadi |
| `Super + Grave` | Lülita Quake konsool |
| `Super + Shift + Grave` | Liiguta aken Quake konsooli |
| `Super + Shift + Ctrl + Arrows` | Liiguta aken selles suunas olevale monitorile |
| `Super + Shift + Alt + Arrows` | Liiguta tööruum selles suunas olevale monitorile |
| `Super + Arrow`  | Liiguta fookus noole suunas olevale aknale, liikudes ekraani serval sellel küljel olevale monitorile |
| `Super + Shift + Arrow`  | Vaheta aken noole suunas oleva aknaga, kaasa arvatud sellel küljel oleval monitoril olev aken |
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
| `Super + Scroll Wheel` | Kerri fokuseeritud monitori tööruumide vahel |
| `Super + G`               | Lülita akna rühmitamist      |
| `Super + Alt + G`               | Liiguta aken rühmitusest välja      |
| `Super + Alt + Tab`               | Vaheta rühmituses akende vahel      |
| `Super + Alt + Shift + Tab`               | Vaheta rühmituses akende vahel tagurpidi      |
| `Super + Alt + Scroll Wheel` | Vaheta rühmituses akende vahel |
| `Super + Alt + 1/2/3/4/5`               | Hüppa rühmituses kindla aknani      |
| `Super + Alt + Arrow`  | Liiguta aken noole suunas rühmitusse, kaasa arvatud sellel küljel oleval monitoril olev aken |
| `Super + Ctrl + Left/Right`  | Liigu plaaditud rühma sees akende vahel |
| `Super + Ctrl + Z` | Suurenda ekraani (korda suurema suumi jaoks) |
| `Super + Ctrl + Alt + Z` | Vähenda ekraani suum täielikult välja |
| `Super + /` | Liigu monitori skaleerimise valikutes edasi |
| `Super + Alt + /` | Liigu monitori skaleerimise valikutes tagasi |
| `Alt + Tab` | Vaheta aktiivsel tööruumil akende vahel edasi |
| `Alt + Shift + Tab` | Vaheta aktiivsel tööruumil akende vahel tagurpidi |
| `Ctrl + Alt + Tab`| Vaheta fookust monitoride vahel edasi |
| `Ctrl + Alt + Shift + Tab`| Vaheta fookust monitoride vahel tagurpidi |

Suuruse muutmise otseteed kasutavad füüsilisi klahve `code:20` ja `code:21` (XKB `<AE11>` ja `<AE12>`), olenemata klaviatuuril trükitud märkidest. USA klaviatuuridel on need klahvid `-` ja `=`; Jaapani (JIS) klaviatuuridel on need `-` ja `^`; Hispaania klaviatuuridel on need `'` ja `¡`. JIS-il on `Super + ^` sama mis `Super + Equal`, samas kui `Super + Shift + -` (mis sisestab `=`) on `Super + Shift + Minus`.

## Süsteemi juhtelemendid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Helipaneel    |
| `Super + Ctrl + B`           | Bluetoothi paneel    |
| `Super + Ctrl + N`           | Wi-Fi/võrgupaneel    |
| `Super + Ctrl + D`           | Ekraanipaneel    |
| `Super + Ctrl + P`           | Toitepaneel    |
| `Super + Ctrl + Alt + D`           | Kalendripaneel    |
| `Super + Ctrl + Alt + E`           | Maailmakella paneel    |
| `Super + Ctrl + 1-9`           | Lülita ribapaneeli asendi järgi    |
| `Super + Ctrl + S` | Jagamismenüü (LocalSendi kaudu) |
| `Super + Ctrl + C` | Jäädvustamise juhtelemendid (ekraanipilt/-salvestus/valija) |
| `Super + Ctrl + O` | Lülita menüüd |
| `Super + Ctrl + H` | Riistvara menüü |
| `Super + Ctrl + E` | Emojide valija |
| `Super + Ctrl + .` | Transkoodi meediat |
| `Super + Shift + Ctrl + A` | Vali AI agent |

## Kohandused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekraani maksimaalne heledus |
| `Shift + Brightness Down` | Ekraani minimaalne heledus |
| `Alt + Brightness Up/Down` | Täpsed 1% heleduse muudatused |
| `Alt + Volume Up/Down` | Täpsed 1% helitugevuse muudatused |
| `Keyboard Brightness Up/Down` | Klaviatuuri taustvalgustus heledamaks/tumedamaks |
| `Keyboard Backlight` | Vaheta klaviatuuri taustvalgustuse tasemeid järjest |
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
| `Super + Shift + Alt + F`           | Failihaldur terminali praeguses töökataloogis    |
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
| `Super + A`           | Vali kõik rakendustes, mis toetavad `Ctrl + A`    |
| `Super + C`           | Kopeeri    |
| `Super + X`           | Lõika (mitte terminalis)    |
| `Super + V`           | Kleebi    |
| `Super + Ctrl + V`           | Lõikelaua haldur    |

Tavaliselt Linuxis on terminalis kopeerimiseks ja kleepimiseks vaja `Ctrl + Shift + C/V` ja kõikjal mujal `Ctrl + C/V`. Need Omarchy ühtsed lõikelaua kiirklahvid töötavad kõikjal.

## Jäädvustamine

| Kiirklahv              | Funktsioon                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekraanipilt                      |
| `Super + Ctrl + Alt + C`            | Ekraanipilt (sama võte klaviatuuridele, millel puudub Print Screen klahv) |
| `Super + Ctrl + C` | Jäädvustamismenüü |
| `Alt + Print Screen`            | Ekraanisalvestus                     |
| `Super + Print Screen` | Värvivalija |
| `Super + Ctrl + Print Screen` | Teksti eraldamine lõikelauale |
| `Super + Alt + [` | Tee veebikaamera ülekate salvestamise ajal väiksemaks |
| `Super + Alt + ]` | Tee veebikaamera ülekate salvestamise ajal suuremaks |
| `Alt + Shift + L` | Kopeeri praegune URL veebirakendusest või Chromiumist |
| `Alt + Shift + D` | Laadi praegusel lehel olev video alla kausta `~/Videos` |
| `Alt + Space` | Alusta/peata dikteerimine (nõuab _Seadistamine > Vaikeseaded > Dikteerimine_) |
| `Right Alt` | Hoia dikteerimiseks all (nõuab _Seadistamine > Vaikeseaded > Dikteerimine_) |

Ekraanisalvestuste korral küsib kiirklahv esmalt, millist heli soovid, seejärel alustab salvestamist. Salvestamise peatamiseks vajuta seda uuesti. Üksikasju vaata jaotisest [ekraanipildid ja salvestamine](12-screenshots-recording.md).

Kõik jäädvustamisvalikud on saadaval ka Omarchy menüüs (`Super + Space`) jaotises _Käivitaja > Jäädvustamine_.

## Teavitused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + ,` | Tegutse uusima teavituse põhjal: ava see või vajuta selle ainsat nuppu, vali selle valikute hulgast või sulge see, kui valikuid ei ole  |
| `Super + Shift + ,` | Sulge kõik teavitused |
| `Super + Ctrl + ,` | Juhi teavitusi klaviatuuriga  |
| `Super + Alt + ,` | Sulge uusim teavitus  |
| `Super + Shift + Alt + ,` | Ava teavituste ajalugu  |
| `Super + Ctrl + Alt + ,` | Lülita teavituste vaigistamist  |

## Stiil

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vali uus teema (ka `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vali teema taust (ka `Super + Ctrl + Space`) |
| `Super + Backspace` | Lülita akna läbipaistvust |
| `Super + Ctrl + Backspace` | Lülita ühe akna ruudukujulist kuvasuhet |

Täiendavad taustapildid asuvad kaustas `~/.config/omarchy/backgrounds/<theme name>`. Saadaval ka Omarchy menüüs jaotises _Installimine > Stiil > Taust_.

Kõik stiilivalikud on saadaval ka Omarchy menüüs (`Super + Space`) jaotises _Stiil_.

## Lülitid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Lülita jõudeolekul lukustamist |
| `Super + Ctrl + Delete` | Lülita sülearvuti ekraan sisse/välja |
| `Super + Ctrl + Alt + Delete` | Lülita sülearvuti ekraani peegeldamist |
| `Super + Shift + Space` | Lülita ülemist riba  |
| `Shift + Mute` | Lülitu järgmisele heliväljundile |
| `Shift + Play` | Lülitu järgmisele meediaallikale |
| `Super + Shift + Backspace` | Lülita akende vahesid |
| `Super + Ctrl + Alt + F` | Lülita täisekraani töölauda (ülemine riba + akende vahed) |

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
| `Super + Ctrl + Alt + W` | Lülita ilma teavitusena kuvamist  |

## Tmux

Eesliiteklahv on `Ctrl + Space` (töötab ka `Ctrl + B`). Neid seoseid saad muuta failis `~/.config/tmux/tmux.conf`.

### Paanid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + v` | Jaga paan kõrvuti (vertikaalselt) |
| `Prefix + h` | Jaga paan alla (horisontaalselt) |
| `Prefix + x` | Tapa paan |
| `Prefix + z` | Lülita paani suumi (täisekraan) |
| `Alt + Enter` | Jaga paan alla (ilma eesliiteta) |
| `Alt + Shift + Enter` | Jaga paan kõrvuti (ilma eesliiteta) |
| `Alt + Escape` | Tapa paan (ilma eesliiteta) |
| `Ctrl + Alt + Arrows` | Liigu paanide vahel |
| `Ctrl + Alt + Shift + Arrows` | Muuda paanide suurust |

### Aknad

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + c` | Uus aken |
| `Prefix + k` | Tapa aken |
| `Prefix + r` | Nimeta aken ümber |
| `Alt + 1-9` | Mine kindla aknani |
| `Alt + Arrow Left/Right` | Liigu akende vahel |
| `Alt + Shift + Arrow Left/Right` | Liiguta akent vasakule/paremale |

### Seansid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + C` | Uus seanss |
| `Prefix + K` | Tapa seanss |
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
| `Prefix + q` | Laadi seadistus uuesti |
| `Prefix + ?` | Näita Tmuxi klahviseoseid |
| `Prefix + :` | Käsuviip |

### Tmuxi paigutusfunktsioonid

Neid funktsioone tuleb käivitada Tmuxi seansi sees.

| Käsk | Funktsioon |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Loo arenduspaigutus redaktori, AI ja terminaliga |
| `tdlm <ai> [<second_ai>]` | Loo arenduspaigutus iga alamkataloogi kohta |
| `tsl <count> <command>` | Loo mitme paaniga parvepaigutus |

## Ghostty terminal

Ghostty terminal installitakse Omarchy menüü kaudu jaotises _Installimine > Terminal_.

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Uus jaotus all |
| `Ctrl + Shift + O` | Uus jaotus kõrval |
| `Ctrl + Alt + Arrows` | Liigu jaotuste vahel |
| `Super + Ctrl + Shift + Arrows` | Muuda jaotuse suurust 10 rea võrra |
| `Super + Ctrl + Shift + Alt + Arrows` | Muuda jaotuse suurust 100 rea võrra |
| `Ctrl + Shift + T` | Uus vahekaart  |
| `Ctrl + Shift + Arrows` | Liigu vahekaartide vahel |
| `Alt + Numbers` | Mine kindla vahekaardini |
| `Shift + Pg Up/Down` | Kerri ajalugu |
| `Ctrl + Left mouse` | Ava link brauseris |

## Failihaldur

| Kiirklahv              | Funktsioon                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Mine teekonnale                     |
| `Space`               | Faili eelvaade (nooled navigeerivad) |
| `Alt + Up`       | Mine üles ülemkausta        |

## Neovim (koos lazyvimiga)

### Navigeerimine

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Näita käsuvalikuid            |
| `Space Space`              | Ava fail häguotsinguga      |
| `Space E`                  | Lülita külgriba                  |
| `Space G G`                | Näita giti juhtelemente               |
| `Space S G`                | Otsi faili sisust             |
| `Ctrl + W W`               | Hüppa külgriba ja redaktori vahel |
| `Ctrl + Left/right arrow`  | Muuda külgriba suurust          |
| `Shift + H`                      | Mine vasakpoolsele failivahekaardile             |
| `Shift + L`                      | Mine parempoolsele failivahekaardile            |
| `Space B D`                | Sulge failivahekaart                  |

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

## Kiiremojid

Saad kasutada klahve `Super + Ctrl + E`, et näidata täielikku emojide valijat, mis paneb valiku lõikelauale, või saad kasutada neid kiire juurdepääsu valikuid.

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
| `Shift + CapsLock M K` | 😘 | musi       |
| `Shift + CapsLock M E` | 🙄 | silmade pööritamine    |
| `Shift + CapsLock M I` | 😉 | silmapilgutus       |
| `Shift + CapsLock M P` | 🙏 | palveta |
| `Shift + CapsLock M D` | 🤤 | ila      |
| `Shift + CapsLock M M` | 💰 | raha      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | terviseks      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | tervitus |
| `Shift + CapsLock M A` |💪 | käsivars |
| `Shift + CapsLock M B` |🤯 | plahvatamas |

## Kiirtäiendused

| Kiirklahv       | Täiendus       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (pikk kriips)   |
| `Shift + CapsLock Space N` | Sinu nimi (nagu seadistamisel sisestatud)  |
| `Shift + CapsLock Space E` | Sinu e-post (nagu seadistamisel sisestatud)  |

Saad enda omi lisada, muutes faili `~/.XCompose`, seejärel käivitades terminalis käsu `omarchy-restart-xcompose`, et muudatused rakenduksid.
