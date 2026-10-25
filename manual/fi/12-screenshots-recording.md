# Kuvakaappaukset ja tallennus

Kaikki, mitä näytöltä voi napata, kulkee Print Screen -näppäimen kautta. Yksi näppäin yksinään ottaa kuvan, ja muuntimet ottavat tallenteen, värin tai alueen sisällä olevan tekstin. Jos näppäimistössäsi ei ole Print Screen -näppäintä lainkaan, `Super + Ctrl + Alt + C` ottaa saman kuvakaappauksen, ja `Super + Ctrl + C` avaa koko kokonaisuuden valikkona.

| Pikanäppäin | Toiminto |
| ------ | -------- |
| `Print Screen` | Kuvakaappaus |
| `Super + Ctrl + Alt + C` | Kuvakaappaus |
| `Alt + Print Screen` | Näytön tallennus (tai käynnissä olevan tallennuksen pysäyttäminen) |
| `Super + Print Screen` | Värinvalitsin |
| `Super + Ctrl + Print Screen` | Poimi teksti alueelta |
| `Super + Ctrl + C` | Kaappausvalikko |
| `Super + Ctrl + .` | Muunna kuva tai video |

## Kuvakaappaukset

Paina `Print Screen` (tai `Super + Ctrl + Alt + C`), niin Omasnap kaappaa kohdistetun näytön ennen kuin sen päällyskuva ilmestyy, joten mikään ei liiku allasi tähtäämisen aikana. Vedä vapaamuotoinen alue, napsauta ikkunaa kaapataksesi sen tai napsauta tyhjää tilaa kaapataksesi koko näytön. Paina `S` ennen piirtämistä kaapataksesi vierivän alueen. Muutitko mielesi? Paina samaa näppäintä uudelleen sulkeaksesi Omasnapin.

Kun olet valinnut alueen, Omasnap tallentaa kaappauksen, kopioi sen leikepöydälle ja näyttää ilmoituksen sen esikatselukuvan kanssa, aivan kuten tallennettu näyttötallenne tekee. Valitse Open katsoaksesi tallennettua kuvaa kuvankatseluohjelmassasi tai Edit lisätäksesi siihen merkintöjä.

Merkintäeditorilla voi piirtää nuolia, viivoja, muotoja, korostuksia, numeroituja merkkejä ja tekstiä sekä tehdä turvallisia peittoja; rajata tai leikata pois osan kuvasta; tunnistaa sen tekstin OCR:llä; ja lisätä taustan. Paina editorissa `Enter` kopioidaksesi ja tallentaaksesi valmiin PNG:n, `Ctrl + C` kopioidaksesi sen tallentamatta tai `Ctrl + S` tallentaaksesi sen kopioimatta.

Tallennetut kuvakaappaukset päätyvät oletuksena kansioon `~/Pictures/Screenshots` nimellä kuten `screenshot-2026-08-13_14-22-05-firefox.png`. Aseta `OMASNAP_SCREENSHOT_DIR` käyttääksesi toista kansiota — katso [UKK](46-faq.md), niin tiedät, minne istunnon ympäristömuuttujat laitetaan. Omasnap luo kansion tallentaessaan ensimmäisen kuvan. Aseta `[output] autosave = false` tiedostossa `~/.config/omasnap/omasnap.conf` poistaaksesi automaattisen tallennuksen käytöstä; kaappaukset sitten vain kopioidaan ja näytetään 10 sekunnin esikatselussa, jonka voit pitää näytöllä sen kiinnityspainikkeella tai `Ctrl + P` -näppäimillä.

Päätteestä `omarchy screenshot` avaa saman päällyskuvan, ja voit valita sen aloitustilan: `omarchy capture screenshot region`, `windows`, `fullscreen` tai `scroll`. Toinen argumentti `copy` tai `save` lähettää kuvan suoraan kyseiseen kohteeseen. Jos haluat muokata ennen tulostusta, käytä komentoa `omarchy screenshot --editor=overlay` koko näytön editoriin tai `omarchy screenshot --editor=window` erilliseen ikkunaan.

### Valitsimen käyttäminen näppäimistöllä

Valinnan ollessa auki sinun ei tarvitse käyttää hiirtä lainkaan:

| Näppäin | Toiminto |
| --- | -------- |
| `S` | Vaihda vierivän alueen tilaa |
| `Super + Arrow keys` | Siirry ikkunoiden välillä Ikkuna-tilassa |
| `Return` | Kaappaa korostettu ikkuna |
| `Ctrl + A` | Kaappaa koko kohdistettu näyttö |
| `R` | Palauta tässä istunnossa viimeksi piirretty alue |
| `Esc` | Sulje Omasnap |

Nämä sidonnat ovat olemassa vain Omasnapin ollessa auki, joten ne eivät voi törmätä mihinkään omassa asetustiedostossasi.

## Näytön tallennus

`Alt + Print Screen` avaa _Trigger > Capture > Screenrecord_, joka kysyy, mitä ääniraidalle haluat: ei ääntä, työpöydän äänen, työpöydän ja mikrofonin tai työpöydän, mikrofonin ja verkkokameran. Viimeinen näkyy vain, jos sinulla on oikeasti kamera kytkettynä. Valitse yksi, niin Omarchyn tallennusvalitsin antaa vetää alueen tai napsauttaa ikkunaa tai näyttöä.

Tallennus toimii gpu-screen-recorderilla, joka koodaa GPU:lla 60 fps:n nopeudella ja palaa CPU:hun, jos sen on pakko. Tuloksena on MP4 kansiossa `~/Videos` nimellä `screenrecording-2026-08-13_14-22-05.mp4`. Aseta `OMARCHY_SCREENRECORD_DIR` muuttaaksesi sitä — mutta huomaa, että toisin kuin kuvakaappauskansio, tämän on oltava jo olemassa, tai tallennus kieltäytyy käynnistymästä.

Tallentaessasi palkkiin ilmestyy pieni ilmaisin. Napsauta sitä lopettaaksesi. Voit lopettaa myös painamalla `Alt + Print Screen` uudelleen tai kohdasta _Stop Screenrecording_ valikossa _Trigger > Capture > Screenrecord_, joka näkyy vain, kun jotain oikeasti tallennetaan.

Lopettaminen tekee hieman siistimistä ennen tiedoston luovuttamista: ensimmäinen ruutu leikataan pois, ja jos ääntä on, se normalisoidaan -14 LUFS:iin ja PipeWire-kaappauksen napsahdus aivan alussa mykistetään. Sitten ilmestyy ilmoitus tallenteesta otetun esikatselukuvan kanssa. Napsauta sitä toistaaksesi tiedoston mpv:ssä.

### Verkkokameran päällyskuva

Kun tallennat verkkokameran kanssa, kamera näkyy kiinnitettynä, rajattuna muotokuvaikkunana tallentamasi kuvan oikeassa alakulmassa. Jos se on jonkin tarvitsemasi päällä, muuta sen kokoa lennossa:

| Pikanäppäin | Toiminto |
| ------ | -------- |
| `Super + Alt + [` | Pienennä verkkokameran päällyskuvaa |
| `Super + Alt + ]` | Suurenna verkkokameran päällyskuvaa |

Kokoja on kolme — pieni, keskikokoinen ja suuri — ja pikanäppäimet liikkuvat niiden välillä. Keskikokoinen on oletus. Ne ovat suhteessa tallenteeseen, joten kamera vie saman osuuden ruudusta, tallensitpa 1080p-näyttöä tai 6K-näyttöä. Ja jos tallensit alueen koko näytön sijaan, päällyskuva ankkuroituu kyseisen alueen kulmaan näytön kulman sijaan, joten se pysyy kuvan sisällä.

Voit kutsua sitä myös suoraan komennolla `omarchy-capture-webcam-resize small` tai `reset` palataksesi keskikokoiseen.

## Teksti, QR-koodit ja värit

`Super + Ctrl + Print Screen` valitsee alueen ja tunnistaa sen tekstin OCR:llä leikepöydälle. Sitä käsitellään kunnolla kohdassa [Tekstin poiminta ja sanelu](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ tekee saman tempun QR-koodeille. Valitse alue, jossa koodi on, niin purettu arvo menee leikepöydälle. Se etsii vain QR-koodeja — tiheällä näytön sisällöllä on tapana antaa muuten vääriä viivakoodiosumia. Hyvä tietää: purettu arvo menee leikepöydälle eikä minnekään muualle. Sitä ei tulosteta, se ei ole ilmoituksessa, ja se on merkitty arkaluonteiseksi, joten se ei jää roikkumaan [leikepöytähistoriaan](08-unified-clipboard-history.md). QR-koodit kantavat rutiininomaisesti salaisuuksia — esimerkiksi 2FA-määrityskoodin taustalla olevan `otpauth://`-URI:n — etkä halua sitä lokiin. Liittäminen toimii silti hyvin.

`Super + Print Screen` (tai _Trigger > Capture > Color_) muuttaa kohdistimen pipetiksi. Napsauta mitä tahansa näytöllä, niin väri päätyy leikepöydälle. Paina pikanäppäintä uudelleen perääntyäksesi valitsematta.

## Muuntaminen ennen jakamista

4K-näyttötallenne tai raaka HEIC puhelimestasi on usein liian iso vain lähetettäväksi. `Super + Ctrl + .` (tai _Trigger > Transcode_) korjaa sen. Se tarjoaa sinulle sumean tiedostonvalitsimen kansioiden `~/Pictures` ja `~/Videos` yli ja kysyy sitten muotoa ja kokoa.

Kuvat menevät jpg:ksi tai png:ksi korkealla, keskitasoisella tai matalalla laadulla, jotka rajoittavat leveyden 3160, 2160 ja 1080 pikseliin. Videot menevät mp4:ksi tai animoiduksi gif:ksi tarkkuuksilla 4k, 1080p tai 720p. Muunnettu tiedosto kirjoitetaan alkuperäisen viereen resoluutio nimessään — `demo-1080p.mp4` — ja polku kopioidaan leikepöydälle tiedoston URI:na, joten voit liittää sen suoraan sovellukseen, joka ottaa vastaan tiedostopudotuksia.

Se toimii myös päätteestä, jos tiedät jo, mitä haluat: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. On myös `omarchy transcode ascii`, joka muuttaa kuvan ASCII-taiteeksi — se on lähinnä [brändäystä](41-branding.md) varten.

## Lähettäminen jonnekin

Kun sinulla on tiedosto, `Super + Ctrl + S` avaa Share-valikon ja lähettää sen toiseen laitteeseen verkossasi LocalSendin kautta. Katso sitä varten [graafiset käyttöliittymät](22-guis.md).
