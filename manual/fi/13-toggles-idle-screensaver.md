# Vaihtokytkimet, joutilaana olo ja näytönsäästäjä

Paljon siitä, mitä muutat päivittäin, ei todella ole asetus. Se on tila, jonka kytket päälle tunniksi ja taas pois: yövalo, kun työskentelet myöhään, älä häiritse, kun esität, pysy hereillä, kun katsot jotain. Omarchy kutsuu niitä vaihtokytkimiksi, ja ne kaikki toimivat samalla tavalla — pikanäppäin, valikkomerkintä ja komento, kaikki osuvat samaan kytkimeen.

### Vaihtokytkinvalikko

`Super + Ctrl + O` avaa suoraan kohdan _Käynnistä > Vaihtokytkin_ tai voit kulkea sinne Omarchy-valikosta (`Super + Space`). Kaikki siinä listassa on kytkin, jonka voit kääntää ajattelematta, missä tila elää. Kytkimet työpöydän ulkoasulle ovat sen vieressä, kohdassa _Käynnistä > Ulkoasu_.

Pääätteestä samat kytkimet ovat `omarchy toggle <thing>`. Aja `omarchy toggle` sellaisenaan nähdäksesi koko ryhmän.

| Vaihtokytkin | Pikanäppäin | Komento |
| ------ | ------ | ------- |
| Yövalo | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Hiljennä ilmoitukset | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Pysy hereillä (ei joutilaisuuslukitusta) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Kaatumiskaappaus | — | `omarchy toggle crash-capture` |
| Näytönsäästäjä | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) teemasynkronointi | — | `omarchy toggle theme sync` |
| Valikkopalkki | `Super + Shift + Space` | `omarchy toggle bar` |
| Kosketuslevy | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Kosketusnäyttö | — | `omarchy toggle touchscreen` |
| Lepotila | — | `omarchy toggle suspend` |
| Hybridi-GPU | — | `omarchy toggle hybrid gpu` |

Kosketuslevyn, kosketusnäytön ja hybridi-GPU:n kytkimet elävät kohdassa _Käynnistä > Laitteisto_ (`Super + Ctrl + H`) eivätkä kohdassa Vaihtokytkin, koska ne näkyvät vain, kun sinulla todella on kyseinen laitteisto. Kosketuslevyn ja kosketusnäytön kytkimet selviytyvät Hyprlandin uudelleenlatauksesta — käytöstä poistetun laitteen nimi tallennetaan pieneen tilatiedostoon, jonka Hyprland lukee käynnistyksessä poistaakseen sen käytöstä uudelleen.

_Käynnistä > Ulkoasu_ sisältää valikkopalkin ja animaatiot sekä muutamia asioita, jotka eivät ole `omarchy toggle` -komentoja mutta käyttäytyvät samoin: akun prosentin palkissa, työtilan oletusasettelun, ikkunoiden välit (`Super + Shift + Backspace`) ja 1 ikkunan neliön näkökulman (`Super + Ctrl + Backspace`).

Useimmat näistä ovat vain lippputiedosto hakemistossa `~/.local/state/omarchy/toggles/`. Jos haluat haarautua yhden perusteella skriptissä, `omarchy-toggle-enabled` antaa sinulle poistumiskoodin sen sijaan, että menisit etsimään:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Liput on nimetty pois päältä -tilan mukaan — `screensaver-off`, `suspend-off`, `bar-off` — joten niiden läsnäolo tarkoittaa, että ominaisuus on pois käytöstä.

### Ilmaisimet palkissa

Kun tila on päällä, näet pienen merkin yläpalkin keskellä kellon vieressä. Se on ilmaisin-widget, ja se kantaa sanelua, ruuduntallennusta, odottavia muistutuksia, yövaloa, älä häiritse -tilaa ja pysy hereillä -tilaa.

Epäaktiiviset ilmaisimet ovat piilossa. Vie osoitin niiden alueen ylle, ja ne häipyvät esiin himmennettyinä, joten voit napsauttaa yhtä kytkeäksesi sen päälle tietämättä sen pikanäppäintä. Aktiivisen napsauttaminen kytkee sen takaisin pois. Jos mieluummin näet ne kaikki koko ajan, aseta `alwaysShow` arvoon `true` merkinnässä `omarchy.indicators` tiedostossa `~/.config/omarchy/shell.json` — katso [yläpalkki](05-the-top-bar.md), miten palkin widgetit määritetään.

### Yövalo

`Super + Ctrl + N` lämmittää ruudun 4000K:hon, ja sen painaminen uudelleen palauttaa sen 6500K:hon. Sitä ajaa hyprsunset, jonka vaihtokytkin käynnistää sinulle, jos se ei ole jo käynnissä.

Oletuksena hyprsunset ei tee ruudullesi mitään. Tiedostoon `~/.config/hypr/hyprsunset.conf` sisältyy identiteettiprofiili juuri siksi, että näyttö pysyisi koskemattomana, kunnes pyydät lämpöä. Jos mieluummin haluat sen vaihtuvan kellon mukaan, korvaa se aikaprofiililla:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Käynnistä sitten hyprsunset kirjautumisen yhteydessä lisäämällä `o.launch_on_start("hyprsunset")` tiedostoon `~/.config/hypr/autostart.lua`. Vaihtokytkimen käyttämä pari 4000K/6500K on kiinteä, joten määritystiedosto on paikka, jonne menet, jos haluat eri lämpötilan.

### Älä häiritse

`Super + Ctrl + ,` hiljentää ilmoitukset. Ponnahdusviestejä ei ilmesty sen ollessa päällä, ja yliviivattu kelloilmaisin istuu palkissa muistuttaakseen sinua, miksi työpöytä on hiljentynyt.

Mitään ei kuitenkaan menetetä. Hiljennetty ilmoitus kirjoitetaan suoraan ilmoitushistoriaasi, mikä on juuri se tallenne, jonka haluat, kun palaat ja ihmettelet, mitä missasit. Avaa se yhdistelmällä `Super + Shift + Alt + ,`. Katso [ilmoitukset](10-notices.md) ilmoitustarinan lopusta.

Kahdenlaiset viestit läpäisevät silti: Omarchyn omat vahvistusponnahdusviestit juuri tekemästäsi asiasta ("Teema vaihdettu", "Kuvakaappaus tallennettu") ja komentoriviltä lähetetyt kriittiset hälytykset. Keskustelusovellukset, jotka merkitsevät kaiken kriittiseksi pakottaakseen tiensä eteesi, eivät kelpaa.

### Joutilaana olo

Omarchyn kuori omistaa joutilaana olon käyttäytymisen, ja ajoitukset ovat ylätason `idle`-lohko tiedostossa `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Molemmat numerot ovat sekunteja, jotka lasketaan hetkestä, jolloin jäit joutilaaksi — ei toisistaan. Joten oletuksilla näytönsäästäjä tulee esiin kahden ja puolen minuutin kuluttua ja lukitusruutu ottaa vallan viiden minuutin kuluttua, riippumatta siitä, pyörikö näytönsäästäjä. Tallenna tiedosto, ja kuori poimii uudet ajoitukset heti.

Jos hylkäät näytönsäästäjän ennen lukituksen määräaikaa, se lasketaan aktiivisuudeksi ja odottava lukitus peruutetaan. Sinua ei lukita ulos siitä, että vilkaiset konettasi.

Pysäyttääksesi lukituksen joutilaana ollessa kokonaan, `Super + Ctrl + I` — tai `omarchy toggle idle` — kääntää pysy hereillä -tilan päälle, ja kahvikuppilmaisia ilmestyy palkkiin. Se on se, jota painat ennen pitkää esitystä tai rakennetta, jota haluat katsella. Paina sitä uudelleen palataksesi normaaliksi. `omarchy toggle idle status` tulostaa nykyisen tilan JSON-muodossa, jos tarvitset sitä skriptistä.

Tämä koskee lukittumista ja näytönsäästäjää, ei virtaa. Lepotilalla ja horrostilalla on oma kokoonpanonsa kohdassa [järjestelmän lepo](36-system-sleep.md).

### Näytönsäästäjä

Omarchyn näytönsäästäjä on ASCII-taidetta, joka kulkee satunnaisten tekstiefektien läpi, yksi instanssi näyttöä kohti. Mikä tahansa näppäin tai hiiren liike poistuu siitä.

Voit käynnistää sen pyynnöstä kohdasta _Järjestelmä > Näytönsäästäjä_ (`Super + Esc`), mikä pakottaa sen esiin, vaikka olisit kytkenyt joutilaan näytönsäästäjän pois päältä. Sille ei ole oletuksena sidottu pikanäppäintä.

`omarchy toggle screensaver` kytkee joutilaan näytönsäästäjän pois, jos mieluummin siirryt suoraan työskentelystä lukituksi. Se tarvitsee päätteen, jonka se osaa määrittää — Alacritty, Foot, Ghostty tai Kitty — ja kertoo niin, jos oletuspäätteesi on jokin muu.

Sen piirtämä logo on sinun vaihdettavissasi kohdassa _Tyyli > Näytönsäästäjä_. Lataa png- tai svg-tiedosto, ja Omarchy muuntaa sen ASCII:ksi. Katso [brändäys](41-branding.md).

### Lukitusruutu

`Super + Ctrl + L` lukitsee koneen. Se ajaa Omarchyn kuoren lukitusruudun, sammuttaa näytön, nollaa näppäimistöasettelusi ensimmäiseksi, jotta et kirjoita salasanaasi väärässä aakkostossa, ja — jos se on käynnissä — lukitsee 1Passwordin poistumisen yhteydessä.

Lukitusruutu ottaa salasanan, ja se ottaa myös sormenjäljen, kun olet asettanut sellaisen. Se ja muut todentamistavat käsitellään kohdassa [laitteistotodennus](37-hardware-authentication.md).
