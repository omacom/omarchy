# 截圖與錄影

你能從畫面上擷取的一切，都繫於 Print Screen 鍵。單按這個鍵就是拍照，搭配修飾鍵則可以錄影、選取一種顏色，或擷取某個區域內的文字。如果你的鍵盤根本沒有 Print Screen 鍵，`Super + Ctrl + Alt + C` 可以拍出相同的截圖，`Super + Ctrl + C` 則會以選單開啟整組功能。

| Hotkey | Function |
| ------ | -------- |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot |
| `Alt + Print Screen` | Screenrecord (or stop the one that's running) |
| `Super + Print Screen` | Colour picker |
| `Super + Ctrl + Print Screen` | Extract text from a region |
| `Super + Ctrl + C` | Capture menu |
| `Super + Ctrl + .` | Transcode a picture or video |

## 截圖

按下 `Print Screen`（或 `Super + Ctrl + Alt + C`），Omasnap 會在它的覆疊介面出現之前擷取目前焦點所在的螢幕，因此你在瞄準時，底下的畫面不會位移。拖曳出任意形狀的區域、點按某個視窗來擷取它，或點按空白處擷取整個螢幕。在繪製前按下 `S`，即可擷取捲動區域。改變主意了嗎？再按一次相同的鍵即可關閉 Omasnap。

選取區域後，Omasnap 會儲存擷取內容、將它複製到剪貼簿，並顯示帶有縮圖的通知，就像已儲存的螢幕錄影一樣。選擇 Open 在你的圖片檢視器中檢視已儲存的截圖，或選擇 Edit 為它加上註解。

註解編輯器可以繪製箭頭、線條、形狀、螢光標示、編號標記、文字和安全遮蔽；裁剪或切除部分圖片；對其文字進行 OCR；並加入背景。在編輯器中，按 `Enter` 複製並儲存完成的 PNG，按 `Ctrl + C` 只複製不儲存，或按 `Ctrl + S` 只儲存不複製。

已儲存的截圖預設會落在 `~/Pictures/Screenshots`，名稱如 `screenshot-2026-08-13_14-22-05-firefox.png`。設定 `OMASNAP_SCREENSHOT_DIR` 可以使用另一個目錄——請參閱[常見問題](46-faq.md)，了解工作階段環境變數該放在哪裡。Omasnap 會在儲存第一張截圖時建立該目錄。在 `~/.config/omasnap/omasnap.conf` 中設定 `[output] autosave = false` 可停用自動儲存；屆時擷取內容只會被複製，並在預覽中顯示 7 秒，你可以透過它的釘選按鈕或 `Ctrl + P` 讓它持續留在畫面上。

從終端機執行 `omarchy screenshot` 會開啟同一個覆疊介面，你也可以選擇它的起始模式：`omarchy capture screenshot region`、`windows`、`fullscreen` 或 `scroll`。第二個參數為 `copy` 或 `save` 時，會將截圖直接送往該目的地。若要在輸出前編輯，使用 `omarchy screenshot --editor=overlay` 開啟全螢幕編輯器，或使用 `omarchy screenshot --editor=window` 在獨立視窗中編輯。

### 用鍵盤操作選取工具

選取介面開啟時，你完全不必使用滑鼠：

| Key | Function |
| --- | -------- |
| `S` | Toggle scrolling-region mode |
| `Super + Arrow keys` | Move among windows in Window mode |
| `Return` | Capture the highlighted window |
| `Ctrl + A` | Capture the full focused monitor |
| `R` | Restore the last region drawn in this session |
| `Esc` | Dismiss Omasnap |

這些綁定只在 Omasnap 開啟時存在，因此不會與你自己設定中的任何綁定衝突。

## 螢幕錄影

`Alt + Print Screen` 會開啟 _Trigger > Capture > Screenrecord_，它會詢問你要在音軌中收錄什麼：無音訊、桌面音訊、桌面加麥克風，或桌面加麥克風加網路攝影機。最後一個選項只有在你確實接上攝影機時才會出現。選好後，Omarchy 的錄影選取工具會讓你拖曳出一個區域，或點按某個視窗或螢幕。

錄影使用 gpu-screen-recorder 執行，它以 GPU 編碼、速度為 60fps，必要時會改用 CPU；在它不支援的 GPU 上，例如 Apple Silicon 的 GPU，Omarchy 則改用 wf-recorder 錄影。成果是位於 `~/Videos` 的 MP4，名稱為 `screenrecording-2026-08-13_14-22-05.mp4`。設定 `OMARCHY_SCREENRECORD_DIR` 可以變更這個位置——但請注意，它與截圖目錄不同，這個目錄必須事先存在，否則錄影會拒絕開始。

錄影時，列上會出現一個小指示器。點按它即可停止。你也可以再次按下 `Alt + Print Screen`，或使用 _Trigger > Capture > Screenrecord_ 下的 _Stop Screenrecording_ 項目來停止；該項目只在確實有東西正在錄影時才會出現。

停止時，它會在把檔案交給你之前做一點整理：修剪第一幀，如果有音訊，則將其正規化到 -14 LUFS，並將最開頭 PipeWire 擷取時的爆音靜音。接著會出現一個通知，帶有錄影的縮圖。選擇 _Open_ 在 Omaview 中播放檔案，或選擇 _Cut_ 在 Omacut 中修剪它。

### 網路攝影機覆疊畫面

使用網路攝影機錄影時，攝影機畫面會以釘選、裁剪過的直式視窗出現在你正在錄製內容的右下角。如果它正擋住你需要的東西，可以即時調整它的大小：

| Hotkey | Function |
| ------ | -------- |
| `Super + Alt + [` | Make the webcam overlay smaller |
| `Super + Alt + ]` | Make the webcam overlay larger |

共有三種大小——小、中、大——熱鍵可在它們之間逐級切換。預設為中。它們與錄影畫面成比例，因此無論你錄的是 1080p 螢幕還是 6K 螢幕，攝影機都會佔據畫面中相同的比例。而如果你錄的是某個區域而非整個顯示器，覆疊畫面會錨定在該區域的角落而非螢幕的角落，因此會一直留在鏡頭內。

你也可以直接用 `omarchy-capture-webcam-resize small` 呼叫它，或用 `reset` 回到中。

## 文字、QR 碼與顏色

`Super + Ctrl + Print Screen` 會選取一個區域，並對它進行 OCR，將結果送到剪貼簿。[文字擷取與聽寫](11-text-extraction-dictation.md) 對此有完整說明。

_Trigger > Capture > QR Code_ 對 QR 碼也玩同樣的把戲。選取含有該碼的區域，解碼後的值就會進入剪貼簿。它只尋找 QR 碼——否則密集的畫面內容很容易被誤判為條碼。有件事值得知道：解碼後的值只會進入剪貼簿，不會去其他任何地方。它不會被印出，不會出現在通知中，而且會被標記為敏感內容，因此不會留在[剪貼簿歷史](08-unified-clipboard-history.md)中。QR 碼經常帶有秘密——例如 2FA 設定碼背後的 `otpauth://` URI——你不會想讓那種東西進入記錄檔。貼上仍然可以正常運作。

`Super + Print Screen`（或 _Trigger > Capture > Color_）會將游標變成滴管。點按畫面上的任何東西，該顏色就會進入剪貼簿。再按一次熱鍵，即可退出而不選取。

## 分享前轉碼

4K 螢幕錄影或手機裡的原始 HEIC 檔案往往太大，無法就這樣直接傳送。`Super + Ctrl + .`（或 _Trigger > Transcode_）就解決了這個問題。它會提供一個可在 `~/Pictures` 和 `~/Videos` 上進行模糊搜尋的檔案選取器，然後詢問你要的格式和尺寸。

圖片可轉成 jpg 或 png 的高、中、低三檔，寬度上限分別為 3160、2160 和 1080 像素。影片可轉成 mp4 或動畫 gif 的 4k、1080p 或 720p。轉換後的檔案會寫在原始檔案旁邊，名稱中帶有解析度——`demo-1080p.mp4`——其路徑則以檔案 URI 的形式複製到剪貼簿，因此你可以直接將它貼到接受檔案拖放的應用程式中。

如果你已經知道自己要什麼，它也可以從終端機運作：`omarchy transcode ~/Videos/demo.mov mp4 1080p`。還有 `omarchy transcode ascii`，它會將一張圖片變成 ASCII 藝術——這個功能主要用於[品牌形象](41-branding.md)。

## 傳送到其他地方

有了檔案後，`Super + Ctrl + S` 會開啟 Share 選單，並透過 LocalSend 將它傳送到你的網路上的另一台裝置。詳情請參閱 [GUI](22-guis.md)。
