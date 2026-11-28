# 從 Mac 或 Windows 過來

如果你在 macOS 或 Windows 上用了很多年，你的手指會記得一百件你的大腦早已忘記自己學過的事。這一章就是翻譯層：在 Omarchy 裡，那些直覺該往哪裡去。各項功能本身在其他章節有深入說明——這裡只是地圖。

### Super 是一切的中心

你圍繞 Cmd 或 Windows 鍵建立的所有肌肉記憶，都會轉移到一個按鍵上：Super。那就是 PC 鍵盤上的 Windows 鍵，也是 Omarchy 裡幾乎所有快捷鍵的錨點。

你使用 Spotlight、Raycast 或開始功能表的反射動作，會變成 `Super + Space`。這會開啟 Omarchy 選單，它可以啟動應用程式、更改設定、安裝軟體、擷取螢幕——幾乎什麼都能做。開始輸入即可篩選。`Super + Alt + Space` 會將每個應用程式顯示在一個格狀畫面中，就像 Launchpad 那樣。請參閱 [導覽](04-navigation.md)。

### 沒有桌面圖示，dock 也會乖乖退開

桌面上沒有要排列的圖示，一旦某個工作區有了視窗，dock 就會隱藏起來，直到你把指標推到它所在的那一側螢幕邊緣為止，預設是底部，除非你把它移動位置（請參閱 [導覽](04-navigation.md)）。應用程式可以透過快捷鍵啟動（`Super + Return` 開啟終端機，`Super + Shift + Return` 開啟瀏覽器，`Super + K` 則顯示所有已對應的功能清單），也可以從選單啟動。唯一持續存在的 UI 元件是 [頂部列](05-the-top-bar.md)，它涵蓋了以前選單列、系統匣和 Notification Center 為你做的事情——而且它上面的幾乎每個小工具，都能透過左鍵、右鍵和中鍵點擊來執行某些操作。

### 視窗會自己安排位置

最大的心態轉變是：你不需要把視窗拖來拖去，也不需要把它們貼齊到螢幕的左半邊或右半邊。開啟一個視窗，它會佔滿整個螢幕。再開啟第二個，它們就會分割螢幕。你永遠不必從另一個視窗底下把某個視窗撈出來，因為視窗不會重疊。

當你真的需要浮動視窗時，`Super + T` 可以將目前使用的視窗切換出平鋪模式（也可以切換回來）。但請先認真給平鋪模式一個機會——它是整套系統的核心。[導覽](04-navigation.md) 會帶你走一遍。

工作區會讓你覺得很熟悉：它們就像 macOS Spaces 或 Windows 虛擬桌面，只不過你真的會去用它們，因為 `Super + 1/2/3/4` 可以直接跳到某個工作區，`Super + Shift + 1/2/3/4` 則會把目前使用的視窗送到那裡。沒有動畫延遲，只有即時跳轉。這表示如果你以前習慣使用多個螢幕，你現在甚至可能不再需要它們了。

### 複製和貼上就是能正常運作

在 Mac 上，你到處都能使用 Cmd + C。在 Windows 上，你到處都能使用 Ctrl + C——除了終端機，在那裡它會終止你的程式。Omarchy 提供 `Super + C`、`Super + X` 和 `Super + V`，它們到處都能運作，包括終端機。你不需要為了 shell 再學一套獨立的反射動作。

Windows 的朋友們：你們的 Win + V 剪貼簿紀錄現在位於 `Super + Ctrl + V`，它除了文字之外也能保存圖片。請參閱 [統一的剪貼簿與紀錄](08-unified-clipboard-history.md)。

### 對照表

| 你下意識會找的 | 在 Omarchy 裡 |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy 選單 |
| AirDrop | LocalSend，透過 `Super + Ctrl + S` — 請參閱 [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` 或 `Print Screen` — 請參閱 [截圖與錄影](12-screenshots-recording.md) |
| Notification Center | 通知紀錄，透過 `Super + Shift + Alt + ,` |
| Time Machine（用於系統） | 每次更新時自動建立 [系統快照](47-system-snapshots.md) |
| App Store / 下載安裝程式 | 選單中的 _Install_，或 `omarchy pkg add` — 請參閱 [其他套件](29-other-packages.md) |
| System Settings / Control Panel | 選單中的 _Setup_，它會編輯純文字設定檔 — 請參閱 [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files，透過 `Super + Shift + F` 開啟 — 請參閱 [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome，透過 `Super + Shift + Return` 開啟；在 _Setup > Defaults > Browser_ 下選另一個 — 請參閱 [瀏覽器](23-browsers.md) |
| Preview / Photos | Omaview 用於圖片、影片和音樂，Document Viewer 用於 PDFs — 請參閱 [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain，透過 `Super + Shift + N` 開啟；在 _Setup > Defaults > Editor_ 下選另一個 |

### 有些事情確實不一樣

很多設定都存放在由你編輯的文字檔裡，而不是讓你點來點去的面板裡。這聽起來很原始，直到你意識到這表示每一項調整都能被看見、複製到你的下一台機器上，並且納入版本控制。_Setup_ 選單會把你直接帶到正確的檔案，並在你完成後重新啟動任何需要重新啟動的東西。

更新透過一個命令完成——_Update > Omarchy_——它會更新 Omarchy 本身以及系統上的每個套件，而且會先建立一個快照。不會有各個應用程式的更新程式在隨機的時間煩你。請參閱 [更新](30-updates.md)。

軟體來自套件管理器，而不是從下載的安裝程式而來。

而且當你關閉一個視窗時，該應用程式真的會結束。它沒有 macOS 那種程式在沒有任何視窗的情況下還持續運作的模糊地帶。`Super + W`——或者 `Super + Q`，如果你帶著這樣的手指記憶過來的話——就表示它消失了。

### 在 Mac 硬體上

Omarchy 在 Intel Macs 上運作得很好，也能透過 Omarchy for Apple Silicon 在 M1、M2 和 M3 Macs 上運作。請參閱 [Mac 支援](44-mac-support.md)。而且鍵盤對你很友善：Omarchy 不會重新對應任何按鍵，Linux 會把 Command 鍵視為 Super，因此 Super 就正位在 Cmd 一直以來所在的位置。你的拇指不會注意到這次轉移。

### 給它兩週時間

這些直覺轉移的速度比你想像的還快。把 [快捷鍵](07-hotkeys.md) 這一章快速瀏覽一次，之後每當你突然想不起某個鍵位時，就按下 `Super + K`——它會把所有鍵位都顯示給你看。那是你真正需要記住的唯一一個快捷鍵。
