# Ekraanitõmmised ja salvestamine

Kõik, mida saad ekraanilt haarata, sõltub Print Screen klahvist. Üks klahv omaette teeb pildi ja modifikaatorid teevad salvestuse, värvi või piirkonna sees oleva teksti. Kui su klaviatuuril pole Print Screen klahvi üldse, avab `Super + Ctrl + C` sama kogumi menüüna.

| Kiirklahv | Funktsioon |
| ------ | -------- |
| `Print Screen` | Ekraanitõmmis |
| `Alt + Print Screen` | Ekraanisalvestus (või peatab töötava) |
| `Super + Print Screen` | Värvivalija |
| `Super + Ctrl + Print Screen` | Eralda tekst piirkonnast |
| `Super + Ctrl + C` | Jäädvusta menüü |
| `Super + Ctrl + .` | Kodeeri pilt või video ümber |

## Ekraanitõmmised

Vajuta `Print Screen` ja Omasnap jäädvustab fookuses oleva kuvari enne, kui selle pealiskiht ilmub, nii et miski ei nihku su all sihtides. Lohista vabakäelise piirkonna, klõpsa akent selle jäädvustamiseks või klõpsa tühja ruumi kogu kuvari jäädvustamiseks. Vajuta `S` enne joonistamist, et jäädvustada keriv piirkond. Muutsid meelt? Vajuta `Print Screen` uuesti, et Omasnap sulgeda.

Pärast ala valimist salvestab Omasnap jäädvustuse, kopeerib selle lõikelauale ja näitab eelvaadet 10 sekundi jooksul. Kasuta eelvaate kinnitusnuppu või `Ctrl + P`, et see ekraanile jätta, või vali Edit selle annoteerimiseks.

Annotatsiooniredaktor saab joonistada nooli, jooni, kujundeid, esiletõste, nummerdatud tähiseid ja teksti ning turvalisi redaktsioone; kärpida või lõigata osa pildist välja; OCR-ida selle teksti; ja lisada tausta. Redaktoris vajuta `Enter`, et valmis PNG kopeerida ja salvestada, `Ctrl + C`, et kopeerida ilma salvestamata, või `Ctrl + S`, et salvestada ilma kopeerimata.

Salvestatud ekraanitõmmised maanduvad vaikimisi `~/Pictures/Screenshots`-i, sellise nimega nagu `screenshot-2026-08-13_14-22-05-firefox.png`. Sea `OMASNAP_SCREENSHOT_DIR`, et kasutada teist kataloogi — vt [KKK](46-faq.md) selle kohta, kuhu seansi keskkonnamuutujad panna. Omasnap loob kataloogi, kui salvestab esimese tõmmise. Sea `[output] autosave = false` failis `~/.config/omasnap/omasnap.conf`, et automaatne salvestamine keelata.

Terminalist avab `omarchy screenshot` sama pealiskihi ja saad valida selle algrežiimi: `omarchy capture screenshot region`, `windows`, `fullscreen` või `scroll`. Teine argument `copy` või `save` jätab eelvaate vahele ja saadab tõmmise otse sellesse sihtkohta. Enne väljundit muutmiseks kasuta `omarchy screenshot --editor=overlay` täisekraani redaktori jaoks või `omarchy screenshot --editor=window` eraldi akna jaoks.

### Valija juhtimine klaviatuurilt

Kui valik on üleval, ei pea sa hiirt üldse kasutama:

| Klahv | Funktsioon |
| --- | -------- |
| `S` | Lülita keriva piirkonna režiim |
| `Super + Arrow keys` | Liigu akende vahel Window režiimis |
| `Return` | Jäädvusta esiletõstetud aken |
| `Ctrl + A` | Jäädvusta täielik fookuses olev kuvar |
| `R` | Taasta viimane selles seansis joonistatud piirkond |
| `Esc` | Sulge Omasnap |

Need seosed eksisteerivad ainult seni, kuni Omasnap on avatud, nii et need ei saa millegagi sinu enda seadistuses kokku põrkuda.

## Ekraanisalvestus

`Alt + Print Screen` avab _Käivita > Jäädvusta > Ekraanisalvestus_, mis küsib, mida soovid heliribale: heli pole, töölaua heli, töölaud pluss mikrofon või töölaud pluss mikrofon pluss veebikaamera. See viimane ilmub ainult siis, kui sul on päriselt kaamera ühendatud. Vali üks ja Omarchy salvestusvalija laseb sul piirkonna lohistada või aknal või kuvaril klõpsata.

Salvestamine töötab gpu-screen-recorderil, mis kodeerib GPU-l 60fps ja läheb vajaduse korral CPU juurde tagasi. Tulemus on MP4 failis `~/Videos`, nimega `screenrecording-2026-08-13_14-22-05.mp4`. Sea `OMARCHY_SCREENRECORD_DIR`, et seda muuta — kuid pane tähele, et erinevalt ekraanitõmmiste kataloogist peab see juba olemas olema, muidu keeldub salvestamine algamast.

Kui salvestad, ilmub ribale väike näidik. Klõpsa seda peatamiseks. Saad peatada ka `Alt + Print Screen` abil uuesti või kirje _Peata ekraanisalvestus_ alt _Käivita > Jäädvusta > Ekraanisalvestus_, mis ilmub ainult siis, kui midagi päriselt salvestatakse.

Peatamine teeb enne faili üleandmist veidi koristustööd: esimene kaader kärbitakse ja kui on heli, normaliseeritakse see -14 LUFS-ini, PipeWire'i jäädvustuse plõks päris alguses vaigistatuna. Seejärel ilmub teavitus koos pisipildiga salvestusest. Klõpsa seda, et fail mpv-s esitada.

### Veebikaamera pealiskiht

Kui salvestad veebikaameraga, ilmub kaamera kinnitatud, kärbitud portreeaknana selle alumisse paremasse nurka, mida salvestad. Kui see asub millegi peal, mida vajad, muuda selle suurust lennult:

| Kiirklahv | Funktsioon |
| ------ | -------- |
| `Super + Alt + [` | Tee veebikaamera pealiskiht väiksemaks |
| `Super + Alt + ]` | Tee veebikaamera pealiskiht suuremaks |

On kolm suurust — väike, keskmine ja suur — ja kiirklahvid astuvad nende vahel. Keskmine on vaikimisi. Need on salvestusega proportsionaalsed, nii et kaamera võtab sama osa kaadrist, olenemata sellest, kas salvestad 1080p kuvarit või 6K kuvarit. Ja kui salvestasid piirkonna, mitte kogu ekraani, ankurdub pealiskiht selle piirkonna nurga, mitte kuvari nurga külge, nii et see jääb kaadri sisse.

Saad seda kutsuda ka otse `omarchy-capture-webcam-resize small` abil või `reset`, et keskmise juurde tagasi minna.

## Tekst, QR-koodid ja värvid

`Super + Ctrl + Print Screen` valib piirkonna ja OCR-ib selle lõikelauale. See on korralikult käsitletud dokumendis [Teksti eraldamine ja dikteerimine](11-text-extraction-dictation.md).

_Käivita > Jäädvusta > QR-kood_ teeb QR-koodide puhul sama trikki. Vali piirkond koos koodiga ja dekrüptitud väärtus läheb lõikelauale. See otsib ainult QR-koode — tihedal ekraanisisul on kombeks muidu triipkoodina valpositiivselt läbi käia. Tasub teada: dekrüptitud väärtus läheb lõikelauale ja mitte kuskile mujale. Seda ei prindita, see pole teavituses ja see on tähistatud tundlikuna, nii et see ei jää [lõikelaua ajaloosse](08-unified-clipboard-history.md) pidama. QR-koodid kannavad rutiinselt saladusi — näiteks `otpauth://` URI 2FA seadistuskoodi taga — ja sa ei taha seda logisse. Kleepimine töötab endiselt hästi.

`Super + Print Screen` (või _Käivita > Jäädvusta > Värv_) muudab kursori pipetiks. Klõpsa ekraanil mida iganes ja värv maandub lõikelaual. Vajuta kiirklahvi uuesti, et valimata tagasi minna.

## Ümberkodeerimine enne jagamist

4K ekraanisalvestus või töötlemata HEIC telefonist on sageli liiga suur, et lihtsalt saata. `Super + Ctrl + .` (või _Käivita > Kodeeri ümber_) parandab selle. See pakub sulle hägusa failivalija `~/Pictures` ja `~/Videos` kohal, seejärel küsib vormingut ja suurust.

Pildid lähevad jpg või png vormingusse kõrge, keskmise või madala korral, mis piiravad laiuse 3160, 2160 ja 1080 pikslini. Videod lähevad mp4 või animeeritud gif vormingusse 4k, 1080p või 720p korral. Teisendatud fail kirjutatakse originaali kõrvale eraldusvõimega nimes — `demo-1080p.mp4` — ja tee kopeeritakse lõikelauale faili URI-na, nii et saad selle otse rakendusse kleepida, mis võtab vastu failide kukutamist.

See töötab ka terminalist, kui juba tead, mida soovid: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Olemas on ka `omarchy transcode ascii`, mis muudab pildi ASCII kunstiks — see on enamasti [brändingu](41-branding.md) jaoks.

## Selle saatmine kuhugi

Kui fail on olemas, avab `Super + Ctrl + S` menüü Jaga ja saadab selle teisele seadmele su võrgus LocalSendi kaudu. Selle kohta vt [GUI-d](22-guis.md).
