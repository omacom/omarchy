# Ekraanipildid ja salvestamine

Kõik, mida ekraanilt haarata saad, ripub Print Screen klahvi küljes. Üks klahv üksi teeb pildi ja modifikaatorid teevad salvestuse, võtavad värvi või piirkonnas oleva teksti. Kui sinu klaviatuuril Print Screen klahvi üldse ei ole, teeb `Super + Ctrl + Alt + C` sama ekraanipildi ja `Super + Ctrl + C` avab kogu komplekti menüüna.

| Kiirklahv | Funktsioon |
| ------ | -------- |
| `Print Screen` | Ekraanipilt |
| `Super + Ctrl + Alt + C` | Ekraanipilt |
| `Alt + Print Screen` | Ekraani salvestamine (või käimasoleva peatamine) |
| `Super + Print Screen` | Värvivalija |
| `Super + Ctrl + Print Screen` | Teksti eraldamine piirkonnast |
| `Super + Ctrl + C` | Jäädvustamise menüü |
| `Super + Ctrl + .` | Pildi või video transkodeerimine |

## Ekraanipildid

Vajuta `Print Screen` (või `Super + Ctrl + Alt + C`) ja Omasnap jäädvustab fokuseeritud monitori enne, kui selle ülekate ilmub, nii et sihtimise ajal ei nihku sinu all midagi. Lohista vabakujuline piirkond, klõpsa aknal selle jäädvustamiseks või klõpsa tühjal alal kogu monitori jäädvustamiseks. Keritava piirkonna jäädvustamiseks vajuta enne joonistamist `S`. Muutsid meelt? Omasnapi sulgemiseks vajuta uuesti sama klahvi.

Pärast ala valimist salvestab Omasnap jäädvustuse, kopeerib selle lõikelauale ja näitab selle pisipildiga teavitust, nagu salvestatud ekraanisalvestuski. Salvestaud pildi vaatamiseks oma pildivaaturis vali Ava või selle annoteerimiseks vali Redigeeri.

Annotatsiooniredaktor oskab joonistada nooli, jooni, kujundeid, esiletõste ja nummerdatud tähiseid, lisada teksti ja turvalisi varjamisi, pilti kärpida või sellest osa välja lõigata, selle teksti OCR-iga eraldada ja lisada tausta. Valmis PNG kopeerimiseks ja salvestamiseks vajuta redaktoris `Enter`, salvestamata kopeerimiseks `Ctrl + C` või kopeerimata salvestamiseks `Ctrl + S`.

Salvestatud ekraanipildid jõuavad vaikimisi kausta `~/Pictures/Screenshots` nimega nagu `screenshot-2026-08-13_14-22-05-firefox.png`. Teise kausta kasutamiseks määra `OMASNAP_SCREENSHOT_DIR` — vaata [KKK-st](46-faq.md), kuhu seansi keskkonnamuutujad panna. Omasnap loob kausta esimese pildi salvestamisel. Automaatse salvestamise keelamiseks määra failis `~/.config/omasnap/omasnap.conf` väärtuseks `[output] autosave = false`; jäädvustused siis ainult kopeeritakse ja näidatakse 10 sekundit eelvaates, mille saad selle kinnitusnupu või klahvikombinatsiooniga `Ctrl + P` ekraanile jätta.

Terminalist avab `omarchy screenshot` sama ülekatte ja saad valida selle algrežiimi: `omarchy capture screenshot region`, `windows`, `fullscreen` või `scroll`. Teine argument `copy` või `save` saadab pildi otse sellesse sihtkohta. Enne väljastamist redigeerimiseks kasuta täisekraaniredaktori jaoks käsku `omarchy screenshot --editor=overlay` või eraldi akna jaoks käsku `omarchy screenshot --editor=window`.

### Valiku juhtimine klaviatuurilt

Kuni valik on üleval, ei pea sa üldse hiirt kasutama:

| Klahv | Funktsioon |
| --- | -------- |
| `S` | Keritava piirkonna režiimi sisse- ja väljalülitamine |
| `Super + Arrow keys` | Aknarežiimis akende vahel liikumine |
| `Return` | Esiletõstetud akna jäädvustamine |
| `Ctrl + A` | Kogu fokuseeritud monitori jäädvustamine |
| `R` | Viimati selles seansis joonistatud piirkonna taastamine |
| `Esc` | Omasnapi sulgemine |

Need seosed on olemas ainult kuni Omasnap on avatud, nii et need ei saa sinu enda konfiguratsioonis millegagi kokku põrkuda.

## Ekraani salvestamine

`Alt + Print Screen` avab _Trigger > Capture > Screenrecord_, mis küsib, mida sa heliribale soovid: heli puudub, töölauaheli, töölaud koos mikrofoniga või töölaud koos mikrofoni ja veebikaameraga. Viimane ilmub ainult siis, kui sul on kaamera tegelikult ühendatud. Vali üks ja Omarchy salvestusvalija laseb sul lohistada piirkonna või klõpsata aknal või monitoril.

Salvestamine töötab gpu-screen-recorderiga, mis kodeerib GPU peal kiirusega 60fps ja läheb vajadusel tagasi CPU peale. Tulemuseks on MP4 kaustas `~/Videos` nimega `screenrecording-2026-08-13_14-22-05.mp4`. Selle muutmiseks määra `OMARCHY_SCREENRECORD_DIR` — aga pane tähele, et erinevalt ekraanipiltide kaustast peab see juba olemas olema, muidu keeldub salvestamine käivitumast.

Salvestamise ajal ilmub ribale väike indikaator. Peatamiseks klõpsa sellel. Peatada saad ka uuesti klahvikombinatsiooniga `Alt + Print Screen` või kirje _Stop Screenrecording_ kaudu menüüs _Trigger > Capture > Screenrecord_, mis ilmub ainult siis, kui midagi tegelikult salvestatakse.

Peatamine teeb enne faili üleandmist veidi koristustööd: esimene kaader kärbitakse ära ja kui heli on olemas, normaliseeritakse see tasemele -14 LUFS ning PipeWire'i jäädvustuse plõks kohe alguses vaigistatakse. Seejärel ilmub salvestuse pisipildiga teavitus. Faili esitamiseks Omaview's klõpsa sellel.

### Veebikaamera ülekate

Kui salvestad veebikaameraga, ilmub kaamera kinnitatud, kärbitud portreeaknana salvestatava ala paremasse alanurka. Kui see on millegi vajaliku peal, muuda selle suurust käigu pealt:

| Kiirklahv | Funktsioon |
| ------ | -------- |
| `Super + Alt + [` | Veebikaamera ülekatte väiksemaks tegemine |
| `Super + Alt + ]` | Veebikaamera ülekatte suuremaks tegemine |

Suurusi on kolm — väike, keskmine ja suur — ja kiirklahvid astuvad nende vahel. Vaikimisi on keskmine. Need on salvestuse suhtes proportsionaalsed, nii et kaamera võtab kaadrist sama osa olenemata sellest, kas salvestad 1080p monitori või 6K monitori. Ja kui salvestasid kogu ekraani asemel piirkonna, ankurdub ülekate monitori nurga asemel selle piirkonna nurka, nii et see jääb võtte sisse.

Seda saad ka otse kutsuda käsuga `omarchy-capture-webcam-resize small` või keskmise juurde naasmiseks käsuga `reset`.

## Tekst, QR-koodid ja värvid

`Super + Ctrl + Print Screen` valib piirkonna ja OCR-ib selle lõikelauale. Seda käsitletakse korralikult jaotises [Teksti eraldamine ja dikteerimine](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ teeb sama trikki QR-koodidega. Vali piirkond, kus kood on, ja dekodeeritud väärtus läheb lõikelauale. See otsib ainult QR-koode — tihe ekraanisisu kipub muidu valepositiivselt vöötkoodina ära tuntama. Tasub teada: dekodeeritud väärtus läheb lõikelauale ja mitte kuhugi mujale. Seda ei prindita, seda ei ole teavituses ja see on märgitud tundlikuks, nii et see ei jää [lõikelaua ajalukku](08-unified-clipboard-history.md) pidama. QR-koodid kannavad rutiinselt saladusi — näiteks 2FA seadistuskoodi taga olevat `otpauth://` URI-d — ja sa ei taha seda logisse. Kleepimine töötab endiselt hästi.

`Super + Print Screen` (või _Trigger > Capture > Color_) muudab kursori pipetiks. Klõpsa ekraanil ükskõik mida ja värv jõuab lõikelauale. Ilma valimata taganemiseks vajuta kiirklahvi uuesti.

## Transkodeerimine enne jagamist

4K ekraanisalvestus või töötlemata HEIC sinu telefonist on sageli lihtsalt saatmiseks liiga suur. `Super + Ctrl + .` (või _Trigger > Transcode_) parandab selle. See pakub sulle häguse failivalija kaustade `~/Pictures` ja `~/Videos` kohal ning küsib seejärel vormingut ja suurust.

Pildid lähevad vormingusse jpg või png kvaliteediga kõrge, keskmine või madal, mis piiravad laiuse vastavalt 3160, 2160 ja 1080 pikslini. Videod lähevad vormingusse mp4 või animeeritud gif eraldusvõimega 4k, 1080p või 720p. Teisendatud fail kirjutatakse originaali kõrvale nii, et eraldusvõime on nimes — `demo-1080p.mp4` — ja tee kopeeritakse lõikelauale faili URI-na, nii et saad selle otse failide lohistamist vastu võtvasse rakendusse kleepida.

See töötab ka terminalist, kui tead juba, mida soovid: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Olemas on ka `omarchy transcode ascii`, mis muudab pildi ASCII kunstiks — see on peamiselt [brändimise](41-branding.md) jaoks.

## Selle kuhugi saatmine

Kui fail on olemas, avab `Super + Ctrl + S` jagamismenüü ja saadab selle LocalSendi kaudu sinu võrgus olevale teisele seadmele. Selle kohta vaata [GUI-sid](22-guis.md).
