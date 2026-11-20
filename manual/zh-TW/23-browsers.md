# 瀏覽器

Omarchy 預設搭載 [Google Chrome](https://www.google.com/chrome/) 作為預設瀏覽器。它會套用與系統其他部分一致的主題，也是按 `Super + Shift + Return` 時開啟的瀏覽器，而且每個[網頁應用程式](25-web-apps.md)都在其中執行。它會直接開啟瀏覽器視窗：沒有歡迎畫面或登入提示，使用統計資料與當機報告不會傳送給 Google，廣告隱私提示也已關閉。只要你想同步，隨時都能從個人資料按鈕登入你的 Google 帳戶。

如果 Chrome 不合你的口味，你也不必被它綁住。在 Omarchy 選單的 _Install > Browser_ 底下，你會找到 [Chromium](https://www.chromium.org/)（Chrome 所源自的純粹開源版本）、Edge、Brave、Brave Origin、Firefox 和 [Zen](https://zen-browser.app/)。選一個，Omarchy 就會安裝它、設定好它的政策目錄，並將你目前的主題套用到它身上。

## 將某個瀏覽器設為預設

安裝瀏覽器並不會讓它自動晉升為預設瀏覽器。等它裝到電腦上之後，前往 _Setup > Defaults > Browser_ 並選取它——選單只會列出你實際已安裝的瀏覽器，並以勾選標記目前的預設瀏覽器。

從終端機操作則是：

```bash
omarchy default browser firefox
```

不帶任何引數執行它，它會告訴你目前的預設瀏覽器。這會設定 XDG 處理程式，因此不只是 Omarchy 的快捷鍵會跟著走——任何開啟連結的東西，從聊天應用程式到終端機指令，都會前往你選取的瀏覽器。

## Copy URL 和 Download Video

Chromium 家族的瀏覽器（Chromium 本身、Chrome、Edge 和 Brave）附帶兩個 Omarchy 擴充功能，能從瀏覽器伸手進入你系統的其他部分。

**Copy URL** 會用 `Alt + Shift + L` 將目前分頁的位址放到你的剪貼簿上。這比點進位址列再複製更快，而且因為它走的是系統剪貼簿而非瀏覽器的剪貼簿，你會收到一則 Omarchy 通知確認完成，該 URL 也會立即可在[統一剪貼簿歷史](08-unified-clipboard-history.md)以及其他每個應用程式中使用。工具列上也有一個按鈕，如果你比較喜歡用點的。

**Download Video** 會用 `Alt + Shift + D` 抓取你正在看的頁面上播放的影片。它將 URL 交給 [yt-dlp](https://github.com/yt-dlp/yt-dlp)，因此適用的網站遠不止 YouTube，下載的檔案會落在 `~/Videos`。進度會顯示在音量和亮度所使用的同一個螢幕顯示上，就地更新，而非堆疊出一堆通知。如果你想讓檔案改放到其他地方，請設定 `OMARCHY_YTDLP_DIR`——環境變數該放在哪裡，請參閱 [FAQ](46-faq.md)。

這兩個擴充功能都透過一個小型的原生訊息傳遞主機與 Omarchy 溝通，該主機會隨瀏覽器一併為你安裝好。正是這個元件，讓網頁上的影片能最終進入你的家目錄、讓 URL 能進入你的剪貼簿管理器，而這是一般擴充功能單靠自己做不到的。

這些僅限 Chromium 家族。Firefox 和 Zen 沒有這些功能。

## Firefox 和 Zen

Firefox 和 Zen 屬於不同的家族，因此得到的待遇也不同：Omarchy 會為它們安裝一份政策檔案以提供合理的預設值，並將它們切換到原生 Wayland 模式，這是分數縮放和平滑觸控板捲動所需要的。

它們沒有上面的 Chromium 擴充功能，也不會由 Omarchy 套用主題，因此這些部分的體驗就交給你自己設定。

## 再次移除某個瀏覽器

這些瀏覽器中的任何一個，包括 Chrome，都可以在 _Remove > Browser_ 底下再次移除。如果 Chrome 或 Chromium 中的另一個仍有安裝，連結之後就會改前往那一個。
