# Yleiset säädöt

Tämä on kokoelma Omarchy-kokoonpanon yleisiä räätälöintejä. Huomaa, että järjestelmäpäivitysten yhteydessä tietyt määritykset on toisinaan palautettava alkuperäiseen tilaansa. Jos näin käy, muutoksesi eivät katoa, vaan ne siirretään alkuperäisen tiedoston viereen `.bak.<timestamp>`-tiedostoon.

Jos sotket jotain, voit palauttaa yksittäiset määritykset alkuperäiseen kokoonpanoonsa Omarchy-valikon kohdasta _Update > Config_. Jos _todella_ sotket kaiken, voit nollata kaikki määritykset komennolla `omarchy reinstall configs` tai asentaa kaikki oletuspaketit ja -määritykset uudelleen komennolla `omarchy reinstall`.

### Näytä kaikki ilmaisinalueen kuvakkeet koko ajan

Oletuksena ilmaisinalueen kuvakkeet, kuten Dropbox, 1password tai Steam, on piilotettu ilmaisinalueen laajennusnuolen taakse, joka paljastaa ne, kun viet hiiren sen päälle. Jos haluat niiden olevan näkyvissä koko ajan, napsauta laajennusnuolta hiiren oikealla painikkeella avataksesi ilmaisinalueen kuvakkeiden hallinnan ja kiinnitä sitten kuvakkeet, jotka haluat pitää näkyvissä (voit myös piilottaa ne, joita et halua koskaan nähdä).

### Pyöristetyt ikkunoiden kulmat

Omarchyn oletusulkoasu käyttää teräviä kulmia, mutta jos haluat pehmentää sitä hieman, valitse Omarchy-valikosta _Appearance > Windows > Window Corners > Rounded Corners_ tai aja `omarchy hyprland corners rounded`. _Theme Corners_ palauttaa käyttöön teeman käyttämän vaihtoehdon. Jos haluat valita oman säteen, pysy vaihtoehdossa _Theme Corners_ (`omarchy hyprland corners theme`), koska Rounded ja Sharp ladataan oman määritystiedostosi jälkeen ja ohittavat sen, ja poista kommentointi pyöristykseltä tiedostossa `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Poista ikkunoiden välit

Kannettavien tietokoneiden näytöillä jotkut eivät halua tuhlata yhtäkään pikseliä ikkunoiden väleihin (tai edes yläpalkkiin, jonka voit kytkeä pois päältä näppäimillä `Super + Shift + Space`). Voit kytkeä kaikki välit ja reunukset pois päältä näppäimillä `Super + Shift + Backspace` tai poistaa ne pysyvästi poistamalla kommentit tästä tiedoston `~/.config/hypr/looknfeel.lua` osiosta:

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
