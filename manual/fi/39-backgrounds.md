# Taustakuvat

Jokaisen teeman mukana tulee oma taustakuvasarjansa, ja voit lisätä omia lisukkeita kansioon `~/.config/omarchy/backgrounds/[theme]`. Jos haluat lisätä ylimääräisen taustakuvan vaikkapa nord-teemaan, laitat tiedoston vain kansioon `~/.config/omarchy/backgrounds/nord`.

Helpoiten teet tämän siirtymällä Omarchy Menu -valikossa kohtaan _Install > Style > Background_. Se avaa kansion, johon kyseisen teeman taustakuvat on tallennettu. Paina `Super + Shift + F` käynnistääksesi toisen tiedostonhallinnan, etsi taustakuvasi ja kopioi se sinne. Nyt se on mukana taustakuvissa, joiden välillä voit valita näppäinyhdistelmällä `Super + Ctrl + W`.

Taustakuvat voivat olla videoita yhtä hyvin kuin pysäytyskuviakin. Pudota `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- tai `avi`-tiedosto samaan kansioon, niin se ilmestyy kuvien rinnalle. Videot toistaa OWE-taustakuvamoottori. Se purkaa videon kerran kaikkia näyttöjä varten ja toistaa sen äänen oletusäänilähdön kautta, ja se pysäyttää toiston aina, kun mikään ei voi nähdä sitä. Videotaustakuva kuluttaa silti paljon enemmän virtaa kuin pysäytyskuva.

Teemoissa voi olla lyhyt intro pysäytyskuvataustaa varten. Tiedostoa `backgrounds/road.webp` vastaava video sijaitsee polussa `backgrounds/intros/road.mp4`. Se toistuu automaattisesti käynnistettäessä, vaihdettaessa teemaan, jossa kyseinen taustakuva on valittuna, ja kyseistä taustakuvaa valittaessa, ja palaa sitten pysäytyskuvaan. Intro-videot pysyvät poissa taustakuvan valitsimesta eivätkä koskaan toistu silmukassa.

Kohdan _Appearance > Animations_ poistaminen käytöstä poistaa käytöstä myös taustakuvien introt. Omarchy tekee tämän oletuksena virtuaalikoneessa. Komento `omarchy theme bg intro toggle` voi kytkeä introt erikseen päälle tai pois. Teeman päivittäminen ei toista introa.

Valtavan kokoelman hienoja, huolella valittuja taustakuvia löydät kokoelmasta [dharmx/walls](https://github.com/dharmx/walls).

Lukitusnäyttö näyttää videotaustakuvasta pysäytyskuvan samalla tavalla kuin se näyttää pysäytyskuvan animoidusta GIF-tiedostosta.
