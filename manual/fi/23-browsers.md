# Selaimet

Omarchy toimitetaan oletusselaimena [Google Chrome](https://www.google.com/chrome/). Se on teemoitettu vastaamaan muuta järjestelmääsi, ja sen avaa `Super + Shift + Return` (tai `Super + Shift + B`), `Super + Shift + Alt + B` avaa yksityisen ikkunan, ja sen sisällä toimii jokainen [verkkosovellus](25-web-apps.md). Se avautuu suoraan selainikkunaan: ei ole tervetulonäyttöä tai kirjautumiskehotetta, käyttötilastoja ja kaatumisraportteja ei lähetetä Googlelle, ja mainosten yksityisyyskehotteet on kytketty pois päältä. Voit silti kirjautua Google-tilillesi profiilipainikkeesta milloin tahansa, kun haluat synkronoinnin.

Jos Chrome ei ole makuusi, et ole jumissa sen kanssa. Omarchy-valikon kohdasta _Install > Browser_ löydät [Chromium](https://www.chromium.org/) (pelkän avoimen lähdekoodin version, josta Chrome on tehty), Edge, Brave, Brave Origin, Firefox ja [Zen](https://zen-browser.app/) (Edge vain x86-koneilla). Valitse yksi, niin Omarchy asentaa sen, määrittää sen käytäntöhakemiston ja soveltaa siihen nykyistä teemaasi.

## Tee yhdestä oletus

Selaimen asentaminen ei tee siitä oletusta. Vaihtaaksesi mene kohtaan _Setup > Defaults > Browser_ ja valitse yksi. Nykyinen oletus on merkitty valintamerkillä, ja sellaisen selaimen valitseminen, jota sinulla ei vielä ole, asentaa sen ensin.

Terminaalista se on:

```bash
omarchy default browser firefox
```

Suorita se ilman argumenttia, niin se kertoo nykyisen oletuksen. Tämä asettaa XDG-käsittelijän, joten pelkät Omarchyn pikanäppäimet eivät seuraa mukana — kaikki, mikä avaa linkin, keskustelusovelluksesta terminaalikomentoon, menee valitsemaasi selaimeen.

## Copy URL ja Download Video

Chromium-perheen selaimissa (itse Chromium, Chrome, Edge, Brave ja Brave Origin) on mukana kolme Omarchy-laajennusta: kaksi, jotka ulottuvat selaimesta ulos muuhun järjestelmääsi, ja yksi, joka siistii WhatsAppia.

**Copy URL** laittaa nykyisen välilehden osoitteen leikepöydällesi näppäimillä `Alt + Shift + L`. Se on nopeampaa kuin osoitepalkkiin napsauttaminen ja kopioiminen, ja koska se kulkee järjestelmän leikepöydän eikä selaimen leikepöydän kautta, saat Omarchy-ilmoituksen vahvistukseksi ja URL on heti käytettävissä [leikepöytähistoriassa](08-unified-clipboard-history.md) ja jokaisessa muussa sovelluksessa. Työkalupalkissa on myös painike, jos mieluummin napsautat.

**Download Video** nappaa katsomallasi sivulla toistettavan videon näppäimillä `Alt + Shift + D`. Se luovuttaa URL:n [yt-dlp](https://github.com/yt-dlp/yt-dlp):lle, joten se toimii paljon muuallakin kuin YouTubessa, ja lataus päätyy kansioon `~/Videos`. Edistyminen näkyy samassa näytön ilmaisimessa, jota äänenvoimakkuus ja kirkkaus käyttävät, ja se päivittyy paikallaan sen sijaan, että ilmoitukset kasautuisivat. Aseta `OMARCHY_YTDLP_DIR`, jos haluat tiedostojen menevän mieluummin muualle — katso [FAQ](46-faq.md):sta, mihin ympäristömuuttujat laitetaan.

Molemmat laajennukset keskustelevat Omarchyn kanssa pienen natiivin viestintäisännän kautta, joka asennetaan puolestasi yhdessä selaimen kanssa. Se on se osa, jonka ansiosta verkkosivun video voi päätyä kotihakemistoosi ja URL leikepöydänhallintaasi, mihin tavallinen laajennus ei yksin pysty.

**WhatsApp Slim** saa WhatsApp Webin noudattamaan järjestelmäteemaasi ja tiivistää sen keskusteluluettelon, kun ikkuna on kapea.

Nämä ovat vain Chromium-perheelle. Firefox ja Zen eivät saa niitä.

## Firefox ja Zen

Firefox ja Zen ovat eri perhettä, joten niitä kohdellaan eri tavalla: Omarchy asentaa käytäntötiedoston järkeviä oletuksia varten ja kytkee ne natiiviin Wayland-tilaan, jonka haluat murto-osasäätöä ja sujuvaa kosketuslevyn vieritystä varten.

Ne eivät saa yllä olevia Chromium-laajennuksia, eikä Omarchy teemoita niitä, joten nuo osat kokemuksesta ovat sinun määritettävissäsi.

## Sen poistaminen uudelleen

Mikä tahansa näistä selaimista, Chrome mukaan lukien, voidaan poistaa uudelleen kohdasta _Remove > Browser_. Linkit menevät sitten Chromeen tai Chromiumiin, jos toinen niistä on edelleen asennettuna.
