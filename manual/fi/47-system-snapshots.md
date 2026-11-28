# Järjestelmän tilannekuvat

Luomme tilannekuvia automaattisesti jokaisen Omarchy-päivityksen yhteydessä, mutta jos haluat luoda oman, voit käyttää komentoa `omarchy-snapshot create`.

Se, miten käynnistät tilannekuvan ja palautat sen, riippuu käynnistyslataimesta, jolla koneesi käynnistyy. Uudet UEFI-asennukset käyttävät systemd-bootia; vanhemmat asennukset ja BIOS-koneet käyttävät Limineä. `omarchy-boot-backend` kertoo, kumpi sinulla on.

## systemd-bootin kanssa

Valitse Omarchy-valikosta _Järjestelmä > Tilannekuvat_ ja valitse tilannekuva, johon haluat käynnistää. Kone käynnistyy siihen kerran uudelleen. Tai pidä Space pohjassa koneen käynnistyessä nähdäksesi käynnistysvalikon, jossa jokainen tilannekuva on lueteltu uusimmasta vanhimpaan yhdessä Omarchy-versionsa ja päivämääränsä kanssa.

Tilannekuva käynnistyy päällään väliaikainen kerros, joten voit käyttää sitä normaalisti, mutta kaikki tekemäsi muutokset katoavat seuraavassa uudelleenkäynnistyksessä. Säilyttääksesi sen tee siitä järjestelmäsi: napsauta ilmoitusta, joka tulee näkyviin kirjautuessasi sisään, valitse _Järjestelmä > Tilannekuvat > Palauta tämä tilannekuva_ tai suorita `omarchy-snapshot restore`. Palautus tapahtuu koneen uudelleenkäynnistyksen aikana. Järjestelmä sellaisena kuin se oli ennen jää käynnistysvalikkoon nimellä _Ennen palautusta_, ja `omarchy-snapshot restore backup` palauttaa sen takaisin.

Terminaalista:

- `omarchy-snapshot list` luettelee tilannekuvat, joihin voit käynnistää;
- `omarchy-snapshot boot 12` käynnistyy uudelleen tilannekuvaan 12 kerran;
- `omarchy-snapshot restore 12` tekee tilannekuvasta 12 järjestelmän seuraavassa uudelleenkäynnistyksessä, ja `omarchy-snapshot restore --cancel` peruu päätöksesi ennen tuota uudelleenkäynnistystä.

## Liminen kanssa

Käynnistääksesi ja palauttaaksesi tilannekuvan valitset sen Limine-käynnistyslataimesta. Käynnistysvalikko pysyy oletuksena piilossa, joten paina mitä tahansa näppäintä heti Limine käynnistyessä tuodaksesi sen esiin.

Valitse tuolta näytöltä tilannekuva, johon haluat käynnistää, päivämäärän ja version perusteella. Omarchyn versio tilannekuvan ottohetkellä näkyy vasemmassa alakulmassa.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Saavuttuasi sisään esiin ponnahtaa ilmoitus, joka kertoo, että olet käynnistettävässä tilannekuvassa, ja jos napsautat sitä, palautusprosessi käynnistyy. Vaihtoehtoisesti voit käyttää komentoa `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Mitä palautus kattaa

Palautus tuo takaisin juuritiedostojärjestelmäsi, mutta ei `/home`-hakemistoasi. Se toimii siis rikkinäisen järjestelmäpäivityksen perumiseen, mutta ei kadonneiden henkilökohtaisten tiedostojen palauttamiseen.

Tämä tarkoittaa myös, että `~/.config`-hakemistosi säilyy sellaisenaan. Jos siis palaat aiempaan versioon kirjastosta tai sovelluksesta, joka tallentaa määritystiedostoja uudessa muodossa, joudut selvittämään sen käsin.

Sama koskee Omarchyn omaa merkintää siitä, mitkä migraatiot on jo suoritettu: se sijaitsee kotihakemistossasi, joten se säilyy palautuksen yli. Migraatiot, jotka suoritettiin tilannekuvan ottamisen jälkeen, pysyvät merkittyinä tehdyiksi, vaikka niiden juuritiedostojärjestelmään tekemät muutokset on peruttu, eikä seuraava `omarchy update` suorita niitä uudelleen. Jos siis päivität uudelleen palautuksen jälkeen ja jotain, minkä aiempi päivitys oli ottanut käyttöön, puuttuu edelleen, se on todennäköinen syy.
