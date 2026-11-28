# Kuvakaappaukset ja tallennus

Kaikki, mitä voit kaapata ruudulta, löytyy Print Screen -näppäimen takaa. Näppäin yksinään ottaa kuvan, ja muokkausnäppäimet ottavat tallenteen, värin tai alueen sisällä olevan tekstin. Jos näppäimistössäsi ei ole Print Screen -näppäintä lainkaan, `Super + Ctrl + Alt + C` ottaa saman kuvakaappauksen, ja `Super + Ctrl + C` avaa koko valikoiman valikkona.

| Pikanäppäin | Toiminto |
| ------ | -------- |
| `Print Screen` | Kuvakaappaus |
| `Super + Ctrl + Alt + C` | Kuvakaappaus |
| `Alt + Print Screen` | Näytön tallennus (tai pysäytä käynnissä oleva tallennus) |
| `Super + Print Screen` | Värien poimija |
| `Super + Ctrl + Print Screen` | Poimi teksti alueelta |
| `Super + Ctrl + C` | Kaappausvalikko |
| `Super + Ctrl + .` | Muunna kuva tai video toiseen muotoon |

## Kuvakaappaukset

Paina `Print Screen` (tai `Super + Ctrl + Alt + C`), niin Omasnap kaappaa kohdistetun näytön ennen peittokuvansa ilmestymistä, joten mikään ei siirry allasi tähtäämisen aikana. Vedä vapaamuotoinen alue, napsauta ikkunaa kaapataksesi sen tai napsauta tyhjää tilaa kaapataksesi koko näytön. Paina `S` ennen piirtämistä kaapataksesi vierivän alueen. Muutitko mielesi? Sulje Omasnap painamalla samaa näppäintä uudelleen.

Kun olet valinnut alueen, Omasnap tallentaa kaappauksen, kopioi sen leikepöydälle ja näyttää ilmoituksen sen pienoiskuvan kanssa, aivan kuten tallennettu näytön tallenne tekee. Valitse Open avataksesi tallennetun kuvan kuvankatseluohjelmassasi tai Edit lisätäksesi siihen merkintöjä.

Merkintäeditorilla voit piirtää nuolia, viivoja, muotoja, korostuksia, numeroituja merkkejä, tekstiä ja suojattuja mustauksia; rajata tai leikata pois osan kuvasta; tunnistaa sen tekstin OCR:llä; ja lisätä taustan. Editorissa kopioi ja tallenna valmis PNG painamalla `Enter`, kopioi se tallentamatta painamalla `Ctrl + C` tai tallenna se kopioimatta painamalla `Ctrl + S`.

Tallennetut kuvakaappaukset päätyvät oletuksena kansioon `~/Pictures/Screenshots` nimellä, kuten `screenshot-2026-08-13_14-22-05-firefox.png`. Aseta `OMASNAP_SCREENSHOT_DIR` käyttääksesi toista kansiota — katso [UKK](46-faq.md), niin näet, minne istunnon ympäristömuuttujat laitetaan. Omasnap luo kansion tallentaessaan ensimmäisen kuvan. Aseta `~/.config/omasnap/omasnap.conf`-tiedostoon `[output] autosave = false` poistaaksesi automaattisen tallennuksen käytöstä; kaappaukset vain kopioidaan silloin, ja ne näytetään 7 sekuntia esikatselussa, jonka voit pitää ruudulla sen kiinnityspainikkeella tai näppäimillä `Ctrl + P`.

Päätteestä `omarchy screenshot` avaa saman peittokuvan, ja voit valita sen aloitustilan: `omarchy capture screenshot region`, `windows`, `fullscreen` tai `scroll`. Toinen argumentti `copy` tai `save` lähettää kuvan suoraan kyseiseen kohteeseen. Jos haluat muokata ennen tulostusta, käytä koko ruudun editoriin komentoa `omarchy screenshot --editor=overlay` tai erilliseen ikkunaan komentoa `omarchy screenshot --editor=window`.

### Valitsimen käyttäminen näppäimistöllä

Kun valinta on esillä, sinun ei tarvitse käyttää hiirtä lainkaan:

| Näppäin | Toiminto |
| --- | -------- |
| `S` | Vaihda vierivän alueen tilaa |
| `Super + Arrow keys` | Siirry ikkunoiden välillä Ikkuna-tilassa |
| `Return` | Kaappaa korostettu ikkuna |
| `Ctrl + A` | Kaappaa koko kohdistettu näyttö |
| `R` | Palauta tässä istunnossa viimeksi piirretty alue |
| `Esc` | Sulje Omasnap |

Nämä sidonnat ovat olemassa vain, kun Omasnap on auki, joten ne eivät voi törmätä mihinkään omassa konfiguraatiossasi.

## Näytön tallennus

`Alt + Print Screen` avaa _Trigger > Capture > Screenrecord_, joka kysyy, mitä haluat ääniraidalle: ei ääntä, työpöydän äänen, työpöydän ja mikrofonin tai työpöydän, mikrofonin ja verkkokameran. Viimeinen vaihtoehto näkyy vain, jos sinulla on oikeasti kamera kytkettynä. Valitse yksi, niin Omarchyn tallennusvalitsin antaa sinun vetää alueen tai napsauttaa ikkunaa tai näyttöä.

Tallennus käyttää gpu-screen-recorderia, joka koodaa GPU:lla 60fps:n nopeudella ja turvautuu CPU:hun, jos on pakko; GPU:illa, joita se ei tue, kuten Apple Siliconilla, Omarchy tallentaa sen sijaan wf-recorderilla. Tuloksena on MP4-tiedosto kansiossa `~/Videos` nimellä `screenrecording-2026-08-13_14-22-05.mp4`. Muuta sitä asettamalla `OMARCHY_SCREENRECORD_DIR` — mutta huomaa, että toisin kuin kuvakaappauskansio, tämän kansion on oltava jo olemassa, tai tallennus kieltäytyy käynnistymästä.

Tallennuksen aikana palkkiin ilmestyy pieni ilmaisin. Pysäytä napsauttamalla sitä. Voit pysäyttää myös painamalla uudelleen `Alt + Print Screen` tai valitsemalla kohdan _Stop Screenrecording_ kohdasta _Trigger > Capture > Screenrecord_, joka näkyy vain, kun jotain todella tallennetaan.

Pysäyttäminen siistii hieman ennen tiedoston luovuttamista sinulle: ensimmäinen ruutu trimmataan pois, ja jos ääntä on, se normalisoidaan -14 LUFS:iin ja PipeWire-kaappauksen napsahdus aivan alussa mykistetään pois. Sitten ilmestyy ilmoitus, jossa on tallenteesta otettu pienoiskuva. Valitse _Open_ toistaaksesi tiedoston Omaview'ssa tai _Cut_ trimmataaksesi sen Omacutissa.

### Verkkokameran peittokuva

Kun tallennat verkkokameran kanssa, kamera ilmestyy kiinnitettynä, rajattuna muotokuvaikkunana tallentamasi kuvan oikeaan alakulmaan. Jos se on jonkin tarvitsemasi päällä, muuta sen kokoa lennossa:

| Pikanäppäin | Toiminto |
| ------ | -------- |
| `Super + Alt + [` | Pienennä verkkokameran peittokuvaa |
| `Super + Alt + ]` | Suurenna verkkokameran peittokuvaa |

Kokoja on kolme — pieni, keskikokoinen ja suuri — ja pikanäppäimet siirtyvät niiden välillä. Keskikokoinen on oletus. Ne ovat suhteessa tallenteeseen, joten kamera vie saman osuuden ruudusta, tallensitpa sitten 1080p-näyttöä tai 6K-näyttöä. Ja jos tallensit alueen koko näytön sijaan, peittokuva ankkuroituu kyseisen alueen kulmaan näytön kulman sijaan, joten se pysyy kuvan sisällä.

Voit kutsua sitä myös suoraan komennolla `omarchy-capture-webcam-resize small` tai palata keskikokoiseen komennolla `reset`.

## Teksti, QR-koodit ja värit

`Super + Ctrl + Print Screen` valitsee alueen ja tunnistaa sen tekstin OCR:llä leikepöydälle. Se käsitellään kunnolla kohdassa [Tekstin poiminta ja sanelu](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ tekee saman tempun QR-koodeille. Valitse alue, jossa koodi on, niin purettu arvo menee leikepöydälle. Se etsii vain QR-koodeja — tiheällä ruudun sisällöllä on tapana tuottaa muuten vääriä positiivisia viivakoodeina. Hyvä tietää: purettu arvo menee leikepöydälle eikä minnekään muualle. Sitä ei tulosteta, se ei ole ilmoituksessa, ja se on merkitty arkaluontoiseksi, jotta se ei jää roikkumaan [leikepöydän historiaan](08-unified-clipboard-history.md). QR-koodit kantavat rutiininomaisesti salaisuuksia — esimerkiksi 2FA-asennuskoodin takana olevan `otpauth://`-URI:n — etkä halua sellaista lokiin. Liittäminen toimii silti aivan hyvin.

`Super + Print Screen` (tai _Trigger > Capture > Color_) muuttaa kohdistimen pipetiksi. Napsauta mitä tahansa ruudulla, niin väri päätyy leikepöydälle. Peru poimimatta painamalla pikanäppäintä uudelleen.

## Muuntaminen toiseen muotoon ennen jakamista

4K-näytön tallenne tai raaka HEIC puhelimestasi on usein liian iso vain lähetettäväksi. `Super + Ctrl + .` (tai _Trigger > Transcode_) korjaa sen. Se tarjoaa sinulle sumean tiedostovalitsimen kansioiden `~/Pictures` ja `~/Videos` yli ja kysyy sitten muotoa ja kokoa.

Kuvat menevät jpg- tai png-muotoon korkealla, keskitasoisella tai matalalla asetuksella, jotka rajoittavat leveyden 3160, 2160 ja 1080 pikseliin. Videot menevät mp4-muotoon tai animoiduksi gif-kuvaksi tarkkuudella 4k, 1080p tai 720p. Muunnettu tiedosto kirjoitetaan alkuperäisen viereen niin, että tarkkuus on nimessä — `demo-1080p.mp4` — ja polku kopioidaan leikepöydälle tiedoston URI:na, joten voit liittää sen suoraan sovellukseen, joka ottaa vastaan tiedostojen pudotuksia.

Se toimii myös päätteestä, jos tiedät jo, mitä haluat: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. On olemassa myös `omarchy transcode ascii`, joka muuttaa kuvan ASCII-taiteeksi — se on lähinnä [brändäystä](41-branding.md) varten.

## Lähettäminen jonnekin

Kun tiedosto on valmis, `Super + Ctrl + S` avaa Share-valikon ja lähettää sen verkossasi olevalle toiselle laitteelle LocalSendillä. Katso [GUIs](22-guis.md).
