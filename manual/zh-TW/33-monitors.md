# 顯示器

Omarchy 預設假定你使用的是一台支援 2x 的 Retina 等級顯示器。這正是你取得那些漂亮、銳利的程式設計字體所需要的。幾乎所有配備高解析度螢幕的新款高階筆電，都是針對這個規格最佳化的。這也是你會想在 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 上使用的設定。

但如果你使用的顯示器 PPI 未達 218 以上，你就會想變更顯示器設定。例如，如果你有一台 27" 或 32" 4K 顯示器，你可以從頂部列的顯示器面板為它選一個分數縮放比例，或是開啟 `~/.config/hypr/monitors.lua` 並切換成該組合的建議值，為每台顯示器設定預設值：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

如果你使用的是 1080p 或 1440p 顯示器，你大概只會想用 1x 縮放，GTK 和 X11 應用程式也一樣，所以你可以使用：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` 的變更會套用到變更後啟動的應用程式（而且 GTK 只接受整數，所以請將它保持在最接近你的顯示器縮放比例的整數）。所以變更後，請務必退出那些尺寸過大的視窗（或用 `Ctrl + Alt + Del` 關閉所有視窗！）。

你也可以使用 `Super + /` 快速往上切換主要的顯示器縮放比例（1x、1.25x、1.6x、2x、3x、4x），用 `Super + Alt + /` 往下切換，或從頂部列的顯示器面板選一個。這些只會變更你目前聚焦的顯示器，所以筆電螢幕和外接顯示器可以各有各自的縮放比例。該面板也會設定每台顯示器的解析度、更新率和旋轉方向。你的選擇會針對該台實體顯示器儲存在 `~/.local/state/omarchy/monitors/settings`，所以重新開機後依然有效，而且下次將它接到任何連接埠或擴充座時都會跟著它。它們的優先順序高於 `~/.config/hypr/monitors.lua` 中針對同一台顯示器的任何規則，而 Omarchy 永遠不會編輯該檔案。如果你更想完全在該檔案中設定你的顯示器，請將 `omarchy_monitor_panel_settings = false` 加入其中，面板的變更就只會持續到 Hyprland 重新載入為止。由於 `GDK_SCALE` 對所有螢幕只有一個值，所選的縮放會以縮放比例最低的顯示器來設定它，所以 X11 應用程式在密度較高的螢幕上會稍微小一點，而不是在另一台上過大。

### 讓文字變大或變小

顯示器縮放會改變所有東西的大小。如果你只想要更大或更小的_文字_，只有一個旋鈕可以調整：

```
omarchy display text size 14
```

它接受 9 到 20 之間的像素大小，並會一起調整 Omarchy shell、GTK 應用程式和你的終端機，讓整個桌面保持比例。不帶參數執行它可以查看你目前的設定，`omarchy display text size reset` 則可以回到預設值。Foot 是唯一跟不上的：它沒有重新載入設定的方法，所以正在運行的終端機會保持舊大小，直到你開啟一個新的。

### 延伸與鏡像筆電顯示器

當你將外接螢幕連接到筆電時，顯示會自動延伸。但你可以使用頂部列顯示器面板中的 _延伸_ | _鏡像_、Omarchy 選單中的 _Trigger > 硬體_，或 `Super + Ctrl + Alt + Delete`，將它改為鏡像。如果該外接螢幕是投影機，而你想一邊工作一邊放映內容，這特別有幫助。

延伸時，闔上筆電上蓋會自動關閉內建螢幕。打開上蓋會將它重新開啟。你也可以使用 Omarchy 選單中的 _Trigger > 硬體_ 或 `Super + Ctrl + Delete` 手動控制。

### 安排多個螢幕

Hyprland 在多螢幕下運作得很好。頂部列的顯示器面板會按照它們所在的位置繪製：把一台拖到另一台的側邊就能將它移到那裡，而且這個排列會與每台顯示器的其他設定一起儲存。對於面板未涵蓋的任何功能，請在 [Hyprland 顯示器文件](https://wiki.hypr.land/Configuring/Basics/Monitors/) 中閱讀更多關於如何配置它們的資訊。在 Omarchy 中，這些會以 `hl.monitor` 項目寫入 `~/.config/hypr/monitors.lua`——該檔案附有註解範例，說明如何保持顯示器關閉、面板未提供的模式、10 位元色彩，以及可變更新率。

每台顯示器都有自己的工作區 1 到 10，所以 `Super + 1` 永遠表示你所在顯示器的第一個工作區。在幕後，Hyprland 仍會跨所有顯示器為工作區編號：你的筆電螢幕（或第一台顯示器）取得 1–10，下一台顯示器是 11–20，依此類推，而且每台顯示器每次你將它接上時都會保留它的區塊。如果你為特定顯示器撰寫[工作區規則](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) 或視窗規則，請使用這些編號，所以工作區 12 是第二台顯示器的第二個工作區。`~/.local/state/omarchy/monitors/workspaces` 列出了每台顯示器擁有哪個區塊。

方向鍵可以在你的布局中共用一條邊緣的顯示器之間運作。只在角落相接、或之間有間隙的螢幕不是鄰居，所以請使用 `Ctrl + Alt + Tab` 在它們之間移動。

| 快速鍵 | 跨顯示器 |
| --- | --- |
| `Super + Arrow` | 當該方向已經沒有視窗時，將焦點移到該側的顯示器 |
| `Super + Shift + Arrow` | 與該側顯示器上的一個視窗交換 |
| `Super + Alt + Arrow` | 將視窗移到該側顯示器上的一個群組中 |
| `Super + Shift + Ctrl + Arrow` | 將視窗移到該側的顯示器，放到它正在顯示的工作區上 |
| `Super + Shift + Alt + Arrow` | 將工作區移到該側的顯示器，若編號空閒則保留其編號 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 將焦點移到下一個或上一個顯示器，不論布局為何 |
| `Super + 1-0`、`Super + Tab`、`Super + Scroll Wheel` | 停留在你目前所在的顯示器 |

你也可以查看 [Hyprmon](https://github.com/erans/hyprmon/)，如果你想要一個 TUI 來協助你定位多個螢幕。

### 控制亮度

顯示器亮度由專用的亮度提高／降低功能鍵控制。如果你按這些鍵時按住 Shift，你會直接到最大或最小亮度。這些鍵控制你目前聚焦的顯示器，所以支援 DDC/CI 的外接顯示器會以與筆電螢幕相同的方式調整。

### Apple 顯示器

如果你使用的是 Apple 顯示器，只要你聚焦在該 Apple 顯示器上，一般的鍵盤亮度鍵也會自動運作。這是透過 `asdcontrol` 命令完成的。

請注意，如果你使用的是 Apple 6K XDR 顯示器，你可能會在 `hyprctl monitors` 清單中看到一個幻影螢幕。你可以在 `~/.config/hypr/monitors.lua` 中使用類似 `hl.monitor({ output = "DP-2", disabled = true })` 的設定將它關閉。

在 Intel 機器上，你應該使用一般的 Thunderbolt 線連接到 Apple 顯示器。在其他沒有 Thunderbolt 的機器上，你通常必須使用一條 [DP + USB-A -> USB-C 線](https://www.amazon.com/dp/B0BNX7MS6N) 才能讓它運作。
