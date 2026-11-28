# 製作你自己的主題

你可以將你自己的主題加入 `~/.config/omarchy/themes`。只要複製一個現有主題作為基礎（請看 `/usr/share/omarchy/themes`），然後隨心所欲地調整。只要你的主題放在那個資料夾裡，它就會出現在主題選單中。

你主要需要調整的檔案是 `colors.toml`。它定義了整組色彩，接著會用來產生終端機（Foot/Alacritty/Ghostty/Kitty）、btop、Chromium、Hyprland、Neovim、Helix、VSCode、Obsidian、Qt 應用程式、鍵盤背光、輸入法、螢幕分享選取器、應用程式圖示、多個 AI 工具（Claude、Pi、Hermes、T3 Code、Herdr），以及整個 Omarchy shell（頂部列、選單、通知、OSD 和鎖定畫面）的設定。

你也可以使用內附的 Aether 應用程式，透過精美的 GUI 介面來建立新主題，盡情玩弄色彩並搜尋背景。只要在 `Super + Alt + Space` 的應用程式格狀檢視中啟動它即可。

### 已安裝的主題可以包含什麼

你在 `~/.config/omarchy/themes` 中自己撰寫的主題可以包含任何你想要的東西——這是你的機器和你的檔案，Omarchy 會全數套用。

你透過 `omarchy theme install` 從別人的 repo 安裝的主題，會保留所有與色彩相關的內容，並捨棄少數會在你的機器上執行程式碼的檔案：任何 `.lua` 檔案、終端機設定（`alacritty.toml`、`foot.ini`、`ghostty.conf`、`kitty.conf`），以及 `vscode.json`。主題的 `hyprland.lua` 是你的 compositor 在登入時會執行的 Lua，終端機設定會指定你的終端機要啟動的程式，而 `vscode.json` 會指定要安裝的 VSCode 擴充功能。安裝別人的主題應該改變你的桌面外觀，絕不應該改變它執行的東西。

其餘一切都會完全依照主題作者撰寫的方式運作——`btop.theme`、`chromium.theme`、`helix.toml`、`shell.toml`、背景和預覽都會保留。只有被捨棄的部分會在你的機器上從 `colors.toml` 重新產生。

Omarchy 透過主題內部是否有自己的 git repo 來區分這兩者，這正是 `omarchy theme install` 在 clone 時會留下的東西。所以你自己撰寫的主題會保持你的，而你從網路上抓來的主題只會是色彩。

### 淺色模式

如果你正在製作淺色模式主題，請在你的 `colors.toml` 頂部設定 `mode = "light"`。接著它就會自動為所有應用程式配對淺色模式。（在主題根目錄放一個名為 `light.mode` 的空檔案這種舊方法仍然有效。）

### 開機和登入畫面

開機時要求輸入磁碟密碼的畫面，以及登入畫面，都會以你的主題的 `accent` 色彩在它的 `background` 上繪製 Omarchy logo，密碼欄位使用它的 `foreground`，密碼錯誤時使用 `red`。你不需要為它們額外提供任何東西：Omarchy 不再使用主題的 `unlock.png` 或 `preview-unlock.png`。在 Apple Silicon Mac 上，無論使用什麼主題，磁碟密碼畫面都會保持 Omarchy 的預設外觀。

### 為 Omarchy 未涵蓋的應用程式套用主題

如果你使用的應用程式不在該清單中，你可以使用範本自己教 Omarchy 如何為它套用主題。在 `~/.config/omarchy/themed/` 中放一個檔案，名稱為它所產生的設定加上 `.tpl` 副檔名，並使用 `{{ background }}`、`{{ foreground }}`、`{{ accent }}`、`{{ red }}`、`{{ color0 }}` 到 `{{ color15 }}` 以及調色盤其餘部分作為預留位置來撰寫設定。每當你切換主題時，該檔案就會以該主題的色彩重新產生。

該資料夾中有一個附有完整註解的 `alacritty.toml.tpl.sample` 可供複製——它列出了你可以使用的每個變數，以及適用於希望色彩不含 `#` 或以十進位 RGB 表示的應用程式的 `_strip` 和 `_rgb` 修飾詞。你的範本優先於 Omarchy 自己的範本，所以你也可以用這種方式覆寫內建應用程式的套用主題方式。

### 散布你的主題

如果你想散布你的主題讓其他人使用，你需要將它放在公開的 git 伺服器上，例如 GitHub。接著人們就可以在 Omarchy 選單中使用該 URL，透過 _Install > Style > Theme_ 來安裝它。建議你遵循 `omarchy-[themename]-theme` 的命名慣例，因為安裝後主題在主題選單中會正確地僅顯示為 `[themename]`。

剩下的 `[themename]` 會成為主題的目錄名稱，所以它必須是 Omarchy 可以安全傳遞的名稱：它必須以字母、數字或底線開頭，其餘部分可以包含字母、數字、`.`、`_`、`+` 和 `-`。大寫字母會自動為你轉換為小寫，但任何其他東西——空格、引號、非英文字元——都會在安裝時被拒絕，而不是被轉換成目錄名稱。所以 `omarchy-tokyo-night-theme`、`omarchy-flexoki_light-theme` 和 `omarchy-c++-theme` 都可以正常安裝。

請記住，一旦從 repo 安裝，它所附帶的任何 `.lua`、終端機設定或 `vscode.json` 都會被捨棄，所以不要以那些東西為核心來打造主題。

你可以將你的主題加入[額外主題頁面](https://omarchy.org/themes/)，方法是向 [omarchy-site repo](https://github.com/omacom-io/omarchy-site) 傳送 pull request。
