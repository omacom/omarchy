# 疑難排解

### 我一更新就把系統弄壞了！

先試著[將系統還原](47-system-snapshots.md)到最近一次更新之前的版本。如果沒用，就使用 `omarchy-debug` 在 Discord 的 #omarchy-help 頻道分享你的問題。如果這些都無效，你可以使用 `omarchy-reinstall` 重新安裝預設的設定與套件。

### 為什麼有些應用程式在我的螢幕上看起來這麼大？

Omarchy 預設你使用的是 2 倍高解析度螢幕，因此需要在 `~/.config/hypr/monitors.lua` 中將 `GDK_SCALE` 設為 2。但如果你用的是 1 倍螢幕，你可以把 `local omarchy_gdk_scale = 2` 改成 1（然後重新啟動任何過大的應用程式）。請參閱[顯示器手冊](33-monitors.md)。

對於 Spotify，你可以使用 `Ctrl + Minus` 縮小介面（使用 `Ctrl + Plus` 則可以放大）。

### 為什麼我的 Super 鍵綁定全部失效了？

在部分 ASUS ROG 和 TUF 筆電上，`Fn + Super` 是一個很容易忽略的組合鍵，它會切換韌體層級的 Windows 鍵鎖定（本來是為了打遊戲時避免不小心離開遊戲而設計的）。螢幕上不會有任何提示告訴你這件事。鎖定開啟時，Super 完全不會發出任何訊號——所以每一個使用 Super 的 Omarchy 綁定都會失效，看起來就像 Hyprland 壞掉了一樣。

在你開始深入檢查 `~/.config/hypr/` 之前，先按一次 `Fn + Super`，如果 Super 還是沒恢復，再按一次，以免一直開著鎖定。這不是 Fn 鎖定，Fn 鎖定只會改變 F 鍵列的功能。

### 我的 Wi-Fi、Bluetooth、音訊或觸控板突然不能用了

在重新開機之前，先試著單獨重新啟動出問題的子系統。Omarchy 選單中的 _Update > Hardware_ 提供了 Wi-Fi、Bluetooth、Audio 和 Trackpad，重新載入其中一項就能解決大多數「五分鐘前還好好的」狀況——例如 Bluetooth 耳機無法重新連線、觸控板在 suspend 之後失靈、拔掉螢幕後聲音就不見了。

### 為什麼我的外接喇叭沒有聲音？

很可能是因為它們沒有被設為主要輸出裝置。點擊列右側的喇叭圖示，就會開啟音量彈出視窗，你可以在那裡選擇輸出裝置（也可以個別調整每個應用程式的音量）。

### 我的筆電喇叭聽起來怪怪的

在某些筆電上，Omarchy 會自動套用喇叭調校，來修正內建喇叭的頻率響應。`omarchy audio tuning status` 可以告訴你你的機器上是否有啟用這項功能，而 `omarchy audio tuning off` 則可以將它關閉，如果你比較想聽喇叭原始的聲音。

### 為什麼我不能用密碼登入或 sudo？

你大概是打錯太多次，所以被鎖住了。如果這發生在鎖定畫面，你可以按 `CTRL + ALT + F2` 開啟一個新的 TTY，在那裡以 root 登入，然後執行 `faillock --reset --user [your-username]`。這樣就會重設鎖定狀態，你就可以繼續了。

### 為什麼我的 1Password SSH Agent / CLI 的 1Password 授權提示沒有出現？

可能有 2 個原因：

若要顯示完整的核准提示，必須開啟 Settings > Advanced > Use Hardware Acceleration。_注意：這需要重新開機後才會開始生效。_

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

或者，如果你開機後還沒有啟動過 1Password，提示就不會出現。
