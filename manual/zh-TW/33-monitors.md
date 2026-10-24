# 顯示器

Omarchy 預設假設你在能支援 2 倍縮放的 retina 級顯示器上執行。這是你獲得那些漂亮、銳利的程式設計師字型所需要的。這是幾乎所有配備高解析度螢幕的新式高級筆記型電腦所最佳化的方向。這是你會想在 27 吋 5K 的 [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或 32 吋 6K 的 [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 上執行的設定。

但是，如果你並非在 PPI 為 218 或更高的顯示器上執行，你會想要更改顯示器設定。例如，如果你有一台 27 吋或 32 吋 4K 顯示器，你可以透過開啟 `~/.config/hypr/monitors.lua`（透過 Omarchy 選單中的 _設定 > 顯示器_）並切換到針對該組合的建議，來使用分數縮放：

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

如果你使用的是 1080p 或 1440p 顯示器，你可能只想使用 1 倍縮放，所以你可以使用：

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

對 `GDK_SCALE` 的變更適用於變更後啟動的應用程式（而且 GTK 只接受整數，所以請將它保持在最接近你顯示器縮放的整數）。所以請在變更後關閉那些過大的視窗（或用 `Ctrl + Alt + Del` 關閉所有視窗！）。

你也可以用 `Super + /` 提高、並用 `Super + Alt + /` 降低，快速在主要的顯示器縮放比例（1x、1.25x、1.6x、2x、3x、4x）之間逐步切換。如果你使用的是預設設定，這些變更在重新開機後也會保留。

### 讓文字變大或變小

顯示器縮放會改變一切的大小。如果你只想讓_文字_變大或變小，有一個專門的控制鈕：

```
omarchy display text size 14
```

這接受 9 到 20 之間的像素大小，並將 Omarchy shell、GTK 應用程式和你的終端機一起調整，使整個桌面保持比例。不帶參數執行它可查看你目前所在的位置，用 `omarchy display text size reset` 可回到預設值。Foot 是唯一的落後者：它沒有重新載入設定的方法，所以正在執行的終端機會保留它們的舊大小，直到你開啟一個新的為止。

### 延伸和鏡像筆記型電腦顯示器

當你將外接螢幕連接到筆記型電腦時，顯示會自動延伸。但你可以使用 Omarchy 選單中的 _觸發 > 硬體_ 或 `Super + Ctrl + Alt + Delete`，將其改為鏡像。如果那台外接螢幕是投影機，而你想在工作時展示某樣東西，這尤其有幫助。

當你在延伸模式時，闔上筆記型電腦的上蓋會自動關閉內部螢幕。打開上蓋會將它重新開啟。你也可以使用 Omarchy 選單中的 _觸發 > 硬體_ 或 `Super + Ctrl + Delete` 手動控制這一點。

### 安排多台螢幕

Hyprland 在多台螢幕下工作得很出色。在 [Hyprland 顯示器文件](https://wiki.hypr.land/Configuring/Basics/Monitors/)中閱讀更多關於如何配置它們的資訊。你也可以[將特定的工作區綁定到特定的顯示器](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)。在 Omarchy 中，這些規則以 `hl.monitor` 項目的形式放在 `~/.config/hypr/monitors.lua` 中——該檔案附帶了註解的範例，用於將特定顯示器釘到特定解析度、位置和旋轉。

如果你想要一個 TUI 來幫助你定位多台螢幕，你也可以看看 [Hyprmon](https://github.com/erans/hyprmon/)。

### 控制亮度

顯示器亮度由專用的亮度調高/調低功能鍵控制。如果你按這些鍵時同時按住 Shift，你會去到最大或最小亮度。這些鍵控制你所聚焦的顯示器，所以支援 DDC/CI 的外接顯示器會以與筆記型電腦螢幕相同的方式進行調整。

### Apple 顯示器

如果你使用的是 Apple 顯示器，普通的鍵盤亮度鍵也會自動運作，前提是你聚焦於該 Apple 顯示器。這是透過 `asdcontrol` 命令完成的。

請注意，如果你使用的是 Apple 6K XDR 顯示器，你可能在你的 `hyprctl monitors` 清單中看到一個幻影螢幕。你可以透過 _設定 > 顯示器_ 使用類似 `hl.monitor({ output = "DP-2", disabled = true })` 這樣的設定來關閉它。

在 Intel 機器上，你應使用一般的 Thunderbolt 線來連接 Apple 顯示器。在其他沒有 Thunderbolt 的機器上，你通常必須使用 [DP + USB-A -> USB-C 線](https://www.amazon.com/dp/B0BNX7MS6N) 才能使其運作。
