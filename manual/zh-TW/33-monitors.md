# 顯示器

Omarchy 預設假設你使用的是一台支援 2 倍縮放的 Retina 等級顯示器。要獲得那種漂亮、銳利的程式設計字型，就需要這樣的顯示器。這也是幾乎所有搭載高解析度螢幕的新款高階筆電所最佳化的規格。如果你想在 27" 5K 的 [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或 32" 6K 的 [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 上使用，這就是你會想要的組合。

但如果你的顯示器 PPI 沒有達到 218 或以上，你就會想要變更顯示器設定。舉例來說，如果你有一台 27" 或 32" 的 4K 顯示器，你可以使用分數縮放，方法是開啟 `~/.config/hypr/monitors.lua`（透過 Omarchy 選單中的 _設定 > 顯示器_），並切換到針對該組合的推薦值：

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

如果你使用的是 1080p 或 1440p 顯示器，你可能只想使用 1 倍縮放，因此你可以使用：

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

對 `GDK_SCALE` 的變更只會套用到變更後才啟動的應用程式（而且 GTK 只支援整數，所以請將它保持在最接近你顯示器縮放倍率的整數）。因此，變更後請務必結束那些尺寸過大的視窗（或使用 `Ctrl + Alt + Del` 關閉所有視窗！）。

你也可以使用 `Super + /` 往上切換，或使用 `Super + Alt + /` 往下切換，快速逐一嘗試主要的顯示器縮放倍率（1x、1.25x、1.6x、2x、3x、4x）。如果你使用的是預設設定，這些變更在重新開機後也會持續保留。

### 讓文字變大或變小

顯示器縮放會改變所有東西的大小。如果你只想要更大或更小的_文字_，有一個專門的控制項可以調整：

```
omarchy display text size 14
```

這個指令接受 9 到 20 之間的像素大小，並會同時調整 Omarchy 殼層、GTK 應用程式和你的終端機，讓整個桌面維持一致的比例。不帶參數執行它，就可以看到你目前的設定；使用 `omarchy display text size reset` 則可以回到預設值。Foot 是唯一跟不上的：它沒有重新載入設定的方法，因此已經在執行的終端機會保留舊的大小，直到你開啟一個新的終端機。

### 筆記型電腦顯示器的延伸和鏡像

當你將外接螢幕連接到筆記型電腦時，畫面會自動延伸。但你可以使用 Omarchy 選單中的 _觸發 > 硬體_ 或 `Super + Ctrl + Alt + Delete`，將它改為鏡像。如果那個外接螢幕是投影機，而你想在工作的同時展示某些內容，這就特別有幫助。

當你正在使用延伸模式時，蓋上筆記型電腦的上蓋會自動關閉內建螢幕。打開上蓋則會將它重新開啟。你也可以使用 Omarchy 選單中的 _觸發 > 硬體_ 或 `Super + Ctrl + Delete`，手動控制這項功能。

### 安排多個螢幕

Hyprland 非常適合多螢幕使用。在 [Hyprland 顯示器文件中](https://wiki.hypr.land/Configuring/Basics/Monitors/) 閱讀更多關於如何配置它們的內容。在 Omarchy 中，這些設定會以 `hl.monitor` 項目寫入 `~/.config/hypr/monitors.lua`，該檔案附有註解範例，說明如何將特定顯示器固定為某種解析度、位置和旋轉方向。

每台顯示器都有各自的 1 到 10 號工作區，因此 `Super + 1` 永遠代表你目前所在顯示器的第一個工作區。在幕後，Hyprland 仍然會跨所有顯示器為工作區編號：你的筆記型電腦螢幕（或第一台顯示器）會分到 1–10，下一台顯示器是 11–20，依此類推，而且每台顯示器每次接上時，都會保留自己的編號區間。如果你要為特定顯示器撰寫[工作區規則](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)或視窗規則，請使用那些編號，因此工作區 12 就是你第二台顯示器的第二個工作區。`~/.local/state/omarchy/monitor-workspaces` 會列出每台顯示器所擁有的區間。

方向鍵可以在版面配置中共用邊緣的顯示器之間運作。只在角落相接，或之間留有空隙的螢幕，並不是相鄰的螢幕，因此請使用 `Ctrl + Alt + Tab` 在它們之間移動。

| 快捷鍵 | 跨顯示器 |
| --- | --- |
| `Super + Arrow` | 當該方向已經沒有視窗時，將焦點移到該側的顯示器 |
| `Super + Shift + Arrow` | 與該側顯示器上的一個視窗交換 |
| `Super + Alt + Arrow` | 將視窗移到該側顯示器上的一個群組中 |
| `Super + Shift + Ctrl + Arrow` | 將視窗移到該側的顯示器上，並放到它目前顯示的工作區 |
| `Super + Shift + Alt + Arrow` | 將工作區移到該側的顯示器上，如果其編號未被占用則保持不變 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 無論版面配置為何，都將焦點移到下一台或上一台顯示器 |
| `Super + 1-0`、`Super + Tab`、`Super + Scroll Wheel` | 停留在你目前所在的顯示器上 |

如果你想要一個 TUI 來協助你定位多個螢幕，你也可以參考 [Hyprmon](https://github.com/erans/hyprmon/)。

### 控制亮度

顯示器亮度由專用的亮度增減功能鍵控制。如果你按住 Shift 再按這些按鍵，你就會直接跳到最大或最小亮度。這些按鍵控制的是你目前焦點所在的顯示器，因此支援 DDC/CI 的外接顯示器會以和筆記型電腦螢幕相同的方式調整。

### Apple 顯示器

如果你使用的是 Apple 顯示器，只要你的焦點位於 Apple 顯示器上，鍵盤上一般的亮度按鍵也會自動運作。這是透過 `asdcontrol` 指令完成的。

請注意，如果你使用的是 Apple 6K XDR 顯示器，你可能會在 `hyprctl monitors` 清單中看到一個幻影螢幕。你可以透過 _設定 > 顯示器_，使用類似 `hl.monitor({ output = "DP-2", disabled = true })` 的設定將它關閉。

在 Intel 機器上，你應該使用一般的 Thunderbolt 線材連接 Apple 顯示器。在其他沒有 Thunderbolt 的機器上，你通常必須使用一條 [DP + USB-A -> USB-C 線材](https://www.amazon.com/dp/B0BNX7MS6N) 才能讓它運作。
