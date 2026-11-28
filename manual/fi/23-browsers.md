# Selaimet

Omarchy toimitetaan [Google Chrome](https://www.google.com/chrome/) oletusselaimena. Se on teemoitettu vastaamaan muuta järjestelmääsi, ja se on selain, joka avautuu näppäimillä `Super + Shift + Return` (tai `Super + Shift + B`), yksityiseen ikkunaan näppäimillä `Super + Shift + Alt + B`, ja sen sisällä jokainen [verkkosovellus](25-web-apps.md) toimii. Se avautuu suoraan selainikkunaan: ei ole tervetulonäyttöä tai kirjautumiskehotetta, käyttötilastoja ja kaatumisraportteja ei lähetetä Googlelle, ja mainosten yksityisyyskehotteet on kytketty pois päältä. Voit silti kirjautua Google-tilillesi profiilipainikkeesta milloin tahansa, kun haluat synkronoinnin.

Jos Chrome ei ole makuusi, et ole jumissa sen kanssa. Omarchy-valikon kohdasta _Install > Browser_ löydät [Chromiumin](https://www.chromium.org/) (pelkän avoimen lähdekoodin version, josta Chrome on tehty), Edgen, Braven, Brave Originin, Firefoxin, [Zenin](https://zen-browser.app/) ja [Ladybirdin](https://ladybird.org/) (Edge vain x86-koneilla). Valitse yksi, niin Omarchy asentaa sen, määrittää sen policy-hakemiston ja soveltaa siihen nykyistä teemaasi.

## Yhden asettaminen oletukseksi

Selaimen asentaminen ei tee siitä oletusta. Vaihtaaksesi siirry kohtaan _Setup > Defaults > Browser_ ja valitse yksi. Nykyinen oletus on merkitty valintamerkillä, ja jos valitset selaimen, jota sinulla ei vielä ole, se asennetaan ensin.

Terminaalista se onnistuu näin:

```bash
omarchy default browser firefox
```

Aja se ilman argumenttia, niin se kertoo nykyisen oletuksen. Tämä asettaa XDG-käsittelijän, joten eivät vain Omarchy-pikanäppäimet seuraa mukana — kaikki linkkejä avaavat ohjelmat, chat-sovelluksesta terminaalikomentoon, käyttävät valitsemaasi selainta.

## Copy URL ja Download Video

Chromium-perheen selaimissa (itse Chromium, Chrome, Edge, Brave ja Brave Origin) on mukana kolme Omarchy-laajennusta: kaksi, jotka ulottuvat selaimen ulkopuolelle muuhun järjestelmääsi, ja yksi, joka siistii WhatsAppia.

**Copy URL** laittaa nykyisen välilehden osoitteen leikepöydällesi näppäimillä `Alt + Shift + L`. Se on nopeampaa kuin osoitepalkin napsauttaminen ja kopioiminen, ja koska se kulkee järjestelmän leikepöydän eikä selaimen oman kautta, saat Omarchy-ilmoituksen vahvistuksena ja URL on heti käytettävissä [leikepöydän historiassa](08-unified-clipboard-history.md) ja jokaisessa muussa sovelluksessa. Työkalupalkissa on myös painike, jos napsauttaminen on enemmän mieleesi.

**Download Video** nappaa katsomallasi sivulla toistettavan videon näppäimillä `Alt + Shift + D`. Se välittää URL-osoitteen [yt-dlp](https://github.com/yt-dlp/yt-dlp)-ohjelmalle, joten se toimii paljon useammilla sivustoilla kuin vain YouTubessa, ja lataus päätyy kansioon `~/Videos`. Edistyminen näkyy samassa ruutunäytössä, jota äänenvoimakkuus ja kirkkaus käyttävät, päivittyen paikallaan ilmoituksia pinomatta. Aseta `OMARCHY_YTDLP_DIR`, jos haluat tiedostojen päätyvän mieluummin jonnekin muualle — katso [FAQ](46-faq.md), mistä näet, mihin ympäristömuuttujat laitetaan.

Molemmat laajennukset keskustelevat Omarchyn kanssa pienen natiivin viestintäisännän kautta, joka asennetaan puolestasi selaimen mukana. Juuri sen ansiosta verkkosivun video voi päätyä kotihakemistoosi ja URL leikepöydänhallintaasi, mihin tavallinen laajennus ei yksin pysty.

**WhatsApp Slim** saa WhatsApp Webin noudattamaan järjestelmäsi teemaa ja kutistaa sen chat-listan, kun ikkuna on kapea.

Nämä ovat vain Chromium-perheelle. Firefox ja Zen eivät niitä saa.

## Firefox ja Zen

Firefox ja Zen ovat eri perhettä, joten niitä kohdellaan eri tavalla: Omarchy asentaa niille policies-tiedoston järkeviä oletuksia varten ja vaihtaa ne natiiviin Wayland-tilaan, jonka haluat murtoskaalausta ja sujuvaa kosketuslevyllä vierittämistä varten.

Ne eivät saa yllä mainittuja Chromium-laajennuksia, eikä Omarchy teemoita niitä, joten nuo osat kokemuksesta jäävät sinun itsesi asetettaviksi.

## Ladybird

Ladybird on alusta asti itse kirjoitettu selain, jossa on oma moottorinsa Chromiumin tai Firefoxin moottorin sijaan. Se on yhä alfavaiheessa, joten varaudu sivustoihin, jotka eivät vielä toimi, ja Omarchy asentaa sen sellaisenaan: ei laajennuksia, ei teemaa, ei policies-määrityksiä. Siinä ei ole myöskään yksityistä ikkunaa, joten `Super + Shift + Alt + B` avaa sen väliaikaisella profiililla, joka poistetaan, kun suljet sen. [Verkkosovellukset](25-web-apps.md) toimivat edelleen Chromessa tai Chromiumissa.

## Selaimen poistaminen

Mikä tahansa näistä selaimista, Chrome mukaan lukien, voidaan poistaa taas kohdassa _Remove > Browser_. Linkit ohjautuvat sen jälkeen Chromeen tai Chromiumiin, jos toinen niistä on yhä asennettuna.
