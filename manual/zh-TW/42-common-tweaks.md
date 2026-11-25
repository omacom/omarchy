# 常見調整

這是針對 Omarchy 設定的一些常見客製調整集合。請注意，系統更新有時可能需要將某些設定還原成原始狀態。如果發生這種情況，你的變更不會遺失，而是會放在原始檔案旁邊的 `.bak.<timestamp>` 檔案中。

如果你搞砸了，可以透過 Omarchy 選單中的 _更新 > 設定_ 將個別設定還原成原始設定。如果你真的把一切都搞砸了，可以透過 `omarchy reinstall configs` 重設所有設定，或使用 `omarchy reinstall` 重新安裝所有預設套件和設定。

### 隨時顯示所有系統匣圖示

依預設，Dropbox、1password 或 Steam 等系統匣圖示會隱藏在系統匣展開箭頭後面，將滑鼠游標移到上面時就會顯示出來。如果你想讓它們隨時顯示，請以滑鼠右鍵按一下展開箭頭，開啟系統匣圖示管理員，然後釘選你想保持可見的圖示（你也可以隱藏那些你永遠不想看到的圖示）。

### 圓角視窗邊角

Omarchy 的預設設計是直角邊角，但如果你想讓它柔和一點，請在 Omarchy 選單中選擇 _外觀 > 視窗 > 視窗邊角 > 圓角_，或執行 `omarchy hyprland corners rounded`。_主題邊角_ 會回到主題所使用的設定。若要選擇自己的圓角半徑，請保持在 _主題邊角_（`omarchy hyprland corners theme`），因為 Rounded 和 Sharp 會在你的設定之後載入並覆蓋它，並將 `~/.config/hypr/looknfeel.lua` 中的 rounding 取消註解：

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### 移除視窗間隙

在筆記型電腦螢幕上，有些人不喜歡在視窗間隙上浪費任何像素（甚至是頂部列，你可以用 `Super + Shift + Space` 將它切換關閉）。你可以用 `Super + Shift + Backspace` 切換關閉所有間隙和邊框，或透過移除 `~/.config/hypr/looknfeel.lua` 這一段中的註解，永久移除它們：

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
