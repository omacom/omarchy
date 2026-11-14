# Kaksoiskäynnistysasennus

Voit asentaa Omarchyn yhdelle osiolle Windowsin tai muiden asennusten rinnalle.

Tässä asennustavassa osio salataan silti oletuksena LUKS-salauksella, joten se ei käytännössä eroa koko levyn asennuksesta. Levyltä pitää vain löytyä vapaata tilaa.

## Tilan tekeminen Windowsissa

Asentaaksesi Omarchyn Windowsin rinnalle kirjoita Käynnistä-valikkoon `disk management` ja valitse vaihtoehto **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Etsi oikea osio, napsauta sitä hiiren kakkospainikkeella ja valitse **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Syötä määrä, jolla haluat pienentää asemaa. Huomaa, että tästä tulee tulevan Omarchy-asennuksesi koko käynnistysosio mukaan lukien.

 ![dual-boot-3](images/dual-boot-3.webp)

Kun olet valmis, sinun pitäisi nähdä jotain tämänkaltaista. Tässä esimerkissä Omarchy asennetaan 50GB:n osioon.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchyn asentaminen

Omarchyn asennusprosessi on käytännössä samanlainen kuin normaalisti. Kun olet valinnut levysi, saat vaihtoehdon **Free space install**. Valitse se, jotta et tyhjennä koko levyä.

 ![dual-boot-5](images/dual-boot-5.webp)

Vahvista, että kaikki näyttää hyvältä, ja odota asennuksen valmistumista normaalisti. Tässä kohtaa voit myös valita salaamattoman asennuksen (ei suositella), aivan kuten koko levyn asennuksessa.
 ![dual-boot-6](images/dual-boot-6.webp)

## Muiden asennusten lisääminen käynnistyslataimeen

Kun Omarchy-asennuksesi on valmis, huomaat, että Limine-käynnistyslatain on nyt oletuksena. Siihen voit lisätä myös vaihtoehtoja muille asennuksillesi, kuten Windowsille.

Lisää muita käyttöjärjestelmiä suorittamalla `limine-scan` ja lisäämällä haluamasi merkinnät Limine-määritykseesi ohjeiden mukaisesti. Käynnistysvalikko pysyy oletuksena piilossa ja käynnistää Omarchyn yhden sekunnin kuluttua. Valitse Windows tai muu merkintä painamalla mitä tahansa näppäintä heti, kun Limine käynnistyy. Kun valikko tulee näkyviin, valitse merkintä nuolinäppäimillä ja paina Enter. Jos Omarchy käynnistyy ennen kuin ehdit painaa näppäintä, käynnistä kone uudelleen ja yritä uudelleen. Jos otit käyttöön asetuksen _Setup > Direct Boot_, laiteohjelmisto ohittaa Limine kokonaan. Valitse silloin Limine BIOS-käynnistysvalikosta tai poista merkintä suorittamalla _Setup > Direct Boot_ uudelleen.

## Bitlocker

On tärkeää huomata, että tämä asennustapa ei ole yhteensopiva Bitlockerin kanssa, koska Bitlocker salaa koko levyn, ei vain osiota. Jos saat virheilmoituksen, jonka mukaan Bitlocker on käytössä, käynnistä Windows, siirry kohtaan **Settings -> Privacy & Security -> Device encryption** ja kytke Bitlocker pois käytöstä. Levyn salauksen purkaminen voi kestää jonkin aikaa.

 ![dual-boot-7](images/dual-boot-7.webp)
