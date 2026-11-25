# Ekraanipildid ja salvestamine

Kõik, mida ekraanilt haarata saad, käib Print Screen klahvi kaudu. Üks klahv üksi teeb pildi ja modifikaatorid teevad salvestuse, valivad värvi või võtavad teksti piirkonna seest. Kui sinu klaviatuuril Print Screen klahvi üldse ei ole, teeb `Super + Ctrl + Alt + C` sama ekraanipildi ja `Super + Ctrl + C` avab kogu komplekti menüüna.

| Klahvikombinatsioon | Funktsioon |
| ------ | -------- |
| `Print Screen` | Ekraanipilt |
| `Super + Ctrl + Alt + C` | Ekraanipilt |
| `Alt + Print Screen` | Ekraanisalvestus (või peata käimasolev) |
| `Super + Print Screen` | Värvivalija |
| `Super + Ctrl + Print Screen` | Võta tekst piirkonnast välja |
| `Super + Ctrl + C` | Hõive menüü |
| `Super + Ctrl + .` | Transkodeeri pilt või video |

## Ekraanipildid

Vajuta `Print Screen` (või `Super + Ctrl + Alt + C`) ja Omasnap hõivab fokuseeritud monitori enne, kui selle kiht ilmub, nii et miski ei nihku sinu all, samal ajal kui sihid. Lohista vabas vormis piirkond, klõpsa akent selle hõivamiseks või klõpsa tühja kohta kogu monitori hõivamiseks. Vajuta enne joonistamist `S`, et hõivata keriv piirkond. Muutsid meelt? Vajuta sama klahvi uuesti, et Omasnap sulgeda.

Pärast piirkonna valimist salvestab Omasnap hõive, kopeerib selle lõikelauale ja näitab pisipildiga teavitust, nagu salvestatud ekraanisalvestus teeb. Vali Open, et vaadata salvestatud pilti oma pildivaaturis, või Edit, et seda annoteerida.

Annotatsiooniredaktor oskab joonistada nooli, jooni, kujundeid, esiletõste, nummerdatud tähiseid, teksti ja turvalisi varjamisi; kärpida või lõigata välja osa pildist; OCR-ida selle teksti; ja lisada tausta. Redaktoris vajuta `Enter`, et kopeerida ja salvestada valmis PNG, `Ctrl + C`, et kopeerida see salvestamata, või `Ctrl + S`, et salvestada see kopeerimata.

Salvestatud ekraanipildid satuvad vaikimisi kausta `~/Pictures/Screenshots`, nimega nagu `screenshot-2026-08-13_14-22-05-firefox.png`. Määra `OMASNAP_SCREENSHOT_DIR`, et kasutada teist kausta — vaata [KKK-d](46-faq.md), et teada saada, kuhu seansi keskkonnamuutujad panna. Omasnap loob kausta, kui salvestab esimese pildi. Määra `~/.config/omasnap/omasnap.conf` failis `[output] autosave = false`, et automaatne salvestamine keelata; hõived siis ainult kopeeritakse ja neid näidatakse 7 sekundit eelvaates, mille saad selle kinnitusnupuga või `Ctrl + P` abil ekraanile jätta.

Terminalist avab `omarchy screenshot` sama kihi ja saad valida selle algrežiimi: `omarchy capture screenshot region`, `windows`, `fullscreen` või `scroll`. Teine argument `copy` või `save` saadab pildi otse sellesse sihtkohta. Et enne väljundit muuta, kasuta `omarchy screenshot --editor=overlay` täisekraaniredaktori jaoks või `omarchy screenshot --editor=window` eraldi akna jaoks.

### Valija juhtimine klaviatuurilt

Kuni valik on üleval, ei pea sa hiirt üldse kasutama:

| Klahv | Funktsioon |
| --- | -------- |
| `S` | Lülita keriva piirkonna režiimi |
| `Super + Arrow keys` | Liigu akende vahel akna režiimis |
| `Return` | Hõiva esiletõstetud aken |
| `Ctrl + A` | Hõiva kogu fokuseeritud monitor |
| `R` | Taasta viimane selles seansis joonistatud piirkond |
| `Esc` | Sulge Omasnap |

Need seosed on olemas ainult kuni Omasnap on avatud, nii et need ei saa sinu enda konfiguratsioonis millegagi kokku põrgata.

## Ekraanisalvestus

`Alt + Print Screen` avab _Trigger > Capture > Screenrecord_, mis küsib, mida sa heliribal tahad: heli puudub, töölaua heli, töölaud pluss mikrofon või töölaud pluss mikrofon pluss veebikaamera. See viimane ilmub ainult siis, kui sul on tegelikult kaamera ühendatud. Vali üks ja Omarchy salvestusvalija laseb sul lohistada piirkonna või klõpsata akent või monitori.

Salvestus töötab gpu-screen-recorder peal, mis kodeerib GPU peal 60fps ja läheb vajadusel tagasi CPU peale; GPU-del, mida see ei toeta, näiteks Apple Silicon omadel, salvestab Omarchy selle asemel wf-recorder abil. Tulemus on MP4 kaustas `~/Videos`, nimega `screenrecording-2026-08-13_14-22-05.mp4`. Määra `OMARCHY_SCREENRECORD_DIR`, et seda muuta — aga pane tähele, et erinevalt ekraanipiltide kaustast peab see juba olemas olema, muidu salvestus keeldub käivitumast.

Kuni sa salvestad, ilmub ribale väike indikaator. Klõpsa seda, et peatada. Saad peatada ka uuesti `Alt + Print Screen` abil või _Stop Screenrecording_ kirje abil _Trigger > Capture > Screenrecord_ all, mis ilmub ainult kuni midagi tegelikult salvestab.

Peatamine teeb enne faili sulle üleandmist natuke koristust: esimene kaader lõigatakse ära ja kui heli on olemas, normaliseeritakse see -14 LUFS peale, nii et PipeWire hõive praksatus päris alguses vaigistatakse. Seejärel ilmub teavitus koos salvestuse pisipildiga. Vali _Open_, et esitada fail Omaview-s, või _Cut_, et lõigata seda Omacut-is.

### Veebikaamera kiht

Kui salvestad veebikaameraga, ilmub kaamera kinnitatud, kärbitud portreeaknana selle paremas alanurgas, mida iganes sa salvestad. Kui see istub millegi peal, mida sul vaja on, muuda selle suurust käigu pealt:

| Klahvikombinatsioon | Funktsioon |
| ------ | -------- |
| `Super + Alt + [` | Tee veebikaamera kiht väiksemaks |
| `Super + Alt + ]` | Tee veebikaamera kiht suuremaks |

Suurusi on kolm — väike, keskmine ja suur — ja klahvikombinatsioonid astuvad nende vahel. Keskmine on vaikimisi. Need on salvestuse suhtes proportsionaalsed, nii et kaamera võtab sama osa kaadrist, olenemata sellest, kas salvestad 1080p monitori või 6K oma. Ja kui salvestasid pigem piirkonna kui kogu ekraani, ankurdub kiht selle piirkonna nurga, mitte monitori nurga külge, nii et see jääb pildi sisse.

Saad seda ka otse kutsuda `omarchy-capture-webcam-resize small` abil või `reset` abil, et minna tagasi keskmise peale.

## Tekst, QR koodid ja värvid

`Super + Ctrl + Print Screen` valib piirkonna ja OCR-ib selle lõikelauale. Seda on korralikult käsitletud [Teksti väljavõtmine ja dikteerimine](11-text-extraction-dictation.md) all.

_Trigger > Capture > QR Code_ teeb sama triki QR koodide jaoks. Vali piirkond, milles kood on, ja dekodeeritud väärtus läheb lõikelauale. See otsib ainult QR koode — tihe ekraanisisu kipub muidu valepositiivselt vöötkoodina tunduma. Tasub teada: dekodeeritud väärtus läheb lõikelauale ja mitte kuhugi mujale. Seda ei trükita, see ei ole teavituses ja see on märgitud tundlikuks, nii et see ei jää [lõikelaua ajalukku](08-unified-clipboard-history.md) pidama. QR koodid kannavad rutiinselt saladusi — `otpauth://` URI 2FA seadistuskoodi taga, näiteks — ja sa ei taha seda logisse. Kleepimine töötab ikka hästi.

`Super + Print Screen` (või _Trigger > Capture > Color_) muudab kursori tilgutiks. Klõpsa ükskõik mida ekraanil ja värv satub lõikelauale. Vajuta klahvikombinatsiooni uuesti, et ilma valimata taganeda.

## Transkodeerimine enne jagamist

4K ekraanisalvestus või töötlemata HEIC sinu telefonist on sageli liiga suur, et seda lihtsalt saata. `Super + Ctrl + .` (või _Trigger > Transcode_) parandab selle. See pakub sulle hägust failivalijat `~/Pictures` ja `~/Videos` kohal, seejärel küsib vormingut ja suurust.

Pildid lähevad jpg või png formaati kõrge, keskmise või madala tasemega, mis piiravad laiuse vastavalt 3160, 2160 ja 1080 pikslini. Videod lähevad mp4 või animeeritud gif formaati 4k, 1080p või 720p tasemel. Teisendatud fail kirjutatakse originaali kõrvale, eraldusvõime nime sees — `demo-1080p.mp4` — ja tee kopeeritakse lõikelauale faili URI-na, nii et saad selle otse kleepida rakendusse, mis võtab failide lohistamisi vastu.

See töötab ka terminalist, kui tead juba, mida tahad: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Olemas on ka `omarchy transcode ascii`, mis muudab pildi ASCII kunstiks — see on enamasti [brändingu](41-branding.md) jaoks.

## Selle kuhugi saatmine

Kui sul on fail käes, avab `Super + Ctrl + S` Share menüü ja saadab selle LocalSend kaudu sinu võrgus olevale teisele seadmele. Vaata selle jaoks [GUIs](22-guis.md).
