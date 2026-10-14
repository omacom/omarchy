# Siirtyminen Macista tai Windowsista

Jos olet viettänyt vuosia macOS:in tai Windowsin parissa, sormesi osaavat sata asiaa, jotka aivosi ovat unohtaneet koskaan oppineensa. Tämä luku on käännöskerros: mihin ne vaistot menevät Omarchyssa. Ominaisuudet itsessään käsitellään syvällisesti muualla — tämä on vain kartta.

### Super on kaiken keskipiste

Kaikki Cmd- tai Windows-näppäimen ympärille rakentamasi lihasmuisti siirtyy yhdelle näppäimelle: Super. Se on Windows-näppäin PC-näppäimistössä, ja se on lähes jokaisen Omarchyn pikanäppäimen ankkuri.

Spotlight-, Raycast- tai Käynnistä-valikkovaistosi muuttuu yhdistelmäksi `Super + Space`. Se avaa Omarchy-valikon, joka käynnistää sovelluksia, muuttaa asetuksia, asentaa ohjelmistoja, kaappaa ruudun — oikeastaan kaiken. Aloita kirjoittaminen suodattaaksesi. `Super + Alt + Space` näyttää kaikki sovellukset yhdellä ruudukolla, niin kuin Launchpad tekee. Katso [navigointi](04-navigation.md).

### Dockia tai työpöydän kuvakkeita ei ole

Ei mitään klikattavaa asioiden käynnistämiseen, ei kuvakkeita järjesteltäväksi työpöydälle. Sovellukset käynnistyvät pikanäppäimellä (`Super + Return` pääätteelle, `Super + Shift + Return` selaimelle ja `Super + K` kaikista määritetyistä luettelolle) tai valikosta. Ainoa pysyvä käyttöliittymän osa on [yläpalkki](05-the-top-bar.md), joka kattaa sen, mitä valikkopalkki, järjestelmärivi ja Ilmoituskeskus tekivät sinulle aiemmin — ja lähes jokainen sen widget tekee jotain vasemmalla, oikealla ja keskimmäisellä napsautuksella.

### Ikkunat asettuvat paikoilleen itse

Suurin mielentavan muutos: et vedä ikkunoita ympäriinsä etkä napsauta niitä ruudun puolikkaille. Avaa ikkuna, ja se vie koko ruudun. Avaa toinen, ja ne jakavat sen. Et koskaan kaiva ikkunaa toisen alta, koska ikkunat eivät ole päällekkäin.

Kun todella tarvitset kelluvan ikkunan, `Super + T` vaihtaa aktiivisen ikkunan pois laatoituksesta (ja takaisin). Mutta anna laatoitukselle ensin kunnon mahdollisuus — se on koko asian sydän. [Navigointi](04-navigation.md) opastaa sinut sen läpi.

Työtilat tuntuvat tutuilta: ne ovat macOSin Spaces tai Windowsin virtuaalityöpöydät, paitsi että tulet todella käyttämään niitä, koska `Super + 1/2/3/4` hyppää suoraan yhteen ja `Super + Shift + 1/2/3/4` lähettää aktiivisen ikkunan sinne. Ei animaatioviivettä, vain välittömiä hyppyjä. Tämä tarkoittaa, että et välttämättä edes tarvitse useita näyttöjä, jos olit tottunut siihen aiemmin.

### Kopiointi ja liittäminen vain toimivat

Macilla sinulla oli Cmd + C kaikkialla. Windowsissa sinulla oli Ctrl + C kaikkialla — paitsi pääätteessä, jossa se tappaa ohjelmasi. Omarchy antaa sinulle yhdistelmät `Super + C`, `Super + X` ja `Super + V`, ja ne toimivat kaikkialla, myös pääätteessä. Kuorta varten ei tarvitse oppia erillistä vaistoa.

Windows-ihmiset: Win + V -leikepöytähistoriasi elää yhdistelmässä `Super + Ctrl + V`, ja se sisältää kuvia sekä tekstiä. Katso [yhtenäinen leikepöytä ja historia](08-unified-clipboard-history.md).

### Käännöstaulukko

| Kätesi tavoittelee | Omarchyssa |
| ------------- | ---------- |
| Spotlight / Raycast / Käynnistä-valikko | `Super + Space` — Omarchy-valikko |
| AirDrop | LocalSend yhdistelmällä `Super + Ctrl + S` — katso [GUI:t](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — katso [kuvakaappaukset ja tallennus](12-screenshots-recording.md) |
| Ilmoituskeskus | Ilmoitushistoria yhdistelmällä `Super + Shift + Alt + ,` |
| Time Machine (järjestelmää varten) | Automaattiset [järjestelmän tilannekuvat](47-system-snapshots.md) jokaisessa päivityksessä |
| App Store / asentajan lataaminen | _Asenna_ valikossa tai `omarchy pkg add` — katso [muut paketit](29-other-packages.md) |
| Järjestelmäasetukset / Ohjauspaneeli | _Asetukset_ valikossa, joka muokkaa tavallisia määritystiedostoja — katso [dotfiles](31-dotfiles.md) |

### Jotkin asiat todella ovat toisin

Monet asetukset elävät tekstitiedostoissa, joita muokkaat, ei paneeleissa, joita klikkailet läpi. Se kuulostaa alkukantaiselta, kunnes ymmärrät, että se tarkoittaa jokaisen säädön voivan nähdä, kopioida seuraavalle koneellesi ja laittaa versionhallintaan. _Asetukset_-valikko pudottaa sinut suoraan oikeaan tiedostoon ja käynnistää uudelleen kaiken, mikä tarvitsee käynnistämistä, kun olet valmis.

Päivitykset tulevat yhden komennon kautta — _Päivitä > Omarchy_ — joka päivittää Omarchyn itsensä ja jokaisen järjestelmän paketin ja ottaa ensin tilannekuvan. Ei sovelluskohtaisia, satunnaisesti häiritseviä päivittimiä. Katso [päivitykset](30-updates.md).

Ohjelmistot tulevat paketinhallinnasta, ei ladatuista asentajista.

Ja kun suljet ikkunan, sovellus todella sulkeutuu. Ei ole macOSin välitilaa, jossa ohjelma jatkaa pyörimistä ilman ikkunoita. `Super + W` — tai `Super + Q`, jos se on se sormimuisti, jolla tulit — tarkoittaa pois.

### Mac-laitteistolla

Omarchy toimii hyvin Intel-Maceilla — katso [Mac-tuki](44-mac-support.md). Ja näppäimistö on sinulle kiltti: Omarchy ei muuta mitään määrittelyjä, ja Linux kohtelee Command-näppäintä Superinä, joten Super istuu juuri siinä, missä Cmd aina oli. Peukalosi ei huomaa siirtoa.

### Anna sille kaksi viikkoa

Vaistot siirtyvät nopeammin kuin luulet. Selaa [pikanäppäimet](07-hotkeys.md)-luku kerran läpi, ja aina kun sidos ei tule mieleen, paina `Super + K` — se näyttää sinulle ne kaikki. Se on ainoa pikanäppäin, joka sinun todella täytyy muistaa ulkoa.
