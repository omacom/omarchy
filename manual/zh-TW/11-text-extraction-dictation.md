# 文字擷取與聽寫

### 文字擷取

按下 `Super + Ctrl + PrtScr` 在螢幕上選取一個區域來擷取文字。tesseract 開源 OCR 模型會迅速將該選取範圍轉換成文字，並放到剪貼簿上。接著你只要按下 `Super + V` 就能貼上。

這對於抓取圖片頁尾中的地址，或是嵌在網站標題裡的電話號碼，非常有幫助。

 ![text-extraction](images/text-extraction.webp)

### 聽寫

在全新安裝中，[Superwhisper](https://superwhisper.com/) 是預設的聽寫後端，使用雲端處理，不需要下載離線模型。透過 Omarchy 選單中的 _Setup > Defaults > Dictation_，選擇 Superwhisper 或 [Voxtype](https://voxtype.io/)。選取某個後端時，如有需要會安裝它，並將它設為聽寫的預設後端。Voxtype 會載入一個基礎英文模型，佔用 150MB；用 `voxtype setup model` 變更模型，其他設定則透過 `~/.config/voxtype/config.toml` 調整。Superwhisper 會開啟它的設定，讓你選擇雲端或本機處理，而 OPR 會保持該應用程式為最新狀態。

你按住 `Right Alt` 就能聽寫，或用 `Alt + Space` 切換開關，聽寫出的文字會出現在目前聚焦的輸入區域。這些快捷鍵會使用所選的後端。Right Alt 用在修飾鍵組合中時，也會啟動聽寫；這類組合請改用 Left Alt。在 Right Alt 是 AltGr 的鍵盤配置上，請使用 `Alt + Space`，讓 AltGr 保持可用於打字。在 Alt + Space 成為預設值之前就已安裝的系統，會保留 `F9` 用於按住說話，以及 `Super + Ctrl + X` 用於切換，它們已加入 `~/.config/hypr/bindings.lua`；在該處移除它們，就能把這些按鍵還給應用程式使用。

相同的快捷鍵適用於任一後端。透過 Setup > Defaults > Dictation 選取你的後端。後端的安裝程式會設定它並儲存選取結果。執行 `omarchy default dictation` 來查看選中的是哪一個。該選取結果儲存在 `~/.config/omarchy/defaults/dictation`。全新安裝會自動選取 Superwhisper。

Omarchy 會自動載入所選後端的桌面整合。在 `~/.config/hypr/` 中不需要任何 Superwhisper 設定。

自訂綁定和腳本可以使用 `omarchy dictation start`、`omarchy dictation stop` 和 `omarchy dictation toggle`。所選後端負責處理錄音與轉錄。選取 Superwhisper 會停用它原生的按住快捷鍵，並將它原生的切換快捷鍵設為 `Ctrl + Alt + Space`，讓它與 Omarchy 的錄音按鍵保持分開。Superwhisper 需要至少一個原生錄音快捷鍵，而它的取消快捷鍵仍保持可用。

其他後端無需變更 Omarchy 就能整合。在 PATH 上提供一個名為 `omarchy-dictation-<backend>` 的可執行檔，它接受 `start`、`stop` 和 `toggle`，並且會立即返回，失敗時返回非零狀態。其安裝程式會設定提供者，並在設定成功後呼叫 `omarchy-dictation-use <backend>`。這會停止先前的後端，並以原子方式儲存選取結果；當提供者閒置或無法使用時，`stop` 必須成功。後端名稱使用小寫字母、數字和連字號。提供 `omarchy-install-dictation-<backend>` 用於設定；`omarchy default dictation <backend>` 會啟動它。透過 Omarchy 選單擴充功能加入一個 Defaults 選單項目，來呼叫該選擇器。選用的桌面整合可以放在 `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`。
