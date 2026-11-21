# Kiirklahvid

Kõiki peamisi klahvikombinatsioone näed klahvidega `Super + K` (Tmuxi seoseid klahvidega `Super + Alt + K` ja Herdr seoseid klahvidega `Super + Ctrl + K`).

## Kuidas kiirklahvid on paigutatud

Iga kiirklahv asub tasandil, mille määravad selle modifikaatorid, ja igal tasandil on üks ülesanne. Just see hoiab kiirklahvid omavahel segamini minemast ja tähendab, et tavaliselt oskad arvata, kus miski asub.

| Tasand | Mis seal asub | Näited |
| --- | --- | --- |
| `Super + key` | Süsteem: aknad, tööruumid, paigutused ja põhimenuüd | `Super + Space` Omarchy menüü, `Super + W` akna sulgemine, `Super + F` täisekraan |
| `Super + Shift + key` | Rakendused | `Super + Shift + B` brauser, `Super + Shift + E` e-post, `Super + Shift + N` redaktor |
| `Super + Ctrl + key` | Paneelid ja süsteemimenüüd | `Super + Ctrl + A` heli, `Super + Ctrl + N` võrk, `Super + Ctrl + C` jäädvustamismenüü |
| `Super + Ctrl + Alt + key` | Kiirtoimingud ja teated | `Super + Ctrl + Alt + T` kellaaja näitamine, `Super + Ctrl + Alt + B` aku, `Super + Ctrl + Alt + C` ekraanipilt |

Kiirklahvile `Alt` lisamine annab sulle sama asja variandi, mitte kunagi midagi seosetut:

- `Super + Shift + B` avab brauseri; `Super + Shift + Alt + B` avab privaatse akna
- `Super + Shift + E` avab e-posti; `Super + Shift + Alt + E` alustab uut kirja
- `Super + F` läheb täisekraanile; `Super + Alt + F` läheb täislaiusele
- `Super + Ctrl + C` avab jäädvustamismenüü; `Super + Ctrl + Alt + C` jätab menüü vahele ja teeb ekraanipildi

Kiirklahvi lisamisel:

1. Vali tasand selle järgi, mida see teeb, seejärel vali klahv.
2. Ära nihuta olemasolevat kiirklahvi, et ruumi teha. Leia õigel tasandil vaba klahv.
3. Kasuta `Alt` ainult ilma selleta kiirklahvi variandi jaoks.

Mõned kiirklahvid rikuvad neid reegleid, sest nii on mugav. `Shift` koos nooleklahvi või `Tab`-iga liigutab või pöörab suunda ümber, selle asemel et rakendust avada, ning `Print`, meediaklahvid, `Alt + Tab` ja `Ctrl + Alt + Del` töötavad samamoodi nagu kõikjal mujal. Need on erandid, mitte mustrid, mida kopeerida.

Kui vaikeseade sulle ei sobi (näiteks tahad ekraanipiltide jaoks `Super + Shift + S` nagu Windowsis), seo see ümber failis `~/.config/hypr/bindings.lua`.

## Navigeerimine

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy menüü (rakendused ja kõik muu) |
| `Super + Alt + Space` | Rakenduste ruudustik |
| `Super + Escape` | Süsteemimenüü (peatamine, taaskäivitamine jne) |
| `Super + Ctrl + L` | Arvuti lukustamine |
| `Super + W` or `Super + Q` | Akna sulgemine |
| `Ctrl + Alt + Del` | Kõigi akende sulgemine |
| `Super + K` | Kõigi kiirklahvide näitamine |
| `Super + Alt + K` | Tmuxi kiirklahvide näitamine |
| `Super + Ctrl + K` | Herdri kiirklahvide näitamine |
| `Super + M` | Akna minimeerimine dokki |
| `Super + T` | Akna lülitamine paanitud/ujuva vahel |
| `Super + J` | Akna asendi lülitamine (horisontaalne/vertikaalne) |
| `Super + O` | Akna kleepuvaks ujuvaks hüpikaknaks muutmise lülitamine |
| `Super + L` | Tsükle läbi dwindle'i, kerimise ja ujuva paigutuse |
| `Super + Alt + L` | Tsükle läbi paigutuste vastupidises järjekorras |
| `Super + P` | Pseudoakna stiili lülitamine (loomulik vs venitatud) |
| `Super + F` | Täisekraanile minek |
| `Super + Alt + F` | Täislaiusele minek |
| `Super + Ctrl + F` | Täisekraan akna sees |
| `Super + 1…9/0` | Hüppa fookuses oleval monitoril konkreetsesse tööruumi (0 on 10) |
| `Super + Tab` | Hüppa fookuses oleval monitoril järgmisesse tööruumi |
| `Super + Shift + Tab` | Hüppa fookuses oleval monitoril eelmisesse tööruumi |
| `Super + Ctrl + Tab` | Hüppa fookuses oleval monitoril varasemasse tööruumi |
| `Super + Shift + 1…9/0` | Akna liigutamine fookuses oleval monitoril tööruumi |
| `Super + Shift + Alt + 1…9/0` | Akna liigutamine fookuses oleval monitoril tööruumi ilma järgnemata |
| `Super + S` | Täisscratchpadi lülitamine |
| `Super + Alt + S` | Akna liigutamine täisscratchpadi |
| `Super + Grave` | Quake'i konsooli lülitamine |
| `Super + Shift + Grave` | Akna liigutamine Quake'i konsooli |
| `Super + Shift + Ctrl + Arrows` | Akna liigutamine selles suunas asuvale monitorile |
| `Super + Shift + Alt + Arrows` | Tööruumi liigutamine selles suunas asuvale monitorile |
| `Super + Arrow` | Fookuse liigutamine noole suunas asuvale aknale, ekraani serval sellel küljel asuvale monitorile üleminekuga |
| `Super + Shift + Arrow` | Akna vahetamine noole suunas asuva teise aknaga, sealhulgas sellel küljel asuval monitoril oleva aknaga |
| `Super + Minus` | Akna laiendamine vasakule |
| `Super + Equal` | Akna kahandamine vasakule |
| `Super + Shift + Minus` | Akna kahandamine üles |
| `Super + Shift + Equal` | Akna laiendamine alla |
| `Super + Alt + Minus/Equal` | Sama suuruse muutmine väiksemate sammudega |
| `Super + Ctrl + Minus/Equal` | Sama suuruse muutmine suuremate sammudega |
| `Super + Alt + Home` | Akna laiuse salvestamine |
| `Super + Home` | Salvestatud akna laiuse taastamine |
| `Super + Left Mouse` | Akna ringilohistamine |
| `Super + Right Mouse` | Akna suuruse muutmine |
| `Super + Scroll Wheel` | Tööruumide kerimine fookuses oleval monitoril |
| `Super + G` | Akende grupeerimise lülitamine |
| `Super + Alt + G` | Akna grupeeringust välja liigutamine |
| `Super + Alt + Tab` | Grupeeringu akende vahel tsüklemine |
| `Super + Alt + Shift + Tab` | Grupeeringu akende vahel tagurpidi tsüklemine |
| `Super + Alt + Scroll Wheel` | Grupeeringu akende vahel tsüklemine |
| `Super + Alt + 1/2/3/4/5` | Hüppa grupeeringus konkreetse akna juurde |
| `Super + Alt + Arrow` | Akna liigutamine noole suunas grupeeringusse, sealhulgas sellel küljel asuval monitoril oleva aknaga |
| `Super + Ctrl + Left/Right` | Paanitud grupi akende vahel liikumine |
| `Super + Ctrl + Z` | Ekraanil sisse suumimine (suurema suumi jaoks korda) |
| `Super + Ctrl + Alt + Z` | Ekraanilt täielikult välja suumimine |
| `Super + /` | Monitori skaleerimisvalikute vahel edasi liikumine |
| `Super + Alt + /` | Monitori skaleerimisvalikute vahel tagasi liikumine |
| `Alt + Tab` | Aktiivse tööruumi akende vahel edasi tsüklemine |
| `Alt + Shift + Tab` | Aktiivse tööruumi akende vahel tagurpidi tsüklemine |
| `Ctrl + Alt + Tab` | Fookuse tsüklemine monitoride vahel edasi |
| `Ctrl + Alt + Shift + Tab` | Fookuse tsüklemine monitoride vahel tagurpidi |
| `Super + I` | Sisendkeele vahetamine (rohkem kui ühe paigutuse või sisestusmeetodi korral) |
| `Super + Shift + I` | Sisendkeele tagasi vahetamine |

Puuteplaadil lülitavad kolme ja nelja sõrme pühked tööruume, liigutavad aknaid ning avavad menüü ja Quake'i konsooli; žeste vaata jaotisest [klaviatuur, hiir ja puuteplaat](34-keyboard-mouse-trackpad.md).

Suuruse muutmise otseteed kasutavad füüsilisi klahve `code:20` ja `code:21` (XKB `<AE11>` ja `<AE12>`), olenemata klaviatuurile trükitud märkidest. USA klaviatuuridel on need klahvid `-` ja `=`; Jaapani (JIS) klaviatuuridel on need `-` ja `^`; Hispaania klaviatuuridel on need `'` ja `¡`. JIS-il on `Super + ^` sama mis `Super + Equal`, samas kui `Super + Shift + -` (mis trükib `=`) on `Super + Shift + Minus`.

## Süsteemi juhtimine

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Helipaneel |
| `Super + Ctrl + B` | Bluetoothi paneel |
| `Super + Ctrl + N` | Wi-Fi/võrgupaneel |
| `Super + Ctrl + D` | Kuvapaneel |
| `Super + Ctrl + P` | Toitepaneel |
| `Super + Ctrl + X` | Agentide paneel |
| `Super + Ctrl + Alt + X` | Kohalike mudelite paneel |
| `Super + Ctrl + Alt + D` | Kalendripaneel |
| `Super + Ctrl + Alt + E` | Maailmakella paneel |
| `Super + Ctrl + 1-9` | Ribapaneeli lülitamine positsiooni järgi |
| `Super + Ctrl + S` | Jagamismenüü (LocalSendi kaudu) |
| `Super + Ctrl + C` | Jäädvustamise juhtnupud (ekraanipilt/-salvestus/valija) |
| `Super + Ctrl + O` | Menüü lülitamine |
| `Super + Ctrl + H` | Riistvaramenüü |
| `Super + Ctrl + E` | Emojivalija |
| `Super + Ctrl + .` | Meedia transkoodimine |
| `Super + Shift + Ctrl + A` | AI-agendi valimine |
| `Power` key | Süsteemimenüü |
| `Super + Shift + Copilot` key | Omarchy menüü |

## Reguleerimised

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Ekraani maksimaalne heledus |
| `Shift + Brightness Down` | Ekraani minimaalne heledus |
| `Alt + Brightness Up/Down` | Täpsed 1% heleduse muudatused |
| `Alt + Volume Up/Down` | Täpsed 1% helitugevuse muudatused |
| `Keyboard Brightness Up/Down` | Klaviatuuri taustvalgustus heledamaks/tumedamaks |
| `Keyboard Backlight` | Klaviatuuri taustvalgustuse tasemete tsüklemine |
| `Ctrl + Brightness Up/Down` | Klaviatuuri taustvalgustus heledamaks/tumedamaks klaviatuuridel, millel pole oma klahve |
| `Mic Mute` | Mikrofoni vaigistamine |
| `Shift + Mute` | Heliväljundi vahetamine |
| `Touchpad Toggle` | Puuteplaadi sisse- või väljalülitamine |
| `Display` key | Tööruumi paigutuse tsüklemine |
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
| `Super + Shift + D` | Docker (lazydocker, kui see on installitud) |
| `Super + Shift + T` | Aktiivsus (btop) |
| `Super + Shift + N` | Redaktor (Plain või sinu valitud vaikeredaktor) |
| `Super + Shift + C` | Kalender ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-post ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Uus e-post ([HEY](https://hey.com/)) |
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
| `Super + A` | Vali kõik rakendustes, mis toetavad `Ctrl + A` |
| `Super + C` | Kopeeri |
| `Super + X` | Lõika (mitte terminalis) |
| `Super + V` | Kleebi |
| `Super + Ctrl + V` | Lõikelauahaldur |

Tavaliselt on Linuxis terminalis kopeerimiseks ja kleepimiseks vaja `Ctrl + Shift + C/V` ja kõikjal mujal `Ctrl + C/V`. Need Omarchy ühtsed lõikelaua kiirklahvid töötavad kõikjal.

## Jäädvustamine

| Kiirklahv | Funktsioon |
| ------------------- | ------------------------------ |
| `Print Screen` | Ekraanipilt |
| `Super + Ctrl + Alt + C` | Ekraanipilt (sama võte klaviatuuridele, millel pole Print Screen klahvi) |
| `Super + Ctrl + C` | Jäädvustamismenüü |
| `Alt + Print Screen` | Ekraanisalvestus |
| `Super + Shift + Ctrl + Alt + C` | Ekraanisalvestus ilma helita, menüüd vahele jättes (peatamiseks vajuta uuesti) |
| `Super + Print Screen` | Värvivalija |
| `Super + Ctrl + Print Screen` | Teksti ekstraktimine lõikelauale |
| `Super + Alt + [` | Veebikaamera ülekatte väiksemaks tegemine salvestamise ajal |
| `Super + Alt + ]` | Veebikaamera ülekatte suuremaks tegemine salvestamise ajal |
| `Alt + Shift + L` | Praeguse URL-i kopeerimine veebirakendusest või brauserist |
| `Alt + Shift + D` | Praegusel lehel oleva video allalaadimine kausta `~/Videos` |
| `Alt + Space` | Dikteerimise alustamine/peatamine (nõuab _Setup > Defaults > Dictation_) |
| `Right Alt` | Dikteerimiseks hoia all (nõuab _Setup > Defaults > Dictation_) |

Ekraanisalvestuste puhul küsib kiirklahv esmalt, millist heli soovid, seejärel alustab salvestamist. Peatamiseks vajuta seda uuesti. Üksikasju vaata jaotisest [ekraanipildid ja salvestamine](12-screenshots-recording.md).

Kõik jäädvustamisvalikud on saadaval ka Omarchy menüü (`Super + Space`) jaotises _Trigger > Capture_.

## Teavitused

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + ,` | Toimi viimase teavitusega: ava see või vajuta selle ainsat nuppu, vali selle valikute hulgast või sulge see, kui valikuid pole |
| `Super + Shift + ,` | Kõigi teavituste sulgemine |
| `Super + Ctrl + ,` | Teavituste juhtimine klaviatuuriga |
| `Super + Alt + ,` | Viimase teavituse sulgemine |
| `Super + Shift + Alt + ,` | Teavituste ajaloo avamine |
| `Super + Ctrl + Alt + ,` | Teavituste vaigistamise lülitamine |

## Stiil

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Uue teema valimine (ka `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Teema tausta valimine (ka `Super + Ctrl + Space`) |
| `Super + Backspace` | Akna läbipaistvuse lülitamine |
| `Super + Ctrl + Backspace` | Ühe akna ruudukujulise kuvasuhte lülitamine |

Täiendavad taustapildid asuvad kaustas `~/.config/omarchy/backgrounds/<theme name>`. Saadaval ka Omarchy menüü jaotise _Install > Style > Background_ kaudu.

Kõik stiilivalikud on saadaval ka Omarchy menüü (`Super + Space`) jaotises _Appearance_.

## Lülitid

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Tühikäigul lukustamise lülitamine |
| `Super + Ctrl + Delete` | Sülearvuti ekraani sisse-/väljalülitamine |
| `Super + Ctrl + Alt + Delete` | Sülearvuti ekraani peegeldamise lülitamine |
| `Super + Shift + Space` | Ülemise riba lülitamine |
| `Shift + Mute` | Järgmisele heliväljundile lülitumine |
| `Shift + Play` | Järgmisele meediaallikale lülitumine |
| `Super + Shift + Backspace` | Aknavahede lülitamine |
| `Super + Ctrl + Alt + F` | Täisekraani töölaua lülitamine (ülemine riba + aknavahed) |

## Meeldetuletused

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Meeldetuletuse seadmine |
| `Super + Ctrl + Alt + R` | Kõigi meeldetuletuste nägemine |
| `Super + Ctrl + Shift + R` | Kõigi meeldetuletuste tühjendamine |

## Teated

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Kellaaja näitamine teavitusena |
| `Super + Ctrl + Alt + B` | Aku näitamine teavitusena |
| `Super + Ctrl + Alt + W` | Ilma teavitusena näitamise lülitamine |

## Tmux

Prefiksiklahv on `Ctrl + Space` (`Ctrl + B` töötab samuti). Neid seoseid saad muuta failis `~/.config/tmux/tmux.conf`.

### Paanid

| Kiirklahv | Funktsioon |
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

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Prefix + c` | Uus aken |
| `Prefix + k` | Akna sulgemine |
| `Prefix + r` | Akna ümbernimetamine |
| `Alt + 1-9` | Mine konkreetse akna juurde |
| `Alt + Arrow Left/Right` | Akende vahel liikumine |
| `Alt + Shift + Arrow Left/Right` | Akna liigutamine vasakule/paremale |

### Seansid

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Prefix + C` | Uus seanss |
| `Prefix + K` | Seansi sulgemine |
| `Prefix + R` | Seansi ümbernimetamine |
| `Prefix + N` | Järgmine seanss |
| `Prefix + P` | Eelmine seanss |
| `Alt + Arrow Up/Down` | Seansside vahel liikumine |
| `Prefix + s` | Seansside loend |
| `Prefix + d` | Seansist lahtiühendamine |

### Kopeerimisrežiim (vi-stiilis)

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Prefix + [` | Kopeerimisrežiimi sisenemine |
| `v` | Valiku alustamine (kopeerimisrežiimis) |
| `y` | Valiku kopeerimine (kopeerimisrežiimis) |

### Üldine

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Prefix + q` | Konfiguratsiooni uuesti laadimine |
| `Prefix + ?` | Tmuxi klahviseoste näitamine |
| `Prefix + :` | Käsuviip |

### Tmuxi paigutusfunktsioonid

Neid funktsioone tuleb käitada Tmuxi seansi sees.

| Käsk | Funktsioon |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Arenduspaigutuse loomine redaktori, AI ja terminaliga |
| `tdlm <ai> [<second_ai>]` | Arenduspaigutuse loomine iga alamkataloogi kohta |
| `tsl <count> <command>` | Mitme paaniga sülempaigutuse loomine |

## Ghostty Terminal

Ghostty terminal installitakse Omarchy menüü jaotise _Install > Terminal_ kaudu.

| Kiirklahv | Funktsioon |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Uus jaotus allpool |
| `Ctrl + Shift + O` | Uus jaotus kõrval |
| `Ctrl + Alt + Arrows` | Jaotuste vahel liikumine |
| `Super + Ctrl + Shift + Arrows` | Jaotuse suuruse muutmine 10 rea võrra |
| `Super + Ctrl + Shift + Alt + Arrows` | Jaotuse suuruse muutmine 100 rea võrra |
| `Ctrl + Shift + T` | Uus vahekaart |
| `Ctrl + Shift + Arrows` | Vahekaartide vahel liikumine |
| `Alt + Numbers` | Mine konkreetse vahekaardi juurde |
| `Shift + Pg Up/Down` | Ajaloo kerimine |
| `Ctrl + Left mouse` | Lingi avamine brauseris |

## Failihaldur

| Kiirklahv | Funktsioon |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Mine tee juurde |
| `Space` | Faili eelvaade (nooled navigeerivad) |
| `Alt + Up` | Mine üles emakausta |

## Neovim (w/ lazyvim)

### Navigeerimine

| Kiirklahv | Funktsioon |
| ------------------------ | ------------------------------- |
| `Space` | Käsuvalikute näitamine |
| `Space Space` | Faili avamine hägusotsinguga |
| `Space E` | Külgriba lülitamine |
| `Space G G` | Giti juhtnuppude näitamine |
| `Space S G` | Faili sisu otsimine |
| `Ctrl + W W` | Külgriba ja redaktori vahel hüppamine |
| `Ctrl + Left/right arrow` | Külgriba suuruse muutmine |
| `Shift + H` | Mine vasakpoolse failivahekaardi juurde |
| `Shift + L` | Mine parempoolse failivahekaardi juurde |
| `Space B D` | Failivahekaardi sulgemine |

### Külgribal olles

| Kiirklahv | Funktsioon |
| ------------------------ | ------------------------------- |
| `A` | Uue faili lisamine emakataloogi |
| `Shift + A` | Uue alamkataloogi lisamine emakataloogi |
| `D` | Esiletõstetud faili/kataloogi kustutamine |
| `M` | Esiletõstetud faili/kataloogi liigutamine |
| `R` | Esiletõstetud faili/kataloogi ümbernimetamine |
| `?` | Kõigi käskude abi näitamine |

[Vaata kõiki Neovimi kiirklahve, mille LazyVim on seadistanud](https://www.lazyvim.org/keymaps).

## Kiiremojid

Täieliku emojivalija näitamiseks, mis paneb valiku lõikelauale, saad kasutada klahve `Super + Ctrl + E`, või saad kasutada neid kiirpääsuvalikuid.

| Kiirklahv | EM | Vihje |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | naeratus |
| `Shift + CapsLock M C` | 😂 | nutt |
| `Shift + CapsLock M L` | 😍 | armastus |
| `Shift + CapsLock M V` | ✌️ | võit |
| `Shift + CapsLock M H` | ❤️ | süda |
| `Shift + CapsLock M Y` | 👍 | jah |
| `Shift + CapsLock M N` | 👎 | ei |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | soov |
| `Shift + CapsLock M R` | 🤘 | rokk |
| `Shift + CapsLock M K` | 😘 | suudlus |
| `Shift + CapsLock M E` | 🙄 | silmapööre |
| `Shift + CapsLock M I` | 😉 | silmapilk |
| `Shift + CapsLock M P` | 🙏 | palve |
| `Shift + CapsLock M D` | 🤤 | ila |
| `Shift + CapsLock M M` | 💰 | raha |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | terviseks |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | tervitus |
| `Shift + CapsLock M A` |💪 | käsivars |
| `Shift + CapsLock M B` |🤯 | plahvatav |

## Kiirtäiendused

| Kiirklahv | Täiendus |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Sinu nimi (nagu seadistamisel sisestatud) |
| `Shift + CapsLock Space E` | Sinu e-post (nagu seadistamisel sisestatud) |

Saad ise rohkem lisada, muutes faili `~/.XCompose` ja käivitades seejärel terminalis `omarchy restart xcompose`, et muudatused rakenduksid.
