# Järjestelmän tilannevedokset

Luomme tilannevedokset automaattisesti jokaisen Omarchy-päivityksen yhteydessä, mutta jos haluat luoda omasi, voit käyttää komentoa `omarchy-snapshot create`.

Käynnistääksesi tilannevedoksesta ja palauttaaksesi sen valitset sen Limine-käynnistyslataajasta. (Jos käynnistät tällä hetkellä suoraan Omarchy-salauksenpurkunäyttöön, sinun on ensin valittava Limine käynnistysvaihtoehdoksi BIOSin kautta).

Valitse kyseiseltä näytöltä tilannevedos, johon haluat käynnistää, päivämäärän ja version perusteella. Omarchy-versio tilannevedoksen ottohetkellä näkyy vasemmassa alakulmassa.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kun olet päässyt sisään, näkyviin tulee ilmoitus, joka kertoo sinun olevan käynnistettävässä tilannevedoksessa, ja jos napsautat sitä, palautusprosessi käynnistyy. Vaihtoehtoisesti voit käyttää komentoa `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Tämä palauttaa juuritiedostojärjestelmäsi, mutta ei `/home`-hakemistoasi. Se siis toimii rikkinäisen järjestelmäpäivityksen kumoamiseen, mutta ei kadonneiden henkilökohtaisten tiedostojen palauttamiseen.

Tämä tarkoittaa myös sitä, että `~/.config`-hakemistosi säilyy sellaisenaan. Jos siis palaat aiempaan versioon kirjastosta tai sovelluksesta, joka tallentaa määritystiedostonsa uudessa muodossa, joudut selvittämään asian manuaalisesti.

Sama koskee Omarchyn omaa tietoa siitä, mitkä migraatiot on jo suoritettu: se sijaitsee kotihakemistossasi, joten se säilyy palautuksen yli. Tilannevedoksen ottamisen jälkeen suoritetut migraatiot pysyvät merkittyinä suoritetuiksi, vaikka niiden juuritiedostojärjestelmään tekemät muutokset on kumottu, eikä seuraava `omarchy update` suorita niitä uudelleen. Jos siis päivität uudelleen palautuksen jälkeen ja jokin aiemman päivityksen tekemä asetus puuttuu edelleen, tämä on todennäköinen syy.

_Huomautus: Tämä ominaisuus on käytettävissä vain asennuksissa, jotka käyttävät Limine-käynnistyslataajaa, joka on ollut oletuksena Omarchy 2.0:sta lähtien. Se ei ole käytettävissä, jos käytössäsi on GRUB tai systemd-boot._

### Käynnistysvalikon ohittaminen

Jos et koskaan käytä käynnistysvalikkoa ja haluat koneen menevän suoraan salauksenpurkunäyttöön, suorita Omarchy-valikossa _Setup > Direct Boot_. Se lisää EFI-merkinnän, joka osoittaa suoraan Omarchyyn, joten laiteohjelmisto käynnistää sen pysähtymättä Limineen.

Kompromissi on sama kuin alussa mainittu: kun suorakäynnistys on käytössä, tilannevedokseen pääseminen tarkoittaa Liminen valitsemista ensin BIOS-käynnistysvalikostasi. Suorita _Setup > Direct Boot_ uudelleen poistaaksesi merkinnän ja palataksesi käynnistämään Liminen kautta. Jotkin laiteohjelmistot eivät suhtaudu ystävällisesti mukautettuihin EFI-merkintöihin, joten asennus kieltäytyy toimimasta American Megatrends- ja Apple-laiteohjelmistoilla.
