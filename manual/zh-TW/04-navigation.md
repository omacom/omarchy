# 導覽

Omarchy 裡的一切都透過鍵盤完成 — _一切！_ 系統剛啟動時，你光靠滑鼠真的什麼都做不了。但你可以按下 `Super + Space` 叫出 Omarchy Menu，從這裡你幾乎能做所有事。

不過，Omarchy menu 本來就不是設計來當作你平常操作系統的主要方式。我們可以比那更快！所有最重要的應用程式都直接綁定到個別的快捷鍵。你用 `Super + Return` 啟動終端機，用 `Super + Shift + Return` 啟動瀏覽器。試著一個接著一個開啟，你就會看到 Hyprland 平鋪佈局的魔法：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

接著你可以按下 `Super + J`，讓它們上下堆疊，而不是左右並排：

 ![navigation-stacked](images/navigation-stacked.webp)

再按一次 `Super + J` 就能讓它們回到左右並排的位置。接著在瀏覽器裡試試 `Super + Shift + Arrow Right` 來交換視窗。

現在試試 `Super + Shift + T` 來啟動 Activity 監控工具。它會以浮動視窗的形式出現。你可以用 `Super + T` 把它變成平鋪（再按一次就會讓它變回浮動）。現在按下 `Super + Shift + F` 開啟檔案管理器。你就會有一個整齊的四分割畫面：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你用 `Super + Arrow` 在想啟用的視窗之間移動。這會切換焦點，並把游標移到新應用程式的中央。在螢幕邊緣時，它會接著移動到那一側的螢幕。

如果你按下 `Super + Shift + 2`，你會把目前聚焦的應用程式移到第二個工作區。`Super + Shift + 1` 則把它移回來。（而 `Super + Shift + Alt + 2` 會把目前聚焦的應用程式移到第二個工作區，但不會切換過去）。

有多台螢幕時，每台螢幕都有自己獨立的 1 到 10 號工作區。`Super + 2` 會前往你所在螢幕的第二個工作區，每台螢幕的頂部列都會顯示自己的工作區以及目前顯示的那一個。`Super + Tab` 會在你所在螢幕的工作區之間循環切換。`Super + Shift + Ctrl + Arrows` 會把你所在的視窗移到那個方向的螢幕上，放到它目前顯示的工作區，而 `Super + Shift + Alt + Arrows` 會把你所在的工作區移到那個方向的螢幕上，如果那邊同編號的工作區是空的，就會沿用同一個編號。螢幕拔掉時，它的工作區不會消失：它們會併到另一台螢幕上，編號排在它既有工作區之後，等螢幕接回來時，又會回到它們原本的編號底下。

如果你按住 `Super` 並用滑鼠點一下視窗，你就能重新安排它的位置。如果你按住 `Super` 並用滑鼠右鍵，你就能自由調整視窗大小。

你用 `Super + W` 或 `Super + Q` 關閉視窗（並用 `Ctrl + Alt + Delete` 關閉所有視窗）。

你也可以用 `Super + F` 進入全螢幕，甚至可以用 `Super + Alt + F` 只佔滿全寬（保留頂部列），或用 `Super + Ctrl + F` 在視窗內全螢幕（很適合 YouTube！）。

### Dwindle 與 scrolling 佈局

Omarchy 的預設佈局叫做 dwindle。它會讓你開啟的所有視窗在單一工作區上隨時都可見，就算必須把視窗縮小也一樣。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以選擇把工作區改成 scrolling 佈局，讓視窗左右並排排列，一直排到顯示畫面可見邊緣之外。你用 `Super + L` 把單一工作區切換成這個佈局。

再按一次 `Super + L` 會把工作區變成浮動模式，視窗可以自由重疊，由你自己擺放，第三次按下則會回到 dwindle。`Super + Alt + L` 則會以相反順序循環切換。本來就會浮動的視窗 — 你用 `Super + T` 彈出來的，或是某個永遠以浮動方式開啟的應用程式 — 在工作區回到平鋪模式時仍會保持浮動。頂部列會用標記來顯示你所在工作區的佈局：正方形代表 dwindle，圓形代表 scrolling，三角形代表浮動。點一下那個標記也可以循環切換佈局。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

這個選擇是以工作區為單位的，而且會保留下來。所以你可以讓工作區 1 保持 dwindle 用來瀏覽、工作區 2 保持 scrolling 用來寫程式，重啟之後它們還是會以那個樣子回來。

如果你想把 scrolling 佈局設為預設值，你可以在 `~/.config/hypr/looknfeel.lua` 裡這樣設定：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### 浮動工作區

浮動工作區的運作方式就像傳統桌面：視窗彼此重疊，由你自己移動和調整大小。每個視窗都會有一條以你的主題顏色顯示的標題列，上面有最小化、最大化和關閉按鈕。`Super + M` 也可以最小化聚焦的視窗。最小化的視窗會等在 dock 裡；點一下它的應用程式就能把它叫回來。點一下視窗就能把它帶到最前面。從任何邊緣或角落都能調整它的大小。點兩下標題列可以最大化視窗，同時仍看得到頂部列，再點兩下就能恢復成原來的大小。

浮動工作區也會顯示一個 dock，裡面有你釘選的應用程式、所有正在執行的程式，以及 apps 按鈕後面收著的全部應用程式格狀清單，`Super + Alt + Space` 和 Omarchy menu 裡的 _Apps_ 也能開啟它。在格狀清單上對某個應用程式按右鍵，或按下 `Delete`，就能解除安裝它。點一下應用程式就能開啟它，或把它的視窗帶到最前面；再點一下會在它的視窗之間循環切換。按中鍵會開啟新視窗。沿著 dock 拖曳圖示可以移動它；把正在執行的應用程式拖進其他圖示之間，就能把它留在那裡。按右鍵可以把應用程式留在 dock 裡、把它從 dock 移走，或結束它。dock 會為全螢幕視窗自動讓路。在 apps 按鈕上按右鍵，可以把 dock 移到另一個邊緣，或讓它隱藏起來，直到指標碰到那個邊緣為止。這個位置也在 _Appearance > Dock > Dock Position_ 底下，`omarchy dock position left` 和 `omarchy dock autohide on` 則可以從終端機設定這兩項。你留在 dock 裡的應用程式在未執行時會以淡色顯示。

新的工作區，以及任何你沒有用 `Super + L` 給它個別指定佈局的工作區，都會使用預設佈局。更改預設值會把每個沒有視窗的工作區都重設為新預設值，而上面有視窗的工作區會保留它目前的佈局。最小化到 dock 的視窗仍然算作它離開的那個工作區上的一個視窗。在 _Appearance > Workspace Layout_ 底下選擇它：Tiling、Scrolling 或 Floating。`omarchy-hyprland-workspace-layout-default scrolling` 可以從終端機設定它。

### 群組視窗

你可以用 `Super + G` 把視窗群組起來。一旦你進入群組，在它啟用期間你啟動的每個視窗都會屬於這個群組。你可以用 `Super + Ctrl + Arrow Left/Right` 在這些群組視窗之間移動，或用 `Super + Alt + 1/2/3/4` 依序直接前往群組視窗。

你可以用 `Super + Alt + G` 把視窗移出群組，或再按一次 `Super + G` 解散整個群組。最後，你可以用 `Super + Alt + Arrows` 把群組外的視窗移進群組裡。

### 彈出視窗

你可以用 `Super + O` 把視窗從它所屬的工作區彈出來。這會把它釘選成一個浮動視窗，無論你去哪個工作區都會跟著你。非常適合影片播放器之類的東西。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad 工作區

有一個特殊的全尺寸 scratchpad 工作區，會疊加在你目前所在的任何工作區之上。你用 `Super + S` 存取上面的東西，並用 `Super + Alt + S` 把視窗放到那裡。

它很適合拿來放控制工具或終端機，讓你不用離開目前的工作區，就能快速與之互動。

### Quake 主控台

最後，還有一個半高 Quake 主控台，會從上方向下滑入，蓋在你目前所在的任何工作區之上。你用 `Super + Grave` 來開關它，並用 `Super + Shift + Grave` 把視窗放到那裡。

它開啟時，你的預設 agent 就已準備就緒。當主控台上只有單一視窗時，它會以置中面板的形式滑下來，而不是佔滿整個螢幕寬度。把第二個應用程式放上去，它就會恢復成全寬，讓這兩個應用程式有空間左右並排。

要把視窗從 scratchpad 或主控台移走，就用像是 `Super + Shift + 1` 這樣的快捷鍵，直接把它送到另一個工作區。

### 是要花點時間習慣啦！

像這樣在桌面間導覽，是要花一點時間才能習慣，但一旦你習慣了，你就會很難再回去用傳統的滑鼠驅動桌面了！
