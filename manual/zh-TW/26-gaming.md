# 遊戲

Omarchy 不只是為了生產力，它也是為了享樂，而有什麼比遊戲更好玩呢？Omarchy 附帶一整套遊戲選項——用於原生和復古遊戲的 Steam 和 RetroArch、用於非 Steam 商店的 Battle.net、Lutris 和 Heroic、用於 PC 串流的 Moonlight、用於雲端的 Xbox Cloud Gaming + NVIDIA GeForce NOW，再加上長青的 Minecraft。

感謝 Valve 在 [Proton 相容層](https://en.wikipedia.org/wiki/Proton_(software))上的出色工作，現在 Linux 上有數以萬計可玩的現代遊戲。喔，你知道嗎？[Steam Deck](https://store.steampowered.com/steamdeck/) 實際上執行的就是 Arch！

所有遊戲安裝程式都位於 Omarchy 選單（`Super + Space`）的 _安裝 > Gaming_ 下。如果你想還原其中任何一個，使用 _移除 > Gaming_。

## Steam

從 Omarchy 選單（`Super + Space`）中選取 _安裝 > Gaming > Steam_ 來安裝 [Steam](https://store.steampowered.com/)。

安裝後，你將能夠用 `Super + Space` 啟動 Steam。

注意，Steam 可能需要 10-20 秒才能啟動，而且它不會提供任何它正在載入的視覺回饋。

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

從 Omarchy 選單（`Super + Space`）中選取 _安裝 > Gaming > RetroArch_ 來安裝 [RetroArch](https://www.retroarch.com/)。它附帶全套 libretro 核心，所以所有經典系統都被涵蓋了。

RetroArch 已完全預先設定了漂亮的 CRT Royale 著色器，帶來完美的復古外觀。

入門方法：

1. 將你的 BIOS 檔案放入 `~/Games/bios`，將你的 ROM 放入 `~/Games/roms`。
2. 用 `Super + Space` 啟動 RetroArch 並輸入 `retro`。
3. 掃描 `~/Games/roms` 目錄，你就準備好玩了。

你還可以用 _安裝 > Gaming > RetroArch Game Launcher_ 為你喜歡的遊戲在應用程式啟動器中建立自己的項目，它讓你選取一個核心和一個 ROM，並從 `Super + Space` 直接跳進遊戲。

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

從 Omarchy 選單（`Super + Space`）中選取 _安裝 > Gaming > Xbox Cloud Gaming_ 來安裝 Xbox Cloud Gaming 網頁應用程式。它「只是」該服務的一個網頁應用程式，但它啟動很快，而且在 1080p 下執行得很好。

如果你已經有 Xbox Game Pass，這是玩 Fortnite 和其他你無法在 Linux 上原生執行的遊戲的一個穩固方式。

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

從 Omarchy 選單（`Super + Space`）中選取 _安裝 > Gaming > NVIDIA GeForce NOW_ 來安裝雲端遊戲服務 [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/)。這是玩在 Linux 上無法原生取得的遊戲標題的另一個好方法。

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

從 Omarchy 選單（`Super + Space`）中選取 _安裝 > Gaming > Minecraft_ 來安裝 Minecraft。

和 Steam 一樣，請注意，在登入或啟動後，下一個畫面可能需要一段時間才會出現，而且你在等待時不會得到任何回饋。

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox 控制器

從 Omarchy 選單（`Super + Space`）中選取 _安裝 > Gaming > Xbox Controllers_ 來安裝對藍牙 Xbox 控制器的支援。透過藍牙（`Super + Ctrl + B`）配對控制器，它們就能在你所有的遊戲中運作。如果你只是用 USB-C 線有線連接控制器，就不需要這個。

## Moonlight（從 PC 串流遊戲）

[Moonlight 用戶端](https://github.com/moonlight-stream/moonlight-qt)已預先安裝在 Omarchy 中，所以你可以立即從一台執行 [Sunshine](https://app.lizardbyte.dev/Sunshine/) 的 Windows PC 串流遊戲。透過 `Super + Space` 啟動 Moonlight。

如果你的 Omarchy 機器和遠端遊戲 PC 都是有線連接，體驗將與本地遊玩無法區分。把解析度拉到原生、將更新率設為 120Hz、把位元率拉到最高——這是在 Linux 上玩 Fortnite 這類競技射擊遊戲的最佳方式。

你還可以執行 `omarchy install service sunshine` 將 Omarchy 機器變成主機，它會安裝 Sunshine 並為你的 LAN 和 Tailscale 開啟 Moonlight 串流連接埠。

## Battle.net

從 Omarchy 選單（`Super + Space`）中選取 _安裝 > Gaming > Battle.net_ 來安裝 [Battle.net](https://eu.shop.battle.net/en-us)。這樣你就能在 GE-Proton 下以獨立安裝的方式取得 Diablo、Starcraft 和 World of Warcraft 這類遊戲——不需要 Steam、Lutris 或 Heroic。

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris（Windows 遊戲）

從 Omarchy 選單（`Super + Space`）中選取 _安裝 > Gaming > Lutris_ 來安裝 [Lutris](https://lutris.net/)。Lutris 是玩 EA 和 Ubisoft Connect 這類沒有上面所列專用安裝程式的商店的 Windows 遊戲的方式。

安裝過程有點不順，有時看起來像什麼都沒發生——請耐心一點，它正在背景工作。

## Heroic Launcher（Epic Games）

從 Omarchy 選單（`Super + Space`）中選取 _安裝 > Gaming > Heroic (Epic Games)_ 來安裝 [Heroic Launcher](https://heroicgameslauncher.com/)。Heroic 讓你執行不依賴反作弊的 Epic Games 遊戲，例如 OddSparks，以及來自 GOG 和 Amazon Prime Gaming 的遊戲。遺憾的是，這意味著沒有 Fortnite，也沒有 Rocket League——在 Tim Sweeney 來到 Linux 之前，這已經是最接近的了。

和 Lutris 一樣，它在安裝遊戲時可能會感覺緩慢而不順。給它一點時間。
