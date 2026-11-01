# 常見問題

### 如何在不同的鍵盤配置之間切換？

編輯你的 `~/.config/hypr/input.lua` 檔案，加入以下內容，就能用 `Left Alt + Right Alt` 在配置之間切換：

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

一旦你設定了多個配置，選單列就會自動顯示你目前的鍵盤配置（你也可以點選它來切換）。

### 如何把時鐘格式改成 12 小時制？

在選單列的時鐘上按右鍵，即可在常見格式（包括 12 小時制）之間循環切換。你也可以直接設定格式：

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

這樣會顯示 Sunday 10:55 AM。

### 如何變更我的時區？

在 Omarchy 選單中執行 _更新 > 時區_，並從清單中挑選。如果時區是對的，但時鐘本身跑偏了，_更新 > 時間_ 會為你重新啟動時間同步。

### 如何變更我的 DNS、分享我的 Wi-Fi，或查看我的連線速度？

這些全都在[網路](35-networking.md)一節中。

### 如何查看我的磁碟速度有多快？

_觸發 > 測速 > 磁碟測速_ 會量測你磁碟的即時讀寫速度，或者在終端機使用 `omarchy disk speedtest`。

### 為什麼我無法在 Chromium 中登入我的 Google 帳號？

原版的開源 Chromium 建置並不附帶 Google 帳號登入所需的 OAuth 憑證。在 Omarchy 選單中執行 _安裝 > 服務 > Chromium 帳號_ 來加入它們，重新啟動瀏覽器，登入就能順利完成。

### 如何新增印表機？

列印功能開箱即已設定好並運行，你可以從應用程式啟動器（`Super + Space`）中的 _Print Settings_ 自行新增每台印表機。

選擇 _Add_，並給它一點時間搜尋：透過 USB 連接的印表機，以及大多數網路印表機，都會自動被找到。如果你的不在清單中，選擇 _Network Printer > Internet Printing Protocol (ipp)_ 並輸入它的位址——印表機自己的顯示畫面或它的網頁會告訴你那是什麼，通常類似 `192.168.1.50` 搭配佇列 `ipp/print`。接著 _Forward_ 會提供一個驅動程式，現代印表機最適合免驅動的 _IPP Everywhere_ 設定檔，較舊的印表機則需要該型號自己的驅動程式。

在一台印表機上按右鍵並選擇 _Set as Default_，可挑選你的應用程式優先使用哪一台，選擇 _Properties_ 則可設定紙張尺寸、雙面列印和品質。

自動探索（讓網路上的印表機不需新增就出現）在重新設計期間暫時關閉，這就是為什麼上面的第一步要由你來做而不是自動完成。列印到 PDF 檔案則完全不需要任何印表機。

### 如何變更螢幕截圖或螢幕錄影的儲存位置？

儲存的螢幕截圖預設放在 `~/Pictures/Screenshots`。要使用其他目錄，把以下內容加到 `~/.config/uwsm/env.d/` 之下的某個檔案裡（例如 `~/.config/uwsm/env.d/capture`）：

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

你也可以用 `OMARCHY_SCREENRECORD_DIR` 對螢幕錄影做同樣的事。

Omasnap 會自動建立它的螢幕截圖目錄。螢幕錄影目錄請自己建立，然後重新啟動 Omarchy，讓任一環境變更生效。

### 如何讓我的 Apple Studio Display 的喇叭＋網路攝影機運作？

你會以為只要插上 USB C 就應該全部能用，但很不幸地並非如此。我發現能讓它可靠運作的解決方案，是使用 [WJESOG DisplayPort + USB-A => USB-C 傳輸線](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/)。這樣一來喇叭和網路攝影機就能如魔法般順暢運作。

別忘了，Omarchy 為 Apple 顯示器（Studio 和 XDR 都包括）內建了亮度控制，你可以使用一般的鍵盤亮度按鍵。

### 如何移除所有額外的軟體？

如果你不想要 Obsidian、LibreOffice 或其他任何預先安裝的程式，你可以很輕鬆地移除它們。

執行 _移除 > 套件_ 可查看每一個已安裝的套件。然後你可以用 tab 選取任何想移除的套件，再用 return 開始移除你選的所有東西。

而且你可以用 Omarchy 選單中的 _Remove > Web App_ 來移除任何你不想要的預先安裝 web app。

或者執行 _移除 > 預先安裝_，一口氣掃除所有預先安裝的附加項目——web app、TUI 和選用應用程式。啟動它們的快捷鍵會隨之一起消失，留給你一張乾淨的綁定白紙，讓你在 `~/.config/hypr/bindings.lua` 中填入你自己的設定。

---

如有錯誤和損壞的部分，請參閱[疑難排解章節](45-troubleshooting.md)。
