# Tuletko Macista tai Windowsista

Jos olet viettänyt vuosia macOS:n tai Windowsin parissa, sormesi tietävät sata asiaa, jotka aivosi ovat unohtaneet koskaan oppineensa. Tämä luku on käännöskerros: mihin nuo vaistot menevät Omarchyssa. Ominaisuudet itsessään käsitellään perusteellisesti muualla — tämä on vain kartta.

### Super on kaiken keskipiste

Kaikki Cmd:n tai Windows-näppäimen ympärille rakentamasi lihasmuisti siirtyy yhdelle näppäimelle: Super. Se on PC-näppäimistön Windows-näppäin, ja se on lähes jokaisen Omarchyn pikanäppäimen ankkuri.

Spotlight-, Raycast- tai Käynnistä-valikkorefleksistäsi tulee `Super + Space`. Se avaa Omarchy-valikon, joka käynnistää sovelluksia, muuttaa asetuksia, asentaa ohjelmistoja, kaappaa näytön — melkein kaiken. Ala kirjoittaa suodattaaksesi. `Super + Alt + Space` näyttää jokaisen sovelluksen yhdessä ruudukossa, niin kuin Launchpad tekee. Katso [navigointi](04-navigation.md).

### Telakkaa ja työpöytäkuvakkeita ei ole

Ei mitään klikattavaa asioiden käynnistämiseen, ei kuvakkeita järjesteltäväksi työpöydälle. Sovellukset käynnistyvät pikanäppäimellä (`Super + Return` terminaalille, `Super + Shift + Return` selaimelle ja `Super + K` listalle kaikesta määritetystä) tai valikosta. Ainoa pysyvä käyttöliittymän osa on [yläpalkki](05-the-top-bar.md), joka kattaa sen, mitä valikkorivi, ilmaisinalue ja Ilmoituskeskus tekivät sinulle aiemmin — ja lähes jokainen sen widget tekee jotakin vasemmalla, oikealla ja keskiklikkauksella.

### Ikkunat asettuvat itse paikalleen

Suurin ajattelutavan muutos: et raahaa ikkunoita ympäriinsä etkä napsauta niitä näytön puolikkaille. Avaa ikkuna, ja se vie koko näytön. Avaa toinen, ja ne jakavat sen. Et koskaan kaiva ikkunaa toisen alta, koska ikkunat eivät mene päällekkäin.

Kun todella tarvitset kelluvan ikkunan, `Super + T` siirtää aktiivisen ikkunan pois ruudukkoasettelusta (ja takaisin). Mutta anna ruudukkoasettelulle ensin kunnon mahdollisuus — se on koko jutun sydän. [Navigointi](04-navigation.md) opastaa sinut sen läpi.

Työtilat tuntuvat tutuilta: ne ovat macOS:n Spaces tai Windowsin virtuaalityöpöydät, paitsi että todella käytät niitä, koska `Super + 1/2/3/4` hyppää suoraan yhteen ja `Super + Shift + 1/2/3/4` lähettää aktiivisen ikkunan sinne. Ei animaatioviivettä, vain välittömiä hyppyjä. Tämä tarkoittaa, ettet ehkä edes tarvitse useita näyttöjä, jos olit tottunut niihin aiemmin.

### Kopiointi ja liittäminen vain toimivat

Macilla sinulla oli Cmd + C kaikkialla. Windowsilla sinulla oli Ctrl + C kaikkialla — paitsi terminaalissa, jossa se tappaa ohjelmasi. Omarchy antaa sinulle `Super + C`, `Super + X` ja `Super + V`, ja ne toimivat kaikkialla, myös terminaalissa. Ei erillistä refleksiä opittavaksi komentotulkille.

Windows-väki: Win + V -leikepöytähistoriasi on kohdassa `Super + Ctrl + V`, ja se säilyttää kuvien lisäksi myös tekstiä. Katso [yhtenäinen leikepöytä ja historia](08-unified-clipboard-history.md).

### Käännöstaulukko

| Etsit tätä | Omarchyssa |
| ------------- | ---------- |
| Spotlight / Raycast / Käynnistä-valikko | `Super + Space` — Omarchy-valikko |
| AirDrop | LocalSend, kautta `Super + Ctrl + S` — katso [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` tai `Print Screen` — katso [kuvakaappaukset ja tallennus](12-screenshots-recording.md) |
| Ilmoituskeskus | Ilmoitushistoria kohdassa `Super + Shift + Alt + ,` |
| Time Machine (järjestelmälle) | Automaattiset [järjestelmän tilannevedokset](47-system-snapshots.md) jokaisella päivityksellä |
| App Store / asennusohjelman lataaminen | _Install_ valikossa tai `omarchy pkg add` — katso [muut paketit](29-other-packages.md) |
| Järjestelmäasetukset / Ohjauspaneeli | _Setup_ valikossa, joka muokkaa tavallisia asetustiedostoja — katso [dotfiles](31-dotfiles.md) |

### Jotkin asiat todella ovat toisin

Monet asetukset ovat muokattavissa tekstitiedostoissa, eivät klikkailtavissa paneeleissa. Se kuulostaa alkeelliselta, kunnes tajuat, että se tarkoittaa, että jokainen muutos voidaan nähdä, kopioida seuraavalle koneellesi ja laittaa versionhallintaan. _Setup_-valikko pudottaa sinut suoraan oikeaan tiedostoon ja käynnistää uudelleen sen, mikä on käynnistettävä uudelleen, kun olet valmis.

Päivitykset tulevat yhden komennon kautta — _Update > Omarchy_ — joka päivittää Omarchyn itsensä ja jokaisen järjestelmän paketin ja ottaa ensin tilannevedoksen. Ei yksittäisten sovellusten päivittäjiä nalkuttamassa sinulle satunnaisesti. Katso [päivitykset](30-updates.md).

Ohjelmistot tulevat paketinhallinnasta, eivät ladatuista asennusohjelmista.

Ja kun suljet ikkunan, sovellus todella sulkeutuu. Ei ole macOS-limboaa, jossa ohjelma jatkaa käynnissä ilman ikkunoita. `Super + W` — tai `Super + Q`, jos se on sormimuisti, jonka kanssa saavuit — tarkoittaa mennyttä.

### Mac-laitteistolla

Omarchy toimii hyvin Intel-Maceilla — katso [Mac-tuki](44-mac-support.md). Ja näppäimistö on sinulle ystävällinen: Omarchy ei määritä mitään uudelleen, ja Linux käsittelee Command-näppäintä Superina, joten Super on juuri siellä, missä Cmd aina oli. Peukalosi ei huomaa siirtoa.

### Anna sille kaksi viikkoa

Vaistot siirtyvät nopeammin kuin luuletkaan. Selaa [pikanäppäimet](07-hotkeys.md)-luku kerran läpi, ja aina kun et muista jotakin näppäinyhdistelmää, paina `Super + K` — se näyttää ne kaikki. Se on ainoa pikanäppäin, joka sinun todella täytyy opetella ulkoa.
