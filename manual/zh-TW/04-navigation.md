# 導覽

Omarchy 裡的一切都靠鍵盤完成——_一切！_ 系統剛啟動時，你光靠滑鼠真的什麼都做不了。不過你可以按下 `Super + Space` 叫出 Omarchy Menu，從這裡幾乎什麼都能做。

但 Omarchy 選單甚至不是設計來當作平常操作系統的主要方式。我們可以比那更快！所有最重要的應用程式都直接綁定到個別的快捷鍵。你用 `Super + Return` 啟動終端機，用 `Super + Shift + Return` 啟動瀏覽器。試著一個接一個啟動，你就會看到 Hyprland 平鋪的魔法實際運作：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

接著你可以按下 `Super + J`，把他們上下堆疊，而不是並排：

 ![navigation-stacked](images/navigation-stacked.webp)

再次按下 `Super + J`，讓他們回到並排的位置。接著在瀏覽器中試試 `Super + Shift + Arrow Right`，交換視窗。

現在試試 `Super + Shift + T` 啟動活動監視器。它會以浮動視窗出現。你可以用 `Super + T` 把它平鋪（再按一次則讓它再次浮動）。現在按下 `Super + Shift + F` 開啟檔案管理員。你會得到一套整齊的四格配置：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你用 `Super + Arrow` 在想啟用的視窗之間導覽。這會切換焦點，並把游標移到新應用程式的中央。在螢幕邊緣時，它會接著前往那一側的螢幕。

如果你按下 `Super + Shift + 2`，你會把目前聚焦的應用程式移到第二個工作區。`Super + Shift + 1` 把它移回來。（而 `Super + Shift + Alt + 2` 會把目前聚焦的應用程式移到第二個工作區，但不會切換過去）。

有多台螢幕時，每台螢幕都有自己專屬的第 1 到第 10 個工作區。`Super + 2` 會前往你所在螢幕的第二個工作區，而且每台螢幕的頂部列都會顯示自己的工作區與目前顯示的那個。`Super + Tab` 會在你所在螢幕的工作區之間循環切換。`Super + Shift + Ctrl + Arrows` 會把你所在的視窗移到那個方向的螢幕上，放到它正在顯示的工作區，而 `Super + Shift + Alt + Arrows` 會把你所在的工作區移到那個方向的螢幕上，若該編號空著，便在那裡沿用相同的編號。拔除一台螢幕時，它會保留其工作區：他們會加入另一台螢幕的工作區，編號接在它原有工作區之後，並在該螢幕回來時回到原來的編號下。

如果你按住 `Super` 並用滑鼠點擊視窗，你就能重新安排它所在的位置。如果你按住 `Super` 並使用滑鼠右鍵，你可以自由調整視窗大小。

你用 `Super + W` 或 `Super + Q` 關閉視窗（並用 `Ctrl + Alt + Delete` 關閉所有視窗）。

你也可以用 `Super + F` 進入全螢幕，甚至只用 `Super + Alt + F` 進入全寬（保留頂部列），或用 `Super + Ctrl + F` 在視窗內全螢幕（很適合 YouTube！）。

### Dwindle 與捲動佈局

Omarchy 的預設佈局稱為 dwindle。它讓你在一一個工作區開啟的所有視窗始終可見，即使必須把他們縮小。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以選擇把工作區變成捲動佈局，讓視窗並排排列，延伸到顯示器可見邊緣之外。你用 `Super + L` 把一一個工作區變成這個佈局。

再次按下 `Super + L` 會把工作區變成浮動，視窗在其中自由重疊，由你自行擺放，第三次按下則讓它回到 dwindle。`Super + Alt + L` 則以相反順序切換。無論如何都會浮動的視窗——你用 `Super + T` 彈出的視窗，或總是以浮動方式開啟的應用程式——在工作區回到平鋪時仍會保持浮動。頂部列會用其佈局標記你所在的工作區：正方形代表 dwindle，圓形代表捲動，三角形代表浮動。點擊該標記也會循環切換佈局，有顯示鍵的筆記型電腦按那個鍵也會。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

這是依工作區分別選擇的，而且會保留下來。所以你可以讓工作區 1 用 dwindle 來瀏覽，工作區 2 用捲動來寫程式，他們在重新啟動後也會以那樣回來。

如果你希望使用捲動佈局作為預設，你可以在 `~/.config/hypr/looknfeel.lua` 中設定：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### 浮動工作區

浮動工作區的運作方式就像傳統桌面：視窗重疊，由你自行移動並調整大小。每個視窗都會獲得一條採用你的主題色彩的標題列，上面有最小化、最大化和關閉按鈕。`Super + M` 也會最小化聚焦的視窗。最小化的視窗會在 Dock 中等待；點擊其應用程式可把它帶回來。點擊視窗可把它帶到前面。從任何邊緣或角落調整其大小。雙擊標題列可在保持頂部列可見的情況下最大化視窗，再雙擊一次則恢復其原來的大小。Chrome 及其他基於 Chromium 的瀏覽器、Disks 和 Document Viewer 會跳過標題列，改用自己的標頭；`Super + Alt + F` 可最大化他們，`Super + M` 可最小化他們。

浮動工作區還會顯示一個 Dock，裡面有你釘選的應用程式、所有正在執行的應用程式，以及位於應用程式按鈕後方的所有應用程式網格，`Super + Alt + Space` 和 Omarchy 選單中的 _Apps_ 也會開啟它。在網格上右擊一一個應用程式，或按下 `Delete`，即可解除安裝它。點擊一一個應用程式可以開啟它，或把其視窗帶到前面；再次點擊則在其視窗之間循環切換。Files 只會從你所在的工作區帶回一一個視窗，否則會開啟一一個新的，而 Terminal 和 Agent 總是會再啟動一一個，盡管最小化的視窗會先回來。中鍵點擊會開啟一一個新視窗。沿著 Dock 拖曳一一個圖示來移動它；把一一個正在執行的應用程式拖到其他應用程式之間會讓它留在那裡。右擊可把一一個應用程式保留在 Dock 中、把它移除，或結束它。Dock 會避開全螢幕視窗。右擊應用程式按鈕可把 Dock 移到另一邊，或讓它隱藏，直到指標抵達其邊緣。其位置也可以在 _Appearance > Dock > Dock Position_ 下設定，而 `omarchy dock position left` 和 `omarchy dock autohide on` 則從終端機設定這兩者。你保留在 Dock 中的應用程式在未執行時會淡化顯示。

新的工作區，以及任何尚未用 `Super + L` 給予專屬佈局的工作區，都會使用預設佈局。變更預設會把每個沒有視窗的工作區都重設為該佈局，而有視窗的工作區則保留其現有佈局。最小化到 Dock 的視窗仍會計為其離開的工作區上的視窗。在 _Appearance > Workspace Layout_ 下選擇它：Tiling、Scrolling 或 Floating。`omarchy hyprland workspace layout default scrolling` 從終端機設定它。

### 將視窗分組

視窗可以用 `Super + G` 分組。一旦你進入一個群組，你在該群組啟用期間啟動的每個視窗都會屬於該群組。你可以用 `Super + Ctrl + Arrow Left/Right` 在這些已分組視窗之間移動，或用 `Super + Alt + 1/2/3/4` 直接按順序前往已分組視窗。

你可以用 `Super + Alt + G` 把一一個視窗移出群組，或再次按下 `Super + G` 拆解整個群組。最後，你可以用 `Super + Alt + Arrows` 把群組外的視窗移到群組內。

### 彈出視窗

你可以用 `Super + O` 把視窗從其工作區配置中彈出。那會把它釘選為一個浮動視窗，跟著你前往你去的任何工作區。很適合影片播放器之類的東西。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad 工作區

有一個特殊的全尺寸 scratchpad 工作區，會覆蓋在你目前所在的任何工作區之上。你用 `Super + S` 存取其上的內容，並用 `Super + Alt + S` 把視窗放在那裡。

它很適合控制介面或你想快速互動、又不必離開目前工作區的終端機。

### Quake 主控台

最後，有一個半高 Quake 主控台，會從上方面落至你目前所在的任何工作區之上。用 `Super + the key above Tab`（在美式佈局上為抑音符）切換它，並用 `Super + Shift + the key above Tab` 把視窗放在那裡。

它第一次開啟時，會啟動你的預設 agent，或在你尚未選過時要求你選一個。當主控台只容納一一個視窗時，它會以置中的面板落下，而不是橫跨螢幕。在其上放第二個應用程式，它便會回到全寬，讓兩者有空間並排而坐。

要把視窗移出 scratchpad 或主控台，用類似 `Super + Shift + 1` 的方式直接把它送到另一個工作區。

### 需要一點時間習慣！

需要一點時間習慣像這樣導覽你的桌面，但一旦你習慣了，就很難再回到傳統以滑鼠驅動的桌面體驗！
