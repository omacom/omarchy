# GUI 應用程式

## 檔案

檔案（Nautilus）是圖形化檔案管理員。使用 `Super + Shift + F` 可以開啟它，而 `Super + Shift + Alt + F` 會在你終端機目前所在的目錄開啟它，可以省下很多點擊。`Ctrl + L` 讓你可以輸入路徑，在任何檔案上按下 `Space` 就能快速預覽，不需要真的開啟。

插上 USB 隨身碟或 SD 卡後，它會自動掛載，所以會直接出現在側邊欄。如果要做更進階的事——格式化磁碟、檢查 SMART 健康狀態、建立分割區——從應用程式啟動器（`Super + Space`）啟動 _Disks_。

雙擊檔案時會遵循合理的預設：圖片會用 imv 開啟、影片會用 mpv 開啟、PDF 會用 Document Viewer 開啟，而純文字會用 Neovim 開啟。

## Disktree

當磁碟滿了，而你完全不知道是什麼在吃空間時，從應用程式啟動器（`Super + Space`）啟動 [Disktree](https://github.com/tobi/disktree)。它會顯示你家目錄的圖形化樹狀圖。越大的區塊代表佔用越多空間；用鍵盤或滑鼠進入目錄、標記要刪除的項目，並在移除任何東西之前檢查你的選擇。執行 `disktree --disk` 可以掃描整個磁碟。

## Obsidian

[Obsidian](https://obsidian.md/) 是一個免費且高度可擴充的筆記應用程式，它使用簡單的 Markdown 檔案作為儲存方式。

Obsidian 完全免費，包含個人、商業和非營利用途。

Obsidian 也提供了一個用於與 iOS 和 Android 行動 App 同步的[商業附加功能](https://obsidian.md/sync)。(https://obsidian.md/pricing)。

你可以用 `Super + Shift + O` 啟動 Obsidian。要使用主題同步，你必須在設定下選擇 `Omarchy` 主題。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家簡單到不行的 Markdown 寫作 App。沒有保管庫、沒有外掛程式，就只有你和文字。

你可以用 `Super + Shift + W` 啟動 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一個基本的圖片編輯工具，非常適合裁切、調整大小和其他基本操作。只是別期待它是 Photoshop 的替代品。但它仍然有魔術棒和圖層！

你可以透過應用程式啟動器（`Super + Space`）啟動 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一個主題應用程式，它可以從背景圖片中提取顏色，並將它們轉換成一個完整、一致的主題。這是最簡單的[打造自己的主題](43-making-your-own-theme.md)的方法。

你可以透過應用程式啟動器（`Super + Space`）啟動 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 讓你可以將檔案傳送到同一網路上執行該 App 的其他裝置，就像 Apple 的 AirDrop 一樣。不過它是跨平台的，所以你可以與 Windows、macOS、Android、iOS，以及當然還有 Linux 互相傳送檔案。

你可以在 `Super + Ctrl + S` 開啟 Share 選單，或在 Omarchy 選單下的 _Trigger > Share_ 開啟。它提供你四個選項：

- **Clipboard** 會將你複製的任何內容作為文字檔案傳送。非常適合將連結或程式碼片段傳到你的手機上，而不用寄電子郵件給自己。
- **File** 會開啟一個檔案選擇器，你可以一次選取多個檔案。
- **Folder** 會傳送整個目錄。
- **Receive** 會開啟 LocalSend 本身，以便其他裝置可以傳送東西給你。

同樣的事也可以從終端機使用 `omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]` 來完成。省略路徑，你就會得到選擇器。

你也可以直接從檔案管理員傳送：在 Nautilus 中對任何選取的項目按右鍵，並選擇 _Send via LocalSend_。

Omarchy 的防火牆預設是關閉的，但 LocalSend 的連接埠除外，所以這在全新安裝時就能直接使用。請參閱[安全性](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一個完整的辦公室套件，包含文書處理器、試算表、簡報、繪圖應用程式等等。它與 Microsoft Office 的檔案相容，所以這是一個能開啟那些 Word 文件的好方法。

你可以透過應用程式啟動器（`Super + Space`）啟動 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家簡單到不行的簡報 App。你的簡報是一個單一的 Markdown 檔案，其圖片和影片放在旁邊：在即時預覽下方撰寫每一張投影片，將投影片拖曳排序，然後全螢幕展示或匯出為 PDF 和 PowerPoint。它甚至會套用你的 Omarchy 主題。

你可以透過應用程式啟動器（`Super + Space`）啟動 Hype。在裡面按下 `?` 可以查看每個快捷鍵。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家簡單到不行的簽署 PDF 並填寫它們的方法。將你儲存的簽名、文字和今天的日期放在頁面上的任何位置，然後在原始檔案旁邊儲存一個已簽署的副本。請參閱[填寫 PDF](27-filling-out-pdfs.md)以了解如何操作。

你可以透過應用程式啟動器（`Super + Space`）啟動 Signed，或從檔案管理員用它開啟 PDF。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家簡單到不行的計算機，它會在一個浮動視窗中開啟。

你可以用 `Super + Shift + Q` 啟動 Omacalc（或是計算機鍵，如果你的鍵盤有的話）。

## Signal

[Signal](https://signal.org/) 是 E2E 加密訊息的先驅，對於任何不想透過大型科技集團通訊的人來說，都是一個很棒的通訊選擇。

你可以用 `Super + Shift + G` 啟動 Signal。它不是基本安裝的一部分，所以你第一次按下時，Omarchy 會提供為你安裝它（它也可以在 Omarchy 選單下的 _Install > Service_ 找到）。

## mpv

[mpv](https://mpv.io/) 是一個簡單、快速的媒體播放器，幾乎可以播放任何來源的任何內容。非常適合看影片。

你可以透過應用程式啟動器（`Super + Space`）啟動 mpv，或直接在檔案管理員中雙擊影片。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家簡單到不行的影片修剪工具。當你只需要剪掉一段影片的開頭和結尾時，它勝過開啟一個完整的影片編輯器。

你可以透過應用程式啟動器（`Super + Space`）啟動 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家簡單到不行的網路攝影機錄影程式。選擇你的攝影機和麥克風一次，然後按下 `Space` 開始錄影，再按一次可以暫停並繼續同一次錄影。它總是以你攝影機的最高解析度錄影，並有一個即時麥克風音量表，讓你在開始之前檢查你的音量。

停止錄影後，它會立即在內建編輯器中開啟。雙擊片段來分割它，拖曳控制點來修剪每個部分，並移除你不想要的部分。然後將它儲存為 MP4。你的原始錄影會保留到你捨棄它為止，所以你隨時可以回來用不同方式剪輯。

你可以透過應用程式啟動器（`Super + Space`）啟動 Monologue。
