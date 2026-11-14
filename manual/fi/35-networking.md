# Verkkoyhteydet

Verkkoyhteyksiä hallitsee Omarchyssa NetworkManager, ja ohjaat sitä [yläpalkin](05-the-top-bar.md) verkkokuvakkeesta tai näppäinyhdistelmällä `Super + Ctrl + N`.

Paneeli etsii Wi-Fi-verkkoja, näyttää signaalin voimakkuuden ja muodostaa yhteyden. Ethernet ei tarvitse mitään — kytke se vain kiinni ja se toimii. Jos pysyt mieluummin terminaalissa, `nmtui` tarjoaa samat säätimet, ja käytettävissä on myös `omarchy network` -komentoryhmä.

## Wi-Fi-yhteytesi jakaminen

Sen sijaan, että lukisit pitkän salasanan ääneen, avaa _Setup > Network > QR Code_, kun olet Wi-Fi-verkossa. Näytölle ilmestyy QR-koodi, jonka mikä tahansa puhelimen kamera voi skannata verkkoon liittymistä varten. Se on yksi niistä asioista, joita käytät enemmän kuin odottaisit, kun tiedät sen olevan olemassa.

Jos tarvitset itse salasanan, `omarchy network password <interface>` tulostaa sen.

## DNS

Omarchy käyttää sitä DNS:ää, jonka verkkosi antaa DHCP:n kautta. Voit ohittaa sen koko koneelle kohdassa _Setup > Network > DNS_, jossa Cloudflare ja Google ovat yhden napsautuksen päässä. Valitse _Custom_ kirjoittaaksesi omat palvelimesi.

Terminaalissa `omarchy dns` tulostaa nykyisen tarjoajan ja `omarchy dns Cloudflare` asettaa sellaisen.

## Wi-Fi-kaistan lukitseminen

Jos reitittimesi sijoittaa 2.4GHz, 5GHz ja 6GHz samaan verkonnimeen, kannettavasi takertuu joskus hitaaseen kaistaan. `omarchy network band` näyttää, millä kaistalla olet, ja `omarchy network band 5` lukitsee sen. Käytä `auto`-asetusta antaaksesi sen valita uudelleen.

Tämä lukitsee kaistan eikä tiettyä tukiasemaa, joten liikut AP:iden välillä normaalisti.

## Kuinka nopea se on?

_Trigger > Speed Test > Network Speed Test_ mittaa todellisen lataus- ja lähetysnopeutesi kahdella mittarilla. Terminaalista se on `omarchy network speedtest down` tai `up`. Se mittaa Omarchyn omaa palvelua vasten ja laskee vain sen testisiirrot. Muut lataukset voivat kilpailla kaistanleveydestä, mutta niitä ei lisätä nopeustestin tulokseen. (Valikossa on sen vieressä levyn nopeustesti, jos mittaat toista pullonkaulaa.)

## Palomuuri

Palomuuri on oletuksena päällä ja estää kaiken saapuvan liikenteen yhtä poikkeusta lukuun ottamatta: portti 53317, jotta [LocalSend](22-guis.md) toimii suoraan. 

SSH on pois päältä, kunnes otat sen käyttöön kohdassa _Setup > Security > SSHD_, joka käynnistää daemonin, avaa portin 22 nopeusrajoitettuna raakaa voimaa vastaan ja valtuuttaa avaimen. Myös Docker on lukittu, joten kontit eivät vahingossa paljastu maailmalle. Katso koko tarina kohdasta [security](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) on mesh-VPN, joka tekee kaikkien tietokoneidesi ja palvelimiesi tavoittamisesta internetin kautta yksinkertaista ja turvallista. Asenna se kohdasta _Install > Service > Tailscale_.

Saat palkkiin Tailscale-paneelin, joka yhdistää ja katkaisee tailnet-yhteyden, vaihtaa tilejä ja valitsee exit node -solmun — sekä omat koneesi että Mullvad-alueet näkyvät luettelossa. Se selaa myös koneitasi, ja siellä Taildrop on: valitse kone ja paina `s` lähettääksesi sille tiedostoja, tai `c`, `n` ja `d` kopioidaksesi sen IP:n, nimen tai täyden DNS-nimen. Terminaalivastine on `omarchy tailscale send <machine> [file...]`, ja sinulle lähetetyt tiedostot päätyvät automaattisesti kansioon `~/Downloads`. Saapumisesta ilmoittava ilmoitus odottaa, kunnes napsautat sen auki tai hylkäät sen, joten tiedosto, joka saapuu ollessasi poissa koneelta, on edelleen vastattavana palatessasi.

Sen asentaminen lisää myös verkkosovelluksen Tailscale-hallintakonsolille.

## Kun se lakkaa toimimasta

Ennen uudelleenkäynnistystä kokeile käynnistää viallinen osa uudelleen yksinään. Kohdassa _Update > Hardware_ on Wi-Fi, Bluetooth, Audio ja Trackpad, ja yhden niistä uudelleenlataaminen selvittää useimmat "se toimi viisi minuuttia sitten" -tilanteet. Katso [troubleshooting](45-troubleshooting.md).
