# Mac 支援

Omarchy 內建支援 **Intel Mac**。目前有幾個已知的限制，但只要你了解並能接受這些限制，就可以把 Omarchy 裝上你的舊 Mac，讓它重獲新生。

請注意，目前並不直接支援在 M 系列 Mac 上安裝。你可以在我們的 [Discord](https://discord.gg/tXFUdasqhY) 的 #omarchy-on-other 頻道中了解這方面的最新狀態。

在一次簡單的測試中，我們光是安裝 Omarchy，就在一台 2019 MacBook Pro 上獲得了 36% 的效能提升。

 ![macbook-omarchy](images/macbook-omarchy.webp)

### 在 Mac 上安裝 Omarchy

目前 Omarchy 只支援作為唯一安裝的作業系統。在安裝過程中，磁碟將被抹除，MacOS 將不再能開機。

如果你之後想還原它，仍然可以透過 Internet Recovery 來做。

在這一段中，我們假設你已經看過[開始使用](02-getting-started.md)並準備好你的 USB 磁碟。如果還沒，現在就去完成。

#### 停用 Secure Boot

為了開機可開機 USB 以及作業系統，有必要停用 Apple 的 Secure Boot。要停用它，請執行以下步驟：

1. 將你的 Mac 關機
2. 開機並 _立刻_ 按住 Command-R，直到你看到載入畫面出現
3. 如果出現提示，選擇你的使用者並輸入密碼
4. 進入還原畫面後，從選單列選擇 **Utilities > Startup Security Utility**
5. 在提示進行驗證時輸入你的密碼
6. 從 Secure Boot 選項中選擇 "No Security"
7. 從 External Boot 選項中選擇 "Allow booting from external or removable media"

#### 開始安裝

1. 插入 USB 磁碟
2. 重新啟動你的 Mac，並 _立刻_ 按住 Option，直到你看到開機裝置畫面
3. 選擇橘色的 EFI Boot 裝置
4. 按照[一般安裝流程](02-getting-started.md)繼續

安裝程式會偵測 Mac 硬體並自動套用所需的修正：Broadcom Wi-Fi 驅動程式和韌體、需要它的 MacBook 型號上的 SPI 鍵盤驅動程式，以及同樣這些型號的 NVMe 暫停修正。

### 已知限制

社群成員持續在為這些挑戰尋找解決方案，所以如果這些問題對你造成困擾，請加入我們 [Discord](https://discord.gg/tXFUdasqhY) 的 #omarchy-on-other 頻道，看看有沒有最新的解決方法。

#### 搭載 T1 晶片的裝置

Apple T1 晶片在 2016 年底推出，專用於第一代配備 Touch Bar 的 MacBook Pro 型號。
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – 型號：A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – 型號：A1708
- MacBook Pro 15-inch (2016) – 型號：A1707

#### 已知問題

- Touch Bar 無法運作
- 聲音無法運作

#### 搭載 T2 晶片的裝置

Apple T2 安全晶片在 2017 年推出。T2 晶片隨著自 2020 年起轉換到 Apple silicon（M 系列晶片）而停產。

- iMac Pro (2017) – 型號：A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – 型號：A1989
- MacBook Pro 15-inch (2018) – 型號：A1990
- MacBook Air (Retina, 13-inch, 2018) – 型號：A1932
- Mac mini (2018) – 型號：A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – 型號：A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – 型號：A2178
- MacBook Pro 15-inch (2019) – 型號：A1990
- iMac (Retina 5K, 27-inch, 2020) – 型號：A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – 型號：A2265
- MacBook Pro 15-inch (2020) – 型號：A1990

在這些型號上，安裝程式會自動設定修補過的 `linux-t2` 核心、T2 音訊設定、Apple 的 Broadcom Wi-Fi/Bluetooth 韌體，以及透過 `t2fanrd` 進行風扇控制。Touch Bar 則運行在核心內建的 Boot Camp 風格支援之上。
