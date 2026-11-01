# Tekstin poiminta & sanelu

### Tekstin poiminta

Paina `Super + Ctrl + PrtScr` valitaksesi näytöltä alueen tekstin poimintaa varten. Avoimen lähdekoodin tesseract-OCR-malli muuntaa valinnan sitten nopeasti tekstiksi ja sijoittaa sen leikepöydälle. Sitten painat vain `Super + V` liittääksesi sen.

Tämä on erittäin hyödyllistä, kun haluat napata osoitteita kuvien alatunnisteista tai puhelinnumeroita verkkosivujen otsikoihin upotetusta tekstistä.

 ![text-extraction](images/text-extraction.webp)

### Sanelu

Tuoreissa asennuksissa [Superwhisper](https://superwhisper.com/) on oletussanelutausta, joka käyttää pilvikäsittelyä ilman offline-mallien latauksia. Valitse Superwhisper, [Voxtype](https://voxtype.io/) tai [Hex](https://anoma.ly/hex/) Omarchy-valikon kohdan _Setup > Defaults > Dictation_ kautta. Taustan valitseminen asentaa sen tarvittaessa ja tekee siitä sanelun oletuksen. Voxtype lataa englanninkielisen perusmallin, joka vie 150MB; vaihda malli komennolla `voxtype setup model` ja muuta muita asetuksia tiedostossa `~/.config/voxtype/config.toml`. Superwhisper avaa asetuksensa pilvi- tai paikallisen käsittelyn valitsemista varten, ja OPR pitää sovelluksen ajan tasalla. Hex lataa laitteella toimivan puhemallinsa asennuksen aikana ja toimii `hex.service`-käyttäjäpalveluna; avaa sen ikkuna palkin ilmaisinalueen kuvakkeesta tai suorittamalla `hex` vaihtaaksesi mallia ja muita asetuksia.

Sanelet pitämällä `Right Alt` pohjassa tai vaihtamalla tilaa näppäimillä `Alt + Space`, ja saneltu teksti ilmestyy kohdistettuun syöttöalueeseen. Nämä pikanäppäimet käyttävät valittua taustaa. Right Alt käynnistää sanelun myös, kun sitä käytetään muokkausnäppäinyhdistelmässä; käytä näissä yhdistelmissä Left Alt -näppäintä. Näppäimistöasetteluissa, joissa Right Alt on AltGr, käytä `Alt + Space` pitääksesi AltGr:n käytettävissä kirjoittamiseen. Asennukset, jotka on tehty ennen kuin Alt + Space tuli oletukseksi, säilyttävät `F9`-näppäimen paina ja puhu -toiminnolle ja `Super + Ctrl + X` -yhdistelmän tilan vaihtamiseen, lisättynä tiedostoon `~/.config/hypr/bindings.lua`; poista ne sieltä antaaksesi näppäimet takaisin sovellusten käyttöön.

Samat pikanäppäimet toimivat jokaisen taustan kanssa. Valitse taustasi kohdan Setup > Defaults > Dictation kautta. Taustan asennusohjelma määrittää sen ja tallentaa valinnan. Suorita `omarchy default dictation` nähdäksesi, mikä on valittuna. Valinta tallennetaan tiedostoon `~/.config/omarchy/defaults/dictation`. Tuoreet asennukset valitsevat Superwhisperin automaattisesti.

Omarchy lataa valitun taustan työpöytäintegraation automaattisesti. Superwhisperin määritystä ei tarvita hakemistossa `~/.config/hypr/`.

Mukautetut sidonnat ja skriptit voivat käyttää komentoja `omarchy dictation start`, `omarchy dictation stop` ja `omarchy dictation toggle`. Valittu tausta hoitaa nauhoituksen ja transkription. Superwhisperin valitseminen poistaa käytöstä sen oman pohjassa pidettävän pikanäppäimen ja asettaa sen omaksi tilanvaihtonäppäimeksi `Ctrl + Alt + Space`, pitäen sen erillään Omarchyn nauhoitusnäppäimistä. Superwhisper vaatii vähintään yhden oman nauhoituspikanäppäimen, ja sen peruutuspikanäppäin pysyy käytettävissä.

Lisätaustat voivat integroitua muuttamatta Omarchya. Tarjoa PATH:ssa suoritettava tiedosto nimeltä `omarchy-dictation-<backend>`, joka hyväksyy komennot `start`, `stop` ja `toggle`, palaa nopeasti ja palauttaa epäonnistuessaan nollasta poikkeavan tilan. Sen asennusohjelma määrittää tarjoajan ja kutsuu komentoa `omarchy-dictation-use <backend>` onnistuneen asennuksen jälkeen. Tämä pysäyttää edellisen taustan ja tallentaa valinnan atomisesti; `stop`-komennon on onnistuttava, kun tarjoaja on käyttämättömänä tai ei ole käytettävissä. Taustojen nimet käyttävät pieniä kirjaimia, numeroita ja väliviivoja. Tarjoa asennusta varten `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` käynnistää sen. Lisää Defaults-valikon kohta Omarchy-valikon laajennuksen kautta kutsumaan kyseistä valitsinta. Valinnainen työpöytäintegraatio voi sijaita tiedostossa `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
