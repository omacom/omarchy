# 導覽

Omarchy 裡的一切全靠鍵盤操作 —— _一切都是！_ 系統剛啟動時，你真的光靠滑鼠什麼都做不到。但你可以按下 `Super + Space` 叫出 Omarchy 選單，從這裡幾乎什麼都能做。

不過，Omarchy 選單甚至不是設計來讓你平常主要這樣操作系統的。我們可以比那更快！所有最重要的應用程式都直接綁定到各自的快捷鍵上。你用 `Super + Return` 啟動終端機，用 `Super + Shift + Return` 啟動瀏覽器。試著一個接著一個來，你就會看到 Hyprland 平鋪的魔法實際運作：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

接著你可以按下 `Super + J`，讓它們上下堆疊，而不是並排：

 ![navigation-stacked](images/navigation-stacked.webp)

再按一次 `Super + J`，讓它們回到並排的位置。然後在瀏覽器裡試試 `Super + Shift + Arrow Right`，交換這兩個視窗。

現在試試 `Super + Shift + T` 啟動 Activity monitor。它會以浮動視窗出現。你可以用 `Super + T` 把它變成平鋪（再按一次又會變回浮動）。現在按下 `Super + Shift + F` 打開檔案管理器。你就會有一個整齊的四格配置：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你用 `Super + Arrow` 在你想啟用的視窗之間移動。這會切換焦點，並把游標移到新應用程式的中央。在螢幕邊緣，它會繼續移到該方向的那台顯示器。

如果你按下 `Super + Shift + 2`，你會把目前聚焦的應用程式移到第二個工作區。`Super + Shift + 1` 會把它移回來。（而 `Super + Shift + Alt + 2` 則會把目前聚焦的應用程式移到第二個工作區，但不會切換過去）。

有多台顯示器時，每台顯示器都有自己的 1 到 10 號工作區。`Super + 2` 會前往你所在顯示器的第二個工作區，每台顯示器的頂部列都會顯示自己的工作區，以及它正在顯示的那一個。`Super + Tab` 會在你所在顯示器的工作區之間循環切換。`Super + Shift + Ctrl + Arrows` 會把你所在的視窗移到該方向的顯示器上，並放到它正在顯示的工作區；`Super + Shift + Alt + Arrows` 則會把你所在的工作區整個移到該方向的顯示器上，如果該編號還沒被占用，就會沿用同一個編號。當你拔掉一台顯示器時，它的工作區仍會保留：它們會併入另一台螢幕，接在它原有的工作區之後編號；等顯示器重新接回來時，又會回到它們原本的編號。

如果你按住 `Super` 並用滑鼠點按某個視窗，你就能重新安排它所在的位置。如果你按住 `Super` 並使用滑鼠右鍵，你可以自由調整視窗大小。

你用 `Super + W` 或 `Super + Q` 關閉視窗（並用 `Ctrl + Alt + Delete` 關閉所有視窗）。

你也可以用 `Super + F` 進入全螢幕，甚至只用 `Super + Alt + F` 變成全寬（保留頂部列），或用 `Super + Ctrl + F` 在視窗內全螢幕（很適合 YouTube！）。

### Dwindle 與捲動式版面

Omarchy 的預設版面叫做 dwindle。它會讓你在單一工作區上開啟的所有視窗始終保持可見，即使必須把它們縮小也要這樣。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以選擇把某個工作區變成捲動式版面，讓視窗並排排列，一直延伸到顯示器可見邊緣之外。你用 `Super + L` 把單一工作區切換成這種版面。

再按一次 `Super + L` 會把工作區變成浮動，視窗可以自由重疊、由你自己擺放；按第三次則回到 dwindle。`Super + Alt + L` 會以相反方向依序循環。有些視窗本來就是浮動的 —— 例如你用 `Super + T` 彈出的視窗，或某個總是以浮動方式開啟的應用程式 —— 當工作區回到平鋪時，它們仍會保持浮動。頂部列會以標記顯示你所在工作區的版面：方形代表 dwindle，圓形代表捲動式，三角形代表浮動。點按該標記也可以循環切換版面。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

這個選擇是依工作區分開的，而且會保留下來。所以你可以讓 1 號工作區保持 dwindle 來瀏覽網頁，讓 2 號工作區保持捲動式來寫程式，重新啟動後它們仍會以那樣的方式回來。

如果你想把捲動式版面用作預設值，你可以在 `~/.config/hypr/looknfeel.lua` 中設定：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### 浮動工作區

浮動工作區就像傳統桌面一樣運作：視窗互相重疊，由你自己移動和調整大小。每個視窗都會得到一個使用你主題顏色的標題列，上面有最小化、最大化和關閉按鈕。`Super + M` 也會最小化目前聚焦的視窗。最小化的視窗會等在 Dock 裡；點按它的應用程式即可把它帶回來。點按某個視窗可把它帶到最前面。從任何邊緣或角落拖曳即可調整大小。雙擊標題列會最大化視窗，同時保持頂部列可見；再雙擊一次則恢復它原本的大小。Chrome 與其他以 Chromium 為基礎的瀏覽器、Disks 和 Document Viewer 會跳過標題列，改用它們自己的標頭列；`Super + Alt + F` 會最大化它們，`Super + M` 會最小化它們。

浮動工作區還會顯示 Dock，其中有你釘選的應用程式、所有正在執行的應用程式，以及藏在應用程式按鈕後面的所有應用程式網格；按下 `Super + Alt + Space`，或從 Omarchy 選單開啟 _Apps_，也能打開這個網格。在網格上對某個應用程式按右鍵，或按下 `Delete`，即可將它解除安裝。點按應用程式可開啟它，或將它的視窗帶到最前面；再點一次則可在它的各個視窗之間循環切換。按滑鼠中鍵會開啟新視窗。沿著 Dock 拖曳圖示即可移動它；把正在執行的應用程式拖到其他圖示之間，就會把它留在那裡。按右鍵可將應用程式保留在 Dock 裡、將它移出，或讓它退出。Dock 會為全螢幕視窗讓路。在應用程式按鈕上按右鍵，可把 Dock 移到另一邊，或讓它隱藏起來，直到指標移到該邊緣為止。Dock 的位置也可以在 _Appearance > Dock > Dock Position_ 下設定，並可在終端機用 `omarchy dock position left` 和 `omarchy dock autohide on` 設定這兩項。你保留在 Dock 裡的應用程式，在未執行時會顯示得較淡。

新工作區，以及任何你還沒有用 `Super + L` 給它自己的版面的的工作區，都會使用預設版面。變更預設版面會把每一個沒有視窗的工作區重置成那個版面，而上面有視窗的工作區則會保留它目前的版面。最小化到 Dock 的視窗，仍算作它離開的那個工作區上的一個視窗。在 _Appearance > Workspace Layout_ 下選擇它：Tiling、Scrolling 或 Floating。`omarchy-hyprland-workspace-layout-default scrolling` 可從終端機設定它。

### 視窗分組

你可以用 `Super + G` 將視窗分組。一旦你進入一個群組，只要該群組處於啟用狀態，你啟動的每個視窗都會屬於該群組。你可以用 `Super + Ctrl + Arrow Left/Right` 在這些分組視窗之間移動，或用 `Super + Alt + 1/2/3/4` 直接依順序前往分組視窗。

你可以用 `Super + Alt + G` 把某個視窗移出群組，或再按一次 `Super + G` 拆散整個群組。最後，你可以用 `Super + Alt + Arrows` 把群組外的視窗移入群組。

### 彈出視窗

你可以用 `Super + O` 把某個視窗彈出它所在的工作區配置。那會把它釘成一個浮動視窗，無論你到哪個工作區，它都會跟著你。非常適合影片播放器之類的東西。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad 工作區

有一個特殊的全尺寸 Scratchpad 工作區，它會覆蓋在你目前所在的工作區之上。你用 `Super + S` 存取上面放的東西，並用 `Super + Alt + S` 把視窗放到那裡。

它很適合放控制面板，或你想快速互動又不必離開目前工作區的終端機。

### Quake 控制台

最後，有一個半高式的 Quake 控制台，會從你目前所在工作區的上方垂下來。你用 `Super + Grave` 切換它，並用 `Super + Shift + Grave` 把視窗放到那裡。

它開啟時，你的預設 agent 已經準備就緒。當控制台裡只容納單一視窗時，它會以置中面板的形式垂下來，而不是橫跨整個螢幕。在上面放第二個應用程式後，它會回到全寬，這樣兩個程式就有空間並排坐在一起。

若要把視窗移出 Scratchpad 或控制台，直接用像 `Super + Shift + 1` 這樣的組合把它送到另一個工作區即可。

### 需要一點時間習慣！

以這種方式導覽你的桌面需要一點時間習慣，但是一旦你習慣了，要再回到傳統以滑鼠驅動的桌面體驗，就會很難了！
