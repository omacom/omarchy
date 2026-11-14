# 遊戲

Omarchy 不只是為了 _pRoDUcTiVItY_，也是為了好玩，還有什麼比玩遊戲更好玩？Omarchy 內建一整套遊戲選項 — Steam 和 RetroArch 供原生與復古遊戲、Battle.net、Lutris 和 Heroic 供非 Steam 商店、Moonlight 供 PC 串流、Xbox Cloud Gaming + NVIDIA GeForce NOW 供雲端遊戲，還有萬年不敗的 Minecraft。

感謝 Valve 在 [Proton 相容層](https://en.wikipedia.org/wiki/Proton_(software)) 上的出色工作，現在 Linux 上有數以萬計可玩的現代遊戲。喔，你知道 [Steam Deck](https://store.steampowered.com/steamdeck/) 其實跑的是 Arch 嗎！

所有遊戲安裝程式都位於 Omarchy 選單 (`Super + Space`) 的 _Install > Gaming_ 之下。如果你想移除其中任何一個，請使用 _Remove > Gaming_。

## Steam

透過在 Omarchy 選單 (`Super + Space`) 中選取 _Install > Gaming > Steam_，來安裝 [Steam](https://store.steampowered.com/)。

安裝之後，你就能用 `Super + Space` 啟動 Steam。

請注意，Steam 可能要花 10-20 秒才能啟動，而且載入期間不會提供任何視覺回饋。

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

透過在 Omarchy 選單 (`Super + Space`) 中選取 _Install > Gaming > RetroArch_，來安裝 [RetroArch](https://www.retroarch.com/)。它隨附完整的 libretro 核心，因此所有經典系統都涵蓋在內。

RetroArch 已完整預先設定美麗的 CRT Royale shader，帶來完美的復古外觀。

開始使用：

1. 將你的 BIOS 檔案放入 `~/Games/bios`，並將你的 ROM 放入 `~/Games/roms`。
2. 用 `Super + Space` 啟動 RetroArch 並輸入 `retro`。
3. 掃描 `~/Games/roms` 目錄，你就可以準備開玩了。

你也可以用 _Install > Gaming > RetroArch Game Launcher_ 為喜愛的遊戲在應用程式啟動器中建立專屬條目，它可讓你挑選核心和 ROM，並直接從 `Super + Space` 跳進遊戲。

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

透過在 Omarchy 選單 (`Super + Space`) 中選取 _Install > Gaming > Xbox Cloud Gaming_，來安裝 Xbox Cloud Gaming 網頁應用程式。它「只是」該服務的網頁應用程式，但啟動快速，且在 1080p 下執行出色。

如果你已經有 Xbox Game Pass，這是遊玩 Fortnite 和其他無法在 Linux 上原生執行的遊戲的可靠方式。

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

透過在 Omarchy 選單 (`Super + Space`) 中選取 _Install > Gaming > NVIDIA GeForce NOW_，來安裝雲端遊戲服務 [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/)。這也是遊玩無法在 Linux 上原生取得的遊戲的絕佳方式。

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

透過在 Omarchy 選單 (`Super + Space`) 中選取 _Install > Gaming > Minecraft_，來安裝 Minecraft。

和 Steam 一樣，請注意，登入或啟動之後，下一個畫面可能要過一段時間才會出現，而且等待期間你不會收到任何回饋。

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

透過在 Omarchy 選單 (`Super + Space`) 中選取 _Install > Gaming > Xbox Controllers_，來安裝 Bluetooth Xbox 控制器的支援。透過 Bluetooth (`Super + Ctrl + B`) 配對控制器，它們就能在你所有遊戲中運作。如果你只是用 USB-C 線有線連接控制器，就不需要這個。

## Moonlight (Game streaming from a PC)

透過在 Omarchy 選單 (`Super + Space`) 中選取 _Install > Gaming > Moonlight_，來安裝 [Moonlight 用戶端](https://github.com/moonlight-stream/moonlight-qt)，你就能從執行 [Sunshine](https://app.lizardbyte.dev/Sunshine/) 的 Windows PC 串流遊戲。

如果你的 Omarchy 機器和遠端遊戲 PC 都是有線連接，這個體驗和在本機遊玩無從區別。把解析度拉高到原生、將更新率設定為 120Hz，並將位元率開到最高 — 這是在 Linux 上玩 Fortnite 等競技射擊遊戲的最佳方式。

你也可以執行 `omarchy install service sunshine`，將 Omarchy 機器變成主機，它會安裝 Sunshine 並為你的 LAN 和 Tailscale 開啟 Moonlight 串流連接埠。

## Battle.net

透過在 Omarchy 選單 (`Super + Space`) 中選取 _Install > Gaming > Battle.net_，來安裝 [Battle.net](https://eu.shop.battle.net/en-us)。這讓你能以在 GE-Proton 下執行的獨立安裝方式取得 Diablo、Starcraft 和 World of Warcraft 等遊戲 — 不需要 Steam、Lutris 或 Heroic。

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows games)

透過在 Omarchy 選單 (`Super + Space`) 中選取 _Install > Gaming > Lutris_，來安裝 [Lutris](https://lutris.net/)。Lutris 是遊玩來自 EA 和 Ubisoft Connect 等商店的 Windows 遊戲的方式，那些商店在上文沒有自己的安裝程式。

安裝過程有點粗糙，有時看起來像什麼事都沒發生 — 請耐心點，它正在背景運作。

## Heroic Launcher (Epic Games)

透過在 Omarchy 選單 (`Super + Space`) 中選取 _Install > Gaming > Heroic (Epic Games)_，來安裝 [Heroic Launcher](https://heroicgameslauncher.com/)。Heroic 讓你能執行不依賴反作弊的 Epic Games 遊戲，例如 OddSparks — 以及來自 GOG 和 Amazon Prime Gaming 的遊戲。很遺憾，這表示玩不到 Fortnite 也玩不到 Rocket League — 在 Tim Sweeney 來到 Linux 之前，這已經是最接近的了。

和 Lutris 一樣，它在安裝遊戲時可能感覺緩慢又粗糙。給它一點時間。
