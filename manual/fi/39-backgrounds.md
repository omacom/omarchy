# Taustakuvat

Jokaisen teeman mukana tulee omat taustakuvansa, ja voit lisätä omia lisäkuvia kansioon `~/.config/omarchy/backgrounds/[theme]`. Jos haluat lisätä ylimääräisen taustakuvan esimerkiksi nord-teemaan, laita tiedosto vain kansioon `~/.config/omarchy/backgrounds/nord`.

Helpoiten teet tämän valitsemalla Omarchy Menu -valikossa _Install > Style > Background_. Se avaa kansion, jossa kyseisen teeman taustakuvia säilytetään. Paina `Super + Shift + F` käynnistääksesi toisen tiedostonhallinnan, etsi taustakuvasi ja kopioi se sinne. Nyt se on mukana taustakuvavaihtoehdoissa, joiden välillä voit valita näppäimillä `Super + Ctrl + W`.

Taustakuvat voivat olla myös videoita still-kuvien ohella. Pudota `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- tai `avi`-tiedosto samaan kansioon, niin se näkyy kuvien rinnalla. Videoita toistaa OWE wallpaper engine. Se purkaa videon kerran kaikkia näyttöjä varten, toistaa sen äänen oletusäänilähdön kautta ja pysäyttää toiston aina, kun mikään ei voi nähdä sitä. Videotaustakuva kuluttaa silti paljon enemmän virtaa kuin still-taustakuva.

Teemat voivat sisältää lyhyen intron still-taustakuvalle. Tiedostolle `backgrounds/road.webp` vastaava video on polussa `backgrounds/intros/road.mp4`. Se toistuu automaattisesti käynnistyksessä ja vaihdettaessa teemaan, jossa kyseinen taustakuva on valittuna, ja palaa sitten still-kuvaan. Introvideot eivät näy taustakuvavalitsimessa eivätkä koskaan toistu silmukassa.

_Appearance > Animations_ -asetuksen poistaminen käytöstä poistaa käytöstä myös taustakuvien introt. Omarchy tekee tämän oletuksena virtuaalikoneessa. `omarchy theme bg intro toggle` -komennolla voit kytkeä introt erikseen päälle tai pois. Teeman päivittäminen tai toisen taustakuvan valitseminen saman teeman sisällä ei toista introa.

Löydät valtavan kokoelman hienoja kuratoituja taustakuvia osoitteesta https://github.com/dharmx/walls.

Lukitusnäyttö näyttää videotaustakuvasta still-kehyksen, samalla tavalla kuin se näyttää animoidusta GIF-tiedostosta still-kehyksen.
