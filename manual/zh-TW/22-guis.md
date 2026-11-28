# 圖形介面

## Files

Files (Folio) 是圖形化檔案管理員。`Super + Shift + F` 可開啟它，`Super + Shift + Alt + F` 則會在你的終端機目前所在的目錄開啟它，能省下很多點擊。`Ctrl + L` 讓你輸入路徑，在任何檔案上按 `Space` 即可全尺寸預覽，不需要真的開啟它。

插入 USB 隨身碟或 SD 卡後，系統會自動掛載，所以它會直接出現在側邊欄。若要做更進階的事——格式化磁碟、檢查 SMART 健康狀態、建立分割區——請從應用程式啟動器 (`Super + Space`) 啟動 _Disks_。

加密磁碟在插入時會要求輸入其密碼。若要讓它自行解鎖，請用 `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` 將一個 keyfile 加入其中，並將該 keyfile 放在 `~/.config/omarchy/drive-keys/<UUID>`，以 `lsblk -dno UUID /dev/sdX1` 為該加密分割區印出的 UUID 命名，且僅限你本人可讀取 (`chmod 600`)。如果該 keyfile 遺失或遭拒，系統會照常要求你輸入密碼。

連按兩下開啟時會遵循合理的預設：圖片、影片和音樂以 Omaview 開啟，PDF 以 Document Viewer 開啟，Markdown 以 Omawrite 開啟，純文字則以你的編輯器開啟，若你未在 _Setup > Defaults > Editor_ 下另選其他編輯器，編輯器便是 Plain。

## Disktree

當磁碟塞滿、而你完全不知道是什麼在吃空間時，請從應用程式啟動器 (`Super + Space`) 啟動 [Disktree](https://github.com/tobi/disktree)。它會顯示你家目錄的圖形化 treemap。越大的區塊佔用越多空間；用鍵盤或滑鼠進入各個目錄，標記該刪除的內容，並在移除任何東西之前先檢查你的選取項目。執行 `disktree --disk` 可掃描整個磁碟。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免費且高度可擴充的筆記應用程式，使用簡單的 Markdown 檔案來儲存。

Obsidian 供所有用途免費使用，包括個人、商業和非營利用途。

Obsidian 也提供了一款 [用於同步的商業附加服務](https://obsidian.md/sync)，可與 iOS 和 Android 上的行動應用程式搭配使用。(https://obsidian.md/pricing)。

你可以用 `Super + Shift + O` 啟動 Obsidian。若要使用主題同步，你必須在設定下選取 `Omarchy` 主題。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家簡單到不行的 Markdown 寫作應用程式。沒有 vault、沒有外掛，只有你和文字。

你可以用 `Super + Shift + W` 啟動 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基本的圖片編輯工具，非常適合裁切、調整大小和其他基本操作。只是別指望它是 Photoshop 的替代品。但它還是有魔術棒和圖層！

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主題應用程式，可以從背景圖片擷取色彩，並將它們轉化為一套完整且協調的主題。這是[打造你自己的主題](43-making-your-own-theme.md)最簡單的方法。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 讓你能將檔案傳送到同一網路上執行該應用程式的其他裝置，就像 Apple 的 AirDrop 一樣。不過它是跨平台的，所以你可以與 Windows、macOS、Android、iOS，當然還有 Linux 之間互相傳送檔案。

你可以用 `Super + Ctrl + S` 開啟 Share 選單，或在 Omarchy 選單下從 _Trigger > Share_ 開啟。它提供四個選項：

- **Clipboard** 會將你複製的任何內容以文字檔傳送。很適合將連結或一段程式碼弄到手機上，不需要寄電子郵件給自己。
- **File** 會開啟檔案選擇器，讓你一次選取多個檔案。
- **Folder** 會傳送整個目錄。
- **Receive** 會開啟 LocalSend 本體，讓另一台裝置能傳送東西給你。

同樣的事也能從終端機完成，指令是 `omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]`。省略路徑，就會出現選擇器。

你也可以直接從檔案管理員傳送：在 Files 中對任何選取項目按右鍵，並用 LocalSend 分享它。

Omarchy 的防火牆預設為關閉，僅開放 LocalSend 的連接埠，所以這在全新安裝時即可直接運作。請參閱[安全性](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一套完整的辦公室軟體包，包含文書處理、試算表、簡報、繪圖應用程式等更多功能。它與 Microsoft Office 的檔案相容，所以這是開啟那些 Word 文件的好方法。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家簡單到不行的簡報應用程式。你的簡報就是單一 Markdown 檔案，圖片和影片放在旁邊：在即時預覽下方撰寫每張投影片，將投影片拖曳排序，然後全螢幕簡報，或匯出為 PDF 和 PowerPoint。它甚至會套用你的 Omarchy 主題。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Hype。在其中按 `?` 可查看每個快捷鍵。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家簡單到不行的 PDF 簽署和填寫方式。將你儲存的簽名、文字和今天的日期放在頁面上的任何位置，然後將簽署後的副本儲存在原始檔案旁邊。請參閱[填寫 PDF](27-filling-out-pdfs.md)了解如何操作。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Signed，或從檔案管理員以它開啟 PDF。

## Game Vibes

Game Vibes 位於應用程式啟動器 (`Super + Space`) 中，是 Omarchy 小遊戲所在之處：Checkmate，一款可與朋友或內建對手對弈的 3D 西洋棋遊戲；Cards，Klondike 接龍；Death Wish，一款有十個房間、滿是尖刺和鋸子的像素精準平台遊戲；以及 Neon Swarm，一款街機射擊遊戲。每款都是一個會跟隨你主題的單一網頁。用方向鍵和 `Enter` 挑選一款，從遊戲的標題畫面按 `Esc`，或在暫停時按 `Q`，即可回到列表。它會以全螢幕開啟：`Super + F` 可將它變成視窗，`Super + W` 則可關閉它。

你用 agent 製作的遊戲也會出現在這裡：在 agents 面板中選擇 _Make something cool → Game_ 並描述一款遊戲，或說出 Game Vibes 中已有的遊戲名稱以繼續開發它。agent 會將它複製到 `~/Games/vibes`，在那裡它歸你任意修改，完成時便會開啟它。你可以用 `omarchy games vibes copy <game>` 自己複製這份副本。別人分享的遊戲安裝方式就像主題一樣：選擇 _Install > Gaming > Game Vibes_ 並貼上它的 git 位址，或執行 `omarchy games vibes install <git-repo-url>`。_Remove > Gaming_ 可以再次將一款遊戲移除，_Update > Game Vibes Games_ 則會取得新版本。遊戲會從網路載入 three.js，所以啟動時需要連線。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家簡單到不行的計算機，會在浮動視窗中開啟。

你可以用 `Super + Shift + Q` 啟動 Omacalc (或者如果你的鍵盤有計算機鍵，也可以用該鍵)。

## Signal

[Signal](https://signal.org/) 是 E2E 加密通訊的先驅，對於任何不想透過大型科技集團的人來說，都是一個很棒的通訊選擇。

你可以用 `Super + Shift + G` 啟動 Signal。它不在基本安裝之中，所以你第一次按下該快捷鍵時，Omarchy 會提供為你安裝它 (它也位於 Omarchy 選單的 _Install > Service_ 下)。

## Omaview

[Omaview](https://github.com/omacom/omaview) 是 Omarchy 自家簡單到不行的圖片檢視器和媒體播放器：用一個視窗處理你的照片、影片和音樂。開啟一張照片後，方向鍵會依序瀏覽同一資料夾的其餘內容，`N` 和 `P` 對任何內容都有同樣作用，`Ctrl + M` 則會將整個資料夾以格狀顯示。它也能顯示 HEIC、AVIF 和 JPEG XL 照片，並且任何較長的內容都能從你上次離開的地方繼續。

按 `F` 全螢幕，按 `E` 在 Omasnap 中編輯圖片或在 Omacut 中修剪影片，按 `Ctrl + P` 列印圖片，按 `Delete` 將檔案移到 Trash (`Ctrl + Z` 可將它帶回來)。在其中按 `?` 可查看每個快捷鍵。

你可以透過應用程式啟動器 (`Super + Space`) 以 _Media Viewer_ 啟動 Omaview，或直接在檔案管理員中連按兩下圖片、影片或歌曲。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家簡單到不行的影片修剪工具。當你需要的只是剪掉片段的開頭和結尾時，它勝過開啟一整套影片編輯器。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家簡單到不行的網路攝影機錄影工具。只需選擇一次相機和麥克風，然後按 `Space` 錄影，再按一次即可暫停並繼續同一段錄製。它始終以相機的最高解析度錄製，並有即時麥克風音量表，讓你在開始前檢查音量。

停止錄製後，它會立即在內建編輯器中開啟。連按兩下一個片段可將它分割，拖曳把手修剪每一段，並移除你不要的部分。然後將它儲存為 MP4。你的原始錄影會保留到你丟棄它為止，所以你隨時可以回來以不同的方式剪輯。

你可以透過應用程式啟動器 (`Super + Space`) 啟動 Monologue。
