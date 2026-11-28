# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) 是個令人愉快的替代方案，可以取代 GitHub Desktop 之類的應用程式，而且它直接在終端機裡執行。

你可以前往任何由 git 管理的目錄並執行 `lazygit`，就能直接執行它。或者，你也可以在 Neovim 裡執行它，在那裡可以用 `Space G G` 啟動。

使用 `Tab` 在不同的窗格之間切換。在 Files 窗格中，使用 `Space` 選取要加入暫存區的檔案，然後就可以使用 `c` 建立新的 commit。使用 `?` 可以查看所有可用的指令。

## Btop

[Btop](https://github.com/aristocratos/btop) 是個漂亮的資源管理器，會顯示記憶體、CPU、磁碟和網路使用量。它也會列出所有正在執行的處理程序，並讓你管理它們。

Omarchy 稱它為 Activity Monitor，你可以從應用程式啟動器啟動它，或按下 `Super + Shift + T`。它會以浮動視窗開啟，你可以用 `Super + T` 將它平鋪。

## Herdr

[Herdr](https://herdr.dev) 是個終端機工作區管理器，提供工作區、標籤頁和窗格，並讓它們全部在一個持久的工作階段中持續執行；你可以中斷這個工作階段，之後再回來。

從應用程式啟動器，或使用 `Super + Ctrl + Return`，即可啟動它（或重新連接到你現有的工作階段）。Omarchy 隨附的 Herdr 設定與其 Tmux 設定相對應，所以這裡的前綴鍵同樣是 `Ctrl + Space`。你可以用 `Super + Ctrl + K` 瀏覽所有的按鍵綁定。

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) 會顯示系統資訊，例如核心版本、運行時間、主題、CPU、記憶體等等。它是廣受歡迎的 neofetch 工具的後繼者。

Omarchy 已將它包裝為 Omarchy 選單（`Super + Space`）中的 _System > About_。

## Cliamp

[Cliamp](https://www.cliamp.stream/) 是個受 Winamp 2.x 啟發的復古終端機音樂播放器，內建 lo-fi beats 電台。使用 `Super + Shift + Alt + M` 啟動它，或從 Omarchy 選單的 _Apps_ 下啟動。按下 `?` 查看完整的按鍵綁定清單。

## 那 Wi-Fi 和 Bluetooth 呢？

你不會找到 Wi-Fi 和 Bluetooth 的 TUI — 這些工作屬於 Omarchy shell。點擊頂部列的 Wi-Fi 圖示（或按下 `Super + Ctrl + N`）即可查看網路並連線，點擊 Bluetooth 圖示（或按下 `Super + Ctrl + B`）即可配對並連接裝置。完整說明請參閱[網路](35-networking.md)。

## 新增你自己的

任何終端機程式都能獲得完整的應用程式待遇。前往 Omarchy 選單（`Super + Space`）中的 _Install > TUI_，給它一個名稱、一個啟動指令、一個視窗樣式和一個圖示，它就會像其他任何應用程式一樣出現在應用程式啟動器中。你可以在 _Remove > TUI_ 下再次將它移除。
