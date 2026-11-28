# Aloittaminen

Omarchy asennetaan ISO-tiedoston avulla. Voit valita koko levyn asennuksen, joka ottaa koko levyn haltuunsa, tai vapaan tilan asennuksen, joka sijoittaa Omarchyn levyn varaamattomaan tilaan — näin teet kaksoiskäynnistyksen Windowsin tai toisen käyttöjärjestelmän rinnalla (katso [kaksoiskäynnistysasennus](50-dual-boot-install.md) — huomaa, että sinun on ensin poistettava BitLocker käytöstä Windowsissa). Kummassakin tapauksessa asennus käyttää oletuksena täyttä salausta, ja koko levyn vaihtoehto pyyhkii valitun levyn, joten muista ottaa varmuuskopio ennen olemassa olevan levyn käyttämistä!

Apple Silicon Macilla asennat sen sen sijaan macOS:stä, ilman ISO-tiedostoa tai USB-tikkua. Katso [Omarchy Apple Siliconille](44-mac-support.md#omarchy-for-apple-silicon).

[Lataa Omarchy ISO](https://omarchy.org/) ensin, laita se USB-tikulle (käytä Windowsissa [Rufus](https://rufus.ie/), Macilla [balenaEtcher](https://etcher.balena.io/) tai Linuxissa [caligula](https://github.com/ifd3f/caligula)) ja käynnistä kone tikulta.

_Sinun on poistettava Secure Boot ja/tai TPM käytöstä BIOSissa. Sinun on poistettava ne käytöstä, jotta voit asentaa Omarchyn. Ne ovat Microsoftin suojausjärjestelmiä, jotka on tarkoitettu Windowsille ja Microsoftiin kytköksissä oleville Linux-jakeluille._

Vastaa sitten määrityskysymyksiin ja vahvista ne näin:

 ![install-config](images/install-config.webp)

Valitse sitten levy asennusta varten, istu alas ja katso asennusshow'ta. Se voi valmistua alle minuutissa nopeimmilla nykyaikaisilla koneilla, mutta sen ei pitäisi kestää yli 5 minuuttia edes vanhemmalla tietokoneella.

 ![install-done](images/install-done.webp)

Nyt olet valmis Omarchyyn!

### Käytä langallista tai 2.4ghz-näppäimistöä!

Koko levyn salaus ei anna sinun syöttää salasanaa Bluetooth-näppäimistöltä käynnistyksen yhteydessä. Aivan kuten et voi käyttää Bluetooth-näppäimistöä PC:n BIOSiin siirtymiseen. Tarvitset näppäimistön, joka käyttää joko 2.4ghz-donglea tai kaapelia (mikä on muutenkin paljon mukavampaa latenssin kannalta!). Itse rakastan [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) -näppäimistöä!

### Asentaminen toiselle omistajalle

Jos valmistelet konetta jollekin toiselle — perheenjäsenelle, uudelle työntekijälle, ostajalle — sinun ei pitäisi vastata henkilökohtaisiin kysymyksiin heidän puolestaan. Paina `Ctrl + C` asennusohjelman aivan ensimmäisellä näytöllä (näppäimistön valinnassa), niin Omarchy tarjoaa mahdollisuuden valmistella kone toiselle omistajalle. Järjestelmä asentuu heti, mutta kaikki henkilökohtainen määritys — näppäimistöasettelu, käyttäjänimi, salasana — lykkääntyy, kunnes kone käynnistyy ensimmäisen kerran. Levy salataan silti oletuksena, ja salasanasta, jonka uusi omistaja valitsee ensimmäisellä käynnistyksellä, tulee myös salauksen salasana. (Jo käyttämäsi kone voidaan luovuttaa myös ilman uudelleenasennusta — katso [tietokoneen nollaaminen](48-security.md).)

### Valvomattomat asennukset

ISO voi asentua myös täysin itsestään — ilman näppäimistöä, ilman ohjattua toimintoa — kun sille annetaan määrityksensä toisella levyllä. Näin Omarchya kannattaa käsitellä VM-koneiden ja konelaivueiden peruslevykuvana. Katso [valvomattomat asennukset](51-unattended-installs.md).

### Asennukset ilman salausta

Omarchy asennetaan oletuksena salauksen kanssa. Se on turvallinen ja vastuullinen valinta mille tahansa tietokoneelle, joka voi mahdollisesti kadota tai tulla varastetuksi. Et halua, että kukaan, joka pääsee käsiksi laitteistoosi, voisi saada tietosi haltuunsa!

Mutta erityistilanteissa, kuten Omarchyn etäasennuksissa suojatuille tietokoneille tai kertakäyttöisissä asennuksissa ilman arkaluonteisia tietoja, saatat haluta asentaa ilman salausta. Voit painaa `Ctrl + C` levyn alustuksen vahvistuksessa vaihtaaksesi salauksettoman asennukseen.

### Kieli

Omarchy puhuu 50 kieltä — sama valikoima kuin omarchy.org:ssa — ja englanti on oletus. Vaihtaaksesi avaa Omarchy-valikko ja siirry kohtaan _Asetukset > Alue > Kieli_ tai suorita terminaalissa `omarchy language <code>` (`omarchy language list` näyttää koodit). Valikko, työpöytä ja Omarchyn omat ilmoitukset vaihtavat kielen heti, ja jokainen sen jälkeen avaamasi sovellus seuraa mukana. Jo auki olleet sovellukset vaihtavat, kun käynnistät ne uudelleen.

Jos haluat säilyttää kielen mutta kirjoittaa päivämäärät, kellonajat, luvut, rahasummat, yksiköt ja paperikoot niin kuin toisella alueella tehdään (esimerkiksi englanti eurooppalaisilla päivämäärillä ja 24 tunnin kellolla), valitse alue kohdassa _Asetukset > Alue > Muotoilut_, jossa jokaisen vaihtoehdon kohdalla näkyy esimerkki, tai suorita `omarchy region formats <code>` (`omarchy region formats list` näyttää koodit). _Sama kuin kieli_ palaa kielen omiin muotoiluihin. Kielenvaihdon tavoin se koskee sovelluksia, jotka avaat sen jälkeen.

### Apua, jos jäät jumiin

Jos jäät jumiin, löydät yleensä jonkun, joka on valmis auttamaan, _#omarchy-help_-kanavalta [yhteisön Discordissa](https://omarchy.org/discord).
