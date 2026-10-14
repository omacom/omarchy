# 製作你自己的主題

你可以把自己的主題加到 `~/.config/omarchy/themes`。只要複製一個現有主題作為基礎（到 `/usr/share/omarchy/themes` 裡找），然後盡情調整即可。只要你的主題在那個資料夾裡，它就會出現在主題選擇選單中。

你主要需要調整的檔案是 `colors.toml`。它定義了色彩集合，接著會用來產生終端機（Foot/Alacritty/Ghostty/Kitty）、btop、Chromium、Hyprland、Neovim、Helix、VSCode、Obsidian 以及整個 Omarchy shell（選單列、選單、通知、OSD 和鎖定畫面）的設定。

你也可以使用內附的 Aether 應用程式，透過一個賞心悅目的 GUI 介面來玩弄色彩、搜尋背景，以建立新主題。只要從 `Super + Alt + Space` 的應用程式網格啟動它即可。

### 已安裝的主題可以包含什麼

你自己在 `~/.config/omarchy/themes` 中撰寫的主題可以包含任何你喜歡的東西——這是你的機器、你的檔案，Omarchy 會全部套用。

你用 `omarchy theme install` 從別人 repo 安裝的主題，則會保留所有色彩相關的內容，並丟掉那少數幾個會在你機器上執行程式碼的檔案：任何 `.lua` 檔案、終端機設定（`alacritty.toml`、`foot.ini`、`ghostty.conf`、`kitty.conf`）以及 `vscode.json`。主題的 `hyprland.lua` 是你的合成器（compositor）在登入時執行的 Lua，終端機設定指名了你的終端機會啟動的程式，而 `vscode.json` 則指名了要安裝的 VSCode 擴充功能。安裝別人的主題應該改變的是你桌面的外觀，永遠不該是它執行的東西。

其他一切仍會完全按照主題作者撰寫的方式運作——`btop.theme`、`chromium.theme`、`helix.toml`、`icons.theme`、`shell.toml`、背景和預覽圖全部都會保留。只有被丟掉的部分會在你的機器上從 `colors.toml` 重新產生。

Omarchy 區分這兩者的方式，是看主題內部是否帶有它自己的 git repo，也就是 `omarchy theme install` 在 clone 時留下的東西。所以你自己寫的主題依然是你的，而從網路上拉下來的主題則只會是色彩。

### 淺色模式

如果你在做淺色模式主題，在你的 `colors.toml` 頂部設定 `mode = "light"`。這樣它就會自動與所有應用程式的淺色模式配對。（舊的方法——在主題根目錄放一個名為 `light.mode` 的空檔案——也仍然有效。）

### 圖示色彩

如果你想讓檔案管理器的圖示與你的主題色彩相配，加上一個名為 `icons.theme` 的檔案，內容是你想使用的圖示集名稱。預設選項有：`Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`。

### 解鎖圖片

附帶 `unlock.png` 和 `preview-unlock.png` 圖片的主題會出現在 _風格 > 解鎖_ 之下。你的 `unlock.png` 最好是透明 png。而你可以用 `omarchy plymouth preview` 來建立預覽圖片。

### 為 Omarchy 未涵蓋的應用程式套用主題

如果你用的應用程式不在上面那份清單裡，你可以用範本親自教 Omarchy 如何為它套用主題。在 `~/.config/omarchy/themed/` 放一個檔案，名稱是它要產生的設定檔加上 `.tpl` 副檔名，並用 `{{ background }}`、`{{ foreground }}`、`{{ accent }}`、`{{ red }}`、`{{ color0 }}` 到 `{{ color15 }}` 以及其餘調色盤色彩作為佔位符來撰寫設定。每次你切換主題時，該檔案就會用該主題的色彩重新產生。

該資料夾中有一個完整註解的 `alacritty.toml.tpl.sample` 可供複製——它列出了你能使用的每個變數，還有供需要不帶 `#` 的色彩或十進位 RGB 的應用程式使用的 `_strip` 和 `_rgb` 修飾詞。你的範本優先於 Omarchy 自己的範本，所以你也可以用這個方法覆寫內建應用程式的主題套用方式。

### 散布你的主題

如果你想散布你的主題讓其他人使用，你需要把它放到一個公開的 git 伺服器上，例如 GitHub。然後別人就可以用該 URL 透過 Omarchy 選單中的 _安裝 > 風格 > 主題_ 來安裝它。建議遵循 `omarchy-[themename]-theme` 的命名慣例，因為安裝後主題會在主題選擇選單中正確顯示為 `[themename]`。

那個剩下的 `[themename]` 會成為主題的目錄名稱，所以它必須是 Omarchy 能安全到處傳遞的名稱：它必須以字母、數字或底線開頭，其餘部分可以包含字母、數字、`.`、`_`、`+` 和 `-`。大寫字母會自動轉成小寫，但其他任何字元——空格、引號、非英文字元——都會在安裝時被拒絕，而不是被變成目錄名稱。所以 `omarchy-tokyo-night-theme`、`omarchy-flexoki_light-theme` 和 `omarchy-c++-theme` 全都安裝順利。

記住，一旦主題是從 repo 安裝的，它附帶的任何 `.lua`、終端機設定或 `vscode.json` 都會被丟掉，所以不要圍繞著這些東西來構建主題。

你可以透過向 [omarchy-site repo](https://github.com/omacom-io/omarchy-site) 送出 pull request，讓你的主題被加到[額外主題頁面](https://omarchy.org/themes/)。
