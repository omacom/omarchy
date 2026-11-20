# Taustakuvat

Jokaisen teeman mukana tulee oma joukkonsa taustakuvia, ja voit lisätä omia lisukkeita kansioon `~/.config/omarchy/backgrounds/[theme]`. Jos haluat lisätä ylimääräisen taustakuvan vaikka nord-teemaan, laita tiedosto vain kansioon `~/.config/omarchy/backgrounds/nord`.

Helpoiten teet tämän siirtymällä Omarchy Menu -valikossa kohtaan _Install > Style > Background_. Se avaa kansion, johon kyseisen teeman taustakuvat on tallennettu. Käynnistä toinen tiedostoselain painamalla `Super + Shift + F`, etsi taustakuvasi ja kopioi se sinne. Nyt se on mukana taustakuvissa, joiden välillä voit valita näppäinyhdistelmällä `Super + Ctrl + W`.

Taustakuvat voivat olla myös videoita, eivät vain liikkumattomia kuvia. Pudota `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- tai `avi`-tiedosto samaan kansioon, niin se ilmestyy kuvien rinnalle. Videoita toistaa OWE-taustakuvamoottori. Se purkaa videon kerran kaikkia näyttöjä varten, toistaa sen äänen oletusäänilähdön kautta ja pysäyttää toiston aina, kun mikään ei voi nähdä sitä. Videotaustakuva kuluttaa silti paljon enemmän virtaa kuin liikkumaton.

Teemat voivat sisältää lyhyen intron liikkumatonta taustakuvaa varten. Tiedostolle `backgrounds/road.webp` sopiva video on polussa `backgrounds/intros/road.mp4`. Se toistuu automaattisesti käynnistyksen yhteydessä, kun vaihdat teemaan, jossa kyseinen taustakuva on valittuna, ja kun valitset kyseisen taustakuvan, ja palaa sen jälkeen liikkumattomaan kuvaan. Introvideot eivät näy taustakuvan valitsimessa eivätkä koskaan toistu silmukassa.

Kohdan _Appearance > Animations_ poistaminen käytöstä poistaa käytöstä myös taustakuvien introt. Omarchy tekee tämän oletuksena virtuaalikoneessa. Komennolla `omarchy theme bg intro toggle` voit kytkeä introt erikseen. Teeman päivittäminen ei toista introa.

Liikkumattomalla kuvalla voi olla myös silmukka, saman kuvan hiljainen versio, joka liikkuu jatkuvasti, polussa `backgrounds/loops/road.mp4`. Se toistuu liikkumattoman kuvan tilalla, sen intron jälkeen, jos sillä on sellainen, ja pysähtyy, kun animaatiot poistetaan käytöstä. Akkuvirralla sen sijaan näkyy liikkumaton kuva, ja silmukka palaa, kun kytket virran takaisin. Silmukat eivät näy taustakuvan valitsimessa.

Löydät valtavan kokoelman hienoja kuratoituja taustakuvia kokoelmasta [dharmx/walls](https://github.com/dharmx/walls).

Lukitusnäyttö näyttää videotaustakuvasta pysäytetyn ruudun samalla tavalla kuin se näyttää animoidusta GIF-tiedostosta pysäytetyn ruudun.
