# Brändäys

Omarchy antaa asettaa yrityksesi logon tai henkilökohtaisen kuvan sekä käynnistyksen lukituksen avaamiseen, näytönsäästäjään että tietoja-ruutuun.

### Käynnistyksen lukituksen avaus

Voit käyttää komentoa `omarchy plymouth preview` nähdäksesi, miltä mukautettu logosi ja värisi näyttäisivät. Se ottaa taustavärin, tekstin värin, logo-png:n ja polun esikatselukuvalle:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Sovella sitten asetukset komennolla `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, mikä antaa myös SDDM-kirjautumisruudulle samat värit ja logon. Jos haluat palauttaa, voit käyttää komentoa `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Näytönsäästäjä

Voit vaihtaa näytönsäästäjän logon kohdassa _Tyyli > Näytönsäästäjä_. Se on ASCII-logo, joten voit muokata tekstiä suoraan, mutta voit myös antaa sille png- tai svg-kuvan, ja me muunnamme sen ASCIIksi. Se näyttää aika hienolta.

 ![branding-screensaver](images/branding-screensaver.webp)

Valikossa on kolme kohtaa:

- **Muokkaa tekstiä** avaa tiedoston `~/.config/omarchy/branding/screensaver.txt` editorissasi. Kirjoita tai liitä mitä haluat — ASCII-taidetta, nimesi, kirosana. Tallenna ja lopeta, niin näytönsäästäjä käynnistyy heti, jotta voit nähdä sen.
- **Aseta kuvasta** avaa tiedostonvalitsimen png- tai svg-tiedostolle, muuntaa sen ASCIIksi ja näyttää tuloksen. Logot, joilla on selkeä siluetti, toimivat paljon paremmin kuin valokuvat.
- **Palauta oletus** palauttaa Omarchy-logon.

### Tietoja-ruutu

Samat kolme vaihtoehtoa ovat kohdassa _Tyyli > Tietoja_ Omarchy-valikosta saatavalle _Tietoja_-ruudulle, ja ne toimivat samoin — tiedosto on `~/.config/omarchy/branding/about.txt`, ja Tietoja-ikkuna ponnahtaa esiin jokaisen muutoksen jälkeen. Tietoja-taide muunnetaan pienempään kokoon kuin näytönsäästäjän, koska sen täytyy mahtua ikkunaan sen sijaan, että täyttäisi näytön.

Kun ikkuna on auki, vihreä välähdys liukuu taiteen yli muutaman sekunnin välein ja jättää sen sitten taas paikalleen. Myös oma taiteesi saa sen, kunhan jokainen sen merkki on yhden sarakkeen leveä — kaikki _Aseta kuvasta_ -toiminnon tuottama on sellainen. Emojeista tai kaksileveistä merkeistä rakennettu taide pysyy sen sijaan paikallaan, ja niin pysyy ruutukin, jos säilytät oman fastfetch-määrityksesi: paikallaan pysyvä logo näissä tapauksissa on animaation tapa pysyä poissa tieltä eikä epäonnistua, koska välähdyksen liu'uttaminen niiden yli siirtäisi rivin loput väärään paikkaan.

 ![branding-about](images/branding-about.webp)

### Kuvien muuntaminen itse

Molemmat _Aseta kuvasta_ -vaihtoehdot vain kutsuvat komentoa `omarchy transcode ascii`, jonka voit ajaa suoraan, jos haluat hallita muunnosta:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Se ottaa valinnat `--width` ja `--height` terminaalin sarakkeina ja riveinä, valinnan `--mode` arvoina `braille` (oletus ja paljon hienovaraisempi) tai `block`, valinnan `--threshold` prosentteina päättämään, mitkä pikselit kuuluvat logoon, sekä valinnan `--invert`, kun logosi on vaalea tummalla taustalla. Jos muunnos tulee ulos möykkynä, kynnysarvo on yleensä se nuppi, jota kääntää.

### Sanoja logon sijaan

`omarchy ascii` piirtää tekstiä Delta Corps Priest 1 -fontilla, FIGlet-fontilla, jolla itse Omarchy-sanamerkki on piirretty, joten näytönsäästäjä voi sanoa jotakin sen sijaan, että näyttäisi kuvan:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Se ottaa tekstin argumentteina tai lukee sen putkesta, kun argumentteja ei anneta. Fontti sisältää vain kirjaimia ja välilyöntejä — se piirrettiin ilman numeroita tai välimerkkejä — joten kaikki muu pudotetaan ja nimetään stderr:ssä sen sijaan, että se nieltäisiin hiljaa.
