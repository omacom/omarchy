# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) 是一款令人愉快的替代方案，用來取代 GitHub Desktop 這類應用程式，而且它直接在終端機裡執行。

你可以直接執行它，方法是前往任何由 git 管理的目錄並執行 `lazygit`。或者你也可以在 Neovim 裡執行它，在 Neovim 中可以用 `Space G G` 啟動。

你用 `Tab` 在不同的窗格之間切換。在 Files 窗格中，你用 `Space` 選取要暫存的檔案，然後可以用 `c` 建立新的 commit。你可以用 `?` 查看所有可用的指令。

## Btop

[Btop](https://github.com/aristocratos/btop) 是一款美觀的資源管理工具，會顯示記憶體、CPU、磁碟和網路的使用情況。它也會列出所有作用中的程序，並讓你管理它們。

Omarchy 把它稱為 Activity Monitor，你可以從應用程式啟動器啟動它，或是按下 `Super + Shift + T`。它會以浮動視窗開啟，你可以用 `Super + T` 把它改為平鋪。

## Herdr

[Herdr](https://github.com/omacom-io/herdr) 是一款終端機工作區管理工具，提供工作區、標籤頁和窗格，並讓它們全部在一個持久的工作階段中持續執行，你可以離開，稍後再回來。

用 `Super + Ctrl + Return` 啟動它（或重新連回你現有的工作階段）。Omarchy 附帶了一份 Herdr 設定，其設計與它的 Tmux 設定相呼應，所以這裡的前綴鍵同樣是 `Ctrl + Space`。你可以用 `Super + Ctrl + K` 瀏覽所有按鍵綁定。

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) 會顯示系統資訊，例如核心版本、執行時間、主題、CPU、記憶體等等。它是熱門的 neofetch 工具的後繼者。

Omarchy 已把它包裝成 Omarchy 選單（`Super + Space`）裡的 _關於_。

## Cliamp

[Cliamp](https://www.cliamp.stream/) 是一款受 Winamp 2.x 啟發的復古終端機音樂播放器，還內建了 lo-fi beats 的電台。用 `Super + Shift + Alt + M` 啟動它，或從 Omarchy 選單的 _應用程式_ 下方啟動。按下 `?` 可查看完整的按鍵綁定清單。

## 那 Wi-Fi 和 Bluetooth 呢？

你不會找到 Wi-Fi 和 Bluetooth 的 TUI——那些工作屬於 Omarchy shell。點擊頂部列的 Wi-Fi 圖示（或按下 `Super + Ctrl + N`）來查看網路並連線，點擊 Bluetooth 圖示（或按下 `Super + Ctrl + B`）來配對並連接裝置。完整的說明請參閱[網路](35-networking.md)。

## 新增你自己的

任何終端機程式都可以獲得完整的應用程式待遇。前往 Omarchy 選單（`Super + Space`）中的 _安裝 > TUI_，給它一個名稱、一個啟動指令、一個視窗樣式和一個圖示，它就會像任何其他應用程式一樣出現在應用程式啟動器中。你可以在 _移除 > TUI_ 下再次把它移除。
