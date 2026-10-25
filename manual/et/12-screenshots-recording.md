# Ekraanipildid ja salvestamine

Kõik, mida ekraanilt haarata saad, ripub Print Screen klahvi küljes. Üks klahv üksi teeb pildi ja modifikaatorid teevad salvestuse, värvi või piirkonna sees oleva teksti. Kui sinu klaviatuuril Print Screen klahvi üldse pole, teeb `Super + Ctrl + Alt + C` sama ekraanipildi ja `Super + Ctrl + C` avab kogu komplekti menüüna.

| Kiirklahv | Funktsioon |
| ------ | -------- |
| `Print Screen` | Ekraanipilt |
| `Super + Ctrl + Alt + C` | Ekraanipilt |
| `Alt + Print Screen` | Ekraanisalvestus (või peata käimasolev) |
| `Super + Print Screen` | Värvivalija |
| `Super + Ctrl + Print Screen` | Eralda tekst piirkonnast |
| `Super + Ctrl + C` | Jäädvustamise menüü |
| `Super + Ctrl + .` | Kodeeri pilt või video ümber |

## Ekraanipildid

Vajuta `Print Screen` (või `Super + Ctrl + Alt + C`) ja Omasnap jäädvustab fookuses monitori enne, kui selle kattekiht ilmub, nii et sihtimise ajal ei nihku sinu all midagi. Lohista vabakäeline piirkond, klõpsa selle jäädvustamiseks aknal või klõpsa kogu monitori jäädvustamiseks tühjal alal. Keritava piirkonna jäädvustamiseks vajuta enne joonistamist `S`. Muutsid meelt? Omasnap'i sulgemiseks vajuta uuesti sama klahvi.

Pärast ala valimist salvestab Omasnap tõmmise, kopeerib selle lõikelauale ja näitab 10 sekundit eelvaadet. Ekraanile hoidmiseks kasuta eelvaate kinnitusnuppu või `Ctrl + P`, või vali selle annoteerimiseks Edit.

Annoteerimisredaktor oskab joonistada nooli, jooni, kujundeid, esiletõste ja nummerdatud tähiseid, lisada teksti ja turvalisi varjamisi; pilti kärpida või sellest osa välja lõigata; selle teksti OCR-iga lugeda; ja tausta lisada. Redaktoris vajuta valmis PNG kopeerimiseks ja salvestamiseks `Enter`, salvestamata kopeerimiseks `Ctrl + C` või kopeerimata salvestamiseks `Ctrl + S`.

Salvestatud ekraanipildid jõuavad vaikimisi kausta `~/Pictures/Screenshots`, nimega nagu `screenshot-2026-08-13_14-22-05-firefox.png`. Teise kataloogi kasutamiseks määra `OMASNAP_SCREENSHOT_DIR` — vaata [KKK](46-faq.md), et teada saada, kuhu seansi keskkonnamuutujad panna. Omasnap loob kataloogi, kui salvestab esimese pildi. Automaatse salvestamise keelamiseks määra failis `~/.config/omasnap/omasnap.conf` väärtus `[output] autosave = false`.

Terminalist avab `omarchy screenshot` sama kattekihi ja valida saad selle algrežiimi: `omarchy capture screenshot region`, `windows`, `fullscreen` või `scroll`. Teine argument `copy` või `save` jätab eelvaate vahele ja saadab pildi otse sihtkohta. Enne väljastamist muutmiseks kasuta täisekraaniredaktori jaoks käsku `omarchy screenshot --editor=overlay` või eraldi akna jaoks käsku `omarchy screenshot --editor=window`.

### Valija juhtimine klaviatuurilt

Kuni valik on üleval, ei pea sa üldse hiirt kasutama:

| Klahv | Funktsioon |
| --- | -------- |
| `S` | Lülita keritava piirkonna režiim sisse/välja |
| `Super + Arrow keys` | Liigu aknarežiimis akende vahel |
| `Return` | Jäädvusta esiletõstetud aken |
| `Ctrl + A` | Jäädvusta kogu fookuses monitor |
| `R` | Taasta selles seansis viimati joonistatud piirkond |
| `Esc` | Sulge Omasnap |

Need seosed on olemas ainult seni, kuni Omasnap on avatud, nii et need ei saa sinu enda konfiguratsioonis millegagi kokku põrgata.

## Ekraani salvestamine

`Alt + Print Screen` avab _Trigger > Capture > Screenrecord_, mis küsib, mida sa heliribale soovid: heli ei ole, töölaua heli, töölaud pluss mikrofon või töölaud pluss mikrofon pluss veebikaamera. Viimane ilmub ainult siis, kui sul on kaamera tegelikult ühendatud. Vali üks ja Omarchy salvestusvalija laseb sul piirkonna lohistada või aknal või monitoril klõpsata.

Salvestus töötab gpu-screen-recorder peal, mis kodeerib GPU peal 60fps ja langeb vajadusel tagasi CPU peale. Tulemus on MP4 kaustas `~/Videos`, nimega `screenrecording-2026-08-13_14-22-05.mp4`. Selle muutmiseks määra `OMARCHY_SCREENRECORD_DIR` — aga pane tähele, et erinevalt ekraanipiltide kataloogist peab see juba olemas olema, muidu keeldub salvestus käivitumast.

Salvestamise ajal ilmub ribale väike indikaator. Peatamiseks klõpsa seda. Peatada saad ka uuesti `Alt + Print Screen` vajutades või kirje _Stop Screenrecording_ alt _Trigger > Capture > Screenrecord_, mis ilmub ainult seni, kuni midagi tegelikult salvestatakse.

Peatamine teeb enne faili üleandmist natuke koristustööd: esimene kaader kärbitakse maha ja kui heli on olemas, normaliseeritakse see -14 LUFS peale ning PipeWire jäädvustuse plõks päris alguses vaigistatakse. Seejärel ilmub teavitus koos salvestuse pisipildiga. Faili mpv-s esitamiseks klõpsa seda.

### Veebikaamera kattekiht

Kui salvestad veebikaameraga, ilmub kaamera kinnitatud, kärbitud portreeaknana salvestatava paremas alanurgas. Kui see istub millegi vajaliku peal, muuda selle suurust käigu pealt:

| Kiirklahv | Funktsioon |
| ------ | -------- |
| `Super + Alt + [` | Tee veebikaamera kattekiht väiksemaks |
| `Super + Alt + ]` | Tee veebikaamera kattekiht suuremaks |

Suurusi on kolm — väike, keskmine ja suur — ja kiirklahvid astuvad nende vahel. Keskmine on vaikimisi. Need on salvestuse suhtes proportsionaalsed, nii et kaamera võtab kaadrist sama osa, olenemata sellest, kas salvestad 1080p monitori või 6K monitori. Ja kui salvestasid terve ekraani asemel piirkonna, ankurdub kattekiht selle piirkonna nurga, mitte monitori nurga külge, nii et see jääb pildi sisse.

Seda saad ka otse kutsuda käsuga `omarchy-capture-webcam-resize small` või keskmise juurde tagasi minemiseks käsuga `reset`.

## Tekst, QR-koodid ja värvid

`Super + Ctrl + Print Screen` valib piirkonna ja OCR-ib selle lõikelauale. Seda käsitletakse korralikult jaotises [Teksti eraldamine ja dikteerimine](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ teeb sama triki QR-koodidega. Vali piirkond, milles kood on, ja dekodeeritud väärtus läheb lõikelauale. See otsib ainult QR-koode — tihe ekraanisisu kipub muidu vöötkoodina valepositiivselt läbi minema. Tasub teada: dekodeeritud väärtus läheb lõikelauale ja mitte kuhugi mujale. Seda ei prindita, seda pole teavituses ja see on märgitud tundlikuks, nii et see ei jää [lõikelaua ajalukku](08-unified-clipboard-history.md) pidama. QR-koodid kannavad rutiinselt saladusi — näiteks 2FA seadistuskoodi taga olev `otpauth://` URI — ja sa ei taha seda logisse. Kleebimine töötab endiselt hästi.

`Super + Print Screen` (või _Trigger > Capture > Color_) muudab kursori pipetiks. Klõpsa ekraanil ükskõik mida ja värv jõuab lõikelauale. Valimata taganemiseks vajuta uuesti kiirklahvi.

## Ümberkodeerimine enne jagamist

4K ekraanisalvestus või töötlemata HEIC sinu telefonist on sageli lihtsalt saatmiseks liiga suur. `Super + Ctrl + .` (või _Trigger > Transcode_) parandab selle. See pakub sulle häguse failivalija kaustade `~/Pictures` ja `~/Videos` kohal ning küsib seejärel vormingut ja suurust.

Pildid lähevad jpg või png vormingusse kõrge, keskmise või madala tasemega, mis piiravad laiuse vastavalt 3160, 2160 ja 1080 piksliga. Videod lähevad mp4 või animeeritud gif vormingusse 4k, 1080p või 720p tasemega. Teisendatud fail kirjutatakse originaali kõrvale, eraldusvõime nimes — `demo-1080p.mp4` — ja tee kopeeritakse lõikelauale faili URI-na, nii et saad selle otse failide kukutamist vastu võtvasse rakendusse kleepida.

See töötab ka terminalist, kui tead juba, mida soovid: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Olemas on ka `omarchy transcode ascii`, mis muudab pildi ASCII kunstiks — see on enamasti [brändingu](41-branding.md) jaoks.

## Kuskile saatmine

Kui fail on sul olemas, avab `Super + Ctrl + S` menüü Share ja saadab selle LocalSend kaudu sinu võrgus olevale teisele seadmele. Selle kohta vaata [GUIs](22-guis.md).
