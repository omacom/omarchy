# Graafilised rakendused

## Files

Files (Folio) on graafiline failihaldur. `Super + Shift + F` avab selle ja `Super + Shift + Alt + F` avab selle kaustas, kus su terminal parasjagu on, mis säästab palju klõpsamist. `Ctrl + L` laseb sul tee sisestada ja mis tahes failil `Space` vajutamine eelvaatleb seda täissuuruses, ilma seda avamata.

Ühenda USB-mälupulk või SD-kaart ja see haagitakse automaatselt, nii et see ilmub lihtsalt külgribale. Millegi põhjalikuma jaoks — draivi vormindamine, SMART-i tervise kontrollimine, partitsioonide loomine — käivita rakenduste käivitajast (`Super + Space`) _Disks_.

Krüptitud draiv küsib ühendamisel oma parooli. Et üks avaneks iseenesest, lisa sellele võtmefail käsuga `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` ja pane see võtmefail asukohta `~/.config/omarchy/drive-keys/<UUID>`, nimetatuna selle UUID järgi, mille `lsblk -dno UUID /dev/sdX1` krüptitud partitsiooni jaoks väljastab, ja ainult sulle loetavana (`chmod 600`). Kui see võtmefail puudub või sellest keeldutakse, küsitakse sinult parooli nagu tavaliselt.

Topeltklõps järgib mõistlikke vaikevalikuid: pildid, videod ja muusika avanevad rakenduses Omaview, PDF-id rakenduses Document Viewer, Markdown rakenduses Omawrite ja lihttekst sinu redaktoris, Plain, kui sa ei vali jaotises _Setup > Defaults > Editor_ teist.

## Disktree

Kui draiv saab täis ja sul pole õrna aimugi, mis seda sööb, käivita rakenduste käivitajast (`Super + Space`) [Disktree](https://github.com/tobi/disktree). See näitab sinu kodukataloogi graafilist puukaarti. Suuremad plokid võtavad rohkem ruumi; liigu kataloogides klaviatuuri või hiirega, märgi, mis peab minema, ja vaata oma valikud enne millegi eemaldamist üle. Käivita `disktree --disk`, et skannida kogu ketast.

## Obsidian

[Obsidian](https://obsidian.md/) on tasuta ja väga laiendatav märkmete tegemise rakendus, mis kasutab salvestamiseks lihtsaid Markdowni faile.

Obsidian on tasuta kõigil eesmärkidel, sealhulgas isiklikuks, ärikasutuseks ja mittetulunduslikuks kasutamiseks.

Obsidian pakub ka [ärilist lisandmoodulit sünkroonimiseks](https://obsidian.md/sync) mobiilirakendustega iOS-il ja Androidil. (https://obsidian.md/pricing).

Käivitad Obsidiani klahvidega `Super + Shift + O`. Teema sünkroonimise kasutamiseks pead seadetes valima teema `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchy enda ülilihtne Markdowni kirjutamisrakendus. Ei mingeid hoidlaid, ei mingeid pluginaid, ainult sina ja sõnad.

Käivitad Omawrite'i klahvidega `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on lihtne pilditöötlustööriist, mis sobib suurepäraselt kärpimiseks, suuruse muutmiseks ja muudeks lihtsateks töötlusteks. Ära ainult Photoshopi alternatiivi oota. Aga sellel on ikkagi Magic Wand ja kihid!

Käivitad Pinta rakenduste käivitaja kaudu (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemarakendus, mis suudab taustapildist värve eraldada ja muuta need terviklikuks, ühtseks teemaks. See on lihtsaim viis [oma teema tegemiseks](43-making-your-own-theme.md).

Käivitad Aetheri rakenduste käivitaja kaudu (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) laseb sul saata faile teistele seadmetele samas võrgus, kus rakendus töötab, nagu Apple'i AirDrop. See on aga platvormiülene, nii et saad faile saata Windowsi, macOS-i, Androidi, iOS-i ja muidugi Linuxi vahel ning nendesse.

Saad avada menüü Share klahvidega `Super + Ctrl + S` või Omarchy menüüs jaotises _Trigger > Share_. See annab sulle neli valikut:

- **Clipboard** saadab kopeeritu tekstifailina. Suurepärane, et link või koodijupp telefoni saada ilma endale e-kirja saatmata.
- **File** avab failivalija, kus saad valida mitu korraga.
- **Folder** saadab terve kataloogi.
- **Receive** avab LocalSendi enda, et teine seade saaks sulle midagi saata.

Sama toimib terminalist käsuga `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jäta tee ära ja saad valija.

Saad saata ka otse failihaldurist: paremklõpsa Filesis mis tahes valikul ja jaga seda LocalSendiga.

Omarchy tulemüür on vaikimisi suletud, välja arvatud LocalSendi pordi jaoks, nii et see toimib värskel installil kohe karbist välja võetuna. Vaata [turvalisus](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täielik kontoripakett tekstitöötluse, arvutustabelite, esitluste, joonistusrakenduse ja muuga. See ühildub Microsoft Office'i failidega, nii et see on suurepärane viis nende Wordi dokumentide avamiseks.

Käivitad LibreOffice'i rakenduste käivitaja kaudu (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchy enda ülilihtne esitlusrakendus. Sinu esitlus on üks Markdowni fail, mille pildid ja videod on selle kõrval: kirjuta iga slaid reaalajas eelvaate alla, lohista slaidid järjekorda, seejärel esitle täisekraanil või ekspordi PDF-i ja PowerPointi. See võtab isegi sinu Omarchy teema üle.

Käivitad Hype'i rakenduste käivitaja kaudu (`Super + Space`). Vajuta selle sees `?`, et näha kõiki kiirklahve.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchy enda ülilihtne viis PDF-ide allkirjastamiseks ja täitmiseks. Pane oma salvestatud allkiri, tekst ja tänane kuupäev lehel suvalisse kohta, seejärel salvesta allkirjastatud koopia originaali kõrvale. Vaata, kuidas seda teha, jaotisest [PDF-ide täitmine](27-filling-out-pdfs.md).

Käivitad Signedi rakenduste käivitaja kaudu (`Super + Space`) või avad sellega PDF-i failihaldurist.

## Game Vibes

Game Vibes rakenduste käivitajas (`Super + Space`) on koht, kus Omarchy väikesed mängud elavad: Checkmate, 3D malemäng sõbra või sisseehitatud vastase vastu; Cards, Klondike pasjanss; Death Wish, pikslitäpne platvormimäng kümne toaga, täis ogasid ja saage; ja Neon Swarm, arkaaditulistamine. Igaüks on üks veebileht, mis järgib sinu teemat. Vali üks noolte ja `Enter` abil ning tule loendisse tagasi mängu tiitliekraanilt `Esc` abil või `Q` abil, kui see on pausil. See avaneb täisekraanil: `Super + F` teeb sellest akna ja `Super + W` sulgeb selle.

Mängud, mille sa agendiga teed, ilmuvad ka siia: vali agentide paneelil _Make something cool → Game_ ja kirjelda üht või nimeta mäng, mis on juba Game Vibes'is, et sellega edasi töötada. Agent kopeerib selle asukohta `~/Games/vibes`, kus see on sinu oma, et seda muuta, ja avab selle, kui see on valmis. Saad selle koopia ise teha käsuga `omarchy games vibes copy <game>`. Mäng, mida keegi teine jagab, installitakse nagu teema: vali _Install > Gaming > Game Vibes_ ja kleebi selle giti aadress või käivita `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ eemaldab ühe jälle ja _Update > Game Vibes Games_ toob uued versioonid. Mängud laadivad three.js-i veebist, nii et neil on käivitumiseks vaja ühendust.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchy enda ülilihtne kalkulaator, mis avaneb ujuvas aknas.

Käivitad Omacalci klahvidega `Super + Shift + Q` (või kalkulaatoriklahviga, kui sinu klaviatuuril selline on).

## Signal

[Signal](https://signal.org/) on E2E-krüptitud sõnumside teerajaja ja suurepärane suhtlusvõimalus kõigile, kes eelistaksid mitte minna läbi ühe suure tehnoloogiakonglomeraadi.

Käivitad Signali klahvidega `Super + Shift + G`. See ei ole baasinstalli osa, nii et esimesel korral, kui seda vajutad, pakub Omarchy selle sinu eest installimist (see on ka Omarchy menüüs jaotises _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchy enda ülilihtne pildivaatur ja meediamängija: üks aken sinu fotode, videote ja muusika jaoks. Ava foto ja nooleklahvid liiguvad läbi ülejäänud kausta, `N` ja `P` teevad seda kõige puhul ning `Ctrl + M` näitab tervet kausta ruudustikuna. See näitab ka HEIC-, AVIF- ja JPEG XL fotosid ning jätkab pikkade asjade puhul sealt, kus pooleli jäid.

Vajuta `F` täisekraani jaoks, `E` pildi redigeerimiseks Omasnapis või video kärpimiseks Omacutis, `Ctrl + P` pildi printimiseks ja `Delete`, et fail prügikasti teisaldada (`Ctrl + Z` toob selle tagasi). Vajuta selle sees `?`, et näha kõiki kiirklahve.

Käivitad Omaview' rakendusena _Media Viewer_ rakenduste käivitaja kaudu (`Super + Space`) või topeltklõpsad lihtsalt failihalduris pildil, videol või laulul.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchy enda ülilihtne videokärpija. Kui sul on vaja ainult klipi algus ja lõpp ära lõigata, võidab see täiemahulise videoredaktori käivitamise.

Käivitad Omacuti rakenduste käivitaja kaudu (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchy enda ülilihtne veebikaamera salvesti. Vali oma kaamera ja mikrofon üks kord, seejärel vajuta salvestamiseks `Space` ja uuesti, et sama võte pausile panna ja jätkata. See salvestab alati sinu kaamera kõrgeima eraldusvõimega, koos reaalajas mikrofonimõõturiga, et saaksid enne alustamist oma tasemeid kontrollida.

Peata võte ja see avaneb kohe sisseehitatud redaktoris. Topeltklõpsa klipil, et see poolitada, lohista käepidemeid, et iga tükki kärpida, ja eemalda osad, mida sa ei taha. Seejärel salvesta see MP4-na. Sinu algne salvestus säilitatakse, kuni sa selle ära viskad, nii et saad alati tagasi tulla ja seda teisiti lõigata.

Käivitad Monologue'i rakenduste käivitaja kaudu (`Super + Space`).
