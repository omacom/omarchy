# Graafiset sovellukset

## Files

Files (Nautilus) on graafinen tiedostonhallinta. `Super + Shift + F` avaa sen, ja `Super + Shift + Alt + F` avaa sen hakemistossa, jossa terminaalisi parhaillaan on, mikä säästää paljolta klikkailulta. `Ctrl + L` antaa sinun kirjoittaa polun, ja `Space`-näppäimen painaminen minkä tahansa tiedoston kohdalla antaa nopean esikatselun avaamatta mitään.

Kytke USB-tikku tai SD-kortti, niin se liitetään automaattisesti, joten se vain ilmestyy sivupalkkiin. Vaativampiin hommiin — aseman alustamiseen, SMART-kunnon tarkistamiseen, osioiden luomiseen — käynnistä _Disks_ sovelluskäynnistimestä (`Super + Space`).

Kaksoisnapsautus noudattaa järkeviä oletuksia: kuvat, videot ja musiikki avautuvat Omaview'ssa, PDF:t Document Viewerissä, Markdown Omawritessa ja pelkkä teksti editorissa, joka on valittu kohdassa _Setup > Default > Editor_.

## Disktree

Kun asema täyttyy etkä tiedä yhtään, mikä sitä syö, käynnistä [Disktree](https://github.com/tobi/disktree) sovelluskäynnistimestä (`Super + Space`). Se näyttää graafisen puukartan kotihakemistostasi. Suuremmat lohkot vievät enemmän tilaa; kulje hakemistoissa näppäimistöllä tai hiirellä, merkitse poistettavat ja tarkista valintasi ennen kuin poistat mitään. Suorita `disktree --disk` skannataksesi koko levyn.

## Obsidian

[Obsidian](https://obsidian.md/) on ilmainen ja erittäin laajennettava muistiinpanosovellus, joka käyttää tallennukseen yksinkertaisia Markdown-tiedostoja.

Obsidian on ilmainen kaikkiin tarkoituksiin, mukaan lukien henkilökohtaiseen, kaupalliseen ja voittoa tavoittelemattomaan käyttöön.

Obsidian tarjoaa myös [kaupallisen lisäosan synkronointiin](https://obsidian.md/sync) iOS- ja Android-mobiilisovellusten kanssa. (https://obsidian.md/pricing).

Käynnistät Obsidianin näppäimillä `Super + Shift + O`. Jotta voit käyttää teemojen synkronointia, sinun on valittava asetuksista `Omarchy`-teema.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchyn oma kuolettavan yksinkertainen Markdown-kirjoitussovellus. Ei holveja, ei lisäosia, vain sinä ja sanat.

Käynnistät Omawriten näppäimillä `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on peruskuvankäsittelytyökalu, joka sopii loistavasti rajaamiseen, koon muuttamiseen ja muihin perusmuokkauksiin. Älä vain odota Photoshop-vaihtoehtoa. Mutta siinä on silti Magic Wand ja tasot!

Käynnistät Pintan sovelluskäynnistimen kautta (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemasovellus, joka osaa poimia värejä taustakuvasta ja muuttaa ne täydelliseksi, yhtenäiseksi teemaksi. Se on helpoin tapa [luoda oma teemasi](43-making-your-own-theme.md).

Käynnistät Aetherin sovelluskäynnistimen kautta (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) antaa sinun lähettää tiedostoja muihin samassa verkossa sovellusta käyttäviin laitteisiin, kuten Applen AirDrop. Se on kuitenkin monialustainen, joten voit lähettää tiedostoja Windowsiin, macOS:ään, Androidiin, iOS:ään ja tietenkin Linuxiin ja niistä pois.

Voit avata Share-valikon näppäimillä `Super + Ctrl + S` tai Omarchy-valikon kohdasta _Trigger > Share_. Se tarjoaa neljä vaihtoehtoa:

- **Clipboard** lähettää kopioimasi sisällön tekstitiedostona. Loistava tapa saada linkki tai koodinpätkä puhelimeesi lähettämättä sitä itsellesi sähköpostissa.
- **File** avaa tiedostonvalitsimen, jossa voit valita useita kerralla.
- **Folder** lähettää kokonaisen hakemiston.
- **Receive** avaa varsinaisen LocalSendin, jotta toinen laite voi lähettää sinulle jotain.

Sama toimii terminaalista komennoilla `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jätä polku pois, niin saat valitsimen.

Voit myös lähettää suoraan tiedostonhallinnasta: napsauta mitä tahansa valintaa Nautiluksessa hiiren oikealla painikkeella ja valitse _Send via LocalSend_.

Omarchyn palomuuri on oletuksena suljettu LocalSendin porttia lukuun ottamatta, joten tämä toimii heti tuoreessa asennuksessa. Katso [tietoturva](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täydellinen toimistopaketti, jossa on tekstinkäsittely, taulukkolaskenta, esitykset, piirrossovellus ja paljon muuta. Se on yhteensopiva Microsoft Officen tiedostojen kanssa, joten tämä on loistava tapa pystyä avaamaan nuo Word-asiakirjat.

Käynnistät LibreOfficen sovelluskäynnistimen kautta (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchyn oma kuolettavan yksinkertainen esityssovellus. Esityksesi on yksi Markdown-tiedosto, jonka kuvat ja videot ovat sen vieressä: kirjoita jokainen dia live-esikatselun alle, raahaa diat järjestykseen ja esitä sitten koko näytöllä tai vie PDF- ja PowerPoint-muotoon. Se jopa poimii Omarchy-teemasi.

Käynnistät Hypen sovelluskäynnistimen kautta (`Super + Space`). Paina sen sisällä `?` nähdäksesi kaikki pikanäppäimet.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchyn oma kuolettavan yksinkertainen tapa allekirjoittaa PDF-tiedostoja ja täyttää niitä. Sijoita tallennettu allekirjoituksesi, tekstiä ja tämän päivän päivämäärä mihin tahansa kohtaan sivulla ja tallenna sitten allekirjoitettu kopio alkuperäisen viereen. Katso ohjeet kohdasta [PDF-tiedostojen täyttäminen](27-filling-out-pdfs.md).

Käynnistät Signedin sovelluskäynnistimen kautta (`Super + Space`) tai avaat sillä PDF:n tiedostonhallinnasta.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchyn oma kuolettavan yksinkertainen laskin, joka avautuu kelluvaan ikkunaan.

Käynnistät Omacalcin näppäimillä `Super + Shift + Q` (tai laskinnäppäimellä, jos näppäimistössäsi on sellainen).

## Signal

[Signal](https://signal.org/) on E2E-salatun viestinnän pioneeri ja loistava viestintävaihtoehto kaikille, jotka mieluummin eivät kulkisi yhden suuren teknologiajätin kautta.

Käynnistät Signalin näppäimillä `Super + Shift + G`. Se ei kuulu perusasennukseen, joten kun painat sitä ensimmäisen kerran, Omarchy tarjoaa sen asentamista puolestasi (se löytyy myös Omarchy-valikon kohdasta _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchyn oma kuolettavan yksinkertainen kuvankatselin ja mediasoitin: yksi ikkuna valokuvillesi, videoillesi ja musiikillesi. Avaa valokuva, niin nuolinäppäimet selaavat sen kansion muita tiedostoja, `N` ja `P` tekevät saman mille tahansa sisällölle, ja `Ctrl + M` näyttää koko kansion ruudukkona. Se näyttää myös HEIC-, AVIF- ja JPEG XL -valokuvia ja jatkaa siitä, mihin jäit missä tahansa pitkässä sisällössä.

Paina `F` saadaksesi koko näytön, `E` muokataksesi kuvaa Omasnapissa tai leikataksesi videota Omacutissa, `Ctrl + P` tulostaaksesi kuvan ja `Delete` siirtääksesi tiedoston roskakoriin (`Ctrl + Z` tuo sen takaisin). Paina sen sisällä `?` nähdäksesi kaikki pikanäppäimet.

Käynnistät Omaview'n nimellä _Media Viewer_ sovelluskäynnistimen kautta (`Super + Space`) tai yksinkertaisesti kaksoisnapsautat kuvaa, videota tai kappaletta tiedostonhallinnassa.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchyn oma kuolettavan yksinkertainen videonleikkaaja. Kun tarvitset vain leikata klipin alun ja lopun pois, se voittaa täyden videoeditorin käynnistämisen.

Käynnistät Omacutin sovelluskäynnistimen kautta (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchyn oma kuolettavan yksinkertainen verkkokameratallennin. Valitse kamerasi ja mikrofonisi kerran, paina sitten `Space` tallentaaksesi ja uudelleen keskeyttääksesi ja jatkaaksesi samaa otosta. Se tallentaa aina kamerasi korkeimmalla resoluutiolla, ja reaaliaikainen mikrofonimittari auttaa sinua tarkistamaan tasosi ennen aloittamista.

Lopeta otos, niin se avautuu heti sisäänrakennettuun editoriin. Kaksoisnapsauta klippiä jakaaksesi sen, raahaa kahvoja leikataksesi jokaisen palan ja poista osat, joita et halua. Tallenna se sitten MP4-tiedostona. Alkuperäinen tallenteesi säilytetään, kunnes hylkäät sen, joten voit aina palata ja leikata sen toisin.

Käynnistät Monologuen sovelluskäynnistimen kautta (`Super + Space`).
