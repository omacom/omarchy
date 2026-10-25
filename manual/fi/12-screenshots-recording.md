# Kuvakaappaukset ja tallennus

Kaikki, mitä voit napata näytöltä, kulkee Print Screen -näppäimen kautta. Yksi näppäin yksinään ottaa kuvan, ja muokkausnäppäimet ottavat tallenteen, värin tai aluetta sisällä olevan tekstin. Jos näppäimistössäsi ei ole Print Screen -näppäintä lainkaan, `Super + Ctrl + Alt + C` ottaa saman kuvakaappauksen ja `Super + Ctrl + C` avaa koko valikoiman valikkona.

| Hotkey | Function |
| ------ | -------- |
| `Print Screen` | Kuvakaappaus |
| `Super + Ctrl + Alt + C` | Kuvakaappaus |
| `Alt + Print Screen` | Näytön tallennus (tai pysäytä käynnissä oleva tallennus) |
| `Super + Print Screen` | Värinpoimija |
| `Super + Ctrl + Print Screen` | Poimi teksti alueelta |
| `Super + Ctrl + C` | Kaappausvalikko |
| `Super + Ctrl + .` | Muunna kuva tai video |

## Kuvakaappaukset

Paina `Print Screen` (tai `Super + Ctrl + Alt + C`), niin Omasnap kaappaa kohdistetun näytön ennen kuin sen peittokerros ilmestyy, joten mikään ei liiku allasi tähtäämisen aikana. Vedä vapaamuotoinen alue, napsauta ikkunaa kaapataksesi sen tai napsauta tyhjää tilaa kaapataksesi koko näytön. Paina `S` ennen piirtämistä kaapataksesi vierivän alueen. Muutitko mielesi? Paina samaa näppäintä uudelleen sulkeaksesi Omasnapin.

Kun olet valinnut alueen, Omasnap tallentaa kaappauksen, kopioi sen leikepöydälle ja näyttää esikatselun 10 sekunnin ajan. Kiinnitä se näytölle esikatselun kiinnityspainikkeella tai `Ctrl + P` -näppäinyhdistelmällä tai valitse Edit lisätäksesi siihen merkintöjä.

Merkintäeditorissa voit piirtää nuolia, viivoja, muotoja, korostuksia, numeroituja merkkejä ja tekstiä sekä tehdä turvallisia peittoja; rajata tai leikata pois osan kuvasta; tunnistaa sen tekstin OCR:llä; ja lisätä taustan. Paina editorissa `Enter` kopioidaksesi ja tallentaaksesi valmiin PNG:n, `Ctrl + C` kopioidaksesi sen tallentamatta tai `Ctrl + S` tallentaaksesi sen kopioimatta.

Tallennetut kuvakaappaukset päätyvät oletuksena kansioon `~/Pictures/Screenshots` nimellä, joka on esimerkiksi `screenshot-2026-08-13_14-22-05-firefox.png`. Aseta `OMASNAP_SCREENSHOT_DIR` käyttääksesi toista kansiota — katso [UKK](46-faq.md), jossa kerrotaan, mihin istunnon ympäristömuuttujat laitetaan. Omasnap luo kansion tallentaessaan ensimmäisen kuvan. Aseta tiedostossa `~/.config/omasnap/omasnap.conf` kohta `[output] autosave = false` poistaaksesi automaattisen tallennuksen käytöstä.

Päätteessä `omarchy screenshot` avaa saman peittokerroksen, ja voit valita sen aloitustilan: `omarchy capture screenshot region`, `windows`, `fullscreen` tai `scroll`. Toinen argumentti `copy` tai `save` ohittaa esikatselun ja lähettää kuvan suoraan kyseiseen kohteeseen. Jos haluat muokata ennen tulostusta, käytä vaihtoehtoa `omarchy screenshot --editor=overlay` koko näytön editoriin tai `omarchy screenshot --editor=window` erilliseen ikkunaan.

### Valitsimen käyttäminen näppäimistöltä

Valinnan ollessa esillä sinun ei tarvitse käyttää hiirtä lainkaan:

| Key | Function |
| --- | -------- |
| `S` | Vaihda vierivän alueen tila päälle tai pois |
| `Super + Arrow keys` | Siirry ikkunoiden välillä ikkunatilassa |
| `Return` | Kaappaa korostettu ikkuna |
| `Ctrl + A` | Kaappaa koko kohdistettu näyttö |
| `R` | Palauta tässä istunnossa viimeksi piirretty alue |
| `Esc` | Sulje Omasnap |

Nämä sidokset ovat olemassa vain Omasnapin ollessa avoinna, joten ne eivät voi törmätä mihinkään omassa konfiguraatiossasi.

## Näytön tallennus

`Alt + Print Screen` avaa _Trigger > Capture > Screenrecord_ -kohdan, joka kysyy, mitä ääniraidalle haluat: ei ääntä, työpöydän äänen, työpöydän ja mikrofonin tai työpöydän, mikrofonin ja verkkokameran. Viimeinen vaihtoehto näkyy vain, jos sinulla todella on kamera kytkettynä. Valitse yksi, niin Omarchyn tallennusvalitsin antaa sinun vetää alueen tai napsauttaa ikkunaa tai näyttöä.

Tallennus toimii gpu-screen-recorderilla, joka koodaa GPU:lla nopeudella 60fps ja käyttää tarvittaessa varalla CPU:ta. Tuloksena on MP4 kansiossa `~/Videos`, nimeltään `screenrecording-2026-08-13_14-22-05.mp4`. Aseta `OMARCHY_SCREENRECORD_DIR` muuttaaksesi sitä — mutta huomaa, että toisin kuin kuvakaappauskansio, tämän on oltava jo olemassa, tai tallennus kieltäytyy käynnistymästä.

Tallentamisen aikana palkkiin ilmestyy pieni ilmaisin. Pysäytä napsauttamalla sitä. Voit pysäyttää myös painamalla uudelleen `Alt + Print Screen` tai kohdasta _Trigger > Capture > Screenrecord_ löytyvällä _Stop Screenrecording_ -merkinnällä, joka näkyy vain silloin, kun jotain todella tallennetaan.

Pysäyttäminen siistii hieman ennen tiedoston luovuttamista: ensimmäinen ruutu leikataan pois, ja jos ääntä on, se normalisoidaan tasoon -14 LUFS ja PipeWire-kaappauksen aivan alussa kuuluva poksahdus vaimennetaan. Sitten ilmestyy ilmoitus, jossa on tallenteesta otettu pikkukuva. Paina sitä toistaaksesi tiedoston mpv:ssä.

### Verkkokameran peittokerros

Kun tallennat verkkokameran kanssa, kamera näkyy kiinnitettynä, rajattuna muotokuvaikkunana tallentamasi kuvan oikeassa alakulmassa. Jos se on jonkin tarvitsemasi asian päällä, muuta sen kokoa lennossa:

| Hotkey | Function |
| ------ | -------- |
| `Super + Alt + [` | Pienennä verkkokameran peittokerrosta |
| `Super + Alt + ]` | Suurenna verkkokameran peittokerrosta |

Kokoja on kolme — pieni, keskikokoinen ja suuri — ja pikanäppäimet siirtyvät niiden välillä. Keskikokoinen on oletus. Ne ovat suhteessa tallenteeseen, joten kamera vie saman osuuden kuvasta riippumatta siitä, tallennatko 1080p-näyttöä vai 6K-näyttöä. Ja jos tallensit alueen etkä koko näyttöä, peittokerros ankkuroituu kyseisen alueen kulmaan näytön kulman sijaan, joten se pysyy kuvan sisällä.

Voit kutsua sitä myös suoraan komennolla `omarchy-capture-webcam-resize small` tai palata keskikokoiseen komennolla `reset`.

## Teksti, QR-koodit ja värit

`Super + Ctrl + Print Screen` valitsee alueen ja tunnistaa sen tekstin OCR:llä leikepöydälle. Tämä käsitellään kunnolla kohdassa [Tekstin poiminta ja sanelu](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ tekee saman tempun QR-koodeille. Valitse alue, jossa koodi on, niin purettu arvo menee leikepöydälle. Se etsii vain QR-koodeja — tiheä näytön sisältö muuttuu muuten mielellään erheellisesti viivakoodiksi. Hyvä tietää: purettu arvo menee leikepöydälle eikä minnekään muualle. Sitä ei tulosteta, sitä ei ole ilmoituksessa, ja se on merkitty arkaluontoiseksi, joten se ei jää roikkumaan [leikepöydän historiaan](08-unified-clipboard-history.md). QR-koodit kantavat rutiininomaisesti salaisuuksia — esimerkiksi 2FA-määrityskoodin takana oleva `otpauth://`-URI — etkä halua sellaista lokiin. Liittäminen toimii silti hienosti.

`Super + Print Screen` (tai _Trigger > Capture > Color_) muuttaa kohdistimen pipetiksi. Napsauta mitä tahansa näytöllä, niin väri päätyy leikepöydälle. Paina pikanäppäintä uudelleen perääntyäksesi poimimatta.

## Muuntaminen ennen jakamista

4K-näytöntallenne tai raaka HEIC puhelimestasi on usein liian iso vain lähetettäväksi. `Super + Ctrl + .` (tai _Trigger > Transcode_) korjaa sen. Se tarjoaa sinulle sumean tiedostovalitsimen kansioiden `~/Pictures` ja `~/Videos` yli ja kysyy sitten muotoa ja kokoa.

Kuvat muunnetaan jpg- tai png-muotoon laadulla high, medium tai low, jotka rajoittavat leveyden 3160, 2160 ja 1080 pikseliin. Videot muunnetaan mp4-muotoon tai animoiduksi gif-tiedostoksi tarkkuudella 4k, 1080p tai 720p. Muunnettu tiedosto kirjoitetaan alkuperäisen viereen niin, että tarkkuus on nimessä — `demo-1080p.mp4` — ja polku kopioidaan leikepöydälle tiedoston URI:na, joten voit liittää sen suoraan sovellukseen, joka ottaa vastaan tiedostopudotuksia.

Se toimii myös päätteestä, jos tiedät jo, mitä haluat: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. On myös `omarchy transcode ascii`, joka muuttaa kuvan ASCII-taiteeksi — se on lähinnä [brändäystä](41-branding.md) varten.

## Lähettäminen jonnekin

Kun sinulla on tiedosto, `Super + Ctrl + S` avaa Share-valikon ja lähettää sen verkossasi olevalle toiselle laitteelle LocalSendin kautta. Katso sitä varten [Graafiset käyttöliittymät](22-guis.md).
