# Mac-tuki

## Omarchy Apple Siliconille

Omarchy Apple Siliconille on virallinen Omacomin ratkaisu, joka julkaistiin ensimmäisen kerran Omarchy 4.5:n yhteydessä. Se asennetaan macOS:n rinnalle, ja valitset niiden välillä, kun Macisi käynnistyy.

Saitko ilmoituksen Omarchy Macista? Siirry kohtaan [Tuletko Omarchy Macista](#coming-from-omarchy-mac).

Se toimii näillä Maceilla:

| Mac | Sirut |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4:ää ja uudempia Maceja ei vielä tueta. M4-tuki on testattavana edge-kanavalla ja tulee seuraavaksi. Asennusohjelma tarkistaa Macisi ennen kuin se muuttaa mitään.

Millä tahansa Apple Silicon Macilla, myös M4:llä ja uudemmilla, voit ajaa Omarchya virtuaalikoneessa [Try Omarchylla](https://github.com/omacom/try-omarchy).

### Mitä tarvitset

- macOS 15 Sequoia tai uudempi ja järjestelmänvalvojan tili
- Vapaata levytilaa Omarchylle. Asennusohjelma ehdottaa kokoa ja antaa sinun vaihtaa sen.
- Macin varmuuskopio, virtaa ja internetyhteys. Asennus lataa useita gigatavuja.

### Asentaminen

Asennat macOS:sta. Asenna Omarchy Installer [Homebrew'lla](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Tai lataa uusin Omarchy Installer sen [julkaisusivulta](https://github.com/omacom/omarchy-mac-installer/releases) ja avaa se.

Asennusohjelma tarkistaa Macisi, näyttää sinulle suunnitelman ja tekee tilaa Omarchylle pienentämällä macOS-osiota. macOS jää levylle eikä USB-asemaa tarvita. Kun ensimmäinen vaihe on valmis, se opastaa sinut viimeistelemään asennuksen macOS Recoveryssa: sammuta, pidä virtapainiketta painettuna, kunnes "Loading startup options" tulee näkyviin, valitse Omarchy ja seuraa ohjeita.

Ensimmäisellä käynnistyksellä Omarchy pyytää salasanaa, joka salaa sen levyn. Palautusavainta ei ole: jos unohdat salasanan, Omarchy-tiedostojasi ei voi palauttaa.

Vaihtaaksesi myöhemmin Omarchyn ja macOS:n välillä sammuta, pidä sitten virtapainiketta painettuna, kunnes käynnistysvalinnat tulevat näkyviin, ja valitse toinen.

### Tuletko Omarchy Macista

Omarchy Mac on nyt osa Omarchy Apple Siliconille -ratkaisua, ja jokainen Mac, jolla sitä ajettiin, on tuettu. Nykyinen asennuksesi toimii edelleen ja sen järjestelmäpaketit päivittyvät edelleen, mutta se ei saa enää Omarchy-päivityksiä. Määräaikaa ei ole eikä päivitystä paikallaan tehdä: varmuuskopioit, poistat vanhan asennuksen, asennat puhtaalta pöydältä ja palautat. Vaiheet 2–5 tapahtuvat macOS:ssa, joten avaa tämä sivu puhelimellasi ennen kuin käynnistät uudelleen.

1. **Varmuuskopioi Omarchysta, pois Macilta.** Vanhan asennuksen poistaminen pyyhkii sen, eikä macOS osaa lukea Omarchy-levyä. Kopioi kotikansiosi ulkoiselle asemalle tai toiselle tietokoneelle, mukaan lukien SSH- ja GPG-avaimet, selainten profiilit ja työntämätön työ. Tallenna pakettilistasi komennolla `pacman -Qqe > ~/packages.txt`. Varmuuskopioi myös macOS, koska sekä poistaminen että asentaminen muuttavat sen levyn kokoa.
2. **Käynnistä Macisi macOS:ään.** Sammuta, pidä virtapainiketta painettuna, kunnes käynnistysvalinnat tulevat näkyviin, ja valitse macOS.
3. **Asenna Omarchy Installer** kuten kohdassa [Asentaminen](#installing) näytetään.
4. **Poista vanha asennus.** Avaa Omarchy Installer ja valitse Installation > Remove Omarchy. Se näyttää, mitä se poistaa, ja palauttaa tilan macOS:lle. Jos se ei tunnista asennustasi, se pysähtyy muuttamatta levyä. Pyydä apua [Discordissa](https://discord.gg/tXFUdasqhY) äläkä poista osioita käsin, mikä voi pyyhkiä macOS:n.
5. **Asenna Omarchy Apple Siliconille** asennusohjelmalla.
6. **Palauta tiedostosi.** Tuo asetuksesi takaisin pala kerrallaan äläkä kopioi koko `~/.config`-kansiota uusien oletusten päälle, koska vanhat asetukset voivat ohittaa ne.

### Hyvä tietää

- M1- ja M2-MacBookeilla herätät koneen unesta avaamalla kannen tai painamalla virtapainiketta.
- Kysymyksiä tai ongelmia: kysy [Discordissamme](https://discord.gg/tXFUdasqhY).

[Asennusohjelman README](https://github.com/omacom/omarchy-mac-installer#readme) kattaa julkaisukanavat, asennusohjelman päivittämisen ja Omarchyn poistamisen.

## Intel-Macit

Yksinkertaisessa testissä saimme 36 %:n suorituskykyparannuksen vuoden 2019 MacBook Prohon pelkästään asentamalla Omarchyn.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchyn asentaminen Macille

Omarchy tukee tällä hetkellä vain sitä, että se on **ainoa** asennettu käyttöjärjestelmä. Asennuksen aikana asema pyyhitään, eikä MacOS ole enää käynnistettävissä.

Voit silti palauttaa sen myöhemmin Internet Recoveryn kautta, jos haluat.

Tässä osassa oletamme, että olet jo tutustunut kohtaan [Aloittaminen](02-getting-started.md) ja USB-asemasi on valmiina. Jos ei ole, tee se nyt.

#### Poista Secure Boot käytöstä

Applen Secure Boot on poistettava käytöstä, jotta käynnistettävä USB ja myös käyttöjärjestelmä voidaan käynnistää. Poista se käytöstä seuraavasti:

1. Sammuta Macisi
2. Käynnistä se ja paina _välittömästi_ Command-R painettuna ja pidä sitä, kunnes näet latausnäytön tulevan näkyviin
3. Valitse käyttäjäsi ja anna salasanasi, jos sitä pyydetään
4. Kun olet palautusnäytössä, valitse valikkoriviltä **Utilities > Startup Security Utility**
5. Anna salasanasi, kun sinua pyydetään todentamaan
6. Valitse Secure Boot -valinnoista "No Security"
7. Valitse External Boot -valinnoista "Allow booting from external or removable media"

#### Aloita asennus

1. Aseta USB-asema paikalleen
2. Käynnistä Macisi uudelleen ja paina _välittömästi_ Option painettuna ja pidä sitä, kunnes näet käynnistyslaitteiden näytön
3. Valitse oranssi EFI Boot -laite
4. Jatka [asennusta normaalisti](02-getting-started.md)

Asennusohjelma tunnistaa Mac-laitteiston ja ottaa tarvittavat korjaukset käyttöön automaattisesti: Broadcomin Wi-Fi-ajurit ja -laiteohjelmiston, FaceTime HD -kamera-ajurin koneissa, joissa on Broadcom 1570 (sen laiteohjelmisto ladataan Applelta, kun Mac on verkossa, koska asennusohjelma toimii offline-tilassa), SPI-näppäimistöajurin sitä tarvitsevissa MacBook-malleissa ja NVMe-lepotilakorjauksen samoille malleille.

### Tunnetut rajoitukset

Yhteisön jäsenet työskentelevät jatkuvasti ratkaisujen parissa näihin haasteisiin, joten jos nämä ovat sinulle ongelmallisia, liity kanavalle #omarchy-on-other [Discordissamme](https://discord.gg/tXFUdasqhY) ja katso, onko näiden ratkaisemiseen olemassa ajantasaisia menetelmiä.

#### FaceTime HD -kamera

Kamera-ajuri jumittaa koneen, jos se on ladattuna Macin siirtyessä horrostilaan, joten se poistetaan käytöstä ensin. Sitä ei voi poistaa käytöstä, kun sovelluksella on kamera auki, joten horrostila peruutetaan ilmoituksella, jossa nimetään sovellus: sulje se ja siirry horrostilaan uudelleen. Tämä koskee myös automaattista horrostilaa kriittisen akun varauksen vuoksi sekä suspend-then-hibernate-toimintoa, joka evätään ennen kuin se siirtyy lepotilaan. Tavallisen lepotilan estää ajuri itse kameran ollessa auki, ilman ilmoitusta.

Kameran laiteohjelmisto ladataan Applelta, joten kamera toimii vasta, kun Mac on ollut verkossa. Lataus alkaa käynnistyksessä ja sitä yritetään uudelleen 15 minuutin välein, kun verkko on ongelmana; jos Applen tiedosto on muuttunut, se pysähtyy ja odottaa Omarchy-päivitystä. Jos kamera ei tule näkyviin, `journalctl -u facetimehd-firmware-fetcher` kertoo miksi, `sudo systemctl restart facetimehd-firmware-fetcher` yrittää uudelleen, ja uudelleenkäynnistys lataa ajurin, jos lataus valmistui mutta kamera ei vieläkään ole siellä.

#### Laitteet, joissa on T1-siru

Apple T1 -siru esiteltiin loppuvuonna 2016 ja sitä käytettiin yksinomaan ensimmäisen sukupolven MacBook Pro -malleissa, joissa on Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Tunnetut ongelmat

- Touch Bar ei toimi
- Ääni ei toimi

#### Laitteet, joissa on T2-siru

Apple T2 Security Chip esiteltiin vuonna 2017. T2-siru lopetettiin siirryttäessä Apple siliconiin (M-sarjan sirut) vuodesta 2020 alkaen.

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

Näissä malleissa asennusohjelma asentaa automaattisesti paikatun `linux-t2`-ytimen, T2-äänimäärityksen, Applen Broadcom Wi-Fi/Bluetooth-laiteohjelmiston ja tuuletinhallinnan `t2fanrd`:n avulla. Touch Bar toimii ytimen sisäänrakennetulla Boot Camp -tyylisellä tuella.

#### iMac Retina 5K (2017)

Vuoden 2017 27-tuuman iMacissa ei ole T2-sirua, joten asennusohjelma määrittää sen kuten muut Intel-Macit.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Tunnetut ongelmat

- Näyttö ei toimi sen natiiviresoluutiolla 5120×2880: paneeli koostuu kahdesta osasta, ja vakioajuri valaisee vain yhden
- Ääni ei toimi
- Kirkkaudensäätö ei vaikuta
- Lepotila jumittaa koneen; vain virrankatkaisu palauttaa sen

Tälle mallille tarkoitettu yhteisön paikkain korjaa näytön, äänen ja kirkkauden: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
