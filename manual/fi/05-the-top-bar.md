# Yläpalkki

Näyttösi yläreunassa kulkeva kaistale on Omarchy-palkki. Se ei ole kylkeen pultattu tilapalkki, vaan osa Omarchy-kuorta, sitä yhtä pitkään käynnissä olevaa Quickshell-prosessia, joka piirtää myös valikon, ilmoitukset, OSD-ponnahdusikkunat ja lukitusnäytön. Siksi sen teema sopii täydellisesti kaikkeen muuhun ja siksi paneeli aukeaa välittömästi sen sijaan, että käynnistäisi uuden sovelluksen.

Se on myös työpöydän ainoa osa, joka on aina näytöllä, joten kannattaa tietää, mitä kaikki ne pienet kuvakkeet tekevät.

## Mitä siinä on oletuksena

Palkissa on kolme osiota. Vasemmalla ovat Omarchy-logo (valikon käynnistin) ja työtilojen ilmaisimet. Keskellä saat tilailmaisimet, kellon, Elsewhenin (maailmankellon), sään ja Omarchy-päivitysmerkin. Oikealla: järjestelmälokero, näppäimistöasettelu (kun useampi kuin yksi on määritetty), agentit, bluetooth, verkko, ääni, näyttö ja virta.

Muutama niistä näkyy vain, kun niillä on jotain sanottavaa. Näppäimistöasettelu näkyy vain, jos olet määrittänyt useamman kuin yhden asettelun. Päivitysmerkki näkyy vain, kun Omarchy-päivitys odottaa. Ja agenttien kuvake ilmestyy, kun Omarchy löytää ensimmäisen kerran koneelta tekoälykoodauksen käyttöä (katso [Tekoäly](17-ai.md)).

## Klikkailu ympäriinsä

Lähes jokainen widgetti tekee jotain vasemmalla, oikealla ja keskinapilla, ja useampi reagoi vieritykseen. Tämä on se osa, joka ihmisiltä jää huomaamatta — oikean ja keskinapin takana piilee paljon hyvää tavaraa.

| Widgetti | Vasen | Oikea | Keskinappi / vieritys |
| --- | --- | --- | --- |
| Valikko | Omarchy-valikko | Uusi pääte | — |
| Työtilat | Tuo kyseinen työtila tälle näytölle | — | Vieritys: seuraava/edellinen työtila |
| Kello | Kalenteriponnahdusikkuna | Vaihda otsikon muotoa | Keskinappi: aikavyöhykkeen valitsin |
| Sää | Ennusteponnahdusikkuna | Täysi sää ilmoituksena | Keskinappi: päivitä |
| Ääni | Äänipaneeli | Mykistä | Keskinappi: paneeli · vieritys: äänenvoimakkuus |
| Mikrofoni | Mykistä mikrofoni | — | Keskinappi: äänipaneeli · vieritys: tulon äänenvoimakkuus |
| Verkko | Verkkopaneeli | — | — |
| Bluetooth | Bluetooth-paneeli | Kytke radio päälle/pois | — |
| Näyttö | Näyttöpaneeli | — | Vieritys: kirkkaus |
| Virta | Virtapaneeli | Näytä/piilota akun prosentti | — |
| Media | Toista/tauko | Kansikuvan ponnahdusikkuna | Keskinappi: seuraava · vieritys: edellinen/seuraava |
| Agentit | Agenttipaneeli | Käynnistä agenttisi | Keskinappi: seuraava tilaus |
| Lokero | Paljasta laatikko viemällä hiiri päälle | Hallitse nuolesta oikealla napilla | — |
| Omarchy-päivitys | Suorita päivitys | — | — |

Kaikki tuossa taulukossa oleva ei ole palkissasi heti valmiina. Mediawidgetti (MPRIS nyt soi, vierivällä kappaleella ja artistilla) ja mikrofoniwidgetti ovat molemmat sisäänrakennettuja mutta oletuksena pois päältä — lisää ne, jos haluat ne, kuten alla kuvataan.

## Paneelit

Palkin kuvakkeen klikkaaminen avaa paneelin, joka on kunnollinen ponnahdusikkuna liukusäätimineen, luetteloineen ja näppäimistönavigointineen työkaluvihjeen sijaan. Jokaisella on myös pikanäppäin, joten sinun ei koskaan tarvitse tähdätä 16 pikselin kuvakkeeseen:

| Pikanäppäin | Paneeli |
| --- | --- |
| `Super + Ctrl + A` | Ääni |
| `Super + Ctrl + N` | Verkko |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Näyttö |
| `Super + Ctrl + P` | Virta |
| `Super + Ctrl + Alt + D` | Kalenteri |
| `Super + Ctrl + Alt + E` | Maailmankello |
| `Super + Ctrl + 1-9` | Näytä/piilota oikean osion n:s paneeli |

Paneelit eivät ole pelkkiä lukemia. Niissä teet asian oikeasti:

- **Äänessä** on pää-äänenvoimakkuuden liukusäädin, toistolaitteen valitsin ja sovelluskohtainen mikseri, joten voit hiljentää sen yhden selainvälilehden koskematta kaikkeen muuhun.
- **Verkko** etsii Wi-Fi-verkkoja, näyttää signaalin voimakkuuden, yhdistää ja antaa valita DNS-palveluntarjoajan.
- **Bluetooth** luetteloi laitteesi yhdistämis-/katkaisutoimintoineen ja akkutasoineen.
- **Virta** näyttää akun tilastot, vaihtaa virtaprofiileja (se muistaa erillisen valinnan akulle ja verkkovirralle) ja tulostaa järjestelmätietoja.
- **Näytössä** on kirkkauden liukusäädin, tekstin koko, näytön skaalauksen esiasetukset ja — kun näyttöjä on useampi kuin yksi — näyttökohtaiset säätimet. Katso syvempi tarina kohdasta [näytöt](33-monitors.md).
- **Kello** avaa kuukausiruudukon ISO-viikkonumeroineen ja kuukausittain askeltamisineen.
- **Maailmankello** pitää jokaiselle kaupungille oman rivinsä, sen sään ja sen, miten sen päivä etenee. Haku löytää kaupunkeja aikavyöhykkeiden ohella, joten Fort Lauderdale on Fort Lauderdale eikä New York. Jos yläreunan rivi nimeää väärän kaupungin, klikkaa sitä ja kerro, missä olet; valitse jokin toiselta aikavyöhykkeeltä ja järjestelmäkello siirtyy sinne myös, mikä on kätevää matkustaessa. Vie hiiri kaupungin päälle ja klikkaa henkilökuvaketta kertoaksesi, kuka siellä asuu — pelkillä nimillä, tai `@` GitHub-tunnuksilla tuodaksesi heidän kasvonsa mukana.

Jokainen paneeli ottaa vastaan myös näppäimistön hiiren ohella: nuolet liikkuvat, Return aktivoi, Tab askeltaa viereiseen paneeliin ja Escape sulkee.

`Super + Ctrl + 1-9` laskee paneelit vasemmalta oikealle oikeassa osiossa, lokero ohittaen, koska sillä ei ole omaa paneelia. Numero vastaa siis sitä kuvaketta, jota osoittaisit.

### Tailscale ja Dropbox

Kaksi widgettiä lisää ilmestyy palkkiin vasta, kun asennat vastaavan palvelun kohdasta **Asenna → Palvelu**, ja kummatkin kannattaa tuntea, koska ne tekevät muutakin kuin raportoivat tilaa.

**Tailscale**-paneeli yhdistää ja katkaisee tailnetin, vaihtaa tilien välillä ja valitsee poistumissolmun (omat koneesi ja Mullvad-alueet näkyvät kumpikin siinä luettelossa). Se selaa myös koneitasi — ja yhdellä valittuna `s` lähettää sille tiedostoja Taildropilla, mikä on nopein tapa siirtää tiedosto puhelimeesi tai toiselle kannettavalle. `c` kopioi koneen IP:n, `n` sen nimen ja `d` sen täyden DNS-nimen. Jokaisella konerivillä on myös lähetyspainike, jos klikkaat mieluummin. Sama asia päätteestä on `omarchy tailscale send <machine> [file...]`.

**Dropbox**-paneeli hoitaa kirjautumisen, näyttää, kuinka paljon tallennustilaa olet käyttänyt, ja luetteloi äskettäin synkronoidut tiedostot.

Kumman tahansa palvelun poistaminen ottaa sen widgetin takaisin pois palkista.

## Ilmaisimet

Pieni rypäs keskellä on ilmaisimet-widgetti. Nämä ovat tilakuvakkeita päälle kytkemillesi tiloille: älä häiritse, yövalo, jonoon laitettu [muistutus](09-reminders.md), aktiivinen näytön tallennus, pysy hereillä ja [sanelu](11-text-extraction-dictation.md). Ne syttyvät, kun tila on aktiivinen, ja pysyvät muuten poissa tieltä — vie hiiri mihin tahansa palkin päälle vilkaistaksesi ei-aktiivisia. Ilmaisimen klikkaaminen kytkee kyseisen tilan päälle/pois. Yksi lisää on vain tilaa varten: etäistunto syttyy punaisena, kun joku on yhdistettynä tähän koneeseen gliffin kautta.

Jos haluat niiden mieluummin olevan aina näkyvissä, aseta widgetillä `alwaysShow` arvoon `true`. Ja jos välität vain joistakin niistä, luetteloi haluamasi kohdassa `items`: `["Dnd", "Reminder", "NightLight"]`. Ilmaisimet-widgettejä voi olla useampi kuin yksi, joten eri osiot voivat näyttää eri osajoukkoja.

## Palkin järjestäminen uudelleen

Palkki määrittää itsensä. Sinun ei tarvitse avata asetustiedostoa siirtääksesi asioita.

Tartu tyhjään palkin läiskään keskikohdan ympärillä ja vedä sitä kohti toista näytön reunaa, niin palkki siirtyy sinne — vasen, oikea, ylä- ja alareuna toimivat kaikki, ja jokainen widgetti mukautuu (pystypalkit palaavat kompakteihin vain-kuvake-muotoihin). Klikkaus ja pohjassa pitäminen aloittaa saman vedon. Kaksoisklikkaa vasemmalla samaa tyhjää tilaa vaihtaaksesi palkin taustan kirkkaasta lasiseen ja läpinäkymättömään. Ja vedä mikä tahansa widgetti järjestääksesi sen uudelleen tai heittääksesi sen toiseen osioon; muut widgetit liukuvat erilleen tehdäkseen tilaa sille kohdalle, johon se laskeutuu.

Palkin keskikohta on laatikko: mikä tahansa siinä pysyy keskitettyinä yhtenä ryhmänä, ja sen kummallakin puolella olevat widgetit roikkuvat sen reunoista. Kun vedät widgettiä, laatikko näkyy ääriviivana tai palkin poikki kulkevana viivana sen ollessa tyhjä, ja voit pudottaa sen sisään tai sen viereen. Kun pudotus osuisi laatikkoon, laatikko kasvaa ottaakseen widgetin sisäänsä.

Widgetin, jonka haluat olevan lähellä mutta ei aina näkyvissä, voi laittaa lokeron laatikkoon: vedä se lokeron päälle, ja laatikko avautuu ottaakseen sen. Se istuu siellä sovelluskuvakkeiden jälkeen, ilmestyy aina laatikon ilmestyessä ja pitää laatikkonsa auki paneelinsa ollessa ylhäällä. Vedä se takaisin ulos palkille laittaaksesi sen takaisin.

Jos valitset mieluummin valikosta, kohdassa **Ulkoasu → Valikkopalkki** on sijainti, ja **Palkin tausta** valitsee, miten palkki piirretään: **Läpinäkymätön palkki**, **Lasinen palkki** (läpinäkyvä, taustalla oleva sumentuneena) tai **Kirkas palkki**.

Samat asiat saa komentoina, mikä on se, mitä haluat [dotfiles](31-dotfiles.md)-asennukseen:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Lisätäksesi tai poistaaksesi widgetin kokonaan käytä liitännäiskomentoja. `omarchy plugin list` tulostaa jokaisen kuoren tunteman widgetin sen id:n kanssa, ja sitten:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Palkin piilottaminen

`Super + Shift + Space` piilottaa palkin ja tuo sen takaisin tappamatta kuorta — paneelit ja pikanäppäimet toimivat edelleen, saat vain pikselit takaisin. Se on myös valikossa kohdassa **Ulkoasu → Valikkopalkki → Piilota palkki**.

## Asetustiedosto

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

Jokainen widgetti on yksi merkintä yhdessä viidestä asettelutaulukosta, ja sen asetukset ovat suoraan siinä merkinnässä — erillistä asetustiedostoa ei ole eikä `config`-aliobjektia ole. Kellon `format`, `formatAlt` (se, mihin oikean napin klikkaus vaihtaa) ja `verticalFormat` elävät kaikki juuri siinä kohdassa `{ "id": "omarchy.clock" }`.

`center` on laatikko palkin keskellä: kaikki siinä on keskitetty näytölle yhtenä ryhmänä. `centerBegin` ja `centerEnd` roikkuvat laatikon kummaltakin puolelta, ja siten kello pysyy täsmälleen keskellä sään ja päivitysmerkin tullessa ja mennessä. Laita `center`-kohtaan useampi kuin yksi widgetti ja ne keskitetään yhdessä; jätä se tyhjäksi ja `centerBegin` ja `centerEnd` kohtaavat palkin keskellä.

Yksi sisäistämisen arvoinen sääntö: **kun sinulla on oma `shell.json`, se on kanoninen**. Kunnes mukautat mitään, kuori lukee Omarchyn oletustiedoston. Heti kun vedät widgettiä, suoritat `omarchy bar` -komennon tai muokkaat tiedostoa itse, omistat sen — syvää yhdistämistä ei ole, joten uudet oletuswidgetit tulevissa Omarchy-julkaisuissa eivät ilmesty palkkiisi automaattisesti. `omarchy bar defaults` laittaa toimitetun asettelun takaisin aina, kun haluat puhtaan pöydän.

Sama tiedosto pitää myös käyttämättömyysaikasi ylimmällä tasolla, avaimen `bar` ulkopuolella: `idle.screensaver` ja `idle.lock`, kumpikin sekunteina siitä, kun menit käyttämättömäksi. Oletusnäytönsäästäjä käynnistyy siis 150 sekunnissa ja lukko 300:ssa.
