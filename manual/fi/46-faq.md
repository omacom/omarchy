# UKK

### Miten vaihdan näppäimistöasettelujen välillä?

Muokkaa tiedostoa `~/.config/hypr/input.lua` ja lisää tämä, jotta voit vaihtaa asettelujen välillä näppäimillä `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Palkki näyttää nykyisen näppäimistöasettelusi automaattisesti, kun olet määrittänyt useita asetteluja (ja voit vaihtaa myös napsauttamalla sitä).

### Miten muutan kellon muodon 12-tuntiseksi?

Napsauta palkin kelloa hiiren oikealla painikkeella selataksesi yleisiä muotoja, mukaan lukien 12-tuntiset muodot. Voit asettaa muodon myös suoraan:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Tämä näyttää ajan muodossa sunnuntai 10:55 AM.

### Miten vaihdan aikavyöhykkeeni?

Aja Omarchy-valikossa _Setup > Region > Timezone_ ja valitse luettelosta. Jos aikavyöhyke on oikea mutta kello itse on ajautunut väärään aikaan, _Update > Time_ käynnistää ajansynkronoinnin uudelleen puolestasi.

### Miten vaihdan DNS-asetuksiani, jaan Wi-Fi-yhteyteni tai tarkistan yhteysnopeuteni?

Ne kaikki löytyvät kohdasta [verkko](35-networking.md).

### Miten tarkistan, kuinka nopea levyni on?

_Trigger > Speed Test > Disk Speed Test_ mittaa aseman reaaliaikaisen luku- ja kirjoitusnopeuden, tai käytä päätteessä komentoa `omarchy disk speedtest`.

### Miten lisään tulostimen?

Tulostus on määritetty ja käynnissä valmiiksi, ja lisäät jokaisen tulostimen itse sovellusten käynnistimen _Print Settings_ -kohdasta (`Super + Alt + Space`).

Valitse _Add_ ja anna sille hetki aikaa etsiä: USB:n kautta kytketty tulostin ja useimmat verkkotulostimet löytyvät puolestasi. Jos omaasi ei ole luettelossa, valitse _Network Printer > Internet Printing Protocol (ipp)_ ja syötä sen osoite — tulostimen oma näyttö tai sen verkkosivu kertoo, mikä se on, yleensä jotain kuten `192.168.1.50` ja jonona `ipp/print`. _Forward_ tarjoaa sitten ajurin, jossa moderni tulostin toimii parhaiten ajurittomalla _IPP Everywhere_ -profiililla ja vanhempi haluaa mallin oman ajurin.

Napsauta tulostinta hiiren oikealla painikkeella ja valitse _Set as Default_ valitaksesi, mitä tulostinta sovelluksesi käyttävät ensin, ja _Properties_ asettaaksesi paperikoon, kaksipuolisuuden ja laadun.

Automaattinen etsintä, jossa verkon tulostimet tulevat näkyviin lisäämättä niitä, on tilapäisesti pois päältä, kun sitä uudistetaan, minkä vuoksi yllä oleva ensimmäinen vaihe on sinun tehtäväsi eikä automaattinen. Tulostaminen PDF-tiedostoon toimii ilman mitään tulostinta.

### Miten muutan, minne kuvakaappaukset tai näyttötallenteet tallennetaan?

Tallennetut kuvakaappaukset menevät oletuksena kansioon `~/Pictures/Screenshots`. Jos haluat käyttää toista hakemistoa, lisää tämä tiedostoon hakemistossa `~/.config/uwsm/env.d/` (kuten `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Voit tehdä saman näyttötallenteille käyttämällä muuttujaa `OMARCHY_SCREENRECORD_DIR`.

Omasnap luo kuvakaappaushakemistonsa automaattisesti. Luo näyttötallenteiden hakemisto itse ja käynnistä sitten Omarchy uudelleen, jotta kumpikin ympäristömuutos tulee voimaan.

### Miten saan kaiuttimet + web-kameran toimimaan Apple Studio Display -näytössäni?

Luulisi, että kaiken pitäisi toimia vain kytkemällä USB C, mutta valitettavasti näin ei ole. Ratkaisu, jonka olen löytänyt toimivan luotettavasti, on käyttää [WJESOG DisplayPort + USB-A => USB-C -kaapelia](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Sitten kaiuttimet ja web-kamera toimivat kuin unelma.

Muista, että Omarchyssä on sisäänrakennettu kirkkauden säätö Apple-näytöille (sekä Studio että XDR) tavallisilla näppäimistön kirkkauspainikkeilla.

### Miten pääsen eroon kaikista ylimääräisistä ohjelmistoista?

Jos et halua ohjelmia kuten Obsidian tai LibreOffice tai mitään muuta esiasennettua tavaraa, voit poistaa sen erittäin helposti.

Aja _Remove > Package_ nähdäksesi jokaisen asennetun paketin. Sitten voit valita tab-näppäimellä minkä tahansa paketin, jonka haluat poistaa, ja aloittaa kaiken valitsemasi poistamisen return-näppäimellä.

Ja voit käyttää Omarchy-valikon kohtaa _Remove > Web App_ poistaaksesi minkä tahansa esiasennetuista verkko-sovelluksista, joita et halua.

Tai aja _Remove > Preinstalls_ lakaistaksesi kaikki esiasennetut lisät — verkko-sovellukset, TUI:t ja valinnaiset sovellukset — yhdellä kertaa. Niitä käynnistäneet pikanäppäimet katoavat niiden mukana, joten sinulle jää puhdas pohja sidonnoille, jotka voit täyttää omillasi tiedostossa `~/.config/hypr/bindings.lua`.

---

Virheistä ja rikkinäisistä kohdista katso [vianmääritysosio](45-troubleshooting.md).
