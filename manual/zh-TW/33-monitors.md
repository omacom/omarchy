# 顯示器

Omarchy 預設假設你使用的是一台支援 2x 的 retina 等級顯示器。這正是你獲得那種漂亮、銳利的程式設計字體所需要的條件。幾乎所有配備高解析度螢幕的新款高階筆記型電腦都是針對這一點最佳化的。對於 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 來說，這正是你會想要的設定。

但如果你的顯示器 PPI 沒有達到 218 或以上，你就會想變更顯示器設定。舉例來說，如果你使用的是 27" 或 32" 4K 顯示器，你可以從頂部列的顯示器面板為它選一個分數縮放比例，或者開啟 `~/.config/hypr/monitors.lua`，並切換成該組合的建議值，來為每一台顯示器設定預設值：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

如果你使用的是 1080p 或 1440p 顯示器，你大概只需要使用 1x 縮放，GTK 與 X11 應用程式也相同，因此你可以使用：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

對 `GDK_SCALE` 的變更只會套用到變更後才啟動的應用程式（而且 GTK 只接受整數，所以請將它保持在最接近你顯示器縮放比例的整數）。因此，在變更後，請務必結束那些尺寸過大的視窗（或者用 `Ctrl + Alt + Del` 關閉所有視窗！）。

你也可以使用 `Super + /` 快速切換到更高一級的主要顯示器縮放比例（1x、1.25x、1.6x、2x、3x、4x），用 `Super + Alt + /` 切換到更低一級，或者從頂部列的顯示器面板中選取一個。這些變更只會影響你目前聚焦的顯示器，因此筆記型電腦螢幕與外接顯示器可以各自有自己的縮放比例。該面板也能設定每台顯示器的解析度。你的選擇會針對該台實體顯示器儲存在 `~/.local/state/omarchy/monitors/settings`，因此它們在重新開機後依然保留，也會跟著顯示器移動到它下次插入的任何連接埠或底座。它們的優先順序高於 `~/.config/hypr/monitors.lua` 中針對同一台顯示器的任何規則，而 Omarchy 永遠不會編輯那個檔案。如果你偏好完全在該檔案中設定你的顯示器，請在其中加入 `omarchy_monitor_panel_settings = false`，這樣面板的變更就只會持續到 Hyprland 重新載入為止。由於 `GDK_SCALE` 對所有螢幕只有單一數值，所選的縮放比例會以縮放比例最低的那台顯示器來設定它，因此 X11 應用程式在密度較高的螢幕上會稍小一些，而不是在另一台螢幕上變得過大。

### 讓文字變大或變小

顯示器縮放會改變所有東西的大小。如果你只想要更大或更小的_文字_，有一個專門的調整鈕可以辦到：

```
omarchy display text size 14
```

它的參數是 9 到 20 之間的像素大小，並會同時調整 Omarchy 殼層、GTK 應用程式和你的終端機，讓整個桌面保持比例。直接執行而不帶參數，可以查看你目前的設定；`omarchy display text size reset` 則可以回到預設值。Foot 是唯一一個落單者：它沒有辦法重新載入自己的設定，所以正在執行的終端機會保留舊的大小，直到你開啟一個新的為止。

### 延伸與鏡像筆記型電腦顯示器

當你把外接螢幕連接到筆記型電腦時，顯示器會自動延伸。但你可以使用 Omarchy 選單中的 _Trigger > Hardware_ 或 `Super + Ctrl + Alt + Delete`，把它改為改用鏡像模式。如果那台外接螢幕是投影機、而且你想要在工作的同時顯示一些內容，這會特別有幫助。

當你正在延伸顯示時，蓋上筆記型電腦的上蓋會自動關閉內建螢幕。打開上蓋則會把它重新開啟。你也可以使用 Omarchy 選單中的 _Trigger > Hardware_ 或 `Super + Ctrl + Delete` 來手動控制這一點。

### 安排多台螢幕

Hyprland 搭配多台螢幕運作得非常好。頂部列的顯示器面板會按照它們實際所在的位置繪製它們：將一台拖到另一台的側邊，就能把它移動到那裡，而且這樣的排列方式會隨著每台顯示器的其他設定一併儲存。對於面板沒有涵蓋的部分，請在 [Hyprland 顯示器文件](https://wiki.hypr.land/Configuring/Basics/Monitors/)中進一步了解如何排列它們。在 Omarchy 中，這些設定以 `hl.monitor` 項目存放在 `~/.config/hypr/monitors.lua`——該檔案附有註解範例，說明如何將特定顯示器固定為某個解析度、位置與旋轉角度。

每台顯示器都有自己專屬的工作區 1 到 10，因此 `Super + 1` 永遠是指你目前所在顯示器的第一個工作區。在背後，Hyprland 仍然會跨所有顯示器編排工作區的編號：你的筆記型電腦螢幕（或第一台顯示器）獲得 1–10，下一台顯示器是 11–20，依此類推，而且每台顯示器每次插入時都會保留自己的分區。如果你要針對特定顯示器撰寫[工作區規則](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)或視窗規則，請使用這些編號，這樣工作區 12 就是你第二台顯示器的第二個工作區。`~/.local/state/omarchy/monitors/workspaces` 會列出每台顯示器擁有哪一個分區。

方向鍵適用於在你的排列中共用一條邊緣的顯示器。只在一個角落接觸、或者彼此之間有間隙的螢幕並不算是相鄰的，因此請使用 `Ctrl + Alt + Tab` 在它們之間移動。

| 快速鍵 | 跨顯示器 |
| --- | --- |
| `Super + Arrow` | 一旦該方向不再有任何視窗，便將焦點移到該側的顯示器 |
| `Super + Shift + Arrow` | 與該側顯示器上的一個視窗交換位置 |
| `Super + Alt + Arrow` | 將視窗移到該側顯示器上的一個群組中 |
| `Super + Shift + Ctrl + Arrow` | 將視窗移到該側的顯示器，並放到它目前顯示的工作區上 |
| `Super + Shift + Alt + Arrow` | 將工作區移到該側的顯示器，若編號空著，便保留其編號 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 無論排列如何，都將焦點移到下一台或上一台顯示器 |
| `Super + 1-0`、`Super + Tab`、`Super + Scroll Wheel` | 停留在你目前所在的顯示器上 |

你也可以看看 [Hyprmon](https://github.com/erans/hyprmon/)，如果你想要一個 TUI 來協助你定位多台螢幕的話。

### 控制亮度

顯示器的亮度由專用的亮度調高／調低功能鍵控制。如果你按這些按鍵的同時按住 shift，就會直接切換到最大或最小亮度。這些按鍵控制的是你目前聚焦的顯示器，因此支援 DDC/CI 的外接顯示器也會以與筆記型電腦螢幕相同的方式調整亮度。

### Apple 顯示器

如果你使用的是 Apple 顯示器，只要你聚焦在該 Apple 顯示器上，一般的鍵盤亮度按鍵也會自動運作。這是透過 `asdcontrol` 指令實現的。

請注意，如果你使用的是 Apple 6K XDR 顯示器，你可能會在 `hyprctl monitors` 清單中看到一個幽靈螢幕。你可以在 `~/.config/hypr/monitors.lua` 中用類似 `hl.monitor({ output = "DP-2", disabled = true })` 這樣的設定將它關閉。

在 Intel 機器上，你應該使用一般的 Thunderbolt 線材來連接到 Apple 顯示器。在其他沒有 Thunderbolt 的機器上，你通常必須使用一條 [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) 才能讓它運作。
