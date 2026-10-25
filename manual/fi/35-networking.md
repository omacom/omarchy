# Verkko

Omarchyssa verkkoyhteydet hoitaa NetworkManager, ja sitä käytät [yläpalkin](05-the-top-bar.md) verkkokuvakkeesta tai näppäinyhdistelmällä `Super + Ctrl + N`.

Paneeli etsii Wi-Fi-verkkoja, näyttää signaalin voimakkuuden ja muodostaa yhteyden. Ethernet ei tarvitse mitään — kytke kaapeli ja se toimii. Jos pysyt mieluummin terminaalissa, `nmtui` tarjoaa samat säädöt, ja käytössä on myös `omarchy network` -komentoryhmä.

## Wi-Fin jakaminen

Sen sijaan että lukisit pitkän salasanan ääneen, avaa _Määritys > Verkko > QR-koodi_ ollessasi Wi-Fi-verkossa. Näytölle tulee QR-koodi, jonka mikä tahansa puhelimen kamera voi skannata liittyäkseen verkkoon. Se on yksi niistä asioista, joita käytät odotettua enemmän, kun tiedät sen olevan siellä.

Jos tarvitset itse salasanan, `omarchy network password <interface>` tulostaa sen.

## DNS

Omarchy käyttää sitä DNS-palvelua, jonka verkkosi jakaa DHCP:n kautta. Voit ohittaa sen koko koneelle kohdassa _Määritys > Verkko > DNS_, jossa Cloudflare ja Google ovat yhden napsautuksen päässä. Valitse _Mukautettu_ kirjoittaaksesi omat palvelimesi.

Terminaalista `omarchy dns` tulostaa nykyisen palveluntarjoajan ja `omarchy dns Cloudflare` asettaa sellaisen.

## Wi-Fi-taajuusalueen kiinnittäminen

Jos reitittimesi laittaa 2.4GHz, 5GHz ja 6GHz samaan verkon nimeen, kannettavasi roikkuu joskus hitaassa vaihtoehdossa. `omarchy network band` näyttää, millä taajuusalueella olet, ja `omarchy network band 5` kiinnittää sen. Käytä `auto`-vaihtoehtoa antaaksesi sen valita uudelleen.

Tämä kiinnittää taajuusalueen tietyn tukiaseman sijaan, joten jatkat normaalia siirtymistä tukiasemien välillä.

## Kuinka nopea se on?

_Laukaisin > Nopeustesti > Verkon nopeustesti_ mittaa todellisen lataus- ja lähetysnopeutesi kahdella mittarilla. Terminaalista se on `omarchy network speedtest down` tai `up`. (Valikossa sen vieressä on levyn nopeustesti, jos mittaat toista pullonkaulaa.)

## Palomuuri

Palomuuri on oletuksena käytössä ja estää kaiken saapuvan liikenteen yhdellä poikkeuksella: portti 53317, jotta [LocalSend](22-guis.md) toimii heti käytössä.

SSH on pois päältä, kunnes otat sen käyttöön kohdassa _Määritys > Tietoturva > SSHD_, mikä käynnistää taustapalvelun, avaa portin 22 nopeusrajoitettuna raakaa voimaa käyttäviä hyökkäyksiä vastaan ja valtuuttaa avaimen. Docker on myös lukittu, joten säiliöt eivät voi vahingossa paljastaa itseään maailmalle. Katso koko tarina kohdasta [tietoturva](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) on mesh-VPN, joka tekee kaikkien tietokoneidesi ja palvelimiesi tavoittamisesta internetin kautta yksinkertaista ja turvallista. Asenna se kohdasta _Asenna > Palvelu > Tailscale_.

Saat palkkiin Tailscale-paneelin, joka yhdistää ja katkaisee yhteyden tailnetiin, vaihtaa tilejä ja valitsee poistumissolmun — omat koneesi ja Mullvad-alueet näkyvät molemmat luettelossa. Se myös selaa koneitasi, ja siellä Taildrop asuu: valitse kone ja paina `s` lähettääksesi sille tiedostoja tai `c`, `n` ja `d` kopioidaksesi sen IP-osoitteen, nimen tai täyden DNS-nimen. Terminaalin vastine on `omarchy tailscale send <machine> [file...]`, ja sinulle lähetetyt tiedostot saapuvat automaattisesti kansioon `~/Downloads`. Saapumisesta ilmoittava ilmoitus odottaa, kunnes napsautat sen auki tai hylkäät sen, joten tiedosto, joka ilmestyy ollessasi poissa koneelta, on edelleen vastattavissa palatessasi.

Sen asentaminen lisää myös verkkosovelluksen Tailscale-hallintakonsolille.

## Kun se lakkaa toimimasta

Ennen uudelleenkäynnistystä kokeile käynnistää viallinen osa uudelleen yksinään. Kohdassa _Päivitä > Laitteisto_ ovat Wi-Fi, Bluetooth, Audio ja Trackpad, ja yhden niistä uudelleenlataaminen selvittää useimmat ”se toimi viisi minuuttia sitten” -tilanteet. Katso [vianmääritys](45-troubleshooting.md).
