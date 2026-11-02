# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) 是 GitHub Desktop 這類應用的絕佳替代品，而且它直接在終端機裡執行。

你可以前往任何由 git 管理的目錄並執行 `lazygit`，直接啟動它。或者你也可以在 Neovim 裡執行它，在那裡可以用 `Space G G` 啟動。

你可以用 `Tab` 在不同的窗格之間跳換。在 Files 窗格中，你用 `Space` 選取要暫存的檔案，然後可以用 `c` 建立新的提交。你可以用 `?` 查看所有可用的命令。

## Btop

[Btop](https://github.com/aristocratos/btop) 是一個美觀的資源管理器，會顯示記憶體、CPU、磁碟和網路的使用情況。它也會列出所有執行中的行程，並讓你管理它們。

Omarchy 將它稱為 Activity，你可以按 `Super + Shift + T` 啟動它。它會以浮動視窗開啟，你可以用 `Super + T` 將它平鋪。

## Herdr

[Herdr](https://github.com/omacom-io/herdr) 是一個終端機工作區管理器，提供工作區、分頁和窗格，並讓它們全部在持久性工作階段中持續執行，你可以從中分離，稍後再回來。

你可以用 `Super + Ctrl + Return` 啟動它（或重新連接到你現有的工作階段）。Omarchy 隨附的 Herdr 設定與其 Tmux 設定相呼應，所以這裡的前綴鍵同樣是 `Ctrl + Space`。你可以用 `Super + Ctrl + K` 瀏覽所有鍵盤綁定。

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) 會顯示系統資訊，例如核心版本、運行時間、主題、CPU、記憶體等等。它是廣受歡迎的 neofetch 工具的後繼者。

Omarchy 已將它包裝為 Omarchy 選單（`Super + Space`）中的 _About_。

## Cliamp

[Cliamp](https://www.cliamp.stream/) 是一個復古終端機音樂播放器，靈感來自 Winamp 2.x，還內建了 lo-fi beats 的廣播電台。用 `Super + Shift + Alt + M` 啟動它，或從 Omarchy 選單的 _Apps_ 底下啟動。按 `?` 查看完整的鍵盤綁定清單。

## What about Wi-Fi and Bluetooth?

你不會找到 Wi-Fi 和 Bluetooth 的 TUI —— 那些工作屬於 Omarchy shell。點擊頂欄的 Wi-Fi 圖示（或按 `Super + Ctrl + N`）來查看網路並連線，點擊 Bluetooth 圖示（或按 `Super + Ctrl + B`）來配對並連接裝置。完整說明請參閱[網路](35-networking.md)。

## 新增你自己的

任何終端機程式都能享有完整的應用程式待遇。前往 Omarchy 選單（`Super + Space`）中的 _Install > TUI_，給它一個名稱、一個啟動命令、一個視窗樣式和一個圖示，它就會像其他任何應用程式一樣出現在應用程式啟動器中。你可以在 _Remove > TUI_ 底下再次將它移除。
