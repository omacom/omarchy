# GUI-d

## Failid

Failid (Nautilus) on graafiline failihaldur. `Super + Shift + F` avab selle ja `Super + Shift + Alt + F` avab selle kataloogis, kus teie terminal parajasti asub, mis säästab palju klõpsamist. `Ctrl + L` võimaldab teil tee sisestada ja mis tahes failil `Space` vajutamine annab teile kiire eelvaate ilma midagi avamata.

Ühendage USB-mälupulk või SD-kaart ja see monteeritakse automaatselt, nii et see ilmub lihtsalt külgribale. Kõige keerukama jaoks — draivi vormindamine, SMART-i seisundi kontrollimine, partitsioonide loomine — käivitage rakenduste käivitajast (`Super + Space`) _Disks_.

Topeltklõps järgib mõistlikke vaikesätteid: pildid, videod ja muusika avanevad rakenduses Omaview, PDF-id rakenduses Document Viewer, Markdown rakenduses Omawrite ja lihttekst redaktoris, mis on valitud jaotises _Setup > Default > Editor_.

## Disktree

Kui draiv saab täis ja teil pole aimugi, mis seda õgib, käivitage rakenduste käivitajast (`Super + Space`) [Disktree](https://github.com/tobi/disktree). See näitab teie kodukataloogi graafilist puukaarti. Suuremad plokid võtavad rohkem ruumi; liikuge kataloogidesse klaviatuuri või hiirega, märkige, mis peab minema, ja vaadake valikud enne millegi eemaldamist üle. Kogu ketta skannimiseks käivitage `disktree --disk`.

## Obsidian

[Obsidian](https://obsidian.md/) on tasuta ja väga laiendatav märkmete tegemise rakendus, mis kasutab salvestamiseks lihtsaid Markdowni faile.

Obsidian on tasuta kõigeks otstarbeks, sealhulgas isiklikuks, äriliseks ja mittetulunduslikuks kasutamiseks.

Obsidian pakub ka [ärilist lisandmoodulit sünkroonimiseks](https://obsidian.md/sync) iOS-i ja Androidi mobiilirakendustega. (https://obsidian.md/pricing).

Käivitate Obsidiani klahvidega `Super + Shift + O`. Teema sünkroonimise kasutamiseks peate seadetes valima teema `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchy enda ülihtne Markdowni kirjutamisrakendus. Ei mingeid hoidlaid, ei mingeid pistikprogramme, ainult teie ja sõnad.

Käivitate Omawrite'i klahvidega `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on lihtne pilditöötlustööriist, mis sobib suurepäraselt kärpimiseks, suuruse muutmiseks ja muudeks lihtsateks töötlusteks. Ärge ainult Photoshopi alternatiivi oodake. Aga sellel on ikkagi Magic Wand ja kihid!

Käivitate Pinta rakenduste käivitaja kaudu (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemarakendus, mis suudab taustapildist värve eraldada ja muuta need terviklikuks, sidusaks teemaks. See on lihtsaim viis [oma teema tegemiseks](43-making-your-own-theme.md).

Käivitate Aetheri rakenduste käivitaja kaudu (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) võimaldab teil saata faile teistesse samas võrgus rakendust kasutavatesse seadmetesse, nagu Apple'i AirDrop. See on aga platvormiülene, nii et saate faile saata Windowsi, macOS-i, Androidi, iOS-i ja muidugi Linuxiga seadmetesse ja neist vastu võtta.

Saate avada menüü Share klahvidega `Super + Ctrl + S` või Omarchy menüüs jaotises _Trigger > Share_. See annab teile neli valikut:

- **Clipboard** saadab tekstifailina selle, mille olete kopeerinud. Suurepärane lingi või koodijupi telefoni saamiseks ilma endale e-kirja saatmata.
- **File** avab failivalija, kus saate korraga valida mitu faili.
- **Folder** saadab terve kataloogi.
- **Receive** avab LocalSendi enda, et teine seade saaks teile midagi saata.

Sama toimib terminalist käskudega `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jätke tee ära ja saate failivalija.

Faile saate saata ka otse failihaldurist: paremklõpsake Nautiluses mis tahes valikul ja valige _Send via LocalSend_.

Omarchy tulemüür on vaikimisi suletud, välja arvatud LocalSendi port, nii et see toimib värskel installil kohe karbist välja. Vt [turvalisus](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on terviklik kontoripakett tekstitöötluse, arvutustabelite, esitluste, joonistusrakenduse ja muuga. See ühildub Microsoft Office'i failidega, nii et see on suurepärane viis nende Wordi dokumentide avamiseks.

Käivitate LibreOffice'i rakenduste käivitaja kaudu (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchy enda ülihtne esitlusrakendus. Teie esitlus on üks Markdowni fail, mille pildid ja videod on selle kõrval: kirjutage iga slaid reaalajas eelvaate alla, lohistage slaidid õigesse järjekorda, seejärel esitage täisekraanil või eksportige PDF-i ja PowerPointi. See võtab isegi teie Omarchy teema üle.

Käivitate Hype'i rakenduste käivitaja kaudu (`Super + Space`). Vajutage selle sees `?`, et näha kõiki otseteid.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchy enda ülihtne viis PDF-ide allkirjastamiseks ja täitmiseks. Pange oma salvestatud allkiri, tekst ja tänane kuupäev lehel suvalisse kohta, seejärel salvestage allkirjastatud koopia originaali kõrvale. Vt [PDF-ide täitmine](27-filling-out-pdfs.md).

Käivitate Signedi rakenduste käivitaja kaudu (`Super + Space`) või avage sellega failihaldurist PDF.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) on Omarchy enda 3D-malemäng. Mängige sõbraga samas arvutis või sisseehitatud vastasega kolmel tasemel, nelja kujundatud komplektiga, millest igaüks liigub omal moel: orbitaalsõidukid, nikerdatud puit ja elevandiluu, metsloomad ja kommid. Mängudel pole kella ja need salvestatakse pärast iga käiku.

Käivitate Checkmate'i rakenduste käivitaja kaudu (`Super + Space`). Vajutage selle sees `?`, et näha kõiki otseteid.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchy enda ülihtne kalkulaator, mis avaneb hõljuvas aknas.

Käivitate Omacalci klahvidega `Super + Shift + Q` (või kalkulaatoriklahviga, kui teie klaviatuuril selline on).

## Signal

[Signal](https://signal.org/) on E2E krüpteeritud sõnumside teerajaja ja suurepärane suhtlusvõimalus kõigile, kes eelistaksid mitte minna läbi ühe suure tehnoloogiakonglomeraadi.

Käivitate Signali klahvidega `Super + Shift + G`. See ei kuulu põhinstalli hulka, nii et esimesel korral, kui seda vajutate, pakub Omarchy selle teile installimist (see on ka Omarchy menüüs jaotises _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchy enda ülihtne pildivaatur ja meediumipleier: üks aken teie fotode, videote ja muusika jaoks. Avage foto ja nooleklahvid liiguvad läbi ülejäänud kausta, `N` ja `P` teevad seda kõige puhul ning `Ctrl + M` näitab tervet kausta ruudustikuna. See näitab ka HEIC, AVIF ja JPEG XL fotosid ning jätkab pikkade asjade puhul sealt, kus pooleli jäite.

Vajutage `F` täisekraani jaoks, `E` pildi redigeerimiseks rakenduses Omasnap või video trimmimiseks rakenduses Omacut, `Ctrl + P` pildi printimiseks ja `Delete`, et fail prügikasti teisaldada (`Ctrl + Z` toob selle tagasi). Vajutage selle sees `?`, et näha kõiki otseteid.

Käivitate Omaview rakenduste käivitaja kaudu nimega _Media Viewer_ (`Super + Space`) või topeltklõpsake lihtsalt failihalduris pildil, videol või laulul.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchy enda ülihtne videotrimmer. Kui teil on vaja ainult klipi algus ja lõpp ära lõigata, võidab see täiemahulise videoredaktori käivitamise.

Käivitate Omacuti rakenduste käivitaja kaudu (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchy enda ülihtne veebikaamera salvesti. Valige oma kaamera ja mikrofon üks kord, seejärel vajutage salvestamiseks `Space` ja uuesti, et sama võte peatada ja jätkata. See salvestab alati teie kaamera kõrgeima eraldusvõimega koos reaalajas mikrofoni mõõdikuga, et saaksite enne alustamist tasemeid kontrollida.

Peatage võte ja see avaneb kohe sisseehitatud redaktoris. Topeltklõpsake klippi selle poolitamiseks, lohistage käepidemeid iga tüki trimmimiseks ja eemaldage osad, mida te ei soovi. Seejärel salvestage see MP4-na. Teie algne salvestis säilitatakse, kuni selle ära viskate, nii et saate alati tagasi tulla ja seda teisiti lõigata.

Käivitate Monologue'i rakenduste käivitaja kaudu (`Super + Space`).
