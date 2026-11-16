# 常見調整

這是一些對 Omarchy 設定進行常見客製調整的彙整。請注意，系統更新偶爾可能需要將某些設定還原到原始狀態。如果發生這種情況，你的變更不會遺失，而是會被放進同一個目錄下的 `.bak` 檔案中。

如果你把什麼東西搞砸了，可以透過 Omarchy 選單中的 _更新 > 設定_ 將個別設定還原到原始狀態。如果你 _真的_ 把一切都搞砸了，可以透過 `omarchy-reinstall` 重設所有設定。

### 永遠顯示所有系統匣圖示

預設情況下，像 Dropbox、1password 或 Steam 這類系統匣圖示會藏在系統匣展開箭頭後面，將滑鼠懸停在箭頭上時才會顯示。如果你想讓它們一直露出來，在展開箭頭上按右鍵開啟系統匣圖示管理器，然後釘選你想保持可見的圖示（你也可以把永遠不想看到的圖示藏起來）。

### 圓角視窗邊角

Omarchy 的預設設計是方角，但如果你想讓它柔和一點，可以修改 `~/.config/hypr/looknfeel.lua`，讓 rounding 不再被註解掉：

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### 移除視窗間距

在筆電顯示器上，有些人不喜歡把任何像素浪費在視窗間距上（甚至是選單列，你可以用 `Super + Shift + Space` 把它關掉）。你可以用 `Super + Shift + Backspace` 一次關閉所有間距和邊框，或透過移除 `~/.config/hypr/looknfeel.lua` 中這個區塊的註解來永久移除它們：

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
