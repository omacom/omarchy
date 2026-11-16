# FAQ

### Miten vaihdan näppäimistöasettelujen välillä?

Muokkaa tiedostoasi `~/.config/hypr/input.lua` ja lisää tämä vaihtaaksesi asettelujen välillä näppäimillä `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Palkki näyttää nykyisen näppäimistöasettelusi automaattisesti, kun olet määrittänyt useita asetteluja (ja voit myös vaihtaa sitä napsauttamalla).

### Miten vaihdan kellon 12 tunnin muotoon?

Napsauta palkin kelloa hiiren kakkospainikkeella selataksesi yleisiä muotoja, mukaan lukien 12 tunnin muodot. Voit myös asettaa muodon suoraan:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Tämä näyttää sunnuntai 10:55 AM.

### Miten vaihdan aikavyöhykkeeni?

Aja Omarchy-valikossa _Päivitä > Aikavyöhyke_ ja valitse luettelosta. Jos aikavyöhyke on oikein, mutta kello on itse ajautunut, _Päivitä > Aika_ käynnistää ajan synkronoinnin uudelleen puolestasi.

### Miten vaihdan DNS:ni, jaan Wi-Fi:ni tai tarkistan yhteysnopeuteni?

Ne kaikki löytyvät kohdasta [verkko](35-networking.md).

### Miten tarkistan, kuinka nopea levyni on?

_Laukaisin > Nopeustesti > Levyn nopeustesti_ mittaa levysi reaaliaikaisen luku- ja kirjoitusnopeuden, tai `omarchy disk speedtest` terminaalista.

### Miten lisään tulostimen?

Tulostus on valmiina ja käynnissä heti käytön alussa, ja lisäät jokaisen tulostimen itse sovellusten käynnistimen _Tulostusasetukset_-kohdasta (`Super + Space`).

Valitse _Lisää_ ja anna sille hetki etsiä: USB:n kautta kytketty tulostin ja useimmat verkkotulostimet löytyvät puolestasi. Jos omaasi ei ole luettelossa, valitse _Verkkotulostin > Internet Printing Protocol (ipp)_ ja syötä sen osoite — tulostimen oma näyttö tai sen verkkosivu kertoo, mikä se on, yleensä jotain kuten `192.168.1.50`, jossa jono on `ipp/print`. _Eteenpäin_ tarjoaa sitten ajurin, jossa moderni tulostin toimii parhaiten ajurittomalla _IPP Everywhere_ -profiililla ja vanhempi haluaa mallin oman ajurin.

Napsauta tulostinta hiiren kakkospainikkeella ja valitse _Aseta oletukseksi_ valitaksesi, mitä niistä sovelluksesi käyttävät ensimmäisenä, ja _Ominaisuudet_ asettaaksesi paperikoon, kaksipuolisuuden ja laadun.

Automaattinen etsintä, jossa verkon tulostimet näkyvät ilman, että niitä lisätään, on tilapäisesti pois päältä, kun sitä uudistetaan, minkä vuoksi ensimmäinen vaihe yllä on sinun tehtäväsi eikä automaattinen. PDF-tiedostoon tulostaminen toimii ilman tulostintakaan.

### Miten vaihdan, minne kuvakaappaukset tai näyttötallenteet tallennetaan?

Tallennetut kuvakaappaukset menevät oletusarvoisesti kansioon `~/Pictures/Screenshots`. Jos haluat käyttää toista hakemistoa, lisää tämä tiedostoon `~/.config/uwsm/env.d/`-hakemiston alle (kuten `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Voit tehdä saman näyttötallenteille käyttämällä asetusta `OMARCHY_SCREENRECORD_DIR`.

Omasnap luo kuvakaappaushakemistonsa automaattisesti. Luo näyttötallenteiden hakemisto itse ja käynnistä sitten Omarchy uudelleen, jotta kumpikin ympäristömuutos tulee voimaan.

### Miten saan kaiuttimet + web-kameran toimimaan Apple Studio Display -näytössäni?

Luulisi, että kaiken pitäisi toimia vain kytkemällä USB C, mutta valitettavasti niin ei ole. Ratkaisu, jonka olen todennut toimivan luotettavasti, on käyttää [WJESOG DisplayPort + USB-A => USB-C -kaapelia](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Silloin kaiuttimet ja web-kamera toimivat loistavasti.

Muista, että Omarchyssa on sisäänrakennettu kirkkauden säätö Apple-näytöille (sekä Studio että XDR) tavallisilla näppäimistön kirkkausnäppäimillä.

### Miten pääsen eroon kaikista ylimääräisistä ohjelmistoista?

Jos et halua ohjelmia kuten Obsidian tai LibreOffice tai mitään muuta esiasennettua tavaraa, voit poistaa ne hyvin helposti.

Aja _Poista > Paketti_ nähdäksesi jokaisen asennetun paketin. Sitten voit valita sarkaimella minkä tahansa poistettavan paketin, ja aloittaa kaikkien valitsemiesi poistamisen return-näppäimellä.

Ja voit käyttää Omarchy-valikon kohtaa _Poista > Verkkosovellus_ poistaaksesi esiasennetut verkkosovellukset, joita et halua.

Tai aja _Poista > Esiasennetut_ lakaistaksesi kaikki esiasennetut ekstrat — verkkosovellukset, TUI:t ja valinnaiset sovellukset — yhdellä kertaa. Niitä käynnistäneet pikanäppäimet katoavat niiden mukana, joten jäljelle jää puhdas taulu sidoksia, jotka voit täyttää omillasi tiedostossa `~/.config/hypr/bindings.lua`.

---

Katso virheiden ja rikkinäisten kohtien osalta [vianmääritysosio](45-troubleshooting.md).
