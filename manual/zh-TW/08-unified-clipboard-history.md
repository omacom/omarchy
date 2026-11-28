# 統一剪貼簿與歷史記錄

通常在 Linux 上，你在終端機裡需要用 `Ctrl + Shift + C/V` 來複製貼上，在其他地方則要用 `Ctrl + C/V`。對於不是從小在 Linux 環境長大的人來說，這真的很難適應！如果你是從 Mac 轉過來的，從 super 切換到 ctrl 也一樣難適應。

Omarchy 用統一的剪貼簿快捷鍵解決了這兩個問題，（幾乎）在任何地方都能用。它們是：

| Hotkey | Command |
| ------- | ----------- |
| Super + A | 全選 |
| Super + C | 複製 |
| Super + X | 剪下 |
| Super + V | 貼上 |
| Super + Ctrl + V | 剪貼簿歷史記錄 |

_請注意，大多數 agent harness 會用 `Ctrl + V` 貼上圖片，但用 `Super + V` 貼上文字。_

用 `Super + A`，再用 `Super + C`，就能複製已聚焦的文字欄位或其他支援 `Ctrl + A` 的應用程式中的全部內容。在終端機中，`Ctrl + A` 會移動到指令行的開頭，而不是選取其文字。

### 剪貼簿歷史記錄

剪貼簿歷史記錄由 Omarchy shell 提供，文字和圖片都適用。你可以用 `Super + Ctrl + V` 觸發它，並用 return 選取你要的項目，它就會直接貼到你剛才所在的應用程式中。用 `Shift + Return` 只會將它複製到剪貼簿，用 `Alt + Return` 會開啟它，用 `Delete` 會將它從歷史記錄中移除，用 `Shift + Delete` 則會清除整個歷史記錄。

 ![clipboard-history](images/clipboard-history.webp)

你也可以直接開始輸入，來搜尋歷史記錄：

 ![clipboard-history-search](images/clipboard-history-search.webp)
