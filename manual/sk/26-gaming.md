# Hranie hier

Omarchy nie je len na _pRoDUkTiViTu_, je aj na zábavu, a čo je zábavnejšie než hranie hier? Omarchy sa dodáva s celou sadou herných možností — Steam a RetroArch na natívne a retro hranie, Battle.net, Lutris a Heroic na obchody mimo Steamu, Moonlight na streamovanie z PC, Xbox Cloud Gaming + NVIDIA GeForce NOW na cloud, plus nestarnúci Minecraft.

Vďaka neuveriteľnej práci Valve na [kompatibilnej vrstve Proton](https://en.wikipedia.org/wiki/Proton_(software)) sú teraz na Linuxe desiatky tisíc hrateľných moderných hier. A vedeli ste, že [Steam Deck](https://store.steampowered.com/steamdeck/) v skutočnosti beží na Archu!

Všetky inštalátory hier nájdete v ponuke Omarchy pod _Install > Gaming_ (`Super + Space`). Ak budete chcieť niektorý z nich niekedy vrátiť späť, použite _Remove > Gaming_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris a Heroic sa ponúkajú len na počítačoch x86.

## Steam

Nainštalujte [Steam](https://store.steampowered.com/) výberom _Install > Gaming > Steam_ z ponuky Omarchy (`Super + Space`).

Po nainštalovaní budete môcť Steam spustiť pomocou `Super + Space`.

Upozorňujeme, že spustenie Steamu môže trvať 10-20 sekúnd a nebude poskytovať žiadnu vizuálnu spätnú väzbu, že sa načítava.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Nainštalujte [RetroArch](https://www.retroarch.com/) výberom _Install > Gaming > RetroArch_ z ponuky Omarchy (`Super + Space`). Dodáva sa s úplnou sadou jadier libretro, takže sú pokryté všetky klasické systémy.

RetroArch je kompletne predkonfigurovaný s nádherným shaderom CRT Royale pre ten dokonalý retro vzhľad.

Ako začať:

1. Vložte svoje súbory BIOS do `~/Games/bios` a svoje ROM do `~/Games/roms`.
2. Spustite RetroArch pomocou `Super + Space` a napísaním `retro`.
3. Preskenujte adresár `~/Games/roms` a môžete hrať.

Obľúbenej hre môžete dať aj vlastnú položku v spúšťači aplikácií pomocou _Install > Gaming > RetroArch Game Launcher_, ktorý vám umožní vybrať si jadro a ROM a skočiť rovno do hry z `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Nainštalujte webovú aplikáciu Xbox Cloud Gaming výberom _Install > Gaming > Xbox Cloud Gaming_ z ponuky Omarchy (`Super + Space`). Je to „len“ webová aplikácia pre túto službu, ale rýchlo sa spúšťa a skvele beží v rozlíšení 1080p.

Ak už máte Xbox Game Pass, je to solídny spôsob, ako hrať Fortnite a ďalšie tituly, ktoré na Linuxe natívne nespustíte.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Nainštalujte cloudovú hernú službu [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) výberom _Install > Gaming > NVIDIA GeForce NOW_ z ponuky Omarchy (`Super + Space`). Ďalší skvelý spôsob, ako hrať tituly, ktoré na Linuxe nie sú dostupné natívne.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Nainštalujte Minecraft výberom _Install > Gaming > Minecraft_ z ponuky Omarchy (`Super + Space`).

Rovnako ako pri Steame upozorňujeme, že po prihlásení alebo spustení môže chvíľu trvať, kým sa zobrazí ďalšia obrazovka, a počas čakania nebudete mať žiadnu spätnú väzbu.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Ovládače Xbox

Nainštalujte podporu pre Bluetooth ovládače Xbox výberom _Install > Gaming > Xbox Controllers_ z ponuky Omarchy (`Super + Space`). Ovládače spárujte cez Bluetooth (`Super + Ctrl + B`) a budú fungovať vo všetkých vašich hrách. Toto nepotrebujete, ak ovládač pripájate len napevno káblom USB-C.

## Moonlight (Streamovanie hier z PC)

Nainštalujte [klienta Moonlight](https://github.com/moonlight-stream/moonlight-qt) výberom _Install > Gaming > Moonlight_ z ponuky Omarchy (`Super + Space`) a môžete streamovať hry z PC so systémom Windows, na ktorom beží [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Ak sú váš počítač s Omarchy aj vzdialený herný PC pripojené káblom, zážitok je na nerozoznanie od lokálneho hrania. Zvýšte rozlíšenie na natívne, nastavte obnovovaciu frekvenciu na 120Hz a bitrate na maximum — toto je najlepší spôsob, ako hrať kompetitívne strieľačky ako Fortnite na Linuxe.

Počítač s Omarchy môžete premeniť aj na hostiteľa spustením `omarchy install service sunshine`, čím sa nainštaluje Sunshine a otvoria sa streamovacie porty Moonlight pre vašu LAN a Tailscale.

## Battle.net

Nainštalujte [Battle.net](https://eu.shop.battle.net/en-us) výberom _Install > Gaming > Battle.net_ z ponuky Omarchy (`Super + Space`). Získate tak tituly ako Diablo, Starcraft a World of Warcraft ako samostatnú inštaláciu bežiacu pod GE-Proton — bez potreby Steamu, Lutrisu alebo Heroicu.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Hry pre Windows)

Nainštalujte [Lutris](https://lutris.net/) výberom _Install > Gaming > Lutris_ z ponuky Omarchy (`Super + Space`). Lutris je spôsob, ako hrať hry pre Windows z obchodov ako EA a Ubisoft Connect, ktoré vyššie nemajú vlastný inštalátor.

Inštalácia je trochu kostrbatá a občas to vyzerá, že sa nič nedeje — len buďte trpezliví, na pozadí to pracuje.

## Heroic Launcher (Epic Games)

Nainštalujte [Heroic Launcher](https://heroicgameslauncher.com/) výberom _Install > Gaming > Heroic (Epic Games)_ z ponuky Omarchy (`Super + Space`). Heroic vám umožní spúšťať tituly z Epic Games, ako napríklad OddSparks, ktoré sa nespoliehajú na anti-cheat — plus hry z GOG a Amazon Prime Gaming. Bohužiaľ to znamená žiadny Fortnite a žiadne Rocket League — kým Tim Sweeney nepríde na Linux, bližšie sa k tomu nedostanete.

Rovnako ako Lutris môže pri inštalácii hier pôsobiť pomaly a kostrbato. Dajte mu čas.
