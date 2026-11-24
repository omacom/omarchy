# Dotfiles

Omarchy 主要透過位於 `~/.config` 的所謂 dotfiles 來設定。那些是你的檔案，供你自行修改。位於 `/usr/share/omarchy` 的檔案屬於 Omarchy 本身，你不應該去動它們。如果你需要更改 `/usr/share/omarchy` 裡的任何東西，應該改在 `~/.config` 裡覆寫該值。

關鍵設定可以直接從 Omarchy 選單（`Super + Space`）編輯，例如 _設定 > 鍵盤 > 按鍵綁定_、_設定 > 輸入_，以及 _設定 > 設定 > [file]_。用這種方式操作時，任何需要在設定編輯後重新啟動的程序，都會在你結束編輯器後自動重新啟動（預設是 Neovim — 記得 `:wq`！— 但你可以透過 _設定 > 預設值 > 編輯器_ 更改）。

以下是 `~/.config` 中的關鍵檔案清單，以及它們各自控制的內容：

| 檔案 | 用途 |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | 主要的 Hyprland 設定。它會載入 Omarchy 的預設值，加上你下方的覆寫檔案。[深入了解 Hyprland 設定](https://wiki.hypr.land/Configuring/)。 |
| `~/.config/hypr/bindings.lua` | 你自己的按鍵綁定，以及對預設值的覆寫。 |
| `~/.config/hypr/monitors.lua` | 監視器面板未涵蓋的監視器設定，例如旋轉、額外模式，或讓某個監視器保持關閉。 |
| `~/.config/hypr/input.lua` | 控制你的鍵盤配置、滑鼠與觸控板設定。 |
| `~/.config/hypr/looknfeel.lua` | 控制間距、邊框、動畫，以及其餘的外觀。 |
| `~/.config/hypr/autostart.lua` | 控制隨工作階段一起啟動的額外程序。 |
| `~/.config/omarchy/shell.json` | 控制 Omarchy shell：列的位置、配置與小工具，以及螢幕保護程式、鎖定與閒置計時。 |
| `~/.config/foot/foot.ini` | 控制你的終端機（foot 是預設的）。 |
| `~/.XCompose` | 定義你快速存取的 emoji 以及姓名／email 自動完成。變更後，務必執行 `omarchy-restart-xcompose`。 |

如果你最後為了調整自己的設定做了很多變更，把所有這些 dotfiles 都備份起來是個好主意。[Stow 是很好的做法](https://www.youtube.com/watch?v=NoFiYOqnC4o)。

### 讓自己的應用程式隨工作階段一起啟動

如果你希望某些東西每次登入時都執行 — 同步 daemon、聊天應用程式、你自己的腳本 — 把它放進 `~/.config/hypr/autostart.lua`：

```lua
o.launch_on_start("my-service")
```

這樣會把該指令作為工作階段的一部分啟動，所以當你再次登出時，它會被妥善清理掉。

### 在系統事件時執行腳本

Omarchy 會在少數幾個時機觸發 hooks，你可以把自己的腳本掛在上面。它們位於 `~/.config/omarchy/hooks/<event>.d/`，每個事件一個目錄，而且裡面每個不以 `.sample` 結尾的檔案，都會在事件發生時以 bash 執行：

| 事件 | 觸發時機 |
| ----- | ------------ |
| `post-boot` | 桌面剛啟動後 |
| `post-update` | 在 `omarchy update` 接近尾聲時，在套件、遷移與服務重新啟動之後，在 mise 工具更新之前 |
| `pre-refresh-pacman` | 在 `omarchy refresh pacman` 重新同步套件設定之後，在它更新套件之前；切換頻道會在同一個重新整理步驟中執行它 |
| `theme-set` | 主題變更後（主題名稱在 `$1`） |
| `font-set` | 字型變更後（字型名稱在 `$1`） |
| `battery-low` | 電池電量偏低時（百分比在 `$1`） |

`pre-refresh-pacman` hook 是自訂套件庫或 `IgnorePkg` 行該放的地方，因為它在套件交易之前執行。兩者都是以你的使用者身分執行。`post-update` 執行時，`omarchy update` 的 sudo 授權仍在有效期內，所以使用 `sudo` 的 hook 不會再要求你輸入密碼；`pre-refresh-pacman` 則是在 `omarchy refresh pacman` 自己用過 sudo 之後緊接著執行。

這些目錄中每個都已經有一個 `.sample` 檔案，展示 hook 的寫法 — 把名稱中的 `.sample` 去掉就能讓它開始運作。要安裝你在其他地方寫好的腳本，請使用 `omarchy hook install post-boot ~/my-hook`，它會把腳本複製進去並使其可執行。

### 新增自己的選單項目

Omarchy 選單（`Super + Space`）可以透過編輯 `~/.config/omarchy/extensions/omarchy-menu.jsonc`，以你自己的列擴充。項目以點號分隔的 id 為鍵，而 id 決定了它們在樹狀結構中的位置，所以 `personal` 會出現在根選單上，而 `personal.notes` 會出現在它裡面：

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

重用既有的 id，你就會覆寫該列，而不是新增一列。該檔案隨附了所有可用欄位，並以註解形式說明。

### 新增自己的 shell 匯出設定、函式與別名

Omarchy 隨附了一堆符合人體工學的別名與實用的函式，但想新增自己的也是很常見的需求。你應該把別名、函式與匯出設定都加在 `~/.bashrc` 裡。這個檔案在更新時不會被覆寫。如果你想更改任何 Omarchy 的預設值，也可以放心地加在這裡。

### 為桌面設定環境變數

桌面工作階段的匯出設定屬於 `~/.config/uwsm/env.d/`。這些檔案會在你的桌面啟動之前執行，所以 shell 錯誤可能會把你送回登入畫面。編輯它們時，請保持一個可用的終端機開著。要停用某個覆寫，把它移出 `env.d`。如果某個變更導致無法登入，請參見[登入救援](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen)。

### 修改 Omarchy 內部檔案

看，這是你的電腦。你想對它做什麼都可以，但我建議不要直接修改 `/usr/share/omarchy` 裡的檔案。它們屬於 Omarchy 的 pacman 套件，所以你的變更在下次更新時就會被直接覆寫掉。你不如改在 `~/.config/*` 資料夾裡覆寫任何你不喜歡的預設值。

你幾乎可以用這種方式更改所有東西，例如預設的按鍵綁定。只要編輯 `~/.config/hypr/bindings.lua`，比方說，把 [Obsidian](https://obsidian.md/) 換成 [Joplin](https://joplinapp.org/)（用 `omarchy-pkg-add joplin-bin` 安裝）：

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` 會先移除既有的綁定，再加入它的替代綁定。它接受與 `o.bind` 相同的參數，包括啟動輔助函式與綁定選項。使用 `o.bind` 來新增綁定，或使用 `hl.unbind` 來移除某個綁定而不取代它。

如果你堅持要動 Omarchy 的內部檔案，請透過 _更新 > 頻道 > Dev_ 切換到 dev 頻道。這會把 Omarchy 連結到位於 `~/omarchy` 的原始碼 git checkout，你可以隨心所欲地修改它。這裡沒人會管你要怎麼做！

### 重置任何變更

如果你最後把設定搞得一團亂，你隨時都可以透過 Omarchy 選單中的 _更新 > 設定_，把它們還原為預設值。或是執行 `omarchy reinstall configs` 來重置一切。
