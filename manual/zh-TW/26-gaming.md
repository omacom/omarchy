# 遊戲

Omarchy 不只是為了 _pRoDUcTiVItY_，也是為了好玩，還有什麼比打遊戲更好玩？Omarchy 內建一整套遊戲選項 — Steam 和 RetroArch 負責原生與懷舊遊戲，Battle.net、Lutris 和 Heroic 負責非 Steam 商店，Moonlight 負責 PC 串流，Xbox Cloud Gaming + NVIDIA GeForce NOW 負責雲端，再加上歷久不衰的 Minecraft。

感謝 Valve 在 [Proton 相容層](https://en.wikipedia.org/wiki/Proton_(software))上的傑出成果，如今 Linux 上已有數以萬計可遊玩的現代遊戲。哦，你知道嗎，[Steam Deck](https://store.steampowered.com/steamdeck/)實際上跑的是 Arch！

所有遊戲安裝程式都位於 Omarchy 選單 (`Super + Space`) 的 _Install > Gaming_ 底下。如果你想移除其中任何一個，請使用 _Remove > Gaming_。Minecraft、NVIDIA GeForce NOW、Battle.net、Lutris 和 Heroic 僅提供給 x86 機器。

## Steam

透過在 Omarchy 選單 (`Super + Space`) 中選擇 _Install > Gaming > Steam_，安裝 [Steam](https://store.steampowered.com/)。

安裝完成後，你就能用 `Super + Space` 啟動 Steam。

請注意，Steam 啟動可能需要 10-20 秒，而且在載入過程中不會提供任何視覺回饋。

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

透過在 Omarchy 選單 (`Super + Space`) 中選擇 _Install > Gaming > RetroArch_，安裝 [RetroArch](https://www.retroarch.com/)。它附帶完整的 libretro 核心，因此所有經典系統都涵蓋在內。

RetroArch 已完整預先設定好漂亮的 CRT Royale shader，帶來完美的懷舊外觀。

開始使用：

1. 將你的 BIOS 檔案放進 `~/Games/bios`，將你的 ROMs 放進 `~/Games/roms`。
2. 用 `Super + Space` 啟動 RetroArch，並輸入 `retro`。
3. 掃描 `~/Games/roms` 目錄，你就可以開始玩了。

你也可以透過 _Install > Gaming > RetroArch Game Launcher_，為喜愛的遊戲在應用程式啟動器中建立專屬項目，讓你選好核心和 ROM 後，直接從 `Super + Space` 跳進遊戲。

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

透過在 Omarchy 選單 (`Super + Space`) 中選擇 _Install > Gaming > Xbox Cloud Gaming_，安裝 Xbox Cloud Gaming 網頁應用程式。它「只是」該服務的一個網頁應用程式，但啟動快速，在 1080p 下執行效果出色。

如果你已經有 Xbox Game Pass，這是遊玩 Fortnite 和其他無法在 Linux 上原生執行的遊戲的可靠方式。

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

透過在 Omarchy 選單 (`Super + Space`) 中選擇 _Install > Gaming > NVIDIA GeForce NOW_，安裝雲端遊戲服務 [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/)。這是遊玩無法在 Linux 上原生取得的遊戲的另一個好方法。

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

透過在 Omarchy 選單 (`Super + Space`) 中選擇 _Install > Gaming > Minecraft_，安裝 Minecraft。

與 Steam 一樣，請注意，登入或啟動後可能需要一段時間才會出現下一個畫面，而且等待期間你不會收到任何回饋。

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

透過在 Omarchy 選單 (`Super + Space`) 中選擇 _Install > Gaming > Xbox Controllers_，安裝 Bluetooth Xbox 控制器的支援。透過 Bluetooth (`Super + Ctrl + B`) 配對控制器後，它們就能在所有遊戲中使用。如果你只是用 USB-C 線連接控制器，就不需要這個。

## Moonlight (從 PC 串流遊戲)

透過在 Omarchy 選單 (`Super + Space`) 中選擇 _Install > Gaming > Moonlight_，安裝 [Moonlight 用戶端](https://github.com/moonlight-stream/moonlight-qt)，你就能從執行 [Sunshine](https://app.lizardbyte.dev/Sunshine/) 的 Windows PC 串流遊戲。

如果你的 Omarchy 機器和遠端遊戲 PC 都是有線連接，體驗與在本機遊玩無異。把解析度拉到原生、更新率設為 120Hz、位元率拉到最高 — 這是在 Linux 上遊玩 Fortnite 這類競技射擊遊戲的最佳方式。

你也可以執行 `omarchy install service sunshine`，將 Omarchy 機器變成主機；這會安裝 Sunshine，並為你的 LAN 和 Tailscale 開啟 Moonlight 串流連接埠。

## Battle.net

透過在 Omarchy 選單 (`Super + Space`) 中選擇 _Install > Gaming > Battle.net_，安裝 [Battle.net](https://eu.shop.battle.net/en-us)。這讓你能以獨立安裝的方式遊玩 Diablo、Starcraft 和 World of Warcraft 等遊戲，並在 GE-Proton 下執行 — 不需要 Steam、Lutris 或 Heroic。

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows 遊戲)

透過在 Omarchy 選單 (`Super + Space`) 中選擇 _Install > Gaming > Lutris_，安裝 [Lutris](https://lutris.net/)。Lutris 是遊玩來自 EA 和 Ubisoft Connect 等商店的 Windows 遊戲的方式，那些商店在上面沒有自己的安裝程式。

安裝過程有點不順，有時看起來像是什麼事都沒發生 — 請耐心等候，它正在背景執行。

## Heroic Launcher (Epic Games)

透過在 Omarchy 選單 (`Super + Space`) 中選擇 _Install > Gaming > Heroic (Epic Games)_，安裝 [Heroic Launcher](https://heroicgameslauncher.com/)。Heroic 讓你執行不依賴反作弊的 Epic Games 遊戲，例如 OddSparks — 再加上來自 GOG 和 Amazon Prime Gaming 的遊戲。遺憾的是，這代表沒有 Fortnite，也沒有 Rocket League — 在 Tim Sweeney 來到 Linux 之前，這已經是最接近的程度了。

與 Lutris 一樣，安裝遊戲時它可能會感覺緩慢且不順。給它一點時間。
