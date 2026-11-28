# 打造你自己的主題

你可以把自己的主題加入 `~/.config/omarchy/themes`。只要從現有的主題中複製一個當作基底（去 `/usr/share/omarchy/themes` 看看），然後隨心所欲地調整。只要你的主題在那個資料夾裡，它就會出現在主題選取選單中。

你主要需要調整的檔案是 `colors.toml`。它定義了顏色組，之後會用來產生終端機（Foot/Alacritty/Ghostty/Kitty）、btop、Chromium、Hyprland、Neovim、Helix、VSCode、Obsidian、Qt 應用程式、鍵盤背光、輸入法、螢幕分享選擇器、應用程式圖示、數個 AI 工具（Claude、Pi、Hermes、T3 Code、Herdr），以及整個 Omarchy shell（頂部列、選單、通知、OSD 和鎖定畫面）的設定。

你也可以使用內附的 Aether 應用程式來建立新主題，透過一個好用的 GUI 介面來玩轉顏色並搜尋背景。只要在 `Super + Alt + Space` 的應用程式格狀清單中啟動它即可。

### 已安裝的主題可以包含什麼

你在 `~/.config/omarchy/themes` 中自己寫的主題，可以包含任何你想要的東西 —— 這是你的機器和你的檔案，Omarchy 會全部套用。

你用 `omarchy theme install` 從別人的儲存庫安裝的主題，會保留所有與顏色有關的東西，並捨棄少數幾個會在你的機器上執行程式碼的檔案：任何 `.lua` 檔案、終端機設定（`alacritty.toml`、`foot.ini`、`ghostty.conf`、`kitty.conf`），以及 `vscode.json`。主題的 `hyprland.lua` 是你的 compositor 在登入時執行的 Lua，終端機設定指定了你的終端機要啟動的程式，而 `vscode.json` 指定了要安裝的 VSCode 擴充功能。安裝別人的主題應該只改變你的桌面外觀，絕不該改變它執行的東西。

其他所有東西仍會完全按照主題作者撰寫的方式運作 —— `btop.theme`、`chromium.theme`、`helix.toml`、`shell.toml`、背景和預覽全都會保留。只有被捨棄的部分，會在你的機器上從 `colors.toml` 重新產生。

Omarchy 會依據主題內部是否有自己的 git 儲存庫來區分這兩者，那就是 `omarchy theme install` 在 clone 時留下的東西。所以你自己寫的主題仍然是你的，而你從網路上抓下來的主題就只剩下顏色。

### 淺色模式

如果你正在製作淺色模式主題，請在你的 `colors.toml` 頂部設定 `mode = "light"`。然後它會自動為所有應用程式配對淺色模式。（在主題根目錄丟一個名為 `light.mode` 的空檔案這個舊方法也仍然有效。）

### 解鎖圖片

隨附 `unlock.png` 和 `preview-unlock.png` 圖片的主題，會列在 _Appearance > Unlock_ 底下。你的 `unlock.png` 最好是透明的 png。你可以使用 `omarchy plymouth preview` 來建立預覽圖片。

### 為 Omarchy 沒有涵蓋的應用程式套用主題

如果你使用的應用程式不在那份清單中，你可以用範本自己教 Omarchy 如何為它套用主題。在 `~/.config/omarchy/themed/` 中丟入一個檔案，名稱以它產生的設定檔命名再加上 `.tpl` 副檔名，並用 `{{ background }}`、`{{ foreground }}`、`{{ accent }}`、`{{ red }}`、`{{ color0 }}` 到 `{{ color15 }}`，以及調色盤的其餘部分作為佔位符來撰寫設定。每當你切換主題時，該檔案就會以該主題的顏色重新產生。

該資料夾中有一個附有完整註解的 `alacritty.toml.tpl.sample` 可供複製 —— 它列出了你可以使用的每一個變數，還有 `_strip` 和 `_rgb` 修飾符，供那些想要不帶 `#` 的顏色或十進位 RGB 顏色的應用程式使用。你的範本優先於 Omarchy 自己的範本，所以你也可以用這個方法來覆寫內建應用程式的佈景方式。

### 發佈你的主題

如果你想發佈你的主題讓其他人使用，你需要把它放在公開的 git 伺服器上，像是 GitHub。然後人們就能在 Omarchy 選單中使用該 URL，透過 _Install > Style > Theme_ 來安裝它。建議你遵循 `omarchy-[themename]-theme` 的命名慣例，因為安裝後主題會在主題選取選單中正確地只顯示為 `[themename]`。

剩下的 `[themename]` 會成為主題的目錄名稱，所以它必須是 Omarchy 可以安全傳遞的名稱：它必須以字母、數字或底線開頭，其餘部分可以包含字母、數字、`.`、`_`、`+` 和 `-`。大寫字母會自動轉為小寫，但其他任何東西 —— 空格、引號、非英文字元 —— 都會在安裝時被拒絕，而不是被轉成目錄名稱。所以 `omarchy-tokyo-night-theme`、`omarchy-flexoki_light-theme` 和 `omarchy-c++-theme` 都能順利安裝。

請記住，一旦它從儲存庫安裝，它隨附的任何 `.lua`、終端機設定或 `vscode.json` 都會被捨棄，所以不要把主題建立在那些東西上。

你可以透過向 [omarchy-site 儲存庫](https://github.com/omacom-io/omarchy-site) 送出 pull request，把你的主題加入[額外主題頁面](https://omarchy.org/themes/)。
