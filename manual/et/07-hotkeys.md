# Kiirklahvid

Kõiki peamisi klaviatuuri seoseid saad vaadata kombinatsiooniga `Super + K` (Tmuxi seoseid `Super + Alt + K` ja Herdri seoseid `Super + Ctrl + K`).

## Kuidas kiirklahvid on paigutatud

Iga kiirklahv asub ühel tasandil, mille määravad selle modifikaatorid, ja igal tasandil on üks ülesanne. See hoiabki kiirklahvid omavahel segamini minemast ja tähendab, et tavaliselt oskad arvata, kus miski asub.

| Tasand | Mis seal asub | Näited |
| --- | --- | --- |
| `Super + key` | Süsteem: aknad, tööruumid, paigutused ja põhimenüüd | `Super + Space` Omarchy menüü, `Super + W` sulge aken, `Super + F` täisekraan |
| `Super + Shift + key` | Rakendused | `Super + Shift + B` brauser, `Super + Shift + E` e-post, `Super + Shift + N` redaktor |
| `Super + Ctrl + key` | Paneelid ja süsteemimenüüd | `Super + Ctrl + A` heli, `Super + Ctrl + N` võrk, `Super + Ctrl + C` jäädvustamismenüü |
| `Super + Ctrl + Alt + key` | Kiirtoimingud ja märguanded | `Super + Ctrl + Alt + T` näita kellaaega, `Super + Ctrl + Alt + B` aku, `Super + Ctrl + Alt + C` ekraanipilt |

`Alt` lisamine kiirklahvile annab sulle sama asja variandi, mitte kunagi midagi seosetut:

- `Super + Shift + B` avab brauseri; `Super + Shift + Alt + B` avab privaatakna
- `Super + Shift + E` avab e-posti; `Super + Shift + Alt + E` alustab uut kirja
- `Super + F` läheb täisekraanile; `Super + Alt + F` läheb täislaiusesse
- `Super + Ctrl + C` avab jäädvustamismenüü; `Super + Ctrl + Alt + C` jätab menüü vahele ja teeb ekraanipildi

Kiirklahvi lisamisel:

1. Vali tasand selle järgi, mida see teeb, seejärel vali klahv.
2. Ära nihuta olemasolevat kiirklahvi, et ruumi teha. Leia õigel tasandil vaba klahv.
3. Kasuta `Alt` ainult ilma selleta kiirklahvi variandi jaoks.

Mõned kiirklahvid rikuvad neid reegleid, sest nii on mugav. `Shift` koos noole või `Tab` klahviga teisaldab või pöörab suunda, selle asemel et rakendust avada, ning `Print`, meediaklahvid, `Alt + Tab` ja `Ctrl + Alt + Del` töötavad nii, nagu nad töötavad kõikjal mujal. Need on erandid, mitte mustrid, mida kopeerida.

Kui vaikesäte sulle ei sobi (näiteks soovid ekraanipiltide jaoks `Super + Shift + S`, nagu Windowsis), seo see ümber failis `~/.config/hypr/bindings.lua`.

## Navigeerimine

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy menüü (rakendused ja kõik muu) |
| `Super + Alt + Space` | Rakenduste ruudustik |
| `Super + Escape` | Süsteemimenüü (peatamine, taaskäivitamine jne) |
| `Super + Ctrl + L` | Lukusta arvuti |
| `Super + W` or `Super + Q` | Sulge aken |
| `Ctrl + Alt + Del` | Sulge kõik aknad |
| `Super + K` | Näita kõiki kiirklahve |
| `Super + Alt + K` | Näita tmuxi kiirklahve |
| `Super + Ctrl + K` | Näita herdri kiirklahve |
| `Super + M` | Minimeeri aken dokki |
| `Super + T` | Lülita aken plaaditud/ujuva režiimi vahel |
| `Super + J` | Lülita akna asendit (horisontaalne/vertikaalne) |
| `Super + O` | Lülita akna kleepuvaks ja ujuvaks hüppamist |
| `Super + L` | Liigu läbi dwindle-, scrolling- ja floating-paigutuste |
| `Super + Alt + L` | Liigu läbi paigutuste vastupidises suunas |
| `Super + P` | Lülita pseudoakna stiili (loomulik või venitatud) |
| `Super + F` | Mine täisekraanile |
| `Super + Alt + F` | Mine täislaiusesse |
| `Super + Ctrl + F` | Mine täisekraanile akna sees |
| `Super + 1…9/0` | Hüppa kindlasse tööruumi (0 on 10) fokuseeritud monitoril |
| `Super + Tab` | Hüppa järgmisse tööruumi fokuseeritud monitoril |
| `Super + Shift + Tab` | Hüppa eelmisse tööruumi fokuseeritud monitoril |
| `Super + Ctrl + Tab` | Hüppa varasemasse tööruumi fokuseeritud monitoril |
| `Super + Shift + 1…9/0` | Teisalda aken tööruumi fokuseeritud monitoril |
| `Super + Shift + Alt + 1…9/0` | Teisalda aken tööruumi fokuseeritud monitoril, ilma kaasa minemata |
| `Super + S` | Lülita täielikku scratchpad'i |
| `Super + Alt + S` | Teisalda aken täielikku scratchpad'i |
| `Super + Grave` | Lülita Quake konsooli |
| `Super + Shift + Grave` | Teisalda aken Quake konsooli |
| `Super + Shift + Ctrl + Arrows` | Teisalda aken selles suunas asuvale monitorile |
| `Super + Shift + Alt + Arrows` | Teisalda tööruum selles suunas asuvale monitorile |
| `Super + Arrow` | Liiguta fookus noole suunas asuvale aknale, ekraani serval ületades selle poole monitori |
| `Super + Shift + Arrow` | Vaheta aken noole suunas asuva teisega, kaasa arvatud selle poole monitoril asuvaga |
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
| `Super + G` | Lülita akende grupeerimist |
| `Super + Alt + G` | Teisalda aken grupeerimisest välja |
| `Super + Alt + Tab` | Liigu grupeeringu akende vahel |
| `Super + Alt + Shift + Tab` | Liigu grupeeringu akende vahel tagurpidi |
| `Super + Alt + Scroll Wheel` | Liigu grupeeringu akende vahel |
| `Super + Alt + 1/2/3/4/5` | Hüppa kindla akna juurde grupeeringus |
| `Super + Alt + Arrow` | Teisalda aken grupeeringusse noole suunas, kaasa arvatud selle poole monitoril asuv |
| `Super + Ctrl + Left/Right` | Liigu plaaditud grupi sees akende vahel |
| `Super + Ctrl + Z` | Suumi ekraanil sisse (suurema suumi jaoks korda) |
| `Super + Ctrl + Alt + Z` | Suumi ekraanilt täielikult välja |
| `Super + /` | Liigu edasi läbi monitori skaleerimisvalikute |
| `Super + Alt + /` | Liigu tagasi läbi monitori skaleerimisvalikute |
| `Alt + Tab` | Liigu edasi läbi aktiivse tööruumi akende |
| `Alt + Shift + Tab` | Liigu tagasi läbi aktiivse tööruumi akende |
| `Ctrl + Alt + Tab` | Liiguta fookust edasi läbi monitoride |
| `Ctrl + Alt + Shift + Tab` | Liiguta fookust tagasi läbi monitoride |
| `Super + I` | Vaheta sisestuskeelt (kui on rohkem kui üks paigutus või sisestusmeetod) |
| `Super + Shift + I` | Vaheta sisestuskeelt tagasi |

Puuteplaadil vahetavad kolme ja nelja sõrme pühked tööruume, teisaldavad aknaid ning avavad menüü ja Quake konsooli; žeste vaata jaotisest [klaviatuur, hiir ja puuteplaat](34-keyboard-mouse-trackpad.md).

Suuruse muutmise otseteed kasutavad füüsilisi klahve `code:20` ja `code:21` (XKB `<AE11>` ja `<AE12>`), sõltumata klaviatuuril trükitud märkidest. USA klaviatuuridel on need klahvid `-` ja `=`; Jaapani (JIS) klaviatuuridel on need `-` ja `^`; Hispaania klaviatuuridel on need `'` ja `¡`. JIS-il on `Super + ^` sama mis `Super + Equal`, samas kui `Super + Shift + -` (mis trükib `=`) on `Super + Shift + Minus`.

## Süsteemi juhtimine

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Helipaneel |
| `Super + Ctrl + B` | Bluetoothi paneel |
| `Super + Ctrl + N` | Wi-Fi/võrgupaneel |
| `Super + Ctrl + D` | Ekraanipaneel |
| `Super + Ctrl + P` | Toitepaneel |
| `Super + Ctrl + X` | Agentide paneel |
| `Super + Ctrl + Shift + X` | Kohalike mudelite paneel |
| `Super + Ctrl + Alt + D` | Kalendripaneel |
| `Super + Ctrl + Alt + E` | Maailmakella paneel |
| `Super + Ctrl + 1-9` | Lülita ribapaneeli asendi järgi |
| `Super + Ctrl + S` | Jagamismenüü (LocalSend kaudu) |
| `Super + Ctrl + C` | Jäädvustamise juhtimine (ekraanipilt/-salvestus/valija) |
| `Super + Ctrl + O` | Lülita menüüd |
| `Super + Ctrl + H` | Riistvaramenüü |
| `Super + Ctrl + E` | Emoji valija |
| `Super + Ctrl + .` | Transkoodi meediat |
| `Super + Shift + Ctrl + A` | Vali AI agent |
| `Power` key | Süsteemimenüü |
| `Super + Shift + Copilot` key | Omarchy menüü |

## Kohandused

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekraani maksimaalne heledus |
| `Shift + Brightness Down` | Ekraani minimaalne heledus |
| `Alt + Brightness Up/Down` | Täpsed 1% heleduse muudatused |
| `Alt + Volume Up/Down` | Täpsed 1% helitugevuse muudatused |
| `Keyboard Brightness Up/Down` | Klaviatuuri taustvalgustus heledamaks/tumedamaks |
| `Keyboard Backlight` | Sirvi klaviatuuri taustvalgustuse tasemeid |
| `Ctrl + Brightness Up/Down` | Klaviatuuri taustvalgustus heledamaks/tumedamaks klaviatuuridel, millel pole oma klahve |
| `Mic Mute` | Vaigista mikrofon |
| `Shift + Mute` | Vaheta heliväljundit |
| `Touchpad Toggle` | Lülita puuteplaat sisse või välja |
| `Display` key | Sirvi tööruumi paigutust |
| `Alt + Play` | Järgmine lugu |
| `Alt + Shift + Play` | Eelmine lugu |

## Rakenduste käivitamine

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmuxi terminal |
| `Super + Ctrl + Return` | Herdr (agentide haldur) |
| `Super + Shift + Return` or `Super + Shift + B` | Brauser |
| `Super + Shift + Alt + B` | Brauser (privaatne/inkognito) |
| `Super + Shift + F` | Failihaldur |
| `Super + Shift + Alt + F` | Failihaldur terminali cwd-s |
| `Super + Shift + M` | Muusika (Spotify) |
| `Super + Shift + Alt + M` | Muusika (cliamp) |
| `Super + Shift + /` | Paroolihaldur (1password) |
| `Super + Shift + Q` or `Calculator` key | Kalkulaator (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, kui see on paigaldatud) |
| `Super + Shift + T` | Tegevus (btop) |
| `Super + Shift + N` | Redaktor (Plain või sinu valitud vaikeväärtus) |
| `Super + Shift + C` | Kalender ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-post ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Uus e-kiri ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Sõnumirakendus (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Sõnumirakendus (WhatsApp) |
| `Super + Shift + Ctrl + G` | Sõnumirakendus (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Kirjutamine (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (uus postitus) |
| `Super + Shift + Y` | YouTube |

Muuda/lisa seoseid failis `~/.config/hypr/bindings.lua`.

## Universaalne lõikelaud

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + A` | Vali kõik rakendustes, mis toetavad kombinatsiooni `Ctrl + A` |
| `Super + C` | Kopeeri |
| `Super + X` | Lõika (mitte terminalis) |
| `Super + V` | Kleebi |
| `Super + Ctrl + V` | Lõikelaua haldur |

Tavaliselt on Linuxis terminalis kopeerimiseks ja kleepimiseks vaja kombinatsiooni `Ctrl + Shift + C/V` ning kõikjal mujal kombinatsiooni `Ctrl + C/V`. Need Omarchy ühtsed lõikelaua kiirklahvid töötavad kõikjal.

## Jäädvustamine

| Kiirklahv | Funktsioon |
| ------------------- | ------------------------------ |
| `Print Screen` | Ekraanipilt |
| `Super + Ctrl + Alt + C` | Ekraanipilt (sama võte klaviatuuridele, millel pole Print Screen klahvi) |
| `Super + Ctrl + C` | Jäädvustamismenüü |
| `Alt + Print Screen` | Ekraanisalvestus |
| `Super + Shift + Ctrl + Alt + C` | Ekraanisalvestus ilma helita, menüü vahele jättes (peatamiseks vajuta uuesti) |
| `Super + Print Screen` | Värvivalija |
| `Super + Ctrl + Print Screen` | Teksti eraldamine lõikelauale |
| `Super + Alt + [` | Tee veebikaamera ülekate salvestamise ajal väiksemaks |
| `Super + Alt + ]` | Tee veebikaamera ülekate salvestamise ajal suuremaks |
| `Alt + Shift + L` | Kopeeri praegune URL veebirakendusest või brauserist |
| `Alt + Shift + D` | Laadi praegusel lehel olev video alla kausta `~/Videos` |
| `Alt + Space` | Alusta/peata dikteerimine (nõuab _Setup > Defaults > Dictation_) |
| `Right Alt` | Hoia dikteerimiseks all (nõuab _Setup > Defaults > Dictation_) |

Ekraanisalvestuste puhul küsib kiirklahv esmalt, millist heli soovid, ja alustab seejärel salvestamist. Peatamiseks vajuta seda uuesti. Üksikasju vaata jaotisest [ekraanipildid ja salvestamine](12-screenshots-recording.md).

Kõik jäädvustamisvalikud on saadaval ka Omarchy menüüs (`Super + Space`) jaotise _Trigger > Capture_ all.

## Teavitused

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + ,` | Tegele uusima teavitusega: ava see või vajuta selle ainsat nuppu, vali selle valikute hulgast või sulge see, kui valikuid pole |
| `Super + Shift + ,` | Sulge kõik teavitused |
| `Super + Ctrl + ,` | Juhi teavitusi klaviatuuriga |
| `Super + Alt + ,` | Sulge uusim teavitus |
| `Super + Shift + Alt + ,` | Ava teavituste ajalugu |
| `Super + Ctrl + Alt + ,` | Lülita teavituste vaigistamist |

## Stiil

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vali uus teema (ka `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vali teema taust (ka `Super + Ctrl + Space`) |
| `Super + Backspace` | Lülita akna läbipaistvust |
| `Super + Ctrl + Backspace` | Lülita ühe akna ruudukujulist kuvasuhet |

Lisataustapildid asuvad kaustas `~/.config/omarchy/backgrounds/<theme name>`. Saadaval ka Omarchy menüüs jaotise _Install > Style > Background_ kaudu.

Kõik stiilivalikud on saadaval ka Omarchy menüüs (`Super + Space`) jaotise _Appearance_ all.

## Lülitid

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Lülita jõudeolekul lukustamist |
| `Super + Ctrl + Delete` | Lülita sülearvuti ekraan sisse/välja |
| `Super + Ctrl + Alt + Delete` | Lülita sülearvuti ekraani peegeldamist |
| `Super + Shift + Space` | Lülita ülemist riba |
| `Shift + Mute` | Vaheta järgmisele heliväljundile |
| `Shift + Play` | Vaheta järgmisele meediaallikale |
| `Super + Shift + Backspace` | Lülita aknavahesid |
| `Super + Ctrl + Alt + F` | Lülita täisekraani töölauda (ülemine riba + aknavahed) |

## Meeldetuletused

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Määra meeldetuletus |
| `Super + Ctrl + Alt + R` | Vaata kõiki meeldetuletusi |
| `Super + Ctrl + Shift + R` | Kustuta kõik meeldetuletused |

## Märguanded

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Näita kellaaega märguandena |
| `Super + Ctrl + Alt + B` | Näita akut märguandena |
| `Super + Ctrl + Alt + W` | Lülita ilma märguandena näitamist |

## Tmux

Prefiksiklahv on `Ctrl + Space` (töötab ka `Ctrl + B`). Neid seoseid saad muuta failis `~/.config/tmux/tmux.conf`.

### Paanid

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Prefix + v` | Jaga paan kõrvuti (vertikaalne) |
| `Prefix + h` | Jaga paan alla (horisontaalne) |
| `Prefix + x` | Sulge paan |
| `Prefix + z` | Lülita paani suumi (täisekraan) |
| `Alt + Enter` | Jaga paan alla (ilma prefiksita) |
| `Alt + Shift + Enter` | Jaga paan kõrvuti (ilma prefiksita) |
| `Alt + Escape` | Sulge paan (ilma prefiksita) |
| `Ctrl + Alt + Arrows` | Liigu paanide vahel |
| `Ctrl + Alt + Shift + Arrows` | Muuda paanide suurust |

### Aknad

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Prefix + c` | Uus aken |
| `Prefix + k` | Sulge aken |
| `Prefix + r` | Nimeta aken ümber |
| `Alt + 1-9` | Mine kindla akna juurde |
| `Alt + Arrow Left/Right` | Liigu akende vahel |
| `Alt + Shift + Arrow Left/Right` | Teisalda aken vasakule/paremale |

### Seansid

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Prefix + C` | Uus seanss |
| `Prefix + K` | Sulge seanss |
| `Prefix + R` | Nimeta seanss ümber |
| `Prefix + N` | Järgmine seanss |
| `Prefix + P` | Eelmine seanss |
| `Alt + Arrow Up/Down` | Liigu seansside vahel |
| `Prefix + s` | Loetle seansid |
| `Prefix + d` | Lahku seansist |

### Kopeerimisrežiim (vi-stiilis)

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Prefix + [` | Sisene kopeerimisrežiimi |
| `v` | Alusta valikut (kopeerimisrežiimis) |
| `y` | Kopeeri valik (kopeerimisrežiimis) |

### Üldine

| Kiirklahv | Funktsioon |
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
| `tsl <count> <command>` | Loo mitme paaniga swarm-paigutus |

## Ghostty Terminal

Ghostty terminal paigaldatakse Omarchy menüü kaudu jaotises _Install > Terminal_.

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Uus jaotus all |
| `Ctrl + Shift + O` | Uus jaotus kõrval |
| `Ctrl + Alt + Arrows` | Liigu jaotuste vahel |
| `Super + Ctrl + Shift + Arrows` | Muuda jaotuse suurust 10 rea võrra |
| `Super + Ctrl + Shift + Alt + Arrows` | Muuda jaotuse suurust 100 rea võrra |
| `Ctrl + Shift + T` | Uus vahekaart |
| `Ctrl + Shift + Arrows` | Liigu vahekaartide vahel |
| `Alt + Numbers` | Mine kindla vahekaardi juurde |
| `Shift + Pg Up/Down` | Keri ajalugu |
| `Ctrl + Left mouse` | Ava link brauseris |

## File Manager

| Kiirklahv | Funktsioon |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Mine asukohta |
| `Space` | Faili eelvaade (nooled liiguvad) |
| `Alt + Up` | Mine üles ülemkausta |

## Neovim (w/ lazyvim)

### Navigeerimine

| Kiirklahv | Funktsioon |
| ------------------------ | ------------------------------- |
| `Space` | Näita käsuvalikuid |
| `Space Space` | Ava fail hägusa otsinguga |
| `Space E` | Lülita külgriba |
| `Space G G` | Näita giti juhtimist |
| `Space S G` | Otsi faili sisust |
| `Ctrl + W W` | Hüppa külgriba ja redaktori vahel |
| `Ctrl + Left/right arrow` | Muuda külgriba suurust |
| `Shift + H` | Mine vasakpoolse failivahekaardi juurde |
| `Shift + L` | Mine parempoolse failivahekaardi juurde |
| `Space B D` | Sulge failivahekaart |

### Külgribal olles

| Kiirklahv | Funktsioon |
| ------------------------ | ------------------------------- |
| `A` | Lisa uus fail ülemkataloogi |
| `Shift + A` | Lisa uus alamkataloog ülemkataloogi |
| `D` | Kustuta esiletõstetud fail/kataloog |
| `M` | Teisalda esiletõstetud fail/kataloog |
| `R` | Nimeta esiletõstetud fail/kataloog ümber |
| `?` | Näita kõigi käskude abi |

[Vaata kõiki Neovimi kiirklahve, mille on seadistanud LazyVim](https://www.lazyvim.org/keymaps).

## Kiired emojid

Saad kasutada kombinatsiooni `Super + Ctrl + E`, et näidata täielikku emoji valijat, mis paneb valiku lõikelauale, või saad kasutada neid kiirpääsuvalikuid.

| Kiirklahv | EM | Clue |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smile |
| `Shift + CapsLock M C` | 😂 | cry |
| `Shift + CapsLock M L` | 😍 | love |
| `Shift + CapsLock M V` | ✌️ | victory |
| `Shift + CapsLock M H` | ❤️ | heart |
| `Shift + CapsLock M Y` | 👍 | yes |
| `Shift + CapsLock M N` | 👎 | no |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | wish |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | kiss |
| `Shift + CapsLock M E` | 🙄 | eyeroll |
| `Shift + CapsLock M I` | 😉 | wink |
| `Shift + CapsLock M P` | 🙏 | pray |
| `Shift + CapsLock M D` | 🤤 | drool |
| `Shift + CapsLock M M` | 💰 | money |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | toast |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | greeting |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blowing |

## Kiired täiendused

| Kiirklahv | Täiendus |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Sinu nimi (nagu häälestamisel sisestatud) |
| `Shift + CapsLock Space E` | Sinu e-post (nagu häälestamisel sisestatud) |

Saad enda omi lisada, muutes faili `~/.XCompose` ja käivitades seejärel terminalis käsu `omarchy restart xcompose`, et muudatused rakenduksid.
