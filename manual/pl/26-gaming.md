# Gry

Omarchy nie jest tylko do _pRoDUkTyWnOśCi_, jest też do zabawy, a co jest zabawniejsze niż granie? Omarchy jest dostarczane z całym zestawem opcji do grania — Steam i RetroArch do gry natywnej i retro, Battle.net, Lutris i Heroic do sklepów innych niż Steam, Moonlight do streamingu z PC, Xbox Cloud Gaming + NVIDIA GeForce NOW do chmury, plus wiecznie żywy Minecraft.

Dzięki niesamowitej pracy Valve nad [warstwą kompatybilności Proton](https://en.wikipedia.org/wiki/Proton_(software)) na Linuxie dostępnych jest teraz dziesiątki tysięcy grywalnych nowoczesnych gier. A, i czy wiedziałeś, że [Steam Deck](https://store.steampowered.com/steamdeck/) tak naprawdę działa na Arch!

Wszystkie instalatory gier znajdują się w _Install > Gaming_ w menu Omarchy (`Super + Space`). Jeśli kiedykolwiek będziesz chciał któryś z nich cofnąć, użyj _Remove > Gaming_.

## Steam

Zainstaluj [Steam](https://store.steampowered.com/), wybierając _Install > Gaming > Steam_ z menu Omarchy (`Super + Space`).

Po zainstalowaniu będziesz mógł uruchomić Steam za pomocą `Super + Space`.

Pamiętaj, że Steam może uruchamiać się 10-20 sekund i nie będzie dawał żadnej wizualnej informacji zwrotnej, że się ładuje.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Zainstaluj [RetroArch](https://www.retroarch.com/), wybierając _Install > Gaming > RetroArch_ z menu Omarchy (`Super + Space`). Jest dostarczany z pełnym zestawem rdzeni libretro, więc wszystkie klasyczne systemy są obsłużone.

RetroArch jest w pełni wstępnie skonfigurowany z pięknym shaderem CRT Royale, który zapewnia ten idealny retro wygląd.

Aby zacząć:

1. Wrzuć pliki BIOS do `~/Games/bios`, a ROM-y do `~/Games/roms`.
2. Uruchom RetroArch za pomocą `Super + Space` i wpisując `retro`.
3. Przeskanuj katalog `~/Games/roms` i jesteś gotowy do gry.

Możesz też nadać ulubionej grze własny wpis w programie uruchamiającym aplikacje za pomocą _Install > Gaming > RetroArch Game Launcher_, który pozwala wybrać rdzeń i ROM oraz wskoczyć prosto do gry z `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Zainstaluj aplikację internetową Xbox Cloud Gaming, wybierając _Install > Gaming > Xbox Cloud Gaming_ z menu Omarchy (`Super + Space`). To „tylko” aplikacja internetowa tej usługi, ale szybko się uruchamia i świetnie działa w 1080p.

Jeśli masz już Xbox Game Pass, to solidny sposób na granie w Fortnite i inne tytuły, których nie da się uruchomić natywnie na Linuxie.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Zainstaluj usługę grania w chmurze [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), wybierając _Install > Gaming > NVIDIA GeForce NOW_ z menu Omarchy (`Super + Space`). Kolejny świetny sposób na granie w tytuły, które nie są dostępne natywnie na Linuxie.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Zainstaluj Minecraft, wybierając _Install > Gaming > Minecraft_ z menu Omarchy (`Super + Space`).

Podobnie jak w przypadku Steam, pamiętaj, że po zalogowaniu lub uruchomieniu może minąć trochę czasu, zanim pojawi się następny ekran, i nie dostaniesz żadnej informacji zwrotnej, gdy będziesz czekać.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Kontrolery Xbox

Zainstaluj obsługę kontrolerów Xbox Bluetooth, wybierając _Install > Gaming > Xbox Controllers_ z menu Omarchy (`Super + Space`). Sparuj kontrolery przez Bluetooth (`Super + Ctrl + B`), a będą działać we wszystkich grach. Nie potrzebujesz tego, jeśli po prostu podłączasz kontroler kablem USB-C.

## Moonlight (streaming gier z PC)

Zainstaluj [klienta Moonlight](https://github.com/moonlight-stream/moonlight-qt), wybierając _Install > Gaming > Moonlight_ z menu Omarchy (`Super + Space`), a będziesz mógł streamować gry z komputera z Windows, na którym działa [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Jeśli zarówno Twoja maszyna z Omarchy, jak i zdalny komputer do gier są podłączone przewodowo, wrażenia są nie do odróżnienia od grania lokalnie. Podnieś rozdzielczość do natywnej, ustaw odświeżanie na 120Hz i ustaw maksymalny bitrate — to najlepszy sposób na granie w rywalizacyjne strzelanki, takie jak Fortnite, na Linuxie.

Możesz też zamienić maszynę z Omarchy w hosta, uruchamiając `omarchy install service sunshine`, co zainstaluje Sunshine i otworzy porty streamingu Moonlight dla Twojej sieci LAN i Tailscale.

## Battle.net

Zainstaluj [Battle.net](https://eu.shop.battle.net/en-us), wybierając _Install > Gaming > Battle.net_ z menu Omarchy (`Super + Space`). Daje Ci to tytuły takie jak Diablo, Starcraft i World of Warcraft jako samodzielną instalację działającą pod GE-Proton — bez potrzeby Steam, Lutris czy Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (gry z Windows)

Zainstaluj [Lutris](https://lutris.net/), wybierając _Install > Gaming > Lutris_ z menu Omarchy (`Super + Space`). Lutris to sposób na granie w gry z Windows ze sklepów takich jak EA i Ubisoft Connect, które nie mają powyżej własnego instalatora.

Instalacja jest trochę toporna i czasami wygląda, jakby nic się nie działo — po prostu bądź cierpliwy, działa w tle.

## Heroic Launcher (Epic Games)

Zainstaluj [Heroic Launcher](https://heroicgameslauncher.com/), wybierając _Install > Gaming > Heroic (Epic Games)_ z menu Omarchy (`Super + Space`). Heroic pozwala uruchamiać tytuły Epic Games, takie jak OddSparks, które nie polegają na anti-cheat — plus gry z GOG i Amazon Prime Gaming. Niestety oznacza to brak Fortnite i brak Rocket League — dopóki Tim Sweeney nie zawita na Linuxa, to najbliżej, jak się da.

Podobnie jak Lutris, podczas instalowania gier może sprawiać wrażenie powolnego i topornego. Daj mu czas.
