# Brändäys

Omarchy antaa sinun asettaa yrityksesi logon tai henkilökohtaisen kuvasi sekä käynnistyksen lukituksen avaukseen, näytönsäästäjään että Tietoja-näyttöön.

### Käynnistyksen lukituksen avaus

Voit käyttää komentoa `omarchy plymouth preview` nähdäksesi, miltä mukautettu logosi ja värisi näyttäisivät. Se ottaa taustavärin, tekstivärin, logo-png:n ja esikatselukuvan polun:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Ota sitten kokoonpano käyttöön komennolla `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, mikä antaa myös SDDM-kirjautumisnäytölle samat värit ja logon. Jos haluat palauttaa aiemman, voit käyttää komentoa `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Näytönsäästäjä

Voit vaihtaa näytönsäästäjälle käytettävän logon kohdassa _Ulkoasu > Brändäys > Näytönsäästäjä_. Se on ASCII-logo, joten voit muokata tekstiä suoraan, mutta voit myös antaa sille png- tai svg-kuvan, ja me muunnamme sen ASCII:ksi. Se näyttää melko hienolta.

 ![branding-screensaver](images/branding-screensaver.webp)

Siinä valikossa on kolme kohtaa:

- **Muokkaa tekstiä** avaa tiedoston `~/.config/omarchy/branding/screensaver.txt` editorissasi. Kirjoita tai liitä mitä haluat — ASCII-taidetta, nimesi, ruma sana. Tallenna ja lopeta, ja näytönsäästäjä käynnistyy heti, niin näet sen.
- **Aseta kuvasta** avaa tiedostovalitsimen png- tai svg-tiedostolle, muuntaa sen ASCII:ksi ja näyttää sinulle tuloksen. Logot, joissa on selkeä siluetti, toimivat huomattavasti paremmin kuin valokuvat.
- **Palauta oletus** palauttaa Omarchy-logon takaisin.

### Tietoja-näyttö

Samot kolme vaihtoehtoa ovat kohdassa _Ulkoasu > Brändäys > Tietoja_ Omarchy-valikosta saatavalle _Tietoja_-näytölle, ja ne toimivat identtisesti — tiedosto on `~/.config/omarchy/branding/about.txt`, ja Tietoja-ikkuna ponnahtaa esiin jokaisen muutoksen jälkeen. Tietoja-taide muunnetaan pienempään kokoon kuin näytönsäästäjän taide, koska sen on mahduttava ikkunaan sen sijaan, että se täyttäisi näyttösi.

Kun ikkuna on auki, kirkkaan valkoisen valon kaistale nojaa taiteen yli muutaman sekunnin välein ja jättää sen sitten taas paikalleen. Myös oma taiteesi saa sen, kunhan jokainen merkki siinä on yhden sarakkeen levyinen — kaikki, mitä _Aseta kuvasta_ tuottaa, on. Emojeista tai kaksinkertaisen levyisistä merkeistä rakennettu taide pysyy sen sijaan paikallaan, ja niin pysyy myös näyttö, jos pidät omaa fastfetch-konfiguraatiotasi: liikkumaton logo on niissä tapauksissa animaatio, joka pysyy poissa tieltä, eikä epäonnistuminen, sillä häikäisyn liu'uttaminen niiden yli asettaisi rivin loppuosan väärään paikkaan.

 ![branding-about](images/branding-about.webp)

### Kuvien muuntaminen itse

Molemmat _Aseta kuvasta_ -vaihtoehdot vain kutsuvat komentoa `omarchy transcode ascii`, jota voit ajaa suoraan, jos haluat hallita muunnosta:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Se ottaa valitsimet `--width` ja `--height` päätteen sarakkeina ja riveinä, valitsimen `--mode` arvolla joko `braille` (oletus ja paljon hienojakoisempi) tai `block`, prosenttiarvon valitsimelle `--threshold` päättämään, mitkä pikselit lasketaan osaksi logoa, ja valitsimen `--invert`, kun logosi on vaalea tummalla taustalla. Jos muunnoksesta tulee möykky, kynnysarvo on yleensä se nuppi, jota kannattaa kääntää.

### Sanoja logon sijaan

`omarchy ascii` piirtää tekstiä fontilla Delta Corps Priest 1, FIGlet-fontilla, jolla Omarchy-sanamerkki itse on piirretty, joten näytönsäästäjä voi sanoa jotain sen sijaan, että se näyttäisi kuvan:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Se ottaa tekstin argumentteina tai lukee sen putkesta, kun argumentteja ei anneta. Fontti sisältää vain kirjaimia ja välilyöntejä — se piirrettiin ilman numeroita tai välimerkkejä — joten kaikki muu pudotetaan pois ja nimetään stderr:ssä sen sijaan, että se nieltäisiin hiljaa.
