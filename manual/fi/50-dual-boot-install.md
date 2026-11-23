# Kaksoiskäynnistysasennus

Voit asentaa Omarchyn yhdelle osiolle Windowsin tai muiden asennusten rinnalle.

Tässä asennustavassa osio salataan silti oletuksena LUKS-salauksella, joten se ei käytännössä eroa koko levyn asennuksesta ja vaatii vain, että levyllä on vapaata tilaa käytettävissä.

## Tilan tekeminen Windowsissa

Asentaaksesi Omarchyn Windowsin rinnalle kirjoita Käynnistä-valikkoon `disk management` ja valitse vaihtoehto **Luo ja alusta kiintolevyosioita**.

 ![dual-boot-1](images/dual-boot-1.webp)

Etsi sopiva osio, napsauta sitä hiiren kakkospainikkeella ja valitse **Pienennä asema**.

![dual-boot-2](images/dual-boot-2.webp)

 Syötä määrä, jolla haluat pienentää asemaa. Huomaa, että tämä on tulevan Omarchy-asennuksesi koko käynnistysosio mukaan lukien.

 ![dual-boot-3](images/dual-boot-3.webp)

Kun olet valmis, sinun pitäisi nähdä jotain tällaista, jossa 50 Gt:n osio on tässä esimerkissä kohta, johon asennamme Omarchyn.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchyn asentaminen

Omarchyn asennusprosessi on käytännössä samanlainen kuin tavallisesti. Kun olet valinnut levysi, saat vaihtoehdon **Vapaan tilan asennus**. Valitse se vaihtoehto estääksesi koko levyn tyhjentämisen.

 ![dual-boot-5](images/dual-boot-5.webp)

Vahvista, että kaikki näyttää hyvältä, ja odota asennuksen valmistumista tavalliseen tapaan. Täällä voit myös valita salaamattoman asennuksen (ei suositella) aivan kuten koko levyn asennuksessakin.
 ![dual-boot-6](images/dual-boot-6.webp)

## Muiden asennusten lisääminen käynnistyslataajaan

Kun Omarchy-asennuksesi on valmis, huomaat, että Limine-käynnistyslataaja on nyt oletuksena. Sen avulla voit lisätä Limineen vaihtoehtoja myös muita asennuksiasi, kuten Windowsia, varten.

Muiden käyttöjärjestelmien lisäämiseksi suorita `limine-scan` ja seuraa kehotteita lisätäksesi haluamasi merkinnät Limine-kokoonpanoosi. Käynnistysvalikko pysyy oletuksena piilossa ja käynnistää Omarchyn yhden sekunnin kuluttua. Valitaksesi Windowsin tai muun merkinnän paina mitä tahansa näppäintä heti Liminen käynnistyessä; kun valikko ilmestyy, valitse merkintä nuolinäppäimillä ja paina Enter. Jos Omarchy käynnistyy ennen kuin ehdit painaa näppäintä, käynnistä uudelleen ja yritä uudestaan.

## Bitlocker

On tärkeää huomata, että tämä asennustapa ei ole yhteensopiva Bitlockerin kanssa, koska se salaa koko levyn eikä vain osiota. Jos saat virheilmoituksen, jonka mukaan Bitlocker on käytössä, käynnistä Windowsiin, siirry kohtaan **Asetukset -> Tietosuoja ja suojaus -> Laitteen salaus** ja kytke Bitlocker pois päältä. Levyn salauksen purkaminen voi kestää jonkin aikaa.

 ![dual-boot-7](images/dual-boot-7.webp)

## Windowsin uudelleenasentaminen

Jos tämä tietokone toimitettiin Windowsilla, sen tuoteavain on tallennettu laiteohjelmistoon. Tulosta se suorittamalla `omarchy windows key`, jotta voit aktivoida Windowsin uudelleen, jos koskaan asennat sen uudelleen tähän koneeseen.
