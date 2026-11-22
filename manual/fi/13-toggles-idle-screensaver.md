# Kytkimet, joutokäynti ja näytönsäästäjä

Suuri osa siitä, mitä muutat päivästä toiseen, ei oikeastaan ole asetus. Se on tila, jonka kytket päälle tunniksi ja sitten taas pois: yövalo, kun työskentelet myöhään, älä häiritse, kun pidät esitystä, pysy hereillä, kun katsot jotain. Omarchy kutsuu niitä kytkimiksi, ja ne kaikki toimivat samalla tavalla — pikanäppäin, valikon kohta ja komento, kaikki samaan kytkimeen osuen.

### Kytkinvalikko

`Super + Ctrl + O` avaa suoraan _Trigger > Toggle_ -valikon, tai sinne pääsee Omarchy-valikon kautta (`Super + Space`). Kaikki siinä luettelossa on kytkimiä, joita voit napsauttaa miettimättä, missä tila sijaitsee. Työpöydän ulkoasua koskevat kytkimet ovat sen vieressä, _Appearance_-kohdassa.

Päätteestä samat kytkimet ovat `omarchy toggle <thing>`. Näet koko ryhmän ajamalla pelkän `omarchy toggle`.

| Kytkin | Pikanäppäin | Komento |
| ------ | ------ | ------- |
| Yövalo | — | `omarchy toggle nightlight` |
| Hiljennä ilmoitukset | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Pysy hereillä (ei joutokäyntilukitusta) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Kaatumisten tallennus | — | `omarchy toggle crash-capture` |
| Näytönsäästäjä | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) -teeman synkronointi | — | `omarchy toggle theme sync` |
| Valikkopalkki | `Super + Shift + Space` | `omarchy toggle bar` |
| Koko näytön työpöytä (ei palkkia, ei välejä) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animaatiot, sumennus ja varjot | — | `omarchy toggle animations` |
| Kosketuslevy | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Kosketusnäyttö | — | `omarchy device touchscreen` |
| Keskeytystila | — | `omarchy toggle suspend` |
| Hybridi-GPU | — | `omarchy device gpu hybrid` |

Kosketuslevyn, kosketusnäytön ja hybridi-GPU:n kytkimet ovat _Trigger > Hardware_ -kohdassa (`Super + Ctrl + H`) Toggle-kohdan sijaan, koska ne näkyvät vain, kun sinulla todella on kyseinen laitteisto. Kosketuslevyn ja kosketusnäytön kytkimet säilyvät Hyprlandin uudelleenlatauksen yli — käytöstä poistetun laitteen nimi tallennetaan pieneen tilatiedostoon, jonka Hyprland lukee käynnistyksessä poistaakseen sen uudelleen käytöstä.

_Appearance_ sisältää valikkopalkin ja animaatiot sekä muutaman asian, jotka eivät ole `omarchy toggle` -komentoja mutta käyttäytyvät samalla tavalla: akun prosenttiosuuden palkissa, työtilojen oletusasettelun sekä _Windows_-kohdassa ikkunoiden välit (`Super + Shift + Backspace`) ja yhden ikkunan neliökuvasuhteen (`Super + Ctrl + Backspace`).

Kun Hyprlandilla ei ole GPU:ta piirtämiseen ja se renderöi sen sijaan CPU:lla (llvmpipe), kuten Maceissa, joiden GPU:ta ei vielä tueta, useimmissa virtuaalikoneissa tai kun grafiikka-ajurin lataus epäonnistuu, Omarchy kytkee animaatiot, sumennuksen ja varjot pois päältä kyseiseksi istunnoksi ja kertoo siitä kerran ilmoituksella. _Appearance > Animations On_ tuo ne takaisin, ja Omarchy muistaa sen myös myöhempiä istuntoja varten.

Useimmat näistä ovat vain lipp tiedosto hakemistossa `~/.local/state/omarchy/toggles/`. Jos haluat haarautua jonkin perusteella skriptissä, `omarchy-toggle-enabled` antaa sinulle poistumiskoodin sen sijaan, että joutuisit etsimään sitä itse:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Liput on nimetty pois päältä -tilan mukaan — `screensaver-off`, `suspend-off`, `bar-off` — joten niiden läsnäolo tarkoittaa, että ominaisuus on poistettu käytöstä.

### Ilmaisimet palkissa

Kun tila on päällä, saat pienen kuvakkeen yläpalkin keskelle kellon viereen. Se on ilmaisimet-widget, ja se sisältää näytön tallennuksen, odottavat muistutukset, yövalon, älä häiritse -tilan ja hereillä pysymisen sekä varoitukset, kun salasanaton sudo on päällä tai joku on yhdistetty etäistuntoon.

Ei-aktiiviset ilmaisimet ovat piilossa. Vie osoitin minne tahansa palkin päälle, niin ne häivytetään näkyviin himmennettyinä, joten voit napsauttaa yhtä kytkeäksesi sen päälle tuntematta sen pikanäppäintä. Aktiivisen napsauttaminen kytkee sen takaisin pois. Jos haluat mieluummin nähdä ne kaikki koko ajan, aseta `alwaysShow` arvoon `true` kohdassa `omarchy.indicators` tiedostossa `~/.config/omarchy/shell.json` — katso [yläpalkki](05-the-top-bar.md), miten palkin widgetit määritetään.

### Yövalo

Yövalo lämmittää näytön 4000K:hon, ja sen kytkeminen uudelleen palauttaa sen 6500K:hon. Napsauta sitä kytkinvalikosta (`Super + Ctrl + O`) tai komennolla `omarchy toggle nightlight`. Sitä ohjaa hyprsunset, jonka kytkin käynnistää puolestasi, jos se ei ole jo käynnissä.

Oletuksena hyprsunset ei tee näytöllesi yhtään mitään. `~/.config/hypr/hyprsunset.conf` toimitetaan identity-profiililla juuri siksi, että näyttö pysyy koskemattomana, kunnes pyydät lämpöä. Jos haluat mieluummin sen vaihtuvan kellon mukaan, korvaa se aikaprofiililla:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Käynnistä sitten hyprsunset kirjautumisen yhteydessä lisäämällä `o.launch_on_start("hyprsunset")` tiedostoon `~/.config/hypr/autostart.lua`. Kytkimen käyttämä 4000K/6500K-pari on kiinteä, joten asetustiedosto on paikka, jonne menet, jos haluat eri lämpötilan.

### Älä häiritse

`Super + Ctrl + Alt + ,` hiljentää ilmoitukset. Kun se on päällä, ponnahdusilmoituksia ei ilmesty, ja yliviivattu kelloilmaisin istuu palkissa muistuttamassa, miksi työpöytä on hiljentynyt.

Mitään ei kuitenkaan menetetä. Hiljennetyt ilmoitukset pidetään tallessa: saat viimeisimmät takaisin näytölle komennolla `Super + Shift + Alt + ,`. Katso loput kohdasta [ilmoitukset](10-notices.md).

Kolmenlaiset viestit pääsevät silti läpi: Omarchyn omat vahvistusilmoitukset jostain, jonka juuri teit ("Theme changed", "Screenshot saved"), komentoriviltä lähetetyt kriittiset hälytykset ja vahvistuskoodit. Keskustelusovellukset, jotka merkitsevät kaiken kriittiseksi pakottaakseen itsensä eteesi, eivät kelpaa.

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

Molemmat luvut ovat sekunteja laskettuna siitä hetkestä, kun siirryit joutokäynnille — eivät toisistaan. Oletuksilla näytönsäästäjä tulee siis esiin kahden ja puolen minuutin kuluttua ja lukitusnäyttö ottaa vallan viiden minuutin kohdalla riippumatta siitä, käynnistyikö näytönsäästäjä. Tallenna tiedosto, niin kuori ottaa uudet ajoitukset käyttöön heti.

Jos hylkäät näytönsäästäjän ennen lukituksen määräaikaa, se lasketaan toiminnaksi ja odottava lukitus peruutetaan. Et jää lukituksi ulos siitä, että vilkaisit konettasi.

Jos haluat lopettaa joutokäyntilukituksen kokonaan, `Super + Ctrl + I` — tai `omarchy toggle idle` — kytkee hereillä pysymisen päälle, ja kahvikupin ilmaisin ilmestyy palkkiin. Se on se, jota kannattaa painaa ennen pitkää esitystä tai koontia, jota haluat seurata. Paina sitä uudelleen palataksesi normaaliin. `omarchy toggle idle status` tulostaa nykyisen tilan JSON-muodossa, jos tarvitset sitä skriptistä.

Tässä on kyse lukituksesta ja näytönsäästäjästä, ei virrasta. Keskeytystilalla ja horrostilalla on omat asetuksensa kohdassa [järjestelmän lepotila](36-system-sleep.md).

### Näytönsäästäjä

Omarchyn näytönsäästäjä on ASCII-taidetta, joka kulkee satunnaisten tekstitehosteiden läpi, yksi esiintymä näyttöä kohti. Mikä tahansa näppäin tai hiiren liike poistuu siitä.

Voit käynnistää sen tarvittaessa kohdasta _System > Screensaver_ (`Super + Esc`), mikä pakottaa sen esiin, vaikka olisit kytkenyt joutokäynnin näytönsäästäjän pois päältä. Sille ei ole oletuksena sidottu pikanäppäintä.

`omarchy toggle screensaver` kytkee joutokäynnin näytönsäästäjän pois päältä, jos haluat mieluummin siirtyä suoraan työskentelystä lukittuun tilaan. Mikä tahansa näppäin, napsautus, vieritys tai hiiren liike sulkee sen.

Sen piirtämä logo on sinun muutettavissasi kohdassa _Appearance > Branding > Screensaver_. Lataa png tai svg, niin Omarchy muuntaa sen ASCII:ksi. Katso [brändäys](41-branding.md).

### Lukitusnäyttö

`Super + Ctrl + L` lukitsee koneen. Se käynnistää Omarchy-kuoren lukitusnäytön, sammuttaa näytön, palauttaa näppäimistöasettelusi ensimmäiseen, jotta et kirjoita salasanaasi väärillä aakkosilla, ja — jos se on käynnissä — lukitsee 1Passwordin poistuessaan.

Lukitusnäyttö hyväksyy salasanan, ja se hyväksyy myös sormenjäljen, kun olet ottanut sellaisen käyttöön. Se ja muut todentamistavat käsitellään kohdassa [laitteistotodennus](37-hardware-authentication.md).
