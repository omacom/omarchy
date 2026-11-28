# Pelaaminen

Omarchy ei ole vain _tUoTtAvUuTtA_ varten, se on myös hauskanpitoa varten, ja mikä olisi hauskempaa kuin pelaaminen? Omarchyn mukana tulee kokonainen valikoima pelivaihtoehtoja — Steam ja RetroArch natiivi- ja retropelaamiseen, Battle.net, Lutris ja Heroic muihin kuin Steam-kauppoihin, Moonlight PC-suoratoistoon, Xbox Cloud Gaming + NVIDIA GeForce NOW pilvipelaamiseen, sekä ikivihreä Minecraft.

Valven uskomattoman työn ansiosta [Proton-yhteensopivuuskerroksen](https://en.wikipedia.org/wiki/Proton_(software)) parissa Linuxilla on nyt pelattavissa kymmeniätuhansia moderneja pelejä. Ai niin, ja tiesitkö, että [Steam Deck](https://store.steampowered.com/steamdeck/) käyttää itse asiassa Archia!

Kaikki pelien asentimet löytyvät Omarchy-valikosta kohdasta _Asenna > Pelaaminen_ (`Super + Space`). Jos haluat joskus perua jonkin asennuksen, käytä kohtaa _Poista > Pelaaminen_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris ja Heroic ovat tarjolla vain x86-koneille.

## Steam

Asenna [Steam](https://store.steampowered.com/) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Steam_.

Asennuksen jälkeen voit käynnistää Steamin näppäimillä `Super + Space`.

Huomaa, että Steamin käynnistyminen voi kestää 10-20 sekuntia, eikä se anna mitään visuaalista palautetta latautumisestaan.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Asenna [RetroArch](https://www.retroarch.com/) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > RetroArch_. Sen mukana tulee täysi valikoima libretro-ytimiä, joten kaikki klassikkojärjestelmät ovat katettuina.

RetroArch on täysin valmiiksi määritetty kauniilla CRT Royale -shaderilla sitä täydellistä retroilmettä varten.

Näin pääset alkuun:

1. Pudota BIOS-tiedostosi kansioon `~/Games/bios` ja ROM-tiedostosi kansioon `~/Games/roms`.
2. Käynnistä RetroArch näppäimillä `Super + Space` ja kirjoittamalla `retro`.
3. Skannaa `~/Games/roms`-hakemisto, niin olet valmis pelaamaan.

Voit myös antaa suosikkipelillesi oman merkinnän sovelluskäynnistimeen kohdalla _Asenna > Pelaaminen > RetroArch Game Launcher_, jolla voit valita ytimen ja ROMin ja hypätä suoraan peliin näppäimillä `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Asenna Xbox Cloud Gaming -verkkosovellus valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Xbox Cloud Gaming_. Se on "vain" palvelun verkkosovellus, mutta se käynnistyy nopeasti ja toimii loistavasti 1080p-tarkkuudella.

Jos sinulla on jo Xbox Game Pass, tämä on mainio tapa pelata Fortnitea ja muita nimikkeitä, joita et voi ajaa natiivisti Linuxilla.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Asenna pilvipelipalvelu [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > NVIDIA GeForce NOW_. Toinen loistava tapa pelata nimikkeitä, jotka eivät ole saatavilla natiivisti Linuxilla.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Asenna Minecraft valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Minecraft_.

Steamin tavoin huomaa, että kirjautumisen tai käynnistymisen jälkeen voi kestää hetken, ennen kuin seuraava näyttö tulee näkyviin, etkä saa mitään palautetta odottaessasi.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox-ohjaimet

Asenna tuki Bluetooth Xbox -ohjaimille valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Xbox Controllers_. Yhdistä ohjaimet pariksi Bluetoothin kautta (`Super + Ctrl + B`), niin ne toimivat kaikissa peleissäsi. Et tarvitse tätä, jos vain kytket ohjaimesi kiinteästi USB-C-kaapelilla.

## Moonlight (Pelistriimaus PC:ltä)

Asenna [Moonlight-asiakasohjelma](https://github.com/moonlight-stream/moonlight-qt) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Moonlight_, niin voit suoratoistaa pelejä Windows-PC:ltä, jossa on käytössä [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Jos sekä Omarchy-koneesi että etäpelikoneesi ovat kiinteästi verkossa, kokemus ei eroa paikallisesta pelaamisesta. Nosta resoluutio natiiviksi, aseta virkistystaajuudeksi 120Hz ja bitrate maksimiin — tämä on paras tapa pelata kilpailullisia räiskintäpelejä, kuten Fortnitea, Linuxilla.

Voit myös muuttaa Omarchy-koneen isännäksi ajamalla `omarchy install service sunshine`, joka asentaa Sunshinen ja avaa Moonlightin suoratoistoportit LAN-verkollesi ja Tailscalelle.

## Battle.net

Asenna [Battle.net](https://eu.shop.battle.net/en-us) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Battle.net_. Tämä tuo sinulle nimikkeet, kuten Diablo, Starcraft ja World of Warcraft, erillisenä asennuksena, joka toimii GE-Protonilla — Steamiä, Lutrisia tai Heroicia ei tarvita.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-pelit)

Asenna [Lutris](https://lutris.net/) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Lutris_. Lutris on tapa pelata Windows-pelejä kaupoista, kuten EA ja Ubisoft Connect, joilla ei ole omaa asentajaa yllä.

Asennus on vähän takkuista ja välillä näyttää siltä, ettei mitään tapahdu — ole vain kärsivällinen, se toimii taustalla.

## Heroic Launcher (Epic Games)

Asenna [Heroic Launcher](https://heroicgameslauncher.com/) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Heroic (Epic Games)_. Heroicilla voit ajaa Epic Games -nimikkeitä, kuten OddSparksia, jotka eivät nojaa huijauksenestoon — sekä pelejä GOGista ja Amazon Prime Gamingista. Valitettavasti se tarkoittaa, ettei Fortnitea eikä Rocket Leagueta — ennen kuin Tim Sweeney tulee Linuxille, tämä on lähintä, mihin päästään.

Lutrisin tavoin se voi tuntua hitaalta ja takkuiselta pelejä asennettaessa. Anna sille aikaa.
