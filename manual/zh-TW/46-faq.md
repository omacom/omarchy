# 常見問題

### 如何切換鍵盤版面配置？

編輯你的 `~/.config/hypr/input.lua` 檔案，加入以下內容，即可用 `Left Alt + Right Alt` 切換版面配置：

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

一旦你設定了多個版面配置，狀態列就會自動顯示你目前的鍵盤版面配置（你也可以點擊它來切換）。

### 如何將時鐘格式改為 12 小時制？

在狀態列中的時鐘上按右鍵，即可循環切換常見格式，包括 12 小時制格式。你也可以直接設定格式：

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

這會顯示為星期日 10:55 AM。

### 如何變更我的時區？

在 Omarchy 選單中執行 _Setup > Region > Timezone_，並從清單中選取。如果時區正確，但時鐘本身出現偏移，_Update > Time_ 會為你重新啟動時間同步。

### 如何變更我的 DNS、分享我的 Wi-Fi，或檢查我的連線速度？

這些都在[網路](35-networking.md)中。

### 如何檢查我的磁碟有多快？

_Trigger > Speed Test > Disk Speed Test_ 會即時測量你磁碟機的讀取與寫入速度，你也可以從終端機執行 `omarchy disk speedtest`。

### 如何新增印表機？

列印功能開箱即用，已設定完成且正在執行，你可以從應用程式啟動器（`Super + Space`）中的 _Print Settings_ 自行新增每一台印表機。

選擇 _Add_，並給它一點時間搜尋：透過 USB 連接的印表機，以及大多數網路印表機，都會為你找到。如果你的印表機不在清單中，請選取 _Network Printer > Internet Printing Protocol (ipp)_ 並輸入它的位址 — 印表機自身的顯示螢幕或它的網頁會告訴你那是什麼，通常是像 `192.168.1.50` 這樣的位址，佇列為 `ipp/print`。接著 _Forward_ 會提供一個驅動程式，現代印表機使用免驅動程式的 _IPP Everywhere_ 設定檔效果最佳，較舊的印表機則需要該型號專用的驅動程式。

在印表機上按右鍵並選擇 _Set as Default_，即可選取你的應用程式優先使用的印表機，並選擇 _Properties_ 來設定紙張大小、雙面列印與品質。

自動探索功能，也就是網路上的印表機會在未新增的情況下自動出現，目前在重新改造期間暫時關閉，這就是為什麼上述第一步需要由你親自操作，而非自動完成。完全不需要任何印表機，也能列印成 PDF 檔案。

### 如何變更螢幕截圖或螢幕錄影的儲存位置？

已儲存的螢幕截圖預設會存到 `~/Pictures/Screenshots`。若要使用其他目錄，請將以下內容加入 `~/.config/uwsm/env.d/` 下的一個檔案（例如 `~/.config/uwsm/env.d/capture`）：

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

螢幕錄影也可以用相同方式，使用 `OMARCHY_SCREENRECORD_DIR`。

Omasnap 會自動建立它的螢幕截圖目錄。螢幕錄影目錄請自行建立，然後重新啟動 Omarchy，任一項環境變更才會生效。

### 如何讓 Apple Studio Display 的喇叭 + 攝影機正常運作？

你可能會以為只要接上 USB C 就應該全部都能運作，但很遺憾，事實並非如此。我找到能讓它可靠運作的解決方案，是使用[這條 WJESOG DisplayPort + USB-A => USB-C 傳輸線](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/)。如此一來，喇叭和攝影機就能完美運作。

請記住，Omarchy 針對 Apple 顯示器（Studio 與 XDR 兩者）內建亮度控制功能，可使用一般的鍵盤亮度按鈕操作。

### 如何移除所有額外的軟體？

如果你不想要 Obsidian 或 LibreOffice 等程式，或任何其他預先安裝的東西，你可以非常輕鬆地將它移除。

執行 _Remove > Package_ 即可查看所有已安裝的套件。然後你可以用 tab 選取任何你想移除的套件，並按 return 開始移除所有已選取的項目。

你也可以使用 Omarchy 選單中的 _Remove > Web App_，移除任何你不想要的預先安裝網頁應用程式。

或是執行 _Remove > Preinstalls_，一次清掃所有預先安裝的額外項目 — 網頁應用程式、TUI 與選用應用程式。啟動它們的快捷鍵會隨之消失，因此你會留下一組乾淨空白的綁定，可以在 `~/.config/hypr/bindings.lua` 中填入你自己的設定。

---

如有錯誤與損壞的部分，請參閱[疑難排解章節](45-troubleshooting.md)。
