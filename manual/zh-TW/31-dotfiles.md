# Dotfiles

Omarchy 主要是透過位於 `~/.config` 中所謂的 dotfiles 來設定的。這些被視為你的檔案，供你進行變更。位於 `/usr/share/omarchy` 中的檔案屬於 Omarchy 本身，你不應該動那些。如果你需要更改 `/usr/share/omarchy` 中的任何東西，你應該改為覆寫 `~/.config` 中的值。

關鍵設定可以直接從 Omarchy 選單（`Super + Space`）編輯，例如 _設定 > 顯示器_、_設定 > 快捷鍵_、_設定 > 輸入_ 和 _設定 > Config > [file]_。當你以這種方式操作時，任何在設定編輯後需要自動重新啟動的處理程序，都會在你離開編輯器後自動重啟（預設為 Neovim——`:wq`，記得喔！——但你可以透過 _設定 > 預設值 > Editor_ 更改它）。

以下是 `~/.config` 中關鍵檔案及其控制範圍的清單：

| 檔案                  | 用途              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | 主要的 Hyprland 設定。載入 Omarchy 預設值以及你下面的覆寫檔案。[進一步了解 Hyprland 設定](https://wiki.hypr.land/Configuring/)。  |
| `~/.config/hypr/bindings.lua` | 你自己的快捷鍵和對預設值的覆寫。 |
| `~/.config/hypr/monitors.lua` | 控制你的顯示器、解析度和位置。 |
| `~/.config/hypr/input.lua` | 控制你的鍵盤配置、滑鼠和觸控板設定。 |
| `~/.config/hypr/looknfeel.lua` | 控制間距、邊框、動畫以及其餘的外觀。 |
| `~/.config/hypr/autostart.lua` | 控制隨工作階段一起啟動的額外處理程序。 |
| `~/.config/omarchy/shell.json` | 控制 Omarchy shell：選單列位置、版面配置和小工具，以及螢幕保護程式、鎖定和閒置計時。 |
| `~/.config/foot/foot.ini` | 控制你的終端機（foot 是預設）。 |
| `~/.XCompose` | 定義你的快速存取表情符號以及姓名/電子郵件自動完成。進行更改後請務必執行 `omarchy-restart-xcompose`。 |

如果你最終為了調整自己的設定做了很多更改，備份所有這些 dotfiles 是個好主意。[Stow 是做這件事的好方法](https://www.youtube.com/watch?v=NoFiYOqnC4o)。

### 隨工作階段啟動你自己的應用程式

如果你想讓某些東西在每次登入時都執行——一個同步 daemon、一個聊天應用程式、你自己的指令碼——把它放在 `~/.config/hypr/autostart.lua` 中：

```lua
o.launch_on_start("my-service")
```

那會將命令作為工作階段的一部分啟動，所以當你再次登出時它會被妥善清理。

### 在系統事件上執行指令碼

Omarchy 會在少數幾個時刻觸發 hook，你可以將自己的指令碼掛在上面。它們位於 `~/.config/omarchy/hooks/<event>.d/`，每個事件一個目錄，而且其中每一個可執行檔案都會在事件發生時執行：

| 事件 | 執行時機 |
| ----- | ------------ |
| `post-boot` | 就在桌面啟動之後 |
| `post-update` | 在 `omarchy update` 接近尾聲時，在套件、遷移和服務重新啟動之後，在 mise 工具更新之前 |
| `pre-refresh-pacman` | 在 `omarchy refresh pacman` 重新同步套件設定之後、在它更新套件之前；切換頻道會在同一個重新整理步驟中執行它 |
| `theme-set` | 在主題變更之後（主題名稱在 `$1` 中） |
| `font-set` | 在字型變更之後（字型名稱在 `$1` 中） |
| `battery-low` | 當電池電量低時（百分比在 `$1` 中） |

`pre-refresh-pacman` hook 是放置自訂儲存庫或 `IgnorePkg` 行的地方，因為它在套件交易之前執行。兩個與更新相關的 hook 都在 Omarchy 清除其快取的 sudo 授權之後以你的使用者身分執行，所以使用 `sudo` 的 hook 需要它自己的授權，而且可能會要求你輸入密碼。

這些目錄中的每一個都已包含一個 `.sample` 檔案，顯示 hook 的形式——將名稱中的 `.sample` 去掉就能讓它開始工作。要安裝一個你在其他地方寫好的指令碼，可使用 `omarchy hook install post-boot ~/my-hook`，它會將其複製進去並使之可執行。

### 加入你自己的選單項目

Omarchy 選單（`Super + Space`）可以透過編輯 `~/.config/omarchy/extensions/omarchy-menu.jsonc` 以你自己的行來擴充。項目以點分隔的 id 作為鍵，而 id 正是將它們放入樹中的因素，所以 `personal` 會出現在根選單上，而 `personal.notes` 會出現在它裡面：

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

重複使用現有的 id，你將覆寫該行，而不是加入新的行。該檔案附帶了以註解形式記錄的所有可用欄位。

### 加入你自己的 shell 匯出、函式和別名

Omarchy 附帶了一大堆符合人體工學的別名和有用的函式，但想要加入自己的東西是很常見的。你應將別名、函式和匯出都加入 `~/.bashrc`。這個檔案不會在更新時被覆寫。如果你想更改任何 Omarchy 預設值，你也可以安全地將它們加入此處。

### 更改 Omarchy 內部檔案

聽著，這是你的電腦。你可以對它做任何你想做的事，但我建議不要直接更改 `/usr/share/omarchy` 中的檔案。它們屬於 Omarchy pacman 套件，所以你的更改將在下次更新時直接被覆寫。你最好改為只在 `~/.config/*` 資料夾中覆寫任何你不喜歡的預設值。

你幾乎可以用這種方式更改一切，例如預設的快捷鍵。只要編輯 `~/.config/hypr/bindings.lua`，比如說用 [Joplin](https://joplinapp.org/) 取代 [Obsidian](https://obsidian.md/)（用 `omarchy-pkg-add joplin-bin` 安裝）：

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` 會在加入其替代鍵之前移除現有的綁定。它接受與 `o.bind` 相同的參數，包括啟動輔助函式和綁定選項。使用 `o.bind` 加入一個綁定，或使用 `hl.unbind` 在不取代的情況下移除一個綁定。

如果你堅持要動 Omarchy 的內部檔案，透過 _更新 > Channel > Dev_ 切換到 dev 頻道。那會將 Omarchy 連結到 `~/omarchy` 中原始碼的 git 副本，你可以盡情更改它。這裡沒人能告訴你該做什麼！

### 重設任何變更

如果你最終把設定弄得一團糟，你隨時可以透過 Omarchy 選單中的 _更新 > Config_ 將它們還原為預設值。或者執行 `omarchy reinstall configs` 來重設一切。
