# 游戏

Omarchy 不仅仅是为了 _pRoDUcTiVItY_，它也是为了娱乐，而有什么比游戏更快乐呢？Omarchy 自带一整套游戏选项——Steam 和 RetroArch 用于原生和复古游戏，Battle.net、Lutris 和 Heroic 用于非 Steam 商店，Moonlight 用于 PC 流式传输，Xbox Cloud Gaming + NVIDIA GeForce NOW 用于云游戏，还有常青的 Minecraft。

得益于 Valve 在[proton 兼容层](https://en.wikipedia.org/wiki/Proton_(software))上的出色工作，现在 Linux 上有数以万计的现代可玩游戏。哦，你知道 [Steam Deck](https://store.steampowered.com/steamdeck/) 实际上运行的是 Arch 吗！

所有游戏安装程序都位于 Omarchy 菜单（`Super + Space`）的 _Install > Gaming_ 下。如果你想撤销其中一个，使用 _Remove > Gaming_。

## Steam

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > Steam_ 来安装 [Steam](https://store.steampowered.com/)。

安装后，你将能够用 `Super + Space` 启动 Steam。

注意，Steam 启动可能需要 10-20 秒，而且它不会提供它正在加载的任何视觉反馈。

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > RetroArch_ 来安装 [RetroArch](https://www.retroarch.com/)。它附带了全套 libretro 核心，所以所有经典系统都有覆盖。

RetroArch 已使用美丽的 CRT Royale 着色器完全预配置，以实现完美的复古外观。

开始步骤：

1. 将你的 BIOS 文件放入 `~/Games/bios`，将你的 ROM 放入 `~/Games/roms`。
2. 使用 `Super + Space` 并输入 `retro` 启动 RetroArch。
3. 扫描 `~/Games/roms` 目录，你就可以玩了。

你也可以用 _Install > Gaming > RetroArch Game Launcher_ 为最喜欢的游戏在应用程序启动器中给它自己的入口，它让你选择一个核心和一个 ROM，并直接从 `Super + Space` 跳入游戏。

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > Xbox Cloud Gaming_ 来安装 Xbox Cloud Gaming 网页应用。它“只是”该服务的一个网页应用，但启动很快，并且在 1080p 下运行得很好。

如果你已经有 Xbox Game Pass，这是玩 Fortnite 和其他无法在 Linux 上原生运行的游戏的坚实方式。

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > NVIDIA GeForce NOW_ 来安装云游戏服务 [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/)。这是玩在 Linux 上无法原生运行的游戏的另一绝佳方式。

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > Minecraft_ 来安装 Minecraft。

和 Steam 一样，注意登录或启动后，下一个画面可能需要一段时间才会出现，而且你在等待期间不会收到任何反馈。

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox 控制器

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > Xbox Controllers_ 来安装对蓝牙 Xbox 控制器的支持。通过蓝牙（`Super + Ctrl + B`）配对控制器，它们将在你所有的游戏中工作。如果你只是用 USB-C 线缆硬连控制器，你不需要这个。

## Moonlight（从 PC 流式传输游戏）

[Moonlight 客户端](https://github.com/moonlight-stream/moonlight-qt) 与 Omarchy 预装，所以你可以立即从运行 [Sunshine](https://app.lizardbyte.dev/Sunshine/) 的 Windows PC 流式传输游戏。通过 `Super + Space` 启动 Moonlight。

如果你的 Omarchy 机器和远程游戏 PC 都有线连接，体验与本地玩没有区别。将分辨率调到原生，将刷新率设为 120Hz，并将码率调到最大——这是在 Linux 上玩 Fortnite 等竞技射击游戏的最佳方式。

你也可以通过运行 `omarchy install service sunshine` 将 Omarchy 机器变成主机，它会安装 Sunshine 并为你的 LAN 和 Tailscale 打开 Moonlight 流式传输端口。

## Battle.net

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > Battle.net_ 来安装 [Battle.net](https://eu.shop.battle.net/en-us)。这为你提供像 Diablo、Starcraft 和 World of Warcraft 这样的游戏，作为运行在 GE-Proton 下的独立安装——无需 Steam、Lutris 或 Heroic。

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris（Windows 游戏）

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > Lutris_ 来安装 [Lutris](https://lutris.net/)。Lutris 是玩来自 EA 和 Ubisoft Connect 等上面没有自己安装程序的商店的 Windows 游戏的方式。

安装有点粗糙，有时看起来好像什么都没发生——耐心点，它在后台工作。

## Heroic Launcher（Epic Games）

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > Heroic (Epic Games)_ 来安装 [Heroic Launcher](https://heroicgameslauncher.com/)。Heroic 让你运行不依赖反作弊的 Epic Games 游戏，如 OddSparks——再加上来自 GOG 和 Amazon Prime Gaming 的游戏。可悲的是，这意味着没有 Fortnite 也没有 Rocket League——在 Tim Sweeney 来到 Linux 之前，这已经是最近的了。

像 Lutris 一样，它在安装游戏时可能会感觉缓慢且粗糙。给它时间。
