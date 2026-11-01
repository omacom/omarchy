# 疑難排解

### 我更新把系統弄壞了！

先試著[將系統還原](47-system-snapshots.md)到最近一次更新之前的版本。如果沒用，就用 `omarchy-debug` 在 Discord 的 #omarchy-help 分享你的問題。如果這些都失敗，你可以用 `omarchy-reinstall` 重新安裝預設設定和套件。

### 為什麼有些應用程式在我的顯示器上這麼大？

Omarchy 預設你使用的是 2x 高解析度顯示器，所以在你於螢幕面板選擇縮放比例之前，它會將 `GDK_SCALE` 設為 2。如果你使用的是 1x 顯示器，而 GTK 或 X11 應用程式顯示得過大，請在螢幕面板中為它選擇 1x，或將 `hl.env("GDK_SCALE", "1")` 加入 `~/.config/hypr/monitors.lua`（然後重新啟動任何顯示過大的應用程式）。請參閱[螢幕手冊](33-monitors.md)。

對於 Spotify，你可以用 `Ctrl + Minus` 縮小介面（用 `Ctrl + Plus` 則可以放大）。

### 為什麼我的 Super 鍵綁定全部失效了？

在某些 ASUS ROG 和 TUF 筆電上，`Fn + Super` 是一個很容易忽略的組合鍵，會切換韌體的 Windows 鍵鎖定（原本是為了玩遊戲設計的，避免不小心離開遊戲）。畫面上不會有任何提示告訴你這件事已經發生。當鎖定開啟時，Super 完全不會發出任何訊號——所以每一個使用 Super 的 Omarchy 綁定都會停止運作，看起來就像 Hyprland 壞掉了一樣。

在深入研究 `~/.config/hypr/` 之前，先按一次 `Fn + Super`，如果 Super 沒有恢復，再按一次，以免讓鎖定保持開啟。這不是 Fn 鎖定，Fn 鎖定只會改變 F 鍵列的功能。

### 我的 Wi-Fi、Bluetooth、音訊或觸控板突然停止運作了

重新開機之前，先試著單獨重新啟動出問題的子系統。Omarchy 選單中的 _Update > Hardware_ 有 Wi-Fi、Bluetooth、Audio 和 Trackpad，重新載入其中一項，就能解決大多數「五分鐘前還好好的」情況——無法重新連線的 Bluetooth 耳機、從睡眠恢復後失效的觸控板、拔掉螢幕後消失的聲音。

### 為什麼我的外接喇叭沒有聲音？

可能因為它們沒有被設為主要輸出裝置。點擊頂欄右側的喇叭圖示，就會開啟音量彈出視窗，你可以在那裡選擇輸出裝置（也可以混合調整每個應用程式的音量）。

### 我的筆電喇叭聽起來怪怪的

在某些筆電上，Omarchy 會自動套用喇叭調校，修正內建喇叭的頻率響應。`omarchy audio tuning status` 會告訴你你的機器上是否有啟用中的調校，而 `omarchy audio tuning off` 則可以將它關閉，如果你比較想聽喇叭未經修正的原始聲音。

### 為什麼我無法用密碼登入或 sudo？

你可能輸入錯誤太多次，被鎖定了。如果這發生在鎖定畫面，你可以按 `CTRL + ALT + F2` 啟動一個新的 TTY，在那裡以 root 登入，然後執行 `faillock --reset --user [your-username]`。這樣就會重設鎖定，你就可以繼續了。

### 我的密碼被接受了，但我又回到登入畫面

損壞的工作階段環境檔案可能會讓桌面無法啟動，即使你的密碼是正確的。在編輯過 `~/.config/uwsm/env.d/` 之後，這一點特別值得檢查。

按 `Ctrl + Alt + F2`，用你平常的使用者名稱和密碼登入，並檢查目前開機的使用者日誌：

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

尋找一個指出你的某個環境檔案有錯誤的訊息，例如 `bad substitution`，它就出現環境輸出標記未找到的訊息之前。再次嘗試登入之前，將該檔案移出 `env.d`。例如，如果錯誤指出的是 `99-custom`：

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM 會跳過有語法錯誤的檔案，但只有在檔案執行時才會出現的致命錯誤，例如 `bad substitution`，仍然可能會讓桌面無法啟動。系統快照還原無法修復這些檔案，因為 `/home` 不會被還原。

登入之後，先修好儲存的副本，再將它移回去。`sh -n` 可以在不執行檔案的情況下找出語法錯誤，但無法找出在載入檔案時發生的所有錯誤。測試變更時，請保持一個可用的終端機開啟著。

### 為什麼我的 1Password SSH Agent / CLI 的 1Password 授權提示沒有出現？

這可能有 2 個原因：

為了讓豐富的批准提示出現，Settings > Advanced > Use Hardware Acceleration 必須開啟。_注意：這需要重新開機才會開始生效。_

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

或者，如果你自開機以來還沒有啟動過 1Password，提示就不會出現。
