# Ilmoitukset

Ilmoitukset saapuvat kohdistetun näytön oikeaan yläkulmaan. Pikanäppäinilmoituksilla pääset myös nopeasti käsiksi päivämäärään ja kellonaikaan, akun tilaan ja nykyiseen säähän.

## Ilmoitukset

Saman sovelluksen tai sivuston ilmoitukset pinoutuvat pakaksi, joten vilkas Slack-kanava ei työnnä koontiversiosi virhettä pois näytöltä. Vie osoitin pakan päälle levittääksesi sen; mitään uutta ei liu'u osoittimesi alle, kun luet. Napsauta korttia siirtyäksesi paikkaan, josta se tuli, ja hylkää se napsauttamalla oikealla tai keskimmäisellä painikkeella tai painamalla ✕.

Kortit tarjoavat sen, mitä ne kantavat: _Kopioi koodi_ vahvistuskoodeille (pidetään poissa [leikepöydän historiasta](08-unified-clipboard-history.md) ja tyhjennetään minuutin kuluttua) sekä kaikki painikkeet, jotka sovellus tarjoaa. Ilmoituksen tekstissä olevat linkit avautuvat, kun niitä napsautetaan.

Kun haluat käyttää niitä ilman hiirtä, paina `Super + Ctrl + ,`. Uusin ilmoitus on valittuna ja sen painikkeet numeroituna: käytä painiketta painamalla sen numeroa, napsauta ilmoitusta painamalla `Enter`, siirry ilmoitusten välillä painikkeilla `↑` ja `↓`, hylkää ilmoitus painamalla `Delete` ja palauta näppäimistö painamalla `Esc`. Se päästää myös itse irti muutaman käyttämättömän sekunnin jälkeen.

Ilmoitusten hiljentäminen pitää ne poissa näkyvistä, lukuun ottamatta Omarchyn omia vahvistuksia, hätävaroituksia ja vahvistuskoodeja, joita pyysit hetki sitten. Tuo viimeisimmät takaisin näytölle, olivatpa ne pidätettyinä tai eivät, painamalla `Super + Shift + Alt + ,`. Historiaa säilytetään vuorokauden ajan.

## Pikanäppäinilmoitukset

### Päivämäärä ja kellonaika

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Sää

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Sijainti tunnistetaan IP-osoitteesi perusteella, mikä on yleensä riittävän lähellä, mutta ei aina. Voit tarkentaa sen komennolla `omarchy weather location --set Malibu` tai olla täsmällinen lisäämällä koordinaatit: `omarchy weather location --set Malibu 34.0259,-118.7798`. Suorita `omarchy weather location` sellaisenaan nähdäksesi, missä se luulee sinun olevan, ja `--clear` palataksesi automaattiseen tunnistukseen.

### Akku

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
