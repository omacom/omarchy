# TUI

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) 是像 GitHub Desktop 應用程式這類東西的一個令人愉快的替代品，而且它在終端機內執行。

你可以前往任何由 git 管理的目錄並執行 `lazygit` 來直接執行它。或者你可以在 Neovim 內執行它，在那裡可以用 `Space G G` 啟動。

你用 `Tab` 在不同窗格之間跳轉。在 Files 窗格中，你用 `Space` 選取要暫存的檔案，然後可以用 `c` 建立新的提交。你可以用 `?` 查看所有可用命令。

## Btop

[Btop](https://github.com/aristocratos/btop) 是一個漂亮的資源管理器，顯示記憶體、CPU、磁碟和網路使用情況。它還會列出所有作用中的處理程序，並讓你管理它們。

Omarchy 叫它 Activity，你按 `Super + Ctrl + T` 啟動它。它會以浮動視窗開啟，你可以用 `Super + T` 將它平鋪。

## Herdr

[Herdr](https://github.com/omacom-io/herdr) 是一個終端機工作區管理器，提供工作區、索引標籤和窗格，並將它們全部保持在一個持續的工作階段中執行，你可以分離後稍後再回來。

你用 `Super + Ctrl + Return` 啟動它（或重新連接到現有的工作階段）。Omarchy 附帶的 Herdr 設定與其 Tmux 設定相呼應，所以這裡的前綴鍵也是 `Ctrl + Space`。你可以用 `Super + Ctrl + K` 瀏覽所有快捷鍵。

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) 顯示系統資訊，例如核心版本、運行時間、主題、CPU、記憶體等。它是熱門的 neofetch 工具的繼任者。

Omarchy 把它包裝成 Omarchy 選單（`Super + Space`）中的 _關於_。

## Cliamp

[Cliamp](https://www.cliamp.stream/) 是一個受 Winamp 2.x 啟發的復古終端機音樂播放器，還內建了 lo-fi 節奏的廣播電台。用 `Super + Shift + Alt + M` 啟動它，或從 Omarchy 選單的 _應用程式_ 下啟動。按 `?` 查看完整的快捷鍵清單。

## Wi-Fi 和藍牙呢？

你找不到 Wi-Fi 和藍牙的 TUI——那些工作屬於 Omarchy shell。按一下選單列中的 Wi-Fi 圖示（或按 `Super + Ctrl + W`）可查看網路並連線，按一下藍牙圖示（或按 `Super + Ctrl + B`）可配對並連接裝置。完整說明請參閱[網路](35-networking.md)。

## 加入你自己的

任何終端機程式都能獲得完整的應用程式待遇。前往 Omarchy 選單（`Super + Space`）中的 _安裝 > TUI_，給它一個名稱、一個啟動命令、一個視窗樣式和一個圖示，它就會像其他應用程式一樣出現在應用程式啟動器中。你可以在 _移除 > TUI_ 下再次移除它。
