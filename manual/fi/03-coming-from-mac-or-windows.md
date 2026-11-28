# Siirtyminen Macista tai Windowsista

Jos olet viettänyt vuosia macOS:n tai Windowsin parissa, sormesi osaavat sata asiaa, joiden oppimisen aivosi ovat jo unohtaneet. Tämä luku on käännöskerros: minne nuo vaistot kuuluvat Omarchyssa. Itse ominaisuudet käsitellään perusteellisesti muualla — tämä on vain kartta.

### Super on kaiken keskipiste

Kaikki Cmd:n tai Windows-näppäimen ympärille rakentamasi lihasmuisti siirtyy yhdelle näppäimelle: Super. Se on PC-näppäimistön Windows-näppäin, ja se on ankkuri lähes jokaiselle Omarchyn pikanäppäimelle.

Spotlight-, Raycast- tai Käynnistä-valikko -refleksistäsi tulee `Super + Space`. Se avaa Omarchy-valikon, joka käynnistää sovelluksia, muuttaa asetuksia, asentaa ohjelmistoja ja kaappaa näytön — melkein kaiken. Ala kirjoittaa suodattaaksesi. `Super + Alt + Space` näyttää kaikki sovellukset yhdessä ruudukossa, kuten Launchpad tekee. Katso [navigointi](04-navigation.md).

### Ei työpöytäkuvakkeita, ja telakka pysyy poissa tieltä

Ei kuvakkeita järjesteltäväksi työpöydällä, ja telakka piiloutuu heti, kun työtilassa on ikkuna, kunnes työnnät osoittimen sen näytön reunaan, alareunaan ellet siirrä sitä (katso [navigointi](04-navigation.md)). Sovellukset käynnistyvät pikanäppäimellä (`Super + Return` päätteelle, `Super + Shift + Return` selaimelle ja `Super + K` luettelolle kaikista määritetyistä) tai valikosta. Ainoa pysyvä käyttöliittymän osa on [yläpalkki](05-the-top-bar.md), joka kattaa sen, mitä valikkopalkki, järjestelmäpalkki ja Notification Center tekivät sinulle ennen — ja lähes jokainen sen pienoisohjelma tekee jotain vasemmalla, oikealla ja keskimmäisellä napsautuksella.

### Ikkunat asettuvat paikoilleen itse

Suurin ajattelutavan muutos: et raahaa ikkunoita ympäriinsä etkä napsauta niitä näytön puolikkaisiin. Avaa ikkuna, ja se valtaa koko näytön. Avaa toinen, ja ne jakavat sen. Et koskaan kaiva ikkunaa esiin toisen alta, koska ikkunat eivät mene päällekkäin.

Kun todella tarvitset kelluvan ikkunan, `Super + T` vaihtaa aktiivisen ikkunan pois laatoituksesta (ja takaisin). Anna laatoitukselle kuitenkin ensin kunnon mahdollisuus — se on koko jutun ydin. [Navigointi](04-navigation.md) opastaa sinut sen läpi.

Työtilat tuntuvat tutuilta: ne ovat macOS Spaces tai Windowsin virtuaalityöpöydät, paitsi että todella käytät niitä, koska `Super + 1/2/3/4` hyppää suoraan yhteen ja `Super + Shift + 1/2/3/4` lähettää aktiivisen ikkunan sinne. Ei animaatioviivettä, vain välittömiä hyppyjä. Tämä tarkoittaa, ettet ehkä edes tarvitse useita näyttöjä, jos olit tottunut siihen ennen.

### Kopiointi ja liittäminen vain toimivat

Macilla sinulla oli Cmd + C kaikkialla. Windowsilla sinulla oli Ctrl + C kaikkialla — paitsi päätteessä, jossa se tappaa ohjelmasi. Omarchy antaa sinulle `Super + C`, `Super + X` ja `Super + V`, ja ne toimivat kaikkialla, myös päätteessä. Kuorelle ei tarvitse opetella erillistä refleksiä.

Windows-väki: Win + V -leikepöytähistoriasi löytyy näppäimeltä `Super + Ctrl + V`, ja se säilyttää tekstin lisäksi myös kuvia. Katso [yhtenäinen leikepöytä ja historia](08-unified-clipboard-history.md).

### Käännöstaulukko

| Mitä etsit | Omarchyssa |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy-valikko |
| AirDrop | LocalSend, näppäimellä `Super + Ctrl + S` — katso [graafiset käyttöliittymät](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` tai `Print Screen` — katso [kuvakaappaukset ja tallennus](12-screenshots-recording.md) |
| Notification Center | Ilmoitushistoria näppäimellä `Super + Shift + Alt + ,` |
| Time Machine (järjestelmälle) | Automaattiset [järjestelmän tilannevedokset](47-system-snapshots.md) jokaisella päivityksellä |
| App Store / asentimen lataaminen | _Install_ valikossa tai `omarchy pkg add` — katso [muut paketit](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ valikossa, joka muokkaa pelkkiä määritystiedostoja — katso [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, näppäimellä `Super + Shift + F` — katso [graafiset käyttöliittymät](22-guis.md) |
| Safari / Edge | Google Chrome näppäimellä `Super + Shift + Return`; valitse toinen kohdasta _Setup > Defaults > Browser_ — katso [selaimet](23-browsers.md) |
| Preview / Photos | Omaview kuville, videolle ja musiikille, Document Viewer PDF-tiedostoille — katso [graafiset käyttöliittymät](22-guis.md) |
| TextEdit / Notepad | Plain, näppäimellä `Super + Shift + N`; valitse toinen kohdasta _Setup > Defaults > Editor_ |

### Jotkin asiat todella ovat toisin

Monet asetukset sijaitsevat tekstitiedostoissa, joita muokkaat, eivät paneeleissa, joita napsauttelet läpi. Se kuulostaa alkeelliselta, kunnes tajuat, että se tarkoittaa, että jokainen säätö voidaan nähdä, kopioida seuraavalle koneellesi ja laittaa versionhallintaan. _Setup_-valikko pudottaa sinut suoraan oikeaan tiedostoon ja käynnistää uudelleen sen, mikä pitää käynnistää uudelleen, kun olet valmis.

Päivitykset tulevat yhden komennon kautta — _Update > Omarchy_ — joka päivittää itse Omarchyn ja järjestelmän jokaisen paketin ja ottaa ensin tilannevedoksen. Ei sovelluskohtaisia päivittäjiä nalkuttamassa satunnaisesti. Katso [päivitykset](30-updates.md).

Ohjelmistot tulevat pakettienhallinnasta, eivät ladatuista asentimista.

Ja kun suljet ikkunan, sovellus todella sulkeutuu. Ei ole macOS-välitilaa, jossa ohjelma jatkaa toimintaansa ilman ikkunoita. `Super + W` — tai `Super + Q`, jos se on sormimuisti, jonka kanssa saavuit — tarkoittaa poissa.

### Mac-laitteistolla

Omarchy toimii hyvin Intel-Maceilla sekä M1-, M2- ja M3-Maceilla Omarchy for Apple Silicon -version kanssa. Katso [Mac-tuki](44-mac-support.md). Ja näppäimistö on sinulle lempeä: Omarchy ei määritä mitään uudelleen, ja Linux käsittelee Command-näppäintä Superina, joten Super istuu juuri siellä, missä Cmd aina oli. Peukalosi ei huomaa siirtoa.

### Anna sille kaksi viikkoa

Vaistot siirtyvät nopeammin kuin luuletkaan. Selaa [pikanäppäimet](07-hotkeys.md)-luku kerran läpi, ja aina kun sidos menee tyhjäksi, paina `Super + K` — se näyttää sinulle ne kaikki. Se on ainoa pikanäppäin, joka sinun todella täytyy opetella ulkoa.
