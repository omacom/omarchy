# 快捷鍵

你可以用 `Super + K` 查看所有主要鍵盤綁定（Tmux 綁定用 `Super + Alt + K`，Herdr 綁定用 `Super + Ctrl + K`）。

## 快捷鍵的配置方式

每個快捷鍵都位於一個由其修飾鍵決定的平面上，而且每個平面只有一個用途。這正是讓快捷鍵不混在一起的原因，也代表你通常能猜到某個功能放在哪裡。

| 平面 | 放在這裡的內容 | 範例 |
| --- | --- | --- |
| `Super + key` | 系統：視窗、工作區、版面配置與核心選單 | `Super + Space` Omarchy 選單、`Super + W` 關閉視窗、`Super + F` 全螢幕 |
| `Super + Shift + key` | 應用程式 | `Super + Shift + B` 瀏覽器、`Super + Shift + E` 電子郵件、`Super + Shift + N` 編輯器 |
| `Super + Ctrl + key` | 面板與系統選單 | `Super + Ctrl + A` 音訊、`Super + Ctrl + N` 網路、`Super + Ctrl + C` 擷取選單 |
| `Super + Ctrl + Alt + key` | 快速動作與通知 | `Super + Ctrl + Alt + T` 顯示時間、`Super + Ctrl + Alt + B` 電池、`Super + Ctrl + Alt + C` 螢幕截圖 |

在快捷鍵上加上 `Alt`，會得到同一件事的變體，絕不會是毫不相關的東西：

- `Super + Shift + B` 開啟瀏覽器；`Super + Shift + Alt + B` 開啟私密視窗
- `Super + Shift + E` 開啟電子郵件；`Super + Shift + Alt + E` 開始撰寫新郵件
- `Super + F` 進入全螢幕；`Super + Alt + F` 進入全寬度
- `Super + Ctrl + C` 開啟擷取選單；`Super + Ctrl + Alt + C` 跳過選單直接拍螢幕截圖

新增快捷鍵時：

1. 先依它做什麼選平面，再選按鍵。
2. 不要為了騰出位置移動既有的快捷鍵。在正確的平面上找一個空閒的按鍵。
3. 只用 `Alt` 表示沒有 `Alt` 的那個快捷鍵的變體。

少數快捷鍵會打破這些規則，因為那樣比較方便。用 `Shift` 加箭頭鍵或 `Tab` 是移動或反向，而不是開啟應用程式，而 `Print`、媒體鍵、`Alt + Tab` 以及 `Ctrl + Alt + Del` 的運作方式就跟其他地方一樣。它們是例外，不是值得照抄的模式。

如果預設值不適合你（例如你想像在 Windows 上一樣用 `Super + Shift + S` 拍螢幕截圖），就在 `~/.config/hypr/bindings.lua` 中重新綁定它。

## 導覽

| 快捷鍵 | 功能 |
| --- | --- |
| `Super + Space` | Omarchy 選單（應用程式與其他所有內容） |
| `Super + Alt + Space` | 應用程式格狀清單 |
| `Super + Escape` | 系統選單（暫停、重新啟動等） |
| `Super + Ctrl + L` | 鎖定電腦 |
| `Super + W` 或 `Super + Q` | 關閉視窗 |
| `Ctrl + Alt + Del` | 關閉所有視窗 |
| `Super + T` | 在平鋪／浮動之間切換視窗 |
| `Super + J` | 切換視窗位置（水平／垂直） |
| `Super + O` | 切換將視窗彈出為黏著浮動狀態 |
| `Super + L` | 循環切換 dwindle、scrolling 與 floating 版面配置 |
| `Super + Alt + L` | 以相反順序循環切換版面配置 |
| `Super + P` | 切換 pseudo 視窗樣式（natural 對 stretch） |
| `Super + F` | 進入全螢幕 |
| `Super + Alt + F` | 進入全寬度 |
| `Super + Ctrl + F` | 在視窗內進入全螢幕 |
| `Super + 1/2/3/4` | 跳至目前焦點螢幕上的指定工作區 |
| `Super + Tab` | 跳至目前焦點螢幕上的下一個工作區 |
| `Super + Shift + Tab` | 跳至目前焦點螢幕上的上一個工作區 |
| `Super + Ctrl + Tab` | 跳至目前焦點螢幕上的先前工作區 |
| `Super + Shift + 1/2/3/4` | 將視窗移到目前焦點螢幕上的工作區 |
| `Super + Shift + Alt + 1/2/3/4` | 將視窗移到目前焦點螢幕上的工作區，但不跟隨切換 |
| `Super + S` | 切換完整暫存區 |
| `Super + Alt + S` | 將視窗移到完整暫存區 |
| `Super + Grave` | 切換 Quake 主控台 |
| `Super + Shift + Grave` | 將視窗移到 Quake 主控台 |
| `Super + Shift + Ctrl + Arrows` | 將視窗移到該方向的螢幕 |
| `Super + Shift + Alt + Arrows` | 將工作區移到該方向的螢幕 |
| `Super + Arrow` | 將焦點移到箭頭方向的視窗，到了螢幕邊緣會跨到該側的螢幕 |
| `Super + Shift + Arrow` | 與箭頭方向的另一個視窗交換，包括該側螢幕上的視窗 |
| `Super + Minus` | 向左擴大視窗 |
| `Super + Equal` | 向左縮小視窗 |
| `Super + Shift + Minus` | 向上縮小視窗 |
| `Super + Shift + Equal` | 向下擴大視窗 |
| `Super + Alt + Minus/Equal` | 相同的縮放，但步幅更小 |
| `Super + Ctrl + Minus/Equal` | 相同的縮放，但步幅更大 |
| `Super + Alt + Home` | 儲存視窗寬度 |
| `Super + Home` | 還原已儲存的視窗寬度 |
| `Super + Left Mouse` | 拖曳視窗 |
| `Super + Right Mouse` | 調整視窗大小 |
| `Super + Scroll Wheel` | 在目前焦點螢幕上捲動切換工作區 |
| `Super + G` | 切換視窗群組 |
| `Super + Alt + G` | 將視窗移出群組 |
| `Super + Alt + Tab` | 在群組內的視窗之間循環切換 |
| `Super + Alt + Shift + Tab` | 在群組內的視窗之間反向循環切換 |
| `Super + Alt + Scroll Wheel` | 在群組內的視窗之間循環切換 |
| `Super + Alt + 1/2/3/4/5` | 跳至群組內的指定視窗 |
| `Super + Alt + Arrow` | 將視窗依箭頭方向移入群組，包括該側螢幕上的視窗 |
| `Super + Ctrl + Left/Right` | 在平鋪群組內的視窗之間移動 |
| `Super + Ctrl + Z` | 放大畫面（重複按下可繼續放大） |
| `Super + Ctrl + Alt + Z` | 從畫面完全縮小 |
| `Super + /` | 向前逐步切換螢幕縮放選項 |
| `Super + Alt + /` | 向後逐步切換螢幕縮放選項 |
| `Alt + Tab` | 在目前工作區的視窗之間向前循環切換 |
| `Alt + Shift + Tab` | 在目前工作區的視窗之間向後循環切換 |
| `Ctrl + Alt + Tab` | 在螢幕之間向前循環切換焦點 |
| `Ctrl + Alt + Shift + Tab` | 在螢幕之間向後循環切換焦點 |

調整大小的快捷鍵使用實體按鍵 `code:20` 與 `code:21`（XKB `<AE11>` 與 `<AE12>`），與鍵盤上印的字符無關。在美式鍵盤上，這些按鍵是 `-` 與 `=`；在日式（JIS）鍵盤上，它們是 `-` 與 `^`；在西班牙文鍵盤上，它們是 `'` 與 `¡`。在 JIS 上，`Super + ^` 是 `Super + Equal`，而 `Super + Shift + -`（會輸入 `=`）是 `Super + Shift + Minus`。

## 系統控制

| 快捷鍵 | 功能 |
| --- | --- |
| `Super + Ctrl + A` | 音訊面板 |
| `Super + Ctrl + B` | Bluetooth 面板 |
| `Super + Ctrl + N` | Wi-Fi／網路面板 |
| `Super + Ctrl + D` | 顯示面板 |
| `Super + Ctrl + P` | 電源面板 |
| `Super + Ctrl + X` | 代理程式面板 |
| `Super + Ctrl + Alt + D` | 日曆面板 |
| `Super + Ctrl + Alt + E` | 世界時鐘面板 |
| `Super + Ctrl + 1-9` | 依位置切換工具列面板 |
| `Super + Ctrl + S` | 分享選單（透過 LocalSend） |
| `Super + Ctrl + C` | 擷取控制（螢幕截圖／錄影／選取器） |
| `Super + Ctrl + O` | 切換選單 |
| `Super + Ctrl + H` | 硬體選單 |
| `Super + Ctrl + E` | 表情符號選取器 |
| `Super + Ctrl + .` | 轉碼媒體 |
| `Super + Shift + Ctrl + A` | 選取一個 AI 代理程式 |

## 調整

| 快捷鍵 | 功能 |
| --- | --- |
| `Shift + Brightness Up` | 螢幕亮度最大 |
| `Shift + Brightness Down` | 螢幕亮度最小 |
| `Alt + Brightness Up/Down` | 精確的 1% 亮度變化 |
| `Alt + Volume Up/Down` | 精確的 1% 音量變化 |
| `Keyboard Brightness Up/Down` | 鍵盤背光更亮／更暗 |
| `Keyboard Backlight` | 循環切換鍵盤背光等級 |
| `Alt + Play` | 下一首曲目 |
| `Alt + Shift + Play` | 上一首曲目 |

## 啟動應用程式

| 快捷鍵 | 功能 |
| --- | --- |
| `Super + Return` | 終端機 |
| `Super + Alt + Return` | Tmux 終端機 |
| `Super + Ctrl + Return` | Herdr（代理程式管理器） |
| `Super + Shift + Return` | 瀏覽器 |
| `Super + Shift + Alt + B` | 瀏覽器（私密／無痕） |
| `Super + Shift + F` | 檔案管理器 |
| `Super + Shift + Alt + F` | 在終端機的 cwd 中開啟檔案管理器 |
| `Super + Shift + M` | 音樂 (Spotify) |
| `Super + Shift + Alt + M` | 音樂 (cliamp) |
| `Super + Shift + /` | 密碼管理器 (1password) |
| `Super + Shift + Q` | 計算機 (Omacalc) |
| `Super + Shift + T` | 系統活動 (btop) |
| `Super + Shift + N` | 編輯器 (Neovim) |
| `Super + Shift + C` | 日曆 ([HEY](https://hey.com/)) |
| `Super + Shift + E` | 電子郵件 ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | 新電子郵件 ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | 即時通訊 (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | 即時通訊 (WhatsApp) |
| `Super + Shift + Ctrl + G` | 即時通訊 (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | 寫作 (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

在 `~/.config/hypr/bindings.lua` 中變更／新增綁定。

## 通用剪貼簿

| 快捷鍵 | 功能 |
| --- | --- |
| `Super + A` | 在支援 `Ctrl + A` 的應用程式中全選 |
| `Super + C` | 複製 |
| `Super + X` | 剪下（終端機中除外） |
| `Super + V` | 貼上 |
| `Super + Ctrl + V` | 剪貼簿管理器 |

在 Linux 上，你通常需要在終端機中用 `Ctrl + Shift + C/V` 複製貼上，在其他地方則用 `Ctrl + C/V`。這些 Omarchy 統一剪貼簿快捷鍵到處都能用。

## 擷取

| 快捷鍵 | 功能 |
| --- | --- |
| `Print Screen` | 螢幕截圖 |
| `Super + Ctrl + Alt + C` | 螢幕截圖（相同功能，適用於沒有 Print Screen 鍵的鍵盤） |
| `Super + Ctrl + C` | 擷取選單 |
| `Alt + Print Screen` | 螢幕錄影 |
| `Super + Print Screen` | 色彩選取器 |
| `Super + Ctrl + Print Screen` | 將文字擷取至剪貼簿 |
| `Super + Alt + [` | 錄影時縮小網路攝影機浮疊畫面 |
| `Super + Alt + ]` | 錄影時放大網路攝影機浮疊畫面 |
| `Alt + Shift + L` | 從網路應用程式或瀏覽器複製目前 URL |
| `Alt + Shift + D` | 將目前頁面上的影片下載至 `~/Videos` |
| `Alt + Space` | 開始／停止聽寫（需要 _設定 > 預設 > 聽寫_） |
| `Right Alt` | 按住以聽寫（需要 _設定 > 預設 > 聽寫_） |

進行螢幕錄影時，這個快捷鍵會先詢問你要哪種音訊，然後開始錄影。再按一次即可停止。詳情請參閱[螢幕截圖與錄影](12-screenshots-recording.md)。

所有擷取選項也可透過 Omarchy 選單（`Super + Space`）中的 _觸發 > 擷取_ 存取。

## 通知

| 快捷鍵 | 功能 |
| --- | --- |
| `Super + ,` | 對最新通知採取行動：開啟它，或按下它唯一的按鈕、從它的選項中選擇，或在它沒有任何選項時將它關閉 |
| `Super + Shift + ,` | 關閉所有通知 |
| `Super + Ctrl + ,` | 用鍵盤控制通知 |
| `Super + Alt + ,` | 關閉最新通知 |
| `Super + Shift + Alt + ,` | 開啟通知歷史記錄 |
| `Super + Ctrl + Alt + ,` | 切換通知靜音 |

## 樣式

| 快捷鍵 | 功能 |
| --- | --- |
| `Super + Ctrl + T` | 選取新主題（也可用 `Super + Ctrl + Shift + Space`） |
| `Super + Ctrl + W` | 選取主題背景（也可用 `Super + Ctrl + Space`） |
| `Super + Backspace` | 切換視窗透明度 |
| `Super + Ctrl + Backspace` | 切換單一視窗正方形比例 |

其他背景圖片位於 `~/.config/omarchy/backgrounds/<theme name>`。也可透過 Omarchy 選單中的 _安裝 > 樣式 > 背景_ 取得。

所有樣式選項也可透過 Omarchy 選單（`Super + Space`）中的 _樣式_ 存取。

## 切換開關

| 快捷鍵 | 功能 |
| --- | --- |
| `Super + Ctrl + I` | 切換閒置時鎖定 |
| `Super + Ctrl + Delete` | 切換筆電顯示器開／關 |
| `Super + Ctrl + Alt + Delete` | 切換筆電顯示器鏡像 |
| `Super + Shift + Space` | 切換頂部列 |
| `Shift + Mute` | 切換至下一個音訊輸出 |
| `Shift + Play` | 切換至下一個媒體來源 |
| `Super + Shift + Backspace` | 切換視窗間隙 |
| `Super + Ctrl + Alt + F` | 切換全螢幕桌面（頂部列＋視窗間隙） |

## 提醒

| 快捷鍵 | 功能 |
| --- | --- |
| `Super + Ctrl + R` | 設定提醒 |
| `Super + Ctrl + Alt + R` | 查看所有提醒 |
| `Super + Ctrl + Shift + R` | 清除所有提醒 |

## 提示

| 快捷鍵 | 功能 |
| --- | --- |
| `Super + Ctrl + Alt + T` | 以通知顯示時間 |
| `Super + Ctrl + Alt + B` | 以通知顯示電池狀態 |
| `Super + Ctrl + Alt + W` | 切換以通知顯示天氣 |

## Tmux

前綴鍵是 `Ctrl + Space`（`Ctrl + B` 也可以）。你可以在 `~/.config/tmux/tmux.conf` 中變更這些綁定。

### 窗格

| 快捷鍵 | 功能 |
| --- | --- |
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
| --- | --- |
| `Prefix + c` | 新增視窗 |
| `Prefix + k` | 關閉視窗 |
| `Prefix + r` | 重新命名視窗 |
| `Alt + 1-9` | 前往指定視窗 |
| `Alt + Arrow Left/Right` | 在視窗之間移動 |
| `Alt + Shift + Arrow Left/Right` | 向左／右移動視窗 |

### 工作階段

| 快捷鍵 | 功能 |
| --- | --- |
| `Prefix + C` | 新增工作階段 |
| `Prefix + K` | 結束工作階段 |
| `Prefix + R` | 重新命名工作階段 |
| `Prefix + N` | 下一個工作階段 |
| `Prefix + P` | 上一個工作階段 |
| `Alt + Arrow Up/Down` | 在工作階段之間移動 |
| `Prefix + s` | 列出工作階段 |
| `Prefix + d` | 自工作階段分離 |

### 複製模式（vi 風格）

| 快捷鍵 | 功能 |
| --- | --- |
| `Prefix + [` | 進入複製模式 |
| `v` | 開始選取（在複製模式中） |
| `y` | 複製選取內容（在複製模式中） |

### 一般

| 快捷鍵 | 功能 |
| --- | --- |
| `Prefix + q` | 重新載入設定 |
| `Prefix + ?` | 顯示 Tmux 按鍵綁定 |
| `Prefix + :` | 命令提示字元 |

### Tmux 版面配置功能

這些功能必須在 Tmux 工作階段內執行。

| 命令 | 功能 |
| --- | --- |
| `tdl <ai> [<second_ai>]` | 建立包含編輯器、AI 與終端機的開發版面配置 |
| `tdlm <ai> [<second_ai>]` | 為每個子目錄建立開發版面配置 |
| `tsl <count> <command>` | 建立多窗格蜂群版面配置 |

## Ghostty 終端機

Ghostty 終端機是透過 Omarchy 選單中的 _安裝 > 終端機_ 安裝的。

| 快捷鍵 | 功能 |
| --- | --- |
| `Ctrl + Shift + E` | 在下方新增分割 |
| `Ctrl + Shift + O` | 在旁邊新增分割 |
| `Ctrl + Alt + Arrows` | 在分割之間移動 |
| `Super + Ctrl + Shift + Arrows` | 將分割調整 10 行 |
| `Super + Ctrl + Shift + Alt + Arrows` | 將分割調整 100 行 |
| `Ctrl + Shift + T` | 新增分頁 |
| `Ctrl + Shift + Arrows` | 在分頁之間移動 |
| `Alt + Numbers` | 前往指定分頁 |
| `Shift + Pg Up/Down` | 捲動歷史記錄 |
| `Ctrl + Left mouse` | 在瀏覽器中開啟連結 |

## 檔案管理器

| 快捷鍵 | 功能 |
| --- | --- |
| `Ctrl + L` | 前往路徑 |
| `Space` | 預覽檔案（用箭頭鍵瀏覽） |
| `Alt + Up` | 前往上層資料夾 |

## Neovim（搭配 lazyvim）

### 導覽

| 快捷鍵 | 功能 |
| --- | --- |
| `Space` | 顯示命令選項 |
| `Space Space` | 透過模糊搜尋開啟檔案 |
| `Space E` | 切換側邊欄 |
| `Space G G` | 顯示 git 控制 |
| `Space S G` | 搜尋檔案內容 |
| `Ctrl + W W` | 在側邊欄與編輯器之間跳轉 |
| `Ctrl + Left/right arrow` | 變更側邊欄大小 |
| `Shift + H` | 前往左側檔案分頁 |
| `Shift + L` | 前往右側檔案分頁 |
| `Space B D` | 關閉檔案分頁 |

### 在側邊欄時

| 快捷鍵 | 功能 |
| --- | --- |
| `A` | 在上層資料夾新增檔案 |
| `Shift + A` | 在上層資料夾新增子資料夾 |
| `D` | 刪除反白的檔案／資料夾 |
| `M` | 移動反白的檔案／資料夾 |
| `R` | 重新命名反白的檔案／資料夾 |
| `?` | 顯示所有命令的說明 |

[查看 LazyVim 設定的所有 Neovim 快捷鍵](https://www.lazyvim.org/keymaps)。

## 快速表情符號

你可以使用 `Super + Ctrl + E` 顯示完整的表情符號選取器，它會將選取結果放到剪貼簿，或者你可以使用這些快速存取選項。

| 快捷鍵 | EM | 線索 |
| --- | --- | --- |
| `Shift + CapsLock M S` | 😄 | 微笑 |
| `Shift + CapsLock M C` | 😂 | 哭 |
| `Shift + CapsLock M L` | 😍 | 愛 |
| `Shift + CapsLock M V` | ✌️ | 勝利 |
| `Shift + CapsLock M H` | ❤️ | 心 |
| `Shift + CapsLock M Y` | 👍 | 是 |
| `Shift + CapsLock M N` | 👎 | 否 |
| `Shift + CapsLock M F` | 🖕 | 幹 |
| `Shift + CapsLock M W` | 🤞 | 許願 |
| `Shift + CapsLock M R` | 🤘 | 搖滾 |
| `Shift + CapsLock M K` | 😘 | 親吻 |
| `Shift + CapsLock M E` | 🙄 | 翻白眼 |
| `Shift + CapsLock M I` | 😉 | 眨眼 |
| `Shift + CapsLock M P` | 🙏 | 祈禱 |
| `Shift + CapsLock M D` | 🤤 | 流口水 |
| `Shift + CapsLock M M` | 💰 | 錢 |
| `Shift + CapsLock M X` | 🎉 | 慶祝 |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | 乾杯 |
| `Shift + CapsLock M O` | 👌 | 好的 |
| `Shift + CapsLock M G` | 👋 | 問候 |
| `Shift + CapsLock M A` | 💪 | 手臂 |
| `Shift + CapsLock M B` | 🤯 | 爆開 |

## 快速補全

| 快捷鍵 | 補全內容 |
| --- | --- |
| `Shift + CapsLock Space Space` | — (長破折號) |
| `Shift + CapsLock Space N` | 你的姓名（依設定時輸入的內容） |
| `Shift + CapsLock Space E` | 你的電子郵件（依設定時輸入的內容） |

你可以編輯 `~/.XCompose` 新增更多自己的內容，然後在終端機中執行 `omarchy-restart-xcompose`，讓變更被套用。
