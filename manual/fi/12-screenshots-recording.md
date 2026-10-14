# Kuvakaappaukset ja tallennus

Kaikki, mitä voit kaapata ruudulta, roikkuu Print Screen -näppäimestä. Yksi näppäin yksinään ottaa kuvan, ja muokkaimet ottavat tallenteen, värin tai tekstin alueen sisältä. Jos näppäimistössäsi ei ole lainkaan Print Screen -näppäintä, `Super + Ctrl + C` avaa saman valikoiman valikkona.

| Pikanäppäin | Toiminto |
| ------ | -------- |
| `Print Screen` | Kuvakaappaus |
| `Alt + Print Screen` | Ruuduntallennus (tai pysäytä käynnissä oleva) |
| `Super + Print Screen` | Värinvalitsin |
| `Super + Ctrl + Print Screen` | Poimi teksti alueelta |
| `Super + Ctrl + C` | Kaappausvalikko |
| `Super + Ctrl + .` | Muunna kuva tai video |

## Kuvakaappaukset

Paina `Print Screen`, ja Omasnap kaappaa kohdistetun näytön ennen peiton ilmestymistä, joten mikään ei siirry allasi tähtäillessäsi. Vedä vapaamuotoinen alue, napsauta ikkunaa kaapataksesi sen tai napsauta avointa tilaa kaapataksesi koko näytön. Paina `S` ennen piirtämistä kaapataksesi vierivän alueen. Muutitko mielesi? Paina uudelleen `Print Screen` sulkeaksesi Omasnapin.

Kun olet valinnut alueen, Omasnap tallentaa kaappauksen, kopioi sen leikepöydälle ja näyttää esikatselun 10 sekunnin ajan. Käytä esikatselun kiinnityspainiketta tai yhdistelmää `Ctrl + P` pitääksesi sen ruudulla, tai valitse Muokkaa kommentoidaksesi sitä.

Kommenttieditori voi piirtää nuolia, viivoja, muotoja, korostuksia, numeroituja merkkejä, tekstiä ja turvallisia sensurointeja; rajata tai leikata pois osan kuvasta; tunnistaa sen tekstin tekstintunnistuksella; ja lisätä taustan. Editorissa paina `Enter` kopioidaksesi ja tallentaaksesi valmiin PNG:n, `Ctrl + C` kopioidaksesi sen tallentamatta tai `Ctrl + S` tallentaaksesi sen kopioimatta.

Tallennetut kuvakaappaukset päätyvät oletuksena hakemistoon `~/Pictures/Screenshots`, nimellä kuten `screenshot-2026-08-13_14-22-05-firefox.png`. Aseta `OMASNAP_SCREENSHOT_DIR` käyttääksesi toista hakemistoa — katso [usein kysytyt kysymykset](46-faq.md), minne istunnon ympäristömuuttujat laitetaan. Omasnap luo hakemiston, kun se tallentaa ensimmäisen kuvan. Aseta tiedostossa `~/.config/omasnap/omasnap.conf` asetus `[output] autosave = false` poistaaksesi automaattisen tallennuksen käytöstä.

Pääätteestä `omarchy screenshot` avaa saman peiton, ja voit valita sen aloitustilan: `omarchy capture screenshot region`, `windows`, `fullscreen` tai `scroll`. Toinen argumentti `copy` tai `save` ohittaa esikatselun ja lähettää kuvan suoraan kyseiseen kohteeseen. Muokataksesi ennen tulostusta käytä komentoa `omarchy screenshot --editor=overlay` koko ruudun editorille tai `omarchy screenshot --editor=window` erilliselle ikkunalle.

### Valitsimen ajaminen näppäimistöstä

Kun valinta on näkyvissä, sinun ei tarvitse käyttää hiirtä lainkaan:

| Näppäin | Toiminto |
| --- | -------- |
| `S` | Vaihda vierisalue-tila |
| `Super + Arrow keys` | Liiku ikkunoiden välillä Ikkuna-tilassa |
| `Return` | Kaappaa korostettu ikkuna |
| `Ctrl + A` | Kaappaa koko kohdistettu näyttö |
| `R` | Palauta viimeksi tässä istunnossa piirretty alue |
| `Esc` | Sulje Omasnap |

Nämä sidokset ovat olemassa vain Omasnapin ollessa avoinna, joten ne eivät voi törmätä mihinkään omassa määrityksessäsi.

## Ruuduntallennus

`Alt + Print Screen` avaa kohdan _Käynnistä > Kaappaus > Ruuduntallennus_, joka kysyy, mitä haluat ääniraidalle: ei ääntä, työpöydän äänen, työpöydän plus mikrofonin tai työpöydän plus mikrofonin plus verkkokameran. Viimeinen näistä näkyy vain, jos sinulla todella on kamera kytkettynä. Valitse yksi, ja Omarchyn tallennusvalitsin antaa sinun vetää alueen tai napsauttaa ikkunaa tai näyttöä.

Tallennus pyörii gpu-screen-recorderilla, joka koodaa GPU:lla 60 fps nopeudella ja turvautuu CPU:hun, jos sen on pakko. Tulos on MP4 hakemistossa `~/Videos`, nimeltään `screenrecording-2026-08-13_14-22-05.mp4`. Aseta `OMARCHY_SCREENRECORD_DIR` muuttaaksesi sitä — mutta huomaa, että toisin kuin kuvakaappaushakemiston, tämän on oltava jo olemassa, tai tallennus kieltäytyy alkamasta.

Tallentaessasi palkkiin ilmestyy pieni ilmaisin. Napsauta sitä pysäyttääksesi. Voit myös pysäyttää painamalla uudelleen `Alt + Print Screen` tai kohdan _Pysäytä ruuduntallennus_ avulla kohdassa _Käynnistä > Kaappaus > Ruuduntallennus_, mikä näkyy vain, kun jokin todella tallentaa.

Pysäyttäminen siivoaa hieman ennen kuin se luovuttaa tiedoston sinulle: ensimmäinen ruutu leikataan, ja jos ääntä on, se normalisoidaan -14 LUFS:iin PipeWire-kaappauksen aivan alussa olevan poksahduksen mykistyttyä. Sitten ilmoitus ilmestyy tallenteen pienoiskuvalla. Napsauta sitä toistaaksesi tiedoston mpv:ssä.

### Verkkokameran peitto

Kun tallennat verkkokameralla, kamera ilmestyy kiinnitettynä, rajattuna muotokuvaikkunana tallentamasi asian oikeassa alakulmassa. Jos se on jonkin tarvitsemasi päällä, muuta sen kokoa lennossa:

| Pikanäppäin | Toiminto |
| ------ | -------- |
| `Super + Alt + [` | Tee verkkokameran peitosta pienempi |
| `Super + Alt + ]` | Tee verkkokameran peitosta suurempi |

Kokoja on kolme — pieni, keskikokoinen ja suuri — ja pikanäppäimet liikkuvat niiden välillä. Keskikokoinen on oletus. Ne ovat suhteessa tallenteeseen, joten kamera vie saman osuuden ruudusta, tallensitpa 1080p-näyttöä tai 6K-näyttöä. Ja jos tallensit alueen koko näytön sijaan, peitto ankkuroituu kyseisen alueen kulmaan näytön kulman sijaan, joten se pysyy kuvan sisällä.

Voit myös kutsua sitä suoraan komennolla `omarchy-capture-webcam-resize small` tai `reset` palataksesi keskikokoiseen.

## Teksti, QR-koodit ja värit

`Super + Ctrl + Print Screen` valitsee alueen ja tunnistaa sen tekstin leikepöydälle. Se käsitellään kunnolla kohdassa [Tekstin poiminta ja sanelu](11-text-extraction-dictation.md).

_Käynnistä > Kaappaus > QR-koodi_ tekee saman tempun QR-koodeille. Valitse alue, jossa koodi on, ja purettu arvo menee leikepöydälle. Se etsii vain QR-koodeja — tiheällä ruudun sisällöllä on muuten tapana antaa vääriä positiivisia viivakoodeina. Hyvä tietää: purettu arvo menee leikepöydälle eikä minnekään muualle. Sitä ei tulosteta, se ei ole ilmoituksessa, ja se on merkitty arkaluonteiseksi, joten se ei jää roikkumaan [leikepöydän historiaan](08-unified-clipboard-history.md). QR-koodit kuljettavat rutiininomaisesti salaisuuksia — esimerkiksi `otpauth://`-URI 2FA-määrityskoodin takana — etkä halua sitä lokiin. Liittäminen toimii silti hyvin.

`Super + Print Screen` (tai _Käynnistä > Kaappaus > Väri_) muuttaa kohdistimen pipetiksi. Napsauta mitä tahansa ruudulla, ja väri päätyy leikepöydälle. Paina pikanäppäintä uudelleen perääntyäksesi valitsematta.

## Muuntaminen ennen jakamista

4K-ruuduntallenne tai raaka HEIC puhelimestasi on usein liian suuri vain lähetettäväksi. `Super + Ctrl + .` (tai _Käynnistä > Muunna_) korjaa sen. Se tarjoaa sinulle sumean tiedostonvalitsimen hakemistojen `~/Pictures` ja `~/Videos` yli ja kysyy sitten muotoa ja kokoa.

Kuvat menevät jpg- tai png-muotoon korkeana, keskikokoisena tai matalana, mikä rajaa leveyden 3160, 2160 ja 1080 pikseliin. Videot menevät mp4-muotoon tai animoituun gif-tiedostoon 4k-, 1080p- tai 720p-muodossa. Muunnettu tiedosto kirjoitetaan alkuperäisen viereen resoluutio nimessään — `demo-1080p.mp4` — ja polku kopioidaan leikepöydälle tiedosto-URI:na, joten voit liittää sen suoraan sovellukseen, joka hyväksyy tiedostojen pudotuksen.

Se toimii myös pääätteestä, jos tiedät jo, mitä haluat: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. On myös `omarchy transcode ascii`, joka muuttaa kuvan ASCII-taiteeksi — se on enimmäkseen [brändäystä](41-branding.md) varten.

## Sen lähettäminen jonnekin

Kun olet saanut tiedoston, `Super + Ctrl + S` avaa Jaa-valikon ja lähettää sen toiselle laitteellesi verkossa LocalSendin kautta. Katso [GUI:t](22-guis.md) sitä varten.
