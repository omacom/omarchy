# Aloittaminen

Omarchy asennetaan ISO:n avulla. Voit valita koko levyn asennuksen, joka ottaa koko aseman haltuunsa, tai vapaan tilan asennuksen, joka sijoittaa Omarchyn asemalla olevaan varaamattomaan tilaan — näin teet dual boot -asennuksen Windowsin tai toisen käyttöjärjestelmän rinnalle (katso [dual-boot-asennus](50-dual-boot-install.md) — huomaa, että sinun on ensin kytkettävä BitLocker pois päältä Windowsissa). Kummassakin tapauksessa asennus käyttää oletuksena täyttä salausta, ja koko levyn vaihtoehto pyyhkii valitun aseman, joten muista ottaa varmuuskopio ennen olemassa olevan aseman käyttämistä!

[Lataa Omarchy ISO](https://omarchy.org/) ensin, laita se USB-tikulle (käytä Macilla/Windowsilla [balenaEtcheriä](https://etcher.balena.io/) tai Linuxilla [caligulaa](https://github.com/ifd3f/caligula)) ja käynnistä tikulta.

_Sinun on kytkettävä Secure Boot ja/tai TPM pois päältä BIOSissa. Ne on pakko kytkeä pois, jotta voit asentaa Omarchyn. Ne ovat Microsoftin tietoturvajärjestelmiä, jotka on tarkoitettu Windowsille ja Microsoftiin kytköksissä oleville Linux-jakeluille._

Vastaa sitten määrityskysymyksiin ja vahvista ne näin:

 ![install-config](images/install-config.webp)

Valitse sitten asema asennustasi varten, nojaa taaksepäin ja katso, kun asennusshow pyörii. Se voi valmistua alle minuutissa nopeimmilla nykyaikaisilla koneilla, mutta sen ei pitäisi kestää yli 5 minuuttia edes vanhemmalla tietokoneella.

 ![install-done](images/install-done.webp)

Nyt olet valmis Omarchyyn!

### Käytä langallista tai 2.4ghz-näppäimistöä!

Koko levyn salaus ei anna sinun syöttää salasanaa Bluetooth-näppäimistöltä käynnistyksessä. Aivan kuten et voi käyttää Bluetooth-näppäimistöä PC:n BIOSiin siirtymiseen. Tarvitset näppäimistön, joka käyttää joko 2.4ghz-donglea tai kaapelia (mikä on muutenkin paljon mukavampaa viiveen kannalta!). Itse rakastan [Lofree Flow84:ää](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Asentaminen toiselle omistajalle

Jos olet ottamassa konetta käyttöön jollekulle toiselle — perheenjäsenelle, uudelle työntekijälle, ostajalle — sinun ei pitäisi vastata henkilökohtaisiin kysymyksiin hänen puolestaan. Paina `Ctrl + C` asentimen aivan ensimmäisessä näytössä (näppäimistön valinta), niin Omarchy tarjoaa sen sijaan koneen valmistelemista toiselle omistajalle. Järjestelmä asennetaan heti, mutta kaikki henkilökohtainen määritys — näppäimistöasettelu, käyttäjänimi, salasana — lykätään siihen asti, kun kone käynnistyy ensimmäistä kertaa. Asema salataan silti oletuksena, ja salasanasta, jonka uusi omistaja valitsee tuossa ensimmäisessä käynnistyksessä, tulee myös salaussalasana. (Koneen, jota olet jo käyttänyt, voi luovuttaa eteenpäin myös ilman uudelleenasennusta — katso [tietokoneen nollaaminen](48-security.md).)

### Valvomattomat asennukset

ISO voi asentua myös täysin itsestään — ei näppäimistöä, ei ohjattua asennusta — kun sille annetaan sen määritys toisella asemalla. Näin Omarchya kannattaa kohdella VM:ien ja konelaivueiden peruslevykuvana. Katso [valvomattomat asennukset](51-unattended-installs.md).

### Salauksettomat asennukset

Omarchy asennetaan oletuksena salauksella. Se on turvallinen ja vastuullinen valinta mille tahansa tietokoneelle, joka voi mahdollisesti kadota tai tulla varastetuksi. Et halua kenenkään, jolla on pääsy laitteistoosi, pystyvän saamaan tietojasi!

Mutta erityisolosuhteissa, kuten Omarchyn etäasennuksissa suojattuihin tietokoneisiin tai kertakäyttöisissä asennuksissa ilman arkaluonteisia tietoja, saatat haluta asentaa ilman salausta. Voit painaa `Ctrl + C` levyn alustuksen vahvistuksessa vaihtaaksesi salauksettomaan asennukseen.

### Kieli

Omarchy puhuu 50 kieltä — samaa joukkoa kuin omarchy.org — ja englanti on oletus. Vaihtaaksesi avaa Omarchy-valikko ja siirry kohtaan _Asetukset > Kieli_, tai aja `omarchy language <code>` terminaalissa (`omarchy language list` näyttää koodit). Valikko, työpöytä ja Omarchyn omat ilmoitukset vaihtavat kieltä välittömästi, ja jokainen sen jälkeen avaamasi sovellus seuraa perässä. Jo avoinna olleet sovellukset vaihtavat, kun käynnistät ne uudelleen.

### Apua, jos jäät jumiin

Jos jäät jumiin, löydät yleensä jonkun, joka on valmis auttamaan, _#omarchy-help_-kanavalta [yhteisön Discordista](https://omarchy.org/discord).
