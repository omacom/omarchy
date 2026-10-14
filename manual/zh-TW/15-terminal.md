# 終端機

[Foot](https://codeberg.org/dnkl/foot) 是 Omarchy 的預設終端機。它快速、輕量，即使在舊電腦上也能相容。不過，它不支援原生的分頁或分割。

如果你用 Tmux，你可能不在意；但如果不用，我們也完整支援 _Alacritty_、_Ghostty_ 和 _Kitty_ 作為選項。在 Omarchy 選單的 _安裝 > 終端機_ 底下選擇你的偏好。

你用 `Super + Return` 啟動一個新的終端機。（這個綁定會自動指向你透過 _安裝 > 終端機_ 安裝的任何終端機，而你可以在 _設定 > 預設值 > 終端機_ 底下在已安裝的終端機之間切換。）

## Tmux

Tmux 提供了一個一致、可程式化的介面，用於窗格、視窗（也就是分頁）和可恢復的工作階段，不受你的終端機影響。它甚至能在遠端主機上運作，所以當你透過 SSH 連進一台伺服器時，你可以使用相同的方法。

你用 `Super + Alt + Return` 在一個全新的終端機中啟動一個新的 Tmux 工作階段，而且因為 Tmux 是一個常駐程序，即使你關閉那個終端機，你也能恢復你的工作階段。只要按下 `Ctrl + Space`（稱為前綴鍵）然後按 `s`，就能看到你所有作用中的工作階段。

Omarchy 內建了一套符合人體工學、最佳化過的 Tmux 設定，它有很多快捷鍵要學，所以請把[速查表](07-hotkeys.md#tmux)放在手邊。

## Tmux 配置函式

因為 Tmux 可以程式化，我們可以用函式來建立配置。Omarchy 內建了四個不同的函式，用於常見的開發者配置。

`tdl [agent]` 會啟動一個三分割、類似 IDE 的介面，左邊是 `$EDITOR`，右邊是你選的 AI 代理程式（例如 opencode 用 `c`、Claude 用 `cx`、OpenAI 用 `codex`），然後底部是一個終端機。

所以 `tdl c` 會啟動這個（或直接用 `ic`）：

 ![tmux-tdl](images/tmux-tdl.webp)

你也可以用 `tdl c cx`（opencode + claude）啟動第二個代理程式（或直接用 `icx`）：

 ![tmux-tdl2](images/tmux-tdl2.webp)

還有 `tds`，它會啟動一個四分割的方形配置，左上是編輯器，右上是即時 diff 監看器，左下是終端機，右下是 opencode。

你也可以用 `tdlm [agent]` 為目前目錄中的每一個子目錄啟動這個配置，然後用 `alt + 1/2/3/4/5/...` 來導覽：

 ![tmux-tdlm](images/tmux-tdlm.webp)

最後，你可以用 `tsl [panes] [command]` 啟動一群代理程式。所以 `tsl 4 c` 會給你一個四分割的 opencode 代理程式格子：

 ![tmux-tsl](images/tmux-tsl.webp)
