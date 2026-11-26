# Yläpalkki

Näytön yläreunassa kulkeva kaistale on Omarchy-palkki. Se ei ole päälle liimattu tilapalkki, vaan osa Omarchy-kuorta, sitä yhtä pitkään käynnissä olevaa Quickshell-prosessia, joka piirtää myös valikon, ilmoitukset, OSD-ponnahdusikkunat ja lukitusnäytön. Siksi sen teema sopii täydellisesti kaikkeen muuhun ja siksi paneeli avautuu heti sen sijaan, että käynnistäisi uuden sovelluksen.

Se on myös ainoa työpöydän osa, joka on aina näytöllä, joten kannattaa tietää, mitä kaikki ne pienet kuvakkeet tekevät.

## Mitä siinä on oletuksena

Palkissa on kolme osiota. Vasemmalla ovat Omarchy-logo (valikon käynnistin) ja työtilojen ilmaisimet. Keskellä ovat tilailmaisimet, kello, Elsewhen (maailmankello), sää ja Omarchy-päivitysmerkki. Oikealla: ilmaisinalue, näppäimistöasettelu (kun käytössä on useampi kuin yksi asettelu tai syöttötapa), agentit, bluetooth, verkko, ääni, näyttö ja virta.

Muutama niistä näkyy vain, kun niillä on jotain sanottavaa. Näppäimistöasettelu näkyy vain, jos olet määrittänyt useamman kuin yhden asettelun tai syöttötavan. Päivitysmerkki näkyy vain, kun Omarchy-päivitys odottaa.

## Klikkailu ympäriinsä

Lähes jokainen pienoissovellus tekee jotain vasemmalla, oikealla ja keskimmäisellä napsautuksella, ja useampi reagoi myös vierittämiseen. Tämä on se osa, joka ihmisiltä jää huomaamatta — oikean ja keskimmäisen painikkeen taakse piiloutuu paljon hyvää tavaraa.

| Pienoissovellus | Vasen | Oikea | Keskipainike / vieritys |
| --- | --- | --- | --- |
| Valikko | Omarchy-valikko | Uusi pääte | — |
| Työtilat | Keskitä kyseinen työtila tälle näytölle | — | Vieritä: seuraava/edellinen työtila |
| Kello | Kalenterin ponnahdusikkuna | Vaihda tunnisteen muotoa | Keskipainike: aikavyöhykkeen valitsin |
| Maailmankello | Maailmankellon paneeli | Päivitä | Keskipainike: päivitä |
| Sää | Ennusteen ponnahdusikkuna | Täysi sää ilmoituksena | Keskipainike: päivitä |
| Ääni | Äänipaneeli | Mykistä | Keskipainike: paneeli · vieritä: äänenvoimakkuus |
| Mikrofoni | Mykistä mikrofoni | — | Keskipainike: äänipaneeli · vieritä: sisääntulon voimakkuus |
| Verkko | Verkkopaneeli | — | — |
| Bluetooth | Bluetooth-paneeli | Kytke radio päälle/pois | — |
| Näyttö | Näyttöpaneeli | — | Vieritä: kirkkaus |
| Virta | Virtapaneeli | Näytä/piilota akun prosentti | — |
| Media | Toista/keskeytä | Kansikuvan ponnahdusikkuna | Keskipainike: seuraava · vieritä: edellinen/seuraava |
| Agentit | Agenttipaneeli | Käynnistä agenttisi | Keskipainike: päivitä käyttö |
| Ilmaisinalue | Vie osoitin päälle paljastaaksesi laatikon | Napsauta nuolta hiiren oikealla hallitaksesi | — |
| Omarchy-päivitys | Suorita päivitys | — | — |

Kaikki tuossa taulukossa oleva ei ole palkissasi heti käytössä. Median pienoissovellus (MPRIS nyt soi, vierivällä kappaleella ja artistilla) ja mikrofonin pienoissovellus ovat molemmat sisäänrakennettuja mutta oletuksena pois päältä — lisää ne, jos haluat ne, kuten alla kuvataan.

## Paneelit

Palkin kuvakkeen napsauttaminen avaa paneelin, joka on kunnollinen ponnahdusikkuna liukusäätimineen, luetteloineen ja näppäimistönavigointeineen työkaluvihjeen sijaan. Jokaisella on myös pikanäppäin, joten sinun ei koskaan tarvitse tähdätä 16 pikselin kuvakkeeseen:

| Pikanäppäin | Paneeli |
| --- | --- |
| `Super + Ctrl + A` | Ääni |
| `Super + Ctrl + N` | Verkko |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Näyttö |
| `Super + Ctrl + P` | Virta |
| `Super + Ctrl + Alt + D` | Kalenteri |
| `Super + Ctrl + Alt + E` | Maailmankello |
| `Super + Ctrl + X` | Agentit |
| `Super + Ctrl + 1-9` | Vaihda oikean osion n. paneeli |

Paneelit eivät ole pelkkiä lukemia. Niissä itse asia tehdään:

- **Ääni** sisältää pää-äänenvoimakkuuden liukusäätimen, ulostulolaitteen valitsimen ja sovelluskohtaisen mikserin, joten voit hiljentää sen yhden selaimen välilehden koskematta kaikkeen muuhun.
- **Verkko** etsii Wi-Fi-verkkoja, näyttää signaalin voimakkuuden, muodostaa yhteyden ja antaa valita DNS-palveluntarjoajan.
- **Bluetooth** luettelee laitteesi yhdistä/katkaise-toiminnoilla ja akkutasolla.
- **Virta** näyttää akun tilastot, vaihtaa virtaprofiileja (se muistaa erillisen valinnan akulle ja verkkovirralle) ja tulostaa jonkin verran järjestelmätietoja.
- **Näyttö** sisältää kirkkauden liukusäätimen, tekstin koon, näyttöjen skaalauksen esiasetukset ja — kun sinulla on useampi kuin yksi näyttö — näyttökohtaiset säätimet. Katso [näytöt](33-monitors.md) saadaksesi syvemmän tarinan.
- **Kello** avaa kuukausiruudukon ISO-viikkonumeroilla ja kuukauden vaihdolla.
- **Maailmankello** pitää rivin jokaista kaupunkia kohden, sen sään ja sen, miten sen päivä sujuu. Haku löytää kaupunkeja sekä aikavyöhykkeitä, joten Fort Lauderdale on Fort Lauderdale eikä New York. Jos ylhäällä oleva rivi mainitsee väärän kaupungin, napsauta sitä ja kerro, missä olet; valitse jokin muulla aikavyöhykkeellä ja järjestelmän kello siirtyy myös sinne, mikä on kätevää matkustaessasi. Vie osoitin kaupungin päälle ja napsauta henkilö-painiketta kertoaksesi, kuka siellä asuu — pelkät nimet, tai `@` GitHub-tunnukset tuodaksesi heidän kasvonsa mukana.

Jokainen paneeli tottelee näppäimistöä sekä hiirtä: nuolet liikkuvat, Return aktivoi, Tab siirtyy viereiseen paneeliin ja Escape sulkee.

`Super + Ctrl + 1-9` laskee paneelit vasemmalta oikealle oikeassa osiossa jättäen ilmaisinalueen väliin, koska sillä ei ole omaa paneelia. Numero vastaa siis kuvaketta, jota osoittaisit.

### Tailscale ja Dropbox

Kaksi muuta pienoissovellusta ilmestyy palkkiin vasta, kun asennat vastaavan palvelun kohdasta **Install → Service**, ja molemmat kannattaa tuntea, koska ne tekevät muutakin kuin raportoivat tilaa.

**Tailscale**-paneeli yhdistää ja katkaisee tailnetin, vaihtaa tilien välillä ja valitsee poistumissolmun (omat koneesi ja Mullvandin alueet näkyvät molemmat siinä luettelossa). Se selaa myös koneitasi — ja yhden valittuna `s` lähettää siihen tiedostoja Taildropin kautta, mikä on nopein tapa siirtää tiedosto puhelimeesi tai toiselle kannettavalle. `c` kopioi koneen IP:n, `n` sen nimen ja `d` sen täyden DNS-nimen. Jokaisella konerivillä on myös lähetyspainike, jos mieluummin napsautat. Sama asia päätteestä on `omarchy tailscale send <machine> [file...]`.

**Dropbox**-paneeli hoitaa kirjautumisen, näyttää, kuinka paljon tallennustilaa olet käyttänyt, ja luettelee äskettäin synkronoidut tiedostot.

Jommankumman palvelun poistaminen vie sen pienoissovelluksen takaisin pois palkista.

## Ilmaisimet

Keskellä oleva pieni rypäs on ilmaisinten pienoissovellus. Nämä ovat tilakuvakkeita päälle kytkemillesi tiloille: älä häiritse, yövalo, jonoon asetettu [muistutus](09-reminders.md), aktiivinen näytön tallennus ja pysy hereillä, sekä varoitukset, kun salasanaton sudo on päällä tai joku on yhdistetty etäistuntoon. Ne syttyvät, kun tila on aktiivinen, ja muuten pysyvät poissa tieltä — vie osoitin aivan niiden viereen, missä ei-aktiiviset olisivat, kurkistaaksesi niitä. Ilmaisimen napsauttaminen kytkee kyseisen tilan päälle tai pois. Yksi lisää on pelkkä tila: etäistunto palaa punaisena, kun joku on yhdistetty tähän koneeseen gliffin kautta.

Jos haluat niiden mieluummin olevan aina näkyvissä, aseta pienoissovellukselle `alwaysShow` arvoon `true`. Ja jos välität vain joistakin niistä, luettele haluamasi kohdassa `items`: `["Dnd", "Reminder", "NightLight"]`. Sinulla voi olla useampi kuin yksi ilmaisinten pienoissovellus, joten eri osiot voivat näyttää eri osajoukkoja.

## Palkin järjesteleminen uudelleen

Palkki määrittää itsensä. Sinun ei tarvitse avata määritystiedostoa siirtääksesi asioita.

Tartu palkin tyhjään kohtaan keskustan ympäriltä ja vedä sitä kohti toista näytön reunaa, ja palkki siirtyy sinne — vasen, oikea, ylä- tai alareuna käyvät kaikki, ja jokainen pienoissovellus mukautuu (pystysuuntaiset palkit palaavat kompakteihin vain-kuvake-muotoihin). Klikkaus-ja-pito käynnistää saman vedon. Kaksoisnapsauta hiiren vasemmalla samaa tyhjää tilaa vaihtaaksesi palkin taustan kirkkaasta lasimaiseen ja läpinäkymättömään. Ja vedä mitä tahansa pienoissovellusta järjestääksesi sen uudelleen tai heittääksesi sen toiseen osioon; muut pienoissovellukset liukuvat erilleen tehdäkseen tilaa sille, mihin se laskeutuu.

Palkin keskiosa on laatikko: mikä tahansa siinä pysyy keskitettyinä yhtenä ryhmänä, ja sen kummallakin puolella olevat pienoissovellukset roikkuvat sen reunoista. Kun vedät pienoissovellusta, laatikko näkyy ääriviivana, tai viivana palkin poikki, kun se on tyhjä, ja voit pudottaa sen sisään tai sen viereen. Kun pudotus osuisi laatikkoon, laatikko kasvaa ottaakseen pienoissovelluksen sisäänsä.

Pienoissovelluksen, jonka haluat olevan lähellä mutta ei aina näkyvissä, voi laittaa ilmaisinalueen laatikkoon: vedä se ilmaisinalueen päälle, ja laatikko avautuu ottaakseen sen. Se istuu siellä sovelluskuvakkeiden jälkeen, näkyy aina, kun laatikko näkyy, ja pitää laatikkonsa avoinna, kun sen paneeli on ylhäällä. Vedä se takaisin ulos palkille laittaaksesi sen takaisin.

Jos mieluummin valitset valikosta, **Appearance → Menu Bar** sisältää sijainnin, ja **Bar Background** valitsee, miten palkki piirretään: **Opaque Bar**, **Glassy Bar** (läpinäkyvä, sen takana oleva sumennettuna) tai **Clear Bar**.

Samoilla asioilla on komennot, mikä on se, mitä haluat [dotfiles](31-dotfiles.md)-asennusta varten:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Pienoissovelluksen lisäämiseen tai poistamiseen kokonaan käytä lisäosakomentoja. `omarchy plugin list` tulostaa jokaisen pienoissovelluksen, jonka kuori tuntee, sen tunnisteen kanssa, ja sitten:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Palkin piilottaminen

`Super + Shift + Space` kytkee palkin pois päältä ja takaisin päälle tappamatta kuorta — paneelit ja pikanäppäimet toimivat edelleen, saat vain pikselit takaisin. Se on myös valikossa kohdassa **Appearance → Menu Bar → Hide Bar**.

## Määritystiedosto

Kaikki se on tallennettu tiedostoon `~/.config/omarchy/shell.json`, avaimen `bar` alle. Tässä on karsittu versio:

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

Jokainen pienoissovellus on yksi merkintä yhdessä viidestä asettelutaulukosta, ja sen asetukset ovat suoraan kyseisessä merkinnässä — erillistä asetustiedostoa ei ole eikä `config`-aliobjektia. Kellon `format`, `formatAlt` (mihin oikean napsautuksen vaihto vaihtaa) ja `verticalFormat` elävät kaikki juuri siinä kohdassa `{ "id": "omarchy.clock" }`.

`center` on laatikko palkin keskellä: kaikki siinä on keskitetty näytölle yhtenä ryhmänä. `centerBegin` ja `centerEnd` roikkuvat laatikon kummallakin puolella, mikä on se, miten kello pysyy tasan keskellä, vaikka sää ja päivitysmerkki tulevat ja menevät. Laita useampi kuin yksi pienoissovellus kohtaan `center` ja ne keskitetään yhdessä; jätä se tyhjäksi ja `centerBegin` ja `centerEnd` kohtaavat palkin keskellä.

Yksi sääntö kannattaa sisäistää: **kun sinulla on oma `shell.json`, se on kanoninen**. Kunnes mukautat mitään, kuori lukee Omarchyn oletustiedoston. Heti kun vedät pienoissovellusta, suoritat `omarchy bar` tai muokkaat tiedostoa itse, omistat sen — syvää yhdistämistä ei ole, joten tulevien Omarchy-julkaisujen uudet oletuspienoissovellukset eivät ilmesty palkillesi automaattisesti. `omarchy bar defaults` palauttaa toimitetun asettelun aina, kun haluat puhtaan pöydän.

Sama tiedosto sisältää myös joutoajan ajoituksesi ylätasolla, `bar`-avaimen ulkopuolella: `idle.screensaver` ja `idle.lock`, molemmat sekunteina siitä, kun siirryit joutotilaan. Oletusnäytönsäästäjä käynnistyy siis 150 sekunnissa ja lukko 300 sekunnissa.
