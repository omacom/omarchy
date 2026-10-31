# 導覽

Omarchy 中的一切都透過鍵盤完成——_一切！_系統剛啟動時，你光靠滑鼠真的什麼都做不了。但你可以按下 `Super + Space` 叫出 Omarchy Menu，從這裡幾乎什麼都能做。

但在大多數時候，Omarchy menu 甚至不算是操作系統的主要方式。我們可以比那更快！所有最重要的應用程式都直接綁定到個別的快捷鍵。你用 `Super + Return` 啟動終端機，用 `Super + Shift + Return` 啟動瀏覽器。試著一個接著一個執行，你就會看到 Hyprland 平鋪的魔法在運作：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

接著你可以按下 `Super + J`，將它們彼此堆疊，而不是並排：

 ![navigation-stacked](images/navigation-stacked.webp)

再次按下 `Super + J`，將它們返回並排位置。接著在瀏覽器上試著按下 `Super + Shift + Arrow Right`，來交換視窗。

現在試著按下 `Super + Shift + T` 啟動 Activity 監控器。它會以浮動視窗的形式出現。你可以用 `Super + T` 將它平鋪（再按一次則讓它再次浮動）。現在按下 `Super + Shift + F` 開啟檔案管理員。你將會有一套漂亮的四方配置：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你用 `Super + Arrow` 在想要設為作用中的視窗之間導覽。這將切換焦點，並將游標移動到新應用程式的中央。在螢幕邊緣時，它會繼續前往該側的顯示器。

如果你按下 `Super + Shift + 2`，你會將目前聚焦的應用程式移動到第二個工作區。`Super + Shift + 1` 將它移回來。（而 `Super + Shift + Alt + 2` 會將目前聚焦的應用程式移動到第二個工作區，且不切換過去。）

在有多台顯示器的情況下，每台顯示器都有屬於自己的 1 到 10 號工作區。`Super + 2` 前往你所在顯示器的第二個工作區，且每台顯示器的頂部欄都會顯示自己的工作區以及正在顯示的那個。`Super + Tab` 循環切換你所在顯示器上的工作區。`Super + Shift + Ctrl + Arrows` 將你所在的視窗移動到該方向的顯示器上它正在顯示的工作區，而 `Super + Shift + Alt + Arrows` 則將你所在的工作區移動到該方向的顯示器，在那裡它會在空著時取得相同的號碼。顯示器在你將它拔掉時會保留它本身的工作區：它們會加入另一個螢幕的，並按照該螢幕已經有的那些依序編號，且在顯示器回來時返回它們原本的號碼。

如果你按住 `Super` 並使用滑鼠點按一個視窗，你將能夠重新安排它所在的位置。如果你按住 `Super` 並使用滑鼠右鍵，你可以自由調整視窗大小。

你用 `Super + W` 或 `Super + Q` 關閉視窗（並用 `Ctrl + Alt + Delete` 關閉所有視窗）。

你也可以用 `Super + F` 切換為全螢幕，或者甚至僅用 `Super + Alt + F` 切換為全寬（保留頂部欄），或用 `Super + Ctrl + F` 在視窗內全螢幕（很適合觀看 YouTube！）。

### Dwindle 與 scrolling 版面配置

Omarchy 的預設版面配置稱為 dwindle。它讓你在單一工作區上開啟的所有視窗始終可見，即使它必須將它們縮小。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以選擇將工作區轉為 scrolling 版面配置，在那裡視窗並排排列，超出顯示器可見的邊緣。你透過 `Super + L` 將單一工作區轉為此版面配置。

再次按下 `Super + L` 會將工作區轉為 floating，在那裡視窗自由重疊，且由你自己放置它們，第三次按下則將它返回 dwindle。`Super + Alt + L` 則以另一種方式依次切換它們。一個無論如何都會浮動的視窗——一個你用 `Super + T` 彈出的視窗，或是一個永遠以浮動方式開啟的應用程式——在工作區回到平鋪模式時仍會保持浮動。頂部欄會用其版面配置標記你所在的工作區：方形代表 dwindle，圓形代表 scrolling，三角形代表 floating。點按那個標記也可以循環切換版面配置。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

這個選擇是依工作區區分的，而且會維持不變。所以你可以將工作區 1 保持 dwindle 用於瀏覽、工作區 2 保持 scrolling 用於寫程式碼，而且它們在重新啟動後會以那個方式回來。

如果你希望將 scrolling 版面配置用作預設，你可以在 `~/.config/hypr/looknfeel.lua` 中這樣設定：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Floating 工作區

floating 工作區運作起來像傳統桌面：視窗重疊，且由你自己移動它們並調整大小。每個視窗都會得到一個具有你的主題色彩的標題欄，帶有最小化、最大化和關閉的按鈕。`Super + M` 也會最小化聚焦的視窗。最小化的視窗會在 dock 中等待；點按它的應用程式將它帶回來。點按視窗將它帶到最前面。從任意邊緣或角落調整它的大小。按兩下標題欄將視窗最大化同時保持頂部欄可見，再按兩下則讓它恢復舊的大小。

floating 工作區同時會顯示一個 dock，帶有你釘選的應用程式、所有正在執行的應用程式，以及 apps 按鈕後面的每個應用程式網格，而 `Super + Alt + Space` 和 Omarchy menu 中的 _Apps_ 也會開啟網格。在網格上以滑鼠右鍵點按應用程式，或按下 `Delete`，即可解除安裝該應用程式。點按應用程式開啟它，或將其視窗帶到最前面；再次點按則循環切換它的視窗。中鍵點按開啟新視窗。沿著 dock 拖曳圖示移動它；將正在執行的應用程式拖曳到其他應用程式之間會讓它留在那裡。以滑鼠右鍵點按來將應用程式保留在 dock 中、將它移出 dock 或結束它。dock 會避開全螢幕視窗。以滑鼠右鍵點按 apps 按鈕，將 dock 移動到另一邊緣，或讓它隱藏直到指標抵達它的邊緣。這個位置也在 _Appearance > Dock > Dock Position_ 之下，且 `omarchy dock position left` 和 `omarchy dock autohide on` 可以從終端機設定這兩者。Apps 在 dock 中時，你保留的應用程式在未執行時會以淡化方式顯示。

新的工作區，以及任何你尚未用 `Super + L` 賦予自己版面配置的工作區，會使用預設版面配置。變更預設會將每個沒有視窗的工作區重設為該預設，而有視窗的工作區會保持其已有的版面配置。最小化至 dock 的視窗仍然算作其所離開的工作區上的一個視窗。在 _Appearance > Workspace Layout_ 之下選取它：Tiling、Scrolling 或 Floating。`omarchy-hyprland-workspace-layout-default scrolling` 從終端機設定它。

### 視窗分組

視窗可以用 `Super + G` 進行分組。一旦你進入一個群組，你在該群組作用中時啟動的每個視窗都將屬於該群組。你可以用 `Super + Ctrl + Arrow Left/Right` 或 `Super + Alt + 1/2/3/4` 在這些分組視窗之間移動，直接依序前往分組視窗。

你可以用 `Super + Alt + G` 將視窗移出分組，或透過再次按下 `Super + G` 拆散整個群組。最後，你可以用 `Super + Alt + Arrows` 將群組外的視窗移動到群組內。

### 彈出視窗

你可以用 `Super + O` 將視窗彈出其所屬的工作區。它會將它釘選為一個浮動視窗，跟隨你前往無論你去到哪個工作區。非常適合影片播放器之類的東西。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad 工作區

有一個特殊的全尺寸 scratchpad 工作區，會覆蓋在你目前所在的工作區之上。你用 `Super + S` 存取其上的內容，並用 `Super + Alt + S` 將視窗放置在那裡。

它很適合用於你想快速互動且不用離開目前工作區的控制項或終端機。

### Quake 控制台

最後，有一個半高 Quake 控制台，會從你目前所在工作區之上降下。用 `Super + Grave` 切換它，並用 `Super + Shift + Grave` 將視窗放置在那裡。

它開啟時你的預設 agent 已準備就緒。當控制台持有單一視窗時，它會以降在中央的面板形式降下，而不是橫跨螢幕。放置第二個應用程式在上面，它會回到全寬，這樣兩個程式就有空間並排坐著。

若要將視窗從 scratchpad 或控制台移出，請用類似 `Super + Shift + 1` 的操作將它直接送往另一個工作區。

### 需要一點時間適應！

以這樣的方式導覽你的桌面需要一點時間適應，但一旦你習慣了，要回到傳統以滑鼠驅動的桌面體驗就會很困難！
