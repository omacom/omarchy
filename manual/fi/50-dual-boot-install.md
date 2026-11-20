# Asennus kaksoiskäynnistykseen

Voit asentaa Omarchyn yhdelle osiolle Windowsin tai muiden asennusten rinnalle.

Tässä asennustavassakin osio salataan oletuksena LUKS-salauksella, joten se ei käytännössä eroa koko levyn asennuksesta ja vaatii vain, että levyllä on vapaata tilaa käytettävissä.

## Tilan tekeminen Windowsissa

Asentaaksesi Omarchyn Windowsin rinnalle, kirjoita Käynnistä-valikkoon `disk management` ja valitse vaihtoehto **Luo ja alusta kiintolevyosioita**.

 ![dual-boot-1](images/dual-boot-1.webp)

Etsi sopiva osio, napsauta sitä hiiren kakkospainikkeella ja valitse **Pienennä asemaa**.

![dual-boot-2](images/dual-boot-2.webp)

 Syötä määrä, jolla haluat pienentää asemaa. Huomaa, että tämä on tulevan Omarchy-asennuksesi koko mukaan lukien käynnistysosio.

 ![dual-boot-3](images/dual-boot-3.webp)

Kun olet valmis, sinun pitäisi nähdä jotain tämänkaltaista, jossa 50 Gt:n osio on tässä esimerkissä kohta, johon asennamme Omarchyn.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchyn asentaminen

Omarchyn asennusprosessi on käytännössä sama kuin normaalisti. Kun olet valinnut levysi, saat vaihtoehdon **Asennus vapaaseen tilaan**. Valitse se vaihtoehto, jotta koko levyä ei pyyhitä.

 ![dual-boot-5](images/dual-boot-5.webp)

Vahvista, että kaikki näyttää hyvältä, ja odota asennuksen valmistumista normaalisti. Tässä kohtaa voit myös valita salaamattoman asennuksen (ei suositella) aivan kuten koko levyn asennuksessa.
 ![dual-boot-6](images/dual-boot-6.webp)

## Muiden asennusten lisääminen käynnistyslataajaan

Kun Omarchy-asennuksesi on valmis, huomaat, että Limine-käynnistyslataaja on nyt oletuksena. Sen avulla voit myös lisätä Limineen vaihtoehtoja muille asennuksillesi, kuten Windowsille.

Lisää muita käyttöjärjestelmiä suorittamalla `limine-scan` ja noudattamalla kehotteita lisätäksesi haluamasi merkinnät Limine-määritykseesi. Käynnistysvalikko pysyy oletuksena piilossa ja käynnistää Omarchyn yhden sekunnin kuluttua. Valitse Windows tai muu merkintä painamalla mitä tahansa näppäintä heti, kun Limine käynnistyy; kun valikko ilmestyy, valitse merkintä nuolinäppäimillä ja paina Enter. Jos Omarchy käynnistyy ennen kuin ehdit painaa näppäintä, käynnistä uudelleen ja yritä uudelleen.

## Bitlocker

On tärkeää huomata, että tämä asennustapa ei ole yhteensopiva Bitlockerin kanssa, koska se salaa koko levyn, ei vain osiota. Jos saat virheen, jonka mukaan Bitlocker on käytössä, käynnistä Windowsiin, siirry kohtaan **Asetukset -> Tietosuoja ja suojaus -> Laitteen salaus** ja kytke Bitlocker pois päältä. Levyn salauksen purkaminen voi kestää jonkin aikaa.

 ![dual-boot-7](images/dual-boot-7.webp)
