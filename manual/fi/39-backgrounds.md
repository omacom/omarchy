# Taustakuvat

Jokaisen teeman mukana toimitetaan oma taustakuvajoukkonsa, ja voit lisätä omia lisätäustakuviasi hakemistoon `~/.config/omarchy/backgrounds/[theme]`. Jos haluat lisätä ylimääräisen taustakuvan vaikkapa nord-teemaan, laitat tiedoston vain hakemistoon `~/.config/omarchy/backgrounds/nord`.

Helpoiten teet tämän menemällä Omarchy Menu -valikossa kohtaan _Install > Style > Background_. Se avaa kansion, johon kyseisen teeman taustakuvat on tallennettu. Avaa toinen tiedostonhallinta painamalla `Super + Shift + F`, etsi taustakuvasi ja kopioi se sinne. Nyt se on mukana taustakuvissa, joiden välillä voit valita näppäimillä `Super + Ctrl + W`.

Taustakuvat voivat olla videotakin pelkkien still-kuvien sijaan. Pudota `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- tai `avi`-tiedosto samaan kansioon, niin se ilmestyy kuvien rinnalle. Videot toistaa OWE wallpaper engine. Se purkaa videon kerran kaikkia näyttöjä varten ja toistaa sen äänen oletusäänilähdön kautta, ja se pysäyttää toiston aina, kun mikään ei voi nähdä sitä. Videotaustakuva kuluttaa silti paljon enemmän virtaa kuin still-kuva.

Teemoissa voi olla lyhyt intro still-taustakuvalle. Taustakuvan `backgrounds/road.webp` tapauksessa vastaava video on polussa `backgrounds/intros/road.mp4`. Se toistuu automaattisesti käynnistyksen yhteydessä ja vaihdettaessa teemaan, jossa kyseinen taustakuva on valittuna, ja palaa sitten still-kuvaan. Introvideot eivät näy taustakuvavalitsimessa eivätkä koskaan toistu silmukassa.

_Appearance > Animations_ -asetuksen poistaminen käytöstä poistaa käytöstä myös taustakuvien introt. Omarchy tekee tämän oletuksena virtuaalikoneessa. Komennolla `omarchy theme bg intro toggle` voit kytkeä introt päälle tai pois erikseen. Teeman päivittäminen tai toisen taustakuvan valitseminen saman teeman sisällä ei toista introa.

Löydät valtavan kokoelman hienoja kuratoituja taustakuvia repositoriosta [dharmx/walls](https://github.com/dharmx/walls).

Lukitusnäyttö näyttää videotaustakuvasta still-kuvan samalla tavalla kuin se näyttää still-kuvan animoidusta GIF-tiedostosta.
