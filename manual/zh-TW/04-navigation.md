# 導覽

Omarchy 裡的一切都透過鍵盤完成——_一切都是！_系統剛啟動時，你真的沒辦法只靠滑鼠做任何事。但你可以按下 `Super + Space` 叫出 Omarchy Menu，從這裡你幾乎可以做所有事。

但 Omarchy 選單甚至不是設計來在大多數時候當作操作系統的主要方式的。我們可以比那更快！所有最重要的應用程式都直接綁定到個別的快速鍵。你用 `Super + Return` 啟動終端機，用 `Super + Shift + Return` 啟動瀏覽器。試著一個接著一個做，你就會看到 Hyprland 平鋪的魔法正在運作：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

接著你可以按下 `Super + J`，把它們堆疊在彼此上方，而不是並排：

 ![navigation-stacked](images/navigation-stacked.webp)

再次按下 `Super + J`，把它們恢復到並排的位置。接著在瀏覽器中試著按下 `Super + Shift + Arrow Right`，交換這些視窗。

現在試著按下 `Super + Shift + T` 啟動 Activity monitor。它會以浮動視窗的形式出現，帶有可用來拖曳它的標題列，以及最小化、最大化和關閉它的按鈕。每個浮動視窗都會有一個，無論它在哪裡。你可以用 `Super + T` 把它改為平鋪（再按一次則會讓它再次浮動）。現在按下 `Super + Shift + F` 開啟檔案管理器。你將會有一個俐落的四格配置：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你可以用 `Super + Arrow` 在你想要啟用的視窗之間導覽。這會切換焦點，並把游標移到新應用程式的中央。在螢幕的邊緣時，它會接著前往那一側的螢幕。

如果你按下 `Super + Shift + 2`，你會把目前聚焦的應用程式移到第二個工作區。`Super + Shift + 1` 會把它移回來。（而 `Super + Shift + Alt + 2` 會把目前聚焦的應用程式移到第二個工作區，但不會切換到它）。

當你有多個螢幕時，每個螢幕都有它自己的 1 到 10 號工作區。`Super + 2` 會前往你所在螢幕的第二個工作區，而每個螢幕的頂部列都會顯示它自己的工作區和它正在顯示的那個。`Super + Tab` 會在你所在螢幕的工作區之間循環切換。`Super + Shift + Ctrl + Arrows` 會把你所在的視窗移到那個方向的螢幕上，放到它正在顯示的工作區上，而 `Super + Shift + Alt + Arrows` 會把你所在的工作區移到那個方向的螢幕上，在那裡，如果同一個編號是空著的，它就會使用同一個編號。當你拔掉一個螢幕時，它會保留它的工作區：它們會加入另一個螢幕的工作區，編號排在它已經有的工作區之後，而當螢幕回來時，它們會回到它們原來的編號下。

如果你按住 `Super` 並用滑鼠按一下某個視窗，你就能重新安排它所在的位置。如果你按住 `Super` 並使用滑鼠右鍵，你可以自由調整視窗大小。

你可以用 `Super + W` 或 `Super + Q` 關閉視窗（並用 `Ctrl + Alt + Delete` 關閉所有視窗）。

你也可以用 `Super + F` 進入全螢幕，甚至可以用 `Super + Alt + F` 只進入全寬（保留頂部列），或用 `Super + Ctrl + F` 在視窗內全螢幕（很適合 YouTube！）。

### Dwindle 與捲動版面配置

Omarchy 的預設版面配置稱為 dwindle。它讓你在單一工作區上開啟的所有視窗始終可見，即使它必須把它們縮小也一樣。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以選擇把一個工作區轉換為捲動版面配置，在那裡視窗並排排列，超出顯示器的可見邊緣。你可以透過 `Super + L` 把單一工作區轉換為這種版面配置。

再次按下 `Super + L` 會把工作區轉換為浮動，在那裡視窗自由重疊，由你自己放置它們，而第三次按下則會把它恢復到 dwindle。`Super + Alt + L` 會以相反的方向循環切換它們。一個本來就會浮動的視窗——一個你用 `Super + T` 彈出的視窗，或一個總是浮動開啟的 app——當工作區回到平鋪時，仍會保持浮動。頂部列會用其版面配置標記你所在的工作區：正方形代表 dwindle，圓形代表捲動，三角形代表浮動。按一下那個標記也會循環切換版面配置，在有顯示鍵的筆記型電腦上，那個按鍵也會這樣做。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

這個選擇是以每個工作區為單位的，而且會保留下來。所以你可以把工作區 1 保持在 dwindle 用來瀏覽，把工作區 2 保持在捲動用來寫程式，它們在重新啟動後就會以那種方式回來。

如果你想把捲動版面配置用作預設，你可以在 `~/.config/hypr/looknfeel.lua` 中設定：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### 浮動工作區

浮動工作區的運作方式像傳統桌面：視窗重疊，由你自己移動和調整它們的大小。每個視窗都會有一個採用你的主題顏色的標題列，帶有最小化、最大化和關閉的按鈕。`Super + M` 也會最小化聚焦的視窗。最小化的視窗會在 dock 中等待；按一下它的 app 即可把它帶回來。按一下視窗即可把它帶到前面。從任何邊緣或角落調整它的大小。按兩下標題列即可最大化視窗，同時保持頂部列可見，再按兩下即可恢復它的舊大小。Chrome 和其他以 Chromium 為基礎的瀏覽器、Disks 和 Document Viewer 會跳過標題列，改用它們自己的標題列；`Super + Alt + F` 會最大化它們，而 `Super + M` 會最小化它們。

每個工作區都有一個 dock，其中有你釘選的 app、所有正在執行的 app，以及 apps 按鈕後方的每一個 app 的格狀清單，`Super + Alt + Space` 和 Omarchy 選單中的 _Apps_ 也會開啟它。在格狀清單上以滑鼠右鍵按一下某個 app，或按下 `Delete`，即可將其解除安裝。按一下 app 即可開啟它，或把它的視窗帶到前面；再次按一下即可在它的視窗之間循環切換。Files 只會把你所在工作區的一個視窗帶回來，否則就會開啟一個新的，而 Terminal 和 Agent 永遠會再啟動一個，不過最小化的視窗會先回來。以滑鼠中鍵按一下會開啟新視窗。沿著 dock 拖曳圖示即可移動它；把一個正在執行的 app 拖到其他 app 之間，就會把它保留在那裡。以滑鼠右鍵按一下即可把 app 保留在 dock 中、把它取出，或結束它。當工作區是空的時候，dock 會一直顯示，而一旦工作區有了視窗，它就會隱藏起來，直到指標抵達它的邊緣。全螢幕視窗會把它完全隱藏。將 apps 按鈕拖向螢幕的另一側邊緣，即可把 dock 移到那裡。以滑鼠右鍵按一下它，使用 _Position_ 來選擇一個邊緣、使用 _Layout_ 來像 _Appearance > Workspace Layout_ 一樣設定預設版面配置，以及使用 _Visibility_ 來讓 dock 始終開啟、讓第一個 app 隱藏它，或讓它始終隱藏。`omarchy dock visibility always` 可從終端機設定這一點。位置也位於 _Appearance > Dock > Dock Position_ 下，而 `omarchy dock position left` 可從終端機設定它。你保留在 dock 中的 app 在未執行時會呈現淡化狀態。若要讓 dock 只保留在浮動工作區上，請使用 _Appearance > Dock > Dock Only on Floating_ 或 `omarchy dock tiling off`。

新的工作區，以及任何你尚未用 `Super + L` 給予其專屬版面配置的工作區，都會使用預設版面配置。變更預設會把每個沒有視窗的工作區都重設為它，而有視窗的工作區則會保持它所擁有的版面配置。最小化到 dock 的視窗仍然算是它所離開的工作區上的一個視窗。在 _Appearance > Workspace Layout_ 下選擇它：Tiling、Scrolling，或 Floating。`omarchy hyprland workspace layout default scrolling` 可從終端機設定它。

### 將視窗分組

視窗可以用 `Super + G` 分組。一旦你進入一個群組，你在該群組啟用時啟動的每個視窗都將屬於該群組。你可以使用 `Super + Ctrl + Arrow Left/Right` 在這些分組的視窗之間移動，或用 `Super + Alt + 1/2/3/4` 直接依序前往分組的視窗。

你可以用 `Super + Alt + G` 把視窗移出群組，或再次按下 `Super + G` 來解散整個群組。最後，你可以用 `Super + Alt + Arrows` 把群組外的視窗移入群組中。

### 彈出視窗

你可以用 `Super + O` 把視窗從其工作區配置中彈出。那會把它釘選為一個浮動視窗，無論你前往哪個工作區，它都會跟隨你。非常適合影片播放器之類的東西。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### 暫存工作區

有一個特殊的全尺寸暫存工作區，會覆蓋在你目前所在的任何工作區上。你用 `Super + S` 存取它上面的東西，而你用 `Super + Alt + S` 把視窗放在那裡。

它非常適合用在你想快速互動，而不想離開目前工作區的控制項或終端機上。

### Quake 主控台

最後，有一個半高 Quake 主控台，會在你目前所在的任何工作區上向下滑出。用 `Super + the key above Tab` 切換它（美式鍵盤配置上為 grave 鍵），並用 `Super + Shift + the key above Tab` 把視窗放在那裡。

它第一次開啟時，會啟動你的預設 agent，或者如果你尚未選擇一個，它會要求你選擇一個。當主控台只容納單一視窗時，它會以置中的面板向下滑出，而不是橫跨螢幕。在它上面放第二個 app，它就會恢復到全寬，這樣兩者就有空間並排坐在一起。

若要把視窗從暫存區或主控台移走，請用類似 `Super + Shift + 1` 的方式把它直接送到另一個工作區。

### 需要一點時間適應！

習慣像這樣導覽你的桌面需要一點時間，但一旦你習慣了，就很難再回到傳統的滑鼠驅動桌面體驗！
