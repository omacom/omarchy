# 通知提示

通知會出現在目前聚焦的顯示器右上角。你也可以透過快速鍵提示，快速查看日期與時間、電池狀態，以及目前天氣。

## 通知

來自同一個應用程式或網站的通知會堆疊成一組牌疊，這樣話多的 Slack 頻道就不會把你的建置失敗通知擠出畫面。將滑鼠停留在一組牌疊上即可將它展開；當你正在閱讀時，不會有新通知滑到你的指標底下。按一下卡片即可跳到它的來源處，按右鍵、按中鍵，或點 ✕ 即可將它關閉。

卡片會提供它所攜帶的操作：針對驗證碼的 _複製驗證碼_（不會保留在[剪貼簿歷史紀錄](08-unified-clipboard-history.md)中，並會在一分鐘後清除），以及應用程式提供的任何按鈕。點擊通知文字中的連結即可開啟。

`Super + ,` 會關閉最新的一則通知，或在通知提供該操作時開啟它所指向的內容，`Super + Alt + ,` 只會關閉最後一則，`Super + Shift + ,` 會將它們全部關閉，而 `Super + Shift + Alt + ,` 會開啟歷史紀錄。若要在不使用滑鼠的情況下操作，請按 `Super + Ctrl + ,`。此時會選取最新的一則通知，並為其按鈕編號：按數字即可使用其中一個按鈕，按 `Enter` 即可點擊該通知，按 `↑` 與 `↓` 可在通知之間移動，按 `Delete` 可關閉一則，按 `Esc` 則交還鍵盤控制權。閒置幾秒後，它也會自行結束。

靜音通知會將它們攔下，但 Omarchy 自己的確認訊息、緊急警示，以及你剛剛才要求的驗證碼除外。使用 `Super + Shift + Alt + ,` 可將最近幾則重新顯示到畫面上，無論它們是否曾被攔下。歷史紀錄會保留一天。

## 快速鍵提示

### 日期與時間

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### 天氣

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

所在位置是根據你的 IP 位址偵測的，通常夠接近了，但並非總是如此。你可以使用 `omarchy weather location --set Malibu` 將它固定下來，或加上座標來精確指定：`omarchy weather location --set Malibu 34.0259,-118.7798`。單獨執行 `omarchy weather location` 即可查看它認為你所在的位置，並使用 `--clear` 回到自動偵測。

### 電池

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
