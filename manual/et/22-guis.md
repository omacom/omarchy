# GUIs

## Failid

Files (Nautilus) on graafiline failihaldur. `Super + Shift + F` avab selle ja `Super + Shift + Alt + F` avab selle kataloogis, kus sinu terminal parajasti asub, mis säästab palju klõpsamist. `Ctrl + L` võimaldab sul sisestada tee ja iga faili peal `Space` vajutamine annab sulle kiire eelvaate midagi avamata.

Ühenda USB-mälupulk või SD-kaart ja see haagitakse automaatselt, nii et see ilmub lihtsalt külgribale. Millegi põhjalikuma jaoks — draivi vormindamine, SMART-i seisundi kontrollimine, partitsioonide loomine — käivita rakenduste käivitajast (`Super + Space`) _Disks_.

Topeltklõps järgib mõistlikke vaikeseadeid: pildid, videod ja muusika avanevad rakenduses Omaview, PDF-id rakenduses Document Viewer, Markdown rakenduses Omawrite ja lihttekst redaktoris, mis on valitud jaotuses _Setup > Default > Editor_.

## Disktree

Kui draiv saab täis ja sul pole õrna aimugi, mis seda sööb, käivita rakenduste käivitajast (`Super + Space`) [Disktree](https://github.com/tobi/disktree). See näitab sinu kodukataloogi graafilist puukaarti. Suuremad plokid võtavad rohkem ruumi; liigu kataloogides klaviatuuri või hiirega, märgi ära, mis peab minema, ja vaata oma valikud enne millegi eemaldamist üle. Kogu ketta skannimiseks käivita `disktree --disk`.

## Obsidian

[Obsidian](https://obsidian.md/) on tasuta ja väga laiendatav märkmete tegemise rakendus, mis kasutab salvestamiseks lihtsaid Markdowni faile.

Obsidian on tasuta igaks otstarbeks, sealhulgas isiklikuks, äriliseks ja mittetulunduslikuks kasutamiseks.

Obsidian pakub ka [ärilist lisandmoodulit sünkroonimiseks](https://obsidian.md/sync) mobiilirakendustega iOS-il ja Androidil. (https://obsidian.md/pricing).

Obsidiani käivitad klahvidega `Super + Shift + O`. Teemade sünkroonimise kasutamiseks pead seadetes valima teema `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchy enda ülilihtne Markdowni kirjutamisrakendus. Ei mingeid hoidlaid, ei mingeid pistikprogramme, ainult sina ja sõnad.

Omawrite'i käivitad klahvidega `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on lihtne pilditöötlustööriist, mis sobib suurepäraselt kärpimiseks, suuruse muutmiseks ja muudeks lihtsateks töötlusteks. Ära ainult Photoshopi alternatiivi oota. Aga sellel on ikkagi Magic Wand ja kihid!

Pinta käivitad rakenduste käivitaja kaudu (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemarakendus, mis suudab taustapildist värvid välja võtta ja neist tervikliku, ühtse teema teha. See on lihtsaim viis [oma teema tegemiseks](43-making-your-own-theme.md).

Aetheri käivitad rakenduste käivitaja kaudu (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) võimaldab sul saata faile teistele samas võrgus olevatele seadmetele, kus rakendus töötab, nagu Apple'i AirDrop. See on aga platvormideülene, nii et saad faile saata Windowsi, macOS-i, Androidi, iOS-i ja muidugi Linuxi seadmetesse ja seadmetest.

Jagamise menüü saad avada klahvidega `Super + Ctrl + S` või Omarchy menüüs jaotuses _Trigger > Share_. See annab sulle neli valikut:

- **Clipboard** saadab kõik, mille oled kopeerinud, tekstifailina. Suurepärane viis lingi või koodijupi telefoni saamiseks ilma endale e-kirja saatmata.
- **File** avab failivalija, kus saad korraga mitu valida.
- **Folder** saadab terve kataloogi.
- **Receive** avab päris LocalSendi, et teine seade saaks sulle midagi saata.

Sama toimib terminalist käskudega `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jäta tee ära ja saad failivalija.

Saad saata ka otse failihaldurist: tee Nautiluses valikul paremklõps ja vali _Send via LocalSend_.

Omarchy tulemüür on vaikimisi suletud, välja arvatud LocalSendi pordi puhul, nii et see töötab värskel installil kohe karbist välja. Vaata [turvalisust](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täielik kontoripakett tekstitöötluse, arvutustabelite, esitluste, joonistusrakenduse ja muuga. See ühildub Microsoft Office'i failidega, nii et see on suurepärane viis nende Wordi dokumentide avamiseks.

LibreOffice'i käivitad rakenduste käivitaja kaudu (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchy enda ülilihtne esitlusrakendus. Sinu esitlus on üks Markdowni fail, mille kõrval on selle pildid ja videod: kirjuta iga slaid reaalajas eelvaate alla, lohista slaidid õigesse järjekorda, seejärel esitle täisekraanil või ekspordi PDF-i ja PowerPointi. See võtab isegi sinu Omarchy teema üle.

Hype'i käivitad rakenduste käivitaja kaudu (`Super + Space`). Kõigi otseteede nägemiseks vajuta selle sees `?`.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchy enda ülilihtne viis PDF-ide allkirjastamiseks ja täitmiseks. Pane oma salvestatud allkiri, tekst ja tänane kuupäev lehel ükskõik kuhu ning salvesta seejärel allkirjastatud koopia originaali kõrvale. Vaata, kuidas seda teha, jaotisest [PDF-ide täitmine](27-filling-out-pdfs.md).

Signedi käivitad rakenduste käivitaja kaudu (`Super + Space`) või avad sellega failihaldurist PDF-i.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) on Omarchy enda 3D-malemäng. Mängi sõbraga samas arvutis või sisseehitatud vastase vastu kolmel tasemel, nelja skulptuurilise komplektiga, millest igaüks liigub omal moel: orbitaalsõidukid, nikerdatud puit ja elevandiluu, metsloomad ja kommid. Mängudel pole kella ja need salvestuvad pärast iga käiku.

Checkmate'i käivitad rakenduste käivitaja kaudu (`Super + Space`), kus see on loetletud nimega Chess. Kõigi otseteede nägemiseks vajuta selle sees `?`.

## Cards

[Cards](https://github.com/omacom/cards) on Omarchy enda Klondike pasjanss. Võta kolm kaarti, läbimiste arv pole piiratud, neljas kaardisarjas: üks on joonistatud sinu teema värvides ja kolmel on oma välimus. Klõpsa kaardil ja seejärel kohal, kuhu see läheb, lohista seda või topeltklõpsa, et saata see parimasse kohta. Mängud salvestuvad pärast iga käiku.

Cardsi käivitad rakenduste käivitaja kaudu (`Super + Space`). Kõigi otseteede nägemiseks klõpsa selle nimel või vajuta `?`.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchy enda ülilihtne kalkulaator, mis avaneb hõljuvas aknas.

Omacalci käivitad klahvidega `Super + Shift + Q` (või kalkulaatori klahviga, kui sinu klaviatuuril selline on).

## Signal

[Signal](https://signal.org/) on otsast lõpuni krüpteeritud sõnumside teerajaja ja suurepärane suhtlusvõimalus igaühele, kes eelistab mitte minna läbi ühe suure tehnoloogiakonglomeraadi.

Signali käivitad klahvidega `Super + Shift + G`. See ei kuulu põhinstalli hulka, nii et esimesel korral, kui seda vajutad, pakub Omarchy selle sinu eest installimist (see on ka Omarchy menüüs jaotuses _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchy enda ülilihtne pildivaatur ja meediumipleier: üks aken sinu fotode, videote ja muusika jaoks. Ava foto ja nooleklahvid liiguvad läbi ülejäänud kausta, `N` ja `P` teevad seda kõige puhul ning `Ctrl + M` näitab tervet kausta ruudustikuna. See näitab ka HEIC-, AVIF- ja JPEG XL fotosid ning jätkab pikemate asjade puhul sealt, kus pooleli jäid.

Vajuta `F` täisekraani jaoks, `E` pildi töötlemiseks rakenduses Omasnap või video kärpimiseks rakenduses Omacut, `Ctrl + P` pildi printimiseks ja `Delete` faili prügikasti teisaldamiseks (`Ctrl + Z` toob selle tagasi). Kõigi otseteede nägemiseks vajuta selle sees `?`.

Omaview käivitad nimega _Media Viewer_ rakenduste käivitaja kaudu (`Super + Space`) või tee lihtsalt failihalduris pildil, videol või laulul topeltklõps.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchy enda ülilihtne videokärpija. Kui sul on vaja ainult klipi algus ja lõpp ära lõigata, on see parem kui täisväärtusliku videoredaktori käivitamine.

Omacuti käivitad rakenduste käivitaja kaudu (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchy enda ülilihtne veebikaamera salvesti. Vali oma kaamera ja mikrofon üks kord, seejärel vajuta salvestamiseks `Space` ning sama võtte peatamiseks ja jätkamiseks vajuta seda uuesti. See salvestab alati sinu kaamera kõrgeima eraldusvõimega, koos reaalajas mikrofoni mõõdikuga, et saaksid enne alustamist oma tasemed üle kontrollida.

Peata võte ja see avaneb kohe sisseehitatud redaktoris. Topeltklõpsa klipil selle poolitamiseks, lohista käepidemeid iga osa kärpimiseks ja eemalda osad, mida sa ei taha. Seejärel salvesta see MP4-na. Sinu algne salvestus säilib, kuni sa selle ära viskad, nii et saad alati tagasi tulla ja seda teisiti lõigata.

Monologue'i käivitad rakenduste käivitaja kaudu (`Super + Space`).
