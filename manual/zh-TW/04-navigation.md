# 導覽

在 Omarchy 中，一切都是透過鍵盤完成的——一切！系統第一次啟動時，單靠滑鼠你真的什麼事都做不了。但你可以按下 `Super + Space` 叫出 Omarchy Menu，從這裡開始，你幾乎可以做任何事。

但 Omarchy menu 根本不是為了成為你平常操作系統的主要方式而設計的。我們可以比那更快！所有最重要的應用程式都直接綁定到各自的快速鍵。你用 `Super + Return` 啟動終端機，用 `Super + Shift + Return` 啟動瀏覽器。試著接連使用這兩個快速鍵，你就會看到 Hyprland 平鋪功能的神奇之處：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

接著你可以按下 `Super + J`，讓它們上下堆疊，而不是並排：

 ![navigation-stacked](images/navigation-stacked.webp)

再次按下 `Super + J`，讓它們回到並排的位置。然後在瀏覽器中試試 `Super + Shift + Arrow Right`，交換這些視窗的位置。

現在試試 `Super + Shift + T` 來啟動 Activity monitor。它會以浮動視窗的形式出現，帶有可供拖曳的標題列，以及最小化、最大化和關閉按鈕。每個浮動視窗都會有一個，不管它在哪裡。你可以使用 `Super + T` 將它改為平鋪（再次按下這個按鍵會讓它恢復浮動）。現在按下 `Super + Shift + F` 開啟檔案管理員。你會得到一個漂亮的四格配置：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你可以用 `Super + Arrow` 在你想要啟用的視窗之間導覽。這會切換焦點，並將游標移到新應用程式的中央。在螢幕邊緣，它會繼續前往那一側的顯示器。

如果你按下 `Super + Shift + 2`，你會將目前聚焦的應用程式移到第二個工作區。`Super + Shift + 1` 則將它移回來。（而 `Super + Shift + Alt + 2` 會將目前聚焦的應用程式移到第二個工作區，但不會切換過去）。

使用多台顯示器時，每台顯示器都有自己專屬的第 1 到第 10 號工作區。`Super + 2` 會前往你目前所在顯示器的第二個工作區，每台顯示器的頂部列都會顯示它自己的工作區，以及它正在顯示的那一個。`Super + Tab` 會在你目前所在顯示器的工作區之間循環切換。`Super + Shift + Ctrl + Arrows` 會將你所在的視窗移到那個方向的顯示器，放到它正在顯示的工作區上；`Super + Shift + Alt + Arrows` 則會將你所在的工作區移到那個方向的顯示器上，如果那個編號還空著，它會在那裡取得相同的編號。顯示器在你拔掉它時仍會保留它自己的工作區：它們會加入另一個螢幕的工作區，編號接在它已有工作區之後，等顯示器回來時，又會回到它們原來的編號之下。

如果你按住 `Super` 並用滑鼠點擊一個視窗，你就能重新安排它的位置。如果你按住 `Super` 並使用滑鼠右鍵，你可以自由調整視窗大小。

你可以用 `Super + W` 或 `Super + Q` 關閉視窗（並用 `Ctrl + Alt + Delete` 關閉所有視窗）。

你也可以用 `Super + F` 全螢幕顯示，甚至可以用 `Super + Alt + F` 只顯示為全寬度（保留頂部列），或用 `Super + Ctrl + F` 在視窗內全螢幕（很適合 YouTube！）。

### Dwindle vs 捲動式佈局

Omarchy 的預設佈局稱為 dwindle。它會讓你在同一個工作區開啟的所有視窗始終保持可見，即使這意味著必須將它們縮小。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以選擇將工作區改為捲動式佈局，在這種佈局中，視窗會並排排列，超出顯示器可見的邊緣。你可以透過 `Super + L` 將單一工作區改為這種佈局。

再次按下 `Super + L` 會將工作區改為浮動模式，在這種模式中視窗可以自由重疊，由你自己放置；第三次按下則回到 dwindle。`Super + Alt + L` 則會以相反的方向循環切換。一個本來就浮動的視窗——用 `Super + T` 彈出來的視窗，或總是開啟為浮動的應用程式——當工作區回到平鋪模式時，仍會保持浮動。頂部列會用一個標記來標示你所在工作區的佈局：正方形代表 dwindle，圓形代表捲動式，三角形代表浮動。點擊該標記也會循環切換佈局，筆記型電腦上如果有顯示按鍵，那個按鍵也有相同作用。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

這個選擇是依工作區而定的，而且會一直保留。所以你可以讓工作區 1 使用 dwindle 來瀏覽網頁，工作區 2 使用捲動式來寫程式碼，重新啟動後它們仍會以那種方式回來。

如果你希望使用捲動式佈局作為預設值，你可以在 `~/.config/hypr/looknfeel.lua` 中這樣設定：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### 浮動工作區

浮動工作區的使用方式就像傳統桌面一樣：視窗互相重疊，由你自己移動並調整大小。每個視窗都會有一個使用你的佈景主題色彩的標題列，上面有最小化、最大化和關閉按鈕。`Super + M` 也會最小化目前聚焦的視窗。最小化的視窗會在 dock 中等待；點擊它的應用程式即可將它帶回來。點擊一個視窗即可將它帶到前方。從任何邊緣或角落調整它的大小。雙擊標題列可最大化視窗，同時保持頂部列可見，再雙擊一次可恢復它原來的大小。Chrome 和其他以 Chromium 為基礎的瀏覽器、Disks 和 Document Viewer 會跳過標題列，改用它們自己的標題列；`Super + Alt + F` 將它們最大化，`Super + M` 將它們最小化。

每個工作區都有一個 dock，裡面有你釘選的應用程式、所有正在執行的程式，以及 apps 按鈕後方所有應用程式的格狀清單，`Super + Alt + Space` 和 Omarchy menu 中的 _Apps_ 也會開啟它。在格狀清單上對應用程式點擊右鍵，或按下 `Delete`，即可將它解除安裝。點擊一個應用程式來開啟它，或將它的視窗帶到前方；再次點擊則在其視窗之間循環。Files 只會從你所在的工作區帶回一個視窗，否則會開啟一個新的視窗；Terminal 和 Agent 則總是會啟動另一個，但最小化的視窗會先回來。中鍵點擊會開啟一個新視窗。沿著 dock 拖曳圖示即可移動它；將正在執行的應用程式拖到其他程式中間，會讓它留在那裡。點擊右鍵即可將應用程式保留在 dock 中、將它移出，或將它結束。工作區為空時，dock 會一直顯示，一旦工作區有了視窗，它就會隱藏起來，直到指標抵達它的邊緣。全螢幕視窗則會讓它完全隱藏。將 apps 按鈕往螢幕的另一條邊拖曳，即可將 dock 移到那裡。對它點擊右鍵以使用 _Position_ 選擇一條邊，並使用 _Layout_ 設定預設佈局，如同 _Appearance > Workspace Layout_ 所做的一樣。位置同樣位於 _Appearance > Dock > Dock Position_，`omarchy dock position left` 則可從終端機設定。如果應用程式沒有在執行，你保留在 dock 中的應用程式會呈現淡化狀態。若要讓 dock 只出現在浮動工作區，使用 _Appearance > Dock > Dock Only on Floating_ 或 `omarchy dock tiling off`。

新的工作區，以及任何你尚未用 `Super + L` 給予專屬佈局的工作區，都會使用預設佈局。變更預設佈局會將每個沒有視窗的工作區重置為該佈局，而有視窗的工作區會保留它目前的佈局。最小化到 dock 的視窗仍然算是它離開的那個工作區上的視窗。在 _Appearance > Workspace Layout_ 下選擇它：平鋪、捲動式或浮動。`omarchy hyprland workspace layout default scrolling` 則可從終端機設定。

### 視窗分組

你可以使用 `Super + G` 將視窗分組。一旦進入群組，你在群組啟用期間啟動的每個視窗都會屬於該群組。你可以使用 `Super + Ctrl + Arrow Left/Right` 在這些分組視窗之間移動，或用 `Super + Alt + 1/2/3/4` 依序直接前往分組視窗。

你可以用 `Super + Alt + G` 將視窗移出群組，或再次按下 `Super + G` 拆散整個群組。最後，你可以用 `Super + Alt + Arrows` 將群組外的視窗移入群組中。

### 彈出視窗

你可以用 `Super + O` 將視窗從其工作區配置中彈出。那會將它釘選為浮動視窗，無論你前往哪個工作區，它都會跟著你。非常適合影片播放器之類的程式。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad 工作區

有一個特殊的全尺寸 scratchpad 工作區，會覆蓋在你目前所在的工作區之上。你用 `Super + S` 存取上面的內容，並用 `Super + Alt + S` 將視窗放在那裡。

它很適合用來放控制器，或你想要快速互動、又不必離開目前工作區的終端機。

### Quake 主控台

最後，有一個半高式的 Quake 主控台，會從上方向下掉落，覆蓋在你目前所在的工作區之上。用 `Super + Tab 上方的按鍵`（美式鍵盤配置上的抑音符）切換它，並用 `Super + Shift + Tab 上方的按鍵` 將視窗放在那裡。

第一次開啟時，它會啟動你的預設 agent，或者如果你尚未選擇，會請你挑選一個。當主控台只容納單一視窗時，它會以居中面板的方式向下掉落，而不是橫跨整個螢幕。在上面放第二個應用程式，它就會回到全寬度，讓兩個程式有空間並排放置。

若要將視窗從 scratchpad 或主控台移走，用類似 `Super + Shift + 1` 的快速鍵直接將它送往另一個工作區。

### 需要一些時間習慣！

像這樣導覽你的桌面需要一點時間來習慣，但一旦你習慣了，就很難再回到傳統以滑鼠驅動的桌面體驗了！
