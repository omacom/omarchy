# 統一剪貼簿與紀錄

一般在 Linux 上，你需要在終端機裡用 `Ctrl + Shift + C/V` 來複製貼上，在其他地方則用 `Ctrl + C/V`。對於不是從小在 Linux 上長大的人來說，這很難習慣！如果你是從 Mac 過來的，從 Super 切換到 Ctrl 同樣不好適應。

Omarchy 用一套（幾乎）處處都能用的統一剪貼簿快捷鍵，一次解決這兩個問題。它們是：

| 快捷鍵 | 指令 |
| ------- | ----------- |
| Super + C | 複製 |
| Super + X | 剪下 |
| Super + V | 貼上 |
| Super + Ctrl + V | 剪貼簿紀錄 |

_請注意，大多數代理程式 harness 會用 `Ctrl + V` 貼上圖片，但用 `Super + V` 貼上文字。_

### 剪貼簿紀錄

剪貼簿紀錄由 Omarchy shell 提供，文字和圖片都能用。你用 `Super + Ctrl + V` 觸發它，按 Enter 選取你的項目，然後它就會被放到剪貼簿上，準備好用 `Super + V` 貼上。

 ![clipboard-history](images/clipboard-history.webp)

你也可以直接開始打字來搜尋紀錄：

 ![clipboard-history-search](images/clipboard-history-search.webp)
