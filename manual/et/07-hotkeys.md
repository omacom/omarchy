# Kiirklahvid

Kõiki peamisi klaviatuuri seoseid näed klahvidega `Super + K` (Tmuxi seoseid klahvidega `Super + Alt + K` ja Herdi seoseid klahvidega `Super + Ctrl + K`).

## Kuidas kiirklahvid on paigutatud

Iga kiirklahv asub tasandil, mille määravad selle modifikaatorid, ja igal tasandil on üks ülesanne. Just see hoiab kiirklahvid üksteisest lahus ega lase neil ähmastuda ja selle põhjal saad tavaliselt ära arvata, kus miski asub.

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
2. Ära nihuta olemasolevat kiirklahvi, et ruumi teha. Leia õigel tasandil vaba klahv.
3. Kasuta `Alt` ainult selle kiirklahvi variandi jaoks, millel seda pole.

Mõned kiirklahvid rikuvad neid reegleid, sest nii on mugav. `Shift` koos noole või `Tab`-iga nihutab või pöörab suunda, selle asemel et rakendust avada, ning `Print`, meediaklahvid, `Alt + Tab` ja `Ctrl + Alt + Del` töötavad nii nagu igal pool mujal. Need on erandid, mitte mustrid, mida kopeerida.

Kui vaikeseade sulle ei sobi (ütleme, et tahad ekraanipiltide jaoks `Super + Shift + S` nagu Windowsis), seo see ümber failis `~/.config/hypr/bindings.lua`.

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
| `Super + T`               | Lülita aken paanitava/ujuva vahel             |
| `Super + J` | Lülita akna asendit (horisontaalne/vertikaalne) |
| `Super + O`               | Lülita akna muutmine kleepuvaks ja ujuvaks |
| `Super + L`               | Sirvi dwindle-, kerimis- ja ujuvaid paigutusi |
| `Super + Alt + L`         | Sirvi paigutusi vastupidises järjekorras |
| `Super + P`               | Lülita pseudoakna stiili (loomulik vs venitatud) |
| `Super + F`                 | Mine täisekraanile              |
| `Super + Alt + F`                 | Mine täislaiusele              |
| `Super + Ctrl + F`                 | Mine akna sees täisekraanile              |
| `Super + 1…9/0`         | Hüppa fokuseeritud monitoril kindlasse tööruumi (0 on 10) |
| `Super + Tab` | Hüppa fokuseeritud monitoril järgmisse tööruumi |
| `Super + Shift + Tab` | Hüppa fokuseeritud monitoril eelmisse tööruumi |
| `Super + Ctrl + Tab` | Hüppa fokuseeritud monitoril varasemasse tööruumi |
| `Super + Shift + 1…9/0` | Teisalda aken fokuseeritud monitori tööruumi |
| `Super + Shift + Alt + 1…9/0` | Teisalda aken fokuseeritud monitori tööruumi ilma järgnemata |
| `Super + S` | Lülita täis-scratchpad |
| `Super + Alt + S` | Teisalda aken täis-scratchpadi |
| `Super + Grave` | Lülita Quake'i konsool |
| `Super + Shift + Grave` | Teisalda aken Quake'i konsooli |
| `Super + Shift + Ctrl + Arrows` | Teisalda aken selles suunas olevale monitorile |
| `Super + Shift + Alt + Arrows` | Teisalda tööruum selles suunas olevale monitorile |
| `Super + Arrow`  | Liiguta fookus noole suunas olevale aknale, ületades ekraani serval selle külje monitori |
| `Super + Shift + Arrow`  | Vaheta aken noole suunas oleva teisega, kaasa arvatud selle külje monitoril olevaga |
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
| `Super + Scroll Wheel` | Kerri fokuseeritud monitori tööruume |
| `Super + G`               | Lülita akende rühmitamist      |
| `Super + Alt + G`               | Teisalda aken rühmast välja      |
| `Super + Alt + Tab`               | Sirvi rühma aknaid      |
| `Super + Alt + Shift + Tab`               | Sirvi rühma aknaid tagurpidi      |
| `Super + Alt + Scroll Wheel` | Sirvi rühma aknaid |
| `Super + Alt + 1/2/3/4/5`               | Hüppa rühmas kindla akna juurde      |
| `Super + Alt + Arrow`  | Teisalda aken noole suunas rühma, kaasa arvatud selle külje monitoril olevaga |
| `Super + Ctrl + Left/Right`  | Liigu paanitava rühma akende vahel |
| `Super + Ctrl + Z` | Suumi ekraanil sisse (suurema suumi jaoks korda) |
| `Super + Ctrl + Alt + Z` | Suumi ekraanilt täielikult välja |
| `Super + /` | Astu monitori skaleerimisvalikutes edasi |
| `Super + Alt + /` | Astu monitori skaleerimisvalikutes tagasi |
| `Alt + Tab` | Sirvi aktiivse tööruumi aknaid edasi |
| `Alt + Shift + Tab` | Sirvi aktiivse tööruumi aknaid tagurpidi |
| `Ctrl + Alt + Tab`| Sirvi monitoride fookust edasi |
| `Ctrl + Alt + Shift + Tab`| Sirvi monitoride fookust tagurpidi |
| `Super + I` | Vaheta sisestuskeelt (kui on rohkem kui üks paigutus või sisestusmeetod) |
| `Super + Shift + I` | Vaheta sisestuskeelt tagasi |

Puuteplaadil lülitavad kolme- ja neljasõrmepyyhked tööruume, teisaldavad aknaid ning avavad menüü ja Quake'i konsooli; žeste vaata jaotisest [klaviatuur, hiir ja puuteplaat](34-keyboard-mouse-trackpad.md).

Suuruse muutmise otseteed kasutavad füüsilisi klahve `code:20` ja `code:21` (XKB `<AE11>` ja `<AE12>`), sõltumata klaviatuuril trükitud märkidest. USA klaviatuuridel on need klahvid `-` ja `=`; Jaapani (JIS) klaviatuuridel on need `-` ja `^`; Hispaania klaviatuuridel on need `'` ja `¡`. JIS-il on `Super + ^` sama mis `Super + Equal`, samas kui `Super + Shift + -` (mis trükib `=`) on `Super + Shift + Minus`.

## Süsteemijuhtimine

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
| `Super + Ctrl + C` | Jäädvustamise juhtnupud (ekraanipilt/-salvestus/valija) |
| `Super + Ctrl + O` | Lülita menüü |
| `Super + Ctrl + H` | Riistvara menüü |
| `Super + Ctrl + E` | Emoji valija |
| `Super + Ctrl + .` | Transkoodi meedia |
| `Super + Shift + Ctrl + A` | Vali AI agent |
| `Power` key | Süsteemimenüü |
| `Super + Shift + Copilot` key | Omarchy menüü |

## Kohandused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekraani maksimaalne heledus |
| `Shift + Brightness Down` | Ekraani minimaalne heledus |
| `Alt + Brightness Up/Down` | Täpsed 1% heleduse muudatused |
| `Alt + Volume Up/Down` | Täpsed 1% helitugevuse muudatused |
| `Keyboard Brightness Up/Down` | Klaviatuuri taustvalgus heledamaks/tumedamaks |
| `Keyboard Backlight` | Sirvi klaviatuuri taustvalguse tasemeid |
| `Ctrl + Brightness Up/Down` | Klaviatuuri taustvalgus heledamaks/tumedamaks klaviatuuridel, millel pole oma klahve |
| `Mic Mute` | Vaigista mikrofon |
| `Shift + Mute` | Vaheta heliväljundit |
| `Touchpad Toggle` | Lülita puuteplaat sisse või välja |
| `Display` key | Sirvi tööruumi paigutust |
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
| `Super + Shift + N`           | Redaktor (Plain või sinu valitud vaikeredaktor)  |
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

Tavaliselt Linuxis vajad terminalis kopeerimiseks ja kleepimiseks `Ctrl + Shift + C/V` ning igal pool mujal `Ctrl + C/V`. Need Omarchy ühtsed lõikelaua kiirklahvid töötavad igal pool.

## Jäädvustamine

| Kiirklahv              | Funktsioon                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekraanipilt                      |
| `Super + Ctrl + Alt + C`            | Ekraanipilt (sama pilt klaviatuuridele, millel pole Print Screen klahvi) |
| `Super + Ctrl + C` | Jäädvustamismenüü |
| `Alt + Print Screen`            | Ekraanisalvestus                     |
| `Super + Shift + Ctrl + Alt + C` | Ekraanisalvestus ilma helita, menüü vahele jättes (peatamiseks vajuta uuesti) |
| `Super + Print Screen` | Värvivalija |
| `Super + Ctrl + Print Screen` | Teksti eraldamine lõikelauale |
| `Super + Alt + [` | Tee veebikaamera ülekatet salvestamise ajal väiksemaks |
| `Super + Alt + ]` | Tee veebikaamera ülekatet salvestamise ajal suuremaks |
| `Alt + Shift + L` | Kopeeri veebirakendusest või brauserist praegune URL |
| `Alt + Shift + D` | Laadi praeguse lehe video alla kausta `~/Videos` |
| `Alt + Space` | Alusta/peata dikteerimine (nõuab _Setup > Defaults > Dictation_) |
| `Right Alt` | Hoia dikteerimiseks all (nõuab _Setup > Defaults > Dictation_) |

Ekraanisalvestustega küsib kiirklahv esmalt, millist heli soovid, seejärel alustab salvestamist. Peatamiseks vajuta seda uuesti. Üksikasju vaata jaotisest [ekraanipildid ja salvestamine](12-screenshots-recording.md).

Kõik jäädvustamisvalikud on kättesaadavad ka Omarchy menüü (`Super + Space`) jaotises _Trigger > Capture_.

## Teavitused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + ,` | Tegutse viimase teavitusega: ava see või vajuta selle ainsat nuppu, vali selle valikute hulgast või loobu sellest, kui valikuid pole  |
| `Super + Shift + ,` | Loobu kõigist teavitustest |
| `Super + Ctrl + ,` | Juhti teavitusi klaviatuuriga  |
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

Täiendavad taustapildid asuvad kaustas `~/.config/omarchy/backgrounds/<theme name>`. Kättesaadavad ka Omarchy menüü jaotise _Install > Style > Background_ kaudu.

Kõik stiilivalikud on kättesaadavad ka Omarchy menüü (`Super + Space`) jaotises _Appearance_.

## Lülitid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Lülita jõudeolekul lukustamist |
| `Super + Ctrl + Delete` | Lülita sülearvuti ekraan sisse/välja |
| `Super + Ctrl + Alt + Delete` | Lülita sülearvuti ekraani peegeldamist |
| `Super + Shift + Space` | Lülita ülemist riba  |
| `Shift + Mute` | Vaheta järgmisele heliväljundile |
| `Shift + Play` | Vaheta järgmisele meediaallikale |
| `Super + Shift + Backspace` | Lülita akende vahesid |
| `Super + Ctrl + Alt + F` | Lülita täisekraani töölauda (ülemine riba + akende vahed) |

## Meeldetuletused

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Sea meeldetuletus  |
| `Super + Ctrl + Alt + R` | Vaata kõiki meeldetuletusi  |
| `Super + Ctrl + Shift + R` | Tühjenda kõik meeldetuletused  |

## Teated

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Näita kellaaega teavitusena  |
| `Super + Ctrl + Alt + B` | Näita akut teavitusena  |
| `Super + Ctrl + Alt + W` | Lülita ilmateadet teavitusena  |

## Tmux

Eesliiteklahv on `Ctrl + Space` (`Ctrl + B` töötab samuti). Neid seoseid saad muuta failis `~/.config/tmux/tmux.conf`.

### Paanid

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + v` | Jaga paan kõrvale (vertikaalne) |
| `Prefix + h` | Jaga paan alla (horisontaalne) |
| `Prefix + x` | Sulge paan |
| `Prefix + z` | Lülita paani suumi (täisekraan) |
| `Alt + Enter` | Jaga paan alla (ilma eesliiteta) |
| `Alt + Shift + Enter` | Jaga paan kõrvale (ilma eesliiteta) |
| `Alt + Escape` | Sulge paan (ilma eesliiteta) |
| `Ctrl + Alt + Arrows` | Liigu paanide vahel |
| `Ctrl + Alt + Shift + Arrows` | Muuda paanide suurust |

### Aknad

| Kiirklahv                  | Funktsioon              |
| ----------------------- | --------------------- |
| `Prefix + c` | Uus aken |
| `Prefix + k` | Sulge aken |
| `Prefix + r` | Nimeta aken ümber |
| `Alt + 1-9` | Mine kindla akna juurde |
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

Neid funktsioone tuleb käivitada Tmuxi seansi sees.

| Käsk | Funktsioon |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Loo arenduspaigutus redaktori, AI ja terminaliga |
| `tdlm <ai> [<second_ai>]` | Loo arenduspaigutus iga alamkataloogi kohta |
| `tsl <count> <command>` | Loo mitme paaniga parvpaigutus |

## Ghostty Terminal

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
| `Alt + Numbers` | Mine kindla vahekaardi juurde |
| `Shift + Pg Up/Down` | Kerri ajalugu |
| `Ctrl + Left mouse` | Ava link brauseris |

## Failihaldur

| Kiirklahv              | Funktsioon                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Mine aadressile                     |
| `Space`               | Faili eelvaade (nooled navigeerivad) |
| `Alt + Up`       | Mine üles emakausta        |

## Neovim (w/ lazyvim)

### Navigeerimine

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Näita käsuvalikuid            |
| `Space Space`              | Ava fail hägusa otsinguga      |
| `Space E`                  | Lülita külgriba                  |
| `Space G G`                | Näita giti juhtnuppe               |
| `Space S G`                | Otsi faili sisu             |
| `Ctrl + W W`               | Hüppa külgriba ja redaktori vahel |
| `Ctrl + Left/right arrow`  | Muuda külgriba suurust          |
| `Shift + H`                      | Mine vasakpoolse failivahekaardi juurde             |
| `Shift + L`                      | Mine parempoolse failivahekaardi juurde            |
| `Space B D`                | Sulge failivahekaart                  |

### Külgribas olles

| Kiirklahv                   | Funktsioon                        |
| ------------------------ | ------------------------------- |
| `A`                        | Lisa uus fail emakataloogi      |
| `Shift + A`                | Lisa uus alamkataloog emakataloogi    |
| `D`                        | Kustuta esiletõstetud fail/kataloog     |
| `M`                        | Teisalda esiletõstetud fail/kataloog       |
| `R`                        | Nimeta esiletõstetud fail/kataloog ümber     |
| `?`                        | Näita kõigi käskude abi      |

[Vaata kõiki LazyVimi seadistatud Neovimi kiirklahve](https://www.lazyvim.org/keymaps).

## Kiired emojid

Võid kasutada `Super + Ctrl + E`, et näidata täielikku emoji valijat, mis paneb valiku lõikelauale, või võid kasutada neid kiirjuurdepääsu võimalusi.

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
| `Shift + CapsLock M I` | 😉 | silmapilgutus       |
| `Shift + CapsLock M P` | 🙏 | palveta |
| `Shift + CapsLock M D` | 🤤 | ilastamine      |
| `Shift + CapsLock M M` | 💰 | raha      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toost      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | tervitus |
| `Shift + CapsLock M A` |💪 | käsi |
| `Shift + CapsLock M B` |🤯 | puhumine |

## Kiirtäiendused

| Kiirklahv       | Täiendus       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Sinu nimi (nagu seadistamisel sisestatud)  |
| `Shift + CapsLock Space E` | Sinu e-posti aadress (nagu seadistamisel sisestatud)  |

Saad ise juurde lisada, muutes faili `~/.XCompose`, seejärel käivitades terminalis `omarchy restart xcompose`, et muudatused rakenduksid.
