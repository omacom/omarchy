# Mac-tuki

Omarchyssa on sisäänrakennettu tuki **Intel-Maceille**. Tällä hetkellä on pari tunnettua rajoitusta, mutta kunhan olet niistä tietoinen ja hyväksyt ne, voit puhaltaa vanhoihin Maceihisi uutta elämää asentamalla Omarchyn.

Huomaa, että asentamista M-sarjan Macille ei tueta suoraan tällä hetkellä. Saat lisätietoja tämän tilanteesta kanavalta #omarchy-on-other [Discordissamme](https://discord.gg/tXFUdasqhY).

Yksinkertaisessa testissä saavutimme 36 % suorituskykyparannuksen vuoden 2019 MacBook Prolla pelkästään asentamalla Omarchyn.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchyn asentaminen Macille

Omarchy tukee tällä hetkellä vain sitä, että se on **ainoa** asennettu käyttöjärjestelmä. Asennuksen aikana asema tyhjennetään eikä MacOS ole enää käynnistettävissä.

Voit silti palauttaa sen myöhemmin Internet Recoveryn kautta halutessasi.

Tämän osan osalta oletamme, että olet jo katsonut kohdan [Aloittaminen](02-getting-started.md) ja USB-asemasi on valmis. Jos ei ole, tee se nyt.

#### Poista Secure Boot käytöstä

Applen Secure Boot on poistettava käytöstä käynnistyäkseen käynnistettävältä USB:ltä sekä käyttöjärjestelmään. Poista se käytöstä seuraavasti:

1. Sammuta Macisi
2. Käynnistä se ja paina _heti_ Command-R pohjaan, kunnes näet latausruudun ilmestyvän
3. Valitse käyttäjäsi ja syötä salasanasi pyydettäessä
4. Kun olet palautusruudulla, valitse valikkopalkista **Utilities > Startup Security Utility**
5. Syötä salasanasi, kun sinua pyydetään todentamaan
6. Valitse Secure Boot -vaihtoehdoista ”No Security”
7. Valitse External Boot -vaihtoehdoista ”Allow booting from external or removable media”

#### Käynnistä asennus

1. Aseta USB-asema
2. Käynnistä Macisi uudelleen ja paina _heti_ Option pohjaan, kunnes näet käynnistyslaitteiden ruudun
3. Valitse oranssi EFI Boot -laite
4. Jatka [asennuksella normaalisti](02-getting-started.md)

Asennusohjelma tunnistaa Mac-laitteiston ja soveltaa tarvittavat korjaukset automaattisesti: Broadcom Wi-Fi -ajurit ja laiteohjelmiston, SPI-näppäimistöajurin sitä tarvitseviin MacBook-malleihin sekä NVMe-lepotilakorjauksen samoille malleille.

### Tunnetut rajoitukset

Yhteisön jäsenet työskentelevät jatkuvasti ratkaisujen parissa näihin haasteisiin, joten jos nämä ovat sinulle ongelmallisia, liity kanavalle #omarchy-on-other [Discordissamme](https://discord.gg/tXFUdasqhY) ja katso, onko ajantasaisia menetelmiä niiden ratkaisemiseksi.

#### Laitteet, joissa on T1-siru

Apple T1 -siru esiteltiin loppuvuonna 2016 ja sitä käytettiin yksinomaan ensimmäisen sukupolven MacBook Pro -malleissa, joissa on Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Tunnetut ongelmat

- Touch Bar ei toimi
- Ääni ei toimi

#### Laitteet, joissa on T2-siru

Apple T2 Security Chip esiteltiin vuonna 2017. T2-siru lakkautettiin siirtymässä Apple Siliconiin (M-sarjan siruihin) alkaen vuodesta 2020.

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

Näissä malleissa asennusohjelma asettaa automaattisesti korjatun `linux-t2`-ytimen, T2-äänimäärityksen, Applen Broadcom Wi-Fi/Bluetooth-laiteohjelmiston ja tuulettimen ohjauksen `t2fanrd`:n kautta. Touch Bar toimii ytimen sisäänrakennetulla Boot Camp -tyylisellä tuella.
