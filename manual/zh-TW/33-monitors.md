# 螢幕

Omarchy 預設假設你使用的是支援 2x 的 Retina 等級顯示器。這正是你要有漂亮、銳利的程式設計師字體所需要的。幾乎所有搭載高解析度螢幕的新款高階筆電都是為此最佳化的。這正是你會想用在 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 上的規格。

但如果你用的顯示器 PPI 沒有達到 218 以上，你就會想改螢幕設定。例如，如果你有一台 27" 或 32" 4K 螢幕，你可以從頂部列的螢幕面板為它挑選一個分數縮放比例，或是開啟 `~/.config/hypr/monitors.lua`，將該組合的建議值設為每台螢幕的預設值：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

如果你使用的是 1080p 或 1440p 顯示器，你大概只想用 1x 縮放，GTK 和 X11 應用程式也設成一樣，所以你可以這樣用：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

對 `GDK_SCALE` 的變更只會套用到變更後啟動的應用程式（而且 GTK 只接受整數，所以請把它保持在最接近你螢幕縮放比例的整數）。所以變更後，務必把那些尺寸過大的視窗關掉（或是用 `Ctrl + Alt + Del` 關閉所有視窗！）。

你也可以用 `Super + /` 往上、`Super + Alt + /` 往下，快速切換主要的螢幕縮放比例（1x、1.25x、1.6x、2x、3x、4x），或是從頂部列的螢幕面板挑選一個。這些只會變更你目前焦點所在的螢幕，所以筆電螢幕和外接顯示器可以各有自己的縮放比例。這個面板也會設定每台螢幕的解析度、更新率和旋轉方向。你的選擇會針對該實體螢幕儲存在 `~/.local/state/omarchy/monitors/settings`，所以重新開機後依然保留，也會跟著螢幕走到下次插上的任何連接埠或擴充基座。它們的優先順序高於 `~/.config/hypr/monitors.lua` 中針對同一台螢幕的任何規則，而 Omarchy 永遠不會編輯那個檔案。如果你寧願完全在該檔案中設定螢幕，請在其中加入 `omarchy_monitor_panel_settings = false`，這樣面板的變更就只會持續到 Hyprland 重新載入為止。由於 `GDK_SCALE` 是所有螢幕共用的一個值，所選的縮放比例會以縮放比例最低的螢幕來設定它，所以 X11 應用程式在密度較高的螢幕上會稍微小一點，而不是在另一台螢幕上過大。

### 讓文字變大或變小

螢幕縮放會改變所有東西的大小。如果你只想要更大或更小的_文字_，有一個專門的旋鈕可以調：

```
omarchy display text size 14
```

它接受 9 到 20 之間的像素大小，並會同時調整 Omarchy shell、GTK 應用程式和你的終端機，讓整個桌面保持比例。不帶引數執行它可以查看你目前的設定，用 `omarchy display text size reset` 則可以回到預設值。Foot 是唯一落隊的那個：它沒有重新載入設定的方法，所以執行中的終端機會保持舊大小，直到你開啟一個新的。

### 延伸與鏡像筆電螢幕

當你把外接螢幕接到筆電上時，顯示會自動延伸。但你可以用 Omarchy 選單中的 _Trigger > Hardware_ 或 `Super + Ctrl + Alt + Delete` 把它改成鏡像。這在外接螢幕是投影機、而你想一邊工作一邊展示內容時特別有幫助。

當你使用延伸模式時，闔上筆電蓋子會自動關閉內建螢幕。打開蓋子會把它重新開啟。你也可以用 Omarchy 選單中的 _Trigger > Hardware_ 或 `Super + Ctrl + Delete` 手動控制。

### 排列多個螢幕

Hyprland 處理多個螢幕非常出色。頂部列的螢幕面板會依它們實際所在的位置繪製它們：把一台拖到另一台的側邊就能移到那裡，排列方式會連同每台螢幕的其他設定一起儲存。對於面板沒有涵蓋的任何功能，請在 [Hyprland 螢幕文件](https://wiki.hypr.land/Configuring/Basics/Monitors/)中閱讀更多關於如何排列它們的資訊。在 Omarchy 中，這些會以 `hl.monitor` 條目的形式放在 `~/.config/hypr/monitors.lua` 中 — 該檔案附有註解範例，說明如何保持一台螢幕關閉、使用面板沒有提供的模式、10-bit 色彩，以及可變更新率。

每台螢幕都有各自的 1 到 10 號工作區，所以 `Super + 1` 永遠代表你所在螢幕的第一個工作區。在幕後，Hyprland 仍然會跨所有螢幕編號工作區：你的筆電螢幕（或第一台螢幕）會拿到 1–10，下一台螢幕拿到 11–20，依此類推，而且每次你插上螢幕時，每台螢幕都會保留自己的區塊。如果你為特定螢幕編寫[工作區規則](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)或視窗規則，請使用那些編號，所以 12 號工作區就是你第二台螢幕的第二個工作區。`~/.local/state/omarchy/monitors/workspaces` 會列出每台螢幕擁有的區塊。

方向鍵可以在版面中共享一條邊的螢幕之間運作。只在一個角落相碰的螢幕，或彼此之間有間隙的螢幕，並不是鄰居，所以請用 `Ctrl + Alt + Tab` 在它們之間移動。

| 快捷鍵 | 跨螢幕 |
| --- | --- |
| `Super + Arrow` | 當該方向已沒有視窗時，將焦點移到該側的螢幕 |
| `Super + Shift + Arrow` | 與該側螢幕上的一個視窗交換 |
| `Super + Alt + Arrow` | 將視窗移到該側螢幕上的一個群組中 |
| `Super + Shift + Ctrl + Arrow` | 將視窗移到該側的螢幕，放到它目前顯示的工作區上 |
| `Super + Shift + Alt + Arrow` | 將工作區移到該側的螢幕，如果編號未被占用則保持其編號 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 不論版面如何，將焦點移到下一台或上一台螢幕 |
| `Super + 1-0`、`Super + Tab`、`Super + Scroll Wheel` | 停留在你目前所在的螢幕 |

如果你想要一個 TUI 來協助你定位多個螢幕，也可以看看 [Hyprmon](https://github.com/erans/hyprmon/)。

### 控制亮度

螢幕亮度由專用的亮度提高／降低功能鍵控制。如果你按住 shift 同時按下這些鍵，就會直接到最大或最小亮度。這些鍵會控制你目前焦點所在的顯示器，所以支援 DDC/CI 的外接螢幕會以與筆電螢幕相同的方式調整。

### Apple 顯示器

如果你使用的是 Apple 顯示器，只要你的焦點在 Apple 顯示器上，一般的鍵盤亮度鍵也會自動運作。這是透過 `asdcontrol` 指令完成的。

請注意，如果你使用的是 Apple 6K XDR 顯示器，你可能會在 `hyprctl monitors` 清單中看到一個幻影螢幕。你可以在 `~/.config/hypr/monitors.lua` 中用像 `hl.monitor({ output = "DP-2", disabled = true })` 這樣的設定把它關掉。

在 Intel 機器上，你應該用一般的 Thunderbolt 線來連接 Apple 顯示器。在其他沒有 Thunderbolt 的機器上，你通常必須使用 [DP + USB-A 轉 USB-C 線材](https://www.amazon.com/dp/B0BNX7MS6N)才能讓它運作。
