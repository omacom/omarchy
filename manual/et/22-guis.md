# GUI-d

## Files

Files (Folio) on graafiline failihaldur. `Super + Shift + F` avab selle ja `Super + Shift + Alt + F` avab selle kaustas, kus sinu terminal parajasti asub, mis säästab palju klikkimist. `Ctrl + L` võimaldab sul tee sisestada ja mis tahes failil `Space` vajutamine kuvab selle eelvaate täissuuruses, ilma seda avamata.

Ühenda USB-mälupulk või SD-kaart ja see haagitakse automaatselt külge, nii et see ilmub lihtsalt külgribale. Kõige keerukama jaoks — ketta vormindamine, SMART-i seisundi kontrollimine, partitsioonide loomine — käivita rakenduste käivitusprogrammist (`Super + Space`) _Disks_.

Topeltklõps järgib mõistlikke vaikevalikuid: pildid, videod ja muusika avanevad rakenduses Omaview, PDF-id rakenduses Document Viewer, Markdown rakenduses Omawrite ja lihttekst sinu redaktoris, Plain, kui sa ei vali _Setup > Defaults > Editor_ alt teist.

## Disktree

Kui ketas saab täis ja sul pole õrna aimugi, mis seda sööb, käivita rakenduste käivitusprogrammist (`Super + Space`) [Disktree](https://github.com/tobi/disktree). See näitab sinu kodukataloogi graafilist puukaarti. Suuremad plokid võtavad rohkem ruumi; liigu kataloogides klaviatuuri või hiirega, märgi ära, mis peab minema, ja vaata oma valikud enne millegi eemaldamist üle. Kogu ketta skannimiseks käivita `disktree --disk`.

## Obsidian

[Obsidian](https://obsidian.md/) on tasuta ja väga laiendatav märkmete tegemise rakendus, mis kasutab salvestamiseks lihtsaid Markdowni faile.

Obsidian on tasuta igaks otstarbeks, sealhulgas isiklikuks, äriliseks ja mittetulunduslikuks kasutamiseks.

Obsidian pakub ka [ärilist lisandmoodulit sünkroonimiseks](https://obsidian.md/sync) iOS-i ja Androidi mobiilirakendustega. (https://obsidian.md/pricing).

Obsidiani käivitad klahvikombinatsiooniga `Super + Shift + O`. Teema sünkroonimise kasutamiseks pead seadete all valima teema `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchy enda ülilihtne Markdownis kirjutamise rakendus. Ei mingeid hoidlaid, ei mingeid pistikprogramme, ainult sina ja sõnad.

Omawrite käivitad klahvikombinatsiooniga `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on lihtne pilditöötlustööriist, mis sobib suurepäraselt kärpimiseks, suuruse muutmiseks ja muudeks lihtsateks töötlusteks. Ära lihtsalt oota Photoshopi alternatiivi. Aga sellel on ikkagi Magic Wand ja kihid!

Pinta käivitad rakenduste käivitusprogrammi kaudu (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemarakendus, mis suudab taustapildilt värvid välja võtta ja neist täieliku, sidusa teema teha. See on kõige lihtsam viis [oma teema tegemiseks](43-making-your-own-theme.md).

Aether käivitad rakenduste käivitusprogrammi kaudu (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) võimaldab sul saata faile teistesse samas võrgus olevatesse seadmetesse, kus rakendus töötab, nagu Apple'i AirDrop. See on aga platvormiülene, nii et saad faile saata Windowsi, macOS-i, Androidi, iOS-i ja muidugi Linuxiga ning neist kõigist.

Share menüü saad avada klahvikombinatsiooniga `Super + Ctrl + S` või Omarchy menüüs _Trigger > Share_ alt. See annab sulle neli valikut:

- **Clipboard** saadab kõik, mis sa kopeerinud oled, tekstifailina. Suurepärane võimalus link või koodijupp telefoni saada, ilma endale e-kirja saatmata.
- **File** avab failivalija, kus saad korraga mitu faili valida.
- **Folder** saadab terve kataloogi.
- **Receive** avab päris LocalSend rakenduse, et teine seade saaks sulle midagi saata.

Sama asi töötab terminalist käskudega `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jäta tee ära ja saad failivalija.

Saada saad ka otse failihaldurist: tee Files rakenduses mis tahes valikul paremklõps ja jaga seda LocalSend abil.

Omarchy tulemüür on vaikimisi suletud, välja arvatud LocalSend pordi jaoks, nii et see töötab värskel paigaldusel kohe karbist välja võttes. Vaata [turvalisust](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täielik kontoripakett tekstitöötluse, arvutustabelite, esitluste, joonistusrakenduse ja muuga. See ühildub Microsoft Office failidega, nii et see on suurepärane võimalus nende Word dokumentide avamiseks.

LibreOffice käivitad rakenduste käivitusprogrammi kaudu (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchy enda ülilihtne esitlusrakendus. Sinu esitlus on üks Markdowni fail koos selle kõrval olevate piltide ja videotega: kirjuta iga slaid reaalajas eelvaate alla, lohista slaidid õigesse järjekorda, seejärel esitle täisekraanil või ekspordi PDF-i ja PowerPointi. See võtab isegi sinu Omarchy teema üle.

Hype käivitad rakenduste käivitusprogrammi kaudu (`Super + Space`). Kõigi kiirklahvide nägemiseks vajuta selle sees `?`.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchy enda ülilihtne viis PDF-ide allkirjastamiseks ja täitmiseks. Pane oma salvestatud allkiri, tekst ja tänane kuupäev lehel suvalisse kohta, seejärel salvesta allkirjastatud koopia originaali kõrvale. Kuidas seda teha, vaata jaotisest [PDF-ide täitmine](27-filling-out-pdfs.md).

Signed käivitad rakenduste käivitusprogrammi kaudu (`Super + Space`) või ava sellega PDF failihaldurist.

## Game Vibes

Game Vibes rakenduste käivitusprogrammis (`Super + Space`) on koht, kus elavad Omarchy väikesed mängud: Checkmate, 3D-malemäng sõbra või sisseehitatud vastase vastu; Cards, Klondike pasjanss; Death Wish, pikslitäpne platvormimäng kümne toa, ogade ja saagidega; ning Neon Swarm, arkaaditulistamismäng. Igaüks neist on üks veebileht, mis järgib sinu teemat. Vali üks noolte ja `Enter` klahviga ning tule loendisse tagasi mängu tiitliekraanilt `Esc` klahviga või pausi ajal `Q` klahviga. See avaneb täisekraanil: `Super + F` teeb sellest akna ja `Super + W` sulgeb selle.

Siin ilmuvad ka mängud, mille sa agendiga teed: vali agentide paneelil _Make something cool → Game_ ja kirjelda üht mängu, või nimeta mõni Game Vibes mäng, et selle kallal edasi töötada. Agent kopeerib selle kausta `~/Games/vibes`, kus see on sinu oma ja saad seda muuta, ning avab selle, kui valmis saab. Selle koopia saad ise teha käsuga `omarchy games vibes copy <game>`. Teise jagatud mäng paigaldatakse nagu teema: vali _Install > Gaming > Game Vibes_ ja kleebi selle git-aadress, või käivita `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ eemaldab mängu taas ja _Update > Game Vibes Games_ toob uued versioonid. Mängud laadivad three.js veebist, nii et käivitumiseks vajavad nad ühendust.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchy enda ülilihtne kalkulaator, mis avaneb hõljuvas aknas.

Omacalc käivitad klahvikombinatsiooniga `Super + Shift + Q` (või kalkulaatoriklahviga, kui sinu klaviatuuril selline on).

## Signal

[Signal](https://signal.org/) on E2E-krüpteeritud sõnumside teerajaja ja suurepärane suhtlusvõimalus kõigile, kes eelistavad mitte käia läbi mõne suure tehnoloogiakontserni.

Signal käivitad klahvikombinatsiooniga `Super + Shift + G`. See ei kuulu põhipaigaldusse, nii et esimesel korral, kui seda vajutad, pakub Omarchy selle sulle paigaldada (see on ka Omarchy menüüs _Install > Service_ all).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchy enda ülilihtne pildivaataja ja meediamängija: üks aken sinu fotode, videote ja muusika jaoks. Ava foto ja nooleklahvid liiguvad läbi ülejäänud kausta, `N` ja `P` teevad seda kõige puhul ning `Ctrl + M` näitab tervet kausta ruudustikuna. See näitab ka HEIC, AVIF ja JPEG XL fotosid ning jätkab kõiges pikemas sealt, kus pooleli jäid.

Vajuta `F` täisekraani jaoks, `E` pildi muutmiseks Omasnap rakenduses või video lõikamiseks Omacut rakenduses, `Ctrl + P` pildi printimiseks ja `Delete` faili prügikasti teisaldamiseks (`Ctrl + Z` toob selle tagasi). Kõigi kiirklahvide nägemiseks vajuta selle sees `?`.

Omaview käivitad rakenduste käivitusprogrammi kaudu nimega _Media Viewer_ (`Super + Space`) või tee lihtsalt failihalduris pildil, videol või laulul topeltklõps.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchy enda ülilihtne videolõikur. Kui sul on vaja ainult klipi algus ja lõpp ära lõigata, on see parem, kui täiemahulise videoredaktori käivitamine.

Omacut käivitad rakenduste käivitusprogrammi kaudu (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchy enda ülilihtne veebikaamera salvestaja. Vali üks kord oma kaamera ja mikrofon, seejärel vajuta salvestamiseks `Space` ja sama võtte peatamiseks ja jätkamiseks vajuta seda uuesti. See salvestab alati sinu kaamera kõrgeima eraldusvõimega, koos reaalajas mikrofoni mõõturiga, et saaksid enne alustamist oma tasemeid kontrollida.

Peata võte ja see avaneb kohe sisseehitatud redaktoris. Tee klipil selle poolitamiseks topeltklõps, lohista käepidemeid iga tüki lõikamiseks ja eemalda osad, mida sa ei taha. Seejärel salvesta see MP4-na. Sinu algne salvestus säilitatakse, kuni sa selle ära viskad, nii et saad alati tagasi tulla ja seda teisiti lõigata.

Monologue käivitad rakenduste käivitusprogrammi kaudu (`Super + Space`).
