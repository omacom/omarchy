# Játék

Az Omarchy nem csak _pRoDUcTiVItY_-re való, hanem szórakozásra is, és mi szórakoztatóbb a játéknál? Az Omarchy egy egész játékos csomagot szállít — Steam és RetroArch natív és retró játékhoz, Battle.net, Lutris és Heroic a nem Steames áruházakhoz, Moonlight PC-s streameléshez, Xbox Cloud Gaming + NVIDIA GeForce NOW felhőhöz, plusz az örökzöld Minecraft.

A Valve hihetetlen munkájának köszönhetően [a proton kompatibilitási rétegen](https://en.wikipedia.org/wiki/Proton_(software)) ma már több tízezer modern játék játszható Linuxon. És azt tudtad, hogy a [Steam Deck](https://store.steampowered.com/steamdeck/) valójában Archot futtat!

Minden játéktelepítő az _Install > Gaming_ alatt él az Omarchy menüben (`Super + Space`). Ha valaha vissza akarsz vonni egyet, használd a _Remove > Gaming_ pontot. A Minecraft, az NVIDIA GeForce NOW, a Battle.net, a Lutris és a Heroic csak x86-os gépeken érhető el.

## Steam

Telepítsd a [Steamet](https://store.steampowered.com/) az _Install > Gaming > Steam_ kiválasztásával az Omarchy menüből (`Super + Space`).

Miután telepítetted, a Steamet a `Super + Space` billentyűkombinációval tudod elindítani.

Ne feledd, hogy a Steam indulása 10-20 másodpercet is igénybe vehet, és semmilyen vizuális visszajelzést nem ad arról, hogy éppen tölt.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Telepítsd a [RetroArchot](https://www.retroarch.com/) az _Install > Gaming > RetroArch_ kiválasztásával az Omarchy menüből (`Super + Space`). A libretro magok teljes készletével érkezik, így minden klasszikus rendszer le van fedve.

A RetroArch teljesen előre be van állítva a gyönyörű CRT Royale shaderrel a tökéletes retró megjelenéshez.

A kezdéshez:

1. Dobd a BIOS fájljaidat a `~/Games/bios` mappába, a ROM-jaidat pedig a `~/Games/roms` mappába.
2. Indítsd el a RetroArchot a `Super + Space` billentyűkombinációval és a `retro` beírásával.
3. Olvasd be a `~/Games/roms` könyvtárat, és már játszhatsz is.

Kedvenc játékodnak saját bejegyzést is adhatsz az alkalmazásindítóban az _Install > Gaming > RetroArch Game Launcher_ segítségével, amellyel kiválaszthatsz egy magot és egy ROM-ot, és egyenesen a játékba ugorhatsz a `Super + Space` billentyűkombinációval.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Telepítsd az Xbox Cloud Gaming webalkalmazást az _Install > Gaming > Xbox Cloud Gaming_ kiválasztásával az Omarchy menüből (`Super + Space`). Ez „csak” egy webalkalmazás a szolgáltatáshoz, de gyorsan indul és remekül fut 1080p felbontásban.

Ha már van Xbox Game Passed, ez egy masszív módja annak, hogy Fortnite-tal és más olyan címekkel játssz, amelyeket nem tudsz natívan futtatni Linuxon.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Telepítsd a felhős játékszolgáltatást, az [NVIDIA GeForce NOW-t](https://www.nvidia.com/en-us/geforce-now/) az _Install > Gaming > NVIDIA GeForce NOW_ kiválasztásával az Omarchy menüből (`Super + Space`). Egy másik remek módja annak, hogy olyan címekkel játssz, amelyek nem érhetők el natívan Linuxon.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Telepítsd a Minecraftot az _Install > Gaming > Minecraft_ kiválasztásával az Omarchy menüből (`Super + Space`).

A Steamhez hasonlóan ne feledd, hogy bejelentkezés vagy indulás után eltarthat egy ideig, amíg megjelenik a következő képernyő, és várakozás közben semmilyen visszajelzést nem kapsz.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Telepítsd a Bluetooth Xbox kontrollerek támogatását az _Install > Gaming > Xbox Controllers_ kiválasztásával az Omarchy menüből (`Super + Space`). Párosítsd a kontrollereket Bluetooth-on keresztül (`Super + Ctrl + B`), és minden játékodban működni fognak. Erre nincs szükséged, ha csak USB-C kábellel kötöd be a kontrolleredet.

## Moonlight (Játék streamelése PC-ről)

Telepítsd a [Moonlight klienst](https://github.com/moonlight-stream/moonlight-qt) az _Install > Gaming > Moonlight_ kiválasztásával az Omarchy menüből (`Super + Space`), és streamelhetsz játékokat egy [Sunshine-t](https://app.lizardbyte.dev/Sunshine/) futtató Windows PC-ről.

Ha mind az Omarchy géped, mind a távoli játék-PC vezetékkel csatlakozik, az élmény megkülönböztethetetlen a helyi játéktól. Tekerd fel a felbontást natívra, állítsd a frissítést 120Hz-re, és maxold ki a bitrátát — ez a legjobb módja annak, hogy kompetitív lövöldözős játékokkal, például Fortnite-tal játssz Linuxon.

Az Omarchy gépedet hoszttá is alakíthatod az `omarchy install service sunshine` futtatásával, amely telepíti a Sunshine-t és megnyitja a Moonlight streamelési portjait a LAN-od és a Tailscale számára.

## Battle.net

Telepítsd a [Battle.netet](https://eu.shop.battle.net/en-us) az _Install > Gaming > Battle.net_ kiválasztásával az Omarchy menüből (`Super + Space`). Így olyan címekhez jutsz, mint a Diablo, a Starcraft és a World of Warcraft, önálló telepítésként, GE-Proton alatt futtatva — nincs szükség Steamre, Lutrisra vagy Heroicra.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-játékok)

Telepítsd a [Lutrist](https://lutris.net/) az _Install > Gaming > Lutris_ kiválasztásával az Omarchy menüből (`Super + Space`). A Lutris a módja annak, hogy olyan áruházakból származó Windows-játékokkal játssz, mint az EA és a Ubisoft Connect, amelyeknek nincs saját telepítőjük fentebb.

A telepítés egy kicsit döcögős, és néha úgy néz ki, mintha semmi sem történne — csak légy türelmes, a háttérben dolgozik.

## Heroic Launcher (Epic Games)

Telepítsd a [Heroic Launchert](https://heroicgameslauncher.com/) az _Install > Gaming > Heroic (Epic Games)_ kiválasztásával az Omarchy menüből (`Super + Space`). A Heroic lehetővé teszi, hogy olyan Epic Games címeket futtass, mint az OddSparks, amelyek nem támaszkodnak anti-cheatre — plusz játékokat a GOG-ról és az Amazon Prime Gamingről. Sajnos ez azt jelenti, hogy nincs Fortnite és nincs Rocket League — amíg Tim Sweeney el nem jön Linuxra, ez a legközelebbi, ami elérhető.

A Lutrishoz hasonlóan játékok telepítése közben lassúnak és döcögősnek érződhet. Adj neki időt.
