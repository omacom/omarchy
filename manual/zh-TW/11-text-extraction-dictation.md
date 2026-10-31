# 文字擷取與聽寫

### 文字擷取

按下 `Super + Ctrl + PrtScr`，在螢幕上選取一個區域進行文字擷取。tesseract 開源 OCR 模型接著會迅速把那個選取範圍轉換成文字，並放到剪貼簿上。然後你只要按下 `Super + V` 就能貼上。

這對於從圖片頁尾抓取地址，或從網站標題中嵌入的電話號碼抓取資料，非常有幫助。

 ![text-extraction](images/text-extraction.webp)

### 聽寫

在全新安裝中，[Superwhisper](https://superwhisper.com/) 是預設的聽寫後端，使用雲端處理，不需要下載離線模型。透過 Omarchy 選單中的 _設定 > 預設值 > 聽寫_ 來選擇 Superwhisper 或 [Voxtype](https://voxtype.io/)。選取一個後端會在需要時安裝它，並使它成為聽寫的預設後端。Voxtype 會載入一個佔用 150MB 的基礎英文模型；用 `voxtype setup model` 變更模型，並透過 `~/.config/voxtype/config.toml` 變更其他設定。Superwhisper 會開啟它的設定，讓你選擇雲端或本機處理，而 OPR 會保持該應用程式更新至最新。

你透過按住 `Right Alt` 或 `F9` 來聽寫，或用 `Super + Ctrl + X` 切換，而聽寫出的文字會出現在目前焦點所在的輸入區域。這些快捷鍵使用所選的後端。Right Alt 在修飾鍵組合中使用時也會啟動聽寫；那些組合請改用 Left Alt。在 Right Alt 是 AltGr 的鍵盤配置上，請使用 `F9`，以便讓 AltGr 保持可用於打字。

相同的快捷鍵在任一後端都能運作。透過 設定 > 預設值 > 聽寫 選取你的後端。後端安裝程式會設定它並儲存選取結果。執行 `omarchy default dictation` 可以查看選了哪一個。選取結果儲存在 `~/.config/omarchy/defaults/dictation` 中。全新安裝會自動選取 Superwhisper。

Omarchy 會自動載入所選後端的桌面整合。在 `~/.config/hypr/` 中不需要任何 Superwhisper 設定。

自訂綁定和腳本可以使用 `omarchy dictation start`、`omarchy dictation stop` 和 `omarchy dictation toggle`。所選的後端負責錄音和轉錄。選取 Superwhisper 會停用它原生的按住快捷鍵，並把它的原生切換鍵設為 `Alt + Space`，讓它與 Omarchy 的錄音鍵保持分開。Superwhisper 至少需要一個原生錄音快捷鍵，而它的取消快捷鍵仍可使用。

額外的後端可以在不變更 Omarchy 的情況下整合進來。在 PATH 上提供一個名為 `omarchy-dictation-<backend>` 的可執行檔，它接受 `start`、`stop` 和 `toggle`，並迅速返回，失敗時返回非零狀態。它的安裝程式會設定該提供者，並在成功設定後呼叫 `omarchy-dictation-use <backend>`。這會停止先前的後端並以原子方式儲存選取結果；當提供者閒置或不可用時，`stop` 必須成功。後端名稱使用小寫字母、數字和連字號。提供用於設定的 `omarchy-install-dictation-<backend>`；`omarchy default dictation <backend>` 會啟動它。透過 Omarchy 選單擴充功能新增一個預設值選單項目來呼叫那個選取器。選用的桌面整合可以放在 `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` 中。
