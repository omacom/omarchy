# 品牌標誌

Omarchy 讓你可以為螢幕保護程式和「關於」畫面設定公司標誌或個人圖片。

### 螢幕保護程式

你可以在 _外觀 > 品牌標誌 > 螢幕保護程式_ 底下變更螢幕保護程式使用的標誌。它是 ASCII 標誌，所以你可以直接編輯文字，但你也可以交給它一張 png 或 svg 圖片，我們會將它轉換成 ASCII。看起來相當酷。

 ![branding-screensaver](images/branding-screensaver.webp)

該選單中有三個項目：

- **編輯文字**會在你的編輯器中開啟 `~/.config/omarchy/branding/screensaver.txt`。輸入或貼上任何你喜歡的內容 — ASCII 藝術、你的名字、一句粗話。儲存並結束，螢幕保護程式就會立即啟動，讓你馬上看到效果。
- **從圖片設定**會開啟檔案選擇器，讓你選取 png 或 svg，將它轉換成 ASCII，並向你顯示結果。輪廓清晰的標誌效果遠比照片好得多。
- **還原預設值**會將 Omarchy 標誌放回去。

### 關於畫面

在 _外觀 > 品牌標誌 > 關於_ 底下也有相同的三個選項，用於你從 Omarchy 選單取得的 _關於_ 畫面，而且運作方式完全相同 — 檔案是 `~/.config/omarchy/branding/about.txt`，而「關於」視窗會在每次變更後彈出。「關於」的圖案轉換後的尺寸比螢幕保護程式的還小，因為它必須塞進一個視窗裡，而不是填滿你的顯示器。

視窗開啟時，一道明亮的白光帶每隔幾秒就會斜斜地橫過圖案，然後又讓它恢復靜止。只要你的圖案中每個字元都只有一欄寬，你自己的圖案也會有這個效果 — 任何由 _從圖片設定_ 產生的圖案都是如此。改由 emoji 或雙寬字元組成的圖案則會保持靜止，而如果你保留自己的一份 fastfetch 設定，畫面也一樣會保持靜止：在那些情況下，靜止的標誌是動畫在主動避開，而不是失敗了，因為讓一道閃光滑過它們，會讓該行的其餘部分落在錯誤的位置。

 ![branding-about](images/branding-about.webp)

### 自行轉換圖片

兩個 _從圖片設定_ 選項其實都只是在呼叫 `omarchy transcode ascii`，如果你想掌控轉換過程，也可以直接執行它：

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

它接受以終端機欄數和列數為單位的 `--width` 和 `--height`、值為 `braille`（預設值，而且精細得多）或 `block` 的 `--mode`、用來決定哪些像素算作標誌一部分的 `--threshold` 百分比，以及當你的標誌是深色背景上的淺色圖案時使用的 `--invert`。如果轉換結果變成一團糊狀物，通常要調整的就是閾值這個旋鈕。

### 用文字代替標誌

`omarchy ascii` 會以 Delta Corps Priest 1 繪製文字，這正是 Omarchy 文字標誌本身所使用的 FIGlet 字型，所以螢幕保護程式可以說些什麼，而不是顯示一張圖片：

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

它將文字作為引數接收，或者在未給予任何引數時從管道讀取。該字型只包含字母和空格 — 繪製時並未包含數字或標點符號 — 因此任何其他字元都會被捨棄，並在 stderr 上明確指出，而不是被悄悄吞掉。
