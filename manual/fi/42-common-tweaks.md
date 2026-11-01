# Yleisiä viilauksia

Tämä on kokoelma yleisiä Omarchy-asetuksen räätälöintejä. Tiedä, että järjestelmäpäivitysten saattaa toisinaan olla välttämätöntä palauttaa tietyt määritykset alkuperäiseen tilaansa. Jos näin tapahtuu, muutoksesi eivät katoa, vaan ne siirretään samassa hakemistossa olevaan `.bak`-tiedostoon.

Jos sotket jotain, voit palauttaa yksittäiset määritykset alkuperäisiin asetuksiinsa Omarchy-valikosta kohdasta _Päivitä > Määritykset_. Jos _todella_ sotket kaiken, voit nollata kaikki määritykset komennolla `omarchy-reinstall`.

### Näytä kaikki ilmaisinalueen kuvakkeet koko ajan

Oletuksena ilmaisinalueen kuvakkeet, kuten Dropbox, 1password tai Steam, ovat piilossa ilmaisinalueen laajennusnuolen takana, joka paljastaa ne, kun viet osoittimen sen päälle. Jos haluat niiden olevan esillä koko ajan, napsauta laajennusnuolta hiiren kakkospainikkeella avataksesi ilmaisinalueen kuvakkeiden hallinnan ja kiinnitä sitten kuvakkeet, jotka haluat pitää näkyvissä (voit myös piilottaa ne, joita et koskaan halua nähdä).

### Pyöristetyt ikkunankulmat

Omarchyn oletusmuotoilu on kulmikas, mutta jos haluat pehmentää sitä hieman, voit muuttaa tiedostoa `~/.config/hypr/looknfeel.lua` niin, että rounding ei enää ole kommentoitu pois:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Ikkunavälien poistaminen

Kannettavan näytöillä jotkut eivät halua tuhlata yhtään pikseliä ikkunaväleihin (tai edes yläpalkkiin, jonka voit kytkeä pois näppäimillä `Super + Shift + Space`). Voit kytkeä kaikki välit ja reunukset pois näppäimillä `Super + Shift + Backspace` tai poistaa ne pysyvästi poistamalla kommentit tästä tiedoston `~/.config/hypr/looknfeel.lua` kohdasta:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
