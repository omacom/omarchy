# 疑難排解

### 我把系統更新壞了！

先試著把系統[回滾](47-system-snapshots.md)到最近一次更新之前的版本。如果沒效，使用 `omarchy-debug` 把你的問題分享到 Discord 的 #omarchy-help 頻道。如果連這樣都不行，你可以用 `omarchy-reinstall` 重新安裝預設設定和套件。

### 為什麼有些應用程式在我的顯示器上這麼大？

Omarchy 假設你使用的是 2 倍高解析度顯示器，這需要在 `~/.config/hypr/monitors.lua` 中把 `GDK_SCALE` 設為 2。但如果你用的是 1 倍顯示器，你可以把 `local omarchy_gdk_scale = 2` 改成 1（然後重新啟動任何過大的應用程式）。請參閱[顯示器手冊](33-monitors.md)。

對於 Spotify，你可以使用 `Ctrl + Minus` 縮小介面（用 `Ctrl + Plus` 則可放大）。

### 我的 Wi-Fi、藍牙、音訊或觸控板突然停止運作了

重新開機之前，先試著單獨重新啟動出問題的子系統。Omarchy 選單中的 _更新 > 硬體_ 有 Wi-Fi、藍牙、音訊和觸控板，重新載入其中之一可以解決大多數「五分鐘前還好好的」狀況——重新連不上線的藍牙耳機、暫停後死了的觸控板、拔掉顯示器時消失的聲音。

### 為什麼我的外接喇叭沒有聲音？

很可能是因為它們沒被設成主要輸出。點選選單列右側的喇叭圖示，就會開啟音量彈出視窗，你可以在那裡挑選輸出裝置（也可以混音每個應用程式的音量）。

### 我的筆電喇叭聽起來怪怪的

在某些筆電上，Omarchy 會自動套用一種喇叭調校，以校正內建喇叭的頻率響應。`omarchy audio tuning status` 會告訴你你的機器上是否啟用了某種調校，而 `omarchy audio tuning off` 可以在你比較想聽喇叭原始聲音時將它關閉。

### 為什麼我無法用密碼登入或執行 sudo？

你很可能輸錯太多次而被鎖住了。如果這發生在鎖定畫面上，你可以按 `CTRL + ALT + F2` 開啟一個新的 TTY，在那裡以 root 登入，然後執行 `faillock --reset --user [your-username]`。這會重設鎖定，然後你就沒問題了。

### 為什麼我的 1Password 對 1Password SSH Agent / CLI 的授權提示沒有出現？

這可能出於 2 個原因：

要讓豐富的核准提示出現，必須開啟 Settings > Advanced > Use Hardware Acceleration。_注意：這需要重新開機才會生效。_

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

或者，如果你開機之後還沒有啟動過 1Password，提示也不會出現。
