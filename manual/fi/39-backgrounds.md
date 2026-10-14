# Taustat

Jokaiseen teemaan kuuluu oma taustakokoelmansa, ja voit lisätä omia lisätiedostojasi kansioon `~/.config/omarchy/backgrounds/[theme]`. Jos haluat lisätä lisätä taustakuvan esimerkiksi nord-teemaan, laitat tiedoston vain kansioon `~/.config/omarchy/backgrounds/nord`.

Helpoiten teet sen valitsemalla Omarchy-valikosta _Asenna > Tyyli > Tausta_. Se avaa kansion, jossa kyseisen teeman taustoja säilytetään. Paina `Super + Shift + F` käynnistääksesi toisen tiedostonhallinnan, etsi taustasi ja kopioi se sinne.  Nyt se on mukana taustoissa, joista voit valita näppäimillä `Super + Ctrl + Space`.

Taustat voivat olla videoita yhtä hyvin kuin still-kuvia. Pudota `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- tai `avi`-tiedosto samaan kansioon, niin se ilmestyy kuvien rinnalle. Videoita toistaa OWE-taustakuvamoottori. Se purkaa videon kerran kaikille näytöille ja toistaa sen äänen oletusäänilähdön kautta, ja se pysäyttää toiston aina, kun mikään ei voi nähdä sitä. Lukitusruutu piirtää saman purun mykistettynä OWE:n kautta. Videotausta kuluttaa silti paljon enemmän virtaa kuin still-tausta.

Teemoihin voi sisältyä lyhyt intro still-taustalle. Tiedostolle `backgrounds/road.webp` vastaava video sijaitsee polussa `backgrounds/intros/road.mp4`. Se toistuu automaattisesti käynnistyksen yhteydessä ja vaihdettaessa teemaan, jossa kyseinen tausta on valittuna, ja palaa sitten still-kuvaan. Introvideot pysyvät poissa taustavalitsimesta eivätkä koskaan silmukoidu.

_Käynnistä > Ulkoasu > Animaatiot_ -valinnan poistaminen käytöstä poistaa käytöstä myös taustaintrot. Omarchy tekee näin oletuksena virtuaalikoneessa. Komento `omarchy theme bg intro toggle` voi kytkeä introt erikseen. Teeman päivittäminen tai toisen taustan valitseminen samassa teemassa ei toista introa.

Löydät valtavan kokoelman hienosti kuratoituja taustoja osoitteesta https://github.com/dharmx/walls.

Videotaustat säilyttävät välimuistissa olevan still-kuvan lukitusruudulla, kun toisto on keskeytetty tai ei käytettävissä. Animoidut GIFit toistuvat työpöydällä ja näyttävät still-ruudun lukitusruudulla.
