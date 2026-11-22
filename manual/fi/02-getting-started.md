# Aloittaminen

Omarchy asennetaan ISO-tiedoston avulla. Voit valita täyden levyn asennuksen, joka ottaa haltuunsa koko aseman, tai vapaan tilan asennuksen, joka sijoittaa Omarchyn aseman varaamattomaan tilaan — näin teet dual boot -asennuksen Windowsin tai toisen käyttöjärjestelmän rinnalle (katso [dual-boot-asennus](50-dual-boot-install.md) — huomaa, että sinun on ensin poistettava BitLocker käytöstä Windowsissa). Kummassakin tapauksessa asennus käyttää oletusarvoisesti täyttä salausta, ja täyden levyn vaihtoehto pyyhkii valitun aseman, joten muista ottaa varmuuskopio ennen kuin käytät olemassa olevaa asemaa!

[Lataa Omarchy-ISO](https://omarchy.org/) ensin, laita se USB-tikulle (käytä [Rufus](https://rufus.ie/)-ohjelmaa Windowsissa, [balenaEtcher](https://etcher.balena.io/)-ohjelmaa Macissa tai [caligula](https://github.com/ifd3f/caligula)-ohjelmaa Linuxissa) ja käynnistä tikulta.

_Sinun on poistettava Secure Boot ja/tai TPM käytöstä BIOSissa. Sinun on poistettava ne käytöstä, jotta voit asentaa Omarchyn. Ne ovat Microsoftin tietoturvamenetelmiä, jotka on tarkoitettu Windowsille ja Microsoftiin kytköksissä oleville Linux-jakeluille._

Vastaa sitten määrityskysymyksiin ja vahvista ne näin:

 ![install-config](images/install-config.webp)

Valitse sitten asema asennusta varten, istu alas ja seuraa asennusnäytöstä. Se voi valmistua alle minuutissa nopeimmilla nykyaikaisilla koneilla, mutta sen ei pitäisi kestää yli 5 minuuttia edes vanhemmalla tietokoneella.

 ![install-done](images/install-done.webp)

Nyt olet valmis Omarchyyn!

### Käytä langallista tai 2.4ghz-näppäimistöä!

Täyden levyn salaus ei salli salasanan syöttämistä Bluetooth-näppäimistöltä käynnistyksen yhteydessä. Aivan kuten et voi käyttää Bluetooth-näppäimistöä BIOSiin siirtymiseen PC:llä. Tarvitset näppäimistön, joka käyttää joko 2.4ghz-vastaanotinta tai kaapelia (mikä on muutenkin paljon mukavampaa viiveen kannalta!). Itse rakastan [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) -näppäimistöä!

### Asentaminen toiselle omistajalle

Jos olet asentamassa konetta jollekin toiselle — perheenjäsenelle, uudelle työntekijälle, ostajalle — sinun ei pitäisi vastata henkilökohtaisiin kysymyksiin hänen puolestaan. Paina `Ctrl + C` asennusohjelman aivan ensimmäisessä näytössä (näppäimistön valinnassa), ja Omarchy tarjoaa mahdollisuuden valmistella kone sen sijaan toiselle omistajalle. Järjestelmä asennetaan heti, mutta kaikki henkilökohtainen määritys — näppäimistöasettelu, käyttäjänimi, salasana — lykätään siihen asti, kun kone käynnistetään ensimmäisen kerran. Asema salataan silti oletusarvoisesti, ja salasanasta, jonka uusi omistaja valitsee ensimmäisellä käynnistyskerralla, tulee myös salaussalasana. (Koneen, jota olet jo käyttänyt, voi luovuttaa myös ilman uudelleenasennusta — katso [tietokoneen nollaaminen](48-security.md).)

### Valvomattomat asennukset

ISO voi myös asentaa järjestelmän täysin itsenäisesti — ilman näppäimistöä, ilman ohjattua asennusta — kun sille annetaan määritykset toisella asemalla. Näin Omarchya kannattaa käsitellä VM-koneiden ja koneryhmien peruslevykuvana. Katso [valvomattomat asennukset](51-unattended-installs.md).

### Asennukset ilman salausta

Omarchy asennetaan oletusarvoisesti salattuna. Se on turvallinen ja vastuullinen valinta jokaiselle tietokoneelle, joka voi mahdollisesti kadota tai tulla varastetuksi. Et halua, että kukaan, joka pääsee käsiksi laitteistoosi, voisi saada tietosi!

Mutta erityistilanteissa, kuten Omarchyn etäasennuksissa suojattuihin tietokoneisiin tai arkaluontoista tietoa sisältämättömiin kertakäyttöasennuksiin, saatat haluta asentaa ilman salausta. Voit painaa `Ctrl + C` levyn alustuksen vahvistuksessa vaihtaaksesi salaamattomaan asennukseen.

### Kieli

Omarchy puhuu 50 kieltä — samaa valikoimaa kuin omarchy.org — ja englanti on oletuskieli. Vaihtaaksesi kielen avaa Omarchy-valikko ja siirry kohtaan _Setup > Region > Language_ tai aja komento `omarchy language <code>` päätteessä (`omarchy language list` näyttää koodit). Valikko, työpöytä ja Omarchyn omat ilmoitukset vaihtavat kielen välittömästi, ja jokainen sen jälkeen avaamasi sovellus seuraa mukana. Jo auki olevat sovellukset vaihtavat kielen, kun käynnistät ne uudelleen.

Jos haluat säilyttää kielen mutta kirjoittaa päivämäärät, kellonajat, luvut, rahasummat, yksiköt ja paperikoot toisen alueen tavalla (esimerkiksi englanti eurooppalaisilla päivämäärillä ja 24 tunnin kellolla), valitse alue kohdasta _Setup > Region > Formats_, jossa jokaisessa vaihtoehdossa näkyy esimerkki, tai aja komento `omarchy region formats <code>` (`omarchy region formats list` näyttää koodit). _Sama kuin kieli_ palauttaa kielen omat muodot. Kielen vaihdon tavoin se vaikuttaa sovelluksiin, jotka avaat sen jälkeen.

### Apua, jos jäät jumiin

Jos jäät jumiin, löydät yleensä jonkun, joka on valmis auttamaan, _#omarchy-help_-kanavalta [yhteisön Discordissa](https://omarchy.org/discord).
