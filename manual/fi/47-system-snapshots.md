# Järjestelmän tilannevedokset

Luomme tilannevedokset automaattisesti jokaisen Omarchy-päivityksen yhteydessä, mutta jos haluat luoda omasi, voit käyttää komentoa `omarchy-snapshot create`.

Käynnistääksesi tilannevedoksesta ja palauttaaksesi sen valitset sen Limine-käynnistyslataajasta. Käynnistysvalikko pysyy oletuksena piilossa, joten paina mitä tahansa näppäintä heti Liminen käynnistyessä saadaksesi sen esiin.

Valitse siltä näytöltä tilannevedos, johon haluat käynnistää, päivämäärän ja version perusteella. Omarchyn versio tilannevedoksen ottohetkellä näkyy vasemmassa alakulmassa.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kun pääset sisään, esiin ponnahtaa ilmoitus, joka kertoo, että olet käynnistettävässä tilannevedoksessa, ja jos napsautat sitä, palautusprosessi käynnistyy. Vaihtoehtoisesti voit käyttää komentoa `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Tämä palauttaa juuritiedostojärjestelmäsi, mutta ei `/home`-hakemistoasi. Se toimii siis rikkinäisen järjestelmäpäivityksen perumiseen, mutta ei kadonneiden henkilökohtaisten tiedostojen palauttamiseen.

Tämä tarkoittaa myös, että `~/.config`-hakemistosi säilyy sellaisenaan. Jos siis palaat aiempaan versioon kirjastosta tai sovelluksesta, joka tallentaa määritystiedostot uuteen muotoon, joudut selvittämään asian käsin.

Sama koskee Omarchyn omaa kirjanpitoa siitä, mitkä migraatiot on jo ajettu: se sijaitsee kotihakemistossasi, joten se säilyy palautuksen jälkeen. Migraatiot, jotka ajettiin tilannevedoksen ottamisen jälkeen, pysyvät merkittyinä tehdyiksi, vaikka niiden juuritiedostojärjestelmään tekemät muutokset on peruttu, eikä seuraava `omarchy update` aja niitä uudelleen. Jos siis päivität uudelleen palautuksen jälkeen ja jotain, minkä aiempi päivitys oli ottanut käyttöön, puuttuu edelleen, se on todennäköinen syy.

_Huomautus: Tämä ominaisuus on saatavilla vain asennuksissa, jotka käyttävät Limine-käynnistyslataajaa, joka on ollut oletuksena Omarchy 2.0:sta lähtien. Se ei ole saatavilla, jos käytät GRUBia tai systemd-bootia._
