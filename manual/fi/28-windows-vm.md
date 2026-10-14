# Windows VM

Omarchy tarjoaa helpon tavan ajaa Windowsia Docker VM:n kautta. Voit asentaa sen käyttämällä Omarchy-valikon (`Super + Space`) kohtaa _Asenna > Windows_.

Koneesi tarvitsee tätä varten KVM-virtualisoinnin, joka useimmissa on — mutta se on joskus kytketty pois päältä BIOSissa, ja asentaja kertoo sinulle, jos niin on. Haluat myös levytilaa: sen verran kuin annat Windowsille, plus noin 10 Gt itse imagelle.

Asentaja kysyy, kuinka paljon RAMia, kuinka monta CPU-ydintä ja kuinka paljon levyä luovutetaan (64 Gt tai enemmän on järkevä alaraja), sitten Windows-käyttäjänimeä ja salasanaa. Jätä ne tyhjiksi, niin saat `docker` / `admin`. Lataus kestää jonkin aikaa — 10–15 minuuttia on normaalia — ja voit seurata edistymistä selaimessa osoitteessa `http://127.0.0.1:8006`. Selain kysyy samat käyttäjänimen ja salasanan ennen konsolin avaamista.

 ![windows-vm](images/windows-vm.webp)

## Käyttäminen

Kun se on asennettu, käynnistä _Windows_ sovellusten käynnistimestä. Se käynnistää VM:n, jollei se ole jo käynnissä, ja yhdistää sinut RDP:n yli, koko näytöltä. Anna sille 15–30 sekuntia kylmäkäynnistyksessä.

RDP-istunto kuljettaa äänen, mikrofonisi ja jaetun leikepöydän, joten tekstin kopioiminen Linuxin ja Windowsin välillä vain toimii. Resoluutio seuraa ikkunaasi, ja Omarchy välittää näyttösi skaalauksen läpi, joten se ei ole sumea sotku HiDPI-näytöllä.

Kun suljet RDP-ikkunan, VM sammuu automaattisesti. Jos haluat mieluummin jättää sen käyntiin — sanotaan, että siellä pyörii jotain tekemässä työtä — käynnistä se sen sijaan komennolla `omarchy windows vm launch --keep-alive`.

Loput ohjaimista ovat samassa komennossa:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Tiedostojen jakaminen

Kotihakemistosi hakemisto `~/Windows` jaetaan automaattisesti VM:n kanssa. Laita tiedostoja sinne, jos haluat niiden olevan Windowsin saatavilla. VM:llä ei ole pääsyä mihinkään muuhun tiedostojärjestelmäsi osaan, joten olet turvassa miltään ikävältä Windowsin puolella. Sen oma virtuaalilevy on saatavilla osoitteessa `~/.windows`.

Nuo tutut kotipolut pysyvät omissa tiedostojärjestelmissään. Ne voivat olla myös symbolisia linkkejä omistamiisi hakemistoihin, mikä on hyödyllistä, kun virtuaalilevy sijaitsee suuremmalla asemalla. Asentaja mittaa vapaan tilan tiedostojärjestelmässä, joka oikeasti sisältää polun `~/.windows`, ei välttämättä kotihakemistosi sisältävässä tiedostojärjestelmässä.

Pidä levy- ja jaetut polut erillisinä, päällekkäin menemättöminä hakemistoina. Poisto tyhjentää levyhakemiston tarkoituksellisesti mutta säilyttää jaetun hakemiston. Välittömästi ennen poistamista Omarchy suorittaa rajatun rajaustarkistuksen ja kieltäytyy poistamasta mitään, jos kyseinen tarkistus aikakatkeaa tai ei voi todistaa, että kaksi puuta ovat erillään.

Ennen VM:n käynnistymistä Omarchy avaa ja kiinnittää nuo kaksi hakemistoa ja bind-liittää sitten tarkat hakemisto-inodet yksityisiin käyttäjäkohtaisiin ankkureihin polun `/var/lib/omarchy/windows/mounts` alla. Docker näkee vain nuo root-suojatut ankkurit. Tämä säilyttää mukautetut levysijainnit ja estää samalla toista käyttäjänäsi ajettavaa prosessia vaihtamasta tarkistettua polkua ennen kuin etuoikeutettu kontti kuluttaa sen. Olemassa olevat levy- ja jaetut hakemistot kiristetään tilaan `0700` siirron aikana, jotta muut paikalliset tilit eivät voi selata niiden sisältöä.

VM:n portit on sidottu vain localhostiin, joten mikään verkossasi ei pääse Windows-koneeseen. Verkkokonsoli vaatii myös määritetyn Windows-käyttäjänimen ja salasanan, mikä estää toista paikallista tiliä ajamasta VM:ää portin 8006 kautta.

## Rajoitukset ja lisensointi

Tässä asetuksessa ei ole GPU-läpivientiä, joten se ei sovellu pelaamiseen tai videoeditointiin. Se on erinomainen tapa ajaa Microsoft Officea tai mitä tahansa muuta, mikä sinun ehdottomasti on saatava.

Asennettu versio on Windows 11 Pro, aktivoimaton. Tarvitset oman lisenssiavaimesi käyttääksesi portitettuja ominaisuuksia.

Jos tämä tietokone toimitettiin Windowsilla, OEM-avain on edelleen firmwaressa jopa Omarchyn asentamisen jälkeen. Tulosta se komennolla `omarchy windows key`. Tuo avain on sidottu tähän koneeseen — se aktivoi tälle laitteistolle uudelleen asennetun Windowsin, mutta se ei yleensä aktivoi VM:ää.

Voit muuttaa resurssien varausta myöhemmin ajamalla uudelleen `omarchy-windows-vm install`, joka kirjoittaa VM:n määrityksen uudelleen vastauksistasi. Compose-tiedosto itse sijaitsee nyt osoitteessa `/var/lib/omarchy/windows/docker-compose.yml` ja sen omistaa root — se on tarkoituksellista, jotta käyttäjänäsi ajettava prosessi ei voi kirjoittaa sitä uudelleen ja saada etuoikeutettua käynnistystä liittämään koko levysi konttiin. Jos sinun pitää muokata sitä käsin (esimerkiksi liittääksesi USB-laitteen), muokkaa sitä `sudo`lla ja katso kaikki vaihtoehdot projektista [Dockur Windows](https://github.com/dockur/windows).

Päästäksesi eroon koko jutusta käytä Omarchy-valikon kohtaa _Poista > Windows_. Se poistaa VM:n levyn ja kaikki sen tiedot, joten varmista, että kaikki välittämäsi on ensin pois hakemistosta `~/Windows`.
