# 從 Mac 或 Windows 轉過來

如果你在 macOS 或 Windows 上用了好幾年，你的手指知道一百件你的大腦早就忘了自己學過的事。這一章就是翻譯層：這些直覺在 Omarchy 裡該往哪裡去。功能本身在其他地方有深入說明——這裡只是一張地圖。

### Super 是一切的中心

你圍繞 Cmd 或 Windows 鍵建立的所有肌肉記憶，都會轉移到一個鍵上：Super。那就是 PC 鍵盤上的 Windows 鍵，也是 Omarchy 裡幾乎每個快捷鍵的錨點。

你想按 Spotlight 或 Raycast 或開始功能表的反射動作，變成 `Super + Space`。那會打開 Omarchy 選單，它能啟動應用程式、變更設定、安裝軟體、擷取螢幕——幾乎什麼都能做。開始打字就能篩選。`Super + Alt + Space` 會在一張格狀畫面中顯示所有應用程式，就像 Launchpad 那樣。參見 [導覽](04-navigation.md)。

### 沒有桌面圖示，Dock 也不擋路

桌面上沒有要你排列的圖示，Dock 一旦某個工作區有了視窗就會隱藏，直到你把指標推到螢幕的那一邊邊緣，預設是右邊，除非你把它移走（參見 [導覽](04-navigation.md)）。應用程式從快捷鍵啟動（`Super + Return` 開終端機、`Super + Shift + Return` 開瀏覽器、`Super + K` 列出所有已對應的功能），也可以從選單啟動。唯一常駐的 UI 元件是[頂部列](05-the-top-bar.md)，它涵蓋了以前選單列、系統匣和通知中心為你做的事——而且上面幾乎每個小工具，左鍵、右鍵和中鍵點下去都會有動作。

### 視窗會自己就定位

最大的心態轉變是：你不用拖曳視窗，也不用把它們貼齊到螢幕的一半。打開一個視窗，它就佔滿整個螢幕。再打開第二個，它們就平分螢幕。你永遠不必從另一個視窗底下把視窗撈出來，因為視窗不會重疊。

當你真的需要浮動視窗時，`Super + T` 會把目前的視窗切出平鋪模式（也能切回去）。但先給平鋪模式一個真正的機會——它是整個系統的核心。[導覽](04-navigation.md) 會帶你走一遍。

工作區會感覺很熟悉：它們就是 macOS 的 Spaces 或 Windows 的虛擬桌面，差別只在於你真的會去用它們，因為 `Super + 1/2/3/4` 能直接跳到某一個，`Super + Shift + 1/2/3/4` 則把目前的視窗送過去。沒有動畫延遲，只有瞬間跳轉。這代表，如果你以前習慣用多螢幕，現在你甚至可能不再需要了。

### 複製和貼上就是能用

在 Mac 上，你到處都用 Cmd + C。在 Windows 上，你到處都用 Ctrl + C——除了終端機，在那裡它會殺掉你的程式。Omarchy 給你 `Super + C`、`Super + X` 和 `Super + V`，而且它們到處都能用，包括終端機。不必為了 shell 再學一套獨立的反射動作。

Windows 用戶：你的 Win + V 剪貼簿歷史現在在 `Super + Ctrl + V`，而且它除了文字也能存放圖片。參見 [統一剪貼簿與歷史紀錄](08-unified-clipboard-history.md)。

### 對照表

| 你下意識想找的 | 在 Omarchy 裡 |
| ------------- | ---------- |
| Spotlight / Raycast / 開始功能表 | `Super + Space` — Omarchy 選單 |
| AirDrop | LocalSend，透過 `Super + Ctrl + S` — 參見 [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` 或 `Print Screen` — 參見 [截圖與錄影](12-screenshots-recording.md) |
| Notification Center | 通知歷史，在 `Super + Shift + Alt + ,` |
| Time Machine（針對系統） | 每次更新時自動建立[系統快照](47-system-snapshots.md) |
| App Store / 下載安裝程式 | 選單中的 _Install_，或 `omarchy pkg add` — 參見 [其他套件](29-other-packages.md) |
| System Settings / Control Panel | 選單中的 _Setup_，它編輯的是純文字設定檔 — 參見 [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files，在 `Super + Shift + F` — 參見 [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome，在 `Super + Shift + Return`；在 _Setup > Defaults > Browser_ 底下挑另一個 — 參見 [瀏覽器](23-browsers.md) |
| Preview / Photos | Omaview 看圖片、影片和音樂，Document Viewer 看 PDF — 參見 [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain，在 `Super + Shift + N`；在 _Setup > Defaults > Editor_ 底下挑另一個 |

### 有些事情真的不一樣

很多設定活在你親手編輯的文字檔裡，而不是你一頁頁點過去的面板裡。這聽起來很原始，直到你意識到這代表每個調整都能被看見、能複製到你的下一台機器、也能納入版本控制。_Setup_ 選單會直接把你送進正確的檔案，等你改完，就重啟所有需要重啟的東西。

更新透過一個指令完成——_Update > Omarchy_——它會更新 Omarchy 本身和系統上的每個套件，而且會先建立快照。不會再有各個應用程式自帶的更新程式隨機冒出來煩你。參見 [更新](30-updates.md)。

軟體來自套件管理員，而不是下載來的安裝程式。

還有，當你關閉一個視窗，應用程式就真的退出了。不會有 macOS 那種程式沒有視窗卻還繼續運行的懸置狀態。`Super + W`——或者 `Super + Q`，如果你帶來的手指記憶是那個——就代表消失。

### 在 Mac 硬體上

Omarchy 在 Intel Mac 上運行得很好，在 M1、M2 和 M3 Mac 上也能透過 Omarchy for Apple Silicon 運行。參見 [Mac 支援](44-mac-support.md)。而且鍵盤對你很友善：Omarchy 不會重新對應任何按鍵，Linux 會把 Command 鍵當作 Super，所以 Super 就在 Cmd 一直以來所在的位置。你的拇指根本不會察覺這次搬家。

### 給它兩個星期

這些直覺轉移的速度比你想像的還快。把[快捷鍵](07-hotkeys.md)那一章快速看過一遍，之後每當你想不起某個按鍵綁定，就按 `Super + K`——它會把全部都顯示給你看。那是你唯一真正必須記住的快捷鍵。
