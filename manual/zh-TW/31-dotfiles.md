# Dotfiles

Omarchy 主要透過所謂的 dotfiles 來設定，這些檔案位於 `~/.config`。這些檔案是屬於你的檔案，供你自行修改。位於 `/usr/share/omarchy` 的檔案屬於 Omarchy 本身，你不應該去動它們。如果你需要變更 `/usr/share/omarchy` 中的任何內容，應該改在 `~/.config` 中覆寫該值。

重要設定可以直接從 Omarchy 選單（`Super + Space`）編輯，例如 _Setup > Keybindings_、_Setup > Input_ 以及 _Setup > Config > [file]_。透過這種方式編輯時，任何在設定編輯後需要重新啟動的程序，都會在你離開編輯器後自動重新啟動（預設為 Neovim — 記得 `:wq`！ — 不過你可以透過 _Setup > Defaults > Editor_ 變更）。

以下是 `~/.config` 中重要檔案的清單，以及它們各自控制的內容：

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | 主要的 Hyprland 設定。會載入 Omarchy 預設值，以及你下列的覆寫檔案。[進一步了解 Hyprland 設定](https://wiki.hypr.land/Configuring/)。  |
| `~/.config/hypr/bindings.lua` | 你自己的按鍵綁定，以及對預設值的覆寫。 |
| `~/.config/hypr/monitors.lua` | 監視器面板未涵蓋的監視器設定，例如旋轉、額外模式，或讓某台監視器保持關閉。 |
| `~/.config/hypr/input.lua` | 控制你的鍵盤配置、滑鼠和觸控板設定。 |
| `~/.config/hypr/looknfeel.lua` | 控制間距、邊框、動畫，以及其餘外觀相關項目。 |
| `~/.config/hypr/autostart.lua` | 控制隨工作階段一起啟動的額外程序。 |
| `~/.config/omarchy/shell.json` | 控制 Omarchy shell：列的位置、版面配置和小工具，以及螢幕保護程式、鎖定和閒置計時。 |
| `~/.config/foot/foot.ini` | 控制你的終端機（foot 為預設終端機）。 |
| `~/.XCompose` | 定義你快速取用的 emoji，以及姓名／電子郵件自動完成。變更後務必執行 `omarchy-restart-xcompose`。 |

如果你最後做了很多變更來調整成你自己的設定，最好把所有這些 dotfiles 都備份起來。[Stow 是很好的備份方式](https://www.youtube.com/watch?v=NoFiYOqnC4o)。

### 讓你自己的應用程式隨工作階段一起啟動

如果你希望某個東西在每次登入時都執行 — 同步 daemon、聊天應用程式、你自己的 script — 就把它放進 `~/.config/hypr/autostart.lua`：

```lua
o.launch_on_start("my-service")
```

這樣會把該指令作為工作階段的一部分啟動，因此當你再次登出時，它會被妥善清理掉。

### 在系統事件時執行 script

Omarchy 會在少數幾個時機觸發 hooks，你可以把你自己的 script 掛在上面。它們位於 `~/.config/omarchy/hooks/<event>.d/`，每個事件一個目錄，裡面每一個可執行檔案都會在該事件發生時執行：

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | 桌面剛啟動完成後 |
| `post-update` | 在 `omarchy update` 接近尾聲時，套件、遷移和服務重新啟動之後，mise 工具更新之前 |
| `pre-refresh-pacman` | 在 `omarchy refresh pacman` 重新同步套件設定之後、更新套件之前；切換頻道時會在同一個 refresh 步驟中執行它 |
| `theme-set` | 主題變更後（主題名稱在 `$1`） |
| `font-set` | 字型變更後（字型名稱在 `$1`） |
| `battery-low` | 電池電量偏低時（百分比在 `$1`） |

`pre-refresh-pacman` hook 是放置自訂儲存庫或 `IgnorePkg` 行的地方，因為它會在套件交易之前執行。兩個與更新相關的 hooks 都會在 Omarchy 清除其快取的 sudo 授權後，以你的使用者身分執行，因此使用 `sudo` 的 hook 需要有自己的授權，而且可能會向你要求密碼。

這些目錄中每一個都已經有一個 `.sample` 檔案，展示 hook 的格式 — 把名稱中的 `.sample` 去掉就能讓它開始運作。若要安裝你在其他地方寫好的 script，請使用 `omarchy hook install post-boot ~/my-hook`，它會把 script 複製進去並設為可執行。

### 加入你自己的選單項目

Omarchy 選單（`Super + Space`）可以透過編輯 `~/.config/omarchy/extensions/omarchy-menu.jsonc` 來擴充，加入你自己的列。項目以帶點的 id 作為鍵，而 id 決定它們在樹狀結構中的位置，所以 `personal` 會顯示在根選單上，而 `personal.notes` 會顯示在它的裡面：

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

重複使用現有的 id，你就會覆寫該列，而不是新增一列。這個檔案附有註解，記錄了所有可用欄位。

### 加入你自己的 shell exports、functions 和 aliases

Omarchy 附帶了一堆符合人體工學的 aliases 和實用的 functions，但你想加入自己的也很常見。你應該把 aliases、functions 和 exports 都加在 `~/.bashrc` 中。這個檔案在更新時不會被覆寫。如果你想變更 Omarchy 的任何預設值，也可以安全地在這裡加入。

### 變更 Omarchy 內部檔案

聽著，這是你的電腦。你想怎麼用都可以，但我建議不要直接變更 `/usr/share/omarchy` 中的檔案。它們屬於 Omarchy pacman 套件，所以你的變更在下一次更新時就會直接被覆寫。你不如改在 `~/.config/*` 資料夾中覆寫任何你不喜歡的預設值。

你可以用這種方式變更幾乎所有東西，例如預設按鍵綁定。只要編輯 `~/.config/hypr/bindings.lua`，比方說把 [Obsidian](https://obsidian.md/) 換成 [Joplin](https://joplinapp.org/)（用 `omarchy-pkg-add joplin-bin` 安裝）：

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` 會先移除現有的綁定，再加入它的替代綁定。它接受與 `o.bind` 相同的參數，包括 launch helpers 和綁定選項。用 `o.bind` 新增綁定，或用 `hl.unbind` 移除綁定而不加以取代。

如果你堅持要動 Omarchy 內部檔案，那就透過 _Update > Channel > Dev_ 切換到 dev 頻道。如此一來，Omarchy 會連結到位於 `~/omarchy` 的原始碼 git checkout，你可以盡情變更。這裡沒有人會來管你想怎麼做！

### 重置任何變更

如果你把設定搞得一團亂，隨時可以透過 Omarchy 選單中的 _Update > Config_ 將它們還原為預設值。或執行 `omarchy reinstall configs` 來重置所有東西。
