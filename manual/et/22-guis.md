# GUI-d

## Files

Files (Nautilus) on graafiline failihaldur. `Super + Shift + F` avab selle ja `Super + Shift + Alt + F` avab selle kataloogis, kus sinu terminal parasjagu asub, mis säästab palju klõpsamist. `Ctrl + L` laseb sul tee sisestada ja mis tahes failil `Space` vajutamine annab sulle kiire eelvaate ilma midagi avamata.

Ühenda USB-mälupulk või SD-kaart ja see ühendatakse automaatselt, nii et see ilmub lihtsalt külgribale. Millegi keerukama jaoks — draivi vormindamine, SMART-i seisundi kontrollimine, partitsioonide loomine — käivita rakenduste käivitajast (`Super + Space`) rakendus _Disks_.

Topeltklõps järgib mõistlikke vaikevalikuid: pildid avanevad imv-s, video mpv-s, PDF-id Document Vieweris ja lihttekst Neovimis.

## Disktree

Kui draiv saab täis ja sul pole aimugi, mis seda õgib, käivita rakenduste käivitajast (`Super + Space`) [Disktree](https://github.com/tobi/disktree). See näitab sinu kodukataloogi graafilist puukaarti. Suuremad plokid võtavad rohkem ruumi; liigu kataloogidesse klaviatuuri või hiirega, märgi ära, mis peab minema, ja vaata oma valikud enne üle, kui midagi eemaldad. Kogu ketta skannimiseks käivita `disktree --disk`.

## Obsidian

[Obsidian](https://obsidian.md/) on tasuta ja väga laiendatav märkmete tegemise rakendus, mis kasutab salvestamiseks lihtsaid Markdowni faile.

Obsidian on tasuta kõigeks otstarbeks, sealhulgas isiklikuks, äriliseks ja mittetulunduslikuks kasutamiseks.

Obsidian pakub ka [ärilist lisandmoodulit sünkroonimiseks](https://obsidian.md/sync) iOS-i ja Androidi mobiilirakendustega. (https://obsidian.md/pricing).

Obsidiani käivitad klahvidega `Super + Shift + O`. Teema sünkroonimise kasutamiseks pead valima seadete alt teema `Omarchy`.

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

[LocalSend](https://localsend.org/) laseb sul saata faile teistele samas võrgus olevatele seadmetele, kus rakendus töötab, nagu Apple'i AirDrop. See on aga platvormiülene, nii et saad faile saata Windowsi, macOS-i, Androidi, iOS-i ja muidugi Linuxi vahel ning neile.

Menüü Share saad avada klahvidega `Super + Ctrl + S` või Omarchy menüüs valiku _Trigger > Share_ alt. See annab sulle neli valikut:

- **Clipboard** saadab selle, mille oled kopeerinud, tekstifailina. Suurepärane selleks, et link või koodijupp telefoni saada ilma endale e-kirja saatmata.
- **File** avab failivalija, kus saad valida mitu faili korraga.
- **Folder** saadab terve kataloogi.
- **Receive** avab päris LocalSendi, et teine seade saaks sulle midagi saata.

Sama asi töötab terminalist käskudega `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jäta tee ära ja saad valija.

Saad saata ka otse failihaldurist: tee Nautiluses valikul paremklõps ja vali _Send via LocalSend_.

Omarchy tulemüür on vaikimisi suletud, välja arvatud LocalSendi port, nii et see töötab värskel paigaldusel kohe karbist võttes. Vaata [turvalisust](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täielik kontoripakett tekstitöötluse, arvutustabelite, esitluste, joonistusrakenduse ja muuga. See ühildub Microsoft Office'i failidega, nii et see on suurepärane viis nende Wordi dokumentide avamiseks.

LibreOffice'i käivitad rakenduste käivitaja kaudu (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchy enda ülilihtne esitlusrakendus. Sinu esitlus on üks Markdowni fail, mille pildid ja videod on selle kõrval: kirjuta iga slaid reaalajas eelvaate alla, lohista slaidid järjekorda, seejärel esitle täisekraanil või ekspordi PDF-i ja PowerPointi. See võtab isegi sinu Omarchy teema üle.

Hype'i käivitad rakenduste käivitaja kaudu (`Super + Space`). Kõigi kiirklahvide nägemiseks vajuta selle sees `?`.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchy enda ülilihtne viis PDF-ide allkirjastamiseks ja täitmiseks. Pane oma salvestatud allkiri, tekst ja tänane kuupäev lehel ükskõik kuhu ning salvesta seejärel allkirjastatud koopia originaali kõrvale. Vaata, kuidas, peatükist [PDF-ide täitmine](27-filling-out-pdfs.md).

Signedi käivitad rakenduste käivitaja kaudu (`Super + Space`) või avad sellega failihaldurist PDF-i.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchy enda ülilihtne kalkulaator, mis avaneb hõljuvas aknas.

Omacalci käivitad klahvidega `Super + Shift + Q` (või kalkulaatoriklahviga, kui sinu klaviatuuril selline on).

## Signal

[Signal](https://signal.org/) on E2E krüpteeritud sõnumside pioneer ja suurepärane suhtlusvõimalus kõigile, kes eelistaksid suurte tehnoloogiakonglomeraatide kaudu mitte minna.

Signali käivitad klahvidega `Super + Shift + G`. See ei kuulu põhipaigalduse hulka, nii et esimesel korral, kui seda vajutad, pakub Omarchy selle sulle paigaldada (see on ka Omarchy menüüs valiku _Install > Service_ all).

## mpv

[mpv](https://mpv.io/) on lihtne ja kiire meediumipleier, mis mängib peaaegu kõike peaaegu igast allikast. Suurepärane videote vaatamiseks.

mpv käivitad rakenduste käivitaja kaudu (`Super + Space`) või lihtsalt topeltklõpsuga failihalduris videol.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchy enda ülilihtne videolõikur. Kui sul on vaja ainult klipi algus ja lõpp ära lõigata, võidab see täiemahulise videoredaktori käivitamise.

Omacuti käivitad rakenduste käivitaja kaudu (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchy enda ülilihtne veebikaamera salvestaja. Vali oma kaamera ja mikrofon üks kord, seejärel vajuta salvestamiseks `Space` ja sama võtte peatamiseks ja jätkamiseks vajuta seda uuesti. See salvestab alati sinu kaamera kõrgeima eraldusvõimega, koos reaalajas mikrofoni mõõdikuga, et saaksid enne alustamist oma tasemed üle kontrollida.

Peata võte ja see avaneb kohe sisseehitatud redaktoris. Klipi poolitamiseks tee sellel topeltklõps, iga tüki kärpimiseks lohista käepidemeid ja eemalda osad, mida sa ei taha. Seejärel salvesta see MP4-na. Sinu algne salvestis säilitatakse seni, kuni selle ära viskad, nii et saad alati tagasi tulla ja seda teisiti lõigata.

Monologue'i käivitad rakenduste käivitaja kaudu (`Super + Space`).
