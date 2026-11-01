# Gry

Omarchy nie służy tylko _pRoDUcTiVItY_, służy też zabawie, a co jest zabawniejsze niż gry? Omarchy dostarcza cały zestaw opcji gamingowych — Steam i RetroArch do gry natywnej i retro, Battle.net, Lutris i Heroic dla sklepów spoza Steam, Moonlight do strumieniowania z PC, Xbox Cloud Gaming + NVIDIA GeForce NOW do chmury, plus wiecznie zielony Minecraft.

Dzięki niesamowitej pracy Valve nad [warstwą kompatybilności Proton](https://en.wikipedia.org/wiki/Proton_(software)), istnieją teraz dziesiątki tysięcy grywalnych nowoczesnych gier na Linuksa. Och, a czy wiesz, że [Steam Deck](https://store.steampowered.com/steamdeck/) tak naprawdę działa na Arch!

Wszystkie instalatory gier żyją w _Instaluj > Gaming_ w menu Omarchy (`Super + Space`). Jeśli kiedykolwiek chcesz cofnąć jeden z nich, użyj _Usuń > Gaming_.

## Steam

Zainstaluj [Steam](https://store.steampowered.com/), wybierając _Instaluj > Gaming > Steam_ z menu Omarchy (`Super + Space`).

Po zainstalowaniu będziesz mógł uruchomić Steam za pomocą `Super + Space`.

Zwróć uwagę, że Steam może potrzebować 10-20 sekund na uruchomienie i nie zapewni żadnej wizualnej informacji zwrotnej, że się ładuje.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Zainstaluj [RetroArch](https://www.retroarch.com/), wybierając _Instaluj > Gaming > RetroArch_ z menu Omarchy (`Super + Space`). Zawiera pełny zestaw rdzeni libretro, więc wszystkie klasyczne systemy są objęte.

RetroArch jest w pełni wstępnie skonfigurowany z pięknym shaderem CRT Royale dla idealnego wyglądu retro.

Aby zacząć:

1. Wrzuć pliki BIOS do `~/Games/bios`, a ROM-y do `~/Games/roms`.
2. Uruchom RetroArch za pomocą `Super + Space` i wpisz `retro`.
3. Przeskanuj katalog `~/Games/roms` i jesteś gotowy do gry.

Możesz również nadać ulubionej grze własny wpis w launcherze aplikacji za pomocą _Instaluj > Gaming > RetroArch Game Launcher_, co pozwala wybrać rdzeń i ROM oraz wskoczyć od razu do gry z `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Zainstaluj aplikację webową Xbox Cloud Gaming, wybierając _Instaluj > Gaming > Xbox Cloud Gaming_ z menu Omarchy (`Super + Space`). To „tylko” aplikacja webowa dla usługi, ale szybko się uruchamia i świetnie działa w 1080p.

Jeśli masz już Xbox Game Pass, jest to solidny sposób na granie w Fortnite i inne tytuły, których nie możesz uruchomić natywnie na Linuksie.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Zainstaluj usługę gier w chmurze [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), wybierając _Instaluj > Gaming > NVIDIA GeForce NOW_ z menu Omarchy (`Super + Space`). Kolejny świetny sposób na granie w tytuły niedostępne natywnie na Linuksie.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Zainstaluj Minecraft, wybierając _Instaluj > Gaming > Minecraft_ z menu Omarchy (`Super + Space`).

Podobnie jak Steam, zwróć uwagę, że po zalogowaniu lub uruchomieniu może upłynąć trochę czasu, zanim pojawi się następny ekran, a podczas oczekiwania nie otrzymasz żadnej informacji zwrotnej.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Kontrolery Xbox

Zainstaluj obsługę kontrolerów Xbox Bluetooth, wybierając _Instaluj > Gaming > Xbox Controllers_ z menu Omarchy (`Super + Space`). Sparuj kontrolery przez Bluetooth (`Super + Ctrl + B`), a będą działać we wszystkich twoich grach. Nie potrzebujesz tego, jeśli po prostu podłączasz kontroler kablem USB-C.

## Moonlight (strumieniowanie gier z PC)

[Klient Moonlight](https://github.com/moonlight-stream/moonlight-qt) jest preinstalowany z Omarchy, więc możesz od razu strumieniować gry z komputera z Windows z uruchomionym [Sunshine](https://app.lizardbyte.dev/Sunshine/). Uruchom Moonlight za pomocą `Super + Space`.

Jeśli zarówno twoja maszyna z Omarchy, jak i zdalny komputer do gier są podłączone kablowo, doświadczenie jest nie do odróżnienia od gry lokalnej. Podkręć rozdzielczość do natywnej, ustaw odświeżanie na 120Hz i maksymalny bitrate — to najlepszy sposób na granie w rywalizacyjne strzelanki, takie jak Fortnite, na Linuksie.

Możesz również zamienić maszynę z Omarchy w hosta, uruchamiając `omarchy install service sunshine`, co instaluje Sunshine i otwiera porty strumieniowania Moonlight dla twojej sieci LAN i Tailscale.

## Battle.net

Zainstaluj [Battle.net](https://eu.shop.battle.net/en-us), wybierając _Instaluj > Gaming > Battle.net_ z menu Omarchy (`Super + Space`). Daje ci to tytuły takie jak Diablo, Starcraft i World of Warcraft jako samodzielną instalację działającą pod GE-Proton — bez potrzeby Steam, Lutris czy Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (gry Windows)

Zainstaluj [Lutris](https://lutris.net/), wybierając _Instaluj > Gaming > Lutris_ z menu Omarchy (`Super + Space`). Lutris to sposób na granie w gry Windows ze sklepów takich jak EA i Ubisoft Connect, które nie mają własnego instalatora powyżej.

Instalacja jest trochę toporna i czasami wygląda, jakby nic się nie działo — po prostu bądź cierpliwy, działa w tle.

## Heroic Launcher (Epic Games)

Zainstaluj [Heroic Launcher](https://heroicgameslauncher.com/), wybierając _Instaluj > Gaming > Heroic (Epic Games)_ z menu Omarchy (`Super + Space`). Heroic pozwala uruchamiać tytuły Epic Games, takie jak OddSparks, które nie polegają na anti-cheat — plus gry z GOG i Amazon Prime Gaming. Niestety oznacza to brak Fortnite i brak Rocket League — dopóki Tim Sweeney nie przyjdzie na Linuksa, to jest tak blisko, jak się da.

Podobnie jak Lutris, może wydawać się wolny i toporny podczas instalowania gier. Daj mu czas.
