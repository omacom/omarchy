# Windows VM

Omarchy tarjoaa helpon tavan ajaa Windowsia Docker VM:n kautta x86_64-koneilla. Voit asentaa sen Omarchy-valikosta (`Super + Space`) kohdasta _Asenna > Windows_.

Koneesi tarvitsee tähän KVM-virtualisoinnin, joka useimmissa onkin — mutta se on joskus kytketty pois päältä BIOSissa, ja asennusohjelma kertoo sinulle, jos näin on. Tarvitset myös levytilaa: sen verran kuin annat Windowsille, plus noin 10GB itse imagelle.

Asennusohjelma kysyy, kuinka paljon RAM-muistia, kuinka monta CPU-ydintä ja kuinka paljon levytilaa luovutat (64GB tai enemmän on järkevä alaraja), ja sen jälkeen Windows-käyttäjänimeä ja -salasanaa. Jätä ne tyhjiksi, niin saat `docker` / `admin`. Lataus kestää jonkin aikaa — 10-15 minuuttia on normaalia — ja voit seurata edistymistä selaimessa osoitteessa `http://127.0.0.1:8006`. Selain kysyy samaa käyttäjänimeä ja salasanaa ennen konsolin avaamista.

 ![windows-vm](images/windows-vm.webp)

## Käyttö

Kun se on asennettu, käynnistä _Windows_ sovelluskäynnistimestä. Se käynnistää VM:n, jos se ei ole jo käynnissä, ja yhdistää sinut RDP:llä koko näytölle. Anna sille 15-30 sekuntia kylmäkäynnistyksessä.

RDP-istunto välittää äänen, mikrofonisi ja jaetun leikepöydän, joten tekstin kopioiminen Linuxin ja Windowsin välillä vain toimii. Tarkkuus seuraa ikkunaasi, ja Omarchy välittää näytön skaalauksesi läpi, joten se ei ole sumeaa sotkua HiDPI-näytöllä.

Kun suljet RDP-ikkunan, VM sammuu automaattisesti. Jos haluat mieluummin jättää sen käyntiin — sanotaan, että sinulla on siellä jotain tekemässä työtä — käynnistä se sen sijaan komennolla `omarchy windows vm launch --keep-alive`.

Muut hallintatoiminnot löytyvät samasta komennosta:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Tiedostojen jakaminen

Kotihakemistossasi oleva hakemisto `~/Windows` jaetaan automaattisesti VM:n kanssa. Laita tiedostot sinne, jos haluat niiden olevan Windowsin käytettävissä. VM:llä ei ole pääsyä mihinkään muuhun osaan tiedostojärjestelmääsi, joten olet turvassa kaikilta Windows-puolen ikävyyksiltä. Sen oma virtuaalilevy on käytettävissä polussa `~/.windows`.

Nuo tutut kotipolut pysyvät omilla tiedostojärjestelmillään. Ne voivat olla myös symlinkkejä omistamiisi hakemistoihin, mikä on hyödyllistä, kun virtuaalilevy sijaitsee suuremmalla asemalla. Asennusohjelma mittaa vapaan tilan tiedostojärjestelmältä, joka todella sisältää polun `~/.windows`, ei välttämättä tiedostojärjestelmältä, joka sisältää kotihakemistosi.

Pidä levy- ja jaetut polut erillisinä, päällekkäin menemättöminä hakemistoina. Poisto tyhjentää tarkoituksella levyhakemiston, mutta säilyttää jaetun hakemiston. Välittömästi ennen poistoa Omarchy suorittaa aikarajatun erillisyystarkistuksen ja kieltäytyy poistamasta mitään, jos tarkistus aikakatkaistaan tai se ei pysty todistamaan, että kaksi puuta ovat erillisiä.

Ennen VM:n käynnistymistä Omarchy avaa ja kiinnittää nuo kaksi hakemistoa ja liittää sitten bind-mountilla tarkat hakemistojen inode:t yksityisiin käyttäjäkohtaisiin ankkureihin polun `/var/lib/omarchy/windows/mounts` alle. Docker näkee vain nuo root-suojatut ankkurit. Tämä säilyttää mukautetut levysijainnit ja estää samalla toista sinun tunnuksellasi ajettavaa prosessia vaihtamasta tarkistettua polkua, ennen kuin etuoikeutettu kontti käyttää sitä. Olemassa olevat levy- ja jaetut hakemistot kiristetään migraation aikana tilaan `0700`, jotta muut paikalliset tilit eivät voi selata niiden sisältöä.

VM:n portit on sidottu vain localhostiin, joten mikään verkossasi ei pääse Windows-koneeseen. Verkkokonsoli vaatii myös määritetyn Windows-käyttäjänimen ja -salasanan, mikä estää toista paikallista tiliä ohjaamasta VM:ää portin 8006 kautta.

## Rajoitukset ja lisensointi

Tässä kokoonpanossa ei ole GPU:n läpivientiä, joten se ei sovellu pelaamiseen tai videoeditointiin. Se on erinomainen tapa ajaa Microsoft Officea tai mitä tahansa muuta, joka sinun on aivan pakko saada.

Asennettava versio on Windows 11 Pro, aktivoimaton. Tarvitset oman lisenssiavaimen rajoitettujen ominaisuuksien käyttöön.

Jos tämä tietokone toimitettiin Windowsilla, OEM-avain on edelleen firmwareessa myös Omarchyn asentamisen jälkeen. Tulosta se komennolla `omarchy windows key`. Kyseinen avain on sidottu tähän koneeseen — se aktivoi tälle laitteistolle uudelleen asennetun Windowsin, mutta yleensä se ei aktivoi VM:ää.

Voit muuttaa resurssien jakoa myöhemmin ajamalla terminaalissa komennon `omarchy windows vm install`, joka kirjoittaa VM:n määrityksen uudelleen vastaustesi perusteella. Itse compose-tiedosto sijaitsee nyt polussa `/var/lib/omarchy/windows/docker-compose.yml` ja sen omistaa root — tämä on tarkoituksellista, jotta sinun tunnuksellasi ajettava prosessi ei voi kirjoittaa sitä uudelleen ja saada etuoikeutettua käynnistystä liittämään koko levyäsi konttiin. Jos sinun täytyy muokata sitä käsin (esimerkiksi USB-laitteen liittämiseksi), muokkaa sitä `sudo`lla ja katso kaikki vaihtoehdot [Dockur Windows -projektista](https://github.com/dockur/windows).

Päästäksesi eroon koko jutusta käytä Omarchy-valikosta kohtaa _Poista > Windows_. Se poistaa VM:n levyn polussa `~/.windows` ja kaiken Windowsin sisälle asennetun, joten kopioi kaikki tarvitsemasi pois VM:stä ensin. Jaettu `~/Windows`-kansiosi jätetään rauhaan.
