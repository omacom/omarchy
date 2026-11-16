# Pelaaminen

Omarchy ei ole vain _tUoTtAvUuTtA_ varten, vaan myös hauskanpitoa varten, ja mikä olisi hauskempaa kuin pelaaminen? Omarchyn mukana tulee kokonainen valikoima pelivaihtoehtoja — Steam ja RetroArch natiivi- ja retropelaamiseen, Battle.net, Lutris ja Heroic muihin kuin Steam-kauppoihin, Moonlight PC-suoratoistoon, Xbox Cloud Gaming + NVIDIA GeForce NOW pilvipelaamiseen sekä ikivihreä Minecraft.

Valven uskomattoman työn ansiosta [proton-yhteensopivuuskerroksessa](https://en.wikipedia.org/wiki/Proton_(software)) Linuxilla on nyt pelattavissa kymmeniätuhansia moderneja pelejä. Ai niin, ja tiesitkö, että [Steam Deck](https://store.steampowered.com/steamdeck/) pyörii itse asiassa Archilla!

Kaikki peliasentajat löytyvät Omarchy-valikon kohdasta _Asenna > Pelaaminen_ (`Super + Space`). Jos haluat joskus perua jonkin niistä, käytä kohtaa _Poista > Pelaaminen_.

## Steam

Asenna [Steam](https://store.steampowered.com/) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Steam_.

Asennuksen jälkeen voit käynnistää Steamin näppäinyhdistelmällä `Super + Space`.

Huomaa, että Steamin käynnistyminen voi kestää 10-20 sekuntia, eikä se anna mitään visuaalista palautetta siitä, että se latautuu.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Asenna [RetroArch](https://www.retroarch.com/) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > RetroArch_. Sen mukana tulee täysi valikoima libretro-ytimiä, joten kaikki klassiset järjestelmät ovat katettuina.

RetroArch on täysin esiasetettu kauniilla CRT Royale -shaderilla sitä täydellistä retroulkonäköä varten.

Näin pääset alkuun:

1. Pudota BIOS-tiedostosi kansioon `~/Games/bios` ja ROM-tiedostosi kansioon `~/Games/roms`.
2. Käynnistä RetroArch näppäinyhdistelmällä `Super + Space` ja kirjoittamalla `retro`.
3. Skannaa kansio `~/Games/roms`, ja olet valmis pelaamaan.

Voit myös antaa suosikkipelillesi oman merkintänsä sovelluskäynnistimeen kohdalla _Asenna > Pelaaminen > RetroArch Game Launcher_, jonka avulla voit valita ytimen ja ROM-tiedoston ja hypätä suoraan peliin näppäinyhdistelmästä `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Asenna Xbox Cloud Gaming -verkkosovellus valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Xbox Cloud Gaming_. Se on "vain" palvelun verkkosovellus, mutta se käynnistyy nopeasti ja toimii loistavasti 1080p-tarkkuudella.

Jos sinulla on jo Xbox Game Pass, tämä on kelpo tapa pelata Fortnitea ja muita nimikkeitä, joita et voi pelata natiivisti Linuxilla.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Asenna pilvipelipalvelu [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > NVIDIA GeForce NOW_. Toinen loistava tapa pelata nimikkeitä, jotka eivät ole saatavilla natiivisti Linuxille.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Asenna Minecraft valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Minecraft_.

Kuten Steamin kohdalla, huomaa, että kirjautumisen tai käynnistymisen jälkeen seuraavan näytön ilmestyminen voi kestää hetken, etkä saa mitään palautetta odottaessasi.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Asenna tuki Bluetooth Xbox -ohjaimille valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Xbox Controllers_. Yhdistä ohjaimet Bluetoothin kautta (`Super + Ctrl + B`), ja ne toimivat kaikissa peleissäsi. Et tarvitse tätä, jos vain kytket ohjaimesi kiinni USB-C-kaapelilla.

## Moonlight (Pelien suoratoisto PC:ltä)

Asenna [Moonlight-asiakasohjelma](https://github.com/moonlight-stream/moonlight-qt) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Moonlight_, ja voit suoratoistaa pelejä Windows-PC:ltä, jossa pyörii [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Jos sekä Omarchy-koneesi että etäpelikoneesi ovat kiinni johdolla, kokemus on erottamaton paikallisesti pelaamisesta. Nosta resoluutio natiiviin, aseta virkistystaajuudeksi 120Hz ja bittinopeus maksimiin — tämä on paras tapa pelata kilpailullisia räiskintäpelejä, kuten Fortnitea, Linuxilla.

Voit myös muuttaa Omarchy-koneen isännäksi ajamalla komennon `omarchy install service sunshine`, joka asentaa Sunshinen ja avaa Moonlight-suoratoistoportit LAN-verkollesi ja Tailscalelle.

## Battle.net

Asenna [Battle.net](https://eu.shop.battle.net/en-us) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Battle.net_. Tämä antaa sinulle nimikkeet, kuten Diablo, Starcraft ja World of Warcraft, erillisenä asennuksena, joka pyörii GE-Protonin alla — Steamiä, Lutrisia tai Heroicia ei tarvita.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-pelit)

Asenna [Lutris](https://lutris.net/) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Lutris_. Lutris on tapa pelata Windows-pelejä kaupoista, kuten EA ja Ubisoft Connect, joilla ei ole omaa asentajaansa yllä.

Asennus on hieman kömpelöä ja näyttää ajoittain siltä, ettei mitään tapahdu — ole vain kärsivällinen, se työskentelee taustalla.

## Heroic Launcher (Epic Games)

Asenna [Heroic Launcher](https://heroicgameslauncher.com/) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Heroic (Epic Games)_. Heroic antaa sinun pelata Epic Games -nimikkeitä, kuten OddSparksia, jotka eivät nojaa huijauksenestoon — sekä pelejä GOGista ja Amazon Prime Gamingista. Valitettavasti se tarkoittaa, ettei Fortnitea eikä Rocket Leagueta — kunnes Tim Sweeney tulee Linuxille, tämä on lähintä, mihin pääsee.

Kuten Lutris, se voi tuntua hitaalta ja kömpelöltä pelejä asennettaessa. Anna sille aikaa.
