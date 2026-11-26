# 切換開關、閒置與螢幕保護程式

你每天改來改去的很多東西，其實不算是設定。那是你開一小時、之後再關掉的模式：熬夜工作時開夜間暖光，簡報時開勿擾，看東西時讓系統保持喚醒。Omarchy 把這些叫做切換開關，它們的運作方式都一樣——一組快速鍵、一個選單項目和一條指令，全部指向同一個開關。

### 切換選單

`Super + Ctrl + O` 直接開啟 _Trigger > Toggle_，或是從 Omarchy 選單（`Super + Space`）一步步走過去。那份清單裡的每一項都是不用管狀態存在哪裡、隨手就能切換的開關。控制桌面外觀的開關就放在它旁邊，位於 _Appearance_ 底下。

從終端機也能操作同樣的開關，使用 `omarchy toggle <thing>`。單獨執行 `omarchy toggle` 就能看到整組開關。

| 切換開關 | 快速鍵 | 指令 |
| ------ | ------ | ------- |
| 夜間暖光 | — | `omarchy toggle nightlight` |
| 靜音通知 | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| 保持喚醒（閒置不鎖定） | `Super + Ctrl + I` | `omarchy toggle idle` |
| 當機擷取 | — | `omarchy toggle crash-capture` |
| 螢幕保護程式 | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) 主題同步 | — | `omarchy toggle theme sync` |
| 選單列 | `Super + Shift + Space` | `omarchy toggle bar` |
| 全螢幕桌面（無列、無間距） | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| 動畫、模糊與陰影 | — | `omarchy toggle animations` |
| 觸控板 | `XF86TouchpadToggle` | `omarchy device touchpad` |
| 觸控螢幕 | — | `omarchy device touchscreen` |
| 暫停 | — | `omarchy toggle suspend` |
| 混合 GPU | — | `omarchy device gpu hybrid` |

觸控板、觸控螢幕和混合 GPU 的開關位於 _Trigger > Hardware_（`Super + Ctrl + H`）底下，而不是 Toggle 底下，因為只有當你真的有那種硬體時，它們才會出現。觸控板和觸控螢幕的開關在 Hyprland 重新載入後仍會保留——停用裝置的名稱會存到一個小型狀態檔，Hyprland 啟動時會讀取它，再次將裝置停用。

_Appearance_ 裡有選單列和動畫，還有幾項不是 `omarchy toggle` 指令、但運作方式相同的東西：列上的電池百分比、預設工作區版面配置，以及 _Windows_ 底下的視窗間距（`Super + Shift + Backspace`）和單視窗方形長寬比（`Super + Ctrl + Backspace`）。

當 Hyprland 沒有 GPU 可用、改用 CPU 繪圖（llvmpipe）時，例如 GPU 尚未受支援的 Mac、在大多數虛擬機器裡，或是圖形驅動程式載入失敗時，Omarchy 會在該工作階段關閉動畫、模糊與陰影，並透過一則通知告訴你一次。_Appearance > Animations On_ 可以把它們重新開啟，Omarchy 也會為之後的工作階段記住這個選擇。

這些大多只是在 `~/.local/state/omarchy/toggles/` 底下的一個旗標檔。如果你想在腳本裡根據某個開關分支處理，`omarchy-toggle-enabled` 會給你一個結束代碼，不用你自己去找：

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

這些旗標是以關閉狀態命名的——`screensaver-off`、`suspend-off`、`bar-off`——所以它們存在，就代表該功能已停用。

### 列上的指示圖示

當某個模式開啟時，頂部列中間、時鐘旁邊會出現一個小圖形。那就是指示圖示小工具，它會顯示螢幕錄影、待處理提醒、夜間暖光、勿擾和保持喚醒，還會在免密碼 sudo 開啟或有人連線到遠端工作階段時顯示警告。

未作用中的指示圖示會隱藏起來。把滑鼠懸停在列上任何位置，它們就會以淡化的樣子浮現，所以即使不知道快速鍵，你也能點一下將它開啟。點一下已作用中的圖示，就會把它關掉。如果你寧願隨時都看到全部圖示，把 `~/.config/omarchy/shell.json` 裡 `omarchy.indicators` 項目的 `alwaysShow` 設為 `true`——詳見[頂部列](05-the-top-bar.md)中關於列小工具的設定方式。

### 夜間暖光

夜間暖光會把螢幕調暖到 4000K，再切換一次就會回到 6500K。從切換選單（`Super + Ctrl + O`）翻開它，或使用 `omarchy toggle nightlight`。它由 hyprsunset 驅動，如果 hyprsunset 還沒在執行，切換開關會幫你啟動它。

依預設，hyprsunset 完全不會對你的螢幕做任何事。`~/.config/hypr/hyprsunset.conf` 隨附一個識別設定檔，目的正是讓顯示器保持不變，直到你要求暖色為止。如果你寧願讓它依照時間切換，把那個設定換成時間設定檔：

```
profile {
    time = 20:00
    temperature = 4000
}
```

然後把 `o.launch_on_start("hyprsunset")` 加入 `~/.config/hypr/autostart.lua`，讓 hyprsunset 在登入時啟動。切換開關使用的 4000K/6500K 這組數值是固定的，所以如果你想要不同的色溫，就要去改設定檔。

### 勿擾

`Super + Ctrl + Alt + ,` 會讓通知靜音。開啟時不會跳出任何快訊通知，列上會放一個劃掉的鈴鐺指示圖示，提醒你為什麼桌面安靜下來了。

不過什麼都不會遺失。被靜音的通知會被保留住：用 `Super + Shift + Alt + ,` 把最近幾則重新放回螢幕上。其餘內容請見[通知](10-notices.md)。

有三種訊息還是會穿透過來：Omarchy 自己針對你剛完成操作的確認快訊（"Theme changed"、"Screenshot saved"）、從命令列送出的重大警示，以及驗證碼。把所有訊息都標成重大、想硬擠到你面前的聊天應用程式，不算在內。

### 閒置

Omarchy shell 負責閒置行為，時間設定是 `~/.config/omarchy/shell.json` 裡最上層的 `idle` 區塊：

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

這兩個數字都是從你進入閒置那一刻起算的秒數——不是彼此相接。所以依預設，兩分半後會跳出螢幕保護程式，五分鐘時鎖定畫面就會接手，不管螢幕保護程式有沒有執行過都一樣。儲存檔案後，shell 會立即採用新的時間設定。

如果你在鎖定期限前關掉螢幕保護程式，那就算是一次活動，待處理的鎖定就會取消。你不會因為瞄一眼機器就被鎖在外面。

若要完全停止閒置鎖定，`Super + Ctrl + I`——或是 `omarchy toggle idle`——會開啟保持喚醒，列上會出現咖啡杯指示圖示。在長時間簡報之前，或是有個你想盯著看的建置過程之前，就按這個。再按一次就會回到正常狀態。如果你需要從腳本取得，`omarchy toggle idle status` 會以 JSON 印出目前狀態。

這講的是鎖定與螢幕保護程式，不是電源。暫停和休眠有它們自己的設定，請見[系統睡眠](36-system-sleep.md)。

### 螢幕保護程式

Omarchy 的螢幕保護程式是透過隨機文字效果播放的 ASCII 藝術，每台螢幕各跑一個執行個體。按任何鍵或移動滑鼠就會退出。

你可以從 _System > Screensaver_（`Super + Esc`）隨需啟動它，即使你已經關閉閒置螢幕保護程式，它也會強制跳出來。依預設沒有為它綁定快速鍵。

`omarchy toggle screensaver` 就是用來關閉閒置螢幕保護程式的，如果你寧願從工作直接進入鎖定。按任何鍵、點擊、捲動或移動滑鼠都會關掉它。

它畫出的標誌可以由你更換，位置在 _Appearance > Branding > Screensaver_ 底下。上傳一張 png 或 svg，Omarchy 就會把它轉成 ASCII。請見[品牌標誌](41-branding.md)。

### 鎖定畫面

`Super + Ctrl + L` 會鎖定機器。這會執行 Omarchy shell 的鎖定畫面、讓顯示器變黑、把鍵盤版面配置重設回第一個，讓你不會用錯字母輸入密碼，而且——如果你有在執行——會在離開時順便鎖定 1Password。

鎖定畫面接受密碼，等你設定好指紋之後，也會接受指紋。這個部分以及其他驗證方式，請見[硬體驗證](37-hardware-authentication.md)。
