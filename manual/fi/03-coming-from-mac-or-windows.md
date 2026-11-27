# Macista tai Windowsista siirtyminen

Jos olet viettänyt vuosia macOS:n tai Windowsin parissa, sormesi osaavat sata asiaa, jotka aivosi ovat unohtaneet koskaan oppineensakaan. Tämä luku on käännöskerros: minne nuo vaistot kuuluvat Omarchyssä. Ominaisuudet itsessään käsitellään perusteellisesti muualla — tämä on vain kartta.

### Super on kaiken keskipiste

Kaikki Cmd:n tai Windows-näppäimen ympärille rakentunut lihasmuistisi siirtyy yhdelle näppäimelle: Super. Se on PC-näppäimistön Windows-näppäin, ja se on lähes jokaisen Omarchyn pikanäppäimen ankkuri.

Spotlight-, Raycast- tai Käynnistä-valikkorefleksisi muuttuu muotoon `Super + Space`. Se avaa Omarchy-valikon, joka käynnistää sovelluksia, muuttaa asetuksia, asentaa ohjelmistoja, kaappaa näytön — melkein kaiken. Ala kirjoittaa suodattaaksesi. `Super + Alt + Space` näyttää kaikki sovellukset yhdessä ruudukossa, niin kuin Launchpad tekee. Katso [navigation](04-navigation.md).

### Ei työpöytäkuvakkeita, ja dock näkyy vain kelluessasi

Ei järjesteltäviä kuvakkeita työpöydällä eikä dockia laatoitetussa työtilassa — dock näkyy vain kelluvassa työtilassa (katso [navigation](04-navigation.md)). Sovellukset käynnistyvät pikanäppäimellä (`Super + Return` terminaalille, `Super + Shift + Return` selaimelle ja `Super + K` listalle kaikesta määritetystä) tai valikosta. Ainoa pysyvä käyttöliittymän osa on [the top bar](05-the-top-bar.md), joka kattaa sen, mitä valikkopalkki, ilmoitusalue ja Notification Center tekivät sinulle aiemmin — ja lähes jokainen sen widget tekee jotakin vasemmalla, oikealla ja keskimmäisellä napsautuksella.

### Ikkunat asettuvat itse

Suurin ajattelutavan muutos: et raahaa ikkunoita ympäriinsä etkä napsauta niitä näytön puolikkaisiin. Avaa ikkuna, ja se valtaa koko näytön. Avaa toinen, ja ne jakavat sen. Et koskaan kalastele ikkunaa toisen alta, koska ikkunat eivät mene päällekkäin.

Kun todella tarvitset kelluvan ikkunan, `Super + T` vaihtaa aktiivisen ikkunan pois laatoituksesta (ja takaisin). Mutta anna laatoitukselle ensin kunnon mahdollisuus — se on koko jutun sydän. [Navigation](04-navigation.md) opastaa sinut sen läpi.

Työtilat tuntuvat tutuilta: ne ovat macOS:n Spaces tai Windowsin virtuaalityöpöydät, paitsi että tulet todella käyttämään niitä, koska `Super + 1/2/3/4` hyppää suoraan yhteen ja `Super + Shift + 1/2/3/4` lähettää aktiivisen ikkunan sinne. Ei animaatioviivettä, vain välittömiä hyppyjä. Tämä tarkoittaa, ettet ehkä edes tarvitse useita näyttöjä, jos olit tottunut siihen aiemmin.

### Kopiointi ja liittäminen vain toimivat

Macilla sinulla oli Cmd + C kaikkialla. Windowsilla sinulla oli Ctrl + C kaikkialla — paitsi terminaalissa, jossa se tappaa ohjelmasi. Omarchy antaa sinulle `Super + C`, `Super + X` ja `Super + V`, ja ne toimivat kaikkialla, myös terminaalissa. Ei erillistä refleksiä opeteltavaksi komentotulkille.

Windows-väki: Win + V -leikepöytähistoriasi löytyy näppäimistä `Super + Ctrl + V`, ja se säilyttää kuvia sekä tekstiä. Katso [unified clipboard & history](08-unified-clipboard-history.md).

### Käännöstaulukko

| Etsit | Omarchyssä |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy-valikko |
| AirDrop | LocalSend, näppäimillä `Super + Ctrl + S` — katso [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` tai `Print Screen` — katso [screenshots & recording](12-screenshots-recording.md) |
| Notification Center | Ilmoitushistoria näppäimillä `Super + Shift + Alt + ,` |
| Time Machine (järjestelmälle) | Automaattiset [system snapshots](47-system-snapshots.md) jokaisella päivityksellä |
| App Store / asennusohjelman lataaminen | _Install_ valikossa tai `omarchy pkg add` — katso [other packages](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ valikossa, joka muokkaa tavallisia asetustiedostoja — katso [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, näppäimillä `Super + Shift + F` — katso [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome näppäimillä `Super + Shift + Return`; valitse toinen kohdasta _Setup > Defaults > Browser_ — katso [browsers](23-browsers.md) |
| Preview / Photos | Omaview kuville, videolle ja musiikille, Document Viewer PDF-tiedostoille — katso [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, näppäimillä `Super + Shift + N`; valitse toinen kohdasta _Setup > Defaults > Editor_ |

### Jotkin asiat todella ovat toisin

Monet asetukset sijaitsevat muokattavissa tekstitiedostoissa, eivät läpinapsuteltavissa paneeleissa. Se kuulostaa alkeelliselta, kunnes tajuat, että se tarkoittaa, että jokainen muutos voidaan nähdä, kopioida seuraavalle koneellesi ja laittaa versionhallintaan. _Setup_-valikko pudottaa sinut suoraan oikeaan tiedostoon ja käynnistää uudelleen sen, mikä tarvitsee uudelleenkäynnistyksen, kun olet valmis.

Päivitykset tulevat yhden komennon kautta — _Update > Omarchy_ — joka päivittää Omarchyn itsensä ja jokaisen järjestelmän paketin ja ottaa ensin tilannekuvan. Ei sovelluskohtaisia päivittäjiä ärsyttämässä sinua satunnaisesti. Katso [updates](30-updates.md).

Ohjelmistot tulevat paketinhallinnasta, eivät ladatuista asennusohjelmista.

Ja kun suljet ikkunan, sovellus todella lopettaa. Ei ole macOS:n välitilaa, jossa ohjelma jatkaa toimintaansa ilman ikkunoita. `Super + W` — tai `Super + Q`, jos se on se sormimuisti, jonka kanssa saavuit — tarkoittaa poissa.

### Mac-laitteistolla

Omarchy toimii hyvin Intel-Maceilla ja M1-, M2- ja M3-Maceilla Omarchy for Apple Silicon -version kanssa. Katso [Mac support](44-mac-support.md). Ja näppäimistö on sinulle ystävällinen: Omarchy ei määritä mitään uudelleen, ja Linux käsittelee Command-näppäintä Superina, joten Super istuu juuri siellä, missä Cmd aina oli. Peukalosi ei huomaa siirtoa.

### Anna sille kaksi viikkoa

Vaistot siirtyvät nopeammin kuin luuletkaan. Selaa [hotkeys](07-hotkeys.md)-luku kerran, ja aina kun jäät tyhjän päälle sitomuksen suhteen, paina `Super + K` — se näyttää sinulle ne kaikki. Se on ainoa pikanäppäin, joka sinun todella täytyy opetella ulkoa.
