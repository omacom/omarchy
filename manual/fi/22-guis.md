# Graafiset käyttöliittymät

## Files

Files (Folio) on graafinen tiedostonhallinta. `Super + Shift + F` avaa sen, ja `Super + Shift + Alt + F` avaa sen hakemistossa, jossa päätelaitteesi parhaillaan on, mikä säästää paljolta klikkailulta. `Ctrl + L` antaa sinun kirjoittaa polun, ja `Space`-näppäimen painaminen minkä tahansa tiedoston kohdalla esikatselee sen täysikokoisena avaamatta sitä.

Liitä USB-tikku tai SD-kortti, niin se liitetään automaattisesti, joten se vain ilmestyy sivupalkkiin. Vaativampiin hommiin — aseman alustamiseen, SMART-kunnon tarkistamiseen, osioiden luomiseen — käynnistä _Disks_ sovelluskäynnistimestä (`Super + Space`).

Kaksoisnapsautus noudattaa järkeviä oletuksia: kuvat, videot ja musiikki avautuvat Omaview’ssa, PDF-tiedostot Document Viewerissa, Markdown Omawrite’ssa ja pelkkä teksti editorissa, joka on valittu kohdassa _Setup > Default > Editor_.

## Disktree

Kun asema täyttyy etkä tiedä yhtään, mikä sitä syö, käynnistä [Disktree](https://github.com/tobi/disktree) sovelluskäynnistimestä (`Super + Space`). Se näyttää kotihakemistostasi graafisen puukartan. Suuremmat lohkot vievät enemmän tilaa; kulje hakemistoissa näppäimistöllä tai hiirellä, merkitse poistettavat ja tarkista valintasi ennen kuin poistat mitään. Aja `disktree --disk` skannataksesi koko levyn.

## Obsidian

[Obsidian](https://obsidian.md/) on ilmainen ja erittäin laajennettava muistiinpanosovellus, joka käyttää tallennukseen yksinkertaisia Markdown-tiedostoja.

Obsidian on ilmainen kaikkiin tarkoituksiin, myös henkilökohtaiseen, kaupalliseen ja voittoa tavoittelemattomaan käyttöön.

Obsidian tarjoaa myös [kaupallisen lisäosan synkronointiin](https://obsidian.md/sync) iOS- ja Android-mobiilisovellusten kanssa. (https://obsidian.md/pricing).

Käynnistät Obsidianin näppäimillä `Super + Shift + O`. Teeman synkronoinnin käyttämiseksi sinun on valittava asetuksista `Omarchy`-teema.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchyn oma äärimmäisen yksinkertainen Markdown-kirjoitussovellus. Ei holveja, ei lisäosia, vain sinä ja sanat.

Käynnistät Omawrite’n näppäimillä `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on peruskuvankäsittelytyökalu, joka sopii loistavasti rajaamiseen, koon muuttamiseen ja muihin perusmuokkauksiin. Älä vain odota Photoshopin korvaajaa. Mutta siinä on silti Magic Wand ja tasot!

Käynnistät Pintan sovelluskäynnistimen kautta (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemasovellus, joka voi poimia värit taustakuvasta ja muuttaa ne täydelliseksi, yhtenäiseksi teemaksi. Se on helpoin tapa [tehdä oma teemasi](43-making-your-own-theme.md).

Käynnistät Aetherin sovelluskäynnistimen kautta (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) antaa sinun lähettää tiedostoja muihin samassa verkossa sovellusta käyttäviin laitteisiin, kuten Applen AirDrop. Se on kuitenkin alustariippumaton, joten voit lähettää tiedostoja Windowsin, macOS:n, Androidin, iOS:n ja tietysti Linuxin välillä edestakaisin.

Voit avata Share-valikon näppäimillä `Super + Ctrl + S` tai Omarchy-valikon kohdasta _Trigger > Share_. Se antaa sinulle neljä vaihtoehtoa:

- **Clipboard** lähettää kopioimasi sisällön tekstitiedostona. Loistava tapa saada linkki tai koodinpätkä puhelimeesi lähettämättä itsellesi sähköpostia.
- **File** avaa tiedostonvalitsimen, jossa voit valita useita kerralla.
- **Folder** lähettää kokonaisen hakemiston.
- **Receive** avaa varsinaisen LocalSendin, jotta toinen laite voi lähettää jotain sinulle.

Sama toimii päätteestä komennoilla `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jätä polku pois, niin saat valitsimen.

Voit lähettää myös suoraan tiedostonhallinnasta: napsauta mitä tahansa valintaa Filesissa hiiren oikealla painikkeella ja jaa se LocalSendilla.

Omarchyn palomuuri on oletuksena suljettu LocalSendin porttia lukuun ottamatta, joten tämä toimii heti tuoreessa asennuksessa. Katso [tietoturva](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täydellinen toimistopaketti, jossa on tekstinkäsittelyohjelma, taulukkolaskenta, esitykset, piirrossovellus ja paljon muuta. Se on yhteensopiva Microsoft Officen tiedostojen kanssa, joten tämä on loistava tapa pystyä avaamaan nuo Word-asiakirjat.

Käynnistät LibreOfficen sovelluskäynnistimen kautta (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchyn oma äärimmäisen yksinkertainen esityssovellus. Esityksesi on yksi Markdown-tiedosto, jonka kuvat ja videot ovat sen vieressä: kirjoita jokainen dia elävän esikatselun alle, raahaa diat järjestykseen ja esitä sitten koko näytöllä tai vie PDF- ja PowerPoint-muotoon. Se jopa poimii Omarchy-teemasi.

Käynnistät Hypen sovelluskäynnistimen kautta (`Super + Space`). Paina `?` sen sisällä nähdäksesi kaikki pikanäppäimet.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchyn oma äärimmäisen yksinkertainen tapa allekirjoittaa PDF-tiedostoja ja täyttää niitä. Aseta tallennettu allekirjoituksesi, teksti ja tämän päivän päivämäärä mihin tahansa sivulle ja tallenna sitten allekirjoitettu kopio alkuperäisen viereen. Katso ohjeet kohdasta [PDF-tiedostojen täyttäminen](27-filling-out-pdfs.md).

Käynnistät Signedin sovelluskäynnistimen kautta (`Super + Space`), tai avaa PDF sillä tiedostonhallinnasta.

## Game Vibes

Game Vibes sovelluskäynnistimessä (`Super + Space`) on paikka, jossa Omarchyn pienet pelit asuvat: Checkmate, 3D-shakkipeli ystävää tai sisäänrakennettua vastustajaa vastaan; Cards, Klondike-pasianssi; ja Neon Swarm, arcade-räiskintä. Jokainen on yksi verkkosivu, joka noudattaa teemaasi. Valitse yksi nuolinäppäimillä ja `Enter`-näppäimellä ja palaa luetteloon painamalla `Esc` pelin aloitusnäytössä tai `Q`, kun se on tauotettu. Se avautuu koko näytölle: `Super + F` tekee siitä ikkunan ja `Super + W` sulkee sen.

Myös agentilla tekemäsi pelit näkyvät täällä: valitse agenttipaneelista _Make something cool → Game_ ja kuvaile peli, tai nimeä Game Vibesissa jo oleva peli jatkaaksesi sen työstämistä. Agentti kopioi sen kansioon `~/Games/vibes`, jossa se on sinun muutettavissasi, ja avaa sen, kun se on valmis. Voit tehdä kopion itse komennolla `omarchy games vibes copy <game>`. Jonkun muun jakama peli asentuu kuin teema: valitse _Install > Gaming > Game Vibes_ ja liitä sen git-osoite, tai aja `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ poistaa pelin taas, ja _Update > Game Vibes Games_ hakee uudet versiot. Pelit lataavat three.js:n verkosta, joten ne tarvitsevat yhteyden käynnistyäkseen.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchyn oma äärimmäisen yksinkertainen laskin, joka avautuu kelluvassa ikkunassa.

Käynnistät Omacalcin näppäimillä `Super + Shift + Q` (tai laskinnäppäimellä, jos näppäimistössäsi on sellainen).

## Signal

[Signal](https://signal.org/) on E2E-salatun viestinnän pioneeri ja loistava viestintävaihtoehto kenelle tahansa, joka ei halua kulkea yhden ison teknologiakonglomeraatin kautta.

Käynnistät Signalin näppäimillä `Super + Shift + G`. Se ei kuulu perusasennukseen, joten ensimmäisellä kerralla, kun painat niitä, Omarchy tarjoaa sen asentamista puolestasi (se on myös Omarchy-valikon kohdassa _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchyn oma äärimmäisen yksinkertainen kuvankatselin ja mediasoitin: yksi ikkuna valokuvillesi, videoillesi ja musiikillesi. Avaa valokuva, niin nuolinäppäimet selaavat sen kansion loput tiedostot läpi, `N` ja `P` tekevät saman mille tahansa, ja `Ctrl + M` näyttää koko kansion ruudukkona. Se näyttää myös HEIC-, AVIF- ja JPEG XL -valokuvia ja jatkaa pitkäkestoisissa sisällöissä siitä, mihin jäit.

Paina `F` koko näyttöön, `E` muokataksesi kuvaa Omasnapissa tai leikataksesi videota Omacutissa, `Ctrl + P` tulostaaksesi kuvan ja `Delete` siirtääksesi tiedoston Trash-kansioon (`Ctrl + Z` tuo sen takaisin). Paina `?` sen sisällä nähdäksesi kaikki pikanäppäimet.

Käynnistät Omaview’n nimellä _Media Viewer_ sovelluskäynnistimen kautta (`Super + Space`), tai kaksoisnapsauta vain kuvaa, videota tai kappaletta tiedostonhallinnassa.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchyn oma äärimmäisen yksinkertainen videonleikkaaja. Kun tarvitset vain leikata klipin alun ja lopun pois, se voittaa täyden videoeditorin käynnistämisen.

Käynnistät Omacutin sovelluskäynnistimen kautta (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchyn oma äärimmäisen yksinkertainen verkkokameranauhuri. Valitse kamerasi ja mikrofonisi kerran, paina sitten `Space` nauhoittaaksesi ja uudelleen keskeyttääksesi ja jatkaaksesi samaa otosta. Se nauhoittaa aina kamerasi korkeimmalla tarkkuudella, ja siinä on elävä mikrofonimittari, jotta voit tarkistaa tasosi ennen aloittamista.

Pysäytä otos, niin se avautuu heti sisäänrakennetussa editorissa. Kaksoisnapsauta klippiä jakaaksesi sen, raahaa kahvoja leikataksesi jokaisen palan ja poista osat, joita et halua. Tallenna se sitten MP4-tiedostona. Alkuperäinen nauhoituksesi säilytetään, kunnes hylkäät sen, joten voit aina palata ja leikata sen toisin.

Käynnistät Monologuen sovelluskäynnistimen kautta (`Super + Space`).
