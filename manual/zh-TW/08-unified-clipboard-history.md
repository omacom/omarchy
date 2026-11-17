# 統一剪貼簿與歷史紀錄

在 Linux 上，通常你要在終端機裡用 `Ctrl + Shift + C/V` 複製貼上，在其他所有地方則用 `Ctrl + C/V`。對於不是在 Linux 環境下土生土長的人來說，這很難習慣！如果你是從 Mac 轉過來的，從 super 切換到 ctrl 也一樣難習慣。

Omarchy 用統一的剪貼簿快捷鍵解決了這兩個問題，在（幾乎）所有地方都能用。它們是：

| 快捷鍵 | 操作 |
| ------- | ----------- |
| Super + A | 全選 |
| Super + C | 複製 |
| Super + X | 剪下 |
| Super + V | 貼上 |
| Super + Ctrl + V | 剪貼簿歷史紀錄 |

_請注意，大多數 agent harnesses 會用 `Ctrl + V` 貼上圖片，但用 `Super + V` 貼上文字。_

在有焦點的文字欄位或其他支援 `Ctrl + A` 的應用程式中，用 `Super + A`，然後用 `Super + C` 來複製所有內容。在終端機中，`Ctrl + A` 是移到命令列開頭，而不是選取其中的文字。

### 剪貼簿歷史紀錄

剪貼簿歷史紀錄由 Omarchy shell 提供，文字和圖片都支援。你用 `Super + Ctrl + V` 觸發它，用 return 選取項目，接著該項目就會放到剪貼簿上，準備好讓你用 `Super + V` 貼上。

 ![clipboard-history](images/clipboard-history.webp)

你也可以直接開始輸入來搜尋歷史紀錄：

 ![clipboard-history-search](images/clipboard-history-search.webp)
