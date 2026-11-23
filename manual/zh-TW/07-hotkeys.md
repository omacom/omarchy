# 快捷鍵

你可以用 `Super + K` 查看所有主要鍵盤綁定（Tmux 綁定用 `Super + Alt + K`，Herdr 綁定用 `Super + Ctrl + K`）。

## 快捷鍵的布局方式

每個快捷鍵都位於一個平面上，由它的修飾鍵決定，每個平面各司其職。這讓快捷鍵不會混在一起，也讓你通常能猜到某個功能在哪裡。

| 平面 | 放什麼 | 範例 |
| --- | --- | --- |
| `Super + key` | 系統：視窗、工作區、版面配置和核心選單 | `Super + Space` Omarchy 選單、`Super + W` 關閉視窗、`Super + F` 全螢幕 |
| `Super + Shift + key` | 應用程式 | `Super + Shift + B` 瀏覽器、`Super + Shift + E` 電子郵件、`Super + Shift + N` 編輯器 |
| `Super + Ctrl + key` | 面板與系統選單 | `Super + Ctrl + A` 音訊、`Super + Ctrl + N` 網路、`Super + Ctrl + C` 擷取選單 |
| `Super + Ctrl + Alt + key` | 快速動作與提示 | `Super + Ctrl + Alt + T` 顯示時間、`Super + Ctrl + Alt + B` 電池、`Super + Ctrl + Alt + C` 螢幕截圖 |

為快捷鍵加上 `Alt` 會得到同一件事的變體，絕不會是毫不相關的東西：

- `Super + Shift + B` 開啟瀏覽器；`Super + Shift + Alt + B` 開啟私密視窗
- `Super + Shift + E` 開啟電子郵件；`Super + Shift + Alt + E` 撰寫新郵件
- `Super + F` 進入全螢幕；`Super + Alt + F` 進入全寬
- `Super + Ctrl + C` 開啟擷取選單；`Super + Ctrl + Alt + C` 跳過選單直接截圖

新增快捷鍵時：

1. 先從它做什麼挑平面，再挑按鍵。
2. 不要為了騰出位置而移動既有的快捷鍵。在正確的平面上找一個空閒的按鍵。
3. 只有在作為無 `Alt` 版本的變體時才使用 `Alt`。

有幾個快捷鍵打破這些規則，因為這樣比較方便。用 `Shift` 加方向鍵或 `Tab` 是移動或反向，而不是開啟應用程式，而 `Print`、媒體鍵、`Alt + Tab` 和 `Ctrl + Alt + Del` 則跟其他地方一樣運作。它們是例外，不是值得照抄的模式。

如果預設值不合你用（例如你想像在 Windows 上一樣用 `Super + Shift + S` 截圖），就在 `~/.config/hypr/bindings.lua` 裡重新綁定。

## 導覽

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy 選單（應用程式與所有其他功能） |
| `Super + Alt + Space` | 應用程式格狀檢視 |
| `Super + Escape` | 系統選單（睡眠、重新啟動等） |
| `Super + Ctrl + L` | 鎖定電腦 |
| `Super + W` or `Super + Q` | 關閉視窗 |
| `Ctrl + Alt + Del` | 關閉所有視窗 |
| `Super + K` | 顯示所有快捷鍵 |
| `Super + Alt + K` | 顯示 tmux 快捷鍵 |
| `Super + Ctrl + K` | 顯示 herdr 快捷鍵 |
| `Super + M` | 將視窗最小化到 dock |
| `Super + T` | 在平鋪／浮動之間切換視窗 |
| `Super + J` | 切換視窗位置（水平／垂直） |
| `Super + O` | 切換將視窗彈出為 sticky'n'floating |
| `Super + L` | 在 dwindle、scrolling 和 floating 版面配置之間循環切換 |
| `Super + Alt + L` | 反向循環切換版面配置 |
| `Super + P` | 切換 pseudo 視窗樣式（自然與拉伸） |
| `Super + F` | 進入全螢幕 |
| `Super + Alt + F` | 進入全寬 |
| `Super + Ctrl + F` | 在視窗內進入全螢幕 |
| `Super + 1…9/0` | 跳至焦點螢幕上的指定工作區（0 為 10） |
| `Super + Tab` | 跳至焦點螢幕上的下一個工作區 |
| `Super + Shift + Tab` | 跳至焦點螢幕上的上一個工作區 |
| `Super + Ctrl + Tab` | 跳至焦點螢幕上的先前工作區 |
| `Super + Shift + 1…9/0` | 將視窗移到焦點螢幕上的工作區 |
| `Super + Shift + Alt + 1…9/0` | 將視窗移到焦點螢幕上的工作區，但不跟過去 |
| `Super + S` | 切換完整 scratchpad |
| `Super + Alt + S` | 將視窗移到完整 scratchpad |
| `Super + the key above Tab` (grave on US layouts) | 切換 Quake 主控台 |
| `Super + Shift + the key above Tab` (grave on US layouts) | 將視窗移到 Quake 主控台 |
| `Super + Shift + Ctrl + Arrows` | 將視窗移到該方向的螢幕 |
| `Super + Shift + Alt + Arrows` | 將工作區移到該方向的螢幕 |
| `Super + Arrow` | 將焦點移到箭頭方向的視窗，到了螢幕邊緣時會跨到該側的螢幕 |
| `Super + Shift + Arrow` | 與箭頭方向的另一個視窗交換，包含該側螢幕上的視窗 |
| `Super + Minus` | 向左擴大視窗 |
| `Super + Equal` | 從左側縮小視窗 |
| `Super + Shift + Minus` | 向上縮小視窗 |
| `Super + Shift + Equal` | 向下擴大視窗 |
| `Super + Alt + Minus/Equal` | 同樣的調整大小，但步幅較小 |
| `Super + Ctrl + Minus/Equal` | 同樣的調整大小，但步幅較大 |
| `Super + Alt + Home` | 儲存視窗寬度 |
| `Super + Home` | 還原儲存的視窗寬度 |
| `Super + Left Mouse` | 拖曳視窗 |
| `Super + Right Mouse` | 調整視窗大小 |
| `Super + Scroll Wheel` | 在焦點螢幕上捲動切換工作區 |
| `Super + G` | 切換視窗群組 |
| `Super + Alt + G` | 將視窗移出群組 |
| `Super + Alt + Tab` | 在群組內的視窗之間循環切換 |
| `Super + Alt + Shift + Tab` | 在群組內的視窗之間反向循環切換 |
| `Super + Alt + Scroll Wheel` | 在群組內的視窗之間循環切換 |
| `Super + Alt + 1/2/3/4/5` | 跳至群組內的指定視窗 |
| `Super + Alt + Arrow` | 將視窗移入箭頭方向的群組，包含該側螢幕上的視窗 |
| `Super + Ctrl + Left/Right` | 在平鋪群組內的視窗之間移動 |
| `Super + Ctrl + Z` | 放大螢幕（重複按下可再放大） |
| `Super + Ctrl + Alt + Z` | 完全縮小螢幕縮放 |
| `Super + /` | 依序往前切換螢幕縮放選項 |
| `Super + Alt + /` | 依序往後切換螢幕縮放選項 |
| `Alt + Tab` | 在目前工作區的視窗之間往前循環切換 |
| `Alt + Shift + Tab` | 在目前工作區的視窗之間反向循環切換 |
| `Ctrl + Alt + Tab`| 在螢幕之間往前循環切換焦點 |
| `Ctrl + Alt + Shift + Tab`| 在螢幕之間反向循環切換焦點 |
| `Super + I` | 切換輸入語言（有多個布局或輸入法時） |
| `Super + Shift + I` | 切換回上一個輸入語言 |

在觸控板上，三指與四指滑動可切換工作區、移動視窗，以及開啟選單和 Quake 主控台；手勢請見[鍵盤、滑鼠與觸控板](34-keyboard-mouse-trackpad.md)。

調整大小用的是 0 右邊的那兩個鍵，不管你的鍵盤上印的是什麼：在美式鍵盤上是 `-` 和 `=`，丹麥與瑞典是 `+` 和 `´`，挪威是 `+` 和 `\`，德國是 `ß` 和 `´`，西班牙是 `'` 和 `¡`，日本（JIS）是 `-` 和 `^`。`Super + K` 會以你鍵盤上印的字樣列出它們。在 JIS 上，`Super + ^` 就是 `Super + Equal`，而 `Super + Shift + -`（會輸入 `=`）則是 `Super + Shift + Minus`。螢幕縮放和密碼管理器使用 `/`；在大多數歐洲布局等只能用 Shift 輸入 `/` 的布局上，它們改用右 Shift 左邊的那個鍵（丹麥和德國是 `-`）。

## 系統控制

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | 音訊面板 |
| `Super + Ctrl + B` | Bluetooth 面板 |
| `Super + Ctrl + N` | Wifi/網路面板 |
| `Super + Ctrl + D` | 顯示面板 |
| `Super + Ctrl + P` | 電源面板 |
| `Super + Ctrl + X` | Agents 面板 |
| `Super + Ctrl + Alt + D` | 行事曆面板 |
| `Super + Ctrl + Alt + E` | 世界時鐘面板 |
| `Super + Ctrl + 1-9` | 依位置切換列面板 |
| `Super + Ctrl + S` | 分享選單（透過 LocalSend） |
| `Super + Ctrl + C` | 擷取控制（螢幕截圖／錄影／選取器） |
| `Super + Ctrl + O` | 切換選單 |
| `Super + Ctrl + H` | 硬體選單 |
| `Super + Ctrl + E` | Emoji 選取器 |
| `Super + Ctrl + .` | 轉碼媒體 |
| `Super + Shift + Ctrl + A` | 啟動你的預設 agent |
| `Power` key | 系統選單 |
| `Super + Shift + Copilot` key | Omarchy 選單 |

## 調整

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | 螢幕亮度最大 |
| `Shift + Brightness Down` | 螢幕亮度最小 |
| `Alt + Brightness Up/Down` | 精確調整亮度，每次 1% |
| `Alt + Volume Up/Down` | 精確調整音量，每次 1% |
| `Keyboard Brightness Up/Down` | 鍵盤背光變亮／變暗 |
| `Keyboard Backlight` | 循環切換鍵盤背光亮度等級 |
| `Ctrl + Brightness Up/Down` | 鍵盤背光變亮／變暗，適用於沒有專用鍵的鍵盤 |
| `Mic Mute` | 將麥克風靜音 |
| `Shift + Mute` | 切換音訊輸出 |
| `Touchpad Toggle` | 開啟或關閉觸控板 |
| `Display` key | 循環切換工作區版面配置 |
| `Alt + Play` | 下一首 |
| `Alt + Shift + Play` | 上一首 |

## 啟動應用程式

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Super + Return` | 終端機 |
| `Super + Alt + Return` | Tmux 終端機 |
| `Super + Ctrl + Return` | Herdr (agent manager) |
| `Super + Shift + Return` or `Super + Shift + B` | 瀏覽器 |
| `Super + Shift + Alt + B` | 瀏覽器（私密／無痕） |
| `Super + Shift + F` | 檔案管理器 |
| `Super + Shift + Alt + F` | 在終端機的 cwd 開啟檔案管理器 |
| `Super + Shift + M` | 音樂 (Spotify) |
| `Super + Shift + Alt + M` | 音樂 (cliamp) |
| `Super + Shift + /` | 密碼管理器 (1password) |
| `Super + Shift + Q` or `Calculator` key | 計算機 (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, once installed) |
| `Super + Shift + T` | 活動 (btop) |
| `Super + Shift + N` | 編輯器（Plain，或你選擇的預設編輯器） |
| `Super + Shift + C` | 行事曆 ([HEY](https://hey.com/)) |
| `Super + Shift + E` | 電子郵件 ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | 新電子郵件 ([HEY](https://hey.com/)) |
| `Super + Shift + A` | 你的預設 agent，或在你選擇之前為 ChatGPT |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | 通訊 (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | 通訊 (WhatsApp) |
| `Super + Shift + Ctrl + G` | 通訊 (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | 寫作 (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X（新貼文） |
| `Super + Shift + Y` | YouTube |

在 `~/.config/hypr/bindings.lua` 中變更／新增綁定。

## 通用剪貼簿

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Super + A` | 在支援 `Ctrl + A` 的應用程式中全選 |
| `Super + C` | 複製 |
| `Super + X` | 剪下（終端機中除外） |
| `Super + V` | 貼上 |
| `Super + Ctrl + V` | 剪貼簿管理器 |

在 Linux 上，你通常需要在終端機用 `Ctrl + Shift + C/V` 複製貼上，在其他地方則用 `Ctrl + C/V`。這些 Omarchy 統一剪貼簿快捷鍵到處都能用。

## 擷取

| 快捷鍵 | 功能 |
| ------------------- | ------------------------------ |
| `Print Screen` | 螢幕截圖 |
| `Super + Ctrl + Alt + C` | 螢幕截圖（同樣的截圖，適用於沒有 Print Screen 鍵的鍵盤） |
| `Super + Ctrl + C` | 擷取選單 |
| `Alt + Print Screen` | 螢幕錄影 |
| `Super + Shift + Ctrl + Alt + C` | 無音訊螢幕錄影，跳過選單（再按一次停止） |
| `Super + Print Screen` | 色彩選取器 |
| `Super + Ctrl + Print Screen` | 將文字擷取至剪貼簿 |
| `Super + Alt + [` | 錄影時縮小 webcam 疊加畫面 |
| `Super + Alt + ]` | 錄影時放大 webcam 疊加畫面 |
| `Alt + Shift + L` | 從 webapp 或瀏覽器複製目前 URL |
| `Alt + Shift + D` | 將目前頁面上的影片下載到 `~/Videos` |
| `Alt + Space` | 開始／停止聽寫（需要 _Setup > Defaults > Dictation_） |
| `Right Alt` | 按住進行聽寫（需要 _Setup > Defaults > Dictation_） |

螢幕錄影時，快捷鍵會先詢問你要哪種音訊，然後開始錄影。再按一次即可停止。詳情請見[螢幕截圖與錄影](12-screenshots-recording.md)。

所有擷取選項也可以在 Omarchy 選單（`Super + Space`）的 _Trigger > Capture_ 下找到。

## 通知

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Super + ,` | 對最新通知進行操作：開啟它或按下它唯一的按鈕、從它的選項中挑選，或在它沒有任何選項時將它關閉 |
| `Super + Shift + ,` | 關閉所有通知 |
| `Super + Ctrl + ,` | 用鍵盤控制通知 |
| `Super + Alt + ,` | 關閉最新通知 |
| `Super + Shift + Alt + ,` | 開啟通知歷史 |
| `Super + Ctrl + Alt + ,` | 切換通知靜音 |

## 樣式

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | 挑選新主題（也可用 `Super + Ctrl + Shift + Space`） |
| `Super + Ctrl + W` | 挑選主題背景（也可用 `Super + Ctrl + Space`） |
| `Super + Backspace` | 切換視窗透明度 |
| `Super + Ctrl + Backspace` | 切換單一視窗正方形比例 |

額外的背景圖片位於 `~/.config/omarchy/backgrounds/<theme name>`。也可以透過 Omarchy 選單中的 _Install > Style > Background_ 取得。

所有樣式選項也可以在 Omarchy 選單（`Super + Space`）的 _Appearance_ 下找到。

## 切換

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | 切換閒置時鎖定 |
| `Super + Ctrl + Delete` | 切換筆電螢幕開／關 |
| `Super + Ctrl + Alt + Delete` | 切換筆電螢幕鏡像 |
| `Super + Shift + Space` | 切換頂部列 |
| `Shift + Mute` | 切換到下一個音訊輸出 |
| `Shift + Play` | 切換到下一個媒體來源 |
| `Super + Shift + Backspace` | 切換視窗間距 |
| `Super + Ctrl + Alt + F` | 切換全螢幕桌面（頂部列 + 視窗間距） |

## 提醒

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | 設定提醒 |
| `Super + Ctrl + Alt + R` | 查看所有提醒 |
| `Super + Ctrl + Shift + R` | 清除所有提醒 |

## 提示

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | 以通知顯示時間 |
| `Super + Ctrl + Alt + B` | 以通知顯示電池 |
| `Super + Ctrl + Alt + W` | 切換以通知顯示天氣 |

## Tmux

前綴鍵是 `Ctrl + Space`（`Ctrl + B` 也可以）。你可以在 `~/.config/tmux/tmux.conf` 中變更這些綁定。

### 窗格

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Prefix + v` | 在旁邊分割窗格（垂直） |
| `Prefix + h` | 在下方分割窗格（水平） |
| `Prefix + x` | 關閉窗格 |
| `Prefix + z` | 切換窗格縮放（全螢幕） |
| `Alt + Enter` | 在下方分割窗格（無需前綴） |
| `Alt + Shift + Enter` | 在旁邊分割窗格（無需前綴） |
| `Alt + Escape` | 關閉窗格（無需前綴） |
| `Ctrl + Alt + Arrows` | 在窗格之間移動 |
| `Ctrl + Alt + Shift + Arrows` | 調整窗格大小 |

### 視窗

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Prefix + c` | 新增視窗 |
| `Prefix + k` | 關閉視窗 |
| `Prefix + r` | 重新命名視窗 |
| `Alt + 1-9` | 前往指定視窗 |
| `Alt + Arrow Left/Right` | 在視窗之間移動 |
| `Alt + Shift + Arrow Left/Right` | 將視窗左移／右移 |

### 工作階段

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Prefix + C` | 新增工作階段 |
| `Prefix + K` | 關閉工作階段 |
| `Prefix + R` | 重新命名工作階段 |
| `Prefix + N` | 下一個工作階段 |
| `Prefix + P` | 上一個工作階段 |
| `Alt + Arrow Up/Down` | 在工作階段之間移動 |
| `Prefix + s` | 列出工作階段 |
| `Prefix + d` | 從工作階段分離 |

### 複製模式（vi 風格）

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Prefix + [` | 進入複製模式 |
| `v` | 開始選取（在複製模式中） |
| `y` | 複製選取內容（在複製模式中） |

### 一般

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Prefix + q` | 重新載入設定 |
| `Prefix + ?` | 顯示 Tmux 鍵盤綁定 |
| `Prefix + :` | 命令提示 |

### Tmux 版面配置函式

這些函式必須在 Tmux 工作階段內執行。

| 指令 | 功能 |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | 建立包含編輯器、AI 和終端機的開發版面配置 |
| `tdlm <ai> [<second_ai>]` | 為每個子目錄建立開發版面配置 |
| `tsl <count> <command>` | 建立多窗格 swarm 版面配置 |

## Ghostty 終端機

Ghostty 終端機可透過 Omarchy 選單使用 _Install > Terminal_ 安裝。

| 快捷鍵 | 功能 |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | 在下方新增分割 |
| `Ctrl + Shift + O` | 在旁邊新增分割 |
| `Ctrl + Alt + Arrows` | 在分割之間移動 |
| `Super + Ctrl + Shift + Arrows` | 調整分割大小 10 行 |
| `Super + Ctrl + Shift + Alt + Arrows` | 調整分割大小 100 行 |
| `Ctrl + Shift + T` | 新增分頁 |
| `Ctrl + Shift + Arrows` | 在分頁之間移動 |
| `Alt + Numbers` | 前往指定分頁 |
| `Shift + Pg Up/Down` | 捲動歷史紀錄 |
| `Ctrl + Left mouse` | 在瀏覽器開啟連結 |

## 檔案管理器

| 快捷鍵 | 功能 |
| ------------------- | ------------------------------ |
| `Ctrl + L` | 前往路徑 |
| `Space` | 預覽檔案（方向鍵導覽） |
| `Alt + Up` | 回到上層資料夾 |

## Neovim (w/ lazyvim)

### 導覽

| 快捷鍵 | 功能 |
| ------------------------ | ------------------------------- |
| `Space` | 顯示命令選項 |
| `Space Space` | 透過模糊搜尋開啟檔案 |
| `Space E` | 切換側邊欄 |
| `Space G G` | 顯示 git 控制 |
| `Space S G` | 搜尋檔案內容 |
| `Ctrl + W W` | 在側邊欄和編輯器之間跳轉 |
| `Ctrl + Left/right arrow` | 變更側邊欄大小 |
| `Shift + H` | 前往左邊的檔案分頁 |
| `Shift + L` | 前往右邊的檔案分頁 |
| `Space B D` | 關閉檔案分頁 |

### 在側邊欄時

| 快捷鍵 | 功能 |
| ------------------------ | ------------------------------- |
| `A` | 在上層目錄新增檔案 |
| `Shift + A` | 在上層目錄新增子目錄 |
| `D` | 刪除反白的檔案／目錄 |
| `M` | 移動反白的檔案／目錄 |
| `R` | 重新命名反白的檔案／目錄 |
| `?` | 顯示所有命令的說明 |

[查看 LazyVim 設定的所有 Neovim 快捷鍵](https://www.lazyvim.org/keymaps)。

## 快速 Emoji

你可以用 `Super + Ctrl + E` 顯示完整的 emoji 選取器，它會將選取結果放到剪貼簿，或者你也可以使用這些快速存取選項。

| 快捷鍵 | EM | 提示 |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | 微笑 |
| `Shift + CapsLock M C` | 😂 | 哭 |
| `Shift + CapsLock M L` | 😍 | 愛 |
| `Shift + CapsLock M V` | ✌️ | 勝利 |
| `Shift + CapsLock M H` | ❤️ | 心 |
| `Shift + CapsLock M Y` | 👍 | 是 |
| `Shift + CapsLock M N` | 👎 | 否 |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | 祈願 |
| `Shift + CapsLock M R` | 🤘 | 搖滾 |
| `Shift + CapsLock M K` | 😘 | 親吻 |
| `Shift + CapsLock M E` | 🙄 | 翻白眼 |
| `Shift + CapsLock M I` | 😉 | 眨眼 |
| `Shift + CapsLock M P` | 🙏 | 祈禱 |
| `Shift + CapsLock M D` | 🤤 | 流口水 |
| `Shift + CapsLock M M` | 💰 | 錢 |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | 乾杯 |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | 問候 |
| `Shift + CapsLock M A` |💪 | 手臂 |
| `Shift + CapsLock M B` |🤯 | 爆炸 |

## 快速補全

| 快捷鍵 | 補全內容 |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | 你的名字（設定時輸入的） |
| `Shift + CapsLock Space E` | 你的電子郵件（設定時輸入的） |

你可以透過編輯 `~/.XCompose` 新增更多自己的內容，然後在終端機執行 `omarchy restart xcompose` 讓變更生效。
