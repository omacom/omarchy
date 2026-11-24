# Graafiset sovellukset

## Files

Files (Folio) on graafinen tiedostonhallinta. `Super + Shift + F` avaa sen, ja `Super + Shift + Alt + F` avaa sen kansiossa, jossa päätteesi parhaillaan on, mikä säästää paljolta klikkailulta. `Ctrl + L` antaa kirjoittaa polun, ja `Space`-näppäimen painaminen minkä tahansa tiedoston kohdalla esikatselee sen täysikokoisena avaamatta sitä.

Kytke USB-tikku tai SD-kortti, niin se liitetään automaattisesti, joten se vain ilmestyy sivupalkkiin. Vaativampiin hommiin — aseman alustamiseen, SMART-kunnon tarkistamiseen, osioiden luomiseen — käynnistä _Disks_ sovelluskäynnistimestä (`Super + Space`).

Kaksoisnapsautus noudattaa järkeviä oletuksia: kuvat, videot ja musiikki avautuvat Omaview'ssa, PDF:t Document Viewerissa, Markdown Omawriteissa ja pelkkä teksti editorissasi, Plainissa, ellet valitse toista kohdassa _Setup > Defaults > Editor_.

## Disktree

Kun asema täyttyy etkä tiedä yhtään, mikä sitä syö, käynnistä [Disktree](https://github.com/tobi/disktree) sovelluskäynnistimestä (`Super + Space`). Se näyttää kotikansiosi graafisena puukarttana. Isommat lohkot vievät enemmän tilaa; kulje kansioihin näppäimistöllä tai hiirellä, merkitse poistettavat ja tarkista valintasi ennen kuin poistat mitään. Skannaa koko levy suorittamalla `disktree --disk`.

## Obsidian

[Obsidian](https://obsidian.md/) on ilmainen ja erittäin laajennettava muistiinpanosovellus, joka käyttää tallennukseen yksinkertaisia Markdown-tiedostoja.

Obsidian on ilmainen kaikkiin tarkoituksiin, myös henkilökohtaiseen, kaupalliseen ja voittoa tavoittelemattomaan käyttöön.

Obsidian tarjoaa myös [kaupallisen synkronointilisäosan](https://obsidian.md/sync) mobiilisovellusten kanssa iOS:llä ja Androidilla. (https://obsidian.md/pricing).

Käynnistät Obsidianin näppäimillä `Super + Shift + O`. Jos haluat käyttää teemojen synkronointia, sinun on valittava asetuksista `Omarchy`-teema.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchyn oma äärimmäisen yksinkertainen Markdown-kirjoitussovellus. Ei holveja, ei lisäosia, vain sinä ja sanat.

Käynnistät Omawritein näppäimillä `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on yksinkertainen kuvankäsittelytyökalu, joka sopii hyvin rajaamiseen, koon muuttamiseen ja muuhun perusmuokkaukseen. Älä vain odota Photoshopin korvaajaa. Mutta siinä on silti Magic Wand ja tasot!

Käynnistät Pintan sovelluskäynnistimestä (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemasovellus, joka voi poimia värejä taustakuvasta ja muuttaa ne kokonaiseksi, yhtenäiseksi teemaksi. Se on helpoin tapa [tehdä oma teemasi](43-making-your-own-theme.md).

Käynnistät Aetherin sovelluskäynnistimestä (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) antaa lähettää tiedostoja muihin samassa verkossa oleviin laitteisiin, joissa sovellus on käytössä, Applen AirDropin tapaan. Se on kuitenkin monialustainen, joten voit lähettää tiedostoja Windowsiin, macOS:ään, Androidiin, iOS:ään ja tietenkin Linuxiin ja niistä takaisin.

Voit avata Share-valikon näppäimillä `Super + Ctrl + S` tai Omarchy-valikosta kohdasta _Trigger > Share_. Se antaa neljä vaihtoehtoa:

- **Clipboard** lähettää kopioimasi sisällön tekstitiedostona. Erinomainen tapa saada linkki tai koodinpätkä puhelimeesi lähettämättä itsellesi sähköpostia.
- **File** avaa tiedostonvalitsimen, jossa voit valita useita kerralla.
- **Folder** lähettää kokonaisen kansion.
- **Receive** avaa varsinaisen LocalSendin, jotta toinen laite voi lähettää jotain sinulle.

Sama toimii päätteestä komennoilla `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jätä polku pois, niin saat valitsimen.

Voit myös lähettää suoraan tiedostonhallinnasta: napsauta mitä tahansa valintaa Filesissa hiiren oikealla painikkeella ja jaa se LocalSendilla.

Omarchyn palomuuri on oletuksena suljettu lukuun ottamatta LocalSendin porttia, joten tämä toimii suoraan uudessa asennuksessa. Katso [tietoturva](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täydellinen toimistopaketti, jossa on tekstinkäsittely, taulukkolaskenta, esitykset, piirrossovellus ja paljon muuta. Se on yhteensopiva Microsoft Officen tiedostojen kanssa, joten tämä on erinomainen tapa avata niitä Word-asiakirjoja.

Käynnistät LibreOfficen sovelluskäynnistimestä (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchyn oma äärimmäisen yksinkertainen esityssovellus. Esityksesi on yksi Markdown-tiedosto, jonka kuvat ja videot ovat sen vieressä: kirjoita jokainen dia elävän esikatselun alle, raahaa diat järjestykseen ja esitä sitten koko näytöllä tai vie PDF:ksi ja PowerPointiin. Se poimii jopa Omarchy-teemasi.

Käynnistät Hypen sovelluskäynnistimestä (`Super + Space`). Paina `?` sovelluksessa nähdäksesi kaikki pikanäppäimet.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchyn oma äärimmäisen yksinkertainen tapa allekirjoittaa PDF:iä ja täyttää niitä. Sijoita tallennettu allekirjoituksesi, tekstiä ja tämän päivän päivämäärä minne tahansa sivulle ja tallenna sitten allekirjoitettu kopio alkuperäisen viereen. Katso ohjeet kohdasta [PDF-tiedostojen täyttäminen](27-filling-out-pdfs.md).

Käynnistät Signedin sovelluskäynnistimestä (`Super + Space`) tai avaat sillä PDF:n tiedostonhallinnasta.

## Game Vibes

Game Vibes, sovelluskäynnistimessä (`Super + Space`), on paikka, jossa Omarchyn pienet pelit asuvat: Checkmate, 3D-shakkipeli ystävää tai sisäänrakennettua vastustajaa vastaan; Cards, Klondike-pasianssi; Death Wish, pikselintarkka tasohyppely, jossa on kymmenen huonetta täynnä piikkejä ja sahoja; ja Neon Swarm, arcade-räiskintä. Jokainen on yksi verkkosivu, joka noudattaa teemaasi. Valitse yksi nuolilla ja `Enter`-näppäimellä ja palaa luetteloon pelin otsikkoruudusta `Esc`-näppäimellä tai `Q`-näppäimellä, kun peli on tauotettu. Se avautuu koko näytölle: `Super + F` tekee siitä ikkunan ja `Super + W` sulkee sen.

Myös agentilla tekemäsi pelit näkyvät täällä: valitse agenttipaneelista _Make something cool → Game_ ja kuvaile peli, tai nimeä Game Vibesissa jo oleva peli jatkaaksesi sen työstämistä. Agentti kopioi sen kansioon `~/Games/vibes`, jossa se on sinun muutettavissasi, ja avaa sen, kun se on valmis. Voit tehdä kopion itse komennolla `omarchy games vibes copy <game>`. Jonkun toisen jakama peli asentuu teeman tapaan: valitse _Install > Gaming > Game Vibes_ ja liitä sen git-osoite, tai suorita `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ poistaa pelin taas, ja _Update > Game Vibes Games_ hakee uudet versiot. Pelit lataavat three.js:n verkosta, joten ne tarvitsevat yhteyden käynnistyäkseen.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchyn oma äärimmäisen yksinkertainen laskin, joka avautuu kelluvassa ikkunassa.

Käynnistät Omacalcin näppäimillä `Super + Shift + Q` (tai laskinnäppäimellä, jos näppäimistössäsi on sellainen).

## Signal

[Signal](https://signal.org/) on E2E-salatun viestinnän pioneeri ja erinomainen viestintävaihtoehto kaikille, jotka eivät haluaisi kulkea jonkin suuren teknologiakonglomeraatin kautta.

Käynnistät Signalin näppäimillä `Super + Shift + G`. Se ei ole osa perusasennusta, joten kun painat sitä ensimmäisen kerran, Omarchy tarjoaa sen asentamista puolestasi (se on myös Omarchy-valikossa kohdassa _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchyn oma äärimmäisen yksinkertainen kuvankatselin ja mediasoitin: yksi ikkuna valokuvillesi, videoillesi ja musiikillesi. Avaa valokuva, niin nuolinäppäimillä voit selata sen kansion loput sisällöt läpi, `N` ja `P` tekevät saman kaikelle sisällölle, ja `Ctrl + M` näyttää koko kansion ruudukkona. Se näyttää myös HEIC-, AVIF- ja JPEG XL -valokuvia ja jatkaa kaikessa pitkässä sisällössä siitä, mihin jäit.

Paina `F` koko näyttöä varten, `E` muokataksesi kuvaa Omasnapissa tai leikataksesi videota Omacutissa, `Ctrl + P` tulostaaksesi kuvan ja `Delete` siirtääksesi tiedoston roskakoriin (`Ctrl + Z` tuo sen takaisin). Paina `?` sovelluksessa nähdäksesi kaikki pikanäppäimet.

Käynnistät Omaviewin _Media Viewer_ -nimellä sovelluskäynnistimestä (`Super + Space`) tai kaksoisnapsautat vain kuvaa, videota tai kappaletta tiedostonhallinnassa.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchyn oma äärimmäisen yksinkertainen videoleikkuri. Kun sinun tarvitsee vain katkaista klipin alku ja loppu, se päihittää täyden videoeditorin käynnistämisen.

Käynnistät Omacutin sovelluskäynnistimestä (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchyn oma äärimmäisen yksinkertainen verkkokameratallennin. Valitse kamerasi ja mikrofonisi kerran, paina sitten `Space` tallentaaksesi ja uudelleen tauottaaksesi ja jatkaaksesi samaa otosta. Se tallentaa aina kamerasi korkeimmalla tarkkuudella, ja siinä on reaaliaikainen mikrofonimittari, joten voit tarkistaa tasosi ennen aloittamista.

Lopeta otos, niin se avautuu heti sisäänrakennetussa editorissa. Kaksoisnapsauta klippiä jakaaksesi sen, raahaa kahvoja leikataksesi jokaista palaa ja poista osat, joita et halua. Tallenna se sitten MP4:nä. Alkuperäinen tallenteesi säilytetään, kunnes hylkäät sen, joten voit aina palata ja leikata sen toisin.

Käynnistät Monologuen sovelluskäynnistimestä (`Super + Space`).
