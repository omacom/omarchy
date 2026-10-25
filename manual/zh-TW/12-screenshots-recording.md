# 截圖與螢幕錄影

所有能從畫面上擷取的東西，都掛在 Print Screen 鍵上。單獨按這個鍵會拍一張圖片，而搭配修飾鍵則可以錄影、選取顏色，或擷取某個區域內的文字。如果你的鍵盤根本沒有 Print Screen 鍵，`Super + Ctrl + Alt + C` 可以拍出相同的截圖，而 `Super + Ctrl + C` 則會以選單形式開啟整組功能。

| 熱鍵 | 功能 |
| ------ | -------- |
| `Print Screen` | 截圖 |
| `Super + Ctrl + Alt + C` | 截圖 |
| `Alt + Print Screen` | 螢幕錄影（或停止正在進行的錄影） |
| `Super + Print Screen` | 選色器 |
| `Super + Ctrl + Print Screen` | 從區域擷取文字 |
| `Super + Ctrl + C` | 擷取選單 |
| `Super + Ctrl + .` | 轉碼圖片或影片 |

## 截圖

按下 `Print Screen`（或 `Super + Ctrl + Alt + C`），Omasnap 會在其覆蓋層出現之前擷取已聚焦的螢幕，所以你在瞄準時，畫面不會在你底下移位。拖曳選取一個任意形狀的區域、點按某個視窗來擷取它，或點按空白處來擷取整個螢幕。在開始繪製之前先按 `S`，可以擷取捲動區域。改變主意了嗎？再按一次相同的按鍵，即可關閉 Omasnap。

選取區域之後，Omasnap 會儲存擷取內容、將它複製到剪貼簿，並顯示帶有縮圖的通知，就像已儲存的螢幕錄影一樣。選擇「開啟」可以在你的圖片檢視器中查看已儲存的截圖，或選擇「編輯」來為它加上註解。

註解編輯器可以繪製箭頭、線條、形狀、醒目提示、編號標記、文字和安全遮蔽；裁剪或挖除圖片的一部分；對其文字進行 OCR；以及加上背景。在編輯器中，按 `Enter` 可以複製並儲存完成的 PNG，按 `Ctrl + C` 可以只複製而不儲存，或按 `Ctrl + S` 可以只儲存而不複製。

已儲存的截圖預設會落在 `~/Pictures/Screenshots`，名稱例如 `screenshot-2026-08-13_14-22-05-firefox.png`。設定 `OMASNAP_SCREENSHOT_DIR` 可以使用其他目錄——請參見[常見問題](46-faq.md)，瞭解工作階段環境變數應該放在何處。Omasnap 會在儲存第一張截圖時建立該目錄。在 `~/.config/omasnap/omasnap.conf` 中設定 `[output] autosave = false` 可以停用自動儲存；此時擷取內容只會被複製，並顯示在一個為期 10 秒的預覽中，你可以用它的釘選按鈕或 `Ctrl + P` 讓它保持在畫面上。

從終端機來看，`omarchy screenshot` 會開啟相同的覆蓋層，而且你可以選擇它的起始模式：`omarchy capture screenshot region`、`windows`、`fullscreen` 或 `scroll`。第二個引數使用 `copy` 或 `save`，會把截圖直接送往該目的地。若要在輸出前先編輯，請使用 `omarchy screenshot --editor=overlay` 開啟全螢幕編輯器，或使用 `omarchy screenshot --editor=window` 開啟獨立視窗。

### 用鍵盤操作選取器

選取功能開啟時，你完全不必使用滑鼠：

| 按鍵 | 功能 |
| --- | -------- |
| `S` | 切換捲動區域模式 |
| `Super + Arrow keys` | 在視窗模式中於視窗之間移動 |
| `Return` | 擷取反白顯示的視窗 |
| `Ctrl + A` | 擷取完整的已聚焦螢幕 |
| `R` | 還原本次工作階段中上次繪製的區域 |
| `Esc` | 關閉 Omasnap |

這些鍵盤綁定只在 Omasnap 開啟時存在，所以它們不會與你自己設定中的任何東西衝突。

## 螢幕錄影

`Alt + Print Screen` 會開啟 _Trigger > Capture > Screenrecord_，它會詢問你希望音軌上有什麼：無音訊、桌面音訊、桌面加麥克風，或桌面加麥克風加網路攝影機。最後一項只有在你確實接上攝影機時才會出現。選好一項之後，Omarchy 的錄影選取器會讓你拖曳選取一個區域，或點按某個視窗或螢幕。

錄影以 gpu-screen-recorder 執行，它會在 GPU 上以 60fps 編碼，必要時則退回使用 CPU。成果是位於 `~/Videos` 的一個 MP4，名稱為 `screenrecording-2026-08-13_14-22-05.mp4`。設定 `OMARCHY_SCREENRECORD_DIR` 可以變更這個位置——但請注意，與截圖目錄不同，這個目錄必須已經存在，否則錄影將拒絕開始。

錄影期間，狀態列中會出現一個小小的指示器。點按它即可停止。你也可以再次按 `Alt + Print Screen` 來停止，或使用 _Trigger > Capture > Screenrecord_ 底下的 _Stop Screenrecording_ 項目，該項目只會在確實有東西正在錄影時出現。

停止時，它會先做一點整理再把檔案交給你：第一個畫面會被修剪掉，而如果有音訊，它會被正規化到 -14 LUFS，並將最一開始的 PipeWire 擷取爆音靜音。接著會出現一個帶有錄影縮圖的通知。點按它，就可以在 mpv 中播放該檔案。

### 網路攝影機覆蓋層

當你使用網路攝影機錄影時，攝影機畫面會以一個釘選、裁剪過的直式視窗，出現在你正在錄製之畫面的右下角。如果它正好擋住你需要的東西，可以即時調整它的大小：

| 熱鍵 | 功能 |
| ------ | -------- |
| `Super + Alt + [` | 讓網路攝影機覆蓋層變小 |
| `Super + Alt + ]` | 讓網路攝影機覆蓋層變大 |

共有三種尺寸——小、中、大——而這些熱鍵可以在它們之間逐步切換。中是預設值。它們會與錄影內容成比例，所以無論你錄的是 1080p 螢幕還是 6K 螢幕，攝影機佔據畫面的比例都相同。而且，如果你錄的是一個區域而非整個顯示器，覆蓋層會錨定在該區域的角落而非螢幕的角落，所以它會留在畫面之內。

你也可以直接用 `omarchy-capture-webcam-resize small` 來呼叫它，或用 `reset` 回到中尺寸。

## 文字、QR 碼與顏色

`Super + Ctrl + Print Screen` 會選取一個區域，並將它 OCR 後放到剪貼簿。這在[文字擷取與聽寫](11-text-extraction-dictation.md)中有完整的說明。

_Trigger > Capture > QR Code_ 對 QR 碼使用相同的手法。選取包含該碼的區域，解碼後的值就會進到剪貼簿。它只會尋找 QR 碼——否則密集的螢幕內容很容易被誤判為條碼。有一點值得知道：解碼後的值只會進到剪貼簿，不會去其他任何地方。它不會被印出來，不會出現在通知中，而且會被標記為敏感內容，所以不會留在[剪貼簿記錄](08-unified-clipboard-history.md)裡。QR 碼經常攜帶秘密——例如 2FA 設定碼背後的 `otpauth://` URI——而你不會想讓那種東西出現在記錄檔中。貼上仍然可以正常運作。

`Super + Print Screen`（或 _Trigger > Capture > Color_）會把游標變成滴管。點按畫面上的任何東西，該顏色就會落到剪貼簿上。再次按下熱鍵，即可在不選取的情況下退出。

## 分享前先轉碼

一段 4K 螢幕錄影，或一張從你手機出來的原始 HEIC，往往太大而無法直接傳送。`Super + Ctrl + .`（或 _Trigger > Transcode_）可以修正這件事。它會在 `~/Pictures` 和 `~/Videos` 之上提供一個模糊搜尋的檔案選取器，然後詢問你要的格式和尺寸。

圖片會轉成 jpg 或 png 的高、中或低品質，其寬度上限分別為 3160、2160 和 1080 像素。影片會轉成 mp4 或動畫 gif，解析度為 4k、1080p 或 720p。轉換後的檔案會寫在原始檔案旁邊，名稱中帶有解析度——`demo-1080p.mp4`——而且該路徑會以檔案 URI 的形式複製到剪貼簿，所以你可以直接把它貼進接受檔案放入的應用程式。

如果你已經知道自己要什麼，它也可以從終端機運作：`omarchy transcode ~/Videos/demo.mov mp4 1080p`。另外還有 `omarchy transcode ascii`，它會把一張圖片變成 ASCII 藝術——那個主要是給[品牌](41-branding.md)用的。

## 把它傳送到某個地方

一旦你有了檔案，`Super + Ctrl + S` 會開啟 Share 選單，並透過 LocalSend 把它傳送到你網路上的另一台裝置。相關內容請參見 [GUIs](22-guis.md)。
