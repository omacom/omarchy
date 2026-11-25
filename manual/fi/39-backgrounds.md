# Taustakuvat

Jokaisen teeman mukana tulee oma taustakuvavalikoimansa, ja voit lisätä omiasi kansioon `~/.config/omarchy/backgrounds/[theme]`. Jos haluat lisätä ylimääräisen taustakuvan vaikkapa nord-teemaan, laitat tiedoston vain kansioon `~/.config/omarchy/backgrounds/nord`.

Helpoiten teet tämän menemällä Omarchy Menu -valikossa kohtaan _Install > Style > Background_. Se avaa kansion, jossa kyseisen teeman taustakuvat säilytetään. Paina `Super + Shift + F` avataksesi toisen tiedostonhallinnan, etsi taustakuvasi ja kopioi se sinne. Nyt se on mukana taustakuvissa, joiden välillä voit valita näppäimillä `Super + Ctrl + W`.

Taustakuvat voivat olla still-kuvien lisäksi myös videoita. Pudota `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- tai `avi`-tiedosto samaan kansioon, niin se ilmestyy kuvien rinnalle. Videot toistaa OWE-taustakuvamoottori. Se purkaa videon kerran kaikille näytöille ja toistaa sen äänen oletusäänilähdön kautta, ja se pysäyttää toiston aina, kun mikään ei voi nähdä sitä. Videotaustakuva kuluttaa silti paljon enemmän virtaa kuin still-taustakuva.

Teemoissa voi olla lyhyt intro still-taustakuvalle. Tiedostolle `backgrounds/road.webp` vastaava video sijaitsee polussa `backgrounds/intros/road.mp4`. Se toistuu automaattisesti käynnistyksen yhteydessä, vaihdettaessa teemaan, jossa kyseinen taustakuva on valittuna, ja valittaessa kyseinen taustakuva, ja palaa sitten still-kuvaan. Introvideot pysyvät poissa taustakuvan valitsimesta eivätkä koskaan toistu silmukassa.

Valinta _Appearance > Animations Off_ poistaa käytöstä myös taustakuvien introt. Omarchy tekee tämän oletuksena virtuaalikoneessa. Komento `omarchy theme bg intro toggle` voi vaihtaa introt erikseen päälle tai pois. Teeman päivittäminen ei toista introa.

Still-kuvalla voi olla myös silmukka, hiljainen versio samasta kuvasta, joka liikkuu jatkuvasti, polussa `backgrounds/loops/road.mp4`. Se toistuu still-kuvan paikalla, sen intron jälkeen, jos sillä on sellainen, ja pysähtyy, kun animaatiot poistetaan käytöstä. Akkuvirralla näytetään sen sijaan still-kuva, ja silmukka palaa, kun kytket laitteen verkkovirtaan. Silmukat pysyvät poissa taustakuvan valitsimesta.

Löydät valtavan kokoelman hienoja kuratoituja taustakuvia repositoriosta [dharmx/walls](https://github.com/dharmx/walls).

Lukitusnäyttö näyttää videotaustakuvasta still-kuvan samalla tavalla kuin se näyttää animoidusta GIF-tiedostosta still-kuvan.
