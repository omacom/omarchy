# Tekstin poiminta ja sanelu

### Tekstin poiminta

Paina `Super + Ctrl + PrtScr` valitaksesi näytöltä alueen tekstin poimintaa varten. Avoimen lähdekoodin tesseract OCR-malli muuntaa valinnan sitten nopeasti tekstiksi ja sijoittaa sen leikepöydälle. Sitten painat vain `Super + V` liittääksesi sen.

Tämä on erittäin kätevää, kun poimit osoitteita kuvien alatunnisteista tai puhelinnumeroita verkkosivujen otsikoihin upotetusta tekstistä.

 ![text-extraction](images/text-extraction.webp)

### Sanelu

Uusissa asennuksissa [Superwhisper](https://superwhisper.com/) on oletussanelutaustaohjelma, joka käyttää pilvikäsittelyä ilman offline-mallien latauksia. Valitse Superwhisper, [Voxtype](https://voxtype.io/) tai [Hex](https://anoma.ly/hex/) Omarchy-valikon kohdasta _Setup > Defaults > Dictation_. Taustaohjelman valitseminen asentaa sen tarvittaessa ja tekee siitä sanelun oletuksen. Voxtype lataa englannin perusmallin, joka vie 150MB; vaihda malli komennolla `voxtype setup model` ja muita asetuksia tiedoston `~/.config/voxtype/config.toml` kautta. Superwhisper avaa asetuksensa, joista voit valita pilvi- tai paikallisen käsittelyn, ja OPR pitää sovelluksen ajan tasalla. Hex lataa laitteessa toimivan puhemallinsa asennuksen aikana ja toimii `hex.service`-käyttäjäpalveluna; avaa sen ikkuna palkin ilmaisinalueen kuvakkeesta tai suorittamalla `hex` vaihtaaksesi mallia ja muita asetuksia.

Sanele pitämällä `Right Alt` painettuna tai vaihtamalla tilaa näppäimillä `Alt + Space`, ja saneltu teksti ilmestyy kohdistettuun syöttökenttään. Nämä pikanäppäimet käyttävät valittua taustaohjelmaa. Right Alt käynnistää sanelun myös, kun sitä käytetään muokkausnäppäinyhdistelmän osana; käytä näissä yhdistelmissä Left Alt -näppäintä. Näppäimistöasetteluissa, joissa Right Alt on AltGr, myös kun tällainen asettelu on yksi niistä, joihin vaihdat, pidä sitä hetki yksinään painettuna sanelemaan; AltGr yhdessä toisen näppäimen kanssa painettuna kirjoittaa silti merkkinsä. Asennukset ajalta ennen kuin Alt + Space tuli oletukseksi säilyttävät näppäimen `F9` paina ja puhu -toiminnolle ja näppäimet `Super + Ctrl + X` vaihtamiseen, lisättynä tiedostoon `~/.config/hypr/bindings.lua`, jossa tämä `Super + Ctrl + X` korvaa agenttipaneelin; poista ne sieltä palauttaaksesi näppäimet sovelluksille ja paneelille.

Samat pikanäppäimet toimivat jokaisen taustaohjelman kanssa. Valitse taustaohjelmasi kohdasta Setup > Defaults > Dictation. Taustaohjelman asennusohjelma määrittää sen ja tallentaa valinnan. Suorita `omarchy default dictation` nähdäksesi, mikä on valittuna. Valinta tallennetaan tiedostoon `~/.config/omarchy/defaults/dictation`. Uudet asennukset valitsevat Superwhisperin automaattisesti.

Omarchy lataa valitun taustaohjelman työpöytäintegraation automaattisesti. Superwhisperin määrityksiä ei tarvita kansiossa `~/.config/hypr/`.

Mukautetut sidonnat ja skriptit voivat käyttää komentoja `omarchy dictation start`, `omarchy dictation stop` ja `omarchy dictation toggle`. Valittu taustaohjelma hoitaa tallennuksen ja transkription. Superwhisperin valitseminen poistaa käytöstä sen oman pitopikanäppäimen ja asettaa sen omaksi vaihtopikanäppäimeksi `Ctrl + Alt + Space`, jolloin se pysyy erillään Omarchyn tallennusnäppäimistä. Superwhisper vaatii vähintään yhden oman tallennuspikanäppäimen, ja sen peruutuspikanäppäin pysyy käytettävissä.

Lisätaustaohjelmat voivat integroitua muuttamatta Omarchyä. Tarjoa PATH-hakemistossa suoritettava tiedosto nimeltä `omarchy-dictation-<backend>`, joka hyväksyy komennot `start`, `stop` ja `toggle` ja palautuu nopeasti, ja palauttaa epäonnistuessaan nollasta poikkeavan tilakoodin. Sen asennusohjelma määrittää palveluntarjoajan ja kutsuu komentoa `omarchy-dictation-use <backend>` onnistuneen asennuksen jälkeen. Tämä pysäyttää edellisen taustaohjelman ja tallentaa valinnan atomisesti; `stop`-komennon on onnistuttava, kun palveluntarjoaja on käyttämättömänä tai ei ole käytettävissä. Taustaohjelmien nimissä käytetään pieniä kirjaimia, numeroita ja väliviivoja. Tarjoa asennusta varten `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` käynnistää sen. Lisää Defaults-valikon kohta Omarchy-valikon laajennuksen kautta kutsumaan kyseistä valitsinta. Valinnainen työpöytäintegraatio voi sijaita tiedostossa `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
