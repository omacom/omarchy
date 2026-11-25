# FAQ

### 我要如何切換鍵盤版面配置？

編輯你的 `~/.config/hypr/input.lua` 檔案，並加入以下內容，即可使用 `Left Alt + Right Alt` 切換版面配置：

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

一旦你設定了多個版面配置，狀態列就會自動顯示你目前的鍵盤版面配置（你也可以點按它來切換）。

### 我要如何將時鐘格式改為 12 小時制？

在狀態列的時鐘上按一下右鍵，即可循環切換常見格式，包括 12 小時制格式。你也可以直接設定格式：

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

這會顯示為星期日 10:55 AM。

### 我要如何變更我的時區？

在 Omarchy 選單中執行 _Setup > Region > Timezone_，然後從清單中選取。如果時區正確，但時鐘本身已經偏移，_Update > Time_ 會為你重新啟動時間同步。

### 我要如何變更我的 DNS、分享我的 Wi-Fi，或檢查我的連線速度？

這些全都在[網路設定](35-networking.md)中。

### 我要如何檢查我的硬碟速度有多快？

_Trigger > Speed Test > Disk Speed Test_ 會測量你硬碟的即時讀取和寫入速度，或從終端機執行 `omarchy disk speedtest`。

### 我要如何新增印表機？

列印功能開箱即用，已經設定好並正在執行，而每台印表機都要由你自己從應用程式啟動器（`Super + Alt + Space`）中的 _Print Settings_ 新增。

選擇 _Add_，並給它一點時間搜尋：透過 USB 連接的印表機，以及大多數網路印表機，都會為你找到。如果你的印表機不在清單中，請選取 _Network Printer > Internet Printing Protocol (ipp)_ 並輸入其位址——印表機本身的顯示器或其網頁會告訴你該位址是什麼，通常類似 `192.168.1.50`，佇列為 `ipp/print`。接著 _Forward_ 會提供一個驅動程式，其中現代印表機最適合使用無驅動程式的 _IPP Everywhere_ 設定檔，較舊的印表機則需要該型號專用的驅動程式。

在印表機上按一下右鍵，並選擇 _Set as Default_ 來選取你的應用程式優先使用的印表機，以及選擇 _Properties_ 來設定紙張大小、雙面列印和品質。

自動探索功能，也就是讓網路上的印表機無需新增就能出現的功能，在重新改版期間暫時關閉，這就是為什麼上述第一步要由你來做，而不是自動完成。完全不需要任何印表機，也能列印成 PDF 檔案。

### 我要如何變更截圖或螢幕錄影的儲存位置？

儲存的截圖預設會放在 `~/Pictures/Screenshots`。若要使用其他目錄，請將以下內容加入 `~/.config/uwsm/env.d/` 下的一個檔案（例如 `~/.config/uwsm/env.d/capture`）：

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

你也可以使用 `OMARCHY_SCREENRECORD_DIR` 對螢幕錄影做相同的設定。

Omasnap 會自動建立其截圖目錄。請自己建立螢幕錄影目錄，然後重新啟動 Omarchy，讓任一環境變更生效。

### 我要如何讓我的 Apple Studio Display 的喇叭 + 網路攝影機正常運作？

你可能會以為只要插上 USB C 就應該全部能運作，但很遺憾，事實並非如此。我找到能讓它可靠運作的解決方案是使用 [WJESOG DisplayPort + USB-A => USB-C 連接線](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/)。之後喇叭和網路攝影機就能完美運作。

請記住，Omarchy 為 Apple 顯示器（Studio 和 XDR 兩者）內建了亮度控制，使用一般的鍵盤亮度按鈕即可。

### 我要如何移除所有額外的軟體？

如果你不想要 Obsidian 或 LibreOffice 等程式，或任何其他預先安裝的東西，你可以非常輕鬆地將它移除。

執行 _Remove > Package_ 來查看每個已安裝的套件。然後你可以用 tab 選取任何你想移除的套件，並用 return 開始移除你已選取的所有套件。

而且你可以使用 Omarchy 選單中的 _Remove > Web App_ 來移除任何你不想要的預先安裝網頁應用程式。

或執行 _Remove > Preinstalls_，一次清掉所有預先安裝的額外內容——網頁應用程式、TUIs 和選用的應用程式。用來啟動它們的快速鍵也會隨之消失，所以你會留下一組乾淨的按鍵綁定，可以在 `~/.config/hypr/bindings.lua` 中填入你自己的設定。

---

如需處理錯誤和故障，請參閱[疑難排解章節](45-troubleshooting.md)。
