# 製作你自己的主題

你可以把自己的主題加入 `~/.config/omarchy/themes`。只要複製一個現有的主題作為基礎（到 `/usr/share/omarchy/themes` 裡找），再隨心所欲地調整即可。只要你的主題放在那個資料夾裡，它就會出現在主題選取選單中。

你主要需要調整的檔案是 `colors.toml`。它定義了整組色彩，之後會用來產生終端機（Foot/Alacritty/Ghostty/Kitty）、btop、Chromium、Hyprland、Neovim、Helix、VSCode、Obsidian，以及整個 Omarchy shell（頂部列、選單、通知、OSD 和鎖定畫面）的設定。

你也可以使用內附的 Aether 應用程式，透過精美的 GUI 介面來建立新主題，盡情玩弄色彩並搜尋背景。只要從 `Super + Alt + Space` 的應用程式格狀清單中啟動它即可。

### 已安裝的主題可以包含什麼

你在 `~/.config/omarchy/themes` 裡自己寫的主題可以包含任何你想要的東西 —— 這是你的機器、你的檔案，Omarchy 會全部套用。

你用 `omarchy theme install` 從別人的 repo 安裝的主題，會保留所有與色彩有關的內容，並捨棄少數幾種會在你機器上執行程式碼的檔案：任何 `.lua` 檔案、終端機設定（`alacritty.toml`、`foot.ini`、`ghostty.conf`、`kitty.conf`），以及 `vscode.json`。主題的 `hyprland.lua` 是你的 compositor 在登入時會執行的 Lua，終端機設定會指定你的終端機要啟動的程式，而 `vscode.json` 會指定要安裝的 VSCode 擴充功能。安裝別人的主題應該改變的是你桌面的外觀，絕不是它會執行的東西。

其他一切仍然完全按照主題作者寫的那樣運作 —— `btop.theme`、`chromium.theme`、`helix.toml`、`icons.theme`、`shell.toml`、背景和預覽全都會保留。只有被捨棄的部分會在你的機器上從 `colors.toml` 重新產生。

Omarchy 區分這兩者的方法，是看主題裡面是否有它自己的 git repo，而這正是 `omarchy theme install` 在 clone 時會留下的東西。所以你自己寫的主題依然是你的，從網路上抓來的主題就只管色彩。

### 淺色模式

如果你要製作淺色模式主題，請在 `colors.toml` 的最上方設定 `mode = "light"`。這樣它就會自動為所有應用程式配對淺色模式。（舊的做法是在主題根目錄放一個名為 `light.mode` 的空檔案，這個做法仍然有效。）

### 圖示色彩

如果你想讓檔案管理員的圖示與你的主題色彩相配，請加入一個名為 `icons.theme` 的檔案，裡面寫上你想使用的圖示集名稱。預設可用的選項有：`Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`。

### 解鎖圖片

隨附 `unlock.png` 和 `preview-unlock.png` 圖片的主題會列在 _外觀 > 解鎖_ 底下。你的 `unlock.png` 最好是一張透明的 png。你可以使用 `omarchy plymouth preview` 來建立預覽圖片。

### 為 Omarchy 沒有涵蓋的應用程式套用主題

如果你使用的應用程式不在那份清單裡，你可以自己用範本教 Omarchy 如何為它套用主題。在 `~/.config/omarchy/themed/` 放一個檔案，名稱是它所產生的設定檔名再加上 `.tpl` 副檔名，並使用 `{{ background }}`、`{{ foreground }}`、`{{ accent }}`、`{{ red }}`、`{{ color0 }}` 到 `{{ color15 }}`，以及調色盤的其餘部分作為佔位符來撰寫設定。每當你切換主題時，該檔案就會以該主題的色彩重新產生。

那個資料夾裡有一個註解完整的 `alacritty.toml.tpl.sample` 可以複製 —— 它列出了所有你可以使用的變數，還有 `_strip` 和 `_rgb` 修飾符，供那些希望色彩不要帶 `#`，或是想用十進位 RGB 表示的應用程式使用。你的範本優先級高於 Omarchy 自己的範本，所以你也可以用這個方法來覆寫內建應用程式的套用主題方式。

### 發布你的主題

如果你想發布你的主題讓其他人使用，你需要把它放到一個公開的 git 伺服器上，例如 GitHub。之後大家就可以在 Omarchy 選單中使用 _安裝 > 樣式 > 主題_，透過該 URL 來安裝它。建議你遵循 `omarchy-[themename]-theme` 這個命名慣例，因為這樣安裝後，主題在主題選取選單中就會正確地只顯示為 `[themename]`。

剩下的那個 `[themename]` 會成為主題的目錄名稱，所以它必須是 Omarchy 能安全傳遞的名稱：它必須以字母、數字或底線開頭，其餘部分可以包含字母、數字、`.`、`_`、`+` 和 `-`。大寫字母會自動轉成小寫，但其他任何東西 —— 空格、引號、非英文字元 —— 都會在安裝時直接被拒絕，而不是被轉成目錄名稱。所以 `omarchy-tokyo-night-theme`、`omarchy-flexoki_light-theme` 和 `omarchy-c++-theme` 都能順利安裝。

記住，一旦它是從 repo 安裝的，它隨附的任何 `.lua`、終端機設定或 `vscode.json` 都會被捨棄，所以不要把主題建立在那些東西上面。

你可以將你的主題加入[額外主題頁面](https://omarchy.org/themes/)，方法是向 [omarchy-site repo](https://github.com/omacom-io/omarchy-site) 送出 pull request。
