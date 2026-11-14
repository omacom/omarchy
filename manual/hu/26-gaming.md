# Játék

Az Omarchy nem csak a _pRoDUcTiVItY_-re való, hanem szórakozásra is, és mi lehet szórakoztatóbb a játéknál? Az Omarchy egy egész csomagnyi játéklehetőséggel érkezik — Steam és RetroArch natív és retró játékhoz, Battle.net, Lutris és Heroic a nem Steam áruházakhoz, Moonlight PC-s játékstreameléshez, Xbox Cloud Gaming + NVIDIA GeForce NOW felhős játékhoz, plusz az örökzöld Minecraft.

Valve hihetetlen munkájának köszönhetően [a proton kompatibilitási rétegen](https://en.wikipedia.org/wiki/Proton_(software)) ma már több tízezer modern játék játszható Linuxon. Ja, és tudtad, hogy a [Steam Deck](https://store.steampowered.com/steamdeck/) valójában Archot futtat!

Minden játéktelepítő az Omarchy menü _Install > Gaming_ pontja alatt található (`Super + Space`). Ha valamelyiket valaha vissza akarod vonni, használd a _Remove > Gaming_ pontot.

## Steam

A [Steam](https://store.steampowered.com/) telepítéséhez válaszd az Omarchy menüben (`Super + Space`) az _Install > Gaming > Steam_ pontot.

Miután telepítetted, a Steamet a `Super + Space` billentyűkombinációval tudod elindítani.

Ne feledd, hogy a Steam indulása 10-20 másodpercig is eltarthat, és semmilyen vizuális visszajelzést nem fog adni arról, hogy éppen tölt.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

A [RetroArch](https://www.retroarch.com/) telepítéséhez válaszd az Omarchy menüben (`Super + Space`) az _Install > Gaming > RetroArch_ pontot. A teljes libretro core-készlettel érkezik, így minden klasszikus rendszer le van fedve.

A RetroArch teljesen előre van konfigurálva a gyönyörű CRT Royale shaderrel a tökéletes retró látványért.

A kezdéshez:

1. Másold a BIOS-fájljaidat a `~/Games/bios` mappába, a ROM-jaidat pedig a `~/Games/roms` mappába.
2. Indítsd el a RetroArchot a `Super + Space` billentyűkombinációval, majd gépeld be: `retro`.
3. Szkenneld be a `~/Games/roms` könyvtárat, és már játszhatsz is.

Kedvenc játékodnak saját bejegyzést is adhatsz az alkalmazásindítóban az _Install > Gaming > RetroArch Game Launcher_ ponttal, amellyel kiválaszthatsz egy core-t és egy ROM-ot, és egyenesen a játékba ugorhatsz a `Super + Space` billentyűkombinációval.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Az Xbox Cloud Gaming webalkalmazás telepítéséhez válaszd az Omarchy menüben (`Super + Space`) az _Install > Gaming > Xbox Cloud Gaming_ pontot. Ez „csak” egy webalkalmazás a szolgáltatáshoz, de gyorsan indul, és remekül fut 1080p-ben.

Ha már van Xbox Game Pass előfizetésed, ez egy masszív módja annak, hogy Fortnite-tal és más olyan címekkel játssz, amelyeket natívan nem tudsz futtatni Linuxon.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

A felhős játékszolgáltatás, az [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) telepítéséhez válaszd az Omarchy menüben (`Super + Space`) az _Install > Gaming > NVIDIA GeForce NOW_ pontot. Egy másik remek módja annak, hogy olyan címekkel játssz, amelyek natívan nem érhetők el Linuxon.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

A Minecraft telepítéséhez válaszd az Omarchy menüben (`Super + Space`) az _Install > Gaming > Minecraft_ pontot.

A Steamhez hasonlóan ne feledd, hogy bejelentkezés vagy indulás után eltarthat egy ideig, amíg megjelenik a következő képernyő, és várakozás közben semmilyen visszajelzést nem fogsz kapni.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox kontrollerek

A Bluetooth Xbox kontrollerek támogatásának telepítéséhez válaszd az Omarchy menüben (`Super + Space`) az _Install > Gaming > Xbox Controllers_ pontot. Párosítsd a kontrollereket Bluetoothon keresztül (`Super + Ctrl + B`), és minden játékodban működni fognak. Erre nincs szükséged, ha csak USB-C kábellel kötöd be a kontrollert.

## Moonlight (Játékstreamelés PC-ről)

A [Moonlight kliens](https://github.com/moonlight-stream/moonlight-qt) telepítéséhez válaszd az Omarchy menüben (`Super + Space`) az _Install > Gaming > Moonlight_ pontot, és streamelhetsz játékokat egy Windows PC-ről, amelyen [Sunshine](https://app.lizardbyte.dev/Sunshine/) fut.

Ha az Omarchy géped és a távoli játék-PC is vezetékkel csatlakozik, az élmény megkülönböztethetetlen a helyi játéktól. Tekerd fel a felbontást natívra, állítsd a frissítést 120Hz-re, és maxold ki a bitrátát — ez a legjobb módja annak, hogy kompetitív lövöldékkel, például Fortnite-tal játssz Linuxon.

Egy Omarchy gépet hoszttá is alakíthatsz az `omarchy install service sunshine` futtatásával, amely telepíti a Sunshine-t, és megnyitja a Moonlight streamelési portjait a LAN és a Tailscale számára.

## Battle.net

A [Battle.net](https://eu.shop.battle.net/en-us) telepítéséhez válaszd az Omarchy menüben (`Super + Space`) az _Install > Gaming > Battle.net_ pontot. Így olyan címekhez jutsz, mint a Diablo, a Starcraft és a World of Warcraft, önálló telepítésként, GE-Proton alatt futtatva — nincs szükség Steamre, Lutrisra vagy Heroicra.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows játékok)

A [Lutris](https://lutris.net/) telepítéséhez válaszd az Omarchy menüben (`Super + Space`) az _Install > Gaming > Lutris_ pontot. A Lutris a módja annak, hogy Windows játékokkal játssz olyan áruházakból, mint az EA és a Ubisoft Connect, amelyeknek nincs saját telepítőjük fentebb.

A telepítés egy kicsit döcögős, és néha úgy tűnik, mintha semmi sem történne — csak légy türelmes, a háttérben dolgozik.

## Heroic Launcher (Epic Games)

A [Heroic Launcher](https://heroicgameslauncher.com/) telepítéséhez válaszd az Omarchy menüben (`Super + Space`) az _Install > Gaming > Heroic (Epic Games)_ pontot. A Heroic lehetővé teszi, hogy Epic Games címeket futtass, például az OddSparksot, amelyek nem támaszkodnak anti-cheatre — plusz játékokat a GOG-ról és az Amazon Prime Gamingről. Sajnos ez azt jelenti, hogy nincs Fortnite és nincs Rocket League — amíg Tim Sweeney nem jön Linuxra, ez a legközelebbi, ami elérhető.

A Lutrishoz hasonlóan játékok telepítése közben lassúnak és döcögősnek érződhet. Adj neki időt.
