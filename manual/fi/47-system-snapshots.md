# Järjestelmän tilannekuvat

Luomme tilannekuvia automaattisesti jokaisen Omarchy-päivityksen yhteydessä, mutta jos haluat luoda oman, voit käyttää komentoa `omarchy-snapshot create`.

Käynnistääksesi ja palauttaaksesi tilannekuvan valitset sen Limine-käynnistyslataimesta. (Jos käynnistyt tällä hetkellä suoraan Omarchyn salauksenpurkuruutuun, sinun täytyy valita Limine käynnistysvaihtoehdoksi BIOSin kautta ensin).

Valitse tuolta ruudulta tilannekuva, johon haluat käynnistää, päivämäärän ja version perusteella. Omarchyn versio tilannekuvan hetkellä näkyy vasemmassa alakulmassa.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Saavuttuasi sisään ilmoitus ponnahtaa esiin ilmoittaen, että olet käynnistettävässä tilannekuvassa, ja jos napsautat sitä, palautusprosessi käynnistyy. Vaihtoehtoisesti voit hyödyntää komentoa `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Tämä palauttaa juuritiedostojärjestelmäsi, mutta ei `/home`-kansiotaasi. Joten se toimii rikkinäisen järjestelmäpäivityksen palauttamiseen, mutta ei kadonneiden henkilökohtaisten tiedostojen palauttamiseen.

Tämä tarkoittaa myös, että hakemistosi `~/.config` säilyy sellaisenaan. Joten jos palaat aiempaan versioon kirjastosta tai sovelluksesta, joka tallentaa määritystiedostoja uudessa muodossa, sinun täytyy selvittää se manuaalisesti.

_Huomautus: Tämä ominaisuus on käytettävissä vain asennuksissa, jotka käyttävät Limine-käynnistyslatainta, joka on ollut oletus Omarchy 2.0:sta lähtien. Se ei ole käytettävissä, jos käytät GRUBia tai systemd-bootia._

### Käynnistysvalikon ohittaminen

Jos et koskaan koske käynnistysvalikkoon ja haluat vain koneen siirtyvän suoraan salauksenpurkuruutuun, aja Omarchy-valikossa _Asetukset > Suorakäynnistys_. Se lisää EFI-merkinnän, joka osoittaa suoraan Omarchyyn, joten laiteohjelmisto käynnistää sen pysähtymättä Limineen.

Kompromissi on yllä mainittu: kun suorakäynnistys on päällä, tilannekuvaan pääseminen tarkoittaa Liminen valitsemista BIOSin käynnistysvalikosta ensin. Aja _Asetukset > Suorakäynnistys_ uudelleen poistaaksesi merkinnän ja palataksesi käynnistykseen Liminen kautta. Jotkut laiteohjelmistot eivät suhtaudu mukautettuihin EFI-merkintöihin suopeasti, joten asetus kieltäytyy toimimasta American Megatrends- ja Apple-laiteohjelmistoilla.
