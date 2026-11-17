# Selaimet

Omarchy toimitetaan [Google Chrome](https://www.google.com/chrome/) oletusselaimena. Se on teemoitettu vastaamaan muuta järjestelmääsi, ja juuri se aukeaa näppäinyhdistelmällä `Super + Shift + Return` ja sen sisällä toimii jokainen [verkkosovellus](25-web-apps.md). Se avautuu suoraan selainikkunaan: ei tervetulonäkymää eikä kirjautumiskehotetta, käyttötilastoja ja kaatumisraportteja ei lähetetä Googlelle, ja mainosten yksityisyyskehotteet on kytketty pois päältä. Voit silti kirjautua Google-tilillesi profiilipainikkeesta milloin tahansa, kun haluat synkronoinnin.

Jos Chrome ei ole mieleesi, et ole jumissa sen kanssa. Omarchy-valikon kohdasta _Install > Browser_ löydät [Chromium](https://www.chromium.org/) (pelkän avoimen lähdekoodin version, josta Chrome on tehty), Edge, Brave, Brave Origin, Firefox ja [Zen](https://zen-browser.app/). Valitse yksi, niin Omarchy asentaa sen, määrittää sen käytäntöhakemiston ja ottaa nykyisen teemasi käyttöön siinä.

## Tee yhdestä oletus

Selaimen asentaminen ei tee siitä oletusta. Kun se on koneella, siirry kohtaan _Setup > Defaults > Browser_ ja valitse se — valikossa näkyvät vain selaimet, jotka sinulla todella on asennettuna, ja nykyinen oletus on merkitty valintamerkillä.

Terminaalista se käy näin:

```bash
omarchy default browser firefox
```

Aja se ilman argumenttia, niin se kertoo nykyisen oletuksen. Tämä asettaa XDG-käsittelijän, joten mukana eivät seuraa vain Omarchyn pikanäppäimet — kaikki linkin avaava, keskustelusovelluksesta terminaalikomentoon, siirtyy valitsemaasi selaimeen.

## Copy URL ja Download Video

Chromium-perheen selaimissa (itse Chromium, Chrome, Edge ja Brave) on kaksi Omarchy-laajennusta, jotka ulottuvat selaimen ulkopuolelle muuhun järjestelmääsi.

**Copy URL** asettaa nykyisen välilehden osoitteen leikepöydällesi näppäinyhdistelmällä `Alt + Shift + L`. Se on nopeampaa kuin osoitepalkin napsauttaminen ja kopioiminen, ja koska se kulkee järjestelmän leikepöydän eikä selaimen leikepöydän kautta, saat Omarchy-ilmoituksen vahvistukseksi ja URL on heti käytettävissä [leikepöytähistoriassa](08-unified-clipboard-history.md) ja jokaisessa muussa sovelluksessa. Työkalupalkissa on myös painike, jos napsauttaminen miellyttää enemmän.

**Download Video** nappaa katselemallasi sivulla toistettavan videon näppäinyhdistelmällä `Alt + Shift + D`. Se luovuttaa URL-osoitteen [yt-dlp](https://github.com/yt-dlp/yt-dlp):lle, joten se toimii paljon muuallakin kuin YouTubessa, ja lataus päätyy kansioon `~/Videos`. Edistyminen näkyy samassa näytöllä esitettävässä ilmaisimessa, jota äänenvoimakkuus ja kirkkaus käyttävät, ja se päivittyy paikallaan ilmoituksia pinoamatta. Aseta `OMARCHY_YTDLP_DIR`, jos haluat tiedostojen menevän mieluummin muualle — katso [UKK](46-faq.md):sta, mihin ympäristömuuttujat laitetaan.

Molemmat laajennukset keskustelevat Omarchyn kanssa pienen natiivin viestivälittäjän kautta, joka asennetaan puolestasi selaimen mukana. Se on se osa, jonka ansiosta verkkosivun video voi päätyä kotihakemistoosi ja URL leikepöydänhallintaasi, mihin tavallinen laajennus ei yksin pysty.

Nämä ovat vain Chromium-perheelle. Firefox ja Zen eivät niitä saa.

## Firefox ja Zen

Firefox ja Zen ovat eri perhettä, joten niitä kohdellaan eri tavalla: Omarchy asentaa käytäntötiedoston järkeville oletuksille ja kytkee ne natiiviin Wayland-tilaan, jonka haluat murtoskaalausta ja sujuvaa kosketuslevyllä vieritystä varten.

Ne eivät saa edellä mainittuja Chromium-laajennuksia, eikä Omarchy teemoita niitä, joten nuo kokemuksen osat jäävät sinun määritettäviksesi.

## Selaimen poistaminen

Minkä tahansa näistä selaimista, Chrome mukaan lukien, voi poistaa uudelleen kohdasta _Remove > Browser_. Linkit siirtyvät sen jälkeen Chromeen tai Chromiumiin, jos toinen niistä on yhä asennettuna.
