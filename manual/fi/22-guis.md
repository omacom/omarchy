# Graafiset käyttöliittymät

## Files

Files (Nautilus) on graafinen tiedostonhallinta. `Super + Shift + F` avaa sen, ja `Super + Shift + Alt + F` avaa sen siinä hakemistossa, jossa päätteesi parhaillaan on, mikä säästää paljolta klikkailulta. `Ctrl + L` antaa kirjoittaa polun, ja `Space`-näppäimen painaminen minkä tahansa tiedoston kohdalla antaa pikaisen esikatselun avaamatta mitään.

Kytke USB-tikku tai SD-kortti, niin se liitetään automaattisesti, joten se vain ilmestyy sivupalkkiin. Kaikkeen monimutkaisempaan — aseman alustamiseen, SMART-tilan tarkistamiseen, osioiden luomiseen — käynnistä _Disks_ sovelluskäynnistimestä (`Super + Space`).

Kaksoisnapsautus noudattaa järkeviä oletuksia: kuvat, videot ja musiikki avautuvat Omaview'ssa, PDF:t Document Viewerissa, Markdown Omawritessa ja pelkkä teksti editorissa, joka on valittu kohdassa _Setup > Default > Editor_.

## Disktree

Kun asema täyttyy etkä tiedä yhtään, mikä sitä syö, käynnistä [Disktree](https://github.com/tobi/disktree) sovelluskäynnistimestä (`Super + Space`). Se näyttää kotihakemistostasi graafisen puukartan. Suuremmat lohkot vievät enemmän tilaa; siirry hakemistoihin näppäimistöllä tai hiirellä, merkitse poistettavat kohteet ja tarkista valintasi ennen kuin poistat mitään. Suorita `disktree --disk` skannataksesi koko levyn.

## Obsidian

[Obsidian](https://obsidian.md/) on ilmainen ja erittäin laajennettavissa oleva muistiinpanosovellus, joka käyttää tallennukseen yksinkertaisia Markdown-tiedostoja.

Obsidian on ilmainen kaikkiin tarkoituksiin, myös henkilökohtaiseen, kaupalliseen ja voittoa tavoittelemattomaan käyttöön.

Obsidian tarjoaa myös [kaupallisen synkronointilisäosan](https://obsidian.md/sync) iOS- ja Android-mobiilisovellusten kanssa. (https://obsidian.md/pricing).

Käynnistät Obsidianin näppäinyhdistelmällä `Super + Shift + O`. Teeman synkronoinnin käyttämiseksi sinun on valittava asetuksista `Omarchy`-teema.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchyn oma äärimmäisen yksinkertainen Markdown-kirjoitussovellus. Ei holveja, ei lisäosia, vain sinä ja sanat.

Käynnistät Omawriten näppäinyhdistelmällä `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on peruskuvankäsittelytyökalu, joka sopii loistavasti rajaamiseen, koon muuttamiseen ja muuhun perusmuokkaukseen. Älä vain odota Photoshop-vaihtoehtoa. Mutta siinä on silti Magic Wand ja tasot!

Käynnistät Pintan sovelluskäynnistimestä (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemasovellus, joka osaa poimia värit taustakuvasta ja muuttaa ne täydelliseksi, yhtenäiseksi teemaksi. Se on helpoin tapa [tehdä oma teemasi](43-making-your-own-theme.md).

Käynnistät Aetherin sovelluskäynnistimestä (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) antaa lähettää tiedostoja muille samassa verkossa sovellusta käyttäville laitteille, kuten Applen AirDrop. Se on kuitenkin monialustainen, joten voit lähettää tiedostoja Windowsiin, macOS:ään, Androidiin, iOS:ään ja tietenkin Linuxiin ja niistä takaisin.

Jaa-valikon voit avata näppäinyhdistelmällä `Super + Ctrl + S` tai Omarchy-valikon kohdasta _Trigger > Share_. Se tarjoaa neljä vaihtoehtoa:

- **Clipboard** lähettää kaiken kopioimasi tekstitiedostona. Mainio tapa saada linkki tai koodinpätkä puhelimeesi lähettämättä itsellesi sähköpostia.
- **File** avaa tiedostonvalitsimen, jossa voit valita useita kerralla.
- **Folder** lähettää kokonaisen hakemiston.
- **Receive** avaa varsinaisen LocalSendin, jotta toinen laite voi lähettää jotain sinulle.

Sama onnistuu päätteestä komennoilla `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jätä polku pois, niin saat valitsimen.

Voit myös lähettää suoraan tiedostonhallinnasta: napsauta mitä tahansa valintaa Nautiluksessa hiiren oikealla painikkeella ja valitse _Send via LocalSend_.

Omarchyn palomuuri on oletuksena suljettu LocalSendin porttia lukuun ottamatta, joten tämä toimii suoraan paketista tuoreessa asennuksessa. Katso [tietoturva](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täydellinen toimistopaketti, jossa on tekstinkäsittely, taulukkolaskenta, esitykset, piirrossovellus ja paljon muuta. Se on yhteensopiva Microsoft Officen tiedostojen kanssa, joten tämä on loistava tapa pystyä avaamaan nuo Word-asiakirjat.

Käynnistät LibreOfficen sovelluskäynnistimestä (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchyn oma äärimmäisen yksinkertainen esityssovellus. Esityksesi on yksi Markdown-tiedosto, jonka kuvat ja videot ovat sen vieressä: kirjoita jokainen dia reaaliaikaisen esikatselun alle, vedä diat järjestykseen ja esitä sitten koko näytöllä tai vie PDF- ja PowerPoint-muotoon. Se jopa nappaa Omarchy-teemasi.

Käynnistät Hypen sovelluskäynnistimestä (`Super + Space`). Paina `?` sen sisällä nähdäksesi kaikki pikanäppäimet.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchyn oma äärimmäisen yksinkertainen tapa allekirjoittaa PDF-tiedostoja ja täyttää niitä. Sijoita tallennettu allekirjoituksesi, tekstiä ja tämän päivän päivämäärä minne tahansa sivulle ja tallenna sitten allekirjoitettu kopio alkuperäisen viereen. Katso ohjeet kohdasta [PDF-tiedostojen täyttäminen](27-filling-out-pdfs.md).

Käynnistät Signedin sovelluskäynnistimestä (`Super + Space`), tai avaa PDF sillä tiedostonhallinnasta.

## Game Vibes

Game Vibes sovelluskäynnistimessä (`Super + Space`) on paikka, jossa Omarchyn pienet pelit asuvat: Checkmate, 3D-shakkipeli ystävää tai sisäänrakennettua vastustajaa vastaan; Cards, Klondike-pasianssi; ja Neon Swarm, arcade-räiskintäpeli. Jokainen on yksi verkkosivu, joka noudattaa teemaasi. Valitse yksi nuolinäppäimillä ja `Enter`-näppäimellä ja palaa luetteloon pelin aloitusnäytöstä painamalla `Esc` tai pelin ollessa tauolla painamalla `Q`. Se avautuu koko näytölle: `Super + F` tekee siitä ikkunan ja `Super + W` sulkee sen.

Myös agentilla tekemäsi pelit näkyvät täällä: valitse agenttipaneelissa _Make something cool → Game_ ja kuvaile peli, tai nimeä peli, joka on jo Game Vibesissa, jatkaaksesi sen työstämistä. Agentti kopioi sen hakemistoon `~/Games/vibes`, jossa voit vapaasti muuttaa sitä, ja avaa sen, kun se on valmis. Voit tehdä kopion itse komennolla `omarchy games vibes copy <game>`. Jonkun muun jakama peli asentuu kuin teema: valitse _Install > Gaming > Game Vibes_ ja liitä sen git-osoite, tai suorita `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ poistaa pelin taas, ja _Update > Game Vibes Games_ hakee uudet versiot. Pelit lataavat three.js:n verkosta, joten ne tarvitsevat yhteyden käynnistyäkseen.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchyn oma äärimmäisen yksinkertainen laskin, joka avautuu kelluvassa ikkunassa.

Käynnistät Omacalcin näppäinyhdistelmällä `Super + Shift + Q` (tai laskinnäppäimellä, jos näppäimistössäsi on sellainen).

## Signal

[Signal](https://signal.org/) on E2E-salatun viestinnän pioneeri ja loistava viestintävaihtoehto kaikille, jotka eivät mielellään kulje yhden suuren teknologiakonglomeraatin kautta.

Käynnistät Signalin näppäinyhdistelmällä `Super + Shift + G`. Se ei kuulu perusasennukseen, joten kun painat sitä ensimmäisen kerran, Omarchy tarjoaa sen asentamista puolestasi (se löytyy myös Omarchy-valikon kohdasta _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchyn oma äärimmäisen yksinkertainen kuvankatselin ja mediasoitin: yksi ikkuna kuvillesi, videoillesi ja musiikillesi. Avaa kuva, niin nuolinäppäimet siirtyvät sen kansion loppuun asti, `N` ja `P` tekevät saman mille tahansa, ja `Ctrl + M` näyttää koko kansion ruudukkona. Se näyttää myös HEIC-, AVIF- ja JPEG XL -kuvia ja jatkaa pitkissä sisällöissä siitä, mihin jäit.

Paina `F` siirtyäksesi koko näyttöön, `E` muokataksesi kuvaa Omasnapissa tai leikataksesi videota Omacutissa, `Ctrl + P` tulostaaksesi kuvan ja `Delete` siirtääksesi tiedoston roskakoriin (`Ctrl + Z` tuo sen takaisin). Paina `?` sen sisällä nähdäksesi kaikki pikanäppäimet.

Omaview käynnistyy nimellä _Media Viewer_ sovelluskäynnistimestä (`Super + Space`), tai kaksoisnapsauta vain kuvaa, videota tai kappaletta tiedostonhallinnassa.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchyn oma äärimmäisen yksinkertainen videoleikkuri. Kun tarvitset vain leikata klipin alun ja lopun pois, se voittaa täyden videoeditorin käynnistämisen.

Käynnistät Omacutin sovelluskäynnistimestä (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchyn oma äärimmäisen yksinkertainen verkkokameranauhuri. Valitse kamerasi ja mikrofonisi kerran, paina sitten `Space` nauhoittaaksesi ja uudelleen keskeyttääksesi ja jatkaaksesi samaa otosta. Se nauhoittaa aina kamerasi korkeimmalla tarkkuudella, ja siinä on reaaliaikainen mikrofonimittari, jotta voit tarkistaa tasosi ennen aloittamista.

Lopeta otos, niin se avautuu heti sisäänrakennetussa editorissa. Kaksoisnapsauta klippiä jakaaksesi sen, vedä kahvoja leikataksesi jokaisen osan ja poista osat, joita et halua. Tallenna se sitten MP4-tiedostona. Alkuperäinen nauhoituksesi säilyy, kunnes hylkäät sen, joten voit aina palata ja leikata sen toisin.

Käynnistät Monologuen sovelluskäynnistimestä (`Super + Space`).
