# 從 Mac 或 Windows 轉換過來

如果你在 macOS 或 Windows 上用了多年，你的手指知道一百件你的大腦早已忘記自己學過的事。本章就是那層翻譯：那些本能在 Omarchy 裡會去到哪裡。功能本身在其他地方有深入說明——這裡只是地圖。

### Super 是一切的核心

你圍繞 Cmd 或 Windows 鍵建立的所有肌肉記憶，都轉移到一個鍵上：Super。那就是 PC 鍵盤上的 Windows 鍵，也是 Omarchy 裡幾乎每個快捷鍵的錨點。

你對 Spotlight、Raycast 或開始選單的反射動作，會變成 `Super + Space`。那會開啟 Omarchy 選單，它能啟動應用程式、變更設定、安裝軟體、擷取螢幕——幾乎什麼都能做。開始打字就能篩選。`Super + Alt + Space` 會把每個應用程式顯示在一個格狀畫面上，就像 Launchpad 那樣。請參閱[導覽](04-navigation.md)。

### 沒有桌面圖示，dock 只在你浮動時出現

沒有圖示要你在桌面上排列，平鋪工作區上也沒有 dock——dock 只會出現在浮動工作區上（請參閱[導覽](04-navigation.md)）。應用程式從快捷鍵啟動（終端機用 `Super + Return`，瀏覽器用 `Super + Shift + Return`，而 `Super + K` 則列出所有已對應的項目），或是從選單啟動。唯一常駐的 UI 元件是[頂部列](05-the-top-bar.md)，它涵蓋了以前選單列、系統匣和通知中心為你做的事——而且它上面的每個小工具幾乎都能在左鍵、右鍵和中鍵點擊時做點什麼。

### 視窗會自己就定位

最大的心態轉變是：你不用拖曳視窗，也不用把它們吸附到螢幕的一半。打開一個視窗，它就佔滿整個螢幕。再打開第二個，它們就會分割螢幕。你永遠不必從另一個視窗底下把視窗撈出來，因為視窗不會重疊。

當你真的需要一個浮動視窗時，`Super + T` 會把目前的視窗切換出平鋪模式（也能切換回去）。但先給平鋪模式一個真正的機會——它是整件事的核心。[導覽](04-navigation.md)會帶你走一遍。

工作區會讓你覺得熟悉：它們就是 macOS 的 Spaces 或 Windows 的虛擬桌面，只不過你真的會去用它們，因為 `Super + 1/2/3/4` 會直接跳到其中一個，而 `Super + Shift + 1/2/3/4` 會把目前的視窗送過去。沒有動畫延遲，只有即時跳轉。這意味著，如果你以前習慣用多個螢幕，你現在可能甚至不需要了。

### 複製貼上就是能用

在 Mac 上，你到處都有 Cmd + C。在 Windows 上，你到處都有 Ctrl + C——除了終端機以外，在那裡它會終止你的程式。Omarchy 給你 `Super + C`、`Super + X` 和 `Super + V`，而且它們到處都能用，包括終端機。你不需要為 shell 另外學一套反射動作。

Windows 的朋友們：你們的 Win + V 剪貼簿歷史記錄就在 `Super + Ctrl + V` 上，而且它除了文字之外也能保存圖片。請參閱[統一剪貼簿與歷史記錄](08-unified-clipboard-history.md)。

### 對照表

| 你習慣找的 | 在 Omarchy 裡 |
| ------------- | ---------- |
| Spotlight / Raycast / 開始選單 | `Super + Space`——Omarchy 選單 |
| AirDrop | LocalSend，透過 `Super + Ctrl + S`——請參閱 [GUI 程式](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` 或 `Print Screen`——請參閱[截圖與錄影](12-screenshots-recording.md) |
| 通知中心 | 通知歷史記錄在 `Super + Shift + Alt + ,` |
| Time Machine（針對系統） | 每次更新時自動建立[系統快照](47-system-snapshots.md) |
| App Store / 下載安裝程式 | 選單中的 _Install_，或是 `omarchy pkg add`——請參閱[其他套件](29-other-packages.md) |
| 系統設定 / 控制台 | 選單中的 _Setup_，它會編輯純文字設定檔——請參閱 [dotfiles](31-dotfiles.md) |
| Finder / 檔案總管 | 檔案，在 `Super + Shift + F`——請參閱 [GUI 程式](22-guis.md) |
| Safari / Edge | Google Chrome 在 `Super + Shift + Return`；在 _Setup > Defaults > Browser_ 下選擇另一個——請參閱[瀏覽器](23-browsers.md) |
| 預覽程式 / 照片 | Omaview 用於圖片、影片和音樂，Document Viewer 用於 PDF——請參閱 [GUI 程式](22-guis.md) |
| TextEdit / 記事本 | Plain，在 `Super + Shift + N`；在 _Setup > Defaults > Editor_ 下選擇另一個 |

### 有些事真的大不相同

很多設定都放在你編輯的文字檔裡，而不是你點來點去的面板裡。這聽起來很原始，直到你意識到這意味著每個調整都能被看見、複製到你的下一台機器，並納入版本控制。_Setup_ 選單會直接把你送到正確的檔案，並在你完成後重新啟動任何需要重新啟動的東西。

更新透過一個指令完成——_Update > Omarchy_——它會更新 Omarchy 本身和系統上的每個套件，並先建立一個快照。沒有每個應用程式各自的更新程式在隨機時刻煩你。請參閱[更新](30-updates.md)。

軟體來自套件管理器，而不是下載下來的安裝程式。

而當你關閉一個視窗時，應用程式真的會結束。不存在 macOS 那種程式沒有視窗卻還繼續執行的懸置狀態。`Super + W`——或是 `Super + Q`，如果你帶著的是那種手指記憶——就代表它消失了。

### 在 Mac 硬體上

Omarchy 在 Intel Mac 上執行得很好，在 M1、M2 和 M3 Mac 上搭配 Omarchy for Apple Silicon 也一樣。請參閱 [Mac 支援](44-mac-support.md)。而且鍵盤對你很友善：Omarchy 不會重新對應任何按鍵，而 Linux 會把 Command 鍵當成 Super，所以 Super 就在 Cmd 一直所在的位置上。你的拇指不會注意到這次移動。

### 給它兩週時間

這些本能轉移得比你想像的還快。把[快捷鍵](07-hotkeys.md)那一章快速看過一次，之後每當你想不起某個按鍵綁定時，就按 `Super + K`——它會把全部都顯示給你。那是你唯一真正必須記住的快捷鍵。
