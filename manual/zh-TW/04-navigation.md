# 導覽

在 Omarchy 中，一切都透過鍵盤完成 — _一切！_ 系統首次啟動時，你真的光靠滑鼠什麼也做不了。但你可以按下 `Super + Space` 叫出 Omarchy Menu，從這裡你幾乎可以做任何事。

但 Omarchy menu 甚至根本不是設計來在大多數時候作為操作系統的主要方式。我們可以比那更快！所有最重要的應用程式都直接綁定到個別快捷鍵。你可以用 `Super + Return` 啟動終端機，用 `Super + Shift + Return` 啟動瀏覽器。試著接連啟動這兩者，你就會看到 Hyprland 平鋪功能的神奇之處：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

接著你可以按下 `Super + J`，將它們上下堆疊，而不是並排：

 ![navigation-stacked](images/navigation-stacked.webp)

再次按下 `Super + J`，即可讓它們回到並排位置。然後在瀏覽器中試試 `Super + Shift + Arrow Right` 來交換視窗。

現在試試 `Super + Shift + T` 來啟動 Activity monitor。它會以浮動視窗的形式出現。你可以用 `Super + T` 將它平鋪（再按一次則讓它再次浮動）。現在按下 `Super + Shift + F` 開啟檔案管理器。你將得到一個整齊的四分布局：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你用 `Super + Arrow` 在想要啟用的視窗之間導覽。這會切換焦點，並將游標移到新應用程式的中央。在螢幕邊緣時，它會繼續前往該側的螢幕。

如果你按下 `Super + Shift + 2`，你會將目前聚焦的應用程式移到第二個工作區。`Super + Shift + 1` 會將它移回。（而 `Super + Shift + Alt + 2` 會將目前聚焦的應用程式移到第二個工作區，但不會切換過去。）

有多個螢幕時，每個螢幕都有各自的 1 到 10 號工作區。`Super + 2` 會前往你所在螢幕的第二個工作區，而且每個螢幕的頂部列都會顯示它自己的工作區，以及它正在顯示的那一個。`Super + Tab` 會在你所在螢幕的工作區之間循環切換。`Super + Shift + Ctrl + Arrows` 會將你所在的視窗移到該方向的螢幕上它正在顯示的工作區，而 `Super + Shift + Alt + Arrows` 會將你所在的工作區移到該方向的螢幕，在那裡如果該編號是空的，它就會使用相同的編號。當你拔掉一個螢幕時，它會保留它的工作區：它們會加入另一個螢幕的工作區，編號排在該螢幕已有的工作區之後，而當螢幕重新接回時，它們會回到原來的編號。

如果你按住 `Super` 並用滑鼠點擊視窗，你就能重新安排它所在的位置。如果你按住 `Super` 並使用滑鼠右鍵，你可以自由調整視窗大小。

你用 `Super + W` 或 `Super + Q` 關閉視窗（並用 `Ctrl + Alt + Delete` 關閉所有視窗）。

你也可以用 `Super + F` 進入全螢幕，甚至可以用 `Super + Alt + F` 只進入全寬模式（保留頂部列），或用 `Super + Ctrl + F` 在視窗內全螢幕（很適合 YouTube！）。

### Dwindle vs 捲動版面配置

Omarchy 的預設版面配置稱為 dwindle。它讓你在單一工作區上開啟的所有視窗始終保持可見，即使必須將它們縮小也一樣。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以選擇將工作區改為捲動版面配置，讓視窗並排排列，延伸到顯示器可見邊緣之外。你透過 `Super + L` 將單一工作區切換為這種版面配置。

再次按下 `Super + L` 會使工作區轉為浮動，視窗會自由重疊，由你自行放置，第三次按下則讓它回到 dwindle。`Super + Alt + L` 會以相反方向依序切換它們。一個本來就會浮動的視窗 — 你用 `Super + T` 彈出的視窗，或總是以浮動方式開啟的 app — 在工作區回到平鋪模式時，會保持浮動。頂部列會以其版面配置標示你所在的工作區：正方形代表 dwindle，圓形代表 scrolling，三角形代表浮動。點擊該標記也會循環切換版面配置，配有此鍵的筆記型電腦上的顯示鍵也會這樣做。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

這項選擇是依工作區分別設定的，而且會保留下來。所以你可以讓工作區 1 使用 dwindle 來瀏覽，讓工作區 2 使用 scrolling 來寫程式，重新啟動後它們都會以那樣的方式回來。

如果你希望將捲動版面配置用作預設，你可以在 `~/.config/hypr/looknfeel.lua` 中這樣設定：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### 浮動工作區

浮動工作區的運作方式就像傳統桌面：視窗彼此重疊，由你自行移動和調整大小。每個視窗都有一個以你的主題色彩顯示的標題列，附有最小化、最大化和關閉的按鈕。`Super + M` 也會將聚焦的視窗最小化。最小化的視窗會在 dock 中等待；點擊它的 app 即可將它帶回。點擊視窗即可將它移到最前面。從任何邊緣或角落調整它的大小。在標題列上按兩下，即可最大化視窗，同時讓頂部列保持可見，再按兩下即可恢復它原來的大小。Chrome 和其他基於 Chromium 的瀏覽器、Disks 和 Document Viewer 會跳過標題列，改用它們自己的標頭；`Super + Alt + F` 將它們最大化，而 `Super + M` 將它們最小化。

浮動工作區也會顯示一個 dock，其中包含你釘選的 app、所有正在執行的項目，以及 apps 按鈕後方每個 app 的格狀檢視，`Super + Alt + Space` 和 Omarchy menu 中的 _Apps_ 也能開啟它。在格狀檢視中以滑鼠右鍵點擊 app，或按下 `Delete`，即可將它解除安裝。點擊 app 即可開啟它，或將它的視窗移到最前面；再次點擊則可在它的視窗之間循環切換。Files 只會帶回你所在工作區中的一個視窗，否則就會開啟一個新視窗，而 Terminal 和 Agent 則總是啟動另一個，不過最小化的視窗會先回來。以滑鼠中鍵點擊會開啟新視窗。沿著 dock 拖曳圖示即可移動它；將正在執行的 app 拖曳到其他項目之中，便會讓它留在那裡。按滑鼠右鍵即可將 app 留在 dock 中、將它從 dock 移除，或結束它。dock 會避開全螢幕視窗。以滑鼠右鍵點擊 apps 按鈕，即可將 dock 移到另一個邊緣，或讓它隱藏，直到指標抵達其邊緣為止。位置也在 _Appearance > Dock > Dock Position_ 下，而 `omarchy dock position left` 和 `omarchy dock autohide on` 都能從終端機設定這兩者。你留在 dock 中的 app 在未執行時會淡化顯示。

新的工作區，以及任何你尚未用 `Super + L` 給予其專屬版面配置的工作區，都使用預設版面配置。變更預設會將每個沒有視窗的工作區重置為該預設，而上面有視窗的工作區會保留它目前的版面配置。最小化到 dock 的視窗仍計為它所離開的工作區上的一個視窗。在 _Appearance > Workspace Layout_ 下選取它：Tiling、Scrolling 或 Floating。`omarchy hyprland workspace layout default scrolling` 會從終端機設定它。

### 將視窗分組

視窗可以用 `Super + G` 分組。一旦你身處一個群組中，在該群組作用期間你啟動的每個視窗都會屬於該群組。你可以使用 `Super + Ctrl + Arrow Left/Right` 在這些已分組的視窗之間移動，或使用 `Super + Alt + 1/2/3/4` 依順序直接前往已分組的視窗。

你可以用 `Super + Alt + G` 將視窗移出群組，或再次按下 `Super + G` 解散整個群組。最後，你可以用 `Super + Alt + Arrows` 將群組外的視窗移入其中。

### 彈出視窗

你可以用 `Super + O` 將視窗從其工作區指派中彈出。那會將它釘選為浮動視窗，無論你前往哪個工作區，它都會跟著你。非常適合影片播放器之類的東西。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad 工作區

有一個特殊的全尺寸 scratchpad 工作區，它會疊加在你目前所在的任何工作區之上。你用 `Super + S` 存取其中的內容，並用 `Super + Alt + S` 將視窗放到那裡。

對於你想快速互動、又不想離開目前工作區的控制項或終端機來說，它很好用。

### Quake 主控台

最後，有一個半高的 Quake 主控台，它會在你目前所在的任何工作區上方下拉。用 `Super + Grave` 切換它，並用 `Super + Shift + Grave` 將視窗放到那裡。

它第一次開啟時，會啟動你的預設 agent，或如果你尚未選擇一個，它會要求你選擇一個。當主控台只容納單一視窗時，它會以置中的面板形式下拉，而不是橫跨螢幕。在上面放第二個 app，它就會回到全寬，這樣兩者就有空間並排放置。

若要將視窗從 scratchpad 或主控台移走，請用像是 `Super + Shift + 1` 這樣的快捷鍵，將它直接傳送到另一個工作區。

### 需要一些時間習慣！

像這樣導覽你的桌面需要一點時間來習慣，但一旦你習慣了，就很難再回去傳統的滑鼠驅動桌面體驗！
