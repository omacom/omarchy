# 瀏覽器

Omarchy 預設搭載 [Google Chrome](https://www.google.com/chrome/) 作為預設瀏覽器。它已套用與系統其他部分一致的主題，`Super + Shift + Return`（或 `Super + Shift + B`）開啟的就是它，`Super + Shift + Alt + B` 則開啟私密視窗，所有 [網頁應用程式](25-web-apps.md) 也都在它裡面執行。它會直接開啟瀏覽器視窗：沒有歡迎畫面或登入提示，使用統計與當機報告不會傳送給 Google，廣告隱私提示也已關閉。只要你想同步，隨時都能從個人資料按鈕登入你的 Google 帳戶。

如果 Chrome 不合你的胃口，你也不是只能用它。在 Omarchy 選單的 _安裝 > 瀏覽器_ 下，你可以找到 [Chromium](https://www.chromium.org/)（Chrome 所採用的純粹開放原始碼版本）、Edge、Brave、Brave Origin、Firefox、[Zen](https://zen-browser.app/) 以及 [Ladybird](https://ladybird.org/)（Edge 僅限 x86 機器）。選一個，Omarchy 就會安裝它、設定它的政策目錄，並套用你目前的主題。

## 設為預設瀏覽器

安裝瀏覽器並不會讓它自動成為預設。要切換，請前往 _設定 > 預設 > 瀏覽器_ 並選取一個。目前的預設項目會以勾選標記，而選取尚未安裝的瀏覽器會先安裝它。

從終端機執行則是：

```bash
omarchy default browser firefox
```

不帶引數執行時，它會告訴你目前的預設瀏覽器。這會設定 XDG 處理程式，所以跟著切換的不只是 Omarchy 的快捷鍵——任何開啟連結的程式，從聊天應用程式到終端機指令，都會前往你選取的瀏覽器。

## 複製網址與下載影片

Chromium 系列瀏覽器（Chromium 本身、Chrome、Edge、Brave 與 Brave Origin）附有三個 Omarchy 擴充功能：其中兩個能從瀏覽器延伸到系統的其他部分，另一個則負責整理 WhatsApp。

**Copy URL** 會以 `Alt + Shift + L` 將目前分頁的位址放到你的剪貼簿。這比點進位址列再複製更快，而且由於它經過的是系統剪貼簿而非瀏覽器的剪貼簿，你會收到一則 Omarchy 通知確認，該網址也會立即出現在[剪貼簿歷史](08-unified-clipboard-history.md)以及其他每個應用程式中。如果你偏好點按，也有工具列按鈕可用。

**Download Video** 會以 `Alt + Shift + D` 抓取你正在看的頁面上播放的影片。它會將網址交給 [yt-dlp](https://github.com/yt-dlp/yt-dlp)，所以適用範圍遠不止 YouTube，下載的檔案會落在 `~/Videos`。進度會顯示在音量與亮度所使用的同一個螢幕顯示介面上，就地更新，而不是堆疊通知。若你希望檔案放到別處，請設定 `OMARCHY_YTDLP_DIR`——環境變數該放在哪裡，請參閱 [FAQ](46-faq.md)。

這兩個擴充功能都透過一個小型的原生傳訊主機與 Omarchy 溝通，該主機會隨瀏覽器一併為你安裝。就是這一部分，讓網頁的影片能夠進到你的家目錄、網址能夠進到你的剪貼簿管理器，這是一般擴充功能自己做不到的。

**WhatsApp Slim** 讓 WhatsApp Web 跟隨你的系統主題，並在視窗較窄時收合其聊天清單。

這些僅限 Chromium 系列。Firefox 與 Zen 不會獲得這些功能。

## Firefox and Zen

Firefox 與 Zen 屬於不同系列，所以待遇也不同：Omarchy 會為它們安裝一份政策檔案以提供合理的預設值，並將它們切換至原生 Wayland 模式，這正是分數縮放與流暢觸控板捲動所需要的。

它們不會獲得上述的 Chromium 擴充功能，也不會由 Omarchy 套用主題，所以這些部分的體驗需由你自行設定。

## Ladybird

Ladybird 是從零開始撰寫的瀏覽器，採用自己的引擎，而非 Chromium 或 Firefox 的引擎。它目前仍處於 alpha 階段，所以請預期有些網站還無法運作，Omarchy 會原封不動地安裝它：沒有擴充功能、沒有主題、沒有政策。它也沒有私密視窗，因此 `Super + Shift + Alt + B` 會以暫時性個人資料開啟它，該個人資料會在你關閉時刪除。[網頁應用程式](25-web-apps.md) 則會繼續在 Chrome 或 Chromium 中執行。

## 移除瀏覽器

上述任何瀏覽器，包括 Chrome，都可以在 _移除 > 瀏覽器_ 下再次移除。之後，若 Chrome 或 Chromium 中另一款仍有安裝，連結就會改用那一款。
