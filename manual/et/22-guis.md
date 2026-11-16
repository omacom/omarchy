# GUIs

## Failid

Files (Nautilus) on graafiline failihaldur. `Super + Shift + F` avab selle ja `Super + Shift + Alt + F` avab selle kataloogis, kus teie terminal parasjagu asub, mis säästab palju klikkimist. `Ctrl + L` võimaldab teil sisestada tee ja mis tahes failil `Space` vajutamine annab teile kiire eelvaate ilma midagi avamata.

Ühendage USB-mälupulk või SD-kaart ja see haagitakse automaatselt, nii et see ilmub lihtsalt külgribale. Kõige keerukama jaoks — draivi vormindamine, SMART-i tervise kontrollimine, partitsioonide loomine — käivitage rakenduste käivitajast (`Super + Space`) _Disks_.

Topeltklõps järgib mõistlikke vaikeseadeid: pildid, videod ja muusika avanevad rakenduses Omaview, PDF-id rakenduses Document Viewer, Markdown rakenduses Omawrite ja lihttekst redaktoris, mis on valitud jaotises _Setup > Default > Editor_.

## Disktree

Kui draiv saab täis ja teil pole aimugi, mis seda sööb, käivitage rakenduste käivitajast (`Super + Space`) [Disktree](https://github.com/tobi/disktree). See näitab teie kodukataloogi graafilist puukaarti. Suuremad plokid võtavad rohkem ruumi; liikuge kataloogidesse klaviatuuri või hiirega, märkige, mis peab minema, ja vaadake oma valikud enne millegi eemaldamist üle. Kogu ketta skannimiseks käivitage `disktree --disk`.

## Obsidian

[Obsidian](https://obsidian.md/) on tasuta ja väga laiendatav märkmete tegemise rakendus, mis kasutab salvestamiseks lihtsaid Markdown faile.

Obsidian on tasuta kõigiks otstarveteks, sealhulgas isiklikuks, äriliseks ja mittetulunduslikuks kasutamiseks.

Obsidian pakub ka [ärilist lisandmoodulit sünkroonimiseks](https://obsidian.md/sync) iOS-i ja Androidi mobiilirakendustega. (https://obsidian.md/pricing).

Obsidiani käivitate klahvidega `Super + Shift + O`. Teema sünkroonimise kasutamiseks peate seadetes valima `Omarchy` teema.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchy enda ülilihtne Markdown kirjutamisrakendus. Ei mingeid hoidlaid, ei mingeid pistikprogramme, ainult teie ja sõnad.

Omawrite'i käivitate klahvidega `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on lihtne pilditöötlustööriist, mis sobib suurepäraselt kärpimiseks, suuruse muutmiseks ja muudeks lihtsateks töötlusteks. Ärge lihtsalt oodake Photoshopi alternatiivi. Aga sellel on ikkagi Magic Wand ja kihid!

Pinta käivitate rakenduste käivitaja kaudu (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemarakendus, mis suudab taustapildilt värvid eraldada ja muuta need terviklikuks, ühtseks teemaks. See on lihtsaim viis [oma teema tegemiseks](43-making-your-own-theme.md).

Aetheri käivitate rakenduste käivitaja kaudu (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) võimaldab teil saata faile teistesse sama võrgu seadmetesse, kus rakendus töötab, nagu Apple'i AirDrop. See on siiski platvormideülene, nii et saate faile saata Windowsi, macOS-i, Androidi, iOS-i ja loomulikult Linuxi vahel.

Jagamismenüü saate avada klahvidega `Super + Ctrl + S` või Omarchy menüüs jaotises _Trigger > Share_. See annab teile neli valikut:

- **Clipboard** saadab kõik, mille olete kopeerinud, tekstifailina. Suurepärane lingi või koodijupi telefoni saamiseks ilma endale e-kirja saatmata.
- **File** avab failivalija, kus saate korraga valida mitu faili.
- **Folder** saadab terve kataloogi.
- **Receive** avab LocalSendi enda, et teine seade saaks teile midagi saata.

Sama asi töötab terminalist käskudega `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jätke tee ära ja saate failivalija.

Saate saata ka otse failihaldurist: paremklõpsake Nautiluses mis tahes valikul ja valige _Send via LocalSend_.

Omarchy tulemüür on vaikimisi suletud, välja arvatud LocalSendi port, nii et see töötab värskel installil kohe karbist võetuna. Vaadake [turvalisust](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on terviklik kontoripakett tekstitöötluse, arvutustabelite, esitluste, joonistusrakenduse ja muuga. See ühildub Microsoft Office'i failidega, nii et see on suurepärane viis nende Wordi dokumentide avamiseks.

LibreOffice'i käivitate rakenduste käivitaja kaudu (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchy enda ülilihtne esitlusrakendus. Teie esitlus on üks Markdown fail, mille pildid ja videod asuvad selle kõrval: kirjutage iga slaid reaalajas eelvaate alla, lohistage slaidid õigesse järjekorda, seejärel esitage täisekraanil või eksportige PDF-i ja PowerPointi. See võtab isegi teie Omarchy teema üle.

Hype'i käivitate rakenduste käivitaja kaudu (`Super + Space`). Kõigi otseteede nägemiseks vajutage selle sees `?`.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchy enda ülilihtne viis PDF-ide allkirjastamiseks ja täitmiseks. Asetage oma salvestatud allkiri, tekst ja tänane kuupäev lehel suvalisse kohta, seejärel salvestage allkirjastatud koopia originaali kõrvale. Kuidas seda teha, vaadake jaotisest [PDF-ide täitmine](27-filling-out-pdfs.md).

Signedi käivitate rakenduste käivitaja kaudu (`Super + Space`) või avate sellega failihaldurist PDF-i.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchy enda ülilihtne kalkulaator, mis avaneb hõljuvas aknas.

Omacalci käivitate klahvidega `Super + Shift + Q` (või kalkulaatoriklahviga, kui teie klaviatuuril selline on).

## Signal

[Signal](https://signal.org/) on E2E krüpteeritud sõnumside teerajaja ja suurepärane suhtlusvõimalus kõigile, kes eelistaksid mitte käia läbi ühe suure tehnoloogiakonglomeraadi.

Signali käivitate klahvidega `Super + Shift + G`. See ei kuulu baasinstalli hulka, nii et esimesel korral, kui seda vajutate, pakub Omarchy selle teie eest installida (see asub ka Omarchy menüüs jaotises _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchy enda ülilihtne pildivaatur ja meediumipleier: üks aken teie fotode, videote ja muusika jaoks. Avage foto ja nooleklahvid liiguvad läbi ülejäänud kausta, `N` ja `P` teevad seda kõige puhul ning `Ctrl + M` näitab kogu kausta ruudustikuna. See näitab ka HEIC, AVIF ja JPEG XL fotosid ning jätkab kõiges pikemas sealt, kus pooleli jäite.

Vajutage `F` täisekraani jaoks, `E` pildi redigeerimiseks rakenduses Omasnap või video kärpimiseks rakenduses Omacut, `Ctrl + P` pildi printimiseks ja `Delete` faili prügikasti teisaldamiseks (`Ctrl + Z` toob selle tagasi). Kõigi otseteede nägemiseks vajutage selle sees `?`.

Omaview käivitate nime all _Media Viewer_ rakenduste käivitaja kaudu (`Super + Space`) või topeltklõpsate failihalduris lihtsalt pilti, videot või laulu.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchy enda ülilihtne video kärpija. Kui teil on vaja ainult klipi algus ja lõpp ära lõigata, on see parem kui täiemahulise videoredaktori käivitamine.

Omacuti käivitate rakenduste käivitaja kaudu (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchy enda ülilihtne veebikaamera salvestaja. Valige oma kaamera ja mikrofon üks kord, seejärel vajutage salvestamiseks `Space` ja uuesti sama võtte peatamiseks ja jätkamiseks. See salvestab alati teie kaamera kõrgeima eraldusvõimega, koos reaalajas mikrofoni mõõdikuga, et saaksite enne alustamist oma helitasemeid kontrollida.

Peatage võte ja see avaneb kohe sisseehitatud redaktoris. Topeltklõpsake klippi selle poolitamiseks, lohistage iga tüki kärpimiseks käepidemeid ja eemaldage osad, mida te ei soovi. Seejärel salvestage see MP4-na. Teie algne salvestus säilitatakse, kuni selle ära viskate, nii et saate alati tagasi tulla ja seda teisiti lõigata.

Monologue'i käivitate rakenduste käivitaja kaudu (`Super + Space`).
