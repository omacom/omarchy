# Taustakuvat

Jokaisen teeman mukana tulee sen oma taustakuvasarja, ja voit lisätä omia lisäkuvia hakemistoon `~/.config/omarchy/backgrounds/[theme]`. Jos haluat lisätä ylimääräisen taustakuvan esimerkiksi nord-teemaan, laitat tiedoston vain hakemistoon `~/.config/omarchy/backgrounds/nord`.

Helpoiten teet tämän valitsemalla Omarchy Menu -valikossa _Install > Style > Background_. Silloin avautuu kansio, jossa kyseisen teeman taustakuvat säilytetään. Käynnistä toinen tiedostoselain painamalla `Super + Shift + F`, etsi taustakuvasi ja kopioi se sinne. Nyt se on mukana taustakuvissa, joiden välillä voit valita näppäimillä `Super + Ctrl + W`.

Taustakuvat voivat olla videoita yhtä hyvin kuin still-kuvia. Pudota `mp4`, `m4v`, `mov`, `webm`, `mkv` tai `avi`-tiedosto samaan kansioon, niin se ilmestyy kuvien rinnalle. Videot toistaa OWE wallpaper engine. Se purkaa videon kerran kaikkia näyttöjä varten, toistaa sen äänen oletusääniulostulon kautta ja pysäyttää toiston aina, kun mikään ei voi nähdä sitä. Videotaustakuva kuluttaa silti paljon enemmän virtaa kuin still-kuva.

Teemat voivat sisältää lyhyen intron still-taustakuvalle. Tiedostolle `backgrounds/road.webp` vastaava video sijaitsee paikassa `backgrounds/intros/road.mp4`. Se toistuu automaattisesti käynnistyksessä, kun vaihdat teemaan, jossa kyseinen taustakuva on valittuna, ja kun valitset kyseisen taustakuvan, ja palaa sitten still-kuvaan. Introvideot pysyvät poissa taustakuvien valitsimesta eivätkä koskaan pyöri silmukassa.

_Appearance > Animations_ -asetuksen kytkeminen pois päältä kytkee pois päältä myös taustakuvien introt. Omarchy tekee tämän oletuksena virtuaalikoneessa. Komennolla `omarchy theme bg intro toggle` introt voi kytkeä erikseen. Teeman virkistäminen ei toista introa.

Still-kuvalla voi olla myös loop, saman kuvan hiljainen versio, joka liikkuu jatkuvasti, paikassa `backgrounds/loops/road.mp4`. Se toistuu still-kuvan tilalla, sen intron jälkeen, jos sillä sellainen on, ja pysähtyy, kun animaatiot kytketään pois päältä. Loopit pysyvät poissa taustakuvien valitsimesta ja kuluttavat, kuten mikä tahansa videotaustakuva, enemmän virtaa kuin still-kuva.

Valtavan kokoelman hienoja kuratoituja taustakuvia löydät kokoelmasta [dharmx/walls](https://github.com/dharmx/walls).

Lukitusnäyttö näyttää videotaustakuvasta pysäytysruudun samalla tavalla kuin se näyttää animoidusta GIF-kuvasta pysäytysruudun.
