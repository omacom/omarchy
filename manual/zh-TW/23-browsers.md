# 瀏覽器

Omarchy 附帶 [Chromium](https://www.chromium.org/) 作為預設瀏覽器。它是樸素的開源版本，經過主題調整以配合你系統的其餘部分，`Super + Shift + Return` 開啟的就是它，每個[網頁應用程式](25-web-apps.md)也在它裡面執行。

如果 Chromium 不合你的口味，你也不會被它綁住。在 Omarchy 選單的 _安裝 > Browser_ 下，你會找到 Chrome、Edge、Brave、Brave Origin、Firefox 和 [Zen](https://zen-browser.app/)。選一個，Omarchy 就會安裝它、設定好它的政策目錄，並將你目前的主題套用到它上。

## 將某個瀏覽器設為預設

安裝瀏覽器不會將它提升為預設。一旦它安裝到機器上，前往 _設定 > 預設值 > Browser_ 並選取它——選單只列出你實際已安裝的瀏覽器，並用勾號標記目前的預設瀏覽器。

在終端機中是這樣：

```bash
omarchy default browser firefox
```

不帶參數執行它，它會告訴你目前的預設瀏覽器。這會設定 XDG 處理程式，所以不只是 Omarchy 的快捷鍵會跟著走——從聊天應用程式到終端機命令，任何開啟連結的東西都會前往你選的瀏覽器。

## 複製 URL 和下載影片

Chromium 家族的瀏覽器（Chromium 本身、Chrome、Edge 和 Brave）附帶兩個 Omarchy 擴充功能，它們能從瀏覽器伸向你系統的其餘部分。

**Copy URL** 用 `Alt + Shift + L` 將目前分頁的地址放到你的剪貼簿上。這比點擊地址列再複製更快，而且因為它走的是系統剪貼簿而不是瀏覽器的剪貼簿，你會收到一個 Omarchy 通知確認此事，而且該 URL 會立即在[剪貼簿紀錄](08-unified-clipboard-history.md)和每個其他應用程式中可用。如果你偏好點擊，也有一個工具列按鈕。

**Download Video** 用 `Alt + Shift + D` 抓取你正在看的頁面上正在播放的影片。它會把 URL 交給 [yt-dlp](https://github.com/yt-dlp/yt-dlp)，所以它遠不止能用在 YouTube 上，而且下載會落入 `~/Videos`。進度會顯示在音量和亮度使用的同一個螢幕顯示中，原地更新而不是堆積通知。如果你希望檔案去別的地方，設定 `OMARCHY_YTDLP_DIR`——環境變數該放在哪裡，請參閱 [FAQ](46-faq.md)。

這兩個擴充功能都透過一個小型的原生訊息主機與 Omarchy 對話，它會連同瀏覽器一起為你安裝。正是這一小塊讓網頁的影片能落入你的家目錄、URL 能落入你的剪貼簿管理器，而一般的擴充功能自己做不到這一點。

這些僅限 Chromium 家族使用。Firefox 和 Zen 沒有這些功能。

## Firefox 和 Zen

Firefox 和 Zen 是不同的家族，所以它們得到不同的待遇：Omarchy 為它們安裝一個具備合理預設的政策檔案，並將它們切換到原生的 Wayland 模式，這是你進行分數縮放和流暢觸控板捲動時想要的。

它們沒有上面的 Chromium 擴充功能，也不會由 Omarchy 套用主題，所以這些部分的體驗需要你自己設定。

## 再次移除某個瀏覽器

你在這裡安裝的任何東西都可以在 _移除 > Browser_ 下移除。Chromium 不在該清單中——它是基礎系統的一部分。
