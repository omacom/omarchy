# Laitteistotodennus

### Sormenjälkitodennus

Monissa kannettavissa tietokoneissa on sormenjälkianturi todennusta varten. Voit käyttää sitä Omarchyssa avaamalla _Setup > Security > Fingerprint_ Omarchy-valikosta (`Super + Space`).

Se avaa koko näytön kokoisen sormenjäljen, joka täyttyy, kun kosketat anturia. Taustalla Omarchy asentaa sormenjälkipaketin, tallentaa sormenjälkesi, vahvistaa sen, ja olet valmis käyttämään sormenjälkeäsi lukituksen avaamiseen lukitusnäytöltä (jonka saat näkyviin näppäimillä `Super + Ctrl + L`), sudo-tilaan siirtymiseen ja järjestelmän kehotteiden valtuuttamiseen.

Kun lukitusnäyttö on sammuttanut näytön, anturi lepää virran säästämiseksi, joten herätä näyttö millä tahansa näppäimellä tai kosketuslevyllä ennen kuin kosketat sitä.

Kun kannettavan tietokoneen kansi on kiinni, sormenjälkikehote ohitetaan automaattisesti, joten pääset suoraan salasanakehotteeseen sen sijaan, että jäisit odottamaan anturia, johon et pääse käsiksi. Jos sinun täytyy muuten työskennellä ulkoisella näppäimistöllä, jossa ei ole anturia, paina vain `CTRL + C`, kun sinulta pyydetään sormenjälkeä `sudo`-komennon aikana.

Voit poistaa sormenjälkitodennuksen kohdasta _Remove > Security > Fingerprint_ Omarchy-valikossa.

### Fido2-todennus

Jos käytät Fido2-laitetta, voit määrittää sen `sudo`-todennusta varten kohdasta _Setup > Security > Fido2_ Omarchy-valikossa (`Super + Space`). Se kattaa kuitenkin `sudo`-kehotteet ja järjestelmän valtuutuskehotteet, ei tietokoneen lukituksen avaamista.

Voit poistaa fido2-todennuksen kohdasta _Remove > Security > Fido2_ Omarchy-valikossa.
