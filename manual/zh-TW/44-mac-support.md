# Mac 支援

Omarchy 內建支援 **Intel Macs**。目前有幾個已知的限制，但只要你了解並能接受這些限制；你就可以透過安裝 Omarchy，讓你的舊 Mac 重獲新生。

請注意，目前不直接支援安裝在 M 系列 Mac 上。你可以在我們的 [Discord](https://discord.gg/tXFUdasqhY) 中的 #omarchy-on-other 了解這方面的最新狀態。

在一次簡單的測試中，我們僅僅透過安裝 Omarchy，就讓一台 2019 年的 MacBook Pro 獲得了 36% 的效能提升。

 ![macbook-omarchy](images/macbook-omarchy.webp)

### 在 Mac 上安裝 Omarchy

Omarchy 目前僅支援作為**唯一**安裝的作業系統。在安裝過程中，磁碟將會被清除，MacOS 將無法再開機。

如果你之後想恢復，仍然可以透過 Internet Recovery 來還原。

在這一部分，我們假設你已經看過 [Getting Started](02-getting-started.md) 並準備好你的 USB 隨身碟。如果你還沒準備好，現在就去做吧。

#### 停用 Secure Boot

為了從可開機 USB 開機，以及啟動作業系統，必須停用 Apple 的 Secure Boot。要停用它，請執行以下步驟：

1. 關閉你的 Mac
2. 開機並_立即_按住 Command-R，直到看到載入畫面出現
3. 選擇你的使用者，並在提示時輸入你的密碼
4. 進入復原畫面後，從選單列選擇 **Utilities > Startup Security Utility**
5. 在提示進行驗證時輸入你的密碼
6. 從 Secure Boot 選項中選擇 "No Security"
7. 從 External Boot 選項中選擇 "Allow booting from external or removable media"

#### 開始安裝

1. 插入 USB 隨身碟
2. 重新啟動你的 Mac，並_立即_按住 Option，直到看到開機裝置畫面
3. 選擇橘色的 EFI Boot 裝置
4. 依照[一般安裝方式](02-getting-started.md)繼續進行

安裝程式會偵測 Mac 硬體並自動套用所需的修復：Broadcom Wi-Fi 驅動程式與韌體、需要它的 MacBook 型號上的 SPI 鍵盤驅動程式，以及同款型號的 NVMe 暫停修復。

### 已知限制

社群成員持續在為這些挑戰尋找解決方案，所以如果這些問題對你造成困擾，歡迎加入我們 [Discord](https://discord.gg/tXFUdasqhY) 中的 #omarchy-on-other，看看是否有任何最新的解決方法。

#### 配備 T1 晶片的裝置

Apple T1 晶片於 2016 年末推出，僅用於配備 Touch Bar 的第一代 MacBook Pro 型號。
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### 已知問題

- Touch Bar 無法運作
- 音效無法運作

#### 配備 T2 晶片的裝置

Apple T2 Security Chip 於 2017 年推出。隨著 2020 年開始轉換到 Apple silicon（M 系列晶片），T2 晶片已停產。

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

在這些型號上，安裝程式會自動設定修補過的 `linux-t2` 核心、T2 音訊設定、Apple 的 Broadcom Wi-Fi/Bluetooth 韌體，以及透過 `t2fanrd` 進行風扇控制。Touch Bar 則使用核心內建的 Boot Camp 風格支援來運作。

#### iMac Retina 5K (2017)

2017 年的 27 吋 iMac 沒有 T2 晶片，因此安裝程式會像其他 Intel Mac 一樣進行設定。

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### 已知問題

- 顯示器無法以其原生的 5120×2880 運作：面板由兩塊拼貼組成，而原廠驅動程式只能點亮其中一塊
- 音效無法運作
- 亮度控制無效
- 睡眠會讓機器當機；只能重新開機才能恢復

針對此型號的社群修補程式修復了顯示、音效與亮度問題：[omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3)。
