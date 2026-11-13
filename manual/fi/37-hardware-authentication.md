# Laitteistotodennus

### Sormenjälkitodennus

Monissa kannettavissa on sormenjälkitunnistin todennusta varten. Voit käyttää sitä Omarchyn kanssa suorittamalla Omarchy-valikosta (`Super + Space`) kohdan _Asennus > Tietoturva > Sormenjälki_.

Se asentaa sormenjälkipaketin, kerää sormenjälkesi ja vahvistaa sen, ja sen jälkeen voit käyttää sormenjälkeäsi lukituksen avaamiseen lukitusnäytöltä (jonka voit käynnistää näppäimillä `Super + Ctrl + L`), sudo-tilaan siirtymiseen ja järjestelmän kehotteiden valtuuttamiseen.

Kun lukitusnäyttö on sammuttanut näytön, tunnistin lepää virran säästämiseksi, joten herätä näyttö millä tahansa näppäimellä tai kosketusalustalla ennen kuin kosketat sitä.

Kun kannettavan kansi on suljettu, sormenjälkikehote ohitetaan automaattisesti, joten pääset suoraan salasanakehotteeseen sen sijaan, että odottaisit tunnistinta, johon et pääse käsiksi. Jos sinun täytyy muusta syystä työskennellä ulkoisella näppäimistöllä, jossa ei ole tunnistinta, paina vain `CTRL + C`, kun sinulta pyydetään sormenjälkeä `sudo`-käytön aikana.

Voit poistaa sormenjälkitodennuksen Omarchy-valikon kohdasta _Poista > Tietoturva > Sormenjälki_.

### Fido2-todennus

Jos käytät Fido2-laitetta, voit määrittää sen `sudo`-todennukseen käyttämällä Omarchy-valikon (`Super + Space`) kohtaa _Asennus > Tietoturva > Fido2_. Se kattaa kuitenkin `sudo`- ja järjestelmän valtuutuskehotteet, ei tietokoneen lukituksen avaamista.

Voit poistaa Fido2-todennuksen Omarchy-valikon kohdasta _Poista > Tietoturva > Fido2_.
