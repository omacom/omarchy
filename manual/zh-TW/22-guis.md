# 圖形介面

## Files

Files (Folio) 是圖形化檔案管理程式。`Super + Shift + F` 可開啟它，`Super + Shift + Alt + F` 則會在你終端機目前所在的目錄開啟它，省下大量點按。`Ctrl + L` 讓你輸入路徑，在任何檔案上按 `Space` 就能以全尺寸預覽，不必開啟它。

插入 USB 隨身碟或 SD 卡後會自動掛載，所以會直接出現在側邊欄。若要做更進階的事——格式化磁碟、檢查 SMART 健康狀態、建立分割區——請從應用程式啟動器（`Super + Space`）啟動 _Disks_。

雙擊會遵循合理的預設：圖片、影片和音樂會在 Omaview 中開啟，PDF 會在 Document Viewer 中開啟，Markdown 會在 Omawrite 中開啟，純文字則會在你的編輯器中開啟，預設是 Plain，除非你在 _Setup > Defaults > Editor_ 下另選一個。

## Disktree

當磁碟滿了，而你完全不知道是什麼在吃空間時，請從應用程式啟動器（`Super + Space`）啟動 [Disktree](https://github.com/tobi/disktree)。它會顯示你家目錄的圖形化樹狀圖。較大的區塊佔用更多空間；用鍵盤或滑鼠走進目錄，標記要移除的項目，並在刪除任何東西之前先檢查你的選擇。執行 `disktree --disk` 可掃描整個磁碟。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免費且高度可擴充的筆記應用程式，使用簡單的 Markdown 檔案儲存。

Obsidian 可免費供所有用途使用，包括個人、商業和非營利用途。

Obsidian 也提供[用於同步的商業附加功能](https://obsidian.md/sync)，可搭配 iOS 和 Android 上的行動應用程式。(https://obsidian.md/pricing)。

使用 `Super + Shift + O` 啟動 Obsidian。若要使用主題同步，你必須在設定下選取 `Omarchy` 主題。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家極其簡單的 Markdown 寫作應用程式。沒有筆記庫，沒有外掛，只有你和文字。

使用 `Super + Shift + W` 啟動 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基本的圖片編輯工具，非常適合裁剪、調整大小和其他基本操作。只是別指望它是 Photoshop 的替代品。但它還是有魔術棒和圖層！

透過應用程式啟動器（`Super + Space`）啟動 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主題應用程式，可以從背景圖片萃取顏色，並將它們轉成完整且一致的主題。這是[打造你自己的主題](43-making-your-own-theme.md)最簡單的方式。

透過應用程式啟動器（`Super + Space`）啟動 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 讓你將檔案傳送到同一網路上執行該應用程式的其他裝置，就像 Apple 的 AirDrop 一樣。不過它是跨平台的，所以你可以與 Windows、macOS、Android、iOS，當然還有 Linux 互相傳送檔案。

你可以用 `Super + Ctrl + S` 開啟 Share 選單，或在 Omarchy 選單的 _Trigger > Share_ 下開啟。它提供四個選項：

- **Clipboard** 會將你複製的任何內容以文字檔傳送。非常適合把連結或程式碼片段傳到手機上，不必寄電子郵件給自己。
- **File** 會開啟檔案選擇器，你可以一次選取多個檔案。
- **Folder** 會傳送整個目錄。
- **Receive** 會開啟 LocalSend 本體，讓其他裝置可以傳送東西給你。

從終端機也能做同樣的事，使用 `omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]`。省略路徑，就會開啟選擇器。

你也可以直接從檔案管理程式傳送：在 Files 中對任何選取項目按右鍵，並用 LocalSend 分享它。

Omarchy 的防火牆預設為關閉，僅 LocalSend 的連接埠除外，所以在全新安裝後開箱即可用。參見[安全性](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一套完整的辦公室套件，包含文書處理器、試算表、簡報、繪圖應用程式等。它與 Microsoft Office 的檔案相容，所以這是開啟那些 Word 文件的好方法。

透過應用程式啟動器（`Super + Space`）啟動 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家極其簡單的簡報應用程式。你的簡報是一個單一 Markdown 檔案，其圖片和影片放在旁邊：在即時預覽下方撰寫每一張投影片，將投影片拖曳排序，然後全螢幕簡報，或匯出為 PDF 和 PowerPoint。它甚至會採用你的 Omarchy 主題。

透過應用程式啟動器（`Super + Space`）啟動 Hype。在其中按 `?` 可查看每個快捷鍵。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家極其簡單的 PDF 簽署和填寫方式。將你儲存的簽名、文字和今天的日期放在頁面上的任何位置，然後在原始檔案旁儲存一份已簽署的副本。如何操作請參見[填寫 PDF](27-filling-out-pdfs.md)。

透過應用程式啟動器（`Super + Space`）啟動 Signed，或從檔案管理程式用它開啟 PDF。

## Game Vibes

Game Vibes 位於應用程式啟動器（`Super + Space`）中，是 Omarchy 小遊戲所在之處：Checkmate，一款與朋友或內建對手對戰的 3D 西洋棋遊戲；Cards，Klondike 接龍；Death Wish，一款像素級精準、十個房間滿是尖刺和鋸子的平台遊戲；以及 Neon Swarm，一款街機射擊遊戲。每一個都是一個會遵循你主題的單一網頁。用方向鍵和 `Enter` 選取一個，並在遊戲的標題畫面按 `Esc`，或在暫停時按 `Q` 回到清單。它會以全螢幕開啟：`Super + F` 可將它變成視窗，`Super + W` 可關閉它。

你用 agent 製作的遊戲也會出現在這裡：在 agents 面板中選擇 _Make something cool → Game_ 並描述一個，或指出 Game Vibes 中已有的遊戲以繼續製作它。agent 會將它複製到 `~/Games/vibes`，在那裡你可以隨意更改，並在完成時開啟它。你也可以用 `omarchy games vibes copy <game>` 自行複製。一款別人分享的遊戲，安裝方式就像主題一樣：選擇 _Install > Gaming > Game Vibes_ 並貼上它的 git 地址，或執行 `omarchy games vibes install <git-repo-url>`。_Remove > Gaming_ 可再次將它移除，_Update > Game Vibes Games_ 可取得新版本。遊戲會從網路載入 three.js，所以啟動時需要連線。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家極其簡單的計算機，會在浮動視窗中開啟。

使用 `Super + Shift + Q` 啟動 Omacalc（如果你的鍵盤有計算機鍵，也可以用該鍵）。

## Signal

[Signal](https://signal.org/) 是 E2E 加密訊息的先驅，對於任何不想透過大型科技集團的人來說，都是一個很棒的通訊選擇。

使用 `Super + Shift + G` 啟動 Signal。它不包含在基本安裝中，所以你第一次按下該快捷鍵時，Omarchy 會提供為你安裝它（它也位於 Omarchy 選單的 _Install > Service_ 下）。

## Omaview

[Omaview](https://github.com/omacom/omaview) 是 Omarchy 自家極其簡單的圖片檢視器和媒體播放器：一個視窗就能看你的照片、影片和音樂。開啟一張照片後，方向鍵可依序瀏覽同一資料夾的其餘照片，`N` 和 `P` 對任何內容都能這樣做，`Ctrl + M` 會將整個資料夾顯示為格狀檢視。它也能顯示 HEIC、AVIF 和 JPEG XL 照片，並能在任何較長的內容中從你上次離開的地方繼續。

按 `F` 全螢幕，`E` 在 Omasnap 中編輯圖片或在 Omacut 中修剪影片，`Ctrl + P` 列印圖片，`Delete` 將檔案移到垃圾桶（`Ctrl + Z` 可將它帶回來）。在其中按 `?` 可查看每個快捷鍵。

透過應用程式啟動器（`Super + Space`）以 _Media Viewer_ 啟動 Omaview，或直接在檔案管理程式中雙擊圖片、影片或歌曲。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家極其簡單的影片修剪工具。當你只需要剪掉片段的開頭和結尾時，它比啟動完整的影片編輯器好用多了。

透過應用程式啟動器（`Super + Space`）啟動 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家極其簡單的網路攝影機錄影工具。選一次你的攝影機和麥克風，然後按 `Space` 錄影，再按一次暫停並繼續同一段錄影。它永遠以你攝影機的最高解析度錄影，並有即時麥克風音量表，讓你在開始前檢查音量。

停止錄影後，它會立即在內建編輯器中開啟。雙擊片段可將它分割，拖曳控制點可修剪每一段，並移除你不要的部分。然後將它儲存為 MP4。你的原始錄影會保留，直到你捨棄它為止，所以你隨時可以回來以不同的方式剪輯。

透過應用程式啟動器（`Super + Space`）啟動 Monologue。
