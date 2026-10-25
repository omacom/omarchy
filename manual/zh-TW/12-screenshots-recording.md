# 螢幕截圖與錄影

螢幕上能擷取的一切，全都掛在 Print Screen 鍵底下。單獨按這顆鍵是拍照，搭配修飾鍵則是錄影、取色，或擷取某個區域內的文字。如果你的鍵盤根本沒有 Print Screen 鍵，`Super + Ctrl + Alt + C` 同樣可以螢幕截圖，`Super + Ctrl + C` 則會把整組功能以選單打開。

| 快捷鍵 | 功能 |
| ------ | -------- |
| `Print Screen` | 螢幕截圖 |
| `Super + Ctrl + Alt + C` | 螢幕截圖 |
| `Alt + Print Screen` | 螢幕錄影（或停止正在進行的錄影） |
| `Super + Print Screen` | 色彩選擇器 |
| `Super + Ctrl + Print Screen` | 從區域擷取文字 |
| `Super + Ctrl + C` | 擷取選單 |
| `Super + Ctrl + .` | 轉碼圖片或影片 |

## 螢幕截圖

按下 `Print Screen`（或 `Super + Ctrl + Alt + C`）後，Omasnap 會在覆疊畫面出現之前先擷取焦點所在的螢幕，所以你在瞄準時，底下的畫面不會位移。拖曳出任意形狀的區域、點一下視窗來擷取它，或點空白處擷取整個螢幕。在開始拖曳之前先按 `S`，可以擷取捲動區域。改變主意了？再按一次同一顆鍵就能關閉 Omasnap。

選好區域之後，Omasnap 會儲存擷取結果、複製到剪貼簿，並顯示 10 秒鐘的預覽。使用預覽上的釘選按鈕或 `Ctrl + P` 可以讓它留在畫面上，或選擇 Edit 來加上註解。

註解編輯器可以畫箭頭、線條、形狀、螢光標記、編號標記和文字，以及進行安全的遮蔽處理；裁切或挖掉圖片的一部分；對其中的文字進行 OCR；並加上背景底圖。在編輯器中，按 `Enter` 是複製並儲存完成後的 PNG，按 `Ctrl + C` 是只複製不儲存，按 `Ctrl + S` 則是只儲存不複製。

儲存的螢幕截圖預設會落在 `~/Pictures/Screenshots`，檔名像是 `screenshot-2026-08-13_14-22-05-firefox.png`。設定 `OMASNAP_SCREENSHOT_DIR` 可以改用其他目錄——工作階段環境變數該放哪裡，請看 [FAQ](46-faq.md)。Omasnap 會在儲存第一張截圖時建立該目錄。在 `~/.config/omasnap/omasnap.conf` 中設定 `[output] autosave = false`，可以停用自動儲存。

從終端機執行 `omarchy screenshot` 也能打開同一個覆疊畫面，而且你可以選擇起始模式：`omarchy capture screenshot region`、`windows`、`fullscreen` 或 `scroll`。再加上 `copy` 或 `save` 作為第二個引數，就會跳過預覽，直接把截圖送到該目的地。若要在輸出前先編輯，使用 `omarchy screenshot --editor=overlay` 開啟全螢幕編輯器，或使用 `omarchy screenshot --editor=window` 以獨立視窗開啟。

### 用鍵盤操作選擇器

選取畫面開啟時，完全不必碰滑鼠：

| 按鍵 | 功能 |
| --- | -------- |
| `S` | 切換捲動區域模式 |
| `Super + Arrow keys` | 在視窗模式中於各視窗之間移動 |
| `Return` | 擷取標示的視窗 |
| `Ctrl + A` | 擷取完整的焦點螢幕 |
| `R` | 還原本次工作階段中最後繪製的區域 |
| `Esc` | 關閉 Omasnap |

這些鍵位綁定只在 Omasnap 開啟時存在，所以不會和你自己設定中的任何東西衝突。

## 螢幕錄影

`Alt + Print Screen` 會開啟 _Trigger > Capture > Screenrecord_，它會問你希望音軌裡有什麼：無音訊、桌面音訊、桌面加麥克風，或桌面加麥克風加網路攝影機。最後一個選項只有在你確實有接上攝影機時才會出現。選好之後，Omarchy 的錄影選擇器會讓你拖曳出一個區域，或點選視窗或螢幕。

錄影跑在 gpu-screen-recorder 上，它用 GPU 以 60fps 編碼，必要時會退回 CPU。產生的成品是放在 `~/Videos` 裡的 MP4，檔名像是 `screenrecording-2026-08-13_14-22-05.mp4`。設定 `OMARCHY_SCREENRECORD_DIR` 可以改變這一點——但請注意，它和螢幕截圖目錄不同，這個目錄必須先存在，否則錄影會直接拒絕開始。

錄影期間，工具列上會出現一個小小的指示器。點它就能停止。你也可以再按一次 `Alt + Print Screen` 來停止，或使用 _Trigger > Capture > Screenrecord_ 底下的 _Stop Screenrecording_ 項目；這個項目只會在確實有東西正在錄影時出現。

停止時會先做一點整理工作再把檔案交給你：第一幀會被修剪掉，如果有音訊，會正規化到 -14 LUFS，並把最開頭 PipeWire 擷取時的爆音靜音。接著會跳出一則帶有錄影縮圖的通知。點它就能用 mpv 播放該檔案。

### 網路攝影機覆疊畫面

當你連同網路攝影機一起錄影時，攝影機畫面會以釘選、裁切過的人像視窗形式出現在錄影畫面的右下角。如果它正擋住你需要的東西，可以即時調整大小：

| 快捷鍵 | 功能 |
| ------ | -------- |
| `Super + Alt + [` | 將網路攝影機覆疊畫面縮小 |
| `Super + Alt + ]` | 將網路攝影機覆疊畫面放大 |

一共有三種大小——小、中、大——快捷鍵會在這三者之間逐段切換。中是預設值。它們是依錄影畫面比例計算的，所以無論你錄的是 1080p 螢幕還是 6K 螢幕，攝影機都會佔據同樣的畫面比例。而且如果你錄的是一個區域而不是整個顯示畫面，覆疊畫面會錨定在該區域的角落，而不是螢幕的角落，所以它會留在畫面之內。

你也可以直接呼叫 `omarchy-capture-webcam-resize small`，或呼叫 `reset` 回到中。

## 文字、QR codes 與色彩

`Super + Ctrl + Print Screen` 會選取一個區域，並把 OCR 出來的文字放進剪貼簿。這部分在 [文字擷取與聽寫](11-text-extraction-dictation.md) 裡有完整的說明。

_Trigger > Capture > QR Code_ 則是對 QR codes 玩同一套把戲。選取包含該 code 的區域，解碼後的值就會進入剪貼簿。它只會找 QR codes——密集的螢幕內容不這樣的話很容易被誤判成條碼。有件事值得知道：解碼後的值只會進入剪貼簿，不去任何其他地方。它不會被印出來，不會出現在通知裡，而且會被標記為敏感資訊，所以不會留在 [剪貼簿歷史](08-unified-clipboard-history.md) 裡。QR codes 常常帶有秘密——舉例來說，2FA 設定 code 背後的 `otpauth://` URI 就是——而你不會想讓這種東西出現在記錄裡。貼上的功能仍然完全正常。

`Super + Print Screen`（或 _Trigger > Capture > Color_）會把游標變成滴管。在畫面上點任何地方，色彩就會落進剪貼簿。再按一次快捷鍵，可以在不取色的情況下退出。

## 分享前先轉碼

一段 4K 螢幕錄影，或一張從手機來的原始 HEIC，常常太大，沒辦法就這樣傳出去。`Super + Ctrl + .`（或 _Trigger > Transcode_）解決的就是這件事。它會在 `~/Pictures` 和 `~/Videos` 之上給你一個模糊搜尋的檔案選擇器，然後請你選擇格式和大小。

圖片會轉成 jpg 或 png，品質有高、中、低三種，分別把寬度上限設為 3160、2160 和 1080 像素。影片會轉成 mp4 或動態 gif，解析度有 4k、1080p 或 720p。轉換後的檔案會寫在原檔旁邊，檔名裡帶有解析度——`demo-1080p.mp4`——而路徑會以檔案 URI 的形式複製到剪貼簿，所以你可以直接把它貼進接受檔案拖放的應用程式裡。

如果你已經知道自己要什麼，它也能從終端機運作：`omarchy transcode ~/Videos/demo.mov mp4 1080p`。還有 `omarchy transcode ascii`，它會把圖片變成 ASCII art——那個主要是給 [品牌形象](41-branding.md) 用的。

## 傳送到其他地方

拿到檔案之後，`Super + Ctrl + S` 會打開 Share 選單，並透過 LocalSend 把它傳給你網路上的另一台裝置。詳情請看 [GUI](22-guis.md)。
