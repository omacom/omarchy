# Taustakuvat

Jokaisen teeman mukana tulee oma joukkonsa taustakuvia, ja voit lisätä omiasi hakemistoon `~/.config/omarchy/backgrounds/[theme]`. Jos haluat lisätä ylimääräisen taustakuvan esimerkiksi nord-teemaan, laitat tiedoston vain hakemistoon `~/.config/omarchy/backgrounds/nord`.

Helpoiten teet tämän valitsemalla Omarchy-valikosta _Asenna > Tyyli > Taustakuva_. Se avaa kansion, jossa kyseisen teeman taustakuvat säilytetään. Käynnistä toinen tiedostonhallinta painamalla `Super + Shift + F`, etsi taustakuvasi ja kopioi se sinne. Nyt se on mukana taustakuvissa, joiden välillä voit valita näppäimillä `Super + Ctrl + W`.

Teema, jolla ei ole omia taustakuvia, saa yhden, joka piirretään sen väreistä: Omarchy-logo teeman korostusvärillä sen taustavärin päällä. Lisää omasi korvataksesi sen.

Taustakuvat voivat olla myös videoita, eivät vain still-kuvia. Pudota `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- tai `avi`-tiedosto samaan kansioon, niin se ilmestyy kuvien rinnalle. Videot toistaa OWE-taustakuvamoottori. Se purkaa videon kerran kaikille näytöille, toistaa sen äänen oletusäänilähdön kautta ja pysäyttää toiston aina, kun mikään ei voi nähdä sitä. Videotaustakuva kuluttaa silti paljon enemmän virtaa kuin still-taustakuva.

Teemoihin voi sisältyä lyhyt intro still-taustakuvalle. Tiedoston `backgrounds/road.webp` tapauksessa vastaava video sijaitsee polussa `backgrounds/intros/road.mp4`. Se toistuu automaattisesti käynnistyksen yhteydessä, vaihdettaessa teemaan, jossa kyseinen taustakuva on valittuna, ja valittaessa kyseinen taustakuva, ja palaa sitten still-kuvaan. Introvideot eivät näy taustakuvan valitsimessa eivätkä koskaan toistu silmukassa.

Valinta _Ulkoasu > Animaatiot pois_ poistaa käytöstä myös taustakuvien introt. Omarchy tekee näin oletuksena virtuaalikoneessa. Komennolla `omarchy theme bg intro toggle` voit kytkeä introt erikseen. Teeman päivittäminen ei toista introa.

Still-kuvalla voi olla myös silmukka, rauhallinen versio samasta kuvasta, joka liikkuu jatkuvasti, polussa `backgrounds/loops/road.mp4`. Se toistuu still-kuvan tilalla, sen intron jälkeen, jos sillä sellainen on, ja pysähtyy, kun animaatiot poistetaan käytöstä. Akkuvirralla näytetään sen sijaan still-kuva, ja silmukka palaa, kun kytket laitteen takaisin verkkovirtaan. Silmukat eivät näy taustakuvan valitsimessa.

Löydät valtavan kokoelman hienoja, kuratoituja taustakuvia kokoelmasta [dharmx/walls](https://github.com/dharmx/walls).

Lukitusnäyttö näyttää videotaustakuvasta still-kehyksen samalla tavalla kuin se näyttää animoidusta GIF-kuvasta still-kehyksen.
