# Macilta tai Windowsilta saapuville

Jos olet viettänyt vuosia macOS:n tai Windowsin parissa, sormesi osaavat sata asiaa, jotka aivosi ovat unohtaneet koskaan oppineensakaan. Tämä luku on käännöskerros: minne nuo vaistot Omarchyssa kuuluvat. Ominaisuudet itsessään käsitellään perusteellisesti muualla — tämä on vain kartta.

### Super on kaiken keskipiste

Kaikki Cmd:n tai Windows-näppäimen ympärille rakentamasi lihasmuisti siirtyy yhdelle näppäimelle: Superille. Se on PC-näppäimistön Windows-näppäin, ja se on lähes jokaisen Omarchyn pikanäppäimen ankkuri.

Spotlight-, Raycast- tai Käynnistä-valikko-refleksistäsi tulee `Super + Space`. Se avaa Omarchy-valikon, joka käynnistää sovelluksia, muuttaa asetuksia, asentaa ohjelmistoja, kaappaa näytön — melkein kaiken. Ala kirjoittaa, niin se suodattuu. `Super + Alt + Space` näyttää kaikki sovellukset yhdessä ruudukossa, niin kuin Launchpad tekee. Katso [navigointi](04-navigation.md).

### Ei työpöytäkuvakkeita, ja dock pysyy poissa tieltä

Ei kuvakkeita järjesteltäväksi työpöydälle, ja dock piiloutuu heti, kun työtilassa on ikkuna, kunnes työnnät osoittimen sen ruudunreunaan, oikeaan reunaan, ellet siirrä sitä (katso [navigointi](04-navigation.md)). Sovellukset käynnistyvät pikanäppäimellä (`Super + Return` päätteelle, `Super + Shift + Return` selaimelle ja `Super + K` listalle kaikesta, mille on määritetty pikanäppäin) tai valikosta. Ainoa pysyvä käyttöliittymän osa on [yläpalkki](05-the-top-bar.md), joka hoitaa sen, mitä valikkorivi, ilmaisinalue ja Notification Center ennen tekivät puolestasi — ja melkein jokainen sen widget tekee jotain vasemmalla, oikealla ja keskimmäisellä napsautuksella.

### Ikkunat asettuvat itse paikoilleen

Suurin ajattelutavan muutos: et raahaa ikkunoita ympäriinsä etkä napsauta niitä ruudun puolikkaille. Avaa ikkuna, ja se valtaa koko ruudun. Avaa toinen, ja ne jakavat sen. Et koskaan kaiva ikkunaa toisen alta, koska ikkunat eivät mene päällekkäin.

Kun todella tarvitset kelluvan ikkunan, `Super + T` vaihtaa aktiivisen ikkunan pois laatoituksesta (ja takaisin). Anna laatoitukselle kuitenkin ensin kunnon mahdollisuus — se on koko jutun sydän. [Navigointi](04-navigation.md) opastaa sinut sen läpi.

Työtilat tuntuvat tutuilta: ne ovat macOS:n Spaces tai Windowsin virtuaalityöpöydät, paitsi että todella käytät niitä, koska `Super + 1/2/3/4` hyppää suoraan yhteen ja `Super + Shift + 1/2/3/4` lähettää aktiivisen ikkunan sinne. Ei animaatioviivettä, vain välittömiä hyppyjä. Tämä tarkoittaa, ettet ehkä edes tarvitse useita näyttöjä, jos olit tottunut siihen aiemmin.

### Kopiointi ja liittäminen vain toimivat

Macilla käytit Cmd + C:tä kaikkialla. Windowsilla käytit Ctrl + C:tä kaikkialla — paitsi päätteessä, jossa se tappaa ohjelmasi. Omarchy antaa sinulle `Super + C`, `Super + X` ja `Super + V`, ja ne toimivat kaikkialla, myös päätteessä. Kuorelle ei tarvitse opetella erillistä refleksiä.

Windows-väki: Win + V -leikepöytähistoriasi asuu näppäimessä `Super + Ctrl + V`, ja se säilyttää kuvia tekstin lisäksi. Katso [yhtenäinen leikepöytä ja historia](08-unified-clipboard-history.md).

### Käännöstaulukko

| Tartut tähän | Omarchyssa |
| ------------- | ---------- |
| Spotlight / Raycast / Käynnistä-valikko | `Super + Space` — Omarchy-valikko |
| AirDrop | LocalSend, näppäimellä `Super + Ctrl + S` — katso [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` tai `Print Screen` — katso [kuvakaappaukset ja tallennus](12-screenshots-recording.md) |
| Notification Center | Ilmoitushistoria näppäimellä `Super + Shift + Alt + ,` |
| Time Machine (järjestelmälle) | Automaattiset [järjestelmän tilannevedokset](47-system-snapshots.md) joka päivityksessä |
| App Store / asentimen lataaminen | _Install_ valikossa, tai `omarchy pkg add` — katso [muut paketit](29-other-packages.md) |
| Järjestelmäasetukset / Ohjauspaneeli | _Setup_ valikossa, joka muokkaa pelkkiä asetustiedostoja — katso [dotfiles](31-dotfiles.md) |
| Finder / Resurssienhallinta | Files, näppäimellä `Super + Shift + F` — katso [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome näppäimellä `Super + Shift + Return`; valitse toinen kohdasta _Setup > Defaults > Browser_ — katso [selaimet](23-browsers.md) |
| Esikatselu / Kuvat | Omaview kuville, videolle ja musiikille, Document Viewer PDF:ille — katso [GUIs](22-guis.md) |
| TextEdit / Muistio | Plain, näppäimellä `Super + Shift + N`; valitse toinen kohdasta _Setup > Defaults > Editor_ |

### Jotkin asiat todella ovat toisin

Moni asetus asuu muokattavissa tekstitiedostoissa, ei läpiklikkailtavissa paneeleissa. Se kuulostaa alkeelliselta, kunnes tajuat, että se tarkoittaa, että jokainen säätö voidaan nähdä, kopioida seuraavalle koneellesi ja laittaa versionhallintaan. _Setup_-valikko pudottaa sinut suoraan oikeaan tiedostoon ja käynnistää uudelleen sen, mikä tarvitsee uudelleenkäynnistyksen, kun olet valmis.

Päivitykset tulevat yhden komennon kautta — _Update > Omarchy_ — joka päivittää Omarchyn itsensä ja jokaisen järjestelmän paketin ja ottaa ensin tilannevedoksen. Ei erillisiä sovellusten päivittäjiä, jotka nalkuttavat sinulle satunnaisesti. Katso [päivitykset](30-updates.md).

Ohjelmistot tulevat paketinhallinnasta, eivät ladatuista asentimista.

Ja kun suljet ikkunan, sovellus todella sulkeutuu. Ei ole sellaista macOS:n limboa, jossa ohjelma jatkaa toimintaansa ilman ikkunoita. `Super + W` — tai `Super + Q`, jos se on sormimuisti, jonka kanssa saavuit — tarkoittaa poissa.

### Mac-laitteistolla

Omarchy toimii hyvin Intel-Maceilla ja M1-, M2- ja M3-Maceilla Omarchy for Apple Silicon -version kanssa. Katso [Mac-tuki](44-mac-support.md). Ja näppäimistö on sinulle ystävällinen: Omarchy ei määritä mitään uudelleen, ja Linux käsittelee Command-näppäintä Superina, joten Super istuu juuri siinä, missä Cmd aina oli. Peukalosi ei huomaa siirtoa.

### Anna sille kaksi viikkoa

Vaistot siirtyvät nopeammin kuin luuletkaan. Selaa [pikanäppäimet](07-hotkeys.md)-luku kerran läpi, ja aina kun pikanäppäin katoaa mielestäsi, paina `Super + K` — se näyttää ne kaikki. Se on ainoa pikanäppäin, joka sinun todella täytyy opetella ulkoa.
