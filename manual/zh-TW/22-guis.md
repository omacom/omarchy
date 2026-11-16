# 圖形介面程式

## Files

Files (Nautilus) 是圖形化檔案管理程式。`Super + Shift + F` 可開啟它，`Super + Shift + Alt + F` 則會在你終端機目前所在的目錄開啟它，能省下不少點擊。`Ctrl + L` 讓你輸入路徑，在任意檔案上按 `Space` 就能快速預覽，不必真的開啟任何東西。

插入 USB 隨身碟或 SD 卡後，它會自動掛載，直接出現在側邊欄中。若要做更進階的事——格式化磁碟、檢查 SMART 健康狀態、建立分割區——請從應用程式啟動器 (`Super + Space`) 啟動 _Disks_。

連按兩下會依合理的預設值開啟：圖片、影片與音樂在 Omaview 中開啟，PDF 在 Document Viewer 中開啟，Markdown 在 Omawrite 中開啟，純文字則在 _Setup > Default > Editor_ 下選定的編輯器中開啟。

## Disktree

當磁碟滿了，而你完全不知道是什麼在吃空間時，從應用程式啟動器 (`Super + Space`) 啟動 [Disktree](https://github.com/tobi/disktree)。它會以圖形化樹狀圖顯示你的家目錄。區塊越大，佔用的空間越多；用鍵盤或滑鼠走進各個目錄，標記要刪除的內容，並在移除任何東西前檢視你的選擇。執行 `disktree --disk` 可掃描整個磁碟。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免費且高度可擴充的筆記應用程式，使用簡單的 Markdown 檔案儲存資料。

Obsidian 可免費供所有用途使用，包括個人、商業與非營利用途。

Obsidian 也提供一款 [用於同步的商業附加功能](https://obsidian.md/sync)，可與 iOS 與 Android 上的行動應用程式同步。(https://obsidian.md/pricing)。

你可以用 `Super + Shift + O` 啟動 Obsidian。若要使用主題同步，你必須在設定下選取 `Omarchy` 主題。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家的超簡單 Markdown 寫作應用程式。沒有資料庫，沒有外掛，只有你和文字。

你可以用 `Super + Shift + W` 啟動 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基本的圖片編輯工具，非常適合裁切、調整大小與其他基本操作。只是別指望它能取代 Photoshop。不過它還是有魔術棒和圖層！

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主題應用程式，能從背景圖片中擷取顏色，並將其轉換成一套完整且協調的主題。這是 [打造你自己的主題](43-making-your-own-theme.md) 最簡單的方法。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 讓你將檔案傳送到同一網路上執行該應用程式的其他裝置，就像 Apple 的 AirDrop 一樣。不過它是跨平台的，所以你可以與 Windows、macOS、Android、iOS，當然還有 Linux，互相傳送檔案。

你可以用 `Super + Ctrl + S` 開啟 Share 選單，或在 Omarchy 選單的 _Trigger > Share_ 下開啟。它提供你四個選項：

- **Clipboard** 將你已複製的任何內容以文字檔案傳送。非常適合把連結或程式碼片段傳到手機上，不必寄信給自己。
- **File** 開啟檔案選擇器，讓你一次選取多個檔案。
- **Folder** 傳送整個目錄。
- **Receive** 開啟 LocalSend 本體，讓另一台裝置可以傳送東西給你。

同樣的事也能從終端機完成：`omarchy share clipboard`、`omarchy share file [path]` 與 `omarchy share folder [path]`。省略路徑，就會開啟選擇器。

你也可以直接從檔案管理程式傳送：在 Nautilus 中對任何選取項目按右鍵，並選擇 _Send via LocalSend_。

Omarchy 的防火牆預設為關閉，僅開放 LocalSend 的連接埠，因此在全新安裝中就能立即使用。請參見 [安全性](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一套完整的辦公室套裝軟體，包含文書處理、試算表、簡報、繪圖應用程式等。它能相容 Microsoft Office 的檔案，所以這是開啟那些 Word 文件的絕佳方式。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家的超簡單簡報應用程式。你的簡報是一份單一 Markdown 檔案，圖片與影片就放在它旁邊：在即時預覽下方撰寫每一張投影片，將投影片拖曳成想要的順序，然後全螢幕簡報，或匯出為 PDF 與 PowerPoint。它甚至會採用你的 Omarchy 主題。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Hype。在其中按 `?` 可查看所有快捷鍵。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家的超簡單 PDF 簽名與填寫方式。將你儲存的簽名、文字與今天的日期放在頁面上的任意位置，然後在原始檔案旁儲存一份已簽名的副本。作法請參見 [填寫 PDF](27-filling-out-pdfs.md)。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Signed，或從檔案管理程式用它開啟 PDF。

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) 是 Omarchy 自家的 3D 西洋棋遊戲。你可以在同一台電腦上與朋友對弈，或以三種程度挑戰內建對手，使用四套各有獨特走法的雕刻棋組：軌道飛行器、雕刻木與象牙、森林生物，以及糖果。對局沒有計時，每走一步都會存檔。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Checkmate。在其中按 `?` 可查看所有快捷鍵。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家的超簡單計算機，會以浮動視窗開啟。

你可以用 `Super + Shift + Q` 啟動 Omacalc（如果你的鍵盤有計算機鍵，也可以用那個鍵）。

## Signal

[Signal](https://signal.org/) 是 E2E 加密訊息的先驅，對於不想透過大型科技集團的任何人來說，都是一個很棒的通訊選擇。

你可以用 `Super + Shift + G` 啟動 Signal。它不包含在基本安裝中，所以你第一次按下那個組合鍵時，Omarchy 會提供為你安裝它的選項（它也位於 Omarchy 選單的 _Install > Service_ 下）。

## Omaview

[Omaview](https://github.com/omacom/omaview) 是 Omarchy 自家的超簡單圖片檢視器與媒體播放器：用一個視窗就能看你的照片、影片與音樂。開啟一張照片後，方向鍵可逐步瀏覽其資料夾中的其他內容，`N` 與 `P` 可對任何內容執行相同操作，`Ctrl + M` 則以格狀方式顯示整個資料夾。它也能顯示 HEIC、AVIF 與 JPEG XL 照片，並能從你上次在任何長內容中停下的地方繼續。

按 `F` 進入全螢幕，按 `E` 在 Omasnap 中編輯圖片或在 Omacut 中剪輯影片，按 `Ctrl + P` 列印圖片，按 `Delete` 將檔案移到垃圾桶（`Ctrl + Z` 可將它復原）。在其中按 `?` 可查看所有快捷鍵。

你可以透過應用程式啟動器 (`Super + Space`) 以 _Media Viewer_ 啟動 Omaview，或直接在檔案管理程式中連按兩下圖片、影片或歌曲。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家的超簡單影片剪輯工具。當你只需要剪掉一段影片的開頭與結尾時，它比啟動完整的影片編輯器好用得多。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家的超簡單網路攝影機錄影工具。只需選擇一次你的攝影機與麥克風，然後按 `Space` 開始錄影，再按一次即可暫停並繼續同一次錄影。它永遠以攝影機的最高解析度錄影，並提供即時麥克風音量表，讓你在開始前檢查音量。

停止錄影後，它會立即在內建編輯器中開啟。連按兩下片段即可將它分割，拖曳控制柄可修剪每一小段，並移除你不要的部分。然後將它儲存為 MP4。你的原始錄影會保留到你捨棄它為止，所以你隨時可以回來以不同方式剪輯。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Monologue。
