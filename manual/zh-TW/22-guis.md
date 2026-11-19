# 圖形介面程式

## Files

Files（Nautilus）是圖形化檔案管理器。按 `Super + Shift + F` 可開啟它，按 `Super + Shift + Alt + F` 則會在終端機目前所在的目錄開啟它，能省下不少點按。按 `Ctrl + L` 可以輸入路徑，在任何檔案上按 `Space`，就能快速預覽，不必開啟任何程式。

插入 USB 隨身碟或 SD 卡後，系統會自動掛載，直接出現在側邊欄中。若要做更進階的操作——格式化磁碟、檢查 SMART 健康狀態、建立分割區——請從應用程式啟動器（`Super + Space`）啟動 _Disks_。

連按兩下會依合理的預設方式開啟：圖片、影片和音樂會在 Omaview 中開啟，PDF 會在 Document Viewer 中開啟，Markdown 會在 Omawrite 中開啟，純文字則會使用在 _設定 > 預設 > 編輯器_ 下選定的編輯器開啟。

## Disktree

當磁碟滿了，而你完全不知道是什麼在吃空間時，請從應用程式啟動器（`Super + Space`）啟動 [Disktree](https://github.com/tobi/disktree)。它會以圖形化樹狀圖顯示你的家目錄。區塊越大，佔用的空間越多；用鍵盤或滑鼠進入目錄，標記要移除的內容，並在刪除任何東西之前先檢查你的選取項目。執行 `disktree --disk` 可以掃描整個磁碟。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免費且高度可擴充的筆記應用程式，使用簡單的 Markdown 檔案儲存資料。

Obsidian 完全免費，包含個人、商業和非營利用途。

Obsidian 也提供可與 iOS 和 Android 行動應用程式同步的[商業附加元件](https://obsidian.md/sync)。(https://obsidian.md/pricing)。

你可以用 `Super + Shift + O` 啟動 Obsidian。若要使用主題同步，必須在設定中選擇 `Omarchy` 主題。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家極簡的 Markdown 寫作應用程式。沒有資料庫，沒有外掛，只有你和文字。

你可以用 `Super + Shift + W` 啟動 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基本的圖片編輯工具，很適合裁切、調整大小和其他基本操作。只是不要期待它能替代 Photoshop。不過它還是有魔術棒和圖層！

你可以透過應用程式啟動器（`Super + Space`）啟動 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主題應用程式，可以從背景圖片中提取顏色，並將其轉換為完整且一致的主題。這是[製作你自己的主題](43-making-your-own-theme.md)最簡單的方法。

你可以透過應用程式啟動器（`Super + Space`）啟動 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 讓你能將檔案傳送到同一網路上執行此應用程式的其他裝置，就像 Apple 的 AirDrop 一樣。不過它是跨平台的，所以你可以在 Windows、macOS、Android、iOS，當然還有 Linux 之間互相傳送檔案。

你可以用 `Super + Ctrl + S` 開啟分享選單，或是在 Omarchy 選單的 _觸發 > 分享_ 下開啟。它提供四個選項：

- **剪貼簿**會將你複製的任何內容以文字檔形式傳送。很適合把連結或程式碼片段傳到手機上，不必再寄信給自己。
- **檔案**會開啟檔案選擇器，你可以一次選取多個檔案。
- **資料夾**會傳送整個目錄。
- **接收**會開啟 LocalSend 本體，讓其他裝置可以傳送東西給你。

在終端機中也可以用同樣的方式操作：`omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]`。省略路徑，就會出現選擇器。

你也可以直接從檔案管理器傳送：在 Nautilus 中對任何選取項目按右鍵，並選擇 _透過 LocalSend 傳送_。

Omarchy 的防火牆預設為關閉狀態，僅開放 LocalSend 的連接埠，因此在全新安裝中開箱即用。請參閱[安全性](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一套完整的辦公室軟體包，包含文書處理、試算表、簡報、繪圖應用程式等。它與 Microsoft Office 的檔案相容，因此這是開啟那些 Word 文件的好方法。

你可以透過應用程式啟動器（`Super + Space`）啟動 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家極簡的簡報應用程式。你的整份簡報就是單一 Markdown 檔案，圖片和影片放在旁邊：在即時預覽下方撰寫每張投影片，將投影片拖曳排序，然後全螢幕簡報，或匯出為 PDF 和 PowerPoint。它甚至會套用你的 Omarchy 主題。

你可以透過應用程式啟動器（`Super + Space`）啟動 Hype。在其中按 `?` 可以查看所有快捷鍵。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家極簡簽署 PDF 並填寫 PDF 的方式。將你儲存的簽名、文字和今天的日期放在頁面上的任何位置，然後在原始檔案旁邊儲存一份已簽名的副本。請參閱[填寫 PDF](27-filling-out-pdfs.md)了解做法。

你可以透過應用程式啟動器（`Super + Space`）啟動 Signed，或從檔案管理器用它開啟 PDF。

## Game Vibes

在應用程式啟動器（`Super + Space`）中的 Game Vibes 是 Omarchy 小遊戲所在之處：Checkmate，一款與朋友或內建對手對弈的 3D 西洋棋遊戲；Cards，Klondike 接龍；還有 Neon Swarm，一款街機射擊遊戲。每款遊戲都是一個遵循你的主題的單一網頁。用方向鍵和 `Enter` 選擇一款遊戲，並從遊戲的標題畫面按 `Esc`，或在暫停時按 `Q` 回到清單。它會以全螢幕開啟：按 `Super + F` 使其變成視窗，按 `Super + W` 將其關閉。

你用 agent 製作的遊戲也會出現在這裡：在 agent 面板中選擇 _做點酷東西 → 遊戲_ 並描述一款遊戲，或是指定 Game Vibes 中已有的遊戲來繼續製作。agent 會將它複製到 `~/Games/vibes`，在那裡你可以任意變更，並在完成時開啟它。你也可以用 `omarchy games vibes copy <game>` 自行複製。他人分享的遊戲安裝方式與主題相同：選擇 _安裝 > 電玩 > Game Vibes_ 並貼上其 git 位址，或執行 `omarchy games vibes install <git-repo-url>`。_移除 > 電玩_ 可以再次移除一款遊戲，_更新 > Game Vibes 遊戲_ 會擷取新版本。遊戲會從網路載入 three.js，因此開始時需要網路連線。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家極簡的計算機，會以浮動視窗開啟。

你可以用 `Super + Shift + Q`（或是計算機鍵，如果你的鍵盤有的話）啟動 Omacalc。

## Signal

[Signal](https://signal.org/) 是 E2E 加密通訊的先驅，對於任何不想透過大型科技集團通訊的人來說，都是一個很好的通訊選擇。

你可以用 `Super + Shift + G` 啟動 Signal。它並非基本安裝的一部分，因此你第一次按下這個組合鍵時，Omarchy 會提供為你安裝它的選項（它也位於 Omarchy 選單的 _安裝 > 服務_ 下）。

## Omaview

[Omaview](https://github.com/omacom/omaview) 是 Omarchy 自家極簡的圖片檢視器和媒體播放器：一個視窗就能處理你的照片、影片和音樂。開啟一張照片後，方向鍵會依序瀏覽其所屬資料夾中的其他內容，`N` 和 `P` 對任何內容都能這樣做，`Ctrl + M` 則會將整個資料夾以格狀顯示。它也支援顯示 HEIC、AVIF 和 JPEG XL 照片，並會在任何較長的內容中從你上次離開的地方繼續播放。

按 `F` 可切換全螢幕，按 `E` 可在 Omasnap 中編輯圖片或在 Omacut 中修剪影片，按 `Ctrl + P` 可列印圖片，按 `Delete` 可將檔案移至垃圾桶（按 `Ctrl + Z` 可將其還原）。在其中按 `?` 可以查看所有快捷鍵。

你可以透過應用程式啟動器（`Super + Space`）以 _媒體檢視器_ 的名稱啟動 Omaview，或直接在檔案管理器中連按兩下圖片、影片或歌曲。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家極簡的影片修剪工具。當你只需要剪掉一段影片的開頭和結尾時，它遠比開啟完整的影片編輯器好用。

你可以透過應用程式啟動器（`Super + Space`）啟動 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家極簡的網路攝影機錄影工具。只需選擇一次你的攝影機和麥克風，然後按 `Space` 即可錄影，再次按下即可暫停並繼續同一次錄影。它一律以你的攝影機最高解析度錄影，並配有即時麥克風音量表，讓你在開始之前就能檢查音量。

停止錄影後，它會立即在內建編輯器中開啟。連按兩下片段即可將其分割，拖曳把手即可修剪每個部分，並移除你不需要的部分。然後將其儲存為 MP4。你的原始錄影會保留，直到你捨棄它為止，因此你可以隨時回來以不同的方式剪輯。

你可以透過應用程式啟動器（`Super + Space`）啟動 Monologue。
