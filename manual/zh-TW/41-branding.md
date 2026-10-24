# 品牌標誌

Omarchy 讓你可以為開機解鎖畫面、螢幕保護程式和「關於」畫面設定你的公司標誌或個人圖片。

### 開機解鎖

你可以用 `omarchy plymouth preview` 預覽你的自訂標誌和色彩會是什麼樣子。它接受一個背景色、一個文字色、一個標誌 png，以及預覽圖片的路徑：

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

然後用 `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` 套用設定，這也會讓 SDDM 登入畫面使用相同的色彩和標誌。如果你想還原，可以使用 `omarchy plymouth reset`。

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### 螢幕保護程式

你可以在 _風格 > 螢幕保護程式_ 之下變更螢幕保護程式使用的標誌。它是一個 ASCII 標誌，所以你可以直接編輯文字，但你也可以給它一張 png 或 svg 圖片，我們會把它轉換成 ASCII。效果看起來挺酷的。

 ![branding-screensaver](images/branding-screensaver.webp)

該選單中有三個項目：

- **編輯文字** 會在你的編輯器中開啟 `~/.config/omarchy/branding/screensaver.txt`。輸入或貼上任何你想要的東西——ASCII 藝術、你的名字、一句粗話。存檔並離開後，螢幕保護程式會立刻啟動讓你看看效果。
- **以圖片設定** 會開啟檔案選擇器讓你挑一張 png 或 svg，把它轉換成 ASCII，並顯示結果給你看。輪廓清晰的標誌效果遠勝過照片。
- **還原預設** 會把 Omarchy 標誌放回來。

### 關於畫面

在 _風格 > 關於_ 之下有同樣的三個選項，用於你在 Omarchy 選單中開啟的 _關於_ 畫面，運作方式完全相同——檔案是 `~/.config/omarchy/branding/about.txt`，「關於」視窗會在每次變更後彈出。「關於」畫面的圖案轉換尺寸比螢幕保護程式的小，因為它必須塞進一個視窗裡，而不是填滿你的顯示器。

當視窗開著的時候，一道綠色的微光每隔幾秒會斜掠過圖案，然後又讓它靜止下來。你自己的圖案也會有這個效果，只要其中每個字元的寬度都是一欄——凡是 _以圖片設定_ 產出的東西都是如此。由表情符號或雙寬字元組成的圖案則會保持靜止；如果你保留了自己的 fastfetch 設定，畫面也會保持靜止：在這些情況下，靜止的標誌是動畫在讓路而不是失敗，因為讓微光滑過它們會讓同一行的其餘內容落在錯誤的位置。

 ![branding-about](images/branding-about.webp)

### 自己轉換圖片

兩個 _以圖片設定_ 選項其實都只是呼叫 `omarchy transcode ascii`，如果你想掌控轉換過程，可以直接執行它：

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

它接受以終端機欄和列為單位的 `--width` 和 `--height`、`braille`（預設值，且精細得多）或 `block` 的 `--mode`、決定哪些像素算是標誌一部分的 `--threshold` 百分比，以及當你的標誌是深色背景上的淺色圖案時使用的 `--invert`。如果轉換結果變成一坨，通常要調整的就是 threshold 這個旋鈕。

### 用文字代替標誌

`omarchy ascii` 會用 Delta Corps Priest 1 來繪製文字，這正是 Omarchy 文字標誌本身所用的 FIGlet 字型，所以螢幕保護程式可以說點什麼，而不只是顯示一張圖片：

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

它接受以引數傳入的文字，或在沒有引數時從管道讀取。這個字型只包含字母和空格——它在繪製時就沒有數字或標點符號——所以其他任何字元都會被丟棄並在 stderr 上指名，而不是被悄悄吞掉。
