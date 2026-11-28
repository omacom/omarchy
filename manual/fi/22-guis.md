# Graafiset sovellukset

## Files

Files (Folio) on graafinen tiedostonhallinta. `Super + Shift + F` avaa sen, ja `Super + Shift + Alt + F` avaa sen hakemistossa, jossa päätteesi parhaillaan on, mikä säästää paljolta klikkailulta. `Ctrl + L` antaa kirjoittaa polun, ja `Space` tiedoston kohdalla näyttää sen esikatseluna täysikokoisena avaamatta sitä.

Liitä USB-tikku tai SD-kortti, niin se liitetään automaattisesti, joten se vain ilmestyy sivupalkkiin. Kaikkeen monimutkaisempaan — aseman alustamiseen, SMART-tilan tarkistamiseen, osioiden luomiseen — käynnistä _Disks_ sovelluskäynnistimestä (`Super + Space`).

Salattu asema pyytää salasanansa, kun se liitetään. Jos haluat sellaisen avautuvan itsestään, lisää siihen avaintiedosto komennolla `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` ja sijoita kyseinen avaintiedosto polkuun `~/.config/omarchy/drive-keys/<UUID>` nimellä, joka on se UUID, jonka `lsblk -dno UUID /dev/sdX1` tulostaa salatulle osiolle, ja vain sinun luettavissasi (`chmod 600`). Jos kyseinen avaintiedosto puuttuu tai se torjutaan, sinulta pyydetään salasanaa tavalliseen tapaan.

Kaksoisnapsautus noudattaa järkeviä oletuksia: kuvat, videot ja musiikki avautuvat Omaview-ohjelmassa, PDF-tiedostot Document Viewerissa, Markdown Omawritessa ja pelkkä teksti editorissasi, Plainissa, ellet valitse toista kohdassa _Setup > Defaults > Editor_.

## Disktree

Kun asema täyttyy etkä tiedä yhtään, mikä sitä syö, käynnistä [Disktree](https://github.com/tobi/disktree) sovelluskäynnistimestä (`Super + Space`). Se näyttää kotihakemistostasi graafisen puukartan. Isommat lohkot vievät enemmän tilaa; siirry hakemistoihin näppäimistöllä tai hiirellä, merkitse poistettavat ja tarkista valintasi ennen kuin poistat mitään. Aja `disktree --disk`, jos haluat tutkia koko levyn.

## Obsidian

[Obsidian](https://obsidian.md/) on ilmainen ja erittäin laajennettava muistiinpanosovellus, joka käyttää tallennukseen yksinkertaisia Markdown-tiedostoja.

Obsidian on ilmainen kaikkiin tarkoituksiin, myös henkilökohtaiseen, kaupalliseen ja voittoa tavoittelemattomaan käyttöön.

Obsidian tarjoaa myös [kaupallisen synkronointilisäosan](https://obsidian.md/sync) iOS:n ja Androidin mobiilisovellusten kanssa. (https://obsidian.md/pricing).

Käynnistät Obsidianin näppäimillä `Super + Shift + O`. Teeman synkronoinnin käyttämiseksi sinun on valittava asetuksissa `Omarchy`-teema.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchyn oma äärimmäisen yksinkertainen Markdown-kirjoitussovellus. Ei holveja, ei liitännäisiä, vain sinä ja sanat.

Käynnistät Omawriten näppäimillä `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on yksinkertainen kuvankäsittelytyökalu, joka sopii loistavasti rajaamiseen, koon muuttamiseen ja muihin perusmuokkauksiin. Älä vain odota sen olevan Photoshopin vaihtoehto. Mutta on siinä silti Magic Wand ja tasot!

Käynnistät Pintan sovelluskäynnistimen kautta (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemasovellus, joka voi poimia värit taustakuvasta ja muuttaa ne täydelliseksi, yhtenäiseksi teemaksi. Se on helpoin tapa [tehdä oma teemasi](43-making-your-own-theme.md).

Käynnistät Aetherin sovelluskäynnistimen kautta (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) antaa lähettää tiedostoja muihin samassa verkossa oleviin laitteisiin, joissa sovellus on käytössä, Applen AirDropin tapaan. Se on kuitenkin monialustainen, joten voit lähettää tiedostoja Windowsin, macOS:n, Androidin, iOS:n ja tietenkin Linuxin välillä edestakaisin.

Voit avata Share-valikon näppäimillä `Super + Ctrl + S` tai Omarchy-valikon kohdassa _Trigger > Share_. Se tarjoaa neljä vaihtoehtoa:

- **Clipboard** lähettää kopioimasi sisällön tekstitiedostona. Loistava tapa saada linkki tai pätkä puhelimeesi lähettämättä itsellesi sähköpostia.
- **File** avaa tiedostonvalitsimen, jossa voit valita useita kerralla.
- **Folder** lähettää kokonaisen hakemiston.
- **Receive** avaa varsinaisen LocalSendin, jotta toinen laite voi lähettää sinulle jotakin.

Sama toimii päätteestä komennolla `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jätä polku pois, niin saat valitsimen.

Voit lähettää myös suoraan tiedostonhallinnasta: napsauta mitä tahansa valintaa Filesissa hiiren oikealla painikkeella ja jaa se LocalSendilla.

Omarchyn palomuuri on oletuksena suljettu LocalSendin porttia lukuun ottamatta, joten tämä toimii heti tuoreessa asennuksessa. Katso [tietoturva](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täydellinen toimistopaketti, jossa on tekstinkäsittelyohjelma, taulukkolaskentaohjelma, esitysohjelma, piirto-ohjelma ja paljon muuta. Se on yhteensopiva Microsoft Officen tiedostojen kanssa, joten tämä on loistava tapa avata nuo Word-asiakirjat.

Käynnistät LibreOfficen sovelluskäynnistimen kautta (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchyn oma äärimmäisen yksinkertainen esityssovellus. Esityksesi on yksi Markdown-tiedosto, jonka kuvat ja videot ovat sen vieressä: kirjoita jokainen dia reaaliaikaisen esikatselun alle, vedä diat järjestykseen ja esitä sitten koko näytön tilassa tai vie PDF:ksi ja PowerPointiin. Se nappaa jopa Omarchy-teemasi.

Käynnistät Hypen sovelluskäynnistimen kautta (`Super + Space`). Paina sen sisällä `?` nähdäksesi kaikki pikanäppäimet.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchyn oma äärimmäisen yksinkertainen tapa allekirjoittaa PDF-tiedostoja ja täyttää niitä. Sijoita tallennettu allekirjoituksesi, tekstiä ja tämän päivän päivämäärä mihin tahansa sivulla ja tallenna sitten allekirjoitettu kopio alkuperäisen viereen. Katso ohjeet kohdasta [PDF-tiedostojen täyttäminen](27-filling-out-pdfs.md).

Käynnistät Signedin sovelluskäynnistimen kautta (`Super + Space`), tai avaa sillä PDF-tiedosto tiedostonhallinnasta.

## Game Vibes

Game Vibes sovelluskäynnistimessä (`Super + Space`) on paikka, jossa Omarchyn pienet pelit asuvat: Checkmate, 3D-shakkipeli ystävää tai sisäänrakennettua vastustajaa vastaan; Cards, Klondike-pasianssi; Death Wish, pikselintarkka tasohyppely, jossa on kymmenen huonetta täynnä piikkejä ja sahoja; ja Neon Swarm, arcade-räiskintä. Jokainen on yksi verkkosivu, joka noudattaa teemaasi. Valitse peli nuolinäppäimillä ja `Enter`-näppäimellä ja palaa luetteloon pelin otsikkoruudusta näppäimellä `Esc` tai näppäimellä `Q`, kun peli on tauotettu. Se avautuu koko näytöllä: `Super + F` tekee siitä ikkunan ja `Super + W` sulkee sen.

Myös agentilla tekemäsi pelit näkyvät täällä: valitse agenttipaneelissa _Make something cool → Game_ ja kuvaile peli, tai nimeä Game Vibesissa jo oleva peli jatkaaksesi sen työstämistä. Agentti kopioi sen polkuun `~/Games/vibes`, jossa voit muuttaa sitä vapaasti, ja avaa sen, kun se on valmis. Voit tehdä kopion itse komennolla `omarchy games vibes copy <game>`. Jonkun toisen jakama peli asentuu teeman tapaan: valitse _Install > Gaming > Game Vibes_ ja liitä sen git-osoite, tai aja `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ poistaa pelin taas, ja _Update > Game Vibes Games_ hakee uudet versiot. Pelit lataavat three.js:n verkosta, joten ne tarvitsevat yhteyden käynnistyäkseen.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchyn oma äärimmäisen yksinkertainen laskin, joka avautuu kelluvassa ikkunassa.

Käynnistät Omacalcin näppäimillä `Super + Shift + Q` (tai laskinnäppäimellä, jos näppäimistössäsi on sellainen).

## Signal

[Signal](https://signal.org/) on E2E-salatun viestinnän pioneeri ja loistava viestintävaihtoehto kaikille, jotka mieluummin eivät kulje yhden suuren teknologiakonglomeraatin kautta.

Käynnistät Signalin näppäimillä `Super + Shift + G`. Se ei ole osa perusasennusta, joten kun painat sitä ensimmäisen kerran, Omarchy tarjoaa sen asentamista puolestasi (se löytyy myös Omarchy-valikon kohdasta _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchyn oma äärimmäisen yksinkertainen kuvien katseluohjelma ja mediasoitin: yksi ikkuna valokuvillesi, videoillesi ja musiikillesi. Avaa valokuva, niin nuolinäppäimet selaavat sen kansion loput sisällöt, `N` ja `P` tekevät saman mille tahansa, ja `Ctrl + M` näyttää koko kansion ruudukkona. Se näyttää myös HEIC-, AVIF- ja JPEG XL -valokuvia ja jatkaa kaikessa pitkäkestoisessa siitä, mihin viimeksi jäit.

Paina `F` saadaksesi koko näytön, `E` muokataksesi kuvaa Omasnapissa tai leikataksesi videota Omacutissa, `Ctrl + P` tulostaaksesi kuvan ja `Delete` siirtääksesi tiedoston roskakoriin (`Ctrl + Z` tuo sen takaisin). Paina sen sisällä `?` nähdäksesi kaikki pikanäppäimet.

Käynnistät Omaview-ohjelman nimellä _Media Viewer_ sovelluskäynnistimen kautta (`Super + Space`), tai kaksoisnapsauta vain kuvaa, videota tai kappaletta tiedostonhallinnassa.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchyn oma äärimmäisen yksinkertainen videoleikkuri. Kun tarvitset vain leikata klipin alun ja lopun pois, se on parempi kuin täyden videoeditorin käynnistäminen.

Käynnistät Omacutin sovelluskäynnistimen kautta (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchyn oma äärimmäisen yksinkertainen verkkokameran tallennin. Valitse kamerasi ja mikrofonisi kerran, paina sitten `Space` tallentaaksesi ja uudelleen keskeyttääksesi ja jatkaaksesi samaa otosta. Se tallentaa aina kamerasi suurimmalla tarkkuudella, ja mikrofonin reaaliaikainen mittari antaa tarkistaa tasosi ennen aloittamista.

Lopeta otos, niin se avautuu heti sisäänrakennetussa editorissa. Kaksoisnapsauta klippiä jakaaksesi sen, vedä kahvoista leikataksesi jokaisen osan ja poista osat, joita et halua. Tallenna se sitten MP4-tiedostona. Alkuperäinen tallenteesi säilytetään, kunnes hylkäät sen, joten voit aina palata ja leikata sen toisin.

Käynnistät Monologuen sovelluskäynnistimen kautta (`Super + Space`).
