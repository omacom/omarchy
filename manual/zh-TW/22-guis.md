# GUI 應用程式

## Files

Files (Nautilus) 是圖形化檔案管理器。按下 `Super + Shift + F` 就能開啟它，而 `Super + Shift + Alt + F` 則會在你的終端機目前所在的目錄開啟它，省下大量點來點去的時間。`Ctrl + L` 讓你直接輸入路徑，在任何檔案上按下 `Space` 就能快速預覽，不必真的開啟任何東西。

插上 USB 隨身碟或 SD 卡後，它會自動掛載，所以會直接出現在側邊欄裡。若要做更進階的事——格式化磁碟、檢查 SMART 健康狀態、建立分割區——就從應用程式啟動器 (`Super + Space`) 啟動 _Disks_。

連點兩下會依合理的預設方式開啟：圖片、影片和音樂會在 Omaview 開啟，PDF 會在 Document Viewer 開啟，Markdown 會在 Omawrite 開啟，純文字則會在 _Setup > Default > Editor_ 下所選的編輯器開啟。

## Disktree

當磁碟塞滿，而你完全不知道是什麼在吃空間時，從應用程式啟動器 (`Super + Space`) 啟動 [Disktree](https://github.com/tobi/disktree)。它會以圖形化樹狀圖顯示你的家目錄。區塊越大，佔用的空間就越多；用鍵盤或滑鼠走進各個目錄，標記要刪除的項目，並在刪除任何東西之前先檢查你的選擇。執行 `disktree --disk` 就能掃描整顆磁碟。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免費且高度可擴充的筆記應用程式，使用簡單的 Markdown 檔案來儲存。

Obsidian 適用於所有用途皆免費，包括個人、商業和非營利用途。

Obsidian 也提供一款[用於同步的商業附加功能](https://obsidian.md/sync)，可與 iOS 和 Android 上的行動應用程式同步。(https://obsidian.md/pricing)。

你可以用 `Super + Shift + O` 啟動 Obsidian。若要使用主題同步，你必須在設定下選擇 `Omarchy` 主題。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家極其簡單的 Markdown 寫作應用程式。沒有 vault，沒有外掛，只有你和文字。

你可以用 `Super + Shift + W` 啟動 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基本的圖片編輯工具，很適合裁切、調整大小和其他基本操作。只是別指望它能替代 Photoshop。不過它還是有 Magic Wand 和圖層！

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主題應用程式，可以從背景圖片中擷取顏色，並將其轉成一套完整且協調的主題。這是[製作你自己的主題](43-making-your-own-theme.md)最簡單的方法。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 讓你把檔案傳送到同一網路上執行這款應用程式的其他裝置，就像 Apple 的 AirDrop 一樣。不過它是跨平台的，所以你可以與 Windows、macOS、Android、iOS，以及當然還有 Linux 互相傳送檔案。

你可以在 `Super + Ctrl + S` 開啟 Share 選單，或是在 Omarchy 選單下的 _Trigger > Share_ 開啟。它提供四個選項：

- **Clipboard** 會將你複製的任何內容以文字檔形式傳送。很適合把連結或一段文字片段傳到手機上，不必再寄電子郵件給自己。
- **File** 會開啟檔案選擇器，讓你一次選取多個檔案。
- **Folder** 會傳送整個目錄。
- **Receive** 會開啟 LocalSend 本體，讓其他裝置能傳送東西給你。

同樣的事也能從終端機用 `omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]` 完成。不加上路徑，就會出現選擇器。

你也可以直接從檔案管理器傳送：在 Nautilus 中對任何選取項目按右鍵，然後選擇 _Send via LocalSend_。

Omarchy 的防火牆預設處於封閉狀態，只有 LocalSend 的連接埠是例外，所以在全新安裝的系統上開箱即可使用。請參閱[安全性](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一套完整的辦公室軟體套件，包含文書處理、試算表、簡報、繪圖應用程式等。它與 Microsoft Office 的檔案相容，所以這是開啟那些 Word 文件的好方法。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家極其簡單的簡報應用程式。你的簡報就是單一 Markdown 檔案，圖片和影片就放在它旁邊：在即時預覽下方撰寫每一張投影片，把投影片拖曳成想要的順序，然後全螢幕簡報，或匯出成 PDF 和 PowerPoint。它甚至會套用你的 Omarchy 主題。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Hype。在裡面按下 `?` 就能看到所有快捷鍵。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家極其簡單的 PDF 簽署與填寫方式。把你儲存的簽名、文字和今天的日期放在頁面上的任何位置，然後在原始檔案旁邊儲存一份已簽署的副本。作法請參閱[填寫 PDF](27-filling-out-pdfs.md)。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Signed，或從檔案管理器用它開啟 PDF。

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) 是 Omarchy 自家的 3D 西洋棋遊戲。你可以在同一台電腦上和朋友對弈，或與三個等級的內建對手對弈，並使用四組造型棋組，每組都有自己獨特的移動方式：軌道飛行器、雕刻木頭與象牙、森林生物，以及糖果。對局沒有計時器，而且每走一步都會儲存。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Checkmate，它在那裡會列為 Chess。在裡面按下 `?` 就能看到所有快捷鍵。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家極其簡單的計算機，會在浮動視窗中開啟。

你可以用 `Super + Shift + Q` 啟動 Omacalc（或是計算機鍵，如果你的鍵盤有的話）。

## Signal

[Signal](https://signal.org/) 是 E2E 加密通訊的先驅，對於任何不想透過大型科技集團通訊的人來說，都是很棒的通訊選擇。

你可以用 `Super + Shift + G` 啟動 Signal。它不在基本安裝之中，所以你第一次按下那組快捷鍵時，Omarchy 會提供為你安裝它（它也位於 Omarchy 選單下的 _Install > Service_）。

## Omaview

[Omaview](https://github.com/omacom/omaview) 是 Omarchy 自家極其簡單的圖片檢視器與媒體播放器：用一個視窗就能看你的照片、影片和音樂。開啟一張照片後，方向鍵會依序瀏覽它所在資料夾的其餘照片，`N` 和 `P` 對任何內容都能這樣做，而 `Ctrl + M` 會把整個資料夾以格狀顯示。它也能顯示 HEIC、AVIF 和 JPEG XL 照片，而且對於任何長篇內容，都會從你上次離開的地方繼續。

按下 `F` 進入全螢幕，按下 `E` 在 Omasnap 中編輯圖片或在 Omacut 中修剪影片，按下 `Ctrl + P` 列印圖片，按下 `Delete` 將檔案移到 Trash（`Ctrl + Z` 可將它還原）。在裡面按下 `?` 就能看到所有快捷鍵。

你可以透過應用程式啟動器 (`Super + Space`) 以 _Media Viewer_ 啟動 Omaview，或直接在檔案管理器中連點兩下圖片、影片或歌曲。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家極其簡單的影片修剪工具。當你只需要剪掉一段影片的開頭和結尾時，用它比啟動一套完整的影片編輯器好多了。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家極其簡單的網路攝影機錄影工具。只要選好你的攝影機和麥克風一次，然後按下 `Space` 開始錄影，再按一次就能暫停並繼續同一次錄影。它一律以你攝影機的最高解析度錄影，並有即時麥克風電平表，讓你在開始前就能檢查音量。

停止錄影後，它會立即在內建編輯器中開啟。連點兩下片段就能將它分割，拖曳控制點來修剪每一小段，並移除你不要的部分。然後將它儲存為 MP4。你的原始錄影會保留到你丟棄它為止，所以你隨時都能回來用不同的方式剪輯。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Monologue。
