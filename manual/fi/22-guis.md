# Graafiset käyttöliittymät

## Files

Files (Nautilus) on graafinen tiedostonhallinta. `Super + Shift + F` avaa sen, ja `Super + Shift + Alt + F` avaa sen hakemistossa, jossa päätteesi parhaillaan on, mikä säästää paljolta klikkailulta. `Ctrl + L` antaa sinun kirjoittaa polun, ja `Space`-näppäimen painaminen minkä tahansa tiedoston kohdalla antaa nopean esikatselun avaamatta mitään.

Kytke USB-tikku tai SD-kortti, niin se liitetään automaattisesti, joten se vain ilmestyy sivupalkkiin. Kaikkeen vaativampaan — aseman alustamiseen, SMART-kunnon tarkistamiseen, osioiden luomiseen — käynnistä _Disks_ sovelluskäynnistimestä (`Super + Space`).

Kaksoisnapsautus noudattaa järkeviä oletuksia: kuvat, videot ja musiikki avautuvat Omaviewissa, PDF-tiedostot Document Viewerissa, Markdown Omawritessa ja pelkkä teksti editorissa, joka on valittu kohdassa _Setup > Default > Editor_.

## Disktree

Kun asema täyttyy etkä tiedä yhtään, mikä sitä syö, käynnistä [Disktree](https://github.com/tobi/disktree) sovelluskäynnistimestä (`Super + Space`). Se näyttää kotihakemistostasi graafisen puukartan. Suuremmat lohkot vievät enemmän tilaa; kulje hakemistoissa näppäimistöllä tai hiirellä, merkitse poistettavat ja tarkista valintasi ennen kuin poistat mitään. Aja `disktree --disk` skannataksesi koko levyn.

## Obsidian

[Obsidian](https://obsidian.md/) on ilmainen ja erittäin laajennettava muistiinpanosovellus, joka käyttää tallennukseen yksinkertaisia Markdown-tiedostoja.

Obsidian on ilmainen kaikkeen käyttöön, myös henkilökohtaiseen, kaupalliseen ja voittoa tavoittelemattomaan käyttöön.

Obsidian tarjoaa myös [kaupallisen lisäosan synkronointiin](https://obsidian.md/sync) iOS- ja Android-mobiilisovellusten kanssa. (https://obsidian.md/pricing).

Käynnistät Obsidianin näppäimillä `Super + Shift + O`. Teeman synkronoinnin käyttämiseksi sinun on valittava asetuksista `Omarchy`-teema.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchyn oma äärimmäisen yksinkertainen Markdown-kirjoitussovellus. Ei holveja, ei lisäosia, vain sinä ja sanat.

Käynnistät Omawriten näppäimillä `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on peruskuvankäsittelytyökalu, joka sopii erinomaisesti rajaamiseen, koon muuttamiseen ja muihin perusmuokkauksiin. Älä vain odota Photoshop-vaihtoehtoa. Mutta siinä on silti Magic Wand ja tasot!

Käynnistät Pintan sovelluskäynnistimen kautta (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemasovellus, joka osaa poimia värit taustakuvasta ja muuttaa ne täydelliseksi, yhtenäiseksi teemaksi. Se on helpoin tapa [tehdä oma teemasi](43-making-your-own-theme.md).

Käynnistät Aetherin sovelluskäynnistimen kautta (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) antaa sinun lähettää tiedostoja muihin samassa verkossa oleviin laitteisiin, joissa sovellus on käytössä, kuten Applen AirDrop. Se on kuitenkin monialustainen, joten voit lähettää tiedostoja Windowsin, macOS:n, Androidin, iOS:n ja tietenkin Linuxin välillä.

Voit avata Share-valikon näppäimillä `Super + Ctrl + S` tai Omarchy-valikon kohdasta _Trigger > Share_. Se antaa sinulle neljä vaihtoehtoa:

- **Clipboard** lähettää kopioimasi sisällön tekstitiedostona. Erinomainen tapa saada linkki tai koodinpätkä puhelimeesi lähettämättä itsellesi sähköpostia.
- **File** avaa tiedostonvalitsimen, jossa voit valita useita kerralla.
- **Folder** lähettää kokonaisen hakemiston.
- **Receive** avaa varsinaisen LocalSendin, jotta toinen laite voi lähettää sinulle jotain.

Sama toimii päätteestä komennoilla `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jätä polku pois, niin saat valitsimen.

Voit lähettää myös suoraan tiedostonhallinnasta: napsauta mitä tahansa valintaa Nautiluksessa hiiren kakkospainikkeella ja valitse _Send via LocalSend_.

Omarchyn palomuuri on oletuksena suljettu LocalSendin porttia lukuun ottamatta, joten tämä toimii heti tuoreessa asennuksessa. Katso [tietoturva](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täydellinen toimistopaketti, jossa on tekstinkäsittelyohjelma, taulukkolaskenta, esitykset, piirrossovellus ja paljon muuta. Se on yhteensopiva Microsoft Officen tiedostojen kanssa, joten tämä on erinomainen tapa pystyä avaamaan nuo Word-asiakirjat.

Käynnistät LibreOfficen sovelluskäynnistimen kautta (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchyn oma äärimmäisen yksinkertainen esityssovellus. Esityksesi on yksi Markdown-tiedosto, jonka kuvat ja videot ovat sen vieressä: kirjoita jokainen dia elävän esikatselun alle, vedä diat järjestykseen ja esitä sitten koko näytön tilassa tai vie PDF-muotoon ja PowerPointiin. Se poimii jopa Omarchy-teemasi.

Käynnistät Hypen sovelluskäynnistimen kautta (`Super + Space`). Paina sen sisällä `?` nähdäksesi kaikki pikanäppäimet.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchyn oma äärimmäisen yksinkertainen tapa allekirjoittaa ja täyttää PDF-tiedostoja. Sijoita tallennettu allekirjoituksesi, tekstiä ja tämän päivän päivämäärä minne tahansa sivulle ja tallenna sitten allekirjoitettu kopio alkuperäisen viereen. Katso ohjeet kohdasta [PDF-tiedostojen täyttäminen](27-filling-out-pdfs.md).

Käynnistät Signedin sovelluskäynnistimen kautta (`Super + Space`) tai avaat PDF-tiedoston sillä tiedostonhallinnasta.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) on Omarchyn oma 3D-shakkipeli. Pelaa ystävää vastaan samalla tietokoneella tai sisäänrakennettua vastustajaa vastaan kolmella tasolla, neljällä veistetyllä pelisetillä, joista jokainen liikkuu omalla tavallaan: kiertorata-alukset, veistetty puu ja norsunluu, metsän olennot ja karkki. Peleissä ei ole kelloa, ja ne tallentuvat jokaisen siirron jälkeen.

Käynnistät Checkmaten sovelluskäynnistimen kautta (`Super + Space`). Paina sen sisällä `?` nähdäksesi kaikki pikanäppäimet.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchyn oma äärimmäisen yksinkertainen laskin, joka avautuu kelluvaan ikkunaan.

Käynnistät Omacalcin näppäimillä `Super + Shift + Q` (tai laskinnäppäimellä, jos näppäimistössäsi on sellainen).

## Signal

[Signal](https://signal.org/) on E2E-salatun viestinnän pioneeri ja erinomainen viestintävaihtoehto kaikille, jotka eivät haluaisi mieluummin kulkea yhden suuren teknologiajätin kautta.

Käynnistät Signalin näppäimillä `Super + Shift + G`. Se ei ole osa perusasennusta, joten ensimmäisellä kerralla kun painat sitä, Omarchy tarjoaa sen asentamista puolestasi (se löytyy myös Omarchy-valikon kohdasta _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchyn oma äärimmäisen yksinkertainen kuvankatselin ja mediasoitin: yksi ikkuna valokuvillesi, videoillesi ja musiikillesi. Avaa valokuva, niin nuolinäppäimet selaavat sen kansion loput tiedostot, `N` ja `P` tekevät saman mille tahansa, ja `Ctrl + M` näyttää koko kansion ruudukkona. Se näyttää myös HEIC-, AVIF- ja JPEG XL -valokuvia ja jatkaa pitkissäkin sisällöissä siitä, mihin jäit.

Paina `F` siirtyäksesi koko näytön tilaan, `E` muokataksesi kuvaa Omasnapissa tai leikataksesi videota Omacutissa, `Ctrl + P` tulostaaksesi kuvan ja `Delete` siirtääksesi tiedoston Trash-kansioon (`Ctrl + Z` tuo sen takaisin). Paina sen sisällä `?` nähdäksesi kaikki pikanäppäimet.

Käynnistät Omaviewin nimellä _Media Viewer_ sovelluskäynnistimen kautta (`Super + Space`) tai kaksoisnapsautat vain kuvaa, videota tai kappaletta tiedostonhallinnassa.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchyn oma äärimmäisen yksinkertainen videoleikkuri. Kun sinun tarvitsee vain leikata klipin alku ja loppu pois, se päihittää täyden videoeditorin käynnistämisen.

Käynnistät Omacutin sovelluskäynnistimen kautta (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchyn oma äärimmäisen yksinkertainen verkkokameratallennin. Valitse kamerasi ja mikrofonisi kerran, paina sitten `Space` tallentaaksesi ja uudelleen keskeyttääksesi ja jatkaaksesi samaa otosta. Se tallentaa aina kamerasi korkeimmalla tarkkuudella, ja siinä on reaaliaikainen mikrofonimittari, jotta voit tarkistaa tasosi ennen aloittamista.

Lopeta otos, niin se avautuu heti sisäänrakennetussa editorissa. Kaksoisnapsauta klippiä jakaaksesi sen, vedä kahvoja trimmaksesi jokaisen palan ja poista osat, joita et halua. Tallenna se sitten MP4-tiedostona. Alkuperäinen tallenteesi säilytetään, kunnes hylkäät sen, joten voit aina palata ja leikata sen toisin.

Käynnistät Monologuen sovelluskäynnistimen kautta (`Super + Space`).
