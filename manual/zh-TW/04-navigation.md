# 導覽

Omarchy 裡的一切都靠鍵盤完成——_每件事都是！_ 系統剛啟動時，你光靠滑鼠真的什麼事都做不了。但你可以按下 `Super + Space` 叫出 Omarchy 選單，從這裡你幾乎什麼都能做。

但 Omarchy 選單甚至不是打算讓你在大多數時候用來操作系統的主要方式。我們可以比那更快！所有最重要的應用程式都直接綁定到各自的快捷鍵上。你用 `Super + Return` 啟動終端機，用 `Super + Shift + Return` 啟動瀏覽器。試著一個接著一個按，你就會看到 Hyprland 平鋪的魔法發揮作用：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

接著你可以按下 `Super + J`，讓它們上下堆疊，而不是並排：

 ![navigation-stacked](images/navigation-stacked.webp)

再按一次 `Super + J`，它們就會回到並排的位置。然後在瀏覽器上試試 `Super + Shift + Arrow Right`，來交換這兩個視窗。

現在試試 `Super + Ctrl + T` 來啟動 Activity 監視器。它會以浮動視窗的形式出現。你可以用 `Super + T` 把它平鋪（再按一次就能讓它重新浮動）。現在按下 `Super + Shift + F` 開啟檔案管理器。你會得到一個整齊的四格配置：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你用 `Super + Arrow` 在你想啟用的視窗之間導覽。這會切換焦點，並把游標移到新應用程式的中心。

如果你按下 `Super + Shift + 2`，你會把目前焦點所在的應用程式移到第二個工作區。`Super + Shift + 1` 則把它移回來。（而 `Super + Shift + Alt + 2` 會把目前焦點所在的應用程式移到第二個工作區，但不切換過去）。

如果你按住 `Super` 並用滑鼠點一下視窗，你就能重新安排它的位置。如果你按住 `Super` 並使用滑鼠右鍵，你就能自由調整視窗大小。

你用 `Super + W` 或 `Super + Q` 關閉視窗（用 `Ctrl + Alt + Delete` 關閉所有視窗）。

你也可以用 `Super + F` 進入全螢幕，甚至只用 `Super + Alt + F` 進入全寬模式（保留頂部列），或用 `Super + Ctrl + F` 在視窗內全螢幕（看 YouTube 時很好用！）。

### Dwindle 與捲動式佈局

Omarchy 的預設佈局叫做 dwindle。它讓你在單一工作區開啟的所有視窗隨時都保持可見，即使必須為此把它們縮小也一樣。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以選擇把一個工作區改成捲動式佈局，在這種佈局下，視窗會並排排列，一路排到顯示器可見邊緣之外。你可以透過 `Super + L` 把單一工作區改成這種佈局。

再按一次 `Super + L` 會把工作區改成浮動式，在那裡視窗可以自由重疊，由你自行擺放，按第三次則回到 dwindle。`Super + Alt + L` 則依相反方向切換這些佈局。一個本來就在浮動的視窗——你用 `Super + T` 彈出來的那種，或總是以浮動方式開啟的應用程式——當工作區回到平鋪時，仍會保持浮動。頂部列會用你所在工作區的佈局來標示它：正方形代表 dwindle，圓形代表捲動式，三角形代表浮動式。點一下那個標記也會循環切換佈局。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

這個選擇是以工作區為單位的，而且會保存下來。所以你可以讓工作區 1 保持 dwindle 用來瀏覽，工作區 2 保持捲動式用來寫程式，重新啟動後它們還會以同樣的樣子回來。

如果你希望把捲動式佈局設為預設，你可以在 `~/.config/hypr/looknfeel.lua` 裡這樣設定：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### 浮動工作區

浮動工作區的運作方式像傳統桌面：視窗彼此重疊，由你自行移動和調整大小。每個視窗都會有一個以你的主題顏色顯示的標題列，上面有最小化、最大化和關閉的按鈕。`Super + M` 也會把焦點所在的視窗最小化。最小化的視窗會在 dock 裡等著；點一下它的應用程式就能把它帶回來。點一下視窗把它帶到最前面。從任何邊緣或角落調整它的大小。連點兩下標題列可以最大化視窗，同時保留頂部列可見，再連點兩下就能取回它原來的大小。

浮動工作區也會顯示一個 dock，裡面有你釘選的應用程式、所有正在執行的程式，以及藏在應用程式按鈕後面的所有應用程式格狀清單，`Super + Alt + Space` 和 Omarchy 選單裡的 _Apps_ 也都能開啟它。對格狀清單上的一個應用程式按右鍵，或按下 `Delete`，就能解除安裝它。點一下應用程式就能開啟它，或把它的視窗帶到最前面；再點一下則可依序切換它的各個視窗。中鍵點一下會開啟新的視窗。沿著 dock 拖曳圖示就能移動它；把一個執行中的應用程式拖到其他應用程式中間，就會把它保留在那裡。按右鍵可以把應用程式保留在 dock 裡、把它移除，或結束它。dock 會為全螢幕視窗讓路。對應用程式按鈕按右鍵，可以把 dock 移到另一個邊緣，或讓它一直隱藏，直到指標碰到它的邊緣為止。這個位置也可以在 _Trigger > Appearance > Dock > Dock Position_ 底下設定，而 `omarchy dock position left` 和 `omarchy dock autohide on` 可以從終端機設定這兩者。你保留在 dock 裡的應用程式，在它們沒有執行時會呈現淡化的樣子。

新的工作區，以及任何你還沒用 `Super + L` 賦予它們自己佈局的工作區，都會使用預設佈局。變更預設值會把每一個沒有視窗的工作區重設為那個佈局，而有視窗在上面的工作區則會保留它現有的佈局。最小化到 dock 裡的視窗，仍然算作它離開的那個工作區上的一個視窗。在 _Trigger > Appearance > Workspace Layout_ 底下挑選它：Tiling、Scrolling 或 Floating。`omarchy-hyprland-workspace-layout-default scrolling` 可以從終端機設定它。

### 將視窗分組

你可以使用 `Super + G` 將視窗分組。一旦你進入一個分組，你在那個狀態啟用時所啟動的每個視窗，都會屬於那個分組。你可以使用 `Super + Ctrl + Arrow Left/Right` 在這些已分組的視窗之間移動，或用 `Super + Alt + 1/2/3/4` 直接依順序前往已分組的視窗。

你可以用 `Super + Alt + G` 把一個視窗移出分組，或再按一次 `Super + G` 把整個分組拆散。最後，你可以用 `Super + Alt + Arrows` 把分組之外的視窗移進來。

### 彈出視窗

你可以用 `Super + O` 把一個視窗從它所屬的工作區彈出來。這會把它釘成一個浮動視窗，無論你前往哪個工作區，它都會跟著你。用在影片播放器之類的東西上很棒。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad 工作區

最後，還有一個特殊的 scratchpad 工作區，它會像 Quake 主控台那樣，從你目前所在的工作區上方降下來。用 `Super + Grave` 或 `Super + S` 切換它，並用 `Super + Shift + Grave` 或 `Super + Alt + S` 在那裡放置一個視窗。

它特別適合用來放一個執行 agent 的終端機，或是你想快速互動但又不想離開目前工作區的控制項。要把視窗移出 scratchpad，直接用像是 `Super + Shift + 1` 之類的快捷鍵，把它送到另一個工作區即可。

當 scratchpad 只放著單一視窗時，它會以置中的面板形式落下，而不是橫跨整個螢幕。在上面放第二個應用程式，它就會回到全寬，這樣兩者就有空間並排坐好。

### 需要一點時間習慣！

要習慣像這樣導覽你的桌面需要一點時間，但一旦習慣了，你會很難再回去用傳統的滑鼠驅動桌面體驗！
