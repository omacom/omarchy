# Kaksoiskäynnistysasennus

Voit asentaa Omarchyn yhdelle osiolle Windowsin tai muiden asennusten rinnalle.

Tämä asennustapa sisältää silti oletuksena LUKS-salauksen osiolle, joten se ei käytännössä eroa koko aseman asennuksesta ja vaatii vain, että levyllä on vapaata tilaa käytettävissä.

## Tilan tekeminen Windowsissa

Asentaaksesi Windowsin rinnalle kirjoita Käynnistä-valikkoon `disk management` ja valitse vaihtoehto **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Etsi sopiva osio, napsauta hiiren kakkospainikkeella ja valitse **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Syötä määrä, jolla haluat osion pienentyvän. Huomaa, että tämä on tulevan Omarchy-asennuksesi koko sisältäen käynnistysosion.

 ![dual-boot-3](images/dual-boot-3.webp)

Kun olet valmis, sinun pitäisi nähdä jotain tällaista, jossa 50 Gt:n osioon asennamme Omarchyn tässä esimerkissä.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchyn asentaminen

Omarchyn asennusprosessi on käytännössä sama kuin normaalisti. Valittuasi levysi sinulle annetaan vaihtoehto **Free space install**. Valitse se välttääksesi koko levyn tyhjentämisen.

 ![dual-boot-5](images/dual-boot-5.webp)

Vahvista, että kaikki näyttää hyvältä, ja odota asennuksen valmistumista normaalisti. Tässä voit myös valita asennuksen salaamattomana (ei suositella) aivan kuten koko aseman asennuksessa.
 ![dual-boot-6](images/dual-boot-6.webp)

## Muiden asennusten lisääminen käynnistyslataimeen

Kun viimeistelet Omarchy-asennuksesi, huomaat, että Limine-käynnistyslatain on nyt oletus. Sen avulla voit myös lisätä Limineen vaihtoehtoja muille asennuksillesi, kuten Windowsille.

Tehdäksesi niin aja `limine-scan` ja seuraa kehotteita lisätäksesi haluamasi kohteet limine-määritykseesi. Sitten käynnistäessäsi näet normaalit vaihtoehtosi Omarchylle sekä Windows Boot Managerin tai muut.

## Bitlocker

On tärkeää huomata, että tämä asennustapa ei ole yhteensopiva Bitlockerin kanssa, koska se salaa koko aseman, ei vain osiota. Jos kohtaat virheen, joka ilmoittaa, että Bitlocker on käytössä, käynnistä Windowsiin, mene kohtaan **Settings -> Privacy & Security -> Device encryption** ja kytke Bitlocker pois päältä. Aseman salauksen purkaminen saattaa viedä jonkin aikaa.

 ![dual-boot-7](images/dual-boot-7.webp)
