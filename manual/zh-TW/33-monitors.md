# 顯示器

Omarchy 預設假設你使用的是支援 2x 的 Retina 等級顯示器。你需要這種顯示器，才能得到漂亮、清晰的程式設計字體。幾乎所有搭載高解析度螢幕的新款高階筆電都是為此最佳化的。如果你要使用 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/)，你就會想這樣執行。

但如果你的顯示器 PPI 未達 218 以上，你就會想變更顯示器設定。例如，如果你有 27" 或 32" 4K 顯示器，你可以從頂部列的顯示器面板為它挑選分數縮放比例，或開啟 `~/.config/hypr/monitors.lua` 並切換為該組合的建議設定，為每台顯示器設定預設值：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

如果你使用的是 1080p 或 1440p 顯示器，你可能只想使用 1x 縮放，GTK 與 X11 應用程式也是如此，所以你可以使用：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` 的變更會套用到變更後啟動的應用程式（而且 GTK 只接受整數，所以請將它保持在最接近你的顯示器縮放比例的整數）。所以變更後，請務必結束那些尺寸過大的視窗（或用 `Ctrl + Alt + Del` 關閉所有視窗！）。

你也可以使用 `Super + /` 提高、使用 `Super + Alt + /` 降低，快速逐步切換主要的顯示器縮放比例（1x、1.25x、1.6x、2x、3x、4x），或從頂部列的顯示器面板挑選一個。這些只會變更你目前聚焦的顯示器，所以筆電螢幕與外接顯示器可以各自有自己的縮放比例。該面板也會設定每台顯示器的解析度、更新率與旋轉方向。你的選擇會針對該實體顯示器儲存在 `~/.local/state/omarchy/monitors/settings`，所以重新開機後仍會保留，而且無論該顯示器下次接到哪個連接埠或擴充基座，都會跟著走。它們的優先順序高於 `~/.config/hypr/monitors.lua` 中針對同一台顯示器的任何規則，而 Omarchy 永遠不會編輯該檔案。如果你寧願完全在該檔案中設定你的顯示器，請在其中加入 `omarchy_monitor_panel_settings = false`，面板所做的變更就只會持續到 Hyprland 重新載入為止。由於 `GDK_SCALE` 是所有螢幕共用的一個值，所選的縮放比例會以縮放比例最低的顯示器來設定它，所以 X11 應用程式在密度較高的螢幕上會顯示得稍小一點，而不是在另一台螢幕上過大。

### 讓文字變大或變小

顯示器縮放會改變所有東西的大小。如果你只想要更大或更小的_文字_，有一個專門的旋鈕可以調整：

```
omarchy display text size 14
```

它接受 9 到 20 之間的像素大小，並會讓 Omarchy shell、GTK 應用程式與你的終端機一起調整，所以整個桌面會保持比例。不帶引數執行它，就可以看到你目前的設定，用 `omarchy display text size reset` 則可以回到預設值。Foot 是唯一落後的：它沒有重新載入設定的方法，所以已在執行中的終端機會保持舊的大小，直到你開啟一個新的終端機為止。

### 延伸與鏡像筆電顯示器

當你把外接螢幕連接到筆電時，顯示會自動延伸。但你可以透過頂部列顯示器面板中的 _Extend_ | _Mirror_、Omarchy 選單中的 _Trigger > Hardware_，或 `Super + Ctrl + Alt + Delete`，把它改為鏡像。如果那台外接螢幕是投影機，而你想在工作時展示某些內容，這就特別有幫助。

當你使用延伸模式時，闔上筆電上蓋會自動關閉內建螢幕。打開上蓋則會把它重新開啟。你也可以使用 Omarchy 選單中的 _Trigger > Hardware_ 或 `Super + Ctrl + Delete` 手動控制。

筆電接著電源時，闔上上蓋永遠不會讓它進入睡眠，所以即使外接螢幕短暫中斷連線，已接上擴充基座的筆電也會保持清醒。沒有連接外接螢幕時，在電源供電下闔上上蓋只會鎖定它。使用電池時，闔上上蓋會如常暫停。

### 排列多台螢幕

Hyprland 在多台螢幕下運作得很好。頂部列的顯示器面板會按照它們所在的位置繪製它們：將一台拖到另一台的側邊，就能把它移到那裡，而且這個排列會與每台顯示器的其他設定一起儲存。若有任何面板未涵蓋的功能，請進一步閱讀 [Hyprland 顯示器文件](https://wiki.hypr.land/Configuring/Basics/Monitors/)，瞭解如何佈局它們。在 Omarchy 中，這些會以 `hl.monitor` 項目寫入 `~/.config/hypr/monitors.lua`——該檔案隨附了註解範例，說明如何關閉一台顯示器、使用面板未提供的模式、10-bit 色彩，以及可變更新率。

每台顯示器都有它自己的工作區 1 到 10，所以 `Super + 1` 永遠代表你所在顯示器的第一個工作區。在幕後，Hyprland 仍會跨所有顯示器為工作區編號：你的筆電螢幕（或第一台顯示器）會得到 1–10，下一台顯示器是 11–20，依此類推，而且每台顯示器每次接上時都會保留它自己的區塊。如果你為特定顯示器撰寫[工作區規則](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)或視窗規則，請使用這些編號，所以工作區 12 就是你的第二台顯示器的第二個工作區。`~/.local/state/omarchy/monitors/workspaces` 會列出每台顯示器擁有的區塊。

方向鍵可以在你的佈局中共用一條邊的顯示器之間運作。只在角落相接，或之間有間隙的螢幕，並不是相鄰的，所以請使用 `Ctrl + Alt + Tab` 在它們之間移動。

| Hotkey | Across monitors |
| --- | --- |
| `Super + Arrow` | 當該方向已經沒有視窗時，將焦點移到該側的顯示器 |
| `Super + Shift + Arrow` | 與該側顯示器上的視窗交換 |
| `Super + Alt + Arrow` | 將視窗移到該側顯示器上的一個群組 |
| `Super + Shift + Ctrl + Arrow` | 將視窗移到該側的顯示器，並移到它正在顯示的工作區 |
| `Super + Shift + Alt + Arrow` | 將工作區移到該側的顯示器，如果它的編號未被占用就保持該編號 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 將焦點移到下一台或上一台顯示器，無論佈局如何 |
| `Super + 1-0`、`Super + Tab`、`Super + Scroll Wheel` | 停留在你所在的顯示器 |

如果你想要一個 TUI 來協助你定位多台螢幕，你也可以看看 [Hyprmon](https://github.com/erans/hyprmon/)。

### 控制亮度

顯示器亮度由專用的亮度提高／降低功能鍵控制。如果你按住 shift 再按下這些鍵，你會直接到最大或最小亮度。這些按鍵會控制你目前聚焦的顯示器，所以支援 DDC/CI 的外接顯示器也會以與筆電螢幕相同的方式調整。

### Apple 顯示器

如果你使用的是 Apple 顯示器，只要你聚焦在該 Apple 顯示器上，一般的鍵盤亮度鍵也會自動運作。這是透過 `asdcontrol` 命令完成的。

請注意，如果你使用的是 Apple 6K XDR 顯示器，你可能會在 `hyprctl monitors` 清單中看到一個幽靈螢幕。你可以在 `~/.config/hypr/monitors.lua` 中用類似 `hl.monitor({ output = "DP-2", disabled = true })` 的設定把它關閉。

在 Intel 機器上，你應該使用一般的 Thunderbolt 連接線連接 Apple 顯示器。在其他沒有 Thunderbolt 的機器上，你通常必須使用一條 [DP + USB-A -> USB-C 連接線](https://www.amazon.com/dp/B0BNX7MS6N) 才能讓它運作。
