# 品牌形象

Omarchy 讓你為開機解鎖、螢幕保護程式和關於畫面，設定你的公司標誌或個人圖片。

### 開機解鎖

你可以使用 `omarchy plymouth preview` 來查看你的自訂標誌和顏色會是什麼樣子。它接受一個背景顏色、一個文字顏色、一個 logo png，以及預覽圖片的路徑：

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

然後使用 `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` 套用這套設定，這也會讓 SDDM 登入畫面使用相同的顏色和標誌。如果你想還原，可以使用 `omarchy plymouth reset`。

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### 螢幕保護程式

你可以在 _外觀 > 品牌形象 > 螢幕保護程式_ 下更改螢幕保護程式使用的標誌。這是一個 ASCII 標誌，所以你可以直接編輯文字，但你也可以給它一張 png 或 svg 圖片，我們會將它轉換為 ASCII。看起來相當酷。

 ![branding-screensaver](images/branding-screensaver.webp)

該選單中有三個項目：

- **編輯文字** 會在你的編輯器中開啟 `~/.config/omarchy/branding/screensaver.txt`。輸入或貼上任何你喜歡的內容 — ASCII 藝術、你的名字、一個粗魯的字。儲存並退出，螢幕保護程式會立即啟動，讓你可以看到效果。
- **從圖片設定** 會開啟一個檔案選擇器，讓你選擇 png 或 svg，將它轉換為 ASCII，並向你顯示結果。輪廓清晰的標誌效果遠比照片好。
- **還原預設值** 會把 Omarchy 標誌放回去。

### 關於畫面

相同的三個選項位於 _外觀 > 品牌形象 > 關於_ 下，適用於你從 Omarchy 選單取得的 _關於_ 畫面，而且運作方式完全相同 — 檔案是 `~/.config/omarchy/branding/about.txt`，每次變更後 About 視窗都會彈出。About 圖案會被轉換為比螢幕保護程式更小的尺寸，因為它必須裝進一個視窗裡，而不是填滿你的顯示器。

視窗開啟時，一道明亮的白光每隔幾秒會斜掠過圖案，然後讓它再次恢復靜止。只要你自己的圖案中每個字元都是單欄寬，它也會有這個效果 — 任何透過 _從圖片設定_ 產生的圖案都是如此。由 emoji 或雙寬字元組成的圖案則會保持靜止，如果你保留你自己的 fastfetch 設定，畫面也會保持靜止：在這些情況下，靜止的標誌是動畫在主動避讓，而不是失敗，因為在它們上面滑過一道閃光，會讓該行其餘部分落在錯誤的位置。

 ![branding-about](images/branding-about.webp)

### 自己轉換圖片

兩個 _從圖片設定_ 選項都只是在呼叫 `omarchy transcode ascii`，如果你想控制轉換過程，可以直接執行它：

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

它接受以終端機欄和列為單位的 `--width` 和 `--height`、為 `braille`（預設，而且細緻得多）或 `block` 其中之一的 `--mode`、用於決定哪些像素算作標誌一部分的 `--threshold` 百分比，以及當你的標誌在深色背景上是淺色時使用的 `--invert`。如果轉換結果變成一團，通常要調整的就是 threshold 這個旋鈕。

### 用文字代替標誌

`omarchy ascii` 會以 Delta Corps Priest 1 繪製文字，這正是 Omarchy 字標本身所使用的 FIGlet 字體，所以螢幕保護程式可以說些什麼，而不是顯示一張圖片：

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

它將文字作為引數接受，或者在沒有給予任何引數時從管道讀取。該字體只包含字母和空格 — 繪製時沒有數字或標點符號 — 所以任何其他內容都會被丟棄，並在 stderr 上指名，而不是被悄悄吞掉。
