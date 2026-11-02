# Graafiset sovellukset

## Tiedostot

Files (Nautilus) on graafinen tiedostonhallinta. `Super + Shift + F` avaa sen, ja `Super + Shift + Alt + F` avaa sen kansiossa, jossa päätteesi parhaillaan on, mikä säästää paljolta klikkailulta. `Ctrl + L` antaa kirjoittaa polun, ja `Space`-näppäimen painaminen minkä tahansa tiedoston kohdalla antaa nopean esikatselun avaamatta mitään.

Kytke USB-tikku tai SD-kortti, niin se liitetään automaattisesti, joten se vain ilmestyy sivupalkkiin. Kaikkea monimutkaisempaa varten — aseman alustaminen, SMART-kunnon tarkistaminen, osioiden luominen — käynnistä _Disks_ sovelluskäynnistimestä (`Super + Space`).

Kaksoisnapsautus noudattaa järkeviä oletuksia: kuvat avautuvat imv:ssä, videot mpv:ssä, PDF:t Document Viewerissä ja pelkkä teksti Neovimissa.

## Disktree

Kun asema täyttyy etkä tiedä lainkaan, mikä sitä syö, käynnistä [Disktree](https://github.com/tobi/disktree) sovelluskäynnistimestä (`Super + Space`). Se näyttää kotikansiosi graafisena puukarttana. Suuremmat lohkot vievät enemmän tilaa; kulje kansioissa näppäimistöllä tai hiirellä, merkitse poistettavat ja tarkista valintasi ennen kuin poistat mitään. Suorita `disktree --disk` skannataksesi koko levyn.

## Obsidian

[Obsidian](https://obsidian.md/) on ilmainen ja erittäin laajennettava muistiinpanosovellus, joka käyttää tallennukseen yksinkertaisia Markdown-tiedostoja.

Obsidian on ilmainen kaikkeen käyttöön, mukaan lukien henkilökohtaiseen, kaupalliseen ja voittoa tavoittelemattomaan käyttöön.

Obsidian tarjoaa myös [kaupallisen lisäosan synkronointiin](https://obsidian.md/sync) iOS- ja Android-mobiilisovellusten kanssa. (https://obsidian.md/pricing).

Käynnistät Obsidianin näppäinyhdistelmällä `Super + Shift + O`. Teeman synkronoinnin käyttämiseksi sinun on valittava asetuksista `Omarchy`-teema.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchyn oma äärimmäisen yksinkertainen Markdown-kirjoitussovellus. Ei holveja, ei lisäosia, vain sinä ja sanat.

Käynnistät Omawrite näppäinyhdistelmällä `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on peruskuvankäsittelytyökalu, joka sopii erinomaisesti rajaamiseen, koon muuttamiseen ja muihin perusmuokkauksiin. Älä vain odota Photoshopin korvaajaa. Mutta siinä on silti Magic Wand ja tasot!

Käynnistät Pintan sovelluskäynnistimen kautta (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemasovellus, joka voi poimia värejä taustakuvasta ja muuttaa ne täydelliseksi, yhtenäiseksi teemaksi. Se on helpoin tapa [luoda oma teemasi](43-making-your-own-theme.md).

Käynnistät Aetherin sovelluskäynnistimen kautta (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) antaa lähettää tiedostoja muihin samassa verkossa oleviin laitteisiin, joissa sovellus on käytössä, Applen AirDropin tapaan. Se on kuitenkin monialustainen, joten voit lähettää tiedostoja Windowsiin, macOS:ään, Androidiin, iOS:ään ja tietenkin Linuxiin ja niistä takaisin.

Voit avata Share-valikon näppäinyhdistelmällä `Super + Ctrl + S` tai Omarchy-valikosta kohdasta _Trigger > Share_. Se antaa neljä vaihtoehtoa:

- **Clipboard** lähettää kopioimasi sisällön tekstitiedostona. Erinomainen linkin tai koodinpätkän saamiseen puhelimeesi ilman, että lähetät itsellesi sähköpostia.
- **File** avaa tiedostonvalitsimen, jossa voit valita useita kerralla.
- **Folder** lähettää kokonaisen kansion.
- **Receive** avaa varsinaisen LocalSendin, jotta toinen laite voi lähettää sinulle jotain.

Sama toimii päätteestä komennoilla `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jätä polku pois, niin saat valitsimen.

Voit myös lähettää suoraan tiedostonhallinnasta: napsauta mitä tahansa valintaa Nautiluksessa hiiren oikealla painikkeella ja valitse _Send via LocalSend_.

Omarchyn palomuuri on oletuksena suljettu LocalSendin porttia lukuun ottamatta, joten tämä toimii heti tuoreessa asennuksessa. Katso [tietoturva](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täydellinen toimistopaketti, jossa on tekstinkäsittely, taulukkolaskenta, esitykset, piirrossovellus ja paljon muuta. Se on yhteensopiva Microsoft Officen tiedostojen kanssa, joten tämä on erinomainen tapa pystyä avaamaan nuo Word-asiakirjat.

Käynnistät LibreOfficen sovelluskäynnistimen kautta (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchyn oma äärimmäisen yksinkertainen esityssovellus. Esityksesi on yksi Markdown-tiedosto, jonka kuvat ja videot ovat sen vieressä: kirjoita jokainen dia reaaliaikaisen esikatselun alle, vedä diat järjestykseen ja esitä sitten koko näytöllä tai vie PDF:ksi ja PowerPointiin. Se nappaa jopa Omarchy-teemasi.

Käynnistät Hypen sovelluskäynnistimen kautta (`Super + Space`). Paina sen sisällä `?` nähdäksesi kaikki pikanäppäimet.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchyn oma äärimmäisen yksinkertainen tapa allekirjoittaa PDF:iä ja täyttää niitä. Aseta tallennettu allekirjoituksesi, tekstiä ja tämän päivän päivämäärä mihin tahansa sivulle ja tallenna sitten allekirjoitettu kopio alkuperäisen viereen. Katso ohjeet kohdasta [PDF-tiedostojen täyttäminen](27-filling-out-pdfs.md).

Käynnistät Signedin sovelluskäynnistimen kautta (`Super + Space`) tai avaat sillä PDF:n tiedostonhallinnasta.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchyn oma äärimmäisen yksinkertainen laskin, joka avautuu kelluvaan ikkunaan.

Käynnistät Omacalcin näppäinyhdistelmällä `Super + Shift + Q` (tai laskinnäppäimellä, jos näppäimistössäsi on sellainen).

## Signal

[Signal](https://signal.org/) on E2E-salatun viestinnän pioneeri ja erinomainen viestintävaihtoehto kaikille, jotka eivät mieluummin kulkisi yhden suuren teknologiakonglomeraatin kautta.

Käynnistät Signalin näppäinyhdistelmällä `Super + Shift + G`. Se ei ole osa perusasennusta, joten kun painat sitä ensimmäisen kerran, Omarchy tarjoaa sen asentamista puolestasi (se on myös Omarchy-valikossa kohdassa _Install > Service_).

## mpv

[mpv](https://mpv.io/) on yksinkertainen, nopea mediasoitin, joka toistaa melkein mitä tahansa mistä tahansa lähteestä. Erinomainen videoiden katseluun.

Käynnistät mpv:n sovelluskäynnistimen kautta (`Super + Space`) tai vain kaksoisnapsauttamalla videota tiedostonhallinnassa.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchyn oma äärimmäisen yksinkertainen videontrimmaaja. Kun sinun tarvitsee vain leikata klipin alku ja loppu pois, se voittaa täyden videoeditorin käynnistämisen.

Käynnistät Omacutin sovelluskäynnistimen kautta (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchyn oma äärimmäisen yksinkertainen verkkokameratallennin. Valitse kamerasi ja mikrofonisi kerran, paina sitten `Space` tallentaaksesi ja uudelleen keskeyttääksesi ja jatkaaksesi samaa otosta. Se tallentaa aina kamerasi korkeimmalla resoluutiolla, ja reaaliaikainen mikrofonimittari auttaa tarkistamaan tasosi ennen aloittamista.

Lopeta otos, niin se avautuu heti sisäänrakennetussa editorissa. Kaksoisnapsauta klippiä jakaaksesi sen, vedä kahvoja trimmataksesi jokaisen osan ja poista osat, joita et halua. Tallenna se sitten MP4:nä. Alkuperäinen tallenteesi säilytetään, kunnes hylkäät sen, joten voit aina palata ja leikata sen toisin.

Käynnistät Monologuen sovelluskäynnistimen kautta (`Super + Space`).
