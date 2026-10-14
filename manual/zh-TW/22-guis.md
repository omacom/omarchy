# GUI

## 檔案

檔案（Nautilus）是圖形化的檔案管理器。`Super + Shift + F` 開啟它，而 `Super + Shift + Alt + F` 會在你的終端機所在的目錄開啟它，這能省下很多點擊。`Ctrl + L` 讓你輸入路徑，在任何檔案上按 `Space` 可在不開啟任何東西的情況下快速預覽。

插入 USB 隨身碟或 SD 卡，它會自動掛載，所以會直接出現在側邊欄中。對於更複雜的事情——格式化磁碟機、檢查 SMART 健康狀態、建立分割區——從應用程式啟動器（`Super + Space`）啟動 _Disks_。

雙擊遵循合理的預設：圖片在 imv 中開啟，影片在 mpv 中開啟，PDF 在 Document Viewer 中開啟，純文字在 Neovim 中開啟。

## Disktree

當磁碟機滿了、而你完全不知道是什麼吃掉了空間時，從應用程式啟動器（`Super + Space`）啟動 [Disktree](https://github.com/tobi/disktree)。它會顯示你家目錄的圖形化樹狀圖。較大的區塊佔用更多空間；用鍵盤或滑鼠走進目錄，標記應該刪除的東西，並在移除任何東西之前檢視你的選取。執行 `disktree --disk` 可掃描整個磁碟。

## Obsidian

[Obsidian](https://obsidian.md/) 是一個免費且高度可擴充的筆記應用程式，使用簡單的 Markdown 檔案作為儲存方式。

Obsidian 可免費使用於所有用途，包括個人、商業和非營利用途。

Obsidian 還提供一個[用於同步的商業外掛](https://obsidian.md/sync)，搭配 iOS 和 Android 上的行動應用程式。(https://obsidian.md/pricing)。

你用 `Super + Shift + O` 啟動 Obsidian。要使用主題同步，你必須在設定中選取 `Omarchy` 主題。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家極簡的 Markdown 寫作應用程式。沒有 vault、沒有外掛，只有你和文字。

你用 `Super + Shift + W` 啟動 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一個基本的圖片編輯工具，非常適合裁剪、縮放和其他基本操作。就是別指望它是 Photoshop 的替代品。但它還是有魔術棒和圖層！

你透過應用程式啟動器（`Super + Space`）啟動 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一個主題應用程式，可以從背景圖片中擷取色彩，並將它們轉換為一個完整、協調的主題。這是[製作你自己的主題](43-making-your-own-theme.md)最簡單的方式。

你透過應用程式啟動器（`Super + Space`）啟動 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 讓你將檔案傳送到同一網路上執行該應用程式的其他裝置，就像 Apple 的 AirDrop。但它是跨平台的，所以你可以與 Windows、macOS、Android、iOS，當然還有 Linux 互相傳送檔案。

你可以在 `Super + Ctrl + S` 或 Omarchy 選單的 _觸發 > 分享_ 下開啟分享選單。它提供四個選項：

- **剪貼簿**會將你已複製的內容以文字檔案的形式傳送。非常適合把連結或程式碼片段傳到手機上，而不用寄電子郵件給自己。
- **檔案**會開啟一個檔案選擇器，你可以一次選取多個檔案。
- **資料夾**會傳送整個目錄。
- **接收**會開啟 LocalSend 本身，讓另一台裝置可以傳送東西給你。

在終端機中用 `omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]` 也能做同樣的事。省略路徑就會得到選擇器。

你也可以直接從檔案管理器傳送：在 Nautilus 中右鍵按一下任何選取項目，並選取 _Send via LocalSend_。

Omarchy 的防火牆預設是關閉的，僅開放 LocalSend 的連接埠，所以在全新安裝後這開箱即用。請參閱[安全性](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一套完整的辦公套件，包含文書處理器、試算表、簡報、繪圖應用程式等。它與 Microsoft Office 的檔案相容，所以這是開啟那些 Word 文件的好方法。

你透過應用程式啟動器（`Super + Space`）啟動 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家極簡的簡報應用程式。你的簡報就是一個 Markdown 檔案，圖片和影片放在旁邊：在即時預覽下方撰寫每一張投影片，將投影片拖曳到正確順序，然後全螢幕簡報或匯出為 PDF 和 PowerPoint。它甚至會採用你的 Omarchy 主題。

你透過應用程式啟動器（`Super + Space`）啟動 Hype。在它裡面按 `?` 可查看每個快捷鍵。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家極簡的 PDF 簽名和填寫方式。將你儲存的簽名、文字和今天的日期放在頁面的任何位置，然後在原始檔案旁邊儲存一份已簽名的副本。做法請參閱[填寫 PDF](27-filling-out-pdfs.md)。

你透過應用程式啟動器（`Super + Space`）啟動 Signed，或從檔案管理器用它開啟 PDF。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家極簡的計算機，會在浮動視窗中開啟。

你用 `Super + Ctrl + Q` 啟動 Omacalc（如果你的鍵盤有計算機鍵，也可以用那個鍵）。

## Signal

[Signal](https://signal.org/) 是端到端加密訊息的先驅，對於任何不想透過某個大型科技集團的人來說，都是一個很好的通訊選擇。

你用 `Super + Shift + G` 啟動 Signal。它不是基礎安裝的一部分，所以你第一次按這個快捷鍵時，Omarchy 會主動為你安裝它（它也位於 Omarchy 選單的 _安裝 > Service_ 下）。

## mpv

[mpv](https://mpv.io/) 是一個簡單、快速的媒體播放器，幾乎可以播放任何來源的任何內容。非常適合看影片。

你透過應用程式啟動器（`Super + Space`）啟動 mpv，或直接在檔案管理器中雙擊影片。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家極簡的影片修剪工具。當你只需要剪掉片段的開頭和結尾時，它比啟動一個完整的影片編輯器好多了。

你透過應用程式啟動器（`Super + Space`）啟動 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家極簡的網路攝影機錄影工具。選一次你的攝影機和麥克風，然後按 `Space` 錄影，再按一次暫停並繼續同一次錄製。它總是以你攝影機的最高解析度錄影，並帶有即時麥克風音量表，讓你在開始前檢查音量。

停止錄製後，它會立即在內建編輯器中開啟。雙擊一個片段可將其分割，拖曳控點可修剪每一小段，並移除你不想要的部分。然後將它儲存為 MP4。你的原始錄影會保留到你捨棄它為止，所以你隨時可以回來用不同方式剪輯。

你透過應用程式啟動器（`Super + Space`）啟動 Monologue。
