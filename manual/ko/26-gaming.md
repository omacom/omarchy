# 게이밍

Omarchy는 _pRoDUcTiVItY_만을 위한 것이 아닙니다. 즐기기 위한 것이기도 한데, 게임보다 재미있는 게 어디 있겠습니까? Omarchy에는 게이밍 옵션 한 세트가 통째로 들어 있습니다 — 네이티브 및 레트로 플레이를 위한 Steam과 RetroArch, Steam이 아닌 스토어를 위한 Battle.net, Lutris, Heroic, PC 스트리밍을 위한 Moonlight, 클라우드를 위한 Xbox Cloud Gaming + NVIDIA GeForce NOW, 그리고 영원한 Minecraft까지.

Valve가 [Proton 호환성 계층](https://en.wikipedia.org/wiki/Proton_(software))에 쏟아부은 놀라운 작업 덕분에, 이제 Linux에서 플레이할 수 있는 최신 게임이 수만 개에 달합니다. 아, 그리고 [Steam Deck](https://store.steampowered.com/steamdeck/)이 실제로 Arch를 실행한다는 사실, 알고 계셨나요!

모든 게임 설치 프로그램은 Omarchy 메뉴(`Super + Space`)의 _Install > Gaming_ 아래에 있습니다. 나중에 되돌리고 싶으면 _Remove > Gaming_을 사용하세요.

## Steam

Omarchy 메뉴(`Super + Space`)에서 _Install > Gaming > Steam_을 선택해 [Steam](https://store.steampowered.com/)을 설치하세요.

설치가 끝나면 `Super + Space`로 Steam을 실행할 수 있습니다.

Steam은 시작하는 데 10-20초가 걸릴 수 있으며, 로딩 중이라는 시각적 피드백은 전혀 제공하지 않는다는 점에 유의하세요.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Omarchy 메뉴(`Super + Space`)에서 _Install > Gaming > RetroArch_를 선택해 [RetroArch](https://www.retroarch.com/)를 설치하세요. libretro 코어 전체 세트가 함께 제공되므로 모든 고전 시스템이 지원됩니다.

RetroArch는 완벽한 레트로 룩을 위한 아름다운 CRT Royale 셰이더로 완전히 사전 구성되어 있습니다.

시작하려면:

1. BIOS 파일을 `~/Games/bios`에, ROM을 `~/Games/roms`에 넣으세요.
2. `Super + Space`로 RetroArch를 실행하고 `retro`를 입력하세요.
3. `~/Games/roms` 디렉터리를 스캔하면 플레이할 준비가 끝납니다.

좋아하는 게임에 앱 런처에서 자체 항목을 부여할 수도 있습니다. _Install > Gaming > RetroArch Game Launcher_를 사용하면 코어와 ROM을 선택하고 `Super + Space`에서 바로 게임으로 뛰어들 수 있습니다.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Omarchy 메뉴(`Super + Space`)에서 _Install > Gaming > Xbox Cloud Gaming_을 선택해 Xbox Cloud Gaming 웹 앱을 설치하세요. 이 서비스용 "그냥" 웹 앱일 뿐이지만, 시작이 빠르고 1080p에서 훌륭하게 실행됩니다.

이미 Xbox Game Pass가 있다면, Linux에서 네이티브로 실행할 수 없는 Fortnite와 다른 타이틀을 플레이하기에 탄탄한 방법입니다.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Omarchy 메뉴(`Super + Space`)에서 _Install > Gaming > NVIDIA GeForce NOW_를 선택해 클라우드 게이밍 서비스 [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/)를 설치하세요. Linux에서 네이티브로 이용할 수 없는 타이틀을 플레이하는 또 다른 훌륭한 방법입니다.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Omarchy 메뉴(`Super + Space`)에서 _Install > Gaming > Minecraft_를 선택해 Minecraft를 설치하세요.

Steam과 마찬가지로, 로그인하거나 시작한 후 다음 화면이 나타날 때까지 시간이 한참 걸릴 수 있으며, 기다리는 동안 아무런 피드백도 받지 못한다는 점에 유의하세요.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox 컨트롤러

Omarchy 메뉴(`Super + Space`)에서 _Install > Gaming > Xbox Controllers_를 선택해 Bluetooth Xbox 컨트롤러 지원을 설치하세요. Bluetooth(`Super + Ctrl + B`)를 통해 컨트롤러를 페어링하면 모든 게임에서 작동합니다. USB-C 케이블로 컨트롤러를 유선 연결만 할 거라면 이 작업은 필요 없습니다.

## Moonlight (PC에서 게임 스트리밍)

Omarchy 메뉴(`Super + Space`)에서 _Install > Gaming > Moonlight_를 선택해 [Moonlight 클라이언트](https://github.com/moonlight-stream/moonlight-qt)를 설치하면, [Sunshine](https://app.lizardbyte.dev/Sunshine/)을 실행하는 Windows PC에서 게임을 스트리밍할 수 있습니다.

Omarchy 머신과 원격 게이밍 PC가 모두 유선으로 연결되어 있다면, 그 경험은 로컬에서 플레이하는 것과 구별할 수 없습니다. 해상도를 네이티브까지 올리고, 주사율을 120Hz로 설정하고, 비트레이트를 최대로 높이세요 — 이것이 Linux에서 Fortnite 같은 경쟁 슈팅 게임을 플레이하는 최고의 방법입니다.

`omarchy install service sunshine`을 실행해 Omarchy 머신을 호스트로 만들 수도 있습니다. 이 명령은 Sunshine을 설치하고 LAN과 Tailscale용 Moonlight 스트리밍 포트를 엽니다.

## Battle.net

Omarchy 메뉴(`Super + Space`)에서 _Install > Gaming > Battle.net_을 선택해 [Battle.net](https://eu.shop.battle.net/en-us)을 설치하세요. 이를 통해 Diablo, Starcraft, World of Warcraft 같은 타이틀을 GE-Proton으로 실행되는 독립 설치로 이용할 수 있습니다 — Steam, Lutris, Heroic이 필요 없습니다.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows 게임)

Omarchy 메뉴(`Super + Space`)에서 _Install > Gaming > Lutris_를 선택해 [Lutris](https://lutris.net/)를 설치하세요. Lutris는 위에 자체 설치 프로그램이 없는 EA와 Ubisoft Connect 같은 스토어의 Windows 게임을 플레이하는 방법입니다.

설치는 약간 투박하고 가끔 아무 일도 일어나지 않는 것처럼 보입니다 — 그냥 인내심을 가지세요. 백그라운드에서 작동하고 있습니다.

## Heroic Launcher (Epic Games)

Omarchy 메뉴(`Super + Space`)에서 _Install > Gaming > Heroic (Epic Games)_를 선택해 [Heroic Launcher](https://heroicgameslauncher.com/)를 설치하세요. Heroic을 사용하면 안티치트에 의존하지 않는 OddSparks 같은 Epic Games 타이틀과, GOG와 Amazon Prime Gaming의 게임을 실행할 수 있습니다. 안타깝게도 이는 Fortnite도, Rocket League도 안 된다는 뜻입니다 — Tim Sweeney가 Linux로 올 때까지는 이게 최선입니다.

Lutris와 마찬가지로, 게임을 설치하는 동안 느리고 투박하게 느껴질 수 있습니다. 시간을 주세요.
