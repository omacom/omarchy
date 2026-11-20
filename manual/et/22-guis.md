# Graafilised rakendused

## Files

Files (Folio) on graafiline failihaldur. `Super + Shift + F` avab selle ja `Super + Shift + Alt + F` avab selle kataloogis, kus su terminal parasjagu on, mis säästab palju klõpsimist. `Ctrl + L` laseb sul tee sisestada ja mis tahes failil `Space` vajutamine eelvaatab seda täissuuruses ilma seda avamata.

Ühenda USB-mälupulk või SD-kaart ja see haagitakse automaatselt, nii et see ilmub lihtsalt külgribale. Millegi põhjalikuma jaoks — draivi vormindamine, SMART-i tervise kontrollimine, partitsioonide loomine — käivita rakenduste käivitajast (`Super + Space`) rakendus _Disks_.

Topeltklõps järgib mõistlikke vaikeseadeid: pildid, videod ja muusika avanevad rakenduses Omaview, PDF-id rakenduses Document Viewer, Markdown rakenduses Omawrite ja lihttekst redaktoris, mis on valitud jaotuses _Setup > Default > Editor_.

## Disktree

Kui draiv saab täis ja sul pole aimugi, mis seda sööb, käivita rakenduste käivitajast (`Super + Space`) [Disktree](https://github.com/tobi/disktree). See näitab sinu kodukataloogi graafilist puukaarti. Suuremad plokid võtavad rohkem ruumi; liigu kataloogidesse klaviatuuri või hiirega, märgi, mis peab minema, ja vaata oma valikud enne millegi eemaldamist üle. Kogu ketta skannimiseks käivita `disktree --disk`.

## Obsidian

[Obsidian](https://obsidian.md/) on tasuta ja väga laiendatav märkmete tegemise rakendus, mis kasutab salvestamiseks lihtsaid Markdowni faile.

Obsidian on tasuta kõigiks otstarveteks, sealhulgas isiklikuks, äriliseks ja mittetulunduslikuks kasutamiseks.

Obsidian pakub ka [ärilist lisandmoodulit sünkroonimiseks](https://obsidian.md/sync) iOS-i ja Androidi mobiilirakendustega. (https://obsidian.md/pricing).

Obsidiani käivitad klahvidega `Super + Shift + O`. Teema sünkroonimise kasutamiseks pead seadete all valima teema `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchy enda ülilihtne Markdowni kirjutamisrakendus. Ei mingeid hoidlaid, ei mingeid pistikprogramme, ainult sina ja sõnad.

Omawrite'i käivitad klahvidega `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on lihtne pilditöötlustööriist, mis sobib suurepäraselt kärpimiseks, suuruse muutmiseks ja muudeks lihtsateks töötlusteks. Ära lihtsalt Photoshopi alternatiivi oota. Aga sellel on ikkagi Magic Wand ja kihid!

Pinta käivitad rakenduste käivitaja kaudu (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemarakendus, mis suudab taustapildist värve eraldada ja neist tervikliku, ühtse teema teha. See on lihtsaim viis [oma teema tegemiseks](43-making-your-own-theme.md).

Aetheri käivitad rakenduste käivitaja kaudu (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) laseb sul saata faile teistesse samas võrgus olevatesse seadmetesse, kus rakendus töötab, nagu Apple'i AirDrop. See on aga platvormiülene, nii et saad faile edasi-tagasi saata Windowsi, macOS-i, Androidi, iOS-i ja muidugi Linuxiga.

Saad avada menüü Share klahvidega `Super + Ctrl + S` või Omarchy menüüs jaotuses _Trigger > Share_. See annab sulle neli valikut:

- **Clipboard** saadab kõik, mille oled kopeerinud, tekstifailina. Suurepärane lingi või koodijupi telefoni saamiseks ilma endale e-kirja saatmata.
- **File** avab failivalija, kus saad korraga mitu valida.
- **Folder** saadab terve kataloogi.
- **Receive** avab LocalSendi enda, et teine seade saaks sulle midagi saata.

Sama toimib terminalist käskudega `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jäta tee ära ja saad valija.

Saad saata ka otse failihaldurist: tee rakenduses Files mis tahes valikul paremklõps ja jaga seda LocalSendiga.

Omarchy tulemüür on vaikimisi suletud, välja arvatud LocalSendi port, nii et see töötab värskel installil kohe karbist välja. Vaata jaotist [turvalisus](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täielik kontoripakett tekstitöötluse, arvutustabelite, esitluste, joonistusrakenduse ja muuga. See ühildub Microsoft Office'i failidega, nii et see on suurepärane viis nende Wordi dokumentide avamiseks.

LibreOffice'i käivitad rakenduste käivitaja kaudu (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchy enda ülilihtne esitlusrakendus. Sinu esitlus on üks Markdowni fail, mille kõrval on selle pildid ja videod: kirjuta iga slaid reaalajas eelvaate alla, lohista slaidid järjekorda, seejärel esitle täisekraanil või ekspordi PDF-i ja PowerPointi. See võtab isegi sinu Omarchy teema üle.

Hype'i käivitad rakenduste käivitaja kaudu (`Super + Space`). Vajuta selle sees `?`, et näha kõiki otseteid.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchy enda ülilihtne viis PDF-ide allkirjastamiseks ja täitmiseks. Pane oma salvestatud allkiri, tekst ja tänane kuupäev lehel ükskõik kuhu, seejärel salvesta allkirjastatud koopia originaali kõrvale. Vaata, kuidas, jaotisest [PDF-ide täitmine](27-filling-out-pdfs.md).

Signedi käivitad rakenduste käivitaja kaudu (`Super + Space`) või avad sellega failihaldurist PDF-i.

## Game Vibes

Game Vibes, rakenduste käivitajas (`Super + Space`), on koht, kus Omarchy väikesed mängud elavad: Checkmate, 3D malemäng sõbra või sisseehitatud vastase vastu; Cards, Klondike pasjanss; ja Neon Swarm, arkaaditulistamismäng. Igaüks on üks veebileht, mis järgib sinu teemat. Vali üks noolte ja klahviga `Enter` ning tule loendisse tagasi mängu tiitelkuvalt klahviga `Esc` või pausi ajal klahviga `Q`. See avaneb täisekraanil: `Super + F` teeb sellest akna ja `Super + W` sulgeb selle.

Mängud, mille sa agendiga teed, ilmuvad ka siia: vali agentide paneelil _Make something cool → Game_ ja kirjelda üht või nimeta mäng, mis on juba Game Vibes'is, et sellega edasi töötada. Agent kopeerib selle kausta `~/Games/vibes`, kus see on sinu oma muuta, ja avab selle, kui see on valmis. Saad selle koopia ise teha käsuga `omarchy games vibes copy <game>`. Mäng, mida keegi teine jagab, installitakse nagu teema: vali _Install > Gaming > Game Vibes_ ja kleebi selle giti aadress või käivita `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ eemaldab ühe jälle ja _Update > Game Vibes Games_ toob uued versioonid. Mängud laadivad three.js-i veebist, nii et neil on käivitumiseks ühendust vaja.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchy enda ülilihtne kalkulaator, mis avaneb ujuvas aknas.

Omacalci käivitad klahvidega `Super + Shift + Q` (või kalkulaatori klahviga, kui su klaviatuuril selline on).

## Signal

[Signal](https://signal.org/) on E2E-krüpteeritud sõnumside teerajaja ja suurepärane suhtlusvõimalus kõigile, kes eelistaksid mitte ühe suure tehnoloogiakonglomeraadi kaudu käia.

Signali käivitad klahvidega `Super + Shift + G`. See ei kuulu baasinstalli hulka, nii et esimesel korral, kui seda vajutad, pakub Omarchy selle sinu eest installida (see on ka Omarchy menüüs jaotuses _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchy enda ülilihtne pildivaatur ja meediamängija: üks aken sinu fotode, videote ja muusika jaoks. Ava foto ja nooleklahvid liiguvad läbi ülejäänud selle kausta, `N` ja `P` teevad seda kõige puhul ning `Ctrl + M` näitab tervet kausta ruudustikuna. See näitab ka HEIC-, AVIF- ja JPEG XL fotosid ning jätkab kõiges pikemas sealt, kus pooleli jäid.

Vajuta `F` täisekraani jaoks, `E` pildi töötlemiseks rakenduses Omasnap või video trimmimiseks rakenduses Omacut, `Ctrl + P` pildi printimiseks ja `Delete`, et fail prügikasti teisaldada (`Ctrl + Z` toob selle tagasi). Vajuta selle sees `?`, et näha kõiki otseteid.

Omaview' käivitad nime _Media Viewer_ all rakenduste käivitaja kaudu (`Super + Space`) või tee lihtsalt failihalduris pildil, videol või laulul topeltklõps.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchy enda ülilihtne videotrimmija. Kui sul on vaja ainult klipi algus ja lõpp ära lõigata, on see palju mõistlikum kui täiemahulise videoredaktori käivitamine.

Omacuti käivitad rakenduste käivitaja kaudu (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchy enda ülilihtne veebikaamera salvestaja. Vali oma kaamera ja mikrofon ühe korra, seejärel vajuta salvestamiseks klahvi `Space` ja uuesti, et sama võte pausile panna ja seda jätkata. See salvestab alati sinu kaamera kõrgeima resolutsiooniga, reaalajas mikrofoni tasememõõdikuga, et saaksid enne alustamist oma tasemeid kontrollida.

Peata võte ja see avaneb kohe sisseehitatud redaktoris. Tee klipil topeltklõps selle poolitamiseks, lohista käepidemeid iga osa trimmimiseks ja eemalda osad, mida sa ei taha. Seejärel salvesta see MP4-na. Sinu algne salvestus säilitatakse, kuni sa selle ära viskad, nii et saad alati tagasi tulla ja seda teisiti lõigata.

Monologue'i käivitad rakenduste käivitaja kaudu (`Super + Space`).
