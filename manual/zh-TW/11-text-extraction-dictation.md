# 文字擷取與聽寫

### 文字擷取

按下 `Super + Ctrl + PrtScr`，即可在螢幕上選取區域進行文字擷取。tesseract 開源 OCR 模型接著會快速將選取內容轉換為文字，並放入剪貼簿。之後只要按下 `Super + V` 就能貼上。

這對於擷取圖片頁尾中的地址，或是嵌入網站標題中的電話號碼，非常有幫助。

 ![text-extraction](images/text-extraction.webp)

### 聽寫

全新安裝時，[Superwhisper](https://superwhisper.com/) 是預設的聽寫後端，採用雲端處理，無需下載離線模型。透過 Omarchy 選單中的 _Setup > Defaults > Dictation_，選擇 Superwhisper、[Voxtype](https://voxtype.io/) 或 [Hex](https://anoma.ly/hex/)。選取後端後，系統會視需要進行安裝，並將其設為聽寫的預設後端。Voxtype 會載入一個佔用 150MB 的基礎英文模型；可使用 `voxtype setup model` 變更模型，其他設定則透過 `~/.config/voxtype/config.toml` 進行調整。Superwhisper 會開啟其設定，讓你選擇雲端或本機處理，而 OPR 會負責保持應用程式為最新狀態。Hex 會在設定期間下載其裝置端語音模型，並以 `hex.service` 使用者服務的形式執行；從列的系統匣圖示開啟其視窗，或執行 `hex`，即可變更模型及其他設定。

按住 `Right Alt` 即可開始聽寫，或使用 `Alt + Space` 切換開關，聽寫出的文字將出現在目前焦點所在的輸入區域。這些快捷鍵會使用所選的後端。Right Alt 在修飾鍵組合中使用時也會啟動聽寫；這類組合請改用 Left Alt。在 Right Alt 為 AltGr 的鍵盤配置上，請使用 `Alt + Space`，以便保留 AltGr 供打字使用。在 Alt + Space 成為預設值之前安裝的系統，會將 `F9` 用於按住說話，以及將 `Super + Ctrl + X` 用於切換，這些設定會加入 `~/.config/hypr/bindings.lua`，而其中的 `Super + Ctrl + X` 會取代 agents 面板的位置；在該處移除這些設定，即可將這些按鍵還給應用程式與該面板。

相同的快捷鍵適用於所有後端。透過 Setup > Defaults > Dictation 選取你的後端。後端安裝程式會對其進行設定，並儲存選取結果。執行 `omarchy default dictation` 即可查看目前選取的是哪一個。選取結果會儲存在 `~/.config/omarchy/defaults/dictation`。全新安裝會自動選取 Superwhisper。

Omarchy 會自動載入所選後端的桌面整合。你不需要在 `~/.config/hypr/` 中進行任何 Superwhisper 設定。

自訂綁定與指令碼可以使用 `omarchy dictation start`、`omarchy dictation stop` 和 `omarchy dictation toggle`。所選後端會負責錄音與轉錄。選取 Superwhisper 會停用其原生的按住快捷鍵，並將其原生切換快捷鍵設為 `Ctrl + Alt + Space`，使其與 Omarchy 的錄音按鍵區隔開來。Superwhisper 至少需要一個原生錄音快捷鍵，而其取消快捷鍵則維持可用。

其他後端無需變更 Omarchy 即可整合。請在 PATH 上提供一個名為 `omarchy-dictation-<backend>` 的可執行檔，它需接受 `start`、`stop` 與 `toggle`，並能即時返回，失敗時則傳回非零狀態。其安裝程式負責設定提供者，並在成功完成設定後呼叫 `omarchy-dictation-use <backend>`。這會停止先前的後端，並以原子作業的方式儲存選取結果；當提供者處於閒置或無法使用狀態時，`stop` 必須成功。後端名稱使用小寫字母、數字與連字號。請提供 `omarchy-install-dictation-<backend>` 以進行設定；`omarchy default dictation <backend>` 會啟動它。透過 Omarchy 選單擴充功能，加入一個 Defaults 選單項目來呼叫該選擇器。選用的桌面整合可放在 `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`。
