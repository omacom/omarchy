# Kiirklahvid

Kõiki peamisi klahvikombinatsioone näed klahvidega `Super + K` (Tmuxi kombinatsioone klahvidega `Super + Alt + K` ja Herdr-i kombinatsioone klahvidega `Super + Ctrl + K`).

## Kuidas kiirklahvid on paigutatud

Iga kiirklahv asub tasandil, mille määravad selle modifikaatorid, ja igal tasandil on üks ülesanne. Just see hoiab kiirklahvid omavahel segamini minemast ja tähendab, et tavaliselt oskad arvata, kus miski asub.

| Tasand | Mis seal asub | Näited |
| --- | --- | --- |
| `Super + key` | Süsteem: aknad, tööruumid, paigutused ja põhimenuüd | `Super + Space` Omarchy menüü, `Super + W` akna sulgemine, `Super + F` täisekraan |
| `Super + Shift + key` | Rakendused | `Super + Shift + B` brauser, `Super + Shift + E` e-post, `Super + Shift + N` redaktor |
| `Super + Ctrl + key` | Paneelid ja süsteemimenüüd | `Super + Ctrl + A` heli, `Super + Ctrl + N` võrk, `Super + Ctrl + C` jäädvustamismenüü |
| `Super + Ctrl + Alt + key` | Kiirtoimingud ja teated | `Super + Ctrl + Alt + T` kellaaja näitamine, `Super + Ctrl + Alt + B` aku, `Super + Ctrl + Alt + C` ekraanipilt |

Klahvi `Alt` lisamine kiirklahvile annab sulle sama asja variandi, mitte kunagi millegi seosetu:

- `Super + Shift + B` avab brauseri; `Super + Shift + Alt + B` avab privaatse akna
- `Super + Shift + E` avab e-posti; `Super + Shift + Alt + E` alustab uut e-kirja
- `Super + F` läheb täisekraanile; `Super + Alt + F` läheb täislaiusele
- `Super + Ctrl + C` avab jäädvustamismenüü; `Super + Ctrl + Alt + C` jätab menüü vahele ja teeb ekraanipildi

Kiirklahvi lisamisel:

1. Vali tasand selle järgi, mida see teeb, seejärel vali klahv.
2. Ära nihuta olemasolevat kiirklahvi, et ruumi teha. Leia õigel tasandil vaba klahv.
3. Kasuta klahvi `Alt` ainult ilma selleta kiirklahvi variandi jaoks.

Mõned kiirklahvid rikuvad neid reegleid, sest nii on mugav. `Shift` koos noole või klahviga `Tab` liigutab või pöörab suunda, selle asemel et rakendust avada, ning `Print`, meediaklahvid, `Alt + Tab` ja `Ctrl + Alt + Del` toimivad nii nagu igal pool mujal. Need on erandid, mitte mustrid, mida kopeerida.

Kui vaikeseade sulle ei sobi (ütleme, et tahad ekraanipiltide jaoks klahve `Super + Shift + S` nagu Windowsis), seo see ümber failis `~/.config/hypr/bindings.lua`.

## Navigeerimine

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy menüü (rakendused ja kõik muu)    |
| `Super + Alt + Space` | Rakenduste ruudustik |
| `Super + Escape` | Süsteemimenüü (peatamine, taaskäivitamine jne)  |
| `Super + Ctrl + L` | Arvuti lukustamine |
| `Super + W` or `Super + Q` | Akna sulgemine             |
| `Ctrl + Alt + Del` | Kõigi akende sulgemine |
| `Super + T`               | Akna lülitamine plaaditud/ujuva vahel             |
| `Super + J` | Akna asendi lülitamine (horisontaalne/vertikaalne) |
| `Super + O`               | Akna lülitamine hüpikuna kleepuvaks ja ujuvaks |
| `Super + L`               | Dwindle, kerimise ja ujuva paigutuse vahel tsükliliselt liikumine |
| `Super + Alt + L`         | Paigutuste vahel tsükliliselt liikumine vastupidises suunas |
| `Super + P`               | Pseudoakna stiili lülitamine (loomulik vs venitatud) |
| `Super + F`                 | Täisekraanile minek              |
| `Super + Alt + F`                 | Täislaiusele minek              |
| `Super + Ctrl + F`                 | Akna sees täisekraanile minek              |
| `Super + 1/2/3/4`         | Fokuseeritud monitoril konkreetsele tööruumile hüppamine |
| `Super + Tab` | Fokuseeritud monitoril järgmisele tööruumile hüppamine |
| `Super + Shift + Tab` | Fokuseeritud monitoril eelmisele tööruumile hüppamine |
| `Super + Ctrl + Tab` | Fokuseeritud monitoril varasemale tööruumile hüppamine |
| `Super + Shift + 1/2/3/4` | Akna liigutamine fokuseeritud monitori tööruumile |
| `Super + Shift + Alt + 1/2/3/4` | Akna liigutamine fokuseeritud monitori tööruumile ilma kaasa minemata |
| `Super + S` | Täieliku scratchpadi lülitamine |
| `Super + Alt + S` | Akna liigutamine täielikku scratchpadi |
| `Super + Grave` | Quake'i konsooli lülitamine |
| `Super + Shift + Grave` | Akna liigutamine Quake'i konsooli |
| `Super + Shift + Ctrl + Arrows` | Akna liigutamine selles suunas asuvale monitorile |
| `Super + Shift + Alt + Arrows` | Tööruumi liigutamine selles suunas asuvale monitorile |
| `Super + Arrow`  | Fookuse liigutamine noole suunas asuvale aknale, ekraani serval selle külje monitorile üleminekuga |
| `Super + Shift + Arrow`  | Akna vahetamine noole suunas asuva teisega, sealhulgas selle külje monitoril asuvaga |
| `Super + Minus` | Akna laiendamine vasakule |
| `Super + Equal` | Akna kahandamine vasakule |
| `Super + Shift + Minus` | Akna kahandamine üles |
| `Super + Shift + Equal` | Akna laiendamine alla |
| `Super + Alt + Minus/Equal` | Sama suuruse muutmine väiksemate sammudega |
| `Super + Ctrl + Minus/Equal` | Sama suuruse muutmine suuremate sammudega |
| `Super + Alt + Home` | Akna laiuse salvestamine |
| `Super + Home` | Salvestatud akna laiuse taastamine |
| `Super + Left Mouse` | Akna lohistamine |
| `Super + Right Mouse` | Akna suuruse muutmine |
| `Super + Scroll Wheel` | Fokuseeritud monitori tööruumide vahel kerimine |
| `Super + G`               | Akende grupeerimise lülitamine      |
| `Super + Alt + G`               | Akna grupeeringust välja liigutamine      |
| `Super + Alt + Tab`               | Grupeeringu akende vahel tsükliliselt liikumine      |
| `Super + Alt + Shift + Tab`               | Grupeeringu akende vahel tagurpidi tsükliliselt liikumine      |
| `Super + Alt + Scroll Wheel` | Grupeeringu akende vahel tsükliliselt liikumine |
| `Super + Alt + 1/2/3/4/5`               | Grupeeringus konkreetsele aknale hüppamine      |
| `Super + Alt + Arrow`  | Akna liigutamine grupeeringusse noole suunas, sealhulgas selle külje monitoril asuvasse |
| `Super + Ctrl + Left/Right`  | Plaaditud rühma sees akende vahel liikumine |
| `Super + Ctrl + Z` | Ekraanile sisse suumimine (korda suurema suumi jaoks) |
| `Super + Ctrl + Alt + Z` | Ekraanilt täielikult välja suumimine |
| `Super + /` | Monitori skaleerimisvalikute vahel edasi liikumine |
| `Super + Alt + /` | Monitori skaleerimisvalikute vahel tagasi liikumine |
| `Alt + Tab` | Aktiivse tööruumi akende vahel edasi tsükliliselt liikumine |
| `Alt + Shift + Tab` | Aktiivse tööruumi akende vahel tagurpidi tsükliliselt liikumine |
| `Ctrl + Alt + Tab`| Fookuse tsükliline liigutamine monitoride vahel edasi |
| `Ctrl + Alt + Shift + Tab`| Fookuse tsükliline liigutamine monitoride vahel tagasi |

Suuruse muutmise otseteed kasutavad füüsilisi klahve `code:20` ja `code:21` (XKB `<AE11>` ja `<AE12>`), sõltumata klaviatuurile trükitud märkidest. USA klaviatuuridel on need klahvid `-` ja `=`; Jaapani (JIS) klaviatuuridel on need `-` ja `^`; Hispaania klaviatuuridel on need `'` ja `¡`. JIS-il on `Super + ^` sama mis `Super + Equal`, samas kui `Super + Shift + -` (mis sisestab märgi `=`) on `Super + Shift + Minus`.

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
| `Super + Ctrl + 1-9`           | Ribapaneeli lülitamine positsiooni järgi    |
| `Super + Ctrl + S` | Jagamismenüü (LocalSendi kaudu) |
| `Super + Ctrl + C` | Jäädvustamise juhtimine (ekraanipilt/-salvestus/valija) |
| `Super + Ctrl + O` | Menüü lülitamine |
| `Super + Ctrl + H` | Riistvaramenüü |
| `Super + Ctrl + E` | Emojivalija |
| `Super + Ctrl + .` | Meedia transkodeerimine |
| `Super + Shift + Ctrl + A` | AI-agendi valimine |

## Kohandused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekraani maksimaalne heledus |
| `Shift + Brightness Down` | Ekraani minimaalne heledus |
| `Alt + Brightness Up/Down` | Täpsed 1% heleduse muutused |
| `Alt + Volume Up/Down` | Täpsed 1% helitugevuse muutused |
| `Keyboard Brightness Up/Down` | Klaviatuuri taustvalgustus heledamaks/tumedamaks |
| `Keyboard Backlight` | Klaviatuuri taustvalgustuse tasemete vahel tsükliliselt liikumine |
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
| `Super + Shift + Alt + X`           | X-i postituse koostamine |
| `Super + Shift + Y`           | YouTube |

Muuda/lisa seoseid failis `~/.config/hypr/bindings.lua`.

## Universaalne lõikelaud

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + A`           | Kõige valimine rakendustes, mis toetavad klahve `Ctrl + A`    |
| `Super + C`           | Kopeerimine    |
| `Super + X`           | Lõikamine (mitte terminalis)    |
| `Super + V`           | Kleepimine    |
| `Super + Ctrl + V`           | Lõikelaua haldur    |

Tavaliselt Linuxis vajad terminalis kopeerimiseks ja kleepimiseks klahve `Ctrl + Shift + C/V` ja kõikjal mujal klahve `Ctrl + C/V`. Need Omarchy ühtsed lõikelaua kiirklahvid töötavad kõikjal.

## Jäädvustamine

| Kiirklahv              | Funktsioon                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekraanipilt                      |
| `Super + Ctrl + Alt + C`            | Ekraanipilt (sama jäädvustus klaviatuuridele, millel pole Print Screen klahvi) |
| `Super + Ctrl + C` | Jäädvustamismenüü |
| `Alt + Print Screen`            | Ekraanisalvestus                     |
| `Super + Print Screen` | Värvivalija |
| `Super + Ctrl + Print Screen` | Teksti eraldamine lõikelauale |
| `Super + Alt + [` | Veebikaamera ülekatte väiksemaks tegemine salvestamise ajal |
| `Super + Alt + ]` | Veebikaamera ülekatte suuremaks tegemine salvestamise ajal |
| `Alt + Shift + L` | Praeguse URL-i kopeerimine veebirakendusest või Chromiumist |
| `Alt + Shift + D` | Praegusel lehel oleva video allalaadimine kausta `~/Videos` |
| `Alt + Space` | Dikteerimise alustamine/peatamine (nõuab _Setup > Defaults > Dictation_) |
| `Right Alt` | Dikteerimiseks all hoidmine (nõuab _Setup > Defaults > Dictation_) |

Ekraanisalvestustega küsib kiirklahv esmalt, millist heli soovid, seejärel alustab salvestamist. Salvestamise peatamiseks vajuta seda uuesti. Üksikasju vaata jaotisest [ekraanipildid ja salvestamine](12-screenshots-recording.md).

Kõik jäädvustamisvalikud on kättesaadavad ka Omarchy menüüs (`Super + Space`) jaotise _Trigger > Capture_ all.

## Teavitused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + ,` | Viimase teavitusega toimimine: selle avamine või selle ainsa nupu vajutamine, valikute hulgast valimine või selle sulgemine, kui valikuid pole  |
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

Täiendavad taustapildid asuvad kaustas `~/.config/omarchy/backgrounds/<theme name>`. Saadaval ka Omarchy menüüs jaotise _Install > Style > Background_ kaudu.

Kõik stiilivalikud on kättesaadavad ka Omarchy menüüs (`Super + Space`) jaotise _Style_ all.

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
| `Super + Ctrl + Alt + R` | Kõigi meeldetuletuste nägemine  |
| `Super + Ctrl + Shift + R` | Kõigi meeldetuletuste kustutamine  |

## Teated

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Kellaaja näitamine teavitusena  |
| `Super + Ctrl + Alt + B` | Aku näitamine teavitusena  |
| `Super + Ctrl + Alt + W` | Ilma teavitusena näitamise lülitamine  |

## Tmux

Prefiksiklahv on `Ctrl + Space` (töötab ka `Ctrl + B`). Neid seoseid saad muuta failis `~/.config/tmux/tmux.conf`.

### Paanid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + v` | Paani jagamine kõrvale (vertikaalne) |
| `Prefix + h` | Paani jagamine alla (horisontaalne) |
| `Prefix + x` | Paani sulgemine |
| `Prefix + z` | Paani suumi lülitamine (täisekraan) |
| `Alt + Enter` | Paani jagamine alla (ilma prefiksita) |
| `Alt + Shift + Enter` | Paani jagamine kõrvale (ilma prefiksita) |
| `Alt + Escape` | Paani sulgemine (ilma prefiksita) |
| `Ctrl + Alt + Arrows` | Paanide vahel liikumine |
| `Ctrl + Alt + Shift + Arrows` | Paanide suuruse muutmine |

### Aknad

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + c` | Uus aken |
| `Prefix + k` | Akna sulgemine |
| `Prefix + r` | Akna ümbernimetamine |
| `Alt + 1-9` | Konkreetsele aknale minek |
| `Alt + Arrow Left/Right` | Akende vahel liikumine |
| `Alt + Shift + Arrow Left/Right` | Akna liigutamine vasakule/paremale |

### Seansid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + C` | Uus seanss |
| `Prefix + K` | Seansi sulgemine |
| `Prefix + R` | Seansi ümbernimetamine |
| `Prefix + N` | Järgmine seanss |
| `Prefix + P` | Eelmine seanss |
| `Alt + Arrow Up/Down` | Seansside vahel liikumine |
| `Prefix + s` | Seansside loetlemine |
| `Prefix + d` | Seansist lahtiühendamine |

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
| `Prefix + ?` | Tmuxi klahvikombinatsioonide näitamine |
| `Prefix + :` | Käsuviip |

### Tmuxi paigutusfunktsioonid

Neid funktsioone tuleb käivitada Tmuxi seansi sees.

| Käsk | Funktsioon |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Arenduspaigutuse loomine redaktori, AI ja terminaliga |
| `tdlm <ai> [<second_ai>]` | Arenduspaigutuse loomine iga alamkataloogi kohta |
| `tsl <count> <command>` | Mitme paaniga parvpaigutuse loomine |

## Ghostty Terminal

Ghostty terminal installitakse Omarchy menüü kaudu jaotises _Install > Terminal_.

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Uus jaotus allpool |
| `Ctrl + Shift + O` | Uus jaotus kõrval |
| `Ctrl + Alt + Arrows` | Jaotuste vahel liikumine |
| `Super + Ctrl + Shift + Arrows` | Jaotuse suuruse muutmine 10 rea võrra |
| `Super + Ctrl + Shift + Alt + Arrows` | Jaotuse suuruse muutmine 100 rea võrra |
| `Ctrl + Shift + T` | Uus vahekaart  |
| `Ctrl + Shift + Arrows` | Vahekaartide vahel liikumine |
| `Alt + Numbers` | Konkreetsele vahekaardile minek |
| `Shift + Pg Up/Down` | Ajaloo kerimine |
| `Ctrl + Left mouse` | Lingi avamine brauseris |

## Failihaldur

| Kiirklahv              | Funktsioon                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Tee juurde minek                     |
| `Space`               | Faili eelvaade (nooled navigeerivad) |
| `Alt + Up`       | Ülemkausta minek        |

## Neovim (koos lazyvimiga)

### Navigeerimine

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Käskude valikute näitamine            |
| `Space Space`              | Faili avamine hägusotsinguga      |
| `Space E`                  | Külgriba lülitamine                  |
| `Space G G`                | Git-juhtnuppude näitamine               |
| `Space S G`                | Faili sisu otsimine             |
| `Ctrl + W W`               | Külgriba ja redaktori vahel hüppamine |
| `Ctrl + Left/right arrow`  | Külgriba suuruse muutmine          |
| `Shift + H`                      | Vasakpoolsele failivahekaardile minek             |
| `Shift + L`                      | Parempoolsele failivahekaardile minek            |
| `Space B D`                | Failivahekaardi sulgemine                  |

### Külgribal olles

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `A`                        | Uue faili lisamine ülemkataloogi      |
| `Shift + A`                | Uue alamkataloogi lisamine ülemkataloogi    |
| `D`                        | Esiletõstetud faili/kataloogi kustutamine     |
| `M`                        | Esiletõstetud faili/kataloogi liigutamine       |
| `R`                        | Esiletõstetud faili/kataloogi ümbernimetamine     |
| `?`                        | Kõigi käskude abi näitamine      |

[Vaata kõiki LazyVimi seadistatud Neovimi kiirklahve](https://www.lazyvim.org/keymaps).

## Kiired emojid

Saad kasutada klahve `Super + Ctrl + E`, et näidata täielikku emojivalijat, mis paneb valiku lõikelauale, või saad kasutada neid kiirjuurdepääsu valikuid.

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
| `Shift + CapsLock M D` | 🤤 | süljevool      |
| `Shift + CapsLock M M` | 💰 | raha      |
| `Shift + CapsLock M X` | 🎉 | pidu |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | terviseks      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | tervitus |
| `Shift + CapsLock M A` |💪 | käsi |
| `Shift + CapsLock M B` |🤯 | vapustav |

## Kiirtäiendused

| Kiirklahv       | Täiendus       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (pikk mõttekriips)   |
| `Shift + CapsLock Space N` | Sinu nimi (nagu seadistamisel sisestatud)  |
| `Shift + CapsLock Space E` | Sinu e-post (nagu seadistamisel sisestatud)  |

Saad enda omi lisada, muutes faili `~/.XCompose` ja käivitades seejärel terminalis käsu `omarchy-restart-xcompose`, et muudatused kasutusele võetaks.
