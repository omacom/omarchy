# 文字擷取與聽寫

### 文字擷取

按下 `Super + Ctrl + PrtScr`，在螢幕上選取一個區域進行文字擷取。開源的 tesseract OCR 模型隨後會迅速將選取範圍轉換成文字，並放入剪貼簿。接著只需按下 `Super + V` 貼上即可。

這對抓取圖片頁尾中的地址，或嵌在網站標題中的電話號碼非常有幫助。

 ![text-extraction](images/text-extraction.webp)

### 聽寫

在全新安裝中，[Superwhisper](https://superwhisper.com/) 是預設的聽寫後端，採用雲端處理，無需下載離線模型。透過 Omarchy 選單中的 _Setup > Defaults > Dictation_，選擇 Superwhisper、[Voxtype](https://voxtype.io/) 或 [Hex](https://anoma.ly/hex/)。選擇後端時，如有需要會安裝它，並將其設為聽寫的預設後端。Voxtype 會載入一個佔用 150MB 的基礎英文模型；使用 `voxtype setup model` 變更模型，並透過 `~/.config/voxtype/config.toml` 修改其他設定。Superwhisper 會開啟其設定，讓你選擇雲端或本機處理，而 OPR 會保持應用程式更新。Hex 會在設定期間下載其裝置端語音模型，並以 `hex.service` 使用者服務的形式執行；從狀態列的系統匣圖示開啟其視窗，或執行 `hex`，即可變更模型與其他設定。

按住 `Right Alt` 進行聽寫，或用 `Alt + Space` 切換，聽寫出的文字便會出現在焦點所在的輸入區域。這些快捷鍵會使用所選的後端。Right Alt 用在修飾鍵組合中時也會啟動聽寫；這類組合請使用 Left Alt。在 Right Alt 為 AltGr 的鍵盤配置上，請使用 `Alt + Space`，讓 AltGr 保持可用於輸入。在 Alt + Space 成為預設值之前安裝的系統，會保留 `F9` 作為按住說話，以及 `Super + Ctrl + X` 作為切換，並將其加入 `~/.config/hypr/bindings.lua`；在該處移除它們，即可將這些按鍵還給應用程式。

相同的快捷鍵適用於每個後端。透過 Setup > Defaults > Dictation 選擇你的後端。後端安裝程式會設定它並儲存選擇。執行 `omarchy default dictation` 查看目前選擇的是哪一個。選擇會儲存在 `~/.config/omarchy/defaults/dictation`。全新安裝會自動選擇 Superwhisper。

Omarchy 會自動載入所選後端的桌面整合。在 `~/.config/hypr/` 中不需要進行任何 Superwhisper 設定。

自訂綁定與指令碼可以使用 `omarchy dictation start`、`omarchy dictation stop` 以及 `omarchy dictation toggle`。所選後端會處理錄音與轉錄。選擇 Superwhisper 會停用其原生的按住快捷鍵，並將其原生切換快捷鍵設為 `Ctrl + Alt + Space`，使其與 Omarchy 的錄音按鍵分開。Superwhisper 至少需要一個原生錄音快捷鍵，而其取消快捷鍵會保持可用。

其他後端無需變更 Omarchy 即可整合。在 PATH 上提供一個名為 `omarchy-dictation-<backend>` 的可執行檔，它接受 `start`、`stop` 與 `toggle`，並迅速返回，失敗時返回非零狀態。其安裝程式會設定供應者，並在設定成功後呼叫 `omarchy-dictation-use <backend>`。這會停止先前的後端，並以原子方式儲存選擇；當供應者閒置或無法使用時，`stop` 必須成功。後端名稱使用小寫字母、數字與連字號。提供 `omarchy-install-dictation-<backend>` 用於設定；`omarchy default dictation <backend>` 會啟動它。透過 Omarchy 選單擴充功能加入一個 Defaults 選單項目，來呼叫該選擇器。選用的桌面整合可以放在 `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`。
