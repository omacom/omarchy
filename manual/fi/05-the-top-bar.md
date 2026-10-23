# Yläpalkki

Ruudun yläreunassa kulkeva kaista on Omarchy-palkki. Se ei ole päälle pultattu tilapalkki, vaan osa Omarchyn kuorta, yhtä pitkään pyörivää Quickshell-prosessia, joka piirtää myös valikon, ilmoitukset, OSD-ilmaisinponnahdusikkunat ja lukitusruudun. Siksi se teemoitetaan täydellisesti kaiken muun kanssa ja siksi paneeli avautuu heti sen sijaan, että käynnistäisi uuden sovelluksen.

Se on myös ainoa työpöydän osa, joka on aina ruudulla, joten kannattaa tietää, mitä kaikki nuo pienet merkit tekevät.

## Mitä siinä on oletuksena

Palkissa on kolme osaa. Vasemmalla on Omarchy-logo (valikon käynnistin) ja työtilojen ilmaisimet. Keskellä on tilailmaisimet, kello, Elsewhen (maailmankello), sää ja Omarchy-päivitysmerkki. Oikealla: näppäimistöasettelu (kun niitä on määritetty useampi kuin yksi), järjestelmärivi, agentit, bluetooth, verkko, ääni, näyttö ja virta.

Muutama niistä näkyy vain, kun niillä on jotain sanottavaa. Näppäimistöasettelu näkyy vain, jos olet määrittänyt useamman kuin yhden asettelun. Päivitysmerkki näkyy vain, kun Omarchy-päivitys odottaa. Ja agenttien kuvake näkyy ensimmäisellä kerralla, kun Omarchy löytää koneelta tekoälykoodauskäyttöä (katso [AI](17-ai.md)).

## Napsautteleminen ympäriinsä

Lähes jokainen widget tekee jotain vasemmalla, oikealla ja keskimmäisellä napsautuksella, ja monet vastaavat vieritykseen. Tämä on se osa, jonka ihmiset huomaamatta jättävät — oikea ja keskimmäinen painike ovat paikkoja, joihin moni hyvä juttu kätkeytyy.

| Widget | Vasen | Oikea | Keskimmäinen / vieritys |
| --- | --- | --- | --- |
| Valikko | Omarchy-valikko | Uusi pääte | — |
| Työtilat | Kohdista kyseiseen työtilaan | — | Vieritys: seuraava/edellinen työtila |
| Kello | Kalenteriponnahdusikkuna | Kierrä merkinnän muotoa | Keskimmäinen: aikavyöhykkeen valitsin |
| Sää | Ennusteponnahdusikkuna | Koko sää ilmoituksena | Keskimmäinen: päivitä |
| Ääni | Äänipaneeli | Mykistä | Keskimmäinen: paneeli · vieritys: äänenvoimakkuus |
| Mikrofoni | Mykistä mikrofoni | — | Keskimmäinen: äänipaneeli · vieritys: sisääntulon äänenvoimakkuus |
| Verkko | Verkkopaneeli | — | — |
| Bluetooth | Bluetooth-paneeli | Vaihda radio | — |
| Näyttö | Näyttöpaneeli | — | Vieritys: kirkkaus |
| Virta | Virtapaneeli | Vaihda akun prosentti | — |
| Media | Toista/keskeytä | Kansikuvaponnahdusikkuna | Keskimmäinen: seuraava · vieritys: edel./seuraava |
| Agentit | Agenttipaneeli | Käynnistä agenttisi | Keskimmäinen: seuraava tilaus |
| Järjestelmärivi | Vie osoitin laatikon paljastamiseksi | Oikealla nuolinappulassa hallinnointiin | — |
| Omarchy-päivitys | Aja päivitys | — | — |

Kaikki tuossa taulukossa ei ole palkissasi heti käyttövalmiina. Media-widget (MPRIS-soitossa, jossa on vierivä kappale ja artisti) ja mikrofoni-widget ovat molemmat sisäänrakennettuja, mutta oletuksena pois päältä — lisää ne, jos haluat, kuten alla kuvataan.

## Paneelit

Palkkikuvakkeen napsauttaminen avaa paneelin, joka on oikea ponnahdusikkuna liukusäätimillä, listoilla ja näppäimistönavigoinnilla ennemmin kuin työkaluvihje. Jokaisella on myös pikanäppäin, joten sinun ei koskaan tarvitse tähdätä 16 pikselin merkkiin:

| Pikanäppäin | Paneeli |
| --- | --- |
| `Super + Ctrl + A` | Ääni |
| `Super + Ctrl + W` | Verkko |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Näyttö |
| `Super + Ctrl + P` | Virta |
| `Super + Ctrl + Alt + D` | Kalenteri |
| `Super + Ctrl + Alt + E` | Maailmankello |
| `Super + Ctrl + 1-9` | Vaihda oikean osan n:s paneeli |

Paneelit eivät ole lukemia. Ne ovat paikkoja, joissa todella teet asian:

- **Äänessä** on pää-äänenvoimakkuuden liukusäädin, ulostulolaitteen valitsin ja sovelluskohtainen mikseri, joten voit vaimentaa tuon yhden selaimen välilehden koskematta kaikkeen muuhun.
- **Verkko** skannaa Wi-Fiä, näyttää signaalin voimakkuuden, yhdistää ja antaa sinun valita DNS-tarjoajan.
- **Bluetooth** luetteloi laitteesi yhdistä/katkaise-toiminnoilla ja akun tasoilla.
- **Virta** näyttää akun tilastot, vaihtaa virtaprofiileja (se muistaa erillisen valinnan akulle ja AC:lle) ja tulostaa joitakin järjestelmätietoja.
- **Näytössä** on kirkkauden liukusäädin, tekstin koko, näytön skaalauksen esiasetukset ja — kun sinulla on useampi kuin yksi ruutu — näyttökohtaiset säätimet. Katso [näytöt](33-monitors.md) syvällisempää tarinaa varten.
- **Kello** avaa kuukausiruudukon ISO-viikon numeroilla ja kuukausinavigoinnilla.

Jokainen paneeli hyväksyy näppäimistön sekä hiiren: nuolet liikkuvat, Return aktivoi, Tab siirtyy viereiseen paneeliin ja Escape sulkee.

`Super + Ctrl + 1-9` laskee paneelit vasemmalta oikealle oikeassa osassa ohittaen järjestelmärivin, koska sillä ei ole omaa paneelia. Numero vastaa siis kuvaketta, johon osoittaisit.

### Tailscale ja Dropbox

Kaksi widgetiä lisää ilmestyy palkkiin vasta, kun asennat vastaavan palvelun kohdasta **Asenna → Palvelu**, ja molemmista kannattaa tietää, koska ne tekevät muutakin kuin raportoivat tilaa.

**Tailscale**-paneeli yhdistää ja katkaisee tailnetin, vaihtaa tilien välillä ja valitsee poistumissolmun (omat koneesi ja Mullvad-alueet näkyvät molemmat siinä listassa). Se myös selaa koneitasi — ja kun yksi on valittu, `s` lähettää tiedostoja sille Taildropin kautta, mikä on nopein tapa siirtää tiedosto puhelimeesi tai toiselle kannettavalle. `c` kopioi koneen IP:n, `n` sen nimen ja `d` sen täyden DNS-nimen. Jokaisella konerivillä on myös lähetyspainike, jos mieluummin napsautat. Sama asia pääätteestä on `omarchy tailscale send <machine> [file...]`.

**Dropbox**-paneeli hoitaa kirjautumisen, näyttää, kuinka paljon tallennustilaa olet käyttänyt, ja luetteloi äskettäin synkronoidut tiedostot.

Kummankin palvelun poistaminen vie sen widgetin takaisin pois palkista.

## Ilmaisimet

Keskitason pieni rypäs on ilmaisin-widget. Nämä ovat tilamerkkejä tiloille, jotka olet kytkenyt päälle: älä häiritse, yövalo, jonotettu [muistutus](09-reminders.md), aktiivinen ruuduntallennus, pysy hereillä ja [sanelu](11-text-extraction-dictation.md). Ne syttyvät, kun tila on aktiivinen, ja muuten pysyvät poissa tieltä — vie osoitin kellon vasemmalle puolelle (pystypalkissa sen yläpuolelle) vilkaistaksesi epäaktiivisia. Ilmaisimen napsauttaminen vaihtaa kyseisen tilan. Yksi lisää on vain tilaa: etäisessio syttyy punaiseksi, kun joku on yhdistetty tähän koneeseen gliffin kautta.

Jos haluat niiden olevan aina näkyvissä, aseta widgetissä `alwaysShow` arvoon `true`. Ja jos välität vain joistakin niistä, luetteloi haluamasi kohdassa `items`: `["Dnd", "Reminder", "NightLight"]`. Sinulla voi olla useampi kuin yksi ilmaisin-widget, joten eri osat voivat näyttää erilaisia osajoukkoja.

## Palkin uudelleenjärjestäminen

Palkki määrittää itsensä. Sinun ei tarvitse avata määritystiedostoa siirtääksesi asioita.

Tartu tyhjään kohtaan palkissa keskustan tienoilla ja vedä sitä kohti toista ruudun reunaa, ja palkki siirtyy sinne — vasen, oikea, ylä- tai alaosa toimivat kaikki, ja jokainen widget mukautuu (pystypalkit palaavat kompakteihin vain kuvakkeita sisältäviin muotoihin). Napsautus ja pohjassa pitäminen käynnistää saman vedon. Kaksoisnapsauta vasemmalla painikkeella samaa tyhjää tilaa kiertääksesi palkin taustaa läpinäkyvästä lasiseen ja peittävään. Ja vedä mitä tahansa widgetiä järjestääksesi sen uudelleen tai heittääksesi sen toiseen osaan.

Widget, jonka haluat pitää saatavilla mutta et aina näkyvissä, voi asua järjestelmärivin laatikossa: vedä se järjestelmärivin päälle, niin laatikko aukeaa ja ottaa sen vastaan. Se istuu siellä sovelluskuvakkeiden jälkeen, näkyy aina kun laatikko näkyy ja pitää laatikkonsa auki niin kauan kuin sen paneeli on auki. Vedä se sieltä takaisin palkkiin palauttaaksesi sen paikalleen.

Jos mieluummin valitset valikosta, kohdassa **Käynnistä → Ulkoasu → Valikkopalkki** on sijainti, ja **Palkin tausta** valitsee, miten palkki piirretään: **Peittävä palkki**, **Lasinen palkki** (läpinäkyvä, sen takana oleva sumennettuna) tai **Läpinäkyvä palkki**.

Samoihin asioihin on komentoja, mikä on se, mitä haluat [dotfiles](31-dotfiles.md)-kokoonpanolle:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Lisätäksesi tai poistaaksesi widgetin kokonaan käytä lisäosakomentoja. `omarchy plugin list` tulostaa jokaisen widgetin, jonka kuori tuntee, sen tunnisteella, ja sitten:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Palkin piilottaminen

`Super + Shift + Space` vaihtaa palkin pois päältä ja takaisin tappamatta kuorta — paneelit ja pikanäppäimet jatkavat toimintaansa, saat vain pikselit takaisin. Se on myös valikossa kohdassa **Käynnistä → Ulkoasu → Valikkopalkki → Piilota palkki**.

## Määritystiedosto

Kaikki se on tallennettu tiedostoon `~/.config/omarchy/shell.json`, avaimen `bar` alle. Tässä on lyhennetty versio:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Jokainen widget on yksi merkintä yhdessä kolmesta asettelu-taulukosta, ja sen asetukset ovat rivissä kyseisessä merkinnässä — ei ole erillistä asetustiedostoa eikä `config`-aliobjektia. Kellon `format`, `formatAlt` (mihin oikean painikkeen napsautus kiertää) ja `verticalFormat` elävät kaikki juuri siinä kohdassa `{ "id": "omarchy.clock" }`.

`centerAnchor` nimeää sen yhden keskimmäisen widgetin, joka kiinnitetään ruudun tarkkaan keskikohtaan, muiden reunustaessa sitä. Näin kello pysyy aivan keskellä, vaikka sää ja päivitysmerkki tulevat ja menevät. Aseta se tyhjäksi merkkijonoksi, ja keskimmäinen lista vain keskitetään ryhmänä sen sijaan.

Yksi sääntö, joka kannattaa sisäistää: **kun sinulla on oma `shell.json`, se on määräävä**. Kunnes mukautat mitään, kuori lukee Omarchyn oletustiedostoa. Heti kun vedät widgetiä, ajat komennon `omarchy bar` tai muokkaat tiedostoa itse, omistat sen — syvää yhdistämistä ei ole, joten tulevissa Omarchy-julkaisuissa uudet oletuswidgetit eivät ilmesty palkkiisi automaattisesti. `omarchy bar defaults` palauttaa mukana toimitetun asettelun aina, kun haluat puhtaan pöydän.

Sama tiedosto sisältää myös joutilaana olemisen ajoituksesi ylätasolla, `bar`-avaimen ulkopuolella: `idle.screensaver` ja `idle.lock`, molemmat sekunteina siitä, kun jäit joutilaaksi. Joten oletusnäytönsäästäjä iskee 150 sekunnin kohdalla ja lukitus 300 sekunnin kohdalla.
