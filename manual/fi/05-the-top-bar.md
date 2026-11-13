# Yläpalkki

Näytön yläreunassa kulkeva kaistale on Omarchy-palkki. Se ei ole päälle pultattu tilapalkki, vaan osa Omarchy-kuorta, sitä yhtä pitkään käynnissä pysyvää Quickshell-prosessia, joka piirtää myös valikon, ilmoitukset, OSD-ponnahdusikkunat ja lukitusnäytön. Siksi sen teema sopii täydellisesti yhteen kaiken muun kanssa ja siksi paneeli aukeaa välittömästi sen sijaan, että käynnistäisi uuden sovelluksen.

Se on myös se työpöydän osa, joka on aina näytöllä, joten kannattaa tietää, mitä kaikki nuo pienet kuviot tekevät.

## Mitä siinä on oletuksena

Palkissa on kolme osiota. Vasemmalla ovat Omarchy-logo (valikon käynnistin) ja työtilojen ilmaisimet. Keskellä saat tilailmaisimet, kellon, Elsewhenin (maailmankello), sään ja Omarchy-päivitysmerkin. Oikealla: järjestelmälokero, näppäimistöasettelu (kun niitä on määritetty useampi kuin yksi), agentit, bluetooth, verkko, ääni, näyttö ja virta.

Muutama niistä näkyy vain silloin, kun niillä on jotain sanottavaa. Näppäimistöasettelu näkyy vain, jos olet määrittänyt useamman kuin yhden asettelun. Päivitysmerkki näkyy vain silloin, kun Omarchy-päivitys odottaa. Ja agenttikuvake ilmestyy ensimmäisen kerran, kun Omarchy löytää koneelta AI-koodauskäyttöä (katso [AI](17-ai.md)).

## Klikkailu

Lähes jokainen pienoisohjelma tekee jotain vasemmalla, oikealla ja keskimmäisellä napsautuksella, ja useampi reagoi myös vieritykseen. Tämä on se osa, joka ihmisiltä jää huomaamatta — oikea ja keskimmäinen painike ovat paikkoja, joihin iso osa hyvistä jutuista piiloutuu.

| Pienoisohjelma | Vasen | Oikea | Keskimmäinen / vieritys |
| --- | --- | --- | --- |
| Valikko | Omarchy-valikko | Uusi pääte | — |
| Työtilat | Siirrä tarkennus kyseiseen työtilaan tällä näytöllä | — | Vieritys: seuraava/edellinen työtila |
| Kello | Kalenterin ponnahdusikkuna | Vaihda tunnisteen muotoa | Keskimmäinen: aikavyöhykkeen valitsin |
| Sää | Ennusteen ponnahdusikkuna | Koko sää ilmoituksena | Keskimmäinen: päivitä |
| Ääni | Äänipaneeli | Mykistä | Keskimmäinen: paneeli · vieritys: äänenvoimakkuus |
| Mikrofoni | Mykistä mikrofoni | — | Keskimmäinen: äänipaneeli · vieritys: tuloäänen voimakkuus |
| Verkko | Verkkopaneeli | — | — |
| Bluetooth | Bluetooth-paneeli | Kytke radio päälle/pois | — |
| Näyttö | Näyttöpaneeli | — | Vieritys: kirkkaus |
| Virta | Virtapaneeli | Näytä/piilota akun prosenttiosuus | — |
| Media | Toista/keskeytä | Kansikuvan ponnahdusikkuna | Keskimmäinen: seuraava · vieritys: edellinen/seuraava |
| Agentit | Agenttipaneeli | Käynnistä agenttisi | Keskimmäinen: seuraava tilaus |
| Ilmaisinalue | Vie hiiri päälle paljastaaksesi laatikon | Hallitse napsauttamalla chevronia oikealla painikkeella | — |
| Omarchy-päivitys | Suorita päivitys | — | — |

Kaikki tuossa taulukossa oleva ei ole palkissasi heti käytössä. Mediapienoisohjelma (MPRIS nyt soi, vierivällä kappaleella ja esittäjällä) ja mikrofonipienoisohjelma ovat molemmat sisäänrakennettuja mutta oletuksena pois päältä — lisää ne, jos haluat ne, kuten alla kuvataan.

## Paneelit

Palkin kuvakkeen napsauttaminen avaa paneelin, joka on kunnollinen ponnahdusikkuna liukusäätimineen, luetteloineen ja näppäimistönavigointineen työkaluvihjeen sijaan. Jokaisella on myös pikanäppäin, joten sinun ei koskaan tarvitse tähdätä 16 pikselin kuvioon:

| Pikanäppäin | Paneeli |
| --- | --- |
| `Super + Ctrl + A` | Ääni |
| `Super + Ctrl + N` | Verkko |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Näyttö |
| `Super + Ctrl + P` | Virta |
| `Super + Ctrl + Alt + D` | Kalenteri |
| `Super + Ctrl + Alt + E` | Maailmankello |
| `Super + Ctrl + 1-9` | Kytke oikean osion n:s paneeli |

Paneelit eivät ole pelkkiä lukemia. Ne ovat paikkoja, joissa itse asia oikeasti tehdään:

- **Ääni** sisältää päääänenvoimakkuuden liukusäätimen, lähtölaitteen valitsimen ja sovelluskohtaisen mikserin, joten voit hiljentää sen yhden selainvälilehden koskematta kaikkeen muuhun.
- **Verkko** etsii Wi-Fi-verkkoja, näyttää signaalin voimakkuuden, muodostaa yhteyden ja antaa sinun valita DNS-palveluntarjoajan.
- **Bluetooth** luetteloi laitteesi yhdistämis-/katkaisutoimintoineen ja akkutasoineen.
- **Virta** näyttää akkutilastoja, vaihtaa virtaprofiileja (se muistaa erillisen valinnan akulle ja AC:lle) ja tulostaa hieman järjestelmätietoja.
- **Näyttö** sisältää kirkkauden liukusäätimen, tekstin koon, näyttöjen skaalauksen esiasetukset ja — kun sinulla on useampi kuin yksi näyttö — näyttökohtaiset säätimet. Katso syvempi tarina kohdasta [näytöt](33-monitors.md).
- **Kello** avaa kuukausiruudukon ISO-viikkonumeroilla ja kuukausivaihdolla.
- **Maailmankello** pitää jokaiselle kaupungille oman rivinsä, jossa on sen sää ja miten sen päivä etenee. Haku löytää kaupunkeja yhtä hyvin kuin aikavyöhykkeitä, joten Fort Lauderdale on Fort Lauderdale eikä New York. Jos yläreunan rivi nimeää väärän kaupungin, napsauta sitä ja kerro, missä olet; valitse jokin toisella aikavyöhykkeellä, niin järjestelmän kello siirtyy myös sinne, mikä on kätevää matkustaessasi. Vie hiiri kaupungin päälle ja napsauta henkilöpainiketta kertoaksesi, kuka siellä asuu — pelkkiä nimiä tai `@` GitHub-tunnuksia tuodaksesi heidän kasvonsa mukana.

Jokainen paneeli ottaa vastaan näppäimistön yhtä hyvin kuin hiiren: nuolet liikkuvat, Return aktivoi, Tab siirtyy naapuripaneeliin ja Escape sulkee.

`Super + Ctrl + 1-9` laskee paneelit vasemmalta oikealle oikeassa osiossa, ohittaen ilmaisinalueen, koska sillä ei ole omaa paneelia. Numero vastaa siis kuvaketta, jota osoittaisit.

### Tailscale ja Dropbox

Kaksi pienoisohjelmaa lisää ilmestyy palkkiin vasta, kun asennat vastaavan palvelun kohdasta **Install → Service**, ja molemmat kannattaa tuntea, koska ne tekevät enemmän kuin raportoivat tilaa.

**Tailscale**-paneeli yhdistää tailnetiin ja katkaisee yhteyden siihen, vaihtaa tilien välillä ja valitsee poistumissolmun (omat koneesi ja Mullvad-alueet näkyvät molemmat siinä luettelossa). Se myös selaa koneitasi — ja yhden valittuna `s` lähettää siihen tiedostoja Taildropin kautta, mikä on nopein tapa siirtää tiedosto puhelimeesi tai toiseen kannettavaan. `c` kopioi koneen IP:n, `n` sen nimen ja `d` sen täyden DNS-nimen. Jokaisella konerivillä on myös lähetyspainike, jos mieluummin napsautat. Sama asia päätteestä on `omarchy tailscale send <machine> [file...]`.

**Dropbox**-paneeli hoitaa kirjautumisen, näyttää, paljonko tallennustilaa olet käyttänyt, ja luetteloi äskettäin synkronoidut tiedostot.

Kumman tahansa palvelun poistaminen ottaa sen pienoisohjelman takaisin pois palkista.

## Ilmaisimet

Pieni rypäs keskellä on ilmaisimien pienoisohjelma. Nämä ovat tilakuvioita päälle kytkemillesi tiloille: älä häiritse, yövalo, jonoon asetettu [muistutus](09-reminders.md), aktiivinen näytön tallennus, pysy hereillä ja [sanelu](11-text-extraction-dictation.md). Ne syttyvät, kun tila on aktiivinen, ja pysyvät muuten poissa tieltä — vie hiiri niiden viereen, kohtaan, jossa ei-aktiiviset olisivat, kurkistaaksesi niihin. Ilmaisimen napsauttaminen kytkee kyseisen tilan päälle tai pois. Yksi lisää on vain tilaa varten: etäistunto syttyy punaisena, kun joku on yhteydessä tähän koneeseen gliffin kautta.

Jos haluat mieluummin, että ne näkyvät aina, aseta pienoisohjelmassa `alwaysShow` arvoon `true`. Ja jos välität vain joistakin niistä, luetteloi haluamasi kohdassa `items`: `["Dnd", "Reminder", "NightLight"]`. Sinulla voi olla useampi kuin yksi ilmaisimien pienoisohjelma, joten eri osiot voivat näyttää eri osajoukkoja.

## Palkin järjestäminen uudelleen

Palkki määrittää itse itsensä. Sinun ei tarvitse avata asetustiedostoa siirtääksesi asioita.

Tartu tyhjään kohtaan palkissa keskustan ympärillä ja vedä sitä kohti toista näytön reunaa, niin palkki siirtyy sinne — vasen, oikea, ylä- ja alareuna toimivat kaikki, ja jokainen pienoisohjelma mukautuu (pystypalkit palaavat kompakteihin vain kuvakkeet sisältäviin muotoihin). Napsautus ja pitäminen painettuna aloittaa saman vedon. Kaksoisnapsauta vasemmalla painikkeella samaa tyhjää tilaa selataksesi palkin taustaa kirkkaasta lasiseen ja läpinäkymättömään. Ja vedä mitä tahansa pienoisohjelmaa järjestääksesi sen uudelleen tai heittääksesi sen toiseen osioon; muut pienoisohjelmat liukuvat erilleen tehdäkseen tilaa kohtaan, johon se laskeutuu.

Palkin keskikohta on laatikko: mikä tahansa siinä on, pysyy keskitettynä yhtenä ryhmänä, ja sen kummallakin puolella olevat pienoisohjelmat riippuvat sen reunoista. Kun vedät pienoisohjelmaa, laatikko näkyy ääriviivana tai viivana palkin poikki, kun se on tyhjä, ja voit pudottaa sen sisään tai sen viereen. Kun pudotus osuisi laatikkoon, laatikko kasvaa ottaakseen pienoisohjelman sisäänsä.

Pienoisohjelman, jonka haluat olevan saatavilla mutta ei aina näkyvissä, voi laittaa ilmaisinalueen laatikkoon: vedä se ilmaisinalueen päälle, niin laatikko aukeaa ottaakseen sen. Se istuu siellä sovelluskuvakkeiden jälkeen, näkyy aina, kun laatikko näkyy, ja pitää laatikkonsa auki, kun sen paneeli on esillä. Vedä se takaisin ulos palkille laittaaksesi sen takaisin.

Jos valitset mieluummin valikosta, **Appearance → Menu Bar** sisältää sijainnin, ja **Bar Background** valitsee, miten palkki piirretään: **Opaque Bar**, **Glassy Bar** (läpinäkyvä, sen takana oleva sumeana) tai **Clear Bar**.

Samat asiat ovat saatavilla komentoina, mikä on se, mitä haluat [dotfiles](31-dotfiles.md)-kokoonpanolle:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Lisätäksesi tai poistaaksesi pienoisohjelman kokonaan, käytä lisäosakomentoja. `omarchy plugin list` tulostaa jokaisen kuoren tunteman pienoisohjelman sen id:n kanssa, ja sitten:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Palkin piilottaminen

`Super + Shift + Space` kytkee palkin pois päältä ja takaisin päälle tappamatta kuorta — paneelit ja pikanäppäimet toimivat edelleen, saat vain pikselit takaisin. Se on myös valikossa kohdassa **Appearance → Menu Bar → Hide Bar**.

## Asetustiedosto

Kaikki se on tallennettu tiedostoon `~/.config/omarchy/shell.json`, `bar`-avaimen alle. Tässä on karsittu versio:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Jokainen pienoisohjelma on yksi merkintä yhdessä viidestä asettelutaulukosta, ja sen asetukset ovat suoraan kyseisessä merkinnässä — erillistä asetustiedostoa ei ole eikä `config`-aliobjektia. Kellon `format`, `formatAlt` (se, johon oikean painikkeen napsautus selaa) ja `verticalFormat` elävät kaikki juuri siinä kohdassa `{ "id": "omarchy.clock" }`.

`center` on laatikko palkin keskellä: kaikki siinä oleva keskitetään näytölle yhtenä ryhmänä. `centerBegin` ja `centerEnd` riippuvat laatikon kummaltakin puolelta, mikä on tapa, jolla kello pysyy täsmälleen keskellä, vaikka sää ja päivitysmerkki tulevat ja menevät. Laita useampi kuin yksi pienoisohjelma kohtaan `center`, niin ne keskitetään yhdessä; jätä se tyhjäksi, niin `centerBegin` ja `centerEnd` kohtaavat palkin keskellä.

Yksi sääntö, joka kannattaa sisäistää: **kun sinulla on oma `shell.json`, se on määräävä**. Kunnes mukautat mitään, kuori lukee Omarchyn oletustiedoston. Heti kun vedät pienoisohjelmaa, suoritat `omarchy bar` tai muokkaat tiedostoa itse, se on sinun — syvää yhdistämistä ei tehdä, joten tulevien Omarchy-julkaisujen uudet oletuspienoisohjelmat eivät ilmesty automaattisesti palkkiisi. `omarchy bar defaults` palauttaa mukana toimitetun asettelun aina, kun haluat puhtaan pöydän.

Sama tiedosto sisältää myös valmiusaikasi ylätasolla, `bar`-avaimen ulkopuolella: `idle.screensaver` ja `idle.lock`, molemmat sekunteina siitä, kun siirryit valmiustilaan. Oletusnäytönsäästäjä käynnistyy siis 150 sekunnissa ja lukitus 300 sekunnissa.
