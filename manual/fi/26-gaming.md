# Pelaaminen

Omarchy ei ole vain _tUoTtAvUuTtA_ varten, se on myös hauskanpitoa varten, ja mikä on hauskempaa kuin pelaaminen? Omarchyssa on kokonainen valikoima pelivaihtoehtoja — Steam ja RetroArch natiiviin ja retropelaamiseen, Battle.net, Lutris ja Heroic ei-Steam-kaupoille, Moonlight PC-suoratoistoon, Xbox Cloud Gaming + NVIDIA GeForce NOW pilveen, sekä ikivihreä Minecraft.

Valven uskomattoman työn ansiosta [Proton-yhteensopivuuskerroksessa](https://en.wikipedia.org/wiki/Proton_(software)) Linuxissa on nyt kymmeniä tuhansia pelattavia moderneja pelejä. Ai niin, ja tiesitkö, että [Steam Deck](https://store.steampowered.com/steamdeck/) ajaa oikeasti Archia!

Kaikki peliasentajat sijaitsevat Omarchy-valikon (`Super + Space`) kohdassa _Asenna > Pelaaminen_. Jos joskus haluat kumota yhden, käytä kohtaa _Poista > Pelaaminen_.

## Steam

Asenna [Steam](https://store.steampowered.com/) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Steam_.

Kun olet asentanut sen, voit käynnistää Steamin näppäimillä `Super + Space`.

Huomaa, että Steamin käynnistyminen voi kestää 10–20 sekuntia, eikä se anna mitään visuaalista palautetta latautumisestaan.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Asenna [RetroArch](https://www.retroarch.com/) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > RetroArch_. Sen mukana tulee täysi joukko libretro-ytimiä, joten kaikki klassikkojärjestelmät ovat katettuja.

RetroArch on täysin esiasetettu kauniilla CRT Royale -shaderilla tuota täydellistä retro-ilmettä varten.

Päästäksesi vauhtiin:

1. Pudota BIOS-tiedostosi hakemistoon `~/Games/bios` ja ROMisi hakemistoon `~/Games/roms`.
2. Käynnistä RetroArch näppäimillä `Super + Space` ja kirjoittamalla `retro`.
3. Skannaa hakemisto `~/Games/roms`, ja olet valmis pelaamaan.

Voit myös antaa suosikkipelillesi oman merkintänsä sovellusten käynnistimeen kohdassa _Asenna > Pelaaminen > RetroArch-pelikäynnistin_, jonka avulla voit valita ytimen ja ROMin ja hypätä suoraan peliin näppäimillä `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Asenna Xbox Cloud Gaming -verkkosovellus valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Xbox Cloud Gaming_. Se on "vain" palvelun verkkosovellus, mutta sen käynnistäminen on nopeaa ja se toimii loistavasti 1080p:nä.

Jos sinulla on jo Xbox Game Pass, tämä on mainio tapa pelata Fortnitea ja muita nimikkeitä, joita et voi ajaa natiivisti Linuxissa.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Asenna pilvipelipalvelu [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > NVIDIA GeForce NOW_. Toinen erinomainen tapa pelata nimikkeitä, joita ei ole saatavilla natiivisti Linuxissa.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Asenna Minecraft valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Minecraft_.

Kuten Steamissa, huomaa, että kirjautumisen tai käynnistyksen jälkeen seuraavan näytön ilmestyminen voi kestää jonkin aikaa, etkä saa mitään palautetta odottaessasi.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Asenna tuki Bluetooth Xbox -ohjaimille valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Xbox-ohjaimet_. Parita ohjaimet Bluetoothin kautta (`Super + Ctrl + B`), ja ne toimivat kaikissa peleissäsi. Et tarvitse tätä, jos vain kytket ohjaimesi kiinteästi USB-C-kaapelilla.

## Moonlight (Pelisuoratoisto PC:ltä)

[Moonlight-asiakas](https://github.com/moonlight-stream/moonlight-qt) tulee esiasennettuna Omarchyn mukana, joten voit suoratoistaa pelejä [Sunshinea](https://app.lizardbyte.dev/Sunshine/) ajavalta Windows-PC:ltä heti. Käynnistä Moonlight näppäimillä `Super + Space`.

Jos sekä Omarchy-koneesi että etäpeli-PC ovat kiinteästi kytkettyjä, kokemus on erottamaton paikallisesti pelaamisesta. Nosta resoluutio natiiviksi, aseta virkistystaajuus 120 Hz:iin ja maksimoi bittinopeus — tämä on paras tapa pelata kilpailullisia ammuskelupelejä, kuten Fortnitea, Linuxissa.

Voit myös muuttaa Omarchy-koneen isännäksi ajamalla `omarchy install service sunshine`, joka asentaa Sunshinen ja avaa Moonlight-suoratoistoportit LANillesi ja Tailscalelle.

## Battle.net

Asenna [Battle.net](https://eu.shop.battle.net/en-us) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Battle.net_. Tämä antaa sinulle nimikkeitä, kuten Diablon, Starcraftin ja World of Warcraftin, erillisasennuksena, joka toimii GE-Protonin alla — Steamia, Lutrista tai Heroicia ei tarvita.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-pelit)

Asenna [Lutris](https://lutris.net/) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Lutris_. Lutris on tapa pelata Windows-pelejä kaupoista, kuten EA ja Ubisoft Connect, joilla ei ole omaa asentajaa yllä.

Asennus on hieman kömpelöä ja näyttää toisinaan siltä, ettei mitään tapahdu — ole vain kärsivällinen, se toimii taustalla.

## Heroic Launcher (Epic Games)

Asenna [Heroic Launcher](https://heroicgameslauncher.com/) valitsemalla Omarchy-valikosta (`Super + Space`) _Asenna > Pelaaminen > Heroic (Epic Games)_. Heroic antaa sinun ajaa Epic Games -nimikkeitä, kuten OddSparksia, jotka eivät nojaa huijauksenestoon — sekä pelejä GOGista ja Amazon Prime Gamingista. Valitettavasti se tarkoittaa, ettei Fortnitea eikä Rocket Leagueta — kunnes Tim Sweeney tulee Linuxiin, tämä on niin lähellä kuin päästään.

Kuten Lutris, se voi tuntua hitaalta ja kömpelöltä pelejä asennettaessa. Anna sille aikaa.
