# FAQ

### 如何在鍵盤配置之間切換？

編輯你的 `~/.config/hypr/input.lua` 檔案，並加入以下內容，就能用 `Left Alt + Right Alt` 在不同配置之間切換：

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

一旦你設定了多個配置，工具列就會自動顯示你目前的鍵盤配置（你也可以點它來切換）。

### 如何將時鐘格式改為 12 小時制？

在工具列的時鐘上按右鍵，就可以在常見格式之間循環切換，包括 12 小時制的格式。你也可以直接設定格式：

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

這會顯示星期日 10:55 AM。

### 如何變更我的時區？

執行 Omarchy 選單中的 _更新 > 時區_，再從清單中挑選。如果時區正確，但時鐘本身已經漂移，_更新 > 時間_ 會為你重新啟動時間同步。

### 如何變更我的 DNS、分享我的 Wi-Fi，或檢查我的連線速度？

這些全都在[網路](35-networking.md)裡。

### 如何檢查我的磁碟有多快？

_觸發 > 速度測試 > 磁碟速度測試_ 會測量你磁碟的即時讀取與寫入速度，或從終端機執行 `omarchy disk speedtest`。

### 如何新增印表機？

列印功能開箱即已設定好並正在執行，而每台印表機都要由你自己從應用程式啟動器（`Super + Space`）中的 _列印設定_ 新增。

選擇 _新增_，並給它一點時間尋找：透過 USB 接上的印表機，以及大多數網路印表機，都會自動替你找到。如果你的印表機不在清單中，選 _網路印表機 > Internet Printing Protocol (ipp)_ 並輸入其位址 — 印表機自己的顯示器或它的網頁會告訴你那是什麼，通常像 `192.168.1.50` 這樣，佇列則是 `ipp/print`。_下一步_ 接著會提供驅動程式，其中現代印表機在免驅動程式的 _IPP Everywhere_ 設定檔上效果最佳，較舊的則需要該型號自己的驅動程式。

在印表機上按右鍵並選 _設為預設_，就能挑選你的應用程式會優先使用哪一台，選 _屬性_ 則可設定紙張大小、雙面列印與品質。

自動探索，也就是讓網路上的印表機不需新增就自動出現的功能，在重新改造期間暫時關閉，這就是為什麼上面的第一步要由你來做，而不是自動完成。完全不需要任何印表機，也能列印成 PDF 檔案。

### 如何變更螢幕截圖或螢幕錄影的儲存位置？

儲存的螢幕截圖預設會放到 `~/Pictures/Screenshots`。若要改用其他目錄，請將以下內容加入 `~/.config/uwsm/env.d/` 底下的一個檔案（例如 `~/.config/uwsm/env.d/capture`）：

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

你可以用 `OMARCHY_SCREENRECORD_DIR` 對螢幕錄影做同樣的事。

Omasnap 會自動建立它的螢幕截圖目錄。螢幕錄影目錄請你自己建立，然後重新啟動 Omarchy，任一環境變更才會生效。

### 如何讓我 Apple Studio Display 上的喇叭 + 網路攝影機運作？

你會以為只要插上 USB C 就應該全部都能運作，但很不幸地並非如此。我找到能可靠讓它運作的解決辦法，是使用 [the WJESOG DisplayPort + USB-A => USB-C cable](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/)。如此一來，喇叭與網路攝影機就運作得完美無瑕。

請記得，Omarchy 針對 Apple 顯示器（Studio 與 XDR 兩者）內建了亮度控制，使用一般的鍵盤亮度按鈕即可。

### 如何移除所有多餘的軟體？

如果你不想要 Obsidian、LibreOffice 這類程式，或任何其他預先安裝的東西，你可以非常輕鬆地將它移除。

執行 _移除 > 套件_ 就能看到所有已安裝的套件。接著你能用 tab 選取任何想移除的套件，並用 return 開始移除你所選的一切。

你還可以使用 Omarchy 選單中的 _移除 > Web App_，來移除任何你不要的預先安裝 Web App。

或者執行 _移除 > 預先安裝項目_，一次清掉所有預先安裝的額外項目 — Web App、TUI 以及選用的應用程式。啟動它們的快捷鍵會隨之一併消失，因此你會得到一片乾淨的綁定空白，可在 `~/.config/hypr/bindings.lua` 中填入你自己的綁定。

---

如需處理錯誤與損壞之處，請參閱[疑難排解章節](45-troubleshooting.md)。
