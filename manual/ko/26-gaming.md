# 게이밍

Omarchy는 _생산성_만을 위한 것이 아닙니다. 즐기기 위한 것이기도 한데, 게이밍보다 더 재미있는 게 뭐가 있겠습니까? Omarchy에는 게이밍 옵션 전체 제품군이 기본으로 들어 있습니다 — 네이티브와 레트로 플레이를 위한 Steam과 RetroArch, Steam이 아닌 스토어를 위한 Battle.net, Lutris, Heroic, PC 스트리밍을 위한 Moonlight, 클라우드를 위한 Xbox Cloud Gaming + NVIDIA GeForce NOW, 그리고 변함없이 사랑받는 Minecraft까지 있습니다.

Valve가 [Proton 호환성 레이어](https://en.wikipedia.org/wiki/Proton_(software))에 기울인 놀라운 작업 덕분에, 이제 Linux에서 플레이할 수 있는 현대적인 게임이 수만 개에 달합니다. 아, 그리고 [Steam Deck](https://store.steampowered.com/steamdeck/)이 실제로 Arch를 실행한다는 사실, 알고 계셨습니까!

모든 게이밍 설치 프로그램은 Omarchy 메뉴(`Super + Space`)의 _설치 > 게이밍_ 아래에 있습니다. 나중에 하나라도 되돌리고 싶다면 _제거 > 게이밍_을 사용하세요. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris, Heroic은 x86 컴퓨터에서만 제공됩니다.

## Steam

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > Steam_을 선택해 [Steam](https://store.steampowered.com/)을 설치하세요.

설치가 끝나면 `Super + Space`로 Steam을 실행할 수 있습니다.

Steam은 시작하는 데 10-20초가 걸릴 수 있으며, 로딩 중이라는 시각적인 피드백은 전혀 제공하지 않는다는 점에 유의하세요.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > RetroArch_를 선택해 [RetroArch](https://www.retroarch.com/)를 설치하세요. libretro 코어 전체 세트가 함께 제공되므로 모든 고전 시스템을 다룰 수 있습니다.

RetroArch는 완벽한 레트로 분위기를 위한 아름다운 CRT Royale 셰이더로 완전히 사전 구성되어 있습니다.

시작하는 방법:

1. BIOS 파일을 `~/Games/bios`에, ROM을 `~/Games/roms`에 넣으세요.
2. `Super + Space`로 RetroArch를 실행하고 `retro`를 입력하세요.
3. `~/Games/roms` 디렉터리를 스캔하면 바로 플레이할 수 있습니다.

좋아하는 게임에 앱 런처의 전용 항목을 만들 수도 있습니다. _설치 > 게이밍 > RetroArch Game Launcher_를 사용하면 코어와 ROM을 선택해 `Super + Space`에서 게임으로 바로 뛰어들 수 있습니다.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > Xbox Cloud Gaming_을 선택해 Xbox Cloud Gaming 웹 앱을 설치하세요. 이 서비스용 "그냥" 웹 앱일 뿐이지만, 시작이 빠르고 1080p에서 아주 잘 실행됩니다.

이미 Xbox Game Pass를 가지고 있다면, Fortnite나 Linux에서 네이티브로 실행할 수 없는 다른 타이틀을 플레이하기에 든든한 방법입니다.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > NVIDIA GeForce NOW_를 선택해 클라우드 게이밍 서비스 [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/)를 설치하세요. Linux에서 네이티브로 이용할 수 없는 타이틀을 플레이하는 또 다른 훌륭한 방법입니다.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > Minecraft_를 선택해 Minecraft를 설치하세요.

Steam과 마찬가지로, 로그인하거나 시작한 뒤 다음 화면이 나타날 때까지 시간이 걸릴 수 있으며, 기다리는 동안 어떤 피드백도 제공되지 않는다는 점에 유의하세요.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > Xbox Controllers_를 선택해 Bluetooth Xbox 컨트롤러 지원을 설치하세요. Bluetooth(`Super + Ctrl + B`)로 컨트롤러를 페어링하면 모든 게임에서 작동합니다. USB-C 케이블로 컨트롤러를 유선으로 연결만 한다면 이 작업은 필요하지 않습니다.

## Moonlight (PC에서 게임 스트리밍)

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > Moonlight_를 선택해 [Moonlight 클라이언트](https://github.com/moonlight-stream/moonlight-qt)를 설치하면, [Sunshine](https://app.lizardbyte.dev/Sunshine/)을 실행 중인 Windows PC에서 게임을 스트리밍할 수 있습니다.

Omarchy 컴퓨터와 원격 게이밍 PC가 모두 유선으로 연결되어 있다면, 그 경험은 로컬에서 플레이하는 것과 구분할 수 없을 정도입니다. 해상도를 네이티브까지 올리고, 주사율을 120Hz로 설정하고, 비트레이트를 최대로 높이세요 — 이것이 Linux에서 Fortnite 같은 경쟁 슈팅 게임을 플레이하는 최고의 방법입니다.

`omarchy install service sunshine`을 실행해 Omarchy 컴퓨터를 호스트로 만들 수도 있습니다. 이렇게 하면 Sunshine이 설치되고 LAN과 Tailscale용 Moonlight 스트리밍 포트가 열립니다.

## Battle.net

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > Battle.net_을 선택해 [Battle.net](https://eu.shop.battle.net/en-us)을 설치하세요. 이를 통해 Diablo, Starcraft, World of Warcraft 같은 타이틀을 GE-Proton 아래에서 실행되는 독립 설치로 이용할 수 있습니다 — Steam, Lutris, Heroic이 필요 없습니다.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows 게임)

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > Lutris_를 선택해 [Lutris](https://lutris.net/)를 설치하세요. Lutris는 위에 자체 설치 프로그램이 없는 EA나 Ubisoft Connect 같은 스토어의 Windows 게임을 플레이하는 방법입니다.

설치가 다소 매끄럽지 못하고, 때로는 아무 일도 일어나지 않는 것처럼 보입니다 — 그냥 인내심을 가지세요. 백그라운드에서 작업이 진행되고 있습니다.

## Heroic Launcher (Epic Games)

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > Heroic (Epic Games)_을 선택해 [Heroic Launcher](https://heroicgameslauncher.com/)를 설치하세요. Heroic을 사용하면 안티치트에 의존하지 않는 OddSparks 같은 Epic Games 타이틀은 물론, GOG와 Amazon Prime Gaming의 게임도 실행할 수 있습니다. 안타깝게도 Fortnite도, Rocket League도 안 된다는 뜻입니다 — Tim Sweeney가 Linux로 넘어오기 전까지는 이게 최선입니다.

Lutris와 마찬가지로, 게임을 설치하는 동안 느리고 매끄럽지 못하게 느껴질 수 있습니다. 시간을 주세요.
