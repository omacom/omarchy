# Kuvakaappaukset & tallennus

Kaikki, mitä voit napata ruudulta, kulkee Print Screen -näppäimen kautta. Näppäin yksinään ottaa kuvan, ja muokkausnäppäimet ottavat tallenteen, värin tai alueen sisällä olevan tekstin. Jos näppäimistössäsi ei ole Print Screen -näppäintä lainkaan, `Super + Ctrl + Alt + C` ottaa saman kuvakaappauksen, ja `Super + Ctrl + C` avaa koko valikoiman valikkona.

| Pikanäppäin | Toiminto |
| ------ | -------- |
| `Print Screen` | Kuvakaappaus |
| `Super + Ctrl + Alt + C` | Kuvakaappaus |
| `Alt + Print Screen` | Näytöntallennus (tai käynnissä olevan lopettaminen) |
| `Super + Print Screen` | Värivalitsin |
| `Super + Ctrl + Print Screen` | Poimi teksti alueelta |
| `Super + Ctrl + C` | Kaappausvalikko |
| `Super + Ctrl + .` | Muunna kuva tai video |

## Kuvakaappaukset

Paina `Print Screen` (tai `Super + Ctrl + Alt + C`), ja Omasnap kaappaa kohdistetun näytön ennen kuin sen peittokuva ilmestyy, joten mikään ei siirry allasi tähtäämisen aikana. Vedä vapaamuotoinen alue, napsauta ikkunaa kaapataksesi sen tai napsauta tyhjää tilaa kaapataksesi koko näytön. Paina `S` ennen piirtämistä kaapataksesi vieritettävän alueen. Muutitko mielesi? Paina samaa näppäintä uudelleen sulkeaksesi Omasnapin.

Kun olet valinnut alueen, Omasnap tallentaa kaappauksen, kopioi sen leikepöydälle ja näyttää ilmoituksen sen pienoiskuvalla, kuten tallennettu näytöntallenne tekee. Valitse Open nähdäksesi tallennetun kuvan kuvankatseluohjelmassasi tai Edit lisätäksesi siihen merkintöjä.

Merkintäeditorilla voi piirtää nuolia, viivoja, muotoja, korostuksia, numeroituja merkkejä, tekstiä ja turvallisia peittoja; rajata tai leikata pois osan kuvasta; tehdä sen tekstille OCR-tekstintunnistuksen; ja lisätä taustan. Paina editorissa `Enter` kopioidaksesi ja tallentaaksesi valmiin PNG:n, `Ctrl + C` kopioidaksesi sen tallentamatta tai `Ctrl + S` tallentaaksesi sen kopioimatta.

Tallennetut kuvakaappaukset päätyvät oletuksena kansioon `~/Pictures/Screenshots` nimellä kuten `screenshot-2026-08-13_14-22-05-firefox.png`. Aseta `OMASNAP_SCREENSHOT_DIR` käyttääksesi toista kansiota — katso [UKK](46-faq.md) siitä, minne istunnon ympäristömuuttujat laitetaan. Omasnap luo kansion tallentaessaan ensimmäisen kuvan. Aseta `[output] autosave = false` tiedostossa `~/.config/omasnap/omasnap.conf` poistaaksesi automaattisen tallennuksen käytöstä; kaappaukset kopioidaan silloin vain, ja ne näytetään 10 sekunnin esikatselussa, jonka voit pitää ruudulla sen kiinnityspainikkeella tai näppäimillä `Ctrl + P`.

Päätteestä `omarchy screenshot` avaa saman peittokuvan, ja voit valita sen aloitustilan: `omarchy capture screenshot region`, `windows`, `fullscreen` tai `scroll`. Toinen argumentti `copy` tai `save` lähettää kuvan suoraan kyseiseen kohteeseen. Muokataksesi ennen tulostusta käytä komentoa `omarchy screenshot --editor=overlay` kokoruudun editoriin tai `omarchy screenshot --editor=window` erilliseen ikkunaan.

### Valitsimen ohjaaminen näppäimistöltä

Kun valinta on auki, sinun ei tarvitse käyttää hiirtä lainkaan:

| Näppäin | Toiminto |
| --- | -------- |
| `S` | Vaihda vieritettävän alueen tilaa |
| `Super + Arrow keys` | Siirry ikkunoiden välillä Ikkuna-tilassa |
| `Return` | Kaappaa korostettu ikkuna |
| `Ctrl + A` | Kaappaa koko kohdistettu näyttö |
| `R` | Palauta viimeksi tässä istunnossa piirretty alue |
| `Esc` | Sulje Omasnap |

Nämä sidonnat ovat olemassa vain Omasnapin ollessa auki, joten ne eivät voi törmätä mihinkään omassa konfiguraatiossasi.

## Näytön tallennus

`Alt + Print Screen` avaa kohdan _Trigger > Capture > Screenrecord_, joka kysyy, mitä haluat ääniraidalle: ei ääntä, työpöydän ääni, työpöytä ja mikrofoni tai työpöytä, mikrofoni ja verkkokamera. Viimeinen vaihtoehto näkyy vain, jos sinulla on oikeasti kamera kytkettynä. Valitse yksi, ja Omarchyn tallennusvalitsin antaa sinun vetää alueen tai napsauttaa ikkunaa tai näyttöä.

Tallennus toimii gpu-screen-recorderilla, joka koodaa GPU:lla 60fps:n nopeudella ja turvautuu CPU:hun, jos on pakko. Tuloksena on MP4-tiedosto kansiossa `~/Videos` nimellä `screenrecording-2026-08-13_14-22-05.mp4`. Aseta `OMARCHY_SCREENRECORD_DIR` muuttaaksesi sitä — mutta huomaa, että toisin kuin kuvakaappauskansio, tämän on oltava jo olemassa, tai tallennus kieltäytyy käynnistymästä.

Tallennuksen aikana palkkiin ilmestyy pieni ilmaisin. Napsauta sitä lopettaaksesi. Voit lopettaa myös painamalla `Alt + Print Screen` uudelleen tai kohdasta _Stop Screenrecording_ kohdan _Trigger > Capture > Screenrecord_ alta, joka näkyy vain, kun jotain todella tallennetaan.

Lopettaminen tekee hieman siivousta ennen kuin se luovuttaa tiedoston: ensimmäinen ruutu leikataan pois, ja jos ääntä on, se normalisoidaan -14 LUFS:iin ja PipeWire-kaappauksen poksahdus aivan alussa mykistetään. Sitten ilmestyy ilmoitus, jossa on pienoiskuva tallenteesta. Napsauta sitä toistaaksesi tiedoston Omaviewissa.

### Verkkokameran peittokuva

Kun tallennat verkkokameralla, kamera näkyy kiinnitettynä, rajattuna muotokuvaikkunana tallentamasi kohteen oikeassa alakulmassa. Jos se on jonkin tarvitsemasi päällä, muuta sen kokoa lennossa:

| Pikanäppäin | Toiminto |
| ------ | -------- |
| `Super + Alt + [` | Pienennä verkkokameran peittokuvaa |
| `Super + Alt + ]` | Suurenna verkkokameran peittokuvaa |

Kokoja on kolme — pieni, keskikokoinen ja suuri — ja pikanäppäimet siirtyvät niiden välillä. Keskikokoinen on oletus. Ne ovat suhteessa tallenteeseen, joten kamera vie saman osuuden ruudusta, tallensitpa 1080p-näyttöä tai 6K-näyttöä. Ja jos tallensit alueen etkä koko näyttöä, peittokuva ankkuroituu kyseisen alueen kulmaan näytön kulman sijaan, joten se pysyy kuvan sisällä.

Voit kutsua sitä myös suoraan komennolla `omarchy-capture-webcam-resize small` tai komennolla `reset` palataksesi keskikokoiseen.

## Teksti, QR-koodit ja värit

`Super + Ctrl + Print Screen` valitsee alueen ja tekee sille OCR-tekstintunnistuksen leikepöydälle. Se on käsitelty kunnolla kohdassa [Tekstin poiminta ja sanelu](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ tekee saman tempun QR-koodeille. Valitse alue, jossa koodi on, ja purettu arvo menee leikepöydälle. Se etsii vain QR-koodeja — tiheä ruudun sisältö tuppaa muuten antamaan vääriä positiivisia viivakoodeina. Hyvä tietää: purettu arvo menee leikepöydälle eikä minnekään muualle. Sitä ei tulosteta, se ei ole ilmoituksessa, ja se on merkitty arkaluontoiseksi, joten se ei jää roikkumaan [leikepöydän historiaan](08-unified-clipboard-history.md). QR-koodit kantavat rutiininomaisesti salaisuuksia — esimerkiksi 2FA-asennuskoodin takana oleva `otpauth://`-URI — etkä halua sitä lokiin. Liittäminen toimii silti hyvin.

`Super + Print Screen` (tai _Trigger > Capture > Color_) muuttaa kohdistimen pipetiksi. Napsauta mitä tahansa ruudulla, ja väri päätyy leikepöydälle. Paina pikanäppäintä uudelleen perääntyäksesi valitsematta.

## Muuntaminen ennen jakamista

4K-näytöntallenne tai raaka HEIC puhelimestasi on usein liian suuri vain lähetettäväksi. `Super + Ctrl + .` (tai _Trigger > Transcode_) korjaa sen. Se tarjoaa sinulle sumean tiedostonvalitsimen kansioiden `~/Pictures` ja `~/Videos` yli ja kysyy sitten muotoa ja kokoa.

Kuvat menevät jpg- tai png-muotoon korkealla, keskitasoisella tai matalalla asetuksella, jotka rajoittavat leveyden 3160, 2160 ja 1080 pikseliin. Videot menevät mp4-muotoon tai animoiduksi gif-tiedostoksi tarkkuuksilla 4k, 1080p tai 720p. Muunnettu tiedosto kirjoitetaan alkuperäisen viereen resoluutio nimessään — `demo-1080p.mp4` — ja polku kopioidaan leikepöydälle tiedoston URI:na, joten voit liittää sen suoraan sovellukseen, joka ottaa vastaan tiedostojen pudotuksia.

Se toimii myös päätteestä, jos tiedät jo, mitä haluat: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. On myös `omarchy transcode ascii`, joka muuttaa kuvan ASCII-taiteeksi — se on lähinnä [brändäystä](41-branding.md) varten.

## Lähettäminen jonnekin

Kun sinulla on tiedosto, `Super + Ctrl + S` avaa Share-valikon ja lähettää sen toiseen laitteeseen verkossasi LocalSendin kautta. Katso siitä kohta [Graafiset käyttöliittymät](22-guis.md).
