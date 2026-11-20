# Kytkimet, joutokäynti & näytönsäästäjä

Moni asia, jota muutat päivittäin, ei oikeastaan ole asetus. Se on tila, jonka kytket päälle tunniksi ja sitten taas pois: yövalo, kun työskentelet myöhään, älä häiritse, kun esität, pysy hereillä, kun katsot jotain. Omarchy kutsuu niitä kytkimiksi, ja ne kaikki toimivat samalla tavalla — pikanäppäin, valikkokohta ja komento osuvat kaikki samaan kytkimeen.

### Kytkinvalikko

`Super + Ctrl + O` avaa suoraan kohdan _Trigger > Toggle_, tai sinne pääsee Omarchy-valikon kautta (`Super + Space`). Kaikki siinä luettelossa ovat kytkimiä, joita voit kääntää miettimättä, missä tila sijaitsee. Työpöydän ulkoasua koskevat kytkimet ovat sen vieressä, kohdassa _Appearance_.

Terminaalista samat kytkimet ovat `omarchy toggle <thing>`. Suorita pelkkä `omarchy toggle`, niin näet koko ryhmän.

| Kytkin | Pikanäppäin | Komento |
| ------ | ------ | ------- |
| Yövalo | — | `omarchy toggle nightlight` |
| Hiljennä ilmoitukset | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Pysy hereillä (ei joutokäyntilukitusta) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Kaatumisten tallennus | — | `omarchy toggle crash-capture` |
| Näytönsäästäjä | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev)-teeman synkronointi | — | `omarchy toggle theme sync` |
| Valikkopalkki | `Super + Shift + Space` | `omarchy toggle bar` |
| Kosketuslevy | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Kosketusnäyttö | — | `omarchy device touchscreen` |
| Valmiustila | — | `omarchy toggle suspend` |
| Hybridi-GPU | — | `omarchy toggle hybrid gpu` |

Kosketuslevyn, kosketusnäytön ja hybridi-GPU:n kytkimet ovat kohdassa _Trigger > Hardware_ (`Super + Ctrl + H`) eivätkä kohdassa Toggle, koska ne näkyvät vain, kun sinulla todella on kyseinen laitteisto. Kosketuslevyn ja kosketusnäytön kytkimet säilyvät Hyprlandin uudelleenlatauksen yli — käytöstä poistetun laitteen nimi tallennetaan pieneen tilatiedostoon, jonka Hyprland lukee käynnistyksessä poistaakseen sen uudelleen käytöstä.

_Appearance_ sisältää valikkopalkin ja animaatiot sekä muutaman asian, jotka eivät ole `omarchy toggle` -komentoja mutta käyttäytyvät samalla tavalla: akun prosenttiosuuden palkissa, työtilojen oletusasettelun ja kohdassa _Windows_ ikkunoiden välit (`Super + Shift + Backspace`) ja yhden ikkunan neliönmuotoisen kuvasuhteen (`Super + Ctrl + Backspace`).

Kun Hyprlandilla ei ole GPU:ta, jolla piirtää, ja se renderöi sen sijaan CPU:lla (llvmpipe), kuten Maceissa, joiden GPU:ta ei vielä tueta, useimmissa virtuaalikoneissa tai kun näytönohjaimen ajuri ei lataudu, Omarchy poistaa animaatiot, sumennuksen ja varjot käytöstä kyseiseksi istunnoksi ja kertoo siitä kerran ilmoituksella. _Appearance > Animations On_ palauttaa ne takaisin, ja Omarchy muistaa sen myös myöhempiä istuntoja varten.

Useimmat näistä ovat vain lipputiedosto hakemistossa `~/.local/state/omarchy/toggles/`. Jos haluat haarautua jonkin perusteella skriptissä, `omarchy-toggle-enabled` antaa sinulle poistumiskoodin sen sijaan, että joutuisit etsimään sitä itse:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Liput on nimetty pois päältä -tilan mukaan — `screensaver-off`, `suspend-off`, `bar-off` — joten niiden olemassaolo tarkoittaa, että ominaisuus on poistettu käytöstä.

### Ilmaisimet palkissa

Kun tila on päällä, saat pienen kuvakkeen yläpalkin keskelle kellon viereen. Se on ilmaisimet-widget, ja se sisältää sanelun, näytön tallennuksen, odottavat muistutukset, yövalon, älä häiritse -tilan ja pysy hereillä -tilan.

Epäaktiiviset ilmaisimet ovat piilossa. Vie hiiri mihin tahansa kohtaan palkkia, niin ne häivytetään näkyviin himmennettyinä, jotta voit napsauttaa yhtä ja kytkeä sen päälle tuntematta sen pikanäppäintä. Aktiivisen napsauttaminen kytkee sen takaisin pois päältä. Jos mieluummin näkisit ne kaikki koko ajan, aseta `alwaysShow` arvoon `true` kohdalle `omarchy.indicators` tiedostossa `~/.config/omarchy/shell.json` — katso, miten palkin widgetit määritetään, kohdasta [yläpalkki](05-the-top-bar.md).

### Yövalo

Yövalo lämmittää näytön arvoon 4000K, ja sen kytkeminen uudelleen palauttaa sen arvoon 6500K. Käännä se kytkinvalikosta (`Super + Ctrl + O`) tai komennolla `omarchy toggle nightlight`. Sitä ohjaa hyprsunset, jonka kytkin käynnistää puolestasi, jos se ei ole jo käynnissä.

Oletuksena hyprsunset ei tee näytöllesi yhtään mitään. `~/.config/hypr/hyprsunset.conf` toimitetaan identity-profiililla juuri siksi, että näyttö pysyy koskemattomana, kunnes pyydät lämpöä. Jos haluat mieluummin sen vaihtuvan kellon mukaan, korvaa se aikaprofiililla:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Käynnistä sitten hyprsunset kirjautumisen yhteydessä lisäämällä `o.launch_on_start("hyprsunset")` tiedostoon `~/.config/hypr/autostart.lua`. Kytkimen käyttämä pari 4000K/6500K on kiinteä, joten määritystiedosto on paikka, jonne menet, jos haluat eri lämpötilan.

### Älä häiritse

`Super + Ctrl + Alt + ,` hiljentää ilmoitukset. Kun se on päällä, mitään ilmoitusponnahduksia ei tule näkyviin, ja yliviivatun kellon ilmaisin istuu palkissa muistuttamassa, miksi työpöytä on käynyt hiljaiseksi.

Mitään ei kuitenkaan menetetä. Hiljennetyt ilmoitukset pidetään taka-alalla: tuo viimeisimmät muutamat takaisin näytölle näppäimillä `Super + Shift + Alt + ,`. Katso loput kohdasta [ilmoitukset](10-notices.md).

Kaksi viestityyppiä pääsee silti läpi: Omarchyn omat vahvistusilmoitukset jostain, jonka juuri teit ("Theme changed", "Screenshot saved"), ja komentoriviltä lähetetyt kriittiset hälytykset. Keskustelusovellukset, jotka merkitsevät kaiken kriittiseksi pakottaakseen tiensä eteesi, eivät kelpaa.

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

Molemmat luvut ovat sekunteja laskettuna siitä hetkestä, kun siirryit joutokäynnille — ei toisistaan. Joten oletuksilla näytönsäästäjä tulee esiin kahden ja puolen minuutin kuluttua ja lukitusnäyttö ottaa ohjat viiden minuutin kohdalla riippumatta siitä, käynnistyikö näytönsäästäjä. Tallenna tiedosto, niin kuori ottaa uudet ajoitukset käyttöön heti.

Jos hylkäät näytönsäästäjän ennen lukituksen määräaikaa, se lasketaan aktiivisuudeksi ja odottava lukitus peruutetaan. Et jää lukituksi ulos siitä, että vilkaisit konettasi.

Jos haluat lopettaa joutokäynnillä lukitsemisen kokonaan, `Super + Ctrl + I` — tai `omarchy toggle idle` — kytkee pysy hereillä -tilan päälle, ja kahvikupin ilmaisin ilmestyy palkkiin. Se on se, jota kannattaa painaa ennen pitkää esitystä tai buildia, jota haluat seurata. Paina sitä uudelleen palataksesi normaaliin. `omarchy toggle idle status` tulostaa nykyisen tilan JSON-muodossa, jos tarvitset sitä skriptistä.

Tämä koskee lukitsemista ja näytönsäästäjää, ei virtaa. Valmiustilalla ja horrostilalla on omat asetuksensa kohdassa [järjestelmän lepotila](36-system-sleep.md).

### Näytönsäästäjä

Omarchyn näytönsäästäjä on ASCII-taidetta, joka kulkee satunnaisten tekstitehosteiden läpi, yksi esiintymä näyttöä kohti. Mikä tahansa näppäin tai hiiren liike poistuu siitä.

Voit käynnistää sen tarvittaessa kohdasta _System > Screensaver_ (`Super + Esc`), mikä pakottaa sen esiin, vaikka olisit kytkenyt joutokäynnin näytönsäästäjän pois päältä. Sille ei ole oletuksena sidottu pikanäppäintä.

`omarchy toggle screensaver` on se, mikä kytkee joutokäynnin näytönsäästäjän pois päältä, jos menet mieluummin suoraan työskentelystä lukittuun tilaan. Mikä tahansa näppäin, napsautus, vieritys tai hiiren liike sulkee sen.

Sen piirtämä logo on sinun muutettavissasi kohdassa _Appearance > Branding > Screensaver_. Lataa png tai svg, niin Omarchy muuntaa sen ASCII-muotoon. Katso [brändäys](41-branding.md).

### Lukitusnäyttö

`Super + Ctrl + L` lukitsee koneen. Se käynnistää Omarchy-kuoren lukitusnäytön, sammuttaa näytön, palauttaa näppäimistöasettelusi ensimmäiseen, jotta et kirjoita salasanaasi väärillä aakkosilla, ja — jos se on käynnissä — lukitsee 1Passwordin poistuessaan.

Lukitusnäyttö ottaa salasanan, ja se ottaa myös sormenjäljen, kun olet määrittänyt sellaisen. Se ja muut todentamistavat käsitellään kohdassa [laitteistotodennus](37-hardware-authentication.md).
