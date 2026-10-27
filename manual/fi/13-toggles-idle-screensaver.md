# Kytkimet, joutokäynti ja näytönsäästäjä

Suuri osa siitä, mitä muutat päivittäin, ei oikeastaan ole asetus. Se on tila, jonka kytket päälle tunniksi ja sitten taas pois: yövalo, kun työskentelet myöhään, älä häiritse, kun esität, ja pysy hereillä, kun katsot jotain. Omarchy kutsuu niitä kytkimiksi, ja ne kaikki toimivat samalla tavalla — pikanäppäin, valikon kohta ja komento osuvat kaikki samaan kytkimeen.

### Kytkinvalikko

`Super + Ctrl + O` avaa suoraan _Trigger > Toggle_, tai voit kulkea sinne Omarchy-valikon kautta (`Super + Space`). Kaikki siinä luettelossa olevat ovat kytkimiä, jotka voit kääntää miettimättä, missä tila sijaitsee. Työpöydän ulkoasua koskevat kytkimet ovat sen vieressä kohdassa _Appearance_.

Päätteestä samat kytkimet ovat `omarchy toggle <thing>`. Näet koko ryhmän ajamalla pelkän `omarchy toggle`.

| Kytkin | Pikanäppäin | Komento |
| ------ | ------ | ------- |
| Yövalo | — | `omarchy toggle nightlight` |
| Hiljennä ilmoitukset | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Pysy hereillä (ei joutokäyntilukitusta) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Kaatumistietojen keruu | — | `omarchy toggle crash-capture` |
| Näytönsäästäjä | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) -teeman synkronointi | — | `omarchy toggle theme sync` |
| Valikkopalkki | `Super + Shift + Space` | `omarchy toggle bar` |
| Kosketuslevy | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Kosketusnäyttö | — | `omarchy toggle touchscreen` |
| Lepotila | — | `omarchy toggle suspend` |
| Hybridi-GPU | — | `omarchy toggle hybrid gpu` |

Kosketuslevyn, kosketusnäytön ja hybridi-GPU:n kytkimet ovat kohdassa _Trigger > Hardware_ (`Super + Ctrl + H`) eivätkä kohdassa Toggle, koska ne näkyvät vain, kun sinulla todella on kyseinen laitteisto. Kosketuslevyn ja kosketusnäytön kytkimet säilyvät Hyprlandin uudelleenlatauksen yli — käytöstä poistetun laitteen nimi tallennetaan pieneen tilatiedostoon, jonka Hyprland lukee käynnistyksessä poistaakseen sen uudelleen käytöstä.

_Appearance_ sisältää valikkopalkin ja animaatiot sekä muutaman asian, jotka eivät ole `omarchy toggle` -komentoja mutta käyttäytyvät samalla tavalla: akun prosenttiosuuden palkissa, oletustyötilan asettelun sekä kohdassa _Windows_ ikkunoiden välit (`Super + Shift + Backspace`) ja yhden ikkunan neliönmuotoisen kuvasuhteen (`Super + Ctrl + Backspace`).

Useimmat näistä ovat vain lipputiedosto hakemistossa `~/.local/state/omarchy/toggles/`. Jos haluat haarautua jonkin perusteella skriptissä, `omarchy-toggle-enabled` antaa sinulle poistumiskoodin sen sijaan, että joutuisit etsimään sitä itse:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Liput on nimetty pois päältä -tilan mukaan — `screensaver-off`, `suspend-off`, `bar-off` — joten niiden läsnäolo tarkoittaa, että ominaisuus on poistettu käytöstä.

### Ilmaisimet palkissa

Kun tila on päällä, saat pienen kuvakkeen yläpalkin keskelle kellon viereen. Se on ilmaisimet-widget, ja se sisältää sanelun, näytön tallennuksen, odottavat muistutukset, yövalon, älä häiritse -tilan ja pysy hereillä -tilan.

Epäaktiiviset ilmaisimet ovat piilossa. Vie hiiri mihin tahansa palkin kohdalle, niin ne häivytetään näkyviin himmennettyinä, joten voit napsauttaa yhtä kytkeäksesi sen päälle tuntematta sen pikanäppäintä. Aktiivisen ilmaisimen napsauttaminen kytkee sen takaisin pois. Jos haluat mieluummin nähdä ne kaikki koko ajan, aseta `alwaysShow` arvoon `true` kohdalle `omarchy.indicators` tiedostossa `~/.config/omarchy/shell.json` — katso [yläpalkki](05-the-top-bar.md), miten palkin widgetit määritetään.

### Yövalo

Yövalo lämmittää näytön 4000K:hon, ja sen kytkeminen uudelleen palauttaa sen 6500K:hon. Käännä se kytkinvalikosta (`Super + Ctrl + O`) tai komennolla `omarchy toggle nightlight`. Sitä ohjaa hyprsunset, jonka kytkin käynnistää puolestasi, jos se ei ole jo käynnissä.

Oletuksena hyprsunset ei tee näytöllesi yhtään mitään. `~/.config/hypr/hyprsunset.conf` toimitetaan identiteettiprofiililla juuri siksi, että näyttö pysyy koskemattomana, kunnes pyydät lämpöä. Jos haluat mieluummin sen vaihtuvan kellon mukaan, korvaa se aikaprofiililla:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Käynnistä sitten hyprsunset kirjautumisen yhteydessä lisäämällä `o.launch_on_start("hyprsunset")` tiedostoon `~/.config/hypr/autostart.lua`. Kytkimen käyttämä 4000K/6500K-pari on kiinteä, joten asetustiedosto on paikka, johon menet, jos haluat eri lämpötilan.

### Älä häiritse

`Super + Ctrl + Alt + ,` hiljentää ilmoitukset. Kun se on päällä, ilmoitusponnahduksia ei ilmesty, ja yliviivattu kelloilmaisin istuu palkissa muistuttamassa, miksi työpöytä on hiljentynyt.

Mitään ei kuitenkaan menetetä. Hiljennetyt ilmoitukset pidetään takana: laita muutama viimeisin takaisin näytölle näppäimillä `Super + Shift + Alt + ,`. Katso loput kohdasta [ilmoitukset](10-notices.md).

Kahdenlaiset viestit pääsevät silti läpi: Omarchyn omat vahvistusponnahdukset jostakin, jonka juuri teit ("Theme changed", "Screenshot saved"), ja komentoriviltä lähetetyt kriittiset hälytykset. Keskustelusovellukset, jotka merkitsevät kaiken kriittiseksi pakottaakseen itsensä eteesi, eivät kelpaa.

### Joutokäynti

Omarchy-kuori omistaa joutokäyntikäyttäytymisen, ja ajoitukset ovat ylimmän tason `idle`-lohko tiedostossa `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Molemmat luvut ovat sekunteja, jotka lasketaan siitä hetkestä, kun siirryit joutokäynnille — ei toisistaan. Joten oletuksilla näytönsäästäjä tulee esiin kahden ja puolen minuutin kuluttua ja lukitusnäyttö ottaa vallan viiden minuutin kohdalla riippumatta siitä, käynnistyikö näytönsäästäjä vai ei. Tallenna tiedosto, niin kuori ottaa uudet ajoitukset käyttöön heti.

Jos hylkäät näytönsäästäjän ennen lukituksen määräaikaa, se lasketaan toiminnaksi ja odottava lukitus peruutetaan. Et jää lukituksi ulos siksi, että vilkaisit konettasi.

Jos haluat lopettaa joutokäyntilukituksen kokonaan, `Super + Ctrl + I` — tai `omarchy toggle idle` — kytkee pysy hereillä -tilan päälle, ja kahvikupin ilmaisin ilmestyy palkkiin. Se on se, jota painat ennen pitkää esitystä tai koontia, jota haluat seurata. Paina sitä uudelleen palataksesi normaaliin. `omarchy toggle idle status` tulostaa nykyisen tilan JSON-muodossa, jos tarvitset sitä skriptistä.

Tämä koskee lukitusta ja näytönsäästäjää, ei virtaa. Lepotilalla ja horrostilalla on oma määrityksensä kohdassa [järjestelmän lepotila](36-system-sleep.md).

### Näytönsäästäjä

Omarchyn näytönsäästäjä on ASCII-taidetta, joka kulkee satunnaisten tekstitehosteiden läpi, yksi ilmentymä näyttöä kohden. Mikä tahansa näppäin tai hiiren liike poistuu siitä.

Voit käynnistää sen tarvittaessa kohdasta _System > Screensaver_ (`Super + Esc`), mikä pakottaa sen esiin, vaikka olisit kytkenyt joutokäynnin näytönsäästäjän pois. Siihen ei ole oletuksena sidottu pikanäppäintä.

`omarchy toggle screensaver` kytkee joutokäynnin näytönsäästäjän pois, jos haluat mieluummin siirtyä suoraan työskentelystä lukittuun tilaan. Se tarvitsee päätteen, jonka se osaa määrittää — Alacritty, Foot, Ghostty tai Kitty — ja kertoo sinulle, jos oletuspäätteesi on jotain muuta.

Sen piirtämä logo on sinun muutettavissasi kohdassa _Appearance > Branding > Screensaver_. Lataa png tai svg, niin Omarchy muuntaa sen ASCII:ksi. Katso [brändäys](41-branding.md).

### Lukitusnäyttö

`Super + Ctrl + L` lukitsee koneen. Se ajaa Omarchy-kuoren lukitusnäytön, sammuttaa näytön, palauttaa näppäimistöasettelusi ensimmäiseen, jotta et kirjoita salasanaasi väärällä aakkostolla, ja — jos sinulla on se käynnissä — lukitsee 1Passwordin matkalla ulos.

Lukitusnäyttö hyväksyy salasanan, ja se hyväksyy myös sormenjäljen, kun olet määrittänyt sellaisen. Se ja muut todentamistavat käsitellään kohdassa [laitteistotodennus](37-hardware-authentication.md).
