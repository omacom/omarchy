# 游戏

Omarchy 不只是为了 _pRoDUcTiVItY_，也是为了玩乐，还有什么比游戏更快乐呢？Omarchy 自带一整套游戏选项——Steam 和 RetroArch 用于原生和复古游戏，Battle.net、Lutris 和 Heroic 用于非 Steam 商店，Moonlight 用于 PC 串流，Xbox Cloud Gaming + NVIDIA GeForce NOW 用于云游戏，还有常青的 Minecraft。

多亏了 Valve 在 [proton 兼容层](https://en.wikipedia.org/wiki/Proton_(software)) 上的出色工作，现在 Linux 上有数以万计可玩的现代游戏。哦，你知道吗，[Steam Deck](https://store.steampowered.com/steamdeck/) 实际上运行的是 Arch！

所有游戏安装程序都位于 Omarchy 菜单（`Super + Space`）的 _Install > Gaming_ 下。如果你想撤销某次安装，请使用 _Remove > Gaming_。

## Steam

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > Steam_ 来安装 [Steam](https://store.steampowered.com/)。

安装完成后，你将能够用 `Super + Space` 启动 Steam。

请注意，Steam 启动可能需要 10-20 秒，并且它不会提供任何正在加载的视觉反馈。

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > RetroArch_ 来安装 [RetroArch](https://www.retroarch.com/)。它附带完整的 libretro 核心集，所以所有经典系统都涵盖了。

RetroArch 已完全预配置了漂亮的 CRT Royale 着色器，以呈现完美的复古外观。

开始方法：

1. 将你的 BIOS 文件放入 `~/Games/bios`，将你的 ROM 放入 `~/Games/roms`。
2. 用 `Super + Space` 并输入 `retro` 启动 RetroArch。
3. 扫描 `~/Games/roms` 目录，你就可以开始玩了。

你也可以用 _Install > Gaming > RetroArch Game Launcher_ 为喜欢的游戏在应用启动器中创建它自己的条目，它让你选择一个核心和一个 ROM，并直接从 `Super + Space` 进入游戏。

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > Xbox Cloud Gaming_ 来安装 Xbox Cloud Gaming 网页应用。它“只是”该服务的一个网页应用，但启动快，在 1080p 下运行出色。

如果你已经有 Xbox Game Pass，这是玩 Fortnite 和其他无法在 Linux 上原生运行的游戏的好方法。

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > NVIDIA GeForce NOW_ 来安装云游戏服务 [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/)。这是玩那些无法在 Linux 上原生运行的游戏的另一个好方法。

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > Minecraft_ 来安装 Minecraft。

和 Steam 一样，请注意，登录或启动后可能需要一段时间才会出现下一个画面，并且在等待期间你不会得到任何反馈。

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > Xbox Controllers_ 来安装对 Bluetooth Xbox 控制器的支持。通过 Bluetooth（`Super + Ctrl + B`）配对控制器，它们就能在你的所有游戏中工作。如果你只是用 USB-C 线有线连接控制器，就不需要这个。

## Moonlight (Game streaming from a PC)

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > Moonlight_ 来安装 [Moonlight client](https://github.com/moonlight-stream/moonlight-qt)，你就可以从运行 [Sunshine](https://app.lizardbyte.dev/Sunshine/) 的 Windows PC 串流游戏。

如果你的 Omarchy 机器和远程游戏 PC 都是有线连接，体验与在本地玩毫无区别。把分辨率拉到原生，把刷新率设为 120Hz，并把码率拉满——这是在 Linux 上玩 Fortnite 这类竞技射击游戏的最佳方式。

你也可以通过运行 `omarchy install service sunshine` 将一台 Omarchy 机器变成主机，它会安装 Sunshine 并为你的 LAN 和 Tailscale 打开 Moonlight 串流端口。

## Battle.net

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > Battle.net_ 来安装 [Battle.net](https://eu.shop.battle.net/en-us)。这让你以独立安装的方式在 GE-Proton 下运行 Diablo、Starcraft 和 World of Warcraft 等游戏——不需要 Steam、Lutris 或 Heroic。

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows games)

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > Lutris_ 来安装 [Lutris](https://lutris.net/)。Lutris 是玩 EA 和 Ubisoft Connect 等商店的 Windows 游戏的方式，这些商店在上面没有自己的安装程序。

安装过程有点别扭，有时看起来像是什么都没发生——耐心点，它正在后台工作。

## Heroic Launcher (Epic Games)

从 Omarchy 菜单（`Super + Space`）中选择 _Install > Gaming > Heroic (Epic Games)_ 来安装 [Heroic Launcher](https://heroicgameslauncher.com/)。Heroic 让你运行不依赖反作弊的 Epic Games 游戏，比如 OddSparks——外加来自 GOG 和 Amazon Prime Gaming 的游戏。遗憾的是，这意味着不能玩 Fortnite，也不能玩 Rocket League——在 Tim Sweeney 来到 Linux 之前，这已经是最接近的方案了。

和 Lutris 一样，安装游戏时它可能感觉缓慢又卡顿。给它一点时间。
