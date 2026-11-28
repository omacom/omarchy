# 疑難排解

### 我把系統在更新時弄壞了！

先試著[將系統回退](47-system-snapshots.md)到你最近更新前的版本。如果不行，在 Discord 的 #omarchy-help 使用 `omarchy-debug` 分享你的問題。如果這些都失敗了，你可以使用 `omarchy-reinstall` 重新安裝預設設定與套件。

### 為什麼有些應用程式在我的顯示器上看起來這麼大？

Omarchy 預設你使用的是 2x 高解析度顯示器，所以在你於螢幕面板中選擇縮放比例之前，它會將 `GDK_SCALE` 設為 2。如果你使用的是 1x 顯示器，而 GTK 或 X11 應用程式顯示得過大，請在螢幕面板中為它選擇 1x，或將 `hl.env("GDK_SCALE", "1")` 加入 `~/.config/hypr/monitors.lua`（然後重新啟動任何顯示過大的應用程式）。請參閱[螢幕手冊](33-monitors.md)。

對於 Spotify，你可以使用 `Ctrl + Minus` 縮小 UI（使用 `Ctrl + Plus` 則可放大）。

### 為什麼我所有的 Super 鍵綁定都停止運作了？

在某些 ASUS ROG 和 TUF 筆記型電腦上，`Fn + Super` 是一個很容易忽略的組合鍵，它會切換韌體的 Windows 鍵鎖定（目的是為了遊戲時不會不小心離開遊戲）。切換時畫面上不會有任何提示。鎖定開啟時，Super 完全不會發出任何訊號——所以所有使用 Super 的 Omarchy 綁定都會停止運作，看起來就像是 Hyprland 壞掉了一樣。

在你開始深入檢查 `~/.config/hypr/` 之前，先按一次 `Fn + Super`，如果那沒有讓 Super 恢復，再按一次，以免讓鎖定保持開啟。這不是 Fn-lock，Fn-lock 只會改變 F 鍵列的功能。

### 我的 Wi-Fi、Bluetooth、音訊或觸控板突然停止運作

在重新開機之前，先試著單獨重新啟動出問題的子系統。Omarchy 選單中的 _Update > Hardware_ 有 Wi-Fi、Bluetooth、Audio 和 Trackpad，重新載入其中一個就能解決大多數「五分鐘前還好好的」情況——無法重新連線的 Bluetooth 耳機、從休眠喚醒後失效的觸控板，或是拔掉螢幕後消失的聲音。

### 為什麼我的外接喇叭沒有播放聲音？

很可能是因為它們沒有被設為主要輸出。點擊列右側的喇叭圖示，就會開啟音量彈出視窗，你可以在那裡選擇輸出裝置（也可以調整各個應用程式的音量混音）。

### 我筆記型電腦的喇叭聽起來怪怪的

在某些筆記型電腦上，Omarchy 會自動套用喇叭調校，修正內建喇叭的頻率響應。`omarchy audio tuning status` 會告訴你你的機器上是否有啟用中的調校，而如果你比較想聽喇叭未經處理的原始聲音，`omarchy audio tuning off` 則可將其關閉。

### 為什麼我無法用密碼登入或使用 sudo？

你大概是打錯了十次而被鎖定了。鎖定會在兩分鐘後自行解除。如果你等不了，而且這發生在鎖定畫面，你可以按 `CTRL + ALT + F2` 啟動新的 TTY，在那裡以 root 身分登入，然後執行 `faillock --reset --user [your-username]`。這會重設鎖定，然後你就可以繼續了。

### 我的密碼被接受了，但我又回到了登入畫面

即使你的密碼正確，損壞的工作階段環境檔案也可能阻止桌面啟動。在編輯過 `~/.config/uwsm/env.d/` 之後，這一點尤其值得檢查。

按 `Ctrl + Alt + F2`，用你平常的使用者名稱和密碼登入，然後檢查目前這次開機的使用者日誌：

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

尋找指出你某個環境檔案的錯誤，例如 `bad substitution`，它就出現在提示找不到 env 輸出標記的訊息之前。在再次嘗試登入之前，將該檔案移出 `env.d`。例如，如果錯誤指出的檔案是 `99-custom`：

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM 會跳過有語法錯誤的檔案，但像 `bad substitution` 這種只有在檔案執行時才會出現的致命錯誤，仍然可能阻止桌面啟動。系統快照回退無法修復這些檔案，因為 `/home` 不會被回退。

一旦你能登入，先修復已儲存的副本，再將它移回。`sh -n` 可以在不執行檔案的情況下抓出語法錯誤，但無法抓出檔案被 source 時發生的所有錯誤。測試變更時，請保持一個可運作的終端機開啟。

### 為什麼我的 1Password SSH Agent / CLI 的 1Password 授權提示沒有出現？

這可能有 2 個原因：

若要顯示完整的核准提示，必須開啟 Settings > Advanced > Use Hardware Acceleration。_注意：這需要重新開機後才會開始生效。_

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

或者，如果你自開機後還沒有啟動 1Password，提示就不會出現。
