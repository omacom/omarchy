# 從 Mac 或 Windows 轉過來

如果你多年來都用 macOS 或 Windows，你的手指知道上百件大腦早已忘記自己學過的事。本章就是那層對照：這些直覺在 Omarchy 裡對應到哪裡。功能本身在其他章節有深入說明——這裡只是地圖。

### Super 是一切的核心

你圍繞 Cmd 或 Windows 鍵建立的所有肌肉記憶，都轉移到一個鍵上：Super。那就是 PC 鍵盤上的 Windows 鍵，也是 Omarchy 裡幾乎每個熱鍵的錨點。

你對 Spotlight、Raycast 或開始選單的反射動作，變成了 `Super + Space`。這會開啟 Omarchy 選單，它能啟動應用程式、更改設定、安裝軟體、擷取螢幕——幾乎什麼都能做。開始輸入即可篩選。`Super + Alt + Space` 會像 Launchpad 那樣，把每個應用程式顯示在一個格狀畫面上。請見[導覽](04-navigation.md)。

### 沒有桌面圖示，Dock 只在你浮動時才會出現

桌面上沒有要排列的圖示，平鋪工作區上也沒有 Dock——Dock 只會出現在浮動工作區上（請見[導覽](04-navigation.md)）。應用程式從熱鍵啟動（`Super + Return` 開啟終端機、`Super + Shift + Return` 開啟瀏覽器，`Super + K` 則列出所有已對應的功能），或從選單啟動。唯一常駐的介面元素是[頂部列](05-the-top-bar.md)，它涵蓋了以前選單列、系統匣和 Notification Center 為你做的事——而且它上面幾乎每個小工具，左鍵、右鍵和中鍵點擊都會有作用。

### 視窗會自己就定位

最大的心態轉變是：你不用拖曳視窗，也不用把它們吸附到螢幕的一半。開啟一個視窗，它就佔滿整個螢幕。再開啟第二個，它們就平分螢幕。你永遠不用從另一個視窗底下把視窗撈出來，因為視窗不會重疊。

當你真的需要浮動視窗時，`Super + T` 會把目前的視窗切換出平鋪模式（也能切換回來）。但先給平鋪模式一個真正的機會——它是整個系統的核心。[導覽](04-navigation.md)會帶你走一遍。

工作區會讓你覺得熟悉：它們就是 macOS 的 Spaces 或 Windows 的虛擬桌面，只是你真的會用它們，因為 `Super + 1/2/3/4` 會直接跳到某個工作區，`Super + Shift + 1/2/3/4` 會把目前的視窗送到那裡。沒有動畫延遲，只有即時跳轉。這表示如果你以前習慣用多台螢幕，現在你甚至可能不再需要多台螢幕了。

### 複製和貼上就是能用

在 Mac 上，你到處用 Cmd + C。在 Windows 上，你到處用 Ctrl + C——除了終端機，在那裡它會終止你的程式。Omarchy 給你 `Super + C`、`Super + X` 和 `Super + V`，而且它們到處都能用，包括終端機。你不用為 shell 再學一套單獨的反射動作。

Windows 的朋友：你的 Win + V 剪貼簿歷史記錄現在在 `Super + Ctrl + V`，而且它除了文字，也能保存圖片。請見[統一的剪貼簿與歷史記錄](08-unified-clipboard-history.md)。

### 對照表

| 你習慣找的 | 在 Omarchy 裡 |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy 選單 |
| AirDrop | LocalSend，透過 `Super + Ctrl + S` — 請見 [圖形介面](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` 或 `Print Screen` — 請見 [螢幕截圖與錄影](12-screenshots-recording.md) |
| Notification Center | 通知歷史記錄在 `Super + Shift + Alt + ,` |
| Time Machine（系統用的） | 每次更新時自動建立[系統快照](47-system-snapshots.md) |
| App Store / 下載安裝程式 | 選單中的 _Install_，或 `omarchy pkg add` — 請見 [其他套件](29-other-packages.md) |
| System Settings / Control Panel | 選單中的 _Setup_，它會編輯純文字設定檔 — 請見 [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files，在 `Super + Shift + F` — 請見 [圖形介面](22-guis.md) |
| Safari / Edge | Google Chrome，在 `Super + Shift + Return`；在 _Setup > Defaults > Browser_ 下選另一個 — 請見 [瀏覽器](23-browsers.md) |
| Preview / Photos | Omaview 用於圖片、影片和音樂，Document Viewer 用於 PDF — 請見 [圖形介面](22-guis.md) |
| TextEdit / Notepad | Plain，在 `Super + Shift + N`；在 _Setup > Defaults > Editor_ 下選另一個 |

### 有些東西真的不一樣

很多設定都放在你編輯的文字檔裡，而不是你點來點去的面板裡。這聽起來很原始，直到你意識到這表示每次調整都能被看見、複製到你的下一台機器，並納入版本控制。_Setup_ 選單會直接把你帶到正確的檔案，並在你完成後重新啟動任何需要重新啟動的東西。

更新透過一個命令而來——_Update > Omarchy_——它會更新 Omarchy 本身和系統上的每個套件，並先建立快照。不會有各個應用程式的更新程式隨機煩你。請見[更新](30-updates.md)。

軟體來自套件管理器，而不是下載的安裝程式。

而且當你關閉視窗時，應用程式真的會結束。不存在 macOS 那種程式沒有視窗卻還繼續執行的懸置狀態。`Super + W`——或者 `Super + Q`，如果你帶來的手指記憶是那個——就表示消失了。

### 在 Mac 硬體上

Omarchy 在 Intel Mac 上執行得很好——請見 [Mac 支援](44-mac-support.md)。而且鍵盤對你很友善：Omarchy 不會重新對應任何按鍵，Linux 會把 Command 鍵當作 Super，所以 Super 就在 Cmd 一直所在的位置。你的拇指不會察覺這次搬家。

### 給它兩週

這些直覺轉移得比你想像的快。把[熱鍵](07-hotkeys.md)這一章快速看一遍，每當你想不起某個綁定時，按 `Super + K`——它會把全部顯示給你。那是唯一真正需要背下來的熱鍵。
