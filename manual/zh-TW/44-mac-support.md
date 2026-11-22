# Mac 支援

## 適用於 Apple Silicon 的 Omarchy

適用於 Apple Silicon 的 Omarchy 是 Omacom 的官方解決方案，首次隨 Omarchy 4.5 一同發布。它會與 macOS 並存安裝，您可以在 Mac 開機時選擇要進入這兩者中的哪一個。

收到有關 Omarchy Mac 的通知嗎？請前往[從 Omarchy Mac 轉移過來](#coming-from-omarchy-mac)。

它可以在這些 Mac 上運行：

| Mac | 晶片 |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 及更新的 Mac 尚未支援。M4 支援目前正在 edge channel 上進行測試，接下來就會推出。安裝程式會在變更任何內容之前，先檢查您的 Mac。

在任何 Apple Silicon Mac 上，包括 M4 及更新的機型，您都可以使用 [Try Omarchy](https://github.com/omacom/try-omarchy) 在虛擬機器中運行 Omarchy。

### 您需要準備的東西

- macOS 15 Sequoia 或更新版本，以及一個系統管理員帳戶
- 供 Omarchy 使用的可用磁碟空間。安裝程式會建議一個大小，並讓您自行變更。
- Mac 的備份、電源，以及網際網路連線。安裝過程會下載數 GB 的資料。

### 安裝

您將從 macOS 進行安裝。使用 [Homebrew](https://brew.sh) 安裝 Omarchy Installer：

```sh
brew install omacom/mac/omarchy
```

或是從其[發行頁面](https://github.com/omacom/omarchy-mac-installer/releases)下載最新版的 Omarchy Installer 並開啟它。

安裝程式會檢查您的 Mac、向您說明計畫，並透過縮小 macOS 分割區來為 Omarchy 騰出空間。macOS 仍會保留在磁碟上，且不需要 USB 隨身碟。第一階段完成後，它會引導您在 macOS Recovery 中完成設定：關機、按住電源按鈕直到 "Loading startup options" 出現、選擇 Omarchy，然後依照步驟操作。

首次開機時，Omarchy 會要求您設定一組用來加密其磁碟的密碼。這裡沒有復原金鑰：如果您忘記密碼，您的 Omarchy 檔案將無法復原。

之後若要在 Omarchy 與 macOS 之間切換，請先關機，然後按住電源按鈕直到啟動選項出現，再選擇其中一個。

### 從 Omarchy Mac 轉移過來

Omarchy Mac 現在已成為適用於 Apple Silicon 的 Omarchy 的一部分，且每一台曾運行它的 Mac 都受到支援。您目前的安裝仍可繼續運行，其系統套件也仍會更新，但它不會再收到 Omarchy 更新。這件事沒有期限，也沒有就地升級：您要備份、移除舊的安裝、全新安裝，然後還原。第 2 步到第 5 步是在 macOS 中進行的，所以在您重新啟動之前，先在手機上開啟這個頁面。

1. **從 Omarchy 備份到 Mac 以外的地方。** 移除舊的安裝會將其清除，且 macOS 無法讀取 Omarchy 磁碟。將您的家目錄複製到外接硬碟或另一台電腦，包括 SSH 與 GPG 金鑰、瀏覽器設定檔，以及尚未推送的工作。使用 `pacman -Qqe > ~/packages.txt` 儲存您的套件清單。也請備份 macOS，因為移除與安裝都會調整其磁碟大小。
2. **在 macOS 中啟動您的 Mac。** 關機、按住電源按鈕直到啟動選項出現，然後選擇 macOS。
3. **安裝 Omarchy Installer**，如[安裝](#installing)所示。
4. **移除舊的安裝。** 開啟 Omarchy Installer 並選擇 Installation > Remove Omarchy。它會顯示它將刪除什麼，並將空間歸還給 macOS。如果它無法辨識您的安裝，它會停止且不變更磁碟。請在 [Discord](https://discord.gg/tXFUdasqhY) 尋求協助，而不是手動刪除分割區，那可能會清除 macOS。
5. **使用安裝程式安裝適用於 Apple Silicon 的 Omarchy。**
6. **還原您的檔案。** 一次一點地將您的設定帶回來，而不是將整個 `~/.config` 複製覆蓋到新的預設值上，因為舊設定可能會覆蓋它們。

### 須知事項

- 在 M1 與 M2 MacBook 上，透過打開上蓋或按下電源按鈕來從睡眠中喚醒。
- 有問題或遇到困難：請在我們的 [Discord](https://discord.gg/tXFUdasqhY) 提問。

[安裝程式的 README](https://github.com/omacom/omarchy-mac-installer#readme) 涵蓋了發行管道、更新安裝程式，以及移除 Omarchy。

## Intel Mac

在一次簡單的測試中，我們光是安裝 Omarchy，就讓一台 2019 年的 MacBook Pro 獲得了 36% 的效能提升。

 ![macbook-omarchy](images/macbook-omarchy.webp)

### 在 Mac 上安裝 Omarchy

Omarchy 目前僅支援作為**唯一**安裝的作業系統。安裝過程中，磁碟將被清除，MacOS 將不再能開機。

如果您想的話，之後仍可透過 Internet Recovery 將其還原。

在這一部分，我們假設您已經看過[入門指南](02-getting-started.md)並準備好您的 USB 隨身碟。如果還沒有，現在就先去完成。

#### 停用 Secure Boot

必須停用 Apple 的 Secure Boot，才能從可開機 USB 以及該作業系統開機。若要停用，請執行以下步驟：

1. 關閉您的 Mac
2. 開啟它，並_立即_按住 Command-R，直到看到載入畫面出現
3. 選擇您的使用者，並在出現提示時輸入您的密碼
4. 進入復原畫面後，從選單列選擇 **Utilities > Startup Security Utility**
5. 在出現提示時輸入您的密碼以進行驗證
6. 從 Secure Boot 選項中選擇 "No Security"
7. 從 External Boot 選項中選擇 "Allow booting from external or removable media"

#### 開始安裝

1. 插入 USB 隨身碟
2. 重新啟動您的 Mac，並_立即_按住 Option，直到看到開機裝置畫面
3. 選擇橘色的 EFI Boot 裝置
4. 依照[一般安裝方式](02-getting-started.md)繼續進行安裝

安裝程式會偵測 Mac 硬體並自動套用所需的修正：Broadcom Wi-Fi 驅動程式與韌體、需要它的 MacBook 機型上的 SPI 鍵盤驅動程式，以及同樣這些機型上的 NVMe 暫停修正。

### 已知限制

社群成員持續在為這些挑戰尋找解決方案，所以如果這些問題對您造成困擾，歡迎加入我們 [Discord](https://discord.gg/tXFUdasqhY) 中的 #omarchy-on-other，看看是否有任何最新的解決方法。

#### 配備 T1 晶片的裝置

Apple T1 晶片於 2016 年底推出，專門用於第一代配備 Touch Bar 的 MacBook Pro 機型。
- MacBook Pro 13 吋（2016 年，兩個 Thunderbolt 3 連接埠）– 型號：A1706
- MacBook Pro 13 吋（2016 年，四個 Thunderbolt 3 連接埠）– 型號：A1708
- MacBook Pro 15 吋（2016 年）– 型號：A1707

#### 已知問題

- Touch Bar 無法運作
- 音效無法運作

#### 配備 T2 晶片的裝置

Apple T2 Security Chip 於 2017 年推出。隨著從 2020 年開始轉換至 Apple silicon（M 系列晶片），T2 晶片也隨之停產。

- iMac Pro（2017 年）– 型號：A1862
- MacBook Pro 13 吋（2018 年，四個 Thunderbolt 3 連接埠）– 型號：A1989
- MacBook Pro 15 吋（2018 年）– 型號：A1990
- MacBook Air（Retina，13 吋，2018 年）– 型號：A1932
- Mac mini（2018 年）– 型號：A1998
- MacBook Pro 13 吋（2019 年，兩個 Thunderbolt 3 連接埠）– 型號：A2159
- MacBook Pro 13 吋（2019 年，四個 Thunderbolt 3 連接埠）– 型號：A2178
- MacBook Pro 15 吋（2019 年）– 型號：A1990
- iMac（Retina 5K，27 吋，2020 年）– 型號：A2115（iMac20,1 與 iMac20,2）
- MacBook Pro 13 吋（2020 年，兩個 Thunderbolt 3 連接埠）– 型號：A2265
- MacBook Pro 15 吋（2020 年）– 型號：A1990

在這些機型上，安裝程式會自動設定修補過的 `linux-t2` 核心、T2 音訊設定、Apple 的 Broadcom Wi-Fi/Bluetooth 韌體，以及透過 `t2fanrd` 進行的風扇控制。Touch Bar 則是透過核心內建的 Boot Camp 風格支援來運作。

#### iMac Retina 5K（2017 年）

2017 年的 27 吋 iMac 沒有 T2 晶片，因此安裝程式會比照其他 Intel Mac 來設定它。

- iMac（Retina 5K，27 吋，2017 年）– 型號：A1419

#### 已知問題

- 顯示器無法以其原生 5120×2880 運作：面板由兩個區塊組成，而原廠驅動程式只會點亮其中一個
- 音效無法運作
- 亮度控制沒有作用
- 睡眠會讓機器當機；只有重新啟動電源才能讓它復原

一個針對此機型的社群修補程式修復了顯示器、音效與亮度：[omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3)。
