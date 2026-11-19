# GUI-d

## Failid

Files (Nautilus) on graafiline failihaldur. `Super + Shift + F` avab selle ja `Super + Shift + Alt + F` avab selle kataloogis, kus su terminal parasjagu on, mis säästab palju klikkimist. `Ctrl + L` laseb sul tee sisestada ja `Space` vajutamine mis tahes failil annab sulle kiire eelvaate ilma midagi avamata.

Ühenda USB-mälupulk või SD-kaart ja see haagitakse automaatselt, nii et see ilmub lihtsalt külgribale. Millegi põhjalikuma jaoks — draivi vormindamine, SMART-i seisundi kontrollimine, partitsioonide loomine — käivita rakenduste käivitajast (`Super + Space`) _Disks_.

Topeltklõps järgib mõistlikke vaikevalikuid: pildid, videod ja muusika avanevad rakenduses Omaview, PDF-id rakenduses Document Viewer, Markdown rakenduses Omawrite ja lihttekst redaktoris, mis on valitud jaotises _Setup > Default > Editor_.

## Disktree

Kui draiv saab täis ja sul pole aimugi, mis seda sööb, käivita rakenduste käivitajast (`Super + Space`) [Disktree](https://github.com/tobi/disktree). See näitab sinu kodukataloogi graafilist puukaarti. Suuremad plokid võtavad rohkem ruumi; liigu kataloogidesse klaviatuuri või hiirega, märgi ära, mis peab minema, ja vaata oma valikud enne millegi eemaldamist üle. Kogu ketta skannimiseks käivita `disktree --disk`.

## Obsidian

[Obsidian](https://obsidian.md/) on tasuta ja väga laiendatav märkmete tegemise rakendus, mis kasutab salvestamiseks lihtsaid Markdowni faile.

Obsidian on tasuta igaks otstarbeks, sealhulgas isiklikuks, äriliseks ja mittetulunduslikuks kasutamiseks.

Obsidian pakub ka [tasulist sünkroonimise lisandmoodulit](https://obsidian.md/sync) mobiilirakendustega iOS-il ja Androidil. (https://obsidian.md/pricing).

Sa käivitad Obsidiani klahvidega `Super + Shift + O`. Teema sünkroonimise kasutamiseks pead seadetes valima teema `Omarchy`.

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

[LocalSend](https://localsend.org/) laseb sul saata faile teistele samas võrgus rakendust kasutavatele seadmetele, nagu Apple'i AirDrop. See on aga platvormiülene, nii et saad faile saata Windowsi, macOS-i, Androidi, iOS-i ja muidugi Linuxiga ning neist vastu võtta.

Jagamise menüü saad avada klahvidega `Super + Ctrl + S` või Omarchy menüüs jaotises _Trigger > Share_. See annab sulle neli valikut:

- **Clipboard** saadab kõik, mida oled kopeerinud, tekstifailina. Suurepärane selleks, et link või koodijupp telefoni saada ilma endale e-kirja saatmata.
- **File** avab failivalija, kus saad korraga mitu valida.
- **Folder** saadab terve kataloogi.
- **Receive** avab päris LocalSendi, et teine seade saaks sulle midagi saata.

Sama asi toimib terminalist käskudega `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jäta tee ära ja saad failivalija.

Saad saata ka otse failihaldurist: tee Nautiluses mis tahes valikul paremklõps ja vali _Send via LocalSend_.

Omarchy tulemüür on vaikimisi suletud, välja arvatud LocalSendi port, nii et see töötab värskel installil kohe karbist välja võttes. Vaata [turvalisus](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täielik kontoripakett tekstitöötluse, arvutustabelite, esitluste, joonistusrakenduse ja muuga. See ühildub Microsoft Office'i failidega, nii et see on suurepärane viis nende Wordi dokumentide avamiseks.

Sa käivitad LibreOffice'i rakenduste käivitaja kaudu (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchy enda ülilihtne esitlusrakendus. Sinu esitlus on üks Markdowni fail koos selle kõrval olevate piltide ja videotega: kirjuta iga slaid reaalajas eelvaate alla, lohista slaidid õigesse järjekorda, seejärel esitle täisekraanil või ekspordi PDF-i ja PowerPointi. See võtab isegi sinu Omarchy teema üle.

Sa käivitad Hype'i rakenduste käivitaja kaudu (`Super + Space`). Kõigi otseteede nägemiseks vajuta selle sees `?`.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchy enda ülilihtne viis PDF-ide allkirjastamiseks ja täitmiseks. Pane oma salvestatud allkiri, tekst ja tänane kuupäev lehel ükskõik kuhu ning salvesta seejärel allkirjastatud koopia originaali kõrvale. Kuidas seda teha, vaata jaotisest [PDF-ide täitmine](27-filling-out-pdfs.md).

Sa käivitad Signedi rakenduste käivitaja kaudu (`Super + Space`) või avad sellega failihaldurist PDF-i.

## Game Vibes

Game Vibes, rakenduste käivitajas (`Super + Space`), on koht, kus elavad Omarchy väikesed mängud: Checkmate, 3D malemäng sõbra või sisseehitatud vastase vastu; Cards, Klondike pasjanss; ja Neon Swarm, arkaaditulistamine. Igaüks neist on üks veebileht, mis järgib sinu teemat. Vali üks noolte ja klahviga `Enter` ning tule loendisse tagasi mängu tiitelkuvalt klahviga `Esc` või pausi ajal klahviga `Q`. See avaneb täisekraanil: `Super + F` teeb sellest akna ja `Super + W` sulgeb selle.

Sinu agentiga tehtud mängud ilmuvad ka siia: vali agentide paneelil _Make something cool → Game_ ja kirjelda mängu või nimeta mõni Game Vibesis juba olev mäng, et selle kallal edasi töötada. Agent kopeerib selle kausta `~/Games/vibes`, kus see on sinu oma, et seda muuta, ja avab selle, kui see valmis on. Selle koopia saad ise teha käsuga `omarchy games vibes copy <game>`. Kellegi teise jagatud mäng installitakse nagu teema: vali _Install > Gaming > Game Vibes_ ja kleebi selle giti aadress või käivita `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ eemaldab mängu jälle ja _Update > Game Vibes Games_ toob uued versioonid. Mängud laadivad three.js-i veebist, nii et neil on käivitamiseks ühendust vaja.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchy enda ülilihtne kalkulaator, mis avaneb ujuvas aknas.

Sa käivitad Omacalci klahvidega `Super + Shift + Q` (või kalkulaatoriklahviga, kui su klaviatuuril selline on).

## Signal

[Signal](https://signal.org/) on E2E-krüpteeritud sõnumside teerajaja ja suurepärane suhtlusvalik kõigile, kes eelistavad mitte käia läbi mõne suure tehnoloogiakonglomeraadi.

Sa käivitad Signali klahvidega `Super + Shift + G`. See ei kuulu põhinstalli hulka, nii et esimesel korral, kui seda vajutad, pakub Omarchy selle sinu eest installida (see on ka Omarchy menüüs jaotises _Install > Service_). 

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchy enda ülilihtne pildivaatur ja meediumipleier: üks aken sinu fotode, videote ja muusika jaoks. Ava foto ja nooleklahvid liiguvad läbi ülejäänud selle kausta, `N` ja `P` teevad seda kõige puhul ning `Ctrl + M` näitab tervet kausta ruudustikuna. See näitab ka HEIC-, AVIF- ja JPEG XL fotosid ning jätkab pikemate asjade puhul sealt, kus pooleli jäid.

Täisekraani jaoks vajuta `F`, pildi redigeerimiseks Omasnapis või video kärpimiseks Omacutis `E`, pildi printimiseks `Ctrl + P` ja faili prügikasti teisaldamiseks `Delete` (`Ctrl + Z` toob selle tagasi). Kõigi otseteede nägemiseks vajuta selle sees `?`.

Sa käivitad Omaview rakenduste käivitajast nime _Media Viewer_ all (`Super + Space`) või teed lihtsalt failihalduris pildil, videol või laulul topeltklõpsu.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchy enda ülilihtne videokärpija. Kui sul on vaja ainult klipi algus ja lõpp ära lõigata, võidab see täiemahulise videoredaktori käivitamist.

Sa käivitad Omacuti rakenduste käivitaja kaudu (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchy enda ülilihtne veebikaamera salvestaja. Vali oma kaamera ja mikrofon üks kord, seejärel vajuta salvestamiseks `Space` ning sama võtte peatamiseks ja jätkamiseks uuesti `Space`. See salvestab alati sinu kaamera kõrgeima eraldusvõimega, koos reaalajas mikrofoni mõõdikuga, et saaksid enne alustamist oma tasemeid kontrollida.

Lõpeta võte ja see avaneb kohe sisseehitatud redaktoris. Tee klipil selle poolitamiseks topeltklõps, lohista iga tüki kärpimiseks käepidemeid ja eemalda osad, mida sa ei taha. Seejärel salvesta see MP4-na. Sinu algne salvestis säilitatakse, kuni sa selle ära viskad, nii et saad alati tagasi tulla ja seda teisiti lõigata.

Sa käivitad Monologue'i rakenduste käivitaja kaudu (`Super + Space`).
