# GUI-d

## Files

Files (Nautilus) on graafiline failihaldur. `Super + Shift + F` avab selle ja `Super + Shift + Alt + F` avab selle kaustas, kus su terminal parasjagu on, mis säästab palju klõpsimist. `Ctrl + L` laseb sul sisestada tee ning mis tahes failil `Space` vajutamine annab sulle kiire eelvaate ilma midagi avamata.

Ühenda USB-mälupulk või SD-kaart ja see haagitakse automaatselt, nii et see ilmub lihtsalt külgribale. Millegi põhjalikuma jaoks — draivi vormindamine, SMART-i seisundi kontrollimine, partitsioonide loomine — käivita rakenduste käivitusmenüüst (`Super + Space`) _Disks_.

Topeltklõps järgib mõistlikke vaikesätteid: pildid, videod ja muusika avanevad rakenduses Omaview, PDF-id rakenduses Document Viewer, Markdown rakenduses Omawrite ning lihttekst redaktoris, mis on valitud jaotises _Setup > Default > Editor_.

## Disktree

Kui draiv saab täis ja sul pole aimugi, mis seda sööb, käivita rakenduste käivitusmenüüst (`Super + Space`) [Disktree](https://github.com/tobi/disktree). See näitab sinu kodukausta graafilist puukaarti. Suuremad plokid võtavad rohkem ruumi; liigu kaustadesse klaviatuuri või hiirega, märgi, mis peab minema, ja vaata oma valikud enne läbi, kui midagi eemaldad. Kogu ketta skannimiseks käivita `disktree --disk`.

## Obsidian

[Obsidian](https://obsidian.md/) on tasuta ja väga laiendatav märkmete tegemise rakendus, mis kasutab salvestamiseks lihtsaid Markdowni faile.

Obsidian on tasuta kõigeks otstarbeks, sealhulgas isiklikuks, äriliseks ja mittetulunduslikuks kasutamiseks.

Obsidian pakub ka [ärilist lisandmoodulit sünkroonimiseks](https://obsidian.md/sync) iOS-i ja Androidi mobiilirakendustega. (https://obsidian.md/pricing).

Obsidiani käivitad klahvidega `Super + Shift + O`. Teema sünkroonimise kasutamiseks pead sätete all valima teema `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchy enda ülilihtne Markdowni kirjutamisrakendus. Ei mingeid hoidlaid, ei mingeid pistikprogramme, ainult sina ja sõnad.

Omawrite'i käivitad klahvidega `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on lihtne pilditöötlustööriist, mis sobib suurepäraselt kärpimiseks, suuruse muutmiseks ja muudeks lihtsateks töötlusteks. Ära ainult Photoshopi alternatiivi oota. Aga sellel on ikkagi Magic Wand ja kihid!

Pinta käivitad rakenduste käivitusmenüü kaudu (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemarakendus, mis oskab taustapildist värvid välja võtta ja neist tervikliku, ühtse teema teha. See on lihtsaim viis [oma teema tegemiseks](43-making-your-own-theme.md).

Aetheri käivitad rakenduste käivitusmenüü kaudu (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) laseb sul saata faile teistesse samas võrgus olevatesse seadmetesse, kus rakendus töötab, nagu Apple'i AirDrop. See on aga platvormiülene, nii et saad faile saata Windowsi, macOS-i, Androidi, iOS-i ja muidugi Linuxi vahel ning neile kõigile.

Share menüü saad avada klahvidega `Super + Ctrl + S` või Omarchy menüüs jaotises _Trigger > Share_. See annab sulle neli valikut:

- **Clipboard** saadab kõik, mille oled kopeerinud, tekstifailina. Suurepärane, et link või koodijupp telefoni saada ilma endale e-kirja saatmata.
- **File** avab failivalija, kus saad korraga mitu valida.
- **Folder** saadab terve kausta.
- **Receive** avab päris LocalSendi, et teine seade saaks sulle midagi saata.

Sama asi töötab terminalist käskudega `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jäta tee ära ja saad failivalija.

Saata saad ka otse failihaldurist: tee Nautiluses mis tahes valikul paremklõps ja vali _Send via LocalSend_.

Omarchy tulemüür on vaikimisi suletud, välja arvatud LocalSendi port, nii et värskel paigaldusel töötab see kohe karbist välja. Vaata [turvalisust](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täielik kontoripakett tekstitöötluse, arvutustabelite, esitluste, joonistusrakenduse ja muuga. See ühildub Microsoft Office'i failidega, nii et see on suurepärane viis nende Wordi dokumentide avamiseks.

LibreOffice'i käivitad rakenduste käivitusmenüü kaudu (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchy enda ülilihtne esitlusrakendus. Sinu esitlus on üksainus Markdowni fail koos selle kõrval olevate piltide ja videotega: kirjuta iga slaid reaalajas eelvaate alla, lohista slaidid õigesse järjekorda, seejärel esitle täisekraanil või ekspordi PDF-i ja PowerPointi. See võtab üles isegi sinu Omarchy teema.

Hype'i käivitad rakenduste käivitusmenüü kaudu (`Super + Space`). Vajuta selle sees `?`, et näha kõiki otseteid.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchy enda ülilihtne viis PDF-ide allkirjastamiseks ja täitmiseks. Pane oma salvestatud allkiri, tekst ja tänane kuupäev lehel kuhu tahes, seejärel salvesta allkirjastatud koopia originaali kõrvale. Vaata, kuidas seda teha, jaotisest [PDF-ide täitmine](27-filling-out-pdfs.md).

Signedi käivitad rakenduste käivitusmenüü kaudu (`Super + Space`) või ava sellega PDF failihaldurist.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) on Omarchy enda 3D-malemäng. Mängi sõbraga samas arvutis või sisseehitatud vastasega kolmel tasemel, nelja skulptuurse komplektiga, millest igaüks liigub omal moel: orbiidisõidukid, nikerdatud puit ja elevandiluu, metsaolendid ja kommid. Mängudel pole kella ja need salvestuvad pärast iga käiku.

Checkmate'i käivitad rakenduste käivitusmenüü kaudu (`Super + Space`), kus see on loetletud nimega Chess. Vajuta selle sees `?`, et näha kõiki otseteid.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchy enda ülilihtne kalkulaator, mis avaneb hõljuvas aknas.

Omacalci käivitad klahvidega `Super + Shift + Q` (või kalkulaatoriklahviga, kui su klaviatuuril selline on).

## Signal

[Signal](https://signal.org/) on otsast lõpuni krüpteeritud sõnumside teerajaja ja suurepärane suhtlusvõimalus kõigile, kes eelistaksid mitte minna läbi ühe suure tehnoloogiakonglomeraadi.

Signali käivitad klahvidega `Super + Shift + G`. See ei kuulu põhipaigalduse hulka, nii et esimesel korral, kui seda vajutad, pakub Omarchy selle sulle paigaldada (see on ka Omarchy menüüs jaotises _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchy enda ülilihtne pildivaatur ja meediumipleier: üks aken sinu fotode, videote ja muusika jaoks. Ava foto ja nooleklahvid liiguvad läbi ülejäänud kausta, `N` ja `P` teevad seda kõige puhul ning `Ctrl + M` näitab tervet kausta ruudustikuna. See näitab ka HEIC-, AVIF- ja JPEG XL fotosid ning jätkab pikemate asjade puhul sealt, kus pooleli jäid.

Vajuta täisekraani jaoks `F`, `E`, et pilti Omasnapis muuta või videot Omacutis kärpida, `Ctrl + P`, et pilt printida, ja `Delete`, et fail prügikasti teisaldada (`Ctrl + Z` toob selle tagasi). Vajuta selle sees `?`, et näha kõiki otseteid.

Omaview käivitad nimega _Media Viewer_ rakenduste käivitusmenüü kaudu (`Super + Space`) või tee lihtsalt failihalduris pildil, videol või laulul topeltklõps.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchy enda ülilihtne videokärpija. Kui sul on vaja ainult klipi algus ja lõpp maha lõigata, võidab see täiemahulise videoredaktori käivitamise.

Omacuti käivitad rakenduste käivitusmenüü kaudu (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchy enda ülilihtne veebikaamera salvesti. Vali oma kaamera ja mikrofon üks kord, seejärel vajuta salvestamiseks `Space` ning uuesti, et sama võte peatada ja jätkata. See salvestab alati sinu kaamera kõrgeima eraldusvõimega, reaalajas mikrofoni tasememõõturiga, et saaksid enne alustamist oma tasemed üle kontrollida.

Peata võte ja see avaneb kohe sisseehitatud redaktoris. Tee klipil topeltklõps, et see poolitada, lohista käepidemeid, et iga tükki kärpida, ja eemalda osad, mida sa ei taha. Seejärel salvesta see MP4-na. Sinu algne salvestis säilitatakse, kuni sa selle ära viskad, nii et saad alati tagasi tulla ja seda teisiti lõigata.

Monologue'i käivitad rakenduste käivitusmenüü kaudu (`Super + Space`).
