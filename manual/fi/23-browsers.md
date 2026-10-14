# Selaimet

Omarchyssa on oletusselaimena [Chromium](https://www.chromium.org/). Se on tavallinen avoimen lähdekoodin koontiversio, teemoitettu vastaamaan muuta järjestelmääsi, ja se on se, minkä `Super + Shift + Return` avaa ja jonka sisällä jokainen [verkkosovellus](25-web-apps.md) toimii.

Jos Chromium ei ole makusi, et ole jumissa sen kanssa. Omarchy-valikon kohdasta _Asenna > Selain_ löydät Chromen, Edgen, Braven, Brave Originin, Firefoxin ja [Zenin](https://zen-browser.app/). Valitse yksi, niin Omarchy asentaa sen, ottaa käyttöön sen käytäntöhakemiston ja soveltaa nykyistä teemaasi siihen.

## Yhden tekeminen oletukseksi

Selaimen asentaminen ei ylennä sitä. Kun se on koneella, siirry kohtaan _Asetukset > Oletukset > Selain_ ja valitse se — valikko listaa vain selaimet, jotka sinulla on oikeasti asennettuina, ja merkitsee nykyisen oletuksen valintamerkillä.

Päätteestä se on:

```bash
omarchy default browser firefox
```

Aja se ilman argumenttia, niin se kertoo nykyisen oletuksen. Tämä asettaa XDG-käsittelijän, joten eivät vain Omarchyn pikanäppäimet seuraa mukana — kaikki, mikä avaa linkin, chat-soveluksesta päätekomentoon, menee valitsemallesi selaimelle.

## Kopioi URL ja lataa video

Chromium-perheen selainten (itse Chromium, Chrome, Edge ja Brave) mukana tulee kaksi Omarchy-laajennusta, jotka ulottuvat selaimen ulkopuolelle muuhun järjestelmääsi.

**Copy URL** laittaa nykyisen välilehden osoitteen leikepöydällesi näppäimillä `Alt + Shift + L`. Se on nopeampaa kuin osoitepalkin napsauttaminen ja kopioiminen, ja koska se kulkee järjestelmän leikepöydän eikä selaimen oman kautta, saat siitä Omarchy-ilmoituksen vahvistukseksi ja URL on heti saatavilla [leikepöydän historiassa](08-unified-clipboard-history.md) ja jokaisessa muussa sovelluksessa. Myös työkalupalkin painike on olemassa, jos napsauttaminen miellyttää enemmän.

**Download Video** nappaa katsomallasi sivulla toistettavan videon näppäimillä `Alt + Shift + D`. Se luovuttaa URL:n [yt-dlp](https://github.com/yt-dlp/yt-dlp):lle, joten se toimii monessa muussakin kuin YouTubessa, ja lataus päätyy hakemistoon `~/Videos`. Edistyminen näkyy samassa näyttöruutunäytössä, jota äänenvoimakkuus ja kirkkaus käyttävät, päivittyen paikallaan sen sijaan, että ilmoitukset kasautuisivat. Aseta `OMARCHY_YTDLP_DIR`, jos haluat tiedostojen menevän mieluummin muualle — katso kohdasta [UKK](46-faq.md), minne ympäristömuuttujat laitetaan.

Molemmat laajennukset keskustelevat Omarchyn kanssa pienen natiivin viestintä-isännän kautta, joka asennetaan puolestasi selaimen mukana. Juuri tuo osa saa verkkosivun videon päätymään kotihakemistoosi ja URL:n leikepöydän hallintaan, mihin tavallinen laajennus ei yksin pysty.

Nämä ovat vain Chromium-perheelle. Firefox ja Zen eivät saa niitä.

## Firefox ja Zen

Firefox ja Zen ovat eri perhettä, joten ne saavat erilaista kohtelua: Omarchy asentaa käytäntötiedoston järkeville oletuksille ja vaihtaa ne natiiviin Wayland-tilaan, jonka haluat murto-osaskaalausta ja sulavaa kosketuslevyvieritystä varten.

Ne eivät saa yllä olevia Chromium-laajennuksia, eikä Omarchy teemoita niitä, joten nuo kokemuksen osat jäävät sinun käyttöönotettaviksesi.

## Yhden poistaminen jälleen

Kaiken, minkä asensit tänne, voi ottaa jälleen pois kohdassa _Poista > Selain_. Chromium ei ole tuossa luettelossa — se on osa perusjärjestelmää.
