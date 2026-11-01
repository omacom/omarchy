# Dotfiles

Omarchy 主要透過位於 `~/.config` 的所謂 dotfiles 來進行設定。這些被視為你的檔案，供你自行修改。位於 `/usr/share/omarchy` 的檔案屬於 Omarchy 本身，你不應該去動它們。如果你需要變更 `/usr/share/omarchy` 中的任何東西，應該改在 `~/.config` 中覆寫其值。

關鍵設定可以直接從 Omarchy 選單（`Super + Space`）編輯，例如 _Setup > Keybindings_、_Setup > Input_ 以及 _Setup > Config > [file]_。透過這種方式編輯時，任何需要在修改設定後重新啟動的處理程序，都會在你結束編輯器後自動重新啟動（預設為 Neovim——`:wq`，記住了！——不過你可以透過 _Setup > Defaults > Editor_ 更改）。

以下是 `~/.config` 中關鍵檔案的清單，以及它們各自控制的內容：

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hyprland 的主要設定。會載入 Omarchy 預設值，以及你下列的覆寫檔案。[深入了解 Hyprland 設定](https://wiki.hypr.land/Configuring/)。  |
| `~/.config/hypr/bindings.lua` | 你自己的按鍵綁定，以及對預設值的覆寫。 |
| `~/.config/hypr/monitors.lua` | 監視器面板沒有涵蓋的監視器設定，例如旋轉、額外模式，或是讓某台監視器保持關閉。 |
| `~/.config/hypr/input.lua` | 控制你的鍵盤配置、滑鼠與觸控板設定。 |
| `~/.config/hypr/looknfeel.lua` | 控制間距、邊框、動畫以及其餘的外觀設定。 |
| `~/.config/hypr/autostart.lua` | 控制隨工作階段一起啟動的額外處理程序。 |
| `~/.config/omarchy/shell.json` | 控制 Omarchy shell：列的位置、配置與小工具，以及螢幕保護程式、鎖定與閒置計時。 |
| `~/.config/foot/foot.ini` | 控制你的終端機（預設為 foot）。 |
| `~/.XCompose` | 定義你快速存取的 emoji，以及姓名／電子郵件自動完成。變更後請務必執行 `omarchy-restart-xcompose`。 |

如果你最後做了很多變更來調整成你自己的設置，建議備份所有這些 dotfiles。[Stow 是個很好的備份方式](https://www.youtube.com/watch?v=NoFiYOqnC4o)。

### 讓你自己的應用程式隨工作階段一起啟動

如果你希望某個東西在每次登入時都執行——同步常駐程式、聊天應用程式、你自己的指令碼——就把它放進 `~/.config/hypr/autostart.lua`：

```lua
o.launch_on_start("my-service")
```

這樣會把該指令作為工作階段的一部分啟動，因此當你再次登出時，它會被妥善清除。

### 在系統事件時執行指令碼

Omarchy 會在少數幾個時機觸發 hooks，你可以把自己的指令碼掛上去。它們位於 `~/.config/omarchy/hooks/<event>.d/`，每個事件一個目錄，裡面的每個可執行檔案都會在該事件發生時執行：

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | 桌面剛啟動完成後立刻 |
| `post-update` | 在 `omarchy update` 將近結束時，於套件、遷移與服務重新啟動之後、mise 工具更新之前 |
| `pre-refresh-pacman` | 在 `omarchy refresh pacman` 重新同步套件設定之後、更新套件之前；切換頻道時會在同一個 refresh 步驟期間執行它 |
| `theme-set` | 主題變更後（主題名稱在 `$1`） |
| `font-set` | 字型變更後（字型名稱在 `$1`） |
| `battery-low` | 電池電量偏低時（百分比在 `$1`） |

`pre-refresh-pacman` hook 就是自訂套件庫或 `IgnorePkg` 行該放的地方，因為它會在套件交易之前執行。這兩個與更新相關的 hook 都會在 Omarchy 清除其快取的 sudo 授權後，以你的使用者身分執行，因此使用 `sudo` 的 hook 需要它自己的授權，可能會要求你輸入密碼。

這些目錄中每個都已經放了一個 `.sample` 檔案，顯示 hook 的形式——把名稱中的 `.sample` 去掉就能讓它開始運作。若要安裝你在其他地方寫好的指令碼，請使用 `omarchy hook install post-boot ~/my-hook`，它會把指令碼複製進去並設為可執行。

### 新增你自己的選單項目

你可以透過編輯 `~/.config/omarchy/extensions/omarchy-menu.jsonc`，為 Omarchy 選單（`Super + Space`）擴充你自己的列。項目以點分隔的 id 作為鍵，而這個 id 決定了它們在樹狀結構中的位置，所以 `personal` 會出現在根選單上，`personal.notes` 則會出現在它裡面：

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

重複使用現有的 id，你就會覆寫該列，而不是新增一列。這個檔案出廠時就以註解的形式記錄了所有可用的欄位。

### 新增你自己的 shell 匯出變數、函式與別名

Omarchy 附帶了一堆符合人體工學的別名與實用的函式，不過想加入你自己的也非常常見。你應該把別名、函式與匯出變數都加入 `~/.bashrc`。這個檔案在更新時不會被覆寫。如果你想更改任何 Omarchy 預設值，也可以安全地加在這裡。

### 設定桌面環境變數

桌面工作階段的匯出變數屬於 `~/.config/uwsm/env.d/`。這些檔案會在你的桌面啟動之前執行，因此 shell 錯誤可能會把你送回登入畫面。編輯它們時，請保持一個能正常運作的終端機開著。若要停用某個覆寫，就把它移出 `env.d`。如果某項變更讓你無法登入，請參見[登入復原](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen)。

### 變更 Omarchy 內部檔案

聽著，這是你的電腦。你想對它做什麼都可以，但我建議你不要直接變更 `/usr/share/omarchy` 中的檔案。它們屬於 Omarchy 的 pacman 套件，所以你的變更在下次更新時就會直接被覆寫。你不如改在 `~/.config/*` 資料夾中覆寫任何你不喜歡的預設值。

你可以用這種方式變更幾乎任何東西，例如預設按鍵綁定。只要編輯 `~/.config/hypr/bindings.lua`，比方說，把 [Obsidian](https://obsidian.md/) 換成 [Joplin](https://joplinapp.org/)（用 `omarchy-pkg-add joplin-bin` 安裝）：

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` 會在加入替代綁定之前，先移除現有的綁定。它接受與 `o.bind` 相同的參數，包括啟動輔助函式與綁定選項。使用 `o.bind` 來新增綁定，或用 `hl.unbind` 來移除某個綁定而不加以取代。

如果你堅持要動 Omarchy 內部檔案，就透過 _Update > Channel > Dev_ 切換到 dev 頻道。這會把 Omarchy 連結到 `~/omarchy` 中的原始碼 git checkout，你可以隨心所欲地改。根本沒人管得了你！

### 重設所有變更

如果你最後把設定搞得一團亂，你隨時都可以透過 Omarchy 選單中的 _Update > Config_ 將它們還原為預設值。或是執行 `omarchy reinstall configs` 來重設一切。
