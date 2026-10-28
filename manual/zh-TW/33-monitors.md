# 螢幕

Omarchy 預設你使用的是支援 2x 的 retina 等級顯示器。這是你取得漂亮、清晰的程式設計字體所需要的條件。這是幾乎所有搭載高解析度螢幕的新款高階筆電都最佳化的目標。這也是你在 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 上會想執行的設定。

但如果你用的顯示器 PPI 沒有達到 218 以上，你會想要變更螢幕設定。舉例來說，如果你有 27" 或 32" 4K，你可以開啟 `~/.config/hypr/monitors.lua`（透過 Omarchy 選單中的 _設定 > Monitors_），切換成針對該組合的建議值，來使用分數縮放：

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

如果你使用的是 1080p 或 1440p 顯示器，你大概會只想使用 1x 縮放，這時你可以用：

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` 的變更會套用到變更後啟動的應用程式（而且 GTK 只接受整數，所以請將它保持在最接近你的螢幕縮放比例的整數）。所以變更後記得結束那些尺寸過大的視窗（或用 `Ctrl + Alt + Del` 關閉所有視窗！）。

你也可以使用 `Super + /` 往上、`Super + Alt + /` 往下，快速依序切換主要的螢幕縮放比例（1x、1.25x、1.6x、2x、3x、4x），或從頂部列的螢幕面板中挑選一個。這些只會變更你目前聚焦的那台螢幕，所以筆電螢幕和外接顯示器可以各自擁有自己的縮放比例。這個選擇會以該螢幕的 `hl.monitor` 規則形式儲存到 `~/.config/hypr/monitors.lua`，所以重新開機後仍會保留，且其優先順序高於 `omarchy_monitor_scale`，後者仍會是所有沒有自己規則的螢幕所用的縮放比例。

### 讓文字變大或變小

螢幕縮放會改變所有東西的大小。如果你只想要更大或更小的_文字_，只要調一個地方就好：

```
omarchy display text size 14
```

它接受 9 到 20 之間的像素大小，並會讓 Omarchy shell、GTK 應用程式和你的終端機一起移動，所以整個桌面會保持一樣的比例。不帶引數執行它，就能看到你目前的設定，用 `omarchy display text size reset` 就能回到預設值。Foot 是唯一的例外：它沒有辦法重新載入它的設定，所以執行中的終端機會保持舊的大小，直到你開一個新的為止。

### 延伸與鏡像筆電顯示器

當你把外接螢幕連接到筆電時，顯示畫面會自動延伸。但你可以使用 Omarchy 選單中的 _觸發 > Hardware_ 或 `Super + Ctrl + Alt + Delete`，改成鏡像輸出。如果那台外接螢幕是投影機，而且你想在工作的同時展示一些內容，這會特別有幫助。

當你使用延伸時，闔上筆電上蓋會自動關閉內建螢幕。打開上蓋就會把它再打開。你也可以使用 Omarchy 選單中的 _觸發 > Hardware_ 或 `Super + Ctrl + Delete` 手動控制這一點。

### 安排多螢幕

Hyprland 對多螢幕的支援做得很好。可以在 [Hyprland 螢幕文件](https://wiki.hypr.land/Configuring/Basics/Monitors/) 中閱讀更多如何配置它們的資訊。在 Omarchy 中，這些設定以 `hl.monitor` 條目的形式放在 `~/.config/hypr/monitors.lua` —— 該檔案附有註解範例，說明如何將特定螢幕固定為某個解析度、位置與旋轉方向。

每一台螢幕都有它自己從 1 到 10 的工作區，所以 `Super + 1` 永遠是指你所在的螢幕的第一個工作區。在幕後，Hyprland 仍然會跨所有螢幕替工作區編號：你的筆電螢幕（或第一台螢幕）會取得 1–10，下一台螢幕取得 11–20，依此類推，而且每台螢幕在你每次把它接上時都會保持自己的區塊。如果你要為特定螢幕編寫 [工作區規則](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) 或視窗規則，請使用這些編號，所以工作區 12 就是你第二台螢幕的第二個工作區。`~/.local/state/omarchy/monitor-workspaces` 會列出每台螢幕擁有哪些區塊。

方向鍵可以在你的配置中共用一條邊的螢幕之間運作。只在角落相碰的螢幕，或中間有空隙的螢幕，並不是鄰居，所以請使用 `Ctrl + Alt + Tab` 在它們之間移動。

| 快捷鍵 | 跨螢幕 |
| --- | --- |
| `Super + Arrow` | 當該方向已沒有視窗時，將焦點移到該側的螢幕 |
| `Super + Shift + Arrow` | 與該側螢幕上的一個視窗交換 |
| `Super + Alt + Arrow` | 將視窗移到該側螢幕上的一個群組中 |
| `Super + Shift + Ctrl + Arrow` | 將視窗移到該側的螢幕，並放到它正在顯示的工作區上 |
| `Super + Shift + Alt + Arrow` | 將工作區移到該側的螢幕，如果可以的話還會保持它的編號 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 將焦點移到下一台或上一台螢幕，無論配置如何 |
| `Super + 1-0`、`Super + Tab`、`Super + Scroll Wheel` | 停留在你目前所在的螢幕上 |

你也可以看看 [Hyprmon](https://github.com/erans/hyprmon/)，如果你想要一個 TUI 來幫助你安排多螢幕的位置的話。

### 控制亮度

螢幕亮度由專門的亮度調高／調低功能鍵控制。如果你在按這些鍵的同時按住 Shift，你會直接跳到最大或最小亮度。這些按鍵控制的是你目前聚焦的那台顯示器，所以支援 DDC/CI 的外接螢幕，會以和筆電螢幕相同的方式調整。

### Apple 顯示器

如果你使用的是 Apple 顯示器，只要你聚焦在 Apple 顯示器上，鍵盤上一般的亮度按鍵也會自動運作。這是透過 `asdcontrol` 命令完成的。

請注意，如果你使用的是 Apple 6K XDR 顯示器，你可能會在你的 `hyprctl monitors` 清單中看到一台幽靈螢幕。你可以透過 _設定 > Monitors_，用像 `hl.monitor({ output = "DP-2", disabled = true })` 這樣的設定把它關掉。

在 Intel 機器上，你應該使用一般的 Thunderbolt 線來連接 Apple 顯示器。在其他沒有 Thunderbolt 的機器上，你通常必須使用一條 [DP + USB-A -> USB-C 線](https://www.amazon.com/dp/B0BNX7MS6N) 才能讓它運作。
