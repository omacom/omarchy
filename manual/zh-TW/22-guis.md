# GUIs

## Files

Files (Folio) 是圖形化檔案管理器。`Super + Shift + F` 開啟它，`Super + Shift + Alt + F` 則會在你終端機目前所在的目錄開啟它，省下大量點來點去的時間。`Ctrl + L` 讓你輸入路徑，在任何檔案上按 `Space` 就能以完整尺寸預覽，不必真的開啟它。

插上 USB 隨身碟或 SD 卡後，它會自動掛載，直接出現在側邊欄裡。要做更進階的事——格式化磁碟、檢查 SMART 健康狀態、建立分割區——就從應用程式啟動器（`Super + Space`）啟動 _Disks_。

雙擊會依合理的預設值開啟：圖片、影片和音樂會在 Omaview 開啟，PDF 會在 Document Viewer 開啟，Markdown 會在 Omawrite 開啟，純文字則會用 _Setup > Default > Editor_ 裡選定的編輯器開啟。

## Disktree

當磁碟塞滿，而你完全不知道是什麼在吃空間時，從應用程式啟動器（`Super + Space`）啟動 [Disktree](https://github.com/tobi/disktree)。它會以圖形化樹狀圖顯示你的家目錄。區塊越大，佔用的空間越多；用鍵盤或滑鼠走進各個目錄，標記要清掉的內容，並在移除任何東西之前先檢查你的選擇。執行 `disktree --disk` 可掃描整個磁碟。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免費且高度可擴充的筆記應用程式，使用簡單的 Markdown 檔案儲存。

Obsidian 完全免費，包含個人、商業和非營利用途。

Obsidian 也提供[用於同步的商業附加服務](https://obsidian.md/sync)，可與 iOS 和 Android 上的行動應用程式同步。(https://obsidian.md/pricing)。

你用 `Super + Shift + O` 啟動 Obsidian。若要使用主題同步，你必須在設定裡選取 `Omarchy` 主題。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家簡單到不行的 Markdown 寫作應用程式。沒有儲存庫，沒有外掛，就只有你和文字。

你用 `Super + Shift + W` 啟動 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基本的圖片編輯工具，很適合裁切、調整大小和其他基本操作。只是別期待它是 Photoshop 的替代品。不過它還是有魔術棒和圖層！

你透過應用程式啟動器（`Super + Space`）啟動 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主題應用程式，可以從背景圖片萃取顏色，並把它們變成一套完整且協調的主題。這是[打造你自己的主題](43-making-your-own-theme.md)最簡單的方法。

你透過應用程式啟動器（`Super + Space`）啟動 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 讓你可以把檔案傳送到同一個網路上執行這款應用程式的其他裝置，就像 Apple 的 AirDrop 一樣。不過它是跨平台的，所以你可以在 Windows、macOS、Android、iOS，當然還有 Linux 之間傳送檔案。

你可以用 `Super + Ctrl + S` 開啟 Share 選單，或在 Omarchy 選單裡的 _Trigger > Share_ 開啟。它提供四個選項：

- **Clipboard** 會把你複製的任何內容以文字檔案傳送。用來把連結或一段程式碼片段弄到手機上很方便，不必寄電子郵件給自己。
- **File** 會開啟檔案選擇器，讓你一次選取多個檔案。
- **Folder** 會傳送整個目錄。
- **Receive** 會開啟 LocalSend 本體，讓另一台裝置可以傳送東西給你。

在終端機裡也能做同樣的事，使用 `omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]`。不加上路徑，就會開啟選擇器。

你也可以直接從檔案管理器傳送：在 Files 裡對任何選取項目按右鍵，並用 LocalSend 分享。

Omarchy 的防火牆預設為關閉狀態，僅 LocalSend 的連接埠除外，因此全新安裝後即可直接使用。請參閱[安全性](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一套完整的辦公室套裝軟體，包含文書處理、試算表、簡報、繪圖應用程式等等。它與 Microsoft Office 的檔案相容，所以這是開啟那些 Word 文件的好方法。

你透過應用程式啟動器（`Super + Space`）啟動 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家簡單到不行的簡報應用程式。你的簡報就是一個 Markdown 檔案，圖片和影片放在旁邊：在即時預覽下方撰寫每一張投影片，把投影片拖曳成想要的順序，然後全螢幕簡報，或匯出成 PDF 和 PowerPoint。它甚至會套用你的 Omarchy 主題。

你透過應用程式啟動器（`Super + Space`）啟動 Hype。在裡面按下 `?` 就能看到所有快捷鍵。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家用來簽署 PDF 並填寫 PDF 的簡單到不行的方法。把你儲存的簽名、文字和今天的日期放在頁面上的任何位置，然後在原始檔案旁邊儲存一份已簽署的副本。作法請參閱[填寫 PDF](27-filling-out-pdfs.md)。

你透過應用程式啟動器（`Super + Space`）啟動 Signed，或從檔案管理器用它開啟 PDF。

## Game Vibes

在應用程式啟動器（`Super + Space`）裡的 Game Vibes，是 Omarchy 小遊戲所在的地方：Checkmate，一款可以跟朋友或內建對手對弈的 3D 西洋棋遊戲；Cards，Klondike 接龍；還有 Neon Swarm，一款街機射擊遊戲。每一款都是一個會跟隨你主題的單一網頁。用方向鍵和 `Enter` 選一款，在遊戲的標題畫面按 `Esc`，或在暫停時按 `Q`，就能回到列表。它會以全螢幕開啟：`Super + F` 讓它變成視窗，`Super + W` 則關閉它。

你用 agent 做出的遊戲也會出現在這裡：在 agents 面板裡選擇 _Make something cool → Game_ 並描述一款遊戲，或說出 Game Vibes 裡已有一款遊戲的名稱來繼續處理它。agent 會把它複製到 `~/Games/vibes`，在那裡它就歸你修改，完成時會開啟它。你也可以自己用 `omarchy games vibes copy <game>` 進行這份複製。別人分享的遊戲安裝方式跟主題一樣：選擇 _Install > Gaming > Game Vibes_ 並貼上它的 git 位址，或執行 `omarchy games vibes install <git-repo-url>`。_Remove > Gaming_ 可以再次移除一款遊戲，_Update > Game Vibes Games_ 則會取得新版本。遊戲會從網路載入 three.js，所以啟動時需要網路連線。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家簡單到不行的計算機，會在浮動視窗中開啟。

你用 `Super + Shift + Q` 啟動 Omacalc（如果你的鍵盤有計算機鍵，也可以用那個鍵）。

## Signal

[Signal](https://signal.org/) 是 E2E 加密通訊的先驅，對於不想透過大型科技集團的人來說，是一個很棒的通訊選擇。

你用 `Super + Shift + G` 啟動 Signal。它不在基本安裝裡，所以你第一次按下這個組合時，Omarchy 會提供為你安裝它（它也位於 Omarchy 選單的 _Install > Service_ 裡）。

## Omaview

[Omaview](https://github.com/omacom/omaview) 是 Omarchy 自家簡單到不行的圖片檢視器和媒體播放器：一個視窗就能看你的照片、影片和音樂。開啟一張照片後，方向鍵會依序瀏覽同一個資料夾裡的其他照片，`N` 和 `P` 對任何內容都能這樣做，`Ctrl + M` 則會把整個資料夾顯示成格狀檢視。它也能顯示 HEIC、AVIF 和 JPEG XL 照片，還能從你上次中斷的地方繼續播放任何較長的內容。

按下 `F` 全螢幕，`E` 在 Omasnap 裡編輯圖片或在 Omacut 裡修剪影片，`Ctrl + P` 列印圖片，`Delete` 把檔案移到垃圾桶（`Ctrl + Z` 把它復原）。在裡面按下 `?` 就能看到所有快捷鍵。

你透過應用程式啟動器（`Super + Space`）以 _Media Viewer_ 的名稱啟動 Omaview，或直接在檔案管理器裡雙擊圖片、影片或歌曲。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家簡單到不行的影片修剪工具。當你只需要剪掉一段影片的開頭和結尾時，它比啟動一套完整的影片編輯器好用多了。

你透過應用程式啟動器（`Super + Space`）啟動 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家簡單到不行的網路攝影機錄影工具。選擇你的攝影機和麥克風一次，然後按 `Space` 錄影，再按一次暫停並繼續同一次拍攝。它一律以你的攝影機最高解析度錄影，並有即時麥克風音量表，讓你在開始前檢查音量。

停止拍攝後，它會立刻在內建編輯器裡開啟。雙擊一段片段來分割它，拖曳把手修剪每一小段，並移除你不要的部分。然後把它儲存成 MP4。在你捨棄原始錄影之前，它會一直保留，所以你隨時可以回來用不同的方式剪輯。

你透過應用程式啟動器（`Super + Space`）啟動 Monologue。
