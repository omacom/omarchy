# 品牌標誌

Omarchy 讓你可以為開機解鎖、螢幕保護程式和關於畫面，設定你的公司標誌或個人圖片。

### 開機解鎖

你可以用 `omarchy plymouth preview` 來預覽自訂標誌和顏色會長什麼樣子。它需要一個背景色、一個文字色、一個 logo png，以及一條預覽圖片的路徑：

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

然後用 `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` 套用設定，這也會讓 SDDM 登入畫面使用同樣的顏色和標誌。如果你想還原，可以用 `omarchy plymouth reset`。

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### 螢幕保護程式

你可以在 _外觀 > 品牌標誌 > 螢幕保護程式_ 底下更改螢幕保護程式使用的標誌。它是 ASCII 標誌，所以你可以直接編輯文字，但你也可以給它一張 png 或 svg 圖片，我們會把那轉成 ASCII。看起來蠻酷的。

 ![branding-screensaver](images/branding-screensaver.webp)

那個選單裡有三個項目：

- **編輯文字** 會在你的編輯器裡開啟 `~/.config/omarchy/branding/screensaver.txt`。隨你喜歡輸入或貼上任何東西 — ASCII 藝術、你的名字、一個粗俗的字也行。儲存並離開，螢幕保護程式就會立刻啟動，讓你看看效果。
- **從圖片設定** 會開啟一個檔案選擇器讓你選 png 或 svg，把它轉成 ASCII，並把結果顯示給你看。輪廓清楚的標誌效果會比照片好得多。
- **還原預設值** 會把 Omarchy 標誌放回去。

### 關於畫面

在 _外觀 > 品牌標誌 > 關於_ 底下有同樣的三個選項，對應的是你從 Omarchy 選單叫出的 _關於_ 畫面，而且運作方式完全相同 — 檔案是 `~/.config/omarchy/branding/about.txt`，每次更改後關於視窗都會彈出來。關於畫面的圖案轉換尺寸會比螢幕保護程式的更小，畢竟它必須塞進一個視窗裡，而不是填滿整個螢幕。

視窗打開時，每隔幾秒就會有一道綠光斜斜地掠過圖案，然後又回復靜止。你的自訂圖案也會有這個效果，只要裡面的每個字元寬度都是一欄 — _從圖片設定_ 產生的圖案全部都是。用 emoji 或雙寬字元拼成的圖案則會保持靜止，如果你保留自己的一份 fastfetch 設定，畫面也一樣會靜止：在這些情況下，靜止的標誌是動畫懂得避開，而不是失敗，因為硬要把一道光滑過它們，會讓該行其餘部分跑到錯誤的位置。

 ![branding-about](images/branding-about.webp)

### 自己轉換圖片

兩個 _從圖片設定_ 選項都只是在呼叫 `omarchy transcode ascii`，如果你想掌控轉換過程，也可以直接執行它：

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

它接受以終端欄與列為單位的 `--width` 和 `--height`、值為 `braille`（預設，而且精細得多）或 `block` 的 `--mode`、用來決定哪些像素算是標誌一部分的 `--threshold` 百分比，以及在你的標誌是深色背景配淺色圖案時使用的 `--invert`。如果轉出來是一團糊，門檻值通常就是該轉的那個旋鈕。

### 用文字取代標誌

`omarchy ascii` 會用 Delta Corps Priest 1 來繪製文字，那正是繪製 Omarchy 字標本身的 FIGlet 字型，所以螢幕保護程式可以說一句话，而不是顯示一張圖：

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

它把文字作為引數接收，或在沒有提供文字時從管線讀取。這個字型只有字母和空格 — 當初繪製時就沒有數字或標點符號 — 所以其他任何東西都會被丟棄，並在 stderr 上點名指出，而不是悄悄吞掉。
