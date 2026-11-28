# 瀏覽器

Omarchy 預設附帶 [Google Chrome](https://www.google.com/chrome/) 作為預設瀏覽器。它的主題會配合系統的其他部分，按下 `Super + Shift + Return`（或 `Super + Shift + B`）開啟的就是它，按下 `Super + Shift + Alt + B` 則會開啟無痕視窗，而且每個[網路應用程式](25-web-apps.md)都是在它裡面執行。它會直接開啟瀏覽器視窗：沒有歡迎畫面或登入提示，使用統計與當機報告不會傳送給 Google，廣告隱私提示也已關閉。只要你想要同步，隨時都可以從個人資料按鈕登入你的 Google 帳戶。

如果 Chrome 不合你的胃口，你也不是只能用它。在 Omarchy 選單的 _Install > Browser_ 底下，你會找到 [Chromium](https://www.chromium.org/)（Chrome 所源自的純粹開源版本）、Edge、Brave、Brave Origin、Firefox 和 [Zen](https://zen-browser.app/)（Edge 僅限 x86 機器）。選一個，Omarchy 就會安裝它、設定好它的政策目錄，並將你目前的主題套用到它身上。

## 將其中一個設為預設

安裝瀏覽器並不會讓它自動成為預設。要切換，請前往 _Setup > Defaults > Browser_ 並選一個。目前的預設瀏覽器會以打勾標示，而如果你選了尚未安裝的瀏覽器，會先幫你安裝。

在終端機裡是這樣：

```bash
omarchy default browser firefox
```

不帶引數執行它，它會告訴你目前的預設瀏覽器。這會設定 XDG 處理程式，所以跟著改變的不只是 Omarchy 的快捷鍵——任何需要開啟連結的東西，從聊天應用程式到終端機指令，都會前往你所選的瀏覽器。

## Copy URL 和 Download Video

Chromium 家族的瀏覽器（Chromium 本身、Chrome、Edge、Brave 和 Brave Origin）附帶三個 Omarchy 擴充功能：兩個能從瀏覽器延伸到你系統的其他部分，另一個則負責整理 WhatsApp。

**Copy URL** 會以 `Alt + Shift + L` 將目前分頁的網址放到你的剪貼簿上。這比點進網址列再複製更快，而且因為它是透過系統剪貼簿而非瀏覽器自己的剪貼簿，你會收到 Omarchy 的確認通知，網址也會立刻出現在[剪貼簿歷史](08-unified-clipboard-history.md)和每個其他應用程式中。如果你偏好用點的，工具列上也有按鈕。

**Download Video** 會以 `Alt + Shift + D` 抓取你正在看的頁面上播放的影片。它會將網址交給 [yt-dlp](https://github.com/yt-dlp/yt-dlp)，所以能用的遠不只有 YouTube，而下載的檔案會落在 `~/Videos`。進度會顯示在與音量和亮度相同的螢幕顯示中，就地更新，而不是堆積成一堆通知。如果你想讓檔案前往其他地方，請設定 `OMARCHY_YTDLP_DIR`——請參閱 [FAQ](46-faq.md) 以了解環境變數該放在哪裡。

這兩個擴充功能都透過一個小型的原生訊息傳遞主機與 Omarchy 溝通，而該主機會隨瀏覽器一起為你安裝。正是這個元件，讓網頁上的影片能落到你的家目錄、網址能進到你的剪貼簿管理員中，而這是一般擴充功能自己做不到的。

**WhatsApp Slim** 會讓 WhatsApp Web 跟隨你的系統主題，並在視窗變窄時收合它的聊天清單。

這些僅限 Chromium 家族使用。Firefox 和 Zen 沒有。

## Firefox 和 Zen

Firefox 和 Zen 屬於不同家族，所以待遇也不同：Omarchy 會安裝一份政策檔案以提供合理的預設值，並將它們切換到原生 Wayland 模式，這正是你在分數縮放和流暢的觸控板捲動時想要的。

它們沒有上面的 Chromium 擴充功能，Omarchy 也不會為它們套用主題，所以那些部分的體驗要由你自己設定。

## 再次移除其中一個

這些瀏覽器中的任何一個，包含 Chrome 在內，都可以在 _Remove > Browser_ 底下再次移除。之後，若另一個仍有安裝，連結就會改為開啟 Chrome 或 Chromium。
