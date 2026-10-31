# 顯示器

Omarchy 預設假設你使用的是支援 2x 的 retina 等級顯示器。這正是你取得漂亮、清晰的程式設計字體所需的條件。這也是幾乎所有搭載高解析度螢幕的新款高階筆電所最佳化的目標。這也是你會想在 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 上使用的設定。

但如果你使用的顯示器 PPI 沒有達到 218 以上，你就會想變更顯示器設定。例如，如果你有 27" 或 32" 4K 顯示器，你可以從頂部列的顯示器面板為它選取分數縮放比例，或開啟 `~/.config/hypr/monitors.lua` 並切換為該組合的建議值，為每一台顯示器設定預設值：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

如果你使用的是 1080p 或 1440p 顯示器，你大概會想使用 1x 縮放，GTK 和 X11 應用程式也一樣，所以你可以使用：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` 的變更會套用到變更後啟動的應用程式（而且 GTK 只接受整數，所以請將它保持在最接近你顯示器縮放比例的整數）。所以變更後，請務必退出那些你開啟的尺寸過大的視窗（或用 `Ctrl + Alt + Del` 關閉所有視窗！）。

你也可以使用 `Super + /` 快速依序切換主要的顯示器縮放比例（1x、1.25x、1.6x、2x、3x、4x）往上調，並使用 `Super + Alt + /` 往下調，或從頂部列的顯示器面板中選取一個。這些只會變更你目前聚焦的顯示器，所以筆電螢幕和外接顯示器可以各自有自己的縮放比例。該面板也能設定每台顯示器的解析度。你的選擇會針對該實體顯示器儲存在 `~/.local/state/omarchy/monitors/settings`，所以重新開機後仍會保留，且無論該顯示器下次接在哪個連接埠或擴充座上都會跟著它。這些設定優先於 `~/.config/hypr/monitors.lua` 中針對同一台顯示器的任何規則，而 Omarchy 永遠不會編輯該檔案。由於 `GDK_SCALE` 對所有螢幕只有一個值，所選的縮放比例會以縮放比例最低的顯示器為準來設定它，所以 X11 應用程式在密度較高的螢幕上會稍微小一點，而不是在另一台螢幕上過大。

### 讓文字變大或變小

顯示器縮放會變更所有東西的大小。如果你只想讓_文字_變大或變小，有一個專門的旋鈕可以調整：

```
omarchy display text size 14
```

這需要一個介於 9 到 20 之間的像素大小，並會同時調整 Omarchy shell、GTK 應用程式和你的終端機，讓整個桌面保持一致的比例。不帶參數執行它可以查看你目前的設定，使用 `omarchy display text size reset` 可以回到預設值。Foot 是唯一落後的那一個：它沒有辦法重新載入設定，所以執行中的終端機會保留舊的大小，直到你開啟一個新的終端機。

### 延伸和鏡像筆電顯示器

當你將外接螢幕連接到筆電時，顯示器會自動延伸。但你可以使用 Omarchy 選單中的 _Trigger > Hardware_ 或 `Super + Ctrl + Alt + Delete` 將其改為鏡像。這在外接螢幕是投影機，而且你想一邊工作一邊展示內容時特別有幫助。

延伸時，蓋上筆電上蓋會自動關閉內建螢幕。打開上蓋則會重新開啟它。你也可以使用 Omarchy 選單中的 _Trigger > Hardware_ 或 `Super + Ctrl + Delete` 手動控制這一點。

### 安排多台螢幕

Hyprland 搭配多台螢幕運作得很好。頂部列的顯示器面板會按照它們所在的位置繪製它們：將一台拖到另一台的側邊就能把它移到那裡，這樣的排列會和每台顯示器的其他設定一起儲存。若有面板涵蓋不到的部分，請在 [Hyprland 顯示器文件](https://wiki.hypr.land/Configuring/Basics/Monitors/) 中閱讀更多關於如何排列它們的資訊。在 Omarchy 中，這些會以 `hl.monitor` 條目的形式寫在 `~/.config/hypr/monitors.lua` 中 — 該檔案附有註解範例，說明如何將特定顯示器固定為某個解析度、位置和旋轉方向。

每台顯示器都有自己專屬的 1 到 10 號工作區，所以 `Super + 1` 永遠表示你目前所在顯示器的第一個工作區。在幕後，Hyprland 仍然會跨所有顯示器為工作區編號：你的筆電螢幕（或第一台顯示器）會得到 1–10 號，下一台顯示器會得到 11–20 號，依此類推，而且每台顯示器每次接上時都會保留自己的區塊。如果你要為特定顯示器撰寫[工作區規則](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)或視窗規則，請使用這些編號，所以工作區 12 就是你的第二台顯示器的第二個工作區。`~/.local/state/omarchy/monitors/workspaces` 會列出每台顯示器擁有的區塊。

方向鍵可以在版面配置中共用一條邊的顯示器之間運作。只在角落接觸或彼此之間有間隙的螢幕並不相鄰，所以請使用 `Ctrl + Alt + Tab` 在它們之間移動。

| 快捷鍵 | 跨顯示器 |
| --- | --- |
| `Super + Arrow` | 當該方向已沒有視窗時，將焦點移到該側的顯示器 |
| `Super + Shift + Arrow` | 與該側顯示器上的一個視窗交換 |
| `Super + Alt + Arrow` | 將視窗移到該側顯示器上的一個群組中 |
| `Super + Shift + Ctrl + Arrow` | 將視窗移到該側的顯示器，並放到它目前顯示的工作區上 |
| `Super + Shift + Alt + Arrow` | 將工作區移到該側的顯示器，如果該編號空著就保留它 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 將焦點移到下一台或上一台顯示器，無論版面配置如何 |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | 留在你目前所在的顯示器 |

你也可以看看 [Hyprmon](https://github.com/erans/hyprmon/)，如果你想要一個 TUI 來協助你定位多台螢幕。

### 控制亮度

顯示器亮度由專用的亮度調高／調低功能鍵控制。如果你按住 Shift 同時按下這些按鍵，你將會直接跳到最大或最小亮度。這些按鍵會控制你目前聚焦的顯示器，所以支援 DDC/CI 的外接顯示器會以和筆電螢幕相同的方式調整。

### Apple 顯示器

如果你使用的是 Apple 顯示器，一般的鍵盤亮度鍵也會自動運作，前提是你聚焦在 Apple 顯示器上。這是透過 `asdcontrol` 指令完成的。

請注意，如果你使用的是 Apple 6K XDR 顯示器，你可能會在 `hyprctl monitors` 清單中看到一台幽靈螢幕。你可以在 `~/.config/hypr/monitors.lua` 中使用類似 `hl.monitor({ output = "DP-2", disabled = true })` 的設定將其關閉。

在 Intel 機器上，你應該使用一般的 Thunderbolt 連接線連接 Apple 顯示器。在其他沒有 Thunderbolt 的機器上，你通常必須使用 [DP + USB-A -> USB-C 連接線](https://www.amazon.com/dp/B0BNX7MS6N) 才能讓它運作。
