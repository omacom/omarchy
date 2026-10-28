# Usein kysytyt kysymykset

### Miten vaihdan näppäinasettelujen välillä?

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

Palkki näyttää automaattisesti nykyisen näppäinasettelusi, kun sinulla on useita asetteluja määritettynä (ja voit myös napsauttaa sitä vaihtaaksesi).

### Miten vaihdan kellon muodon 12 tunnin muotoon?

Napsauta palkissa olevaa kelloa hiiren kakkospainikkeella selataksesi yleisiä muotoja, mukaan lukien 12 tunnin muodot. Voit myös asettaa muodon suoraan:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Tämä näyttää Sunday 10:55 AM.

### Miten vaihdan aikavyöhykkeeni?

Aja Omarchy-valikossa _Päivitä > Aikavyöhyke_ ja valitse luettelosta. Jos aikavyöhyke on oikein mutta itse kello on ajautunut, _Päivitä > Aika_ käynnistää ajansynkronoinnin uudelleen puolestasi.

### Miten vaihdan DNS:ni, jaan Wi-Fini tai tarkistan yhteyden nopeuteni?

Ne ovat kaikki kohdassa [verkko](35-networking.md).

### Miten tarkistan, kuinka nopea levyni on?

_Käynnistä > Nopeustesti > Levyn nopeustesti_ mittaa asemasi reaaliaikaisen luku- ja kirjoitusnopeuden, tai `omarchy disk speedtest` terminaalista.

### Miksi en voi kirjautua Google-tililleni Chromiumissa?

Pelkkä avoimen lähdekoodin Chromium-koonti ei sisällä OAuth-tunnistetietoja, joita Google vaatii tilin kirjautumiseen. Aja Omarchy-valikossa _Asenna > Palvelu > Chromium Account_ lisätäksesi ne, käynnistä selain uudelleen, ja kirjautuminen menee läpi.

### Miten lisään tulostimen?

Tulostus on asetettu ja käynnissä heti, ja lisäät jokaisen tulostimen itse sovelluskäynnistimestä (`Super + Space`) kohdasta _Print Settings_.

Valitse _Add_ ja anna sille hetki etsiä: USB:n kautta kytketty tulostin ja useimmat verkkotulostimet löytyvät puolestasi. Jos omasi ei ole luettelossa, valitse _Network Printer > Internet Printing Protocol (ipp)_ ja syötä sen osoite — tulostimen oma näyttö tai sen verkkosivu kertoo, mikä se on, yleensä jotain kuten `192.168.1.50` jonolla `ipp/print`. _Forward_ tarjoaa sitten ajurin, jossa moderni tulostin toimii parhaiten ajurittomalla _IPP Everywhere_ -profiililla ja vanhempi haluaa mallin oman ajurin.

Napsauta tulostinta hiiren kakkospainikkeella ja valitse _Set as Default_ valitaksesi, mihin sovelluksesi tarttuvat ensin, ja _Properties_ asettaaksesi paperikoko, kaksipuolisuus ja laatu.

Automaattinen etsintä, jossa verkon tulostimet ilmestyvät ilman lisäämistä, on tilapäisesti pois käytöstä, kun sitä uudistetaan, minkä vuoksi yllä oleva ensimmäinen vaihe on sinun eikä automaattinen. Tulostaminen PDF-tiedostoon toimii ilman tulostinta lainkaan.

### Miten vaihdan, minne kuvakaappaukset tai näytöntallennukset tallennetaan?

Tallennetut kuvakaappaukset menevät oletuksena kansioon `~/Pictures/Screenshots`. Käyttääksesi toista hakemistoa lisää tämä tiedostoon hakemistossa `~/.config/uwsm/env.d/` (kuten `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Voit tehdä saman näytöntallennuksille käyttäen muuttujaa `OMARCHY_SCREENRECORD_DIR`.

Omasnap luo kuvakaappaushakemistonsa automaattisesti. Luo näytöntallennushakemisto itse ja käynnistä sitten Omarchy uudelleen, jotta ympäristömuutos tulee voimaan.

### Miten saan kaiuttimet ja verkkokameran toimimaan Apple Studio Displayssäni?

Luulisi, että kaiken pitäisi toimia pelkällä USB C:n kytkemisellä, mutta valitettavasti niin ei ole. Ratkaisu, jonka olen löytänyt saadakseni sen toimimaan luotettavasti, on käyttää [WJESOG DisplayPort + USB-A => USB-C -kaapelia](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Sitten kaiuttimet ja verkkokamera toimivat kuin hurmio.

Muista, että sinulla on Omarchyssa sisäänrakennettu kirkkaudensäätö Apple-näytöille (sekä Studio että XDR) tavallisilla näppäimistön kirkkauspainikkeilla.

### Miten pääsen eroon kaikesta ylimääräisestä ohjelmistosta?

Jos et halua ohjelmia kuten Obsidian tai LibreOffice tai mitään muuta esiasennettua, voit poistaa ne erittäin helposti.

Aja _Poista > Package_ nähdäksesi jokaisen asennetun paketin. Sitten voit valita minkä tahansa paketin, jonka haluat poistaa, sarkaimella ja alkaa poistaa kaikkia valitsemiasi returnilla.

Ja voit käyttää Omarchy-valikosta _Poista > Web App_ poistaaksesi minkä tahansa esiasennetuista verkkosovelluksista, joita et halua.

Tai aja _Poista > Preinstalls_ lakaistaksesi pois kaikki esiasennetut lisät — verkkosovellukset, TUI:t ja valinnaiset sovellukset — yhdellä kertaa. Niitä käynnistäneet pikanäppäimet lähtevät niiden mukana, joten sinulle jää puhdas lähtökohta sidoksille, jotka täytät omillasi tiedostossa `~/.config/hypr/bindings.lua`.

---

Virheistä ja rikkinäisistä osista katso [Vianmääritys-osio](45-troubleshooting.md).
