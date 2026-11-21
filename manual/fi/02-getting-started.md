# Aloittaminen

Omarchy asennetaan ISO:n avulla. Voit valita koko levyn asennuksen, joka ottaa koko aseman haltuunsa, tai vapaan tilan asennuksen, joka sijoittaa Omarchyn aseman varaamattomaan tilaan — näin teet dual boot -asennuksen Windowsin tai toisen käyttöjärjestelmän rinnalle (katso [dual-boot-asennus](50-dual-boot-install.md) — huomaa, että sinun on ensin poistettava BitLocker käytöstä Windowsissa). Kummassakin tapauksessa asennus käyttää oletuksena täyttä salausta, ja koko levyn vaihtoehto pyyhkii valitun aseman, joten ota ehdottomasti varmuuskopio ennen kuin käytät jo olemassa olevaa asemaa!

[Lataa Omarchy ISO](https://omarchy.org/) ensin, laita se USB-tikulle (käytä Windowsissa [Rufus](https://rufus.ie/), Macissa [balenaEtcher](https://etcher.balena.io/) tai Linuxissa [caligula](https://github.com/ifd3f/caligula)) ja käynnistä kone tikulta.

_Sinun on poistettava Secure Boot ja/tai TPM käytöstä BIOSissa. Ne on poistettava käytöstä, jotta voit asentaa Omarchyn. Ne ovat Microsoftin tietoturvamenetelmiä, jotka on tarkoitettu Windowsille ja Microsoftiin kytköksissä oleville Linux-jakeluille._

Vastaa sitten määrityskysymyksiin ja vahvista ne näin:

 ![install-config](images/install-config.webp)

Valitse sitten asennukselle asema, istu alas ja seuraa asennusesitystä. Se voi valmistua alle minuutissa nopeimmilla nykyaikaisilla koneilla, mutta sen ei pitäisi kestää yli 5 minuuttia edes vanhemmalla tietokoneella.

 ![install-done](images/install-done.webp)

Nyt olet valmis Omarchyyn!

### Käytä langallista tai 2.4ghz-näppäimistöä!

Koko levyn salaus ei anna syöttää salasanaa Bluetooth-näppäimistöltä käynnistyksen yhteydessä. Aivan kuten et voi käyttää Bluetooth-näppäimistöä PC:n BIOSiin siirtymiseen. Tarvitset näppäimistön, joka käyttää joko 2.4ghz-vastaanotinta tai kaapelia (mikä on muutenkin paljon mukavampaa viiveen kannalta!). Itse rakastan [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) -näppäimistöä!

### Asentaminen toiselle omistajalle

Jos valmistelet konetta jollekin toiselle — perheenjäsenelle, uudelle työntekijälle, ostajalle — sinun ei pitäisi vastata henkilökohtaisiin kysymyksiin hänen puolestaan. Paina `Ctrl + C` asentimen aivan ensimmäisellä näytöllä (näppäimistön valinta), niin Omarchy tarjoaa mahdollisuuden valmistella koneen toiselle omistajalle sen sijaan. Järjestelmä asennetaan heti, mutta kaikki henkilökohtainen määritys — näppäimistöasettelu, käyttäjänimi, salasana — lykätään siihen asti, kun kone käynnistyy ensimmäisen kerran. Asema salataan silti oletuksena, ja salasanasta, jonka uusi omistaja valitsee tuolla ensimmäisellä käynnistyksellä, tulee myös salauksen salasana. (Myös koneen, jota olet jo käyttänyt, voi luovuttaa ilman uudelleenasennusta — katso [tietokoneen nollaaminen](48-security.md).)

### Valvomattomat asennukset

ISO voi myös asentaa kaiken täysin itsenäisesti — ilman näppäimistöä, ilman ohjattua toimintoa — kun sen määritys annetaan sille toisella asemalla. Näin Omarchyä voi käyttää peruslevykuvana VM-koneille ja koneryhmän koneille. Katso [valvomattomat asennukset](51-unattended-installs.md).

### Asennukset ilman salausta

Omarchy asennetaan oletuksena salauksen kanssa. Se on turvallinen, vastuullinen valinta jokaiselle tietokoneelle, joka voi mahdollisesti kadota tai tulla varastetuksi. Et halua kenenkään, joka pääsee käsiksi laitteistoosi, voivan saada tietojasi!

Mutta erityisissä olosuhteissa, kuten Omarchyn etäasennuksissa suojatuille tietokoneille tai kertakäyttöisissä asennuksissa ilman arkaluonteisia tietoja, saatat haluta asentaa ilman salausta. Voit painaa `Ctrl + C` levyn alustuksen vahvistuksessa vaihtaaksesi salauksettomaan asennukseen.

### Kieli

Omarchy puhuu 50 kieltä — sama valikoima kuin omarchy.org — ja englanti on oletus. Vaihtaaksesi avaa Omarchy-valikko ja siirry kohtaan _Asetukset > Alue > Kieli_, tai aja terminaalissa `omarchy language <code>` (`omarchy language list` näyttää koodit). Valikko, työpöytä ja Omarchyn omat ilmoitukset vaihtavat kielen heti, ja jokainen sen jälkeen avaamasi sovellus seuraa mukana. Jo auki olleet sovellukset vaihtavat kielen, kun käynnistät ne uudelleen.

Jos haluat pitää kielen mutta kirjoittaa päivämäärät, ajat, numerot, rahasummat, yksiköt ja paperikoot toisen alueen tavalla (esimerkiksi englanti eurooppalaisilla päivämäärillä ja 24 tunnin kellolla), valitse alue kohdassa _Asetukset > Alue > Muotoilut_, jossa jokaisen valinnan yhteydessä näkyy esimerkki, tai aja `omarchy region <code>` (`omarchy region list` näyttää koodit). _Sama kuin kieli_ palaa kielen omiin muotoiluihin. Kielenvaihdon tavoin se vaikuttaa sovelluksiin, jotka avaat sen jälkeen.

### Apua, jos jäät jumiin

Jos jäät jumiin, löydät yleensä jonkun, joka on halukas auttamaan, _#omarchy-help_-kanavalta [yhteisön Discordissa](https://omarchy.org/discord).
