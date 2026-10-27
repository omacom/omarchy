# Ekraanipildid ja salvestamine

Kõik, mida ekraanilt haarata saab, ripub Print Screen klahvi küljes. Klahv üksi teeb pildi ja modifikaatorid teevad salvestuse, värvi või piirkonnas oleva teksti. Kui sinu klaviatuuril Print Screen klahvi üldse pole, teeb `Super + Ctrl + Alt + C` sama ekraanipildi ja `Super + Ctrl + C` avab kogu komplekti menüüna.

| Kiirklahv | Funktsioon |
| ------ | -------- |
| `Print Screen` | Ekraanipilt |
| `Super + Ctrl + Alt + C` | Ekraanipilt |
| `Alt + Print Screen` | Ekraanisalvestus (või peata töötav salvestus) |
| `Super + Print Screen` | Värvivalija |
| `Super + Ctrl + Print Screen` | Eralda piirkonnast tekst |
| `Super + Ctrl + C` | Pildistamismenüü |
| `Super + Ctrl + .` | Kodeeri pilt või video ümber |

## Ekraanipildid

Vajuta `Print Screen` (või `Super + Ctrl + Alt + C`) ja Omasnap pildistab fokuseeritud monitori enne, kui selle kiht ilmub, nii et sihtimise ajal ei nihku miski sinu all. Lohista vabakujuline piirkond, klõpsa akent selle pildistamiseks või klõpsa tühja kohta kogu monitori pildistamiseks. Vajuta enne joonistamist `S`, et pildistada keritav piirkond. Muutsid meelt? Vajuta sama klahvi uuesti, et Omasnap sulgeda.

Pärast ala valimist salvestab Omasnap pildi, kopeerib selle lõikelauale ja näitab pisipildiga teavitust, nagu salvestatud ekraanisalvestuski teeb. Vali Open, et vaadata salvestatud pilti oma pildivaaturis, või Edit, et seda annoteerida.

Annotatsiooniredaktor oskab joonistada nooli, jooni, kujundeid, esiletõsteid, nummerdatud tähiseid, teksti ja turvalisi varjamisi; pilti kärpida või sellest osa välja lõigata; selle teksti OCR-ida; ja lisada tausta. Redaktoris vajuta `Enter`, et kopeerida ja salvestada valmis PNG, `Ctrl + C`, et kopeerida ilma salvestamata, või `Ctrl + S`, et salvestada ilma kopeerimata.

Salvestatud ekraanipildid jõuavad vaikimisi kausta `~/Pictures/Screenshots`, nimega nagu `screenshot-2026-08-13_14-22-05-firefox.png`. Määra `OMASNAP_SCREENSHOT_DIR`, et kasutada teist kausta — vaata [KKK-d](46-faq.md), et teada saada, kuhu sessiooni keskkonnamuutujad panna. Omasnap loob kausta esimese pildi salvestamisel. Määra failis `~/.config/omasnap/omasnap.conf` `[output] autosave = false`, et automaatne salvestamine keelata; pildid siis ainult kopeeritakse ja näidatakse 10 sekundit eelvaates, mille saad selle kinnitusnupuga või `Ctrl + P` abil ekraanile jätta.

Terminalist avab `omarchy screenshot` sama kihi ja saad valida selle algrežiimi: `omarchy capture screenshot region`, `windows`, `fullscreen` või `scroll`. Teine argument `copy` või `save` saadab pildi otse sellesse sihtkohta. Enne väljastamist muutmiseks kasuta `omarchy screenshot --editor=overlay` täisekraaniredaktori jaoks või `omarchy screenshot --editor=window` eraldi akna jaoks.

### Valiku juhtimine klaviatuurilt

Kuni valik on üleval, ei pea sa hiirt üldse kasutama:

| Klahv | Funktsioon |
| --- | -------- |
| `S` | Lülita keritava piirkonna režiim sisse või välja |
| `Super + Arrow keys` | Liigu akende vahel Window režiimis |
| `Return` | Pildista esiletõstetud aken |
| `Ctrl + A` | Pildista kogu fokuseeritud monitor |
| `R` | Taasta selles sessioonis viimati joonistatud piirkond |
| `Esc` | Sulge Omasnap |

Need seosed on olemas ainult siis, kui Omasnap on avatud, nii et need ei saa sinu enda konfiguratsioonis millegagi kokku põrgata.

## Ekraanisalvestus

`Alt + Print Screen` avab _Trigger > Capture > Screenrecord_, mis küsib, mida sa heliribale tahad: heli pole, töölauaheli, töölaud pluss mikrofon või töölaud pluss mikrofon pluss veebikaamera. Viimane ilmub ainult siis, kui sul on kaamera tegelikult ühendatud. Vali üks ja Omarchy salvestusvalija laseb sul lohistada piirkonna või klõpsata akent või monitori.

Salvestus töötab gpu-screen-recorder peal, mis kodeerib GPU peal 60fps ja läheb vajadusel CPU peale tagasi. Tulemuseks on MP4 kaustas `~/Videos`, nimega `screenrecording-2026-08-13_14-22-05.mp4`. Määra `OMARCHY_SCREENRECORD_DIR`, et seda muuta — aga pane tähele, et erinevalt ekraanipiltide kaustast peab see juba olemas olema, muidu keeldub salvestus käivitumast.

Salvestamise ajal ilmub ribale väike indikaator. Klõpsa seda peatamiseks. Saad peatada ka uuesti `Alt + Print Screen` vajutades või kirje _Stop Screenrecording_ alt _Trigger > Capture > Screenrecord_, mis ilmub ainult siis, kui midagi tegelikult salvestatakse.

Peatamine teeb enne faili üleandmist pisut koristust: esimene kaader kärbitakse ära ja kui heli on, normaliseeritakse see -14 LUFS peale, kusjuures PipeWire'i pildistamise plõks päris alguses vaigistatakse välja. Seejärel ilmub salvestuse pisipildiga teavitus. Klõpsa seda, et fail mpv-s mängida.

### Veebikaamera kiht

Kui salvestad veebikaameraga, ilmub kaamera kinnitatud, kärbitud portreeaknana selle paremas alanurgas, mida iganes sa salvestad. Kui see istub millegi vajaliku peal, muuda selle suurust käigu pealt:

| Kiirklahv | Funktsioon |
| ------ | -------- |
| `Super + Alt + [` | Tee veebikaamera kiht väiksemaks |
| `Super + Alt + ]` | Tee veebikaamera kiht suuremaks |

Suurusi on kolm — väike, keskmine ja suur — ja kiirklahvid astuvad nende vahel. Keskmine on vaikimisi. Need on salvestuse suhtes proportsionaalsed, nii et kaamera võtab sama osa kaadrist, kas salvestad 1080p monitori või 6K oma. Ja kui salvestasid terve ekraani asemel piirkonna, ankurdub kiht monitori nurga asemel selle piirkonna nurka, nii et see jääb pildi sisse.

Saad seda kutsuda ka otse käsuga `omarchy-capture-webcam-resize small` või `reset`, et minna tagasi keskmisele.

## Tekst, QR-koodid ja värvid

`Super + Ctrl + Print Screen` valib piirkonna ja OCR-ib selle lõikelauale. Seda käsitletakse korralikult jaotises [Teksti eraldamine ja dikteerimine](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ teeb QR-koodidega sama trikki. Vali piirkond, kus kood on, ja dekodeeritud väärtus läheb lõikelauale. See otsib ainult QR-koode — tihe ekraanisisu kipub muidu vöötkoodina valepositiive andma. Tasub teada: dekodeeritud väärtus läheb lõikelauale ja mitte kuhugi mujale. Seda ei prindita, seda pole teavituses ja see on märgitud tundlikuks, nii et see ei jää [lõikelaua ajalukku](08-unified-clipboard-history.md) pidama. QR-koodid kannavad rutiinselt saladusi — näiteks 2FA seadistuskoodi taga olev `otpauth://` URI — ja sa ei taha seda logisse. Kleebimine töötab ikka hästi.

`Super + Print Screen` (või _Trigger > Capture > Color_) muudab kursori pipetiks. Klõpsa ekraanil ükskõik mida ja värv jõuab lõikelauale. Vajuta kiirklahvi uuesti, et ilma valimata väljuda.

## Ümberkodeerimine enne jagamist

4K ekraanisalvestus või töötlemata HEIC telefonist on sageli lihtsalt saatmiseks liiga suur. `Super + Ctrl + .` (või _Trigger > Transcode_) parandab selle. See pakub sulle häguse failivalija kaustade `~/Pictures` ja `~/Videos` kohal, seejärel küsib vormingut ja suurust.

Pildid lähevad jpg või png vormingusse kõrge, keskmise või madala tasemega, mis piiravad laiuse vastavalt 3160, 2160 ja 1080 piksliga. Videod lähevad mp4 või animeeritud gif vormingusse 4k, 1080p või 720p. Teisendatud fail kirjutatakse originaali kõrvale, eraldusvõime nime sees — `demo-1080p.mp4` — ja tee kopeeritakse lõikelauale faili URI-na, nii et saad selle otse kleepida rakendusse, mis võtab vastu failide lohistamist.

See töötab ka terminalist, kui tead juba, mida tahad: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. On ka `omarchy transcode ascii`, mis muudab pildi ASCII-kunstiks — see on enamasti [brändingu](41-branding.md) jaoks.

## Selle kuhugi saatmine

Kui fail käes, avab `Super + Ctrl + S` Share menüü ja saadab selle LocalSend kaudu sinu võrgus olevale teisele seadmele. Selle kohta vaata [GUI-sid](22-guis.md).
