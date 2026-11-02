# 從 Mac 或 Windows 轉過來

如果你多年來都用 macOS 或 Windows，你的手指記得上百件大腦早已忘記自己學過的事。本章就是翻譯層：那些直覺到了 Omarchy 該往哪裡去。功能本身在其他章節有深入說明——這裡只是地圖。

### Super 是所有事的核心

你圍繞 Cmd 或 Windows 鍵建立的所有肌肉記憶，都轉移到一個按鍵：Super。那就是 PC 鍵盤上的 Windows 鍵，也是 Omarchy 幾乎所有快捷鍵的錨點。

你的 Spotlight、Raycast 或開始功能表反射動作，會變成 `Super + Space`。那會打開 Omarchy 選單，可用來啟動應用程式、更改設定、安裝軟體、擷取螢幕——幾乎所有事。開始輸入即可篩選。`Super + Alt + Space` 會將所有應用程式顯示在一個格狀畫面，就像 Launchpad 一樣。請參閱 [導覽](04-navigation.md)。

### 沒有 Dock，也沒有桌面圖示

沒有東西可以點來啟動程式，也沒有圖示可以排在桌面上。應用程式靠快捷鍵啟動（`Super + Return` 開終端機、`Super + Shift + Return` 開瀏覽器、`Super + K` 查看所有已對應的快捷鍵清單），或是從選單啟動。唯一常駐的 UI 元素是[頂部列](05-the-top-bar.md)，它涵蓋了以前選單列、系統匣和通知中心為你做的事——而且上面幾乎每個小工具，左鍵、右鍵和中鍵點擊都有作用。

### 視窗會自己就定位

最大的心態轉變：你不用拖曳視窗，也不用把視窗貼齊到螢幕的一半。打開一個視窗，它就佔滿整個螢幕。打開第二個，它們就對分螢幕。你永遠不必從另一個視窗底下把視窗撈出來，因為視窗不會重疊。

當你真的需要浮動視窗時，`Super + T` 會將目前視窗切換出平鋪模式（再按一次切回來）。但先給平鋪模式一個真正的機會——它是整套系統的核心。[導覽](04-navigation.md) 會帶你走一遍。

工作區會讓你感覺熟悉：它們就像 macOS 的 Spaces 或 Windows 的虛擬桌面，差別在於你真的會去用它們，因為 `Super + 1/2/3/4` 會直接跳到某個工作區，而 `Super + Shift + 1/2/3/4` 會把目前視窗送過去。沒有動畫延遲，只有瞬間跳轉。這代表如果你以前習慣用多螢幕，現在你甚至可能不再需要多螢幕了。

### 複製貼上就是能用

在 Mac 上你到處都用 Cmd + C。在 Windows 上你到處都用 Ctrl + C——除了終端機，在那裡它會殺掉你的程式。Omarchy 給你 `Super + C`、`Super + X` 和 `Super + V`，而且到處都能用，包括終端機。Shell 不需要再學一套獨立的反射動作。

Windows 用戶：你的 Win + V 剪貼簿歷史記錄在 `Super + Ctrl + V` 上，而且它不只能存文字，還能存圖片。請參閱[統一剪貼簿與歷史記錄](08-unified-clipboard-history.md)。

### 翻譯表

| 你想用的是 | 在 Omarchy 裡 |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy 選單 |
| AirDrop | LocalSend，透過 `Super + Ctrl + S` — 請參閱 [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` 或 `Print Screen` — 請參閱[截圖與錄影](12-screenshots-recording.md) |
| Notification Center | 通知歷史記錄在 `Super + Shift + Alt + ,` |
| Time Machine（系統用） | 每次更新時自動建立[系統快照](47-system-snapshots.md) |
| App Store / 下載安裝程式 | 選單裡的 _Install_，或 `omarchy pkg add` — 請參閱[其他套件](29-other-packages.md) |
| System Settings / Control Panel | 選單裡的 _Setup_，它會編輯純文字設定檔 — 請參閱 [dotfiles](31-dotfiles.md) |

### 有些事真的不一樣

許多設定存放在你要編輯的文字檔裡，而不是要你一頁頁點的面板。聽起來很原始，直到你意識到這代表每一個調整都看得見、可以複製到你的下一台機器，還能納入版本控制。_Setup_ 選單會直接把你送到正確的檔案，你完成後它會重新啟動任何需要重新啟動的東西。

更新透過一個命令而來——_Update > Omarchy_——它會更新 Omarchy 本身和系統上的每一個套件，並先建立快照。不會有各個應用程式的更新程式在隨機時間煩你。請參閱[更新](30-updates.md)。

軟體來自套件管理器，而不是下載來的安裝程式。

而且當你關閉一個視窗時，應用程式就真的退出了。沒有 macOS 那種程式沒有視窗卻還在運行的懸置狀態。`Super + W`——或是 `Super + Q`，如果你帶來的手指記憶是那個——就代表消失。

### 在 Mac 硬體上

Omarchy 在 Intel Mac 上運行良好——請參閱 [Mac 支援](44-mac-support.md)。而且鍵盤對你很友善：Omarchy 不會重新對應任何東西，而 Linux 會把 Command 鍵視為 Super，所以 Super 就在 Cmd 一直所在的位置。你的拇指不會注意到這次搬家。

### 給它兩週

這些直覺轉移得比你想像的還快。把[快捷鍵](07-hotkeys.md)章節瀏覽一次，之後每當你想不起一個綁定時，就按 `Super + K`——它會把所有綁定都顯示給你。那是你唯一真正需要背起來的快捷鍵。
