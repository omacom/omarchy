# Macista tai Windowsista tuleville

Jos olet viettänyt vuosia macOS:n tai Windowsin parissa, sormesi osaavat sata asiaa, jotka aivosi ovat unohtaneet koskaan oppineensa. Tämä luku on käännöskerros: minne nuo vaistot menevät Omarchyssa. Ominaisuudet itsessään käsitellään syvällisesti muualla — tämä on vain kartta.

### Super on kaiken keskipiste

Kaikki Cmd:n tai Windows-näppäimen ympärille rakentamasi lihasmuisti siirtyy yhdelle näppäimelle: Superille. Se on Windows-näppäin PC-näppäimistöllä, ja se on ankkuri lähes jokaiselle Omarchyn pikanäppäimelle.

Spotlight-, Raycast- tai Käynnistä-valikkorefleksistäsi tulee `Super + Space`. Se avaa Omarchy-valikon, joka käynnistää sovelluksia, muuttaa asetuksia, asentaa ohjelmistoja, kaappaa näytön — melkein kaiken. Ala kirjoittaa suodattaaksesi. `Super + Alt + Space` näyttää kaikki sovellukset yhdessä ruudukossa, niin kuin Launchpad tekee. Katso [navigointi](04-navigation.md).

### Ei työpöytäkuvakkeita, ja telakka näkyy vain kelluvalla työtilalla

Ei kuvakkeita järjesteltäväksi työpöydälle eikä telakkaa laatoittavalla työtilalla — telakka näkyy vain kelluvalla työtilalla (katso [navigointi](04-navigation.md)). Sovellukset käynnistyvät pikanäppäimellä (`Super + Return` päätteelle, `Super + Shift + Return` selaimelle ja `Super + K` kaikelle kartoitetulle) tai valikosta. Ainoa pysyvä osa käyttöliittymää on [yläpalkki](05-the-top-bar.md), joka hoitaa sen, mitä valikkorivi, järjestelmälokero ja Notification Center tekivät sinulle aiemmin — ja lähes jokainen sen pienoisohjelma tekee jotakin vasemmalla, oikealla ja keskimmäisellä napsautuksella.

### Ikkunat asettuvat itse paikalleen

Suurin ajattelutavan muutos: et raahaa ikkunoita ympäriinsä etkä napsauta niitä näytön puolikkaisiin. Avaa ikkuna, ja se valtaa koko näytön. Avaa toinen, ja ne jakavat sen. Et koskaan kalasta ikkunaa toisen alta, koska ikkunat eivät mene päällekkäin.

Kun todella tarvitset kelluvan ikkunan, `Super + T` vaihtaa aktiivisen ikkunan pois laatoituksesta (ja takaisin). Mutta anna laatoitukselle ensin kunnon mahdollisuus — se on koko jutun sydän. [Navigointi](04-navigation.md) opastaa sinut sen läpi.

Työtilat tuntuvat tutuilta: ne ovat macOS Spaces tai Windowsin virtuaalityöpöydät, paitsi että todella käytät niitä, koska `Super + 1/2/3/4` hyppää suoraan yhteen ja `Super + Shift + 1/2/3/4` lähettää aktiivisen ikkunan sinne. Ei animaatioviivettä, vain välittömiä hyppyjä. Tämä tarkoittaa, ettet ehkä edes tarvitse useita näyttöjä, jos olit tottunut siihen aiemmin.

### Kopiointi ja liittäminen vain toimivat

Macilla sinulla oli Cmd + C kaikkialla. Windowsilla sinulla oli Ctrl + C kaikkialla — paitsi päätteessä, jossa se tappaa ohjelmasi. Omarchy antaa sinulle `Super + C`, `Super + X` ja `Super + V`, ja ne toimivat kaikkialla, myös päätteessä. Ei erillistä refleksiä opeteltavaksi komentotulkille.

Windows-väelle: Win + V -leikepöytähistoriasi on näppäimillä `Super + Ctrl + V`, ja se säilyttää kuvia tekstin lisäksi. Katso [yhtenäinen leikepöytä ja historia](08-unified-clipboard-history.md).

### Käännöstaulukko

| Kaipaat tätä | Omarchyssa |
| ------------- | ---------- |
| Spotlight / Raycast / Käynnistä-valikko | `Super + Space` — Omarchy-valikko |
| AirDrop | LocalSend, näppäimillä `Super + Ctrl + S` — katso [graafiset sovellukset](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` tai `Print Screen` — katso [kuvakaappaukset ja tallennus](12-screenshots-recording.md) |
| Notification Center | Ilmoitushistoria näppäimillä `Super + Shift + Alt + ,` |
| Time Machine (järjestelmälle) | Automaattiset [järjestelmän tilannekuvat](47-system-snapshots.md) joka päivityksen yhteydessä |
| App Store / asennusohjelman lataaminen | _Install_ valikossa tai `omarchy pkg add` — katso [muut paketit](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ valikossa, joka muokkaa tavallisia määritystiedostoja — katso [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, näppäimillä `Super + Shift + F` — katso [graafiset sovellukset](22-guis.md) |
| Safari / Edge | Google Chrome näppäimillä `Super + Shift + Return`; valitse toinen kohdasta _Setup > Defaults > Browser_ — katso [selaimet](23-browsers.md) |
| Preview / Photos | Omaview kuville, videolle ja musiikille, Document Viewer PDF-tiedostoille — katso [graafiset sovellukset](22-guis.md) |
| TextEdit / Notepad | Plain, näppäimillä `Super + Shift + N`; valitse toinen kohdasta _Setup > Defaults > Editor_ |

### Jotkin asiat todella ovat toisin

Monet asetukset elävät muokkaamissasi tekstitiedostoissa, eivät paneeleissa, joita napsuttelet läpi. Se kuulostaa alkeelliselta, kunnes tajuat, että se tarkoittaa, että jokainen säätö voidaan nähdä, kopioida seuraavalle koneellesi ja laittaa versionhallintaan. _Setup_-valikko pudottaa sinut suoraan oikeaan tiedostoon ja käynnistää uudelleen kaiken uudelleenkäynnistettävän, kun olet valmis.

Päivitykset tulevat yhden komennon kautta — _Update > Omarchy_ — joka päivittää Omarchyn itsensä ja jokaisen järjestelmän paketin ja ottaa ensin tilannekuvan. Ei sovelluskohtaisia päivittäjiä nalkuttamassa sinulle satunnaisesti. Katso [päivitykset](30-updates.md).

Ohjelmistot tulevat paketinhallinnasta, eivät ladatuista asennusohjelmista.

Ja kun suljet ikkunan, sovellus todella lopettaa. Ei ole sellaista macOS-välitilaa, jossa ohjelma jatkaa toimintaansa ilman ikkunoita. `Super + W` — tai `Super + Q`, jos se on se sormimuisti, jonka kanssa saavuit — tarkoittaa poissa.

### Mac-laitteistolla

Omarchy toimii hyvin Intel-Maceilla — katso [Mac-tuki](44-mac-support.md). Ja näppäimistö on sinulle ystävällinen: Omarchy ei kartoita mitään uudelleen, ja Linux käsittelee Command-näppäintä Superina, joten Super istuu juuri siellä, missä Cmd aina oli. Peukalosi ei huomaa siirtoa.

### Anna sille kaksi viikkoa

Vaistot siirtyvät nopeammin kuin luuletkaan. Selaa [pikanäppäimet](07-hotkeys.md)-luku kerran, ja aina kun lyö tyhjää sitomuksen kanssa, paina `Super + K` — se näyttää ne kaikki sinulle. Se on ainoa pikanäppäin, joka sinun todella täytyy opetella ulkoa.
