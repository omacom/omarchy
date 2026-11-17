# Graafiset sovellukset

## Files

Files (Nautilus) on graafinen tiedostonhallinta. `Super + Shift + F` avaa sen, ja `Super + Shift + Alt + F` avaa sen hakemistossa, jossa terminaalisi parhaillaan on, mikä säästää paljon klikkailua. `Ctrl + L` antaa kirjoittaa polun, ja `Space`-näppäimen painaminen minkä tahansa tiedoston kohdalla antaa nopean esikatselun avaamatta mitään.

Kytke USB-tikku tai SD-kortti, niin se liitetään automaattisesti ja ilmestyy vain sivupalkkiin. Vaativampiin hommiin — aseman alustamiseen, SMART-kunnon tarkistamiseen, osioiden luomiseen — käynnistä _Disks_ sovelluskäynnistimestä (`Super + Space`).

Kaksoisnapsautus noudattaa järkeviä oletuksia: kuvat, videot ja musiikki avautuvat Omaview’ssa, PDF:t Document Viewerissa, Markdown Omawritessa ja pelkkä teksti editorissa, joka on valittu kohdassa _Setup > Default > Editor_.

## Disktree

Kun asema täyttyy etkä tiedä yhtään, mikä sitä syö, käynnistä [Disktree](https://github.com/tobi/disktree) sovelluskäynnistimestä (`Super + Space`). Se näyttää kotihakemistostasi graafisen puukartan. Isommat lohkot vievät enemmän tilaa; kulje hakemistoissa näppäimistöllä tai hiirellä, merkitse poistettavat ja tarkista valintasi ennen kuin poistat mitään. Aja `disktree --disk` skannataksesi koko levyn.

## Obsidian

[Obsidian](https://obsidian.md/) on ilmainen ja erittäin laajennettava muistiinpanosovellus, joka käyttää tallennukseen yksinkertaisia Markdown-tiedostoja.

Obsidian on ilmainen kaikkiin tarkoituksiin, myös henkilökohtaiseen, kaupalliseen ja voittoa tavoittelemattomaan käyttöön.

Obsidian tarjoaa myös [kaupallisen synkronointilisäosan](https://obsidian.md/sync) mobiilisovellusten kanssa iOS:llä ja Androidilla. (https://obsidian.md/pricing).

Käynnistät Obsidianin näppäinyhdistelmällä `Super + Shift + O`. Teeman synkronoinnin käyttämiseksi sinun on valittava asetuksista `Omarchy`-teema.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) on Omarchyn oma kuolettavan yksinkertainen Markdown-kirjoitussovellus. Ei holveja, ei lisäosia, vain sinä ja sanat.

Käynnistät Omawriten näppäinyhdistelmällä `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) on peruskuvankäsittelytyökalu, joka sopii loistavasti rajaamiseen, koon muuttamiseen ja muihin perusmuokkauksiin. Älä vain odota Photoshopin korvaajaa. Mutta siinä on silti Magic Wand ja tasot!

Käynnistät Pintan sovelluskäynnistimen kautta (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) on teemasovellus, joka osaa poimia värit taustakuvasta ja tehdä niistä kokonaisen, yhtenäisen teeman. Se on helpoin tapa [tehdä oma teemasi](43-making-your-own-theme.md).

Käynnistät Aetherin sovelluskäynnistimen kautta (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) antaa lähettää tiedostoja muihin samassa verkossa oleviin laitteisiin, joissa sovellus on käynnissä, kuten Applen AirDrop. Se on kuitenkin alustariippumaton, joten voit lähettää tiedostoja Windowsiin, macOS:ään, Androidiin, iOS:ään ja tietysti Linuxiin ja niistä pois.

Voit avata Share-valikon näppäinyhdistelmällä `Super + Ctrl + S` tai Omarchy-valikosta kohdasta _Trigger > Share_. Se antaa neljä vaihtoehtoa:

- **Clipboard** lähettää kopioimasi sisällön tekstitiedostona. Loistava tapa saada linkki tai koodinpätkä puhelimeesi lähettämättä itsellesi sähköpostia.
- **File** avaa tiedostonvalitsimen, jossa voit valita useita kerralla.
- **Folder** lähettää kokonaisen hakemiston.
- **Receive** avaa varsinaisen LocalSendin, jotta toinen laite voi lähettää sinulle jotain.

Sama toimii terminaalista komennoilla `omarchy share clipboard`, `omarchy share file [path]` ja `omarchy share folder [path]`. Jätä polku pois, niin saat valitsimen.

Voit lähettää myös suoraan tiedostonhallinnasta: napsauta mitä tahansa valintaa Nautiluksessa hiiren oikealla painikkeella ja valitse _Send via LocalSend_.

Omarchyn palomuuri on oletuksena suljettu LocalSendin porttia lukuun ottamatta, joten tämä toimii heti tuoreella asennuksella. Katso [tietoturva](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) on täydellinen toimistopaketti, jossa on tekstinkäsittely, taulukkolaskenta, esitykset, piirrossovellus ja paljon muuta. Se on yhteensopiva Microsoft Officen tiedostojen kanssa, joten tämä on loistava tapa päästä avaamaan nuo Word-asiakirjat.

Käynnistät LibreOfficen sovelluskäynnistimen kautta (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) on Omarchyn oma kuolettavan yksinkertainen esityssovellus. Esityksesi on yksi Markdown-tiedosto, jonka kuvat ja videot ovat sen vieressä: kirjoita jokainen dia reaaliaikaisen esikatselun alle, raahaa diat järjestykseen ja esitä sitten koko näytöllä tai vie PDF:ksi ja PowerPointiin. Se poimii jopa Omarchy-teemasi.

Käynnistät Hypen sovelluskäynnistimen kautta (`Super + Space`). Paina `?` sen sisällä nähdäksesi kaikki pikanäppäimet.

## Signed

[Signed](https://github.com/omacom/signed) on Omarchyn oma kuolettavan yksinkertainen tapa allekirjoittaa PDF-tiedostoja ja täyttää niitä. Sijoita tallennettu allekirjoituksesi, tekstiä ja tämän päivän päivämäärä minne tahansa sivulle ja tallenna sitten allekirjoitettu kopio alkuperäisen viereen. Katso ohjeet kohdasta [PDF-tiedostojen täyttäminen](27-filling-out-pdfs.md).

Käynnistät Signedin sovelluskäynnistimen kautta (`Super + Space`) tai avaat sillä PDF:n tiedostonhallinnasta.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) on Omarchyn oma 3D-shakkipeli. Pelaa kaveria vastaan samalla tietokoneella tai sisäänrakennettua vastustajaa vastaan kolmella tasolla, neljällä veistetyllä pelisetillä, jotka kaikki liikkuvat omalla tavallaan: kiertorata-alukset, veistetty puu ja norsunluu, metsän olennot ja karkit. Peleissä ei ole kelloa, ja ne tallentuvat jokaisen siirron jälkeen.

Käynnistät Checkmaten sovelluskäynnistimen kautta (`Super + Space`), jossa se näkyy nimellä Chess. Paina `?` sen sisällä nähdäksesi kaikki pikanäppäimet.

## Cards

[Cards](https://github.com/omacom/cards) on Omarchyn oma Klondike-pasianssi. Nosta kolme, ilman rajoitusta läpikäynneille, neljässä korttisarjassa: yksi on piirretty teemasi väreillä ja kolmella on oma ulkoasunsa. Napsauta korttia ja sitten kohdetta, johon se menee, raahaa sitä tai kaksoisnapsauta lähettääksesi sen parhaaseen paikkaan. Pelit tallentuvat jokaisen siirron jälkeen.

Käynnistät Cardsin sovelluskäynnistimen kautta (`Super + Space`). Napsauta sen nimeä tai paina `?` nähdäksesi kaikki pikanäppäimet.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) on Omarchyn oma kuolettavan yksinkertainen laskin, joka avautuu kelluvassa ikkunassa.

Käynnistät Omacalcin näppäinyhdistelmällä `Super + Shift + Q` (tai laskinnäppäimellä, jos näppäimistössäsi on sellainen).

## Signal

[Signal](https://signal.org/) on E2E-salatun viestinnän pioneeri ja loistava viestintävaihtoehto kaikille, jotka eivät halua kulkea yhden suuren teknologiakonglomeraatin kautta.

Käynnistät Signalin näppäinyhdistelmällä `Super + Shift + G`. Se ei ole osa perusasennusta, joten ensimmäisellä kerralla, kun painat sitä, Omarchy tarjoaa sen asentamista puolestasi (se on myös Omarchy-valikossa kohdassa _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) on Omarchyn oma kuolettavan yksinkertainen kuvankatselin ja mediasoitin: yksi ikkuna kuvillesi, videoillesi ja musiikillesi. Avaa kuva, niin nuolinäppäimet selaavat loput sen kansiosta, `N` ja `P` tekevät saman mille tahansa, ja `Ctrl + M` näyttää koko kansion ruudukkona. Se näyttää myös HEIC-, AVIF- ja JPEG XL -kuvat ja jatkaa siitä, mihin jäit missä tahansa pitkässä sisällössä.

Paina `F` koko näyttöä varten, `E` muokataksesi kuvaa Omasnapissa tai leikataksesi videota Omacutissa, `Ctrl + P` tulostaaksesi kuvan ja `Delete` siirtääksesi tiedoston roskakoriin (`Ctrl + Z` tuo sen takaisin). Paina `?` sen sisällä nähdäksesi kaikki pikanäppäimet.

Käynnistät Omaview’n nimellä _Media Viewer_ sovelluskäynnistimen kautta (`Super + Space`) tai vain kaksoisnapsautat kuvaa, videota tai kappaletta tiedostonhallinnassa.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) on Omarchyn oma kuolettavan yksinkertainen videonleikkaaja. Kun tarvitset vain leikata klipin alun ja lopun pois, se päihittää täyden videoeditorin käynnistämisen.

Käynnistät Omacutin sovelluskäynnistimen kautta (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) on Omarchyn oma kuolettavan yksinkertainen verkkokameratallennin. Valitse kamerasi ja mikrofonisi kerran, paina sitten `Space` tallentaaksesi ja uudelleen keskeyttääksesi ja jatkaaksesi samaa otosta. Se tallentaa aina kamerasi korkeimmalla tarkkuudella, ja siinä on reaaliaikainen mikrofonimittari, jotta voit tarkistaa tasosi ennen aloittamista.

Lopeta otos, niin se avautuu heti sisäänrakennetussa editorissa. Kaksoisnapsauta klippiä jakaaksesi sen, raahaa kahvoja leikataksesi jokaisen palan ja poista osat, joita et halua. Tallenna se sitten MP4:nä. Alkuperäinen tallenteesi säilytetään, kunnes hylkäät sen, joten voit aina palata ja leikata sen toisin.

Käynnistät Monologuen sovelluskäynnistimen kautta (`Super + Space`).
