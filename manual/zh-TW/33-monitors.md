# 顯示器

Omarchy 預設假設你使用的是支援 2x 縮放的 Retina 等級顯示器。你需要這樣的顯示器，才能獲得那種漂亮又清晰銳利的程式設計字型。幾乎所有新款高階筆記型電腦的高解析度螢幕，都是針對這一點最佳化的。如果你要搭配 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/)，你也會想要这样做。

但如果你使用的顯示器 PPI 沒有達到 218 或以上，你就會想變更顯示器設定。例如，如果你使用的是 27" 或 32" 4K 顯示器，你可以開啟 `~/.config/hypr/monitors.lua`（透過 Omarchy 選單中的 _Setup > Monitors_），改用針對該組合的建議設定，來使用分數縮放：

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

如果你使用的是 1080p 或 1440p 顯示器，你大概只會想使用 1x 縮放，所以你可以使用：

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` 的變更只會套用到變更後啟動的應用程式（而且 GTK 只接受整數，所以請將它保持在最接近你的顯示器縮放值的整數）。所以，變更後請務必關閉那些尺寸過大的視窗（或是用 `Ctrl + Alt + Del` 關閉所有視窗！）。

你也可以使用 `Super + /` 往上切換、使用 `Super + Alt + /` 往下切換，快速輪流切換主要的顯示器縮放比例（1x、1.25x、1.6x、2x、3x、4x），或是從頂部列的顯示器面板中挑選一個。這些操作只會變更你目前焦點所在的顯示器，所以筆記型電腦螢幕和外接顯示器可以各自擁有自己的縮放比例。這個選擇會以該顯示器的 `hl.monitor` 規則形式儲存到 `~/.config/hypr/monitors.lua`，所以重新開機後依然有效，而且其優先順序高於 `omarchy_monitor_scale`；`omarchy_monitor_scale` 仍然是每一台沒有自己規則的顯示器所使用的縮放比例。由於 `GDK_SCALE` 對所有螢幕來說都是同一個值，這些變更會以縮放比例最低的顯示器為準來設定它，所以 X11 應用程式在像素密度較高的螢幕上會稍微小一點，而不是在另一台螢幕上過大。

### 放大或縮小文字

顯示器縮放會改變所有東西的大小。如果你只想要放大或縮小_文字_，只需要調整一個地方：

```
omarchy display text size 14
```

它接受 9 到 20 之間的像素大小，並會同時調整 Omarchy shell、GTK 應用程式和你的終端機，讓整個桌面保持一致的比例。執行時不帶參數可以查看你目前的設定，執行 `omarchy display text size reset` 則可以回到預設值。Foot 是唯一的例外：它沒有重新載入設定的方法，所以正在執行的終端機會維持舊的大小，直到你開啟一個新的終端機。

### 延伸與鏡像筆記型電腦顯示器

當你將外接螢幕連接到筆記型電腦時，畫面會自動延伸。但你可以使用 Omarchy 選單中的 _Trigger > Hardware_ 或 `Super + Ctrl + Alt + Delete`，將它改為鏡像輸出。如果那台外接螢幕是投影機，而你想在工作時展示某些內容，這就特別有幫助。

當你使用延伸模式時，蓋上筆記型電腦的上蓋會自動關閉內建螢幕。打開上蓋則會將它重新開啟。你也可以使用 Omarchy 選單中的 _Trigger > Hardware_ 或 `Super + Ctrl + Delete` 手動控制這一點。

### 排列多台螢幕

Hyprland 搭配多台螢幕的效果非常好。想了解如何安排它們的版面配置，請閱讀 [Hyprland 顯示器文件](https://wiki.hypr.land/Configuring/Basics/Monitors/)。在 Omarchy 中，這些設定會以 `hl.monitor` 項目形式放在 `~/.config/hypr/monitors.lua` 中；該檔案附有註解範例，說明如何將特定顯示器固定為某個解析度、位置與旋轉方向。

每台顯示器都有自己專屬的 1 到 10 號工作區，所以 `Super + 1` 永遠代表你目前所在顯示器的第一個工作區。在幕後，Hyprland 仍然會跨所有顯示器對工作區編號：你的筆記型電腦螢幕（或第一台顯示器）獲得 1–10，接下來的一台顯示器獲得 11–20，依此類推，而且每台顯示器每次接上時都會保留自己的編號區間。如果你要為特定顯示器撰寫[工作區規則](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)或視窗規則，請使用這些編號，所以工作區 12 就是你的第二台顯示器的第二個工作區。`~/.local/state/omarchy/monitor-workspaces` 會列出每台顯示器擁有哪一個編號區間。

方向鍵可以在版面配置中共用一條邊的顯示器之間運作。只在角落相接的螢幕，或彼此之間有間隙的螢幕，並不算是相鄰，所以請使用 `Ctrl + Alt + Tab` 在它們之間移動。

| 快速鍵 | 跨顯示器 |
| --- | --- |
| `Super + Arrow` | 當該方向已經沒有視窗時，將焦點移到該側的顯示器 |
| `Super + Shift + Arrow` | 與該側顯示器上的一個視窗交換 |
| `Super + Alt + Arrow` | 將視窗移到該側顯示器上的一個群組中 |
| `Super + Shift + Ctrl + Arrow` | 將視窗移到該側的顯示器，並放到它目前顯示的工作區上 |
| `Super + Shift + Alt + Arrow` | 將工作區移到該側的顯示器，若其編號未被占用則保持該編號 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 不論版面配置為何，將焦點移到下一台或上一台顯示器 |
| `Super + 1-0`、`Super + Tab`、`Super + Scroll Wheel` | 停留在你目前所在的顯示器上 |

如果你想要一個 TUI 來協助你定位多台螢幕，你也可以試試 [Hyprmon](https://github.com/erans/hyprmon/)。

### 控制亮度

顯示器亮度由專用的亮度增加／降低功能鍵控制。如果你按住 shift 再按這些鍵，你會直接跳到最高或最低亮度。這些按鍵控制的是你目前焦點所在的顯示器，所以支援 DDC/CI 的外接顯示器會以與筆記型電腦螢幕相同的方式調整。

### Apple 顯示器

如果你使用的是 Apple 顯示器，而且你的焦點位於該 Apple 顯示器上，一般的鍵盤亮度鍵也會自動運作。這是透過 `asdcontrol` 指令完成的。

請注意，如果你使用的是 Apple 6K XDR 顯示器，你可能會在 `hyprctl monitors` 清單中看到一個幽靈螢幕。你可以透過 _Setup > Monitors_ 使用類似 `hl.monitor({ output = "DP-2", disabled = true })` 的設定將它關閉。

在 Intel 機器上，你應該使用一般的 Thunderbolt 連接線來連接 Apple 顯示器。在其他沒有 Thunderbolt 的機器上，你通常必須使用一條 [DP + USB-A -> USB-C 連接線](https://www.amazon.com/dp/B0BNX7MS6N) 才能讓它正常運作。
