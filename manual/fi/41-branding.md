# Brändäys

Omarchyssa voit asettaa yrityksesi logon tai oman kuvasi sekä näytönsäästäjään että tietoja-näyttöön.

### Näytönsäästäjä

Voit vaihtaa näytönsäästäjässä käytettävän logon kohdassa _Ulkoasu > Brändäys > Näytönsäästäjä_. Se on ASCII-logo, joten voit muokata tekstiä suoraan, mutta voit myös antaa sille png- tai svg-kuvan, ja me muunnamme sen ASCII-muotoon. Se näyttää aika hienolta.

 ![branding-screensaver](images/branding-screensaver.webp)

Valikossa on kolme kohtaa:

- **Muokkaa tekstiä** avaa tiedoston `~/.config/omarchy/branding/screensaver.txt` editorissasi. Kirjoita tai liitä mitä haluat — ASCII-taidetta, nimesi, ruma sana. Tallenna ja sulje, niin näytönsäästäjä käynnistyy heti, jotta näet sen.
- **Aseta kuvasta** avaa tiedostonvalitsimen png- tai svg-tiedostolle, muuntaa sen ASCII-muotoon ja näyttää sinulle tuloksen. Logot, joissa on selkeä siluetti, toimivat paljon paremmin kuin valokuvat.
- **Palauta oletus** palauttaa Omarchy-logon takaisin.

### Tietoja-näyttö

Samot kolme vaihtoehtoa ovat kohdassa _Ulkoasu > Brändäys > Tietoja_ sitä _Tietoja_-näyttöä varten, jonka saat Omarchy-valikosta, ja ne toimivat täsmälleen samalla tavalla — tiedosto on `~/.config/omarchy/branding/about.txt`, ja Tietoja-ikkuna ponnahtaa esiin jokaisen muutoksen jälkeen. Tietoja-taide muunnetaan pienempään kokoon kuin näytönsäästäjän taide, koska sen on mahduttava ikkunaan sen sijaan, että se täyttäisi näyttösi.

Kun ikkuna on auki, kirkkaan valkoisen valon vyö kulkee taiteen yli muutaman sekunnin välein ja jättää sen sen jälkeen taas paikalleen. Myös oma taiteesi saa sen, kunhan jokainen sen merkki on yhden sarakkeen levyinen — kaikki _Aseta kuvasta_ -toiminnon tuottama on. Emojeista tai kaksileveistä merkeistä rakennettu taide pysyy sen sijaan paikallaan, ja niin pysyy näyttökin, jos pidät omaa fastfetch-asetustasi: liikkumaton logo on näissä tapauksissa sitä, että animaatio pysyy poissa tieltä eikä epäonnistu, koska kiillon liu'uttaminen niiden yli asettaisi rivin loppuosan väärään paikkaan.

 ![branding-about](images/branding-about.webp)

### Kuvien muuntaminen itse

Molemmat _Aseta kuvasta_ -vaihtoehdot vain kutsuvat komentoa `omarchy transcode ascii`, jonka voit ajaa suoraan, jos haluat hallita muunnosta:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Se ottaa `--width`- ja `--height`-arvot päätteen sarakkeina ja riveinä, `--mode`-arvon, joka on joko `braille` (oletus ja paljon tarkempi) tai `block`, `--threshold`-prosentin, joka päättää, mitkä pikselit lasketaan osaksi logoa, ja `--invert`-valitsimen sitä varten, kun logosi on vaalea tummalla taustalla. Jos muunnoksesta tulee möykky, kynnysarvo on yleensä se säädin, jota kannattaa kääntää.

### Sanoja logon sijaan

`omarchy ascii` piirtää tekstiä Delta Corps Priest 1 -fontilla, sillä FIGlet-fontilla, jolla itse Omarchy-sanamerkki on piirretty, joten näytönsäästäjä voi sanoa jotain sen sijaan, että se näyttäisi kuvan:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Se ottaa tekstin argumentteina tai lukee sen putkesta, kun argumentteja ei anneta. Fontissa on vain kirjaimia ja välilyöntejä — se piirrettiin ilman numeroita tai välimerkkejä — joten kaikki muu pudotetaan pois ja nimetään stderrissä sen sijaan, että se nieltäisiin hiljaa.
