# 文字擷取與聽寫

### 文字擷取

按下 `Super + Ctrl + PrtScr`，在螢幕上選取一個區域進行文字擷取。tesseract 開源 OCR 模型接著會迅速將該選取範圍轉換為文字，並放到剪貼簿上。然後你只要按下 `Super + V` 就能貼上。

這對於從圖片頁尾擷取地址，或擷取嵌入在網站標題中的電話號碼，非常有幫助。

 ![text-extraction](images/text-extraction.webp)

### 聽寫

在全新安裝中，[Superwhisper](https://superwhisper.com/) 是預設的聽寫後端，採用雲端處理，無需下載離線模型。透過 Omarchy 選單中的 _Setup > Defaults > Dictation_，選擇 Superwhisper、[Voxtype](https://voxtype.io/) 或 [Hex](https://anoma.ly/hex/)。選擇後端時，如有需要會安裝它，並將其設為聽寫的預設後端。Voxtype 會載入一個佔用 150MB 的基礎英文模型；使用 `voxtype setup model` 變更模型，其他設定則透過 `~/.config/voxtype/config.toml` 變更。Superwhisper 會開啟其設定，讓你選擇雲端或本地處理，而 OPR 會保持應用程式更新。Hex 會在設定期間下載其裝置端語音模型，並以 `hex.service` 使用者服務的形式執行；從狀態列的系統匣圖示開啟其視窗，或執行 `hex` 來變更模型與其他設定。

按住 `Right Alt` 即可聽寫，或使用 `Alt + Space` 切換開關，聽寫出的文字會出現在目前焦點所在的輸入區域。這些快捷鍵會使用所選的後端。Right Alt 用在修飾鍵組合中時，也會啟動聽寫；這類組合請改用 Left Alt。在 Right Alt 為 AltGr 的鍵盤配置上，包括你切換過去後使用的這類配置，單獨按住它片刻即可進行聽寫；AltGr 與其他按鍵一起按下時，仍會輸入其對應字元。在 Alt + Space 成為預設值之前的安裝，會保留 `F9` 用於按住說話，以及 `Super + Ctrl + X` 用於切換，這些都已加入 `~/.config/hypr/bindings.lua`，在那裡 `Super + Ctrl + X` 會取代 agents 面板的位置；在該處移除它們，即可將這些按鍵還給應用程式與面板。

相同的快捷鍵適用於每一個後端。透過 Setup > Defaults > Dictation 選擇你的後端。後端安裝程式會設定該後端，並儲存你的選擇。執行 `omarchy default dictation` 可查看目前選用的是哪一個。選擇結果儲存在 `~/.config/omarchy/defaults/dictation` 中。全新安裝會自動選用 Superwhisper。

Omarchy 會自動載入所選後端的桌面整合。在 `~/.config/hypr/` 中不需要任何 Superwhisper 設定。

自訂綁定與腳本可以使用 `omarchy dictation start`、`omarchy dictation stop` 與 `omarchy dictation toggle`。錄音與轉錄由所選後端處理。選擇 Superwhisper 會停用其原生的按住快捷鍵，並將其原生切換快捷鍵設為 `Ctrl + Alt + Space`，使其與 Omarchy 的錄音按鍵分開。Superwhisper 需要至少一個原生錄音快捷鍵，而其取消快捷鍵仍保持可用。

其他後端無需變更 Omarchy 即可整合。請在 PATH 上提供一個名為 `omarchy-dictation-<backend>` 的可執行檔，它接受 `start`、`stop` 與 `toggle`，且能迅速返回，失敗時以非零狀態返回。其安裝程式負責設定該提供者，並在成功完成設定後呼叫 `omarchy-dictation-use <backend>`。這會停止先前的後端，並以原子操作的方式儲存選擇；當提供者閒置或無法使用時，`stop` 必須成功。後端名稱使用小寫字母、數字與連字號。提供 `omarchy-install-dictation-<backend>` 進行設定；`omarchy default dictation <backend>` 會啟動它。透過 Omarchy 選單擴充功能加入一個 Defaults 選單條目，來呼叫該選擇器。選配的桌面整合可以放在 `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` 中。
