# UKK

### Miten vaihdan näppäimistöasettelujen välillä?

Muokkaa tiedostoa `~/.config/hypr/input.lua` ja lisää tämä vaihtaaksesi asettelujen välillä näppäimillä `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Palkki näyttää nykyisen näppäimistöasettelusi automaattisesti, kun sinulla on määritettynä useita asetteluja (ja voit myös vaihtaa sitä napsauttamalla).

### Miten vaihdan kellon muodon 12-tuntiseksi?

Napsauta palkissa olevaa kelloa hiiren oikealla painikkeella selataksesi yleisiä muotoja, mukaan lukien 12-tuntiset muodot. Voit myös asettaa muodon suoraan:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Tämä näyttää muodon sunnuntai 10:55 AM.

### Miten vaihdan aikavyöhykettäni?

Suorita Omarchy-valikossa _Setup > Region > Timezone_ ja valitse luettelosta. Jos aikavyöhyke on oikea mutta kello itse on siirtynyt pois ajasta, _Update > Time_ käynnistää ajan synkronoinnin uudelleen puolestasi.

### Miten vaihdan DNS-asetuksiani, jaan Wi-Fi-verkkoni tai tarkistan yhteysnopeuteni?

Kaikki ne löytyvät kohdasta [verkkoasetukset](35-networking.md).

### Miten tarkistan, kuinka nopea levyni on?

_Trigger > Speed Test > Disk Speed Test_ mittaa levysi reaaliaikaisen luku- ja kirjoitusnopeuden, tai `omarchy disk speedtest` terminaalista.

### Miten lisään tulostimen?

Tulostus on asennettu ja käynnissä heti valmiina, ja lisäät jokaisen tulostimen itse sovelluskäynnistimen (`Super + Space`) kohdasta _Print Settings_.

Valitse _Add_ ja anna sille hetki aikaa etsiä: USB:llä kytketty tulostin ja useimmat verkkotulostimet löytyvät puolestasi. Jos omasi ei ole luettelossa, valitse _Network Printer > Internet Printing Protocol (ipp)_ ja syötä sen osoite — tulostimen oma näyttö tai sen verkkosivu kertoo, mikä se on, yleensä jotain kuten `192.168.1.50` ja jonona `ipp/print`. _Forward_ tarjoaa sen jälkeen ajuria, jossa moderni tulostin toimii parhaiten ajurittomalla _IPP Everywhere_ -profiililla ja vanhempi haluaa mallin oman ajurin.

Napsauta tulostinta hiiren oikealla painikkeella ja valitse _Set as Default_ valitaksesi, mihin tulostimeen sovelluksesi tarttuvat ensimmäisenä, ja _Properties_ asettaaksesi paperikoon, kaksipuoleisuuden ja laadun.

Automaattinen etsintä, jossa verkon tulostimet ilmestyvät näkyviin ilman, että niitä lisätään, on tilapäisesti pois käytöstä, kun sitä uudistetaan, minkä vuoksi yllä oleva ensimmäinen vaihe on sinun tehtäväsi automaattisen sijaan. PDF-tiedostoon tulostaminen toimii ilman yhtään tulostinta.

### Miten vaihdan, minne kuvakaappaukset tai näytön tallenteet tallennetaan?

Tallennetut kuvakaappaukset menevät oletuksena kansioon `~/Pictures/Screenshots`. Jos haluat käyttää toista hakemistoa, lisää tämä tiedostoon hakemiston `~/.config/uwsm/env.d/` alle (kuten `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Voit tehdä saman näytön tallenteille käyttämällä muuttujaa `OMARCHY_SCREENRECORD_DIR`.

Omasnap luo kuvakaappaushakemistonsa automaattisesti. Luo näytön tallenteiden hakemisto itse ja käynnistä sitten Omarchy uudelleen, jotta kumpikin ympäristömuutos tulee voimaan.

### Miten saan kaiuttimet + verkkokameran toimimaan Apple Studio Display -näytössäni?

Luulisi, että kaiken pitäisi toimia vain kytkemällä USB C, mutta valitettavasti niin ei ole. Ratkaisu, jonka olen löytänyt saamaan sen toimimaan luotettavasti, on käyttää [WJESOG DisplayPort + USB-A => USB-C -kaapelia](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Sitten kaiuttimet ja verkkokamera toimivat kuin unelma.

Muista, että Omarchyssä on sisäänrakennettu kirkkauden säätö Apple-näytöille (sekä Studio että XDR) tavallisilla näppäimistön kirkkausnäppäimillä.

### Miten pääsen eroon kaikista ylimääräisistä ohjelmistoista?

Jos et halua ohjelmia kuten Obsidian tai LibreOffice tai mitään muuta esiasennettua tavaraa, voit poistaa ne todella helposti.

Suorita _Remove > Package_ nähdäksesi jokaisen asennetun paketin. Sitten voit valita tab-näppäimellä minkä tahansa paketin, jonka haluat poistaa, ja aloittaa kaiken valitsemasi poistamisen return-näppäimellä.

Ja voit käyttää Omarchy-valikon kohtaa _Remove > Web App_ poistaaksesi mitkä tahansa esiasennetut verkkosovellukset, joita et halua.

Tai suorita _Remove > Preinstalls_ lakaistaksesi kaikki esiasennetut lisät — verkkosovellukset, TUI:t ja valinnaiset sovellukset — pois yhdellä kertaa. Niitä käynnistäneet pikanäppäimet katoavat niiden mukana, joten jäljelle jää puhdas pöytä sidontoja täytettäväksi omillasi tiedostossa `~/.config/hypr/bindings.lua`.

---

Virheitä ja rikkinäisiä kohtia varten katso [Vianmääritys-osio](45-troubleshooting.md).
