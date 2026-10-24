# GUI:t

## Files

Files (Nautilus) on graafinen tiedostonhallinta. `Super + Shift + F` avaa sen, ja `Super + Shift + Alt + F` avaa sen hakemistossa, jossa päätteesi on, mikä säästää paljon napsauttelua. `Ctrl + L` antaa sinun kirjoittaa polun, ja `Space`-näppäimen painaminen minkä tahansa tiedoston kohdalla antaa pikaesikatselun avaamatta mitään.

Liitä USB-tikku tai SD-kortti, niin se liitetään automaattisesti ja ilmestyy vain sivupalkkiin. Mihin tahansa monimutkaisempaan — aseman alustamiseen, SMART-kunnon tarkistamiseen, osioiden luomiseen — käynnistä _Disks_ sovellusten käynnistimestä (`Super + Space`).

Kaksoisnapsautus noudattaa järkeviä oletuksia: kuvat avautuvat imv:ssä, videot mpv:ssä, PDF:t Document Viewerissa ja pelkkä teksti Neovimissa.

## Disktree

Kun levy täyttyy eikä sinulla ole aavistustakaan, mikä sitä syö, käynnistä [Disktree](https://github.com/tobi/disktree) sovellusten käynnistimestä (`Super + Space`). Se näyttää kotihakemistosi graafisen puukartan. Suuremmat lohkot vievät enemmän tilaa; kulje hakemistoissa näppäimistöllä tai hiirellä, merkitse poistettavat ja tarkista valintasi ennen kuin poistat mitään. Aja `disktree --disk` skannataksesi koko levyn.

## Obsidian

[Obsidian](https://obsidian.md/) on ilmainen ja erittäin laajennettava muistiinpanosovellus, joka käyttää tallennukseen yksinkertaisia Markdown-tiedostoja.

Obsidian on ilmainen kaikkiin tarkoituksiin, mukaan lukien henkilökohtaiseen, kaupalliseen ja voittoa tavoittelemattomaan käyttöön.

Obsidian tarjoaa myös [kaupallisen lisäosan synkronoimiseen](https://obsidian.md/sync) iOS:n ja Androidin mobiilisovellusten kanssa. (https://obsidian.md/pricing).

Käynnistät Obsidianin näppäimillä `Super + Shift + O`. Käyttääksesi teemojen synkronointia sinun on valittava asetuksissa teema `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchyn oma äärimmäisen yksinkertainen Markdown-kirjoitussovellus. Ei holveja, ei lisäosia, vain sinä ja sanat.

Käynnistät Omawriten näppäimillä `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on yksinkertainen kuvankäsittelytyökalu, joka sopii hyvin rajaamiseen, koon muuttamiseen ja muihin perusmanipulaatioihin. Älä vain odota Photoshop-vaihtoehtoa. Mutta siinä on silti taikasauva ja tasot!

Käynnistät Pintan sovellusten käynnistimen kautta (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemasovellus, joka voi poimia värejä taustakuvasta ja muuttaa ne täydelliseksi, yhtenäiseksi teemaksi. Se on helpoin tapa [tehdä oma teemasi](43-making-your-own-theme.md).

Käynnistät Aetherin sovellusten käynnistimen kautta (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) antaa sinun lähettää tiedostoja muihin samaa sovellusta ajaviin, samassa verkossa oleviin laitteisiin, kuten Applen AirDrop. Se on kuitenkin alustariippumaton, joten voit lähettää tiedostoja Windowsiin, macOS:ään, Androidiin, iOS:ään ja tietenkin Linuxiin ja niistä pois.

Voit avata Jaa-valikon näppäimillä `Super + Ctrl + S` tai Omarchy-valikon kohdassa _Käynnistä > Jaa_. Se antaa sinulle neljä vaihtoehtoa:

- **Leikepöytä** lähettää kopioimasi sisällön tekstitiedostona. Erinomainen linkin tai katkelman saamiseen puhelimeesi ilman, että lähetät itsellesi sähköpostia.
- **Tiedosto** avaa tiedostonvalitsimen, jossa voit valita useita kerralla.
- **Kansio** lähettää kokonaisen hakemiston.
- **Vastaanota** avaa itse LocalSendin, jotta toinen laite voi lähettää jotain sinulle.

Sama toimii päätteestä komennoilla `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jätä polku pois, niin saat valitsimen.

Voit myös lähettää suoraan tiedostonhallinnasta: napsauta mitä tahansa valintaa Nautiluksessa hiiren kakkospainikkeella ja valitse _Send via LocalSend_.

Omarchyn palomuuri on oletuksena suljettu lukuun ottamatta LocalSendin porttia, joten tämä toimii heti käytössä tuoreessa asennuksessa. Katso [turvallisuus](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täydellinen toimistopaketti, jossa on tekstinkäsittely, taulukkolaskenta, esitykset, piirrossovellus ja paljon muuta. Se on yhteensopiva Microsoft Officen tiedostojen kanssa, joten tämä on erinomainen tapa pystyä avaamaan nuo Word-asiakirjat.

Käynnistät LibreOfficen sovellusten käynnistimen kautta (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchyn oma äärimmäisen yksinkertainen esityssovellus. Esityksesi on yksi Markdown-tiedosto, jonka vieressä ovat sen kuvat ja videot: kirjoita jokainen dia reaaliaikaisen esikatselun alapuolelle, raahaa diat järjestykseen ja esitä sitten koko näytöltä tai vie PDF:ksi ja PowerPointiksi. Se jopa omaksuu Omarchy-teemasi.

Käynnistät Hypen sovellusten käynnistimen kautta (`Super + Space`). Paina sen sisällä `?` nähdäksesi jokaisen pikanäppäimen.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchyn oma äärimmäisen yksinkertainen tapa allekirjoittaa PDF:iä ja täyttää niitä. Aseta tallennettu allekirjoituksesi, tekstiä ja tämän päivän päivämäärä minne tahansa sivulle ja tallenna sitten allekirjoitettu kopio alkuperäisen viereen. Katso ohjeet kohdasta [PDF:ien täyttäminen](27-filling-out-pdfs.md).

Käynnistät Signedin sovellusten käynnistimen kautta (`Super + Space`) tai avaat PDF:n sillä tiedostonhallinnasta.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchyn oma äärimmäisen yksinkertainen laskin, joka avautuu kelluvaan ikkunaan.

Käynnistät Omacalcin näppäimillä `Super + Ctrl + Q` (tai laskinnäppäimellä, jos näppäimistössäsi on sellainen).

## Signal

[Signal](https://signal.org/) on päästä päähän salatun viestinnän uranuurtaja ja erinomainen viestintävaihtoehto jokaiselle, joka ei haluaisi kulkea jonkin suuren teknologiakonglomeraatin kautta.

Käynnistät Signalin näppäimillä `Super + Shift + G`. Se ei kuulu perusasennukseen, joten ensimmäisellä kerralla, kun painat sitä, Omarchy tarjoaa asentavansa sen puolestasi (se on myös Omarchy-valikon kohdassa _Asenna > Palvelu_).

## mpv

[mpv](https://mpv.io/) on yksinkertainen, nopea mediasoitin, joka toistaa melkein mitä tahansa mistä tahansa lähteestä. Erinomainen videoiden katsomiseen.

Käynnistät mpv:n sovellusten käynnistimen kautta (`Super + Space`) tai vain kaksoisnapsautat videota tiedostonhallinnassa.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchyn oma äärimmäisen yksinkertainen videoleikkuri. Kun sinun tarvitsee vain leikata leikkeen alku ja loppu pois, se päihittää täyden videoeditorin käynnistämisen.

Käynnistät Omacutin sovellusten käynnistimen kautta (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchyn oma äärimmäisen yksinkertainen verkkokameratallennin. Valitse kamerasi ja mikrofonisi kerran, paina sitten `Space` tallentaaksesi ja uudelleen tauottaaksesi ja jatkaaksesi samaa otosta. Se tallentaa aina kamerasi korkeimmalla resoluutiolla, ja siinä on reaaliaikainen mikrofonimittari, jotta voit tarkistaa tasosi ennen aloittamista.

Pysäytä otos, niin se avautuu heti sisäänrakennetussa editorissa. Kaksoisnapsauta leikettä halkaistaksesi sen, raahaa kahvoja leikataksesi jokaisen palan ja poista osat, joita et halua. Tallenna se sitten MP4:nä. Alkuperäinen tallenteesi säilytetään, kunnes hylkäät sen, joten voit aina palata ja leikata sen toisin.

Käynnistät Monologuen sovellusten käynnistimen kautta (`Super + Space`).
