# Dotfiles

Omarchy 主要透過位於 `~/.config` 的所謂 dotfiles 來設定。這些被視為你的檔案，供你自行變更。位於 `/usr/share/omarchy` 的檔案屬於 Omarchy 本身，你不應該去動那些檔案。如果你需要變更 `/usr/share/omarchy` 中的任何東西，你應該改在 `~/.config` 中覆寫該值。

主要設定可以直接從 Omarchy 選單（`Super + Space`）編輯，像是 _設定 > 鍵盤 > 按鍵綁定_、_設定 > 輸入_，以及 _設定 > 設定檔 > [file]_。用這種方式編輯時，任何在設定編輯後需要重新啟動的程序，都會在你離開編輯器後自動重新啟動（預設是 Neovim — 記得 `:wq`！— 不過你可以透過 _設定 > 預設 > 編輯器_ 變更）。

以下是 `~/.config` 中主要檔案的清單，以及它們各自控制什麼：

| 檔案                  | 用途              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hyprland 的主要設定檔。載入 Omarchy 預設值，以及你下方的覆寫檔案。[深入了解 Hyprland 設定](https://wiki.hypr.land/Configuring/)。  |
| `~/.config/hypr/bindings.lua` | 你自己的按鍵綁定，以及對預設值的覆寫。 |
| `~/.config/hypr/monitors.lua` | 顯示器面板未涵蓋的顯示器設定，像是旋轉、額外模式，或是讓某台顯示器保持關閉。 |
| `~/.config/hypr/input.lua` | 控制你的鍵盤配置、滑鼠和觸控板設定。 |
| `~/.config/hypr/looknfeel.lua` | 控制間距、邊框、動畫，以及外觀的其餘部分。 |
| `~/.config/hypr/autostart.lua` | 控制隨工作階段一起啟動的額外程序。 |
| `~/.config/omarchy/shell.json` | 控制 Omarchy shell：列的位置、版面配置和小工具，以及螢幕保護程式、鎖定和閒置計時。 |
| `~/.config/foot/foot.ini` | 控制你的終端機（foot 是預設值）。 |
| `~/.XCompose` | 定義你的快速取用 emoji 以及姓名/電子郵件自動完成。變更後務必執行 `omarchy-restart-xcompose`。 |

如果你最後做了很多變更來調整你自己的設定，最好備份所有這些 dotfiles。[Stow 是個很好的做法](https://www.youtube.com/watch?v=NoFiYOqnC4o)。

### 隨工作階段一起啟動你自己的應用程式

如果你想讓某個東西在每次登入時執行 — 一個同步守護程序、一個聊天應用程式、你自己的 script — 把它放進 `~/.config/hypr/autostart.lua`：

```lua
o.launch_on_start("my-service")
```

這會把該命令作為工作階段的一部分啟動，所以當你再次登出時，它會被妥善清理掉。

### 在系統事件時執行 scripts

Omarchy 會在少數幾個時刻觸發 hooks，你可以把你自己的 scripts 掛在上面。它們位於 `~/.config/omarchy/hooks/<event>.d/`，每個事件一個目錄，而且其中每個可執行檔案都會在該事件發生時執行：

| 事件 | 執行時機 |
| ----- | ------------ |
| `post-boot` | 桌面剛啟動完畢後立刻執行 |
| `post-update` | 在 `omarchy update` 接近尾聲時，於套件、遷移和服務重新啟動之後，mise 工具更新之前執行 |
| `pre-refresh-pacman` | 在 `omarchy refresh pacman` 重新同步套件設定之後、更新套件之前執行；切換頻道會在同一個 refresh 步驟中執行它 |
| `theme-set` | 主題變更之後（主題名稱在 `$1`） |
| `font-set` | 字型變更之後（字型名稱在 `$1`） |
| `battery-low` | 電池電量偏低時（百分比在 `$1`） |

`pre-refresh-pacman` hook 是放置自訂儲存庫或 `IgnorePkg` 行的地方，因為它會在套件交易之前執行。兩個與更新相關的 hooks 都會在 Omarchy 清除其快取的 sudo 授權之後，以你的使用者身分執行，所以使用 `sudo` 的 hook 需要它自己的授權，而且可能會要求你輸入密碼。

這些目錄中每個都已經有一個 `.sample` 檔案，展示 hook 的形式 — 把名稱中的 `.sample` 去掉就能讓它上工。若要安裝你寫在其他地方的 script，請使用 `omarchy hook install post-boot ~/my-hook`，它會把它複製進去並使其可執行。

### 新增你自己的選單項目

Omarchy 選單（`Super + Space`）可以透過編輯 `~/.config/omarchy/extensions/omarchy-menu.jsonc`，以你自己的列來擴充。項目以帶點的 id 作為鍵，而 id 決定了它們在樹狀結構中的位置，所以 `personal` 會出現在根選單上，而 `personal.notes` 會出現在它裡面：

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

重用現有的 id，你就會覆寫該列，而不是新增一列。該檔案附有所有可用欄位，並以註解形式記錄下來。

### 新增你自己的 shell exports、functions 和 aliases

Omarchy 附帶了一堆順手好用的 aliases 和實用的 functions，但想要新增你自己的也很常見。你應該把 aliases、functions 和 exports 都新增到 `~/.bashrc` 中。這個檔案在更新時不會被覆寫。如果你想變更任何 Omarchy 預設值，你也可以安全地把它們新增到這裡。

### 為桌面設定環境變數

桌面工作階段的 exports 屬於 `~/.config/uwsm/env.d/`。這些檔案會在你的桌面啟動之前執行，所以 shell 錯誤可能會把你送回登入畫面。編輯它們時，請保持一個可運作的終端機開啟。若要停用某個覆寫，把它移出 `env.d`。如果某項變更導致無法登入，請參閱[登入救援](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen)。

### 變更 Omarchy 內部檔案

聽著，這是你的電腦。你想怎麼用都可以，但我建議不要直接變更 `/usr/share/omarchy` 中的檔案。它們屬於 Omarchy pacman 套件，所以你的變更在下次更新時就會直接被覆寫。你不如改在 `~/.config/*` 資料夾中覆寫任何你不喜歡的預設值。

幾乎所有東西都可以用這種方式變更，像是預設的按鍵綁定。只要編輯 `~/.config/hypr/bindings.lua`，比方說把 [Obsidian](https://obsidian.md/) 換成 [Joplin](https://joplinapp.org/)（用 `omarchy-pkg-add joplin-bin` 安裝）：

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` 會先移除現有的綁定，再新增它的替代綁定。它接受與 `o.bind` 相同的引數，包括啟動輔助函式和綁定選項。使用 `o.bind` 來新增綁定，或使用 `hl.unbind` 來移除綁定而不取代它。

如果你堅持要動 Omarchy 內部檔案，請透過 _更新 > 頻道 > Dev_ 切換到 dev 頻道。這會把 Omarchy 連結到位於 `~/omarchy` 的原始碼 git checkout，你可以隨心所欲地變更它。這裡可沒人能管你怎麼做！

### 重置任何變更

如果你最後把設定搞得一團亂，你隨時都可以透過 Omarchy 選單中的 _更新 > 設定檔_ 把它們還原為預設值。或是執行 `omarchy reinstall configs` 來重置一切。
