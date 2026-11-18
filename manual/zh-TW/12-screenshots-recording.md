# 螢幕截圖與錄影

從螢幕上能抓取的一切，全都掛在 Print Screen 鍵上。單獨按這顆鍵就是拍一張圖，搭配修飾鍵則是錄影、取色，或擷取某個區域內的文字。如果你的鍵盤根本沒有 Print Screen 鍵，`Super + Ctrl + Alt + C` 也能拍出同樣的截圖，`Super + Ctrl + C` 則會把整組功能以選單方式打開。

| 快捷鍵 | 功能 |
| ------ | -------- |
| `Print Screen` | 螢幕截圖 |
| `Super + Ctrl + Alt + C` | 螢幕截圖 |
| `Alt + Print Screen` | 螢幕錄影（或停止正在進行的錄影） |
| `Super + Print Screen` | 色彩選取器 |
| `Super + Ctrl + Print Screen` | 從區域擷取文字 |
| `Super + Ctrl + C` | 擷取選單 |
| `Super + Ctrl + .` | 轉碼圖片或影片 |

## 螢幕截圖

按下 `Print Screen`（或 `Super + Ctrl + Alt + C`），Omasnap 會在它的覆蓋層出現之前先擷取目前聚焦的螢幕，所以你瞄準時畫面不會在你底下位移。拖出任意形狀的區域、點一下某個視窗來擷取它，或點一下空白處來擷取整個螢幕。在開始拖曳前按 `S`，可以擷取可捲動區域。改變主意了？再按一次同一顆鍵就能關閉 Omasnap。

選好區域後，Omasnap 會儲存擷取結果、複製到剪貼簿，並顯示帶有縮圖的通知，和儲存後的螢幕錄影一樣。選擇 Open 在圖片檢視器裡查看已儲存的截圖，或選擇 Edit 來為它加註。

加註編輯器可以畫箭頭、線條、形狀、螢光標示、編號標記、文字，以及安全遮蔽；裁切或挖除部分圖片；對圖片文字進行 OCR；並加上背景襯底。在編輯器中，按 `Enter` 複製並儲存完成的 PNG，按 `Ctrl + C` 只複製不儲存，或按 `Ctrl + S` 只儲存不複製。

已儲存的截圖預設會落在 `~/Pictures/Screenshots`，名稱像 `screenshot-2026-08-13_14-22-05-firefox.png`。設定 `OMASNAP_SCREENSHOT_DIR` 可以改用其他目錄 — 要把工作階段環境變數放在哪裡，請看[常見問題](46-faq.md)。Omasnap 會在儲存第一張截圖時建立該目錄。在 `~/.config/omasnap/omasnap.conf` 裡設定 `[output] autosave = false` 可以停用自動儲存；此後擷取結果只會被複製，並在預覽中顯示 10 秒，你可以用它的釘選按鈕或 `Ctrl + P` 把它保留在螢幕上。

在終端機裡，`omarchy screenshot` 會打開同一個覆蓋層，你還可以選擇它的起始模式：`omarchy capture screenshot region`、`windows`、`fullscreen` 或 `scroll`。第二個參數給 `copy` 或 `save`，截圖就會直接送往該目的地。要在輸出前先編輯，用 `omarchy screenshot --editor=overlay` 開啟全螢幕編輯器，或用 `omarchy screenshot --editor=window` 開在獨立視窗裡。

### 用鍵盤操作選取器

選取畫面開啟時，你完全不需要用滑鼠：

| 按鍵 | 功能 |
| --- | -------- |
| `S` | 切換可捲動區域模式 |
| `Super + Arrow keys` | 在視窗模式中於視窗之間移動 |
| `Return` | 擷取反白顯示的視窗 |
| `Ctrl + A` | 擷取完整的聚焦螢幕 |
| `R` | 還原本工作階段裡上次拖出的區域 |
| `Esc` | 關閉 Omasnap |

這些綁定只在 Omasnap 開啟時存在，所以不會和你自己設定檔裡的任何東西衝突。

## 螢幕錄影

`Alt + Print Screen` 會開啟 _Trigger > Capture > Screenrecord_，它會問你要什麼樣的音軌：無音訊、桌面音訊、桌面加麥克風，或桌面加麥克風加網路攝影機。最後一個選項只有在你真的接了攝影機時才會出現。選好後，Omarchy 的錄影選取器讓你拖出一個區域，或點選某個視窗或螢幕。

錄影是靠 gpu-screen-recorder 運作，它以 60fps 在 GPU 上編碼，必要時會退回 CPU。產生的成品是放在 `~/Videos` 裡的 MP4，名稱像 `screenrecording-2026-08-13_14-22-05.mp4`。設定 `OMARCHY_SCREENRECORD_DIR` 可以更換 — 但要注意，和截圖目錄不同，這個目錄必須預先存在，否則錄影會拒絕開始。

錄影時，狀態列上會出現一個小指示器。點它就能停止。你也可以再按一次 `Alt + Print Screen` 停止，或用 _Trigger > Capture > Screenrecord_ 底下的 _Stop Screenrecording_ 項目停止；該項目只在真的有東西正在錄製時才會出現。

停止時，它在把檔案交給你之前會做一點整理：修剪第一個畫格；如果有音訊，會正規化到 -14 LUFS，並把開頭最前面的 PipeWire 擷取爆音消音。接著會跳出通知，帶著來自錄影的縮圖。點它就在 Omaview 裡播放該檔案。

### 網路攝影機覆蓋層

當你搭配網路攝影機錄影時，攝影機畫面會以釘選、裁切為直向的視窗出現在你所錄製畫面的右下角。如果它剛好壓在你需要看的東西上，就即時調整大小：

| 快捷鍵 | 功能 |
| ------ | -------- |
| `Super + Alt + [` | 把網路攝影機覆蓋層變小 |
| `Super + Alt + ]` | 把網路攝影機覆蓋層變大 |

一共有三種大小 — 小、中、大 — 快捷鍵會在它們之間逐步切換。預設是中。它們和錄影畫面成比例，所以不論你錄的是 1080p 螢幕還是 6K 螢幕，攝影機在畫面中佔的比例都一樣。而且如果你錄的是某個區域而不是整個顯示器，覆蓋層會錨在那個區域的角落而非螢幕的角落，所以它會留在畫面裡。

你也可以直接用 `omarchy-capture-webcam-resize small` 呼叫，或用 `reset` 回到中。

## 文字、QR 碼與色彩

`Super + Ctrl + Print Screen` 會選取一個區域並透過 OCR 把文字送到剪貼簿。這部分的完整說明在[文字擷取與聽寫](11-text-extraction-dictation.md)。

_Trigger > Capture > QR Code_ 對 QR 碼也玩同一招。選取包含該碼的區域，解碼後的值就會進入剪貼簿。它只找 QR 碼 — 否則密集的螢幕內容動不動就會被誤判為條碼。值得知道的是：解碼後的值只會進入剪貼簿，不去任何其他地方。它不會被輸出、不會出現在通知裡，也會被標記為敏感內容，所以不會留在[剪貼簿歷史記錄](08-unified-clipboard-history.md)裡。QR 碼經常藏著祕密 — 例如 2FA 設定碼背後的 `otpauth://` URI — 你不會想讓那種東西留在記錄裡。貼上仍然照常運作。

`Super + Print Screen`（或 _Trigger > Capture > Color_）會把游標變成滴管。點一下螢幕上任何東西，那個色彩就會落在剪貼簿裡。再按一次快捷鍵就能不取色地退出。

## 分享前先轉碼

4K 螢幕錄影或手機來的原始 HEIC 往往太大，沒法直接傳。`Super + Ctrl + .`（或 _Trigger > Transcode_）就是來解決這個的。它會提供一個模糊搜尋的檔案選取器，範圍涵蓋 `~/Pictures` 和 `~/Videos`，接著詢問格式和大小。

圖片轉成 jpg 或 png，可選高、中、低，寬度上限分別為 3160、2160 和 1080 像素。影片轉成 mp4 或動態 gif，可選 4k、1080p 或 720p。轉換後的檔案會寫在原始檔案旁邊，檔名帶有解析度 — `demo-1080p.mp4` — 路徑也會以檔案 URI 的形式複製到剪貼簿，所以你可以直接貼進接受檔案拖放的應用程式。

如果你已經知道自己要什麼，從終端機也能操作：`omarchy transcode ~/Videos/demo.mov mp4 1080p`。還有 `omarchy transcode ascii`，它會把圖片轉成 ASCII 藝術 — 那個主要是給[品牌](41-branding.md)用的。

## 把它傳到某個地方

有了檔案後，`Super + Ctrl + S` 會開啟 Share 選單，透過 LocalSend 把它傳到你網路上的另一台裝置。詳見[圖形介面](22-guis.md)。
