# 通知

通知會出現在焦點所在顯示器的右上角。你也可以透過快捷鍵通知，快速查看日期與時間、電池狀態和目前天氣。

## 通知

來自同一個應用程式或網站的通知會堆疊成一組，所以訊息很多的 Slack 頻道不會把你的建置失敗通知擠出畫面。將滑鼠停留在一組通知上即可將其展開；你正在閱讀時，不會有新通知滑到你的指標下方。點按卡片即可跳到它的來源，按右鍵、按中鍵，或點 ✕ 即可將其關閉。

卡片會提供它所帶來的操作：驗證碼的 _Copy code_（不會留存在[剪貼簿歷史記錄](08-unified-clipboard-history.md)中，並會在一分鐘後清除），以及應用程式提供的任何按鈕。點按通知文字中的連結即可開啟。

若要不用滑鼠操作，請按 `Super + Ctrl + ,`。系統會選取最新的一則通知，並為它的按鈕編號：按數字即可使用對應的按鈕，按 `Enter` 可點按該通知，按 `↑` 和 `↓` 可在通知之間移動，按 `Delete` 可關閉一則通知，按 `Esc` 則可交還鍵盤。它也會在閒置幾秒鐘後自動解除。

讓通知靜音會把通知先攔下來，但 Omarchy 自己的確認、緊急警示和驗證碼除外，畢竟那些是你剛才主動要求的。用 `Super + Shift + Alt + ,` 可以把最近幾則重新放到畫面上，不管它們有沒有被攔下來。歷史記錄會保留一天。

## 快捷鍵通知

### 日期與時間

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### 天氣

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

位置是從你的 IP 位址偵測出來的，通常已經夠接近了，但並非每次都如此。你可以用 `omarchy weather location --set Malibu` 把位置固定下來，或是加上座標來精確指定：`omarchy weather location --set Malibu 34.0259,-118.7798`。單獨執行 `omarchy weather location` 可以查看它認為你在哪裡，而 `--clear` 則可回到自動偵測。

### 電池

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
