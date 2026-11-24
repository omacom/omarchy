# Neovim

[Neovim](https://neovim.io/) on moderni toteutus [vi-editorista](<https://en.wikipedia.org/wiki/Vi_(text_editor)>), jonka Bill Joy loi jo vuonna 1976. Se on modaalinen editori, jossa syöttötila ja komentotila on erotettu toisistaan, ja se on melkoinen supervoima, kun opit edes osan uskomattoman laajasta näppäinkomentojen valikoimasta. Mutta oppimiskäyrä on myös melkoinen!

Jos vim-tyylinen muokkaaminen on sinulle täysin uutta, suosittelen tutustumaan [ThePrimeagenin Vim As Your Editor -sarjaan](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) YouTubessa. Se opettaa sinulle perusteet. Tiedä vain, että toisin kuin tutummissa valtavirran editoreissa, vimin perustason hallinnan oppiminen vie sinulta pidempään. Mutta kun sen opit, hyöty on myös suurempi.

Neovim on käytännössä loputtomasti muokattavissa. Jos haluat oikeasti mennä äärimmäisyyksiin, voit luoda oman Neovim-kokoonpanosi alusta asti. Typecraftilta löytyy loistava kurssi [Neovimin käyttöönotosta alusta asti](https://www.youtube.com/watch?v=zHTeCSVAFNY). Ja [ThePrimeagenilla on myös sellainen](https://www.youtube.com/watch?v=w7i4amO_zaE).

Mutta Omarchyn mukana tulee täydellinen Neovim-kokoonpano — `omarchy-nvim`-paketti — joka on hiottu rakkaudella näyttämään parhaat puolet siitä, mikä on mahdollista suoraan käyttövalmiina. Ilman että sinun tarvitsee kirjoittaa riviäkään konfiguraatiota! Se on rakennettu [LazyVimin](https://www.lazyvim.org/) päälle, joka on Neovim-lisäosien ja -kokoonpanojen jakelu. Se on mahtava.

## LazyVimin perusteet

Kuten mainitsin, en aio opettaa sinulle vimiä tässä lyhyessä johdannossa, mutta voin näyttää muutaman LazyVimin perusteen ja sen, miten siinä liikutaan.

Ensinnäkin Neovimissa on ajatus leader-näppäimestä. Se on käytännössä portti kaikkiin komentoihin. LazyVim on asettanut sen näppäimeksi `Space`. Paina siis vain sitä, odota sekunti, niin näet joukon vaihtoehtoja selitettynä näin rivin sisällä:

Tässä on muutama peruskomento, joita käytän koko ajan:

- `Space Space` - Etsi mikä tahansa tiedosto nykyisestä hakemistosta sumealla haulla.
- `Space S G` - Hae kaikista tiedostoista grepillä esikatselun kanssa.
- `Space E` - Näytä tai piilota tiedostopuu.
- `Ctrl + W W` - Hyppää tiedostopuusta editoriin ja takaisin.
- `Shift + H` - Siirry vasemmalle avoimien välilehtien välillä (vim kutsuu niitä puskureiksi).
- `Shift + L` - Siirry oikealle avoimien välilehtien välillä.
- `Space B D` - Sulje välilehti.
- `Space B O` - Sulje kaikki muut välilehdet paitsi nykyinen.
- `Space G G` - Käynnistä LazyGit kelluvassa ruudussa nykyisestä hakemistosta.
- `Space U W` - Ota pehmeä rivitys käyttöön tai pois käytöstä.

Kun olet tiedostopuussa (`Space E` näyttää sen, `Ctrl + W W` hyppää sinne), voit lisätä uuden tiedoston näppäimellä `a` tai uuden hakemiston näppäimellä `A`. Paina `?` ollessasi puussa nähdäksesi kaikki komennot.

Jos haluat oppia vimin peruskielen, olen kirjoittanut [kolmiosaisesta syntaksista](https://world.hey.com/dhh/wonderful-vi-a1d034d3) ja siitä, miten niillä tehdään niitä sairaita kombo-liikkeitä!

Näet kaikki mahdolliset komennot [LazyVimin Keymaps-sivulla](https://www.lazyvim.org/keymaps).

## Neovimin käynnistäminen

`Super + Shift + N` käynnistää oletuseditorisi, joka on uusissa asennuksissa Plain; valitse Neovim kohdasta _Setup > Defaults > Editor_, jos haluat sen käynnistävän sen sijaan Neovimin. Mutta sitä on yleensä helpompi käyttää terminaalista siirtymällä hakemistoon, jossa haluat työskennellä, ja kirjoittamalla `n`. `n` on alias komennolle `nvim`, joka käyttää oletuksena avaamiseen nykyistä hakemistoa. Voit avata yksittäisen tiedoston komennolla `n myfile.txt`.

## Neovimin käyttäminen sudo-muokkauksiin

Jos sinun täytyy muokata tiedostoja, joita voit muuttaa vain pääkäyttäjänä, aja `sudoedit /etc/sudoers.d/00-sudo-only-file`. Se avaa oletuseditorisi, joten aseta Neovim kohdassa _Setup > Defaults > Editor_, jos haluat sen sinne kaikkine lisäosineen.
