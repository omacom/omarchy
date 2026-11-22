# Mac-tuki

## Omarchy for Apple Silicon

Omarchy for Apple Silicon on virallinen Omacom-ratkaisu, joka julkaistiin ensimmäisen kerran Omarchy 4.5:n yhteydessä. Se asennetaan macOS:n rinnalle, ja valitset niiden välillä Macin käynnistyessä.

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

M4:ää ja uudempia Maceja ei vielä tueta. M4-tuki on testissä edge-kanavalla ja tulee seuraavaksi. Asennusohjelma tarkistaa Macisi ennen kuin se muuttaa mitään.

Millä tahansa Apple Silicon Macilla, myös M4:llä ja uudemmilla, voit ajaa Omarchya virtuaalikoneessa [Try Omarchy](https://github.com/omacom/try-omarchy) avulla.

### Mitä tarvitset

- macOS 15 Sequoia tai uudempi ja järjestelmänvalvojan tili
- Vapaata levytilaa Omarchylle. Asennusohjelma ehdottaa kokoa ja antaa muuttaa sitä.
- Varmuuskopio Macistasi, virtaa ja internetyhteys. Asennus lataa useita gigatavuja.

### Asentaminen

Asennat sen macOS:stä. Asenna Omarchy Installer [Homebrew](https://brew.sh):llä:

```sh
brew install omacom/mac/omarchy
```

Tai lataa uusin Omarchy Installer sen [julkaisusivulta](https://github.com/omacom/omarchy-mac-installer/releases) ja avaa se.

Asennusohjelma tarkistaa Macisi, näyttää suunnitelman ja tekee tilaa Omarchylle pienentämällä macOS-osiota. macOS pysyy levyllä eikä USB-asemaa tarvita. Kun ensimmäinen vaihe on valmis, se opastaa sinut viimeistelemään asennuksen macOS Recoveryssä: sammuta, pidä virtapainiketta painettuna, kunnes "Loading startup options" tulee näkyviin, valitse Omarchy ja seuraa ohjeita.

Ensimmäisellä käynnistyksellä Omarchy pyytää salasanaa, joka salaa sen levyn. Palautusavainta ei ole: jos unohdat salasanan, Omarchy-tiedostojasi ei voi palauttaa.

Kun haluat myöhemmin vaihtaa Omarchyn ja macOS:n välillä, sammuta ja pidä sitten virtapainiketta painettuna, kunnes käynnistysvaihtoehdot tulevat näkyviin, ja valitse niistä yksi.

### Tuletko Omarchy Macista

Omarchy Mac on nyt osa Omarchy for Apple Siliconia, ja jokainen Mac, jolla sitä käytettiin, on tuettu. Nykyinen asennuksesi toimii edelleen ja sen järjestelmäpaketit päivittyvät yhä, mutta se ei saa enää Omarchy-päivityksiä. Määräaikaa ei ole eikä päivitystä paikallaan tehdä: otat varmuuskopion, poistat vanhan asennuksen, asennat puhtaalta pöydältä ja palautat. Vaiheet 2–5 tapahtuvat macOS:ssä, joten avaa tämä sivu puhelimessasi ennen uudelleenkäynnistystä.

1. **Tee varmuuskopio Omarchysta, pois Macilta.** Vanhan asennuksen poistaminen pyyhkii sen, eikä macOS osaa lukea Omarchy-levyä. Kopioi kotikansiosi ulkoiselle asemalle tai toiselle tietokoneelle, mukaan lukien SSH- ja GPG-avaimet, selainten profiilit ja työntämätön työ. Tallenna pakettilistasi komennolla `pacman -Qqe > ~/packages.txt`. Varmuuskopioi myös macOS, koska sekä poistaminen että asentaminen muuttavat sen levyn kokoa.
2. **Käynnistä Macisi macOS:ään.** Sammuta, pidä virtapainiketta painettuna, kunnes käynnistysvaihtoehdot tulevat näkyviin, ja valitse macOS.
3. **Asenna Omarchy Installer** kohdassa [Asentaminen](#installing) esitetyllä tavalla.
4. **Poista vanha asennus.** Avaa Omarchy Installer ja valitse Installation > Remove Omarchy. Se näyttää, mitä se poistaa, ja palauttaa tilan macOS:lle. Jos se ei tunnista asennustasi, se pysähtyy muuttamatta levyä. Pyydä apua [Discord](https://discord.gg/tXFUdasqhY)issa sen sijaan, että poistaisit osioita käsin, mikä voi pyyhkiä macOS:n.
5. **Asenna Omarchy for Apple Silicon** asennusohjelmalla.
6. **Palauta tiedostosi.** Tuo asetuksesi takaisin pala kerrallaan sen sijaan, että kopioisit koko `~/.config`:n uusien oletusten päälle, koska vanhat asetukset voivat ohittaa ne.

### Hyvä tietää

- M1- ja M2-MacBookeilla herätät koneen lepotilasta avaamalla kannen tai painamalla virtapainiketta.
- Kysymyksiä tai ongelmia: kysy [Discord](https://discord.gg/tXFUdasqhY)issamme.

[Asennusohjelman README](https://github.com/omacom/omarchy-mac-installer#readme) kattaa julkaisukanavat, asennusohjelman päivittämisen ja Omarchyn poistamisen.

## Intel-Macit

Yksinkertaisessa testissä saimme vuoden 2019 MacBook Prossa 36 %:n suorituskykyparannuksen pelkästään asentamalla Omarchyn.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchyn asentaminen Macille

Omarchy tukee tällä hetkellä vain sitä, että se on **ainoa** asennettu käyttöjärjestelmä. Asennuksen aikana levy tyhjennetään eikä MacOS ole enää käynnistettävissä.

Voit silti palauttaa sen myöhemmin Internet Recoveryn kautta, jos haluat.

Tämän osan osalta oletamme, että olet jo tutustunut kohtaan [Aloittaminen](02-getting-started.md) ja USB-asemasi on valmiina. Jos ei, tee se nyt.

#### Poista Secure Boot käytöstä

Applen Secure Boot on poistettava käytöstä, jotta käynnistettävä USB voidaan käynnistää, samoin kuin käyttöjärjestelmä. Poista se käytöstä seuraavasti:

1. Sammuta Macisi
2. Käynnistä se ja paina _välittömästi_ Command-R:tä ja pidä sitä painettuna, kunnes latausnäyttö tulee näkyviin
3. Valitse käyttäjäsi ja anna salasanasi, jos sitä pyydetään
4. Kun olet palautusnäytössä, valitse valikkopalkista **Utilities > Startup Security Utility**
5. Anna salasanasi, kun sinua pyydetään tunnistautumaan
6. Valitse Secure Boot -vaihtoehdoista "No Security"
7. Valitse External Boot -vaihtoehdoista "Allow booting from external or removable media"

#### Aloita asennus

1. Aseta USB-asema paikoilleen
2. Käynnistä Macisi uudelleen ja paina _välittömästi_ Optionia ja pidä sitä painettuna, kunnes näet käynnistyslaitteiden näytön
3. Valitse oranssi EFI Boot -laite
4. Jatka [asennuksella tavalliseen tapaan](02-getting-started.md)

Asennusohjelma tunnistaa Mac-laitteiston ja ottaa tarvittavat korjaukset käyttöön automaattisesti: Broadcom Wi-Fi -ajurit ja laiteohjelmiston, SPI-näppäimistöajurin niillä MacBook-malleilla, jotka sitä tarvitsevat, sekä NVMe-lepotilakorjauksen samoille malleille.

### Tunnetut rajoitukset

Yhteisön jäsenet työskentelevät jatkuvasti näiden haasteiden ratkaisujen parissa, joten jos nämä ovat sinulle ongelmallisia, liity #omarchy-on-other-kanavalle [Discord](https://discord.gg/tXFUdasqhY)issamme ja katso, onko niiden ratkaisemiseen ajantasaisia menetelmiä.

#### Laitteet, joissa on T1-siru

Apple T1 -siru esiteltiin loppuvuodesta 2016 ja sitä käytettiin yksinomaan ensimmäisen sukupolven Touch Barilla varustetuissa MacBook Pro -malleissa.
- MacBook Pro 13-tuumainen (2016, kaksi Thunderbolt 3 -porttia) – Malli: A1706
- MacBook Pro 13-tuumainen (2016, neljä Thunderbolt 3 -porttia) – Malli: A1708
- MacBook Pro 15-tuumainen (2016) – Malli: A1707

#### Tunnetut ongelmat

- Touch Bar ei toimi
- Ääni ei toimi

#### Laitteet, joissa on T2-siru

Apple T2 Security Chip esiteltiin vuonna 2017. T2-siru lopetettiin siirryttäessä Apple siliconiin (M-sarjan siruihin) vuodesta 2020 alkaen.

- iMac Pro (2017) – Malli: A1862
- MacBook Pro 13-tuumainen (2018, neljä Thunderbolt 3 -porttia) – Malli: A1989
- MacBook Pro 15-tuumainen (2018) – Malli: A1990
- MacBook Air (Retina, 13-tuumainen, 2018) – Malli: A1932
- Mac mini (2018) – Malli: A1998
- MacBook Pro 13-tuumainen (2019, kaksi Thunderbolt 3 -porttia) – Malli: A2159
- MacBook Pro 13-tuumainen (2019, neljä Thunderbolt 3 -porttia) – Malli: A2178
- MacBook Pro 15-tuumainen (2019) – Malli: A1990
- iMac (Retina 5K, 27-tuumainen, 2020) – Malli: A2115 (iMac20,1 ja iMac20,2)
- MacBook Pro 13-tuumainen (2020, kaksi Thunderbolt 3 -porttia) – Malli: A2265
- MacBook Pro 15-tuumainen (2020) – Malli: A1990

Näillä malleilla asennusohjelma asentaa automaattisesti korjatun `linux-t2`-ytimen, T2-äänimäärityksen, Applen Broadcom Wi-Fi/Bluetooth-laiteohjelmiston ja tuulettimen ohjauksen `t2fanrd`:n avulla. Touch Bar toimii ytimen sisäänrakennetulla Boot Camp -tyylisellä tuella.

#### iMac Retina 5K (2017)

Vuoden 2017 27-tuumaisessa iMacissa ei ole T2-sirua, joten asennusohjelma asentaa sen kuten muut Intel-Macit.

- iMac (Retina 5K, 27-tuumainen, 2017) – Malli: A1419

#### Tunnetut ongelmat

- Näyttö ei toimi sen natiivilla 5120×2880-tarkkuudella: paneeli koostuu kahdesta osasta, ja vakioajuri sytyttää vain toisen
- Ääni ei toimi
- Kirkkauden säätö ei vaikuta
- Lepotila jumittaa koneen; vain virran katkaiseminen ja kytkeminen palauttaa sen

Yhteisön korjaustyökalu tälle mallille korjaa näytön, äänen ja kirkkauden: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
