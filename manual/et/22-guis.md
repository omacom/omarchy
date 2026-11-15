# GUI-d

## Failid

Files (Nautilus) on graafiline failihaldur. `Super + Shift + F` avab selle ja `Super + Shift + Alt + F` avab selle kataloogis, kus su terminal parasjagu asub, mis säästab palju klikkimist. `Ctrl + L` laseb sul tee sisestada ja `Space` vajutamine mis tahes failil annab sulle kiire eelvaate ilma midagi avamata.

Ühenda USB-mälupulk või SD-kaart ja see haagitakse automaatselt, nii et see ilmub lihtsalt külgribale. Kõige keerukama jaoks — ketta vormindamine, SMART-i seisundi kontrollimine, partitsioonide loomine — käivita rakenduste käivitajast (`Super + Space`) rakendus _Disks_.

Topeltklõps järgib mõistlikke vaikevalikuid: pildid, videod ja muusika avanevad rakenduses Omaview, PDF-id rakenduses Document Viewer ja lihttekst rakenduses Neovim.

## Disktree

Kui ketas saab täis ja sul pole aimugi, mis seda sööb, käivita rakenduste käivitajast (`Super + Space`) [Disktree](https://github.com/tobi/disktree). See näitab sinu kodukataloogi graafilist puukaarti. Suuremad plokid võtavad rohkem ruumi; liigu kataloogidesse klaviatuuri või hiirega, märgi ära, mis peab minema, ja vaata oma valikud enne millegi eemaldamist üle. Kogu ketta skannimiseks käivita `disktree --disk`.

## Obsidian

[Obsidian](https://obsidian.md/) on tasuta ja väga laiendatav märkmete tegemise rakendus, mis kasutab salvestamiseks lihtsaid Markdowni faile.

Obsidian on tasuta kõigeks otstarbeks, sealhulgas isiklikuks, äriliseks ja mittetulunduslikuks kasutamiseks.

Obsidian pakub ka [tasulist sünkroonimise lisandmoodulit](https://obsidian.md/sync) mobiilirakendustega iOS-il ja Androidil. (https://obsidian.md/pricing).

Sa käivitad Obsidiani klahvidega `Super + Shift + O`. Teema sünkroonimise kasutamiseks pead seadete all valima `Omarchy` teema.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchy enda ülilihtne Markdowni kirjutamisrakendus. Ei mingeid hoidlaid, ei mingeid pluginaid, ainult sina ja sõnad.

Sa käivitad Omawrite'i klahvidega `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on lihtne pilditöötlustööriist, mis sobib suurepäraselt kärpimiseks, suuruse muutmiseks ja muudeks lihtsateks töötlusteks. Ära lihtsalt oota Photoshopi alternatiivi. Aga sellel on ikkagi Magic Wand ja kihid!

Sa käivitad Pinta rakenduste käivitaja kaudu (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemarakendus, mis suudab taustapildilt värvid välja võtta ja neist tervikliku, ühtse teema teha. See on lihtsaim viis [oma teema tegemiseks](43-making-your-own-theme.md).

Sa käivitad Aetheri rakenduste käivitaja kaudu (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) laseb sul saata faile teistesse samas võrgus rakendust kasutavatesse seadmetesse, nagu Apple'i AirDrop. See on aga platvormiülene, nii et saad faile saata Windowsi, macOS-i, Androidi, iOS-i ja muidugi Linuxi seadmetesse ning neist tagasi.

Jagamismenüü saad avada klahvidega `Super + Ctrl + S` või Omarchy menüüs jaotises _Trigger > Share_. See annab sulle neli võimalust:

- **Lõikelaud** saadab tekstifailina selle, mille oled kopeerinud. Suurepärane viis lingi või koodijupi telefoni saamiseks ilma endale e-kirja saatmata.
- **Fail** avab failivalija, kus saad korraga mitu valida.
- **Kaust** saadab terve kataloogi.
- **Vastuvõtt** avab päris LocalSendi, et teine seade saaks sulle midagi saata.

Sama asi töötab terminalist käskudega `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jäta tee ära ja saad valija.

Sa saad saata ka otse failihaldurist: tee Nautiluses mis tahes valikul paremklõps ja vali _Send via LocalSend_.

Omarchy tulemüür on vaikimisi suletud, välja arvatud LocalSendi port, nii et see töötab värskel installil kohe karbist võttes. Vaata [turvalisust](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täielik kontoripakett tekstitöötluse, tabelarvutuse, esitluste, joonistusrakenduse ja muuga. See ühildub Microsoft Office'i failidega, nii et see on suurepärane viis nende Wordi dokumentide avamiseks.

Sa käivitad LibreOffice'i rakenduste käivitaja kaudu (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchy enda ülilihtne esitlusrakendus. Sinu esitlus on üks Markdowni fail, mille kõrval on selle pildid ja videod: kirjuta iga slaid reaalajas eelvaate alla, lohista slaidid õigesse järjekorda, seejärel esitle täisekraanil või ekspordi PDF-i ja PowerPointi. See võtab isegi sinu Omarchy teema üle.

Sa käivitad Hype'i rakenduste käivitaja kaudu (`Super + Space`). Vajuta sees `?`, et näha kõiki otseteid.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchy enda ülilihtne viis PDF-ide allkirjastamiseks ja täitmiseks. Pane oma salvestatud allkiri, tekst ja tänane kuupäev lehel ükskõik kuhu, seejärel salvesta allkirjastatud koopia originaali kõrvale. Kuidas seda teha, vaata jaotisest [PDF-ide täitmine](27-filling-out-pdfs.md).

Sa käivitad Signedi rakenduste käivitaja kaudu (`Super + Space`) või avad sellega PDF-i failihaldurist.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchy enda ülilihtne kalkulaator, mis avaneb hõljuvas aknas.

Sa käivitad Omacalci klahvidega `Super + Shift + Q` (või kalkulaatoriklahviga, kui su klaviatuuril selline on).

## Signal

[Signal](https://signal.org/) on E2E-krüpteeritud sõnumside teerajaja ja suurepärane suhtlusvõimalus kõigile, kes eelistavad mitte käia läbi mõne suure tehnoloogiakonglomeraadi.

Sa käivitad Signali klahvidega `Super + Shift + G`. See ei ole baasinstalli osa, nii et kui sa seda esimest korda vajutad, pakub Omarchy selle sulle installimist (see on ka Omarchy menüüs jaotises _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchy enda ülilihtne pildibrauser ja meediumipleier: üks aken sinu fotode, videote ja muusika jaoks. Ava foto ja nooleklahvid liiguvad läbi ülejäänud selles kaustas olevate failide, `N` ja `P` teevad sama iga asja puhul ning `Ctrl + M` näitab tervet kausta ruudustikuna. See näitab ka HEIC-, AVIF- ja JPEG XL fotosid ning jätkab kõiges pikemas sealt, kus pooleli jäid.

Vajuta `F` täisekraani jaoks, `E` pildi redigeerimiseks rakenduses Omasnap või video kärpimiseks rakenduses Omacut, `Ctrl + P` pildi printimiseks ja `Delete`, et fail Prügikasti teisaldada (`Ctrl + Z` toob selle tagasi). Vajuta sees `?`, et näha kõiki otseteid.

Sa käivitad Omaview rakendusena _Media Viewer_ rakenduste käivitaja kaudu (`Super + Space`) või teed failihalduris lihtsalt pildil, videol või laulul topeltklõpsu.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchy enda ülilihtne videokärpija. Kui sul on vaja ainult klipi algus ja lõpp maha lõigata, on see parem kui täiemahulise videoredaktori käivitamine.

Sa käivitad Omacuti rakenduste käivitaja kaudu (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchy enda ülilihtne veebikaamera salvestaja. Vali oma kaamera ja mikrofon üks kord, seejärel vajuta salvestamiseks `Space` ning uuesti sama võtte peatamiseks ja jätkamiseks. See salvestab alati sinu kaamera kõrgeima eraldusvõimega, koos reaalajas mikrofoni mõõdikuga, et saaksid enne alustamist oma tasemeid kontrollida.

Peata võte ja see avaneb kohe sisseehitatud redaktoris. Tee klipil selle poolitamiseks topeltklõps, lohista käepidemeid iga tüki kärpimiseks ja eemalda osad, mida sa ei taha. Seejärel salvesta see MP4-na. Sinu algne salvestus säilitatakse, kuni sa selle ära viskad, nii et saad alati tagasi tulla ja seda teisiti lõigata.

Sa käivitad Monologue'i rakenduste käivitaja kaudu (`Super + Space`).
