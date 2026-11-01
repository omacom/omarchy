# Hranie hier

Omarchy nie je len o _pRoDUcTiVItY_, je aj o zábave, a čo je zábavnejšie než hranie hier? Omarchy sa dodáva s celou sadou herných možností — Steam a RetroArch na natívne a retro hranie, Battle.net, Lutris a Heroic pre obchody mimo Steamu, Moonlight na streamovanie z PC, Xbox Cloud Gaming + NVIDIA GeForce NOW na cloud a k tomu vždy zelený Minecraft.

Vďaka neuveriteľnej práci spoločnosti Valve na [vrstve kompatibility proton](https://en.wikipedia.org/wiki/Proton_(software)) sú teraz na Linuxe desiatky tisíc hrateľných moderných hier. A vedel si, že [Steam Deck](https://store.steampowered.com/steamdeck/) v skutočnosti beží na Archu!

Všetky herné inštalátory žijú v časti _Inštalovať > Hry_ v menu Omarchy (`Super + Space`). Ak by si niekedy chcel niektorý z nich zrušiť, použi _Odstrániť > Hry_.

## Steam

[Steam](https://store.steampowered.com/) nainštaluješ výberom _Inštalovať > Hry > Steam_ z menu Omarchy (`Super + Space`).

Po nainštalovaní budeš môcť Steam spustiť pomocou `Super + Space`.

Maj na pamäti, že spustenie Steamu môže trvať 10 – 20 sekúnd a nebude poskytovať žiadnu vizuálnu spätnú väzbu, že sa načítava.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

[RetroArch](https://www.retroarch.com/) nainštaluješ výberom _Inštalovať > Hry > RetroArch_ z menu Omarchy (`Super + Space`). Dodáva sa s kompletnou sadou jadier libretro, takže sú pokryté všetky klasické systémy.

RetroArch je úplne predkonfigurovaný s krásnym shaderom CRT Royale pre dokonalý retro vzhľad.

Ako začať:

1. Vlož svoje súbory BIOS do `~/Games/bios` a svoje ROM do `~/Games/roms`.
2. Spusti RetroArch pomocou `Super + Space` a napísania `retro`.
3. Naskenuj adresár `~/Games/roms` a si pripravený hrať.

Obľúbenej hre môžeš tiež dať vlastnú položku v spúšťači aplikácií pomocou _Inštalovať > Hry > Spúšťač hier RetroArch_, kde si môžeš vybrať jadro a ROM a preskočiť priamo do hry z `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Webovú aplikáciu Xbox Cloud Gaming nainštaluješ výberom _Inštalovať > Hry > Xbox Cloud Gaming_ z menu Omarchy (`Super + Space`). Je to „len“ webová aplikácia pre túto službu, ale spúšťa sa rýchlo a beží skvele v rozlíšení 1080p.

Ak už máš Xbox Game Pass, je to solídny spôsob, ako hrať Fortnite a ďalšie tituly, ktoré nemôžeš spustiť natívne na Linuxe.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Cloudovú hernú službu [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) nainštaluješ výberom _Inštalovať > Hry > NVIDIA GeForce NOW_ z menu Omarchy (`Super + Space`). Ďalší skvelý spôsob, ako hrať tituly, ktoré nie sú dostupné natívne na Linuxe.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Minecraft nainštaluješ výberom _Inštalovať > Hry > Minecraft_ z menu Omarchy (`Super + Space`).

Podobne ako pri Steame maj na pamäti, že po prihlásení alebo spustení môže chvíľu trvať, než sa objaví ďalšia obrazovka, a počas čakania nebudeš dostávať žiadnu spätnú väzbu.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Ovládače Xbox

Podporu pre Bluetooth ovládače Xbox nainštaluješ výberom _Inštalovať > Hry > Ovládače Xbox_ z menu Omarchy (`Super + Space`). Spáruj ovládače prostredníctvom Bluetooth (`Super + Ctrl + B`) a budú fungovať vo všetkých tvojich hrách. Toto nepotrebuješ, ak ovládač len pripájaš káblom USB-C.

## Moonlight (streamovanie hier z PC)

[Klient Moonlight](https://github.com/moonlight-stream/moonlight-qt) sa dodáva predinštalovaný s Omarchy, takže môžeš okamžite streamovať hry z počítača s Windowsom, na ktorom beží [Sunshine](https://app.lizardbyte.dev/Sunshine/). Moonlight spustíš prostredníctvom `Super + Space`.

Ak sú tvoj počítač s Omarchy aj vzdialený herný počítač pripojené káblom, zážitok je na nerozoznanie od lokálneho hrania. Zvýš rozlíšenie na natívne, nastav obnovovaciu frekvenciu na 120 Hz a maximalizuj bitrate — toto je najlepší spôsob, ako hrať súťažné strieľačky ako Fortnite na Linuxe.

Počítač s Omarchy môžeš tiež premeniť na hostiteľa spustením `omarchy install service sunshine`, čo nainštaluje Sunshine a otvorí streamovacie porty Moonlight pre tvoju LAN a Tailscale.

## Battle.net

[Battle.net](https://eu.shop.battle.net/en-us) nainštaluješ výberom _Inštalovať > Hry > Battle.net_ z menu Omarchy (`Super + Space`). Tým získaš tituly ako Diablo, Starcraft a World of Warcraft ako samostatnú inštaláciu bežiacu pod GE-Proton — nie je potrebný Steam, Lutris ani Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (hry pre Windows)

[Lutris](https://lutris.net/) nainštaluješ výberom _Inštalovať > Hry > Lutris_ z menu Omarchy (`Super + Space`). Lutris je spôsob, ako hrať hry pre Windows z obchodov ako EA a Ubisoft Connect, ktoré vyššie nemajú vlastný inštalátor.

Inštalácia je trochu kostrbatá a občas to vyzerá, akoby sa nič nedialo — len buď trpezlivý, na pozadí to pracuje.

## Heroic Launcher (Epic Games)

[Heroic Launcher](https://heroicgameslauncher.com/) nainštaluješ výberom _Inštalovať > Hry > Heroic (Epic Games)_ z menu Omarchy (`Super + Space`). Heroic ti umožňuje spúšťať tituly Epic Games, ako je OddSparks, ktoré sa nespoliehajú na ochranu proti podvádzaniu (anti-cheat) — plus hry z GOG a Amazon Prime Gaming. Bohužiaľ to znamená, že žiadny Fortnite a žiadny Rocket League — kým Tim Sweeney nepríde na Linux, bližšie sa nedostaneme.

Podobne ako Lutris sa môže pri inštalovaní hier zdať pomalý a kostrbatý. Daj mu čas.
