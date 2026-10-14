# Játékok

Az Omarchy nem csak a _tErMeLéKeNySéGrE_ való, hanem szórakozásra is, és mi lehetne szórakoztatóbb, mint játszani? Az Omarchy a játékos lehetőségek egész készletét hozza el — Steam és RetroArch natív és retró játékhoz, Battle.net-, Lutris- és Heroic nem steam-boltokhoz, Moonlight PC-s streaminghez, Xbox Cloud Gaming + NVIDIA GeForce NOW felhőz, valamint az örökzöld Minecraft.

A Valve [a proton kompatibilitási rétegen](https://en.wikipedia.org/wiki/Proton_(software)) végzett hihetetlen munkájának köszönhetően ma már több tízezer modern játék játszható Linuxon. És tudtad, hogy a [Steam Deck](https://store.steampowered.com/steamdeck/) tulajdonképpen Archot futtat!

Minden játékos telepítő az Omarchy menü (`Super + Space`) _Install > Gaming_ pontjában található. Ha valaha is vissza szeretnél vonni egyet, használd az _Remove > Gaming_ pontot.

## Steam

Telepítsd a [Steamet](https://store.steampowered.com/) az Omarchy menü (`Super + Space`) _Install > Gaming > Steam_ pontjának kiválasztásával.

A telepítés után a `Super + Space` kombinációval indíthatod a Steamet.

Megjegyzés: a Steam indulása 10–20 másodpercig tarthat, és semmilyen vizuális visszajelzést nem fog adni arról, hogy betöltődik.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Telepítsd a [RetroArchot](https://www.retroarch.com/) az Omarchy menü (`Super + Space`) _Install > Gaming > RetroArch_ pontjának kiválasztásával. A libretro-magok teljes készletét tartalmazza, így minden klasszikus rendszer le van fedve.

A RetroArch teljesen előre konfigurált a gyönyörű CRT Royale shadervel a tökéletes retró megjelenésért.

Kezdéshez:

1. Dobja be a BIOS-fájljait a `~/Games/bios` mappába, ROM-jait pedig a `~/Games/roms` mappába.
2. Indítsd a RetroArchot a `Super + Space` kombinációval, és írd be, hogy `retro`.
3. Vizsgáld át a `~/Games/roms` könyvtárat, és készen állsz a játékra.

Kedvenc játékodnak saját bejegyzést is adhatsz az alkalmazásindítóban az _Install > Gaming > RetroArch Game Launcher_ eszközzel, amely lehetővé teszi egy mag és egy ROM kiválasztását, és közvetlenül a játékba ugorhatsz a `Super + Space` kombinációval.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Telepítsd az Xbox Cloud Gaming webalkalmazást az Omarchy menü (`Super + Space`) _Install > Gaming > Xbox Cloud Gaming_ pontjának kiválasztásával. „Csak” a szolgáltatás egy webalkalmazása, de gyorsan indul, és 1080p-n kiválóan fut.

Ha már van Xbox Game Passod, ez egy szilárd lehetőség a Fortnite és más olyan címek lejátszására, amelyeket nem tudsz natívan futtatni Linuxon.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Telepítsd a felhőjáték-szolgáltatást, az [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) szolgáltatást az Omarchy menü (`Super + Space`) _Install > Gaming > NVIDIA GeForce NOW_ pontjának kiválasztásával. További nagyszerű lehetőség olyan címek lejátszására, amelyek nem érhetők el natívan Linuxon.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Telepítsd a Minecraftot az Omarchy menü (`Super + Space`) _Install > Gaming > Minecraft_ pontjának kiválasztásával.

Akárcsak a Steam esetében, vedd figyelembe, hogy a bejelentkezés vagy indítás után sokáig tarthat, amíg megjelenik a következő képernyő, és várakozás közben semmilyen visszajelzést nem kapsz.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox-kontrollerek

Telepítsd a Bluetooth Xbox kontrollerek támogatását az Omarchy menü (`Super + Space`) _Install > Gaming > Xbox Controllers_ pontjának kiválasztásával. Párosítsd a kontrollerekat Bluetoothon (`Super + Ctrl + B`) keresztül, és működni fognak minden játékodban. Erre nincs szükséged, ha a kontrollert csak USB-C kábellel keményen csatlakoztatod.

## Moonlight (Játék-streaming PC-ről)

A [Moonlight kliens](https://github.com/moonlight-stream/moonlight-qt) előre telepítve van az Omarchyval, így azonnal streamelhetsz játékokat egy [Sunshine](https://app.lizardbyte.dev/Sunshine/) rendszert futtató Windows PC-ről. Indítsd a Moonlightot a `Super + Space` kombinációval.

Ha mind az Omarchy géped, mind a távoli játékos PC-d kábeles, az élmény megkülönböztethetetlen a helyben történő játéktól. Törd fel a felbontást natívra, állítsd a frissítési gyakoriságot 120 Hz-re, és maximalizáld az átviteli sebességet — ez a legjobb mód a versenyszintű FPS-játékok, mint a Fortnite, Linuxon történő lejátszására.

Az Omarchy-gépet gazdagéppé is teheted az `omarchy install service sunshine` paranccsal, amely telepíti a Sunshine-t, és megnyitja a Moonlight streaming portjait a LAN és a Tailscale felé.

## Battle.net

Telepítsd a [Battle.netet](https://eu.shop.battle.net/en-us) az Omarchy menü (`Super + Space`) _Install > Gaming > Battle.net_ pontjának kiválasztásával. Így olyan játékok érhetők el, mint a Diablo, a Starcraft és a World of Warcraft önálló telepítésként GE-Proton alatt — Steamre, Lutrisra vagy Heroicra nincs szükség.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-játékok)

Telepítsd a [Lutrist](https://lutris.net/) az Omarchy menü (`Super + Space`) _Install > Gaming > Lutris_ pontjának kiválasztásával. A Lutris az a mód, ahogyan olyan boltokból származó Windows-játékokat játszhatsz, mint az EA és az Ubisoft Connect, amelyeknek nincs saját telepítőjük fent.

A telepítés kissé döcögős, és néha úgy tűnik, mintha semmi sem történne — kérjük, légy türelmes, a háttérben működik.

## Heroic Launcher (Epic Games)

Telepítsd a [Heroic Launchert](https://heroicgameslauncher.com/) az Omarchy menü (`Super + Space`) _Install > Gaming > Heroic (Epic Games)_ pontjának kiválasztásával. A Heroic lehetővé teszi Epic Games-játékok futtatását, mint az OddSparks, amelyek nem használják az anti-cheatet — plusz a GOG és az Amazon Prime Gaming játékait is. Sajnos ez azt jelenti, hogy nincs Fortnite és nincs Rocket League — amíg Tim Sweeney nem érkezik meg Linuxra, ez van a legközelebb, amit kaphatsz.

Akárcsak a Lutrisnál, a játékok telepítése közben is lassúnak és döcögősnek érződhet. Adj neki időt.
