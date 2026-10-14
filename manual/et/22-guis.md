# GUI-d

## Failid

Files (Nautilus) on graafiline failihaldur. `Super + Shift + F` avab selle ja `Super + Shift + Alt + F` avab selle kaustas, kus sinu terminal asub, mis säästab palju klõpsimist. `Ctrl + L` võimaldab sisestada tee ja `Space` vajutamine suvalisel failil annab kiire eelvaate ilma midagi avamata.

Ühenda USB-pulk või SD-kaart ja see ühendatakse automaatselt, nii et see ilmub lihtsalt külgribale. Kõikide keerukamate toimingute jaoks — draivi vormindamine, SMART seisundi kontrollimine, partitsioonide loomine — käivita rakenduste käivitajast (`Super + Space`) _Disks_.

Topeltklõps järgib mõistlikke vaikesätteid: pildid avanevad imv-s, video mpv-s, PDF-id Document Vieweris ja lihttekst Neovimis.

## Disktree

Kui ketas saab täis ja sul pole aimugi, mis seda sööb, käivita rakenduste käivitajast (`Super + Space`) [Disktree](https://github.com/tobi/disktree). See näitab sinu kodukausta graafilist puukaarti. Suuremad blokid võtavad rohkem ruumi; liigu kaustades klaviatuuri või hiirega, märgi, mis peaks kaduma, ja vaata oma valikud enne millegi eemaldamist üle. Kogu ketta skannimiseks käivita `disktree --disk`.

## Obsidian

[Obsidian](https://obsidian.md/) on tasuta ja väga laiendatav märkmete tegemise rakendus, mis kasutab salvestamiseks lihtsaid Markdown-faile.

Obsidian on tasuta kõikidel eesmärkidel, sealhulgas isiklikuks, äriliseks ja mittetulunduslikuks kasutamiseks.

Obsidian pakub ka [ärilist lisandmoodulit sünkroonimiseks](https://obsidian.md/sync) mobiilirakendustega iOS-is ja Androidis. (https://obsidian.md/pricing).

Obsidiani käivitad kombinatsiooniga `Super + Shift + O`. Teema sünkroonimise kasutamiseks pead seadetes valima teema `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchy enda surnult lihtne Markdowni kirjutamisrakendus. Ei mingeid hoidlaid, ei mingeid pistikprogramme, lihtsalt sina ja sõnad.

Omawrite'i käivitad kombinatsiooniga `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on põhiline pilditöötlustööriist, mis sobib suurepäraselt kärpimiseks, suuruse muutmiseks ja muudeks põhilisteks manipulatsioonideks. Ära ainult Photoshopi alternatiivi oota. Kuid sellel on siiski Magic Wand ja kihid!

Pinta käivitad rakenduste käivitaja kaudu (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemarakendus, mis saab taustapildist värve eraldada ja muuta need terviklikuks, ühtseks teemaks. See on lihtsaim viis [oma teema tegemiseks](43-making-your-own-theme.md).

Aetheri käivitad rakenduste käivitaja kaudu (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) võimaldab saata faile teistele samas võrgus töötavatele seadmetele, mis rakendust kasutavad, nagu Apple'i AirDrop. See on aga platvormideülene, nii et saad saata faile Windowsi, macOS-i, Androidi, iOS-i ja muidugi Linuxi vahel.

Jagamenüü saad avada kombinatsiooniga `Super + Ctrl + S` või Omarchy menüüs jaotises _Käivita > Jaga_. See annab sulle neli valikut:

- **Clipboard** saadab kopeeritu tekstifailina. Suurepärane lingi või koodijupi telefoni saamiseks ilma endale e-kirja saatmata.
- **File** avab failivalija, kus saad korraga mitu valida.
- **Folder** saadab terve kausta.
- **Receive** avab õige LocalSendi, et teine seade saaks sulle midagi saata.

Sama asi töötab terminalist käskudega `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jäta tee ära ja saad valija.

Saad saata ka otse failihaldurist: tee Nautiluses suvalisel valikul paremklõps ja vali _Send via LocalSend_.

Omarchy tulemüür on vaikimisi suletud, välja arvatud LocalSendi port, nii et see töötab värskel paigaldusel kohe. Vaata [turvalisus](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on terviklik kontoripakett tekstitöötluse, tabelarvutuse, esitluste, joonistusrakenduse ja muuga. See ühildub Microsoft Office'i failidega, nii et see on suurepärane viis nende Wordi dokumentide avamiseks.

LibreOffice'i käivitad rakenduste käivitaja kaudu (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchy enda surnult lihtne esitlusrakendus. Sinu esitlus on üks Markdown-fail koos piltide ja videotega selle kõrval: kirjuta iga slaid otse-eelvaate alla, lohista slaidid järjekorda, seejärel esinda täisekraanil või ekspordi PDF-i ja PowerPointi. See võtab isegi sinu Omarchy teema üle.

Hype'i käivitad rakenduste käivitaja kaudu (`Super + Space`). Vajuta selle sees `?`, et näha iga otseteed.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchy enda surnult lihtne viis PDF-ide allkirjastamiseks ja täitmiseks. Pane oma salvestatud allkiri, tekst ja tänane kuupäev lehel suvalisse kohta, seejärel salvesta allkirjastatud koopia originaali kõrvale. Kuidas, vaata jaotisest [PDF-ide täitmine](27-filling-out-pdfs.md).

Signedi käivitad rakenduste käivitaja kaudu (`Super + Space`) või ava sellega PDF failihaldurist.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchy enda surnult lihtne kalkulaator, mis avaneb ujuvas aknas.

Omacalci käivitad kombinatsiooniga `Super + Ctrl + Q` (või kalkulaatori klahviga, kui sinu klaviatuuril see on).

## Signal

[Signal](https://signal.org/) on E2E krüpteeritud sõnumside teerajaja ja suurepärane suhtlusvõimalus kõigile, kes eelistaksid mitte minna läbi ühe suure tehnoloogiakonglomeraadi.

Signali käivitad kombinatsiooniga `Super + Shift + G`. See ei kuulu põhipaigaldusse, nii et esimesel korral, kui seda vajutad, pakub Omarchy selle sulle paigaldada (see on ka Omarchy menüüs jaotises _Paigalda > Service_).

## mpv

[mpv](https://mpv.io/) on lihtne, kiire meediapleier, mis mängib peaaegu kõike igast allikast. Suurepärane videote vaatamiseks.

mpv käivitad rakenduste käivitaja kaudu (`Super + Space`) või lihtsalt topeltklõpsa failihalduris videol.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchy enda surnult lihtne videotrimmer. Kui sul on vaja ainult klipi algus ja lõpp ära lõigata, on see parem kui täieliku videoredaktori käivitamine.

Omacuti käivitad rakenduste käivitaja kaudu (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchy enda surnult lihtne veebikaamera salvestaja. Vali kaamera ja mikrofon üks kord, seejärel vajuta salvestamiseks `Space` ja uuesti, et sama võte peatada ja jätkata. See salvestab alati sinu kaamera kõrgeima eraldusvõimega, koos reaalajas mikrofoni mõõturiga, et saaksid enne alustamist tasemeid kontrollida.

Peata võte ja see avaneb kohe sisseehitatud redaktoris. Topeltklõpsa klippi selle poolitamiseks, lohista käepidemeid iga tüki kärpimiseks ja eemalda osad, mida ei soovi. Seejärel salvesta see MP4-na. Sinu algne salvestus säilib, kuni selle ära viskad, nii et saad alati tagasi tulla ja seda teistmoodi lõigata.

Monologue'i käivitad rakenduste käivitaja kaudu (`Super + Space`).
