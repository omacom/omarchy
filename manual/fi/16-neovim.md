# Neovim

[Neovim](https://neovim.io/) on moderni toteutus [vi-editorista](<https://en.wikipedia.org/wiki/Vi_(text_editor)>), jonka Bill Joy loi aina vuonna 1976. Se on modaalinen editori, jossa lisäystila ja komentotila on erotettu, ja se on melkoinen supervoima, kun opit edes osajoukon uskomattoman syvästä näppäimistökomentovalikoimasta. Mutta siinä on myös melkoinen oppimiskäyrä!

Jos olet täysin uusi vim-tyylisessä muokkaamisessa, suosittelen katsomaan [ThePrimeagenin Vim As Your Editor -sarjan](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) YouTubessa. Se opettaa sinulle perusteet. Tiedä vain, että toisin kuin samankaltaisemmissa valtavirtaeditoreissa, vimin perustaitojen saavuttaminen vie kauemmin. Mutta kun saavutat sen, myös palkinto on suurempi.

Neovim on nyt pohjimmiltaan loputtomasti määritettävissä. Jos todella haluat villiintyä, voit luoda oman Neovim-määrityksesi tyhjästä. Siihen on loistava kurssi Typecraftilta aiheesta [Neovimin käyttöönotto tyhjästä](https://www.youtube.com/watch?v=zHTeCSVAFNY). Ja [ThePrimeagenilla on myös yksi](https://www.youtube.com/watch?v=w7i4amO_zaE).

Mutta Omarchyn mukana tulee täydellinen Neovim-kokoonpano — `omarchy-nvim`-paketti — joka on rakkaudella viritetty esittelemään parhaita siitä, mikä on mahdollista heti käyttövalmiina. Ilman, että sinun tarvitsee kirjoittaa riviäkään määritystä! Se on rakennettu [LazyVimin](https://www.lazyvim.org/) päälle, joka on Neovim-lisäosien ja määritysten jakelu. Se on mahtava.

## LazyVimin perusteet

Kuten mainittiin, en aio opettaa sinulle vimiä tässä lyhyessä johdannossa, mutta voin näyttää sinulle muutaman LazyVimin perusteen ja kuinka liikkua ympäriinsä.

Ensinnäkin Neovimilla on ajatus johdannaisnäppäimestä (leader key). Se on pohjimmiltaan portti kaikkiin komentoihin. LazyVim on asettanut sen näppäimeksi `Space`. Joten paina vain sitä, odota hetki, ja näet joukon vaihtoehtoja selitettyinä rivissä näin:

Tässä on muutamia peruskomentoja, joita käytän koko ajan:

- `Space Space` - Etsi sumeasti mikä tahansa tiedosto nykyisestä hakemistosta.
- `Space S G` - Hae kaikista tiedostoista grepillä esikatselun kera.
- `Space E` - Vaihda tiedostopuu päälle/pois.
- `Ctrl + W W` - Hypi tiedostopuusta editoriin ja takaisin.
- `Shift + H` - Siirry vasemmalle avoimien välilehtien välillä (vim kutsuu niitä puskureiksi).
- `Shift + L` - Siirry oikealle avoimien välilehtien välillä.
- `Space B D` - Sulje välilehti.
- `Space B O` - Sulje kaikki muut välilehdet paitsi nykyinen.
- `Space G G` - Käynnistä LazyGit kelluvassa paneelissa nykyisestä hakemistosta.
- `Space U W` - Vaihda pehmeä rivin kelaus.

Kun olet tiedostopuussa (`Space E` paljastaaksesi, `Ctrl + W W` hypätäksesi sinne), voit lisätä uuden tiedoston näppäimellä `a` tai uuden hakemiston näppäimellä `A`. Paina `?` puussa ollessasi nähdäksesi kaikki komennot.

Jos haluat oppia vimin peruskielen, olen kirjoittanut [kolmiosaisesta syntaksista](https://world.hey.com/dhh/wonderful-vi-a1d034d3) ja siitä, kuinka tehdä noita siistejä yhdistelmäliikkeitä!

Näet kaikki mahdolliset komennot [LazyVimin Keymaps-sivulla](https://www.lazyvim.org/keymaps).

## Neovimin käynnistäminen

Voit käynnistää Neovimin yhdistelmällä `Super + Shift + N` (sidos käynnistää oletuseditorisi, joka on Neovim heti käyttövalmiina), mutta on yleensä helpompaa ajaa sitä pääätteestä siirtymällä hakemistoon, jossa haluat työskennellä, ja kirjoittamalla `n`. `n` on aliaskomento komennolle `nvim`, joka käyttää avaamiseen oletuksena nykyistä hakemistoa. Voit avata yhden tiedoston komennolla `n myfile.txt`.

## Neovimin käyttäminen sudo-muokkauksiin

Jos sinun tarvitsee muokata tiedostoja, joita voit muuttaa vain pääkäyttäjänä, voit käyttää Neovimiä kaikkine lisäosineen ajamalla komennon `sudoedit /etc/sudoers.d/00-sudo-only-file`.
