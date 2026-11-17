# Kiirklahvid

Näed kõiki peamisi klahvikombinatsioone klahvidega `Super + K` (Tmuxi seosed klahvidega `Super + Alt + K` ja Herdr seosed klahvidega `Super + Ctrl + K`).

## Kuidas kiirklahvid on korraldatud

Iga kiirklahv asub tasandil, mille määravad selle modifikaatorid, ja igal tasandil on üks ülesanne. Just see hoiab kiirklahvid omavahel segamini minemast ja tähendab, et tavaliselt oskad arvata, kus miski asub.

| Tasand | Mis seal elab | Näited |
| --- | --- | --- |
| `Super + key` | Süsteem: aknad, tööruumid, paigutused ja põhimenüüd | `Super + Space` Omarchy menüü, `Super + W` sulge aken, `Super + F` täisekraan |
| `Super + Shift + key` | Rakendused | `Super + Shift + B` brauser, `Super + Shift + E` e-post, `Super + Shift + N` redaktor |
| `Super + Ctrl + key` | Paneelid ja süsteemimenüüd | `Super + Ctrl + A` heli, `Super + Ctrl + N` võrk, `Super + Ctrl + C` jäädvustamismenüü |
| `Super + Ctrl + Alt + key` | Kiirtoimingud ja teated | `Super + Ctrl + Alt + T` näita kellaaega, `Super + Ctrl + Alt + B` aku, `Super + Ctrl + Alt + C` ekraanipilt |

`Alt` lisamine kiirklahvile annab sulle sama asja variandi, mitte kunagi millegi seosetu:

- `Super + Shift + B` avab brauseri; `Super + Shift + Alt + B` avab privaatse akna
- `Super + Shift + E` avab e-posti; `Super + Shift + Alt + E` alustab uut e-kirja
- `Super + F` läheb täisekraanile; `Super + Alt + F` läheb täislaiusesse
- `Super + Ctrl + C` avab jäädvustamismenüü; `Super + Ctrl + Alt + C` jätab menüü vahele ja teeb ekraanipildi

Kiirklahvi lisamisel:

1. Vali tasand selle järgi, mida see teeb, seejärel vali klahv.
2. Ära nihuta olemasolevat kiirklahvi, et ruumi teha. Leia õigel tasandil vaba klahv.
3. Kasuta `Alt` ainult ilma selleta kiirklahvi variandi jaoks.

Mõned kiirklahvid rikuvad neid reegleid, sest nii on mugav. `Shift` koos noole või `Tab` klahviga liigutab või pöörab suunda ümber, selle asemel et rakendust avada, ning `Print`, meediaklahvid, `Alt + Tab` ja `Ctrl + Alt + Del` töötavad samamoodi nagu igal pool mujal. Need on erandid, mitte mustrid, mida kopeerida.

Kui vaikesäte sulle ei sobi (ütleme, et tahad ekraanipiltide jaoks `Super + Shift + S` nagu Windowsis), seo see ümber failis `~/.config/hypr/bindings.lua`.

## Navigeerimine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menüü (rakendused ja kõik muu)    |
| `Super + Alt + Space` | Rakenduste ruudustik |
| `Super + Escape` | Süsteemimenüü (peatamine, taaskäivitus jne)  |
| `Super + Ctrl + L` | Lukusta arvuti |
| `Super + W` or `Super + Q` | Sulge aken             |
| `Ctrl + Alt + Del` | Sulge kõik aknad |
| `Super + T`               | Lülita akna paanitava/ujuva režiimi vahel             |
| `Super + J` | Lülita akna asendit (horisontaalne/vertikaalne) |
| `Super + O`               | Lülita akna tõstmine kleepuvaks ja ujuvaks |
| `Super + L`               | Käi läbi dwindle-, kerimis- ja ujuv paigutus |
| `Super + Alt + L`         | Käi paigutused läbi vastupidises järjekorras |
| `Super + P`               | Lülita pseudoakna stiili (loomulik vs venitatud) |
| `Super + F`                 | Mine täisekraanile              |
| `Super + Alt + F`                 | Mine täislaiusesse              |
| `Super + Ctrl + F`                 | Mine akna sees täisekraanile              |
| `Super + 1/2/3/4`         | Hüppa fokuseeritud monitoril kindlale tööruumile |
| `Super + Tab` | Hüppa fokuseeritud monitoril järgmisele tööruumile |
| `Super + Shift + Tab` | Hüppa fokuseeritud monitoril eelmisele tööruumile |
| `Super + Ctrl + Tab` | Hüppa fokuseeritud monitoril varasemale tööruumile |
| `Super + Shift + 1/2/3/4` | Teisalda aken fokuseeritud monitori tööruumile |
| `Super + Shift + Alt + 1/2/3/4` | Teisalda aken fokuseeritud monitori tööruumile ilma kaasa minemata |
| `Super + S` | Lülita kogu scratchpad |
| `Super + Alt + S` | Teisalda aken kogu scratchpad'i |
| `Super + Grave` | Lülita Quake'i konsool |
| `Super + Shift + Grave` | Teisalda aken Quake'i konsooli |
| `Super + Shift + Ctrl + Arrows` | Teisalda aken selles suunas olevale monitorile |
| `Super + Shift + Alt + Arrows` | Teisalda tööruum selles suunas olevale monitorile |
| `Super + Arrow`  | Nihuta fookus noole suunas olevale aknale, ekraani serval ületades selle poole monitori |
| `Super + Shift + Arrow`  | Vaheta aken noole suunas oleva teisega, sealhulgas selle poole monitoril olevaga |
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
| `Super + Scroll Wheel` | Keri fokuseeritud monitori tööruumide vahel |
| `Super + G`               | Lülita akende rühmitamist      |
| `Super + Alt + G`               | Teisalda aken rühmitusest välja      |
| `Super + Alt + Tab`               | Käi rühmituse akende vahel ringi      |
| `Super + Alt + Shift + Tab`               | Käi rühmituse akende vahel tagurpidi ringi      |
| `Super + Alt + Scroll Wheel` | Keri rühmituse akende vahel |
| `Super + Alt + 1/2/3/4/5`               | Hüppa rühmituses kindlale aknale      |
| `Super + Alt + Arrow`  | Teisalda aken noole suunas rühmitusse, sealhulgas selle poole monitoril oleva puhul |
| `Super + Ctrl + Left/Right`  | Liigu paanitava rühma akende vahel |
| `Super + Ctrl + Z` | Suumi ekraani sisse (korda suurema suumi jaoks) |
| `Super + Ctrl + Alt + Z` | Suumi ekraanilt täielikult välja |
| `Super + /` | Astu monitori skaleerimisvalikutes edasi |
| `Super + Alt + /` | Astu monitori skaleerimisvalikutes tagasi |
| `Alt + Tab` | Käi aktiivse tööruumi akende vahel edasi ringi |
| `Alt + Shift + Tab` | Käi aktiivse tööruumi akende vahel tagurpidi ringi |
| `Ctrl + Alt + Tab`| Käi monitoride fookuse vahel edasi ringi |
| `Ctrl + Alt + Shift + Tab`| Käi monitoride fookuse vahel tagurpidi ringi |

Suuruse muutmise otseteed kasutavad füüsilisi klahve `code:20` ja `code:21` (XKB `<AE11>` ja `<AE12>`), olenemata klaviatuurile trükitud märkidest. USA klaviatuuridel on need klahvid `-` ja `=`; Jaapani (JIS) klaviatuuridel on need `-` ja `^`; Hispaania klaviatuuridel on need `'` ja `¡`. JIS-il on `Super + ^` sama mis `Super + Equal`, samas kui `Super + Shift + -` (mis trükib `=`) on `Super + Shift + Minus`.

## Süsteemi juhtimine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Helipaneel    |
| `Super + Ctrl + B`           | Bluetoothi paneel    |
| `Super + Ctrl + N`           | Wi-Fi/võrgupaneel    |
| `Super + Ctrl + D`           | Ekraanipaneel    |
| `Super + Ctrl + P`           | Toitepaneel    |
| `Super + Ctrl + X`           | Agentide paneel    |
| `Super + Ctrl + Alt + D`           | Kalendripaneel    |
| `Super + Ctrl + Alt + E`           | Maailmakella paneel    |
| `Super + Ctrl + 1-9`           | Lülita ribapaneeli asendi järgi    |
| `Super + Ctrl + S` | Jagamismenüü (LocalSendi kaudu) |
| `Super + Ctrl + C` | Jäädvustamise juhtimine (ekraanipilt/salvestus/valija) |
| `Super + Ctrl + O` | Lülitusmenüü |
| `Super + Ctrl + H` | Riistvaramenüü |
| `Super + Ctrl + E` | Emojivalija |
| `Super + Ctrl + .` | Meedia transkoodimine |
| `Super + Shift + Ctrl + A` | Vali AI-agent |

## Kohandused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimaalne ekraani heledus |
| `Shift + Brightness Down` | Minimaalne ekraani heledus |
| `Alt + Brightness Up/Down` | Täpsed 1% heleduse muudatused |
| `Alt + Volume Up/Down` | Täpsed 1% helitugevuse muudatused |
| `Keyboard Brightness Up/Down` | Klaviatuuri taustvalgustus heledamaks/tumedamaks |
| `Keyboard Backlight` | Käi klaviatuuri taustvalgustuse tasemed läbi |
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
| `Super + Shift + T`           | Tegevus (btop)    |
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

Tavaliselt Linuxis vajad terminalis kopeerimiseks ja kleepimiseks `Ctrl + Shift + C/V` ning mujal selleks `Ctrl + C/V`. Need Omarchy ühtsed lõikelaua kiirklahvid töötavad kõikjal.

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
| `Super + Alt + [` | Tee veebikaamera ülekate salvestamise ajal väiksemaks |
| `Super + Alt + ]` | Tee veebikaamera ülekate salvestamise ajal suuremaks |
| `Alt + Shift + L` | Kopeeri praegune URL veebirakendusest või brauserist |
| `Alt + Shift + D` | Laadi praeguse lehe video alla kausta `~/Videos` |
| `Alt + Space` | Alusta/peata dikteerimine (nõuab _Setup > Defaults > Dictation_) |
| `Right Alt` | Hoia dikteerimiseks all (nõuab _Setup > Defaults > Dictation_) |

Ekraanisalvestuste puhul küsib kiirklahv esmalt, millist heli soovid, seejärel alustab salvestamist. Peatamiseks vajuta seda uuesti. Vaata üksikasju jaotisest [ekraanipildid ja salvestamine](12-screenshots-recording.md).

Kõik jäädvustamisvalikud on saadaval ka Omarchy menüü (`Super + Space`) jaotises _Trigger > Capture_.

## Märguanded

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + ,` | Toimi viimase märguandega: ava see või vajuta selle ainsat nuppu, vali selle valikute hulgast või hülga see, kui valikuid pole  |
| `Super + Shift + ,` | Hülga kõik märguanded |
| `Super + Ctrl + ,` | Juhi märguandeid klaviatuuriga  |
| `Super + Alt + ,` | Hülga viimane märguanne  |
| `Super + Shift + Alt + ,` | Ava märguannete ajalugu  |
| `Super + Ctrl + Alt + ,` | Lülita märguannete vaigistamist  |

## Stiil

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vali uus teema (ka `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vali teema taust (ka `Super + Ctrl + Space`) |
| `Super + Backspace` | Lülita akna läbipaistvust |
| `Super + Ctrl + Backspace` | Lülita ühe akna ruudukujulist kuvasuhet |

Täiendavad taustapildid asuvad kaustas `~/.config/omarchy/backgrounds/<theme name>`. Saadaval ka Omarchy menüü jaotise _Install > Style > Background_ kaudu.

Kõik stiilivalikud on saadaval ka Omarchy menüü (`Super + Space`) jaotises _Style_.

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
| `Super + Ctrl + Alt + F` | Lülita täisekraani töölaud (ülemine riba + akende vahed) |

## Meeldetuletused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Määra meeldetuletus  |
| `Super + Ctrl + Alt + R` | Vaata kõiki meeldetuletusi  |
| `Super + Ctrl + Shift + R` | Tühjenda kõik meeldetuletused  |

## Teated

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Näita kellaaega märguandena  |
| `Super + Ctrl + Alt + B` | Näita akut märguandena  |
| `Super + Ctrl + Alt + W` | Lülita ilma märguandena näitamist  |

## Tmux

Prefiksiklahv on `Ctrl + Space` (`Ctrl + B` töötab samuti). Neid seoseid saad muuta failis `~/.config/tmux/tmux.conf`.

### Paanid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + v` | Jaga paan kõrvuti (vertikaalselt) |
| `Prefix + h` | Jaga paan allapoole (horisontaalselt) |
| `Prefix + x` | Sulge paan |
| `Prefix + z` | Lülita paani suumi (täisekraan) |
| `Alt + Enter` | Jaga paan allapoole (ilma prefiksita) |
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
| `Alt + 1-9` | Mine kindlale aknale |
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
| `tdlm <ai> [<second_ai>]` | Loo arenduspaigutus iga alamkataloogi jaoks |
| `tsl <count> <command>` | Loo mitme paaniga parvpaigutus |

## Ghostty terminal

Ghostty terminal installitakse Omarchy menüü jaotise _Install > Terminal_ kaudu.

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Uus jaotus allapoole |
| `Ctrl + Shift + O` | Uus jaotus kõrvuti |
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
| `Ctrl + L`            | Mine asukohateele                     |
| `Space`               | Faili eelvaade (nooled navigeerivad) |
| `Alt + Up`       | Mine üles emakausta        |

## Neovim (koos lazyvimiga)

### Navigeerimine

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Näita käsuvalikuid            |
| `Space Space`              | Ava fail häguotsinguga      |
| `Space E`                  | Lülita külgriba                  |
| `Space G G`                | Näita giti juhtimist               |
| `Space S G`                | Otsi faili sisust             |
| `Ctrl + W W`               | Hüppa külgriba ja redaktori vahel |
| `Ctrl + Left/right arrow`  | Muuda külgriba suurust          |
| `Shift + H`                      | Mine vasakpoolsele failivahekaardile             |
| `Shift + L`                      | Mine parempoolsele failivahekaardile            |
| `Space B D`                | Sulge failivahekaart                  |

### Külgribal olles

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `A`                        | Lisa uus fail emakataloogi      |
| `Shift + A`                | Lisa uus alamkataloog emakataloogi    |
| `D`                        | Kustuta esiletõstetud fail/kataloog     |
| `M`                        | Teisalda esiletõstetud fail/kataloog       |
| `R`                        | Nimeta esiletõstetud fail/kataloog ümber     |
| `?`                        | Näita kõigi käskude abi      |

[Vaata kõiki Neovimi kiirklahve, mille LazyVim on seadistanud](https://www.lazyvim.org/keymaps).

## Kiiremojid

Saad kasutada `Super + Ctrl + E`, et näidata täielikku emojivalijat, mis paneb valiku lõikelauale, või saad kasutada neid kiirjuurdepääsu valikuid.

| Kiirklahv       | EM | Vihje       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | naeratus      |
| `Shift + CapsLock M C` | 😂 | nutt        |
| `Shift + CapsLock M L` | 😍 | armastus       |
| `Shift + CapsLock M V` | ✌️ | võit    |
| `Shift + CapsLock M H` | ❤️ | süda      |
| `Shift + CapsLock M Y` | 👍 | jah        |
| `Shift + CapsLock M N` | 👎 | ei         |
| `Shift + CapsLock M F` | 🖕 | vitt       |
| `Shift + CapsLock M W` | 🤞 | soov       |
| `Shift + CapsLock M R` | 🤘 | rokk       |
| `Shift + CapsLock M K` | 😘 | suudlus       |
| `Shift + CapsLock M E` | 🙄 | silmapööritus    |
| `Shift + CapsLock M I` | 😉 | silmapilgutus       |
| `Shift + CapsLock M P` | 🙏 | palve |
| `Shift + CapsLock M D` | 🤤 | ilastamine      |
| `Shift + CapsLock M M` | 💰 | raha      |
| `Shift + CapsLock M X` | 🎉 | pidu |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | terviseks      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | tervitus |
| `Shift + CapsLock M A` |💪 | käsi |
| `Shift + CapsLock M B` |🤯 | plahvatav |

## Kiirtäiendused

| Kiirklahv       | Täiendus       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (pikk mõttekriips)   |
| `Shift + CapsLock Space N` | Sinu nimi (nagu seadistamisel sisestatud)  |
| `Shift + CapsLock Space E` | Sinu e-post (nagu seadistamisel sisestatud)  |

Saad ise lisa lisada, muutes faili `~/.XCompose`, seejärel käitades terminalis `omarchy-restart-xcompose`, et muudatused rakenduksid.
