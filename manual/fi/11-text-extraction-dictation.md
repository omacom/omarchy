# Tekstin poiminta ja sanelu

### Tekstin poiminta

Paina `Super + Ctrl + PrtScr` valitaksesi näytöltä alueen tekstin poimintaa varten. Avoimen lähdekoodin tesseract OCR-malli muuntaa valinnan sitten nopeasti tekstiksi ja sijoittaa sen leikepöydälle. Sitten painat vain `Super + V` liittääksesi sen.

Tämä on erittäin hyödyllistä, kun haluat napata osoitteita kuvien alatunnisteista tai puhelinnumeroita verkkosivustojen otsikoihin upotettuna.

 ![text-extraction](images/text-extraction.webp)

### Sanelu

Uusissa asennuksissa [Superwhisper](https://superwhisper.com/) on oletussanelutaustajärjestelmä, joka käyttää pilvikäsittelyä ilman offline-mallien latauksia. Valitse Superwhisper tai [Voxtype](https://voxtype.io/) Omarchy-valikosta kohdasta _Setup > Defaults > Dictation_. Taustajärjestelmän valinta asentaa sen tarvittaessa ja tekee siitä sanelun oletuksen. Voxtype lataa englannin perusmallin, joka vie 150MB; vaihda malli komennolla `voxtype setup model` ja muuta muita asetuksia tiedoston `~/.config/voxtype/config.toml` kautta. Superwhisper avaa asetuksensa, joissa voit valita pilvi- tai paikallisen käsittelyn, ja OPR pitää sovelluksen ajan tasalla.

Sanele pitämällä `Right Alt` pohjassa tai kytkemällä sanelu näppäimillä `Alt + Space`, ja sanelemasi teksti ilmestyy kohdistettuun syöttökenttään. Nämä pikanäppäimet käyttävät valittua taustajärjestelmää. Oikea Alt käynnistää sanelun myös, kun sitä käytetään muokkausnäppäinyhdistelmässä; käytä noissa yhdistelmissä vasenta Altia. Näppäimistöasetteluissa, joissa oikea Alt on AltGr, käytä `Alt + Space` pitääksesi AltGr:n käytettävissä kirjoittamiseen. Asennukset ajalta ennen kuin Alt + Space -yhdistelmästä tuli oletus säilyttävät näppäimet `F9` paina ja puhu -toiminnolle ja `Super + Ctrl + X` kytkemiselle, lisättynä tiedostoon `~/.config/hypr/bindings.lua`; poista ne sieltä antaaksesi näppäimet takaisin sovelluksille.

Samat pikanäppäimet toimivat kummallakin taustajärjestelmällä. Valitse taustajärjestelmäsi kohdasta Setup > Defaults > Dictation. Taustajärjestelmän asennusohjelma määrittää sen ja tallentaa valinnan. Aja `omarchy default dictation` nähdäksesi, kumpi on valittuna. Valinta tallennetaan tiedostoon `~/.config/omarchy/defaults/dictation`. Uudet asennukset valitsevat Superwhisperin automaattisesti.

Omarchy lataa valitun taustajärjestelmän työpöytäintegraation automaattisesti. Superwhisperin määrityksiä ei tarvita hakemistossa `~/.config/hypr/`.

Mukautetut sidonnat ja skriptit voivat käyttää komentoja `omarchy dictation start`, `omarchy dictation stop` ja `omarchy dictation toggle`. Valittu taustajärjestelmä hoitaa tallennuksen ja transkription. Superwhisperin valinta poistaa sen oman pohjassa pidettävän pikanäppäimen käytöstä ja asettaa sen omaksi kytkentäpikanäppäimeksi `Ctrl + Alt + Space` pitäen sen erillään Omarchyn tallennusnäppäimistä. Superwhisper vaatii vähintään yhden oman tallennuspikanäppäimen, ja sen peruutuspikanäppäin pysyy käytettävissä.

Lisätaustajärjestelmät voivat integroitua muuttamatta Omarchya. Tarjoa PATH:ssa suoritettava tiedosto nimeltä `omarchy-dictation-<backend>`, joka hyväksyy argumentit `start`, `stop` ja `toggle` ja palaa ripeästi, epäonnistuessaan nollasta poikkeavalla tilalla. Sen asennusohjelma määrittää palveluntarjoajan ja kutsuu komentoa `omarchy-dictation-use <backend>` onnistuneen asennuksen jälkeen. Tämä pysäyttää edellisen taustajärjestelmän ja tallentaa valinnan atomisesti; `stop`-komennon on onnistuttava, kun palveluntarjoaja on käyttämättömänä tai ei ole käytettävissä. Taustajärjestelmien nimissä käytetään pieniä kirjaimia, numeroita ja yhdysmerkkejä. Tarjoa asennusta varten `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` käynnistää sen. Lisää Defaults-valikkoon merkintä Omarchy-valikon laajennuksen kautta kutsumaan kyseistä valitsinta. Valinnainen työpöytäintegraatio voi sijaita polussa `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
