# Neovim

[Neovim](https://neovim.io/) 是 [vi 編輯器](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) 的一個現代實作，vi 是 Bill Joy 早在 1976 年就創造出來的。它是一個模態編輯器，插入模式和指令模式是分開的；一旦你學會它那套深不可測的按鍵指令集的哪怕只是一小部分，它都有點像一種超能力。但它的學習曲線也相當陡峭！

如果你完全沒接觸過 vim 風格的編輯，我推薦你去看看 YouTube 上 [ThePrimeagen 的 Vim As Your Editor 系列](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R)。那會教你基礎。只要知道，不像那些更相似的主流編輯器，你需要花更長的時間才能在 vim 上達到基本熟練。但一旦你做到了，回報也更大。

現在 Neovim 基本上可以無限設定。如果你真的想發瘋，你可以從零開始建立你自己的 Neovim 設定。有一門很棒的課程，是 [Typecraft 講解從零設定 Neovim](https://www.youtube.com/watch?v=zHTeCSVAFNY)。而 [ThePrimeagen 也有一門](https://www.youtube.com/watch?v=w7i4amO_zaE)。

但 Omarchy 內建了一套完整的 Neovim 設定——`omarchy-nvim` 套件——它經過用心的調校，展示開箱即用能做到的最好表現。你不需要寫任何一行設定！它建立在 [LazyVim](https://www.lazyvim.org/) 之上，LazyVim 是一套 Neovim 外掛與設定的發行版。它太棒了。

## LazyVim 基礎

如前所述，我不會在這篇簡短的介紹裡教你 vim，但我可以向你展示一些 LazyVim 的基礎，以及如何四處移動。

首先，Neovim 有 leader 鍵的概念。那基本上是通往所有指令的大門。LazyVim 把它設為 `Space`。所以只要按下它、等一秒鐘，你就會看到一堆像這樣內嵌說明的選項：

以下是一些我一直都在用的基本指令：

- `Space Space` - 在目前目錄中模糊搜尋任何檔案。
- `Space S G` - 用 grep 搜尋所有檔案並附預覽。
- `Space E` - 開關檔案樹。
- `Ctrl + W W` - 在檔案樹和編輯器之間來回跳。
- `Shift + H` - 在開啟的分頁（vim 稱之為 buffer）之間向左移動。
- `Shift + L` - 在開啟的分頁之間向右移動。
- `Space B D` - 關閉一個分頁。
- `Space B O` - 關閉除了目前分頁以外的所有其他分頁。
- `Space G G` - 從目前目錄在一個浮動窗格中啟動 LazyGit。
- `Space U W` - 切換軟換行。

當你在檔案樹中時（用 `Space E` 顯示它，用 `Ctrl + W W` 跳過去），你可以用 `a` 新增一個檔案，或用 `A` 新增一個目錄。在檔案樹中按下 `?` 可以查看所有指令。

如果你想掌握基本的 vim 語言，我寫過關於[三段式語法](https://world.hey.com/dhh/wonderful-vi-a1d034d3)以及如何使出那些厲害連招的文章！

你可以在 [LazyVim 快捷鍵頁面](https://www.lazyvim.org/keymaps)查看所有可能的指令。

## 啟動 Neovim

你可以用 `Super + Shift + N` 啟動 Neovim（這個綁定會啟動你的預設編輯器，開箱即用時就是 Neovim），但通常從終端機驅動它更容易：導覽到你想工作的目錄，然後輸入 `n`。`n` 是 `nvim` 的別名，它預設會使用目前的目錄來開啟。你可以用 `n myfile.txt` 開啟單一個檔案。

## 使用 Neovim 進行 sudo 編輯

如果你需要編輯只有超級使用者才能變更的檔案，你可以執行 `sudoedit /etc/sudoers.d/00-sudo-only-file`，用上已設定好你所有外掛的 neovim。
