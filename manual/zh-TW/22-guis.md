# GUI 應用程式

## Files

Files (Nautilus) 是圖形化檔案管理員。`Super + Shift + F` 可開啟它，`Super + Shift + Alt + F` 則會在你終端機目前所在的目錄開啟它，省下大量點選。`Ctrl + L` 讓你輸入路徑，在任何檔案上按 `Space` 就能快速預覽，不需要開啟任何東西。

插入 USB 隨身碟或 SD 卡後，系統會自動掛載，所以會直接出現在側邊欄。若要處理更進階的事——格式化磁碟、檢查 SMART 健康狀態、建立分割區——從應用程式啟動器 (`Super + Space`) 啟動 _Disks_。

雙擊會遵循合理的預設：圖片、影片和音樂以 Omaview 開啟，PDF 以 Document Viewer 開啟，Markdown 以 Omawrite 開啟，純文字則以 _Setup > Default > Editor_ 底下選定的編輯器開啟。

## Disktree

當磁碟滿了，而你完全不知道是什麼在吃空間時，從應用程式啟動器 (`Super + Space`) 啟動 [Disktree](https://github.com/tobi/disktree)。它會顯示你家目錄的圖形化樹狀矩形圖。較大的區塊佔用更多空間；用鍵盤或滑鼠進入各目錄，標記要刪除的項目，並在移除任何東西之前檢視你的選取。執行 `disktree --disk` 可掃描整個磁碟。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免費且高度可擴充的筆記應用程式，使用簡單的 Markdown 檔案作為儲存格式。

Obsidian 在所有用途下皆免費使用，包括個人、商業和非營利用途。

Obsidian 也提供 [用於同步的商業附加服務](https://obsidian.md/sync)，可與 iOS 和 Android 上的行動應用程式同步。(https://obsidian.md/pricing)。

你用 `Super + Shift + O` 啟動 Obsidian。若要使用主題同步，你必須在設定底下選擇 `Omarchy` 主題。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家極為簡單的 Markdown 寫作應用程式。沒有資料庫，沒有外掛，只有你和文字。

你用 `Super + Shift + W` 啟動 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基本的圖片編輯工具，非常適合裁切、調整大小和其他基本操作。只是別期待它是 Photoshop 的替代品。但它還是有 Magic Wand 和圖層！

你透過應用程式啟動器 (`Super + Space`) 啟動 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主題應用程式，可以從背景圖片萃取顏色，並將其轉換為完整、協調一致的主題。這是[製作你自己的主題](43-making-your-own-theme.md)最簡單的方法。

你透過應用程式啟動器 (`Super + Space`) 啟動 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 讓你將檔案傳送到同一網路上執行該應用程式的其他裝置，就像 Apple 的 AirDrop。只是它是跨平台的，所以你可以在 Windows、macOS、Android、iOS，當然還有 Linux 之間互傳檔案。

你可以用 `Super + Ctrl + S` 開啟 Share 選單，或從 Omarchy 選單的 _Trigger > Share_ 開啟。它提供四個選項：

- **Clipboard** 會將你複製的任何內容以文字檔傳送。非常適合把連結或程式碼片段傳到手機上，而不必寄電子郵件給自己。
- **File** 會開啟檔案選擇器，可一次選取多個檔案。
- **Folder** 會傳送整個目錄。
- **Receive** 會開啟 LocalSend 本體，讓其他裝置傳送東西給你。

在終端機也可以用同樣功能：`omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]`。省略路徑，就會出現選擇器。

你也可以直接從檔案管理員傳送：在 Nautilus 中對任何選取項目按右鍵，並選擇 _Send via LocalSend_。

Omarchy 的防火牆預設為關閉狀態，僅開放 LocalSend 的連接埠，因此在全新安裝後即可直接使用。參見[安全性](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一套完整的辦公室套件，包含文書處理、試算表、簡報、繪圖應用程式等。它與 Microsoft Office 的檔案相容，所以這是能開啟那些 Word 文件的好方法。

你透過應用程式啟動器 (`Super + Space`) 啟動 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家極為簡單的簡報應用程式。你的簡報是一個單一 Markdown 檔案，旁邊放著它的圖片和影片：在即時預覽下方寫下每張投影片，將投影片拖曳排序，然後全螢幕簡報，或匯出為 PDF 和 PowerPoint。它甚至會套用你的 Omarchy 主題。

你透過應用程式啟動器 (`Super + Space`) 啟動 Hype。在裡面按 `?` 可查看每個快捷鍵。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家極為簡單的 PDF 簽署和填寫方式。將你儲存的簽名、文字和今天的日期放在頁面上的任何位置，然後在原始檔案旁邊儲存一份已簽署的副本。參見[填寫 PDF](27-filling-out-pdfs.md)了解做法。

你透過應用程式啟動器 (`Super + Space`) 啟動 Signed，或從檔案管理員以它開啟 PDF。

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) 是 Omarchy 自家 3D 西洋棋遊戲。在同一台電腦上和朋友對弈，或挑戰三種等級的內建對手，在四組各以獨特方式移動的雕刻棋組上遊玩：軌道飛行器、雕刻木材與象牙、森林生物，以及糖果。對局沒有計時，並在每一步後儲存。

你透過應用程式啟動器 (`Super + Space`) 啟動 Checkmate，它在那裡以 Chess 的名稱列出。在裡面按 `?` 可查看每個快捷鍵。

## Cards

[Cards](https://github.com/omacom/cards) 是 Omarchy 自家 Klondike 接龍。抽三張，且不限重新翻牌次數，在四組紙牌系列中遊玩：一組以你主題的顏色繪製，另外三組各有自己的外觀。點擊一張牌，再點擊它要去的位置，拖曳它，或雙擊將它送到最佳位置。遊戲在每一步後儲存。

你透過應用程式啟動器 (`Super + Space`) 啟動 Cards。點擊它的名稱，或按 `?`，可查看每個快捷鍵。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家極為簡單的計算機，會在浮動視窗中開啟。

你用 `Super + Shift + Q` 啟動 Omacalc（或計算機鍵，如果你的鍵盤有這個鍵）。

## Signal

[Signal](https://signal.org/) 是 E2E 加密通訊的先驅，對於任何不想透過大型科技集團的人來說，是一個很棒的通訊選項。

你用 `Super + Shift + G` 啟動 Signal。它不在基本安裝內，所以第一次按下時，Omarchy 會提供為你安裝（也可以在 Omarchy 選單的 _Install > Service_ 底下找到）。

## Omaview

[Omaview](https://github.com/omacom/omaview) 是 Omarchy 自家極為簡單的圖片檢視器和媒體播放器：一個視窗就能看你的照片、影片和音樂。開啟一張照片後，方向鍵可依序瀏覽同一資料夾的其餘照片，`N` 和 `P` 可對任何內容這樣做，`Ctrl + M` 則將整個資料夾以格狀顯示。它也支援 HEIC、AVIF 和 JPEG XL 照片，並能從任何長內容上次中斷的地方繼續。

按 `F` 進入全螢幕，按 `E` 在 Omasnap 中編輯圖片或在 Omacut 中修剪影片，按 `Ctrl + P` 列印圖片，按 `Delete` 將檔案移到 Trash（`Ctrl + Z` 可將它還原）。在裡面按 `?` 可查看每個快捷鍵。

你透過應用程式啟動器 (`Super + Space`) 以 _Media Viewer_ 啟動 Omaview，或直接在檔案管理員中雙擊圖片、影片或歌曲。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家極為簡單的影片修剪工具。當你只需要剪掉片段的開頭和結尾時，它勝過開啟完整的影片編輯器。

你透過應用程式啟動器 (`Super + Space`) 啟動 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家極為簡單的網路攝影機錄影程式。只需選擇一次你的相機和麥克風，然後按 `Space` 開始錄影，再按一次暫停並繼續同一次拍攝。它始終以你相機的最高解析度錄製，並有即時麥克風電平表，讓你在開始前檢查音量。

停止拍攝後，它會立即在內建編輯器中開啟。雙擊片段可將其分割，拖曳控制點可修剪每一段，並移除你不需要的部分。然後將其儲存為 MP4。你的原始錄影會保留，直到你捨棄它，所以你隨時可以回來以不同方式剪輯。

你透過應用程式啟動器 (`Super + Space`) 啟動 Monologue。
