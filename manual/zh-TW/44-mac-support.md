# Mac 支援

## 適用於 Apple Silicon 的 Omarchy

適用於 Apple Silicon 的 Omarchy 是官方的 Omacom 解決方案，隨 Omarchy 4.5 首次發布。它會安裝在 macOS 旁邊，你可以在 Mac 啟動時在兩者之間做選擇。

收到 Omarchy Mac 相關通知了嗎？請前往[從 Omarchy Mac 遷移](#coming-from-omarchy-mac)。

它可在這些 Mac 上運行：

| Mac | 晶片 |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

尚未支援 M4 及更新的 Mac。M4 支援正在 edge 頻道測試中，接下來就會推出。安裝程式會在變更任何內容之前先檢查你的 Mac。

在任何 Apple Silicon Mac 上，包括 M4 及更新的機型，你都可以使用 [Try Omarchy](https://github.com/omacom/try-omarchy) 在虛擬機器中運行 Omarchy。

### 你需要的東西

- macOS 15 Sequoia 或更新版本，以及管理員帳戶
- 供 Omarchy 使用的可用磁碟空間。安裝程式會建議一個大小，並讓你變更。
- Mac 的備份、電源以及網際網路連線。安裝過程會下載數 GB 的資料。

### 安裝

你從 macOS 進行安裝。使用 [Homebrew](https://brew.sh) 安裝 Omarchy Installer：

```sh
brew install omacom/mac/omarchy
```

或者從其[發行頁面](https://github.com/omacom/omarchy-mac-installer/releases)下載最新版 Omarchy Installer 並開啟它。

安裝程式會檢查你的 Mac、向你顯示計畫，並透過縮小 macOS 分割區來為 Omarchy 騰出空間。macOS 會保留在磁碟上，且不需要 USB 隨身碟。當第一階段完成後，它會引導你在 macOS Recovery 中完成設定：關機、按住電源按鈕直到出現「正在載入開機選項」、選擇 Omarchy，然後依照步驟操作。

首次開機時，Omarchy 會要求你設定一個用於加密其磁碟的密碼。沒有復原金鑰：如果你忘記密碼，你的 Omarchy 檔案將無法復原。

之後若要在 Omarchy 與 macOS 之間切換，請關機，然後按住電源按鈕，直到出現開機選項，然後選擇其中一個。

### 從 Omarchy Mac 遷移

Omarchy Mac 現在是適用於 Apple Silicon 的 Omarchy 的一部分，且支援每一台曾運行它的 Mac。你目前的安裝會繼續運行，其系統套件仍會更新，但不會再收到 Omarchy 更新。沒有期限，也沒有就地升級：你備份、移除舊安裝、全新安裝，然後還原。第 2 到 5 步在 macOS 中進行，所以在重新啟動前，先在手機上開啟此頁面。

1. **從 Omarchy 備份到 Mac 以外的地方。** 移除舊安裝會將其清除，而且 macOS 無法讀取 Omarchy 磁碟。將你的家目錄複製到外接磁碟機或另一台電腦，包括 SSH 與 GPG 金鑰、瀏覽器設定檔以及未推送的工作。使用 `pacman -Qqe > ~/packages.txt` 儲存你的套件清單。也備份 macOS，因為移除和安裝都會調整其磁碟大小。
2. **在 macOS 中啟動你的 Mac。** 關機、按住電源按鈕，直到出現開機選項，然後選擇 macOS。
3. **安裝 Omarchy Installer**，如[安裝](#installing)所示。
4. **移除舊安裝。** 開啟 Omarchy Installer 並選擇 Installation > Remove Omarchy。它會顯示將刪除的內容，並將空間歸還給 macOS。如果它無法辨識你的安裝，它會停止且不變更磁碟。在 [Discord](https://discord.gg/tXFUdasqhY) 尋求協助，而不是手動刪除分割區，那可能會清除 macOS。
5. **安裝適用於 Apple Silicon 的 Omarchy**，使用安裝程式。
6. **還原你的檔案。** 一次一點地將設定恢復，而不是將整個 `~/.config` 複製到新的預設值之上，因為舊設定可能會覆蓋它們。

### 須知事項

- 在 M1 和 M2 MacBook 上，透過開啟上蓋或按下電源按鈕從睡眠喚醒。
- 有問題或疑問：在我們的 [Discord](https://discord.gg/tXFUdasqhY) 提問。

[安裝程式的 README](https://github.com/omacom/omarchy-mac-installer#readme) 涵蓋發行頻道、更新安裝程式以及移除 Omarchy。

## Intel Mac

在一次簡單測試中，我們僅透過安裝 Omarchy，就在 2019 年 MacBook Pro 上獲得了 36% 的效能提升。

 ![macbook-omarchy](images/macbook-omarchy.webp)

### 在 Mac 上安裝 Omarchy

Omarchy 目前僅支援成為唯一安裝的 OS。在安裝期間，磁碟機將被清除，MacOS 將無法再開機。

如果你願意，之後仍可透過 Internet Recovery 將其還原。

在這一部分，我們假設你已經閱讀[入門指南](02-getting-started.md)並準備好 USB 隨身碟。如果你還沒有，現在就去做。

#### 停用 Secure Boot

必須停用 Apple 的 Secure Boot，才能從可開機 USB 開機，以及啟動 OS。要停用它，請執行以下步驟：

1. 關閉你的 Mac
2. 開啟它並_立即_按住 Command-R，直到你看到載入畫面出現
3. 選擇你的使用者，並在出現提示時輸入你的密碼
4. 進入復原畫面後，從選單列選擇 **Utilities > Startup Security Utility**
5. 在出現驗證提示時輸入你的密碼
6. 從 Secure Boot 選項中選擇「No Security」
7. 從 External Boot 選項中選擇「Allow booting from external or removable media」

#### 開始安裝

1. 插入 USB 隨身碟
2. 重新啟動你的 Mac 並_立即_按住 Option，直到你看到開機裝置畫面
3. 選擇橘色的 EFI Boot 裝置
4. 依照一般方式[進行安裝](02-getting-started.md)

安裝程式會偵測 Mac 硬體並自動套用所需的修正：Broadcom Wi-Fi 驅動程式和韌體、在配備 Broadcom 1570 的機器上的 FaceTime HD 相機驅動程式（其韌體會在 Mac 上線後從 Apple 下載，因為安裝程式可離線運作）、在需要它的 MacBook 機型上的 SPI 鍵盤驅動程式，以及針對相同機型的 NVMe 暫停修正。

### 已知限制

社群成員不斷致力於解決這些挑戰，所以如果這些對你造成困擾，請加入我們 [Discord](https://discord.gg/tXFUdasqhY) 中的 #omarchy-on-other，看看是否有任何最新的解決方法。

#### FaceTime HD 相機

如果相機驅動程式在 Mac 休眠時已載入，它會使機器當機，所以會先將其卸載。趁應用程式開啟相機時，它無法被卸載，所以休眠會被取消，並透過通知指出該應用程式：關閉它並再次休眠。這包括電池嚴重不足時自動休眠，以及 suspend-then-hibernate，它會在暫停之前被拒絕。在相機開啟時，一般暫停會被驅動程式本身拒絕，且沒有通知。

相機的韌體會從 Apple 下載，所以相機只有在 Mac 上線後才能運作。下載會在開機時開始，且當網路是問題時，每 15 分鐘重試一次；如果 Apple 的檔案已變更，它會停止並等待 Omarchy 更新。如果相機沒有出現，`journalctl -u facetimehd-firmware-fetcher` 會說明原因，`sudo systemctl restart facetimehd-firmware-fetcher` 會再次嘗試，而如果下載已完成但相機仍未出現，重新開機將載入驅動程式。

#### 配備 T1 晶片的裝置

Apple T1 晶片於 2016 年末推出，僅用於配備 Touch Bar 的第一代 MacBook Pro 機型。
- MacBook Pro 13 吋（2016 年，兩個 Thunderbolt 3 連接埠）– 型號：A1706
- MacBook Pro 13 吋（2016 年，四個 Thunderbolt 3 連接埠）– 型號：A1708
- MacBook Pro 15 吋（2016 年）– 型號：A1707

#### 已知問題

- Touch Bar 無法使用
- 音效無法運作

#### 配備 T2 晶片的裝置

Apple T2 Security Chip 於 2017 年推出。T2 晶片隨著 2020 年開始轉換至 Apple silicon（M 系列晶片）而停產。

- iMac Pro（2017 年）– 型號：A1862
- MacBook Pro 13 吋（2018 年，四個 Thunderbolt 3 連接埠）– 型號：A1989
- MacBook Pro 15 吋（2018 年）– 型號：A1990
- MacBook Air (Retina, 13 吋，2018 年) – 型號：A1932
- Mac mini（2018 年）– 型號：A1998
- MacBook Pro 13 吋（2019 年，兩個 Thunderbolt 3 連接埠）– 型號：A2159
- MacBook Pro 13 吋（2019 年，四個 Thunderbolt 3 連接埠）– 型號：A2178
- MacBook Pro 15 吋（2019 年）– 型號：A1990
- iMac (Retina 5K, 27 吋，2020 年) – 型號：A2115 (iMac20,1 和 iMac20,2)
- MacBook Pro 13 吋（2020 年，兩個 Thunderbolt 3 連接埠）– 型號：A2265
- MacBook Pro 15 吋（2020 年）– 型號：A1990

在這些機型上，安裝程式會自動設定修補過的 `linux-t2` 核心、T2 音訊設定、Apple 的 Broadcom Wi-Fi/Bluetooth 韌體，以及透過 `t2fanrd` 進行的風扇控制。Touch Bar 運行在核心內建的 Boot Camp 風格支援上。

#### iMac Retina 5K (2017)

2017 年 27 吋 iMac 沒有 T2 晶片，所以安裝程式會像其他 Intel Mac 一樣設定它。

- iMac (Retina 5K, 27 吋，2017 年) – 型號：A1419

#### 已知問題

- 顯示器無法以其原生 5120×2880 運行：面板由兩個圖塊組成，而原廠驅動程式僅點亮其中一個
- 音效無法運作
- 亮度控制沒有效果
- 睡眠會使機器當機；只能透過電源循環復原

針對此機型的社群修補程式修復了顯示器、音效和亮度：[omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3)。
