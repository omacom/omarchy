# Granie

Omarchy nie służy tylko do _pRoDUkTyWnOśCi_, służy też do zabawy, a co jest zabawniejsze niż granie? Omarchy jest dostarczane z całym zestawem opcji do grania — Steam i RetroArch do grania natywnego i retro, Battle.net, Lutris i Heroic do sklepów spoza Steam, Moonlight do streamowania z PC, Xbox Cloud Gaming + NVIDIA GeForce NOW do chmury, plus wiecznie żywy Minecraft.

Dzięki niesamowitej pracy Valve nad [warstwą zgodności Proton](https://en.wikipedia.org/wiki/Proton_(software)) na Linuksie można teraz grać w dziesiątki tysięcy nowoczesnych gier. Aha, i czy wiesz, że [Steam Deck](https://store.steampowered.com/steamdeck/) tak naprawdę działa na Arch!

Wszystkie instalatory do grania znajdują się w sekcji _Install > Gaming_ w menu Omarchy (`Super + Space`). Jeśli kiedykolwiek zechcesz któryś cofnąć, użyj _Remove > Gaming_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris i Heroic są oferowane wyłącznie na maszynach x86.

## Steam

Zainstaluj [Steam](https://store.steampowered.com/), wybierając _Install > Gaming > Steam_ w menu Omarchy (`Super + Space`).

Po zainstalowaniu będziesz mógł uruchamiać Steam za pomocą `Super + Space`.

Pamiętaj, że uruchomienie Steam może zająć 10-20 sekund i nie zobaczysz żadnej wizualnej informacji zwrotnej, że się ładuje.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Zainstaluj [RetroArch](https://www.retroarch.com/), wybierając _Install > Gaming > RetroArch_ w menu Omarchy (`Super + Space`). Jest dostarczany z pełnym zestawem rdzeni libretro, więc wszystkie klasyczne systemy są obsłużone.

RetroArch jest w pełni wstępnie skonfigurowany z pięknym shaderem CRT Royale, zapewniającym idealny wygląd retro.

Aby zacząć:

1. Wrzuć pliki BIOS do `~/Games/bios`, a ROM-y do `~/Games/roms`.
2. Uruchom RetroArch za pomocą `Super + Space` i wpisania `retro`.
3. Przeskanuj katalog `~/Games/roms` i możesz grać.

Możesz też nadać ulubionej grze osobny wpis w programie uruchamiającym aplikacje za pomocą _Install > Gaming > RetroArch Game Launcher_, który pozwala wybrać rdzeń i ROM oraz wskoczyć prosto do gry z `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Zainstaluj aplikację internetową Xbox Cloud Gaming, wybierając _Install > Gaming > Xbox Cloud Gaming_ w menu Omarchy (`Super + Space`). To „tylko” aplikacja internetowa tej usługi, ale szybko się uruchamia i świetnie działa w 1080p.

Jeśli masz już Xbox Game Pass, to solidny sposób na granie w Fortnite i inne tytuły, których nie da się uruchomić natywnie na Linuksie.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Zainstaluj usługę grania w chmurze [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), wybierając _Install > Gaming > NVIDIA GeForce NOW_ w menu Omarchy (`Super + Space`). Kolejny świetny sposób na granie w tytuły, które nie są dostępne natywnie na Linuksie.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Zainstaluj Minecraft, wybierając _Install > Gaming > Minecraft_ w menu Omarchy (`Super + Space`).

Podobnie jak w przypadku Steam pamiętaj, że po zalogowaniu lub uruchomieniu pojawienie się kolejnego ekranu może chwilę potrwać i podczas oczekiwania nie zobaczysz żadnej informacji zwrotnej.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Kontrolery Xbox

Zainstaluj obsługę kontrolerów Xbox Bluetooth, wybierając _Install > Gaming > Xbox Controllers_ w menu Omarchy (`Super + Space`). Sparuj kontrolery przez Bluetooth (`Super + Ctrl + B`) i będą działać we wszystkich Twoich grach. Nie potrzebujesz tego, jeśli po prostu podłączasz kontroler przewodowo kablem USB-C.

## Moonlight (streamowanie gier z PC)

Zainstaluj [klienta Moonlight](https://github.com/moonlight-stream/moonlight-qt), wybierając _Install > Gaming > Moonlight_ w menu Omarchy (`Super + Space`), a będziesz mógł streamować gry z komputera z Windows z uruchomionym [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Jeśli zarówno Twoja maszyna z Omarchy, jak i zdalny komputer do grania są podłączone przewodowo, doświadczenie jest nie do odróżnienia od grania lokalnie. Podnieś rozdzielczość do natywnej, ustaw odświeżanie na 120Hz i maksymalną przepływność — to najlepszy sposób na granie w konkurencyjne strzelanki, takie jak Fortnite, na Linuksie.

Możesz też zamienić maszynę z Omarchy w hosta, uruchamiając `omarchy install service sunshine`, co instaluje Sunshine i otwiera porty streamowania Moonlight dla Twojej sieci LAN i Tailscale.

## Battle.net

Zainstaluj [Battle.net](https://eu.shop.battle.net/en-us), wybierając _Install > Gaming > Battle.net_ w menu Omarchy (`Super + Space`). Daje Ci to tytuły takie jak Diablo, Starcraft i World of Warcraft jako samodzielną instalację działającą pod GE-Proton — bez potrzeby Steam, Lutris ani Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (gry z Windows)

Zainstaluj [Lutris](https://lutris.net/), wybierając _Install > Gaming > Lutris_ w menu Omarchy (`Super + Space`). Lutris to sposób na granie w gry z Windows ze sklepów takich jak EA i Ubisoft Connect, które nie mają powyżej własnego instalatora.

Instalacja jest trochę toporna i czasem wygląda, jakby nic się nie działo — po prostu bądź cierpliwy, działa w tle.

## Heroic Launcher (Epic Games)

Zainstaluj [Heroic Launcher](https://heroicgameslauncher.com/), wybierając _Install > Gaming > Heroic (Epic Games)_ w menu Omarchy (`Super + Space`). Heroic pozwala uruchamiać tytuły z Epic Games, takie jak OddSparks, które nie polegają na anti-cheat — plus gry z GOG i Amazon Prime Gaming. Niestety oznacza to brak Fortnite i brak Rocket League — dopóki Tim Sweeney nie przyjdzie na Linuksa, bliżej się nie da.

Podobnie jak Lutris, podczas instalowania gier może sprawiać wrażenie wolnego i topornego. Daj mu czas.
