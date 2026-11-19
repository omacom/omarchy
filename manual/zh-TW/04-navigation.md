# 導覽

Omarchy 裡的一切都透過鍵盤完成——*一切都是！*系統剛啟動時，你真的光靠滑鼠什麼都做不了。但你可以按下 `Super + Space` 叫出 Omarchy 選單，從這裡你幾乎可以做所有事。

但 Omarchy 選單甚至不是設計來當作大多數時候操作系統的主要方式。我們可以比那更快！所有最重要的應用程式都直接綁定到個別的快捷鍵。你用 `Super + Return` 啟動終端機，用 `Super + Shift + Return` 啟動瀏覽器。試著一個接著一個做，你就會看到 Hyprland 平鋪的魔法正在運作：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

接著你可以按下 `Super + J` 把它們堆疊在彼此上方，而不是並排：

 ![navigation-stacked](images/navigation-stacked.webp)

再按一次 `Super + J`，把它們恢復成並排位置。接著在瀏覽器裡試試 `Super + Shift + Arrow Right` 來交換視窗。

現在試試 `Super + Shift + T` 啟動 Activity 監視器。那會以浮動視窗出現。你可以用 `Super + T` 把它平鋪（再按一次就會讓它再次浮動）。現在按下 `Super + Shift + F` 開啟檔案管理員。你會有一個整齊的四視窗配置：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你用 `Super + Arrow` 在你想啟用的視窗之間導覽。這會切換焦點，並把游標移到新應用程式的中央。在螢幕邊緣時，它會繼續到那一側的顯示器。

如果你按下 `Super + Shift + 2`，你會把目前聚焦的應用程式移到第二個工作區。`Super + Shift + 1` 把它移回來。（而 `Super + Shift + Alt + 2` 會把目前聚焦的應用程式移到第二個工作區，但不會切換過去）。

有多個顯示器時，每個顯示器都有它自己的工作區 1 到 10。`Super + 2` 會前往你所在顯示器的第二個工作區，每個顯示器的頂欄都會顯示它自己的工作區，以及它正在顯示的那一個。`Super + Tab` 會循環切換你所在顯示器上的工作區。`Super + Shift + Ctrl + Arrows` 會把你所在的視窗移到那個方向的顯示器，移到它正在顯示的工作區上，而 `Super + Shift + Alt + Arrows` 會把你所在的工作區移到那個方向的顯示器上，在那裡它會佔用相同的編號，如果該編號空著的話。顯示器在你拔掉它時會保留它的工作區：它們會加入另一個螢幕的工作區，編號排在它已經有的工作區之後，並在顯示器回來時回到它們原本的編號下。

如果你按住 `Super` 並用滑鼠點擊視窗，你就能重新安排它所在的位置。如果你按住 `Super` 並使用滑鼠右鍵，你可以自由調整視窗大小。

你用 `Super + W` 或 `Super + Q` 關閉視窗（並用 `Ctrl + Alt + Delete` 關閉所有視窗）。

你也可以用 `Super + F` 全螢幕，甚至用 `Super + Alt + F` 只全寬（保留頂欄），或用 `Super + Ctrl + F` 在視窗內全螢幕（很適合 YouTube！）。

### Dwindle 對上 scrolling 版面配置

Omarchy 的預設版面配置稱為 dwindle。它讓你在單一工作區開啟的所有視窗隨時都可見，就算必須把它們縮小也一樣。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以選擇把工作區轉成 scrolling 版面配置，其中視窗並排排列，超出顯示器的可見邊緣。你透過 `Super + L` 把單一工作區轉成此版面配置。

再按一次 `Super + L` 會把工作區轉成浮動，視窗在其中自由重疊、由你自己擺放，第三次按下則讓它回到 dwindle。`Super + Alt + L` 會以相反方向循環經過它們。一個本來就浮動的視窗——你用 `Super + T` 彈出的視窗，或總是以浮動方式開啟的應用程式——在工作區回到平鋪時仍會保持浮動。頂欄會用其版面配置標示你所在的工作區：正方形代表 dwindle，圓形代表 scrolling，三角形代表浮動。點擊那個標記也會循環切換版面配置。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

這個選擇是以工作區為單位的，而且會保留。所以你可以讓工作區 1 用 dwindle 來瀏覽、工作區 2 用 scrolling 來寫程式，它們在重新啟動後也會以那樣回來。

如果你希望把 scrolling 版面配置當作預設值，你可以在 `~/.config/hypr/looknfeel.lua` 中設定：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### 浮動工作區

浮動工作區的運作方式像傳統桌面：視窗重疊，由你自己移動它們並調整大小。每個視窗都會有一個你主題顏色的標題列，上面有最小化、最大化和關閉按鈕。`Super + M` 也會最小化聚焦的視窗。最小化的視窗會在 Dock 中等待；點擊它的應用程式就能把它帶回來。點擊視窗把它帶到前面。從任何邊緣或角落調整它的大小。在標題列上按兩下可以最大化視窗，同時保持頂欄可見，再按兩下則恢復它原本的大小。Chrome 和其他以 Chromium 為基礎的瀏覽器、Disks 和 Document Viewer 會跳過標題列，改用它們自己的標頭；`Super + Alt + F` 最大化它們，`Super + M` 最小化它們。

浮動工作區也會顯示 Dock，其中有你釘選的應用程式、所有正在執行的應用程式，以及在應用程式按鈕後面的每個應用程式的格狀清單，`Super + Alt + Space` 和 Omarchy 選單中的 _Apps_ 也會開啟它。在格狀清單上對應用程式按右鍵，或按下 `Delete`，就能解除安裝它。點擊應用程式來開啟它，或把它的視窗帶到前面；再點擊一次會循環切換它的視窗。Files 只會從你所在的工作區帶回視窗，否則會開啟新視窗，而 Terminal 和 Agent 總是啟動另一個，不過最小化的視窗會先回來。用滑鼠中鍵點擊會開啟新視窗。沿著 Dock 拖曳圖示來移動它；把正在執行的應用程式拖到其他應用程式之中會讓它留在那裡。按右鍵把應用程式留在 Dock 中、把它移除，或結束它。Dock 會避開全螢幕視窗。對應用程式按鈕按右鍵，可以把 Dock 移到另一個邊緣，或讓它隱藏直到指標抵達其邊緣為止。該位置也可以在 _Appearance > Dock > Dock Position_ 下找到，而 `omarchy dock position left` 和 `omarchy dock autohide on` 從終端機設定這兩者。你留在 Dock 中的應用程式在未執行時會變淡。

新的工作區，以及任何你沒有用 `Super + L` 給予其自身版面配置的工作區，都使用預設版面配置。更改預設值會把每個沒有視窗的工作區重設為它，而有視窗的工作區會保留它擁有的版面配置。最小化到 Dock 的視窗仍算作它所離開的工作區上的一個視窗。在 _Appearance > Workspace Layout_ 下選擇它：Tiling、Scrolling 或 Floating。`omarchy-hyprland-workspace-layout-default scrolling` 從終端機設定它。

### 將視窗分組

可以用 `Super + G` 把視窗分組。一旦你進入群組，在該群組啟用時你啟動的每個視窗都會屬於該群組。你可以用 `Super + Ctrl + Arrow Left/Right` 在這些已分組的視窗之間移動，或用 `Super + Alt + 1/2/3/4` 直接依序前往已分組的視窗。

你可以用 `Super + Alt + G` 把視窗移出群組，或再按一次 `Super + G` 拆解整個群組。最後，你可以用 `Super + Alt + Arrows` 把群組外的視窗移到群組內。

### 彈出視窗

你可以用 `Super + O` 把視窗從它的工作區分配中彈出。那會把它釘選為浮動視窗，跟著你到你去的任何工作區。非常適合影片播放器之類的東西。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad 工作區

有一個特殊全尺寸的 scratchpad 工作區，它覆蓋在你目前所在的工作區上。你用 `Super + S` 存取上面有什麼東西，並用 `Super + Alt + S` 把視窗放在那裡。

它很適合用於你想快速互動、又不必離開目前工作區的控制項或終端機。

### Quake 主控台

最後，有一個半高 Quake 主控台，它會在你目前所在的工作區上降下。用 `Super + Grave` 切換它，並用 `Super + Shift + Grave` 把視窗放在那裡。

它開啟時你的預設 agent 已經準備就緒。當主控台只有單一視窗時，它會以置中的面板降下，而不是橫跨螢幕。在上面放第二個應用程式，它就會回到全寬，這樣兩者就有空間並排。

要把視窗從 scratchpad 或主控台移開，用像 `Super + Shift + 1` 這樣的組合直接把它送到另一個工作區。

### 需要一點時間習慣！

像這樣導覽你的桌面需要一點時間習慣，但一旦你習慣了，就很難再回到傳統以滑鼠驅動的桌面體驗！
