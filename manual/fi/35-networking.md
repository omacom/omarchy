# Verkko

Omarchyn verkkoa hallinnoi NetworkManager, ja käytät sitä [yläpalkin](05-the-top-bar.md) verkkokuvakkeesta tai näppäinyhdistelmällä `Super + Ctrl + W`.

Paneeli etsii Wi-Fi-verkot, näyttää signaalin voimakkuuden ja yhdistää. Ethernet ei vaadi mitään — kytke kaapeli, ja se toimii. Jos pysyt mieluummin terminaalissa, `nmtui` tarjoaa samat säädöt, ja tarjolla on myös `omarchy network` -komentoryhmä.

## Wi-Fin jakaminen

Sen sijaan, että lukisit pitkän salasanan ääneen, valitse _Asetukset > Verkko > QR-koodi_, kun olet Wi-Fi-verkossa. Ruudulle ilmestyy QR-koodi, jonka mikä tahansa puhelimen kamera voi skannata liittyäkseen. Se on yksi niistä asioista, joita käytät useammin kuin kuvittelisit, kun tiedät sen olevan olemassa.

Jos tarvitset itse salasanan, `omarchy network password <interface>` tulostaa sen.

## DNS

Omarchy käyttää verkosi DHCP:n kautta jakamaa DNS:ää. Voit ohittaa sen koko koneella kohdassa _Asetukset > Verkko > DNS_, jossa Cloudflare ja Google ovat yhden napsautuksen päässä. Valitse _Mukautettu_, jos haluat kirjoittaa omat palvelimesi.

Terminaalissa `omarchy dns` tulostaa nykyisen palveluntarjoajan ja `omarchy dns Cloudflare` asettaa sen.

## Wi-Fi-kaistan kiinnittäminen

Jos reitittimesi laittaa 2,4 GHz, 5 GHz ja 6 GHz samalle verkkonimelle, kannettavasi saattaa toisinaan roikkua hitaassa kaistassa. `omarchy network band` näyttää, millä kaistalla olet, ja `omarchy network band 5` kiinnittää sen. Palauta automaattivalinta arvolla `auto`.

Tämä kiinnittää kaistan, ei tiettyä tukiasemaa, joten vaellat tukiasemien välillä normaalisti.

## Kuinka nopea se on?

_Käynnistä > Nopeustesti > Verkon nopeustesti_ mittaa todellisen lähetys- ja latausnopeutesi kahdella mittarilla. Terminaalissa se on `omarchy network speedtest down` tai `up`. (Samassa valikossa vieressä on myös levyn nopeustesti, jos testaat toista pullonkaulaa.)

## Palomuuri

Palomuuri on oletuksena päällä ja estää kaiken saapuvan liikenteen yhtä poikkeusta lukuun ottamatta: porttia 53317, jotta [LocalSend](22-guis.md) toimii heti.

SSH on pois päältä, kunnes otat sen käyttöön kohdassa _Asetukset > Turvallisuus > SSHD_, mikä käynnistää demoniin, avaa portin 22 väsytyshyökkäyksiä vastaan rajoitettuna ja valtuuttaa avaimen. Myös Docker on lukittu, joten kontit eivät voi vahingossa paljastaa itseään maailmalle. Katso koko tarina kohdasta [turvallisuus](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) on mesh-VPN, joka tekee kaikkien tietokoneidesi ja palvelimiesi tavoittamisen internetin yli yksinkertaista ja turvallista. Asenna se kohdasta _Asenna > Palvelu > Tailscale_.

Saat palkkiin Tailscale-paneelin, joka yhdistää ja katkaisee tailnet-yhteyden, vaihtaa tilin ja valitsee poistumissolmun — omat koneesi ja Mullvad-alueet näkyvät molemmat listassa. Se myös selaa koneitasi, ja siellä Taildrop asuu: valitse kone ja paina `s` lähettääksesi sille tiedostoja tai `c`, `n` ja `d` kopioidaksesi sen IP-osoitteen, nimen tai koko DNS-nimen. Terminaalivaste on `omarchy tailscale send <machine> [file...]`, ja sinulle lähetetyt tiedostot päätyvät automaattisesti kansioon `~/Downloads`. Ilmoitus saapumisesta odottaa, kunnes napsautat sen auki tai hylkäät sen, joten tiedosto, joka saapuu poissa ollessasi, on yhä vastattavissa palatessasi.

Asennus lisää myös verkkosovelluksen Tailscalen hallintakonsoliin.

## Kun se lakkaa toimimasta

Ennen uudelleenkäynnistystä yritä käynnistää syyllinen osa uudelleen yksinään. Kohdassa _Päivitä > Laitteisto_ ovat Wi-Fi, Bluetooth, Audio ja Trackpad, ja yhden niistä uudelleenlataaminen selvittää useimmat ”toimi viisi minuuttia sitten” -tilanteet. Katso [vianmääritys](45-troubleshooting.md).
