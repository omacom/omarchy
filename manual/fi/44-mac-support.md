# Mac-tuki

Omarchyssa on sisäänrakennettu tuki **Intel Maceille**. Tällä hetkellä tiedossa on pari rajoitusta, mutta kunhan tiedät ne ja ne sopivat sinulle, voit puhaltaa vanhoihin Maceihisi uutta elämää asentamalla Omarchyn.

Huomaa, että asentaminen M-sarjan Maciin ei ole tällä hetkellä suoraan tuettua. Lisätietoja tämän tilanteesta löydät kanavalta #omarchy-on-other [Discordissamme](https://discord.gg/tXFUdasqhY).

Yksinkertaisessa testissä saimme vuoden 2019 MacBook Prohon 36% lisää suorituskykyä pelkästään asentamalla Omarchyn.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchyn asentaminen Maciin

Omarchy tukee tällä hetkellä vain sitä, että se on koneen **ainoa** käyttöjärjestelmä. Asennuksen aikana levy tyhjennetään, eikä MacOSia voi enää käynnistää.

Voit silti palauttaa sen myöhemmin Internet Recoveryn kautta, jos haluat.

Tässä osiossa oletamme, että olet jo lukenut kohdan [Aloittaminen](02-getting-started.md) ja USB-asemasi on valmiina. Jos ei ole, tee se nyt.

#### Poista Secure Boot käytöstä

Applen Secure Boot on poistettava käytöstä, jotta käynnistettävä USB voidaan käynnistää, samoin kuin käyttöjärjestelmä. Poista se käytöstä näin:

1. Sammuta Macisi
2. Käynnistä se ja paina _välittömästi_ Command-R pohjaan ja pidä se painettuna, kunnes näet latausruudun tulevan näkyviin
3. Valitse käyttäjäsi ja syötä salasanasi, jos sitä kysytään
4. Kun olet palautusruudussa, valitse valikkopalkista **Utilities > Startup Security Utility**
5. Syötä salasanasi, kun sinua pyydetään todentautumaan
6. Valitse Secure Boot -asetuksista "No Security"
7. Valitse External Boot -asetuksista "Allow booting from external or removable media"

#### Aloita asennus

1. Aseta USB-asema paikalleen
2. Käynnistä Macisi uudelleen ja paina _välittömästi_ Option pohjaan ja pidä se painettuna, kunnes näet käynnistyslaitteiden ruudun
3. Valitse oranssi EFI Boot -laite
4. Jatka [asennusta normaalisti](02-getting-started.md)

Asennusohjelma tunnistaa Mac-laitteiston ja ottaa tarvittavat korjaukset käyttöön automaattisesti: Broadcom Wi-Fi -ajurit ja firmwaren, SPI-näppäimistöajurin niillä MacBook-malleilla, jotka sitä tarvitsevat, ja NVMe-lepotilakorjauksen samoille malleille.

### Tunnetut rajoitukset

Yhteisön jäsenet työstävät näihin haasteisiin jatkuvasti ratkaisuja, joten jos nämä ovat sinulle ongelma, liity kanavalle #omarchy-on-other [Discordissamme](https://discord.gg/tXFUdasqhY) ja katso, onko niiden ratkaisemiseen jo ajantasaisia keinoja.

#### Laitteet, joissa on T1-siru

Apple T1 -siru esiteltiin loppuvuonna 2016, ja sitä käytettiin yksinomaan ensimmäisen sukupolven MacBook Pro -malleissa, joissa on Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Tunnetut ongelmat

- Touch Bar ei toimi
- Ääni ei toimi

#### Laitteet, joissa on T2-siru

Apple T2 Security Chip esiteltiin vuonna 2017. T2-sirun käyttö lopetettiin siirryttäessä Apple siliconiin (M-sarjan siruihin) vuodesta 2020 alkaen.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Näissä malleissa asennusohjelma ottaa automaattisesti käyttöön paikatun `linux-t2`-ytimen, T2-ääniasetukset, Applen Broadcom Wi-Fi/Bluetooth-firmwaren ja tuuletinhallinnan `t2fanrd`:llä. Touch Bar toimii ytimen sisäänrakennetulla Boot Camp -tyylisellä tuella.

#### iMac Retina 5K (2017)

Vuoden 2017 27-tuumaisessa iMacissa ei ole T2-sirua, joten asennusohjelma asentaa sen kuten muutkin Intel Macit.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Tunnetut ongelmat

- Näyttö ei toimi natiiviresoluutiollaan 5120×2880: paneeli koostuu kahdesta osasta, ja vakioajuri sytyttää niistä vain yhden
- Ääni ei toimi
- Kirkkaudensäätö ei vaikuta mihinkään
- Lepotila jumittaa koneen; vain virrankatkaisu ja uudelleenkäynnistys palauttaa sen

Tälle mallille tehty yhteisön korjaustyökalu korjaa näytön, äänen ja kirkkauden: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
