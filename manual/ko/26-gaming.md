# 게이밍

Omarchy는 _생산성_만을 위한 것이 아니라 즐거움을 위한 것이기도 합니다. 게이밍보다 더 재미있는 게 뭐가 있을까요? Omarchy에는 게이밍 옵션 전체 제품군이 함께 제공됩니다 — 네이티브 및 레트로 플레이를 위한 Steam과 RetroArch, Steam이 아닌 스토어를 위한 Battle.net, Lutris, Heroic, PC 스트리밍을 위한 Moonlight, 클라우드를 위한 Xbox Cloud Gaming + NVIDIA GeForce NOW, 그리고 언제나 새로워지는 Minecraft까지 포함됩니다.

Valve의 [proton 호환성 레이어](https://en.wikipedia.org/wiki/Proton_(software))에 대한 놀라운 작업 덕분에 이제 Linux에서 플레이 가능한 최신 게임이 수만 개에 달합니다. 아, 그리고 [Steam Deck](https://store.steampowered.com/steamdeck/)이 실제로 Arch를 실행한다는 것을 알고 계셨나요!

모든 게이밍 설치 프로그램은 Omarchy 메뉴(`Super + Space`)의 _설치 > 게이밍_ 아래에 있습니다. 하나를 취소하고 싶다면 _제거 > 게이밍_을 사용하세요.

## Steam

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > Steam_을 선택해 [Steam](https://store.steampowered.com/)을 설치하세요.

설치한 후에는 `Super + Space`로 Steam을 실행할 수 있습니다.

Steam은 시작하는 데 10-20초가 걸릴 수 있으며, 로딩 중이라는 시각적 피드백은 제공하지 않는다는 점에 유의하세요.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > RetroArch_를 선택해 [RetroArch](https://www.retroarch.com/)를 설치하세요. 전체 libretro 코어 세트와 함께 제공되므로 모든 고전 시스템이 커버됩니다.

RetroArch는 완벽한 레트로 룩을 위해 아름다운 CRT Royale 셰이더로 완전히 사전 구성되어 있습니다.

시작하려면:

1. BIOS 파일을 `~/Games/bios`에, ROM을 `~/Games/roms`에 넣으세요.
2. `Super + Space`로 RetroArch를 실행하고 `retro`를 입력하세요.
3. `~/Games/roms` 디렉터리를 스캔하면 플레이할 준비가 됩니다.

_설치 > 게이밍 > RetroArch 게임 실행 프로그램_으로 즐겨찾는 게임에 앱 실행 프로그램 항목을 직접 부여할 수도 있습니다. 코어와 ROM을 선택하고 `Super + Space`에서 게임으로 바로 뛰어들 수 있습니다.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > Xbox Cloud Gaming_을 선택해 Xbox Cloud Gaming 웹 앱을 설치하세요. 해당 서비스를 위한 "그냥" 웹 앱이지만, 빠르게 시작하고 1080p에서 훌륭하게 실행됩니다.

이미 Xbox Game Pass를 가지고 있다면, Linux에서 네이티브로 실행할 수 없는 Fortnite와 기타 타이틀을 플레이하는 확실한 방법입니다.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > NVIDIA GeForce NOW_를 선택해 클라우드 게이밍 서비스 [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/)를 설치하세요. Linux에서 네이티브로 사용할 수 없는 타이틀을 플레이하는 또 다른 좋은 방법입니다.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > Minecraft_를 선택해 Minecraft를 설치하세요.

Steam과 마찬가지로, 로그인이나 시작 후 다음 화면이 나타나기까지 시간이 걸릴 수 있으며, 기다리는 동안 피드백은 제공되지 않는다는 점에 유의하세요.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox 컨트롤러

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > Xbox 컨트롤러_를 선택해 Bluetooth Xbox 컨트롤러 지원을 설치하세요. Bluetooth(`Super + Ctrl + B`)를 통해 컨트롤러를 페어링하면 모든 게임에서 동작합니다. 컨트롤러를 USB-C 케이블로 직접 연결만 한다면 이 기능은 필요 없습니다.

## Moonlight (PC에서 게임 스트리밍)

[Moonlight 클라이언트](https://github.com/moonlight-stream/moonlight-qt)는 Omarchy에 사전 설치되어 있으므로, [Sunshine](https://app.lizardbyte.dev/Sunshine/)을 실행 중인 Windows PC에서 바로 게임을 스트리밍할 수 있습니다. `Super + Space`로 Moonlight를 실행하세요.

Omarchy 컴퓨터와 원격 게이밍 PC가 모두 유선 연결되어 있다면, 경험은 로컬에서 플레이하는 것과 구별할 수 없습니다. 해상도를 네이티브로 높이고, 새로 고침을 120Hz로 설정하고, 비트레이트를 최대로 높이세요 — 이것이 Linux에서 Fortnite 같은 경쟁 슈팅 게임을 플레이하는 최고의 방법입니다.

`omarchy install service sunshine`을 실행해 Omarchy 컴퓨터를 호스트로 만들 수도 있습니다. Sunshine을 설치하고 LAN과 Tailscale용 Moonlight 스트리밍 포트를 엽니다.

## Battle.net

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > Battle.net_을 선택해 [Battle.net](https://eu.shop.battle.net/en-us)을 설치하세요. GE-Proton 아래에서 실행되는 독립 설치로 Diablo, Starcraft, World of Warcraft 같은 타이틀을 제공합니다 — Steam, Lutris, Heroic은 필요 없습니다.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows 게임)

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > Lutris_를 선택해 [Lutris](https://lutris.net/)를 설치하세요. Lutris는 위의 자체 설치 프로그램이 없는 EA, Ubisoft Connect 같은 스토어의 Windows 게임을 플레이하는 방법입니다.

설치가 좀 삐걱거리며, 가끔 아무 일도 일어나지 않는 것처럼 보입니다 — 그냥 기다리세요. 백그라운드에서 동작 중입니다.

## Heroic Launcher (Epic Games)

Omarchy 메뉴(`Super + Space`)에서 _설치 > 게이밍 > Heroic (Epic Games)_을 선택해 [Heroic Launcher](https://heroicgameslauncher.com/)를 설치하세요. Heroic은 OddSparks처럼 안티 치트에 의존하지 않는 Epic Games 타이틀과 GOG, Amazon Prime Gaming의 게임을 실행할 수 있게 해줍니다. 안타깝게도 Fortnite와 Rocket League는 없습니다 — Tim Sweeney가 Linux로 오기 전까지는 이게 최선입니다.

Lutris처럼 게임을 설치하는 동안 느리고 삐걱거리는 느낌이 들 수 있습니다. 시간을 주세요.
