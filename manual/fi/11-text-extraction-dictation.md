# Tekstin poiminta & sanelu

### Tekstin poiminta

Paina `Super + Ctrl + PrtScr` valitaksesi näytöltä alueen tekstin poimintaa varten. Avoimen lähdekoodin tesseract OCR-malli muuntaa valinnan sitten nopeasti tekstiksi ja sijoittaa sen leikepöydälle. Sitten painat vain `Super + V` liittääksesi.

Tästä on paljon apua, kun poimit osoitteita kuvien alatunnisteista tai verkkosivujen otsikoihin upotettuja puhelinnumeroita.

 ![text-extraction](images/text-extraction.webp)

### Sanelu

Uusissa asennuksissa [Superwhisper](https://superwhisper.com/) on oletussanelutausta, joka käyttää pilvikäsittelyä ilman offline-mallien latauksia. Valitse Superwhisper, [Voxtype](https://voxtype.io/) tai [Hex](https://anoma.ly/hex/) Omarchy-valikon kohdasta _Setup > Defaults > Dictation_. Taustan valitseminen asentaa sen tarvittaessa ja tekee siitä sanelun oletuksen. Voxtype lataa englannin perusmallin, joka vie 150MB; vaihda mallia komennolla `voxtype setup model` ja muita asetuksia tiedostossa `~/.config/voxtype/config.toml`. Superwhisper avaa asetuksensa pilvi- tai paikallisen käsittelyn valitsemista varten, ja OPR pitää sovelluksen ajan tasalla. Hex lataa laitteessa toimivan puhemallinsa asennuksen aikana ja toimii `hex.service`-käyttäjäpalveluna; avaa sen ikkuna palkin ilmaisinalueen kuvakkeesta tai suorittamalla `hex` vaihtaaksesi mallia ja muita asetuksia.

Sanelet pitämällä `Right Alt` pohjassa tai vaihtamalla tilaa näppäimillä `Alt + Space`, ja sanelemasi teksti ilmestyy kohdistettuun syöttökenttään. Nämä pikanäppäimet käyttävät valittua taustaa. Right Alt käynnistää sanelun myös, kun sitä käytetään muokkausnäppäinyhdistelmässä; käytä niihin yhdistelmiin Left Alt -näppäintä. Näppäimistöasetteluissa, joissa Right Alt on AltGr, käytä `Alt + Space`, jotta AltGr pysyy käytettävissä kirjoittamiseen. Asennukset ajalta ennen kuin Alt + Space tuli oletukseksi säilyttävät paina-ja-puhu-näppäimenä `F9` ja vaihtamiseen `Super + Ctrl + X`, lisättynä tiedostoon `~/.config/hypr/bindings.lua`, jossa tuo `Super + Ctrl + X` korvaa agenttipaneelin; poista ne sieltä antaaksesi näppäimet takaisin sovelluksille ja paneelille.

Samat pikanäppäimet toimivat jokaisen taustan kanssa. Valitse taustasi kohdasta Setup > Defaults > Dictation. Taustan asennusohjelma määrittää sen ja tallentaa valinnan. Suorita `omarchy default dictation` nähdäksesi, mikä on valittuna. Valinta tallennetaan tiedostoon `~/.config/omarchy/defaults/dictation`. Uudet asennukset valitsevat Superwhisperin automaattisesti.

Omarchy lataa valitun taustan työpöytäintegraation automaattisesti. Superwhisperin määrityksiä ei tarvita kansiossa `~/.config/hypr/`.

Mukautetut sidokset ja skriptit voivat käyttää komentoja `omarchy dictation start`, `omarchy dictation stop` ja `omarchy dictation toggle`. Valittu tausta hoitaa tallennuksen ja litteroinnin. Superwhisperin valitseminen poistaa käytöstä sen oman pohjassa pidettävän pikanäppäimen ja asettaa sen omaksi vaihtopikanäppäimeksi `Ctrl + Alt + Space`, jolloin se pysyy erillään Omarchyn tallennusnäppäimistä. Superwhisper vaatii vähintään yhden oman tallennuspikanäppäimen, ja sen peruutuspikanäppäin pysyy käytettävissä.

Lisätaustat voivat integroitua muuttamatta Omarchya. Tarjoa PATH-hakemistossa suoritettava tiedosto nimeltä `omarchy-dictation-<backend>`, joka hyväksyy parametrit `start`, `stop` ja `toggle`, palaa nopeasti ja palauttaa virhetilanteessa nollasta poikkeavan tilan. Sen asennusohjelma määrittää palveluntarjoajan ja kutsuu komentoa `omarchy-dictation-use <backend>` onnistuneen asennuksen jälkeen. Tämä pysäyttää edellisen taustan ja tallentaa valinnan atomisesti; `stop`-komennon on onnistuttava, kun palveluntarjoaja on käyttämättömänä tai ei ole käytettävissä. Taustojen nimissä käytetään pieniä kirjaimia, numeroita ja yhdysmerkkejä. Tarjoa asennusta varten `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` käynnistää sen. Lisää Defaults-valikkoon merkintä Omarchy-valikkolaajennuksen kautta kutsumaan kyseistä valitsinta. Valinnainen työpöytäintegraatio voi sijaita polussa `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
