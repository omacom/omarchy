# 疑難排解

### 我一更新就把系統弄壞了！

先試著[將系統還原](47-system-snapshots.md)到最近一次更新前的版本。如果沒用，使用 `omarchy-debug` 將你的問題分享到 Discord 的 #omarchy-help。如果這些全都沒用，你可以使用 `omarchy-reinstall` 重新安裝預設設定與套件。

### 為什麼有些應用程式在我的顯示器上這麼大？

Omarchy 假設你使用的是 2x 高解析度顯示器，所以在你於螢幕面板中選擇縮放比例之前，會將 `GDK_SCALE` 設定為 2。如果你在 1x 顯示器上，且 GTK 或 X11 應用程式顯示得過大，請在螢幕面板中為它選擇 1x，或將 `hl.env("GDK_SCALE", "1")` 加入 `~/.config/hypr/monitors.lua`（然後重新啟動任何顯示得過大的應用程式）。參閱[顯示器手冊](33-monitors.md)。

至於 Spotify，你可以使用 `Ctrl + Minus` 縮小介面（以及使用 `Ctrl + Plus` 放大介面）。

### 為什麼我的 Super 鍵綁定全都停止運作了？

在部分 ASUS ROG 與 TUF 筆記型電腦上，`Fn + Super` 是一個容易忽略的組合鍵，會切換韌體的 Windows 鍵鎖定（原本是為了遊戲設計，讓你不會不小心離開遊戲）。畫面上不會有任何提示告訴你這件事發生了。鎖定開啟時，Super 完全不會發出任何訊號——所以每一個使用 Super 的 Omarchy 綁定就這樣停了，看起來就像 Hyprland 壞了一樣。

在你開始深入翻查 `~/.config/hypr/` 之前，先按一次 `Fn + Super`，如果這樣還是沒讓 Super 回來，再按一次，才不會讓鎖定一直維持開啟。這不是 Fn-lock，Fn-lock 只會改變 F 鍵列的行為。

### 我的 Wi-Fi、Bluetooth、音訊或觸控板突然停止運作了

重新開機之前，先試著單獨重新啟動出問題的子系統。Omarchy 選單中的 _Update > Hardware_ 有 Wi-Fi、Bluetooth、Audio 與 Trackpad，重新載入其中之一就能解決大多數「五分鐘前還好好的」狀況——Bluetooth 耳機無法重新連線、觸控板在喚醒後沒反應、拔掉螢幕時聲音就消失了。

### 為什麼我的外接喇叭沒有聲音？

可能因為它們沒有被設為主要輸出裝置。點擊狀態列右側的喇叭圖示，就會開啟音量彈出視窗，你可以在那裡選擇輸出裝置（也可以混合調整各應用程式的音量）。

### 我的筆記型電腦喇叭聽起來怪怪的

在部分筆記型電腦上，Omarchy 會自動套用一項喇叭調校，修正內建喇叭的頻率響應。`omarchy audio tuning status` 會告訴你你的機器上是否有正在生效的調校，而 `omarchy audio tuning off` 可以將其關閉，如果你寧可聽喇叭原始的聲音。

### 為什麼我不能用我的密碼登入或 sudo？

你大概是打錯太多次而被鎖定了。如果這發生在鎖定畫面，你可以按 `CTRL + ALT + F2` 啟動一個新的 TTY，在那裡以 root 身分登入，然後執行 `faillock --reset --user [your-username]`。這樣就會重設鎖定，你就可以繼續了。

### 為什麼我的 1Password SSH Agent / CLI 的 1Password 授權提示沒有出現？

這可能有 2 個原因：

為了讓豐富的核准提示出現，Settings > Advanced > Use Hardware Acceleration 必須開啟。_注意：這需要重新開機才會開始生效。_

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

或者，如果你自開機以來還沒有啟動過 1Password，提示就不會出現。
