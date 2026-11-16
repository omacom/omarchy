# GUI-sovellukset

## Files

Files (Nautilus) on graafinen tiedostonhallintaohjelma. `Super + Shift + F` avaa sen, ja `Super + Shift + Alt + F` avaa sen hakemistossa, jossa terminaalisi parhaillaan on, mikä säästää paljolta klikkailulta. `Ctrl + L` antaa sinun kirjoittaa polun, ja `Space` minkä tahansa tiedoston kohdalla antaa nopean esikatselun avaamatta mitään.

Kytke USB-tikku tai SD-kortti, ja se liitetään automaattisesti, joten se vain ilmestyy sivupalkkiin. Kaikkeen monimutkaisempaan — aseman alustamiseen, SMART-kunnon tarkistamiseen, osioiden luomiseen — käynnistä _Disks_ sovelluskäynnistimestä (`Super + Space`).

Kaksoisnapsautus noudattaa järkeviä oletuksia: kuvat, videot ja musiikki avautuvat Omaviewissa, PDF:t Document Viewerissa ja pelkkä teksti Neovimissa.

## Disktree

Kun levy täyttyy etkä tiedä yhtään, mikä sitä syö, käynnistä [Disktree](https://github.com/tobi/disktree) sovelluskäynnistimestä (`Super + Space`). Se näyttää kotihakemistosi graafisena puukarttana. Suuremmat lohkot vievät enemmän tilaa; kulje hakemistoissa näppäimistöllä tai hiirellä, merkitse poistettavat kohteet ja tarkista valintasi ennen kuin poistat mitään. Suorita `disktree --disk` skannataksesi koko levyn.

## Obsidian

[Obsidian](https://obsidian.md/) on ilmainen ja erittäin laajennettava muistiinpanosovellus, joka käyttää tallennukseen yksinkertaisia Markdown-tiedostoja.

Obsidian on ilmainen kaikkiin tarkoituksiin, myös henkilökohtaiseen, kaupalliseen ja voittoa tavoittelemattomaan käyttöön.

Obsidian tarjoaa myös [kaupallisen lisäosan synkronointiin](https://obsidian.md/sync) iOS- ja Android-mobiilisovellusten kanssa. (https://obsidian.md/pricing).

Käynnistät Obsidianin näppäinyhdistelmällä `Super + Shift + O`. Teemojen synkronoinnin käyttämiseksi sinun on valittava asetuksista `Omarchy`-teema.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchyn oma äärimmäisen yksinkertainen Markdown-kirjoitussovellus. Ei holveja, ei liitännäisiä, vain sinä ja sanat.

Käynnistät Omawriten näppäinyhdistelmällä `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on yksinkertainen kuvankäsittelytyökalu, joka sopii erinomaisesti rajaamiseen, koon muuttamiseen ja muihin perusmuokkauksiin. Älä vain odota Photoshop-vaihtoehtoa. Mutta siinä on silti Magic Wand ja tasot!

Käynnistät Pintan sovelluskäynnistimen kautta (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemasovellus, joka voi poimia värit taustakuvasta ja muuttaa ne täydelliseksi, yhtenäiseksi teemaksi. Se on helpoin tapa [tehdä oma teemasi](43-making-your-own-theme.md).

Käynnistät Aetherin sovelluskäynnistimen kautta (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) antaa sinun lähettää tiedostoja muille samassa verkossa sovellusta käyttäville laitteille, kuten Applen AirDrop. Se on kuitenkin monialustainen, joten voit lähettää tiedostoja Windowsiin, macOS:ään, Androidiin, iOS:ään ja tietenkin Linuxiin ja niistä takaisin.

Voit avata Share-valikon näppäinyhdistelmällä `Super + Ctrl + S` tai Omarchy-valikosta kohdasta _Trigger > Share_. Se tarjoaa neljä vaihtoehtoa:

- **Clipboard** lähettää kopioimasi sisällön tekstitiedostona. Erinomainen tapa saada linkki tai koodinpätkä puhelimeesi lähettämättä itsellesi sähköpostia.
- **File** avaa tiedostonvalitsimen, jossa voit valita useita kerralla.
- **Folder** lähettää kokonaisen hakemiston.
- **Receive** avaa varsinaisen LocalSendin, jotta toinen laite voi lähettää jotain sinulle.

Sama toimii terminaalista komennolla `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jätä polku pois, niin saat valitsimen.

Voit myös lähettää suoraan tiedostonhallinnasta: napsauta mitä tahansa valintaa Nautiluksessa hiiren oikealla painikkeella ja valitse _Send via LocalSend_.

Omarchyn palomuuri on oletuksena suljettu LocalSendin porttia lukuun ottamatta, joten tämä toimii heti tuoreessa asennuksessa. Katso [tietoturva](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täydellinen toimistopaketti, jossa on tekstinkäsittelyohjelma, taulukkolaskenta, esitykset, piirrossovellus ja paljon muuta. Se on yhteensopiva Microsoft Officen tiedostojen kanssa, joten tämä on erinomainen tapa päästä avaamaan nuo Word-asiakirjat.

Käynnistät LibreOfficen sovelluskäynnistimen kautta (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchyn oma äärimmäisen yksinkertainen esityssovellus. Esityksesi on yksi Markdown-tiedosto, jonka kuvat ja videot ovat sen vieressä: kirjoita jokainen dia reaaliaikaisen esikatselun alapuolelle, vedä diat järjestykseen ja esitä sitten koko näytöllä tai vie PDF- ja PowerPoint-muotoon. Se jopa poimii Omarchy-teemasi.

Käynnistät Hypen sovelluskäynnistimen kautta (`Super + Space`). Paina `?` sen sisällä nähdäksesi kaikki pikanäppäimet.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchyn oma äärimmäisen yksinkertainen tapa allekirjoittaa PDF-tiedostoja ja täyttää niitä. Sijoita tallennettu allekirjoituksesi, tekstiä ja tämän päivän päivämäärä minne tahansa sivulle ja tallenna sitten allekirjoitettu kopio alkuperäisen viereen. Katso ohjeet kohdasta [PDF-tiedostojen täyttäminen](27-filling-out-pdfs.md).

Käynnistät Signedin sovelluskäynnistimen kautta (`Super + Space`), tai avaa sillä PDF tiedostonhallinnasta.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchyn oma äärimmäisen yksinkertainen laskin, joka avautuu kelluvassa ikkunassa.

Käynnistät Omacalcin näppäinyhdistelmällä `Super + Shift + Q` (tai laskinnäppäimellä, jos näppäimistössäsi on sellainen).

## Signal

[Signal](https://signal.org/) on E2E-salatun viestinnän pioneeri ja erinomainen viestintävaihtoehto kaikille, jotka eivät halua kulkea jonkin suuren teknologiakonglomeraatin kautta.

Käynnistät Signalin näppäinyhdistelmällä `Super + Shift + G`. Se ei kuulu perusasennukseen, joten kun painat sitä ensimmäisen kerran, Omarchy tarjoaa sen asentamista puolestasi (se löytyy myös Omarchy-valikosta kohdasta _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchyn oma äärimmäisen yksinkertainen kuvankatselin ja mediasoitin: yksi ikkuna valokuvillesi, videoillesi ja musiikillesi. Avaa valokuva, ja nuolinäppäimet kulkevat vaiheittain sen kansion muun sisällön läpi, `N` ja `P` tekevät saman mille tahansa sisällölle, ja `Ctrl + M` näyttää koko kansion ruudukkona. Se näyttää myös HEIC-, AVIF- ja JPEG XL -valokuvia ja jatkaa pitkissä sisällöissä siitä, mihin jäit.

Paina `F` siirtyäksesi koko näyttöön, `E` muokataksesi kuvaa Omasnapissa tai leikataksesi videota Omacutissa, `Ctrl + P` tulostaaksesi kuvan ja `Delete` siirtääksesi tiedoston roskakoriin (`Ctrl + Z` tuo sen takaisin). Paina `?` sen sisällä nähdäksesi kaikki pikanäppäimet.

Käynnistät Omaviewin nimellä _Media Viewer_ sovelluskäynnistimen kautta (`Super + Space`), tai kaksoisnapsauta vain kuvaa, videota tai kappaletta tiedostonhallinnassa.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchyn oma äärimmäisen yksinkertainen videoleikkuri. Kun tarvitset vain leikata klipin alun ja lopun pois, se on huomattavasti kätevämpää kuin täyden videoeditorin käynnistäminen.

Käynnistät Omacutin sovelluskäynnistimen kautta (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchyn oma äärimmäisen yksinkertainen verkkokameratallennin. Valitse kamerasi ja mikrofonisi kerran, paina sitten `Space` tallentaaksesi ja uudelleen keskeyttääksesi ja jatkaaksesi samaa otosta. Se tallentaa aina kamerasi korkeimmalla resoluutiolla, ja reaaliaikainen mikrofonimittari auttaa sinua tarkistamaan tasosi ennen aloittamista.

Kun lopetat otoksen, se avautuu heti sisäänrakennetussa editorissa. Kaksoisnapsauta klippiä jakaaksesi sen, vedä kahvoista leikataksesi jokaisen osan ja poista osat, joita et halua. Tallenna se sitten MP4-tiedostona. Alkuperäinen tallenteesi säilytetään, kunnes hylkäät sen, joten voit aina palata ja leikata sen toisin.

Käynnistät Monologuen sovelluskäynnistimen kautta (`Super + Space`).
