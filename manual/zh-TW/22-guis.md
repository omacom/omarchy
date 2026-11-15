# 圖形介面

## Files

Files (Nautilus) 是圖形化檔案管理程式。`Super + Shift + F` 可開啟它，`Super + Shift + Alt + F` 則會在你的終端機目前所在的目錄開啟它，省下很多點按。`Ctrl + L` 讓你輸入路徑，在任何檔案上按 `Space` 就能快速預覽，不需要真的開啟任何東西。

插上 USB 隨身碟或 SD 卡就會自動掛載，所以它會直接出現在側邊欄。若要做更進階的事 — 格式化磁碟、檢查 SMART 健康狀態、建立分割區 — 從應用程式啟動器（`Super + Space`）啟動 _Disks_。

連按兩下會依合理的預設值執行：圖片、影片和音樂在 Omaview 中開啟，PDF 在 Document Viewer 中開啟，純文字則在 Neovim 中開啟。

## Disktree

當磁碟滿了，而你完全不知道是什麼在吃空間時，從應用程式啟動器（`Super + Space`）啟動 [Disktree](https://github.com/tobi/disktree)。它會以圖形化樹狀圖顯示你的家目錄。區塊越大，佔用的空間越多；用鍵盤或滑鼠進入目錄，標記要刪掉的項目，並在移除任何東西前先檢視你的選擇。執行 `disktree --disk` 可掃描整個磁碟。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免費且高度可擴充的筆記應用程式，使用簡單的 Markdown 檔案作為儲存方式。

Obsidian 完全免費，包含個人、商業和非營利用途。

Obsidian 還提供 [用於同步的商業附加功能](https://obsidian.md/sync)，可與 iOS 和 Android 上的行動應用程式同步。(https://obsidian.md/pricing)。

用 `Super + Shift + O` 啟動 Obsidian。若要使用主題同步，你必須在設定中選擇 `Omarchy` 主題。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家簡單到不行的 Markdown 寫作應用程式。沒有 vault、沒有外掛，只有你和文字。

用 `Super + Shift + W` 啟動 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基本的圖片編輯工具，很適合裁切、調整大小和其他基本操作。就是別指望它能替代 Photoshop。不過它還是有 Magic Wand 和圖層！

透過應用程式啟動器（`Super + Space`）啟動 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主題應用程式，能從背景圖片擷取顏色，並將其轉成一套完整且協調的主題。這是 [製作你自己的主題](43-making-your-own-theme.md) 最簡單的方法。

透過應用程式啟動器（`Super + Space`）啟動 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 讓你把檔案傳送到同一網路上執行這款應用程式的其他裝置，就像 Apple 的 AirDrop。不過它是跨平台的，所以你可以在 Windows、macOS、Android、iOS，當然還有 Linux 之間傳送檔案。

你可以用 `Super + Ctrl + S` 開啟 Share 選單，或是在 Omarchy 選單的 _Trigger > Share_ 下找到它。它提供四個選項：

- **Clipboard** 會把你複製的任何內容當成文字檔案傳送。很適合把連結或一段程式碼片段傳到手機上，不用寄電子郵件給自己。
- **File** 會開啟檔案選擇器，讓你一次選取多個檔案。
- **Folder** 會傳送整個目錄。
- **Receive** 會開啟 LocalSend 本身，讓其他裝置能傳送東西給你。

在終端機也能用相同功能，指令是 `omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]`。省略路徑就會開啟選擇器。

你也能直接從檔案管理程式傳送：在 Nautilus 中對任何選取項目按右鍵，然後選擇 _Send via LocalSend_。

Omarchy 的防火牆預設是封閉的，只有 LocalSend 的連接埠例外，所以在全新安裝後開箱即用。請參閱 [安全性](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一款完整的辦公室套裝軟體，包含文書處理、試算表、簡報、繪圖應用程式等。它與 Microsoft Office 的檔案相容，所以這是開啟那些 Word 文件的好方法。

透過應用程式啟動器（`Super + Space`）啟動 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家簡單到不行的簡報應用程式。你的簡報是一份單一的 Markdown 檔案，圖片和影片就放在它旁邊：在即時預覽下方撰寫每張投影片，把投影片拖曳成想要的順序，然後全螢幕簡報，或匯出為 PDF 和 PowerPoint。它甚至會套用你的 Omarchy 主題。

透過應用程式啟動器（`Super + Space`）啟動 Hype。在裡面按 `?` 就能看到所有快捷鍵。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家簡單到不行的 PDF 簽署與填寫方式。把你儲存的簽名、文字和今天的日期放在頁面上的任何位置，然後在原始檔案旁邊儲存一份已簽署的副本。作法請參閱 [填寫 PDF](27-filling-out-pdfs.md)。

透過應用程式啟動器（`Super + Space`）啟動 Signed，或從檔案管理程式用它開啟 PDF。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家簡單到不行的計算機，會以浮動視窗開啟。

用 `Super + Shift + Q` 啟動 Omacalc（或是計算機鍵，如果你的鍵盤上有這個鍵）。

## Signal

[Signal](https://signal.org/) 是 E2E 加密訊息的先驅，對於任何不想透過大型科技集團的人來說，都是很好的通訊選擇。

用 `Super + Shift + G` 啟動 Signal。它不包含在基本安裝中，所以你第一次按下那組快捷鍵時，Omarchy 會詢問是否要幫你安裝（它也位於 Omarchy 選單的 _Install > Service_ 下）。

## Omaview

[Omaview](https://github.com/omacom/omaview) 是 Omarchy 自家簡單到不行的圖片檢視器和媒體播放器：一個視窗就能看你的照片、影片和音樂。開啟一張照片後，方向鍵可以逐步瀏覽同一資料夾中的其他內容，`N` 和 `P` 則能對任何內容執行相同操作，`Ctrl + M` 會把整個資料夾顯示為格狀檢視。它也能顯示 HEIC、AVIF 和 JPEG XL 照片，而且任何較長的內容，都能接續上次播放的位置。

按 `F` 全螢幕，`E` 在 Omasnap 中編輯圖片或在 Omacut 中修剪影片，`Ctrl + P` 列印圖片，`Delete` 把檔案移到 Trash（`Ctrl + Z` 可還原）。在裡面按 `?` 就能看到所有快捷鍵。

透過應用程式啟動器（`Super + Space`）以 _Media Viewer_ 的名稱啟動 Omaview，或直接在檔案管理程式中連按兩下圖片、影片或歌曲。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家簡單到不行的影片修剪工具。當你只需要剪掉片段的開頭和結尾時，它比啟動一套完整的影片編輯器好用多了。

透過應用程式啟動器（`Super + Space`）啟動 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家簡單到不行的 webcam 錄影程式。只要選擇一次你的攝影機和麥克風，然後按 `Space` 開始錄影，再按一次就能暫停並繼續同一次錄影。它一律以你的攝影機最高解析度錄影，並提供即時麥克風音量表，讓你在開始前檢查音量。

停止錄影後，它會立即在內建編輯器中開啟。連按兩下片段就能將其分割，拖曳控制點來修剪每個片段，並移除你不要的部分。然後將其儲存為 MP4。你的原始錄影會保留到你捨棄它為止，所以你隨時都能回來以不同的方式剪輯。

透過應用程式啟動器（`Super + Space`）啟動 Monologue。
