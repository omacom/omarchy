# Neovim

[Neovim](https://neovim.io/) 是 [vi 編輯器](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) 的現代實作，該編輯器由 Bill Joy 早在 1976 年就創造出來。它是一種模式編輯器，將插入模式與命令模式分開；一旦你學會那套深不見底的按鍵命令中哪怕只是一小部分，它簡直就是一種超能力。但它的學習曲線也確實陡峭！

如果你完全沒接觸過 vim 風格的編輯方式，我推薦你去看 YouTube 上的 [ThePrimeagen 的 Vim As Your Editor 系列](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R)。那會教你基礎知識。只是要知道，不同於其他較為相似的主流編輯器，你需要花更長的時間才能達到 vim 的基本熟練度。但一旦你學會了，回報也會更大。

如今，Neovim 基本上擁有無限的自訂空間。如果你真的想玩到極致，你可以從零開始打造自己的 Neovim 設定。Typecraft 有一門很棒的課程，講解 [如何從零開始設定 Neovim](https://www.youtube.com/watch?v=zHTeCSVAFNY)。而 [ThePrimeagen 也有一門](https://www.youtube.com/watch?v=w7i4amO_zaE)。

但 Omarchy 附帶了一套完整的 Neovim 設定——`omarchy-nvim` 套件——經過精心調整，開箱即可展現最佳的使用體驗。你不需要寫任何一行設定！它建立在 [LazyVim](https://www.lazyvim.org/) 之上，這是一套 Neovim 外掛與設定的發行版。它非常出色。

## LazyVim 基礎

正如前面提到的，我不會在這篇簡短的介紹中教你 vim，但我可以向你展示 LazyVim 的一些基礎知識，以及如何上手操作。

首先，Neovim 有 leader key 的概念。那基本上是通往所有命令的大門。LazyVim 將它設定為 `Space`。所以只要按下它，稍等一秒，你就會看到一堆選項像這樣直接顯示說明：

以下是我經常使用的一些基本命令：

- `Space Space` - 模糊搜尋目前目錄中的任何檔案。
- `Space S G` - 使用 grep 搜尋所有檔案，並提供預覽。
- `Space E` - 切換檔案樹的開關。
- `Ctrl + W W` - 在檔案樹與編輯器之間來回切換。
- `Shift + H` - 在開啟的索引標籤之間向左移動（vim 稱它們為 buffers）。
- `Shift + L` - 在開啟的索引標籤之間向右移動。
- `Space B D` - 關閉一個索引標籤。
- `Space B O` - 關閉除目前以外的所有其他索引標籤。
- `Space G G` - 從目前目錄在浮動窗格中啟動 LazyGit。
- `Space U W` - 切換軟換行。

當你在檔案樹中時（按 `Space E` 顯示，按 `Ctrl + W W` 切換過去），你可以按 `a` 新增檔案，或按 `A` 新增目錄。在檔案樹中按 `?` 可以查看所有命令。

如果你想掌握 vim 的基本語言，我寫過關於 [三段式語法](https://world.hey.com/dhh/wonderful-vi-a1d034d3) 的文章，以及如何使出那些厲害的連招！

你可以在 [LazyVim Keymaps 頁面](https://www.lazyvim.org/keymaps) 查看所有可用的命令。

## 啟動 Neovim

`Super + Shift + N` 會啟動你的預設編輯器，在新安裝的系統上是 Plain；在 _Setup > Defaults > Editor_ 中選擇 Neovim，便可改為啟動 Neovim。但通常從終端機操作會更容易：前往你想工作的目錄，然後輸入 `n`。`n` 是 `nvim` 的別名，它預設會使用目前目錄開啟。你可以用 `n myfile.txt` 開啟單一檔案。

## 使用 Neovim 進行 sudo 編輯

如果你需要編輯只有超級使用者才能更改的檔案，請執行 `sudoedit /etc/sudoers.d/00-sudo-only-file`。它會開啟你的預設編輯器，所以如果你想在那裡使用 Neovim 及其所有外掛，請在 _Setup > Defaults > Editor_ 中將編輯器設定為 Neovim。
