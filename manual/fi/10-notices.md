# Ilmoitukset

Ilmoitukset saapuvat kohdistetun näytön oikeaan yläkulmaan. Pikanäppäinilmoituksilla pääset myös nopeasti käsiksi päivämäärään ja kellonaikaan, akun tilaan ja nykyiseen säähän.

## Ilmoitukset

Saman sovelluksen tai sivuston ilmoitukset pinoutuvat pakaksi, joten puhelias Slack-kanava ei työnnä koontivirhettäsi pois näytöltä. Vie osoitin pakan päälle levittääksesi sen auki; mikään uusi ei liu'u osoittimesi alle, kun olet lukemassa. Siirry ilmoituksen lähteeseen napsauttamalla korttia, ja hylkää se napsauttamalla hiiren oikealla painikkeella, keskimmäisellä painikkeella tai painamalla ✕.

Kortit tarjoavat sen, mitä ne kantavat: _Kopioi koodi_ vahvistuskoodeille (ne pidetään poissa [leikepöydän historiasta](08-unified-clipboard-history.md) ja tyhjennetään minuutin kuluttua) sekä kaikki sovelluksen tarjoamat painikkeet. Ilmoituksen tekstissä olevat linkit avautuvat napsautettaessa.

`Super + ,` hylkää uusimman ilmoituksen tai avaa sen kohteen, jos ilmoitus tarjoaa sellaisen, `Super + Alt + ,` hylkää vain viimeisimmän, `Super + Shift + ,` hylkää ne kaikki ja `Super + Shift + Alt + ,` avaa historian. Käytä niitä ilman hiirtä painamalla `Super + Ctrl + ,`. Uusin ilmoitus valitaan ja sen painikkeet numeroidaan: käytä painiketta painamalla sen numeroa, napsauta ilmoitusta painamalla `Enter`, siirry ilmoitusten välillä painamalla `↑` ja `↓`, hylkää ilmoitus painamalla `Delete` ja palauta näppäimistö painamalla `Esc`. Se päästää myös irti itsestään muutaman käyttämättömän sekunnin jälkeen.

Ilmoitusten vaimentaminen pidättää niitä, lukuun ottamatta Omarchyn omia vahvistuksia, hätähälytyksiä ja vahvistuskoodeja, joita pyysit hetki sitten. Tuo muutama viimeisin takaisin näytölle, pidätettyinä tai ei, näppäimillä `Super + Shift + Alt + ,`. Historia säilytetään vuorokauden ajan.

## Pikanäppäinilmoitukset

### Päivämäärä ja kellonaika

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Sää

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Sijainti tunnistetaan IP-osoitteesi perusteella, mikä on yleensä tarpeeksi lähellä, mutta ei aina. Voit tarkentaa sen komennolla `omarchy weather location --set Malibu` tai määrittää sen täsmällisesti lisäämällä koordinaatit: `omarchy weather location --set Malibu 34.0259,-118.7798`. Suorita `omarchy weather location` sellaisenaan nähdäksesi, missä se luulee sinun olevan, ja palaa automaattiseen tunnistukseen valinnalla `--clear`.

### Akku

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
