# Brändäys

Omarchy antaa sinun asettaa yrityksesi logon tai henkilökohtaisen kuvan sekä käynnistyksen lukituksen avaukseen, näytönsäästäjään että Tietoja-näyttöön.

### Käynnistyksen lukituksen avaus

Voit käyttää komentoa `omarchy plymouth preview` nähdäksesi, miltä mukautettu logosi ja värisi näyttäisivät. Se ottaa taustavärin, tekstivärin, logo-png:n ja polun esikatselukuvalle:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Ota sitten kokoonpano käyttöön komennolla `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, joka antaa myös SDDM-kirjautumisnäytölle samat värit ja logon. Jos haluat perua muutoksen, voit käyttää komentoa `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Näytönsäästäjä

Voit vaihtaa näytönsäästäjässä käytettävän logon kohdassa _Ulkoasu > Brändäys > Näytönsäästäjä_. Se on ASCII-logo, joten voit muokata tekstiä suoraan, mutta voit myös antaa sille png- tai svg-kuvan, ja me muutamme sen ASCII-muotoon. Se näyttää aika siistiltä.

 ![branding-screensaver](images/branding-screensaver.webp)

Valikossa on kolme kohtaa:

- **Muokkaa tekstiä** avaa tiedoston `~/.config/omarchy/branding/screensaver.txt` editorissasi. Kirjoita tai liitä mitä haluat — ASCII-taidetta, nimesi, ruma sana. Tallenna ja lopeta, ja näytönsäästäjä käynnistyy heti, jotta näet sen.
- **Aseta kuvasta** avaa tiedostonvalitsimen png- tai svg-kuvalle, muuttaa sen ASCII-muotoon ja näyttää tuloksen. Logot, joissa on selkeä siluetti, toimivat paljon paremmin kuin valokuvat.
- **Palauta oletus** palauttaa Omarchy-logon takaisin.

### Tietoja-näyttö

Samat kolme vaihtoehtoa ovat kohdassa _Ulkoasu > Brändäys > Tietoja_ Omarchy-valikosta avautuvalle _Tietoja_-näytölle, ja ne toimivat täsmälleen samalla tavalla — tiedosto on `~/.config/omarchy/branding/about.txt`, ja Tietoja-ikkuna ponnahtaa esiin jokaisen muutoksen jälkeen. Tietoja-taide muutetaan pienempään kokoon kuin näytönsäästäjän taide, koska sen on mahduttava ikkunaan sen sijaan, että se täyttäisi näyttösi.

Kun ikkuna on auki, vihreä välähdys nojaa taiteen yli muutaman sekunnin välein ja jättää sen sitten taas paikalleen. Myös oma taiteesi saa sen, kunhan jokainen sen merkki on yhden sarakkeen levyinen — kaikki _Aseta kuvasta_ -toiminnon tuottama on. Emojeista tai kaksinkertaisen levyisistä merkeistä tehty taide pysyy sen sijaan paikallaan, ja niin pysyy näyttökin, jos sinulla on oma fastfetch-asetuksesi: liikkumaton logo on näissä tapauksissa animaatio, joka pysyy poissa tieltä, eikä merkki epäonnistumisesta, koska välähdyksen liu'uttaminen niiden yli saisi rivin loppuosan väärään paikkaan.

 ![branding-about](images/branding-about.webp)

### Kuvien muuntaminen itse

Molemmat _Aseta kuvasta_ -vaihtoehdot vain kutsuvat komentoa `omarchy transcode ascii`, jonka voit ajaa suoraan, jos haluat hallita muunnosta:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Se ottaa valitsimet `--width` ja `--height` päätteen sarakkeina ja riveinä, valitsimen `--mode` arvolla joko `braille` (oletus ja paljon hienojakoisempi) tai `block`, prosenttiarvon valitsimelle `--threshold` päättämään, mitkä pikselit lasketaan osaksi logoa, ja valitsimen `--invert` tilanteisiin, joissa logosi on vaalea tummalla taustalla. Jos muunnoksesta tulee möykky, kynnysarvo on yleensä se säädin, jota kannattaa kääntää.

### Sanoja logon sijaan

`omarchy ascii` piirtää tekstiä Delta Corps Priest 1 -fontilla, FIGlet-fontilla, jolla Omarchy-sanamerkki itse on piirretty, joten näytönsäästäjä voi sanoa jotain kuvan näyttämisen sijaan:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Se ottaa tekstin argumentteina tai lukee sen putkesta, kun argumentteja ei anneta. Fontti sisältää vain kirjaimia ja välilyöntejä — se piirrettiin ilman numeroita tai välimerkkejä — joten kaikki muu pudotetaan pois ja nimetään stderrissä sen sijaan, että se nieltäisiin hiljaa.
