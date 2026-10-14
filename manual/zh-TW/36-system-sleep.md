# 系統睡眠

Omarchy 預設啟用暫停（suspend）和休眠（hibernation），但如果你的機器在使用其中任何一種時遇到問題，可以把它們關閉。

### 電源設定檔

在筆電上，Omarchy 會分別記住插電時和用電池時的電源設定檔，並在你插拔電源時自動切換。開箱即用的設定是插電時用效能模式，用電池時用平衡模式。

你可以用 `omarchy powerprofiles list` 看看你的機器提供哪些選項，並用 `omarchy powerprofiles set autodetect power-saver` 設定你目前狀態下想要的那個。若要在不拔掉任何東西的情況下設定另一個狀態，直接指名即可：`omarchy powerprofiles set battery power-saver`。你選的設定就是下次進入該狀態時會得到的設定。

### 切換暫停

在終端機執行 `omarchy toggle suspend` 即可切換暫停功能。這只是在 _系統_（或 `Super + Esc`）之下顯示／隱藏該選項，然後你可以看看它在你的系統上是否能穩定運作。如果不行，再用同一個指令把它藏回去。

### 切換休眠

在終端機執行 `omarchy hibernation setup` 即可設定休眠。休眠會在你的開機磁碟上建立一個 /swap 子卷，大小等於你的實體 RAM，所以請確保你有足夠的剩餘空間。在一台 32GB 的機器上，你永遠需要為這個子卷預留 32GB 以上的可用空間。休眠也需要預設的 Limine 開機載入程式。

設定完成後，你會在 _系統_（或 `Super + Esc`）之下看到休眠選項，然後可以看看它在你的系統上是否能穩定運作。如果不行，執行 `omarchy hibernation remove` 即可再次移除它。
